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
%token <Range.t> COPEN             /*   '/' '*'  */
%token <Range.t> CCLOS             /*   '*' '/'  */
%token <Range.t * string> COMMLINE /*   non-annotation comment text  */
%token <Range.t> LSEP              /*   ,    */
%token <Range.t> LPAREN            /*   (    */
%token <Range.t> RPAREN            /*   )    */
%token <Range.t> SEMI              /*   )    */
%token <Range.t> INSTART           /* input prop starter */
%token <Range.t> OUTSTART          /* output prop starter */
%token <Range.t * string> IDENT    /* identifier */
%token <Range.t * string> OTHER    /* other program string */

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
  | topprog EOF                 { $1 }

topprog:
  | COPEN COMMLINE apairs CCLOS { AComm (snd $2, $3) }

apairs:
  | apair                       { [$1] }
  | apair apairs                { $1 :: $2 }

apair:
  | inannot outannot            { APair ($1, $2) }

inannot:
  | pannot                      { [$1] }
  | pannot LSEP inannot         { $1 :: $3 }

pannot:
  | IDENT LPAREN exlist RPAREN  { ((snd $1), $3) }

exlist:
  | IDENT                       { [snd $1] }
  | IDENT LSEP exlist           { (snd $1) :: $3 }

outannot:
  | OUTSTART IDENT              { snd $2 }

