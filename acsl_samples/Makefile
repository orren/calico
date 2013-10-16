build: pre
	gcc -o gen `frama-c -print-share-path`/e-acsl/e_acsl.c generated_code.c

pre:
	frama-c -e-acsl acsl_sample.c -then-on e-acsl -print -ocode generated_code.c
