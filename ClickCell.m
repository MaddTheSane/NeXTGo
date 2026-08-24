#include "comment.header"

/* $Id: ClickCell.m,v 1.3 1997/07/06 19:37:56 ergo Exp $ */

/*
 * $Log: ClickCell.m,v $
 * Revision 1.3  1997/07/06 19:37:56  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:56:51  ergo
 * added time control for moves
 *
 */

#import "ClickCell.h"
#import "GoApp.h"

#import <appkit/Text.h>
#import <appkit/Font.h>
#import <appkit/Window.h>
#import <appkit/Application.h>

#import <stdio.h>

@implementation ClickCell

-(BOOL) trackMouse:(NXEvent *)theEvent inRect:(const NXRect *)cellFrame ofView:controlView
{
    [NXApp cellClicked:self];

    return  YES;   
}    

- initTextCell:(const char *)aString
{
    self = [super initTextCell:aString];
    [self setFont:[Font newFont:"Helvetica" size:17]];
    [self setBackgroundGray:NX_LTGRAY];
    [self setBezeled:YES];
    [self setAlignment:NX_LEFTALIGNED];
    return self;
}    
@end
