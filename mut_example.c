#include <stdio.h>

extern void exit(int);

/**
 * May sum the elements of an array
 *
 * @fun-info { double_int_ptr, VoidReturn, "void" } ;
 * @param-info { in, "int*" } ;
 * @input-prop { VoidReturn } negate(in) ;
 * @output-prop { VoidReturn } negate(in) ;
 * @state-recover { in, "sizeof(int)", 1 } ;
 * @equality-op { memcmp } ;
 */
void double_int_ptr ( int* in ) {
  *in = *in * 2;
}

int main () {
  int n = 5;
  double_int_ptr(&n);
  printf("*** Double int is %d\n", n);
  exit(0);
}


