#include "comment.header"

/* $Id: smartgo.h,v 1.3 1997/07/06 19:38:27 ergo Exp $ */

/*
 * $Log: smartgo.h,v $
 * Revision 1.3  1997/07/06 19:38:27  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:23  ergo
 * added time control for moves
 *
 */

#ifndef _SMART_GO_DEFINITIONS_
#define _SMART_GO_DEFINITIONS_

#include <stdio.h>

#define MAX_LETTERS 12
#define MAXCOMMENT 4097
#define MAXCOMMENTLINES 300
#define MAXCOMMENTWIDTH 50

typedef enum {
  t_White,
  t_Black,
  t_Open,
  t_Close,
  t_NewNode,
  t_Comment,
  t_AddWhite,
  t_AddBlack,
  t_Letter,
  t_Mark,
  t_AddEmpty,
  t_Name,
  t_Pass,
  t_Player,
  t_Size,
  t_Handicap,
  t_PlayerBlack,
  t_BlackRank,
  t_PlayerWhite,
  t_WhiteRank,
  t_GameName,
  t_Event,
  t_Round,
  t_Date,
  t_Place,
  t_TimeLimit,
  t_Result,
  t_GameComment,
  t_Source,
  t_User,
  t_Komi,

  t_WS,
  t_EOF
  } Token;


typedef struct _node {
  int nodenum, flag, recurse;
  struct _node *parent, *variants, *next_var, *prev_var, *next, *prev;
  char *properties;
} node;


/*   Routines from smartgoparse.c needed by other routines.  */
extern node* parse_tree(char* inputBuffer);

/*   Routines from smartgoeval.c needed by other routines.   */
extern void evaluateNode(char *c, unsigned char b[][]);


/*   Routines from smartgotree.c needed by other routines.  */
extern node* forwardOneNode(node* currentNode);
extern node* forwardOneNode0(node* currentNode);
extern node* backOneNode(node* currentNode);
extern node* findLast(node* currentNode);
extern node* findLast0(node* currentNode);
extern node* forwardOneVariant(node* currentNode);
extern node* backOneVariant(node* currentNode);
extern void clearNodeFlags(node* currentNode);
extern int evaluateSteps(node* currentNode, node* targetNode, unsigned char b[][]);
extern void buildToNode(node* targetNode);
extern node* stepForward(node* currentNode);
extern node* stepBackward(node* currentNode);
extern node* jumpForward(node* currentNode);
extern node* jumpBackward(node* currentNode);


#endif

