//
//	MiscString.h -- a generic class to simplify manipulation of (char *)'s
//		Written by Don Yacktman Copyright (c) 1993, 1994 by Don Yacktman.
//				Version 1.95.  All rights reserved.
//		This notice may not be removed from this source code.
//
//	This object is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"LICENSE.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//	

#import <appkit/appkit.h>

#import <misckit/MiscProtocols.h>

#ifndef _MISCSTRING_H
#define _MISCSTRING_H

// special constants for -extractPart... methods
#define MISC_STRING_LAST -1
#define MISC_STRING_FIRST 0

// character types...they can be OR'ed together...
#define MISC_UPPER     1
#define MISC_LOWER     2
#define MISC_DIGIT     4
#define MISC_XDIGIT    8
#define MISC_PUNCT    16
#define MISC_ASCII    32
#define MISC_CNTRL    64
#define MISC_PRINT   128
#define MISC_SPACE   256
#define MISC_GRAPH   512

/* A couple of obvious combinations */
#define MISC_ALPHA (MISC_UPPER|MISC_LOWER)
#define MISC_ALNUM (MISC_ALPHA|MISC_DIGIT)


char *MiscBuildStringFromFormatV(const char *formatStr, va_list param_list);

// Note that the NXTransport protocol is handled by the NEXTSTEP category.
@interface MiscString:Object
{
	 char *buffer;
	 NXStringOrderTable *orderTable;
	 int length, _length;	// length is string length, _length is buffer size
}

+ initialize;
+ new;
+ newWithString:(const char *)aString;
- new;
- init;
- initCapacity:(int)capacity;
- initCapacity:(int)capacity fromZone:(NXZone *)zone;
- initString:(const char *)aString;
- initFromFormat:(const char *)formatStr, ...;
- allocateBuffer:(int)size;
- allocateBuffer:(int)size fromZone:(NXZone *)zone;
- copyFromZone:(NXZone *)zone;
- (char *)getCopyInto:(char *)buf;
- freeString;
- free;
- (BOOL)emptyString;
- (char)charAt:(int)index;
- (int)numOfChar:(char)aChar caseSensitive:(BOOL)sense;
- (int)numOfChar:(char)aChar;
- (int)numOfChars:(const char *)aString caseSensitive:(BOOL)sense;
- (int)numOfChars:(const char *)aString;
- (int)length;
- (unsigned)capacity;
- setCapacity:(unsigned)newCapacity;
- (size_t)recalcLength;
- fixStringLength;
- fixStringLengthAt:(unsigned)index;
- setStringOrderTable:(NXStringOrderTable *)table;
- (NXStringOrderTable *)stringOrderTable;
- (const char *)stringValue;
- (NXAtom)uniqueStringValue;
- (const char *)stringValueAndFree;
- (int)intValue;
- (float)floatValue;
- (double)doubleValue;

@end

@interface MiscString(Comparing) <MiscCompare, MiscEndCompare>

- (BOOL)isEqual:anObject;
- (unsigned int)hash;
- (int)cmp:(const char *)aString n:(int)n;
- (int)compareTo:sender n:(int)n caseSensitive:(BOOL)sense;
- (int)casecmp:(const char *)aString n:(int)n;
- (int)endcmp:(const char *)aString n:(int)n;
- (int)endcasecmp:(const char *)aString n:(int)n;
- (int)endCompareTo:(id)sender n:(int)n caseSensitive:(BOOL)sense;

#ifndef _HEADER_VIEWER_  /* convenience methods */
- (int)cmp:(const char *)aString;
- (int)casecmp:(const char *)aString;
- (int)endcmp:(const char *)aString;
- (int)endcasecmp:(const char *)aString;
- (int)compareTo:sender;
- (int)compareTo:sender n:(int)n;
- (int)compareTo:sender caseSensitive:(BOOL)sense;
- (int)endCompareTo:(id)sender;
- (int)endCompareTo:(id)sender caseSensitive:(BOOL)sense;
- (int)endCompareTo:(id)sender n:(int)n;
#endif

@end

@interface MiscString(Debugging)

- buildInstanceImageIn:(char *)buf;
- printForDebugger:(NXStream *)stream;
- printToStdErr:(const char *)label;

@end

@interface MiscString(Fields)

