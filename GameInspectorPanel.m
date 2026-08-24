
#import "GameInspectorPanel.h"
#import "GoApp.h"

@implementation GameInspectorPanel

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
