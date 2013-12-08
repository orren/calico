#include <stdio.h>

extern void exit(int);

/**
 * Crazy: weird (comment, text)
 */
/**
 * May sum the elements of an array
 *
 * @fun-info { sum, "int" } ;
 * @param-info { arr, "int*" } ;
 * @param-info { length, "int" } ;
 * @input-prop { multiply_int_array(arr, 2, length), id } ;
 * @output-prop { "double_int(result)" } ;
 * @input-prop { duplicate(arr, length), double_int(length) } ;
 * @output-prop { double_int(result, 1, 2, 3) } ;
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
