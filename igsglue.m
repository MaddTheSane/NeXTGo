#include "comment.header"

/* $Id: igsglue.m,v 1.3 1997/07/06 19:37:59 ergo Exp $ */

/*
 * $Log: igsglue.m,v $
 * Revision 1.3  1997/07/06 19:37:59  ergo
 * actual version
 *
 * Revision 1.3  1997/05/04 18:56:56  ergo
 * added time control for moves
 *
 */

#include "igs.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "shared.h"

#import <appkit/appkit.h>
#import "GoApp.h"
#import "Board.h"

typedef piece boardtype[19][19];

message mesg;

char prefix[20];
int boardon = 0;
int boardmode = 0;
int beepcount = 1;

int ingame = -1;
extern int MAXX, MAXY;

char local[1000], *loc;

int observing = 0;

void showboard(boardtype b) {
	extern unsigned char p[19][19];
	int i, j;

	for (i = 0; i < 19; i++)
		for (j = 0; j < 19; j++)
			p[i][j] = b[i][j];

	[[NXApp getGoView] refreshIO];
}

void igsbeep(void) {

	id beepSound = [Sound findSoundFor:"Bonk"];
	[beepSound play];
}

int startgame(int n) {
	char str[100];
	int ret;
  
	sprintf(str, "games %d\n", n);
	sendstr(str);
	do {
		do {
      		ret = getmessage(&mesg, 0);
      		if (ret < 0)
				exit(1);
    	} while (!ret);
    	if (mesg.id == MOVE)
      	[NXApp SetIGSStatus:"%Premature move.  Restart game.\n"];
  	} while (mesg.id != GAMES);
	if (mesg.gamecount != 1)
    	return -1;
  	if (mesg.gamelist[0].bsize > 19) {
    	[NXApp SetIGSStatus:"%Boardsize too large\n"];
    	return -1;
  	}
  	if (observing) {
    	[NXApp SetIGSStatus:"Removing observe\n"];
    	sprintf(str, "unobserve\n");
    	sendstr(str);
    	do {
      		do {
				ret = getmessage(&mesg, 0);
				if (ret < 0)
	  				exit(1);
      		} while (!ret);
    	} while (mesg.id != PROMPT);
    	observing = 0;
  	}
  	ingame = n;
  	MAXX = MAXY = mesg.gamelist[0].bsize;
  	[[NXApp getGoView] startNewGame];
  	[[NXApp getGoView] refreshIO];
  	[[NXApp getGoView] display];
  	[[NXApp getGoView] setGameNumber:ingame];
  	sprintf(str, "%s (%s)", mesg.gamelist[0].white, mesg.gamelist[0].wrank);
  	[[NXApp getGoView] setWhiteName:str];
  	sprintf(str, "%s (%s)", mesg.gamelist[0].black, mesg.gamelist[0].brank);
  	[[NXApp getGoView] setBlackName:str];
  	[[NXApp getGoView] setIGSHandicap:mesg.gamelist[0].hcap];
  	sprintf(str, "%3.1f", mesg.gamelist[0].komi);
  	[[NXApp getGoView] setIGSKomi:str];
	[[NXApp getGoView] setByoTime:mesg.byo];
  	boardon = 1;
  	return 0;
}

void makemove(int x, int y, int movenum, int color, int btime, int bbyo,
	      int wtime, int wbyo) {
	extern void sethand(int);
	
	if ((x < MAXX) && (y < MAXY)) {
		[[NXApp getGoView] makeMove: color: x: y];
		[[NXApp getGoView] setTimeAndByo: btime: bbyo: wtime: wbyo];
		[[NXApp getGoView] dispTime];
    }
  	else if (x > 100) {
      sethand(x-100);
      [[NXApp getGoView] display];
    }
}

void makemovesilent(int x, int y, int movenum, int color, int btime, int bbyo,
	      int wtime, int wbyo)
{
  extern void sethand(int);

  if ((x < MAXX) && (y < MAXY))
    {
      [[NXApp getGoView] makeMoveSilent: color: x: y];
    }
  else if (x > 100)
    {
      sethand(x-100);
    }
}

