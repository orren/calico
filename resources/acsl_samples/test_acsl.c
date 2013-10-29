#include <sys/types.h>
#include <sys/ipc.h>
#include <stdlib.h>
#include <sys/shm.h>
#include <stdio.h>
#include <string.h>


int __sum(int A[], int length) {
  int i, sum = 0;
  for (i = 0; i < length; i++) sum += A[i];
  return sum;
}

void __multiply(int A[], int factor, int length) {
  int i;
  for (i = 0; i < length; i++) A[i] *= factor;
}

void __permute(int A[], int length) {
  int i;
  for (i = 0; i < length; i++) {
    int which = random() % length;
    int temp = A[i];
    A[i] = A[which];
    A[which] = temp;
  }
}


int __sum_test1(int A[], int length, int *result, char *ready) {
  // apply transformation
  __multiply(A, 2, length);

  int s1 = __sum(A, length); // call the function again

  // wait for parent
  while (*ready == 0);

  printf("I read %d\n", *result);

  // int s2 = *result * 2;

  // do the check
  //@ ghost int s2 = *result * 2;
  //@ assert s1 == s2;

  // if (s == *result * 2) {
  //  printf("Test 1 passed!\n");
  //bin/  }
  // else printf("Test 1 failed! %d %d\n", *result, s);
  shmdt(result);
  exit(0);
}

int __sum_test2(int A[], int length, int *result, char *ready) {
  // apply transformation
  __permute(A, length);

  int s = __sum(A, length); // call the function again

  // wait for parent
  while (*ready == 0);

  printf("I read %d\n", *result);

  // do the check
  if (s == *result) {
    printf("Test 2 passed!\n");
  }
  else printf("Test 2 failed! %d %d\n", *result, s);
  shmdt(result);
  exit(0);
}

int sum(int A[], int length) {

  
    int shmid;
    key_t key = 9487; // set the key for the shared memory segment
    int retval = 0;

    int *result; // the type comes from the function's return value
    char *ready; // to indicate that the result is ready

    // Create the segment for the result
    // the size is the same as the size of the function's return value
    if ((shmid = shmget(key, sizeof(int), IPC_CREAT | 0666)) < 0) {
        perror("shmget");
        exit(1);
    }
    // Attach to the segment.
    if ((result = shmat(shmid, NULL, 0)) ==  (int*)-1) {
        perror("shmat");
        exit(1);
    }

    // Create the segment for the ready flag
    if ((shmid = shmget(key+1, sizeof(char), IPC_CREAT | 0666)) < 0) {
        perror("shmget");
        exit(1);
    }
    // Attach to the segment.
    if ((ready = shmat(shmid, NULL, 0)) ==  (char*)-1) {
        perror("shmat");
        exit(1);
    }
    // initialize
    *ready = 0;


    if (fork() == 0) {
      __sum_test1(A, length, result, ready);
    }
    if (fork() == 0) {
      __sum_test2(A, length, result, ready);
    }

    printf("I'm the parent\n");

    retval = __sum(A, length); // original function call

    // put the return val in shared memory
    *result = retval;
    *ready = 1; // indicate that we've updated it

    //printf("Rest of program\n");
    return retval;
}

int main() {

  int array[] = { 4, 7, -2, 1, 0 };

  int s = sum(array, 5);

  printf("sum is %d\n", s);

}
