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

#if defined(SUPPORT_LFN)
	#define MAXFILES 100
	typedef struct ss_flist {
		char fn[256];
		int fs;
	} s_flist;
#else
	#define MAXFILES 200
	typedef struct ss_flist {
		char fn[13];
		int fs;
	} s_flist;
#endif

extern void MMgetline(int filenbr, char *p);
extern void MMfputs(char *p, int filenbr);
extern void inline CheckAbort(void) ;
extern void MMfopen(char *fname, char *mode, int fnbr);
extern void MMfclose(int fnbr);
extern char MMfgetc(int fnbr);
extern char MMfputc(char c, int fnbr);
extern int InitSDCard(void) ;
extern int SDCheckFileName(char *p);
extern void CloseAllFiles(void);
extern int MMfeof(int fnbr);
extern int FindFreeFileNbr(void);
extern void GetFileLength(int fnbr);
extern char *MMgetcwd(void);

extern int GetDrive(char *p);
extern char *GetFName(char *p);
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
extern int DefaultDrive;

extern int MMerrno;


//////////////////////////////////////// defines for flash storage //////////////////////////////////////////
// If MMBasic fails to link with an error:  "Link Error: Could not allocate section .dinit" this means that 
// you need to reduce the amount of flash memory allocated to the internal drive (A:)
// To do this adjust the define MONOCHROME_NBR_PAGES below.  Colour and the CAN bus require more memory
// so the #defines below adjust for that.  The result is DRIVE_A_NBR_PAGES which is used to allocate flash.

#define FLASH_PAGE_SIZE		        4096						        // size of each page of flash storage
#define MONOCHROME_NBR_PAGES        46                                  // size of flash storage used for files in pages on the monochrome Maximite

// The monochrome Maximite requires the least amount of flash for the firmware so it can have the most space allocated to the flash drive
// Other versions of the Maximite need more space for the firmware so here we subtract a fixed amount from the space allocated to the flash 
// drive and this amount depends on the type of hardware supported (colour, CAN and/or touch).
#if defined(__DEBUG)
    #define DRIVE_A_NBR_PAGES	(MONOCHROME_NBR_PAGES - 10)             // Debug needs a lot more flash for the firmware
#else 
    #if defined(INCLUDE_CAN)
        #if defined(COLOUR)
            #define DRIVE_A_NBR_PAGES	(MONOCHROME_NBR_PAGES - 8)      // Colour Maximite with CAN requires more flash for the firmware
        #else
            #define DRIVE_A_NBR_PAGES	(MONOCHROME_NBR_PAGES - 3)      // Monochrome Maximite with CAN also requires more flash for the firmware
        #endif
    #else
        #if defined(COLOUR)
            #if defined(TFT_MAXIMITE)
                #define DRIVE_A_NBR_PAGES	(MONOCHROME_NBR_PAGES - 10)  // TFT Maximite requires more flash for the firmware because of the colour and touch code
            #else
                #define DRIVE_A_NBR_PAGES	(MONOCHROME_NBR_PAGES - 5)  // Colour Maximite requires more flash for the firmware because of the colour support
            #endif
        #else
            #define DRIVE_A_NBR_PAGES	MONOCHROME_NBR_PAGES            // The Monochrome Maximite uses the least anount of flash
        #endif
    #endif
#endif

// the following defines are based on structBlock (defined below)
// in this struct gnbr MUST start on a word boundary.
#define FILENAME_LENGTH		12							// max length of a file name (not counting the terminating zero)
#define PROG_DATA_LENGTH			(FLASH_PAGE_SIZE - (FILENAME_LENGTH + 1) - (sizeof(char) * 3) - sizeof(unsigned int))

// structure of a flash filesystem page (or block)
struct structBlock {
	unsigned short blen;
	char bnbr;
	char fname[FILENAME_LENGTH + 1];
	unsigned int gnbr;
	char dat[PROG_DATA_LENGTH];
};

struct structBlock *FindFlashBlock(char* fn, int block) ;

#define FLASH_WRITE_WORD          0x4001
void FlashWrite(void *p, unsigned int wrd, unsigned int operation);


#endif
#endif


