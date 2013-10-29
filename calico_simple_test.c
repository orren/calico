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
    int key = 9487;
    size_t result_size = sizeof(int);
    int numProps = 2;
    int* shmids = malloc(numProps * sizeof(int));
    int procNum = -1;
    int i;

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
        int result = __sum(A, length);
        for (i = 0; i < numProps; i += 1) {
            wait(NULL);
        }
    }

    if (procNum == 0) {
        int shmid = shmget(key + procNum, result_size, 0666);
        int *result = shmat(shmid, NULL, 0);
        *result = __sum(multiply(A, 2, length), id);
        *result = double(*result);
        shmdt(result);
        return 0;
    }

    if (procNum == 1) {
        int shmid = shmget(key + procNum, result_size, 0666);
        int *result = shmat(shmid, NULL, 0);
        *result = __sum(multiply(A, -1, length, id);
        *result = negate(*result);
        shmdt(result);
        return 0;
    }

    int *trans_result;
    trans_result = shmat(shmids[0], NULL, 0);
    if (*result != *trans_result) {
        printf("a property has been violated:\ninput_prop: %s\noutput_prop: %s, multiply(A, 2, length), id", double);
    }
    trans_result = shmat(shmids[1], NULL, 0);
    if (*result != *trans_result) {
        printf("a property has been violated:\ninput_prop: %s\noutput_prop: %s, multiply(A, -1, length, id", negate);
    }    dealloc(chmids);
    return result;
}

// some comment or whatever
