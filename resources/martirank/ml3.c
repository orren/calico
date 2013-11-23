#include <stdio.h>
#include <signal.h>
#define __USE_GNU
#include <sched.h>


/*
 * $Id:$


 * 
 */

/*
 * Transcoded from perl by ji
 * Martiboost training module.
 *
 * Revisions (sjain 02/13/2006):
 *  - Randomizes initial ordering of examples.
 *  - Picks top variable probabilistically from a list
 *    of top scoring variables for each bin.
 *  - Fixed sorting of variables (when they contain
 *    unknowns). See sort_examples().
 *  - Variables containing too many unknowns (above
 *    a certain limit) are not considered now.
 *
 * TODO:
 *  - instead of picking just one variable for a bin,
 *    pick top-k variables and compute an average sort.
 *    This will require changes in generated model.
 */

#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <err.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>

#include "marti.h"

inline double
nan(const char *s)
{
  union {
    struct
    {
      u_int manl : 32;
      u_int manh : 20;
      u_int  exp : 11;
      u_int sign :  1;
    } uns;
    double und;
  } NaNu;

  NaNu.uns.manl = 1;
  NaNu.uns.manh = 1;
  NaNu.uns.exp  = 2047;
  NaNu.uns.sign = 0;

  return NaNu.und;
}


/*
 * This struct stores feature record.
 */
struct Score {
  int var;
  char* dir;
  double auc;
  double weight;
  int* order;
};

#define Score  struct Score

#define MAX_VARS  10

#define N_ROUNDS_DEFAULT	10

int n_ids;				/* # of lines in table */
int n_names;				/* # of columns in table */
int n_rounds = N_ROUNDS_DEFAULT; /* # of rounds, default 10 */
int *rounds = NULL;		/* list of splits per round: n_round  of them */
int *order = NULL;     		/* order[i] gives the index of the
                           *   example that is ranked i+1.
                           * order[0] is the feeder most likely to fail
                           */
int *sublist_order = NULL;
Score *scores = NULL;
Score *min_score_ptr = NULL;
int *this_order = NULL;
int *best_order = NULL;

int *ignore_set = NULL; /* variables too ignore since they contain too many unknowns */

int topk = 1; /* # of variables considered in each bin */

double unknown_limit = 0.4;  /* maximum unknown ratio acceptable for a variable */

int prob_dist_flag = 1;     /* whether to pick top variable from probability distribution */

extern double **tabula;			/* all the samples; a matrix, really */
extern int exti;
int **failures = NULL;			/* @F in the original */
int **last = NULL;			/* @last in the original */

int gargc;				/* global versions of argc */
char **gargv;				/* and argv */
char **genvp;				/* and envp */



/*
 * Compare-descending (Score)

  meta \result == 0 - comp_auc_desc(bp, ap);
*/
 static int comp_auc_desc(const void *ap, const void *bp)
{
  Score *a, *b;
    
  a = (Score *)ap;
  b = (Score *)bp;
  
  return dleg(b->auc, a->auc);
}

/*
 * Area Under the quasi-ROC Curve
 * 
 * Takes as arguments a pointer to the first element
 * of a sublist of indices to tabula (table of samples)
 * and the sublist's length.
 *
 * Returns the weighted-AUC value of #failures indexed
 * by the sublist.
 */
 static double pauc(int *orderref, int n)
{
  double encountered = 0;		/* sum of failures found in bin */
  double total_predicted = 0;		/* integral of sum-of-failures (AUC) */
  int i;
  int total_weight = 0;
    
  for (i = 0; i < n; i++) {
    /*
     * n_names - 1 is the last column, that is, number of failures
     */
    encountered += tabula[orderref[i]][n_names - 1];
    total_predicted += encountered;
    total_weight++;
  }
    
  if (encountered == 0)
    return 0.5;
  else
    return total_predicted / (total_weight * encountered);
}

//extern int* reverse(int* p, int n);
//extern double diff(double a, double b);




/*
 * Creates a probability distribution for given scores.
 * Takes as input an array of scores and updates weights
 * based on the auc scores. Only considers the top <num>
 * vars.
 */
void 
auc_to_dist(Score *scores, size_t num) {
  double total = 0.0;
  int i;

  for (i = 0; i < num; i++) {
    total += scores[i].auc;
  }
  
  for (i = 0; i < num; i++) {
    scores[i].weight = scores[i].auc/total;
  }
}
			      
/*
 * Picks a variable probabilistically based on weights.
 * Only considers top <num> vars.
 */
