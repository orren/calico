%{
open Ast;;
%}

/* Declare your tokens here. */

/* ocamlyacc uses this declaration to automatically generate
 * a token datatype.
 * Each token carries a Range.t value
 */

%token EOF
%token <Range.t> NL
%token <Range.t * string> CTRL
%token <Range.t> COPEN             /* '/' '*' */
%token <Range.t> CCLOS             /* '*' '/' */
%token <Range.t * string> COMMLINE /* non-annotation comment text */
%token <Range.t> LSEP              /* ,  */
%token <Range.t> LPAREN            /* (  */
%token <Range.t> RPAREN            /* )  */
%token <Range.t> LBRACE            /* {  */
%token <Range.t> RBRACE            /* }  */
%token <Range.t> SEMI              /* ;  */
%token <Range.t> INSTART           /* input prop starter */
%token <Range.t> OUTSTART          /* output prop starter */
%token <Range.t> FUNSTART          /* fun info starter */
%token <Range.t> PARAMSTART        /* param info starter */
%token <Range.t * string> IDENT    /* identifier */
%token <Range.t * string> STRLIT   /* string literal */

/* ---------------------------------------------------------------------- */

/* Mark 'toplevel' as a starting nonterminal of the grammar */
%start toplevel

/* Define type annotations for toplevel and bexp */
%type <Ast.annotated_comment> toplevel
%%

/* The variables $1, $2, etc. refer to the values computed by the
 * first, second, etc., symbols of the grammar.
 */

toplevel:
  | topprog EOF                     { $1 }

topprog:
  | commlines finfo SEMI params apairs   { AComm ($1, $2, $4, $5) }

finfo:
  | FUNSTART LBRACE IDENT LSEP IDENT LSEP STRLIT RBRACE { (snd $3,
                                                           KindStr(snd $5),
                                                           TyStr(snd $7)) }

params:
  | /* no parameters */               { [] }
  | paramlist SEMI                    { List.rev $1 }

paramlist:
  | param                             { [$1] }
  | paramlist SEMI param              { $3 :: $1 }

param:
  | PARAMSTART LBRACE IDENT LSEP STRLIT RBRACE { (snd $3,
                                                  TyStr(snd $5)) }

commlines:
  | COMMLINE                        { snd $1 }
  | COMMLINE commlines              { (snd $1) ^ $2 }

apairs:
  | apair                           { [$1] }
  | apair apairs                    { $1 :: $2 }

apair:
  | inannot SEMI outannot           { APair ($1, $3) }

inannot:
  | INSTART pannots                 { $2 }

pannots:
  | pannot                          { [$1] }
  | pannot LSEP pannots             { $1 :: $3 }

pannot:
  | LBRACE IDENT RBRACE IDENT LPAREN exlist RPAREN { ((snd $4), KindStr(snd $2), $6) }

exlist:
  | IDENT                           { [snd $1] }
  | IDENT LSEP exlist               { (snd $1) :: $3 }

outannot:
  | OUTSTART IDENT SEMI             { snd $2 }

