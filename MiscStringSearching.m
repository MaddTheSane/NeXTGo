//
//	MiscStringSearching.m
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

@implementation MiscString(Searching)

// This category is composed of methods which search a
// MiscString and return pointers to the start of specific
// substrings within the MiscString.

- (int)spotOf:(char)aChar
{
  return [self spotOf:aChar occurrenceNum:0 caseSensitive:YES];
}

- (int)spotOf:(char)aChar caseSensitive:(BOOL)sense
{
  return [self spotOf:aChar occurrenceNum:0 caseSensitive:sense];
}

- (int)spotOf:(char)aChar occurrenceNum:(int)n
{
  return [self spotOf:aChar occurrenceNum:n caseSensitive:YES];
}

- (int)rspotOf:(char)aChar
{
  return [self rspotOf:aChar occurrenceNum:0 caseSensitive:YES];
}

- (int)rspotOf:(char)aChar caseSensitive:(BOOL)sense
{
  return [self rspotOf:aChar occurrenceNum:0 caseSensitive:sense];
}

- (int)rspotOf:(char)aChar occurrenceNum:(int)n
{
  return [self rspotOf:aChar occurrenceNum:n caseSensitive:YES];
}

- (int)spotOf:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense
{
  int currnum = -1;
  int count = 0;
  
  if (n<0) return -1;
  
  while ((currnum < n) && (count < length)) {
    if (!sense) {
      if (NXToUpper(buffer[count]) == NXToUpper(aChar)) currnum++;
     }
    else {
      if (buffer[count] == aChar) currnum++;
     }
    count++;
   }
  if (currnum != n) return -1;
  return (count-1);
}

- (int)rspotOf:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense
{
  int currnum = -1;
  int count = length-1;
  
  if (n<0) return -1;
  
  while ((currnum < n) && (count >= 0)) {
    if (!sense) {
      if (NXToUpper(buffer[count]) == NXToUpper(aChar)) currnum++;
     }
    else {
      if (buffer[count] == aChar) currnum++;
     }
    count--;
   }
  if (currnum != n) return -1;
  return (count+1);
}

- (const char *)rindex:(char)aChar
{
	return [self rindex:aChar occurrenceNum:0 caseSensitive:YES];
}

- (const char *)rindex:(char)aChar occurrenceNum:(int)n
{
	return [self rindex:aChar occurrenceNum:n caseSensitive:YES];
}

- (const char *)rindex:(char)aChar caseSensitive:(BOOL)sense
{
	return [self rindex:aChar occurrenceNum:0 caseSensitive:sense];
}

- (const char *)rindex:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense
{
  int num;
  num = [self rspotOf:aChar occurrenceNum:n caseSensitive:sense];
  if (num == -1) return NULL;
  return buffer+num;
}

- (const char *)index:(char)aChar
{
	return [self index:aChar occurrenceNum:0 caseSensitive:YES];
}

- (const char *)index:(char)aChar occurrenceNum:(int)n
{
	return [self index:aChar occurrenceNum:n caseSensitive:YES];
}

- (const char *)index:(char)aChar caseSensitive:(BOOL)sense
{
	return [self index:aChar occurrenceNum:0 caseSensitive:sense];
}

- (const char *)index:(char)aChar occurrenceNum:(int)n caseSensitive:(BOOL)sense
{
  int num;
  num = [self spotOf:aChar occurrenceNum:n caseSensitive:sense];
  if (num==-1) return NULL;
  return buffer+num;
}

/* No longer used:
- (const char *)strstr:(const char *)subString
{
	if (!(buffer||subString)) return NULL;
	return strstr(buffer, subString);
}
*/

- (int)spotOfChars:(const char *)aString
{
	return [self spotOfChars:aString occurrenceNum:0 caseSensitive:YES];
}

- (int)spotOfChars:(const char *)aString caseSensitive:(BOOL)sense
{
	return [self spotOfChars:aString occurrenceNum:0 caseSensitive:sense];
}

