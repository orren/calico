type token =
  | EOF
  | SRC of (Range.t * string)

val toplevel :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string
