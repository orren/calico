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
%token <Range.t * string> AUTO
%token <Range.t * string> REGISTER
%token <Range.t * string> STATIC
%token <Range.t * string> EXTERN
%token <Range.t * string> TYPEDEF
%token <Range.t * string> VOID
%token <Range.t * string> CHAR
%token <Range.t * string> SHORT
%token <Range.t * string> INT
%token <Range.t * string> LONG
%token <Range.t * string> FLOAT
%token <Range.t * string> DOUBLE
%token <Range.t * string> SIGNED
%token <Range.t * string> UNSIGNED
%token <Range.t * string> CONST
%token <Range.t * string> VOLATILE
%token <Range.t * string> STRUCT
%token <Range.t * string> UNION
%token <Range.t * string> LBRACE
%token <Range.t * string> RBRACE
%token <Range.t * string> COMMA
%token <Range.t * string> LPAREN
%token <Range.t * string> RPAREN
%token <Range.t * string> LBRACKET
%token <Range.t * string> RBRACKET
%token <Range.t * string> STAR
%token <Range.t * string> SEMI
%token <Range.t * string> COLON
%token <Range.t * string> DOT

%token <Range.t * string> IDENT



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
  | declaration_specifiers declarator declaration_list compound_statement { "" }
  |                        declarator declaration_list compound_statement { "" }
  | declaration_specifiers declarator                  compound_statement { "" }
  |                        declarator                  compound_statement { "" }

compound_statement:
  | RBRACE any LBRACE {}

constant_expression:
  | any {}

declaration_list:
  | declaration {}
  | declaration_list declaration {}

declaration_specifiers:
  | storage_class_specifier {}
  | type_specifier {}
  | type_qualifier {}
  | storage_class_specifier declaration_specifiers {}
  | type_specifier          declaration_specifiers {}
  | type_qualifier          declaration_specifiers  {}

type_specifier:
  | VOID {}
  | CHAR {}
  | SHORT {}
  | INT {}
  | LONG {}
  | FLOAT {}
  | DOUBLE {}
  | SIGNED {}
  | UNSIGNED {}
  | struct_or_union_specifier {}
  | enum_specifier {}
  | typedef_name  {}

type_qualifier:
  | CONST {}
  | VOLATILE {}

storage_class_specifier:
  | AUTO {}
  | REGISTER {}
  | STATIC {}
  | EXTERN {}
  | TYPEDEF {}

struct_or_union_specifier:
  | struct_or_union IDENT LBRACE struct_declaration_list RBRACE {}
  | struct_or_union       LBRACE struct_declaration_list RBRACE {}
  | struct_or_union IDENT {}

struct_declaration_list:
  | struct_declaration {}
  | struct_declaration_list struct_declaration {}

struct_declaration:
  | specifier_qualifier_list struct_declarator_list SEMI {}


specifier_qualifier_list:
  | type_specifier specifier_qualifier_list {}
  | type_specifier {}
  | type_qualifier specifier_qualifier_list {}
  | type_qualifier {}

struct_or_union:
  | STRUCT {}
  | UNION {}

declarator:
  | pointer direct_declarator {}
  |         direct_declarator {}

direct_declarator:
  | IDENT {}
  | LPAREN declarator RPAREN {}
  | direct_declarator LBRACKET constant_expression RBRACKET {}
  | direct_declarator LBRACKET                     RBRACKET {}
  | direct_declarator LPAREN parameter_type_list RPAREN {}
  | direct_declarator LPAREN identifier_list RPAREN {}
  | direct_declarator LPAREN                 RPAREN {}

parameter_type_list:
  | parameter_list {}
  | parameter_list COMMA DOT DOT DOT {}

parameter_list:
  | parameter_declaration {}
  | parameter_list COMMA parameter_declaration {}

parameter_declaration:
  | declaration_specifiers declarator {}
  | declaration_specifiers abstract_declarator {}
  | declaration_specifiers {}

abstract_declarator:
  | pointer {}
  | pointer direct_abstract_declarator {}
  |         direct_abstract_declarator {}

direct_abstract_declarator:
  | LPAREN abstract_declarator RPAREN {}
  | direct_abstract_declarator LBRACKET constant_expression RBRACKET {}
  |                            LBRACKET                     RBRACKET {}
  | direct_abstract_declarator LBRACKET constant_expression RBRACKET {}
  | direct_abstract_declarator LPAREN parameter_type_list RPAREN {}
  |                            LPAREN                     RPAREN {}

struct_declarator_list:
  | struct_declarator {}
  | struct_declarator_list COMMA struct_declarator {}

struct_declarator:
  | declarator {}
  | declarator COLON constant_expression {}
  |            COLON constant_expression {}

pointer:
  | STAR {}
  | STAR type_qualifier_list {}
  | STAR type_qualifier_list pointer {}
  | STAR                     pointer {}

type_qualifier_list:
  | type_qualifier {}
  | type_qualifier_list type_qualifier {}