- (int)spotOfChars:(const char *)aString occurrenceNum:(int)n
{
	return [self spotOfChars:aString occurrenceNum:n caseSensitive:YES];
}

- (int)spotOfChars:(const char *)aString occurrenceNum:(int)n
		caseSensitive:(BOOL)sense
{
	int currnum = -1;
	int count = 0;
	id tempStr;
 
	if (n < 0) return -1;
	tempStr = [MiscString newWithString:aString];
	while ((currnum < n) && (count < length)) {
		if ([tempStr spotOf:buffer[count] caseSensitive:sense] != -1)
			currnum++;
		count++;
	}
	[tempStr free];
	if (currnum != n) return -1;
	return (count - 1);
}

- (int)rspotOfChars:(const char *)aString
{
	return [self rspotOfChars:aString occurrenceNum:0 caseSensitive:YES];
}

- (int)rspotOfChars:(const char *)aString caseSensitive:(BOOL)sense
{
	return [self rspotOfChars:aString occurrenceNum:0 caseSensitive:sense];
}

- (int)rspotOfChars:(const char *)aString occurrenceNum:(int)n
{
	return [self rspotOfChars:aString occurrenceNum:n caseSensitive:YES];
}

- (int)rspotOfChars:(const char *)aString occurrenceNum:(int)n
		caseSensitive:(BOOL)sense
{
	int currnum = -1;
	int count = length - 1;
	id tempStr;
 
	if (n<0) return -1;
	tempStr = [[self class] newWithString:aString];
	while ((currnum < n) && (count >= 0)) {
		if ([tempStr spotOf:buffer[count] caseSensitive:sense] != -1)
			currnum++;
		count--;
	}
	if (currnum != n) return -1;
	return (count + 1);
}

- (const char *)rindexOfChars:(const char *)aString
{
	return [self rindexOfChars:aString occurrenceNum:0 caseSensitive:YES];
}

- (const char *)rindexOfChars:(const char *)aString caseSensitive:(BOOL)sense
{
	return [self rindexOfChars:aString occurrenceNum:0 caseSensitive:sense];
}

- (const char *)rindexOfChars:(const char *)aString occurrenceNum:(int)n
{
	return [self rindexOfChars:aString occurrenceNum:n caseSensitive:YES];
}

- (const char *)rindexOfChars:(const char *)aString occurrenceNum:(int)n
		caseSensitive:(BOOL)sense
{
	int num;
	num = [self rspotOfChars:aString occurrenceNum:n caseSensitive:sense];
	if (num == -1) return NULL;
	return (const char *)(buffer+num);
}

- (const char *)indexOfChars:(const char *)aString
{
	return [self indexOfChars:aString occurrenceNum:0 caseSensitive:YES];
}

- (const char *)indexOfChars:(const char *)aString caseSensitive:(BOOL)sense
{
	return [self indexOfChars:aString occurrenceNum:0 caseSensitive:sense];
}

- (const char *)indexOfChars:(const char *)aString occurrenceNum:(int)n
{
	return [self indexOfChars:aString occurrenceNum:n caseSensitive:YES];
}

- (const char *)indexOfChars:(const char *)aString occurrenceNum:(int)n
		caseSensitive:(BOOL)sense
{
	int num;
	num = [self spotOfChars:aString occurrenceNum:n caseSensitive:sense];
	if (num == -1) return NULL;
	return (const char *)(buffer+num);
}

