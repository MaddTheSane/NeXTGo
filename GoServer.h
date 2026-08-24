#ifndef GoServer_h
#define GoServer_h

#import <appkit/appkit.h>
#include <MiscString.h>

@interface GoServer:Object
{
	id	name;
	int	port;
	id	login;
	id	password;
}

- init;
- initFromPref:(int)i;
- saveToPref:(int)i;
- removeFromPref:(int)i;
- (const char*) name;
- (int) port;
- (const char*) login;
- (const char*) password;
- setServerName:(char *) aName;
- setPort:(int) aPort;
- setLogin:(char *) aLogin;
- setPassword:(char *) aPassword;
- free;

@end
 
#endif