- subStringRight:subString;
- subStringLeft:subString;
- left:(int)count fromZone:(NXZone *)zone;
- right:(int)count fromZone:(NXZone *)zone;
- midFrom:(int)start to:(int)end fromZone:(NXZone *)zone;
- midFrom:(int)start length:(int)len fromZone:(NXZone *)zone;
- extractPart:(int)n useAsDelimiter:(char)c caseSensitive:(BOOL)sense
		fromZone:(NXZone *)zone;
- wordNum:(int) num fromZone:(NXZone *)zone;
- (int)numWords;
- tokenize:(const char *)breakChars into:aList;

#ifndef _HEADER_VIEWER_  /* convenience methods */
- extractPart:(int)n useAsDelimiter:(char)c caseSensitive:(BOOL)sense;
- extractPart:(int)n useAsDelimiter:(char)c fromZone:(NXZone *)zone;
- extractPart:(int)n useAsDelimiter:(char)c;
- wordNum:(int) num;
- left:(int)count;
- right:(int)count;
- midFrom:(int)start to:(int)end;
- midFrom:(int)start length:(int)len;
#endif

@end

@interface MiscString(Insertion)

- cat:(const char *)aString n:(int)n fromZone:(NXZone *)zone;
- concatenate:sender n:(int)n fromZone:(NXZone *)zone;
- insert:(const char *)aString at:(int)index;
- insertString:(id)sender at:(int)index;
- insertChar:(char)aChar at:(int)index;
- catStrings:  ( const char *) strings,  ...;
- concatenateStrings:(id)strings,  ...;
- insert:(const char *)aString;
- insertString:aString;
- addChar:(char)aChar;
- insertFromFormat:(const char *)format, ...;
- insertAt:(int)index fromFormat:(const char *)format, ...;
- catFromFormat:(const char *)format, ...;

#ifndef _HEADER_VIEWER_  /* convenience methods */
- cat:(const char *)aString;
- cat:(const char *)aString n:(int)n;
- cat:(const char *)aString fromZone:(NXZone *)zone;
- concatenate:sender;
- concatenate:sender n:(int)n;
- concatenate:sender fromZone:(NXZone *)zone;
- insertChar:(char)aChar;
#endif

@end

@interface MiscString(Modification)

- setStringValue:(const char *)aString;
- setStringValue:(const char *)aString n:(int)n fromZone:(NXZone *)zone;
- setFromFormat:(const char *)formatStr, ...;
- setIntValue:(int)val;
- setFloatValue:(float)val;
- setDoubleValue:(double)val;
- sprintf:(const char *)formatStr, ...;
- takeStringValueFrom:sender;
- takeStringValueFrom:sender fromZone:(NXZone *)zone;
- takeIntValueFrom:sender;
- takeFloatValueFrom:sender;
- takeDoubleValueFrom:sender;
- trimLeadSpaces;
- trimTailSpaces;
- trimSpaces;
- trimLeadWhiteSpaces;
- trimTailWhiteSpaces;
- trimWhiteSpaces;
- squashSpaces;
- reverse;
- toUpper;
- toLower;
- invertCases;
- capitalizeEachWord;
- removeFrom:(int)index length:(int)len;
- removeFrom:(int)start to:(int)end;
- (int)gets;
- (int)fgets:(FILE *)fd keepNewline:(BOOL)keepit;
- (int)streamGets:(NXStream *)stream keepNewline:(BOOL)keepit;
- padToLength:(int)len withChar:(char)aChar;
- padFrontToLength:(int)len withChar:(char)aChar;

#ifndef _HEADER_VIEWER_  /* convenience methods */
- setStringValue:(const char *)aString fromZone:(NXZone *)zone;
- setStringValue:(const char *)aString n:(int)n;
- (int)fgets:(FILE *)fd;
- (int)streamGets:(NXStream *)stream;
#endif

@end

@interface MiscString(NEXTSTEP) <NXTransport>

- read:(NXTypedStream *)stream;
- write:(NXTypedStream *)stream;
- (BOOL)isRTFText;
- (MiscString *)plainTextForRTF;
- (const char *)getInspectorClassName;
- (NXImage *)getIBImage;
- writeToStream:(NXStream *)aStream;

@end

#import <misckit/MiscStringPatterns.h>
#import <misckit/MiscStringRegex.h>
#import <misckit/MiscString_ExtendedParsing.h>
#import <misckit/MiscStringCompatability.h>