- (BOOL) hasType:(int)type
{
  int i;
  
  for (i=0;i<length;i++) {
    if (type & MISC_UPPER)  if (NXIsUpper(buffer[i]))  return YES;
    if (type & MISC_LOWER)  if (NXIsLower(buffer[i]))  return YES;
    if (type & MISC_DIGIT)  if (NXIsDigit(buffer[i]))  return YES;
    if (type & MISC_XDIGIT) if (NXIsXDigit(buffer[i])) return YES;
    if (type & MISC_PUNCT)  if (NXIsPunct(buffer[i]))  return YES;
    if (type & MISC_ASCII)  if (NXIsAscii(buffer[i]))  return YES;
    if (type & MISC_CNTRL)  if (NXIsCntrl(buffer[i]))  return YES;
    if (type & MISC_PRINT)  if (NXIsPrint(buffer[i]))  return YES;
    if (type & MISC_SPACE)  if (NXIsSpace(buffer[i]))  return YES;
    if (type & MISC_GRAPH)  if (NXIsGraph(buffer[i]))  return YES;
   }
  return NO;
}

- (BOOL) isAllOfType:(int)type
{
  int i, j;

  if (length <= 0) return NO;  
  
  for (i=0;i<length;i++) {
    j = 0;
    if (type & MISC_UPPER)  j |= (NXIsUpper(buffer[i]));
    if (type & MISC_LOWER)  j |= (NXIsLower(buffer[i]));
    if (type & MISC_DIGIT)  j |= (NXIsDigit(buffer[i]));
    if (type & MISC_XDIGIT) j |= (NXIsXDigit(buffer[i]));
    if (type & MISC_PUNCT)  j |= (NXIsPunct(buffer[i]));
    if (type & MISC_ASCII)  j |= (NXIsAscii(buffer[i]));
    if (type & MISC_CNTRL)  j |= (NXIsCntrl(buffer[i]));
    if (type & MISC_PRINT)  j |= (NXIsPrint(buffer[i]));
    if (type & MISC_SPACE)  j |= (NXIsSpace(buffer[i]));
    if (type & MISC_GRAPH)  j |= (NXIsGraph(buffer[i]));
    if (!j) return NO;
   }
  return YES;
}

- (int)spotOfType:(int)type occurrenceNum:(int)n
{
  int i, currnum = -1;

  if (n < 0) return -1;

  for (i=0;(i < length) && (currnum < n);i++) {
    if (type & MISC_UPPER)  if (NXIsUpper(buffer[i]))  {currnum++; continue;}
    if (type & MISC_LOWER)  if (NXIsLower(buffer[i]))  {currnum++; continue;}
    if (type & MISC_DIGIT)  if (NXIsDigit(buffer[i]))  {currnum++; continue;}
    if (type & MISC_XDIGIT) if (NXIsXDigit(buffer[i])) {currnum++; continue;}
    if (type & MISC_PUNCT)  if (NXIsPunct(buffer[i]))  {currnum++; continue;}
    if (type & MISC_ASCII)  if (NXIsAscii(buffer[i]))  {currnum++; continue;}
    if (type & MISC_CNTRL)  if (NXIsCntrl(buffer[i]))  {currnum++; continue;}
    if (type & MISC_PRINT)  if (NXIsPrint(buffer[i]))  {currnum++; continue;}
    if (type & MISC_SPACE)  if (NXIsSpace(buffer[i]))  {currnum++; continue;}
    if (type & MISC_GRAPH)  if (NXIsGraph(buffer[i]))  {currnum++; continue;}
   }

  if (n == currnum) return i-1;
  return -1;
}


- (int)rspotOfType:(int)type occurrenceNum:(int)n
{
  int i, currnum = -1;

  if (n < 0) return -1;

  for (i=(length-1);(i >= 0) && (currnum < n);i--) {
    if (type & MISC_UPPER)  if (NXIsUpper(buffer[i]))  {currnum++; continue;}
    if (type & MISC_LOWER)  if (NXIsLower(buffer[i]))  {currnum++; continue;}
    if (type & MISC_DIGIT)  if (NXIsDigit(buffer[i]))  {currnum++; continue;}
    if (type & MISC_XDIGIT) if (NXIsXDigit(buffer[i])) {currnum++; continue;}
    if (type & MISC_PUNCT)  if (NXIsPunct(buffer[i]))  {currnum++; continue;}
    if (type & MISC_ASCII)  if (NXIsAscii(buffer[i]))  {currnum++; continue;}
    if (type & MISC_CNTRL)  if (NXIsCntrl(buffer[i]))  {currnum++; continue;}
    if (type & MISC_PRINT)  if (NXIsPrint(buffer[i]))  {currnum++; continue;}
    if (type & MISC_SPACE)  if (NXIsSpace(buffer[i]))  {currnum++; continue;}
    if (type & MISC_GRAPH)  if (NXIsGraph(buffer[i]))  {currnum++; continue;}
   }

  if (n == currnum) return i+1;
  return -1;
}

