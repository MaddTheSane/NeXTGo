/*---------------------------------------------------------------------------
MatrixScrollView.h -- single column selection matrix within a scroll view

Copyright (c) 1990 Doug Brenner

$Source: /usr/local/lib/cvs/Repository/NeXTGo/MatrixScrollView.h,v $ $Revision: 1.2 $
---------------------------------------------------------------------------*/

#import <appkit/ScrollView.h>

@interface MatrixScrollView:ScrollView
{
}

/* ---------- Creating and Freeing */

+ newFrame:(const NXRect *) frameRect;
- free;

/* ---------- Target and Action */

- setTarget:theTarget action:(SEL) theAction;
- setTarget:theTarget setDoubleAction:(SEL) theAction;

/* ---------- Working with Cell Names */

- removeSelectedName;
- replaceSelectedNameWith:(const char *) newName;
- insertName:(const char *) name alphaOrder:(BOOL) aFlag select:(BOOL) sFlag;
- selectName:(const char *) name;
- (const char *) selectedName;

/* ---------- Working with Matrix Rows */

- selectRow:(int) row;
- (int) selectedRow;

@end
