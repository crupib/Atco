/***********************************************************************************************************************
MMBasic

functions.c

Handles all the functions in MMBasic.

Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

************************************************************************************************************************/

#include <stdio.h>
#include <math.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"


#define RADCONV 57.2957795130823229	/* Used when converting degrees -> radians and vice versa */


/********************************************************************************************************************************************
 basic functions
 each function is responsible for decoding a basic function
 all function names are in the form fun_xxxx() so, if you want to search for the function responsible for the ASC() function look for fun_asc

 There are 4 globals used by these functions:

 char *ep       This is a pointer to the argument of the function
                Eg, in the case of INT(35/7) ep would point to "35/7)"

 fret           Is the return value for a basic function that returns a float

 sret           Is the return value for a basic function that returns a string

 tret           Is the type of the return value.  normally this is set by the caller and is not changed by the function

 ********************************************************************************************************************************************/




void fun_abs(void) {
	fret = fabsf(getnumber(ep));
}



void fun_asc(void) {
	char *s;

	s = getstring(ep);
	if(*s == 0)
	    fret = 0;
	else
    	fret = (float)*(s + 1);
}




void fun_atn(void) {
	fret = atanf(getnumber(ep));
}




// return the binary representation of a number
void fun_bin(void) {
	int i, j, firstb;
	char *p;

	i = getinteger(ep);
	sret = GetTempStringSpace();									// this will last for the life of the command
	p = sret; firstb = false;
	for(j = 31; j >= 0; j--) {
		if(firstb || ((i >> j) & 1) || j == 0) {
			*p++ = '0' + ((i >> j) & 1);
			firstb = true;
		}
	}
	*p = 0;
	CtoM(sret);
}



void fun_chr(void) {
	int i;

	i = getinteger(ep);
	if(i < 0 || i > 0xff) error("Number out of bounds");
	sret = GetTempStringSpace();									// this will last for the life of the command
	sret[0] = 1;
	sret[1] = i;
}




void fun_cint(void) {
	fret = (float)getinteger(ep);
}



void fun_cos(void) {
	fret = cosf(getnumber(ep));
}


// convert radians to degrees.  Thanks to Alan Williams for the contribution
void fun_deg(void) {
	fret = (float)((double)getnumber(ep)*RADCONV);
}



void fun_exp(void) {
	fret = expf(getnumber(ep));
}



void fun_hex(void) {
	int i;

	i = getinteger(ep);
	sret = GetTempStringSpace();								// this will last for the life of the command
	sprintf(sret, "%X", i);
	CtoM(sret);
}



// syntax:  nbr = INSTR([start,] string1, string2)
//          find the position of string2 in string1 starting at start chars in string1
void fun_instr(void) {
	char *s1 = NULL, *s2 = NULL;
	int start = 0;
	getargs(&ep, 5, ",");

	if(argc == 5) {
		start = getinteger(argv[0]) - 1;
		s1 = getstring(argv[2]);
		s2 = getstring(argv[4]);
		if(start < 0 || start > MAXSTRLEN) error("Number out of bounds");
	}
	else if(argc == 3) {
		start = 0;
		s1 = getstring(argv[0]);
		s2 = getstring(argv[2]);
	}
	else
		error("Incorrect number of arguments");

	if(start > *s1 - *s2 + 1 || *s2 == 0)
		fret = 0;
	else {
		// find s2 in s1 using MMBasic strings
		int i;
		for(i = start; i < *s1 - *s2 + 1; i++) {
			if(memcmp(s1 + i + 1, s2 + 1, *s2) == 0) {
				fret = (float)(i + 1);
				return;
			}
		}
	}
	fret = 0;
}




void fun_int(void) {
	fret = floorf(getnumber(ep));
}



void fun_fix(void) {
	fret = (float)((int)(getnumber(ep)));
}




void fun_left(void) {
	int i;
    char *s;
	getargs(&ep, 3, ",");

	if(argc != 3) error("Incorrect argument count");
	s = GetTempStringSpace();                                       // this will last for the life of the command
	Mstrcpy(s, getstring(argv[0]));
	i = getinteger(argv[2]);
	if(i < 0 || i > MAXSTRLEN) error("Number out of bounds");
	if(i < *s) *s = i;                                              // truncate if it is less than the current string length
    sret = s;
}




void fun_right(void) {
	int nbr;
	char *s, *p1, *p2;
	getargs(&ep, 3, ",");

	if(argc != 3) error("Incorrect number of arguments");
	s = getstring(argv[0]);
	nbr = getinteger(argv[2]);
	if(nbr < 0 || nbr > MAXSTRLEN) error("Number out of bounds");
	if(nbr > *s) nbr = *s;											// get the number of chars to copy
	sret = GetTempStringSpace();									// this will last for the life of the command
	p1 = sret; p2 = s + (*s - nbr) + 1;
	*p1++ = nbr;													// inset the length of the returned string
	while(nbr--) *p1++ = *p2++;										// and copy the characters
}


