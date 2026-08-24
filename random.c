#include "comment.header"

/* $Id: random.c,v 1.3 1997/07/06 19:35:05 ergo Exp $ */

/*
 * $Log: random.c,v $
 * Revision 1.3  1997/07/06 19:35:05  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:10  ergo
 * added time control for moves
 *
 */

extern void seed(int*);

void Random(int *i)
/* random number generator */
  {
   if (*i == 0)
     seed(i);
   else
     {
      *i = *i * 137 % 3833;
      if (*i < 0) *i = -*i;
   }
}  /* end random */

