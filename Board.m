#include "comment.header"

/* $Id: Board.m,v 1.3 1997/07/06 19:37:55 ergo Exp $ */

/*
 * $Log: Board.m,v $
 * Revision 1.3  1997/07/06 19:37:55  ergo
 * actual version
 *
 * Revision 1.5  1997/06/03 23:01:55  ergo
 * *** empty log message ***
 *
 * Revision 1.4  1997/05/30 18:44:13  ergo
 * Added an Inspector
 *
 * Revision 1.3  1997/05/04 18:56:50  ergo
 * added time control for moves
 *
 */

#import "Board.h"
#import "gnugo.h"
#include "igs.h"
#include "MiscString.h"

#import <libc.h>
#import <math.h>
#import <sys/time.h>
#import <dpsclient/wraps.h>	// PSxxx functions
#import <soundkit/Sound.h>
#import <appkit/appkit.h>

#define EMPTY		0
#define WHITESTONE	1
#define BLACKSTONE	2
#define NEUTRAL_TERR	3
#define WHITE_TERR	4
#define BLACK_TERR	5
#define SPECIAL_CHAR    6
#define KOMI            5.5

// The following values are the default sizes for the various pieces. 
  
#define RADIUS		14.5 			// Stone radius
#define STONEWIDTH	29.0			// Stone width
#define STONEHEIGHT	29.0			// Stone height
  
  // SHADOWOFFSET defines the amount the shadow is offset from the piece. 
  
#define SHADOWOFFSET 2.0
  
#define BASEBOARDX 19.0
#define BASEBOARDY 19.0
#define WINDOWOFFSETX 12.0
#define WINDOWOFFSETY 12.0
  
#define gameSize  bounds.size

#define PSLine(a, b, x, y)	PSmoveto(a, b); PSlineto(x, y)

float stoneX, stoneY;
int blackStones, whiteStones;
char currentCharacter;
unsigned char oldBoard[19][19];

void setStoneLoc(int x, int y)
{
  stoneX = ((19.0 - MAXX)/2.0)*STONEWIDTH + BASEBOARDX - RADIUS + (x*STONEWIDTH);
  stoneY = BASEBOARDY - RADIUS + ((18 - y)*STONEHEIGHT) - ((19.0 - MAXY)/2.0)*STONEHEIGHT;
}  

void TEHandler(DPSTimedEntry teNumber, double now, void* userdata) {
	id obj  = (id)userdata;
	TimeStruct*	ts = [obj ts];

	char buf[256];
	int myTime;
	
	if ([obj startZeit] == 0.0)
		[obj setStartZeit:now];
	myTime = ts->time - (now - [obj startZeit]);
	if (myTime < 0) {
		if (ts->byo == -1 || 		/* player is in first byo-yomi time */
			ts->byo == 25) { 		/* player is in byo-yomi but did 	*/
									/* not yet move */
			myTime += [obj ByoTime] * 60;
			ts->byo = 25;
		}
	}
    sprintf(buf, "%d:%02d", myTime / 60, myTime % 60);
    if (ts->byo != -1)
		sprintf(buf, "%s, %d", buf, ts->byo);
	[ts->timeToHandle setStringValue:buf];
	[ts->timeToHandle display];
}

@implementation GoView
  
