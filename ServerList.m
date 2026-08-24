
#import "ServerList.h"
#include "GoServer.h"

@implementation List(ServerList)

- initFromPref {
	int i;

	for (i=0; [self addObject:[ [GoServer alloc] initFromPref:i]]; i++); 
	return self;	
}

- saveToPref {
	int i;
/* How many servers did we know before ? */
	
	id tempServerList = [ [ [List alloc] init] initFromPref];
	int oldNumberOfServers =  [tempServerList  count];
	
/* save the actual list */
	
	for (i=0; i<=[self count]; i++) {
		id server = [self objectAt:i];
		if ([server respondsTo:@selector(saveToPref:)])
			[server saveToPref:i];
	} 

/* if the number of servers decreased, delete the remaining servers */ 
	
	if ([self count] < oldNumberOfServers) {
		for (i=[self count]; i<=oldNumberOfServers; i++) {
			id server = [tempServerList objectAt:i];
			if ([server respondsTo:@selector(removeFromPref:)])
				[server removeFromPref:i];
		}
	} 
	[ [tempServerList freeObjects] free];
			
	return self;
}

@end
