#include "calico_prop_library.h"
#include <stdio.h>

extern void exit(int);



int __sum(int* arr, int length) {
  int i = 0, r = 0;
  for (; i < length;) r += arr[i++];
  return r;
}

int sum(int* arr, int length) {
    int key = 9847;
    size_t result_size = sizeof(int);
    int numProps = 2;
    int* shmids = malloc(numProps * sizeof(int));
    int procNum = -1;
    int i;
    int orig_result = 0;
    int* result = 0;

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
        orig_result = __sum(arr, length);
        for (i = 0; i < numProps; i += 1) {
            wait(NULL);
        }
    }

    if (procNum == 0) {
        int shmid = shmget(key + procNum, result_size, 0666);
        result = shmat(shmid, NULL, 0);
// < input_transformation
        int* *temp_arr = multiply_int_array(arr, 2, length);
        memcpy(arr, temp_arr, sizeof (int*));
// input_transformation >;
        // < input_transformation
        length = id(length);
// input_transformation >;
// < call_inner_function
        *result = __sum(arr, length);
// call_inner_function >
// < output_transformation
        *result = double_int;
// output_transformation >
        shmdt(result);
        return 0;
    }

    if (procNum == 1) {
        int shmid = shmget(key + procNum, result_size, 0666);
        result = shmat(shmid, NULL, 0);
// < input_transformation
        int* *temp_arr = duplicate(arr, length);
        memcpy(arr, temp_arr, sizeof (int*));
// input_transformation >;
        // < input_transformation
        length = double_int(length);
// input_transformation >;
// < call_inner_function
        *result = __sum(arr, length);
// call_inner_function >
// < output_transformation
        *result = double_int;
// output_transformation >
        shmdt(result);
        return 0;
    }

    result = shmat(shmids[0], NULL, 0);
    if (orig_result != *result) {
        printf("a property has been violated:\ninput_prop: multiply_int_array, id\noutput_prop: double_int");
    }

    result = shmat(shmids[1], NULL, 0);
    if (orig_result != *result) {
        printf("a property has been violated:\ninput_prop: duplicate, double_int\noutput_prop: double_int");
    }

    free(shmids);
    return orig_result;
}
int main () {
return 0;
}
