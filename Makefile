INTERFACES =   \
	parser/range.mli  \
	parser/comparser.mli

SOURCES = \
	parser/ast.ml \
	parser/range.ml   \
	parser/lexutil.ml \
	parser/comparser.ml  \
	parser/comlexer.ml \
	parser/prelex.ml  \
	parser/srclexer.ml  \
	parser/parsedriver.ml \
	writer/calico_writer.ml

GEN_SOURCES =  \
	parser/comparser.ml \
	parser/comlexer.ml  \
	parser/srclexer.ml  \
	parser/prelex.ml

all: build_main comp_SUT comp_sum run_SUT run_sum

build_main: parser_pre calico.ml
	ocamlc str.cma -I writer/ -I parser/ -o calicoMain parser/ast.ml $(INTERFACES) $(SOURCES) calico.ml

comp_SUT: test_SUT.c
	gcc -Wall -o test_SUT_original test_SUT.c
	./test_SUT_original

comp_sum: sum_example.c
	gcc -Wall -o sum_example_original sum_example.c
	./sum_example_original

run_SUT: build_main test_SUT.c
	./calicoMain test_SUT.c
	gcc -Wall -o calico_gen_test_SUT calico_gen_test_SUT.c

run_sum: build_main sum_example.c
	./calicoMain sum_example.c
	gcc -Wall -o calico_gen_sum_example calico_gen_sum_example.c

clean: test_SUT.c sum_example.c
	rm parser/*.cm* $(GEN_SOURCES)
	rm calico_gen_*
	rm ./test_SUT_original test_SUT ./sum_example_original sum_example

build_lex:
	ocamllex parser/comlexer.mll
	ocamllex parser/srclexer.mll
	ocamllex parser/prelex.mll

build_yacc:
	ocamlyacc parser/comparser.mly

parser_pre: build_lex build_yacc
