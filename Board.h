#include "comment.header"

/* $Id: Board.h,v 1.3 1997/07/06 19:38:19 ergo Exp $ */

/*
 * $Log: Board.h,v $
 * Revision 1.3  1997/07/06 19:38:19  ergo
 * actual version
 *
 * Revision 1.3  1997/05/04 18:57:16  ergo
 * added time control for moves
 *
 */

#import <appkit/View.h>
#import <soundkit/Sound.h>
#import <dpsclient/dpsNeXT.h>
#include "history.h"

// Maximum number of tiles in the playing area...
  
#define WHITESTONE	1     
#define BLACKSTONE	2
  
extern unsigned char p[19][19];
extern unsigned char patternmat[19][19], scoringmat[19][19], ownermat[19][19];
extern unsigned char tempmat[19][19], newpatternmat[19][19], mark[19][19];
extern char special_characters[19][19];
extern int hist[19][19], currentMoveNumber;
extern int rd, bothSides, neitherSide, blackSide, whiteSide, MAXX, MAXY;
extern int opn[9], blackCaptured, whiteCaptured, handicap;
extern int currentStone, opposingStone, blackPassed, whitePassed;
extern int blackTerritory, whiteTerritory, SmartGoGameFlag;
extern int AGAScoring, manualScoring, manScoreTemp, typeOfScoring, gameType;
extern float black_Score, white_Score;
extern gameHistory gameMoves[500];
extern int lastMove;
extern BOOL finished;
BOOL scoringGame, resultsDisplayed;
typedef struct {
	id caller;
	id timeToHandle;
	int time;
	int byo;
	} TimeStruct;  
	


@interface GoView:View 
{
  
  BOOL gameRunning, gameScored;
  
	id 	blackStone, 
  		whiteStone, 
		grayStone, 
		backGround, 
		gameMessage, 
		blacksPrisoners, 
		whitesPrisoners, 
		gameMessage2, 
		startButton, 
		stopButton, 
		passButton, 
		mainMenu, 
		upperLeft, 
		upperRight, 
		lowerLeft, 
		lowerRight, 
		midLeft, 
		midRight, 
		midTop, 
		midBottom, 
		innerSquare, 
		innerHandicap;
	id 	BlackTerrValue, 
		BlackTerrString, 
		BlackPrisonValue, 
		BlackPrisonString, 
		BlackTotalValue, 
		WhiteTerrValue, 
		WhiteTerrString, 
		WhitePrisonValue, 
		WhitePrisonString, 
		WhiteTotalValue, 
		GameResult, 
		KomiValue, 
		TypeOfScoring, 
		ScoringWindow;
	id	showHistFlag, 
		historyFont, 
		blackTerrFont, 
		whiteTerrFont, 
		stoneClick, 
		showCoords, 
		playSounds, 
		blackTime, 
		whiteTime, 
		IGSGameNumber, 
		IGSBlackPlayer, 
		IGSWhitePlayer, 
		IGShandicap, 
		IGSkomi;
	id	ControlPanel;
		
	int bTime, bByo, wTime, wByo;
	DPSTimedEntry te;
	float startZeit;
	TimeStruct	ts;
	int ByoTime;		/* time in byo-yomi in minutes 	*/
	long time;			/* time we received a move 		*/
  
}

/* The following methods can be called by Interface Builder objects &
   during creation/destruction of instances of BreakView.  */
  
- initFrame:(const NXRect *)frm;
- free;

- resetButtons;
- startNewGame;
- go:sender;
- stop:sender;
- passMove;
- showLastMove:sender;
- undo;
- undoLastMove:sender;
- toggleShowHistFlag:sender;
- toggleSound:sender;
- doClick;
- toggleCoords:sender;

- changeBackground:sender;
- revertBackground:sender;

- setMess1:(char *)s;
- setMess2:(char *)s;

/* The following methods are internal and probably should not be called
   by others.  */
  
- setBackgroundFile:(const char *)fileName andRemember:(BOOL)remember;
- drawSelf:(NXRect *)rects :(int)rectCount;
- drawBackground:(NXRect *)rect;
- showBlackStone;
- showWhiteStone;
- showGrayStone;
- showBackgroundPiece: (int)x: (int)y;
- eraseStone;
- addMoveToGameMoves: (int)color: (int)x: (int)y;
- makeMove: (int)color: (int)x: (int)y;
- makeMoveSilent: (int)color: (int)x: (int)y;
- setGameNumber: (int)n;
- setTimeAndByo: (int)btime: (int)bbyo: (int)wtime: (int)wbyo;
- dispTime;
- setWhiteName: (char *)wname;
- setBlackName: (char *)bname;
- setIGSHandicap: (int)h;
- setIGSKomi: (char *)k;
- setByoTime: (int)aByoTime;
- (int)ByoTime;
- updateInfo;
- refreshIO;
- displayScoringInfo;
- scoreGame;
- step;
- selectMove;
- selectMoveEnd;
- flashStone: (int)x :(int)y;
- setblacksPrisoners:(int)bp;
- setwhitesPrisoners:(int)wp;
- (float)startZeit;
- setStartZeit:(float)aTime;
- (int)bByo;
- (TimeStruct*)ts;
- gameCompleted;
- removeTE;

@end
