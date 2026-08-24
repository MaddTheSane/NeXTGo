#include "comment.header"
  
/* $Id: genmove.c,v 1.3 1997/07/06 19:35:00 ergo Exp $ */

/*
 * $Log: genmove.c,v $
 * Revision 1.3  1997/07/06 19:35:00  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:05  ergo
 * added time control for moves
 *
 */

#define EMPTY 0
#define MAXTRY 400
#define BLACKSTONE 2

extern unsigned char p[19][19];
extern int currentStone, opposingStone, MAXX, MAXY;
extern int rd, lib, blackPassed, whitePassed;
extern void eval(int);
extern int findwinner(int*,int*,int*);
extern int findsaver(int*,int*,int*);
extern int findpatn(int*,int*,int*);
extern void countlib(int,int,int);
extern int fioe(int,int);
extern void Random(int*);

void genmove(int *i, int *j)
     /* generate computer move */
{
  int ti, tj, tval;
  int val;
  int try = 0;   /* number of try */
  
  /* initialize move and value */
  *i = -1;  *j = -1;  val = -1;
  
  /* re-evaluate liberty of opponent pieces */
  eval(opposingStone);
  
  /* find opponent piece to capture or attack */
  if (findwinner(&ti, &tj, &tval))
    if (tval > val)
      {
	val = tval;
	*i = ti;
	*j = tj;
      }
  
  /* save any piece if threaten */
  if (findsaver(&ti, &tj, &tval))
    if (tval > val)
      {
	val = tval;
	*i = ti;
	*j = tj;
      }
  
  /* try match local play pattern for new move */
  if (findpatn(&ti, &tj, &tval))
    if (tval > val)
      {
	val = tval;
	*i = ti;
	*j = tj;
      }
  
  /* no urgent move then do random move */
  if (val < 0)
    do {
      Random(&rd);
      *i = rd % MAXX;
      /* avoid low line  and center region */
      if ((*i < 2) || (*i > MAXX - 3) || ((*i > (MAXX/2) - 2) && (*i < (MAXX/2) + 2)))
	{
	  Random(&rd);
	  *i = rd % MAXX;
	  if ((*i < 2) || (*i > MAXX - 3))
	    {
	      Random(&rd);
	      *i = rd % MAXX;
	    }
	}
      Random(&rd);
      *j = rd % MAXY;
      /* avoid low line and center region */
      if ((*j < 2) || (*j > MAXY - 3) || ((*j > (MAXX/2) - 2) && (*j < (MAXY/2) + 2)))
	{
	  Random(&rd);
	  *j = rd % MAXY;
	  if ((*j < 2) || (*j > MAXY - 3))
	    {
	      Random(&rd);
	      *j = rd % MAXY;
	    }
	}
      lib = 0;
      countlib(*i, *j, currentStone);
    }
  /* avoid illegal move, liberty one or suicide, fill in own eye */
  while ((++try < MAXTRY)
	 && ((p[*i][*j] != EMPTY) || (lib < 3) || fioe(*i, *j)));
  
  if (try >= MAXTRY)  /* computer pass */
    {
      if (currentStone == BLACKSTONE)
	blackPassed = 1;
      else
	whitePassed = 1;
      *i = *j = -1;
    }
  else   /* find valid move */
    {
      if (currentStone == BLACKSTONE)
	blackPassed = 0;
      else
	whitePassed = 0;
    }
}  /* end genmove */
