open Printf
open List
open Ast

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

let call_inner_function (procNum: int) (name: string) (kind: funKind) (ty: string)
                        (params: param_info list) (recover : bool) : string =
  let index = string_of_int procNum in
  let get_p_name = (fun p -> match p with (name, _) -> name) in
  let all_names = (map get_p_name params) in
  "// < call_inner_function\n        " ^
    begin match kind with
      | Pure        -> (if not recover then "*t_result" ^ index ^ " = __" else "") ^ name ^
                       "(" ^ String.concat ", " all_names ^ ")"
      | SideEffect  -> "__" ^ name ^ "(" ^ String.concat ", " all_names ^ ")"
      | PointReturn -> ty ^ " temp_t_result = __" ^ name ^ "(" ^
        String.concat ", " all_names ^
        ");\n        memcpy(t_result" ^ index ^ ", temp_t_result, result_sizes[" ^ index ^ "])"
    end
  ^ ";\n// call_inner_function >\n"

let output_transformation (procNum : int) (return_type : string)
                          (prop : out_annot) : string =
  let index = string_of_int procNum in
  "// < output_transformation\n    " ^
    begin match prop with
      | (prop_name, Pure)        -> "*g_result" ^ index ^ " = " ^
          Str.global_replace (Str.regexp "result") "*orig_result" prop_name
      | (prop_name, SideEffect)  -> prop_name
      | (prop_name, PointReturn) -> return_type ^ " *temp_g_result = " ^
          Str.global_replace (Str.regexp "result") "orig_result" prop_name ^
        ";\n        memcpy(g_result" ^ index ^ ", temp_g_result, result_sizes[" ^ index ^ "])"
    end
  ^ ";\n// output_transformation >\n"

let input_transformation (param : param_info) (prop : param_annot) : string =
  begin match (param, prop) with
    | ((param_name, TyStr(ty)), (name, kind, inputs)) ->
      let prop_expr = name ^ "(" ^ (String.concat ", " inputs) ^ ")" in
      "// < input_transformation\n        " ^
        begin match kind with
          | Pure
          | PointReturn -> if String.compare param_name name = 0 ||
                              String.compare name "id" = 0
                           then ""
                           else param_name ^ " = " ^ prop_expr
          | SideEffect  -> prop_expr
        end
      ^ ";\n// input_transformation >"
  end

let recover_t_result (procNum : int) (aset : annotation_set) : string =
  begin match aset with
    | ASet(_, _, Some(expr, _)) -> "*t_result" ^ string_of_int procNum ^ " = " ^ expr ^ ";\n"
    | ASet(_, _, None)          -> ""
  end

(* Requires param and property list *)
let transformed_call (f : annotated_comment) (procNum : int) : string =
  let index = string_of_int procNum in
  begin match f with
    | AComm(_, (name, kind, TyStr(ty)), params, asets) ->
        let aset = nth asets procNum in
        let (pAnnots, recover) = begin match aset with
          | ASet (pas, _, Some (_)) -> (pas, true)
          | ASet (pas, _, None)     -> (pas, false)
        end in
        "    if (procNum == " ^ index ^ ") {\n" ^
        "        t_result" ^ index ^ " = shmat(shmids[" ^ index ^ "], NULL, 0);\n" ^
        (* apply input transformations *)
        String.concat ";\n        "
          (map2 input_transformation params pAnnots) ^
        (* run inner function *)
        (call_inner_function procNum name kind ty params recover) ^
        (* recover result if necessary *)
        recover_t_result procNum aset ^
        (* clean up *)
        "        shmdt(t_result" ^ index ^ ");\n" ^
        "        exit(0);\n" ^
        "    }\n"
  end

let fprint_results (procNum : int) (fun_kind : funKind) (return_type : string) : string =
  let index = string_of_int procNum in
  let indicator = begin match return_type with
                  | "int"    -> "%d"
                  | "double" -> "%f"
                  | "float"  -> "%f"
                  | _        -> ""
                  end in
  begin match indicator with
  | "" -> ""
  | _  -> "        printf(\"g(f(x)): " ^ indicator ^ "\\nf(t(x)): " ^ indicator ^
          "\\n\", *g_result" ^ index ^ ", *t_result" ^ index ^ ");"
  end

let property_assertion (return_type : string) (fun_kind : funKind)
    (prop : annotation_set) (procNum : int) : string =
  let index = string_of_int procNum in
  begin match prop with
    | ASet(param_props, out_prop, recover) ->
      "    t_result" ^ index ^ " = shmat(shmids[" ^ index ^ "], NULL, 0);\n    " ^
      begin match recover with
        | None          -> output_transformation procNum return_type out_prop
        | Some(expr, _) -> "*g_result" ^ index ^ " = " ^ expr ^ ";\n    "
      end
      ^ "    if (*g_result" ^ index ^ " != *t_result" ^ index ^ ") {\n" ^
      "        printf(\"a property has been violated:\\ninput_prop: " ^
      (String.concat ", " (map name_of_param_annot param_props)) ^
      "\\noutput_prop: " ^ (name_of_out_annot out_prop) ^ "\\n\");\n" ^
      fprint_results procNum fun_kind return_type ^
      "\n    }\n"
  end

