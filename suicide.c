#include "comment.header"

/* $Id: suicide.c,v 1.3 1997/07/06 19:35:12 ergo Exp $ */

/*
 * $Log: suicide.c,v $
 * Revision 1.3  1997/07/06 19:35:12  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:15  ergo
 * added time control for moves
 *
 */

#define EMPTY 0
#define BLACKSTONE 2

extern unsigned char p[19][19], l[19][19];
extern int currentStone, opposingStone, MAXX, MAXY;
extern int lib;
extern int blackCapturedKoI, blackCapturedKoJ, whiteCapturedKoI, whiteCapturedKoJ;  /* piece captured */
extern void countlib(int, int, int);
extern void eval(int);

int suicide(int i, int j)
/* check for suicide move of opponent at p[i][j] */
{
 int m, n, k, uik, ujk;

/* check liberty of new move */
 lib = 0;
 countlib(i, j, currentStone);
 if (lib == 0)
/* new move is suicide then check if kill my pieces and Ko possibility */
   {
/* assume alive */
    p[i][j] = currentStone;

/* check opponent pieces */
    eval(opposingStone);
    k = 0;

    for (m = 0; m < MAXX; m++)
      for (n = 0; n < MAXY; n++)
/* count pieces that will be killed */
	if ((p[m][n] == opposingStone) && !l[m][n]) ++k;

    if (currentStone == BLACKSTONE) {
      uik = blackCapturedKoI;
      ujk = blackCapturedKoJ;
    } else {
      uik = whiteCapturedKoI;
      ujk = whiteCapturedKoJ;
    }
    if ((k == 0) || (k == 1 && ((i == uik) && (j == ujk))))
/* either no effect on my pieces or an illegal Ko take back */
      {
       p[i][j] = EMPTY;   /* restore to open */
       return 1;
      }
    else
/* good move */
      return 0;
   }
 else
/* valid move */
   return 0;
}  /* end suicide */

