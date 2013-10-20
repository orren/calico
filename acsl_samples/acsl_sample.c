#include <stdio.h>
#include <stdlib.h>

extern int rand (void);
int sum(int [], int);
void multiply(int [], int, int);
void permute(int [], int);

void arrcpy (int A1[], int A2[], int length) {
  int i;
  for (i = 0; i < length; i++) {
    A2[i] = A1[i];
  }
}

int check_sum_double_is_double (int A [], int length) {
  int A2 [] = malloc(sizeof(int) * length);
  arrcpy(A, A2, length);
  multiply(A2, 2, length);

  int r1 = sum(A, length);
  int r2 = sum(A2, length);
  printf("*** original sum is: %d\n", r1);
  printf("*** modified sum is: %d\n", r2);

  /*@ assert r1 * 2 == r2; */
  free(A2);
  return 0;
}

int sum(int A[], int length) {
  int i, sum = 0;
  for (i = 0; i < length; i++) {
    sum += A[i];
  }
  return sum;
}

void multiply(int A[], int factor, int length) {
  int i;
  for (i = 0; i < length; i++) {
    A[i] *= factor;
  }
}

void permute(int A[], int length) {
  int i;
  for (i = 0; i < length; i++) {
    int which = rand() % length;
    int temp = A[i];
    A[i] = A[which];
    A[which] = temp;
  }
}

int main(void) {
  int a [3];

  a[0] = 1;
  a[1] = 2;
  a[2] = 3;

  printf("The sum is: %d\n", sum(a, 3));
  check_sum_double_is_double(a, 3);

  return 0;
}


