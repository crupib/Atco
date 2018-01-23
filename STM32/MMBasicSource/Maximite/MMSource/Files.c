/***********************************************************************************************************************
MMBasic

Files.c

Handles all the file input/output in MMBasic.

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

#include <p32xxxx.h>								// device specific defines
#include <plib.h>									// peripheral libraries
#include <stdlib.h>									// standard library functions
#include <string.h>									// string functions
#include <stdio.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

FSFILE *MMFilePtr[MAXOPENFILES];

int DefaultDrive = SDFS;

int FlashStatus = CLOSED;

int FlashEOF = false;
int OptionErrorAbort = true;
int MMerrno = 0;

unsigned short *ConvertToUTF16(char *p);
char *ChangeToDir(char *p);

int FlashFreeSpace(void);
void FlashOpenRead(char *s);
void FlashOpenWrite(char *s);
void FlashOpenAppend(char *s);
void FlashPutc(char c);
void FlashPutStr(char *s);
void FlashCloseRead(void);
void FlashCloseWrite(void);
char FlashGetc(void);
int FlashKill(char *fn);
struct structBlock *FindFlashBlock(char* fn, int block);
void FlashCopyRename(char *old, char *new, int rename);



//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////// ERROR HANDLING ////////////////////////////////////////////


/*****************************************************************************************
Mapping of errors reported by the Microchip FAT 16/32 file system to MMBasic file errors
*****************************************************************************************/
const int ErrorMap[34] = {			0, 	// 0  =   No error
									11, // 1  =   An erase failed
									1, 	// 2  =   No SD card found
									15, // 3  =   The disk is of an unsupported format
									15, // 4  =   The boot record is bad
									15, // 5  =   The file system type is unsupported
									15, // 6  =   An initialization error has occurred
									15, // 7  =   An operation was performed on an uninitialized device
									10, // 8  =   A bad read of a sector occurred
									11, // 9  =   Could not write to a sector
									15, // 10 =  Invalid cluster value
									6, 	// 11 =  Could not find the file on the device
									7, 	// 12 =  Could not find the directory
									10, // 13 =  File is corrupted
									0, 	// 14 =  No more files in this directory
									15, // 15 =  Could not load/allocate next cluster in file
									5, 	// 16 =  A specified file name is too long to use
									9, 	// 17 =  A specified filename already exists on the device
									5, 	// 18 =  Invalid file name
									12, // 19 =  Attempt to delete a directory with KILL
									4, 	// 20 =  All root directory entries are taken
									3, 	// 21 =  All clusters in partition are taken
									14, // 22 =  This directory is not empty yet, remove files before deleting
									15, // 23 =  The disk is too big to format as FAT16
									2, 	// 24 =  Card is write protected
									11, // 25 =  File not opened for the write
									11, // 26 =  File location could not be changed successfully
									10, // 27 =  Bad cache read
									15, // 28 =  FAT 32 - card not supported
									8, 	// 29 =  The file is read-only
									10, // 30 =  The file is write-only
									15, // 31 =  Invalid argument
									9, 	// 32 =  Too many files are already open
									15, // 33 =  Unsupported sector size
							};

/******************************************************************************************
Text for the file related error messages reported by MMBasic
******************************************************************************************/

const char *FErrorMsg[NBRERRMSG] = {	"No error",									// 0
										"SD card not found",						// 1
										"SD card is write protected",				// 2
										"No space on media",						// 3
										"All root directory entries are taken",		// 4
										"Invalid file or directory name",			// 5
										"Cannot find file",							// 6
										"Cannot find or create directory",			// 7
										"File is read only",						// 8
										"Cannot open file",							// 9
										"Cannot read from file",					// 10
										"Cannot write to file",						// 11
										"Not a file",								// 12
										"Not a directory",							// 13
										"Directory not empty",						// 14
										"Cannot access the SD card",				// 15
										"Flash memory write failure"				// 16
									};


int ErrorThrow(int e) {
	MMerrno = e;
	if(e == 15) SDCardRemoved = true;
	if(e > 0 && e < NBRERRMSG && OptionErrorAbort) error((char *)FErrorMsg[e]);
	return e;
}


int ErrorCheck(void) {
	int e;
	e = FSerror();
	if(e == 15) SDCardRemoved = true;
	if(e < 1 || e > 33) return e;
	return ErrorThrow(ErrorMap[e]);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////


/*******************************************************************************************
File related commands in MMBasic
================================
These are the functions responsible for executing the file related commands in MMBasic
They are supported by utility functions that are grouped at the end of this file

Each function is responsible for decoding a command
all function names are in the form cmd_xxxx() (for a basic command) or fun_xxxx() (for a
basic function) so, if you want to search for the function responsible for the LOCATE command
look for cmd_name

There are 4 items of information that are setup before the command is run.
All these are globals.

int cmdtoken	This is the token number of the command (some commands can handle multiple
			statement types and this helps them differentiate)

char *cmdline	This is the command line terminated with a zero char and trimmed of leading
			spaces.  It may exist anywhere in memory (or even ROM).

char *nextstmt	This is a pointer to the next statement to be executed.  The only thing a
			command can do with it is save it or change it to some other location.

char *CurrentLinePtr  This is read only and is set to NULL if the command is in immediate mode.

The only actions a command can do to change the program flow is to change nextstmt or
execute longjmp(mark, 1) if it wants to abort the program.

********************************************************************************************/



void cmd_open(void) {
	int fnbr, i;
	char *mode = NULL, *fname;
	char ss[3];														// this will be used to split up the argument line

	ss[0] = GetTokenValue("FOR");
	ss[1] = tokenvalue[TKN_AS];
	ss[2] = 0;
	{																// start a new block
		getargs(&cmdline, 5, ss);									// getargs macro must be the first executable stmt in a block
		fname = GetFileName(argv[0], NULL);

		// check if it is a serial port that we are opening and, if so, handle it as a special case
		if(argc == 3 && mem_equal(fname, "COM", 3) && fname[4] == ':' && fname[3] >= '0' && fname[3] <= '0' + NBR_SERIAL_PORTS) {
			i = (str_equal(argv[2], "CONSOLE")) ? 1 : 0;
			SerialOpen(fname, i);
			if(i == false) {
				// if it is NOT the console get the file number
				if(*argv[2] == '#') argv[2]++;
				fnbr = getinteger(argv[2]);
				if(fnbr < 1 || fnbr > 10) error("Invalid file number");
				if(MMFilePtr[fnbr - 1] != NULL) error("File number is already open");
				MMFilePtr[fnbr - 1] = (FSFILE *)(fname[3] - '0');
			}
			return;
		}

		if(argc != 5) error("Invalid Syntax");
		if(str_equal(argv[2], "OUTPUT"))
			mode = "w";
		else if(str_equal(argv[2], "APPEND"))
			mode = "a";
		else if(str_equal(argv[2], "INPUT"))
			mode = "r";
		else if(str_equal(argv[2], "RANDOM"))
			mode = "x";
		else
			error("Invalid file access mode");
		if(*argv[4] == '#') argv[4]++;
		fnbr = getinteger(argv[4]);
		MMfopen(fname, mode, fnbr);
	}
}



void cmd_close(void) {
	int i;
	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ",");				// getargs macro must be the first executable stmt in a block
	if((argc & 0x01) == 0) error("Invalid syntax");

	if(argc == 1 && str_equal(argv[0], "CONSOLE")) {
		SerialClose(SerialConsole);
		return;
	}

	MMerrno = 0;
	for(i = 0; i < argc; i += 2) {
		if(*argv[i] == '#') argv[i]++;
		MMfclose(getinteger(argv[i]));
	}
}


