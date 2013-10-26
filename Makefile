all: write compile

write: calico.ml
	ocaml calico.ml

compile: calico_simple_test.c
	gcc -Wall -o calico_simple_test calico_simple_test.c