#include "comment.header"

/* $Id: count.c,v 1.3 1997/07/06 19:34:52 ergo Exp $ */

/*
 * $Log: count.c,v $
 * Revision 1.3  1997/07/06 19:34:52  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:56:58  ergo
 * added time control for moves
 *
 */

#define EMPTY 0

extern unsigned char p[19][19], ml[19][19];
extern int lib, MAXX, MAXY;

void count(int i, int j, int color)
     /* count liberty of color piece at i, j */
{
  /* set current piece as marked */
  ml[i][j] = EMPTY;
  
  /* check North neighbor */
  if (i != EMPTY)
    {
      if ((p[i - 1][j] == EMPTY) && ml[i - 1][j])
	{
	  ++lib;
	  ml[i - 1][j] = EMPTY;
	}
      else
	if ((p[i - 1][j] == color) && ml[i - 1][j])
	  count(i - 1, j, color);
    }
  /* check South neighbor */
  if (i != MAXX - 1)
    {
      if ((p[i + 1][j] == EMPTY) && ml[i + 1][j])
	{
	  ++lib;
	  ml[i + 1][j] = EMPTY;
	}
      else
	if ((p[i + 1][j] == color) && ml[i + 1][j])
	  count(i + 1, j, color);
    }
  /* check West neighbor */
  if (j != EMPTY)
    {
      if ((p[i][j - 1] == EMPTY) && ml[i][j - 1])
	{
	  ++lib;
	  ml[i][j - 1] = EMPTY;
	}
      else
	if ((p[i][j - 1] == color) && ml[i][j - 1])
	  count(i, j - 1, color);
    }
  /* check East neighbor */
  if (j != MAXY - 1)
    {
      if ((p[i][j + 1] == EMPTY) && ml[i][j + 1])
	{
	  ++lib;
	  ml[i][j + 1] = EMPTY;
	}
      else
	if ((p[i][j + 1] == color) && ml[i][j + 1])
	  count(i, j + 1, color);
    }
}  /* end count */

