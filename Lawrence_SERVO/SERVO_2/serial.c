//---------------------------------------------------------------------
//	File:		serial.c
//
//	Written By:	Lawrence Glaister VE7IT
//
// Purpose: This set of routines is used to implement
//          serial I/O
//          
//---------------------------------------------------------------------
//
// Revision History
//
// Sept 12 2009 --    first version for dspic33
// 
//---------------------------------------------------------------------- 
#include <stdio.h>
#include <uart.h>
#include "servo-dual.h"

// Select the desired UART baud rate here
#define THE_BAUD_RATE 9600
//#define THE_BAUD_RATE 19200
//#define THE_BAUD_RATE 57600
//#define THE_BAUD_RATE 115200 

#if defined FCY
    #if defined THE_BAUD_RATE
     #define DSBRG   (FCY/(16*THE_BAUD_RATE))-1
    #else
      #error Cannot calculate DSBRG value. Please define THE_BAUD_RATE in serial.c file
    #endif
 #else
     #error Cannot calculate DSBRG value. Please define FCY in servo-dual.h file
 #endif

 #define BAUDRATE_ACTUAL   (FCY/(16*(DSBRG+1)))
 #define BAUD_ERROR        ((BAUDRATE_ACTUAL > THE_BAUD_RATE) ? BAUDRATE_ACTUAL - THE_BAUD_RATE : THE_BAUD_RATE - BAUDRATE_ACTUAL)
 #define BAUD_ERROR_PERCENT    (((BAUD_ERROR*100)+(THE_BAUD_RATE/2))/THE_BAUD_RATE)

 #if    (BAUD_ERROR_PERCENT > 2)
     #error The value loaded to the BRG register produces a baud rate error higher than 2%
 #endif
#define UART_PRIORITY  3       //This the UART RX interrupt priority assigned to receive



extern void lockIO();
extern void unlockIO();
extern volatile unsigned timer1;		// general purpose software delay timer

char rxbuff[30];			// global rx buffer for serial data
char *rxbuffptr;		// local input ptr for storing data
short int rxrdy;			// flag to indicate a line of data is available in buffer

/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _U1ErrInterrupt (void)

  Input:           None.

  Output:          None.

  Side Effects:    None.

  Overview:        Handles uart error intr

********************************************************************/
void __attribute__((__interrupt__,no_auto_psv)) _U1ErrInterrupt (void)
{
   IFS4bits.U1EIF = 0;		// clr int flag
}

/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _U1RXInterrupt (void)

  Input:           None.

  Output:          None.

  Side Effects:    None.

  Overview:        Handles uart rx intr

********************************************************************/
void __attribute__((__interrupt__,no_auto_psv)) _U1RXInterrupt (void)
{
	char ch;

    IFS0bits.U1RXIF = 0;

	while (U1STAbits.URXDA)
	{
		ch = U1RXREG & 0xFF;
		// save the character if there is room in the input buffer
		if ( ch == 0x0a )
			continue;			// strip LF

		if ( ch == 0x0d )
		{
			// end of input stream.. 
			// let user know if we have something to process
			rxrdy = 1;
			break;
		}

		// if we have room in the buffer, store the ch for later processing
		if (rxbuffptr < (&rxbuff[0] + sizeof(rxbuff) - 1 ))
		{
			// still working on filling buffer
			*rxbuffptr++ = ch;
			*rxbuffptr = 0;			// null terminate buffer
			putchar(ch);	
		}
		else
		{
			putchar('?');
		}
	}
}

