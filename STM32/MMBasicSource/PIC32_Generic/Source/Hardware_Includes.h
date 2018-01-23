/***********************************************************************************************************************
MMBasic

Hardware_Includes.h

Defines the hardware aspects for PIC32-Generic MMBasic.
  
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

#include "Memory.h"
#include "Version.h"
#include "Configuration.h"

#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)

void cmd_copyright(void);

// global variables used in MMBasic but must be maintained outside of the interpreter
extern int MMerrno;
extern int ListCnt;
extern int MMCharPos;
extern char *StartEditPoint;
extern int StartEditChar;
extern int OptionErrorAbort;
extern int ExitMMBasicFlag;
extern char *InterruptReturn;
extern int OptionErrorAbort;
extern int MMerrno;
extern unsigned int _excep_peek;

// File related I/O.  These are all dummies and will throw an error if used
char MMfputc(char c, int fnbr);
int MMfgetc(int filenbr);
void MMfopen(char *fname, char *mode, int fnbr);
int MMfeof(int filenbr);
void MMfclose(int fnbr);
int FindFreeFileNbr(void);
void CloseAllFiles(void);
void MMgetline(int filenbr, char *p);


#define VCHARS  25					// nbr of lines in the terminal emulation box (used in LIST)
#define ClearExternalIO()			// same

// console related I/O
int MMInkey(void);
int MMgetchar(void);
char MMputchar(char c);

void CheckAbort(void);
void EditInputLine(void);

// empty functions used in MMBasic but must be maintained outside of the interpreter
void UnloadFont(int);
#define NBRFONTS 0

#endif


/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)


	{ "Copyright",  T_CMD,				0, cmd_copyright},


#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)

	{ "As",			T_NA,				0, op_invalid	},

#endif



