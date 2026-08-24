#include "comment.header"

/* $Id: initmark.c,v 1.3 1997/07/06 19:35:02 ergo Exp $ */

/*
 * $Log: initmark.c,v $
 * Revision 1.3  1997/07/06 19:35:02  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:07  ergo
 * added time control for moves
 *
 */

extern unsigned char ma[19][19];
extern int MAXX, MAXY;

void initmark()
/* initialize all markings with zero */
{
int i, j;

  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      ma[i][j] = 0;
}  /* end initmark */

