/***********************************************************************************************************************
MMBasic

Hardware_Includes.h

Defines the hardware aspects for DOS MMBasic.
  
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


#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)

#include "Version.h"
#include "Configuration.h"

void cmd_open(void);
void cmd_close(void);
//void cmd_files(void);
void cmd_mkdir(void);
void cmd_rmdir(void);
void cmd_chdir(void);
void cmd_kill(void);
void cmd_copy(void);
void cmd_name(void);
void cmd_exitmmb(void);
void cmd_system(void);
void cmd_cls(void);
void cmd_files(void);
void cmd_pause(void);
void cmd_timer(void);
void cmd_copyright(void);
void cmd_seek(void);
void cmd_library(void);

void fun_eof(void);
void fun_loc(void);
void fun_lof(void);
void fun_cwd(void);
void fun_errno(void);
void fun_inputstr(void);
void fun_mmfname(void);
void fun_dir(void);
void fun_date(void);
void fun_time(void);
void fun_timer(void);
void fun_type(void);

// global variables used in MMBasic but must be maintained outside of the interpreter
extern int MMerrno;
extern int ListCnt;
extern int MMCharPos;
extern char *StartEditPoint;
extern int StartEditChar;
extern int OptionErrorAbort;
extern int ExitMMBasicFlag;
extern char *InterruptReturn;
extern unsigned int _excep_peek;

#define VCHARS  25					// nbr of lines in the DOS box (used in LIST)
#define ClearExternalIO()			// same

#define FILENAME_LENGTH 12

extern char *ModuleTable[MAXMODULES];           // list of pointers to modules loaded in memory;
extern int NbrModules;                          // the number of modules currently loaded


#define NBRERRMSG 17				// number of file error messages

// console related I/O
int MMInkey(void);
int MMgetchar(void);
char MMputchar(char c);

// File related I/O
char MMfputc(char c, int fnbr);
int MMfgetc(int filenbr);
void MMfopen(char *fname, char *mode, int fnbr);
int MMfeof(int filenbr);
void MMfclose(int fnbr);
int FindFreeFileNbr(void);
void CloseAllFiles(void);
void MMgetline(int filenbr, char *p);

void CheckAbort(void);
void EditInputLine(void);

// empty functions used in MMBasic but must be maintained outside of the interpreter
void UnloadFont(int);
#define NBRFONTS 0

// for the watcom compiler
#if !defined(MSVCC)
#define fabsf fabs
#define atanf atan
#define cosf cos
#define expf exp
#define floorf floor
#define logf log
#define sinf sin
#define sqrtf sqrt
#define tanf tan
#endif

#if defined(MSVCC)
#define mkdir _mkdir
#define rmdir _rmdir
#define chdir _chdir
#define getcwd _getcwd
#define kbhit _kbhit
#define getch _getch
#define ungetch _ungetch
#define putch _putch
#endif
#endif

#define dp(...) {char s[140];sprintf(s,  __VA_ARGS__); MMPrintString(s); MMPrintString("\r\n");}



/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)


	{ "Open",		T_CMD,				0, cmd_open		},
	{ "Close",		T_CMD,				0, cmd_close	},
	{ "Mkdir",		T_CMD,				0, cmd_mkdir	},
	{ "Rmdir",		T_CMD,				0, cmd_rmdir	},
	{ "Chdir",		T_CMD,				0, cmd_chdir	},
	{ "Kill",		T_CMD,				0, cmd_kill		},
	{ "Copy",		T_CMD,				0, cmd_copy		},
	{ "Name",		T_CMD,				0, cmd_name		},
	{ "Quit",       T_CMD,				0, cmd_exitmmb	},
	{ "System",     T_CMD,				0, cmd_system   },
	{ "Cls",        T_CMD,				0, cmd_cls      },
	{ "Files",      T_CMD,				0, cmd_files    },
	{ "Pause",      T_CMD,				0, cmd_pause    },
	{ "Timer",      T_CMD | T_FUN,		0, cmd_timer    },
	{ "Copyright",  T_CMD,				0, cmd_copyright},
	{ "Seek",		T_CMD,				0, cmd_seek     },
	{ "Library",	T_CMD,				0, cmd_library	},


#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)
	{ "Eof(",		T_FUN | T_NBR,		0, fun_eof		},
	{ "Loc(",		T_FUN | T_NBR,		0, fun_loc		},
	{ "Lof(",		T_FUN | T_NBR,		0, fun_lof		},
	{ "Cwd$",		T_FNA | T_STR,		0, fun_cwd		},
	{ "As",			T_NA,				0, op_invalid	},
	{ "MM.Errno",	T_FNA | T_NBR,		0, fun_errno	},
	{ "Input$(",	T_FUN | T_STR,		0, fun_inputstr	},
	{ "MM.Fname$",	T_FNA | T_STR,		0, fun_mmfname	},
//	{ "Dir$(",		T_FUN | T_STR,		0, fun_dir		},
	{ "Date$",		T_FNA | T_STR,		0, fun_date		},
	{ "Time$",		T_FNA | T_STR,		0, fun_time		},
	{ "Timer",		T_FNA | T_NBR,		0, fun_timer	},
	{ "MM.Device$",	T_FNA  | T_STR,		0, fun_type	    },


#endif