- (int)spotOfStr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  int currnum = -1, currspot = 0, len;
  char fchar;

  if (!str || (n < 0)) return -1;
  len = strlen(str);
  if (len == 0) return -1;  //Can't have 0 for len...
  fchar = (sense)? str[0]:NXToUpper(str[0]);

  while ((currnum < n) && (currspot <= (length-len))) {
    //search for a potential start of match
    while ((currspot <= (length-len)) && (fchar != ((sense)? buffer[currspot]:NXToUpper(buffer[currspot]))))
      currspot++;
    //check for match
    if (!NXOrderStrings((unsigned char *)str,(unsigned char *)buffer+currspot,sense,len,orderTable)) {
      currnum++;
      //if we've found the nth, return the spot
      if (currnum == n) return currspot;
      //if overlap is YES, the next match could potentially be at the next
      //character.  If NO, then continue searching after the matched portion.
      if (overlap) currspot++;
      else currspot += len;
    }
    else currspot++;   // didn't match, keep looking
  }
  //nth occurrence was not found
  return -1;
}


- (int)rspotOfStr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  int num = [self numOf:str caseSensitive:sense overlap:overlap];
  if ((num <= 0) || (n < 0)) return -1;
  return [self spotOfStr:str occurrenceNum:num-1-n caseSensitive:sense overlap:overlap];
}


- (int)spotOfString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  if (![sender respondsTo:@selector(stringValue)]) return -1;
  return [self spotOfStr:[sender stringValue] occurrenceNum:n caseSensitive:sense overlap:overlap];
}

- (int)rspotOfString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  if (![sender respondsTo:@selector(stringValue)]) return -1;
  return [self rspotOfStr:[sender stringValue] occurrenceNum:n caseSensitive:sense overlap:overlap];
}

- (const char *)strstr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  int spot = [self spotOfStr:str occurrenceNum:n caseSensitive:sense overlap:overlap];

  if (spot < 0) return NULL;
  return (const char *)buffer+spot;
}


- (const char *)strString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  if (![sender respondsTo:@selector(stringValue)]) return NULL;
  return [self strstr:[sender stringValue] occurrenceNum:n caseSensitive:sense overlap:overlap];
}

- (const char *)rstrstr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  int spot = [self rspotOfStr:str occurrenceNum:n caseSensitive:sense overlap:overlap];

  if (spot < 0) return NULL;
  return (const char *)buffer+spot;
}


- (const char *)rstrString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  if (![sender respondsTo:@selector(stringValue)]) return NULL;
  return [self rstrstr:[sender stringValue] occurrenceNum:n caseSensitive:sense overlap:overlap];
}

- (int)numOfType:(int)type
{
  int i, currnum = 0;

  for (i=0;i<length;i++) {
    if (type & MISC_UPPER)  if (NXIsUpper(buffer[i]))  {currnum++; continue;}
    if (type & MISC_LOWER)  if (NXIsLower(buffer[i]))  {currnum++; continue;}
    if (type & MISC_DIGIT)  if (NXIsDigit(buffer[i]))  {currnum++; continue;}
    if (type & MISC_XDIGIT) if (NXIsXDigit(buffer[i])) {currnum++; continue;}
    if (type & MISC_PUNCT)  if (NXIsPunct(buffer[i]))  {currnum++; continue;}
    if (type & MISC_ASCII)  if (NXIsAscii(buffer[i]))  {currnum++; continue;}
    if (type & MISC_CNTRL)  if (NXIsCntrl(buffer[i]))  {currnum++; continue;}
    if (type & MISC_PRINT)  if (NXIsPrint(buffer[i]))  {currnum++; continue;}
    if (type & MISC_SPACE)  if (NXIsSpace(buffer[i]))  {currnum++; continue;}
    if (type & MISC_GRAPH)  if (NXIsGraph(buffer[i]))  {currnum++; continue;}
   }

  return currnum;
}


