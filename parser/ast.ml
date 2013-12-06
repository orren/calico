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
type ty_str = string
type param_annot = string * funKind * string list (* name, kind, transformation list *)
type out_annot = string * funKind
type state_recovery =  string * string * string (* name, size, count *)
type eq_fun = string (* identifier for equality function *)
type annotation_set = ASet of param_annot list * out_annot * (state_recovery option) * (eq_fun option)
type param_info = string * ty_str (* name, type *)
type fun_info = string * funKind * ty_str (* name, kind, type *)
type annotated_comment = AComm of
    fun_info * (param_info list) * (annotation_set list)
type function_body = string
type function_header = string
type program_element = SrcStr of string
                       | ComStr of string
                       | AFun of annotated_comment * function_header * function_body

type sourceUnderTest = { file_name: string;
                         elements: program_element list }

let name_of_param_annot (p: param_annot) : string =
  match p with
    | (name, _, _) -> name

let name_of_out_annot (p: out_annot) : string =
  match p with
    | (name, _) -> name

let str_of_kind (k: funKind) : string =
  match k with
    | PointReturn -> "PointReturn"
    | Pure -> "Pure"
    | SideEffect -> "SideEffect"

let str_of_pannot (annot: param_annot) : string =
  match annot with
    | (name, kind, lst) -> "CALL TO:  " ^ name ^ ", KIND:  " ^
      (str_of_kind kind) ^ "\n ARGS:  " ^ (String.concat ", " lst) ^ " "

let str_of_pair (p: annotation_set) : string =
  match p with
    | ASet (annot, (str, _), None, None) -> "\nIN ANNOTATIONS: " ^
      (String.concat "\n" (List.map str_of_pannot annot)) ^ "\nOUT ANNOTATION: " ^ str ^ "\n"
    | ASet (annot, (str, _), Some(s, size, num), None) -> "\nIN ANNOTATIONS: " ^
      (String.concat "\n" (List.map str_of_pannot annot)) ^ "\nOUT ANNOTATION: " ^ str ^ "\n" ^
      "STATE recovery ptr: " ^ s ^ ", size expr: " ^ size ^ "*" ^ num ^ "\n"
    | ASet (annot, (str, _), Some(s, size, num), Some(eq)) -> "\nIN ANNOTATIONS: " ^
      (String.concat "\n" (List.map str_of_pannot annot)) ^ "\nOUT ANNOTATION: " ^ str ^ "\n" ^
      "STATE recovery ptr: " ^ s ^ ", size expr: " ^ size ^ "*" ^ num ^ "\n" ^
      "EQUALITY function: " ^ eq ^ "\n"
    | ASet (annot, (str, _), _, _) -> failwith "Equality but no state recovery?"

let str_of_funinfo (funinfo: fun_info) : string =
  match funinfo with
    | (name, k, ty) ->
      ("Function name: " ^ name ^ " Return Type: " ^ ty ^ " Fun kind: " ^
          (str_of_kind k))


let str_of_param (p : param_info) : string =
  match p with
    | (name, ty) ->
      "Param name: " ^ name ^ " Type: " ^ ty

let str_of_annot (ac : annotated_comment) : string =
  match ac with
    | AComm (funinfo, params, apairs) ->
      ("ANNOTS: " ^ (String.concat "\n"
                       (List.map str_of_pair apairs))) ^ "\n" ^
        (str_of_funinfo funinfo) ^ "\nPARAMS: " ^ (String.concat "\n"
                                                     (List.map str_of_param params)) ^ "\n"

let str_of_pelem (e : program_element) : string =
  match e with
    | SrcStr (str) -> "SRC:\n" ^ str
    | ComStr (str) -> "COM:\n" ^ "/*" ^ str ^ "*/"
    | AFun (acomm, header, fundef) -> (str_of_annot acomm) ^ "\nHEADER: " ^ header ^ "\nSRCSTR: " ^ fundef
    
let str_of_prog (p : program_element list) : string =
  String.concat "\n" (List.map str_of_pelem p)

let str_from_elem (p : program_element) : string =
  match p with
    | SrcStr(src) -> src
    | ComStr(com) -> com
    | AFun(_, _, _)  -> failwith "Unable to extract single string from function pair"