void fun_inputstr(void) {
	int nbr, fnbr;
	char *p;
	getargs(&ep, 3, ",");
	if(argc != 3) error("Invalid syntax");
	nbr = getinteger(argv[0]);
	if(nbr < 1 || nbr > MAXSTRLEN) error("Number out of bounds");
	if(*argv[2] == '#') argv[2]++;
	fnbr = getinteger(argv[2]);
	sret = GetTempStringSpace();									// this will last for the life of the command
	p = sret + 1;													// point to the start of the char array
	*sret = nbr;													// set the length of the returned string
	while(nbr) {
		if(MMfeof(fnbr)) break;
		*p++ = MMfgetc(fnbr);										// get the char and save in our returned string
		nbr--;
	}
	*sret -= nbr;													// correct if we get less than nbr chars
}



// search for a volume label, directory or file
// s$ = DIR$(fspec, VOL|DIR|FILE)		will return the first entry
// s$ = DIR$()							will return the next
// If s$ is empty then no (more) files found
void fun_dir(void) {
	static SearchRec file;
	int r, flags;
	char *p;

	getargs(&ep, 3, ",");
	if(argc == 2) error("Invalid syntax");

	flags = ATTR_HIDDEN | ATTR_SYSTEM | ATTR_READ_ONLY | ATTR_ARCHIVE;
	if(argc == 3) {
		if(checkstring(argv[2], "VOL"))
			flags = ATTR_VOLUME;
		else if(checkstring(argv[2], "DIR"))
			flags = ATTR_DIRECTORY;
		else if(checkstring(argv[2], "FILE"))
			flags = ATTR_HIDDEN | ATTR_SYSTEM | ATTR_READ_ONLY | ATTR_ARCHIVE;
		else
			error("Invalid flag specification");
	}

	if(!InitSDCard()) ErrorThrow(1);								// setup the SD card
	SDActivityLED = SDActivityTime;
	if(argc > 0) {
		// this must be the first call eg:  DIR$("*.*", FILE)
		p = getCstring(argv[0]);
		if(GetDrive(p) == FLASHFS) error("Command not valid on A:");
		p = GetFName(p);
		r = FindFirst(p, flags, &file);
	} else
		// this is a subsequent call for more files
		r = FindNext(&file);

	sret = GetTempStringSpace();									// this will last for the life of the command
	if(r) return;													// no more file names so return empty
	ErrorCheck();

	#if defined(SUPPORT_LFN)
		if(file.utf16LFNfoundLength == 0)
			strcpy(sret, file.filename);
		else {
			int i;
			for(i = 0; i < file.utf16LFNfoundLength; i++)
				sret[i] = (char) file.utf16LFNfound[i];
			sret[i] = 0;
		}
	#else
			strcpy(sret, file.filename);
	#endif

	CtoM(sret);														// convert to a MMBasic style string
}



void cmd_mkdir(void) {
	char *p;

	p = GetFileName(cmdline, NULL);										// get the directory name and convert to a standard C string
	if(GetDrive(p) == FLASHFS) error("Command not valid on A:");
	if(!InitSDCard()) return;
	SDActivityLED = SDActivityTime;
	#if defined(SUPPORT_LFN)
		wFSmkdir(ConvertToUTF16(p));
	#else
		FSmkdir(p);
	#endif
	ErrorCheck();
}



void cmd_rmdir(void){
	char *p;

	p = GetFileName(cmdline, NULL);										// get the directory name and convert to a standard C string
	if(GetDrive(p) == FLASHFS) error("Command not valid on A:");
	if(!InitSDCard()) return;
	SDActivityLED = SDActivityTime;
	#if defined(SUPPORT_LFN)
		wFSrmdir(ConvertToUTF16(p), false);
	#else
		FSrmdir(p, false);
	#endif
	ErrorCheck();
}



void cmd_chdir(void){
	char *p;

	p = GetFileName(cmdline, NULL);										// get the directory name and convert to a standard C string
	if(GetDrive(p) == FLASHFS) error("Command not valid on A:");
	if(!InitSDCard()) return;
	SDActivityLED = SDActivityTime;
	#if defined(SUPPORT_LFN)
		if(strcmp(p, "\\") == 0 || strcmp(p, "..") == 0)
			FSchdir(p);
		else
			wFSchdir(ConvertToUTF16(p));
	#else
		FSchdir(p);
	#endif
	ErrorCheck();
}




void fun_eof(void) {
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fret = (float)MMfeof(getinteger(argv[0]));
}



void fun_loc(void) {
	int fnbr;
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	if(MMFilePtr[fnbr] <= (FSFILE *)NBR_SERIAL_PORTS)
		fret = (float)SerialRxStatus((int)MMFilePtr[fnbr]);
	else
		fret = (float)(MMFilePtr[fnbr]->seek + 1);
}

    int iiii;


void fun_lof(void) {
	int fnbr;
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	if(MMFilePtr[fnbr] <= (FSFILE *)NBR_SERIAL_PORTS)
		fret = (float)com1_buf_size - SerialTxStatus((int)MMFilePtr[fnbr]);
	else
		fret = (float)MMFilePtr[fnbr]->size;
}



void fun_cwd(void) {
	MMerrno = 0;
	if(DefaultDrive == FLASHFS) {
    	sret = GetTempStringSpace();								// this will last for the life of the command
		sret[0] = 3; sret[1] = 'A'; sret[2] = ':'; sret[3] = '\\';  // this is a MMBasic string
	}
	else
		sret = CtoM(MMgetcwd());
}



void cmd_kill(void){
	char *p;
	int err;

	p = GetFileName(cmdline, NULL);									// get the file name (can be non quoted)

	if(GetDrive(p) == FLASHFS)
		FlashFileKill(GetFName(p));
	else {
		if(!InitSDCard()) return;
		p = ChangeToDir(p);
		if(!*p) { ChangeToDir(NULL); ErrorThrow(5); return; }
		if(!SDCheckFileName(p)) { ErrorThrow(6); return; }
		SDActivityLED = SDActivityTime;
	#if defined(SUPPORT_LFN)
		wFSremove(ConvertToUTF16(p));
	#else
		FSremove(p);
	#endif
		if((err = FSerror()) != 0) {
			ChangeToDir(NULL);
			ErrorThrow(ErrorMap[err]);
			return;
		}

		ChangeToDir(NULL);
		ErrorCheck();
	}
}



