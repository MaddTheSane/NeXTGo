
#import "Controller.h"
#import "GoServer.h"

@implementation Controller

- init {

    id key;

    NSEnumerator *enumerator;

    [super init];

    myGoServers  = [[NSMutableDictionary dictionaryWithDictionary:[ [NSUserDefaults standardUserDefaults] dictionaryForKey:@"GoServers"] ] retain];

    enumerator = [myGoServers keyEnumerator];

    while ((key = [enumerator nextObject])) {
        id aGoServer = [myGoServers objectForKey:key];
        [myGoServers setObject:[ [ [ [GoServer alloc] init] initFromString:aGoServer] retain] forKey:key];
    }

    [myGoServers retain];
    
    return self;
}

- (void)awakeFromNib  {

    [GoServerSelectionList setDataSource:self];
    [GoServerSelectionList setDelegate:self];
    [GoServerSelectionList sizeLastColumnToFit];

    [GoServerSelectionList setDoubleAction:@selector(connectToServer:)];

}

- openGoServer:sender  {
    [GoServerSelectionPanel makeKeyAndOrderFront:self];
    return self;
}

- connect:sender {
    NSString *key = [[NSString alloc] initWithFormat:@"%@%d",@"Server", [GoServerSelectionList selectedRow]];
    id server = [myGoServers objectForKey:key];
    [LoginDefinition setTitle:[server serverName]];
    [ServerLogin setStringValue:[server login]];
    [ServerPassword setStringValue:[server password]];
    [ServerPort setIntValue:[server port]];
    [ServerPort selectText:self];
	
    [LoginDefinition makeKeyAndOrderFront:self];

    return self;
}

- connectToServer:sender {
    NSString *key = [[NSString alloc] initWithFormat:@"%@%d",@"Server", [GoServerSelectionList selectedRow]];
    id server = [myGoServers objectForKey:key];
    if ([sender isMemberOfClass:[NSButton class]]) {
	[server setLogin:[ServerLogin stringValue] ];
	[server setPassword:[ServerPassword stringValue] ];
	[server setPort:[ServerPort intValue] ];
        [myGoServers setObject:server forKey:key];
    }
				/* sender is NSTableView   */
				/* so server is yet initialized */
    [GoServerSelectionPanel orderOut:self];
    [LoginDefinition orderOut:self];
    [GoApplication connect:server];
	
    return self;	
}

- remove:sender {
    id anObject;
    int i, numberOfGoServers;
    NSString *key;
    numberOfGoServers = [myGoServers count];
    key = [[NSString alloc] initWithFormat:@"%@%d",@"Server", [GoServerSelectionList selectedRow]];
    [myGoServers removeObjectForKey:key ];
    for (i = [GoServerSelectionList selectedRow]+1; i < numberOfGoServers;i++) {
        [key release];
        key = [[NSString alloc] initWithFormat:@"%@%d",@"Server", i];
        anObject = [myGoServers objectForKey:key];
        [myGoServers removeObjectForKey:key ];
        [key release];
        key = [[NSString alloc] initWithFormat:@"%@%d",@"Server", i-1];
        [myGoServers setObject:anObject forKey:key];
    }
    [GoServerSelectionList reloadData];
    [key release];
    return self;
}

- add:sender {
    NSString *key;
    id newServer;
    if (0 == [ [GoServerName stringValue] length]) {
        return self;
    }
    key = [[NSString alloc] initWithFormat:@"%@%d",@"Server", [myGoServers count]];
    newServer = [ [GoServer alloc] init];
    [newServer setServerName:[GoServerName stringValue] ];
    [GoServerName setStringValue:@""];

    [myGoServers setObject:newServer forKey:key];
    [GoServerSelectionList reloadData];
    return self;
}

/* NSTableView data source methods */

- (int)numberOfRowsInTableView:(NSTableView *)theTableView
{
    return [myGoServers count];
}

- (id)tableView:(NSTableView *)theTableView
      objectValueForTableColumn:(NSTableColumn *)theColumn
            row:(int)rowIndex
{
    NSString *key = [[NSString alloc] initWithFormat:@"%@%d",@"Server", rowIndex];
    if ([[theColumn identifier] intValue]==0) 
        // only the names should be displayed
        return [ [ [NSString stringWithString:[ [myGoServers objectForKey:key] login]] stringByAppendingString:@"@"] stringByAppendingString:[ [myGoServers objectForKey:key] serverName]];
    else
        return nil;
}
      
@end

@implementation Controller(ApplicationDelegate)

- (BOOL)applicationShouldTerminate:(id)sender {

    id key;
    id defaults = [NSUserDefaults standardUserDefaults];

    NSEnumerator *enumerator = [myGoServers keyEnumerator];

    while ((key = [enumerator nextObject])) {
        id aGoServer = [myGoServers objectForKey:key];
        [myGoServers setObject:[aGoServer dumpToString] forKey:key];
    }

    [defaults setObject:myGoServers forKey:@"GoServers"];

    [defaults synchronize];

    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [GoApplication applicationDidFinishLaunching:notification];
}

@end
