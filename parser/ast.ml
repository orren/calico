(*  Ast.ml
 *
 *  The abstract syntax tree to be populated by this parser.
 *  This reflects the grammar for annotated C programs specified
 *  here: https://bitbucket.org/orren/calico/wiki/parser_spec.md
 *)

(* Annotated C functions in context *)
(* type parameter = CParam of string * string * bool *)
(* type return_type = string *)
(* type fun_name = string *)
(* type fun_body = string *)

(* type prog_context = ProgContext of string list *)
type pannot = string * string list
type annotation_pair = APair of pannot list * string
type param_info = string * string (* name, type *)
type fun_info = string * string * string (* name, kind, type *)
type annotated_comment = AComm of string * fun_info * (param_info list) * (annotation_pair list)
type function_definition = string (* CFun of return_type * fun_name * parameter list * fun_body *)
type annotated_fun = AFun of annotated_comment * function_definition
type program_element = SrcStr of string | ComStr of string (* | annotated_fun *)
type annotated_program = program_element list

let str_of_pannot (annot: pannot) : string =
  match annot with
    | (s, lst) -> "CALL TO:  " ^ s ^ ", ARGS: " ^ (String.concat ", " lst) ^ " "

let str_of_pair (p : annotation_pair) : string =
  match p with
    | APair (annot, str) -> "\nIN ANNOTATIONS: " ^
      (String.concat "\n" (List.map str_of_pannot annot)) ^ "\nOUT ANNOTATION: " ^ str ^ "\n"

let str_of_funinfo (funinfo: fun_info) : string =
  match funinfo with
    | (name, kind, ty) ->
      "Function name: " ^ name ^ " Return Type: " ^ ty ^ " Fun kind: " ^ kind

let str_of_param (p : param_info) : string =
  match p with
    | (name, ty) ->
      "Param name: " ^ name ^ " Type: " ^ ty

let str_of_annot (ac : annotated_comment) : string =
  match ac with
    | AComm (str, funinfo, params, apairs) ->
      ("COMMENT TEXT: \n" ^ str ^ "\nANNOTS: " ^ (String.concat "\n"
                                                    (List.map str_of_pair apairs))) ^ "\n" ^
        (str_of_funinfo funinfo) ^ "\nPARAMS: " ^ (String.concat "\n"
                                                     (List.map str_of_param params)) ^ "\n"

let str_of_afun (af: annotated_fun) : string =
  match af with
    | AFun (acomm, fundef) -> (str_of_annot acomm) ^ "SRCSTR: " ^ fundef

let str_of_pelem (e : program_element) : string =
  match e with
    | SrcStr (str) -> "SRC:\n" ^ str
    | ComStr (str) -> "COM:\n" ^ "/*" ^ str ^ "*/"

let str_of_prog (p : annotated_program) : string =
  String.concat "\n" (List.map str_of_pelem p)
