/*****************************************************************************************************************************
Maximite

Main.c

Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


This is the main source file for the Maximite project.

Development Environment
    To compile this you need:
     - Microchip MPLAB IDE V8.56 or later (www.microchip.com)
     - Microchip C32 C Compiler V2.01 Student (or Lite) version (www.microchip.com)
       IMPORTANT - This will not compile on versions earlier than 2.01

You must use the MPLAB project files distributed with this source as it has some customised settings for some files.
There are three project files.  Run the one to match your target platform (MAXIMITE, ColourMM or DUINOMITE)

----------------------- PIC32 HARDWARE --------------------------
Interrupts.......................................................
PRIORITY     DESCRIPTION                 MAX SPEED
   7         Video horizontal sync       every 66uS
   6         Serial interface            every 17uS when open
   5         I2C interface			  	    ?
   4		 Audio Synthesiser			 every 10uS to 30uS when open
   3         PS2 keyboard clock          every 30 uS when receiving a char
   2         Counting pins (11 to 14)    up to every 5uS
   1         MMBasic clocks and timers   every 500 uS

If you modify these priorities then you must also adjust the code of lower priority interrupts
to take into account that something like LATEbits.LATE4 = 1 is a macro and not not an atomic operation
and a higher interrupt might change PORTE while the macro is being executed.

Timers...........................................................
TIMER NBR    DESCRIPTION                 INTERRUPT
  core       Used by the uSec() macro       no
   1		 Sampling timer for audio       yes
   2		 Audio PWM clock				no
   3		 Video horizontal sync			yes
   4		 MMBasic clocks and timers		yes
   5		 Serial interface				yes


********************************************************************************************************************************/

#if !defined(MAXIMITE) && !defined(UBW32) && !defined(DUINOMITE) && !defined(COLOUR) && !defined(TFT_MAXIMITE)
	#error Must define the target hardware in the project file
#endif

#include <p32xxxx.h>								// device specific defines
#include <plib.h>									// peripheral libraries
#include <stdlib.h>									// standard library functions
#include <string.h>									// string functions
#include <peripheral/nvm.h>							// used in writing to the flash memory

#include "Maximite.h"								// helpful defines
#if defined(MAXIMITE) || (defined(UBW32) && defined(__DEBUG)) || defined(DUINOMITE) || defined(COLOUR)
	#include "Configuration Bits.h"					// config pragmas
#endif

//** USB INCLUDES ***********************************************************
#include "./USB/Microchip/Include/USB/usb.h"
#include "./USB/Microchip/Include/USB/usb_function_cdc.h"
#include "./USB/HardwareProfile.h"

#include "./USB/Microchip/Include/GenericTypeDefs.h"
#include "./USB/Microchip/Include/Compiler.h"
#include "./USB/usb_config.h"
#include "./USB/Microchip/Include/USB/usb_device.h"

extern void USBDeviceTasks(void);


//** MMBasic INCLUDES *******************************************************
#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"



/*****************************************************************************************************************************
Configuration defines
******************************************************************************************************************************/
#define USB_RX_BUFFER_SIZE	128
#define USB_TX_BUFFER_SIZE	64



/*****************************************************************************************************************************
Other defines
******************************************************************************************************************************/
#define MES_EXCEPTION1  "Exception code %d at address 0x%X\r\n"

#define MES_EXCEPTION2  "Using PEEK or POKE caused an exception\r\nThe processor has been reset\r\n\n"

#define MES_EXCEPTION3  "An internal error was trapped and your\r\nprogram has been lost (sorry).\r\n\n"

#define MES_EXCEPTION4  "The WATCHDOG command timed out\r\nand restarted the processor.\r\n\n"


/*****************************************************************************************************************************
Declare all functions
******************************************************************************************************************************/
void InitEverything(void);
int CopyDataToKeystrokeBuffer(int numBytes);
void DrawLogo(void);
void TryLoadProgram(void);

/*****************************************************************************************************************************
Global memory locations
******************************************************************************************************************************/
char USB_RxBuf[USB_RX_BUFFER_SIZE];
char USB_TxBuf[2][USB_TX_BUFFER_SIZE];
volatile int USB_NbrCharsInTxBuf;
volatile int USB_Current_TxBuf;

int USBOn, VideoOn;													// variables controlling the output of the print (and other) commands

volatile unsigned char InpQueue[INP_QUEUE_SIZE];					// INP_QUEUE_SIZE is defined in Maximite.h
volatile int InpQueueHead, InpQueueTail;

volatile int MMAbort = false;
int FileXfr = false;												// true if we are transfering a file
int BreakKey = 3;											        // the numeric value of the key that we want to use to interrupt a running program
int ProgramChanged;                                                 // true if the program has been modified and therefor a save might be required
char *OnKeyGOSUB;                                                   // used to record the location in:  ON KEY location

//#if  (__C32_VERSION__ < 200)
//    Error - This requires Microchip C32 Compiler V2.01 or later
//#else
//	unsigned int _excep_dummy1 __attribute__((persistent));
//	unsigned int _excep_peek __attribute__((persistent));
//	unsigned int _excep_code __attribute__((persistent));
//	unsigned int _excep_addr __attribute__((persistent));
//#endif


