#include <calico.c>

// TODO: Eliminate this file?
/*
 * sum(\multiply(A, 2, length), length) == \result * 2
 * sum(\permute(A), length) == \result
 */
int sum(int A[], int length) {
  int i, sum = 0;
  for (i = 0; i < length; i++) {
    sum += A[i];
  }
  return sum;
}

int multiply(int A[], int factor, int length) {
  int i;
  for (i = 0; i < length; i++) {
    A[i] *= factor;
  }
}

/*
 * 
 */
int permute(int A[], int length) {
  int i;
  for (i = 0; i < length; i++) {
    int which = random() % length;
    int temp = A[i];
    A[i] = A[which];
    A[which] = temp;
  }
}
