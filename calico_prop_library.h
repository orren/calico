#ifndef _calico_props
#define _calico_props

#include <stdlib.h>
#include <time.h>

int multiply_int(int a, int factor) {
  return a * factor;
}

void multiply_int_array(int *a, int factor, int length) {
  int i;
  for (i = 0; i < length; i++) a[i] *= factor;
}

double multiply_double(double a, double factor) {
  return a * factor;
}

void multiply_double_array(double* a, double factor, double length) {
  int i;
  for (i = 0; i < length; i++) a[i] *= factor;
}

void permute(int A[], int length) {
  srand(time(NULL));
  int i;
  for (i = 0; i < length; i++) {
    int which = rand() % length;
    int temp = A[i];
    A[i] = A[which];
    A[which] = temp;
  }
}

#endif