/****************************************************************************************************************************
Main program
*****************************************************************************************************************************/
//char *p1, *p2, *p3;
int main(void) {
    static int FirstTimeRun = true;
    static int PromptError = false;
    char *autorun;
    char normal[] = "AUTORUN.BAS";
    char restart[] = "RESTART.BAS";
    int r;

	// initial setup of the I/O ports
    AD1PCFG = 0xFFFF;                 								// Default all pins to digital
    mJTAGPortEnable(0);												// turn off jtag

 	// setup the CPU
    SYSTEMConfigPerformance(CLOCKFREQ);    							// System config performance
    #if defined(MAXIMITE) || (defined(UBW32) && defined(__DEBUG)) || defined(DUINOMITE) || defined(COLOUR)
	    mOSCSetPBDIV(OSC_PB_DIV_1);									// fix the peripheral bus to the main clock speed
	#endif

    INTEnableSystemMultiVectoredInt();   							// allow vectored interrupts

 // TRISEbits.TRISE0 = 0; LATEbits.LATE0 = 0;    // debug turn on the power led
 // TRISEbits.TRISE1 = 0; LATEbits.LATE1 = 0;    // debug turn on the activity led

    // init global variables
    USB_NbrCharsInTxBuf = 0;
    USB_Current_TxBuf = 0;
    InpQueueHead = InpQueueTail = 0;
    USBOn = VideoOn = true;
    BreakKey = 3;                                                   // break key set to CtrlC

	// initilise the USB input/output subsystems
    USBDeviceInit();												// Initialise USB module SFRs and firmware

    #if defined(DUINOMITE)                                          // on the DuinoMite we must turn on the I/O
        P_DM_STNB                                                   // turn on the power to the I/O
        uSec(26000);                                                // allow time for the power to come up
    #endif

    NbrModules = 0;
    InitHeap();              										// initilise memory allocation
    initTimers();              										// initilise and startup the timers
    initExtIO();													// Initialise the external analog and digital I/O
    initFont();														// initialise the font table
    initVideo();    												// start the video state machine
    MMcls();														// clear the video buffer

    SoundPlay = 0;													// start by not playing a sound
    while(PauseTimer < 1000);;   							        // let everything settle
    initKeyboard();              									// initilise and startup the keyboard routines
    
#if defined(COLOUR)
    GetRTC();                                                       // get the time from the RTC
#endif

    // Initial message
    if(ReadEventWDT()) {                                            // did the watchdog go off ?
        MMPrintString(MES_EXCEPTION4);							    // print suitable message
		autorun = restart;                                          // setup so that we run the recovery autorun
		ClearEventWDT();                                            // clear the error flag
	} else if(RCON & 0x0040) {										// this will only happen if we recovered from an untrapped exception
//	    char tmp[150];												// buffer for building the error message
//		if(_excep_addr) {
//			sprintf(tmp, MES_EXCEPTION1, _excep_code, _excep_addr); // error codes
//			MMPrintString(tmp);
//		}
//		if(_excep_peek)
//		    MMPrintString(MES_EXCEPTION2);							// print the rest of the message for a PEEK/POKE exception
//		else
		    MMPrintString(MES_EXCEPTION3);							// print the rest of the message for a general exception
		autorun = restart;                                          // setup so that we run the recovery autorun
		RCONCLR = 0x0040;                                           // clear the error flag
	} else {
#if defined(COLOUR)
	    if(vga)
	        DrawLogo();
	    else {
    		MMPrintString(MES_SIGNON); 								// print signon message
            MMPrintString(MES_COPYRIGHT);
    		MMPrintString("\r\n"); 									// extra line looks better
    	}    
#else
		MMPrintString(MES_SIGNON); 									// print signon message
        MMPrintString(MES_COPYRIGHT);
		MMPrintString("\r\n"); 										// extra line looks better
#endif
		autorun = normal;
	}

//	_excep_peek = false;

#ifdef REPORT_STACK_USAGE
    InitStackUsage();
#endif

    InitBasic();

    if(CommandTableSize >= 128) dp("Command table too large");
    if(TokenTableSize >= 128) dp("Token table too large");
#ifdef __DEBUG
    {
    dp("Command table entries free: %d", 127 - CommandTableSize);
    dp("Token table entries free: %d\r\n", 127 - TokenTableSize);
    }
#endif

    ExtSet(0, 1);                                                   // turn on the power LED

    while(1) {
        if(setjmp(mark) == 0) {                                     // return to here on error or when we want to halt execution
            ShowCursor(false);                                      // just in case it was left on after a CTRL-C
            if(CurrentLinePtr) StopAudio();                         // stop any background audio only if we were running a program
            if(MMAbort) autoOn = false;
            MMAbort = false;                                        // MMAbort is set on CTRL-C
            FileXfr = false;                                        // we are not doing a file transfer
            while(MMInkey() != -1);                                 // clear the input buffer

            // if this is the first time that MMBasic has been run check for AUTORUN and AUTOKEYS
            if(FirstTimeRun) {
                FirstTimeRun = false;                               // we only run this code once

                /////////////////////////////////////////////////////////////////////////////////////////////////////////////
                // look for AUTORUN.BAT (or RESTART.BAS)
                DefaultDrive = FLASHFS;
                r = (FindFlashBlock(autorun, 1) != NULL);
                if(!r) {
                #if defined(UBW32)
                        if(InitSDCard() == true)
                #endif
                    {
                        DefaultDrive = SDFS;
                        OptionErrorAbort = false;                   // do not flag an error if the file does not exist
                        r = SDCheckFileName(autorun);               // and check for the autorun file on the SDCard fs
                        OptionErrorAbort = true;                    // restore normal file error handling
                    }
                }
                if(r) {
                    mergefile(autorun, NULL);                       // load the program
                    ExecuteProgram(PMemory + 1);                    // and execute it
                }
            }

#ifdef PROFILE
            StopProfiling();
#endif
#ifdef REPORT_STACK_USAGE
            PrintStackUsage();
            InitStackUsage();
#endif
            SetFont((GetFlashOption(&FontOption) == CONFIG_FONT1) ? 0:1, 1, 0); // set a reasonable default font

            #if defined(COLOUR)
                CurrentFgColour = ConsoleFgColour;                  // reset the text colours
                CurrentBgColour = ConsoleBgColour;
                if(CLine < (char *)&_stack) FreeHeap(CLine);
                CLine = NULL;
            #endif
            Cursor = C_STANDARD;
            AutoLineWrap = true;
            PrintPixelMode = 0;
            USBOn = VideoOn = true;                                 // turn on the outputs;

            ClearStack();
        	m_alloc(M_EDIT, false);                                 // clear any memory allocated to the editor
            TempStringClearStart = 0;                               // this should not be needed but it ensures that all temp space will be cleared
            ClearTempSpace();                                       // clear temp string space (the editor could have used a lot)

            if(MMCharPos > 1) MMPrintString("\r\n");                // prompt should be on a new line
            if((MMPosY % (fontHeight * fontScale)) != 0)
                MMPosY += (fontHeight * fontScale) - (MMPosY % (fontHeight * fontScale)); // and ensure that it is an even scan line

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
            ClearTempSpace();                                       // clear temp string space (might have been used by the prompt)
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
            InsertLastcmd(inpbuf);                                  // save in case we want to edit it later
            tokenise(true);                                         // turn into executable code
            if(*tknbuf != T_LINENBR) {                              // if there is not a line number
                TryLoadProgram();                                   // try to load/run the program if this is an implied RUN command
                ExecuteProgram(tknbuf);                             // now execute whatever we have in the token buffer
            } else {                                                // we are adding this line to program memory
                ClearRuntime();                                     // clear any leftovers from the previous program
                AddProgramLine(false);	                            // add to program memory

            }
        }
        else {
            // we got here via a long jump which means an error or CTRL-C
            ContinuePoint = nextstmt;                               // save where we were in the program in case the user wants to invoke the continue command
        }
    }
}



