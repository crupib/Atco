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

    // #define INCLUDE_CAN                             // remove the comment on this line if you wish to include CAN networking


	// The main clock frequency for the chip
	#define	CLOCKFREQ		(80000000L)				// This is set in in Configuration Bits.h

	// The peripheral bus frequency
	#define BUSFREQ			(CLOCKFREQ/1)			// This is set in the first few lines of main.c

    // start up messages
    #ifdef MAXIMITE
    	#define MES_SIGNON  "Maximite BASIC Version " VERSION "\r\n"
    #endif

    #ifdef UBW32
    	#define MES_SIGNON  "UBW32 MMBasic Version " VERSION "\r\n"
    #endif

    #ifdef TFT_MAXIMITE
        #define MES_SIGNON  "TFT Maximite MMBasic V" VERSION "\r\n"
    #else
        #ifdef INCLUDE_CAN
            #ifdef DUINOMITE
            	#define MES_SIGNON  "DuinoMite MMBasic Version " VERSION " with CAN\r\n"
            #endif
    
            #ifdef COLOUR
            	#define MES_SIGNON  "Colour Maximite MMBasic V" VERSION " with CAN\r\n"
            #endif
        #else
            #ifdef DUINOMITE
            	#define MES_SIGNON  "DuinoMite MMBasic Version " VERSION "\r\n"
            #endif
    
            #ifdef COLOUR
            	#define MES_SIGNON  "Colour Maximite MMBasic V" VERSION "\r\n"
            #endif
        #endif
    #endif
    
    #define MES_COPYRIGHT	"Copyright " YEAR " Geoff Graham\r\n"


	#define nop	__asm__ ("NOP")

	#define forever 1
	#define true	1
	#define false	0

    #define dp(...) {char s[140];sprintf(s,  __VA_ARGS__); MMPrintString(s); MMPrintString("\r\n");}
	#if defined(__DEBUG)
	    #define debughalt() __asm__ volatile (" sdbbp 0")
		void dump(char *p, int nbr);
	#else
	    #define debughalt() (void)0
	#endif

	// Don't use the core timer.  This is not as accurate but it does not waste a timer for trivial timing jobs
	// maximum delay is 26000uS (26mS)
	// #define uSec(us) { volatile unsigned int i; for(i = 0; i < (((CLOCKFREQ/1000) * us) / 9440); i++); }

    // Use the core timer, much better but it ties up the last remaining timer.  The maximum delay is 4 seconds
	#define uSec(us) { unsigned int i = ((((unsigned int)(us) * 1000) - 450) / (2000000000/CLOCKFREQ)); WriteCoreTimer(0); while(ReadCoreTimer() < i); }


	//#ifdef __DEBUG
		// Debugging console. Functions available include DBPRINTF(),DBSCANF(),DBGETC(),DBGETWORD(),DBPUTC(),DBPUTWORD()
		// note speed is reduced by 1/3 in debug mode (ie 20MHz in debug vs 60MHz in release mode)
	//  	#define _APPIO_DEBUG											// comment out to disable console debugger
	//  	#include <sys/appio.h>
	//#endif

	#define SDActivityTime 40

	// functions for processing USB data (defined in Main.c)
	#define INP_QUEUE_SIZE	256
	extern volatile unsigned char InpQueue[INP_QUEUE_SIZE];
	extern volatile int InpQueueHead, InpQueueTail;

	// functions for getting data from keyboard/USB (defined in Main.c)
	extern int MMInkey(void);
	extern char MMGetc(void);
	extern void AddToKeystrokeBuffer(unsigned char c);

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

	// used to detect if PEEK/POKE caused an exceotion
	//extern unsigned int _excep_peek;

	// MMBasic variables defined in Main.c
	extern int MMCharPos;
	extern volatile int MMAbort;
	extern int FileXfr, BreakKey;                                   // both are used to manage the reaction to CtrlC
	extern int Autorun;
	extern int USBOn, VideoOn;										// variables controlling the display of the output
    extern char *OnKeyGOSUB;                                        // used for the target in ON KEY target

	// getting and setting options
	int GetFlashOption(const unsigned int *w);
	void SetFlashOption(const unsigned int *w, int x);

	// writing to the flash
	#define FLASH_WRITE_WORD          0x4001      // Write a word
	#define FLASH_PAGE_ERASE       	  0x4004      // Page erase
	void FlashWrite(void *p, unsigned int wrd, unsigned int operation);

    // access the real time clock chip
    extern int ReadRTC(int reg);
    extern void WriteRTC(int reg, int data);
    extern int GetRTC(void);

	// Uncomment the following #define to turn on performance profiling
	// To use profiling run a program.  When it terminates the results will be written to the SD card as PROFILE.XLS
	// Note:  The serial ports cannot be used while profiling and execution speed will be reduced by approx 10%
	//#define PROFILE

	// Uncomment the following #define to display stack usage of the previous immediate command
	//#define REPORT_STACK_USAGE


	#ifdef PROFILE
		#define P_START_ADDR	0x9d004800							// start address to profile
		#define P_END_ADDR		0x9d070000							// this must be increased if more code is added
		#define P_GRANUALITY	64									// reporting increments
		void StartProfiling(void);
		void StopProfiling(void);
	#else
		#define StartProfiling(void){}
		#define StopProfiling(void)	{}
	#endif


	#ifdef REPORT_STACK_USAGE
		void InitStackUsage(void);
		void PrintStackUsage(void);
	#else
		#define InitStackUsage()   {}
		#define PrintStackUsage()  {}
	#endif

#endif // MMHeader