void removeGroup(int x, int y)
{
  extern unsigned char p[19][19], patternmat[19][19];
  extern int blackCaptured, whiteCaptured, currentStone;
  extern void find_pattern_in_board(int,int);
  int i, j;

  currentStone = p[x][y];

  find_pattern_in_board(x,y);
  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      if (patternmat[i][j])
	{
	  p[i][j] = EMPTY;
	  if (currentStone==BLACK)
	    blackCaptured++;
	  else
	    whiteCaptured++;
	}

  [[NXApp getGoView] setblacksPrisoners:blackCaptured];
  [[NXApp getGoView] setwhitesPrisoners:whiteCaptured];

  [[NXApp getGoView] refreshIO];
}

void getmoves(int n)
{
  int ret;
  char str[100];
  
  sprintf(str, "moves %d\n", n);
  sendstr(str);
  do {
    do {
      ret = getmessage(&mesg, 0);
      if (ret < 0)
	exit(1);
    } while (!ret);
    if (mesg.id == MOVE)
      makemovesilent(mesg.x, mesg.y, mesg.movenum, mesg.color, mesg.btime,
	       mesg.bbyo, mesg.wtime, mesg.wbyo);
    else if (mesg.id && mesg.id != PROMPT)
      [NXApp SetIGSStatus:mesg.text];
  } while (mesg.id != PROMPT);	/* MOVE || mesg.id == 0); */
  lastMove--;
  makemove(mesg.x, mesg.y, mesg.movenum, mesg.color, mesg.btime,
	   mesg.bbyo, mesg.wtime, mesg.wbyo);
  [[NXApp getGoView] refreshIO];
  [[NXApp getGoView] display];
}

void getgames(message *mess)
{
  int ret;

  sendstr("games\n");
  do {
    do {
      ret = getmessage(mess, 0);
      if (ret < 0)
	exit(1);
    } while (!ret);
    if (mess->id == MOVE)
      [NXApp SetIGSStatus:"%Premature move.  Restart game.\n"];
  } while (mess->id != GAMES);
}

void unobserve(void) {
	char str[100];
	sprintf(str, "unobserve %d\n", ingame);
	sendstr(str);
	observing=0; ingame= -1; setgame(-1); 
}

int observegame(int n) {
	int ret;
	char str[20];
  
	if (!observing && ingame != -1) {
    	[NXApp SetIGSStatus:"Can't observe while playing.\n"];
    	return 1;
  	}
  	if (startgame(n))
    	return 1;
  	getmoves(n);
  	sprintf(str, "observe %d\n", n);
  	sendstr(str);
  	observing = 1;
  	do {
    	do {
      		ret = getmessage(&mesg, 0);
      		if (ret < 0)
				exit(1);
    	} while (!ret);
    	if ((mesg.id == INFO) && !strncmp(mesg.text, "Removing", 8))
      		[NXApp SetIGSStatus:"%fatal sync error.  Restart igs.\n"];
	} while (mesg.id != MOVE && mesg.id != UNDO);
  	return 0;
}

/* commented out because currently not used
 *
 * int peekgame(int n)
 * {
 * if (!observing && ingame != -1) {
 *   [NXApp SetIGSStatus:"Can't peek while playing.\n"];
 *   return 1;
 * }
 * if (startgame(n))
 *   return 1;
 * getmoves(n);
 * setgame(-1);
 * return 0;
 * }
 */
 
void setgame(int newgame) {
	if (newgame != ingame) {
		ingame = newgame;
	/*	[[NXApp getGoView] setGameNumber:ingame];	*/ 
	}
}

void loadgame(char *name)
{
  char str[100];
  int ret;
  sprintf(str, "load %s\n", name);
  sendstr(str);
  do {
    ret = getmessage(&mesg, 0);
    if (ret < 0)
      exit(1);
    sprintf(str, "&&%d&&\n", mesg.id);
    [NXApp SetIGSStatus:str];
  } while (mesg.id != MOVE && mesg.id != ERROR);
  if (mesg.id == ERROR)
    [NXApp SetIGSStatus:mesg.text];
  else {
    if (!startgame(mesg.gamenum))
      getmoves(mesg.gamenum);
  }
}

