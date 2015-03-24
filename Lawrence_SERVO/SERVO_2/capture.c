//---------------------------------------------------------------------
//  File:       capture.c
//
//  Written By: Lawrence Glaister VE7IT
//
// Purpose: This set of routines deals with using 2 pins
// connected to the PC as a quadrature signal for incrementing or
// decementing commanded position. The IC1 and IC2 pins are used
// and are setup to generate an interrupt on each edge change.
// The ISR's then looks at the state of IC1 and IC2 and uses
// a state machine to incr or decr the commanded position.
// The IC1 and IC2 pins are smidt trigger inputs.
// The CN inputs could also have been used to detect change of state on
// the 2 pc command pins as we dont use most of the input capture
// functionality.
//
//
//---------------------------------------------------------------------
//
// Revision History
//
// Aug 7 2006 --    first version Lawrence Glaister
// Aug 15 2006      added pc command pulse multiplier option
// Jun 29 2009      added code for step/dir command (conditional compile)
// Aug 20 2009		ported to dspic33 series, dual servo controller CN inputs used
//----------------------------------------------------------------------
#include "servo-dual.h"

extern struct PID pid[];
volatile unsigned short int cmd_posn0;   // current posn cmd from PC 1st channel
volatile unsigned short int cmd_posn1;   // current posn cmd from PC 2nd channel
volatile unsigned short int cmd_err;     // shared number of bogus encoder positions detected
volatile unsigned short int cmd_bits0;    // a 4 bit number with old and new port values
volatile unsigned short int cmd_bits1;    // a 4 bit number with old and new port values
// uncoment one of the options below...
//#define STEP_DIR 
#undef STEP_DIR

#ifdef  STEP_DIR   // step/dir pc control
error -- this code has not been ported to dual servo config
/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _IC1Interrupt(void)

  PreCondition:    None.

  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:        handles changes on IC1 pin

  Note:            None.
********************************************************************/
void __attribute__((__interrupt__,auto_psv)) _IC1Interrupt(void)
{
    // leading edge of step pin causes target position to move
    IFS0bits.IC1IF = 0;                     // Clear IF bit
    if (PORTDbits.RD0)  // Step pin high
    {
        if (PORTDbits.RD1)  // step up
            cmd_posn += pid.multiplier;
        else    // step down
            cmd_posn -= pid.multiplier;
    }
}

/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _IC2Interrupt(void)

  PreCondition:    None.

  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:        handles changes on IC2 pin

  Note:            None.
********************************************************************/
void __attribute__((__interrupt__,auto_psv)) _IC2Interrupt(void)
{
    // we ignore transitions based on direction pin
    IFS0bits.IC2IF = 0;                    /* Clear IF bit */
}


#else  // quadrature mode pc controll

// 4 functions that perform adjustments to the commanded position
void change_NO(void)
{
}
void change_UP0(void)
{
    cmd_posn0 += pid[0].multiplier;
}
void change_DN0(void)
{
    cmd_posn0 -= pid[0].multiplier;
}
void change_ER(void)
{
    cmd_err++;      // both bits changed.... overspeed???
}

void change_UP1(void)
{
    cmd_posn1 += pid[1].multiplier;
}
void change_DN1(void)
{
    cmd_posn1 -= pid[1].multiplier;
}

// define the array of functions needed to handle changes
               // Encoder lines
               // Before Now
// change_NO   // 0 0   0 0
// change_UP   // 0 0   0 1
// change_DN   // 0 0   1 0
// change_ER   // 0 0   1 1

// change_DN   // 0 1   0 0
// change_NO   // 0 1   0 1
// change_ER   // 0 1   1 0
// change_UP   // 0 1   1 1

// change_UP   // 1 0   0 0
// change_ER   // 1 0   0 1
// change_NO   // 1 0   1 0
// change_DN   // 1 0   1 1

// change_ER   // 1 1   0 0
// change_DN   // 1 1   0 1
// change_UP   // 1 1   1 0
// change_NO   // 1 1   1 1

void (*funcArr0[16])(void)={ change_NO,change_UP0,change_DN0,change_ER,
                            change_DN0,change_NO,change_ER,change_UP0,
                            change_UP0,change_ER,change_NO,change_DN0,
                            change_ER,change_DN0,change_UP0,change_NO};
void (*funcArr1[16])(void)={ change_NO,change_UP1,change_DN1,change_ER,
                            change_DN1,change_NO,change_ER,change_UP1,
                            change_UP1,change_ER,change_NO,change_DN1,
                            change_ER,change_DN1,change_UP1,change_NO};

/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _CNInterrupt(void)

  PreCondition:    None.

  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:        handles changes on IC1 pin

  Note:            None.
********************************************************************/
void __attribute__((__interrupt__,no_auto_psv)) _CNInterrupt(void)
{
	unsigned char new0, new1;
	// read state of both sets of inputs... any one could have changed
	new0 = new1 = 0;
	if (_RB11) new0 += 1;
	if (_RB10) new0 += 2;
	if (_RA4) new1 += 1;
	if (_RB4) new1 += 2;
    IFS1bits.CNIF = 0;                     // Clear IF bit

	// depending on state change, update internal position requests
    cmd_bits0 = ((cmd_bits0 << 2) & 0x000c) + new0;     // old bits move left
    (*funcArr0[cmd_bits0])();                 // process cmd from pc

    cmd_bits1 = ((cmd_bits1 << 2) & 0x000c) + new1;     // old bits move left
    (*funcArr1[cmd_bits1])();                 // process cmd from pc
}
#endif

/*********************************************************************
  Function:        void setup_capture(void)

  PreCondition:    None.

  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:			configures 4 input bits for use as pc or offset 
					commands (2 quad signals)

  Note:            None.
********************************************************************/
void setup_capture(void)
{
	CNEN1 = CNEN2 = 0;		// disable all change intr
	_TRISA4 = _TRISB4 = _TRISB10 = _TRISB11 = 1;	// set pins 11,12,21,22 as inputs

	// pullups may be useful depending on hardware design
	CNPU1 = CNPU2 = 0;	// clear all then set weak pullups on pins
//	CNPU1bits.CN15PUE = CNPU1bits.CN1PUE = CNPU1bits.CN0PUE = CNPU2bits.CN16PUE = 1;
	
    IFS1bits.CNIF = 0;  // Clean up any pending IF 
    IPC4bits.CNIP = 0x0004;   // assign Interrupt Priority to IPC Register  (4 is default)

    cmd_posn0 = cmd_posn1 = 0;

#ifndef STEP_DIR
    cmd_err = 0;
  	// current port state
	cmd_bits0 = cmd_bits1 = 0;
	if (_RB11) cmd_bits0 += 1;
	if (_RB10) cmd_bits0 += 2;
	if (_RA4) cmd_bits1 += 1;
	if (_RB4) cmd_bits1 += 2;
#endif
	// go live with the bits we want to monitor
	CNEN1bits.CN15IE = CNEN1bits.CN1IE = CNEN1bits.CN0IE = CNEN2bits.CN16IE = 1; // enable some change intr
	IEC1bits.CNIE = 1;		// enable cn interrupts as a logic block
}