// Try to find a program on disk that matches the start of the input buffer
// If found, load that program into memory and fake a run command in the token buffer
// Also, save the command line to the token buffer for possible use by the MM.CMDLINE$ function
void TryLoadProgram(void) {
    char fname[MAXSTRLEN], cline[MAXSTRLEN], *p1, *p2;
    int fn, quoted = false;;

    if(*tknbuf >= C_BASETOKEN) return;
    p1 = inpbuf;  p2 = fname;
    skipspace(p1);
    if(*p1 == '\"') { quoted = true; p1++; }                        // in case the user has quoted the file name
	while(*p1 != ' ' && *p1 != '\'' && *p1 != '\"' && *p1) *p2++ = *p1++;      // copy the file name to the buffer
	*p2 = 0;                                                        // and terminate
    if(*p1 == '\"') p1++;                                           // in case the user has quoted the file name
	strcpy(cline, p1);                                              // save the command line
	if(strchr(fname, '.') == NULL) strcat(fname, ".BAS");
	if(!str_equal(fname, LastFile)) {                               // if the program is NOT already in memory then load it
    	fn = FindFreeFileNbr();
        if(!quoted) OptionErrorAbort = false;                       // do not flag an error if the file does not exist
    	MMfopen(fname, "r", fn);				                    // check if the file exists (will abort with an error if it does not)
    	if(MMerrno) return;
        OptionErrorAbort = true;                                    // restore normal file error handling
        if(ProgramChanged) error("Program in memory not saved");
    	ClearProgram();							                    // the file exists so clear the program space so that the merge becomes a load
    	mergefile(fname, NULL);					                    // load the program
    	strcpy(LastFile, fname);                                    // save the new file name
    	ProgramChanged = false;
    }
	tknbuf[0] = GetCommandValue("RUN") + C_BASETOKEN;               // fake a RUN command
	tknbuf[1] = tknbuf[2] = tknbuf[3] = 0;                          // and terminate it
	p1 = cline;
	skipspace(p1);                                                  // skip any spaces on the command line
	if(!(*p1 == 0 || *p1 == '\'')) {                                // if there is a command line
    	tknbuf[3] = 123;                                            // magic number indicating that there is a command line
    	strcpy(&tknbuf[4], p1);                                     // copy the command line into tknbuf after the magic number
    }
}




/****************************************************************************************************************************
USB related functions
*****************************************************************************************************************************/


/******************************************************************************************
Check the USB for work to be done.
Used to send and get data to or from the USB interface.
This is called from the Inkey loop, before a command is executed and other places where the
interpreter might be waiting.
Each call takes typically 3uS but sometimes it can be up to 300uS.
*******************************************************************************************/
void CheckUSB(void) {
	int i, numBytesRead;

	if(U1OTGSTAT & 1) {														    // is there 5V on the USB?
	    USBDeviceTasks();													    // do any USB work

        if(USBGetDeviceState() == CONFIGURED_STATE) {
			numBytesRead = getsUSBUSART(USB_RxBuf,USB_RX_BUFFER_SIZE);		    // check for data to be read
			for(i = 0; i < numBytesRead; i++) {								    // if we have some data, copy it into the keyboard buffer
				InpQueue[InpQueueHead] = USB_RxBuf[i];						    // add the byte in the keystroke buffer
				InpQueueHead = (InpQueueHead + 1) % INP_QUEUE_SIZE;			    // increment the head of the queue
				if(USB_RxBuf[i] == BreakKey  && !FileXfr) {			            // check for CTRL-C
					MMAbort = true;											    // and if so tell BASIC to stop running
					WDTimer = 0;                                            	// turn off the watchdog timer
                }
			}

			if(USB_NbrCharsInTxBuf && mUSBUSARTIsTxTrfReady()) {			    // next, check for data to be sent
				putUSBUSART(USB_TxBuf[USB_Current_TxBuf],USB_NbrCharsInTxBuf);	// and send it
				USB_Current_TxBuf = !USB_Current_TxBuf;
				USB_NbrCharsInTxBuf = 0;
			}
		    CDCTxService();													    // send anything that needed sending
		}
	}
}




/******************************************************************************************
BOOL USER_USB_CALLBACK_EVENT_HANDLER
This function is called from the USB stack to notify a user application that a USB event
occured.  This callback is in interrupt context when the USB_INTERRUPT option is selected.

Args:  event - the type of event
       *pdata - pointer to the event data
       size - size of the event data

This function was derived from the demo CDC program provided by Microchip
*******************************************************************************************/
BOOL USER_USB_CALLBACK_EVENT_HANDLER(USB_EVENT event, void *pdata, WORD size)
{
    switch(event)
    {
        case EVENT_CONFIGURED:
            CDCInitEP();
             break;
//        case EVENT_SET_DESCRIPTOR:
//            break;
        case GRG_EVENT_EP0_REQUEST:
            USBCheckCDCRequest();
            USBBannerTimer = 200;				// wait 200mS then send the MMBasic banner
            break;
        case EVENT_SOF:
            break;
        case EVENT_SUSPEND:
            break;
        case EVENT_RESUME:
            break;
        case EVENT_BUS_ERROR:
            break;
        case EVENT_TRANSFER:
            Nop();
            break;
        default:
            break;
    }
    return TRUE;
}




/****************************************************************************************************************************
Keyboard/USB input functions
*****************************************************************************************************************************/

int isKeyInBuffer(void) {
    if(InpQueueHead != InpQueueTail) return true;
    if(SerialConsole && SerialRxStatus(SerialConsole)) return true;
    return false;
}


// get a character from the keyboard, USB or console
// returns -1 if nothing waiting
int MMInkeyTask(void) {
	int c = -1;											            // default no character

    if(InpQueueHead != InpQueueTail) {								// is there anything in the keyboard queue?
		c = InpQueue[InpQueueTail];									// if so, get it
		InpQueueTail = (InpQueueTail + 1) % INP_QUEUE_SIZE;			// and remove from the queue
	} else if(SerialConsole) {										// if there is a serial console
		c = SerialGetchar(SerialConsole);							// get the char from the serial port (returns -1 if nothing)
	}
	if(MMAbort) longjmp(mark, 1);									// jump back to the input prompt
	return c;
}


/*****************************************************************************************
The vt100 escape code sequences
===============================
3 char codes			Arrow Up	esc [ A
						Arrow Down	esc [ B
						Arrow Right	esc [ C
						Arrow Left	esc [ D

4 char codes			Insert		esc [ 1 ~
						Home		esc [ 2 ~
						End			esc [ 4 ~
						Page Up		esc [ 5 ~
						Page Down	esc [ 6 ~

5 char codes			F1			esc [ 1 1 ~
						F2			esc [ 1 2 ~
						F3			esc [ 1 3 ~
						F4			esc [ 1 4 ~
						F5			esc [ 1 5 ~			note the
						F6			esc [ 1 7 ~			disconnect
						F7			esc [ 1 8 ~
						F8			esc [ 1 9 ~
						F9			esc [ 2 0 ~
						F10			esc [ 2 2 ~			note the
						F11			esc [ 2 3 ~			disconnect
						F12			esc [ 2 4 ~

						SHIFT-F3    esc [ 2 5 ~         used in the editor

*****************************************************************************************/