Score* 
weighted_rand(Score *scores, size_t num) {
  double randnum;
  int i;
  
  while (1) {
    randnum = (double)rand()/((unsigned)RAND_MAX+1);   // [0,1)
    for (i = 0; i < num; i++) {
      randnum -= scores[i].weight;
      if (randnum < 0.0)
        return &scores[i];
    }
  }
}



/*
 * Insert the given variable record in the scores array.
 * Maintains the top MAX_VARS variables in scores.
 * Returns 1 if score was inserted; 0 if not.
 */
int insert_score(Score *scores, int *num_scores,
                  int var, char *dir, double auc,
                  int *order, int bin_size) {
  
  Score *p;
  double min_auc;
  int k;
  
  if (*num_scores >= MAX_VARS) {
    if (min_score_ptr == NULL) {
      min_auc = scores[0].auc;
      min_score_ptr = scores;
      for (k = 1; k < MAX_VARS; k++) {
        if (scores[k].auc < min_auc) {
          min_auc = scores[k].auc;
          min_score_ptr = scores + k;
        }
      }
    }
    p = NULL;
    if (auc > (*min_score_ptr).auc)
      p = min_score_ptr;
  } else {
    p = scores + *num_scores;	 
    ++(*num_scores);
  }

  if (p != NULL) {
    (*p).var = var;
    (*p).dir = dir;
    (*p).auc = auc;	  	  
    for (k = 0; k <= bin_size; k++)
      (*p).order[k] = order[k];
    return 1;
  }
  return 0;
}

void
usage()
{
  errx(1, "usage: %s file.data file.model [ 'rounds' rounds ] ['topk' topk] ['miss-limit' miss-limit] [--no-prob-dist] [--no-permute] [--seed seed_val] [--sort-unknowns 0|1]\n", gargv[0]);
}