- initFrame:(const NXRect *)frm
{
  NXSize stoneSize;
  
  stoneSize.width = STONEWIDTH;
  stoneSize.height = STONEHEIGHT;
  
  te = 0;
  startZeit = 0;
  
  [super initFrame:frm];
  
  [self allocateGState];	// For faster lock/unlockFocus
    
  [(blackStone = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [blackStone useDrawMethod:@selector(drawBlackStone:) inObject:self];
  [blackStone setSize:&stoneSize];
  
  [(whiteStone = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [whiteStone useDrawMethod:@selector(drawWhiteStone:) inObject:self];
  [whiteStone setSize:&stoneSize];
  
  [(grayStone = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [grayStone useDrawMethod:@selector(drawGrayStone:) inObject:self];
  [grayStone setSize:&stoneSize];
  
  [(upperLeft = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [upperLeft useDrawMethod:@selector(drawUpperLeft:) inObject:self];
  [upperLeft setSize:&stoneSize];
  
  [(upperRight = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [upperRight useDrawMethod:@selector(drawUpperRight:) inObject:self];
  [upperRight setSize:&stoneSize];
  
  [(lowerLeft = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [lowerLeft useDrawMethod:@selector(drawLowerLeft:) inObject:self];
  [lowerLeft setSize:&stoneSize];
  
  [(lowerRight = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [lowerRight useDrawMethod:@selector(drawLowerRight:) inObject:self];
  [lowerRight setSize:&stoneSize];
  
  [(midLeft = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [midLeft useDrawMethod:@selector(drawMidLeft:) inObject:self];
  [midLeft setSize:&stoneSize];
  
  [(midRight = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [midRight useDrawMethod:@selector(drawMidRight:) inObject:self];
  [midRight setSize:&stoneSize];
  
  [(midTop = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [midTop useDrawMethod:@selector(drawMidTop:) inObject:self];
  [midTop setSize:&stoneSize];
  
  [(midBottom = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [midBottom useDrawMethod:@selector(drawMidBottom:) inObject:self];
  [midBottom setSize:&stoneSize];
  
  [(innerSquare = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [innerSquare useDrawMethod:@selector(drawInnerSquare:) inObject:self];
  [innerSquare setSize:&stoneSize];
  
  [(innerHandicap = [[NXImage allocFromZone:[self zone]] init]) setScalable:NO];
  [innerHandicap useDrawMethod:@selector(drawInnerHandicap:) inObject:self];
  [innerHandicap setSize:&stoneSize];
  
  [self setBackgroundFile:NXGetDefaultValue([NXApp appName], "BackGround") 
 andRemember:NO];
  
  [self startNewGame];

  historyFont = [Font newFont:"Helvetica" size:9.0 matrix:NX_IDENTITYMATRIX];
  blackTerrFont = [Font newFont:"Helvetica" size:25.0 matrix:NX_IDENTITYMATRIX];
  whiteTerrFont = [Font newFont:"Helvetica" size:22.5 matrix:NX_IDENTITYMATRIX];
  stoneClick = [Sound findSoundFor:"Pop"];
  
	{
		struct timeval tp;
    	struct timezone tzp;
	    gettimeofday(&tp, &tzp);
		time = tp.tv_sec;
	}
  return self;
}

// free simply gets rid of everything we created for MainGoView, including
  // the instance of MainGoView itself. This is how nice objects clean up.
  
- free {
	[backGround free];
	return [super free];
}



// This methods allows changing the file used to paint the background of the
  // playing field. Set fileName to NULL to revert to the default. Set
  // remember to YES if you wish the write the value out in the defaults.
  
- setBackgroundFile:(const char *)fileName andRemember:(BOOL)remember {
	[backGround free];
	backGround = [[NXImage allocFromZone:[self zone]] initSize:&gameSize];
	if (fileName) {
    	[backGround useFromFile:fileName];
    	if (remember) 
      		NXWriteDefault ([NXApp appName], "Background", fileName);
  	} else {
    	[backGround useFromSection:"Background.tiff"];
    	if (remember)
      		NXRemoveDefault ([NXApp appName], "Background");
  	}
	[backGround setBackgroundColor:NX_COLORWHITE];
	[backGround setScalable:NO];
	[self display];
  
	return self;   
}

// The following two methods allow changing the background image from
// menu items or buttons.
  
- changeBackground:sender {
	
	const char *const types[] = {"tiff", "eps", NULL};  
  
	if ([[OpenPanel new] runModalForTypes:types]) {
		[self setBackgroundFile:[[OpenPanel new] filename] andRemember:YES];
		[self display];
	}
  
	return self;
}

- revertBackground:sender
{
  [self setBackgroundFile:NULL andRemember:YES];
  [self display];
  return self;
}

- resetButtons
{
  if (SmartGoGameFlag)
    {
      [startButton setEnabled: NO];
      [stopButton setEnabled: NO];
      [passButton setEnabled: NO];

      return self;
    }
    
 if (bothSides)
    [passButton setEnabled: NO];
  else
    [passButton setEnabled: YES];
 
  if (neitherSide)
    {
      [startButton setEnabled: NO];
      [stopButton setEnabled: NO];
    }
  else
    {
      [startButton setEnabled: YES];
      [stopButton setEnabled: YES];
    }

  return self;
}

// The following method will initialize all the variables for a new game.
  
- startNewGame {
	
	int i, j;
  
	gameRunning = NO;
	finished = NO;
	gameScored = NO;
	resultsDisplayed = NO;
	scoringGame = NO;
	lastMove = 0;
  	blackCaptured = whiteCaptured = 0;
	manualScoring = manScoreTemp;
  
	seed(&rd);
  
	for (i = 0; i < MAXX; i++)
    	for (j = 0; j < MAXY; j++)
      		oldBoard[i][j] = p[i][j] = hist[i][j] = 0;
  
  	for (i = 0; i < 9; i++)
    	opn[i] = 1;
  	opn[4] = 0;


  	if (gameType == LOCAL) {
		sethand(handicap);
      	currentStone = (handicap == 0)?BLACKSTONE:WHITESTONE;
      	opposingStone = (currentStone == BLACKSTONE)?WHITESTONE:BLACKSTONE;
  
      	if (currentStone == BLACKSTONE)
			[gameMessage setStringValue:"Black's Turn"];
      	else
			[gameMessage setStringValue:"White's Turn"];

      	[self resetButtons];
  
      	if (((currentStone == BLACKSTONE) && (blackSide == 1)) ||
	  		((currentStone == WHITESTONE) && (whiteSide == 1)))  
			[gameMessage2 setStringValue:"Press START to begin..."];
      	else
			[gameMessage2 setStringValue:"You move first..."];
    }
  	else {
		[gameMessage2 setStringValue:"Internet Go Server"];
      	[gameMessage setStringValue:""];
      	[self setblacksPrisoners:0];
      	[self setwhitesPrisoners:0];
      	[passButton setEnabled: YES];
      	[startButton setEnabled: NO];
      	[stopButton setEnabled: NO];
		[self removeTE];
		{
			struct timeval tp;
    		struct timezone tzp;
    		gettimeofday(&tp, &tzp);
			time = tp.tv_sec;
		}	
	}
    
  	[ScoringWindow close];
  	NXPing();
    
  	return self;
}

// The stop method will pause a running game. The go method will start it up
  // again.
  
- go:sender
{
  if (gameType == IGSGAME)
    return self;
    
  if ((scoringGame) && (manualScoring))
    {
      int i, j;

      find_owner();
      blackTerritory = 0;
      whiteTerritory = 0;

      for (i = 0; i < MAXX; i++)
	for (j = 0; j < MAXY; j++)
	  {
	    if (ownermat[i][j] == BLACKSTONE)
	      {
		blackTerritory++;
		p[i][j] = BLACK_TERR;
	      }
	    if (ownermat[i][j] == WHITESTONE)
	      {
		whiteTerritory++;
		p[i][j] = WHITE_TERR;
	      }
	    if (ownermat[i][j] == NEUTRAL_TERR)
	      {
		p[i][j] = NEUTRAL_TERR;
	      }
	  }

      gameScored = YES;
      [self displayScoringInfo];
      NXPing();
    }

  if ((gameRunning == 0) && (finished == 0)) {
    gameRunning = YES;
    [self step];
  }
  return 0;
}

- stop:sender {
	if (gameType == IGSGAME)
		return self;
      
	if (gameRunning) 
		gameRunning = NO;
	return self;
}

- showLastMove:sender
{
  int i;

  if (SmartGoGameFlag)
    return self;

  if (finished)
    {
      NXRunAlertPanel("NeXTGo", "The game has concluded.  The last move was\n\
the scoring.", "OK", 0, 0);

      return self;
    }

  if (lastMove == 0)
    {
      NXRunAlertPanel("NeXTGo", "The game has not yet started.", "OK", 0, 0);

      return self;
    }

  for (i = 0; i < gameMoves[lastMove-1].numchanges; i++)
    {
      if (gameMoves[lastMove-1].changes[i].x < 0)
	{
	  NXRunAlertPanel("NeXTGo", "The last move was a pass.", "OK", 0, 0);

	  return self;
	}
    }
    
  [self lockFocus];
  for (i = 0; i < gameMoves[lastMove-1].numchanges; i++)
    {
      if (gameMoves[lastMove-1].changes[i].added)
	{
	  setStoneLoc(gameMoves[lastMove-1].changes[i].x,
		      gameMoves[lastMove-1].changes[i].y);
	  [self showGrayStone];
	}
    }
  [self unlockFocus];
  NXPing();
  
  [self lockFocus];
  [[self window] flushWindow];
  [self drawSelf:&bounds :0];
  [self display];
  [self unlockFocus];
  NXPing();
  
  return self;
}

- undo
{
  int i, j, x, y;

  if (finished)
    return self;
  
  if (lastMove == 1)
    {
      [self startNewGame];
      [self display];

      return self;
    }
    
  if (lastMove > 0)
    {
      lastMove--;

      for (i = 0; i < MAXX; i++)
	for (j = 0; j < MAXY; j++)
	  p[i][j] = oldBoard[i][j];
      blackCaptured = gameMoves[lastMove].blackCaptured;
      whiteCaptured = gameMoves[lastMove].whiteCaptured;

      for (i = 0; i < gameMoves[lastMove-1].numchanges; i++)
	{
	  x = gameMoves[lastMove-1].changes[i].x;
	  y = gameMoves[lastMove-1].changes[i].y;
	  if (gameMoves[lastMove-1].changes[i].added)
	    {
	      oldBoard[x][y] = EMPTY;
	    }
	  else
	    {
	      oldBoard[x][y] = gameMoves[lastMove-1].changes[i].color;
	    }
	}
      [self refreshIO];

      currentStone = opposingStone;
      opposingStone = (currentStone == BLACKSTONE)?WHITESTONE:BLACKSTONE;

      if (gameType == LOCAL)
	{
	  [gameMessage setStringValue:(currentStone == BLACKSTONE)?
	   "Black's Turn":"White's Turn"];
	  
	  if ((bothSides) || (((currentStone == BLACKSTONE) && (blackSide)) ||
			      ((currentStone == WHITESTONE) && (whiteSide))))
	    {
	      [gameMessage2 setStringValue:"Press START to continue..."];
	      gameRunning = 0;
	    }
	  else
	    [gameMessage2 setStringValue:"Your move..."];
	}
    }

  return self;
}

- undoLastMove:sender
{
  if (SmartGoGameFlag)
    return self;

  if (gameType == LOCAL)
    {
      [self undo];
    }
  else
    {
      sendstr("undo\n");
    }

  return self;
}

- toggleShowHistFlag:sender
{
  [self lockFocus];
  [self display];
  [self unlockFocus];

  return self;
}

- toggleSound:sender
{

  return self;
}

- doClick
{
  if ([playSounds intValue])
    [stoneClick play];
  NXPing();

  return self;
}

- toggleCoords:sender
{
  [self lockFocus];
  [self display];
  [self unlockFocus];

  return self;
}

- mouseDown:(NXEvent *)event
{
  	NXPoint pickedP;

	if (gameType == LOCAL) {
      	if ((((currentStone == BLACKSTONE) && (blackSide == 1)) ||
	   		((currentStone == WHITESTONE) && (whiteSide == 1))) &&
	  		(!scoringGame) && (!manualScoring))
			return self;

      	if (SmartGoGameFlag)
			return self;
    
      	if ((!gameRunning) && (!finished))
			gameRunning = YES;
  
      	if (!finished) {
			int i, j, x, y;

			pickedP = event->location;
    
			x = floor((pickedP.x - ((19.0 - MAXX)/2.0)*STONEWIDTH - BASEBOARDX 	
								  - WINDOWOFFSETX + RADIUS)/STONEWIDTH);
			y = 18 - floor((pickedP.y - BASEBOARDY - WINDOWOFFSETY + RADIUS +
			((19.0 - MAXY)/2.0)*STONEHEIGHT)/STONEHEIGHT);
    
			if (x < 0) x = 0;
			if (x > MAXX - 1) x = MAXX - 1;
			if (y < 0) y = 0;
			if (y > MAXY - 1) y = MAXY - 1;
    
			if ((p[x][y] == 0) && (!suicide(x,y))) {
	  			for (i = 0; i < MAXX; i++)
	    			for (j = 0; j < MAXY; j++)
	      				oldBoard[i][j] = p[i][j];

				p[x][y] = currentStone;
	  			if (currentStone == BLACKSTONE)
	    			blackPassed = 0;
	  			else
	    			whitePassed = 0;

	  			setStoneLoc(x,y);
      
	  			[self lockFocus];
	  			switch (p[x][y]) {
	    			case WHITESTONE: 
						[self showWhiteStone];
	      				break;
	    			case BLACKSTONE: 
						[self showBlackStone];
	     			 	break;
	    			default: 
						break;
	    		}
	  			[self unlockFocus];

	  			[self doClick];

		  		[self updateInfo];

		  		[self addMoveToGameMoves: currentStone: x: y];

		  		if ([showHistFlag intValue]) {
		      		NXRect tmpRect = {{floor(stoneX), floor(stoneY)},
							{floor(STONEWIDTH), floor(STONEHEIGHT)}};

	      			[self lockFocus];
	      			[self drawSelf:&tmpRect :0];
	      			[self unlockFocus];
	    		}

	  			if (!neitherSide)
	    			[self step];
      			[self update];
			} 
		} 
		else {
			if ((scoringGame) && (manualScoring) && (!gameScored)) {
	    	int x, y;

	    	pickedP = event->location;
    
	    	x = floor((pickedP.x - ((19.0 - MAXX)/2.0)*STONEWIDTH - BASEBOARDX
		       - WINDOWOFFSETX + RADIUS)/STONEWIDTH);
	    	y = 18 - floor((pickedP.y - BASEBOARDY - WINDOWOFFSETY + RADIUS +
			    ((19.0 - MAXY)/2.0)*STONEHEIGHT)/STONEHEIGHT);
    
	    	if (x < 0) x = 0;
	    	if (x > MAXX - 1) x = MAXX - 1;
	    	if (y < 0) y = 0;
	    	if (y > MAXY - 1) y = MAXY - 1;

	    	if (p[x][y] != EMPTY) {
				int k, l;

				currentStone = p[x][y];

				find_pattern_in_board(x, y);
				for (k = 0; k < MAXX; k++)
		  			for (l = 0; l < MAXY; l++)
		    			if (patternmat[k][l]) {
							p[k][l] = EMPTY;
							if (currentStone == BLACKSTONE)
			  					blackCaptured++;
							else
			  					whiteCaptured++;
		      			}
		
				[self setblacksPrisoners:blackCaptured];
				[self setwhitesPrisoners:whiteCaptured];

				[self update];
	      	}
	  		}
  		}
  	}
  	else {
      	int x, y;
      	char s[50], n[50];
      	extern int observing, ingame;

      	if (observing || (ingame == -1)) {
	  		NXRunAlertPanel("IGS Error", "You cannot make a move unless you are playing.", "OK", 0, 0);

	  		return self;
		}

      	pickedP = event->location;
    
      	x = floor((pickedP.x - ((19.0 - MAXX)/2.0)*STONEWIDTH - BASEBOARDX -
		 	WINDOWOFFSETX + RADIUS)/STONEWIDTH);
      	y = 18 - floor((pickedP.y - BASEBOARDY - WINDOWOFFSETY + RADIUS +
		      ((19.0 - MAXY)/2.0)*STONEHEIGHT)/STONEHEIGHT);

      	if (x < 0) x = 0;
      	if (x > MAXX - 1) x = MAXX - 1;
      	if (y < 0) y = 0;
      	if (y > MAXY - 1) y = MAXY - 1;

      	s[0] = x + 'a';
      	if (x > 7)
        	s[0] = x + 'b';
      	s[1] = 0;
      	sprintf(n, "%d", MAXY-y);
      	strcat(s, n);
		{
			struct timeval tp;
    		struct timezone tzp;
	    	gettimeofday(&tp, &tzp);
			time = tp.tv_sec - time;
		
		}

 		sprintf(n, " %d", ingame); 	
      	strcat(s, n);
 
		sprintf(n, " %ld", time); 	
      	strcat(s, n);
      	strcat(s, "\n");
      	sendstr(s);
    }

  return self;
}


- passMove
{
	if (gameType == LOCAL) {
		if (((currentStone == BLACKSTONE) && (blackSide == 1)) ||
	  		((currentStone == WHITESTONE) && (whiteSide == 1))) {
			return self;
		}
		if (currentStone == BLACKSTONE) {
	  		blackPassed = 1;
	  		if (AGAScoring) blackCaptured++;
		}
      	else {
	  		whitePassed = 1;
	  		if (AGAScoring) whiteCaptured++;
		}

      	[self updateInfo];

      	[self addMoveToGameMoves: currentStone: -1: -1];
    
      	if ((!neitherSide) && (!finished))
		[self step];
    }
  	else {
		sendstr("pass\n");
    }
    
  return self;
}

- refreshIO
{
  [self setblacksPrisoners:blackCaptured];
  [self setwhitesPrisoners:whiteCaptured];
  
  [self lockFocus];
  [[self window] flushWindow];
  [self drawSelf:&bounds :0];
  [self display];
  [self unlockFocus];
  
  NXPing();

  return self;
}

- addMoveToGameMoves: (int)color: (int)x: (int)y
{
	int i, j, k, numchanges;

  	numchanges = 0;
  	for (i = 0; i < MAXX; i++)
    	for (j = 0; j < MAXY; j++)
      		if (p[i][j] != oldBoard[i][j])
				numchanges++;
  	if (x < 0 || y < 0)
		numchanges++;
  	gameMoves[lastMove].numchanges = numchanges;
  	gameMoves[lastMove].changes = (struct change *)
    	malloc((size_t)sizeof(struct change)*numchanges);
  	k = 0;
  	if (x < 0 || y < 0) {
      	gameMoves[lastMove].changes[0].added = NO;
      	gameMoves[lastMove].changes[0].x = x;
		gameMoves[lastMove].changes[0].y = y;
		gameMoves[lastMove].changes[0].color = color;
      	k++;
    }
  	for (i = 0; i < MAXX; i++)
    	for (j = 0; j < MAXY; j++)
      		if (p[i][j] != oldBoard[i][j]) {
	  			gameMoves[lastMove].changes[k].x = i;
	  			gameMoves[lastMove].changes[k].y = j;
	  			if (p[i][j] != EMPTY) {
	      			gameMoves[lastMove].changes[k].added = YES;
	      			gameMoves[lastMove].changes[k].color = p[i][j];
	    		}
	  			else {
	      			gameMoves[lastMove].changes[k].added = NO;
	      			gameMoves[lastMove].changes[k].color = oldBoard[i][j];
				}
	  			k++;
			}
  	gameMoves[lastMove].blackCaptured = blackCaptured;
  	gameMoves[lastMove].whiteCaptured = whiteCaptured;

  	lastMove++;

  	if (x >= 0)
		hist[x][y] = lastMove;

  	return self;
}

- makeMove: (int)color: (int)x: (int)y {
	int oldwhitesPrisoners, oldblacksPrisoners, i, j;

	currentStone = color;
	opposingStone = (currentStone == BLACKSTONE)?WHITESTONE:BLACKSTONE;

	if ((x >= 0) && (y >= 0)) {
		for (i = 0; i < MAXX; i++)
        	for (j = 0; j < MAXX; j++)
          		oldBoard[i][j] = p[i][j];

      	p[x][y] = color;
      
      	setStoneLoc(x,y);

	    [self lockFocus];
      	switch (p[x][y]) {
        	case WHITESTONE: 
				[self showWhiteStone];
          		break;
        	case BLACKSTONE: 
				[self showBlackStone];
          		break;
        	default: 
				break;
        }
      	[self unlockFocus];

      	[self doClick];

      	oldblacksPrisoners = blackCaptured;
      	oldwhitesPrisoners = whiteCaptured;
      
      	examboard(opposingStone);
  
      	[self setblacksPrisoners:blackCaptured];
      	[self setwhitesPrisoners:whiteCaptured];
  
      	if (((oldblacksPrisoners != blackCaptured) ||
           (oldwhitesPrisoners != whiteCaptured))) {
        	[self lockFocus];
	  		[self display];
          	[self unlockFocus];
        
		}

      	if ([showHistFlag intValue]) {
          	NXRect tmpRect = {{floor(stoneX), floor(stoneY)},
	    		      {floor(STONEWIDTH), floor(STONEHEIGHT)}};

          	[self lockFocus];
          	[self drawSelf:&tmpRect :0];
          	[self display];
			[self unlockFocus];
		}
		
		if (blackPassed) {
			blackPassed = 0;
			[gameMessage2 setStringValue:""];
		}
		
		if (whitePassed) {
			whitePassed = 0;
			[gameMessage2 setStringValue:""];
		}
	}
	[self addMoveToGameMoves: color: x: y];
	
	[gameMessage setStringValue:(opposingStone == BLACKSTONE)?"Black's Turn":
       "White's Turn"];
	
	if ((-1 == x) && (-1 == y)) {		/* opponent has passed */
		if (currentStone == BLACKSTONE) {
			blackPassed = 1;
    		[gameMessage2 setStringValue:"Black has passed."];
		}
		else {
 			whitePassed = 1;
    		[gameMessage2 setStringValue:"White has passed."];
		}
    }
	{
		struct timeval tp;
    	struct timezone tzp;
    	gettimeofday(&tp, &tzp);
		time = tp.tv_sec;
	}	
	[self doClick];
	[self update];
	return self;
}

- makeMoveSilent: (int)color: (int)x: (int)y
{
  int i, j;
      
  if ((x >= 0) && (y >= 0))
    {
      for (i = 0; i < MAXX; i++)
	for (j = 0; j < MAXY; j++)
	  oldBoard[i][j] = p[i][j];

      p[x][y] = color;

      currentStone = color;
      opposingStone = (currentStone == BLACKSTONE)?WHITESTONE:BLACKSTONE;

      examboard(opposingStone);

      [self addMoveToGameMoves: color: x: y];
    }
  
  return self;
}

- setTimeAndByo: (int)btime: (int)bbyo: (int)wtime: (int)wbyo
{
	ts.caller = self;
	if (bTime != -1) {
		if (bTime < 0)
			bTime = 0;
		if (wTime < 0)
			wTime = 0;
		if (currentStone == WHITESTONE) {		/* Black moved */
			[self removeTE];
			startZeit = 0.0;
			ts.byo = bbyo;
			ts.time = btime;
			ts.timeToHandle = blackTime;
			te = DPSAddTimedEntry(0.2, TEHandler, (void*)self,
								   NX_BASETHRESHOLD);
		} 
		else {						/* White moved */
			[self removeTE];
			startZeit = 0.0;
			ts.byo = wbyo;
			ts.time = wtime;
			ts.timeToHandle = whiteTime;
			te = DPSAddTimedEntry(0.2, TEHandler, (void*)self,
								   NX_BASETHRESHOLD);
		}
		bTime = btime;
		bByo = bbyo;
		wTime = wtime;
		wByo = wbyo;
	}
	return self;
}

- dispTime
{
	char bltime[25], whtime[25];

    sprintf(bltime, "%d:%02d", bTime / 60, bTime % 60);
    if (bByo != -1)
		sprintf(bltime, "%s, %d", bltime, bByo);
    sprintf(whtime, "%d:%02d", wTime / 60, wTime % 60);
    if (wByo != -1)
		sprintf(whtime, "%s, %d", whtime, wByo);
	[blackTime setStringValue:bltime];
	[blackTime display];
	[whiteTime setStringValue:whtime];
	[whiteTime display];
	return self;
}

- setGameNumber: (int)n
{
  [IGSGameNumber setIntValue:n];
  [IGSGameNumber display];
  
  return self;
}

- updateTitle {
	id buf = [ [MiscString alloc] initString:[IGSBlackPlayer stringValue]];
	[buf cat:" - "];
	[buf cat:[IGSWhitePlayer stringValue]];
	[[self window] setTitle:[buf stringValue]];
	[buf free];
	
	return self;	
}

- setWhiteName: (char *)wname {
	
	[IGSWhitePlayer setStringValue:wname];
	[IGSWhitePlayer display];
	[self updateTitle];

	return self;
}

- setBlackName: (char *)bname {

	[IGSBlackPlayer setStringValue:bname];
	[IGSBlackPlayer display];
	[self updateTitle];

	return self;
}

- setIGSHandicap: (int)h
{
  [IGShandicap setIntValue:h];
  [IGShandicap display];

  return self;
}

- setIGSKomi: (char *)k
{
  [IGSkomi setStringValue:k];
  [IGSkomi display];

  return self;
}

- setByoTime: (int)aByoTime {
	ByoTime = aByoTime;
	
	return self;
}

- (int) ByoTime {
	return ByoTime;
}

- updateInfo
{
  int oldblacksPrisoners, oldwhitesPrisoners, i, j;
  
  if (finished && gameScored && resultsDisplayed)
    {
      [startButton setEnabled: NO];
      [stopButton setEnabled: NO];
      [passButton setEnabled: NO];
      return self;
    }
  
  oldblacksPrisoners = blackCaptured;
  oldwhitesPrisoners = whiteCaptured;
      
  examboard(opposingStone);
  
  	if (currentStone == BLACKSTONE) {
  		opposingStone = BLACKSTONE;
    	currentStone = WHITESTONE;
    	[gameMessage setStringValue:"White's Turn"];
  	} else {
    	opposingStone = WHITESTONE;
    	currentStone = BLACKSTONE;
    	[gameMessage setStringValue:"Black's Turn"];
  	}
  
	[self setblacksPrisoners:blackCaptured];
	[self setwhitesPrisoners:whiteCaptured];
  
	if (((oldblacksPrisoners != blackCaptured) ||
      	(oldwhitesPrisoners != whiteCaptured))) {
      	[self lockFocus];
      	for (i = 0; i < MAXX; i++)
			for (j = 0; j < MAXX; j++)
	  			if ((oldBoard[i][j] != EMPTY) && (p[i][j] == EMPTY)) {
	      			setStoneLoc(i, j);
	      			[self eraseStone];
	      			[self showBackgroundPiece: i: j];
	    		}
    	[self unlockFocus];
  	}

  if ([showHistFlag intValue])
    {
      NXRect tmpRect = {{floor(stoneX), floor(stoneY)},
			  {floor(STONEWIDTH), floor(STONEHEIGHT)}};

      [self lockFocus];
      [self drawSelf:&tmpRect :0];
      [self display];
      [self unlockFocus];
    }
  
  if ((blackPassed) && (opposingStone == BLACKSTONE))
    [gameMessage2 setStringValue:"Black has passed."];
    
  if ((whitePassed) && (opposingStone == WHITESTONE))
    [gameMessage2 setStringValue:"White has passed."];
    
  if ((!blackPassed) && (!whitePassed))
    [gameMessage2 setStringValue:""];
  
  if ((blackPassed) && (whitePassed) && (!manualScoring) && (!gameScored))
    {
      [self lockFocus];
      [[self window] flushWindow];
      [gameMessage setStringValue:"Scoring Game, Please Wait"];
      [gameMessage2 setStringValue:"Removing Dead Groups..."];
      [self display];
      [self unlockFocus];
      finished = 1;
      score_game();
//      [self scoreGame];
      manualScoring = 1;
    }
  if ((blackPassed) && (whitePassed) && (manualScoring) && (!gameScored))
    {
      [self lockFocus];
      [[self window] flushWindow];
      [gameMessage setStringValue:"Please remove dead groups"];
      [gameMessage2 setStringValue:"When finished, press Start..."];
      [self display];
      [self unlockFocus];
      [passButton setEnabled:NO];
      [stopButton setEnabled:NO];
      finished = 1;
      scoringGame = YES;
    }

  return self;

}

- displayScoringInfo
{
  char s[35];
  int i, j;

  if (gameScored)
    {
      resultsDisplayed = YES;
      if (typeOfScoring == 0)
	{
	  black_Score = (float)blackTerritory - (float)blackCaptured;
	  white_Score = (float)whiteTerritory - (float)whiteCaptured;
	  white_Score += (handicap == 0)?KOMI:0.5;
	  [TypeOfScoring setStringValue:"Japanese Scoring Method"];
	  [BlackTerrString setStringValue:"Territory"];
	  [WhiteTerrString setStringValue:"Territory"];
	  [BlackTerrValue setIntValue:blackTerritory];
	  [WhiteTerrValue setIntValue:whiteTerritory];
	  [BlackPrisonString setStringValue:"Prisoners"];
	  [WhitePrisonString setStringValue:"Prisoners"];
	  [BlackPrisonValue setIntValue:blackCaptured];
	  [WhitePrisonValue setIntValue:whiteCaptured];
	  [BlackTotalValue setFloatValue:black_Score];
	  [WhiteTotalValue setFloatValue:white_Score];
	}
      else
	{
	  blackStones = whiteStones = 0;
	  for (i = 0; i < MAXX; i++)
	    for (j = 0; j < MAXY; j++)
	      {
		if (p[i][j] == BLACKSTONE) blackStones++;
		if (p[i][j] == WHITESTONE) whiteStones++;
	      }
	  black_Score = (float)blackTerritory + (float)blackStones;
	  white_Score = (float)whiteTerritory + (float)whiteStones;
	  white_Score += (handicap == 0)?KOMI:0.5;
	  [TypeOfScoring setStringValue:"Chinese Scoring Method"];
	  [BlackTerrString setStringValue:"Territory"];
	  [WhiteTerrString setStringValue:"Territory"];
	  [BlackTerrValue setIntValue:blackTerritory];
	  [WhiteTerrValue setIntValue:whiteTerritory];
	  [BlackPrisonString setStringValue:"Stones"];
	  [WhitePrisonString setStringValue:"Stones"];
	  [BlackPrisonValue setIntValue:blackStones];
	  [WhitePrisonValue setIntValue:whiteStones];
	  [BlackTotalValue setFloatValue:black_Score];
	  [WhiteTotalValue setFloatValue:white_Score];
	}
      if (black_Score > white_Score)
	sprintf(s, "Result:  Black wins by %3.1f points.", black_Score - white_Score);
      if (white_Score > black_Score)
	sprintf(s, "Result:  White wins by %3.1f points.", white_Score - black_Score);
      if (black_Score == white_Score)
	sprintf(s, "Result:  The game was a tie.");
      [KomiValue setFloatValue:((handicap == 0)?KOMI:0.5)];
      [GameResult setStringValue:s];
      [ScoringWindow makeKeyAndOrderFront:self];
      [gameMessage setStringValue:"Game Over"];
      [self lockFocus];
      [self display];
      [self unlockFocus];
    }
  
  return self;
}

- scoreGame
{
  int i, j, k, l, changes = 1, num_in_pattern;

  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      scoringmat[i][j] = 0;
      
  while (changes)
    {
      changes = 0;
      find_owner();

      for (i = 0; i < MAXX; i++)
	for (j = 0; j < MAXY; j++)
	  if ((p[i][j] != 0) && (scoringmat[i][j] == 0))
	    {
	      if (surrounds_territory(i, j))
		{
		  find_pattern_in_board(i, j);

		  for (k = 0; k < MAXX; k++)
		    for (l = 0; l < MAXY; l++)
		      if (patternmat[k][l])
			scoringmat[k][l] = p[k][l];
		}
	      else
		{
		  find_pattern_in_board(i, j);
		  set_temp_to_p();
		  num_in_pattern = 0;

		  for (k = 0; k < MAXX; k++)
		    for (l = 0; l < MAXY; l++)
		      if (patternmat[k][l])
			{
			  p[k][l] = EMPTY;
			  [self flashStone:k:l];
			  num_in_pattern++;
			}

		  find_owner();

		  if ((ownermat[i][j] != NEUTRAL_TERR) &&
		      (ownermat[i][j] != tempmat[i][j]))
		    {
		      if (tempmat[i][j] == BLACKSTONE)
			blackCaptured += num_in_pattern;
		      else
			whiteCaptured += num_in_pattern;
		      changes++;
		      [self lockFocus];
		      [self display];
		      [self unlockFocus];
		    }
		  else
		    {
		      set_p_to_temp();
		      find_owner();
		    }
		}
	    }
    }

/*  blackTerritory = 0;
  whiteTerritory = 0;

  [self lockFocus];
  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      {
	if (ownermat[i][j] == BLACKSTONE)
	  {
	    blackTerritory++;
	    p[i][j] = BLACK_TERR;
	  }
	if (ownermat[i][j] == WHITESTONE)
	  {
	    whiteTerritory++;
	    p[i][j] = WHITE_TERR;
	  }
	if (ownermat[i][j] == NEUTRAL_TERR)
	  {
	    [self flashStone:i:j];
	    p[i][j] = NEUTRAL_TERR;
	  }
      }
  [self unlockFocus];   */

  return self;
}

// The following methods draw the pieces.
  
  - drawBlackStone:imageRep 
{
  //    PSscale (1.0, 1.0);
  
  // First draw the shadow under the stone.
    
//    PSarc (RADIUS+SHADOWOFFSET/2, RADIUS-SHADOWOFFSET/2, 
//	   RADIUS-SHADOWOFFSET, 0.0, 360.0);
//  PSsetgray (NX_DKGRAY);
//  if (NXDrawingStatus == NX_DRAWING) {
//    PSsetalpha (0.666);
//  }
//  PSfill ();
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }
  
  // Draw the stone.
    
    PSarc (RADIUS, RADIUS, 
	   RADIUS, 0.0, 360.0);
  PSsetgray (NX_BLACK);
  PSfill ();
  
  // And the lighter & darker spots on the stone...
    
    PSarcn (RADIUS, RADIUS, 
	    RADIUS-SHADOWOFFSET-3.0, 170.0, 100.0);
  PSarc (RADIUS, RADIUS, 
	 RADIUS-SHADOWOFFSET-2.0, 100.0, 170.0);
  PSsetgray (NX_DKGRAY);
  PSfill ();
  PSarcn (RADIUS, RADIUS, 
	  RADIUS-SHADOWOFFSET-3.0, 350.0, 280.0);
  PSarc (RADIUS, RADIUS, 
	 RADIUS-SHADOWOFFSET-2.0, 280.0, 350.0);
  PSsetgray (NX_LTGRAY);
  PSfill ();
  
  return self;
}

- drawWhiteStone:imageRep 
{
  //    PSscale (1.0, 1.0);
  
  // First draw the shadow under the stone.
    
//    PSarc (RADIUS+SHADOWOFFSET/2, RADIUS-SHADOWOFFSET/2, 
//	   RADIUS-SHADOWOFFSET, 0.0, 360.0);
//  PSsetgray (NX_DKGRAY);
//  if (NXDrawingStatus == NX_DRAWING) {
//    PSsetalpha (0.666);
//  }
//  PSfill ();
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }
  
  // Draw the stone.
    
    PSarc (RADIUS, RADIUS, 
	   RADIUS, 0.0, 360.0);
  PSsetgray (NX_WHITE);
  PSfill ();
  
  // And the lighter & darker spots on the stone...
    
    PSarcn (RADIUS, RADIUS, 
	    RADIUS-SHADOWOFFSET-3.0, 170.0, 100.0);
  PSarc (RADIUS, RADIUS, 
	 RADIUS-SHADOWOFFSET-2.0, 100.0, 170.0);
  PSsetgray (NX_LTGRAY);
  PSfill ();
  PSarcn (RADIUS, RADIUS, 
	  RADIUS-SHADOWOFFSET-3.0, 350.0, 280.0);
  PSarc (RADIUS, RADIUS, 
	 RADIUS-SHADOWOFFSET-2.0, 280.0, 350.0);
  PSsetgray (NX_DKGRAY);
  PSfill ();
  
  return self;
}

- drawGrayStone:imageRep 
{
  //    PSscale (1.0, 1.0);
  
  // First draw the shadow under the stone.
    
//    PSarc (RADIUS+SHADOWOFFSET/2, RADIUS-SHADOWOFFSET/2, 
//	   RADIUS-SHADOWOFFSET, 0.0, 360.0);
//  PSsetgray (NX_DKGRAY);
//  if (NXDrawingStatus == NX_DRAWING) {
//    PSsetalpha (0.666);
//  }
//  PSfill ();
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }
  
  // Draw the stone.
    
//    PSarc (RADIUS-SHADOWOFFSET/2, RADIUS+SHADOWOFFSET/2, 
//	   RADIUS-SHADOWOFFSET, 0.0, 360.0);
    PSarc (RADIUS, RADIUS, 
	   RADIUS, 0.0, 360.0);
  PSsetgray (NX_DKGRAY);
  PSfill ();
  
  // And the lighter & darker spots on the stone...
    
    PSarcn (RADIUS, RADIUS, 
	    RADIUS-SHADOWOFFSET-3.0, 170.0, 100.0);
  PSarc (RADIUS, RADIUS, 
	 RADIUS-SHADOWOFFSET-2.0, 100.0, 170.0);
  PSsetgray (NX_LTGRAY);
  PSfill ();
  PSarcn (RADIUS, RADIUS, 
	  RADIUS-SHADOWOFFSET-3.0, 350.0, 280.0);
  PSarc (RADIUS, RADIUS, 
	 RADIUS-SHADOWOFFSET-2.0, 280.0, 350.0);
  PSsetgray (NX_WHITE);
  PSfill ();
  
  return self;
}

- drawUpperLeft:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(RADIUS, RADIUS);
  PSlineto(bounds.size.width,RADIUS);
  PSmoveto(RADIUS, RADIUS);
  PSlineto(RADIUS, 0.0);
  PSmoveto(RADIUS-SHADOWOFFSET, RADIUS+SHADOWOFFSET);
  PSlineto(bounds.size.width, RADIUS+SHADOWOFFSET);
  PSmoveto(RADIUS-SHADOWOFFSET, RADIUS+SHADOWOFFSET);
  PSlineto(RADIUS-SHADOWOFFSET, 0.0);
  PSstroke();

  return self;
}

- drawUpperRight:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(RADIUS, RADIUS);
  PSlineto(0.0,RADIUS);
  PSmoveto(RADIUS, RADIUS);
  PSlineto(RADIUS, 0.0);
  PSmoveto(RADIUS+SHADOWOFFSET, RADIUS+SHADOWOFFSET);
  PSlineto(0.0, RADIUS+SHADOWOFFSET);
  PSmoveto(RADIUS+SHADOWOFFSET, RADIUS+SHADOWOFFSET);
  PSlineto(RADIUS+SHADOWOFFSET, 0.0);
  PSstroke();

  return self;
}

- drawLowerLeft:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(RADIUS, RADIUS);
  PSlineto(bounds.size.width,RADIUS);
  PSmoveto(RADIUS, RADIUS);
  PSlineto(RADIUS, bounds.size.height);
  PSmoveto(RADIUS-SHADOWOFFSET, RADIUS-SHADOWOFFSET);
  PSlineto(bounds.size.width, RADIUS-SHADOWOFFSET);
  PSmoveto(RADIUS-SHADOWOFFSET, RADIUS-SHADOWOFFSET);
  PSlineto(RADIUS-SHADOWOFFSET, bounds.size.height);
  PSstroke();

  return self;
}

- drawLowerRight:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(RADIUS, RADIUS);
  PSlineto(0.0,RADIUS);
  PSmoveto(RADIUS, RADIUS);
  PSlineto(RADIUS, bounds.size.height);
  PSmoveto(RADIUS+SHADOWOFFSET, RADIUS-SHADOWOFFSET);
  PSlineto(0.0, RADIUS-SHADOWOFFSET);
  PSmoveto(RADIUS+SHADOWOFFSET, RADIUS-SHADOWOFFSET);
  PSlineto(RADIUS+SHADOWOFFSET, bounds.size.height);
  PSstroke();

  return self;
}

- drawMidLeft:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(RADIUS, RADIUS);
  PSlineto(bounds.size.width,RADIUS);
  PSmoveto(RADIUS, bounds.size.height);
  PSlineto(RADIUS, 0.0);
  PSmoveto(RADIUS-SHADOWOFFSET, bounds.size.height);
  PSlineto(RADIUS-SHADOWOFFSET, 0.0);
  PSstroke();

  return self;
}

- drawMidRight:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(RADIUS, RADIUS);
  PSlineto(0.0,RADIUS);
  PSmoveto(RADIUS, bounds.size.height);
  PSlineto(RADIUS, 0.0);
  PSmoveto(RADIUS+SHADOWOFFSET, bounds.size.height);
  PSlineto(RADIUS+SHADOWOFFSET, 0.0);
  PSstroke();

  return self;
}

- drawMidTop:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(RADIUS, RADIUS);
  PSlineto(RADIUS,0.0);
  PSmoveto(0.0, RADIUS);
  PSlineto(bounds.size.width, RADIUS);
  PSmoveto(0.0, RADIUS+SHADOWOFFSET);
  PSlineto(bounds.size.width, RADIUS+SHADOWOFFSET);
  PSstroke();

  return self;
}

- drawMidBottom:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(RADIUS, RADIUS);
  PSlineto(RADIUS,bounds.size.height);
  PSmoveto(0.0, RADIUS);
  PSlineto(bounds.size.width, RADIUS);
  PSmoveto(0.0, RADIUS-SHADOWOFFSET);
  PSlineto(bounds.size.width, RADIUS-SHADOWOFFSET);
  PSstroke();

  return self;
}

- drawInnerSquare:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(0.0, RADIUS);
  PSlineto(bounds.size.width,RADIUS);
  PSmoveto(RADIUS, bounds.size.height);
  PSlineto(RADIUS, 0.0);
  PSstroke();

  return self;
}

- drawInnerHandicap:imageRep
{
  PSsetgray(NX_BLACK);
  PSsetlinewidth(0.0);
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetalpha (1.0);
  }

  PSnewpath();
  PSmoveto(0.0, RADIUS);
  PSlineto(bounds.size.width,RADIUS);
  PSmoveto(RADIUS, bounds.size.height);
  PSlineto(RADIUS, 0.0);
  PSstroke();
  
  PSarc(RADIUS, RADIUS, SHADOWOFFSET, 0.0, 360.0);
  PSfill();

  return self;
}

// The following methods show or erase the stones from the board.
  
  - showBlackStone 
{
  NXRect tmpRect = {{floor(stoneX), floor(stoneY)},
		      {floor(STONEWIDTH), floor(STONEHEIGHT)}};
  [blackStone composite:NX_SOVER toPoint:&tmpRect.origin];
  return self;
}

- showWhiteStone
{
  NXRect tmpRect = {{floor(stoneX), floor(stoneY)},
		      {floor(STONEWIDTH), floor(STONEHEIGHT)}};
  [whiteStone composite:NX_SOVER toPoint:&tmpRect.origin];
  return self;
}

- showGrayStone
{
  NXRect tmpRect = {{floor(stoneX), floor(stoneY)},
		      {floor(STONEWIDTH), floor(STONEHEIGHT)}};
  [grayStone composite:NX_SOVER toPoint:&tmpRect.origin];
  return self;
}

- eraseStone
{
  NXRect tmpRect = {{floor(stoneX), floor(stoneY)}, {floor(STONEWIDTH), floor(STONEHEIGHT)}};
  return [self drawBackground:&tmpRect];
}

// drawBackground: just draws the specified piece of the background by
// compositing from the background image.

- showBackgroundPiece: (int)x: (int)y {
  int q;
  NXRect tmpRect = {{floor(stoneX), floor(stoneY)}, {floor(STONEWIDTH), floor(STONEHEIGHT)}};

  if ((x == 0) && (y == 0))
    [upperLeft composite:NX_SOVER toPoint:&tmpRect.origin];
  
  if ((x == 0) && (y == MAXY - 1))
    [lowerLeft composite:NX_SOVER toPoint:&tmpRect.origin];
  
  if ((x == MAXX - 1) && (y == 0))
    [upperRight composite:NX_SOVER toPoint:&tmpRect.origin];
  
  if ((x == MAXX - 1) && (y == MAXY - 1))
    [lowerRight composite:NX_SOVER toPoint:&tmpRect.origin];
  
  if ((x == 0) && (y > 0) && (y < MAXY - 1))
    [midLeft composite:NX_SOVER toPoint:&tmpRect.origin];
  
  if ((x == MAXX - 1) && (y > 0) && (y < MAXY - 1))
    [midRight composite:NX_SOVER toPoint:&tmpRect.origin];
  
  if ((x > 0) && (x < MAXX - 1) && (y == 0))
    [midTop composite:NX_SOVER toPoint:&tmpRect.origin];
  
  if ((x > 0) && (x < MAXX - 1) && (y == MAXY - 1))
    [midBottom composite:NX_SOVER toPoint:&tmpRect.origin];
  
  if ((x > 0) && (x < MAXX - 1) && (y > 0) && (y < MAXY - 1))
    [innerSquare composite:NX_SOVER toPoint:&tmpRect.origin];
    
  if (MAXX < 13)
    q = 2;
  else
    q = 3;
  
  if (((x == q) && (y == q)) || ((x == q) && (y == MAXY/2)) ||
      ((x == q) && (y == MAXY-q-1)) || ((x == MAXX/2) && (y == q)) ||
      ((x == MAXX/2) && (y == MAXY/2)) || ((x == MAXX/2) && (y == MAXY-q-1)) ||
      ((x == MAXX-q-1) && (y == q)) || ((x == MAXX-q-1) && (y == MAXY/2)) ||
      ((x == MAXX-q-1) && (y == MAXY-q-1)))
    [innerHandicap composite:NX_SOVER toPoint:&tmpRect.origin];

  return self;
}
  
  - drawBackground:(NXRect *)rect
{
  NXRect tmpRect = *rect;
  
  NX_X(&tmpRect) = floor(NX_X(&tmpRect));
  NX_Y(&tmpRect) = floor(NX_Y(&tmpRect));
  if (NXDrawingStatus == NX_DRAWING) {
    PSsetgray (NX_WHITE);
    PScompositerect (NX_X(&tmpRect), NX_Y(&tmpRect),
		     NX_WIDTH(&tmpRect), NX_HEIGHT(&tmpRect), NX_COPY);
  }
  [backGround composite:NX_SOVER fromRect:&tmpRect toPoint:&tmpRect.origin];
  return self;
}

// drawSelf::, a method every decent View should have, redraws the game
// in its current state. This allows us to print the game very easily.
  
  - drawSelf:(NXRect *)rects :(int)rectCount 
{
  int xcnt, ycnt;
  char s[5], specialChar;
  
  [self drawBackground:(rects ? rects : &bounds)];

  specialChar = 'a';

  for (xcnt = 0; xcnt < MAXX; xcnt++)
    {
      for (ycnt = 0; ycnt < MAXY; ycnt++)
	{
	  setStoneLoc(xcnt, ycnt);

	  switch (p[xcnt][ycnt])
	    {
	    case EMPTY: currentCharacter = 0;
	      [self showBackgroundPiece: xcnt: ycnt];
	      break;
	    case WHITESTONE: [self showWhiteStone];
	      if ([showHistFlag intValue])
		{
		  char s[5];
		  
		  [historyFont set];
		  PSsetgray(NX_BLACK);
		  PSmoveto(stoneX+RADIUS -
			   (floor(log(hist[xcnt][ycnt]+0.5)/log(10))+1.0)*3,
			   stoneY+RADIUS - 4);
		  if (hist[xcnt][ycnt] > 0)
		    {
		      sprintf(s, "%d", hist[xcnt][ycnt]);
		      PSshow(s);
		    }
		  else
		    {
		      PSmoveto(stoneX + RADIUS - 4, stoneY + RADIUS - 4);
		      PSshow("H");
		    }
		}
	      break;
	    case BLACKSTONE: [self showBlackStone];
	      if ([showHistFlag intValue])
		{
		  char s[5];

		  [historyFont set];
		  PSsetgray(NX_WHITE);
		  PSmoveto(stoneX+RADIUS -
			   (floor(log(hist[xcnt][ycnt]+0.5)/log(10))+1.0)*3,
			   stoneY+RADIUS - 4);
		  if (hist[xcnt][ycnt] > 0)
		    {
		      sprintf(s, "%d", hist[xcnt][ycnt]);
		      PSshow(s);
		    }
		  else
		    {
		      PSmoveto(stoneX + RADIUS - 4, stoneY + RADIUS - 4);
		      PSshow("H");
		    }
		}
	      break;
	    case NEUTRAL_TERR: [self showGrayStone];
	      break;
	    case WHITE_TERR: [self showBackgroundPiece: xcnt: ycnt];
	      [whiteTerrFont set];
	      PSsetgray(NX_WHITE);
	      PSmoveto(stoneX+RADIUS/3, stoneY+RADIUS/3+2);
	      PSshow("W");
	      break;
	    case BLACK_TERR: [self showBackgroundPiece: xcnt: ycnt];
	      [blackTerrFont set];
	      PSsetgray(NX_DKGRAY);
	      PSmoveto(stoneX+RADIUS/3+1, stoneY+RADIUS/3);
	      PSshow("B");
	      break;
	    case SPECIAL_CHAR: [self showBackgroundPiece: xcnt: ycnt];
	      PSselectfont("Helvetica", 25.0);
	      PSsetgray(NX_DKGRAY);
	      PSmoveto(stoneX+RADIUS/3+1, stoneY+RADIUS/3);
	      sprintf(s,"%c",specialChar);
	      specialChar++;
	      PSshow(s);
	      break;
	    default: currentCharacter = 0;
	      [self showBackgroundPiece: xcnt: ycnt];
	      break;
	    }
	}
    }

  if ([showCoords intValue])
    {
      for (xcnt = 0; xcnt < MAXX; xcnt++)
	{
	  setStoneLoc(xcnt, 0);

	  [historyFont set];
	  PSsetgray(NX_DKGRAY);
	  PSmoveto(stoneX + RADIUS - 3, stoneY + RADIUS + 11);
	  s[0] = 'A' + xcnt;
	  if (xcnt > 7) s[0]++;
	  s[1] = 0;
	  PSshow(s);

          setStoneLoc(xcnt, MAXY - 1);
          PSmoveto(stoneX + RADIUS - 3, stoneY - 3);
	  PSshow(s);
	}
      for (ycnt = 0; ycnt < MAXX; ycnt++)
	{
	  setStoneLoc(0, ycnt);

	  [historyFont set];
	  PSsetgray(NX_DKGRAY);
	  PSmoveto(stoneX - 4, stoneY + RADIUS - 4);
	  sprintf(s, "%d", MAXY-ycnt);
	  PSshow(s);

	  setStoneLoc(MAXX - 1, ycnt);
	  if (xcnt < 10)
	    {
	      PSmoveto(stoneX + STONEWIDTH, stoneY + RADIUS - 4);
	    }
	  else
	    {
	      PSmoveto(stoneX + STONEWIDTH - 6, stoneY + RADIUS - 4);
	    }
	  PSshow(s);
	}
    }
  
  return self;
}

- print:sender
{
  return [self printPSCode:sender];
}

- step
{
  NXEvent peek_ev, *get_ev;
  
  if (gameType == IGSGAME)
    {
      return self;
    }
  
  if (neitherSide)
    return self;
    
  if (((currentStone == BLACKSTONE) && (blackSide == 0)) ||
      ((currentStone == WHITESTONE) && (whiteSide == 0)))
    return self;
  
  if (bothSides) {
    while ((gameRunning) && (!finished)) {
      [self selectMove];
      NXPing();

      if( [NXApp peekNextEvent: NX_MOUSEDOWNMASK into: &peek_ev] ){
	get_ev = [NXApp getNextEvent: NX_MOUSEDOWNMASK];
	[NXApp sendEvent: get_ev];
      }
    }
  
    NXPing();
  } else {
    [passButton setEnabled: NO];
    [self selectMove];

    NXPing();

    NXPing();
    [passButton setEnabled: YES];
    NXPing();
  }
  return self;
}

- selectMove
{
  int i, j;
  
  NXPing();

  if( !bothSides )
    [stopButton setEnabled: NO];
  else
    [stopButton setEnabled: YES];

  for (i = 0; i < MAXX; i++)
    for (j = 0; j < MAXY; j++)
      oldBoard[i][j] = p[i][j];
  
  genmove( &i, &j );
  if (i >= 0)
    {
      p[i][j] = currentStone;

      [self flashStone: i: j];
    }

  if (((i < 0) || (j < 0)) && (AGAScoring))
    {
      if (currentStone == BLACKSTONE)
        blackCaptured++;
      else
        whiteCaptured++;
    }
  
  [self selectMoveEnd];
    
  if (i >= 0)
    {
      [self lockFocus];
      if (currentStone == BLACKSTONE)
        [self showBlackStone];
      else
        [self showWhiteStone];
      [self unlockFocus];

      [self doClick];
    }

  [self updateInfo];
    
  [self addMoveToGameMoves: currentStone: i: j];
  
  if ([showHistFlag intValue])
    {
      NXRect tmpRect = {{floor(stoneX), floor(stoneY)},
			  {floor(STONEWIDTH), floor(STONEHEIGHT)}};

      [self lockFocus];
      [self drawSelf:&tmpRect :0];
      [self display];
      [self unlockFocus];
    }

  NXPing();
  return self;
}

- selectMoveEnd
{
  NXPing();

  [startButton setEnabled: YES];
  [stopButton setEnabled: YES];
  NXPing();

  return self;
}

- flashStone: (int)x :(int)y
{
  
  setStoneLoc(x, y);
  
  [self lockFocus];
  [self showGrayStone];
  [self unlockFocus];
  
  return self;
}

- setMess1:(char *)s
{
  [gameMessage setStringValue:s];
  [gameMessage display];

  return self;
}

- setMess2:(char *)s
{
  [gameMessage2 setStringValue:s];
  [gameMessage2 display];

  return self;
}

- setblacksPrisoners:(int)bp
{
  [blacksPrisoners setIntValue:bp];
  [blacksPrisoners display];

  return self;
}

- setwhitesPrisoners:(int)wp
{
  [whitesPrisoners setIntValue:wp];
  [whitesPrisoners display];

  return self;
}

- (float)startZeit {
	return startZeit;
}

- setStartZeit:(float)aTime {
	startZeit = aTime;
	return self;
}

- (int)bByo {
	return bByo;
}

- (TimeStruct*)ts {
	return &ts;
}

- gameCompleted {
	
	[self removeTE];	
  	[self setblacksPrisoners:0];
  	[self setwhitesPrisoners:0];
	[IGSGameNumber setStringValue:""]; 
	[IGSBlackPlayer setStringValue:""]; 
	[IGSWhitePlayer setStringValue:""]; 
	[IGShandicap setStringValue:""]; 
	[IGSkomi setStringValue:""];
	[blackTime setStringValue:""];
	[whiteTime setStringValue:""];

	
	return self;
}

- removeTE {
	if (te) 
		DPSRemoveTimedEntry(te);
	te = 0;
	return self;
}

@end

