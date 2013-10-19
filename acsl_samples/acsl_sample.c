#include <stdio.h>
#include <stdlib.h>


int sum(int [], int);
int multiply(int [], int, int);
int permute(int [], int);

int main(void) {
  int a [3];

  a[0] = 1;
  a[1] = 2;
  a[2] = 3;

  printf("The sum is: %d\n", sum(a, 3));

  /*@ assert \true; */
  return 0;
}

/**
 *
 * 
 */
int sum(int A[], int length) {
  int i, sum = 0;
  for (i = 0; i < length; i++) {
    sum += A[i];
  }
  return sum;
}

/**
int multiply(int A[], int factor, int length) {
  int i;
  for (i = 0; i < length; i++) {
    A[i] *= factor;
  }
  return;
}

int permute(int A[], int length) {
  int i;
  for (i = 0; i < length; i++) {
    int which = rand() % length;
    int temp = A[i];
    A[i] = A[which];
    A[which] = temp;
  }
  return;
}

*/
