#include "comment.header"

/* $Id: eval.c,v 1.3 1997/07/06 19:34:54 ergo Exp $ */

/*
 * $Log: eval.c,v $
 * Revision 1.3  1997/07/06 19:34:54  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:56:59  ergo
 * added time control for moves
 *
 */

extern unsigned char p[19][19], l[19][19];
extern int lib, MAXX, MAXY;
extern void countlib(int i, int j, int color);

void eval(int color)
     /* evaluate liberty of color pieces */
{
  int i, j;
  
  /* find liberty of each piece */
  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      if (p[i][j] == color)
	{
	  lib = 0;
	  countlib(i, j, color);
	  l[i][j] = lib;
	}
}  /* end eval */
