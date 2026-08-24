#include "comment.header"

/* $Id: ClickCell.m,v 1.4 1997/11/04 16:49:53 ergo Exp $ */

/*
 * $Log: ClickCell.m,v $
 * Revision 1.4  1997/11/04 16:49:53  ergo
 * ported to OpenStep
 *
 * Revision 1.3  1997/07/06 19:37:56  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:56:51  ergo
 * added time control for moves
 *
 */

#import "ClickCell.h"
#import "GoApp.h"

#import <AppKit/NSText.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSApplication.h>

#import <stdio.h>

@implementation ClickCell

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)_untilMouseUp
{
    [NSApp cellClicked:self];

    return  YES;   
}    

- initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    [self setFont:[NSFont fontWithName:@"Helvetica" size:17]];
    [self setBackgroundColor:[NSColor lightGrayColor]];
    [self setBezeled:YES];
    [self setAlignment:NSLeftTextAlignment];
    return self;
}    
@end