void cmd_name(void) {
	FSFILE *fp;
	char *old, *new, ss[2];
	ss[0] = tokenvalue[TKN_AS];										// this will be used to split up the argument line
	ss[1] = 0;
	{																// start a new block
		getargs(&cmdline, 3, ss);									// getargs macro must be the first executable stmt in a block
		if(argc != 3) error("Invalid syntax");
        old = GetFileName(argv[0], NULL);                           // get the old file name (does not have to use quote marks in immediate mode)
        new = GetFileName(argv[2], NULL);                           // get the new file name (ditto)
		if(GetDrive(old) == FLASHFS) {
			if(GetDrive(new) != FLASHFS) error("Cannot rename across drives");
			if(str_equal(old, new)) error("Old and new filenames are the same");
			FlashCopyRename(GetFName(old), GetFName(new), true);
		} else {
			if(GetDrive(new) != SDFS) error("Cannot rename across drives");
			if(str_equal(old, new)) error("Old and new filenames are the same");
			if(!InitSDCard()) return;
			if(!SDCheckFileName(GetFName(old))) { ErrorThrow(6); return; }
			if(SDCheckFileName(GetFName(new))) { ErrorThrow(9); return; }
		#if defined(SUPPORT_LFN)
			fp = wFSfopen(ConvertToUTF16(old), "r");
		#else
			fp = FSfopen(old, "r");
		#endif
			if(ErrorCheck() || fp == NULL) return;
			SDActivityLED = SDActivityTime;
		#if defined(SUPPORT_LFN)
			wFSrename(ConvertToUTF16(new), fp);
		#else
			FSrename(new, fp);
		#endif
			if(ErrorCheck()) return;
			FSfclose(fp);
		}
	}
}



void cmd_copy(void) {                                           // thanks to Bryan Rentoul for the contribution
    char *old, *new, ss[2], c;
    const int CBSIZE = 1024 * 2;
    char buf[CBSIZE];
    int n;
    int of, nf;

    ss[0] = tokenvalue[TKN_TO];                                 // this will be used to split up the argument line
    ss[1] = 0;

    getargs(&cmdline, 3, ss);                                   // getargs macro must be the first executable stmt in a block
    if(argc != 3) error("Invalid syntax");
    old = GetFileName(argv[0], NULL);                           // get the old file name (does not have to use quote marks in immediate mode)
    new = GetFileName(argv[2], NULL);                           // get the new file name (ditto)

    if((strchr(new, ':') != NULL) && (strlen(new) == 2)) {      // if only a dest drive letter given then append source name to blank (drive only) dest name.
        if(strrchr(old, '\\') != NULL)
            strcat(new, strrchr(old, '\\') + 1);
        else
            strcat(new, GetFName(old));
    }

    if(GetDrive(old) == GetDrive(new) && str_equal(GetFName(old), GetFName(new)))
    	error("Source and destination are the same");

    if(GetDrive(old) == FLASHFS && GetDrive(new) == FLASHFS) {
    	FlashCopyRename(GetFName(old), GetFName(new), false);
    	return;
    }

    of = FindFreeFileNbr();
    MMfopen(old, "r", of);
    if(MMerrno) return;

    nf = FindFreeFileNbr();
    MMfopen(new, "w", nf); 										// We'll just overwrite any existing file
    if(MMerrno) { MMfclose(of); return; }

    if(GetDrive(old) == SDFS && GetDrive(new) == SDFS)          // If both the source and destination are on the SD card
        do {                                                    // use the fast copy method
        	SDActivityLED = SDActivityTime;
            n = FSfread(buf, 1, CBSIZE, MMFilePtr[of - 1]);
            if(!FSfeof(MMFilePtr[of - 1]) && ErrorCheck()) return;
            CheckAbort();
        	SDActivityLED = SDActivityTime;
            FSfwrite(buf, 1, n, MMFilePtr[nf - 1]);
            if(ErrorCheck()) return;
            CheckAbort();
        } while(n == CBSIZE);
    else
        while(1) {                                              // otherwise use the old (slow) method
            if(MMfeof(of)) break;
            c = MMfgetc(of);
            MMfputc(c, nf);
        }

    MMfclose(of);
    MMfclose(nf);
}



void fun_errno(void) {
	fret = (float)MMerrno;
}


void cmd_drive(void){
	char *p;

	p = GetFileName(cmdline, NULL);
	makeupper(p);
	if(*p == 'B')
		DefaultDrive = SDFS;
	else
		if(*p == 'A')
			DefaultDrive = FLASHFS;
		else
			error("Unrecognised drive letter");
}


void cmd_seek(void) {
	int fnbr, idx;
	getargs(&cmdline, 5, ",");
	if(argc != 3) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10 || MMFilePtr[fnbr] < (FSFILE *)NBR_SERIAL_PORTS) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	idx = getinteger(argv[2]) - 1;
    FSfseek(MMFilePtr[fnbr], idx, SEEK_SET);
    if(FSerror() == 31)                                             // if the error is "invalid argument" it generally means seek beyond end of file
        ErrorThrow(10);                                             // so throw a "cannot read" error.  This could be made more informative
    else
        ErrorCheck();                                               // otherwise the normal error check
}


// The MM.DRIVE$ automatic variable
void fun_mmdrive(void) {
    sret = GetTempStringSpace();								    // this will last for the life of the command
	sret[0] = 2; sret[2] = ':';                                     // this is a MMBasic string
	if(DefaultDrive == FLASHFS)
		sret[1] = 'A';
	else
		sret[1] = 'B';
}


// The MM.FNAME$ automatic variable
void fun_mmfname(void) {
	char *tp;
	tp = GetTempStringSpace();										// this will last for the life of the command
	strcpy(tp, LastFile);											// get the string and save in a temp place
	CtoM(tp);														// convert to a MMBasic style string
	sret = tp;
}


#if defined(MMFAMILY)
int FLen;       // global that will be loaded with the file length by MMfopen() (this is a kludge - must be fixed at some time)
void cmd_library(void) {
    int fn, i;
    char *pPath, *pFName, *p, *pmem;
    char save_tknbuf[STRINGSIZE];

	p = cmdline;

	// This block of code handles the command:   LIBRARY LOAD filename
	if(*p == GetTokenValue("LOAD")) {
    	p++;                                                        // step over the token
    	pPath = getCstring(p);
    	pFName = strrchr(pPath, '\\') + 1;                          // get just the filename part of a possible path
    	if(pFName == (char *)1) pFName = strrchr(pPath, ':') + 1;
    	if(pFName == (char *)1) pFName = pPath;                     // no path, we were given just the file name
	    if(strchr(pFName, '.') == NULL) strcat(pFName, ".LIB");     // add the default extension if necessary
    	for(i = 0; i < NbrModules; i++)                             // scan the module table to see if it is already loaded
    	    if(str_equal(ModuleTable[i] + 4, pFName))
    	        return;                                             // and exit if already loaded
	    fn = FindFreeFileNbr();
	    MMfopen(pPath, "r", fn);                                    // test open the file and get the file length into FLen
    	MMfclose(fn);
    	pmem = getmemory(FLen + FILENAME_LENGTH + 5);               // get the memory
    	ModuleTable[NbrModules++] = pmem;                           // add this library to our list of modules
    	*((int *)pmem) = FLen;  pmem += 4;                          // put the size in first
    	memmove(pmem, pFName, FILENAME_LENGTH);                     // then copy in the file name
    	pmem += FILENAME_LENGTH + 1;
    	memmove(save_tknbuf, tknbuf, STRINGSIZE);                   // save tknbuf in case we are in command mode (megefile uses tknbuf)
    	mergefile(pPath, pmem);                                     // load the library
    	memmove(tknbuf, save_tknbuf, STRINGSIZE);                   // restore tknbuf
        PrepareProgram();                                           // build the global list of subs/funs
        return;
    }

	// this block of code handles the command:   LIBRARY UNLOAD filename
	if((p = checkstring(cmdline, "UNLOAD")) != NULL) {
    	pPath = getCstring(p);
    	pFName = strrchr(pPath, '\\') + 1;                          // get just the filename part of a possible path
    	if(pFName == (char *)1) pFName = strrchr(pPath, ':') + 1;
    	if(pFName == (char *)1) pFName = pPath;                     // no path, we were given just the file name
	    if(strchr(pFName, '.') == NULL) strcat(pFName, ".LIB");
    	for(i = 0; i < NbrModules; i++)                             // scan the module table to see if it is already loaded
    	    if(str_equal(ModuleTable[i] + 4, pFName)) {
        	    FreeHeap(ModuleTable[i]);                           // free the memory
        	    while(i < NbrModules) {
            	    ModuleTable[i] = ModuleTable[i + 1];            // delete the entry in the module table and close up the gap
            	    i++;
            	}
        	    NbrModules--;
        	    PrepareProgram();                                   // build the global list of subs/funs
        	    return;
    	    }
    	error("Library not loaded");
    }
    error("Invalid Syntax");
}
#endif



