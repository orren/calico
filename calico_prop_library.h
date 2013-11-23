#ifndef _calico_props
#define _calico_props

#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int key = 8947;

int multiply_int(int a, int factor) {
  return a * factor;
}

/*
int sum ( int arr [], int length ) {
  int i = 0, r = 0;
  for (; i < length;) r += arr[i++];
  return r;
}
*/

int negate (int n) {
  return n * (-1);
}

int id(int n) {
  return n;
}

int double_int(int n) {
  return n * 2;
}

int* duplicate(int *a, int length) {
  int* res = malloc(sizeof(int) * (length * 2));
  int i;

  for (i = 0; i < length; i++) {
    res[i] = a[i];
  }
  int j;
  for (j = 0; j < length; j++, i++) {
    res[i] = a[j];
  }

  return res;
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

void permute_int(int A[], int length) {
  srand(time(NULL));
  int i;
  for (i = 0; i < length; i++) {
    int which = rand() % length;
    int temp = A[i];
    A[i] = A[which];
    A[which] = temp;
  }
}

void permute(void* base, size_t nmemb, size_t size) {
  srand(time(NULL));
  int i;

  void * temp = malloc(size);

  for (i = 0; i < nmemb; i++) {
    int which = rand() % nmemb;
    memcpy(temp, (base + (which * size)), size);
    memcpy((base + (i * size)), (base + (which * size)), size);
    memcpy((base + (which * size)), (base + (i * size)), size);
  }
}

#endif
