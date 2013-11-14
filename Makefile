all: rewrite

original: test_SUT.c
	gcc -Wall -o test_SUT_original test_SUT.c
	./test_SUT_original

rewrite: test_SUT calico.ml
	ocamlc -I writer/ -I parser/ -o calicoMain writer/calico_writer.ml parser/parsedriver.ml calico.ml
	calicoMain test_SUT.c

clean: test_SUT.c
	rm ./test_SUT_original test_SUT
