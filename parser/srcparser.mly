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
%token <Range.t * string> ENUM
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
%token <Range.t * string> EQUALS

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
  | function_definition EOF  { $1 }

function_definition:
  | declaration_specifiers declarator declaration_list compound_statement { $4 }
  |                        declarator declaration_list compound_statement { $3 }
  | declaration_specifiers declarator                  compound_statement { $3 }
  |                        declarator                  compound_statement { $2 }

compound_statement:
  | LBRACE any RBRACE { $2 }

constant_expression:
  | any {}

assignment_expression:
  | any {}

any:
  | any_elem     { Printf.printf "any elem: %s\n" $1;
                   $1 }
  | any_elem any { $1 ^ $2 }

declarator:
  | pointer direct_declarator {}
  |         direct_declarator { Printf.printf "direct_declarator\n"; }

direct_declarator:
  | IDENT {}
  | LPAREN declarator RPAREN {}
  | direct_declarator LBRACKET constant_expression RBRACKET {}
  | direct_declarator LBRACKET                     RBRACKET {}
  | direct_declarator LPAREN parameter_type_list RPAREN {}
  | direct_declarator LPAREN identifier_list RPAREN {}
  | direct_declarator LPAREN                 RPAREN {}

declaration:
  | declaration_specifiers SEMI {}
  | declaration_specifiers init_declarator_list SEMI {}

init_declarator_list:
  | declarator {}
  | declarator EQUALS einitializer {}

initializer_list:
  | einitializer {}
  | initializer_list COMMA einitializer {}

einitializer:
  | assignment_expression {}
  | LBRACE initializer_list RBRACE {}
  | LBRACE initializer_list COMMA RBRACE {}

declaration_list:
  | declaration {}
  | declaration_list declaration {}

declaration_specifiers:
  | storage_class_specifier {}
  | type_specifier { Printf.printf "type_specifier: %s\n" $1; }
  | type_qualifier {}
  | storage_class_specifier declaration_specifiers {}
  | type_specifier          declaration_specifiers {}
  | type_qualifier          declaration_specifiers {}

type_specifier:
  /* | VOID { }
  | CHAR {} 
  | SHORT {} */
  | INT { snd $1 }
  /* | LONG {}
  | FLOAT {}
  | DOUBLE {}
  | SIGNED {}
  | UNSIGNED {}
  | struct_or_union_specifier {}
  | enum_specifier {}
  | typedef_name  {} */

enum_specifier:
  | ENUM IDENT LBRACE enumerator_list RBRACE {}
  | ENUM       LBRACE enumerator_list RBRACE {}
  | ENUM IDENT {}

enumerator_list:
  | enumerator {}
  | enumerator_list COMMA enumerator_list {}

enumerator:
  | IDENT {}
  | IDENT EQUALS constant_expression {}

typedef_name:
  | IDENT {}

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


identifier_list:
  | IDENT {}
  | identifier_list COMMA IDENT {}

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

any_elem:
  | AUTO     { snd $1 }
  | REGISTER { snd $1 }
  | STATIC   { snd $1 }
  | EXTERN   { snd $1 }
  | TYPEDEF  { snd $1 }
  | VOID     { snd $1 }
  | CHAR     { snd $1 }
  | SHORT    { snd $1 }
  | INT      { snd $1 }
  | LONG     { snd $1 }
  | FLOAT    { snd $1 }
  | DOUBLE   { snd $1 }
  | SIGNED   { snd $1 }
  | UNSIGNED { snd $1 }
  | CONST    { snd $1 }
  | VOLATILE { snd $1 }
  | STRUCT   { snd $1 }
  | UNION    { snd $1 }
  | LBRACE   { snd $1 }
  | RBRACE   { snd $1 }
  | COMMA    { snd $1 }
  | LPAREN   { snd $1 }
  | RPAREN   { snd $1 }
  | LBRACKET { snd $1 }
  | RBRACKET { snd $1 }
  | STAR     { snd $1 }
  | SEMI     { snd $1 }
  | COLON    { snd $1 }
  | DOT      { snd $1 }
  | IDENT    { snd $1 }
  | EQUALS   { snd $1 }
