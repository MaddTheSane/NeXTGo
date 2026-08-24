//
//	MiscString.m -- a generic class to simplify manipulation of (char *)'s
//		Written by Don Yacktman Copyright (c) 1993 by Don Yacktman.
//				Version 1.95  All rights reserved.
//		This notice may not be removed from this source code.
//
//	This object is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"LICENSE.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//	

// This class is not specifically thread-safe.  If there is enough
// demand, we can easily enough produce a thread-safe subclass.
// Let us know what you'd like to see in the future!

//
//	And now for an implementation note... (philosophy of this class)
//	The object is to make a bulletproof class.  That means that NULL
//	pointers and values that are out of range are ignored, or that
//	nil is returned, or that the object tries to do what would be the
//	intelligent thing to do in such boundary cases.  Obviously, all
//	this error checking costs you something:  speed.  On the other hand,
//	your code shouldn't end up with anywhere near as many bus errors
//	and other silliness!  (This is not a panacea; don't rely on the
//	MiscString to get everything right for you; if a boundary condition
//	might exist, do be sure to check return values as they can signal
//	problems for you.)  There is no substitue for good programming,
//	but hopefully this class will help you survive silly mistakes.
//	Most of the methods send to other methods to do the real work;
//	it would run faster to implement each method separately, since
//	some methods would then not need to do certain checks, and so on.
//	On the other hand, it is a whole lot easier to maintain this code
//	since there are a handful of core methods that do all the work.
//	Someday I may attempt to make a MiscFastString class that will
//	be optimized for speed... but only if there is either (1) a *whole*
//	lot of demand for it, or (2) someone pays me to write it.  :-)
//
//	Returns:  I try to follow NeXT conventions.  Return self, nil, or
//		whatever makes sense in the context.  Hopefully your idea of
//		what makes sense will coincide with mine.  Read the docs...
//
//	For release (1.2), I have gone over every single method and
//		tried to make sure it behaved sanely on all possible boundary
//		cases, especially NULL pointers.  If there is any way to
//		break this class, or cause a bus error in here, etc. or any
//		other bugs I WANT to know about them... be sure to send bug
//		reports to me at Don_Yacktman@byu.edu so I can fix them.  I
//		want this class to be bulletproof.  Note that there are still
//		a few possibilities to get memory leaks here.  I want to fix
//		those, if at all possible, so remind me of the ones you find.
//		I got rid of the most obvious and common ones.
//
//	For release (1.3) I have added a few suggested methods, cleaned
//		up a few minor bugs that were discovered, and that's about
//		it.  Nothing earth-shattering, but it is better than 1.2.
//
//	For release (1.4) (Unreleased) Split into categories.
//
//	For release (1.5) Added compatability with the MOKit's MOString
//		so you can replace any instances of that class with this one
//		and folded in methods contributed by David Lehn and Carl
//		Lindberg.  Did some more testing.  Words, fields, etc. have
//		the first "thing" being #0.  This alters a few methods that
//		used to have NO field #0, with field #1 being the first.
//		It is hoped that this won't break too many folks' code.  In
//		most cases, it shouldn't, but there will be a few.  Sorry!
//
//	For release (1.6) Misc. bug fixes and tweaks.
//
//	For release (1.7) More bug fixes, tweaks, and a pile of new methods.
//
//	One memory leak possibility, and this happens in the test app a
//	little bit:  you call a method that returns a new object, but
//	then do something like this:
//		printf("%s", [[aString right:5] stringValue]);
//	A new instance is created, but never freed.  I have attempted to
//	solve the problem with a -stringValueAndFree method.  Basically,
//	there is now a global scratch MiscString that is never freed which
//	holds the value.  Note that there is only one of these, so that
//	means it is not at all thread-safe and you should set up, say, a
//	lock on the _entire_ string class if you're gonna muck with it.
//	(I don't really know how much of an issue this really is, but I
//	figure you ought to be warned.)  If this is a problem, the best
//  workaround is to make the scratch string an instance variable so
//  that it is on a per string basis, and then have the string class
//  itself lock it.  The current global variable solution uses far less
//  storage space and is only a problem in multi-threaded situations.
//	If you don't trust my method, as an alternative there is this:
//		temp = [aString right:5];
//		printf("%s", [temp stringValue]);
//		[temp free];
//	But that's a pain in the *ss...even if it removes the leaks.
//	If you have any better ideas, let me know.
// Thanks to dlehn@ARPA.MIL (David Lehn) for suggesting one way to get a
// -stringValueAndFree method.  It's so obvious once you see it...
//
//	Note that if you can count on the appkit being there (which we cannot)
//	you could use the appkit's object extension for delaying method calls,
//	and just have a delayed free.
//

