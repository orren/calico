%{
open Ast;;
%}

/* Declare your tokens here. */

/* ocamlyacc uses this declaration to automatically generate
 * a token datatype.
 * Each token carries a Range.t value 
 */

%token EOF
%token <Range.t * string> VAR
%token <Range.t> ARR      /* -> */
%token <Range.t> BAR      /* | */
%token <Range.t> AMPER    /* & */
%token <Range.t> LPAREN   /* ( */
%token <Range.t> RPAREN   /* ) */
%token <Range.t> TILDE    /* ~ */
%token <Range.t> TRUE     /* true */
%token <Range.t> FALSE    /* false */

/* ---------------------------------------------------------------------- */

/* Mark 'toplevel' as a starting nonterminal of the grammar */
%start toplevel

/* Define type annotations for toplevel and bexp */
%type <Ast.bexp> toplevel
%type <Ast.bexp> bexp
%%

/* The variables $1, $2, etc. refer to the values computed by the 
 * first, second, etc., symbols of the grammar. 
 */

toplevel:
  | bexp EOF { $1 }        

bexp:
  | B1 { $1 }  

B1:
  | B2 ARR B1 { Imp($1, $3) }
  | B2 { $1 }

B2:
  | B3 BAR B2 { Or($1, $3) }
  | B3 { $1 }

B3:
  | B4 AMPER B3 { And($1, $3) }
  | B4 { $1 }

B4:
  | TILDE B4 { Not($2) }
  | B5 { $1 }

B5:
  | TRUE  { True }
  | FALSE { False }
  | VAR   { Var (snd $1) }
  | LPAREN B1 RPAREN { $2 }
