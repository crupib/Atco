/***********************************************************************************************************************
Maximite

serial.c

This module manages the serial interfaces.

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

//#define INCLUDE_FUNCTION_DEFINES

#include <p32xxxx.h>
#include <plib.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

// variables for com1
int com1 = 0;														// true if COM1 is enabled
int com1_buf_size;													// size of the buffer used to receive chars
int com1_div;														// determines the baud rate
int com1_fc;														// true if COM1 is using flow control
int com1_de;                                                        // true if COM1 is running in RS485 mode
char *com1_interrupt;												// pointer to the interrupt routine
int com1_ilevel;													// number nbr of chars in the buffer for an interrupt

int com1Rx_cnt;														// used to count the timer ticks
int com1Rx_start_cnt;												// the starting count for com1Rx_cnt
unsigned char *com1Rx_buf;											// pointer to the buffer for received characters
volatile int com1Rx_head, com1Rx_tail;								// head and tail of the ring buffer for com1

int com1Tx_cnt;														// used to count the timer ticks
int com1Tx_start_cnt;												// the starting count for com1Tx_cnt
unsigned char *com1Tx_buf;											// pointer to the buffer for transmitted characters
volatile int com1Tx_head, com1Tx_tail;								// head and tail of the ring buffer for com1

// variables for com2
int com2 = 0;														// true if COM2 is enabled
int com2_buf_size;													// size of the buffer used to receive chars
int com2_div;														// determines the baud rate
char *com2_interrupt;												// pointer to the interrupt routine
int com2_ilevel;													// number nbr of chars in the buffer for an interrupt

int com2Rx_cnt;														// used to count the timer ticks
int com2Rx_start_cnt;												// the starting count for com2Rx_cnt
unsigned char *com2Rx_buf;											// pointer to the buffer for received characters
volatile int com2Rx_head, com2Rx_tail;								// head and tail of the ring buffer for com2 Rx

int com2Tx_cnt;														// used to count the timer ticks
int com2Tx_start_cnt;												// the starting count for com2Tx_cnt
unsigned char *com2Tx_buf;											// pointer to the buffer for transmitted characters
volatile int com2Tx_head, com2Tx_tail;								// head and tail of the ring buffer for com2 Tx


#ifdef DUINOMITE
// variables for com3
int com3 = 0;                                                       // true if COM3 is enabled
int com3_buf_size;                                                  // size of the buffer used to receive chars
char *com3_interrupt;                                               // pointer to the interrupt routine
int com3_ilevel;                                                    // number nbr of chars in the buffer for an interrupt

unsigned char *com3Rx_buf;                                          // pointer to the buffer for received characters
volatile int com3Rx_head, com3Rx_tail;                              // head and tail of the ring buffer for com3 Rx

unsigned char *com3Tx_buf;                                          // pointer to the buffer for transmitted characters
volatile int com3Tx_head, com3Tx_tail;                              // head and tail of the ring buffer for com3 Tx

// variables for com4
int com4 = 0;                                                       // true if COM4 is enabled
int com4_buf_size;                                                  // size of the buffer used to receive chars
char *com4_interrupt;                                               // pointer to the interrupt routine
int com4_ilevel;                                                    // number nbr of chars in the buffer for an interrupt

unsigned char *com4Rx_buf;                                          // pointer to the buffer for received characters
volatile int com4Rx_head, com4Rx_tail;                              // head and tail of the ring buffer for com4 Rx

unsigned char *com4Tx_buf;                                          // pointer to the buffer for transmitted characters
volatile int com4Tx_head, com4Tx_tail;                              // head and tail of the ring buffer for com4 Tx
#endif


int SerialConsole = 0;												// holds the serial port number if the console function is enabled


/***************************************************************************************************
Initialise the serial function including the timer and interrupts.
****************************************************************************************************/
void SerialOpen(char *spec, int as_console) {
	int baud, i, oc, fc, de, s2, bufsize, ilevel;
	char *interrupt;
	
	#ifdef PROFILE
		error("Cannot use serial while profiling");
	#endif

	getargs(&spec, 13, ":,");										// this is a macro and must be the first executable stmt
	if(argc != 2 && (argc & 0x01) == 0) error("Invalid COM specification");

	if(as_console && SerialConsole) error("The serial console is already open");

    oc = fc = de = s2 = false;
    for(i = 0; i < 4; i++) {
    	if(str_equal(argv[argc - 1], "OC")) { oc = true; argc -= 2; }	// get the open collector option
    	if(str_equal(argv[argc - 1], "FC")) { fc = true; argc -= 2; }	// get the flow control option
    	if(str_equal(argv[argc - 1], "DE")) { de = true; argc -= 2; }	// get the RS485 control option
    	if(str_equal(argv[argc - 1], "S2")) { s2 = true; argc -= 2; }	// get the two stop bit option
    }
    
	if(argc < 1 || argc > 9) error("Invalid COM specification");

	if(argc >= 3 && *argv[2]) {
		baud = getinteger(argv[2]);									// get the baud rate as a number
		if(spec[3] == '1' || spec[3] == '2') {                      // if it is a software UART
    		for(i = COM12_MAX_BAUD_RATE; baud != i; i /= 2)		    // make sure that the baud rate is the max rate evenly divided by 2
    			if(i <= 300) error("Invalid baud rate");
		}
	} else
		baud = COM_DEFAULT_BAUD_RATE;

	if(argc >= 5 && *argv[4]) {
		bufsize = getinteger(argv[4]);								// get the buffer size as a number
		if(bufsize <= COM_FLOWCTRL_MARGIN + 1) error("Invalid COM specification");
	} else
		bufsize = COM_DEFAULT_BUF_SIZE;

	if(argc >= 7) {
    	InterruptUsed = true;
		interrupt = GetIntAddress(argv[6]);							// get the interrupt location
	} else
		interrupt = NULL;

	if(argc >= 9) {
		ilevel = getinteger(argv[8]);								// get the buffer level for interrupt as a number
		if(ilevel < 1 || ilevel > bufsize) error("Invalid COM specification");
	} else
		ilevel = 1;


	if(spec[3] == '1') {
	///////////////////////////////// this is COM1 ////////////////////////////////////
		if(com1) error("COM port is already open");

		com1_div = (COM12_MAX_BAUD_RATE/baud) * 3;					// com2_div determines the baud rate
		com1_buf_size = bufsize;									// extracted from the comspec above
		if(fc && de) error("DE is invalid");
		com1_fc = fc;
		com1_de = de;
		com1_interrupt = interrupt;
		com1_ilevel	= ilevel;

		if(fc || de) {
    		ExtCfg(P_COM1_RTS_PIN_NBR, EXT_NOT_CONFIG);
			ExtSet(P_COM1_RTS_PIN_NBR, fc ? 1:0);						// start with the pin high (OK to send) if flow control or low if RS485
			ExtCfg(P_COM1_RTS_PIN_NBR, oc ? EXT_OC_OUT : EXT_DIG_OUT);	// setup the RTS pin
			ExtCfg(P_COM1_RTS_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use
		}
		if(fc) {
			ExtCfg(P_COM1_CTS_PIN_NBR, EXT_DIG_IN);						// setup the CTS pin
			ExtCfg(P_COM1_CTS_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use
		}

		// setup for receive
		com1Rx_start_cnt = (27 + 1) * (com1_div / 3);
		com1Rx_buf = getmemory(com1_buf_size);						// setup the buffer
		com1Rx_head = com1Rx_tail = 0;
		ExtCfg(P_COM1_RX_PIN_NBR, EXT_DIG_IN);						// pin 15 is Rx (an input)
		ExtCfg(P_COM1_RX_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use

		// setup for transmit
        if(de)
		    com1Tx_start_cnt = 30 * (com1_div / 3) + 2;             // RS485 needs an extra stop bit at the end
		else if(s2)
    		com1Tx_start_cnt = 33 * (com1_div / 3);                 // if two stop bits (note: in normal serial (RS232) the stop bit is at the start!)
    	else
    		com1Tx_start_cnt = 30 * (com1_div / 3);                 // for normal serial
    		
		com1Tx_buf = getmemory(com1_buf_size);						// setup the buffer
		com1Tx_head = com1Tx_tail = 0;
		ExtCfg(P_COM1_TX_PIN_NBR, EXT_NOT_CONFIG);
		ExtSet(P_COM1_TX_PIN_NBR, 1);								// start with the Tx pin high (ie, idle)
		ExtCfg(P_COM1_TX_PIN_NBR, oc ? EXT_OC_OUT : EXT_DIG_OUT);	// set the Tx pin as an output
		ExtCfg(P_COM1_TX_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use

		if(as_console) SerialConsole = 1;
		com1 = true;
	}
    if (spec[3] == '2') {
	///////////////////////////////// this is COM2 ////////////////////////////////////
		if(com2) error("COM port is already open");
        if(fc) error("Flow control not available");
		if(de) error("DE is invalid");

		com2_div = (COM12_MAX_BAUD_RATE/baud) * 3;					// com2_div determines the baud rate
		com2_buf_size = bufsize;									// extracted from the comspec above
		com2_interrupt = interrupt;
		com2_ilevel	= ilevel;

		// setup for receive
		com2Rx_start_cnt = (27 + 1) * (com2_div / 3);
		com2Rx_buf = getmemory(com2_buf_size);						// setup the buffer
		com2Rx_head = com2Rx_tail = 0;
		ExtCfg(P_COM2_RX_PIN_NBR, EXT_DIG_IN);						// pin 18 is Rx (an input)
		ExtCfg(P_COM2_RX_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use

		// setup for transmit
		if(s2)
    		com2Tx_start_cnt = 33 * (com2_div / 3);                 // if two stop bits (note: in normal serial (RS232) the stop bit is at the start!)
    	else
    		com2Tx_start_cnt = 30 * (com2_div / 3);                 // for normal serial
		//com2Tx_start_cnt = 30 * (com2_div / 3);
		com2Tx_buf = getmemory(com2_buf_size);						// setup the buffer
		com2Tx_head = com2Tx_tail = 0;
		ExtCfg(P_COM2_TX_PIN_NBR, EXT_NOT_CONFIG);
		ExtSet(P_COM2_TX_PIN_NBR, 1);								// start with the Tx pin high (ie, idle)
		ExtCfg(P_COM2_TX_PIN_NBR, oc ? EXT_OC_OUT : EXT_DIG_OUT);	// set the Tx pin as an output
		ExtCfg(P_COM2_TX_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use

		if(as_console) SerialConsole = 2;
		com2 = true;
	}

#ifdef DUINOMITE
    if (spec[3] == '3') {
        ///////////////////////////////// this is COM3 ////////////////////////////////////
		if(com3) error("COM port is already open");
        if(fc) error("Flow control not available");
		if(de) error("DE is invalid");
        com3_buf_size = bufsize;                                    // extracted from the comspec above
        com3_interrupt = interrupt;
        com3_ilevel = ilevel;

        com3Rx_buf = getmemory(com3_buf_size);                      // setup the buffer
        com3Rx_head = com3Rx_tail = 0;

        com3Tx_buf = getmemory(com3_buf_size);                      // setup the buffer
        com3Tx_head = com3Tx_tail = 0;
        LATFbits.LATF5 = 1;
        TRISFbits.TRISF5 = 0;
        UARTConfigure(UART3A, UART_ENABLE_PINS_TX_RX_ONLY);
		if(s2)
            UARTSetLineControl(UART3A, UART_DATA_SIZE_8_BITS | UART_PARITY_NONE | UART_STOP_BITS_2);
        else
            UARTSetLineControl(UART3A, UART_DATA_SIZE_8_BITS | UART_PARITY_NONE | UART_STOP_BITS_1);
        UARTSetDataRate(UART3A, 80000000ul, baud);
        IFS1bits.U3ATXIF = 0;
        UARTEnable(UART3A, UART_ENABLE_FLAGS(UART_PERIPHERAL | UART_RX | UART_TX));
        if(as_console) SerialConsole = 3;
        com3 = true;
    }

    if (spec[3] == '4') {
        ///////////////////////////////// this is COM4 ////////////////////////////////////
		if(com4) error("COM port is already open");
        if(fc) error("Flow control not available");
		if(de) error("DE is invalid");
        com4_buf_size = bufsize;                                    // extracted from the comspec above
        com4_interrupt = interrupt;
        com4_ilevel = ilevel;

        com4Rx_buf = getmemory(com4_buf_size);                      // setup the buffer
        com4Rx_head = com4Rx_tail = 0;

        com4Tx_buf = getmemory(com4_buf_size);                      // setup the buffer
        com4Tx_head = com4Tx_tail = 0;

        ExtCfg(P_COM4_RX_PIN_NBR, EXT_COM_RESERVED + as_console);   // reserve the pin for com use
        ExtCfg(P_COM4_TX_PIN_NBR, EXT_COM_RESERVED + as_console);   // reserve the pin for com use
        
        LATFbits.LATF5 = 1;
        TRISFbits.TRISF5 = 0;
        UARTConfigure(UART3B, UART_ENABLE_PINS_TX_RX_ONLY);
        if(s2)
            UARTSetLineControl(UART3B, UART_DATA_SIZE_8_BITS | UART_PARITY_NONE | UART_STOP_BITS_2);
        else
            UARTSetLineControl(UART3B, UART_DATA_SIZE_8_BITS | UART_PARITY_NONE | UART_STOP_BITS_1);
        UARTSetDataRate(UART3B, 80000000ul, baud);
//        IFS1bits.U3BTXIF = 0;
        UARTEnable(UART3B, UART_ENABLE_FLAGS(UART_PERIPHERAL | UART_RX | UART_TX));
        if(as_console) SerialConsole = 4;
        com4 = true;
    }
#endif


 	// if timer 5 is off then set it up
    if(T5CON == 0) {
	    PR5 = ((BUSFREQ/COM12_MAX_BAUD_RATE) / 3) - 1;    			// ticks at 3 times the max baud rate
	    T5CON = 0x8000;         									// T4 on, prescaler 1:1
	    mT5SetIntPriority(6);  										// a high priority 
	    mT5ClearIntFlag();      									// clear interrupt flag
	    mT5IntEnable(1);       										// enable interrupt
	}
}




/***************************************************************************************************
Close a serial port.
****************************************************************************************************/
void SerialClose(int comnbr) {

	if(SerialConsole == comnbr) SerialConsole = 0;

	if(comnbr == 1 && com1) {
		com1 = false;
		com1_interrupt = NULL;
		ExtCfg(P_COM1_RX_PIN_NBR, EXT_NOT_CONFIG);
		ExtCfg(P_COM1_TX_PIN_NBR, EXT_NOT_CONFIG);
		if(com1_fc || com1_de) ExtCfg(P_COM1_RTS_PIN_NBR, EXT_NOT_CONFIG);
		if(com1_fc) ExtCfg(P_COM1_CTS_PIN_NBR, EXT_NOT_CONFIG);
		FreeHeap(com1Rx_buf);
		FreeHeap(com1Tx_buf);
	}

	if(comnbr == 2 && com2) {
		com2 = false;
		com2_interrupt = NULL;
		ExtCfg(P_COM2_RX_PIN_NBR, EXT_NOT_CONFIG);
		ExtCfg(P_COM2_TX_PIN_NBR, EXT_NOT_CONFIG);
		FreeHeap(com2Rx_buf);
		FreeHeap(com2Tx_buf);
	}

#ifdef DUINOMITE
    if (comnbr == 3 && com3) {
        UARTEnable(UART3A, UART_DISABLE_FLAGS(UART_PERIPHERAL | UART_RX | UART_TX));
        com3 = false;
        com3_interrupt = NULL;
        FreeHeap(com3Rx_buf);
        FreeHeap(com3Tx_buf);
    }
    if (comnbr == 4 && com4) {
        UARTEnable(UART3B, UART_DISABLE_FLAGS(UART_PERIPHERAL | UART_RX | UART_TX));
        com4 = false;
        com4_interrupt = NULL;
        ExtCfg(P_COM4_RX_PIN_NBR, EXT_NOT_CONFIG);
        ExtCfg(P_COM4_TX_PIN_NBR, EXT_NOT_CONFIG);
        FreeHeap(com4Rx_buf);
        FreeHeap(com4Tx_buf);
    }
    
	// if all com ports are closed we can disable the interrupts and timer
	if(!com1 && !com2 && !com3 && !com4) {
		mT5IntEnable(0);
		T5CON = 0;
	}
#else
	// if both com ports are closed we can disable the interrupts and timer
	if(!com1 && !com2) {
		mT5IntEnable(0);
		T5CON = 0;
	}
#endif
}



/***************************************************************************************************
Add a character to the serial output buffer.
****************************************************************************************************/
unsigned char SerialPutchar(int comnbr, unsigned char c) {
	if(comnbr == 1) {
		while(com1Tx_tail == ((com1Tx_head + 1) % com1_buf_size)) 	// wait if the buffer is full
			if(MMAbort) {											// allow the user to abort a hung serial port
				com1Tx_tail = com1Tx_head = 0;						// clear the buffer
				longjmp(mark, 1);									// and abort
			}
		com1Tx_buf[com1Tx_head] = c;								// add the char
		com1Tx_head = (com1Tx_head + 1) % com1_buf_size;			// advance the head of the queue
	}
	if(comnbr == 2) {
		while(com2Tx_tail == ((com2Tx_head + 1) % com2_buf_size))  	// wait if the buffer is full
			if(MMAbort) {											// allow the user to abort a hung serial port
				com2Tx_tail = com2Tx_head = 0;						// clear the buffer
				longjmp(mark, 1);									// and abort
			}
		com2Tx_buf[com2Tx_head] = c;								// add the char
		com2Tx_head = (com2Tx_head + 1) % com2_buf_size;			// advance the head of the queue
	}
	
#ifdef DUINOMITE
	if(comnbr == 3) {
		while(com3Tx_tail == ((com3Tx_head + 1) % com3_buf_size))  	// wait if the buffer is full
			if(MMAbort) {											// allow the user to abort a hung serial port
				com3Tx_tail = com3Tx_head = 0;						// clear the buffer
				longjmp(mark, 1);									// and abort
			}
		com3Tx_buf[com3Tx_head] = c;								// add the char
		com3Tx_head = (com3Tx_head + 1) % com3_buf_size;			// advance the head of the queue
	}
	if(comnbr == 4) {
		while(com4Tx_tail == ((com4Tx_head + 1) % com4_buf_size))  	// wait if the buffer is full
			if(MMAbort) {											// allow the user to abort a hung serial port
				com4Tx_tail = com4Tx_head = 0;						// clear the buffer
				longjmp(mark, 1);									// and abort
			}
		com4Tx_buf[com4Tx_head] = c;								// add the char
		com4Tx_head = (com4Tx_head + 1) % com4_buf_size;			// advance the head of the queue
	}
#endif

	return c;
}



/***************************************************************************************************
Get the status the serial receive buffer.
Returns the number of characters waiting in the buffer
****************************************************************************************************/
int SerialRxStatus(int comnbr) {
	int i = 0;
	if(comnbr == 1) {
		i = com1Rx_head - com1Rx_tail;
		if(i < 0) i += com1_buf_size;
	}
	if(comnbr == 2) {
		i = com2Rx_head - com2Rx_tail;
		if(i < 0) i += com2_buf_size;
	}
#ifdef DUINOMITE
	if(comnbr == 3) {
		i = com3Rx_head - com3Rx_tail;
		if(i < 0) i += com3_buf_size;
	}
	if(comnbr == 4) {
		i = com4Rx_head - com4Rx_tail;
		if(i < 0) i += com4_buf_size;
	}
#endif

	return i;
}



/***************************************************************************************************
Get the status the serial transmit buffer.
Returns the number of characters waiting in the buffer
****************************************************************************************************/
int SerialTxStatus(int comnbr) {
	int i = 0;
	if(comnbr == 1) {
		i = com1Tx_head - com1Tx_tail;
		if(i < 0) i += com1_buf_size;
	}
	if(comnbr == 2) {
		i = com2Tx_head - com2Tx_tail;
		if(i < 0) i += com2_buf_size;
	}
#ifdef DUINOMITE
	if(comnbr == 3) {
		i = com3Tx_head - com3Tx_tail;
		if(i < 0) i += com3_buf_size;
	}
	if(comnbr == 4) {
		i = com4Tx_head - com4Tx_tail;
		if(i < 0) i += com4_buf_size;
	}
#endif

	return i;
}



/***************************************************************************************************
Get a character from the serial receive buffer.
Note that this is returned as an integer and -1 means that there are no characters available
****************************************************************************************************/
int SerialGetchar(int comnbr) {
	int c;
	if(comnbr == 1) {
		if(com1_fc) P_COM1_RTS_SET_HI;							// make sure that RTS is asserted regardless
		if(com1Rx_head != com1Rx_tail) {						// if the queue has something in it
			c = com1Rx_buf[com1Rx_tail];						// get the char
 			com1Rx_tail = (com1Rx_tail + 1) % com1_buf_size;	// and remove from the buffer
			return c;
		}
	}
	if(comnbr == 2) {
		if(com2Rx_head != com2Rx_tail) {						// if the queue has something in it
			c = com2Rx_buf[com2Rx_tail];						// get the char
 			com2Rx_tail = (com2Rx_tail + 1) % com2_buf_size;	// and remove from the buffer
			return c;
		}
	}
#ifdef DUINOMITE
	if(comnbr == 3) {
		if(com3Rx_head != com3Rx_tail) {						// if the queue has something in it
			c = com3Rx_buf[com3Rx_tail];						// get the char
 			com3Rx_tail = (com3Rx_tail + 1) % com3_buf_size;	// and remove from the buffer
			return c;
		}
	}
	if(comnbr == 4) {
		if(com4Rx_head != com4Rx_tail) {						// if the queue has something in it
			c = com4Rx_buf[com4Rx_tail];						// get the char
 			com4Rx_tail = (com4Rx_tail + 1) % com4_buf_size;	// and remove from the buffer
			return c;
		}
	}
#endif

	return -1;													// return eof
}



/****************************************************************************************************************
Timer 5 interrupt processor - This fires at 3 times the maximum baud rate
com1_cnt is used to count the timer ticks while receiving a byte.  com1_div contains a number used to determine
when to clock in a bit.  At 19200 baud com1_div will be 3 and the bit stream is sampled on every third tick,
at 9600 baud com1_div will be 6 and sampling is every 6 ticks, etc.

This code is optimised for speed.  For example, individual integers are used for parameters (eg, com1Rx_cnt)
Receiving a single bit takes about 0.25uS while processing the whole byte (done when the stop bit is verified)
takes a bit over 0.5uS (at level 2 optimisation).  This excludes the interrupt overhead.

Note:  Profiling uses this timer and interrupt, so if it is enabled, this function is not compiled.
*****************************************************************************************************************/
#ifndef PROFILE
void __ISR( _TIMER_5_VECTOR, ipl6) T5Interrupt( void) {
	int i;
	static int com1Rx_byte;											// build the received byte here
	static int com1Tx_byte;											// hold the transmit byte here
	static int com2Rx_byte;											// build the received byte here
	static int com2Tx_byte;											// hold the transmit byte here

	if(com1) {
		///////////////////////////////// this is COM1 ////////////////////////////////////
		// this is the receive character routine
		// first check if we are waiting for the start bit (ie, com1Rx_cnt is zero)
		// if so, initialise.  Otherwise we must be receiving a character
		if(com1Rx_cnt == 0) {
			if(!P_COM1_RX_PORT) {
				com1Rx_cnt = com1Rx_start_cnt;						// got the leading edge of a start bit so initialise
				com1Rx_byte = 0;
			}
		} else {
			// we are in the process of receiving a byte so clock it in
			com1Rx_cnt--;
			if(com1Rx_cnt % com1_div == 0) {						// is this the right clock tick?
				if(com1Rx_cnt == 0) {
					// this should be the stop bit
					// check that the stop bit is high and that the start bit was low
					// if both are correct add the byte to the queue
					if(P_COM1_RX_PORT && (com1Rx_byte & 1) == 0) {
						com1Rx_byte >>= 1;							// shift out the start bit (not needed now)
						com1Rx_buf[com1Rx_head] = com1Rx_byte;		// store the byte in the ring buffer
						com1Rx_head = (com1Rx_head + 1) % com1_buf_size;// advance the head of the queue
						if(SerialConsole == 1 && com1Rx_byte == BreakKey && !FileXfr) 
							MMAbort = true;							// check for CTRL-C and if so tell BASIC to stop running
						if(com1Rx_head == com1Rx_tail) 				// if the buffer has overflowed throw away the oldest char
							com1Rx_tail = (com1Rx_tail + 1) % com1_buf_size;
						// check if we are using flow control and set RTS low if there are only a few bytes left
						if(com1_fc) {
							i = com1Rx_head - com1Rx_tail;
							if(i < 0) i += com1_buf_size;
							if(i >= com1_buf_size - COM_FLOWCTRL_MARGIN) P_COM1_RTS_SET_LO;
						}
					}
				} else {
					// we are receiving the start bit or a data bit - regardless, shift it into our byte
					com1Rx_byte >>= 1;								// shift up the data 1 bit
					if(P_COM1_RX_PORT) com1Rx_byte |= 0b100000000;	// and insert our new bit
				}
			}
		}

		// this is the transmit character routine
		if(com1Tx_cnt == 0) {										// if we are not transmitting a character
			if(com1Tx_head != com1Tx_tail) {						// if there is something in the buffer
				if(!com1_fc || (com1_fc && P_COM1_CTS_PORT)) {		// if flow control is not stopping us
					com1Tx_byte = ((com1Tx_buf[com1Tx_tail] << 1) | 0b111000000000);		// get the char from the buffer
					com1Tx_tail = (com1Tx_tail + 1) % com1_buf_size;// advance the tail of the queue
					com1Tx_cnt = com1Tx_start_cnt;					// and arm the transmission
				}
			}	
		} else {
			// we must be in the process of sending a character
			com1Tx_cnt--;
			if(com1Tx_cnt % com1_div == 0) {						// is this the right baud rate count?
				if(com1Tx_byte & 1)
					P_COM1_TX_SET_HI;								// output the bit hi - this is atomic and is interrupt proof
				else
					P_COM1_TX_SET_LO;
				com1Tx_byte >>= 1;									// and get the next bit ready
			}
			if(com1_de) {                                           // control the DE output for RS485
    			if(com1Tx_cnt == 0 && com1Tx_head == com1Tx_tail)
			            P_COM1_RTS_SET_LO;                          // turn off DE if no more data
			    else
			            P_COM1_RTS_SET_HI;                          // turn on DE if we are transmitting
			}            
		}
	}


	if(com2) {
		///////////////////////////////// this is COM2 ////////////////////////////////////
		// this is the receive character routine
		// first check if we are waiting for the start bit (ie, com2Rx_cnt is zero)
		// if so, initialise.  Otherwise we must be receiving a character so clock it in
		if(com2Rx_cnt == 0) {
			if(!P_COM2_RX_PORT) {
				com2Rx_cnt = com2Rx_start_cnt;						// got the leading edge of a start bit so initialise
				com2Rx_byte = 0;
			}
		} else {
			// we are in the process of receiving a byte
			com2Rx_cnt--;
			if(com2Rx_cnt % com2_div == 0) {						// is this the right clock tick?
				if(com2Rx_cnt == 0) {
					// this should be the stop bit
					// check that the stop bit is high and that the start bit was low
					// if both are correct add the byte to the queue
					if(P_COM2_RX_PORT && (com2Rx_byte & 1) == 0) {
						com2Rx_byte >>= 1;							// shift out the start bit (not needed now)
						com2Rx_buf[com2Rx_head] = com2Rx_byte;		// store the byte in the ring buffer
						com2Rx_head = (com2Rx_head + 1) % com2_buf_size;// advance the head of the queue
						if(SerialConsole == 2 && com2Rx_byte == BreakKey && !FileXfr) 
							MMAbort = true;							// check for CTRL-C and if so tell BASIC to stop running
						if(com2Rx_head == com2Rx_tail) 				// if the buffer has overflowed throw away the oldest char
							com2Rx_tail = (com2Rx_tail + 1) % com2_buf_size;
					}
				} else {
					// we are receiving the start bit or a data bit - regardless, shift it into our byte
					com2Rx_byte >>= 1;								// shift up the data 1 bit
					if(P_COM2_RX_PORT) com2Rx_byte |= 0b100000000;	// and insert our new bit
				}
			}
		}

		// this is the transmit character routine
		if(com2Tx_cnt == 0) {										// if we are not transmitting a character
			if(com2Tx_head != com2Tx_tail) {						// if there is something in the buffer
				com2Tx_byte = ((com2Tx_buf[com2Tx_tail] << 1) | 0b111000000000);		// get the char and build the bits to send
				com2Tx_tail = (com2Tx_tail + 1) % com2_buf_size;	// advance the tail of the queue
				com2Tx_cnt = com2Tx_start_cnt;						// and arm the transmission
			}
		} else {
			// we must be in the process of sending a character
			com2Tx_cnt--;
			if(com2Tx_cnt % com2_div == 0) {						// is this the right baud rate count?
				if(com2Tx_byte & 1)
					P_COM2_TX_SET_HI;								// output the bit hi - this is atomic and is interrupt proof
				else
					P_COM2_TX_SET_LO;
				com2Tx_byte >>= 1;									// and get the next bit ready
			}
		}
	}
#ifdef DUINOMITE
    ///////////////////////////////// this is COM3 ////////////////////////////////////
    if (com3) {
		// this is the receive character routine
        if (UARTReceivedDataIsAvailable(UART3A)) {
            com3Rx_buf[com3Rx_head] = (char)UARTGetDataByte(UART3A);                      // store the byte in the ring buffer
            if(SerialConsole == 3 && com3Rx_buf[com3Rx_head] == BreakKey && !FileXfr)
                MMAbort = true;                                      // check for CTRL-C and if so tell BASIC to stop running
            com3Rx_head = (com3Rx_head + 1) % com3_buf_size;         // advance the head of the queue
            if(com3Rx_head == com3Rx_tail)                           // if the buffer has overflowed throw away the oldest char
                com3Rx_tail = (com3Rx_tail + 1) % com3_buf_size;
        }
		// this is the transmit character routine
        if(com3Tx_head != com3Tx_tail) {
            if(UARTTransmitterIsReady(UART3A)) {
                UARTSendDataByte(UART3A,com3Tx_buf[com3Tx_tail]);
                com3Tx_tail = (com3Tx_tail + 1) % com3_buf_size;     // advance the tail of the queue
            }
        }
    }
    ///////////////////////////////// this is COM4 ////////////////////////////////////
    if (com4) {
		// this is the receive character routine
        if (UARTReceivedDataIsAvailable(UART3B)) {
            com4Rx_buf[com4Rx_head] = (char)UARTGetDataByte(UART3B);                      // store the byte in the ring buffer
            if(SerialConsole == 4 && com4Rx_buf[com4Rx_head] == BreakKey && !FileXfr)
                MMAbort = true;                                     // check for CTRL-C and if so tell BASIC to stop running
            com4Rx_head = (com4Rx_head + 1) % com4_buf_size;        // advance the head of the queue
            if(com4Rx_head == com4Rx_tail)                          // if the buffer has overflowed throw away the oldest char
                com4Rx_tail = (com4Rx_tail + 1) % com4_buf_size;
        }
		// this is the transmit character routine
        if(com4Tx_head != com4Tx_tail) {
            if(UARTTransmitterIsReady(UART3B)) {
                UARTSendDataByte(UART3B,com4Tx_buf[com4Tx_tail]);
                com4Tx_tail = (com4Tx_tail + 1) % com4_buf_size;    // advance the tail of the queue
            }
        }
    }
#endif

    // Clear the interrupt flag
    mT5ClearIntFlag();
}
#endif