- (int)numOf:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  int currnum = 0, currspot = 0, len;
  char fchar;

  if (!str || ((len = strlen(str)) == 0)) return 0;
  fchar = (sense)? str[0]:NXToUpper(str[0]);

  while (currspot <= (length-len)) {
    while ((currspot <= (length-len)) && (fchar != ((sense)? buffer[currspot]:NXToUpper(buffer[currspot]))))
      currspot++;
    if (!NXOrderStrings((unsigned char *)str,(unsigned char *)buffer+currspot,sense,len,orderTable)) {
      currnum++;
      if (overlap) currspot++;
      else currspot += len;
     }
    else currspot++;
   }

  return currnum;
}


- (int)numOfString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{
  if (![sender respondsTo:@selector(stringValue)]) return 0;
  return [self numOf:[sender stringValue] caseSensitive:sense overlap:overlap];
}


/*******************************************************************/
/**************   Convenience methods ******************************/
/*******************************************************************/


- (int)spotOfStr:(const char *)str
{ return [self spotOfStr:str occurrenceNum:0 caseSensitive:YES overlap:NO]; }

- (int)spotOfStr:(const char *)str occurrenceNum:(int)n
{ return [self spotOfStr:str occurrenceNum:n caseSensitive:YES overlap:NO]; }

- (int)spotOfStr:(const char *)str caseSensitive:(BOOL)sense
{ return [self spotOfStr:str occurrenceNum:0 caseSensitive:sense overlap:NO]; }

- (int)spotOfStr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense
{ return [self spotOfStr:str occurrenceNum:n caseSensitive:sense overlap:NO]; }

- (int)spotOfStr:(const char *)str overlap:(BOOL)overlap
{ return [self spotOfStr:str occurrenceNum:0 caseSensitive:YES overlap:overlap]; }

- (int)spotOfStr:(const char *)str occurrenceNum:(int)n overlap:(BOOL)overlap
{ return [self spotOfStr:str occurrenceNum:n caseSensitive:YES overlap:overlap]; }

- (int)spotOfStr:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{ return [self spotOfStr:str occurrenceNum:0 caseSensitive:sense overlap:overlap]; }




- (int)rspotOfStr:(const char *)str
{ return [self rspotOfStr:str occurrenceNum:0 caseSensitive:YES overlap:NO]; }

- (int)rspotOfStr:(const char *)str occurrenceNum:(int)n
{ return [self rspotOfStr:str occurrenceNum:n caseSensitive:YES overlap:NO]; }

- (int)rspotOfStr:(const char *)str caseSensitive:(BOOL)sense
{ return [self rspotOfStr:str occurrenceNum:0 caseSensitive:sense overlap:NO]; }

- (int)rspotOfStr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense
{ return [self rspotOfStr:str occurrenceNum:n caseSensitive:sense overlap:NO]; }

- (int)rspotOfStr:(const char *)str overlap:(BOOL)overlap
{ return [self rspotOfStr:str occurrenceNum:0 caseSensitive:YES overlap:overlap]; }

- (int)rspotOfStr:(const char *)str occurrenceNum:(int)n overlap:(BOOL)overlap
{ return [self rspotOfStr:str occurrenceNum:n caseSensitive:YES overlap:overlap]; }

- (int)rspotOfStr:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{ return [self rspotOfStr:str occurrenceNum:0 caseSensitive:sense overlap:overlap]; }



- (int)spotOfString:(id)sender
{ return [self spotOfString:sender occurrenceNum:0 caseSensitive:YES overlap:NO]; }

