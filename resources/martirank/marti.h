/*
 * $Id: luis $
 *
 */

/*
 * Martiboost header files.
 * Contains common information that the various marti score modules need.
 * This is to prevent replication of important information from one
 * module to another.
 */


#define isnewline(_c)  (isspace(_c) && ((_c)!=' ') && ((_c)!='\t'))

#define RAND_ORDER 0
#define REL_ORDER 1

extern int compasc(const void *, const void *);
extern int compdesc(const void *, const void *);


