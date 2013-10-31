type token =
  | EOF
  | AUTO of (Range.t)
  | REGISTER of (Range.t)
  | STATIC of (Range.t)
  | EXTERN of (Range.t)
  | TYPEDEF of (Range.t)
  | VOID of (Range.t)
  | CHAR of (Range.t)
  | SHORT of (Range.t)
  | INT of (Range.t)
  | LONG of (Range.t)
  | FLOAT of (Range.t)
  | DOUBLE of (Range.t)
  | SIGNED of (Range.t)
  | UNSIGNED of (Range.t)
  | CONST of (Range.t)
  | VOLATILE of (Range.t)
  | STRUCT of (Range.t)
  | UNION of (Range.t)
  | SRC of (Range.t * string)

val toplevel :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string