// check if there is a keystroke waiting in the buffer and, if so, return with the char
// returns -1 if no char waiting
// the main work is to check for vt100 escape code sequences and map to Maximite codes
int MMInkey(void) {
	unsigned int c = -1;											// default no character
	unsigned int tc = -1;											// default no character
	unsigned int ttc = -1;											// default no character
	static unsigned int c1 = -1;
	static unsigned int c2 = -1;
	static unsigned int c3 = -1;
	static unsigned int c4 = -1;

	if(c1 != -1) {													// check if there are discarded chars from a previous sequence
		c = c1; c1 = c2; c2 = c3; c3 = c4; c4 = -1;					// shuffle the queue down
		return c;													// and return the head of the queue
	}

	c = MMInkeyTask();												// do discarded chars so get the char
	if(c == 0x1b && !FileXfr) {
		InkeyTimer = 0;												// start the timer
		while((c = MMInkeyTask()) == -1 && InkeyTimer < 30);		// get the second char with a delay of 30mS to allow the next char to arrive
		if(c != '[') { c1 = c; return 0x1b; }						// must be a square bracket
		while((c = MMInkeyTask()) == -1 && InkeyTimer < 50);		// get the third char with delay
		if(c == 'A') return UP;										// the arrow keys are three chars
		if(c == 'B') return DOWN;
		if(c == 'C') return RIGHT;
		if(c == 'D') return LEFT;
		if(c < '1' && c > '6') { c1 = '['; c2 = c; return 0x1b; }	// the 3rd char must be in this range
		while((tc = MMInkeyTask()) == -1 && InkeyTimer < 70);		// delay some more to allow the final chars to arrive, even at 1200 baud
		if(tc == '~') {												// all 4 char codes must be terminated with ~
			if(c == '1') return HOME;
			if(c == '2') return INSERT;
			if(c == '3') return DEL;
			if(c == '4') return END;
			if(c == '5') return PUP;
			if(c == '6') return PDOWN;
			c1 = '['; c2 = c; c3 = tc; return 0x1b;					// not a valid 4 char code
		}
		while((ttc = MMInkeyTask()) == -1 && InkeyTimer < 90);		// get the 5th char with delay
		if(ttc == '~') {											// must be a ~
			if(c == '1') {
				if(tc >='1' && tc <= '5') return F1 + (tc - '1');	// F1 to F5
				if(tc >='7' && tc <= '9') return F6 + (tc - '7'); 	// F6 to F8
			}
			if(c == '2') {
				if(tc =='0' || tc == '1') return F9 + (tc - '0'); 	// F9 and F10
				if(tc =='3' || tc == '4') return F11 + (tc - '3'); 	// F11 and F12
				if(tc =='5') return F3 + 0x20; 	                    // SHIFT-F3
			}
		}
		// nothing worked so bomb out
		c1 = '['; c2 = c; c3 = tc; c4 = ttc;
		return 0x1b;
	}
	return c;
}


// get a keystroke.  Will wait forever for input
// if the char is a cr then replace it with a newline (lf)
int MMgetchar(void) {
	int c;
	do {
		ShowCursor(true);
		c = MMInkey();
		if(c == '\r') c = '\n';
	} while(c == -1);
	ShowCursor(false);
	return c;
}





/****************************************************************************************************************************
Video/USB output functions
*****************************************************************************************************************************/


// put a character out to the video screen, the serial console and the USB interface
char MMputchar(char c) {
	if(!FileXfr && VideoOn) VideoPutc(c);							// draw the char on the video screen
	if((c & 0x80) && !FileXfr) return c;                            // don't print anything with the top bit set to USB or console
	if(SerialConsole) SerialPutchar(SerialConsole, c);				// send it to the serial console if enabled
	if(!(SerialConsole && FileXfr)) USBPutchar(c);			        // send it to the USB
	return c;
}



// put a character out to the USB interface
void USBPutchar(char c) {
static int DelayCnt = 0;

    if(!USBOn || (U1OTGSTAT & 1) == 0 || (USBDeviceState < CONFIGURED_STATE)||(USBSuspendControl==1)) {// check USB status
	    USB_NbrCharsInTxBuf = 0;
	    DelayCnt = 0;
    	return;														// and skip if the USB is not connected
    }

    // if the buffer is full delay for a maximum of 5mS (at level 2 optimisation)
    // this will only delay once on buffer full and the delay will only be re enabled when something is sent
	while((USB_NbrCharsInTxBuf >= USB_TX_BUFFER_SIZE) && DelayCnt < 57000) DelayCnt++ ;

	if(USB_NbrCharsInTxBuf < USB_TX_BUFFER_SIZE) {					// skip if the buffer is still full (not being drained)
		mT4IntEnable(0);											// Disable Timer 4 Interrupt in Timers.c as that could call CheckUSB()
		USB_TxBuf[USB_Current_TxBuf][USB_NbrCharsInTxBuf++] = c;	// Place char into the buffer
		mT4IntEnable(1);											// ReEnable Timer 4 Interrupt
		DelayCnt = 0;
	}
}


// put a vt100 escape sequence out on the USB
// escape sequences must not be split into separate USB transmissions
void USBPutEscape(char *p) {
    if(!USBOn || (U1OTGSTAT & 1) == 0) return;
	mT4IntEnable(0);											    // Disable Timer 4 Interrupt (in Timers.c) as that could call CheckUSB()
    CheckUSB();                                                     // flush anything there
    if(!(USB_NbrCharsInTxBuf + strlen(p) >= USB_TX_BUFFER_SIZE)) {  // sanity check
        while(*p) USB_TxBuf[USB_Current_TxBuf][USB_NbrCharsInTxBuf++] = *p++; // and put the escape sequence into the buffer
        CheckUSB();                                                 // flush it
    }
	mT4IntEnable(1);											    // ReEnable Timer 4 Interrupt
}



/****************************************************************************************************************************
Utility functions
*****************************************************************************************************************************/


// trap an unhandled error (exception)