int
main(int argc, char *argv[], char *envp[])
{
  FILE *fdata;			/* .data file (input)*/
  FILE *fmodel;			/* .model file (output) */
  FILE *fauc;				/* .model.1st file (output) */

  int atnl;				/* at newline (flag) */
  char *aucname;			/* file name of the AUC file */
  double baseline;
  char c;
  int divider;			/* #of bins to divide in this round */
  int failures_seen;			/* in this bin */
  int i, j, k, l;
  int maxrounds;			/* max(@ROUNDS) */
  int numbins;			/* misnomer, really "this round" */
  char *sca0, *sca, *scc;		/* tmp variables */
  int t;				/* XXX - some kind of counter? */
  int this_first, this_last;
  double this_pauc;
  double randnum;
  int *rand_seed = NULL;
  int total_failures;
  int num_scores;
  int init_permute_flag = 1;
  int unknown_meth = REL_ORDER;
  Score *p;
  Score *best;
  double min_auc;

  gargc = argc;
  gargv = argv;
  genvp = envp;

  /*
   * Make sure we grok NaNs
   * (unknown entries in the input file, given as '?', are
   *  stored as not-a-number values)
   */

  if (!isnan(nan("")))
    errx(1, "Implementation does not understand NaNs");

  /*
   * PARSE ARGUMENTS
   */

  if (argc < 3)
    usage();

  if ((fdata = fopen(argv[1], "r")) == NULL)
    err(1, "cannot open %s for reading", argv[1]);

  if ((fmodel = fopen(argv[2], "w")) == NULL)
    err(1, "cannot open %s for writing", argv[2]);

  if ((aucname = (char *)calloc(strlen(argv[2]) + sizeof (".1st"), 1)) == NULL)
    err(1, "allocating aucname");

  strcpy(aucname, argv[2]);
  strcat(aucname, ".1st");
  if ((fauc = fopen(aucname, "w")) == NULL)
    err(1, "cannot open %s for writing", aucname);

  argc -= 3;
  argv += 3;

  while (argc > 0) {    
    if (!strcmp(argv[0], "rounds") || !strcmp(argv[0], "--rounds")) {
      if (argc < 2)
        usage();
      if ((sca0 = sca = strdup(argv[1])) == NULL)
        err(1, "strdup: copying %s", argv[1]);

      while (*sca == ',')	    /* strip leading commas, if any */
        sca++;

      scc = sca + strlen(sca);
      if (scc == sca)  /* must have at least one digit! */
        usage();

      while (*--scc == ',')	/* strip trailing commas */
        *scc = '\0';

      if (strchr(sca, ',')) {
        /*
         * comma-separated list of rounds, parse
         */

        n_rounds = 0;
        for (scc = sca; *scc; scc++)
          if (*scc == ',')
            n_rounds++;
        n_rounds++;
        if ((rounds = (int *)calloc(n_rounds, sizeof (*rounds))) == NULL)
          err(1, "calloc %d rounds", n_rounds);
        for (i = 0; i < n_rounds; i++) {
          rounds[i] = strtol(sca, &scc, 10);
          if (rounds[i] <= 0)
            errx(1, "round %d must be positive", i);
          sca = scc + 1;
        }
      } else {
        n_rounds = strtol(sca, NULL, 10);        
      }
      
      if (n_rounds <= 0)
        usage();
      
      argc -= 2;
      argv += 2;

    } else if (!strcmp(argv[0], "topk") || !strcmp(argv[0], "--topk")) {
      if (argc < 2)
        usage();
      if ((sca0 = sca = strdup(argv[1])) == NULL)
        err(1, "strdup: copying %s", argv[1]);

      scc = sca + strlen(sca);
      if (scc == sca)  /* must have at least one digit! */
        usage();      

      topk = strtol(sca, NULL, 10);
      
      if (topk <= 0)
        usage();

      argc -= 2;
      argv += 2;

    } else if (!strcmp(argv[0], "miss-limit") || !strcmp(argv[0], "--miss-limit")) {
      if (argc < 2)
        usage();      
      if ((sca0 = sca = strdup(argv[1])) == NULL)
        err(1, "strdup: copying %s", argv[1]);

      scc = sca + strlen(sca);
      if (scc == sca)  /* must have at least one digit! */
        usage();      
      
      unknown_limit = atof(sca);
      
      if (unknown_limit < 0 || unknown_limit > 1)
        usage();

      argc -= 2;
      argv += 2;

    } else if (!strcmp(argv[0], "--no-prob-dist")) {
      prob_dist_flag = 0;
      argc -= 1;
      argv += 1;

    } else if (!strcmp(argv[0], "--no-permute") || 
	       !strcmp(argv[0], "no-permute")) {

      init_permute_flag = 0;
      argc -= 1;
      argv += 1;

    } else if (!strcmp(argv[0], "--sort-unknowns") ||
	       !strcmp(argv[0], "sort-unknowns")) {

      if (argc < 2)
	usage();

      if ((sca = strdup(argv[1])) == NULL)
	err(1, "strdup: copying %s", argv[1]);

      unknown_meth = atoi(sca);

      if (unknown_meth != RAND_ORDER || unknown_meth != REL_ORDER) {
	usage();
      }

      argc -= 2;
      argv += 2;


    } else if (!strcmp(argv[0], "seed") || !strcmp(argv[0], "--seed")) {

      if (argc < 2)
	usage();

      if ((sca0 = sca = strdup(argv[1])) == NULL)
	err(1, "strdup: copying %s", argv[1]);

      scc = sca + strlen(sca);
      if (scc == sca) {
	//must have one digit
	usage();
      }

      if ((rand_seed = (int *) malloc(sizeof(int))) == NULL)
	err(1, "calloc one integer", 1);

      *rand_seed = atoi(sca);

      argc -= 2;
      argv += 2;
    
    } else {
      /* No other options supported */
      usage();
    }
  }

  /*
   * if we got a single number as the "rounds" argument, we 
   * interpret it as the list 1,2,...,n
   */
  if (rounds == NULL) {
    if ((rounds = (int *)calloc(n_rounds, sizeof (*rounds))) == NULL)
      err(1, "calloc %d rounds", n_rounds);
    for (i = 0; i < n_rounds; i++)
      rounds[i] = i+1;
  }

  /*
   * Prep @F and @last
   */

  /*
   * find the max value in rounds[], 
   * needed for allocating space for failures[][] and last[][]
   */
  for (i = 0, maxrounds = 0; i < n_rounds; i++) 
    if (maxrounds < rounds[i])
      maxrounds = rounds[i];

  if ((failures = (int **)calloc(n_rounds + 3, sizeof (*failures))) == NULL)
    err(1, "calloc %d failures", n_rounds);
  if ((last = (int **)calloc(n_rounds + 3, sizeof (*last))) == NULL)
    err(1, "calloc %d last", n_rounds);
  for (i = 0; i <= n_rounds; i++) {
    if ((failures[i] = (int *)calloc(maxrounds + 3, sizeof (**failures))) == NULL)
      err(1, "calloc failures[%d]", i);
    if ((last[i] = (int *)calloc(maxrounds + 3, sizeof (**last))) == NULL)
      err(1, "calloc last[%d]", i);
  }

  /*
   * COUNT NAMES and IDS
   */

  /*
   * Start reading the first line, counting fields
   */
  //first check to make sure there is data in the file
  c = fgetc(fdata);
  if (c == EOF) {
    fclose(fdata);
    err(1, "Error: Data file %s is empty\n", gargv[1]);
  }

  n_names = 1;			/* at least one! */

  /*
    attributes a comma separated. So count the number of commas in 
    the first line to calculate the number of attributes in the data.
  */
  while (!isnewline(c) && c != EOF) {
    if (c == ',')
      n_names++;
    c = fgetc(fdata);
  }
  /* 
   * We've read the first line; let's keep counting lines.
   * There is some cruftiness in the code in order to deal with
   * text files with lines ending in \r\n and not just \n
   */
  n_ids = 1;				/* we've already read one line! */

  atnl = 0;
  while ((c = fgetc(fdata)) != EOF)
    if (isnewline(c)) {
      if (!atnl) {
        n_ids++;
        atnl++;			
      }
    } else {
      atnl = 0;
    }

  fclose(fdata);
  if ((fdata = fopen(gargv[1], "r")) == NULL)
    err(1, "cannot open %s for reading", gargv[1]);

  if ((tabula = (double **)calloc(n_ids, sizeof (*tabula))) == NULL)
    err(1, "allocating tabula");
  for (i = 0; i < n_ids; i++) {
    if ((tabula[i] = (double *)calloc(n_names, sizeof (**tabula))) == NULL)
      err(1, "allocating %d-th row of table\n", i);
    for (j = 0; j < n_names - 1; j++)
      if (fscanf(fdata, "%lg,", &tabula[i][j]) != 1) {
        tabula[i][j] = nan("");
        while (fgetc(fdata) != ',')
          ;
      }
    fscanf(fdata, "%lg", &tabula[i][j]); /* 
                                          * XXX - a well-formed file
                                          * MUST not have the result
                                          * value (last column) be a '?'
                                          * DOUBLE_CHECK
                                          */
  }

  total_failures = 0;
  for (i = 0; i < n_ids; i++)
    total_failures += tabula[i][n_names - 1];

  printf("data_file = %s\n", gargv[1]);
  printf("model = %s\n", gargv[2]);
  printf("nr rounds = %d\tnr splits=", n_rounds);
  for (i = 0; i < n_rounds; i++)
    printf(" %d", rounds[i]);
  printf("\nnr_examples = %d\ttotal_failures = %d", n_ids, total_failures);
  printf("\tnr_attribs = %d\n", n_names);

  // seed random no generator
  if (rand_seed == NULL) {
    srand((unsigned)time(NULL));   
  }
  else {
    srand(*rand_seed);
    //don't need rand_seed anymore...
    free(rand_seed);
    rand_seed = NULL;
  }

  if ((order = (int *)calloc(n_ids, sizeof (*order))) == NULL)
    err(1, "calloc %d order", n_ids);

  if ((sublist_order = (int *)calloc(n_ids, sizeof (*sublist_order))) == NULL)
    err(1, "calloc %d sublist_order", n_ids);

  if ((scores = (Score *)calloc(MAX_VARS, sizeof (Score))) == NULL)
    err(1, "calloc %d scores", MAX_VARS);  

  for (i = 0; i < MAX_VARS; i++) {
    scores[i].auc = 0;
    if ((scores[i].order = (int *)calloc(n_ids, sizeof (*(scores[i].order)))) == NULL)
      err(1, "calloc %d scores[%d].order", n_ids, i);    
  }  

  if ((ignore_set = (int *)calloc(n_names-1, sizeof (*ignore_set))) == NULL)
    err(1, "calloc %d ignore_set", n_names-1);  

  if ((this_order = (int *)calloc(n_ids, sizeof (*this_order))) == NULL)
    err(1, "calloc %d this_order", n_ids);  

  if ((best_order = (int *)calloc(n_ids, sizeof (*best_order))) == NULL)
    err(1, "calloc %d best_order", n_ids);  

  /* randomize initial ordering */
  if (init_permute_flag) {
    for (i = 0; i < n_ids; i++)
      order[i] = -1;
    for (i = 0; i < n_ids; i++) {
      randnum = (double)rand()/((unsigned)RAND_MAX+1);  // [0,1)
      j = (int)(randnum*n_ids);
      while (order[j] != -1)
	j = (j + 1) % n_ids;
      order[j] = i;    
    }
  }
  else {
    for (i = 0; i < n_ids; i++) {
      order[i] = i;
    }
  }

  /* find variables to ignore */
  for (i = 0; i < n_names-1; i++) {
    ignore_set[i] = 0;
    if (check_var(i,n_ids, unknown_limit) < 0)
      ignore_set[i] = 1;    
  }

  /* iteration over rounds */
  for (numbins = 1; numbins <= n_rounds; numbins++) {
    printf("round = %d\tsplits = %d\n", numbins, rounds[numbins - 1]);    

    t = 0;
    failures_seen = 0;
    for (divider = 0; divider < rounds[numbins - 1]; divider++) {
      while ((failures_seen < ((divider + 1) * (double)total_failures /
                               rounds[numbins - 1])) &&
             (t < n_ids)) {
        failures_seen += tabula[order[t]][n_names-1];
        t++;
      }
      last[numbins][divider] = t - 1;
      failures[numbins][divider] = failures_seen;
      if (divider == (rounds[numbins - 1] - 1)) 
        failures[numbins][divider+1] = total_failures - failures_seen;
    }

    this_first = 0;	   /* find the first element of the sublist */
    
    /* iteration over bins in this round */
    for (j = 0; j < rounds[numbins - 1]; j++) {
      if (j < rounds[numbins - 1] - 1)
        this_last = last[numbins][j];
      else
        this_last = n_ids - 1;

      printf("\tbin %d: [%d..%d] %d failures",
             j, this_first, this_last,
             failures[numbins][j] - (j ? failures[numbins][j-1] : 0));
      printf("\t(%.12f%%)\n", 
             (this_last - this_first + 1) * 100.0 / n_ids);

      // ordering from previous round
      for (k = this_first; k <= this_last; k++)
        sublist_order[k - this_first] = order[k];
      baseline = pauc(sublist_order, this_last - this_first + 1);

      // reset scores
      for (k = 1; k < MAX_VARS; k++)
        scores[k].auc = 0;
      min_score_ptr = NULL;
      num_scores = 0;
      
      /* iteration over variables for this bin */
      for (exti = 0; exti < n_names - 1; exti++) {
	
        if (ignore_set[exti])
          continue;

        /* variable ascending */

        for (k = this_first; k <= this_last; k++)
          this_order[k - this_first] = sublist_order[k - this_first];       

        if (sort_examples((void *)this_order, this_last - this_first + 1,
                          sizeof (*this_order), compasc, unknown_meth) < 0)
          err(1, "sort_examples this_order ascending");
        
        this_pauc = pauc(this_order, this_last - this_first + 1);
        
        if (numbins == 1)
          fprintf(fauc, "VAR=%d AUC=%f DIR=asc\n", exti, this_pauc);
        
        if (this_pauc > baseline)
          insert_score(scores, &num_scores, exti, "a", this_pauc, this_order, 
                       this_last - this_first + 1);
        
        /* variable descending */

        for (k = this_first; k <= this_last; k++)
          this_order[k - this_first] = sublist_order[k - this_first];

        if (sort_examples((void *)this_order, this_last - this_first + 1,
                          sizeof (*this_order), compdesc, unknown_meth) < 0)
          err(1, "sort_examples this_order descending");

        this_pauc = pauc(this_order, this_last - this_first + 1);
		
        if (numbins == 1)
          fprintf(fauc, "VAR=%d AUC=%f DIR=desc\n", exti, this_pauc);

        if (this_pauc > baseline)	  
          insert_score(scores, &num_scores, exti, "d", this_pauc, this_order, 
                       this_last - this_first + 1);        
      } /* end variables loop */      

      if (num_scores > 0) {
        // sort scores in desc order of auc
        if (mergesort((void *)scores, num_scores,
                      sizeof (*scores), comp_auc_desc) < 0)
          err(1, "mergesort scores descending");
        
        if (prob_dist_flag) {
          // pick top variable probabilistically
          // XXX: pick topk vars and compute avg sort
          auc_to_dist(scores, num_scores);
          best = weighted_rand(scores, num_scores);
        }
        else
          best = scores;
         	
        // merge results into main array
        for (k = this_first; k <= this_last; k++)
          order[k] = (*best).order[k - this_first];

        // update model
        fprintf(fmodel, "%.12f,%1d,%s",
                (this_last + 1) / (double) n_ids,
                best->var,
                best->dir);
	fflush(fmodel);
      } else {
        fprintf(fmodel, "%.12f,nop", (this_last + 1) / (double) n_ids);
	fflush(fmodel);
      }      
	    
      if (j < rounds[numbins - 1] - 1)
	{
	  fprintf(fmodel, ";");
	  fflush(fmodel);
	}
      
      this_first = this_last + 1;
    } /* end bins loop */
	    
    fprintf(fmodel, "\n");
    fflush(fmodel);
    printf("  Overall training AUC %.6f\n", pauc(order, n_ids));
  } /* end rounds loop */
	
  fclose(fmodel);
  fclose(fauc);

  exit(0);
}
