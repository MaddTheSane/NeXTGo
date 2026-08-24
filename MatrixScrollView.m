/*---------------------------------------------------------------------------
MatrixScrollView.m -- single column selection matrix within a scroll view

Copyright (c) 1990 Doug Brenner

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 1, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA, or send
   electronic mail to the the author.

Implementation for the MatrixScrollView class.  MatrixScrollView is similar
to the ScrollView available in Interface Builder (IB), except it contains a
matrix of selection cells, not a text object.

The matrix is specifically designed to hold one row and to resize itself so
the matrix always fills the clip view.  (See AutoWidthMatrix for more details
about the matrix.)

MatrixScrollView is rather single-minded in its behavior because I use it as
a Custom View in Interface Builder.  (Until custom views are supported in
Interface Builder there seems little other choice.)

Doug Brenner <dbrenner@umaxc.weeg.uiowa.edu>

$Header: /usr/local/lib/cvs/Repository/NeXTGo/MatrixScrollView.m,v 1.2 1997/07/06 19:37:58 ergo Exp $
-----------------------------------------------------------------------------
$Log: MatrixScrollView.m,v $
Revision 1.2  1997/07/06 19:37:58  ergo
actual version

Revision 1.2  1997/05/04 18:56:56  ergo
added time control for moves

---------------------------------------------------------------------------*/

#import "MatrixScrollView.h"
#import "AutoWidthMatrix.h"

#import <appkit/SelectionCell.h>

#include <string.h>

@implementation MatrixScrollView

+ newFrame:(const NXRect *) frameRect
{
   /* ScrollView instance variables used:
      id contentView */

   NXRect matrixFrame = {0.0, 0.0, 0.0, 0.0};
   id matrix;
   

   /* ---------- create the scroll view */

   self = [super newFrame:frameRect];
   [self setBorderType:NX_BEZEL];
   [self setVertScrollerRequired:YES];

   /* The matrix may not be as large as the ClipView; a light gray background
      makes the transition from Matrix to ScrollView less apparent. */

   [self setBackgroundGray:NX_LTGRAY];

   /* Make sure resize messages (superviewSizeChanged:) are passed down the
      view chain so things will update correctly. */

   [self setAutoresizeSubviews:YES];
   [contentView setAutoresizeSubviews:YES];
   

   /* ---------- create the matrix managed by the scroll and clip views */

   [self getContentSize:&(matrixFrame.size)];

   matrix = [AutoWidthMatrix newFrame:&matrixFrame mode:NX_RADIOMODE
             cellClass:[SelectionCell class] numRows:0 numCols:0];
   [matrix setAutoscroll:YES];

   /* Setting the matrix background to light gray hides the intercell gaps. */

   [matrix setBackgroundGray:NX_LTGRAY];
   
   /* Attach the matrix to the scroll and clip views and size to superview. */

   [[self setDocView:matrix] free];
   [matrix sizeToSuperviewWidth];

   return self;
}

- setTarget:theTarget action:(SEL) theAction
{
   id matrix = [self docView];
   
   if ([matrix isKindOf:[Matrix class]] == NO)
      return self;
   
   [[matrix setTarget:theTarget] setAction:theAction];

   return self;
}

- setTarget:theTarget setDoubleAction:(SEL) theAction
{
   id matrix = [self docView];
   
   if ([matrix isKindOf:[Matrix class]] == NO)
      return self;
   
   [[matrix setTarget:theTarget] setDoubleAction:theAction];

   return self;
}

- removeSelectedName
{
   id matrix = [self docView];

   if (! ([matrix isKindOf:[Matrix class]] == YES && [matrix selectedCell]))
       return self;

   [matrix removeRowAt:[matrix selectedRow] andFree:YES];
   [matrix sizeToSuperviewWidth];
   [matrix display];
   
   return self;
}

- (const char *) selectedName
{
   id matrix = [self docView];

   if ([matrix isKindOf:[Matrix class]] == NO) return NULL;

   return [[matrix selectedCell] stringValue];
}

- insertName:(const char *) name alphaOrder:(BOOL) aFlag select:(BOOL) sFlag
{
   int matrixRows, matrixCols;
   id matrix = [self docView];
   
   if (! (name && [matrix isKindOf:[Matrix class]] == YES))
      return self;
   
   [matrix addRow];
   [matrix getNumRows:&matrixRows numCols:&matrixCols];
   [[matrix cellAt:matrixRows-1:matrixCols-1] setStringValue:name];

   if (sFlag == YES)
      [matrix selectCellAt:matrixRows-1 :matrixCols-1];

   [matrix sizeToSuperviewWidth];
   [matrix display];

   return self;
}

- replaceSelectedNameWith:(const char *) newName
{
   id matrix = [self docView];

   if (! (newName && [matrix isKindOf:[Matrix class]] == YES
	  && [matrix selectedCell]))
      return self;

   [[matrix selectedCell] setStringValue:newName];
   [[matrix selectedCell] setLeaf:NO];
   
   [matrix display];
   
   return self;
}

- selectName:(const char *) name
{
   int matrixRow, matrixCol;
   const char *cellName;
   id matrix = [self docView];
   
   if (! (name && [matrix isKindOf:[Matrix class]] == YES))
      return self;

   [matrix getNumRows:&matrixRow numCols:&matrixCol];
   
   for (matrixRow--; matrixRow >= 0; matrixRow--) {
      cellName = [[matrix cellAt:matrixRow :0] stringValue];
      if (cellName && strcmp (cellName, name) == 0) {
	 [matrix selectCellAt:matrixRow :0];
	 break;
      }
   }
   
   return self;
}

- selectRow:(int) row
{
   if ([[self docView] isKindOf:[Matrix class]] == NO)
      return self;
   
   return [[self docView] selectCellAt:row :0];
}

- (int) selectedRow
{
   if ([[self docView] isKindOf:[Matrix class]] == NO)
      return -1;

   return [[self docView] selectedRow];
}

- free
{
   [[self docView] free];
   [super free];
   return self;
}

@end
