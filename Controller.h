
#import <AppKit/AppKit.h>

#import "GoServer.h"

@interface Controller:NSObject
{
    id	GoApplication;
    NSMutableDictionary *myGoServers;
    id	GoServerSelectionList;
    id	GoServerSelectionPanel;
    id	GoServerName;
    id	LoginDefinition;
    id	ServerLogin;
    id	ServerPassword;
    id	ServerPort;
}

- init;
- openGoServer:sender;
- connect:sender;
- connectToServer:sender;
- remove:sender;
- add:sender;

@end
