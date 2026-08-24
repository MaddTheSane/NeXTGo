
#import "GameInspectorPanel.h"
#import "GoApp.h"

@implementation GameInspectorPanel

- (void)keyDown:(NSEvent *)theEvent  {
	if([ControlPanel isVisible]) {
		[ControlPanel makeKeyAndOrderFront:self];
		[ControlPanel sendEvent:theEvent];
		[NSApp setCommandSender:self];
		return;
	}
	else 
		[super keyDown:theEvent];
}


@end
