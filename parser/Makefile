INTERFACES =   \
	range.mli  \
	parser.mli \
# 	lexer.mli

SOURCES =      \
	range.ml   \
	parser.ml  \
	prelex.ml  \
	lexer.ml

GEN_SOURCES =  \
	parser.ml \
	lexer.ml

all: clean run

clean:
	rm *.cm* pmain $(GEN_SOURCES)

build_lex:
	ocamllex lexer.mll
	ocamllex prelex.mll

build_yacc:
	ocamlyacc parser.mly

build: build_lex build_yacc
	ocamlc -o pmain ast.ml $(INTERFACES) $(SOURCES) main.ml

run: build
	./pmain
