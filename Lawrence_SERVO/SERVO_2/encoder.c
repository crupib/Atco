//---------------------------------------------------------------------
//	File:		encoder.c
//
//	Written By:	Lawrence Glaister VE7IT
//
// Purpose: routines to setup and use quadrature encoder
//      
// 
//---------------------------------------------------------------------
//
// Revision History
//
// Aug 19 2009 -- first version for dspic33
//---------------------------------------------------------------------- 
#include "servo-dual.h"
extern void lockIO();
extern void unlockIO();

/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _QEI1Interrupt(void)

  PreCondition:    None.
 
  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:        handles encoder interrupts 

  Note:            We can get intrs via index pulses, counting errors
********************************************************************/
void __attribute__((__interrupt__,no_auto_psv)) _QEI1Interrupt(void)
{
    if (QEI1CONbits.CNTERR)
    {
        QEI1CONbits.CNTERR = 0;      // reset count error flag
    }
    IFS3bits.QEI1IF = 0;         // reset the if flag
}
/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _QEI2Interrupt(void)

  PreCondition:    None.
 
  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:        handles encoder interrupts 

  Note:            We can get intrs via index pulses, counting errors
********************************************************************/
void __attribute__((__interrupt__,no_auto_psv)) _QEI2Interrupt(void)
{
    if (QEI2CONbits.CNTERR)
    {
        QEI2CONbits.CNTERR = 0;      // reset count error flag
    }
    IFS4bits.QEI2IF = 0;         // reset the if flag
}

/*********************************************************************
  Function:        void setupEncoder(void)

  PreCondition:    None.
 
  Input:           None

  Output:          None.

  Side Effects:    some analog I/O config bits are played with

  Overview:        handles encoder interrupts 

  Note:            We can get intrs via index pulses, counting errors
                   (counter rollovers). Setup is tricky.... we need
                    an intr on index pulse so that we can do commutation.
                    We also need an intr when the 16 bit internal 
                    counter rolls over so that we can keep track of multi
                    word position data. We setup counter for reset
                    on index, but dont enable the reset part (this still
                    generates an intr). By setting maxcnt = 0xffff, and
                    enabling intr on CNTERR, we also get an intr when the
                    counter rolls over (even though this is not really an
                    error).
********************************************************************/

void setup_encoder(void)
{
	// channel 1
	_TRISB12 = 1;			// used by quad encoder input ch A
	_TRISB13 = 1;			// used by quad encoder input ch B
	unlockIO();
	RPINR14bits.QEB1R = 12;	// rp12 = pin 23
	RPINR14bits.QEA1R = 13;	// rp13 = pin 24
	RPINR15bits.INDX1R = 31; 	// index not used
	lockIO();	

	// channel 2
	_TRISB5 = 1;			// used by quad encoder input ch A
	_TRISB6 = 1;			// used by quad encoder input ch B
	unlockIO();
	RPINR16bits.QEB2R = 6;	// rp6 = pin 15
	RPINR16bits.QEA2R = 5;	// rp5 = pin 14
	RPINR17bits.INDX2R = 31; 	// index not used
	lockIO();	

    MAX1CNT = MAX2CNT = 0xffff;  // counts/rev (used as preset when index pulse seen)
    POS1CNT = POS2CNT = 0x0000;

    QEI1CON = QEI2CON = 0;  // clr CNTERR bit (among others)
    QEI1CONbits.QEIM = QEI2CONbits.QEIM = 6;    // x4 reset by indx
    QEI1CONbits.POSRES = QEI2CONbits.POSRES = 0;    // index rest not used

    // digital filter requires the input to be valid for 3 (scaled) clk pulses
    DFLT1CON = DFLT2CON = 0;            // digital filter set off
    DFLT1CONbits.IMV = DFLT2CONbits.IMV = 3;    // in x4 mode, a and b and i have to be high for reset 
    DFLT1CONbits.QEOUT = DFLT2CONbits.QEOUT = 1;  // enable digital filter on phase a,b,i


    /* set up interrupts for encoder */
    IFS3bits.QEI1IF = 0;         // clear Interrupt flag 
    IFS4bits.QEI2IF = 0;         // clear Interrupt flag 

    IPC14bits.QEI1IP = 4;        // bits <2:0> are the priority
    IPC18bits.QEI2IP = 4;        // bits <2:0> are the priority

    IEC3bits.QEI1IE = 1;         // go live
    IEC4bits.QEI2IE = 1;         // go live

}
