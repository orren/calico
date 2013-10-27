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
  261 (* COMMLINE *);
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
\001\000\002\000\003\000\003\000\004\000\005\000\005\000\007\000\
\008\000\008\000\006\000\000\000"

let yylen = "\002\000\
\002\000\004\000\001\000\002\000\002\000\001\000\003\000\004\000\
\001\000\003\000\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\012\000\000\000\000\000\001\000\000\000\
\000\000\000\000\000\000\000\000\000\000\002\000\004\000\000\000\
\005\000\000\000\000\000\000\000\011\000\007\000\000\000\008\000\
\010\000"

let yydgoto = "\002\000\
\004\000\005\000\009\000\010\000\011\000\017\000\012\000\020\000"

let yysindex = "\255\255\
\254\254\000\000\253\254\000\000\003\000\248\254\000\000\255\254\
\001\255\248\254\252\254\002\255\000\255\000\000\000\000\003\255\
\000\000\248\254\004\255\005\255\000\000\000\000\000\255\000\000\
\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\007\255\000\000\006\255\000\000\000\000\000\000\000\000\
\000\000\000\000\008\255\000\000\000\000\000\000\000\000\000\000\
\000\000"

let yygindex = "\000\000\
\000\000\000\000\004\000\000\000\247\255\000\000\000\000\251\255"

let yytablesize = 18
let yytable = "\001\000\
\003\000\006\000\007\000\008\000\014\000\013\000\016\000\018\000\
\022\000\023\000\003\000\019\000\024\000\015\000\021\000\009\000\
\006\000\025\000"

let yycheck = "\001\000\
\003\001\005\001\000\000\012\001\004\001\007\001\011\001\006\001\
\018\000\006\001\004\001\012\001\008\001\010\000\012\001\008\001\
\011\001\023\000"

let yynames_const = "\
  EOF\000\
  "

let yynames_block = "\
  NL\000\
  CTRL\000\
  COPEN\000\
  CCLOS\000\
  COMMLINE\000\
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
# 113 "parser.ml"
               : Ast.annotated_comment))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Range.t) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : Range.t * string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'apairs) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Range.t) in
    Obj.repr(
# 44 "parser.mly"
                                ( AComm (snd _2, _3) )
# 123 "parser.ml"
               : 'topprog))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'apair) in
    Obj.repr(
# 47 "parser.mly"
                                ( [_1] )
# 130 "parser.ml"
               : 'apairs))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'apair) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'apairs) in
    Obj.repr(
# 48 "parser.mly"
                                ( _1 :: _2 )
# 138 "parser.ml"
               : 'apairs))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'inannot) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'outannot) in
    Obj.repr(
# 51 "parser.mly"
                                ( APair (_1, _2) )
# 146 "parser.ml"
               : 'apair))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'pannot) in
    Obj.repr(
# 54 "parser.mly"
                                ( [_1] )
# 153 "parser.ml"
               : 'inannot))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pannot) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Range.t) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'inannot) in
    Obj.repr(
# 55 "parser.mly"
                                ( _1 :: _3 )
# 162 "parser.ml"
               : 'inannot))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Range.t * string) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : Range.t) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'exlist) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Range.t) in
    Obj.repr(
# 58 "parser.mly"
                                ( ((snd _1), _3) )
# 172 "parser.ml"
               : 'pannot))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Range.t * string) in
    Obj.repr(
# 61 "parser.mly"
                                ( [snd _1] )
# 179 "parser.ml"
               : 'exlist))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Range.t * string) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Range.t) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'exlist) in
    Obj.repr(
# 62 "parser.mly"
                                ( (snd _1) :: _3 )
# 188 "parser.ml"
               : 'exlist))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Range.t) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Range.t * string) in
    Obj.repr(
# 65 "parser.mly"
                                ( snd _2 )
# 196 "parser.ml"
               : 'outannot))
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