#import <misckit/MiscString.h>
#import <strings.h>
#import <objc/objc-runtime.h>

// this is a kludge to allow you to do a "delayed free"...actually,
// rather than leaking lots of MiscStrings, we have one string that
// is used as a scratch place for all strings, and we always have
// a pointer to it.  That makes it a non-memory leak. :-)
static id theKludgeString = nil; // used by all MiscString instances,
		// meaning that this variable is NOT thread-safe!  Beware!!!

#define MISC_STRING_VERSION 1	// This version is used for archiving
	// MiscStrings.  If we ever add instance vars, we'll need to bump
	// it up.  Until then, we can leave it at 1.

#define MISCSTRING_MIN_BUFFER_SIZE 15 // all strings start with a buffer
	// at least this big, so that NULL pointers aren't ever returned
	// from -stringValue, etc.  This number should be a malloc good size - 1.

#define CLASS_NAME "MiscString"
@interface MiscString(private)

// private methods: do not mess with these!
- _unhookBuffer;

@end

char *MiscBuildStringFromFormatV(const char *formatStr, va_list param_list)
// This function takes a format string and a variable argument list.
// It returns a pointer to a newly allocated chunk of memory containing 
// the results of sprintf'ing the format string and va_list into the 
// new memory.
{
	NXStream *stream;
	long l;
	char *buf;

	stream = NXOpenMemory(NULL, 0, NX_READWRITE);
	NXVPrintf(stream, formatStr, param_list);
	NXFlush(stream);
	NXSeek(stream, 0, NX_FROMEND);
	l = NXTell(stream);
	NXSeek(stream, 0, NX_FROMSTART);
	NX_MALLOC(buf, char, l+1);
	NXRead(stream, buf, l);
	buf[l]='\0';
	NXCloseMemory(stream, NX_FREEBUFFER);
	return buf;
}

@implementation MiscString

// These are the core methods for memory management and basic instance
// variable querying/setting.

+ initialize	// make sure the -stringValueAndFree stuff is set up
{
	if (self == objc_lookUpClass(CLASS_NAME)) {
		if (!theKludgeString) {
			theKludgeString = [[MiscString alloc] init];
		}
		[MiscString setVersion:MISC_STRING_VERSION];
	}
	return self;
}

+ new
{
	return [[self alloc] init];
}

+ newWithString:(const char *)aString
// I just got tired of typing [[[MiscString alloc] init] setStringValue:xxx] 
{
	id newString = [[self alloc] init]; // self is a Class object, remember.
	if ([newString setStringValue:aString]) return newString;
	[newString free];
	return nil;
}

- new
{
	return [[[self class] alloc] init];
}

- init
{
	 [super init];
	 [self setStringOrderTable:NXDefaultStringOrderTable()];
	 if (buffer) free(buffer);
	 buffer = NULL;
	 length = 0;
	 _length = 0;
	 // This is a bit inefficient to do, but removes yet another
	 // chance for things to blow up; you could safely remove it
	 // if you need faster initializing and better memory usage.
	 [self allocateBuffer:MISCSTRING_MIN_BUFFER_SIZE fromZone:[self zone]];
	 return self;
}

