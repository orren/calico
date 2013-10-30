{
  open Lexing
  open Range
  open Lexutil
  open Ast
}


(* Basic regular expressions for the tokens of this grammar *)
let nl = '\n'
let linewhitespace = ['\t' ' ' '\r']
let whitespace = linewhitespace | nl

let com_char = (['*'] [^ '/']) | [^ '*']
let src_char = (['/'] [^ '*']) | [^ '/']

(* A rudimentary lexer whose purpose is to break a C program into a list
   of multi-line comments and other program elements.
*)
rule prog_elements lst = parse
  | eof                 { List.rev lst }
  | src_char* as src    { prog_elements (SrcStr(src)::lst) lexbuf }
  | "/*"                { comment lst lexbuf }
  | _ as c              { unexpected_char lexbuf c }
and comment lst = parse
  | com_char* as com    { comment (ComStr(com)::lst) lexbuf }
  | "*/"                { prog_elements lst lexbuf }
  | _ as c              { unexpected_char lexbuf c }
