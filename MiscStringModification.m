//
//	MiscStringModification.m
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

@implementation MiscString(Modification)

// This category is composed of methods which modify a MiscString in
// various ways (case conversion, trimming whitespace, deleting portions
// of the string, and so on).

- setStringValue:(const char *)aString
{
	return [self setStringValue:aString fromZone:[self zone]];
}

- setStringValue:(const char *)aString fromZone:(NXZone *)zone
{
	if (!aString) return self; // use -freeString to set to "NULL"
	// Note that I could have used NXCopyStringBufferFromZone() here
	// instead.  This works just as well, but it may be slower...
	// I haven't checked that out, though.  It might be worth doing.
	[self allocateBuffer:(strlen(aString)+1) fromZone:zone];
	strcpy(buffer, aString);
	length = strlen(buffer);
	return self;
}

- setStringValue:(const char *)aString n:(int)n
{
	return [self setStringValue:aString n:n fromZone:[self zone]];
}

- setStringValue:(const char *)aString n:(int)n fromZone:(NXZone *)zone
{
	char *buf = NULL;
	if ((aString) && (n > 0))  {
		NX_MALLOC(buf, char, n + 1);
		strncpy(buf, aString, n);
		buf[n]='\0';
	}
	[self setStringValue:buf fromZone:zone];
	NX_FREE(buf);
	return self;
}

- setFromFormat:(const char *)formatStr, ...
// Sets the string from and printf style format string and arguments.
{
	va_list param_list;
	char *buf;

	va_start(param_list, formatStr);
	buf = MiscBuildStringFromFormatV(formatStr, param_list);
	va_end(param_list);
	[self setStringValue:buf];
	NX_FREE(buf);
	return self;
}

- setIntValue:(int)val
// Sets the string by converting the given int to a string.
{
	return [self setFromFormat:"%d", val];
}

- setFloatValue:(float)val
// Sets the string by converting the given float to a string.
{
	return [self setFromFormat:"%f", val];
}

- setDoubleValue:(double)val
// Sets the string by converting the given double to a string.
{
	return [self setFromFormat:"%f", val];
}

- sprintf:(const char *)formatStr, ...
// Sets the strings contents as the result of printf'ing with the
// given format string and arguments.  Same as setFromFormat:, ...
{
	va_list param_list;
	char *buf;
	
	va_start(param_list, formatStr);
	buf = MiscBuildStringFromFormatV(formatStr, param_list);
	va_end(param_list);
	[self setStringValue:buf];
	NX_FREE(buf);
	return self;
}

- takeStringValueFrom:sender
{ // if no string value, return nil; the user is expecting a changed string
	if (!sender) return [self setStringValue:""]; // this seems reasonable...
		// but maybe I should just return nil instead...
	if (![sender respondsTo:@selector(stringValue)]) return nil;
	return [self setStringValue:[sender stringValue] fromZone:[self zone]];
}

- takeStringValueFrom:sender fromZone:(NXZone *)zone
{
	if (![sender respondsTo:@selector(stringValue)]) return nil;
	return [self setStringValue:[sender stringValue] fromZone:zone];
}

- takeIntValueFrom:sender
{
	if (![sender respondsTo:@selector(intValue)]) return nil;
	[self setIntValue:[sender intValue]];
	return self;
}

- takeFloatValueFrom:sender
{
	if (![sender respondsTo:@selector(floatValue)]) return nil;
	[self setFloatValue:[sender floatValue]];
	return self;
}

- takeDoubleValueFrom:sender
{
	if (![sender respondsTo:@selector(doubleValue)]) return nil;
	[self setDoubleValue:[sender doubleValue]];
	return self;
}

- trimLeadSpaces
{	// removes any leading spaces from buffer
	int i = 0;
	id tmpStr;

	if (!buffer) return self;
	if (length < 1) return self;
	while ((i < length) && (buffer[i] == ' ')) i++;
	if (i==0) return self;
	tmpStr = [self right:length-i];
	[self takeStringValueFrom:tmpStr];
	[tmpStr free];
	return self;
}

- trimTailSpaces
// removes any trailing spaces from buffer
{
	int i = length;
	id tmpStr;

	if (!buffer) return self;
	if (i < 1) return self;
	while ((i > 0) && (buffer[i-1] == ' ')) i--;
	if (i==length) return self;
	tmpStr = [self left:i];
	[self takeStringValueFrom:tmpStr];
	[tmpStr free];
	return self;
}

- trimSpaces
// takes off leading and trailing spaces of the buffer
{
	return [[self trimLeadSpaces] trimTailSpaces];
}

- trimLeadWhiteSpaces
// removes any leading white space from buffer
{ 
	int i = 0;
	id tmpStr;
	
	if (!buffer) return self;
	if (length < 1) return self;
	while ((i < length) && NXIsSpace(buffer[i])) i++;
	if (i==0) return self;
	tmpStr = [self right:length-i];
	[self takeStringValueFrom:tmpStr];
	[tmpStr free];
	return self;
}

- trimTailWhiteSpaces
// removes any leading white space from buffer
{ 
	int i = length;
	id tmpStr;
	
	if (!buffer) return self;
	if (i < 1) return self;
	while ((i > 0) && NXIsSpace(buffer[i-1])) i--;
	if (i==length) return self;
	tmpStr = [self left:i];
	[self takeStringValueFrom:tmpStr];
	[tmpStr free];
	return self;
}

