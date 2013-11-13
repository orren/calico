all: write compile run

write: calico_writer.ml
	ocamlc str.cma -I ../ -o cwriter ../SUT_struct.ml mock_SUT.ml calico_writer.ml
	./cwriter

compile: calico_simple_test.c
	gcc -Wall -o calico_simple_test calico_simple_test.c -I ..

run: calico_simple_test
	./calico_simple_test

clean:
	rm calico_simple_test calico_simple_test.c *.cm*