void fun_len(void) {
	fret = (float)*getstring(ep);									// first byte is the length
}




void fun_log(void) {
    float f;
	f = getnumber(ep);
    if(f == 0) error("Divide by zero");
	fret = logf(f);
}


// syntax:  S$ = MID$(s, spos [, nbr])
void fun_mid(void) {
	char *s, *p1, *p2;
	int spos, nbr = 0, i;
	getargs(&ep, 5, ",");

	if(argc == 5) {													// we have MID$(s, n, m)
		nbr = getinteger(argv[4]);									// nbr of chars to return
	}
	else if(argc == 3) {											// we have MID$(s, n)
		nbr = MAXSTRLEN;											// default to all chars
	}
	else
		error("Incorrect number of arguments");

	s = getstring(argv[0]);											// the string
	spos = getinteger(argv[2]);										// the mid position
	if(nbr < 0 || nbr > MAXSTRLEN || spos < 1 || spos > MAXSTRLEN) error("Number out of bounds");

	sret = GetTempStringSpace();									// this will last for the life of the command
	if(spos > *s || nbr == 0)										// if the numeric args are not in the string
		return;														// return a null string
	else {
		i = *s - spos + 1;											// find how many chars remaining in the string
		if(i > nbr) i = nbr;										// reduce it if we don't need that many
		p1 = sret; p2 = s + spos;
		*p1++ = i;													// set the length of the MMBasic string
		while(i--) *p1++ = *p2++;									// copy the nbr chars required
	}
}




void fun_oct(void) {
	int i;

	i = getinteger(ep);
	sret = GetTempStringSpace();								// this will last for the life of the command
	sprintf(sret, "%o", i);
	CtoM(sret);
}



// Return the value of Pi.  Thanks to Alan Williams for the contribution
void fun_pi(void) {
	fret = (float)3.1415926;
}


// convert degrees to radians.  Thanks to Alan Williams for the contribution
void fun_rad(void) {
	fret = (float)((double)getnumber(ep)/RADCONV);
}



// generate a random number that is greater than or equal to 0 but less than 1
void fun_rnd(void) {
	fret = (float)rand()/((float)RAND_MAX + (float)RAND_MAX/1000000);
}


void fun_sgn(void) {
	float f;
	f = getnumber(ep);
	if(f > 0)
		fret = +1;
	else if(f < 0)
		fret = -1;
	else
		fret = 0;
}



void fun_sin(void) {
	fret = sinf(getnumber(ep));
}



void fun_sqr(void) {
	float f;
	f = getnumber(ep);
	if(f < 0) error("Negative argument to SQR()");
	fret = sqrtf(f);
}



void fun_tan(void) {
	fret = tanf(getnumber(ep));
}



void fun_val(void) {
	char *p, *t;
	p = getCstring(ep);
	if(*p == '&') {
		switch(*++p) {
			case 'h':
			case 'H': fret = (float)strtol(++p, &t, 16); break;     // note that we MUST supply a variable for the third ard of strol() due to a bug in C32 2.1
			case 'o':
			case 'O': fret = (float)strtol(++p, &t, 8); break;
			case 'b':
			case 'B': fret = (float)strtol(++p, &t, 2); break;
			default : fret = 0;
		}
	} else
		fret = (float)atof(p);
}


void fun_space(void) {
	int i;

	i = getint(ep, 0, MAXSTRLEN);
	sret = GetTempStringSpace();									// this will last for the life of the command
	memset(sret + 1, ' ', i);
	*sret = i;
}


void fun_str(void) {
	float f;

	f = getnumber(ep);
	sret = GetTempStringSpace();									// this will last for the life of the command
	sprintf(sret, "%G", (double)f);
	CtoM(sret);
}



void fun_string(void) {
	int i, j;
	char *p;
	getargs(&ep, 3, ",");
	if(argc != 3) error("Invalid syntax");

	i = getint(ep, 0, MAXSTRLEN);
	if(isdigit(*argv[2]))
		j = getint(argv[2], ' ', 0x7e);
	else {
		p = getstring(argv[2]);
		if(*p == 0) error("Zero length argument");
		j = p[1];
	}
	sret = GetTempStringSpace();									// this will last for the life of the command
	memset(sret + 1, j, i);
	*sret = i;
}