@interface MiscString(Replacing)

- replaceFrom:(int)start length:(int)len with:(const char *)aString;
- replaceFrom:(int)start to:(int)end with:(const char *)aString;
- replaceFrom:(int)start length:(int)len withString:(id)sender;
- replaceFrom:(int)start to:(int)end withString:(id)sender;
- replace:(const char *)subString with:(const char *)newString;
- replace:(const char *)subString withString:(id)sender;
- replaceCharAt:(int)index withChar:(char)aChar;
- replaceFrom:(int)start length:(int)len withChar:(char)aChar;
- replaceFrom:(int)start to:(int)end withChar:(char)aChar;

- replaceEveryOccurrenceOfChars:(const char *)aString with:(const char *)replaceString caseSensitive:(BOOL)sense;
- replaceEveryOccurrenceOfChars:(const char *)aString withChar:(char)replaceChar caseSensitive:(BOOL)sense;
- replaceEveryOccurrenceOfChars:(const char *)aString withString:(id)sender caseSensitive:(BOOL)sense;
- replaceEveryOccurrenceOfChar:(char)aChar with:(const char *)aString caseSensitive:(BOOL)sense;
- replaceEveryOccurrenceOfChar:(char)aChar withString:(id)sender caseSensitive:(BOOL)sense;
- replaceEveryOccurrenceOfChar:(char)aChar withChar:(char)replaceChar caseSensitive:(BOOL)sense;

- replaceType:(int)type with:(const char *)str occurrenceNum:(int)n;
- replaceType:(int)type withChar:(char)aChar occurrenceNum:(int)n;
- replaceType:(int)type withString:(id)sender occurrenceNum:(int)n;
- replaceEveryOccurrenceOfType:(int)type with:(const char *)str;
- replaceEveryOccurrenceOfType:(int)type withChar:(char)aChar;
- replaceEveryOccurrenceOfType:(int)type withString:(id)sender;

- (int)replaceEveryOccurrenceOf:(const char *)str with:(const char *)repl caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)replaceEveryOccurrenceOf:(const char *)str withChar:(char)aChar caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)replaceEveryOccurrenceOf:(const char *)str withString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)replaceEveryOccurrenceOfString:(id)sender with:(const char *)repl caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)replaceEveryOccurrenceOfString:(id)sender withChar:(char)aChar caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)replaceEveryOccurrenceOfString:(id)sender withString:(id)repl caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- replace:(const char *)str with:(const char *)repl occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- replace:(const char *)str withChar:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- replace:(const char *)str withString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- replaceString:(id)sender with:(const char *)repl occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- replaceString:(id)sender withChar:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- replaceString:(id)sender withString:(id)repl occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

#ifndef _HEADER_VIEWER_  /* convenience methods */
- replaceEveryOccurrenceOfChars:(const char *)aString with:(const char *)replaceString;
- replaceEveryOccurrenceOfChars:(const char *)aString withChar:(char)replaceChar;
- replaceEveryOccurrenceOfChars:(const char *)aString withString:(id)sender;
- replaceEveryOccurrenceOfChar:(char)aChar with:(const char *)aString;
- replaceEveryOccurrenceOfChar:(char)aChar withString:(id)sender;
- replaceEveryOccurrenceOfChar:(char)aChar withChar:(char)replaceChar;

- replaceType:(int)type with:(const char *)str;
- replaceType:(int)type withChar:(char)aChar;
- replaceType:(int)type withString:(id)sender;

- (int)replaceEveryOccurrenceOf:(const char *)str with:(const char *)repl;
- (int)replaceEveryOccurrenceOf:(const char *)str with:(const char *)repl caseSensitive:(BOOL)sense;
- (int)replaceEveryOccurrenceOf:(const char *)str with:(const char *)repl overlap:(BOOL)overlap;

- (int)replaceEveryOccurrenceOf:(const char *)str withChar:(char)aChar;
- (int)replaceEveryOccurrenceOf:(const char *)str withChar:(char)aChar caseSensitive:(BOOL)sense;
- (int)replaceEveryOccurrenceOf:(const char *)str withChar:(char)aChar overlap:(BOOL)overlap;

- (int)replaceEveryOccurrenceOf:(const char *)str withString:(id)sender;
- (int)replaceEveryOccurrenceOf:(const char *)str withString:(id)sender caseSensitive:(BOOL)sense;
- (int)replaceEveryOccurrenceOf:(const char *)str withString:(id)sender overlap:(BOOL)overlap;