- trimWhiteSpaces
// takes off leading and trailing spaces of the buffer
{
	return [[self trimLeadWhiteSpaces] trimTailWhiteSpaces];
}

- squashSpaces
{
  int count = 0;
  id tempStr;
  
  if (!buffer) return self;
  [self trimSpaces];
  tempStr = [[[[self class] alloc] init] allocateBuffer:length];
  while (count<length) {
    while ((count<length) && (buffer[count]!=' ')) {
      [tempStr addChar:buffer[count]];
      count++;
     }
    if ((count<length) && (buffer[count] == ' ')) {
      [tempStr addChar:buffer[count]];
      count++;
     }
    if ((count<length) && (buffer[count]==' ') && 
       ((buffer[count-2] == ':') || (buffer[count-2] =='.'))) {
         [tempStr addChar:buffer[count]];
         count++;
     }
    while (buffer[count]==' ') count++;
   }
  [self takeStringValueFrom:tempStr];
  [tempStr free];
  return self;
}

- reverse
// reverses the characters in the buffer.  If it's a palindrome, you won't
// notice much of a difference :-)
{
	char tmp[length+1];
	int i, j=0;
  
	if (length <= 1) return self;
	for (i=length-1; i>=0; i--) {
		tmp[j] = buffer[i];
		j++;
	}
	tmp[length] = 0;
	if (length != 0) [self setStringValue:tmp];
	return self;
}

- toUpper
// converts any lowercase characters in buffer to uppercase
{
	int i;
	for (i=0; i<length; i++) {
		if (NXIsLower(buffer[i])) buffer[i] = NXToUpper(buffer[i]);
	}
	return self;
}

- toLower
// converts any uppercase chars in buffer to lowercase
{
	int i;
	for (i=0; i<length; i++) {
		if (NXIsUpper(buffer[i])) buffer[i] = NXToLower(buffer[i]);
	}
	return self;
}

- invertCases
{
	int i;
	for (i=0; i<length; i++) {
		if (NXIsUpper(buffer[i])) buffer[i] = NXToLower(buffer[i]);
		else buffer[i] = NXToUpper(buffer[i]);
	}
	return self;
}

- capitalizeEachWord
{ // ***** it might be nice to NOT capitalize words like "a" "an" and "the"
	// so that capitalizations follw the style of titles, etc.
	int i = 0;
	if (!buffer) return 0;  
	while (i <= length) {
		while ((NXIsSpace(buffer[i])) && (i <= length)) i++;
		if (i < length) buffer[i] = NXToUpper(buffer[i]);
		while ((!NXIsSpace(buffer[i])) && (i <= length)) i++;
	}
	return self;
}

- removeFrom:(int)index length:(int)len
{ // to avoid memory leaks, this should NEVER return nil!
  id temp1,temp2;
  
  if (!buffer) return self;	// everything's already gone
  if (len <= 0) return self; // noting to remove
  // DAY: should I presume to fix index<0 like so? or just index = 0?
  // or just return self?
  if (index < 0) { len += index; index = 0; if (len <= 0) return self; }
  if (index > length - 1) return self; // nothing out there
  temp1 = [self left:index];
  if (!temp1) temp1 = [[[self class] alloc] init];
  temp2 = [self midFrom:index+len to:length];
  [temp1 concatenate:temp2];
  [self takeStringValueFrom:temp1];
  [temp1 free];
  [temp2 free];
  return self;
}

- removeFrom:(int)start to:(int)end
{
  return [self removeFrom:start length:end-start+1];
}

- (int)gets
{
  char c;
  [self setStringValue:""];
  
  while (((c = getchar()) != '\n') && (c != EOF)) {
    if (length == _length-1) [self setCapacity:length*2];
    [self addChar:c];
   }
  return (c == '\n')? 0:EOF;
}

- (int)fgets:(FILE *)fd keepNewline:(BOOL)keepit
{
  char c;
  [self setStringValue:""];
  
  while (((c = fgetc(fd)) != '\n') && (c != EOF)) {
    if (length == _length-1) [self setCapacity:length*2];
    [self addChar:c];
   }
  if (keepit && (c == '\n')) [self addChar:'\n']; //don't add EOF
  return (c == '\n')? 0:EOF;
}

- (int)fgets:(FILE *)fd
{
  return [self fgets:fd keepNewline:YES];
}

 
- (int)streamGets:(NXStream *)stream keepNewline:(BOOL)keepit
{
  char c = '\0';
  [self setStringValue:""];
  
  while (!NXAtEOS(stream) && ((c = NXGetc(stream)) != '\n') && (c != EOF)) {
    if (length == _length-1) [self setCapacity:length*2];
    [self addChar:c];
   }
  if (keepit && (c == '\n')) [self addChar:'\n']; //don't add EOF
  return (c == '\n')? 0:EOF;
}

- (int)streamGets:(NXStream *)stream
{
  return [self streamGets:stream keepNewline:YES];
}

- padToLength:(int)len withChar:(char)aChar
{
  int i;
  
  for (i=length;i<len;i++) {
    if (length == _length-1) [self setCapacity:length*2];
    [self addChar:aChar];
   }
  return self;
}

- padFrontToLength:(int)len withChar:(char)aChar
{
  if (len > length) {
    id string = [[[[self class] alloc] initCapacity:len-length+1]
                    padToLength:len-length withChar:aChar];
    [self insertString:string];
    [string free];
  }
  
  return self;
}

// need a removePart:... series like the extract part stuff.
@end
