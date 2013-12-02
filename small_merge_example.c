#include <stdio.h>
#include "martirank/calico_gen_merge.c"

void arr_print (int arr [], int length) {
  int i;
  printf("{ ");
  for (i = 0; i < (length - 1); i++) {
    printf("%d, ", arr[i]);
  }
  printf("%d ", arr[length - 1]);
  printf(" }\n");
}

int compare_ints(const void* a, const void* b) {
  int a_val = * (int *) a;
  int b_val = * (int *) b;
  return (a_val < b_val) ? -1 : ((a_val == b_val) ? 0 : 1);
}

int main () {

  int arr [] = {1, 2, 3, 7, 34, 0, 12};
  printf("*** input: \n");
  arr_print(arr, 7);
  mergesort(arr, 7, sizeof(int), compare_ints);
  printf("*** output: \n");
  arr_print(arr, 7);

  return 0;
}