- (int)replaceEveryOccurrenceOfString:(id)sender with:(const char *)repl;
- (int)replaceEveryOccurrenceOfString:(id)sender with:(const char *)repl caseSensitive:(BOOL)sense;
- (int)replaceEveryOccurrenceOfString:(id)sender with:(const char *)repl overlap:(BOOL)overlap;

- (int)replaceEveryOccurrenceOfString:(id)sender withChar:(char)aChar;
- (int)replaceEveryOccurrenceOfString:(id)sender withChar:(char)aChar caseSensitive:(BOOL)sense;
- (int)replaceEveryOccurrenceOfString:(id)sender withChar:(char)aChar overlap:(BOOL)overlap;

- (int)replaceEveryOccurrenceOfString:(id)sender withString:(id)repl;
- (int)replaceEveryOccurrenceOfString:(id)sender withString:(id)repl caseSensitive:(BOOL)sense;
- (int)replaceEveryOccurrenceOfString:(id)sender withString:(id)repl overlap:(BOOL)overlap;

- replace:(const char *)str with:(const char *)repl;
- replace:(const char *)str with:(const char *)repl occurrenceNum:(int)n;
- replace:(const char *)str with:(const char *)repl caseSensitive:(BOOL)sense;
- replace:(const char *)str with:(const char *)repl occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- replace:(const char *)str with:(const char *)repl overlap:(BOOL)overlap;
- replace:(const char *)str with:(const char *)repl occurrenceNum:(int)n overlap:(BOOL)overlap;
- replace:(const char *)str with:(const char *)repl caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- replace:(const char *)str withChar:(char)aChar;
- replace:(const char *)str withChar:(char)aChar occurrenceNum:(int)n;
- replace:(const char *)str withChar:(char)aChar caseSensitive:(BOOL)sense;
- replace:(const char *)str withChar:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- replace:(const char *)str withChar:(char)aChar overlap:(BOOL)overlap;
- replace:(const char *)str withChar:(char)aChar occurrenceNum:(int)n overlap:(BOOL)overlap;
- replace:(const char *)str withChar:(char)aChar caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- replace:(const char *)str withString:(id)sender;
- replace:(const char *)str withString:(id)sender occurrenceNum:(int)n;
- replace:(const char *)str withString:(id)sender caseSensitive:(BOOL)sense;
- replace:(const char *)str withString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- replace:(const char *)str withString:(id)sender overlap:(BOOL)overlap;
- replace:(const char *)str withString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap;
- replace:(const char *)str withString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- replaceString:(id)sender with:(const char *)repl;
- replaceString:(id)sender with:(const char *)repl occurrenceNum:(int)n;
- replaceString:(id)sender with:(const char *)repl caseSensitive:(BOOL)sense;
- replaceString:(id)sender with:(const char *)repl occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- replaceString:(id)sender with:(const char *)repl overlap:(BOOL)overlap;
- replaceString:(id)sender with:(const char *)repl occurrenceNum:(int)n overlap:(BOOL)overlap;
- replaceString:(id)sender with:(const char *)repl caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- replaceString:(id)sender withChar:(char)aChar;
- replaceString:(id)sender withChar:(char)aChar occurrenceNum:(int)n;
- replaceString:(id)sender withChar:(char)aChar caseSensitive:(BOOL)sense;
- replaceString:(id)sender withChar:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- replaceString:(id)sender withChar:(char)aChar overlap:(BOOL)overlap;
- replaceString:(id)sender withChar:(char)aChar occurrenceNum:(int)n overlap:(BOOL)overlap;
- replaceString:(id)sender withChar:(char)aChar caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- replaceString:(id)sender withString:(id)repl;
- replaceString:(id)sender withString:(id)repl occurrenceNum:(int)n;
- replaceString:(id)sender withString:(id)repl caseSensitive:(BOOL)sense;
- replaceString:(id)sender withString:(id)repl occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- replaceString:(id)sender withString:(id)repl overlap:(BOOL)overlap;
- replaceString:(id)sender withString:(id)repl occurrenceNum:(int)n overlap:(BOOL)overlap;
- replaceString:(id)sender withString:(id)repl caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
#endif

@end

@interface MiscString(Searching)

