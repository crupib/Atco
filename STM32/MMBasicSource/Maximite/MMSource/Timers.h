/***********************************************************************************************************************
MMBasic

timers.h

Include file that contains the globals and defines for timers.c in MMBasic.
  
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

// timer variables
extern volatile unsigned int mSecTimer;								// this is used to count mSec
extern volatile unsigned int PauseTimer;						    // this is used in the PAUSE command
extern volatile unsigned int IntPauseTimer;							// this is used in the PAUSE command
extern volatile unsigned int CursorTimer;							// used to control cursor blink rate
extern volatile unsigned int InkeyTimer;							// used to delay on an escape character
extern volatile unsigned int USBBannerTimer;
extern volatile unsigned int SecondsTimer;
extern volatile unsigned int WDTimer;                               // used for the watchdog timer
extern volatile int ds18b20Timer;

// date/time counters
extern volatile int second;													
extern volatile int minute;
extern volatile int hour;
extern volatile int day;
extern volatile int month;
extern volatile int year;

// sound variables
extern volatile unsigned int SoundPlay;

// SD Card Activity
extern volatile int SDActivityLED;
extern volatile int SDCardRemoved;
volatile int CheckingSD;

// global timer functions
extern void initTimers(void);

// define the blink rate for the cursor
#define CURSOR_OFF		350											// cursor off time in mS
#define CURSOR_ON		650											// cursor on time in mS

extern unsigned char PulsePin[];
extern unsigned char PulseDirection[];
extern int PulseCnt[];
extern int PulseActive;