void fun_format(void) {
	char *p, *fmt;
	int inspec;

	getargs(&ep, 3, ",");
	if(argc%2 == 0) error("Invalid syntax");
	if(argc == 3)
		fmt = getCstring(argv[2]);
	else
		fmt = "%g";

	// check the format string for errors that might crash the CPU
	for(inspec = 0, p = fmt; *p; p++) {
		if(*p == '%') {
			inspec++;
			if(inspec > 1) error("Only one format specifier (%) allowed");
			continue;
		}

		if(inspec == 1 && (*p == 'g' || *p == 'G' || *p == 'f' || *p == 'e' || *p == 'E'))
			inspec++;

		if(inspec == 1 && !(isdigit(*p) || *p == '+' || *p == '-' || *p == '.' || *p == ' '))
			error("Illegal character in format specification");
	}
	if(inspec != 2) error("Format specification not found");
	sret = GetTempStringSpace();									// this will last for the life of the command
	sprintf(sret, fmt, getnumber(argv[0]));
	CtoM(sret);
}




void fun_ucase(void) {
	char *s, *p;
	int i;

	s = getstring(ep);
	p = sret = GetTempStringSpace();								// this will last for the life of the command
	i = *p++ = *s++;												// get the length of the string and save in the destination
	while(i--) {
		*p = toupper(*s);
		p++; s++;
	}
}


void fun_lcase(void) {
	char *s, *p;
	int i;

	s = getstring(ep);
	p = sret = GetTempStringSpace();								// this will last for the life of the command
	i = *p++ = *s++;												// get the length of the string and save in the destination
	while(i--) {
		*p = tolower(*s);
		p++; s++;
	}
}



void fun_peek(void) {
    unsigned int i;
    char *p;
	getargs(&ep, 3, ",");
	if(argc != 3) error("Invalid syntax");
	i = 0;
#if defined(MMFAMILY)
    #if defined(COLOUR)
        if(checkstring(argv[0], "RVIDEO"))
            i = (unsigned int)VideoBufRed;
        else if(checkstring(argv[0], "GVIDEO"))
            i = (unsigned int)VideoBufGrn;
        else if(checkstring(argv[0], "BVIDEO"))
            i = (unsigned int)VideoBufBlu;
        else
    #else
        if(checkstring(argv[0], "VIDEO"))
            i = (unsigned int)VideoBuf;
        else
    #endif   // COLOUR
    if(checkstring(argv[0], "KBUF"))
        i = (unsigned int)InpQueue;
    else if(checkstring(argv[0], "KHEAD"))
        i = (unsigned int)&InpQueueHead;
    else if(checkstring(argv[0], "KTAIL"))
        i = (unsigned int)&InpQueueTail;
    else
#endif
    if(checkstring(argv[0], "PROGMEM"))
        i = (unsigned int)PMemory;
	else if((p = checkstring(argv[0], "VAR")))
		i = (unsigned int)findvar(p, true);
    else if(checkstring(argv[0], "VARTBL"))
        i = (unsigned int)vartbl;
    else
        i = getinteger(argv[0]) << 16;

    if(i == 0) error("Invalid argument");
//    _excep_peek = true;
	fret = *(char *)(i + getinteger(argv[2]));
//	_excep_peek = false;
}



// function (which looks like a pre defined variable) to return the version number
// it pulls apart the VERSION string to generate the number
void fun_version(void){
	char *s;
	s = VERSION;
	fret = (float)(s[0] - '0') + ((float)atoi(&s[2])/100);
	if(isalpha(s[strlen(s) - 1])) fret += (float)(toupper(s[strlen(s) - 1]) - 'A' + 1) / (float)10000;
}



void fun_pos(void){
	fret = (float)MMCharPos;
}



void fun_tab(void) {
	int i;
	char *p;

	i = getinteger(ep);
	if(i < 1 || i > 255) error("Number out of bounds");
	sret = p = GetTempStringSpace();							// this will last for the life of the command
	if(MMCharPos > i) {
		i--;
		*p++ = '\r';
		*p++ = '\n';
	}
	else
		i -= MMCharPos;
	memset(p, ' ', i);
	p[i] = 0;
	CtoM(sret);
}




void fun_inkey(void){
    int i;

	sret = GetTempStringSpace();									// this buffer is automatically zeroed so the string is zero size

	i = MMInkey();
	if(i != -1) {
		sret[0] = 1;												// this is the length
		sret[1] = i;												// and this is the character
	}
}




// function (which looks like a pre defined variable) to return MM.CMDLINE$
// it uses the command line for a shortcut RUN (the + symbol) which was stored in tknbuf[]
void fun_cmdline(void){
	sret = GetTempStringSpace();									// this buffer is automatically zeroed so the string is zero size
	if(tknbuf[0] == GetCommandValue("RUN") + C_BASETOKEN && tknbuf[1] == 0 && tknbuf[2] == 0 && tknbuf[3] == 123)                        // magic numbers indicate valid data
	    strcpy(sret, &tknbuf[4]);                                   // copy the string
	CtoM(sret);
}
