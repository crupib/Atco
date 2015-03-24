//---------------------------------------------------------------------
//	File:		timer1.c
//
//	Written By:	Lawrence Glaister VE7IT
//
// Purpose: This set of routines is used to implement
//          a 1ms interval timer
//          
//---------------------------------------------------------------------
//
// Revision History
//
// Sept 12 2009 --    first version for dspic33
// 
//---------------------------------------------------------------------- 


#include "servo-dual.h"
volatile unsigned timer1;		// general purpose software delay timer

/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _T1Interrupt (void)

  PreCondition:    

  Input:           None.

  Output:          None.

  Side Effects:    None.

  Overview:        This is a basic 1000 us ISR used for software delays
					and scheduling.
********************************************************************/

void __attribute__((interrupt, no_auto_psv)) _T1Interrupt (void)
{
    IFS0bits.T1IF = 0;

	if ( timer1 > 0 )
		--timer1;
    return;
}

/*********************************************************************
  Function:        void setup_TMR1(void)

  PreCondition:    None.

  Input:           None.

  Output:          None.

  Side Effects:    None.

  Overview:        Setup a basic 1ms timer delays using 16bit timer1
                   
  Note:            None.
********************************************************************/

void setup_TMR1(void)
{
	T1CONbits.TON = 0;		// stop timer
	T1CONbits.TCS = 0;		// use internal instruction clk
	T1CONbits.TGATE = 0;	// disable gated timer mode
//	T1CONbits.TCKPS = 0b10;	// use divide by 64 prescaler
	T1CONbits.TCKPS = 0b00;	// use divide by 1 prescaler
    TMR1 = 0;				// clear timer reg
//    PR1 = FCY/64/1000;    // 1 ms = Fcy/64/1000 = 615
	PR1 = FCY/1/1000;       // 1 ms = Fcy/1/1000 = 39374.5
	IPC0bits.T1IP = 0x01;	// set intr priority
	IFS0bits.T1IF = 0;		// clr any pending intr flag
	IEC0bits.T1IE = 1;		// enable timer 1 intr
    T1CONbits.TON = 1;      // start timer 1
    return;
}
