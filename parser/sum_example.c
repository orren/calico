#include <stdio.h>

extern void exit(int);

/**
 * May sum the elements of an array
 *
 * @fun-info { foo, sideEffect, "int" } ;
 * @param-info { A, "int*" } ;
 * @param-info { length, "int" } ;
 * @input-prop multiply(A, two, length), id(length) ;
 * @output-prop double ;
 * @input-prop duplicate(A, length), double(length) ;
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
