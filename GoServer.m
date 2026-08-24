
#import "GoServer.h"

@implementation GoServer

- init
{
	name = [ [MiscString alloc] init];
	port = 0;
	login = [ [MiscString alloc] init];
	password = [ [MiscString alloc] init];
	return self;
}

- initFromString:(id)aString {

	id buf = [ [MiscString alloc] init];
	
	if (name) {
		[name free];
		name = 0;
	}
	name = [aString extractPart:MISC_STRING_FIRST useAsDelimiter:' '];

	buf = [aString extractPart:MISC_STRING_FIRST+1 useAsDelimiter:' '];
	sscanf([buf stringValue], "%d", &port);
	
	if (login) {
		[login free];
		login = 0;
	}
	login = [aString extractPart:MISC_STRING_FIRST+2 useAsDelimiter:' '];
	
	if (password) {
		[password free];
		password = 0;
	}
	password = [aString extractPart:MISC_STRING_FIRST+3 useAsDelimiter:' '];
	
	return self;
}

- (id)dumpToString:(id) aStringObject {
	char buf[256];
 	[aStringObject setStringValue:[name stringValue]];
	sprintf(buf, " %d ", port);
	[aStringObject cat:buf];
	[aStringObject concatenate:login];
	[aStringObject cat:" "];
	[aStringObject concatenate:password];
	return aStringObject;
}

- initFromPref:(int)i{

	char buf[256] = "Server";
	id buffer = [MiscString alloc];

	sprintf(buf+6, "%d", i);
	[buffer initString: NXGetDefaultValue("NeXTGo",buf)];
	if ([buffer emptyString]) 
		return nil;
	[self initFromString:buffer];
	return self;
}

- saveToPref:(int)i {
	char buf[256] = "Server";
	id buffer = [ [MiscString alloc] init];

	sprintf(buf+6, "%d", i);
	[self dumpToString:buffer];
	NXWriteDefault("NeXTGo", buf, [buffer stringValue]);
	return self;
}

- removeFromPref:(int)i {

	char buf[256] = "Server";

	sprintf(buf+6, "%d", i);
	NXRemoveDefault("NeXTGo", buf);

	return self;
}

- (const char*) name
{
	return [name stringValue];
}

- (int) port
{
	return port;
}

- (const char*) login
{
	return [login stringValue];
}

- (const char*) password
{
	return [password stringValue];
}

- setServerName:(char *) aName
{
	[name setStringValue:aName];
	return self;
}

- setPort:(int) aPort
{
	port = aPort;
	return self;
}

- setLogin:(char *) aLogin
{
	[login setStringValue:aLogin];
	return self;
}

- setPassword:(char *) aPassword
{
	[password setStringValue:aPassword];
	return self;
}

- free {
	[name free];
	[login free];
	[password free];	
	return [super free];
}



@end
