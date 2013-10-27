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
type annotated_comment = AComm of string * (annotation_pair list)
type function_definition = string (* CFun of return_type * fun_name * parameter list * fun_body *)
type annotated_fun = AFun of annotated_comment * function_definition
(* type afun_with_context = ProgTriple of prog_context * annotated_fun * prog_context *)
type annotated_program = TopProg of string list

let str_of_pannot (annot: pannot) : string =
  match annot with
    | (s, lst) -> "CALL TO:" ^ s ^ ", ARGS: " ^ (String.concat ", " lst)

let str_of_pair (p : annotation_pair) : string =
  match p with
    | APair (annot, str) -> "IN ANNOTATIONS: " ^
      (String.concat ", " (List.map str_of_pannot annot)) ^ "OUT ANNOTATIONS: " ^ str

let str_of_annot (ac : annotated_comment) : string =
  match ac with
    | AComm (str, apairs) ->
      "ACOMM: " ^ ("COMMTEXT: " ^ str ^ "ANNOTS: " ^ (String.concat ", " (List.map str_of_pair apairs)))

let str_of_prog (p : annotated_program) : string =
  match p with
    | TopProg(lst) -> String.concat "" lst
