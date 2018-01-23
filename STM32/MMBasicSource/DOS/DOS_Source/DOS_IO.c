/***********************************************************************************************************************
MMBasic

Files.c

Handles all the file input/output in MMBasic.
  
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

//#include "stdafx.h"
#include <stdlib.h>									// standard library functions
#include <stdio.h>
#include <string.h>
#include <direct.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


#include "..\..\MMBasic\MMBasic_Includes.h"
#include "Hardware_Includes.h"

FILE *MMFilePtr[MAXOPENFILES];
	 
int OptionErrorAbort = true;
int MMerrno = 0;

unsigned short int *ConvertToUTF16(char *p);
char *ChangeToDir(char *p);

char *MMgetcwd(void);


//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////// ERROR HANDLING ////////////////////////////////////////////



/******************************************************************************************
Text for the file related error messages reported by MMBasic
******************************************************************************************/
	
int ErrorThrow(int e) {
	MMerrno = e;
	if(e > 0 && e < 41 && OptionErrorAbort) error((char *)sys_errlist[e]);
	errno = 0;
	return e;
}	


int ErrorCheck(void) {
	int e;
	e = errno;
	errno = 0;
	if(e < 1 || e > 41) return e;
	return ErrorThrow(e);
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



void cmd_system(void) {
    int rc;

    rc = system(cmdline);
    if(rc != 0) {
      error("Command could not be run");
    }
}


void cmd_cls(void) {
    int rc;
    
	checkend(cmdline);
    rc = system("CLS");
    if(rc != 0) {
      error("Command could not be run");
    }
}


void cmd_files(void) {
    int rc;
    
	checkend(cmdline);
    rc = system("DIR");
    if(rc != 0) {
      error("Command could not be run");
    }
}


static int mSecTimer;

void fun_timer(void) {
	fret = (float)(clock() - mSecTimer);
}



// this is invoked as a command (ie, TIMER = 0)
// search through the line looking for the equals sign and step over it,
// evaluate the rest of the command and save in the timer
void cmd_timer(void) {
	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) error("Invalid syntax");
	mSecTimer = clock() - getinteger(++cmdline);
}


void cmd_pause(void) {
    int i;
    i = clock() + getinteger(cmdline);
    while(clock() < i);
}




void cmd_copyright(void) {
	MMPrintString("DOS MMBasic V" VERSION "\n");
	MMPrintString("Copyright (c) " YEAR " Geoff Graham.\n");
	MMPrintString("All Rights Reserved.  See http://mmbasic.com.\n\n");
	MMPrintString("This is free software and comes with absolutely\n");
	MMPrintString("no warranty implied or otherwise.\n\n");
	MMPrintString("Updates at http://mmbasic.com/downloads.html\n");
}





