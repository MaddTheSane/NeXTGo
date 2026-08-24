#include "comment.header"

/* $Id: gnugo.h,v 1.3 1997/07/06 19:38:22 ergo Exp $ */

/*
 * $Log: gnugo.h,v $
 * Revision 1.3  1997/07/06 19:38:22  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:19  ergo
 * added time control for moves
 *
 */

extern void sethand(int i);        // set up the handicap stones.
extern void examboard(int color);  // remove dead stones.
extern void eval(int color);       // evaluate the liberties of the stones.
extern void countlib(int m, int n, int color);
                                   // count the liberties of the color at m,n.
extern void count(int i, int j, int color);
                                   // count the liberties of the stone at i,j.
extern int suicide(int i, int j);  // determine if legally placed stone.
extern void genmove(int *i, int *j);
                                   // generate computer move.
extern int findwinner(int *i, int *j, int *val);
                                   // find opponent piece to capture or attack.
extern int findopen(int m, int n, int i[], int j[], int color, int minlib, int *ct);
                                   // find all open spaces i, j from m, n.
extern int findsaver(int *i, int *j, int *val);
                                   // find move if any pieces are threatened.
extern void initmark();            // initialize all markings with zero.
extern int findnextmove(int m, int n, int *i, int *j, int *val, int minlib);
                                   // find new move i,j from group containing m,n.
extern int fval(int newlib, int minlib);
                                   // evaluate new move.
extern int findpatn(int *i, int *j, int *val);
                                   // find pattern to match for next move.
extern int opening(int *i, int *j, int *cnd, int type);
                                   // get move for opening from game tree.
extern int openregion(int i1, int j1, int i2, int j2);
                                   // check if region from i1,j1  to i2,j2 is open.
extern int matchpat(int m, int n, int *i, int *j, int *val);
                                   // match pattern and get next move.
extern int fioe(int i, int j);     // check edges.
extern void Random(int *i);        // return a random integer.
extern void seed(int *i);          // seed a random number generator.
extern void score_game(void);      // remove dead stones and score the game.
extern void find_owner(void);
extern int surrounds_territory(int x, int y);
extern void find_pattern_in_board(int x, int y);
extern void set_temp_to_p(void);
extern void set_p_to_temp(void);
