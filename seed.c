#include "comment.header"

/* $Id: seed.c,v 1.3 1997/07/06 19:35:07 ergo Exp $ */

/*
 * $Log: seed.c,v $
 * Revision 1.3  1997/07/06 19:35:07  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:11  ergo
 * added time control for moves
 *
 */

#include <sys/time.h>

void seed(int *i)
/* start seed of random number generator for Sun */
  {
   struct timeval tp;
   struct timezone tzp;

   gettimeofday(&tp, &tzp);
   *i = tp.tv_usec;
}  /* end seed */