/*******************************************************************************************
********************************************************************************************

Utility routines for the file I/O commands in MMBasic

********************************************************************************************
********************************************************************************************/



// get a line from the keyboard or a file handle
// most of the keyboard input is handled by EditInputLine() but it will use this function
// if a line greater than he screen width is being entered.
// IMPORTANT: This will append to the buffer pointed to by p, so (if you don't want this)
//            make sure that the first char of p is zero before calling this.
void MMgetline(int filenbr, char *p) {
	int nbrchars;
	char c, *tp;

	nbrchars = strlen(p);											// the line might not be empty and we want to add to the end
	p += nbrchars;

	while(1) {

		CheckAbort();												// jump right out if CTRL-C

		if(filenbr != 0) {                                          // do NOT check for EOF on console input
    		// ignore EOF on the COM ports
    		if(MMFilePtr[filenbr - 1] != NULL && MMFilePtr[filenbr - 1] <= (FSFILE *)NBR_SERIAL_PORTS && SerialRxStatus((int)MMFilePtr[filenbr - 1]) == 0) continue;

    		if(MMfeof(filenbr)) break;									// end of file - stop collecting
        }

		c = MMfgetc(filenbr);

		if(filenbr == 0 && c >= F1 && c <= F12) {					// expand if a function key
			for(tp = FunKey[c - 0x91]; *tp; ) {
				if(++nbrchars > MAXSTRLEN) error("Line is too long");
				if(*tp == '\n') break;
				MMfputc(*tp, 0);
				*p++ = *tp++;
			}
			continue;
		}


		if(c == '\t') {												// expand tabs to spaces
			 do {
				if(++nbrchars > MAXSTRLEN) error("Line is too long");
				*p++ = ' ';
				if(filenbr == 0) MMfputc(' ', 0);
			} while(nbrchars % 8);
			continue;
		}

		if(c == '\b') {												// handle the backspace
			if(nbrchars) {
				if(filenbr == 0) MMfputs("\3\b \b", 0);
				nbrchars--;
				p--;
			}
			continue;
		}

		if(c == '\r') {
			continue;												// skip a lf (it should follow a cr)
		}

		if(c == '\n') {
			if(filenbr == 0) MMfputs("\2\r\n", 0);
			break;													// end of the line - stop collecting
		}

		if(isprint(c)) {
			if(filenbr == 0) MMfputc(c, 0);							// Maximite requires that chars be specificially echoed
		}
		if(++nbrchars > MAXSTRLEN) error("Line is too long");		// stop collecting if maximum length
		*p++ = c;													// save our char
	}
	*p = 0;
}



void inline CheckAbort(void) {
	if(MMAbort) {
		longjmp(mark, 1);
	}
}


// return a pointer to the part of the file spec immediately after the drive designator.
// For example  GetFName("A:FILE.BAS")  will return a pointer pointing to the F
// It will throw an error if the prefix is not a valid drive
char *GetFName(char *p) {
	if(*p && p[1] == ':') {
		if(toupper(p[0]) == 'B')
			return p + 2;
		else if(toupper(p[0]) == 'A')
			return p + 2;
		else
		    error("Unrecognised drive letter");
	}
	return p;
}



// return the drive designation
// this will:
//   - find the drive prefix (A: or B:) in the argument
//   - throw an error if the prefix is not a valid drive
//   - throw an error if the file name is empty or too long
//   - return with the drive designation (ie, FLASHFS or SDCARD)
//   - if the prefix is not specified this will return with the current default drive.
int GetDrive(char *p) {
	int fs = 0;
	char *pp;

	if(*p && p[1] == ':') {
		if(toupper(p[0]) == 'B')
			fs = SDFS;
		else
			if(toupper(p[0]) == 'A')
				fs = FLASHFS;
			else
				error("Unrecognised drive letter");
	} else
		fs = DefaultDrive;
	pp = GetFName(p);
	if(fs == FLASHFS && strlen(pp) > FILENAME_LENGTH) error("Invalid Filename");
	return fs;
}



// fname must be a standard C style string (not the MMBasic style)
void MMfopen(char *fname, char *mode, int fnbr) {
	int err;
	char *p;
	if(fnbr < 1 || fnbr > 10) error("Invalid file number");
	fnbr--;
	if(GetDrive(fname) == FLASHFS) {
		// Flash filesystem
		if(FlashStatus != CLOSED) error("Only one internal flash file can be open at a time");
		if(*mode == 'r') FlashOpenRead(GetFName(fname));
		if(*mode == 'w') FlashOpenWrite(GetFName(fname));
		if(*mode == 'a') error("Mode not valid on A:");
		if(*mode == 'x') error("Mode not valid on A:");
		MMFilePtr[fnbr] = (FSFILE *)FLASHFS;
	} else {
		// SD card filesystem
		if(!InitSDCard()) return;
		if(MMFilePtr[fnbr] != NULL) error("File number is already open");
		if(year > 2010) SetClockVars(year, month, day, hour, minute, second);

		p = ChangeToDir(fname);
		if(!*p) { ChangeToDir(NULL); ErrorThrow(5); return; }

		switch(*mode) {
			case 'r':	if(!SDCheckFileName(p)) {
							ChangeToDir(NULL);
							ErrorThrow(6);
							return;
						}
						break;
			case 'w':
			case 'a':
    		case 'x':	if(SD_WE) {
							ChangeToDir(NULL);
							ErrorThrow(2);
							return;
						} else
							SDCheckFileName(p);
						break;
		}

		SDActivityLED = SDActivityTime;

	#if defined(SUPPORT_LFN)
	    if(*mode == 'x')
    		MMFilePtr[fnbr] = wFSfopen(ConvertToUTF16(p), "a+");
    	else
    		MMFilePtr[fnbr] = wFSfopen(ConvertToUTF16(p), mode);
	#else
	    if(*mode == 'x')
    		MMFilePtr[fnbr] = FSfopen(p, "a+");
    	else
    		MMFilePtr[fnbr] = FSfopen(p, mode);
	#endif

		if((err = FSerror()) != 0) {
			ChangeToDir(NULL);
			ErrorThrow(ErrorMap[err]);
			return;
		}
		FLen = MMFilePtr[fnbr]->size;
		ChangeToDir(NULL);
		if(MMFilePtr[fnbr] == NULL) ErrorThrow(9);
	}
}




