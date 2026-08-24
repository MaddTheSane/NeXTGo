#include "comment.header"

/* $Id: countlib.c,v 1.3 1997/07/06 19:34:53 ergo Exp $ */

/*
 * $Log: countlib.c,v $
 * Revision 1.3  1997/07/06 19:34:53  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:56:58  ergo
 * added time control for moves
 *
 */

extern unsigned char ml[19][19];
extern int MAXX, MAXY;
extern void count(int m, int n, int color);

void countlib(int m,int n,int color)
     /* count liberty of color piece at m, n */
{
  int i, j;
  
  /* set all piece as unmarked */
  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      ml[i][j] = 1;
  
  /* count liberty of current piece */
  count(m, n, color);
}  /* end countlib */