- (int)spotOfString:(id)sender occurrenceNum:(int)n
{ return [self spotOfString:sender occurrenceNum:n caseSensitive:YES overlap:NO]; }

- (int)spotOfString:(id)sender caseSensitive:(BOOL)sense
{ return [self spotOfString:sender occurrenceNum:0 caseSensitive:sense overlap:NO]; }

- (int)spotOfString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense
{ return [self spotOfString:sender occurrenceNum:n caseSensitive:sense overlap:NO]; }

- (int)spotOfString:(id)sender overlap:(BOOL)overlap
{ return [self spotOfString:sender occurrenceNum:0 caseSensitive:YES overlap:overlap]; }

- (int)spotOfString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap
{ return [self spotOfString:sender occurrenceNum:n caseSensitive:YES overlap:overlap]; }

- (int)spotOfString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{ return [self spotOfString:sender occurrenceNum:0 caseSensitive:sense overlap:overlap]; }



- (int)rspotOfString:(id)sender
{ return [self rspotOfString:sender occurrenceNum:0 caseSensitive:YES overlap:NO]; }

- (int)rspotOfString:(id)sender occurrenceNum:(int)n
{ return [self rspotOfString:sender occurrenceNum:n caseSensitive:YES overlap:NO]; }

- (int)rspotOfString:(id)sender caseSensitive:(BOOL)sense
{ return [self rspotOfString:sender occurrenceNum:0 caseSensitive:sense overlap:NO]; }

- (int)rspotOfString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense
{ return [self rspotOfString:sender occurrenceNum:n caseSensitive:sense overlap:NO]; }

- (int)rspotOfString:(id)sender overlap:(BOOL)overlap
{ return [self rspotOfString:sender occurrenceNum:0 caseSensitive:YES overlap:overlap]; }

- (int)rspotOfString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap
{ return [self rspotOfString:sender occurrenceNum:n caseSensitive:YES overlap:overlap]; }

- (int)rspotOfString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{ return [self rspotOfString:sender occurrenceNum:0 caseSensitive:sense overlap:overlap]; }

- (const char *)strstr:(const char *)str
{ return [self strstr:str occurrenceNum:0 caseSensitive:YES overlap:NO]; }

- (const char *)strstr:(const char *)str occurrenceNum:(int)n
{ return [self strstr:str occurrenceNum:n caseSensitive:YES overlap:NO]; }

- (const char *)strstr:(const char *)str caseSensitive:(BOOL)sense
{ return [self strstr:str occurrenceNum:0 caseSensitive:sense overlap:NO]; }

- (const char *)strstr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense
{ return [self strstr:str occurrenceNum:n caseSensitive:sense overlap:NO]; }

- (const char *)strstr:(const char *)str overlap:(BOOL)overlap
{ return [self strstr:str occurrenceNum:0 caseSensitive:YES overlap:overlap]; }

- (const char *)strstr:(const char *)str occurrenceNum:(int)n overlap:(BOOL)overlap
{ return [self strstr:str occurrenceNum:n caseSensitive:YES overlap:overlap]; }

- (const char *)strstr:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{ return [self strstr:str occurrenceNum:0 caseSensitive:sense overlap:overlap]; }



- (const char *)rstrstr:(const char *)str
{ return [self rstrstr:str occurrenceNum:0 caseSensitive:YES overlap:NO]; }

- (const char *)rstrstr:(const char *)str occurrenceNum:(int)n
{ return [self rstrstr:str occurrenceNum:n caseSensitive:YES overlap:NO]; }

- (const char *)rstrstr:(const char *)str caseSensitive:(BOOL)sense
{ return [self rstrstr:str occurrenceNum:0 caseSensitive:sense overlap:NO]; }

- (const char *)rstrstr:(const char *)str occurrenceNum:(int)n caseSensitive:(BOOL)sense
{ return [self rstrstr:str occurrenceNum:n caseSensitive:sense overlap:NO]; }

