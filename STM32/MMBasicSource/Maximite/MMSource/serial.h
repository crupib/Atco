/***********************************************************************************************************************
MMBasic

serial.h

Include file that contains the globals and defines for serial.c in MMBasic.
  
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

#define	COM12_MAX_BAUD_RATE			19200                           // Software UARTs (hardware UARTS have no set limit)
#define	COM_DEFAULT_BAUD_RATE       9600
#define	COM_DEFAULT_BUF_SIZE		256
#define COM_FLOWCTRL_MARGIN			6

// global variables
extern int SerialConsole;											// holds the com number for the console function or zero if disabled
extern char *com1_interrupt;										// pointer to the interrupt routine
extern int com1_ilevel;												// number nbr of chars in the buffer for an interrupt
extern char *com2_interrupt;										// pointer to the interrupt routine
extern int com2_ilevel;												// number nbr of chars in the buffer for an interrupt

extern int com1_buf_size;											// buffer size
extern int com2_buf_size;

#ifdef DUINOMITE
extern char *com3_interrupt;										// pointer to the interrupt routine
extern int com3_ilevel;												// number nbr of chars in the buffer for an interrupt
extern char *com4_interrupt;										// pointer to the interrupt routine
extern int com4_ilevel;												// number nbr of chars in the buffer for an interrupt

extern int com3_buf_size;											// buffer size
extern int com4_buf_size;
#endif

// global functions
void SerialOpen(char *spec, int as_console);
void SerialClose(int comnbr);
unsigned char SerialPutchar(int comnbr, unsigned char c);
int SerialRxStatus(int comnbr);
int SerialTxStatus(int comnbr);
int SerialGetchar(int comnbr);
