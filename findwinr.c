#include "comment.header"

/* $Id: findwinr.c,v 1.3 1997/07/06 19:34:59 ergo Exp $ */

/*
 * $Log: findwinr.c,v $
 * Revision 1.3  1997/07/06 19:34:59  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:03  ergo
 * added time control for moves
 *
 */

#define EMPTY 0

extern unsigned char p[19][19], l[19][19];
extern int currentStone, opposingStone, MAXX, MAXY;
extern int lib;
extern void countlib(int,int,int);
extern void initmark();
extern int findopen(int,int,int[],int[],int,int,int*);

int findwinner(int *i, int *j, int *val)
     /* find opponent piece to capture or attack */
{
  int m, n, ti[3], tj[3], tval, ct, u, v, lib1;
  
  *i = -1;   *j = -1;   *val = -1;
  
  /* find opponent with liberty less than four */
  for (m = 0; m < MAXX; m++)
    for (n = 0; n < MAXY; n++)
      if ((p[m][n] == opposingStone) && (l[m][n] < 4))
	{
	  ct = 0;
	  initmark();
	  if (findopen(m, n, ti, tj, opposingStone, l[m][n], &ct))
	    {
	      if (l[m][n] == 1)
		{
		  if (*val < 120)
		    {
		      *val = 120;
		      *i = ti[0];
		      *j = tj[0];
		    }
		}
	      else
		for (u = 0; u < l[m][n]; u++)
		  for (v = 0; v < l[m][n]; v++)
		    if (u != v)
		      {
			lib = 0;
			countlib(ti[u], tj[u], currentStone);
			if (lib > 0) /* valid move */
			  {
			    lib1 = lib;
			    p[ti[u]][tj[u]] = currentStone;
			    /* look ahead opponent move */
			    lib = 0;
			    countlib(ti[v], tj[v], opposingStone);
			    if ((lib1 == 1) && (lib > 0))
			      tval = 0;
			    else
			      tval = 120 - 20 * lib;
			    if (*val < tval)
			      {
				*val = tval;
				*i = ti[u];
				*j = tj[u];
			      }
			    p[ti[u]][tj[u]] = EMPTY;
			  }
		      }
	    }
	}
  if (*val > 0)	/* find move */
    return 1;
  else  /* fail to find winner */
    return 0;
}  /* end findwinner */

