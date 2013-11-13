all: original

original: test_SUT.c
	gcc -Wall -o test_SUT_original test_SUT.c