/* list of exception codes
	0 = EXCEP_IRQ,				// interrupt
	4 = EXCEP_AdEL,				// address error exception (load or ifetch)
	5 = EXCEP_AdES,				// address error exception (store)
	6 = EXCEP_IBE,				// bus error (ifetch)
	7 = EXCEP_DBE,				// bus error (load/store)
	8 = EXCEP_Sys,				// syscall
	9 = EXCEP_Bp,				// breakpoint
	10 = EXCEP_RI,				// reserved instruction
	11 = EXCEP_CpU,				// coprocessor unusable
	12 = EXCEP_Overflow,		// arithmetic overflow
	13 = EXCEP_Trap,			// trap (possible divide by zero)
	14 = EXCEP_IS1 = 16,		// implementation specfic 1
	15 = EXCEP_CEU,				// CorExtend Unuseable
	16 = EXCEP_C2E				// coprocessor 2
*/

/* exception handler
   this function overrides the normal _weak_ generic handler and uses two variables (_excep_code and _excep_addr) to save the cause
   and address of the exception.  These are saved in a special section of memory which is not initialised by the startup code.
   For details see the following:
   			http://www.microchip.com/forums/tm.aspx?m=434737&mpage=1&key=%F1%AA%88%B1
   			http://www.microchip.com/forums/tm.aspx?m=458360&high=persist

*/

void _general_exception_handler(void)
{

//	asm volatile("mfc0 %0,$13" : "=r" (_excep_code));
//	asm volatile("mfc0 %0,$14" : "=r" (_excep_addr));
//
//	_excep_code = (_excep_code & 0x0000007C) >> 2;

    debughalt(); 		// Break here when compiling under a Debug build configuration
  	SoftReset(); 		// this will restart the processor – only works when not in debug
}



// report the amount of stack used
// InitStackUsage() will zero the area of memory used by the stack
#ifdef REPORT_STACK_USAGE

void InitStackUsage(void) {
	unsigned int *p;
	extern unsigned int _splim;
	register unsigned int msp asm("sp");
	for(p = (unsigned int *)msp - 4; p > (unsigned int *) &_splim + 2; p--) *p = 0;
}

void PrintStackUsage(void) {
	unsigned int *p;
	extern unsigned int _splim;
	extern unsigned int _stack;
	for(p = (unsigned int *) &_splim + 4; p < (unsigned int *)&_stack; p++) if(*p != 0) break;
	sprintf(inpbuf, "Stack usage: %d bytes of %d\r\n", (unsigned int)&_stack - (unsigned int)p, STACK_SIZE);
	MMPrintString(inpbuf);
}
#endif




//#ifdef __DEBUG
void dump(char *p, int nbr) {
	char buf1[60], buf2[30], *b1, *b2;
	b1 = buf1; b2 = buf2;
	b1 += sprintf(b1, "%8x: ", (unsigned int)p);
	while(nbr > 0) {
		b1 += sprintf(b1, "%02x ", *p);
		b2 += sprintf(b2, "%c", (*p >= ' ' && *p < 0x7f) ? *p : ' ');
		p++;
		nbr--;
		if((unsigned int)p % 16 == 0) {
			sprintf(inpbuf, "%s   %s", buf1, buf2);
			MMPrintString(inpbuf);
			b1 = buf1; b2 = buf2;
			b1 += sprintf(b1, "\r\n%8x: ", (unsigned int)p);
		}
	}
	if(b2 != buf2) {
		sprintf(inpbuf, "%s   %s", buf1, buf2);
		MMPrintString(inpbuf);
	}
	MMPrintString("\r\n");
}
//#endif



#ifdef PROFILE
int p_enabled = false;
unsigned int *p_array;


void StartProfiling(void) {
	int i;

	p_array = (unsigned int *)getmemory(((P_END_ADDR - P_START_ADDR)/P_GRANUALITY) * 4);
	for(i = 0; i < (P_END_ADDR - P_START_ADDR)/P_GRANUALITY; i++) p_array[i] = 0;
	p_enabled = true;

    PR5 =  10 * ((BUSFREQ)/1000000) - 1;    					// ticks at 10us
    T5CON = 0x8000;         									// T4 on, prescaler 1:1
    mT5SetIntPriority(6);  										// a reasonably high priority
    mT5ClearIntFlag();      									// clear interrupt flag
    mT5IntEnable(1);       										// enable interrupt
}



void __ISR( _TIMER_5_VECTOR, ipl6) T5Interrupt( void) {
	unsigned int pc;
	register unsigned int *msp asm("sp");

	// note the magic number 44 is found in the disassembly of this interrupt, look for the lines:
	//   lw          k0,44(sp)
	//      - - - - - - -
	//   mtc0        k0,EPC
	// the magic number is the 44 (or whatever)
	pc = msp[44/4];
	pc -= P_START_ADDR;
	pc /= P_GRANUALITY;
	if(pc < (P_END_ADDR - P_START_ADDR)/P_GRANUALITY) p_array[pc]++;
    mT5ClearIntFlag();
}


void StopProfiling(void) {
	int filenbr, i;
	char *p;
	char fn[] = "B:PROFILE.XLS";

	if(!p_enabled) return;
	p_enabled = false;
	mT5IntEnable(0);
	T5CON = 0;

	filenbr = FindFreeFileNbr();
	MMfopen(fn, "w", filenbr);
	for(i = 0; i < (P_END_ADDR - P_START_ADDR)/P_GRANUALITY; i++) {
		sprintf(inpbuf, "0x%x\t%u\r\n", (i * P_GRANUALITY) + P_START_ADDR, p_array[i]);
		p = inpbuf;
		while(*p) MMfputc(*p++, filenbr);
	}
	MMfclose(filenbr);

	FreeHeap(p_array);
}

#endif


/**********************************************************************************************
   Write to the flash
   This replaces the Microchip library routines which contain a bug related to disabling the DMA

   Arguments:
     p = address to write at
     wrd = data to write if the operation is write a word
     operation = FLASH_WRITE_WORD or FLASH_PAGE_ERASE

***********************************************************************************************/

void FlashWrite(void *p, unsigned int wrd, unsigned int operation) {

	INTDisableInterrupts();

    // load the address and data
    NVMADDR = KVA_TO_PA((unsigned int)p);
    NVMCON = NVMCON_WREN | operation;
    if(operation == FLASH_WRITE_WORD) NVMDATA = wrd;

	// delay 64 uS.  This is required for two reasons:
    //  - wait at least 6 us for LVD start-up required by the B6 stepping and later
    //  - wait for a composite video frame to finish and the DMA to reach the idle state
    uSec(64);

	// program the flash
    NVMKEY 		= 0xAA996655;
    NVMKEY 		= 0x556699AA;
    NVMCONSET 	= NVMCON_WR;

    // Wait for the write to finish
    while(NVMCON & NVMCON_WR);

    // Disable Flash Write/Erase operations
    NVMCONCLR = NVMCON_WREN;

	INTEnableInterrupts();
	if(NVMIsError()) error("Cannot write to flash memory");
}



