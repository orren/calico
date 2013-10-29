DIR=`frama-c -print-share-path`/e-acsl

MDIR=$(DIR)/memory_model

build: pre1
	cc -Wno-attributes -o gen -DE_ACSL_MACHDEP=x86_64 \
	$(DIR)/e_acsl.c $(MDIR)/e_acsl_bittree.c $(MDIR)/e_acsl_mmodel.c \
	generated_code.c

pre2:
	frama-c -machdep x86_64 -e-acsl test_acsl.c -then-on e-acsl -print -ocode generated_code.c

pre1:
	frama-c -machdep x86_64 -e-acsl acsl_sample.c -then-on e-acsl -print -ocode generated_code.c
