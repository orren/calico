type token =
  | EOF
  | NL of (Range.t)
  | CTRL of (Range.t * string)
  | COPEN of (Range.t)
  | CCLOS of (Range.t)
  | COMMLINE of (Range.t * string)
  | LSEP of (Range.t)
  | LPAREN of (Range.t)
  | RPAREN of (Range.t)
  | LBRACE of (Range.t)
  | RBRACE of (Range.t)
  | SEMI of (Range.t)
  | INSTART of (Range.t)
  | OUTSTART of (Range.t)
  | FUNSTART of (Range.t)
  | PARAMSTART of (Range.t)
  | IDENT of (Range.t * string)

val toplevel :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.annotated_comment
