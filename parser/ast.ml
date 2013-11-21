(*  Ast.ml
 *
 *  The abstract syntax tree to be populated by this parser.
 *  This reflects the grammar for annotated C programs specified
 *  here: https://bitbucket.org/orren/calico/wiki/parser_spec.md
 *)

(* Annotated C functions in context *)

type funKind = Pure
               | SideEffect
               | PointReturn
type ty_str = TyStr of string
type param_annot = string * funKind * string list (* name, kind, input list *)
type out_annot = string * funKind * (string * string) option
type annotation_pair = APair of param_annot list * out_annot
type param_info = string * ty_str (* name, type *)
type fun_info = string * funKind * ty_str (* name, kind, type *)
type annotated_comment = AComm of
    string * fun_info * (param_info list) * (annotation_pair list)
type function_body = string
type program_element = SrcStr of string
                       | ComStr of string
                       | AFun of annotated_comment * function_body

type sourceUnderTest = { file_name: string;
                         elements: program_element list }

let name_of_param_annot (p: param_annot) : string =
  match p with
    | (name, _, _) -> name

let name_of_out_annot (p: out_annot) : string =
  match p with
    | (name, _, _) -> name

let str_of_kind (k: funKind) : string =
  match k with
    | PointReturn -> "PointReturn"
    | Pure -> "Pure"
    | SideEffect -> "SideEffect"

let str_of_pannot (annot: param_annot) : string =
  match annot with
    | (name, kind, lst) -> "CALL TO:  " ^ name ^ ", KIND:  " ^
      (str_of_kind kind) ^ "\n ARGS:  " ^ (String.concat ", " lst) ^ " "

let str_of_pair (p: annotation_pair) : string =
  match p with
    | APair (annot, (str, _, None)) -> "\nIN ANNOTATIONS: " ^
      (String.concat "\n" (List.map str_of_pannot annot)) ^ "\nOUT ANNOTATION: " ^ str ^ "\n"
    | APair (annot, (str, _, Some(s, ty))) -> "\nIN ANNOTATIONS: " ^
      (String.concat "\n" (List.map str_of_pannot annot)) ^ "\nOUT ANNOTATION: " ^ str ^ "\n" ^
      "\nSTATE recovery expr: " ^ s ^ ", of type: " ^ ty ^ "\n"

let str_of_funinfo (funinfo: fun_info) : string =
  match funinfo with
    | (name, k, TyStr(ty)) ->
      ("Function name: " ^ name ^ " Return Type: " ^ ty ^ " Fun kind: " ^
          (str_of_kind k))


let str_of_param (p : param_info) : string =
  match p with
    | (name, TyStr(ty)) ->
      "Param name: " ^ name ^ " Type: " ^ ty

let str_of_annot (ac : annotated_comment) : string =
  match ac with
    | AComm (str, funinfo, params, apairs) ->
      ("COMMENT TEXT: \n" ^ str ^ "\nANNOTS: " ^ (String.concat "\n"
                                                    (List.map str_of_pair apairs))) ^ "\n" ^
        (str_of_funinfo funinfo) ^ "\nPARAMS: " ^ (String.concat "\n"
                                                     (List.map str_of_param params)) ^ "\n"

let str_of_pelem (e : program_element) : string =
  match e with
    | SrcStr (str) -> "SRC:\n" ^ str
    | ComStr (str) -> "COM:\n" ^ "/*" ^ str ^ "*/"
    | AFun (acomm, fundef) -> (str_of_annot acomm) ^ "SRCSTR: " ^ fundef

let str_of_prog (p : program_element list) : string =
  String.concat "\n" (List.map str_of_pelem p)
