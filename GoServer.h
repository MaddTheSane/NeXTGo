#ifndef GoServer_h
#define GoServer_h

#import <AppKit/AppKit.h>

@interface GoServer:NSObject
{
	NSString	*name;
	int	port;
        NSString	*login;
        NSString	*password;
}

+ (GoServer*)initFromPref:(int)i;
- init;
//- (void)saveToPref:(int)i;
//- (void)removeFromPref:(int)i;
- (NSString *)serverName;
- (int) port;
- (NSString*) login;
- (NSString*) password;
- setServerName:(NSString *) aName;
- setPort:(int) aPort;
- setLogin:(NSString *) aLogin;
- setPassword:(NSString *) aPassword;
- (void)dealloc;
- (GoServer*)initFromString:(NSString*)aString; 
- (NSString*)dumpToString;

@end
 
#endif