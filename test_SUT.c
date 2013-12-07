#include <stdlib.h>
#include <stdio.h>

/**
 * Sums the elements of an array?
 *
 * @fun-info { sum, ArithmeticReturn, "int" } ;
 * @param-info { arr, "int*" } ;
 * @param-info { length, "int" } ;
 * @input-prop { VoidReturn } multiply_int_array(arr, 2, length), { ArithmeticReturn } id ;
 * @output-prop { ArithmeticReturn } multiply_int(result, 2) ;
 * @input-prop { VoidReturn } permute_int(arr, length), { ArithmeticReturn } id ;
 * @output-prop { ArithmeticReturn } result ;
 */
int sum(int *arr, int length) {
  int i, sum = 0;
  for (i = 0; i < length; i++) sum += arr[i];
  return sum;
}

// This is a comment that should not be changed

/**
 * Returns a pointer to a double that is the absolute value of a?
 *
 * @fun-info { absolute, PointerReturn, "double *" } ;
 * @param-info { a, "double"} ;
 * @input-prop { ArithmeticReturn } multiply_double(a, -1) ;
 * @output-prop { ArithmeticReturn } result ;
 */
double *absolute(double a) {
  double *answer = malloc(sizeof(double));
  if (a < 0) {
    *answer = -1 * a;
  } else {
    *answer = a;
  }
  return answer;
}

// here's more stuff lol watchout


int main() {
  
  int array[] = { 4, 7, -2, 1, 0 };

  int s = sum(array, 5);

  printf("sum is %d\n", s);

  double x = -15.5;
  double *y = absolute(x);

  printf("absolute value of %f is %f\n", x, *y);
}
