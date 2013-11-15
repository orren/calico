#include <stdio.h>

extern void exit(int);

/**
 * May sum the elements of an array
 *
 * @fun-info { sum, SideEffect, "int" } ;
 * @param-info { arr, "int*" } ;
 * @param-info { length, "int" } ;
 * @input-prop { PointReturn } multiply(arr, 2, length), { Pure } id(length) ;
 * @output-prop { Pure } double ;
 * @input-prop { PointReturn } duplicate(arr, length), { Pure } double(length) ;
 * @output-prop { Pure } double ;
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
