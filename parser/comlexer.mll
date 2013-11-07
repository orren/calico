{
  open Lexing
  open Comparser
  open Lexutil
  open Range
}

(* Commonly used regex *)
let nl = '\n'
let linewhitespace = ['\t' ' ' '\r']
let whitespace = linewhitespace | nl

let lowercase = ['a'-'z']
let uppercase = ['A'-'Z']
let digit = ['0'-'9']
let alphachar = uppercase | lowercase
let idchar = alphachar | '_' (* start of a legal identifier *)
let ident = idchar (idchar | digit)*

(* Basic regular expressions for the tokens of this grammar *)
let fun_info = ['@'] whitespace* "fun-info"
let param_info = ['@'] whitespace* "param-info"
let in_prop  = ['@'] whitespace* "input-prop"
let out_prop = ['@'] whitespace* "output-prop"

let com_char = (['*'] [^ '/'] | idchar)
let com_line = linewhitespace* ('*' | (com_char | linewhitespace)*) nl

(* Other characters we care about... *)
let other_char = ['/' '\\' '!' ';' '"' '\'' '#' '*' '<' '>' '.'] | digit

let anychar = idchar | other_char
let linechar = anychar | linewhitespace
let other = anychar | whitespace

(* Returns a token of type as specified in parser.mly

   Each token carries a Range.t value indicating its
   position in the file.
*)
rule token = parse
  | eof                                          { EOF }
  | whitespace+                                  { token lexbuf }  (* skip whitespace *)
  | "/*"                                         { COPEN (lex_range lexbuf) }
  | ['*']? "*/"                                  { CCLOS (lex_range lexbuf) }
  | com_line                                     { COMMLINE (lex_range lexbuf, lexeme lexbuf) }
  | (['*']? whitespace* in_prop) | in_prop       { INSTART  (lex_range lexbuf) }
  | (['*']? whitespace* out_prop) | out_prop     { OUTSTART (lex_range lexbuf) }
  | (['*']? whitespace* fun_info) | fun_info     { FUNSTART  (lex_range lexbuf) }
  | (['*']? whitespace* param_info) | param_info { PARAMSTART (lex_range lexbuf) }
  | idchar (digit|idchar)*                       { IDENT (lex_range lexbuf, lexeme lexbuf) }
  | '"'                                          { STRLIT (lex_range lexbuf, str "" lexbuf) }
  | ','                                          { LSEP (lex_range lexbuf) }
  | '('                                          { LPAREN (lex_range lexbuf) }
  | ')'                                          { RPAREN (lex_range lexbuf) }
  | '{'                                          { LBRACE (lex_range lexbuf) }
  | '}'                                          { RBRACE (lex_range lexbuf) }
  | ';'                                          { SEMI (lex_range lexbuf) }
  | _ as c                                       { unexpected_char lexbuf c }
and str s = parse
  | [^ '"']* as s                                { str s lexbuf }
  | '"'                                          { s }

