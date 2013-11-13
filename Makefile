all: original

original: test_SUT.c
	gcc -Wall -o test_SUT_original test_SUT.c
	./test_SUT_original

clean: test_SUT_original
	rm ./test_SUT_original