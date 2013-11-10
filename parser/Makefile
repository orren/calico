INTERFACES =   \
	range.mli  \
	comparser.mli

SOURCES =      \
	../SUT_struct.ml \
	range.ml   \
	lexutil.ml \
	prelex.ml  \
	srclexer.ml  \
	comparser.ml  \
	comlexer.ml

GEN_SOURCES =  \
	comparser.ml \
	comlexer.ml  \
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

build: build_lex build_yacc
	ocamlc str.cma -o pmain ast.ml $(INTERFACES) $(SOURCES) main.ml

run: build
	./pmain