/**********************************************************************************************
   These routines are used to save a flag that will be needed even after cycling the power
   The flags are saved in flash using the PIC32's ability to rewrite its flash

   An option consists of three bits and can have one of seven states (0b001 to 0b111).
   One option is stored in 4 bytes which contains 10 "slots" of three bits each.  The first slot
   is writen with the option being set.  If that option is changed the slot is zeroed and the
   new option is written to the next slot.

   Thus you can change the option 9 times before the flash will need to be erased (done by
   reflashing the firmware).  For this reason these routines should only be used for options
   that are rarely changed.
***********************************************************************************************/

// return the current option state
int GetFlashOption(const unsigned int *w) {
	int i;
	unsigned int t;
	t = *w;
	for(i = 27 ; i >= 0; i -= 3) {
		t = *w >> i;
		if(t & 0b111) return (t & 0b111);
	}
	return 0b11;
}


// set a new option state
void SetFlashOption(const unsigned int *w, int x) {
	int i;
	unsigned int t;
	t = *w;
	for(i = 27 ; i >= 0; i -= 3) {
		if(((*w >> i) & 0b111) != 0) {								// if this slot has not been erased
			if(((*w >> i) & 0b111) == x) return;					// exit if it is the same as we want to set
			if(i == 0) error("Cannot change option more than 9 times - reflash MMBasic to reset");
			t = (*w & ~(0x38000000 >>(27 - i)));					// zero that slot
			i -= 3;													// step to the next slot
			t = (t & ~(0x38000000 >>(27 - i))) | x << i;			// change the bits to the new option
			FlashWrite((void *)w, t, FLASH_WRITE_WORD);
			return;
		}
	}
}




#if defined(COLOUR)

/**********************************************************************************************
   These routines are used to access the real time clock in the colour version
***********************************************************************************************/

#define I2C_TIMEOUT     100
#define RTC_ADDR        0b1101000

int ReadRTC(int reg) {
    int result;

        PauseTimer = 0;
        I2CEnable(I2C2, false);
        uSec(1000);
        I2CSetFrequency(I2C2, BUSFREQ, 20);                         // Set the I2C baudrate
        I2CEnable(I2C2, true);                                      // Enable the I2C bus

        while(!I2CBusIsIdle(I2C2))                                  // Wait for the bus to be idle, then start the transfer
            if(PauseTimer > I2C_TIMEOUT) return -1;

        if(I2CStart(I2C2) != I2C_SUCCESS) return -1;
        while(!(I2CGetStatus(I2C2) & I2C_START))                    // Wait for the signal to complete
            if(PauseTimer > I2C_TIMEOUT) return -1;

       if(I2CSendByte(I2C2, (RTC_ADDR << 1))) return -1;            // send the address of the RTC
        while(!I2CTransmissionHasCompleted(I2C2))
            if(PauseTimer > I2C_TIMEOUT) return -1;
        if(!I2CByteWasAcknowledged(I2C2)) return -1;

        if(I2CSendByte(I2C2, reg)) return -1;                       // send the register that we want
        while(!I2CTransmissionHasCompleted(I2C2))
            if(PauseTimer > I2C_TIMEOUT) return -1;
        if(!I2CByteWasAcknowledged(I2C2)) return -1;

        if(I2CRepeatStart(I2C2) != I2C_SUCCESS) return -1;          // send a repeated start to switch to read mode
        while(!(I2CGetStatus(I2C2) & I2C_START))                    // Wait for the signal to complete
            if(PauseTimer > I2C_TIMEOUT) return -1;

        if(I2CSendByte(I2C2, (RTC_ADDR << 1) | 1)) return -1;       // send a read request
        while(!I2CTransmissionHasCompleted(I2C2))
            if(PauseTimer > I2C_TIMEOUT) return -1;
        if(!I2CByteWasAcknowledged(I2C2)) return -1;

        I2CReceiverEnable(I2C2, true);
        while(!I2CReceivedDataIsAvailable(I2C2))
            if(PauseTimer > I2C_TIMEOUT) return -1;
        result = (unsigned int)I2CGetByte(I2C2);                    // get the response
        I2CAcknowledgeByte(I2C2, false);

        while(!I2CAcknowledgeHasCompleted(I2C2))
            if(PauseTimer > I2C_TIMEOUT) return -1;

        I2CReceiverEnable(I2C2, false);                             // stop the I2C
        I2CStop(I2C2);
        while(!(I2CGetStatus(I2C2) & I2C_STOP))                     // Wait for the signal to complete
            if(PauseTimer > I2C_TIMEOUT) return -1;

        I2CEnable(I2C2, false);

        return result;
}



void WriteRTC(int reg, int data) {
        PauseTimer = 0;
        I2CEnable(I2C2, false);
        uSec(1000);
        I2CSetFrequency(I2C2, BUSFREQ, 20);                         // Set the I2C baudrate
        I2CEnable(I2C2, true);                                      // Enable the I2C bus

        while(!I2CBusIsIdle(I2C2))                                                      // Wait for the bus to be idle, then start the transfer
            if(PauseTimer > I2C_TIMEOUT) error("Setting Real Time Clock");

        if(I2CStart(I2C2) != I2C_SUCCESS) error("Setting Real Time Clock");
        while(!(I2CGetStatus(I2C2) & I2C_START))                                        // Wait for the signal to complete
            if(PauseTimer > I2C_TIMEOUT) error("Setting Real Time Clock");

        if(I2CSendByte(I2C2, (RTC_ADDR << 1))) error("Setting Real Time Clock");        // send the address of the RTC
        while(!I2CTransmissionHasCompleted(I2C2))
            if(PauseTimer > I2C_TIMEOUT) error("Setting Real Time Clock");
        if(!I2CByteWasAcknowledged(I2C2)) error("Setting Real Time Clock");

        if(I2CSendByte(I2C2, reg)) error("Setting Real Time Clock");                    // send the register that we want to change
        while(!I2CTransmissionHasCompleted(I2C2))
            if(PauseTimer > I2C_TIMEOUT) error("Setting Real Time Clock");
        if(!I2CByteWasAcknowledged(I2C2)) error("Setting Real Time Clock");

        if(I2CSendByte(I2C2, data)) error("Setting Real Time Clock");                   // and the new data
        while(!I2CTransmissionHasCompleted(I2C2))
            if(PauseTimer > I2C_TIMEOUT) error("Setting Real Time Clock");
        if(!I2CByteWasAcknowledged(I2C2)) error("Setting Real Time Clock");

        while(!I2CAcknowledgeHasCompleted(I2C2))
            if(PauseTimer > I2C_TIMEOUT) error("Setting Real Time Clock");

        I2CReceiverEnable(I2C2, false);                             // stop the I2C bus
        I2CStop(I2C2);
        while(!(I2CGetStatus(I2C2) & I2C_STOP))                     // Wait for the signal to complete
            if(PauseTimer > I2C_TIMEOUT) error("Setting Real Time Clock");

        I2CEnable(I2C2, false);

}



