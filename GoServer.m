
#import "GoServer.h"

@implementation GoServer

+ (GoServer*)initFromPref:(int)i {
    NSString *buf = [[NSString alloc] initWithFormat:@"%@%d",@"Server", i];
    return [ [NSUserDefaults standardUserDefaults] objectForKey:buf] ;
}

- init {
	name = [ [NSString alloc] init];
	port = 0;
	login = [ [NSString alloc] init];
	password = [ [NSString alloc] init];
	return self;
}

- (GoServer*)initFromString:(NSString*)aString {

    NSString *buf;
    NSArray *listItems = [aString componentsSeparatedByString:@" "];

    if (name) {
        [name release];
        name = 0;
    }
    name = [ [listItems objectAtIndex:0] retain];

    buf = [listItems objectAtIndex:1];
    sscanf([buf cString], "%d", &port);

    if (login) {
        [login release];
        login = 0;
    }
    login = [ [listItems objectAtIndex:2] retain];

    if (password) {
        [password release];
        password = 0;
    }
    password = [ [listItems objectAtIndex:3] retain];

    return self;
}

- (NSString*)dumpToString {
    id portbuf = [ [NSString localizedStringWithFormat:@"%d", port] retain];
    return [ [NSArray arrayWithObjects:name, portbuf, login, password, nil] componentsJoinedByString:@" "];
}
/*
- (void)saveToPref:(int)i {
    NSString *buf = [[NSString alloc] initWithFormat:@"%@%d",@"Server", i];
    [[NSUserDefaults standardUserDefaults] setObject:[self dumpToString] forKey:buf];
}

- (void)removeFromPref:(int)i {
    NSString *buf = [[NSString alloc] initWithFormat:@"%@%d",@"Server", i];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:buf];
}
*/
- (NSString *)serverName {
	return name;
}

- (int) port {
	return port;
}

- (NSString*) login {
	return login;
}

- (NSString*) password {
	return password;
}

- setServerName:(NSString *) aName {
    [name release];
    name = [ [NSString alloc]initWithString:aName];
    return self;
}

- setPort:(int) aPort {
	port = aPort;
	return self;
}

- setLogin:(NSString*) aLogin {
    [login release];
    login = [ [NSString alloc] initWithString:aLogin];
    return self;
}

- setPassword:(NSString *) aPassword {
    [password release];
    password = [ [NSString alloc] initWithString:aPassword];
    return self;
}

- (void)dealloc {
	[name release];
	[login release];
	[password release];	
	{ [super dealloc]; return; };
}



@end
