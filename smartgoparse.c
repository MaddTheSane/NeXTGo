#include "comment.header"

/* $Id: smartgoparse.c,v 1.3 1997/07/06 19:35:09 ergo Exp $ */

/*
 * $Log: smartgoparse.c,v $
 * Revision 1.3  1997/07/06 19:35:09  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:14  ergo
 * added time control for moves
 *
 */

#include <stdlib.h>
#include "smartgo.h"

/*  Define the following when debugging the tree parsing algorithm.  */
/*  #define _DEBUG_ON_  */

char *currentChar;
int currentNodeNumber;

void add_node(node* cur_node, char* node_loc)
{
  node* new_node;

  new_node = (node *) malloc((size_t) sizeof(node));

  new_node->nodenum = currentNodeNumber++;
  cur_node->next = new_node;
  new_node->prev = cur_node;
  new_node->parent = cur_node->parent;
  new_node->properties = node_loc;
  new_node->next = new_node->next_var = new_node->prev_var =
    new_node->variants = NULL;

#ifdef _DEBUG_ON_
  printf("Add, ");
#endif
}

void add_variant(node* parent)
{
  node *new_var, *tnode;

  new_var = (node *) malloc((size_t) sizeof(node));

  if (parent->variants == NULL)
    {
      parent->variants = new_var;
      new_var->prev_var = NULL;
    }
  else
    {
      tnode = parent->variants;
      while (tnode->next_var != NULL)
	tnode = tnode->next_var;
      tnode->next_var = new_var;
      new_var->prev_var = tnode;
    }

  new_var->parent = parent;
  new_var->properties = NULL;
  new_var->nodenum = 0;
  new_var->next_var = new_var->variants = new_var->next = new_var->prev = NULL;

#ifdef _DEBUG_ON_
  printf("Pop, ");
#endif
}

void do_variant(node* startNode)
{
  node *subNode, *currentNode;
  int level = 0;

  currentNode = startNode;

  while ((*currentChar != ')') && (*currentChar != 0))
    {
      if (*currentChar == '\\')
	{
	  currentChar++;
	}
      else if (*currentChar == '[')
	{
	  level++;
	}
      else if (*currentChar == ']')
	{
	  level--;
	}
      else if ((*currentChar == '(') && (level == 0))
	{
#ifdef _DEBUG_ON_
	  printf("Down, ");
#endif

	  add_variant(currentNode);
	  subNode = currentNode->variants;
	  while (subNode->next_var != NULL)
	    subNode = subNode->next_var;

	  currentChar++;
	  do_variant(subNode);
	}
      else if ((*currentChar == ';') && (level == 0))
	{
	  add_node(currentNode, currentChar);
	  currentChar++;
	  currentNode = currentNode->next;
	}
      currentChar++;
      if ((*currentChar == ')') && (level != 0))
	currentChar++;
    }

/*  currentChar++;  */

#ifdef _DEBUG_ON_
  printf("Up, ");
#endif
}

node* parse_tree(char* inputBuffer)
{
  node *rootNode, *subNode;

  rootNode = (node *) malloc((size_t) sizeof(node));
  rootNode->properties = NULL;
  rootNode->nodenum = 0;
  rootNode->parent = rootNode->variants = rootNode->next_var =
    rootNode->prev_var = rootNode->next = rootNode->prev = NULL;
  currentNodeNumber = 0;

  currentChar = inputBuffer;

  while (*currentChar != '(')
    currentChar++;

  while ((*currentChar != ')') && (*currentChar != 0))
    {
      if (*currentChar == '(')
	{
#ifdef _DEBUG_ON_
	  printf("Down, ");
#endif

	  add_variant(rootNode);
	  subNode = rootNode->variants;
	  while (subNode->next_var != NULL)
	    subNode = subNode->next_var;

	  currentChar++;
	  do_variant(subNode);
	}
      currentChar++;
    }

#ifdef _DEBUG_ON_
  printf("\n\n\n");
#endif

  return rootNode;
}

