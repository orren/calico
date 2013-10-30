{
  open Lexing
  open Srcparser
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

let anychar = [^ '\t' ' ' '\r' '\n']
let linechar = anychar | linewhitespace
let other = anychar | whitespace

(* Returns a token of type as specified in parser.mly

   Each token carries a Range.t value indicating its
   position in the file.
*)
(* Returns a token of type as specified in parser.mly

   Each token carries a Range.t value indicating its
   position in the file.
*)
rule token = parse
  | eof                               { EOF }
  | anychar*                          { SRC (lex_range lexbuf, lexeme lexbuf) }
  | _ as c                            { unexpected_char lexbuf c }

