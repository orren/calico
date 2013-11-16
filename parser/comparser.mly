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
%token <Range.t * string> NAT      /* natural number */
%token <Range.t * Ast.funKind> KIND    /* function kind */

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
  | commlines funinfo SEMI params apairs   { AComm ($1, $2, $4, $5) }

funinfo:
  | FUNSTART LBRACE IDENT LSEP KIND LSEP STRLIT RBRACE { (snd $3,
                                                          snd $5,
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
  | INSTART paramannots                 { $2 }

paramannots:
  | paramannot                          { [$1] }
  | paramannot LSEP paramannots             { $1 :: $3 }

paramannot:
  | LBRACE KIND RBRACE IDENT LPAREN arglist RPAREN { (snd $4, snd $2, $6) }

arglist:
  | arg                            { [$1] }
  | arg LSEP arglist               { ($1) :: $3 }

arg:
  | IDENT    {snd $1}
  | NAT      {snd $1}
  | STRLIT   {snd $1}

outannot:
  /* single identifier */
  | OUTSTART LBRACE KIND RBRACE IDENT SEMI       { (snd $5, snd $3) }
  /* a string literal */
  | OUTSTART LBRACE KIND RBRACE STRLIT SEMI      { (snd $5, snd $3) }
  /* call to a function */
  | OUTSTART LBRACE KIND RBRACE funcall SEMI     { ($5, snd $3) }

/* recognize a function call, emit the whole thing as a string */
funcall:
  | IDENT LPAREN arglist RPAREN { (snd $1) ^ "(" ^ (String.concat ", " $3) ^ ")" }
