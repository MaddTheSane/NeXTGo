
#import "GoWindow.h"
#import "GoApp.h"

@implementation GoWindow

- keyDown:(NXEvent *)theEvent {
	if([ControlPanel isVisible]) {
		[ControlPanel makeKeyAndOrderFront:self];
		[ControlPanel sendEvent:theEvent];
		[NXApp setCommandSender:self];
		return self;
	}
	else 
		return [super keyDown:theEvent];
}

@end
