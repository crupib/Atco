/***********************************************************************************************************************
MMBasic

file.h

Include file that contains the functions for handling file I/O in MMBasic.

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


/**********************************************************************************
 the C language function associated with commands, functions or operators should be
 declared here
**********************************************************************************/
#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
// format:
//      void cmd_???(void)
//      void fun_???(void)
//      void op_???(void)

void cmd_open(void);
void cmd_close(void);
void cmd_files(void);
void cmd_mkdir(void);
void cmd_rmdir(void);
void cmd_chdir(void);
void cmd_kill(void);
void cmd_copy(void);
void cmd_name(void);
void cmd_drive(void);
void cmd_seek(void);
void cmd_library(void);
void cmd_fdump(void);

void fun_cwd(void);
void fun_errno(void);
void fun_eof(void);
void fun_loc(void);
void fun_lof(void);
void fun_inputstr(void);
void fun_mmdrive(void);
void fun_mmfname(void);
void fun_dir(void);

#endif



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
	{ "Files",		T_CMD,				0, cmd_files	},
	{ "Mkdir",		T_CMD,				0, cmd_mkdir	},
	{ "Rmdir",		T_CMD,				0, cmd_rmdir	},
	{ "Chdir",		T_CMD,				0, cmd_chdir	},
	{ "Kill",		T_CMD,				0, cmd_kill		},
	{ "Copy",		T_CMD,				0, cmd_copy		},
	{ "Name",		T_CMD,				0, cmd_name		},
	{ "Drive",		T_CMD,				0, cmd_drive	},
	{ "Seek",		T_CMD,				0, cmd_seek     },
#if defined(MMFAMILY)
	{ "Library",		T_CMD,			0, cmd_library	},
#endif
//	{ "FDump",		T_CMD,				0, cmd_fdump     },

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
	{ "MM.Drive$",	T_FNA | T_STR,		0, fun_mmdrive	},
	{ "MM.Drive",	T_FNA | T_STR,		0, fun_mmdrive	},					// for users who forget that it is a string
	{ "MM.Fname$",	T_FNA | T_STR,		0, fun_mmfname	},
	{ "Dir$(",		T_FUN | T_STR,		0, fun_dir		},


#endif



#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
// General definitions used by other modules

#ifndef FILES_HEADER
#define FILES_HEADER



typedef struct { 
  WORD nr;
} F7FILE;

void ENABLE_USB(void);
void DISABLE_USB(void);





	#define MAXFILES 200
	typedef struct ss_flist {
		char fn[13];
		int fs;
	} s_flist;


extern void MMgetline(int filenbr, char *p);
extern void MMfputs(char *p, int filenbr);
extern void inline CheckAbort(void) ;
extern void MMfopen(char *fname, char *mode, int fnbr);
extern void MMfclose(int fnbr);
extern char MMfgetc(int fnbr);
extern char MMfputc(char c, int fnbr);
extern int InitSDCard(void) ;
extern int SDCheckFileName(char *p);
extern int USBCheckFileName(char *p);
extern void CloseAllFiles(void);
extern int MMfeof(int fnbr);
extern int FindFreeFileNbr(void);
extern int GetFileLength(int fnbr);
extern char *MMgetcwd(void);

extern int GetDrive(char *p);
extern char *GetFName(char *p);
extern int SetPathNameF7(char *fname, int drive);
extern int FlashFileKill(char *fn);
extern int FlashList(s_flist *flist);

// define the flash file status
#define CLOSED		0
#define OPENREAD	1
#define OPENWRITE	2
extern int FlashStatus; 

extern void FlashOpenMOD(char *s);
extern void FlashOpenRead(char *s);
extern void FlashCloseRead(void);
extern void FlashSeek(int pos);
extern char FlashGetc(void);

#define SDFS		8
#define FLASHFS		9
#define USBFS		10
extern int DefaultDrive;

extern int MMerrno;

#define FILENAME_LENGTH		12							// max length of a file name (not counting the terminating zero)



#endif
#endif


