/***********************************************************************************************************************
MMBasic

Main.c

The startup code and essential hardware related functions for the DOS version of MMBasic.

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

#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <signal.h>
#include "..\..\MMBasic\MMBasic_Includes.h"
#include "Hardware_Includes.h"
//#include <windows.h>

// global variables used in MMBasic but must be maintained outside of the interpreter
int ListCnt;
int MMCharPos;
int ExitMMBasicFlag = false;
char *StartEditPoint;
int StartEditChar;
int MMAbort = false;
char *InterruptReturn = NULL;
unsigned int _excep_peek;

// empty functions used in MMBasic but must be maintained outside of the interpreter
void UnloadFont(int i) {}

void IntHandler(int signo);
void TryLoadProgram(void);

#define MES_SIGNON  "\rDOS MMBasic Version " VERSION "\r\n"\
					"Copyright " YEAR " Geoff Graham\r\n\r\n"


int main(int argc, char* argv[]) {
    static int PromptError = false;

    InitHeap();              										// initilise memory allocation
	MMPrintString(MES_SIGNON); 										// print signon message
	OptionErrorAbort = false;
	InitBasic();

	signal(SIGBREAK, IntHandler);
	signal(SIGINT, IntHandler);

	// if there is something on the command line load the token buffer with the run command
	if(argc == 2)
		sprintf(tknbuf, "%c \"%s\"", GetCommandValue("RUN") + C_BASETOKEN, argv[1]);
	else
		*tknbuf = 0;

	if(setjmp(mark) != 0) {
        // we got here via a long jump which means an error or CTRL-C or the program wants to exit to the command prompt
		if(ExitMMBasicFlag) return 0;							// program has executed an ExitMMBasic command
        ContinuePoint = nextstmt;                               // in case the user wants to use the continue command
		*tknbuf = 0;											// we do not want to run whatever is in the token buffer
	}

	if(*tknbuf) ExecuteProgram(tknbuf);							// if something is on the command line, run the program

    while(1) {
        if(MMAbort) autoOn = false;
		MMAbort = false;
        TempStringClearStart = 0;                               // this should not be needed but it ensures that all space will be cleared
        ClearTempSpace();                                 	    // clear temp string space (might have been used by the prompt)
        if(MMCharPos > 1) MMPrintString("\n");                  // prompt should be on a new line
        CurrentLinePtr = NULL;                                  // do not use the line number in error reporting
        if(PromptError || *PromptString == 0) {                 // if there has been an error in printing the prompt or there is no prompt set
            PromptError = false;
            *PromptString = 0;                                  // reset the prompt in case we got here via an error while printing the prompt
            MMPrintString("> ");                                // print the simple (safe) prompt
        } else {
            PromptError = true;                                 // set a flag so that we will know if an error occured
            MMPrintString(getCstring(PromptString));            // evaluate prompt string and output the result
            PromptError = false;                                // no error occured so reset the flag
        }
        ClearTempSpace();                                 	    // clear temp string space (might have been used by the prompt)
        CurrentLinePtr = NULL;                                  // do not use the line number in error reporting
        if(autoOn) {                                            // the AUTO command is running
            if(IsValidLine(autoNext)) {
                MMputchar('*');                                 // indicate that this will overwrite
                sprintf(inpbuf, "%3d ", autoNext);              // preload the buffer with the line bumber
            } else
                sprintf(inpbuf, "%4d ", autoNext);
        } else
            *inpbuf = 0;                                        // empty the input buffer
        EditInputLine();                                        // get the input
        if(!*inpbuf) continue;                                  // ignore an empty line
        tokenise(true);                                         // turn into executable code
        if(*tknbuf != T_LINENBR) {                              // is there a line number?
        	TryLoadProgram();
            ExecuteProgram(tknbuf);                             // no, there is not, so execute the line straight away
        }
        else {                                                  // we are adding this line to program memory
            ClearRuntime();                                     // clear any leftovers from the previous program
            AddProgramLine(false);								// add to program memory
        }
    }
}





// Try to find a program on disk that matches the start of the input buffer
// If found, load that program into memory and fake a run command in the token buffer
// Also, save the command line to the token buffer for possible use by the MM.CMDLINE$ function
void TryLoadProgram(void) {
    char cline[MAXSTRLEN], *p1, *p2;
    int fn, quoted = false;

    if(*tknbuf >= C_BASETOKEN) return;
    p1 = inpbuf;  p2 = LastFile;
    skipspace(p1);
    if(*p1 == '\"') { quoted = true; p1++; }                    // in case the user has quoted the file name
	while(*p1 != ' ' && *p1 != '\'' && *p1 != '\"' && *p1) *p2++ = *p1++;      // copy the file name to the buffer
	*p2 = 0;                                                    // and terminate
    if(*p1 == '\"') p1++;                                       // in case the user has quoted the file name
	strcpy(cline, p1);                                          // save the command line
	if(strchr(LastFile, '.') == NULL) strcat(LastFile, ".BAS");
	fn = FindFreeFileNbr();
    if(!quoted) OptionErrorAbort = false;                       // if not quoted do not flag an error if the file does not exist
	MMfopen(LastFile, "r", fn);				                    // check if the file exists (will abort with an error if it does not)
	if(MMerrno) return;
    OptionErrorAbort = true;                                    // restore normal file error handling
    if(ProgramChanged) error("Program in memory not saved");
	ClearProgram();							                    // the file exists so clear the program space so that the merge becomes a load
	mergefile(LastFile, NULL);					                // load the program
	ProgramChanged = false;
	tknbuf[0] = GetCommandValue("RUN") + C_BASETOKEN;           // fake a RUN command
	tknbuf[1] = tknbuf[2] = tknbuf[3] = 0;                      // and terminate it
	p1 = cline;
	skipspace(p1);                                              // skip any spaces on the command line
	if(!(*p1 == 0 || *p1 == '\'')) {                            // if there is a command line
    	tknbuf[3] = 123;                                        // magic number indicating that there is a command line
    	strcpy(&tknbuf[4], p1);                                 // copy the command line into tknbuf after the magic number
    }
}


void IntHandler(int signo) {
	signal(SIGBREAK, IntHandler);
	signal(SIGINT, IntHandler);
    MMAbort = true;
}


int MMInkey(void) {
    char c;
    char s;
		CheckAbort();
        if (kbhit()) {
			c = getch();										// modification to support the numeric enter key by Jim Hiley
			if(c == 0) {                            			// keypress is a special key
				s = getch();
				if(s == 28)
					c = '\n';           						// numeric enter key
				else
					ungetch(s);
			}
		return c;
	}
	else
		return -1;
}


void CheckAbort(void) {
	if(MMAbort) {
		longjmp(mark, 1);										// jump back to the input prompt
	}
}


void EditInputLine(void) {
	MMPrintString(inpbuf);
	if(autoOn) {
		MMgetline(0, inpbuf);
		if(atoi(inpbuf) > 0) autoNext = atoi(inpbuf) + autoIncr;
	}
	else
		MMgetline(0, inpbuf);
		//gets(inpbuf);
}


// get a keystroke.  Will wait forever for input
// if the char is a cr then replace it with a newline (lf)
int MMgetchar(void) {
	int c;

	do {
		c = MMInkey();
		if(c == '\r') c = '\n';
	} while(c == -1);
	return c;
}



// put a character out to the operating system
char MMputchar(char c) {
	//if(c != '\r')
	putch(c);
	if(isprint(c)) MMCharPos++;
	if(c == '\r' || c == '\n') {
		MMCharPos = 1;
		ListCnt++;
	}
	return c;
}


// get a line from the keyboard or a file handle
// IMPORTANT: This will append to the buffer pointed to by p, so (if you don't want this)
//            make sure that the first char of p is zero before calling this.
void MMgetline(int filenbr, char *p) {
	int nbrchars;
	unsigned char c;

	nbrchars = strlen(p);											// the line might not be empty and we want to add to the end
	p += nbrchars;

	while(1) {

		if(MMfeof(filenbr)) break;									// end of file - stop collecting

		c = MMfgetc(filenbr);

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
			if(filenbr == 0) MMfputs("\1\n", 0);
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





// function (which looks like a pre defined variable) to return the type of platform
void fun_type(void){
	sret = GetTempStringSpace();									// this will last for the life of the command
    strcpy(sret, "DOS");
    CtoM(sret);
}
