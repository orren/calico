#include <stdio.h>

extern void exit(int);

/**
 * May sum the elements of an array
 *
 * @fun-info { double_int_ptr, SideEffect, "void" } ;
 * @param-info { in, "int*" } ;
 * @input-prop { Pure } negate(in) ;
 * @output-prop { Pure } negate(in), { "in", "int*" } ;
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


