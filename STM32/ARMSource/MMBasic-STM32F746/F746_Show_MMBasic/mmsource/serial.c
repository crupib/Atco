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



#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

// variables for com1
int com1 = 0;														// true if COM1 is enabled

// variables for com2
int com2 = 0;														// true if COM2 is enabled
int com2_fc;														// true if COM2 is using flow control


int SerialConsole = 0;												// holds the serial port number if the console function is enabled

/***************************************************************************************************
Initialise the serial function
****************************************************************************************************/
void SerialOpen(char *spec, int as_console)
{
	int baud, i, oc, fc, de, s2, bufsize, ilevel;
	char *interrupt;
	int COM12_BAUD_RATE[6]={4800,9600,19200,38400,57600,115200};

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
		for(i=0;i<6;i++) { 									// make sure that the baud rate is ok
			if(baud==COM12_BAUD_RATE[i]) break;
		}
		if(i==6) error("Invalid baud rate");
	} else
		baud = COM_DEFAULT_BAUD_RATE;

	if(argc >= 5 && *argv[4]) {
		bufsize = getinteger(argv[4]);								// get the buffer size as a number
		if(bufsize <= COM_FLOWCTRL_MARGIN + 1) error("Invalid COM specification");
	} else
		bufsize = COM_DEFAULT_BUF_SIZE;

	if(argc >= 7) {
    	//InterruptUsed = true;
		//interrupt = GetIntAddress(argv[6]);							// get the interrupt location
		interrupt = NULL;
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

		if(fc) error("Flow control not available");
		if(de) error("DE is invalid");
		if(oc) error("OC is invalid");

		ExtCfg(P_COM1_RX_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use
		ExtCfg(P_COM1_TX_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use

		MM_Uart_Init(COM6, baud, fc, s2);

		if(as_console) SerialConsole = 1;
		com1 = true;
	}
	if(spec[3] == '2') {
	///////////////////////////////// this is COM2 ////////////////////////////////////
		if(com2) error("COM port is already open");

		if(de) error("DE is invalid");
		if(oc) error("OC is invalid");
		com2_fc = fc;

		if(fc) {
			ExtCfg(P_COM2_RTS_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use
			ExtCfg(P_COM2_CTS_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use
		}

		ExtCfg(P_COM2_RX_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use
		ExtCfg(P_COM2_TX_PIN_NBR, EXT_COM_RESERVED + as_console);	// reserve the pin for com use

		MM_Uart_Init(COM7, baud, fc, s2);

		if(as_console) SerialConsole = 2;
		com2 = true;
	}
}

/***************************************************************************************************
Close a serial port.
****************************************************************************************************/
void SerialClose(int comnbr)
{
	if(SerialConsole == comnbr) SerialConsole = 0;

	if(comnbr == 1 && com1) {
		com1 = false;
		ExtCfg(P_COM1_RX_PIN_NBR, EXT_NOT_CONFIG);
		ExtCfg(P_COM1_TX_PIN_NBR, EXT_NOT_CONFIG);
	}
	if(comnbr == 2 && com2) {
		com2 = false;
		if(com2_fc) {
			ExtCfg(P_COM2_CTS_PIN_NBR, EXT_NOT_CONFIG);
			ExtCfg(P_COM2_RTS_PIN_NBR, EXT_NOT_CONFIG);
		}
		ExtCfg(P_COM2_RX_PIN_NBR, EXT_NOT_CONFIG);
		ExtCfg(P_COM2_TX_PIN_NBR, EXT_NOT_CONFIG);
	}
}

/***************************************************************************************************
send a character to the serial output
****************************************************************************************************/
unsigned char SerialPutchar(int comnbr, unsigned char c)
{
	if(comnbr == 1) {
		UB_Uart_SendByte(COM6,c);
		return 0;
	}
	if(comnbr == 2) {
		UB_Uart_SendByte(COM7,c);
		return 0;
	}
	return 0;
}


/***************************************************************************************************
Get the status the serial receive buffer.
Returns the number of characters waiting in the buffer
****************************************************************************************************/
int SerialRxStatus(int comnbr)
{
	int i = 0;
	if(comnbr == 1) {
		i = MM_Uart_GetRxStatus(COM6);
		return i;
	}
	if(comnbr == 2) {
		i = MM_Uart_GetRxStatus(COM7);
		return i;
	}
	return 0;
}

/***************************************************************************************************
Get the status the serial transmit buffer.
Returns the number of characters free in the buffer
****************************************************************************************************/
int SerialTxStatus(int comnbr)
{	
	if(comnbr == 1) return RX_BUF_SIZE_COM6;
	if(comnbr == 2) return RX_BUF_SIZE_COM7;
	return 0;
}


/***************************************************************************************************
Get a character from the serial receive buffer.
Note that this is returned as an integer and -1 means that there are no characters available
****************************************************************************************************/
int SerialGetchar(int comnbr)
{
	int c=-1;

	if(comnbr == 1) {
		c=MM_Uart_ReveiveByte(COM6);
		return c;		
	}
	if(comnbr == 2) {
		c=MM_Uart_ReveiveByte(COM7);
		return c;		
	}
	return -1;
}

