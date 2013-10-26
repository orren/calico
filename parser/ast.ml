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
type in_annotation = InAnnot of string * in_annotation | End
type annotation_pair = APair of in_annotation * string
type annotation_pairs = Pairs of annotation_pair * annotation_pairs | Ends
type annotated_comment = AComm of string * annotation_pairs
type function_definition = string (* CFun of return_type * fun_name * parameter list * fun_body *)
type annotated_fun = AFun of annotated_comment * function_definition
(* type afun_with_context = ProgTriple of prog_context * annotated_fun * prog_context *)
type annotated_program = TopProg of string list


let rec str_of_annot (a : in_annotation) : string =
  match a with
    | End -> ""
    | InAnnot (str, annot) -> str ^ (str_of_annot annot)

let str_of_pair (p : annotation_pair) : string =
  match p with
      APair (annot, str) -> (str_of_annot annot) ^ str

let rec str_of_pairs (ps : annotation_pairs ) : string =
  match ps with
    | Ends -> ""
    | Pairs (pair, pairs) -> (str_of_pair pair) ^ (str_of_pairs pairs)

let str_of_annot (ac : annotated_comment) : string =
  match ac with
    | AComm (str, apairs) -> str ^ (str_of_pairs apairs)

let str_of_prog (p : annotated_program) : string =
  match p with
    | TopProg(lst) -> String.concat "" lst
