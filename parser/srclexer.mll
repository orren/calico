{
  open Lexing
  open Srcparser
  open Lexutil
  open Range

  let type_keywords = [
    (* Keywords appearing in c types *)
    ("auto", fun i s -> AUTO (i, s));
    ("register", fun i s -> REGISTER (i, s));
    ("static", fun i s -> STATIC (i, s));
    ("extern", fun i s -> EXTERN (i, s));
    ("typedef", fun i s -> TYPEDEF (i, s));
    ("void", fun i s -> VOID (i, s));
    ("char", fun i s -> CHAR (i, s));
    ("short", fun i s -> SHORT (i, s));
    ("int", fun i s -> INT (i, s));
    ("long", fun i s -> LONG (i, s));
    ("float", fun i s -> FLOAT (i, s));
    ("double", fun i s -> DOUBLE (i, s));
    ("signed", fun i s -> SIGNED (i, s));
    ("unsigned", fun i s -> UNSIGNED (i, s));
    ("const", fun i s -> CONST (i, s));
    ("volatile", fun i s -> VOLATILE (i, s));
    ("struct", fun i s -> STRUCT (i, s));
    ("union", fun i s -> UNION (i, s));
  ]

  type build_fun = Range.t -> Srcparser.token
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
  | eof                       { EOF }
  | "{"                       { LBRACE (lex_range lexbuf, lexeme lexbuf) }
  | "}"                       { RBRACE (lex_range lexbuf, lexeme lexbuf) }
  | ";"                       { SEMI (lex_range lexbuf, lexeme lexbuf) }
  | ":"                       { COLON (lex_range lexbuf, lexeme lexbuf) }
  | "("                       { LPAREN (lex_range lexbuf, lexeme lexbuf) }
  | ")"                       { RPAREN (lex_range lexbuf, lexeme lexbuf) }
  | ","                       { COMMA (lex_range lexbuf, lexeme lexbuf) }
  | "*"                       { STAR (lex_range lexbuf, lexeme lexbuf) }
  | "."                       { DOT (lex_range lexbuf, lexeme lexbuf) }
  | "["                       { LBRACKET (lex_range lexbuf, lexeme lexbuf) }
  | "]"                       { RBRACKET (lex_range lexbuf, lexeme lexbuf) }
  | whitespace+               { token lexbuf }
  | idchar (idchar | digit)*  { create_token lexbuf }
  | _ as c                    { unexpected_char lexbuf c }
