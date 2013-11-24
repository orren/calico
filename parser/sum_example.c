#include <stdio.h>

extern void exit(int);

/**
 * Crazy: weird (comment, text)
 */
/**
 * May sum the elements of an array
 *
 * @fun-info { sum, Pure, "int" } ;
 * @param-info { arr, "int*" } ;
 * @param-info { length, "int" } ;
 * @input-prop { SideEffect } multiply_int_array(arr, 2, length), { Pure } id ;
 * @output-prop { Pure } "double_int(result)" ;
 * @input-prop { PointReturn } duplicate(arr, length), { Pure } double_int(length) ;
 * @output-prop { Pure } double_int(result, 1, 2, 3) ;
 */
int sum ( int arr [], int length ) {
  int i = 0, r = 0; /* mulit-line comment in source */
  for (; i < length;) r += arr[i++];
  return r;
}

int main () {
  int arr [] = {1, 2, 3};
  printf("*** The sum is : %d\n", sum(arr, 3));
  exit(0);
}
