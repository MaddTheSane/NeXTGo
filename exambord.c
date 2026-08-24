#include "comment.header"

/* $Id: exambord.c,v 1.3 1997/07/06 19:34:54 ergo Exp $ */

/*
 * $Log: exambord.c,v $
 * Revision 1.3  1997/07/06 19:34:54  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:00  ergo
 * added time control for moves
 *
 */

#define EMPTY 0
#define BLACKSTONE 2

extern unsigned char p[19][19], l[19][19];
extern int MAXX, MAXY;
extern int currentStone, opposingStone, whiteCaptured, blackCaptured;
extern int whiteCapturedKoI, whiteCapturedKoJ, blackCapturedKoI, blackCapturedKoJ;
extern void eval(int color);

void examboard(int color)
     /* examine pieces */
{
  int i, j, n;

  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      if (p[i][j] > 2)
	return;
  
  /* find liberty of each piece */
  eval(color);
  
  /* initialize piece captured */
  if (color == BLACKSTONE)
    {
      blackCapturedKoI = -1;
      blackCapturedKoJ = -1;
    }
  else
    {
      whiteCapturedKoI = -1;
      whiteCapturedKoJ = -1;
    }
  n = 0; /* The number of captures this move for Ko purposes */
  
  /* remove all piece of zero liberty */
  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      if ((p[i][j] == color) && (l[i][j] == 0))
	{
	  p[i][j] = EMPTY;
	  /* record piece captured */
	  if (color == BLACKSTONE)
	    {
	      blackCapturedKoI = i;
	      blackCapturedKoJ = j;
	      ++blackCaptured;
	    }
	  else
	    {
	      whiteCapturedKoI = i;
	      whiteCapturedKoJ = j;
	      ++whiteCaptured;
	    }
	  ++n;  /* increment number of captures on this move */
	}
  /* reset to -1 if more than one stone captured since  no Ko possible */
  if ((color == BLACKSTONE) && (n > 1))
    {
      blackCapturedKoI = -1;
      blackCapturedKoJ = -1;
    }
  else if ( n > 1 )
    {
      whiteCapturedKoI = -1;
      whiteCapturedKoJ = -1;
    }
}  /* end examboard */

