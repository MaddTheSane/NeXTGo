
#import "Controller.h"
#include "ServerList.h"
#include "MiscString.h"

@implementation Controller

- init 
{
	[super init];
	
	panelIsInitialized = FALSE;
	
	myGoServerList = [ [ [List alloc] init] initFromPref]; 
	return self;
}

- initPanel {
	int i;
	
	if (!panelIsInitialized) {
		[GoServerSelectionList setTarget:self setDoubleAction:@selector(connectToServer:)];

		for (i=0; i < [myGoServerList count]; i++) {
			id aGoServer = [myGoServerList objectAt:i];
			[GoServerSelectionList	insertName:[aGoServer name] alphaOrder:NO select:NO];
		}
		[GoServerSelectionList selectRow:0]; 
	
		panelIsInitialized = TRUE;	
	}
	
	return self;
}

- openGoServer:sender  {
	[GoServerSelectionPanel makeKeyAndOrderFront:self];
	return self;
}

- connect:sender {
	id server = [myGoServerList objectAt:[GoServerSelectionList selectedRow] ];

	[LoginDefinition setTitle:[server name]];
	[ServerLogin setStringValue:[server login] ];
	[ServerPassword setStringValue:[server password] ];
	[ServerPort setIntValue:[server port] ];
	[ServerPort	selectText:self];
	
	[LoginDefinition makeKeyAndOrderFront:self];

	return self;
}

- connectToServer:sender {
	id server = [myGoServerList objectAt:[GoServerSelectionList selectedRow] ];
	
	if ([sender isMemberOf:[Button class] ]) {
		[server setLogin:(char*)[ServerLogin stringValue] ];
		[server setPassword:(char*)[ServerPassword stringValue] ];
		[server setPort:[ServerPort intValue] ];
	}
				/* sender is MatrixScrollView   */
				/* so server is yet initialized */
	[GoServerSelectionPanel orderOut:self]; 
	[LoginDefinition orderOut:self]; 
	[GoApplication connect:server];
	
	return self;	
}

- remove:sender {
	[myGoServerList removeObjectAt:[GoServerSelectionList selectedRow] ];
	[GoServerSelectionList removeSelectedName];	
	return self;
}

- add:sender {
	id newServer = [ [GoServer alloc] init];
	[newServer setServerName:(char*) [GoServerName stringValue] ];
	[GoServerSelectionList	insertName:[newServer name] alphaOrder:NO select:YES];
	[myGoServerList addObject:newServer];	
	return self;
}

@end

@implementation Controller(ApplicationDelegate)

- appWillTerminate:sender {
	[ [ [myGoServerList saveToPref] freeObjects] free];
	return self;
}

@end
