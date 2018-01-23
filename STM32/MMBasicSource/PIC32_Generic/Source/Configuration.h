/***********************************************************************************************************************
Configuration.h

Include file that contains the configuration details for the Maximite using MMBasic.
  
Copyright 2011 - 2013 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following 
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

************************************************************************************************************************/

// The main clock frequency for the chip
#define	CLOCKFREQ		(80000000L)				// This is set in in Configuration Bits.h

// The peripheral bus frequency
#define BUSFREQ			(CLOCKFREQ/1)			// This is set in the first few lines of main.c

#define nop	__asm__ ("NOP")

#define forever 1
#define true	1
#define false	0

#define dp(...) {char s[140];sprintf(s,  __VA_ARGS__); MMPrintString(s); MMPrintString("\r\n");}
    
#define BOOL_ALREADY_DEFINED

#define MAXVARLEN           32                      // maximum length of a variable name
#define MAXSTRLEN           255                     // maximum length of a string
#define STRINGSIZE          256                     // must be 1 more than MAXSTRLEN.  3 of these buffers are staticaly created
#define MAXDIM              8                       // maximum nbr of dimensions to an array

#define MAXFORLOOPS         10                      // maximum nbr of nested for-next loops, each entry uses 17 bytes
#define MAXDOLOOPS          10                      // maximum nbr of nested do-loops, each entry uses 12 bytes
#define MAXGOSUB            30                      // maximum nbr of nested gosubs and defined subs/functs, each entry uses 4 bytes
#define MAX_MULTILINE_IF    10                      // maximum nbr of nested multiline IFs, each entry uses 8 bytes
#define MAXTEMPSTRINGS      64                      // maximum nbr of temporary strings allowed, each entry takes up 4 bytes
#define MAXSUBFUN           32                      // maximum nbr of defined subroutines or functions in a program. each entry takes up 4 bytes


// define the maximum number of arguments to PRINT, INPUT, WRITE, ON, DIM, ERASE, DATA and READ
// each entry uses zero bytes.  The number is limited by the length of a command line
#define MAX_ARG_COUNT       50

#define MAXPROMPTLEN        49                                      // max length of a prompt incl the terminating null