void cmd_open(void) {
	int fnbr;
	char *mode, *fname;
	char ss[3];														// this will be used to split up the argument line

	ss[0] = GetTokenValue("FOR");
	ss[1] = tokenvalue[TKN_AS];
	ss[2] = 0;
	{																// start a new block
		getargs(&cmdline, 5, ss);									// getargs macro must be the first executable stmt in a block
		fname = getCstring(argv[0]);
		
		if(argc != 5) error("Invalid Syntax");
		if(str_equal(argv[2], "OUTPUT"))
			mode = "wb";											// binary mode so that we do not have lf to cr/lf translation
		else if(str_equal(argv[2], "APPEND"))
			mode = "ab";											// binary mode is used in MMfopen()
		else if(str_equal(argv[2], "INPUT"))
			mode = "rb";											// note binary mode
		else if(str_equal(argv[2], "RANDOM"))
			mode = "x";												// a special mode for MMfopen()
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
	
	MMerrno = 0;
	for(i = 0; i < argc; i += 2) {
		if(*argv[i] == '#') argv[i]++;
		MMfclose(getinteger(argv[i]));
	}
}	



void cmd_seek(void) {
	int fnbr, idx;
	getargs(&cmdline, 5, ",");
	if(argc != 3) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	idx = getinteger(argv[2]);
	fflush(MMFilePtr[fnbr]);
	fsync(fileno(MMFilePtr[fnbr]));
    fseek(MMFilePtr[fnbr], idx, SEEK_SET);
//    if(FSerror() == 31)                                             // if the error is "invalid argument" it generally mean seek beyond end of file
//        ErrorThrow(10);                                             // so throw a "cannot read" error.  This could be made more informative
//    else
        ErrorCheck();                                               // otherwise the normal error check
}    


void fun_loc(void) {
	int fnbr;
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	fret = (float)ftell(MMFilePtr[fnbr]);
}	



void fun_lof(void) {
	int fnbr, pos;
	struct stat buf;
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	pos = ftell(MMFilePtr[fnbr]);
	fseek(MMFilePtr[fnbr], 0L, SEEK_END);
	fret = (float)ftell(MMFilePtr[fnbr]);
	fseek(MMFilePtr[fnbr], pos, SEEK_SET);
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



void cmd_mkdir(void) {
	char *p;
	
	p = getCstring(cmdline);										// get the directory name and convert to a standard C string
	errno = 0;
	mkdir(p);
	ErrorCheck();
}	




void cmd_rmdir(void){
	char *p;
	
	p = getCstring(cmdline);										// get the directory name and convert to a standard C string
	errno = 0;
	rmdir(p);
	ErrorCheck();
}




void cmd_chdir(void){
	char *p;

	p = getCstring(cmdline);										// get the directory name and convert to a standard C string
	errno = 0;
	chdir(p);
	ErrorCheck();
}



void fun_eof(void) {
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fret = (float)MMfeof(getinteger(argv[0]));
}	



void fun_cwd(void) {
	MMerrno = 0;
	sret = CtoM(MMgetcwd());
}


void cmd_kill(void){
	char *p;
	int err;

	p = getCstring(cmdline);										// get the file name and convert to a standard C string
	
	errno = 0;
	remove(p);
	if((err = errno) != 0) {
		ErrorThrow(err);
		return;
	}
		
	ErrorCheck();
}




void cmd_name(void) {
	char *oldf, *newf, ss[2];
	ss[0] = tokenvalue[TKN_AS];										// this will be used to split up the argument line
	ss[1] = 0;
	{																// start a new block
		getargs(&cmdline, 3, ss);									// getargs macro must be the first executable stmt in a block
		if(argc != 3) error("Invalid syntax");
		oldf = getCstring(argv[0]);									// get the old file name and convert to a standard C string
		newf = getCstring(argv[2]);									// get the new file name and convert to a standard C string
		errno = 0;
		rename(oldf, newf);
		if(ErrorCheck()) return;
	}
}	




void cmd_copy(void) { // thanks to Bryan Rentoul for the contribution
    char *oldf, *newf, ss[2];
    char c;
    int of, nf;

    ss[0] = tokenvalue[TKN_TO];                                 // this will be used to split up the argument line
    ss[1] = 0;
	{
		getargs(&cmdline, 3, ss);                                   // getargs macro must be the first executable stmt in a block
		if(argc != 3) error("Invalid syntax");
		oldf = getCstring(argv[0]);                                  // get the old file name and convert to a standard C string
		newf = getCstring(argv[2]);                                  // get the new file name and convert to a standard C string

		of = FindFreeFileNbr();
		if(of == 0) error("Too many files open");
		MMfopen(oldf, "r", of);
	    
		nf = FindFreeFileNbr();
		if(nf == 0) error("Too many files open");
		MMfopen(newf, "w", nf); 										// We'll just overwrite any existing file
	}
    while(1) {
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
	

// The MM.FNAME$ automatic variable
void fun_mmfname(void) {
	char *tp;
	tp = GetTempStringSpace();										// this will last for the life of the command
	strcpy(tp, LastFile);											// get the string and save in a temp place
	CtoM(tp);														// convert to a MMBasic style string
	sret = tp;
}	




void fun_date(void) {
    time_t time_of_day;
    struct tm *tmbuf;

    time_of_day = time(NULL);
	tmbuf = localtime(&time_of_day);
	sret = GetTempStringSpace();									// this will last for the life of the command
	sprintf(sret, "%02d-%02d-%04d", tmbuf->tm_mday, tmbuf->tm_mon + 1, tmbuf->tm_year + 1900);
	CtoM(sret);
}



void cmd_library(void) {
    int fn, i, FLen;
    char *pPath, *pFName, *p, *pmem;
    char save_tknbuf[STRINGSIZE];

	p = cmdline;

	// This block of code handles the command:   LIBRARY LOAD filename
	if((p = checkstring(cmdline, "LOAD")) != NULL) {
    	p++;                                                        // step over the token
    	pPath = getCstring(p);
    	pFName = strrchr(pPath, '\\') + 1;                          // get just the filename part of a possible path
    	if(pFName == (char *)1) pFName = strrchr(pPath, ':') + 1;
    	if(pFName == (char *)1) pFName = pPath;                     // no path, we were given just the file name
	    if(strchr(pFName, '.') == NULL) strcat(pFName, ".LIB");     // add the default extension if necessary
    	for(i = 0; i < NbrModules; i++)                             // scan the module table to see if it is already loaded
    	    if(str_equal(ModuleTable[i] + 4, pFName))
    	        return;                                          // and exit if already loaded
	    fn = FindFreeFileNbr();
	    MMfopen(pPath, "rb+", fn);                                  // test open the file and get the file length into FLen
		fseek(MMFilePtr[fn - 1], 0L, SEEK_END);						// this kludge is needed to get the file length
		FLen = ftell(MMFilePtr[fn - 1]);
    	MMfclose(fn);
    	pmem = getmemory(FLen + FILENAME_LENGTH + 5);               // get the memory
    	ModuleTable[NbrModules++] = pmem;                           // add this module to our list of modules
    	*((int *)pmem) = FLen;  pmem += 4;                          // put the size in first
    	memmove(pmem, pFName, FILENAME_LENGTH);                     // then copy in the file name
    	pmem += FILENAME_LENGTH + 1;
    	memmove(save_tknbuf, tknbuf, STRINGSIZE);                   // save tknbuf in case we are in command mode (megefile uses tknbuf)
    	mergefile(pPath, pmem);                                     // load the module
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
        	    PrepareProgram();                                   // rebuild the global list of subs/funs without this module
        	    return;
    	    }
    	error("Library not loaded");
    }
    error("Invalid Syntax");
}



/*******************************************************************************************
A couple of general MMBasic functions
********************************************************************************************/



void fun_time(void) {
    time_t time_of_day;
    struct tm *tmbuf;

    time_of_day = time(NULL);
	tmbuf = localtime(&time_of_day);
	sret = GetTempStringSpace();									// this will last for the life of the command
	sprintf(sret, "%02d:%02d:%02d", tmbuf->tm_hour, tmbuf->tm_min, tmbuf->tm_sec);
	CtoM(sret);
}


void cmd_exitmmb(void) {
	checkend(cmdline);
	ExitMMBasicFlag = true;											// signal that we want out of here
	longjmp(mark, 1);												// jump back to the input prompt
}

/*******************************************************************************************
I/O related functions called from within MMBasic
********************************************************************************************/



// fname must be a standard C style string (not the MMBasic style)
void MMfopen(char *fname, char *mode, int fnbr) {
	int err;
	if(fnbr < 1 || fnbr > 10) error("Invalid file number");
	fnbr--;
	if(MMFilePtr[fnbr] != NULL) error("File number is already open");
	
	MMerrno = errno = 0;
	
	// random writing is not allowed when a file is opened for append so open it first for read+update
	// and if that does not work open it for writing+update.  This has the same effect as opening for 
	// append+update but will allow writing
	if(*mode == 'x') {
		MMFilePtr[fnbr] = fopen(fname, "rb+");
		if(MMFilePtr[fnbr] == 0) {
			errno = 0;
			MMFilePtr[fnbr] = fopen(fname, "wb+");
		}
		fseek(MMFilePtr[fnbr], 0, SEEK_END);
	}
	else
		MMFilePtr[fnbr] = fopen(fname, mode);

	if((err = errno) != 0) {
		ErrorThrow(err);
		return;
	}
	
	if(MMFilePtr[fnbr] == NULL) ErrorThrow(9);
}


	

void MMfclose(int fnbr) {
	if(fnbr < 1 || fnbr > 10) error("Invalid file number");
	fnbr--;
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	errno = 0;
	fclose(MMFilePtr[fnbr]);
	MMFilePtr[fnbr] = NULL;
	ErrorCheck();
}	



int MMfgetc(int fnbr) {
	unsigned char ch;
	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return MMgetchar();
	fnbr--;
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	errno = 0;
	if(fread(&ch, 1, 1, MMFilePtr[fnbr]) == 0) ch = -1;
	ErrorCheck();
	return ch;
}	
	
	

char MMfputc(char c, int fnbr) {

	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return MMputchar(c);
	fnbr--;
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	errno = 0;
	if(fwrite(&c, 1, 1, MMFilePtr[fnbr]) == 0) if(ErrorCheck() == 0) ErrorThrow(9);
	return c;
}	



int MMfeof(int fnbr) {
	int i, c;
	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return 0;
	fnbr--;
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	errno = 0;
	c = fgetc(MMFilePtr[fnbr]);										// the Watcom compiler will only set eof after it has tried to read beyond the end of file
	i = (feof(MMFilePtr[fnbr]) != 0) ? -1 : 0;
	ungetc(c, MMFilePtr[fnbr]);										// undo the Watcom bug fix
	ErrorCheck();
	return i;
}	
	


char *MMgetcwd(void) {
	char *b;
	b = GetTempStringSpace();
	errno = 0;
	getcwd(b, STRINGSIZE);
	ErrorCheck();
	return b;
}	



void CloseAllFiles(void) {
	int i, prev;
	prev = OptionErrorAbort;
	OptionErrorAbort = false;										// don't abort on error
	for(i = 0; i < MAXOPENFILES; i++) {
		if(MMFilePtr[i] != NULL) MMfclose(i + 1);					// try and close a file
		MMFilePtr[i] = NULL;										// make sure that the entry is removed
	}
	OptionErrorAbort = prev;
}			

	
	
// finds the first available free file number.  Returns with zero if no free file numbers
int FindFreeFileNbr(void) {
	int i;
	for(i = 0; i < MAXOPENFILES; i++) 
		if(MMFilePtr[i] == NULL) return i + 1;
	return 0;
}	

	
