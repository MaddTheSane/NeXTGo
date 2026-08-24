#include "comment.header"

/* $Id: history.h,v 1.3 1997/07/06 19:38:24 ergo Exp $ */

/*
 * $Log: history.h,v $
 * Revision 1.3  1997/07/06 19:38:24  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:21  ergo
 * added time control for moves
 *
 */

#ifndef _game_history_
#define _game_history_

struct change {
  int added;
  int color, x, y;
};

typedef struct {
  int numchanges, blackCaptured, whiteCaptured;
  struct change *changes;
} gameHistory;

extern gameHistory gameMoves[500];

#endif
