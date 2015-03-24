//---------------------------------------------------------------------
//	File:		traps.c
//
//	Written By:	Lawrence Glaister VE7IT
//
// Purpose: This set of routines is used to implement
//          traps that should never happen. If they do, servo
//			should fault to prevent damage.
//          
//---------------------------------------------------------------------
//
// Revision History
//
// Sept 12 2009 --    first version for dspic33
// 
//---------------------------------------------------------------------- 
#include "servo-dual.h"
/*
Primary Exception Vector handlers:
These routines are used if INTCON2bits.ALTIVT = 0.
All trap service routines in this file simply ensure that device
continuously executes code within the trap service routine. Users
may modify the basic framework provided here to suit to the needs
of their application.
*/
void __attribute__((interrupt, no_auto_psv)) _OscillatorFail(void)
{
        INTCON1bits.OSCFAIL = 0;        //Clear the trap flag
		SERVO_FAULT = 1;
        while (1);
}

void __attribute__((interrupt, no_auto_psv)) _AddressError(void)
{
//      errLoc=getErrLoc();
        INTCON1bits.ADDRERR = 0;        //Clear the trap flag
		SERVO_FAULT = 1;
        while (1);
}
void __attribute__((interrupt, no_auto_psv)) _StackError(void)
{

        INTCON1bits.STKERR = 0;         //Clear the trap flag
		SERVO_FAULT = 1;
        while (1);
}

void __attribute__((interrupt, no_auto_psv)) _MathError(void)
{
        INTCON1bits.MATHERR = 0;        //Clear the trap flag
		SERVO_FAULT = 1;
        while (1);
}

void __attribute__((interrupt, no_auto_psv)) _DMACError(void)
{
        INTCON1bits.DMACERR = 0;        //Clear the trap flag
		SERVO_FAULT = 1;
        while (1);
}





/*
Alternate Exception Vector handlers:
These routines are used if INTCON2bits.ALTIVT = 1.
All trap service routines in this file simply ensure that device
continuously executes code within the trap service routine. Users
may modify the basic framework provided here to suit to the needs
of their application.
*/

void __attribute__((interrupt, no_auto_psv)) _AltOscillatorFail(void)
{
        INTCON1bits.OSCFAIL = 0;
		SERVO_FAULT = 1;
        while (1);
}

void __attribute__((interrupt, no_auto_psv)) _AltAddressError(void)
{
        INTCON1bits.ADDRERR = 0;
		SERVO_FAULT = 1;
        while (1);
}

void __attribute__((interrupt, no_auto_psv)) _AltStackError(void)
{
        INTCON1bits.STKERR = 0;
		SERVO_FAULT = 1;
        while (1);
}

void __attribute__((interrupt, no_auto_psv)) _AltMathError(void)
{
        INTCON1bits.MATHERR = 0;
		SERVO_FAULT = 1;
        while (1);
}

void __attribute__((interrupt, no_auto_psv)) _AltDMACError(void)
{
        INTCON1bits.DMACERR = 0;        //Clear the trap flag
		SERVO_FAULT = 1;
        while (1);
}

