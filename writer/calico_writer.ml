open Printf
open List
open Ast

let key_number : string = "9847"

let rec repeat (s : string) (n : int) : string =
  if n <= 1 then s else s ^ (repeat s (n - 1))

let fst (tup : 'a * 'b) : 'a =
  begin match tup with
    | (x, _) -> x
  end

let snd (tup : 'a * 'b) : 'b =
  begin match tup with
    | (_, x) -> x
  end

let lbr (indent : int) : string =
  ";\n" ^ (repeat "    " indent)

let rec range_list (i : int) (j : int) (acc : int list) : int list =
  if i > j then acc else range_list i (j - 1) (j :: acc)

let rec merge (l1:'a list) (l2:'a list) : 'a list =
  begin match (l1, l2) with
    | ([], []) -> []
    | ([], l) -> l
    | (l, []) -> l
    | ((n1 :: rest1), (n2 :: rest2)) -> n1 :: n2 :: (merge rest1 rest2)
  end ;;

let write_param (param : param_info) : string =
  match param with
    | (name, TyStr(ty)) -> ty ^ " " ^ name

let call_inner_function (name: string) (kind: funKind) (ty: string) (params: param_info list) : string =
  let get_p_name = (fun p -> match p with (name, _) -> name) in
  let all_names = (map get_p_name params) in
  "// < call_inner_function\n        " ^
    begin match kind with
      | Pure        -> "*t_result = __" ^ name ^ "(" ^ String.concat ", " all_names ^ ")"
      | SideEffect  -> "__" ^ name ^ "(" ^ String.concat ", " all_names ^ ")"
      | PointReturn -> ty ^ " temp_t_result = __" ^ name ^ "(" ^
        String.concat ", " all_names ^ ");\n        memcpy(t_result, temp_t_result, result_size)"
    end
  ^ ";\n// call_inner_function >\n"

let deref_var (s : string) (v : string) : string =
  Str.global_replace (Str.regexp v) "orig_result" s

let output_transformation (return_type : string) (prop : (string * funKind)): string =
  "// < output_transformation\n    " ^
    begin match prop with
      | (prop_name, Pure)        -> "g_result = " ^ (deref_var prop_name "result")
      | (prop_name, SideEffect)  -> prop_name
      | (prop_name, PointReturn) -> return_type ^ " *temp_g_result = " ^
        (deref_var prop_name "result") ^
        ";\n        memcpy(&g_result, temp_g_result, result_size)"
    end
  ^ ";\n// output_transformation >\n"

let input_transformation (param : param_info) (prop : param_annot) : string =
  begin match (param, prop) with
    | ((param_name, TyStr(ty)), (name, kind, inputs)) ->
      let prop_expr = name ^ "(" ^ (String.concat ", " inputs) ^ ")" in
      "// < input_transformation\n        " ^
        begin match kind with
          | Pure -> if String.compare param_name name = 0
                    then ""
                    else param_name ^ " = " ^ prop_expr
          | PointReturn -> if String.compare param_name name = 0
                           then ""
                           else param_name ^ " = " ^ prop_expr
          | SideEffect  -> prop_expr
        end
      ^ ";\n// input_transformation >"
  end

let transform_of_properties (ty: string)
    (params: param_info list) (apair: annotation_pair) : (string * string) =
  match apair with
    | APair(param_annots, out_annot) ->
            let in_transform = String.concat ";\n        "
              (map2 input_transformation params param_annots) ^ ";\n" in
            let out_transform = output_transformation ty out_annot in
            (in_transform, out_transform)

(* Requires param and property list *)
let transformed_call (f : annotated_comment) (procNum : int) : string =
  begin match f with
    | AComm(_, (name, kind, TyStr(ty)), params, apairs) ->
      let (in_transform, out_transform) = transform_of_properties ty params (nth apairs procNum) in
        "    if (procNum == " ^ (string_of_int procNum) ^ ") {\n" ^
        "        int shmid = shmget(key + procNum, result_size, 0666);\n" ^
        "        t_result = shmat(shmid, NULL, 0);\n" ^
        (* apply input transformations *)
        in_transform ^
        (* run inner function *)
        (call_inner_function name kind ty params) ^
        (* apply output transformations *)
        "        shmdt(t_result);\n" ^
        "        exit(0);\n" ^
        "    }\n"
  end

let fprint_results (fun_kind : funKind) (return_type : string) : string =
  let indicator = begin match return_type with
                  | "int"    -> "%d"
                  | "double" -> "%f"
                  | "float"  -> "%f"
                  | _        -> ""
                  end in
  begin match indicator with
  | "" -> ""
  | _  -> "        printf(\"g(f(x)): " ^ indicator ^ "\\nf(t(x)): " ^ indicator ^
          "\\n\", g_result, *t_result);"
  end

