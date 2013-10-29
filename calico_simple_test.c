#include "calico_prop_library.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int __sum(int A[], int length) {
    int i, sum = 0;
    for (i = 0; i < length; i++) sum += A[i];
    return sum;
}

/**
 * Sums the elements of an array?
 *
 * @input-prop multiply(A, 2, length), id
 * @output-prop double
 */
int sum(int A[], int length) {
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
        multiply_int_array(A, 2, length);
        id(length);
        result = __sum(A, length);
        double(result, length);
        shmdt(result);
        return 0;
    }

    if (procNum == 1) {
        int shmid = shmget(key + procNum, result_size, 0666);
        result = shmat(shmid, NULL, 0);
        multiply(A, -1, length);
        id(length);
        result = __sum(A, length);
        multiply_int(result, -1);
        shmdt(result);
        return 0;
    }

    result = shmat(shmids[0], NULL, 0);
    if (orig_result != *result) {
        printf("a property has been violated:\ninput_prop: %s\noutput_prop: %s, multiply_int_array(A, 2, length), id(length)", double(result, length));
    }
    result = shmat(shmids[1], NULL, 0);
    if (orig_result != *result) {
        printf("a property has been violated:\ninput_prop: %s\noutput_prop: %s, multiply(A, -1, length), id(length)", multiply_int(result, -1));
    }    dealloc(shmids);
    return orig_result;
}

// some comment or whatever
