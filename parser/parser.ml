type token =
  | EOF
  | NL of (Range.t)
  | CTRL of (Range.t * string)
  | COPEN of (Range.t)
  | CCLOS of (Range.t)
  | COMM of (Range.t * string)
  | LSEP of (Range.t)
  | LPAREN of (Range.t)
  | RPAREN of (Range.t)
  | SEMI of (Range.t)
  | INSTART of (Range.t)
  | OUTSTART of (Range.t)
  | IDENT of (Range.t * string)
  | OTHER of (Range.t * string)

open Parsing;;
let _ = parse_error;;
# 2 "parser.mly"
open Ast;;
# 22 "parser.ml"
let yytransl_const = [|
    0 (* EOF *);
    0|]

let yytransl_block = [|
  257 (* NL *);
  258 (* CTRL *);
  259 (* COPEN *);
  260 (* CCLOS *);
  261 (* COMM *);
  262 (* LSEP *);
  263 (* LPAREN *);
  264 (* RPAREN *);
  265 (* SEMI *);
  266 (* INSTART *);
  267 (* OUTSTART *);
  268 (* IDENT *);
  269 (* OTHER *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\000\000"

let yylen = "\002\000\
\002\000\003\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\003\000\000\000\000\000\001\000\002\000"

let yydgoto = "\002\000\
\004\000\005\000"

let yysindex = "\255\255\
\254\254\000\000\253\254\000\000\003\000\000\255\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000"

let yytablesize = 4
let yytable = "\001\000\
\003\000\006\000\007\000\008\000"

let yycheck = "\001\000\
\003\001\005\001\000\000\004\001"

let yynames_const = "\
  EOF\000\
  "

let yynames_block = "\
  NL\000\
  CTRL\000\
  COPEN\000\
  CCLOS\000\
  COMM\000\
  LSEP\000\
  LPAREN\000\
  RPAREN\000\
  SEMI\000\
  INSTART\000\
  OUTSTART\000\
  IDENT\000\
  OTHER\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'topprog) in
    Obj.repr(
# 41 "parser.mly"
                ( _1 )
# 98 "parser.ml"
               : Ast.annotated_comment))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Range.t) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Range.t * string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Range.t) in
    Obj.repr(
# 44 "parser.mly"
                     ( AComm ( snd _2, Pairs ( APair (End, ""), Ends )) )
# 107 "parser.ml"
               : 'topprog))
(* Entry toplevel *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let toplevel (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.annotated_comment)