// get the time from the RTC and set the internal MMBasic clock
// Returns:  0 if the RTC is not installed
//           1 if the time on the RTC has not been set
//           2 if the time has been retrieved and the MMBasic clock has been set
int GetRTC(void) {
    int i;
	i = ReadRTC(0);
	if(i == -1) return 0;
    if(i & 0x80) return 1;
	SecondsTimer = 0;
	second = (i >> 4) * 10 + (i & 0x0f);
	i = ReadRTC(1);
	minute =  (i >> 4) * 10 + (i & 0x0f);
	i = ReadRTC(2);
	hour = (i >> 4) * 10 + (i & 0x0f);
	i = ReadRTC(4);
	day = (i >> 4) * 10 + (i & 0x0f);
	i = ReadRTC(5);
	month = (i >> 4) * 10 + (i &0x0f);
	i = ReadRTC(6);
	year = (i >> 4) * 10 + (i & 0x0f) + 2000;
	return 2;
}    




/****************************************************************************************************************
This is the startup logo
It uses a simple form of run length encoding
For each byte:
     - The top three bits is the colour
     - The lower 5 bits is the number of horizontal bits of that colour to draw
****************************************************************************************************************/
#define LOGO_BYTES   1244                                           // number of bytes in logo image
#define LOGO_WIDTH   205                                            // width of the logo image in bits

char logo[LOGO_BYTES] = {
                    0x1F, 0x1D, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5E,
                    0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5C, 0x09, 0x29, 0x09, 0x25,
                    0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5A, 0x0D, 0x25, 0x0D, 0x23, 0xDE, 0x1F, 0x05, 0xE7, 0x0B, 0xE7, 0x17, 0x9E, 0x5A, 0x04, 0xE7, 0x04, 0x23, 0x04, 0xE7, 0x04, 0x21, 0xDE, 0x1F, 0x04, 0xEB, 0x07,
                    0xEB, 0x15, 0x9E, 0x59, 0x03, 0xEB, 0x03, 0x21, 0x03, 0xEB, 0x03, 0xDE, 0x1F, 0x03, 0xED, 0x05, 0xED, 0x13, 0x9E, 0x59, 0x03, 0xED, 0x05, 0xED, 0x03, 0xDC, 0x1F, 0x03, 0xEF, 0x03, 0xEF, 0x12,
                    0x9E, 0x58, 0x03, 0xEF, 0x03, 0xEF, 0x03, 0xDB, 0x1F, 0x02, 0xF1, 0x01, 0xF1, 0x10, 0x9E, 0x59, 0x02, 0xF1, 0x01, 0xF1, 0x02, 0xDA, 0x1F, 0x03, 0xFF, 0xE4, 0x10, 0x9E, 0x58, 0x03, 0xFF, 0xE4,
                    0x03, 0xD9, 0x1F, 0x02, 0xFF, 0xE6, 0x0E, 0x9E, 0x59, 0x02, 0xFF, 0xE6, 0x02, 0xD8, 0x1F, 0x03, 0xFF, 0xE6, 0x15, 0x88, 0x0B, 0x84, 0x0B, 0x41, 0x0A, 0x42, 0x03, 0xFF, 0xE6, 0x03, 0xC1, 0x0A,
                    0xC2, 0x1F, 0x0C, 0xFF, 0xE8, 0x16, 0x85, 0x0D, 0x82, 0x18, 0x41, 0x02, 0xFF, 0xE8, 0x1F, 0x1B, 0xFF, 0xE8, 0x0B, 0xE8, 0x05, 0x83, 0x02, 0xE9, 0x06, 0xE9, 0x03, 0xE8, 0x02, 0x41, 0x02, 0xFF,
                    0xE8, 0x04, 0xE8, 0x04, 0xF6, 0x08, 0xEB, 0x01, 0xFF, 0xE8, 0x09, 0xEC, 0x04, 0x82, 0x02, 0xEA, 0x04, 0xEA, 0x03, 0xE8, 0x02, 0x41, 0x02, 0xFF, 0xE8, 0x04, 0xE8, 0x04, 0xF6, 0x06, 0xED, 0x01,
                    0xEB, 0x02, 0xED, 0x02, 0xEB, 0x07, 0xF0, 0x03, 0x81, 0x03, 0xE9, 0x04, 0xE9, 0x04, 0xE8, 0x02, 0x41, 0x02, 0xEB, 0x02, 0xED, 0x02, 0xEB, 0x04, 0xE8, 0x04, 0xF6, 0x05, 0xEE, 0x01, 0xEA, 0x04,
                    0xEB, 0x04, 0xEA, 0x06, 0xF2, 0x02, 0x82, 0x02, 0xEA, 0x02, 0xEA, 0x04, 0xE8, 0x02, 0x41, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x04, 0xF6, 0x04, 0xEF, 0x01, 0xEA, 0x04, 0xEB, 0x04,
                    0xEA, 0x06, 0xF2, 0x03, 0x81, 0x03, 0xE9, 0x02, 0xE9, 0x05, 0xE8, 0x02, 0x41, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x04, 0xF6, 0x04, 0xEF, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x05,
                    0xF4, 0x02, 0x82, 0x03, 0xF2, 0x03, 0x41, 0x02, 0xE8, 0x02, 0x41, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x04, 0xF6, 0x03, 0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x05, 0xF4, 0x03,
                    0x82, 0x02, 0xF2, 0x02, 0x42, 0x02, 0xE8, 0x02, 0x41, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x04, 0xF6, 0x03, 0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x82, 0x03,
                    0xF0, 0x03, 0x42, 0x02, 0xE8, 0x02, 0x41, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x04, 0xF6, 0x03, 0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE9, 0x04, 0xE9, 0x02, 0x83, 0x02,
                    0xF0, 0x02, 0x43, 0x02, 0xE8, 0x02, 0x41, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0A, 0xE8, 0x09, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x06, 0xE8, 0x02, 0x83, 0x03,
                    0xEE, 0x03, 0x43, 0x02, 0xE8, 0x02, 0x41, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC1, 0x08, 0xE8, 0x0A, 0xE8, 0x09, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0x82, 0x02,
                    0xE8, 0x02, 0x84, 0x02, 0xEE, 0x02, 0x44, 0x02, 0xE8, 0x02, 0x41, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC5, 0x04, 0xE8, 0x0A, 0xE8, 0x09, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04,
                    0xE8, 0x02, 0x82, 0x02, 0xE8, 0x02, 0x84, 0x03, 0xEC, 0x03, 0x44, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC4, 0x05, 0xE8, 0x0A, 0xF0, 0x01, 0xEA, 0x04,
                    0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x06, 0xE8, 0x02, 0x85, 0x02, 0xEC, 0x02, 0x45, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC4, 0x05, 0xE8, 0x0A, 0xF0, 0x01,
                    0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x06, 0xE8, 0x02, 0x85, 0x03, 0xEA, 0x03, 0x45, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC3, 0x06, 0xE8, 0x0A,
                    0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x86, 0x02, 0xEA, 0x02, 0x46, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC3, 0x06, 0xE8, 0x0A,
                    0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x85, 0x03, 0xEA, 0x03, 0x45, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC2, 0x07, 0xE8, 0x0A,
                    0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x85, 0x02, 0xEC, 0x02, 0x45, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC2, 0x07, 0xE8, 0x0A,
                    0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x84, 0x03, 0xEC, 0x03, 0x44, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC1, 0x08, 0xE8, 0x0A,
                    0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x84, 0x02, 0xEE, 0x02, 0x44, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x02, 0xC1, 0x08, 0xE8, 0x0A,
                    0xE8, 0x09, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x83, 0x03, 0xEE, 0x03, 0x43, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0A, 0xE8, 0x09,
                    0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x83, 0x02, 0xF0, 0x02, 0x43, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0A, 0xE8, 0x09, 0xEA, 0x04,
                    0xEB, 0x04, 0xEA, 0x04, 0xF6, 0x02, 0x82, 0x03, 0xF0, 0x03, 0x42, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0A, 0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04,
                    0xEA, 0x04, 0xE8, 0x06, 0xE8, 0x02, 0x82, 0x02, 0xF2, 0x02, 0x42, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0A, 0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04,
                    0xEA, 0x04, 0xE8, 0x06, 0xE8, 0x02, 0x81, 0x03, 0xF2, 0x03, 0x41, 0x02, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0A, 0xF0, 0x01, 0xEA, 0x04, 0xEB, 0x04,
                    0xEA, 0x04, 0xE8, 0x02, 0x82, 0x02, 0xE8, 0x05, 0xE9, 0x02, 0xE9, 0x05, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0B, 0xEF, 0x01, 0xEA, 0x04, 0xEB, 0x04,
                    0xEA, 0x04, 0xE8, 0x02, 0x82, 0x02, 0xE8, 0x04, 0xEA, 0x02, 0xEA, 0x04, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0B, 0xEF, 0x01, 0xEA, 0x04, 0xEB, 0x04,
                    0xEA, 0x04, 0xE8, 0x02, 0x82, 0x02, 0xE8, 0x04, 0xE9, 0x04, 0xE9, 0x04, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0C, 0xEE, 0x01, 0xEA, 0x04, 0xEB, 0x04,
                    0xEA, 0x04, 0xE8, 0x02, 0x82, 0x02, 0xE8, 0x03, 0xEA, 0x04, 0xEA, 0x03, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0D, 0xED, 0x01, 0xEA, 0x04, 0xEB, 0x04,
                    0xEA, 0x04, 0xE8, 0x02, 0x82, 0x02, 0xE8, 0x03, 0xE9, 0x06, 0xE9, 0x03, 0xE8, 0x02, 0x21, 0x02, 0xEA, 0x04, 0xEB, 0x04, 0xEA, 0x04, 0xE8, 0x0B, 0xE8, 0x0F, 0xEB, 0x1F, 0x17, 0x82, 0x18, 0x42,
                    0x18, 0x21, 0x1F, 0x1F, 0x1F, 0x1F, 0x0F, 0x82, 0x0A, 0x84, 0x0A, 0x41, 0x0B, 0x44, 0x0B, 0x41, 0x0A, 0x23, 0x0C, 0x22, 0x0D, 0xC2, 0x0C, 0xC2, 0x1F, 0x1F, 0x1C, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F,
                    0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E,
                    0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F,
                    0x16, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x16, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x1F, 0x17, 0x9E, 0x5E, 0x3E, 0xDE, 0x1F, 0x18
};


