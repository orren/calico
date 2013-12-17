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

all: all_sum all_SUT all_mut all_merge

all_sum: build_main rwr_sum run_sum

all_SUT: build_main rwr_SUT run_SUT

all_mut: build_main rwr_mut run_mut

all_merge: build_main rwr_merge run_merge

build_main: parser_pre calico.ml
	ocamlc str.cma -I writer/ -I parser/ -o calicoMain parser/ast.ml $(INTERFACES) $(SOURCES) calico.ml

comp_SUT: examples/test_SUT.c
	gcc -I . -Wall -o test_SUT_original examples/test_SUT.c
	./test_SUT_original

comp_sum: examples/sum_example.c
	gcc -I . -Wall -o sum_example_original examples/sum_example.c
	./sum_example_original

comp_mut: examples/mut_example.c
	gcc -I . -Wall -o mut_example_original examples/mut_example.c
	./mut_example_original

comp_merge: martirank/merge.c
	gcc -I . -Wall -o merge_original martirank/ml3.c martirank/merge.c martirank/m-core.c
	./merge_original martirank/data.txt ./output.txt --no-permute --no-prob-dist

rwr_SUT: build_main examples/test_SUT.c
	./calicoMain examples/test_SUT.c

rwr_sum: build_main examples/sum_example.c
	./calicoMain examples/sum_example.c

rwr_mut: build_main examples/mut_example.c
	./calicoMain examples/mut_example.c

rwr_merge: build_main martirank/merge.c
	./calicoMain martirank/merge.c

run_SUT:
	gcc -I . -Wall -o calico_gen_test_SUT examples/calico_gen_test_SUT.c
	./calico_gen_test_SUT

run_sum:
	gcc -I . -Wall -o calico_gen_sum_example examples/calico_gen_sum_example.c
	./calico_gen_sum_example

run_mut:
	gcc -I . -Wall -o calico_gen_mut_example examples/calico_gen_mut_example.c
	./calico_gen_mut_example

run_merge:
	gcc -Wall -I . -o calico_gen_merge martirank/calico_gen_merge.c martirank/ml3.c martirank/m-core.c
	./calico_gen_merge martirank/data.txt ./output.txt --no-permute --no-prob-dist

clean:
	rm calicoMain
	rm parser/*.cm* $(GEN_SOURCES)
	rm writer/*.cm*
	rm *.cm*
	rm examples/calico_gen_*
	rm calico_gen_*
	rm ./test_SUT_original test_SUT ./sum_example_original sum_example

build_lex:
	ocamllex parser/comlexer.mll
	ocamllex parser/srclexer.mll
	ocamllex parser/prelex.mll

build_yacc:
	ocamlyacc parser/comparser.mly

parser_pre: build_lex build_yacc