- (int)spotOf:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (int)rspotOf:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (const char *)rindex:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (const char *)index:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (int)spotOfChars:(const char *)aString occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (int)rspotOfChars:(const char *)aString occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (const char *)rindexOfChars:(const char *)aString occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (const char *)indexOfChars:(const char *)aString occurrenceNum:(int)n caseSensitive:(BOOL)sense;

- (BOOL) hasType:(int)type;
- (BOOL) isAllOfType:(int)type;
- (int)spotOfType:(int)type occurrenceNum:(int)n;
- (int)rspotOfType:(int)type occurrenceNum:(int)n;

- (int)spotOfStr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)rspotOfStr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)spotOfString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)rspotOfString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (const char *)strstr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (const char *)rstrstr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (const char *)strString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (const char *)rstrString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)numOfType:(int)type;
- (int)numOf:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap;
- (int)numOfString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

#ifndef _HEADER_VIEWER_  /* convenience methods */
- (int)spotOf:(char)aChar;
- (int)spotOf:(char)aChar caseSensitive:(BOOL)sense;
- (int)spotOf:(char)aChar occurrenceNum:(int)n;
- (int)rspotOf:(char)aChar;
- (int)rspotOf:(char)aChar caseSensitive:(BOOL)sense;
- (int)rspotOf:(char)aChar occurrenceNum:(int)n;

- (const char *)rindex:(char)aChar;
- (const char *)rindex:(char)aChar occurrenceNum:(int)n;
- (const char *)rindex:(char)aChar caseSensitive:(BOOL)sense;
- (const char *)index:(char)aChar;
- (const char *)index:(char)aChar occurrenceNum:(int)n;
- (const char *)index:(char)aChar caseSensitive:(BOOL)sense;

- (int)spotOfChars:(const char *)aString;
- (int)spotOfChars:(const char *)aString caseSensitive:(BOOL)sense;
- (int)spotOfChars:(const char *)aString occurrenceNum:(int)n;
- (int)rspotOfChars:(const char *)aString;
- (int)rspotOfChars:(const char *)aString caseSensitive:(BOOL)sense;
- (int)rspotOfChars:(const char *)aString occurrenceNum:(int)n;

- (const char *)rindexOfChars:(const char *)aString;
- (const char *)rindexOfChars:(const char *)aString caseSensitive:(BOOL)sense;
- (const char *)rindexOfChars:(const char *)aString occurrenceNum:(int)n;
- (const char *)indexOfChars:(const char *)aString;
- (const char *)indexOfChars:(const char *)aString caseSensitive:(BOOL)sense;
- (const char *)indexOfChars:(const char *)aString occurrenceNum:(int)n;

- (int)spotOfType:(int)type;
- (int)rspotOfType:(int)type;

