#include "comment.header"

/* $Id: opening.c,v 1.3 1997/07/06 19:35:03 ergo Exp $ */

/*
 * $Log: opening.c,v $
 * Revision 1.3  1997/07/06 19:35:03  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:09  ergo
 * added time control for moves
 *
 */

extern int rd, MAXX, MAXY;
extern void Random(int*);

int opening(int *i, int *j, int *cnd, int type)
     /* get move for opening from game tree */
{
  struct tnode {
    int i, j, ndct, next[8];
  };
  
  static struct tnode tree[] = {
    {-1, -1, 8, { 1, 2, 3, 4, 5, 6, 7, 20}},	/* 0 */
    {2, 3, 2, { 8, 9}},
    {2, 4, 1, {10}},
    {3, 2, 2, {11, 12}},
    {3, 3, 6, {14, 15, 16, 17, 18, 19}},
    {3, 4, 1, {10}},  /* 5 */
    {4, 2, 1, {13}},
    {4, 3, 1, {13}},
    {4, 2, 0},
    {4, 3, 0},
    {3, 2, 0},  /* 10 */
    {2, 4, 0},
    {3, 4, 0},
    {2, 3, 0},
    {2, 5, 1, {10}},
    {2, 6, 1, {10}},  /* 15 */
    {3, 5, 1, {10}},
    {5, 2, 1, {13}},
    {5, 3, 1, {13}},
    {6, 2, 1, {13}},
    {2, 2, 0}  /* 20 */
  };
  int m;
  
  /* get i, j */
  if ((type == 1) || (type == 3))
    *i = (18 - tree[*cnd].i)*MAXX/19;   /* inverted */
  else
    *i = tree[*cnd].i*MAXX/19;
  if ((type == 2) || (type == 3))
    *j = (18 - tree[*cnd].j)*MAXY/19;   /* reflected */
  else
    *j = tree[*cnd].j*MAXY/19;
  if (tree[*cnd].ndct)  /* more move */
    {
      Random(&rd);
      m = rd % tree[*cnd].ndct;  /* select move */
      *cnd = tree[*cnd].next[m];	/* new	current node */
      return 1;
    }
  else
    return 0;
}  /* end opening */

