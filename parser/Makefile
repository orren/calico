INTERFACES =   \
	range.mli  \
	comparser.mli \
	srcparser.mli

SOURCES =      \
	../SUT_struct.ml \
	range.ml   \
	lexutil.ml \
	prelex.ml  \
	srcparser.ml \
	srclexer.ml  \
	comparser.ml  \
	comlexer.ml

GEN_SOURCES =  \
	comparser.ml \
	comlexer.ml  \
	srcparser.ml \
	srclexer.ml  \
	prelex.ml

all: clean run

clean:
	rm *.cm* pmain $(GEN_SOURCES)

build_lex:
	ocamllex comlexer.mll
	ocamllex srclexer.mll
	ocamllex prelex.mll

build_yacc:
	ocamlyacc comparser.mly
	ocamlyacc srcparser.mly

build: build_lex build_yacc
	ocamlc -o pmain ast.ml $(INTERFACES) $(SOURCES) main.ml

run: build
	./pmain
