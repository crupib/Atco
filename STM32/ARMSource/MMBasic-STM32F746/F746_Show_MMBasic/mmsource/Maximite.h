/***********************************************************************************************************************
MMBasic

Maximite.h

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


#ifndef MMHeader
#define MMHeader



  // The main clock frequency for the chip
  #define	CLOCKFREQ		(200000000L)

  // start up messages
  #define MES_SIGNON  "STM32F746 MMBasic V" VERSION "\r\n"
  #define MES_COPYRIGHT	"Copyright " YEAR " Geoff Graham\r\n"

  #define nop	__asm__ ("NOP")

  #define forever 1
  #define true	1
  #define false	0

  #define dp(...) {char s[140];sprintf(s,  __VA_ARGS__); MMPrintString(s); MMPrintString("\r\n");}

  // MMBasic variables defined in Main.c
  extern int MMCharPos;
  extern volatile int MMAbort;
  extern int FileXfr, BreakKey;                                   // both are used to manage the reaction to CtrlC
  extern int USBOn, VideoOn;										// variables controlling the display of the output
  extern char *OnKeyGOSUB;                                        // used for the target in ON KEY target

	// getting and setting options
	int GetFlashOption(const unsigned int *w);
	void SetFlashOption(const unsigned int *w, int x);


// functions for sending data to keyboard/USB (defined in Main.c)
extern void MMPrintString(char *);
extern void CheckUSB(void);
extern char MMPutc(char c);
extern int MMgetchar(void);
extern char MMputchar(char c);
extern void USBPutchar(char c);
extern void USBPutEscape(char *p);
extern void USBSignon(void);
extern int isKeyInBuffer(void);                                 // true if a keystroke is in the input buffer (defined in main.c)



#endif // MMHeader

