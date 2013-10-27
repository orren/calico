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
\001\000\002\000\003\000\003\000\004\000\004\000\005\000\006\000\
\008\000\008\000\009\000\010\000\010\000\007\000\000\000"

let yylen = "\002\000\
\002\000\004\000\001\000\002\000\001\000\002\000\003\000\002\000\
\001\000\003\000\004\000\001\000\003\000\003\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\015\000\000\000\000\000\000\000\001\000\
\004\000\000\000\000\000\000\000\000\000\000\000\008\000\000\000\
\002\000\006\000\000\000\000\000\000\000\000\000\007\000\000\000\
\000\000\010\000\000\000\000\000\011\000\014\000\013\000"

let yydgoto = "\002\000\
\004\000\005\000\007\000\011\000\012\000\013\000\023\000\015\000\
\016\000\025\000"

let yysindex = "\255\255\
\254\254\000\000\253\254\000\000\003\000\253\254\250\254\000\000\
\000\000\249\254\002\255\250\254\255\254\000\255\000\000\003\255\
\000\000\000\000\001\255\004\255\249\254\005\255\000\000\007\255\
\006\255\000\000\009\255\004\255\000\000\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\010\255\000\000\000\000\
\000\000\000\000\000\000\011\255\000\000\000\000\000\000\012\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\014\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000\004\000\007\000\000\000\000\000\000\000\246\255\
\000\000\251\255"

let yytablesize = 23
let yytable = "\001\000\
\003\000\006\000\008\000\010\000\014\000\017\000\020\000\019\000\
\021\000\009\000\026\000\022\000\028\000\029\000\005\000\024\000\
\027\000\030\000\018\000\003\000\009\000\012\000\031\000"

let yycheck = "\001\000\
\003\001\005\001\000\000\010\001\012\001\004\001\007\001\009\001\
\006\001\006\000\021\000\011\001\006\001\008\001\004\001\012\001\
\012\001\009\001\012\000\010\001\009\001\008\001\028\000"

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
# 115 "parser.ml"
               : Ast.annotated_comment))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Range.t) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'commlines) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'apairs) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Range.t) in
    Obj.repr(
# 44 "parser.mly"
                                    ( AComm (_2, _3) )
# 125 "parser.ml"
               : 'topprog))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Range.t * string) in
    Obj.repr(
# 47 "parser.mly"
                                    ( snd _1 )
# 132 "parser.ml"
               : 'commlines))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Range.t * string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'commlines) in
    Obj.repr(
# 48 "parser.mly"
                                    ( (snd _1) ^ _2 )
# 140 "parser.ml"
               : 'commlines))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'apair) in
    Obj.repr(
# 51 "parser.mly"
                                    ( [_1] )
# 147 "parser.ml"
               : 'apairs))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'apair) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'apairs) in
    Obj.repr(
# 52 "parser.mly"
                                    ( _1 :: _2 )
# 155 "parser.ml"
               : 'apairs))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'inannot) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Range.t) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'outannot) in
    Obj.repr(
# 55 "parser.mly"
                                    ( APair (_1, _3) )
# 164 "parser.ml"
               : 'apair))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Range.t) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'pannots) in
    Obj.repr(
# 58 "parser.mly"
                                    ( _2 )
# 172 "parser.ml"
               : 'inannot))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'pannot) in
    Obj.repr(
# 61 "parser.mly"
                                    ( [_1] )
# 179 "parser.ml"
               : 'pannots))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pannot) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Range.t) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'pannots) in
    Obj.repr(
# 62 "parser.mly"
                                    ( _1 :: _3 )
# 188 "parser.ml"
               : 'pannots))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Range.t * string) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : Range.t) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'exlist) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Range.t) in
    Obj.repr(
# 65 "parser.mly"
                                    ( ((snd _1), _3) )
# 198 "parser.ml"
               : 'pannot))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Range.t * string) in
    Obj.repr(
# 68 "parser.mly"
                                    ( [snd _1] )
# 205 "parser.ml"
               : 'exlist))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Range.t * string) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Range.t) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'exlist) in
    Obj.repr(
# 69 "parser.mly"
                                    ( (snd _1) :: _3 )
# 214 "parser.ml"
               : 'exlist))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Range.t) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Range.t * string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Range.t) in
    Obj.repr(
# 72 "parser.mly"
                                    ( snd _2 )
# 223 "parser.ml"
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
