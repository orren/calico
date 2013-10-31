{
  open Lexing
  open Comparser
  open Lexutil
  open Range
}

(* Basic regular expressions for the tokens of this grammar *)
let lowercase = ['a'-'z']
let uppercase = ['A'-'Z']
let digit = ['0'-'9']
let alphachar = uppercase | lowercase
let idchar = alphachar | '_' (* legal identifiers *)

let nl = '\n'
let linewhitespace = ['\t' ' ' '\r']
let whitespace = linewhitespace | nl

let in_prop  = ['@'] whitespace* "input-prop"
let out_prop = ['@'] whitespace* "output-prop"

(* let com_char = [^ '@' '*' ] | (['*'] [^ '/']) *)
let com_char = (['*'] [^ '/'] | idchar)
let com_line = linewhitespace* ('*' | (com_char | linewhitespace)*) nl
let other_char = ['/' '\\' '!' ';' '"' '\'' '#' '*' '<' '>' '.'] | digit (* Other characters we care about... *)

let anychar = idchar | other_char
let linechar = anychar | linewhitespace
let other = anychar | whitespace

(* Returns a token of type as specified in parser.mly

   Each token carries a Range.t value indicating its
   position in the file.
*)
rule token = parse
  | eof                                      { EOF }
  | whitespace+                              { token lexbuf }  (* skip whitespace *)
  | "/*"                                     { COPEN (lex_range lexbuf) }
  | ['*']? "*/"                              { CCLOS (lex_range lexbuf) }
  | com_line                                 { COMMLINE (lex_range lexbuf, lexeme lexbuf) }
  | (['*']? whitespace* in_prop) | in_prop   { INSTART  (lex_range lexbuf) }
  | (['*']? whitespace* out_prop) | out_prop { OUTSTART (lex_range lexbuf) }
  | idchar anychar*                          { IDENT (lex_range lexbuf, lexeme lexbuf) }
  | ','                                      { LSEP (lex_range lexbuf) } 
  | '('                                      { LPAREN (lex_range lexbuf) }
  | ')'                                      { RPAREN (lex_range lexbuf) }
  | ';'                                      { SEMI (lex_range lexbuf) }
  | _ as c                                   { unexpected_char lexbuf c }