void MMfclose(int fnbr) {
	if(fnbr < 1 || fnbr > 10) error("Invalid file number");
	fnbr--;
	if(MMFilePtr[fnbr] != NULL && MMFilePtr[fnbr] <= (FSFILE *)NBR_SERIAL_PORTS)
		SerialClose((int)MMFilePtr[fnbr]);
	else if((int)MMFilePtr[fnbr] == FLASHFS) {
		// Flash filesystem
		if(FlashStatus == OPENREAD)
			FlashCloseRead();
		else if(FlashStatus == OPENWRITE)
			FlashCloseWrite();
	} else {
		// SD card filesystem
		if(!InitSDCard()) return;
		if(MMFilePtr[fnbr] == NULL) error("File number is not open");
		if(year > 2010) SetClockVars(year, month, day, hour, minute, second);
		SDActivityLED = SDActivityTime;
		FSfclose(MMFilePtr[fnbr]);
		MMFilePtr[fnbr] = NULL;
		ErrorCheck();
	}
	MMFilePtr[fnbr] = NULL;
}



char MMfgetc(int fnbr) {
	char ch;
	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return MMgetchar();
	fnbr--;
	if(MMFilePtr[fnbr] != NULL && MMFilePtr[fnbr] <= (FSFILE *)NBR_SERIAL_PORTS)
		return SerialGetchar((int)MMFilePtr[fnbr]);

	if((int)MMFilePtr[fnbr] == FLASHFS)  	 return FlashGetc();		// Flash filesystem

	// SD card filesystem
	if(!InitSDCard()) return 0;
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	SDActivityLED = SDActivityTime;
	if(FSfread(&ch, 1, 1, MMFilePtr[fnbr]) == 0) ch = 0xff;
	ErrorCheck();
	return ch;
}



char MMfputc(char c, int fnbr) {
	static char t;
	static int nbr;

	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return MMputchar(c);
	fnbr--;
	if(MMFilePtr[fnbr] != NULL && MMFilePtr[fnbr] <= (FSFILE *)NBR_SERIAL_PORTS)
		return SerialPutchar((int)MMFilePtr[fnbr], c);

	if((int)MMFilePtr[fnbr] == FLASHFS) {
		// Flash filesystem
		FlashPutc(c);
		return c;
	} else {
		// SD card filesystem
		t = c;
		nbr = fnbr;
		if(!InitSDCard()) return 0;
		if(MMFilePtr[fnbr] == NULL) error("File number is not open");
		SDActivityLED = SDActivityTime;
		if(FSfwrite(&t, 1, 1, MMFilePtr[nbr]) == 0) if(ErrorCheck() == 0) ErrorThrow(9);
		return t;
	}
}



int MMfeof(int fnbr) {
	int i;
	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return 0;
	fnbr--;
	if(MMFilePtr[fnbr] != NULL && MMFilePtr[fnbr] <= (FSFILE *)NBR_SERIAL_PORTS)
		return SerialRxStatus((int)MMFilePtr[fnbr]) == 0;

	if((int)MMFilePtr[fnbr] == FLASHFS) 	 return FlashEOF;		// Flash filesystem

	// SD card filesystem
	if(!InitSDCard()) return 0;
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	i = (FSfeof(MMFilePtr[fnbr]) != 0) ? -1 : 0;
	ErrorCheck();
	return i;
}





char *MMgetcwd(void) {
	char *b;
	b = GetTempStringSpace();
	if(!InitSDCard()) return b;
	FSgetcwd(b + 2, STRINGSIZE - 2);
	ErrorCheck();
	if(!MMerrno) { b[0] = 'B'; b[1] = ':'; }
	return b;
}



void CloseAllFiles(void) {
	int i, prev;
	if(year > 2010) SetClockVars(year, month, day, hour, minute, second);
	prev = OptionErrorAbort;
	OptionErrorAbort = false;										// don't abort on error
	for(i = 0; i < MAXOPENFILES; i++) {
		if(MMFilePtr[i] != NULL) MMfclose(i + 1);					// try and close a file
		MMFilePtr[i] = NULL;										// make sure that the entry is removed
	}
	FlashStatus = CLOSED;
	FlashEOF = false;
	OptionErrorAbort = prev;
}


int InitSDCard(void) {
	int i;
	ErrorThrow(0);				// reset mm.errno to zero
	if(SDCardRemoved == false) return true;
	for(i = 0; i < MAXOPENFILES; i++) MMFilePtr[i] = NULL;	            // make sure that the table is empty
	if(!MDD_MediaDetect()) { ErrorThrow(1); return false; }
	if(!FSInit())  { ErrorThrow(15); return false; }
	SDCardRemoved = false;
	SDActivityLED = SDActivityTime;
	return true;
}



// finds the first available free file number.  Throws an error if no free file numbers
int FindFreeFileNbr(void) {
	int i;
	for(i = 0; i < MAXOPENFILES; i++)
		if(MMFilePtr[i] == NULL) return i + 1;
	error("Too many files open");
	return 0;
}


#if defined(SUPPORT_LFN)
// convert an ASCII string to the UTF16 format
// required to use the MDD library functions which support long file names
unsigned short *ConvertToUTF16(char *p) {
	unsigned short *ip, *tp;
	tp = ip = (unsigned short *)GetTempStringSpace();

	if( p[1] == ':') {
		if(toupper(p[0]) == 'B')
			p += 2;
		else
			error("Unrecognised drive letter");
	}
	if(!*p || strlen(p) > 127) error("Invalid file name");
	while(*p) *tp++ = *p++;
	*tp = 0;
	return ip;
}
#endif


// this function takes a path (ie, "\dir1\dir2\file.bas") and:
//    1.  saves the current working directory in temporary buffer
//    2.  changes to the directory specified in the path
//    3.  returns with a pointer pointing to the file component
// if called with a NULL argument this function will change back to the previously saved directory
char *ChangeToDir(char *p) {
	static char *cwd = NULL;
	char *tp;

	// if the argument is NULL the caller wants to return to the previously saved directory
	if(p == NULL) {
		if(cwd != NULL)
		#if defined(SUPPORT_LFN)
			wFSchdir(ConvertToUTF16(cwd));
		#else
			FSchdir(cwd);
		#endif
		return NULL;
	}

	cwd = NULL;

	// adjust p to remove the drive letter if present
	if( p[1] == ':') {
		if(toupper(p[0]) == 'B')
			p += 2;
		else
			error("Unrecognised drive letter");
	}
	if(!*p) error("Invalid file or directory name");

	// search backwards for for the directory separator and set tp to point to it
	tp = p + strlen(p);
	while(tp != p && *tp != '\\') tp--;

	// if we end up pointing to the start of the string this could because of:
	//    1.  The path started at the root (ie, "\file.bas")
	//    2.  There is no directory component (ie, "file.bas")
	if(tp == p) {
		if(*p != '\\') return p;							// if there is no directory component we can return immediately pointing to the file component
		p = "\\";											// otherwise provide the root for the rest of the function to use
	}

	cwd = GetTempStringSpace();								// allocate some memory
	SDActivityLED = SDActivityTime;
	FSgetcwd(cwd, STRINGSIZE - 2);							// get the current directory
	if(ErrorCheck()) return "";
	*tp = 0;												// terminate the directory component in the function's argument
#if defined(SUPPORT_LFN)
	wFSchdir(ConvertToUTF16(p));							// change to the directory component
#else
	FSchdir(p);												// change to the directory component
#endif
	if(ErrorCheck()) return "";
	*tp = '\\';												// replace the character
	return tp + 1;											// return pointing to the file component of the path
}