let initialize_tg_results (default : string) (set : annotation_set) (procNum : int) : string =
  let theType = begin match set with
    | ASet(_, _, Some (_, TyStr(ty))) -> ty
    | ASet(_, _, None)                -> default
  end in
  let index = string_of_int procNum in
  "result_sizes[" ^ index ^ "] = sizeof(" ^ theType ^ ");\n    " ^
  theType ^ " *t_result" ^ index ^ " = NULL;\n    " ^
  theType ^ " *g_result" ^ index ^ " = malloc(result_sizes[" ^ index ^ "]);\n"

let instrument_function (f : program_element) : string =
  begin match f with
    | ComStr(s) -> "/*\n" ^ s ^ "*/\n"
    | SrcStr(s) -> s
    | AFun (AComm(comm_text, (name, k, TyStr(ty)), params, asets) as acomm, header, funbody) ->
      (* each child process will have a number *)
      let child_indexes = (range_list 0 ((length asets) - 1) []) in
      let call_to_inner = name ^ "(" ^ String.concat ", "
        (map fst params) ^ ")" in
      let dereffed_type = (Str.global_replace (Str.regexp "*") "" ty) in
      (* original version of the function with underscores *)
      ty ^ " __" ^ name ^ header ^ funbody ^ "\n\n" ^
        (* instrumented version *)
        (* TODO: comm_text produces bad comments... would be most useful if
           original annotations were included, or if left off entirely
        comm_text ^ "\n" ^ *)
        ty ^ " " ^ name ^ header ^ " {\n" ^
        "    int numProps = " ^ string_of_int (length asets) ^ ";\n" ^
        "    size_t result_sizes[numProps];\n" ^

        (* fork *)

        "    int* shmids = malloc(numProps * sizeof(int));\n" ^
        "    int procNum = -1;\n" ^ (* -1 for parent, 0 and up for children *)
        "    int i;\n" ^

        (* TODO: how to initialize for a pure struct return type? *)
        begin match k with
          | Pure
          | PointReturn -> "    " ^ dereffed_type ^ " *orig_result = malloc(sizeof(" ^
                           dereffed_type ^ "));\n"
          | SideEffect  -> "" (* no need to return anything *)
        end
        ^ "\n    " ^ String.concat "\n    "
        (map2 (initialize_tg_results dereffed_type) asets child_indexes) ^

        "\n" ^
        "    for (i = 0; i < numProps; i += 1) {\n" ^
        "        if (procNum == -1) {\n" ^
        "            shmids[i] = shmget(key++, result_sizes[i], IPC_CREAT | 0666);\n" ^
        "            if (0 == fork()) {\n" ^
        "                procNum = i;\n" ^
        "                break;\n" ^
        "            }\n" ^
        "        }\n" ^
        "    }\n\n" ^

        (* parent runs original inputs and waits for children *)
        "    if (procNum == -1) {\n        " ^
        begin match k with
          | Pure        -> "*orig_result = __" ^ call_to_inner
          | PointReturn -> ty ^ " temp_orig_result = __" ^ call_to_inner ^
            ";\n        memcpy(orig_result, temp_orig_result, sizeof(" ^ ty ^ "))"
          | SideEffect  -> call_to_inner
        end
        ^ ";\n        for (i = 0; i < numProps; i += 1) {\n" ^
        "            wait(NULL);\n" ^
        "        }\n" ^
        "    }\n\n" ^

        (* children run transformed inputs and record the result in shared memory *)
        String.concat "\n" (map (transformed_call acomm) child_indexes) ^ "\n" ^

        (* make assertions about the results *)
        String.concat "\n" (map2 (property_assertion ty k) asets child_indexes) ^ "\n" ^

        (* cleanup *)
        "    free(shmids);\n" ^
        "    return " ^ (if String.compare ty "void" = 0 then "" else
                        (if k == Pure then "*" else "") ^ "orig_result") ^
        ";\n" ^ "}"
  end

let rec name_out_path (modif : string) (path : string list) : string = 
  begin match path with
    | []      -> raise (Failure "")
    | [x]     -> modif ^ x
    | x :: xs -> x ^ "/" ^ (name_out_path modif xs)
  end

let write_source (sut: sourceUnderTest) : unit =
  (* TODO: actually implement indentation tracking instead of just guessing *)
  let path = Str.split (Str.regexp "/") sut.file_name in
  let out = open_out (name_out_path "calico_gen_" path) in
  fprintf out "#include \"calico_prop_library.h\"\n%s\n"
    (String.concat "\n" (map instrument_function sut.elements));
  close_out out;
