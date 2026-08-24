
#import <appkit/appkit.h>

#import "GoServer.h"
#import "MatrixScrollView.h"

@interface Controller:Object
{
    id	GoApplication;
	id	myGoServerList;
    id	GoServerSelectionList;
    id	GoServerSelectionPanel;
	id	GoServerName;
    id	LoginDefinition;
    id	ServerLogin;
    id	ServerPassword;
    id	ServerPort;
	BOOL panelIsInitialized;
}

- init;
- initPanel;
- openGoServer:sender;
- connect:sender;
- connectToServer:sender;
- remove:sender;
- add:sender;

@end