- initCapacity:(int)capacity
{
	return [self initCapacity:capacity fromZone:[self zone]];
}

- initCapacity:(int)capacity fromZone:(NXZone *)zone
{
	[self init];
	[self allocateBuffer:capacity fromZone:zone];
	return self;
}

- initString:(const char *)aString
{
	[self init];
	return [self setStringValue:aString];
}

- initFromFormat:(const char *)formatStr, ...
// Initializes the string from printf style format string and arguments.
{
	va_list param_list;
	char *buf;

	va_start(param_list, formatStr);
	buf = MiscBuildStringFromFormatV(formatStr, param_list);
	va_end(param_list);
	[self initString:buf];
	NX_FREE(buf);
	return self;
}

- allocateBuffer:(int)size
{
	return [self allocateBuffer:size fromZone:[self zone]];
}

- allocateBuffer:(int)size fromZone:(NXZone *)zone
{	// This is the only method that should be allowed to alter the
	// _length instance variable.  That variable is used to track the
	// amount of memory allocated in the buffer, and this method and
	// freeString are the only ones that change that.  If you muck with
	// it yourself, you will make the class less efficient, create a
	// memory leak, or create crash possibilities.  So leave it alone!!!
	
	if (size <= _length) return self; // return if buffer is already big enough
	
	// if not big enough, free the old buffer and then create a new buffer
	// of the right size.  Since the buffer is to be empty anyway, there's
	// no point in calling realloc, and so this is just fine.
	[self freeString];
	if (!size) return self;
	_length = size + 1; // just in case somebody forgot to take
		// terminators into account, we'll make sure there is space.
		// Note that if they did take it into account, we'll waste a
		// little bit of space, but that's the price of stability...
	buffer = (char *)NXZoneMalloc(zone, _length);
	buffer[0] = '\0'; // terminator at zero for zero length string
	buffer[size] = '\0';	// make 100% sure we'll be terminated
	return self;
}

- copyFromZone:(NXZone *)zone
{
	MiscString *myCopy = [super copyFromZone:zone];
	// force child to have it's own copy of the string buffer
	[myCopy _unhookBuffer];  // see below
	[myCopy allocateBuffer:_length fromZone:zone]; // make a new buffer
	[myCopy setStringValue:buffer fromZone:zone];  // and copy the string to it
	return myCopy;
}

- (char *)getCopyInto:(char *)buf
{
	if (!buf) {
		NX_MALLOC(buf, char, length + 1);
	}
	strcpy(buf, buffer);
	return buf;
}

- _unhookBuffer
{ // used by the copy method so that we don't free the buffer from orig.
	// If you call this method without knowing what you're doing,
	// you will very likely create a memory leak; that's why it's got
	// the underbar and is considered private, and is undocumented.
	// I do it 'cos it solves a problem I couldn't solve any other way;
	// see the -copyFromZone: method...
	buffer = NULL; _length = 0;
	return self;
}

- freeString
{	// Empty out the buffer, throw it away, and then we're zero length.
	if (buffer) free(buffer);
	buffer = NULL;
	length = 0;
	_length = 0;
	return self;
}

- free
{
	 [self freeString];
	 return [super free];
}

- (BOOL)emptyString
{
	return ((length > 0) ? NO : YES);
}

- (char)charAt:(int)index
{
	if ((index < 0) || (index > length - 1)) return '\0';
	return (char)buffer[index];
}

- (int)numOfChar:(char)aChar caseSensitive:(BOOL)sense
{
	int i, count = 0;

	if (sense) {
		for (i=0; i<length; i++)
			if (buffer[i] == aChar) count++;
	} else {
		for (i=0; i<length; i++)
			if (NXToUpper(buffer[i]) == NXToUpper(aChar)) count++;
	}
	return count;
}

- (int)numOfChar:(char)aChar
{
	return [self numOfChar:aChar caseSensitive:YES];
}