let property_assertion (return_type : string) (fun_kind : funKind)
                       (prop : annotation_pair) (procNum : int) : string =
  begin match prop with
    | APair (param_props, out_prop) ->
      "    t_result = shmat(shmids[" ^ (string_of_int procNum) ^ "], NULL, 0);\n    " ^
      output_transformation return_type out_prop ^
      "    if (" ^
    (* TODO: for compound data types, we need the tester to supply a notion of equality *)
        begin match fun_kind with
          | PointReturn -> "*"
          | Pure        -> ""
          | SideEffect  -> ""
        end
      ^ "g_result != *t_result) {\n" ^
        "        printf(\"a property has been violated:\\ninput_prop: " ^
        (String.concat ", " (map name_of_param_annot param_props)) ^
        "\\noutput_prop: " ^ (name_of_out_annot out_prop) ^ "\\n\");\n" ^
        fprint_results fun_kind return_type ^
        "\n    }\n"
  end

let instrument_function (f : program_element) : string =
  begin match f with
    | ComStr(s) -> s
    | SrcStr(s) -> s
    | AFun (AComm(comm_text, (name, k, TyStr(ty)), params, apairs),
            funbody) ->
      (* TODO: Don't do this: *)
      let acomm = AComm(comm_text, (name, k, TyStr(ty)), params, apairs) in
      (* each child process will have a number *)
      let child_indexes = (range_list 0 ((length apairs) - 1) []) in
      let call_to_inner = name ^ "(" ^ String.concat ", "
        (map fst params)^ ")" in
      let param_decl = "(" ^ String.concat ", " (map write_param params) ^ ")" in
      (* original version of the function with underscores *)
      ty ^ " __" ^ name ^ param_decl ^ funbody ^ "\n\n" ^
        (* instrumented version *)
        (* TODO: comm_text produces bad comments... would be most useful if
           original annotations were included, or if left off entirely
        comm_text ^ "\n" ^ *)
        ty ^ " " ^ name ^ param_decl ^ " {\n" ^

        (* fork *)
        "    int key = " ^ key_number ^ ";\n" ^ (* why this number? *)
        "    size_t result_size = sizeof(" ^ ty ^ ");\n" ^
        "    int numProps = " ^ string_of_int (length apairs) ^ ";\n" ^
        "    int* shmids = malloc(numProps * sizeof(int));\n" ^
        "    int procNum = -1;\n" ^ (* -1 for parent, 0 and up for children *)
        "    int i;\n" ^
        "    " ^ ty ^ " orig_result = " ^
        (if k = PointReturn then "NULL" else "0") ^
        begin match k with
          | Pure -> ";\n    " ^ ty ^ "* t_result = 0;\n    " ^ ty ^ " g_result = 0"
          | SideEffect -> "" (* This case produces invalid code *)
          | PointReturn -> ";\n    " ^ ty ^ " t_result = NULL;\n    " ^
                                       ty ^ " g_result = NULL;"
        end
        ^ ";\n\n" ^
        "    for (i = 0; i < numProps; i += 1) {\n" ^
        "        if (procNum == -1) {\n" ^
        "            shmids[i] = shmget(key + i, result_size, IPC_CREAT | 0666);\n" ^
        "            if (0 == fork()) {\n" ^
        "                procNum = i;\n" ^
        "                break;\n" ^
        "            }\n" ^
        "        }\n" ^
        "    }\n\n" ^

        (* parent runs original inputs and waits for children *)
        "    if (procNum == -1) {\n        " ^
        begin match k with
          | Pure        -> "orig_result = __" ^ call_to_inner
          | PointReturn -> ty ^ " temp_orig_result = __" ^ call_to_inner ^
            ";\n        memcpy(orig_result, temp_orig_result, result_size)"
          | SideEffect  -> call_to_inner
        end
        ^ ";\n        for (i = 0; i < numProps; i += 1) {\n" ^
        "            wait(NULL);\n" ^
        "        }\n" ^
        "    }\n\n" ^

        (* children run transformed inputs and transform the result *)
        String.concat "\n" (map (transformed_call acomm) child_indexes) ^ "\n" ^

        (* make assertions about the results *)
        String.concat "\n" (map2 (property_assertion ty k) apairs child_indexes) ^ "\n" ^

        (* cleanup *)
        "    free(shmids);\n" ^
        "    return orig_result;\n" ^
        "}"
  end

let write_source (sut: sourceUnderTest) : unit =
  (* TODO: actually implement indentation tracking instead of just guessing *)
  let out = open_out ("calico_gen_" ^ sut.file_name) in
  fprintf out "#include \"calico_prop_library.h\"\n%s\n"
    (String.concat "\n\n" (map instrument_function sut.elements));
  close_out out;