- (int)spotOfStr:(const char *)str;
- (int)spotOfStr:(const char *)str occurrenceNum:(int)n;
- (int)spotOfStr:(const char *)str caseSensitive:(BOOL)sense;
- (int)spotOfStr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (int)spotOfStr:(const char *)str overlap:(BOOL)overlap;
- (int)spotOfStr:(const char *)str occurrenceNum:(int)n overlap:(BOOL)overlap;
- (int)spotOfStr:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- (int)rspotOfStr:(const char *)str;
- (int)rspotOfStr:(const char *)str occurrenceNum:(int)n;
- (int)rspotOfStr:(const char *)str caseSensitive:(BOOL)sense;
- (int)rspotOfStr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (int)rspotOfStr:(const char *)str overlap:(BOOL)overlap;
- (int)rspotOfStr:(const char *)str occurrenceNum:(int)n overlap:(BOOL)overlap;
- (int)rspotOfStr:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- (int)spotOfString:(id)sender;
- (int)spotOfString:(id)sender occurrenceNum:(int)n;
- (int)spotOfString:(id)sender caseSensitive:(BOOL)sense;
- (int)spotOfString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (int)spotOfString:(id)sender overlap:(BOOL)overlap;
- (int)spotOfString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap;
- (int)spotOfString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- (int)rspotOfString:(id)sender;
- (int)rspotOfString:(id)sender occurrenceNum:(int)n;
- (int)rspotOfString:(id)sender caseSensitive:(BOOL)sense;
- (int)rspotOfString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (int)rspotOfString:(id)sender overlap:(BOOL)overlap;
- (int)rspotOfString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap;
- (int)rspotOfString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- (const char *)strstr:(const char *)str;
- (const char *)strstr:(const char *)str occurrenceNum:(int)n;
- (const char *)strstr:(const char *)str caseSensitive:(BOOL)sense;
- (const char *)strstr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (const char *)strstr:(const char *)str overlap:(BOOL)overlap;
- (const char *)strstr:(const char *)str occurrenceNum:(int)n overlap:(BOOL)overlap;
- (const char *)strstr:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- (const char *)rstrstr:(const char *)str;
- (const char *)rstrstr:(const char *)str occurrenceNum:(int)n;
- (const char *)rstrstr:(const char *)str caseSensitive:(BOOL)sense;
- (const char *)rstrstr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (const char *)rstrstr:(const char *)str overlap:(BOOL)overlap;
- (const char *)rstrstr:(const char *)str occurrenceNum:(int)n overlap:(BOOL)overlap;
- (const char *)rstrstr:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- (const char *)strString:(id)sender;
- (const char *)strString:(id)sender occurrenceNum:(int)n;
- (const char *)strString:(id)sender caseSensitive:(BOOL)sense;
- (const char *)strString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (const char *)strString:(id)sender overlap:(BOOL)overlap;
- (const char *)strString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap;
- (const char *)strString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- (const char *)rstrString:(id)sender;
- (const char *)rstrString:(id)sender occurrenceNum:(int)n;
- (const char *)rstrString:(id)sender caseSensitive:(BOOL)sense;
- (const char *)rstrString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense;
- (const char *)rstrString:(id)sender overlap:(BOOL)overlap;
- (const char *)rstrString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap;
- (const char *)rstrString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap;

- (int)numOf:(const char *)str;
- (int)numOf:(const char *)str caseSensitive:(BOOL)sense;
- (int)numOf:(const char *)str overlap:(BOOL)overlap;

- (int)numOfString:(id)sender;
- (int)numOfString:(id)sender caseSensitive:(BOOL)sense;
- (int)numOfString:(id)sender overlap:(BOOL)overlap;
#endif

@end

@interface MiscString(Sybase)

- convertUnixWildcardsToSybase;
- convertToCaseInsensitiveSearchString;
- makeCaseInsensitiveSearchString;

@end

// These are legal arguments for the -isFileOfType: method...
typedef enum _MiscFileType {
	Misc_Socket           = S_IFSOCK,  // socket
	Misc_Directory        = S_IFDIR,   // directory
	Misc_PlainFile        = S_IFREG,   // regular (plain) file
	Misc_SymbolicLink     = S_IFLNK,   // symbolic link
	Misc_CharacterSpecial = S_IFCHR,   // character special
	Misc_BlockSpecial     = S_IFBLK,   // block special
	Misc_Fifo             = S_IFIFO    // fifo (Sun VFS)
} MiscFileType;

@interface MiscString(Unix)

// all MiscStrings use a global separator for splitting up paths.
// it's less overhead than making a UNIX subclass that stores these
// for each and every path...and typically you would never need to
// worry about changing these anyway...
+ setPathSeparator:(char)c;
+ setExtensionSeparator:(char)c;
+ (char)extensionSeparator;
+ (char)pathSeparator;

// passwords
- encrypt:salt;

// parsing paths
- fileName;
- pathName;
- fileExtension;
- fileBasename;
- fileNameFromZone:(NXZone *)zone;
- pathNameFromZone:(NXZone *)zone;
- fileExtensionFromZone:(NXZone *)zone;
- fileBasenameFromZone:(NXZone *)zone;
- addExtensionIfNeeded:(const char *)aString;

// manipulating paths
- replaceHomeWithTilde;
- replaceTildeWithHome;

// info about paths
- (BOOL)isRelativePath;
- (BOOL)isAbsolutePath;
- (BOOL)doesExistInFileSystem;
- (BOOL)isFileOfType:(MiscFileType)fileType;
- (int)numberOfPathComponents;
- pathComponentAt:(int)index;
- setDirectory:(const char *)dir file:(const char *)file;
- initDirectory:(const char *)dir file:(const char *)file;

- (int)system; // runs the system() function on the string

- loadFromFile:(const char *)fileName; // reads contents of file
	// into the string

@end

#endif /* _MISCSTRING_H */