- (const char *)rstrstr:(const char *)str overlap:(BOOL)overlap
{ return [self rstrstr:str occurrenceNum:0 caseSensitive:YES overlap:overlap]; }

- (const char *)rstrstr:(const char *)str occurrenceNum:(int)n overlap:(BOOL)overlap
{ return [self rstrstr:str occurrenceNum:n caseSensitive:YES overlap:overlap]; }

- (const char *)rstrstr:(const char *)str caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{ return [self rstrstr:str occurrenceNum:0 caseSensitive:sense overlap:overlap]; }


- (const char *)strString:(id)sender
{ return [self strString:sender occurrenceNum:0 caseSensitive:YES overlap:NO]; }

- (const char *)strString:(id)sender occurrenceNum:(int)n
{ return [self strString:sender occurrenceNum:n caseSensitive:YES overlap:NO]; }

- (const char *)strString:(id)sender caseSensitive:(BOOL)sense
{ return [self strString:sender occurrenceNum:0 caseSensitive:sense overlap:NO]; }

- (const char *)strString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense
{ return [self strString:sender occurrenceNum:n caseSensitive:sense overlap:NO]; }

- (const char *)strString:(id)sender overlap:(BOOL)overlap
{ return [self strString:sender occurrenceNum:0 caseSensitive:YES overlap:overlap]; }

- (const char *)strString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap
{ return [self strString:sender occurrenceNum:n caseSensitive:YES overlap:overlap]; }

- (const char *)strString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{ return [self strString:sender occurrenceNum:0 caseSensitive:sense overlap:overlap]; }



- (const char *)rstrString:(id)sender
{ return [self rstrString:sender occurrenceNum:0 caseSensitive:YES overlap:NO]; }

- (const char *)rstrString:(id)sender occurrenceNum:(int)n
{ return [self rstrString:sender occurrenceNum:n caseSensitive:YES overlap:NO]; }

- (const char *)rstrString:(id)sender caseSensitive:(BOOL)sense
{ return [self rstrString:sender occurrenceNum:0 caseSensitive:sense overlap:NO]; }

- (const char *)rstrString:(id)sender occurrenceNum:(int)n caseSensitive:(BOOL)sense
{ return [self rstrString:sender occurrenceNum:n caseSensitive:sense overlap:NO]; }

- (const char *)rstrString:(id)sender overlap:(BOOL)overlap
{ return [self rstrString:sender occurrenceNum:0 caseSensitive:YES overlap:overlap]; }

- (const char *)rstrString:(id)sender occurrenceNum:(int)n overlap:(BOOL)overlap
{ return [self rstrString:sender occurrenceNum:n caseSensitive:YES overlap:overlap]; }

- (const char *)rstrString:(id)sender caseSensitive:(BOOL)sense overlap:(BOOL)overlap
{ return [self rstrString:sender occurrenceNum:0 caseSensitive:sense overlap:overlap]; }

- (int)spotOfType:(int)type
{ return [self spotOfType:type occurrenceNum:0]; }

- (int)rspotOfType:(int)type
{ return [self rspotOfType:type occurrenceNum:0]; }

- (int)numOf:(const char *)str
{ return [self numOf:str caseSensitive:YES overlap:NO]; }

- (int)numOf:(const char *)str caseSensitive:(BOOL)sense
{ return [self numOf:str caseSensitive:sense overlap:NO]; }

- (int)numOf:(const char *)str overlap:(BOOL)overlap
{ return [self numOf:str caseSensitive:YES overlap:overlap]; }

- (int)numOfString:(id)sender
{ return [self numOfString:sender caseSensitive:YES overlap:NO]; }

- (int)numOfString:(id)sender caseSensitive:(BOOL)sense
{ return [self numOfString:sender caseSensitive:sense overlap:NO]; }

- (int)numOfString:(id)sender overlap:(BOOL)overlap
{ return [self numOfString:sender caseSensitive:YES overlap:overlap]; }

@end
