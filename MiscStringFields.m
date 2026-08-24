//
//	MiscStringFields.m
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

@implementation MiscString(Fields)

// This category is composed of methods which locate specific fields
// within a MiscString.  Mostly useful for various types of parsing.

- subStringRight:subString
{
	const char *sub, *sub2;
	if (!buffer) return nil;
	if ([subString respondsTo:@selector(stringValue)])
		sub = [subString stringValue];
	else return nil;	// error if can't get string value
	if (!sub) return nil;
	sub2 = strstr(buffer,sub);
	if (!sub2) return nil;
	return [[[self class] allocFromZone:[self zone]]
			initString:sub2];
}

- subStringLeft:subString
{
	const char *sub;
	char *sub2;
	int spot;

	if ([subString respondsTo:@selector(stringValue)])
		sub = [subString stringValue];
	else return nil;	// error if can't get string value
	if (!sub) return nil;
	if (!(sub2 = strstr(buffer, sub))) return nil;
	spot = (int)sub2 - (int)buffer - 1;
	if (spot < 0) return nil;
	return [self midFrom:0 to:spot];
}

- left:(int)count
{
	return [self left:count fromZone:[self zone]];
}

- right:(int)count
{
	return [self right:count fromZone:[self zone]];
}

- midFrom:(int)start to:(int)end
{
	return [self midFrom:start to:end fromZone:[self zone]];
}

- midFrom:(int)start length:(int)len
{
	return [self midFrom:start length:len fromZone:[self zone]];
}

- left:(int)count fromZone:(NXZone *)zone
{
	char smash = buffer[count];
	id newString;
	// perhaps I should return an empty MiscString here rather than nil?
	if ((count <= 0) || !buffer) return nil;
	if (count >= length) return [self copyFromZone:zone];
	newString = [[[self class] allocFromZone:zone] init];
	buffer[count] = '\0';
	[newString setStringValue:buffer fromZone:zone];
	buffer[count] = smash;
	return newString;
}

- right:(int)count fromZone:(NXZone *)zone
{
	id newString;
	// perhaps I should return an empty MiscString here rather than nil?
	if ((count <= 0) || !buffer) return nil;
	if (count >= length) return [self copyFromZone:zone];
	newString = [[[self class] allocFromZone:zone] init];
	[newString setStringValue:&buffer[length - count] fromZone:zone];
	return newString;
}

- midFrom:(int)start to:(int)end fromZone:(NXZone *)zone
{
	char smash;
	id newString;
	if (!buffer) return nil;
	if ((end < 0) || (start >= length)) return nil;
	if (end >= length) end = length - 1;
	if (start < 0) start = 0;
	newString = [[[self class] allocFromZone:zone] init];
	smash = buffer[end+1];
	buffer[end+1] = '\0'; // inclusive; end is not.
	[newString setStringValue:&buffer[start] fromZone:zone];
	buffer[end+1] = smash;
	return newString;
}

- midFrom:(int)start length:(int)len fromZone:(NXZone *)zone
{
	return [self midFrom:start to:(start + len - 1) fromZone:zone];
/*	faster to have our own code here, but rather than maintain this,
	we use the cover above.  I'm keeping the code around in case I
	decide to do MiscFastString.
	
	register int spot = start + len;
	char smash = buffer[spot];
	id newString;
	if (!buffer) return nil;
	if ((end < 0) || (start >= length)) return nil;
	if (start < 0) start = 0;
	if (start+len-1 >= length) len = length-start;
	newString = [[[self class] allocFromZone:zone] init];
	buffer[spot] = '\0';
	[newString setStringValue:&buffer[start] fromZone:zone];
	buffer[spot] = smash;
	return newString;
*/
}

