DIR=`frama-c -print-share-path`/e-acsl

MDIR=$(DIR)/memory_model

build: pre
	gcc -o gen -DE_ACSL_MACHDEP=x86_64 \
	$(DIR)/e_acsl.c $(MDIR)/e_acsl_bittree.c $(MDIR)/e_acsl_mmodel.c \
	generated_code.c

pre:
	ECHO $(DIR) \
	frama-c -e-acsl acsl_sample.c -then-on e-acsl -print -ocode generated_code.c
