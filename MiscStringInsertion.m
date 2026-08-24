//
//	MiscStringInsertion.m
//		Written by Don Yacktman Copyright (c) 1993 by Don Yacktman.
//				Version 1.95  All rights reserved.
//		This notice may not be removed from this source code.
//
//	This object is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"LICENSE.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//	

#import <misckit/MiscString.h>

@implementation MiscString(Insertion)

// This category is composed of methods which insert characters or
// strings into a MiscString.

- cat:(const char *)aString
{
	if (!aString) return nil; // so strlen() stays sane.  Thanks Steve Hayman!
	return [self cat:aString n:strlen(aString) fromZone:[self zone]];
}

- cat:(const char *)aString n:(int)n
{
	return [self cat:aString n:n fromZone:[self zone]];
}

- cat:(const char *)aString fromZone:(NXZone *)zone
{
	if (!aString) return nil; // so strlen() stays sane.  Thanks Steve Hayman!
	return [self cat:aString n:strlen(aString) fromZone:zone];
}

- cat:(const char *)aString n:(int)n fromZone:(NXZone *)zone
{
	char *newBuffer; int newSize;
	if (!(aString || buffer)) return nil;
	if (!buffer) { // Not very efficient, but safer.
		char *tempBuffer = (char *)NXZoneMalloc(zone, n+1);
		if (!tempBuffer) return nil;
		strncpy(tempBuffer, aString, n);
		tempBuffer[n] = '\0';
		[self setStringValue:tempBuffer fromZone:zone];
		free(tempBuffer);
		return self;
	}
	if (!aString) return self;
	if (n > strlen(aString)) n = strlen(aString);
	newSize = length + n + 1;
	if (newSize > _length) {
		newBuffer = (char *)NXZoneMalloc(zone, newSize);
		_length = newSize;
		newBuffer[0] = '\0';
		strcat(newBuffer, buffer);
		strncat(newBuffer, aString, n);
		free(buffer);
		buffer = newBuffer;
	} else  strncat(buffer, aString, n);
	length = strlen(buffer);
	return self;
}

- concatenate:sender
{ // note return self here; assume that there's nothing to add...
	if (![sender respondsTo:@selector(stringValue)]) return self;
	return [self cat:[sender stringValue]
				 n:strlen([sender stringValue])
				 fromZone:[self zone]];
}

- concatenate:sender n:(int)n
{
	if (![sender respondsTo:@selector(stringValue)]) return self;
	return [self cat:[sender stringValue] n:n fromZone:[self zone]];
}

- concatenate:sender fromZone:(NXZone *)zone
{
	if (![sender respondsTo:@selector(stringValue)]) return self;
	return [self cat:[sender stringValue]
			n:strlen([sender stringValue]) fromZone:zone];
}

- concatenate:sender n:(int)n fromZone:(NXZone *)zone
{
	if (![sender respondsTo:@selector(stringValue)]) return self;
	return [self cat:[sender stringValue] n:n fromZone:zone];
}

- insert:(const char *)aString at:(int)index
// inserts given string into buffer starting at index.
// (the first character is position #0)
{
	id temp1;
	id temp2;

	if ((aString == NULL) || (strlen(aString)<=0)) return self;
	if (index < 0) index = 0;         
	if (index >= length) return [self cat:aString];

	temp1 = [self left:index];
	if (!temp1) temp1 = [[[self class] alloc] init];
	temp2 = [self right:length-index];  
	[[temp1 cat:aString] concatenate:temp2];
	[self setStringValue:[temp1 stringValue]];

	[temp1 free];
	[temp2 free];
	return self;
}

- insertString:(id)sender at:(int)index
// cover for insert:at: for a String object
{
	if (![sender respondsTo:@selector(stringValue)]) return self;
	return [self insert:[sender stringValue] at:index];
}

- insertChar:(char)aChar at:(int)index
{
	id tempStr;
	id retval;

	if (aChar == 0) return self;	// or should this return nil? DAY: leave it

	tempStr = [[[[[self class] alloc] init] allocateBuffer:2] addChar:aChar];
	retval = [self insert:[tempStr stringValue] at:index];
	[tempStr free];
	return retval;
}

