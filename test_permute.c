#include <stdio.h>
#include "calico_prop_library.h"

void arr_print ( int arr [], int len) {

  printf("[ ");
  for (int i = 0; i < (len - 1); i++) {
    printf("%d, ", arr[i]);
  }
  printf("%d ", arr[len - 1]);
  printf("]\n");

}
int main () {

  int arr [] = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };

  permute(arr, 9, sizeof(int));

  arr_print(arr, 9);

}

