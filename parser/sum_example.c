#include <stdio.h>

extern void exit(int);

/**
 * May sum the elements of an array
 *
 * @fun-info { sum, sideEffect, "int" } ;
 * @param-info { A, "int*" } ;
 * @param-info { length, "int" } ;
 * @input-prop { PointReturn } multiply(A, two, length), { Pure } id(length) ;
 * @output-prop double ;
 * @input-prop { PointReturn } duplicate(A, length), { Pure } double(length) ;
 * @output-prop double ;
 */
int sum ( int arr [], int length ) {
  int i = 0, r = 0;
  for (; i < length;) r += arr[i++];
  return r;
}

int main () {
  int arr [] = {1, 2, 3};
  printf("*** The sum is : %d\n", sum(arr, 3));
  exit(0);
}
