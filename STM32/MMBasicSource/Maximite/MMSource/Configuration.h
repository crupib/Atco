/***********************************************************************************************************************
Configuration.h

Include file that contains the configuration details for the Maximite family using MMBasic.
  
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

#define MAXVARLEN           32                      // maximum length of a variable name
#define MAXSTRLEN           255                     // maximum length of a string
#define STRINGSIZE          256                     // must be 1 more than MAXSTRLEN.  3 of these buffers are staticaly created
#define MAXOPENFILES        10                      // maximum number of open files
#define MAXDIM              8                       // maximum nbr of dimensions to an array

#define NBRPROGKEYS         12                      // number of programmable function keys
#define MAXKEYLEN           12                      // maximum length of a programmable function key string

#define MAXFORLOOPS         20                      // maximum nbr of nested for-next loops, each entry uses 17 bytes
#define MAXDOLOOPS          20                      // maximum nbr of nested do-loops, each entry uses 12 bytes
#define MAXGOSUB            100                     // maximum nbr of nested gosubs and defined subs/functs, each entry uses 4 bytes
#define MAX_MULTILINE_IF    20                      // maximum nbr of nested multiline IFs, each entry uses 8 bytes
#define MAXTEMPSTRINGS      64                      // maximum nbr of temporary strings allowed, each entry takes up 4 bytes
#define MAXSUBFUN           64                      // maximum nbr of defined subroutines or functions in a program. each entry takes up 4 bytes
#define MAXMODULES          8                       // maximum nbr of library modules that can be loaded simultaneously. each entry takes up 4 bytes
#define NBRSETTICKS         4                       // the number of SETTICK interrupts available

// define the maximum number of arguments to PRINT, INPUT, WRITE, ON, DIM, ERASE, DATA and READ
// each entry uses zero bytes.  The number is limited by the length of a command line
#define MAX_ARG_COUNT       50

#define MAXPROMPTLEN        49                                      // max length of a prompt incl the terminating null