// define where the elements of the start up messages will be placed
#define LOGO_X      137
#define LOGO_Y      0

#define MSG_X       ((480 - (strlen(MES_SIGNON)-2)*6)/2)
#define MSG_Y       75
#define MSG_COLOUR  CYAN

#define COPYRIGHT_X ((480 - (strlen(MES_COPYRIGHT)-2)*6)/2)
#define COPYRIGHT_Y 87

#define CLK_COLOUR  YELLOW
//#define CLOCKMSG_X  0
#define CLOCKMSG_Y  104

#define PROMPT_Y    132

void DrawLogo(void) {
    int i, j, n;
    char tmp[150];										// buffer for building the time message
    char *th;
    static const char *monthstr[12] = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };

    n = 0;
    for(i = 0; i < LOGO_BYTES; i++) {
        for(j = 0; j < (logo[i] & 0b00011111); j++) {
            plot(LOGO_X + (n % LOGO_WIDTH), LOGO_Y + (n / LOGO_WIDTH), logo[i] >> 5);
            n++;
        }
    }

    CurrentFgColour = MSG_COLOUR;
    MMPosX = MSG_X; MMPosY = MSG_Y;
	MMPrintString(MES_SIGNON); 									// print signon message
    MMPosX = COPYRIGHT_X; MMPosY = COPYRIGHT_Y;
    MMPrintString(MES_COPYRIGHT);

    #if defined(TFT_MAXIMITE)
		InitTouchLCD(CLK_COLOUR, COPYRIGHT_Y + 12);             // place Carsten's msg immediately after the copyright
		#undef CLOCKMSG_Y
		#define CLOCKMSG_Y 116                                  // and shift the clock message further down
    #endif

    i = GetRTC();
    if(i) {
        if(i == 1) {
            CurrentFgColour = CLK_COLOUR;
            strcpy(tmp, "Battery Backed Clock Not Set");
        } else {
            if(day == 1 || day == 21 || day == 31)
    		    th = "st";
    		else if(day == 2 || day == 22)
    		    th = "nd";
    		else if(day == 3 || day == 23)
    		    th = "rd";
    		else
    		    th = "th";
    		sprintf(tmp, "%d:%02d %s  %d%s %s %d", hour > 12 ? hour - 12: hour, minute, hour >= 12 ? "PM" : "AM", day, th, monthstr[month - 1], year);
    	}
    	MMPosX = (480 - strlen(tmp)*6)/2; MMPosY = CLOCKMSG_Y;
    	MMPrintString(tmp);
    }	

    CurrentFgColour = WHITE;
	MMPosX = 0; MMPosY = PROMPT_Y;
}

#endif      // COLOUR
