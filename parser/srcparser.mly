%{
open Ast;;
%}

/* Declare your tokens here. */

/* ocamlyacc uses this declaration to automatically generate
 * a token datatype.
 * Each token carries a Range.t value
 *
 * So many keywords, so little time!
 *
 */

%token EOF
%token <Range.t> AUTO
%token <Range.t> REGISTER
%token <Range.t> STATIC
%token <Range.t> EXTERN
%token <Range.t> TYPEDEF
%token <Range.t> VOID
%token <Range.t> CHAR
%token <Range.t> SHORT
%token <Range.t> INT
%token <Range.t> LONG
%token <Range.t> FLOAT
%token <Range.t> DOUBLE
%token <Range.t> SIGNED
%token <Range.t> UNSIGNED
%token <Range.t> CONST
%token <Range.t> VOLATILE
%token <Range.t> STRUCT
%token <Range.t> UNION

%token <Range.t * string> SRC



/* ---------------------------------------------------------------------- */

/* Mark 'toplevel' as a starting nonterminal of the grammar */
%start toplevel

/* Define type annotations for toplevel and bexp */
%type <string> toplevel
%%

/* The variables $1, $2, etc. refer to the values computed by the
 * first, second, etc., symbols of the grammar.
 */

toplevel:
  | SRC EOF { snd $1 }

