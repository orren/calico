#include <stdlib.h>
#include <stdio.h>

/**
 * Sums the elements of an array?
 *
 * @input-prop multiply(A, 2, length), length
 * @output-prop multiply_int(result, 2)
 *
 * @input-prop permute(A), length
 * @output-prop result
 */
int sum(int *A, int length) {
    int i, sum = 0;
    for (i = 0; i < length; i++) sum += A[i];
    return sum;
}

/**
 * Returns a pointer to a double that is the absolute value of a?
 *
 * @input-prop multiply_double(a, -1)
 * @output-prop result
 */
double *absolute(double a) {
    double *answer = malloc(sizeof(int));
    *answer = abs(a);
    return answer;
};

int main() {
  
  int array[] = { 4, 7, -2, 1, 0 };

  int s = sum(array, 5);

  printf("sum is %d\n", s);

  double x = -15.5;
  double *y = absolute(x);

  printf("absolute value of %f is %f", x, *y);
  
}