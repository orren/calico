#include <stdio.h>

extern void exit(int);

/**
 * May sum the elements of an array
 *
 * @fun-info { sum, ArithmeticReturn, "int" } ;
 * @param-info { arr, "int*" } ;
 * @param-info { length, "int" } ;
 * @input-prop { VoidReturn } multiply_int_array(arr, 2, length), { ArithmeticReturn } id ;
 * @output-prop { ArithmeticReturn } double_int(result) ;
 * @input-prop { PointerReturn } duplicate(arr, length), { ArithmeticReturn } double_int(length) ;
 * @output-prop { ArithmeticReturn } double_int(result) ;
 */
int sum ( int arr [], int length ) {
  int i = 0, r = 0;
  for (; i < length;) r += arr[i++];
  return r;
}

int main () {
  int arr [] = {1, 2, 3};
  int x = sum(arr, 3);
  printf("*** The sum is : %d\n", x);
  exit(0);
}
