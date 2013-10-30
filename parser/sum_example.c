#include <stdio.h>

extern void exit(int);

/**
 * May sum the elements of an array!
 * @input-prop multiply(A, 2, length), id
 * @output-prop double
 */
int sum ( int arr [], int length ) {
  int i = 0;
  int r = 0;
  for (; i < length;) r += arr[i++];
  return r;
}

int main () {
  int arr [] = {1, 2, 3};
  printf("*** The sum is : %d\n", sum(arr, 3));
  exit(0);
}