// confirm that a file exists and get its case mapping.
// first this searches the file system looking for a file that has the same name regardless of the case
// if found it rewrites the argument with the file name (and case) as found on the card and returns true.
// if not found it will return false.
// This is needed because the MDD file system is case sensitive and we do not want that.
int SDCheckFileName(char *p) {
	SearchRec file;
	char fn[256];
	int r;
	#if defined(SUPPORT_LFN)
	int i;
	#endif

	if(!InitSDCard()) return false;
	r = FindFirst("*.*", ATTR_HIDDEN | ATTR_SYSTEM | ATTR_READ_ONLY | ATTR_DIRECTORY |ATTR_ARCHIVE, &file);
	SDActivityLED = SDActivityTime;
	while(r != -1) {
		SDActivityLED = SDActivityTime;
		if(FSerror()) {
			ErrorCheck();
			longjmp(mark, 1);
		}
	#if defined(SUPPORT_LFN)
		if(file.utf16LFNfoundLength == 0)
			strcpy(fn, file.filename);
		else {
			for(i = 0; i < file.utf16LFNfoundLength; i++)
				fn[i] = (char) file.utf16LFNfound[i];
			fn[i] = 0;
		}
	#else
			strcpy(fn, file.filename);
	#endif

		if(str_equal(fn, p)) {
			strcpy(p, fn);
			return true;
		}

		r = FindNext(&file);
	}

	return false;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// flash filesystem //////////////////////////////////////////////////
/*

Structure of the flash filesystem
=================================
This filesystem is designed to be simple to implement, work with the PIC32 flash memory and spread the wear
load on the flash.

Each page of flash memory is 4096 bytes.  A file will occupy one or more pages.
Each page has the following structure:
  short int (16 bits)  Data Length    (the length of the data in the last block, undefined if not the last block)
  char 			       Block Number   (01 = first block, 02 = second, etc)  00 means that the block is erased.
  char[15] 		       File Name      (an ascii string terminated with a zero byte, eg:  "FILE.BAS")
  unsigned word		   Generation     (starts at 0xff and counts down)
  char[4074]  		   Data		      (can be any character)

There is no file table or FAT in this filesystem.  Each block contains all the information needed (eg, the Block
Number and File Name).  The first block allocated to a file is given a Block Number of 01, the second 02, etc.
All the blocks in a file can be found by searching for the File Name (which is imbedded in each block) and then
checking if the Block Number matches the particular block being looked for.

The length of the file can be found by counting the blocks allocated.  Each block will contain PROG_DATA_LENGTH
bytes except for the last block which has the data length field (blen) written with the number of data bytes in
that particular block.  The length of the file can then be found using the following:
    file length = ((number_of_blocks - 1) * PROG_DATA_LENGTH)  +  blen_in_the_last_block
This calculation is made when a file is opened for input so that the end of file can be detected and reported.

When a file is erased its Data Length, Block Number and the first character of the file name are over written with
zeros.  This can be done without erasing as a write to flash can change bits to zero without an erase (the erase
sets all bits back to ones).

The Generation word is used for wear leveling.  Everytime a block is written this word is decremented and written
with the block.  When searching for a page to reuse the software must use a block with Block Number = 0x00 or 0xff
(which indicates that the block is free) and the highest Generation number.  This ensures that page erase will be
distributed across the whole of the flash memory.

When a free block is found it may need erasing.  The PIC32 flash memory can only be erased in pages of 4096 bytes
which is why the filesystem page size is the same.  When the page is erased all bits are set to one.  When writing
to flash bits are set to zero.  Each write must be in a word (4 bytes).  The write routines buffer each byte to be
written until 4 are accumulated then all 4 are written simultaneously.

********************************************************************************************************************************/


// note:  in the project -funsigned-char must be defined



//////////////////////////////////////////////////////////////////////////////////////////////
// Macro to reserve flash memory for saving/loading data and initialise to 0xFF's
// Note that “bytes” need to be a multiple of:-
//  - BYTE_PAGE_SIZE (and aligned that way) if you intend to erase
//  - BYTE_ROW_SIZE (and aligned that way) if you intend to write rows
//  - sizeof(int) if you intend to write words
#if  (__C32_VERSION__ < 200)
	#define NVM_ALLOCATE(name, align, bytes) volatile char name[(bytes)] \
	     __attribute__ ((aligned(align),section(".text,\"ax\",@progbits #"))) = \
	     { [0 ...(bytes)-1] = 0xFF }
#else
	#define NVM_ALLOCATE(name, align, bytes) volatile char name[(bytes)] \
	     __attribute__ ((aligned(align),space(prog),section(".nvm"))) = \
	     { [0 ...(bytes)-1] = 0xFF }
#endif

// allocate space in flash for program saves.  "Flash" is aligned on erasable page boundary
NVM_ALLOCATE(Flash, FLASH_PAGE_SIZE, FLASH_PAGE_SIZE * DRIVE_A_NBR_PAGES);


///////////////////////////////////////// globals ///////////////////////////////////////////

union {
	unsigned int wrd;
	char ch[4];
} WBuf;

int WBufCnt;
char *WBufPtr;
struct structBlock *CurrentBlock;
char *RPtr;
int RCnt;                                                           // this counts how many bytes have been written to the data portion of a block

struct structBlock **FileBlocks;
int FileLen;

void FlashWriteByte(char c) {
	int i;
	if(WBufPtr == NULL) return;
	WBuf.ch[WBufCnt % 4] = c;
	WBufCnt++;
	if((WBufCnt % 4) == 0) {										// if we have filled up a word (4 bytes)
		FlashWrite((void *)WBufPtr, WBuf.wrd, FLASH_WRITE_WORD);	// write the bytes
		if(MMerrno == 0) {
			for(i = 0; i < 4; i++) {								// verify the 4 bytes just written
				if(*WBufPtr++ != WBuf.ch[i])
					error("Write to flash memory failed to verify correctly");
			}
		}
	}
}



///////////////// utility functions specific to saving/loading program files //////////////////

struct structBlock *FindFlashBlock(char* fn, int block) {
	int i;
	struct structBlock *b;
	b = (struct structBlock *)Flash;

	for(i = 0; i < DRIVE_A_NBR_PAGES; i++, b++)
		if(b->bnbr == block && strncasecmp(fn, b->fname, FILENAME_LENGTH) == 0)
			return b;
	return NULL;
}



struct structBlock *FindFreeFlashBlock(void) {
	int t;
	int i;
	struct structBlock *b, *n;


	// first search for a block that has never been used
	b = (struct structBlock *)Flash;
	for(i = 0; i < DRIVE_A_NBR_PAGES; i++, b++)
		if(b->bnbr == 0xff) return b;				// and return it if found

	// find the erased block with the highest generation number
	t = 0; n = NULL;
	b = (struct structBlock *)Flash;
	for(i = 0; i < DRIVE_A_NBR_PAGES; i++, b++)
		if(b->bnbr == 0 && b->gnbr > t) {
			t = b->gnbr;											// save the generation number
			n = b;													// and save the pointer incase this is the one
		}
	if(n != NULL) FlashWrite((void *)n, 0, FLASH_PAGE_ERASE);		// erase the block
	return n;														// and return the block pointer (NULL if not enough space)
}



unsigned int GetNextGeneration(void) {
	volatile struct structBlock *b;
	unsigned int i, t;

	b = (volatile struct structBlock *)Flash;
	t = 0xffffffff;
	for(i = 0; i < DRIVE_A_NBR_PAGES; i++, b++)
		if(b->gnbr < t) t = b->gnbr;
	return t - 1;
}


///////////////////////////////////// intermediate routines for low level access ///////////////////////////

void FlashAllocateNewBlock(int bnbr, char *fn) {
	int i;
	MMerrno = 0;
	CurrentBlock = FindFreeFlashBlock();						    // find a free block
	if(CurrentBlock == NULL) {
    	FlashStatus = CLOSED; FlashEOF = false;                     // close the file
		ErrorThrow(3);											    // out of space
		return;
	}
	WBufPtr = (char *)CurrentBlock;
	WBufCnt = 0;
	FlashWriteByte(0xff); FlashWriteByte(0xff);					    // allocate space for the block length but do not write any significant data
	FlashWriteByte(bnbr);										    // write the block number
	for(i = 0; i < FILENAME_LENGTH + 1; i++)
		FlashWriteByte(toupper(fn[i]));						        // write the filename
	FlashWrite(WBufPtr, GetNextGeneration(), FLASH_WRITE_WORD);	    // write the generation number
	WBufPtr += 4;
	WBufCnt += 4;
	RCnt = 0;                                                       // this counts how many bytes have been written to the data portion of this block
}



void FlashWriteNextByte(char c) {
	if((WBufCnt % FLASH_PAGE_SIZE) == 0)
		FlashAllocateNewBlock(CurrentBlock->bnbr + 1, CurrentBlock->fname); // allocate a new block if we have filled the current one
	FlashWriteByte(c);
}


char FlashGetNextByte(void) {
	struct structBlock *b;
	MMerrno = 0;
	RCnt++;
	if(RCnt > FileLen) FlashEOF = true;
	if((RCnt % PROG_DATA_LENGTH) == 0) {
		b = FindFlashBlock(CurrentBlock->fname, CurrentBlock->bnbr + 1);
		if(b == NULL || b->blen == 0) {FlashEOF = true; return 0;}
		RPtr = b->dat;
	}
	return *RPtr++;
}


int FlashFreeSpace(void) {
	int i, sfree;
	volatile struct structBlock *b;

	MMerrno = 0;
	b = (struct structBlock *)Flash;
	for(sfree = i = 0; i < DRIVE_A_NBR_PAGES; i++, b++)
		if(b->bnbr == 0 || b->bnbr == 0xff) sfree += PROG_DATA_LENGTH;
	return sfree;
}


/////////////////////////////////////// routines used by the file I/O interface functions //////////////////////////////////


int FlashFileKill(char *fn) {
	int i, ok;
	struct structBlock *b;

	ok = false;
	for(i = 1; i < DRIVE_A_NBR_PAGES + 1; i++) {
		b = FindFlashBlock(fn, i);									// find any occurances of that filename
		if(b != NULL) {
			FlashWrite((char *)b, 0, FLASH_WRITE_WORD);
			ok = true;
		}
	}
	return ok;
}



void FlashOpenWrite(char *fn) {
	FlashFileKill(fn);											    // delete any file with the same name

	FlashAllocateNewBlock(1, fn); 					                // allocate the first block
	FlashEOF = false;
	FlashStatus = OPENWRITE;
    MMerrno = 0;
}



void FlashOpenRead(char *fn) {
	struct structBlock *b;
	b = (struct structBlock *)Flash;
	int i, j, max, maxlen = 0;

	FileBlocks = getmemory(DRIVE_A_NBR_PAGES * sizeof(char *));

	// load the cache with pointers to the blocks - used for fast seek
	for(max = i = 0; i < DRIVE_A_NBR_PAGES; i++, b++) {
		if(strncasecmp(fn, b->fname, FILENAME_LENGTH) == 0) {
			j = b->bnbr;
    	    FileBlocks[j - 1] = b;
    	    if(j > max) {
        	    max = j;
        	    maxlen = b->blen;
        	}
        }
    }
    FLen = FileLen = ((max - 1) * PROG_DATA_LENGTH ) + maxlen;

    CurrentBlock = FileBlocks[0];                                   // this is the first block
	if(CurrentBlock == NULL) {                                      // null means that it is not there
        FreeHeap(FileBlocks);
    	FlashStatus = CLOSED;
		FlashEOF = true;
		ErrorThrow(6);												// not found
		return;
	}

	RPtr = CurrentBlock->dat;										// next byte to read
	RCnt = 0;														// nbr of bytes read from this block
	FlashEOF = (RCnt >= FileLen);				                    // check for empty file and set EOF accordingly
	FlashStatus = OPENREAD;
    MMerrno = 0;
}



void FlashCopyRename(char *old, char *new, int rename) {
	int i, x, blocknbr;
	struct structBlock *b;
	char *p;

	if(FlashStatus != CLOSED) error("Only one flash file can be accessed at a time");
	if(FindFlashBlock(new, 1) != NULL) error("File name already exists");

	// copy the old to the new, page by page
	MMerrno = 0;
	blocknbr = 1;
	while((b = FindFlashBlock(old, blocknbr)) != NULL) {				// while there are pages in the file
		p = b->dat;														// point to the data in that page
		WBufPtr = (char *)FindFreeFlashBlock();							// point to the flash to be written to
		if(WBufPtr == NULL) {
        	FlashStatus = CLOSED; FlashEOF = false;                     // close the file
			ErrorThrow(3);												// error free block not found
			return;														// error return
		}
		WBufCnt = 0;													// start counting from the start of the page
		FlashWriteByte(b->blen); FlashWriteByte((b->blen) >> 8);        // write the block length
		FlashWriteByte(blocknbr);										// write the block number
		if(MMerrno) return;
		for(x = i = 0; i < FILENAME_LENGTH + 1; i++) {
			FlashWriteByte(toupper(new[x]));							// write the new file name
			if(new[x] != 0) x++;										// do not go beyond the terminating null char
			if(MMerrno) return;
		}
		FlashWrite(WBufPtr, GetNextGeneration(), FLASH_WRITE_WORD);		// write the generation number
		if(MMerrno) return;
		WBufPtr += 4; WBufCnt += 4;										// point to the data
		while(WBufCnt < FLASH_PAGE_SIZE) {
			FlashWriteByte(*p++);										// copy to the new page with the new filename
			if(MMerrno) return;
		}
		if(rename) FlashWrite((char *)b, 0, FLASH_WRITE_WORD);			// if rename erase the old page with the old filename
		if(MMerrno) return;
		blocknbr++;
	}
	if(blocknbr == 1) ErrorThrow(6);									// error file not found
}





// get a character
// end of file is returned by setting eof true
char FlashGetc(void) {
    if(FlashEOF) return 0;
    CurrentBlock = FileBlocks[RCnt/PROG_DATA_LENGTH];
    RPtr = CurrentBlock->dat + (RCnt % PROG_DATA_LENGTH);
	FlashEOF = (++RCnt >= FileLen);
	return *RPtr;
}



// write a char to the flash file
void FlashPutc(char c) {
	FlashWriteNextByte(c);
	RCnt++;
}



void FlashPutStr(char *s) {
	while(*s) FlashPutc(*s++);
}



void FlashCloseWrite(void) {
	MMerrno = 0;
	FlashStatus = CLOSED;
	while((WBufCnt % 4) != 0) FlashWriteByte(0xff);						// while the buffer has something in it write a padding char

	// load WBuf with the current length of the block and write
	WBuf.ch[0] = RCnt;
	WBuf.ch[1] = RCnt >> 8;
	WBuf.ch[2] = CurrentBlock->bnbr;
	WBuf.ch[3] = CurrentBlock->fname[0];
	FlashWrite((void *)CurrentBlock, WBuf.wrd, FLASH_WRITE_WORD);	    // write the four bytes

	FlashEOF = false;
}


void FlashCloseRead(void) {
    FreeHeap(FileBlocks);
	MMerrno = 0;
	FlashStatus = CLOSED;
	FlashEOF = false;
}


// a fast method of seeking to a position in the flash file system
void FlashSeek(int pos) {
    FlashEOF = (pos > FileLen);
    if(FlashEOF) pos = FileLen;
    RCnt = pos;
    CurrentBlock = FileBlocks[pos/PROG_DATA_LENGTH];
    RPtr = CurrentBlock->dat + (pos % PROG_DATA_LENGTH);
}



/////////////////////////////////////// routines used by both the flash and SD card file systems //////////////////////////////////




void cmd_files(void) {
	SearchRec file;
	int r, i, dirs, err, flashfs = false;
	char *p;
	int fcnt;
	char ts[STRINGSIZE] = "";

	#if defined(SUPPORT_LFN)
	s_flist *flist;
	#else
	s_flist flist[MAXFILES];
	#endif

	if(CurrentLinePtr) error("Invalid in a program");
	OptionErrorAbort = true;

	if(*cmdline)
		p = GetFileName(cmdline, NULL);
	else
		p = ts;

	// is this the flash filesystem?
	if((p[0] == 0 && DefaultDrive == FLASHFS) || (p[1] == ':' && toupper(p[0]) == 'A') || (p[1] != ':' && DefaultDrive == FLASHFS)) {
    	int i, j, max, maxlen;
    	struct structBlock *b, *bs;

    	flashfs = true;
		MMPrintString("A:\\\r\n");

    	b = (struct structBlock *)Flash;

    	// search through the flash looking for the start of a file (block number = 1)
    	for(fcnt = i = 0; i < DRIVE_A_NBR_PAGES; i++, b++) {
    		if(b->bnbr == 1) {
        		// now, scan the flash again - this time looking for files with the same file name
        		// and record the maximum block number found and the length of that block.
        		// this will give us the file size
            	bs = (struct structBlock *)Flash;
    	        for(max = maxlen = j = 0; j < DRIVE_A_NBR_PAGES; j++, bs++) {
            		if(strncasecmp(b->fname, bs->fname, FILENAME_LENGTH) == 0) {
                	    if(bs->bnbr > max) {
                    	    max = bs->bnbr;
                    	    maxlen = bs->blen;
                    	}
                    }
                }

        		// sort the file name into place in the array
        		*ts = 'F';                                          // all entries on the flash file system are files
        		strncpy(ts + 1, b->fname, FILENAME_LENGTH);
        		j = fcnt;
        		for(j = fcnt; j > 0; j--) {
        			if(strcmp(flist[j - 1].fn, ts) > 0)
        				flist[j] = flist[j - 1];
        			else
        				break;
        		}
                // add the details of this file to the array
        		strcpy(flist[j].fn, ts);
        		flist[j].fs = ((max - 1) * PROG_DATA_LENGTH ) + maxlen;
        		fcnt++;
    		}
    	}

	} else {
        // this is the SD card
        // use the Microchip functions to find each file
    	if(!*p) strcat(p, "*.*");										// add wildcard if needed
    	if(strchr(p, '.') == NULL && strchr(p, '*') == NULL && strchr(p, '?') == NULL)  strcat(p, "\\*.*");	// add wildcard if needed
    	if(!InitSDCard()) error((char *)FErrorMsg[1]);					// setup the SD card
    	p = ChangeToDir(p);
    	if(!*p) { ChangeToDir(NULL); error("Invalid search specification"); }

    	MMPrintString(MMgetcwd()); MMPrintString("\r\n");

    	#if defined(SUPPORT_LFN)
    	ClearRuntime(0);
    	flist = GetTempSpace(MAXFILES * sizeof(struct s_flist));
    	#endif

    	fcnt = 0;
    	r = FindFirst(p, ATTR_HIDDEN | ATTR_SYSTEM | ATTR_READ_ONLY | ATTR_DIRECTORY |ATTR_ARCHIVE, &file);

    	while(r != -1) {
    		SDActivityLED = SDActivityTime;

    		if((err = FSerror()) != 0) {
    			ChangeToDir(NULL);
    			error((char *)FErrorMsg[ErrorMap[err]]);
    		}

    		if(fcnt >= MAXFILES) {
    				ChangeToDir(NULL);
    				error("Too many files to list");
    		}

    		if(file.attributes & ATTR_DIRECTORY)
    			ts[0] = 'D';
    		else
    			ts[0] = 'F';

    	#if defined(SUPPORT_LFN)
    		if(file.utf16LFNfoundLength == 0)
    			strcpy(&ts[1], file.filename);
    		else {
    			for(i = 0; i < file.utf16LFNfoundLength; i++)
    				ts[i + 1] = (char) file.utf16LFNfound[i];
    			ts[i + 1] = 0;
    		}
    	#else
    			strcpy(&ts[1], file.filename);
    	#endif

    		// sort the file name into place in the array
    		for(i = fcnt; i > 0; i--) {
    			if(strcmp(flist[i - 1].fn, ts) > 0)
    				flist[i] = flist[i - 1];
    			else
    				break;
    		}
    		strcpy(flist[i].fn, ts);
    		flist[i].fs = file.filesize;
    		fcnt++;
    		r = FindNext(&file);
    	}
    }
	ListCnt = 2;
	for(i = dirs = 0; i < fcnt; i++) {
		if(flist[i].fn[0] == 'D') {
    		dirs++;
			sprintf(ts,"   <DIR>  %s\r\n", flist[i].fn + 1);
		}
		else
			sprintf(ts, "%8d  %s\r\n", flist[i].fs, flist[i].fn + 1);
		MMPrintString(ts);
		// check if it is more than a screenfull
		if(VRes > 0 && ListCnt >= (VRes / (fontHeight * fontScale)) && i < fcnt) {
			MMPrintString("PRESS ANY KEY ...");
			MMgetchar();
			MMPrintString("\r                 \r");
			ListCnt = 1;
		}
	}
	if(flashfs)
	    sprintf(ts, "%d file%s, %d bytes free\r\n", fcnt, (fcnt==1?"":"s"), FlashFreeSpace());
    else
	    sprintf(ts, "%d director%s, %d file%s\r\n", dirs, (dirs==1?"y":"ies"), fcnt - dirs, ((fcnt-dirs)==1?"":"s"));
	MMPrintString(ts);
	ChangeToDir(NULL);
	longjmp(mark, 1);							// jump back to the input prompt
}


#if 0
// for this command to work you must also uncomment the entry for FDump in the command table in Files.h
void cmd_fdump(void) {
	int i;
	struct structBlock *b;

	b = (struct structBlock *)Flash;

	// search through the flash looking for a valid file file
	for(i = 0; i < DRIVE_A_NBR_PAGES; i++, b++) {
		if(!(b->bnbr == 0 || b->bnbr == 0xff)) {
    		//dump(b->fname, 16);
    		dp("bnbr =%3d   blen =%3d  gnbr =%8u   fname = %s", b->bnbr, b->blen, b->gnbr, b->fname);
        }
    }
}
#endif