void doserver(void)
{
  	int ret;
  	NXEvent peek_ev, *get_ev;
  
  	loc = local;
  	idle = 0;
  	ret = getmessage(&mesg, 1);
  	if (ret < 0 && ret != KEY) {
    	[NXApp SetIGSStatus:"Connection closed\n"];
  	}
  	if (ret > 0)
    	switch (mesg.id) {
    		case QUITMESG:
      			[NXApp SetIGSStatus:mesg.text];
      			break;
    		case ONSERVER:
      			[NXApp SetIGSStatus:"Connection established\n"];
      			break;
    		case BEEP:
    	  		break;
    		case MOVE:
      			if (!boardon)
					[NXApp SetIGSStatus:"%Error: isolated move received\n"];
      			else {
					makemove(mesg.x, mesg.y, mesg.movenum, mesg.color, 
							 mesg.btime,
		 					 mesg.bbyo, mesg.wtime, mesg.wbyo);
					setgame(mesg.gamenum);
      			}
      			break;
    		case UNDO:
      			if (!boardon)
					[NXApp SetIGSStatus:"%Error: isolated undo received"];
      			else {
					setgame(mesg.gamenum);
					[[NXApp getGoView] undo];
					[[NXApp getGoView] display];
      			}
      			break;
    		case SCOREUNDO:
      			/*	endgame();  */
      			[NXApp SetIGSStatus:"Scoring undone."];
      			break;
    		case LOAD:
      			if (!startgame(mesg.gamenum))
					getmoves(mesg.gamenum);
      			break;
    		case MATCH:
      			startgame(mesg.gamenum);
      			break;
    		case REMOVE:
      			removeGroup(mesg.x, mesg.y);
      			break;
    		case SCORE:
      			{
					char str[50];
					showboard(mesg.board);
					sprintf(str, "Black: %g\nWhite: %g\n", mesg.bscore,
					mesg.wscore);
					[NXApp SetIGSStatus:str];
      			}
      			break;
    		case LOOK_M: {
      			int pris[2];
      			if (mesg.boardsize > 19)
					[NXApp SetIGSStatus:"%Boardsize of saved game too big.\n"];
      			else {
					MAXX = MAXY = mesg.boardsize;
					[[NXApp getGoView] startNewGame];
					[[NXApp getGoView] display];
					boardon = 1;
					pris[0] = mesg.bcap;
					pris[1] = mesg.wcap;
					[[NXApp getGoView] setblacksPrisoners:pris[0]];
					[[NXApp getGoView] setwhitesPrisoners:pris[1]];
					[[NXApp getGoView] refreshIO];
					showboard(mesg.board);
      			}
    			}
      			break;
    		case KIBITZ:{
      			char s[300];
      			sprintf(s, "%s: %s\n", mesg.kibitzer, mesg.kibitz);
      			[NXApp SetIGSStatus:s];
    			}
      			break;
    		case STORED:
      			if (!strlen(mesg.text))
					[NXApp SetIGSStatus:"No stored games\n"];
      			else
					[NXApp SetIGSStatus:mesg.text];
      			break;
    		case INFO:
      			if (strstr(mesg.text, "Removing")) {
					observing = 0;
					setgame(-1);
				}
      			if (strstr(mesg.text, "game completed")) {
					[NXApp gameCompleted];
				}
				[NXApp SetIGSStatus:mesg.text];
      			break;
    		case PROMPT:
      			if (ingame != -1 && mesg.prompttype == 5) {
					setgame(-1);
					observing = 0;
					[NXApp gameCompleted];
      			}
			case 0:
      			break;
    		default:
      			[NXApp SetIGSStatus:mesg.text];
      			break;
   		}
  	idle = 1;
      
  if( [NXApp peekNextEvent: NX_MOUSEDOWNMASK into: &peek_ev] )
    {
      get_ev = [NXApp getNextEvent: NX_MOUSEDOWNMASK];
      [NXApp sendEvent: get_ev];
    }
}


