{
  open Lexing
  open Srcparser
  open Lexutil
  open Range

  let type_keywords = [
    (* Keywords appearing in c types *)
    ("auto", fun i -> AUTO i);
    ("register", fun i -> REGISTER i);
    ("static", fun i -> STATIC i);
    ("extern", fun i -> EXTERN i);
    ("typedef", fun i -> TYPEDEF i);
    ("void", fun i -> VOID i);
    ("char", fun i -> CHAR i);
    ("short", fun i -> SHORT i);
    ("int", fun i -> INT i);
    ("long", fun i -> LONG i);
    ("float", fun i -> FLOAT i);
    ("double", fun i -> DOUBLE i);
    ("signed", fun i -> SIGNED i);
    ("unsigned", fun i -> UNSIGNED i);
    ("const", fun i -> CONST i);
    ("volatile", fun i -> VOLATILE i);
    ("struct", fun i -> STRUCT i);
    ("union", fun i -> UNION i);
    ("{", fun i -> LBRACE i);
    ("}", fun i -> RBRACE i);
    ( ",", fun i -> COMMA i);
    ( "(", fun i -> LPAREN i);
    ( ")", fun i -> RPAREN i);
    ( "[", fun i -> LBRACKET i);
    ( "]", fun i -> RBRACKET i);
    ( "*", fun i -> STAR i)
  ]

  type build_fun = Range.t -> Parser.token
  let (symbol_table : (string, build_fun) Hashtbl.t) = Hashtbl.create 1024
  let _ =
    List.iter (fun (str,f) -> Hashtbl.add symbol_table str f) type_keywords

  let create_token lexbuf =
    let str = lexeme lexbuf in
    let r = lex_range lexbuf in
    try (Hashtbl.find symbol_table str) r
    with _ -> IDENT (r, str)

}

(* Basic regular expressions for the tokens of this grammar *)
let lowercase = ['a'-'z']
let uppercase = ['A'-'Z']
let digit = ['0'-'9']
let alphachar = uppercase | lowercase
let idchar = alphachar | '_' (* start of a legal identifier *)
let ident = idchar (idchar | digit)*

let nl = '\n'
let linewhitespace = ['\t' ' ' '\r']
let whitespace = linewhitespace | nl

(* Returns a token of type as specified in parser.mly

   Each token carries a Range.t value indicating its
   position in the file.
*)
rule token = parse
  | eof                        { EOF }
  | "{"                        { LBRACE (lex_range lexbuf) }
  | "}"                        { RBRACE (lex_range lexbuf) }
  | ";"                        { SEMI (lex_range lexbuf) }
  | "("                        { LPAREN (lex_range lexbuf) }
  | ")"                        { RPAREN (lex_range lexbuf) }
  | ","                        { COMMA (lex_range lexbuf) }
  | "*"                        { STAR (lex_range lexbuf) }
  | "["                        { LBRACKET (lex_range lexbuf) }
  | "]"                        { RBRACKET (lex_range lexbuf) }
  | idchar (idchar | digit)*   { create_token lexbuf }
  | _ as c                     { unexpected_char lexbuf c }