//**************************************************************************
//* Configure the USART
// the default stdin,stdout are directed to serial port 1
//**************************************************************************
void setup_uart( void )
{
	// assign pins for serial I/O
	// setup I/O pins for proper directions
	_TRISB2 = 1;		//pin 6 (RP2) RB2 = input
	_TRISB3 = 0;		//pin 7 (RP3) RB3 = output

	// make sure we are not in analog mode for pins
	AD1PCFGLbits.PCFG4 = 1;		// pins set for non analog use
	AD1PCFGLbits.PCFG5 = 1;		// pins set for non analog use

	// assign uart 1 to proper pins
	unlockIO();
	RPINR18bits.U1RXR = 0x02; 	// rx pin on rp2 == rp pin #
	RPOR1bits.RP3R =  0x03;		// tx pin on rp3 == func# from table30-2
	lockIO();	

    U1BRG  = (((FCY/THE_BAUD_RATE) /16) - 1);     /* baud rate */

	// now setup all the config to uart
	// configure U1MODE
	//U1MODEbits.UARTEN = 0;	// Bit15 TX, RX DISABLED, ENABLE at end of func
	// U1MODEbits.notimplemented;	// Bit14
	//U1MODEbits.USIDL = 0;	// Bit13 Continue in Idle
	//U1MODEbits.IREN = 0;	// Bit12 No IR translation
	//U1MODEbits.RTSMD = 1;	// Bit11 Simplex Mode  ??? example conflicts with datasheet
	// U1MODEbits.notimplemented;	// Bit10
	//U1MODEbits.UEN = 0;		// Bits8,9 TX,RX enabled, CTS,RTS not
	//U1MODEbits.WAKE = 0;	// Bit7 No Wake up (since we don't sleep here)
	//U1MODEbits.LPBACK = 0;	// Bit6 No Loop Back
	//U1MODEbits.ABAUD = 0;	// Bit5 No Autobaud (would require sending '55')
	//U1MODEbits.URXINV = 0;	// Bit4 IdleState = 1  (for dsPIC)
	//U1MODEbits.BRGH = 0;	// Bit3 16 clocks per bit period
	//U1MODEbits.PDSEL = 0;	// Bits1,2 8bit, No Parity
	//U1MODEbits.STSEL = 0;	// Bit0 One Stop Bit
	U1MODE = 0;

	// Load all values in for U1STA SFR
	//U1STAbits.UTXISEL1 = 0;	//Bit15 Int when Char is transferred (1/2 config!)
	//U1STAbits.UTXINV = 0;	//Bit14 N/A, IRDA config
	//U1STAbits.UTXISEL0 = 0;	//Bit13 Other half of Bit15
	//U1STAbits.notimplemented = 0;	//Bit12
	//U1STAbits.UTXBRK = 0;	//Bit11 Disabled
	//U1STAbits.UTXEN = 0;	//Bit10 TX pins controlled by uart reset below
	//U1STAbits.UTXBF = 0;	//Bit9 *Read Only Bit*
	//U1STAbits.TRMT = 0;	//Bit8 *Read Only bit*
	//U1STAbits.URXISEL = 0;	//Bits6,7 Int. on character recieved
	//U1STAbits.ADDEN = 0;	//Bit5 Address Detect Disabled
	//U1STAbits.RIDLE = 0;	//Bit4 *Read Only Bit*
	//U1STAbits.PERR = 0;		//Bit3 *Read Only Bit*
	//U1STAbits.FERR = 0;		//Bit2 *Read Only Bit*
	//U1STAbits.OERR = 0;		//Bit1 *Read Only Bit*
	//U1STAbits.URXDA = 0;	//Bit0 *Read Only Bit*
	U1STA = 0;

	IPC2bits.U1RXIP = 4;	// rx, Mid Range Interrupt Priority level, no urgent reason
	IPC3bits.U1TXIP = 4;	// tx

	rxbuffptr = &rxbuff[0];
	rxbuff[0] = 0;
	rxrdy = 0;

	U1MODEbits.RTSMD = 0;	// Bit11 Simplex Mode  ??? example conflicts with datasheet
	U1MODEbits.UARTEN = 1;	// enable uart

	// seems this must be done after uart is enabled
	U1STAbits.UTXEN = 1;	// Bit10 TX pins controlled by uart

//	tx isr not used
//  IFS0bits.U1TXIF = 0;
//	IEC0bits.U1TXIE = 1;

	IFS0bits.U1RXIF = 0;
	IEC0bits.U1RXIE = 1;		// go live with serial rx intr
} 