- insertChar:(char)aChar	// does an insert at the front (for chars)
{ // added for convenience; as you see it is redundant.
	return [self insertChar:aChar at:0];
}

// catStrings:	- a convenience function to append a list of strings
//				to a string object.
//	use like this:
//		[aString addStrings:string0, string1, string2, string3, string4, NULL];
//	make sure to have the ending NULL!
//
// Note from Don:  I've decided to use a version sent in by David Moffett
//		since it is a bit more concise.

- catStrings:  ( const char *) strings,  ...;
{
	const char *aString;
	va_list ptr;
  
	va_start( ptr, strings );
	aString = strings;
	while (aString) {
		[self cat:aString n:strlen(aString) fromZone:[self zone]];
		aString = va_arg(ptr, char *);
	}
	va_end( ptr );       
	return self;
}

// and here's one modified to handle MiscStrings -- don
- concatenateStrings:(id)strings,  ...
{
	id aString;
	va_list ptr;
  
	va_start(ptr, strings);
	aString = strings;
	while (aString) {
		if ([aString respondsTo:@selector(stringValue)]) {
			const char *sptr = [aString stringValue];
			[self cat:sptr
					n:([aString respondsTo:@selector(length)] ?
							[aString length] : strlen(sptr))
					fromZone:[self zone]];
		}
		aString = va_arg(ptr, id);
	}
	va_end( ptr );       
	return self;
}

- insert:(const char *)aString	// does an insert at the front (for char *'s)
{ // added for convenience; as you see it is redundant.
	return [self insert:aString at:0];
}

- insertString:aString	// does an insert at the front (for objects)
{ // added for convenience; as you see it is redundant.
	return [self insertString:aString at:0];
}

- addChar:(char)aChar
{
  if (aChar) [self cat:&aChar n:1];
  return self;
}


// The following methods are from the MOString by Mike Ferris:

- insertFromFormat:(const char *)format, ...
// Prepends the given format string after formatting before the contents
// of the receiver.
{
	va_list param_list;
	
	va_start(param_list, format);
	[self insertAt:0 fromFormat:format, param_list];
	va_end(param_list);
	return self;
}

- insertAt:(int)index fromFormat:(const char *)format, ...
{
	char *buf;
	va_list param_list;
	
	va_start(param_list, format);
	buf = MiscBuildStringFromFormatV(format, param_list);
	[self insert:buf at:index];
	NX_FREE(buf);
	va_end(param_list);
	return self;
}

- catFromFormat:(const char *)format, ...
// Appends to the string from the printf style format string and arguments.
{
	char *buf;
	va_list param_list;

	va_start(param_list, format);
	buf = MiscBuildStringFromFormatV(format, param_list);
	[self cat:buf];
	NX_FREE(buf);
	va_end(param_list);
	return self;
}

// Here's an alternative way to catFromFormat, courtesy of Steve Hayman.
// For now, we're keeping everything in the MiscBuildStringFromFormatV
// function for simplicity.
/* This method is currently commented out and not compiled.
- printf:(const char *)fmt, ...
{
    NXStream *mem;
    char *streambuf;
    int len, maxlen;
    va_list  ap;

    va_start(ap, fmt);
    
    // open a memory stream ...
    mem = NXOpenMemory( NULL, 0, NX_WRITEONLY );
    
    // printf everything to the memory stream ...
    NXVPrintf( mem, fmt, ap );
    // and make sure it's null terminated
    NXPutc( mem, '\0' );
    // and get pointers to the buffer where the stream is ...
    NXGetMemoryBuffer( mem, &streambuf, &len, &maxlen );
    
    // and append the text to ourself
    [self cat:streambuf];
    
    // and free the memory stream.
	NXCloseMemory(mem, NX_FREEBUFFER);
    va_end(ap);

    return self;
}
*/
@end
