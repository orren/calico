/*
 * $Id: luis$
 *
 */

/*
 * The marti sorting component.
 */

#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <stdarg.h>
#include <ctype.h>

#include "marti.h"


double **tabula = NULL;   /* a matrix of the samples. 
			     defined in calling program */

int exti; /* used for indexing into the tabula */

/*
 * The perl <=> (less-equal-greater) operator
 */

inline int
ileg(register int a, register int b)
{
  return (a < b) ? -1 : ((a==b) ? 0 : 1);
}

inline int
dleg(register double a, register double b)
{
  return (a < b) ? -1 : ((a==b) ? 0 : 1);
}


/*
 * Compare-ascending
 */

int
compasc(const void *ap, const void *bp) 
{
  register int a, b;
    
  a = *(int *)ap;
  b = *(int *)bp;
    
  return dleg(tabula[a][exti], tabula[b][exti]);
}


/*
 * Compare-descending
 */

int
compdesc(const void *ap, const void *bp) 
{
  register int a, b;
    
  a = *(int *)ap;
  b = *(int *)bp;
    
  return dleg(tabula[b][exti], tabula[a][exti]);
}


/*
 * Sorts examples based on the given comparator function 
 * on exti variable. Since the given set can contain both 
 * known and unknown values, it first sorts only examples 
 * with known values and then inserts unknown examples 
 * randomly in the sorted set.
 * Uses mergesort for sorting known values.
 */
int
sort_examples(base, nmemb, size, cmp, unknown_meth)
     void *base;
     size_t nmemb;
     size_t size;
     int (*cmp)(const void *, const void *);
     int unknown_meth;
{

  int *basep = (int *)base;
  int *known_arr = NULL;
  int *unknown_arr = NULL;
  int *pk = NULL;
  int *pu = NULL;
  int *p = NULL;
  double randnum;
  int knowns, unknowns;
  int pos;
  int ret;
  int i;  
 
  // count knowns and unknowns
  unknowns = 0;
  p = basep;
  while (p < (basep + nmemb)) {
    if (isnan(tabula[*p][exti]))
      ++unknowns;
    ++p;
  }
  knowns = nmemb - unknowns;
  
  // accumulate knowns and unknowns in separate arrays
  if ((known_arr = (int *)calloc(knowns, sizeof (*known_arr))) == NULL) {
    return (-1);
  }

  if ((unknown_arr = (int *)calloc(unknowns, sizeof (*unknown_arr))) == NULL) {
    free(known_arr);
    return (-1);
  }

  p = basep;
  pk = known_arr;
  pu = unknown_arr;
  while (p < (basep + nmemb)) {
    if (isnan(tabula[*p][exti]))
      *pu++ = *p++;
    else
      *pk++ = *p++;
  }
  
  // sort knowns
  if ((ret = mergesort(known_arr, knowns, size, cmp)) < 0) {
    free(known_arr);
    free(unknown_arr);
    return ret;
  }    

  // reinitialize given array
  p = basep;
  while (p < (basep + nmemb)) {
    *p++ = -1;
  }

  if (unknown_meth == RAND_ORDER) {
    // insert unknowns randomly
    for (i = 0; i < unknowns; i++) {
      randnum = (double)rand()/((unsigned)RAND_MAX+1);  // [0,1)
      pos = (int)(randnum*nmemb);
      while (basep[pos] != -1)
	pos = (pos + 1) % nmemb;
      basep[pos] = unknown_arr[i];
    }
  }
  else {
    pos = 0;
    for (i = 0; i < unknowns; i++) {
      randnum = (double)rand()/((unsigned)RAND_MAX+1);
      pos = pos + (int)(randnum*(nmemb - pos - (unknowns - i)));
      basep[pos] = unknown_arr[i];
      pos++;
    }
  }

  // insert knowns at empty slots in order
  p = basep;
  for (i = 0; i < knowns; i++) {
    while (*p != -1) 
      ++p;
    *p = known_arr[i];
  }

  free(known_arr);
  free(unknown_arr);

  return (0);
}


/*
 * Returns 0 if variable should be considered; else -1.
 *  - A variable is ignored if it contains too many unknowns.
 */
int check_var(int var_idx, int num_ids, double unknown_limit) {
  int i;
  int unknowns = 0;

  // check unknown factor
  for (i = 0; i < num_ids; i++) {
    if (isnan(tabula[i][var_idx]))
      ++unknowns;
  }    
  if (((double)unknowns/num_ids) >= unknown_limit)
    return -1;

  return 0;
}
