SOURCES = \
	parser/ast.ml \
	parser/range.ml   \
	parser/lexutil.ml \
	parser/comlexer.ml \
	parser/prelex.ml  \
	parser/srclexer.ml  \
	parser/comparser.ml  \
	parser/parsedriver.ml \
	writer/calico_writer.ml

GEN_SOURCES =  \
	parser/comparser.ml \
	parser/comlexer.ml  \
	parser/srclexer.ml  \
	parser/prelex.ml

all: rewrite compile_gen

original: test_SUT.c
	gcc -Wall -o test_SUT_original test_SUT.c
	./test_SUT_original

rewrite: parser_pre test_SUT calico.ml
	ocamlc str.cma -I writer/ -I parser/ -o calicoMain $(SOURCES) calico.ml
	./calicoMain sum_example.c

compile_gen:
	gcc calico_gen_sum_example.c

clean: test_SUT.c
	rm parser/*.cm* $(GEN_SOURCES)
	rm ./test_SUT_original test_SUT

build_lex:
	ocamllex parser/comlexer.mll
	ocamllex parser/srclexer.mll
	ocamllex parser/prelex.mll

build_yacc:
	ocamlyacc parser/comparser.mly

parser_pre: build_lex build_yacc
