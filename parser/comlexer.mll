{
  open Lexing
  open Comparser
  open Lexutil
  open Range
  open Ast

  let find_kwd (buf: lexbuf) =
    let lex_res = lexeme buf in
    let lex_rng = lex_range buf in
    if (compare lex_res "id") = 0
    then KWRD (lex_rng, "id")
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

let in_kwrd = ['@'] whitespace* "input-prop"
let in_prop = (['*']? whitespace* in_kwrd) | in_kwrd

let out_kwrd = ['@'] whitespace* "output-prop"
let out_prop = (['*']? whitespace* out_kwrd) | out_kwrd

let fun_kwrd = ['@'] whitespace* "fun-info"
let fun_info = (['*']? whitespace* fun_kwrd) | fun_kwrd

let param_kwrd = ['@'] whitespace* "param-info"
let param_info = (['*']? whitespace* param_kwrd) | param_kwrd

let state_kwrd = ['@'] whitespace* "state-recover"
let state_rec = (['*']? whitespace* state_kwrd) | state_kwrd

let eq_kwrd = ['@'] whitespace* "equality-op"
let eq_fun = (['*']? whitespace* eq_kwrd) | eq_kwrd

(* Other characters we care about, (excluding '@') *)
let com_char = ['*' '%' '/' ':' '`' '-' '?' '\\' '!' '\'' '#' '<' '>' '.' 'a'-'z' 'A'-'Z' '0'-'9']
let com_line = linewhitespace* com_char+ (linewhitespace|com_char)* nl

(* Returns a token of type as specified in parser.mly

   Each token carries a Range.t value indicating its
   position in the file.
*)
rule token = parse
  | eof                    { EOF }
  | linewhitespace+        { token lexbuf }  (* skip whitespace *)
  | nl                     { new_line lexbuf;
                             token lexbuf }
  | "/*" ['*']?            { COPEN (lex_range lexbuf) }
  | ['*']? "*/"            { CCLOS (lex_range lexbuf) }
  | in_prop                { INSTART  (lex_range lexbuf) }
  | out_prop               { OUTSTART (lex_range lexbuf) }
  | fun_info               { FUNSTART  (lex_range lexbuf) }
  | param_info             { PARAMSTART (lex_range lexbuf) }
  | state_rec              { STATEREC (lex_range lexbuf) }
  | eq_fun                 { EQFUN    (lex_range lexbuf) }
  | idchar (digit|idchar)* { find_kwd lexbuf }
  | ['-']? pdigit (digit)* { INT (lex_range lexbuf, lexeme lexbuf) }
  | com_line               { COMMLINE (lex_range lexbuf, lexeme lexbuf) }
  | '"'                    { STRLIT (lex_range lexbuf, str "" lexbuf) }
  | ','                    { LSEP (lex_range lexbuf) }
  | '('                    { LPAREN (lex_range lexbuf) }
  | ')'                    { RPAREN (lex_range lexbuf) }
  | '{'                    { LBRACE (lex_range lexbuf) }
  | '}'                    { RBRACE (lex_range lexbuf) }
  | ';'                    { SEMI (lex_range lexbuf) }
  | _ as c                 { unexpected_char lexbuf c
                                                     ("Error in comment lexer at: " ^ (lexeme lexbuf)) }

and str s = parse
  | [^ '"']* as s                                { str s lexbuf }
  | '"'                                          { s }

