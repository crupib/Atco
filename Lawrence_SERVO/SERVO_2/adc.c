//---------------------------------------------------------------------
//	File:		adc.c
//
//	Written By:	Lawrence Glaister VE7IT
//
// Purpose: This set of routines is used to implement
//          analog inputs
//          
//---------------------------------------------------------------------
//
// Revision History
//
// Sept 12 2009 --    first version Lawrence Glaister
// 
//---------------------------------------------------------------------- 
#include "servo-dual.h"

#define  SAMP_BUFF_SIZE	 		8		// Size of the input buffer per analog input
#define  NUM_CHS2SCAN			4		// Number of channels enabled for channel scan

int  ain0buff[SAMP_BUFF_SIZE];	// these could be averaged as needed
int  ain1buff[SAMP_BUFF_SIZE];
int  ain2buff[SAMP_BUFF_SIZE];
int  ain3buff[SAMP_BUFF_SIZE];
int  scan_ctr=0;
int  samp_ctr=0;

/*=============================================================================
ADC INITIALIZATION FOR CHANNEL SCAN
=============================================================================*/
void setup_adc(void)
{
//	AD1CON1bits.FORM   = 1;		// Data Output Format: signed integer
	AD1CON1bits.FORM   = 0;		// Data Output Format: unsigned integer output
	AD1CON1bits.SSRC   = 2;		// Sample Clock Source: GP Timer starts conversion
	AD1CON1bits.ASAM   = 1;		// ADC Sample Control: Sampling begins immediately after conversion
	AD1CON1bits.AD12B  = 0;		// 10-bit ADC operation

	AD1CON2bits.CSCNA = 1;		// Scan Input Selections for CH0+ during Sample A bit
	AD1CON2bits.CHPS  = 0;		// Converts CH0

	AD1CON3bits.ADRC = 0;		// ADC Clock is derived from Systems Clock
	AD1CON3bits.ADCS = 63;		// ADC Conversion Clock Tad=Tcy*(ADCS+1)= (1/40M)*64 = 1.6us (625Khz)
								// ADC Conversion Time for 10-bit Tc=12*Tab = 19.2us

	AD1CON2bits.SMPI    = (NUM_CHS2SCAN-1);	// 4 ADC Channel is scanned

    // Configure scan input channels
    AD1CSSL = 0;
	AD1CSSLbits.CSS0 = 1;  	// Scan ch 0
	AD1CSSLbits.CSS1 = 1;  	// Scan ch 1
	AD1CSSLbits.CSS2 = 1;  	// Scan ch 2
	AD1CSSLbits.CSS3 = 1;  	// Scan ch 3

    /* set port configuration here */
    AD1PCFGLbits.PCFG0 = 0;         // ensure AN0 is analog
	AD1PCFGLbits.PCFG1 = 0;         // ensure AN1 is analog
    AD1PCFGLbits.PCFG2 = 0;         // ensure AN2 is analog
    AD1PCFGLbits.PCFG3 = 0;         // ensure AN3 is analog
	// set as input pins
	_TRISA0 = 1;
	_TRISA1 = 1;
	_TRISB0 = 1;
	_TRISB1 = 1;

    IFS0bits.AD1IF = 0;			// Clear the A/D interrupt flag bit
    IEC0bits.AD1IE = 1;			// Enable A/D interrupt 
    AD1CON1bits.ADON = 1;		// Turn on the A/D converter	
}

/*=============================================================================  
Timer 3 is setup to time-out every 125 microseconds (8Khz Rate). As a result, the module 
will stop sampling and trigger a conversion on every Timer3 time-out, i.e., Ts=125us. 
=============================================================================*/
void setup_tmr3() 
{
        TMR3 = 0x0000;
        PR3 = 4999;
        IFS0bits.T3IF = 0;
        IEC0bits.T3IE = 0;
        T3CONbits.TON = 1;        //Start Timer 3
}

/*=============================================================================  
ADC INTERRUPT SERVICE ROUTINE
=============================================================================*/

void __attribute__((interrupt, no_auto_psv)) _ADC1Interrupt(void)
{
	switch (scan_ctr)
	{
		case 0:	
			ain0buff[samp_ctr] = ADC1BUF0; 
			break;

		case 1:
			ain1buff[samp_ctr] = ADC1BUF0; 
			break;

		case 2:
			ain2buff[samp_ctr] = ADC1BUF0; 
			break;
	
		case 3:
			ain3buff[samp_ctr] = ADC1BUF0; 
			break;
			
		default:
			scan_ctr = 0;
			break;			
	}

	scan_ctr++;
	if(scan_ctr == NUM_CHS2SCAN)	
	{
		scan_ctr = 0;
		samp_ctr++;
	}

	if(samp_ctr == SAMP_BUFF_SIZE)
		samp_ctr=0;

    IFS0bits.AD1IF = 0;		// Clear the ADC1 Interrupt Flag
}








