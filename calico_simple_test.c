#include "calico_prop_library.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int __sum(int *A, int length) {
    int i, sum = 0;
    for (i = 0; i < length; i++) sum += A[i];
    return sum;
}

/**
 * Sums the elements of an array?
 *
 * @input-prop multiply(A, 2, length), length
 * @output-prop multiply_int(result, 2)
 */
int sum(int *A, int length) {
    int key = 9847;
    size_t result_size = sizeof(int);
    int numProps = 2;
    int* shmids = malloc(numProps * sizeof(int));
    int procNum = -1;
    int i;
    int orig_result;
    int *result;

    for (i = 0; i < numProps; i += 1) {
        if (procNum == -1) {
            shmids[i] = shmget(key + i, result_size, IPC_CREAT | 0666);
            fork();
            procNum = i;
        } else {
            break;
        }
    }

    if (procNum == -1) {
        orig_result = __sum(A, length);
        for (i = 0; i < numProps; i += 1) {
            wait(NULL);
        }
    }

    if (procNum == 0) {
        int shmid = shmget(key + procNum, result_size, 0666);
        result = shmat(shmid, NULL, 0);
// < input_transformation
        multiply_int_array(A, 2, length);
// input_transformation >;
        // < input_transformation
        ;
// input_transformation >;
        // < call_inner_function
        *result = __sum(A, length);
// call_inner_function >
        // < output_transformation
        *result = multiply_int(*result, 2);
// output_transformation >
        shmdt(result);
        return 0;
    }

    if (procNum == 1) {
        int shmid = shmget(key + procNum, result_size, 0666);
        result = shmat(shmid, NULL, 0);
// < input_transformation
        multiply_int_array(A, -1, length);
// input_transformation >;
        // < input_transformation
        ;
// input_transformation >;
        // < call_inner_function
        *result = __sum(A, length);
// call_inner_function >
        // < output_transformation
        *result = multiply_int(*result, -1);
// output_transformation >
        shmdt(result);
        return 0;
    }

    result = shmat(shmids[0], NULL, 0);
    if (orig_result != *result) {
        printf("a property has been violated:\ninput_prop: multiply_int_array(A, 2, length), length\noutput_prop: multiply_int(result, 2)");
    }

    result = shmat(shmids[1], NULL, 0);
    if (orig_result != *result) {
        printf("a property has been violated:\ninput_prop: multiply_int_array(A, -1, length), length\noutput_prop: multiply_int(result, -1)");
    }

    free(shmids);
    return orig_result;
}

// some comment or whatever

double* __absolute(double a) {
    double *answer = malloc(sizeof(int));
    *answer = abs(a);
    return answer;
}

/**
 * Returns a pointer to a double that is the absolute value of a
 *
 * @input-prop multiply_double(a, -1)
 * @output-prop result
 */
double* absolute(double a) {
    int key = 9847;
    size_t result_size = sizeof(double);
    int numProps = 1;
    int* shmids = malloc(numProps * sizeof(int));
    int procNum = -1;
    int i;
    double *orig_result;
    double *result;

    for (i = 0; i < numProps; i += 1) {
        if (procNum == -1) {
            shmids[i] = shmget(key + i, result_size, IPC_CREAT | 0666);
            fork();
            procNum = i;
        } else {
            break;
        }
    }

    if (procNum == -1) {
        double *temp_orig_result = __absolute(a);
        memcpy(orig_result, temp_orig_result, sizeof(double));
        for (i = 0; i < numProps; i += 1) {
            wait(NULL);
        }
    }

    if (procNum == 0) {
        int shmid = shmget(key + procNum, result_size, 0666);
        result = shmat(shmid, NULL, 0);
// < input_transformation
        a = multiply_double(a, -1);
// input_transformation >;
        // < call_inner_function
        double *temp_f_result = __absolute(a);
        memcpy(result, temp_f_result, sizeof(double));
// call_inner_function >
        // < output_transformation
        *result = multiply_int(*result, 2);
// output_transformation >
        shmdt(result);
        return 0;
    }

    result = shmat(shmids[0], NULL, 0);
    if (*orig_result != *result) {
        printf("a property has been violated:\ninput_prop: multiply_double(a, -1)\noutput_prop: multiply_int(result, 2)");
    }

    free(shmids);
    return orig_result;
}
int main () {
return 0;
}