- (int)numOfChars:(const char *)aString caseSensitive:(BOOL)sense
{
	int i, count = 0;
	id tempStr;

	if (!aString) return 0;
	tempStr = [MiscString newWithString:aString];
	for (i=0; i<length; i++)
		if ([tempStr spotOf:buffer[i] caseSensitive:sense] != -1) count++;
	[tempStr free];
	return count;
}

- (int)numOfChars:(const char *)aString
{
	return [self numOfChars:aString caseSensitive:YES];
}

- (int)length
{
	return length;
}

- (unsigned)capacity
{
	return (unsigned)_length;
}

- setCapacity:(unsigned)newCapacity
{
	char *tempBuffer = NXCopyStringBufferFromZone(buffer, [self zone]);
	if (!tempBuffer) return nil; // something went wrong!
	[self allocateBuffer:newCapacity fromZone:[self zone]];
	[self setStringValue:tempBuffer fromZone:[self zone]];
	free(tempBuffer);
	return self;
}

- fixStringLength // realloce buffer space; this will trim off any extra space
{
	char *tempBuffer = NXCopyStringBufferFromZone(buffer, [self zone]);
	if (!tempBuffer) return nil; // something went wrong!
	[self freeString];
	buffer = tempBuffer;
	length = strlen(buffer);
	_length = length + 1;
	return self;
}

- fixStringLengthAt:(unsigned)index
{ // truncates the string to a certain length.
	if (!buffer) return self;
	if (_length <= index) return self;
	buffer[index] = '\0';
	length = index;
	[self fixStringLength];
	return(self);
}


- setStringOrderTable:(NXStringOrderTable *)table
{
	if (table) orderTable = table;
	else orderTable = NXDefaultStringOrderTable(); // just in case...
	return self;
}

- (NXStringOrderTable *)stringOrderTable
{
	return orderTable;
}

- (const char *)stringValue
{
	return buffer;
}

- (NXAtom)uniqueStringValue
{
	return NXUniqueString(buffer);
}

- (const char *)stringValueAndFree
{	// you could use this as a model to build other ...AndFree methods,
	// but this is by far the most useful one.
	if (!buffer) [theKludgeString setStringValue:"" fromZone:[self zone]];
	else [theKludgeString setStringValue:buffer fromZone:[self zone]];
	[self free];
	return [theKludgeString stringValue];
}

- (int)intValue
// Returns the string converted to an int.
{
	if (!buffer) return 0;
	return atoi(buffer);
}

- (float)floatValue
// Returns the string converted to an float.
{
	if (!buffer) return 0.0;
	return (float)atof(buffer);
}

- (double)doubleValue
// Returns the string converted to an double.
{
	if (!buffer) return 0.0;
	return atof(buffer);
}

- kitchenSink
{	// OK, Carl, here it is.  Read it and weep.  Heheheh.
	// You're probably the only one who will notice this in here.  :-)
	return [[self class] newWithString:"Kitchen Sink"];
}	// Yes, you've found the easter egg.  Sorry, I guess it's too late
	// at night.  Better get some sleep...

- (size_t)recalcLength
{
	if (buffer) length = strlen(buffer);
	else length = 0;
	return length;
}

@end

// interesting ideas:  These will have to wait for a future release...

// extract	- add some extract... type methods that have methods such as:
//     - extract:firstDelimiter :lastDelimiter
// This would be great so that a parenthesized string could be examined
// "functionA(firstParam,secondParam);"   lets you take out the
// "firstParam,secondParam".
// Bad example, but you get the idea.
// Maybe add a delimiterList string so that you can set which characters
// (strings??) will break up a string.

// fieldCount	- a method to return the number of fields delimited by
// multiple delimiters
// ex.  the number of field surrounded by parentheses.

// Two important points:  (1) There should be different start/end delimiters
// (2) you have to balance them, like prens, so it would need to be a PDA.
// Of course, if we are making a full blown PDA to do this we may as well
// just do a proper lexical analyzer and be done with it.  Perhaps we could
// build a subclass that is an interpreted version of lex(1)...
