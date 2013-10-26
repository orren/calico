INTERFACES =   \
	range.mli  \
	parser.mli \
# 	lexer.mli

SOURCES =      \
	range.ml   \
	parser.ml  \
	lexer.ml

all: clean run

clean:
	rm *.cm*

build_lex:
	ocamllex lexer.mll

build_yacc:
	ocamlyacc parser.mly

build: build_lex build_yacc
	ocamlc -o pmain ast.ml $(INTERFACES) $(SOURCES) main.ml

run: build
	./pmain
