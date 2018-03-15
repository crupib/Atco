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


#include <p32xxxx.h>								// device specific defines
#include <plib.h>									// peripheral libraries
#include <stdio.h>
#include <string.h>
#include "Configuration Bits.h"					// config pragmas
#include "..\..\MMBasic\MMBasic_Includes.h"
#include "Hardware_Includes.h"

// global variables used in MMBasic but must be maintained outside of the interpreter
int ListCnt;
int MMCharPos;
int ExitMMBasicFlag = false;
char *StartEditPoint;
int StartEditChar;
int MMAbort = false;
char *InterruptReturn = NULL;
int OptionErrorAbort = false;
int MMerrno = 0;
unsigned int _excep_peek;

// empty functions used in MMBasic but must be maintained outside of the interpreter
void UnloadFont(int i) {}

// declare functions used in this file
void initU2(void);
int putU2(int c);
int kbhitU2(void);
char getU2(void);


#define MES_SIGNON  "\rPIC32-Generic MMBasic Version " VERSION "\r\n"\
					"Copyright " YEAR " Geoff Graham\r\n\r\n" 


int main(int argc, char* argv[]) {
    static int PromptError = false;
    
	// initial setup of the I/O ports
    AD1PCFG = 0xFFFF;                 								// Default all pins to digital
    mJTAGPortEnable( 0);											// turn off jtag
 	
 	// setup the CPU
    SYSTEMConfigPerformance(CLOCKFREQ);    							// System config performance
	mOSCSetPBDIV(OSC_PB_DIV_1);									    // fix the peripheral bus to the main clock speed

    initU2();                                                       // initialise the UART
    
    InitHeap();              										// initilise memory allocation
	MMPrintString(MES_SIGNON); 										// print signon message
	InitBasic();

	*tknbuf = 0;
			
	if(setjmp(mark) != 0) {
        // we got here via a long jump which means an error or CTRL-C or the program wants to exit to the command prompt
        ContinuePoint = nextstmt;                                   // in case the user wants to use the continue command
		*tknbuf = 0;											    // we do not want to run whatever is in the token buffer
	}

    while(1) {
        if(MMAbort) autoOn = false;
        MMAbort = false;
        TempStringClearStart = 0;                                   // this should not be needed but it ensures that all space will be cleared
        ClearTempSpace();                                 	        // clear temp string space (might have been used by the prompt)
        if(MMCharPos > 1) MMPrintString("\r\n");                    // prompt should be on a new line
        CurrentLinePtr = NULL;                                      // do not use the line number in error reporting
        if(PromptError || *PromptString == 0) {                     // if there has been an error in printing the prompt or there is no prompt set
            PromptError = false;
            *PromptString = 0;                                      // reset the prompt in case we got here via an error while printing the prompt
            MMPrintString("> ");                                    // print the simple (safe) prompt
        } else {
            PromptError = true;                                     // set a flag so that we will know if an error occured
            MMPrintString(getCstring(PromptString));                // evaluate prompt string and output the result
            PromptError = false;                                    // no error occured so reset the flag
        }    
        ClearTempSpace();                                 	        // clear temp string space (might have been used by the prompt)
        CurrentLinePtr = NULL;                                      // do not use the line number in error reporting
        if(autoOn) {                                                // the AUTO command is running
            if(IsValidLine(autoNext)) {
                MMputchar('*');                                     // indicate that this will overwrite
                sprintf(inpbuf, "%3d ", autoNext);                  // preload the buffer with the line bumber
            } else
                sprintf(inpbuf, "%4d ", autoNext);
        } else
            *inpbuf = 0;                                            // empty the input buffer
        EditInputLine();                                            // get the input
        if(!*inpbuf) continue;                                      // ignore an empty line
        tokenise(true);                                             // turn into executable code
        if(*tknbuf != T_LINENBR) {                                  // is there a line number?
            ExecuteProgram(tknbuf);                                 // no, there is not, so execute the line straight away
        }
        else {                                                      // we are adding this line to program memory
            ClearRuntime();                                         // clear any leftovers from the previous program
            AddProgramLine(false);								    // add to program memory
        }
    }
}

static int chbuf = -1;

int MMInkey(void) {
	int c;
	CheckAbort();
    c = chbuf;
    chbuf = -1;
    return c;
}


void CheckAbort(void) {
    if(chbuf == -1 && kbhitU2()) 
        chbuf = getU2();                                            // get the character from the UART
    if(chbuf == 3) {                                                // if it is CTRL-C
        chbuf = -1;
		MMAbort = true;
		longjmp(mark, 1);										    // jump back to the input prompt
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



// put a character out to the serial console
char MMputchar(char c) {
	putU2(c);	
	if(isprint(c)) MMCharPos++;
	if(c == '\r') {
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

    if(filenbr) error("Files not supported");
	nbrchars = strlen(p);											// the line might not be empty and we want to add to the end
	p += nbrchars;

	while(1) {
		
		if(filenbr > 0 && MMfeof(filenbr)) break;					// end of file - stop collecting

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


/**********************************************************************************************
* PIC32 Generic MMBasic Commands and functions
**********************************************************************************************/


void cmd_copyright(void) {
	MMPrintString("PIC32-Generic MMBasic V" VERSION "\r\n");
	MMPrintString("Copyright (c) " YEAR " Geoff Graham.\r\n");
	MMPrintString("All Rights Reserved.  See http://mmbasic.com.\r\n\n");
	MMPrintString("This is free software and comes with absolutely\r\n");
	MMPrintString("no warranty implied or otherwise.\r\n\n");
	MMPrintString("Updates at http://mmbasic.com/downloads.html\r\n");
}




/**********************************************************************************************
* Serial I/O functions to suit the Explorer 16 board
**********************************************************************************************/

#define DESIRED_BAUDRATE    9600

// initialize the UART2 serial port
void initU2(void) {
    OpenUART2(UART_EN, UART_RX_ENABLE | UART_TX_ENABLE, BUSFREQ/16/DESIRED_BAUDRATE-1);
}


// send a character to the UART2 serial port
int putU2(int c) {
      while(BusyUART2());                                           // Wait till the UART transmitter is free.
      putcUART2(c);                                                 // Write data into Tx.
    return c;
}


// check if a character is waiting on the UART2 serial port
int kbhitU2(void) {
    return DataRdyUART2();
}


// get a char from the UART2 serial port
char getU2(void) {
    return (char)ReadUART2(); 
}




/**********************************************************************************************
* File I/O is not supported in the generic PIC32 version so dummy functions are used
**********************************************************************************************/

// File related I/O
char MMfputc(char c, int fnbr) { MMputchar(c); return c;}
int MMfgetc(int filenbr) { return MMgetchar();}
void MMfopen(char *fname, char *mode, int fnbr) { error("Files not supported");}
int MMfeof(int filenbr) { return 0;}
void MMfclose(int fnbr) { }
int FindFreeFileNbr(void) { return 0;}
void CloseAllFiles(void) { }