- extractPart:(int)n useAsDelimiter:(char)c caseSensitive:(BOOL)sense fromZone:(NXZone *)zone
{	// code has to return an empty object if field is empty, but nil if
	// requested field # is > # of fields

	// What we will do is use the midFrom:to: to grab a segment of the
	// string, and so we need to know where the left and right bounds
	// are on the field in question.
	int left, right;
	switch (n) {
		case MISC_STRING_FIRST : {
			left = 0;
			right = [self spotOf:c occurrenceNum:0 caseSensitive:sense] - 1;
			if (right < -1) return [self copy]; // only one field
			if (right == -1) // field is empty
				return [[self class] newWithString:""];
			break;
		}
		case MISC_STRING_LAST : {
			left = [self rspotOf:c occurrenceNum:0 caseSensitive:sense] + 1;
			if (left < 1) return [self copy]; // only one field
			right = length - 1;
			if (right < left) // field is empty
				return [[self class] newWithString:""];
			break;
		}
		default : { // won't work for field #0, but MISC_STRING_FIRST == 0
			left = [self spotOf:c occurrenceNum:(n-1) caseSensitive:sense] + 1;
			right = [self spotOf:c occurrenceNum:n caseSensitive:sense] - 1;
			if (left >= 1) { // if left == 0, then no field, so leave right
				// at -1 to trigger midFrom:to:fromZone: to return nil.
				if (right == -2) right = length - 1; // if it's the last field
				if (right < left) // field is empty
					return [[self class] newWithString:""];
			}
		}
	}
	return [self midFrom:left to:right fromZone:zone];
}

- extractPart:(int)n useAsDelimiter:(char)c caseSensitive:(BOOL)sense
{
	return [self extractPart:n useAsDelimiter:c
			caseSensitive:sense fromZone:[self zone]];
}

- extractPart:(int)n useAsDelimiter:(char)c fromZone:(NXZone *)zone
{
	return [self extractPart:n useAsDelimiter:c
			caseSensitive:YES fromZone:zone];
}

- extractPart:(int)n useAsDelimiter:(char)c
{
	return [self extractPart:n useAsDelimiter:c
			caseSensitive:YES fromZone:[self zone]];
}

- wordNum:(int)num
{
	return [self wordNum:num fromZone:[self zone]];
}

- wordNum:(int) num fromZone:(NXZone *)zone
// returns a new String containing the numth word in buffer
// if numth word does not exist, returns nil.
{
	int i = 0;
	int currword = 0;
	int spot = 0; 
	int spot2 = 0;

	if (!buffer) return nil;
	while ((i < length) && (currword <= num)) {
		while ((i < length) && (NXIsSpace(buffer[i]))) i++;
		spot2 = i;
		while ((i < length) && (!NXIsSpace(buffer[i]))) i++;
		spot = i;
		currword++;
	}
	
	if ((spot == spot2) || (num != (currword-1))) return nil;
	return [self midFrom:spot2 length:spot-spot2 fromZone:zone];
}


- (int)numWords
{ //counts the number of words in buffer.
	int i=0;
	int currword = 0;

	if (!buffer) return 0;  
	while (i <= length) {
		while ((NXIsSpace(buffer[i])) && (i <= length)) i++;
		while ((!NXIsSpace(buffer[i])) && (i <= length)) i++;
		currword++;
	}
	if (NXIsSpace(buffer[length-1])) currword--;
	return currword;
}

- tokenize:(const char *)breakChars into:aList
// Uses strtok() on a COPY of the strings contents to break the string
// into tokens.  Fills aList with MiscString objects containing (in order) 
// the tokens from strtok.  If aList is nil a list is allocated, but the 
// caller is still responsible for freeing it.  This is a "safe" usage of 
// strtok() (although not "thread-safe").  strtok() relies on static 
// variables to keep track of where it is in between calls.  This is
// "safe" in that we parse the whole thing before returning, so no one
// in this thread will start parsing another string with strtok() while
// we're in the middle of ours.
{
	char *toker, *token;

	// Allocate the list if we need to.
	if (aList == nil)  {
		aList = [[List allocFromZone:[self zone]] init];
	}

	// Copy our contents into a scratch buffer.
	NX_MALLOC(toker, char, length+1);
	strcpy(toker, buffer);
	
	// Start toking on it.
	token = strtok(toker, breakChars);
	while (token)  {
		[aList addObject:[[[self class] allocFromZone:[self zone]] 
					initString:token]];
		token = strtok(NULL, breakChars);
	}
	
	// As you allocate, so shall ye free.
	NX_FREE(toker);	
	return aList;
}

@end
