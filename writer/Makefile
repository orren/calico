all: write compile run

write: calico_writer.ml
	ocaml calico_writer.ml

compile: calico_simple_test.c
	gcc -Wall -o calico_simple_test calico_simple_test.c

run: calico_simple_test
	./calico_simple_test

clean:
	rm calico_simple_test calico_simple_test.c