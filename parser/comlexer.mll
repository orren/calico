{
  open Lexing
  open Comparser
  open Lexutil
  open Range
  open Ast

  let find_kwd (buf: lexbuf) =
    let lex_res = lexeme buf in
    let lex_rng = lex_range buf in
    if (compare lex_res "PointReturn") = 0
    then KIND (lex_rng, PointReturn)
    else if (compare lex_res "Pure") = 0
    then KIND (lex_rng, Pure)
    else if (compare lex_res "SideEffect") = 0
    then KIND (lex_rng, SideEffect)
    else IDENT (lex_rng, lex_res)
}

(* Commonly used regex *)
let nl = '\n'
let linewhitespace = ['\t' ' ' '\r']
let whitespace = linewhitespace | nl

let lowercase = ['a'-'z']
let uppercase = ['A'-'Z']
let pdigit = ['1'-'9']
let digit = pdigit | ['0']
let alphachar = uppercase | lowercase
let idchar = alphachar | '_' (* start of a legal identifier *)
let ident = idchar (idchar | digit)*

let fun_info = ['@'] whitespace* "fun-info"
let param_info = ['@'] whitespace* "param-info"
let in_prop  = ['@'] whitespace* "input-prop"
let out_prop = ['@'] whitespace* "output-prop"

(* Other characters we care about... *)
let com_char = ['*' '%' '/' ':' '`' '-' '?' '\\' '!' '\'' '#' '<' '>' '.' 'a'-'z' 'A'-'Z' '0'-'9']
let com_line = (com_char | linewhitespace)+ nl
let kind_str = "PointReturn" | "Pure" | "SideEffect"

(* Returns a token of type as specified in parser.mly

   Each token carries a Range.t value indicating its
   position in the file.
*)
rule token = parse
  | eof                                          { EOF }
  | whitespace+                                  { token lexbuf }  (* skip whitespace *)
  | "/*" ['*']?                                  { COPEN (lex_range lexbuf) }
  | ['*']? "*/"                                  { CCLOS (lex_range lexbuf) }
  | (['*']? whitespace* in_prop) | in_prop       { INSTART  (lex_range lexbuf) }
  | (['*']? whitespace* out_prop) | out_prop     { OUTSTART (lex_range lexbuf) }
  | (['*']? whitespace* fun_info) | fun_info     { FUNSTART  (lex_range lexbuf) }
  | (['*']? whitespace* param_info) | param_info { PARAMSTART (lex_range lexbuf) }
  | idchar (digit|idchar)*                       { find_kwd lexbuf }
  | ['-']? pdigit (digit)*                       { INT (lex_range lexbuf, lexeme lexbuf) }
  | com_line                                     { COMMLINE (lex_range lexbuf, lexeme lexbuf) }
  | '"'                                          { STRLIT (lex_range lexbuf, str "" lexbuf) }
  | nl                                           { NL (lex_range lexbuf) }
  | ','                                          { LSEP (lex_range lexbuf) }
  | '('                                          { LPAREN (lex_range lexbuf) }
  | ')'                                          { RPAREN (lex_range lexbuf) }
  | '{'                                          { LBRACE (lex_range lexbuf) }
  | '}'                                          { RBRACE (lex_range lexbuf) }
  | ';'                                          { SEMI (lex_range lexbuf) }
  | _ as c                                       { unexpected_char lexbuf c
                                                     ("Error in comment lexer at: " ^ (lexeme lexbuf)) }

and str s = parse
  | [^ '"']* as s                                { str s lexbuf }
  | '"'                                          { s }

