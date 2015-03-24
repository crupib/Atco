//---------------------------------------------------------------------
//---------------------------------------------------------------------
//  File:       main.c
//
//
// The following files should be included in the MPLAB project:
//
//      main.c   				-- Main source code file
//      p33FJ128MC202.h          -- Header file for dsPIC33F
//
//      p33FJ128MC202.gld        -- Linker script file
// Revision History
//
// Aug 17 2009 -- first version of dual servo config

//----------------------------------------------------------------------
#include "servo-dual.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/******************************************************************************/
/* Configuration bits                                                         */
/******************************************************************************/
_FOSCSEL(FNOSC_FRC);            // Start with FRC; will switch to Primary (XT, HS, EC) Oscillator with PLL
_FOSC(FCKSM_CSECMD & POSCMD_EC & OSCIOFNC_ON & IOL1WAY_OFF);    // Clock Switching Enabled and Fail Safe Clock Monitor is disable
                            // Primary Oscillator Mode: external clock, allow multiple i/o configs

_FBS(RBS_NO_RAM & BSS_NO_FLASH & BSS_NO_BOOT_CODE & BWRP_WRPROTECT_OFF);	/* no Boot sector stuff and write protection disabled */

_FWDT(FWDTEN_OFF);							/* Turn off Watchdog Timer */

_FGS(GSS_OFF & GCP_OFF & GWRP_OFF);		/* Set Code Protection Off for the General Segment */

/* PWM mode is Port registers
   PWM high & low active high
   FPOR power on reset 128ms
*/
_FPOR(PWMPIN_ON & HPOL_ON & LPOL_ON & FPWRT_PWR128);

_FICD(ICS_PGD2 & JTAGEN_OFF & COE_ON);		/* Use PGC2/PGD2 for programming and debugging */

_FSS(RSS_NO_RAM & SSS_NO_FLASH & SWRP_WRPROTECT_OFF)	//No Secure Ram, No Secure Segment, wrt prot off

//----------------------------------------------------------------------

extern void setup_TMR1(void);
extern void setup_encoder(void);
extern void setup_uart(void);
extern void setup_adc( void );
extern void setup_tmr3() ;
extern void setup_pwm1(void);
extern void setup_pwm2(void);
extern void set_pwm0(float percent);
extern void set_pwm1(float percent);
extern void init_pid(void);
extern void	process_serial_buffer();
extern void setup_move(int axis, long int dist, float maxv, float acc);

//extern void setup_adc10(void);
extern void setup_capture(void);
extern int calc_cksum(int sizew, int *adr);
extern void print_tuning( int axis );
extern void ReadNV(void);

extern volatile unsigned timer1;		// general purpose software delay timer

extern char rxbuff[];			// global rx buffer for serial data
extern char *rxbuffptr;		// local input ptr for storing data
extern volatile short int rxrdy;

extern volatile long int jerk;					// global used for loop tuning
extern int axis;		// user sets to 0 or 1 for tuning or commands					

//extern struct PID _EEDATA(32) pidEE;
extern struct PID pid[];
extern volatile struct MOVE move[];

/***********************************************************************************
 * Function: lockIO
 *
 * Preconditions: None.
 *
 * Overview: This executes the necessary process to set the IOLOCK bit to lock
 * I/O mapping from being modified.
 *
 * Input: None.
 *
 * Output: None.
 *
 *****************************************************************************/
void lockIO(){

asm volatile ("mov #OSCCON,w1 \n"
                "mov #0x46, w2 \n"
                "mov #0x57, w3 \n"
                "mov.b w2,[w1] \n"
                "mov.b w3,[w1] \n"
                "bset OSCCON, #6");
}

/*****************************************************************************
 * Function: unlockIO
 *
 * Preconditions: None.
 *
 * Overview: This executes the necessary process to clear the IOLOCK bit to
 * allow I/O mapping to be modified.
 *
 * Input: None.
 *
 * Output: None.
 *
 *****************************************************************************/
void unlockIO(){

asm volatile ("mov #OSCCON,w1 \n"
                "mov #0x46, w2 \n"
                "mov #0x57, w3 \n"
                "mov.b w2,[w1] \n"
                "mov.b w3,[w1] \n"
                "bclr OSCCON, #6");
}
/*********************************************************************
  Function:        void set-io(void)

  PreCondition:    None.
 
  Input:           None.

  Output:          None.

  Side Effects:    None.

  Overview:        Sets up io ports for in and out

  Note:            Some periperal configs may change them again
********************************************************************/
void setup_io( void )
{
	// special functions setup their own I/O bits... rest is done here
	_TRISA3 = 1;		// pin 10 servo enable input
	_TRISB7  = 0;		// pin 16 fault led	
	_TRISB15 = 0;		// pin 26 ch 0 dir bit is output
	_TRISB9 = 0;		// pin 18 ch 1 dir bit is output

	
}

/*********************************************************************
  Function:        int main(void)

  PreCondition:    None.

  Input:           None.

  Output:          None.

  Side Effects:    None.

  Overview:        main function of the application.

  Note:            None.
********************************************************************/

int main(void)
{
	int cs;
	// vars used for detection of incremental motion

	jerk = 0.0;

    //The settings below set up the oscillator and PLL for 39.3745 MIPS as
    //follows:
    //                Crystal Frequency  * M          14318000 * 22
    // Fcy =   0.5 *  ----------------------  = 0.5 * --------------
    //                        N1 *  N2                    2 * 2   
    // Crystal  = 14.318 MHz
	// Fvco     = 157.498 MHz
    // Fosc     = 78.749 Mhz
    // Fcy      = 39.3745 MIPs

	// it seems the dspic33 series works best by starting
	// up on the internal rc oscillator and then changing
	// to a faster mode using the following code.
	// I could not get it to function at all using the external
	// osc from a cold start(seems the PLL needs setting up).
	// switch from startup rc osc to EC+PLL mode
	// setup pll dividers
	_TRISA2 = 1;				// clk pin used as input
    PLLFBD =  (22-2);           // M=22
    CLKDIVbits.PLLPOST = 0;     // N1=2
    CLKDIVbits.PLLPRE = 0;      // N2=2
	OSCTUN = 0;					// zero out rc osc tweaks
	// disable watchdog timer
	RCONbits.SWDTEN = 0;


	// the following builtin functions are used as a special unlock sequence
	// is needed to write to the osccon register
    __builtin_write_OSCCONH(0x03);		// new osc mode of EC+PLL
    __builtin_write_OSCCONL(0x01);		// request switch to new mode
   	while(OSCCONbits.COSC != 0b011);	// wait for mode switch to take effect
    while(OSCCONbits.LOCK != 1);		// Wait for PLL to lock


    setup_TMR1();     	// Initialize TMR1 for 1 ms periodic ISR
	setup_io();			// assign all pins as ins/out/analog/digital/assign programmable peripheral pins
	setup_uart();

	// we fault here so that if any servo resets during operation,
	// a fault will occur during the restart procedure
	SERVO_FAULT = 1;
	// 1/2 seconds startup delay 
	timer1 = 500; while ( timer1 );
	SERVO_FAULT = 0;

	printf("\r\nPowerup..I/O..timer1..uart1..");	
	init_pid();
	pid[0].enable = pid[1].enable = 0;		// turn servo loop off for a while
	printf("pid..");

	setup_pwm1();		// start analog output
	set_pwm0(0.0); 
	setup_pwm2();
	set_pwm1(0.0);
	printf("pwm..");

    setup_encoder();    // 16 bit quadrature encoder module setup
	printf("encoder..");

    setup_capture();    // 2 pins with quadrature cmd from PC
	printf("\r\ncapture..");

	setup_adc();			// 4 ch of adc inputs 0-3.3v
	setup_tmr3();			// polled at timer3 rate
	printf("adc..tmr3..");

	ReadNV();
	printf("restore settings..");

	printf("done\r\n");
	printf("%s%s\r\n",CPWRT,VERSION);

	cs = -calc_cksum(((long int)&pid[0].cksum - (long int)&pid[0])/sizeof(int),(int*)&pid[0]);
	if (( cs != pid[0].cksum ) || ((pid[0].cksum == 0) && (pid[0].pgain == 0.0)))
	{
		// opps, no valid setup detected
		// assume we are starting from a new box
		printf("No valid setup found in EEPROM 0x%04X\r\n",pid[0].cksum);
		init_pid();
		while (1 )
		{
			// a very fast flash to indicate no config... serial activity
			// (hopefully the user setting params gets us out of the loop)
		    SERVO_FAULT = 1;	timer1 = 100; while ( timer1 );
			SERVO_FAULT = 0;	timer1 = 100; while ( timer1 );
			if ( rxrdy ) break;
		}
	}
	else
	{
		printf("Using saved setup.. ? for help\r\n");
		print_tuning(axis);
	}

	while (1)
	{
		// check for serial cmds
		if ( rxrdy )
			process_serial_buffer();

		if ( jerk )
		{
			while ( 1 )
			{
				printf("jerk of %ld counts... press enter or disable servo to halt\r\n",jerk);
				// loop forever until serial active or servo gets disabled
				if ( rxrdy || (SVO_ENABLE==0) )
				{
					jerk = 0L;
					break;
				}
				setup_move(axis,jerk,pid[axis].velocity,pid[axis].accel);
				while (move[axis].enable)
				{
					if (SVO_ENABLE==0 || rxrdy)		// allow mid move aborts
					{
						jerk = 0L;
						move[axis].enable = 0;
						printf("jerk testing aborted\r\n");
					}
				};	// wait for move to complete
				jerk = -jerk;
				printf("max error: %f\r\n",(double)pid[axis].maxposerror);
				pid[axis].maxposerror = 0.0;
			}
		}


		// check to see if external forces are causing use to change servo status
		// in this implementation, there is only 1 external enable for both servos
		if (SVO_ENABLE == 1)
		{
			if ( pid[0].enable == 0 )	// last loop, servo was off
			{
				pid[0].enable = pid[1].enable = 1;
				printf("servo-enabled\r\n>");
				// give the servo loop some time to get established
				timer1 = 250; while ( timer1 );
			}
		}
		else	// servo operation is disabled by external controller
		{
			pid[0].command = pid[0].feedback;		// make positions match
			pid[1].command = pid[1].feedback;		// make positions match
			if ( pid[0].enable == 1 )	// last loop servo was active
			{
				pid[0].enable = pid[1].enable = 0;
				move[0].enable = move[1].enable = 0;	// shut down in progress g cmds
				printf("servo-disabled\r\n>");
			}
		}

	    // check for a drive fault ( posn error > allowed )
		SERVO_FAULT = 0;	//set servo fault output low (inactive)
		int posn_fault = 0;
		// if we have enabled position error faults, then check for them
	    if (( pid[0].maxerror > 0.0 ) && ( fabs(pid[0].error) > pid[0].maxerror )) 
			posn_fault = 1;
	    if (( pid[1].maxerror > 0.0 ) && ( fabs(pid[1].error) > pid[1].maxerror )) 
			posn_fault = 1;
		if (SVO_ENABLE == 0)		// can only fault if servo is enabled
			posn_fault = 0;
		if (pid[0].raw_pwm != 0.0 || pid[1].raw_pwm != 0.0)	// dont fault if raw pwm is in progress
			posn_fault = 0;

	    if (posn_fault)
	    {
			pid[0].enable = pid[1].enable = 0;		// shut down servo updates
			pid[0].raw_vel = pid[1].raw_vel = 0.0;	// shut down raw velocity mode moves
			move[0].enable = move[1].enable = 0;	// shut down in progress g commands
			
			SERVO_FAULT = 1;	// set servo fault output high (active)
		    while (1)	        // trap here until svo disabled or pwr cycle
		    {
			    set_pwm0( 0.0 );
				set_pwm1( 0.0 );
			    printf("drive fault... maxerror(s) exceeded %f %f\r\n",(double)pid[0].error,(double)pid[1].error);
				timer1 = 1000; while ( timer1 );
				if (SVO_ENABLE == 0) 
					break;
			}
			SERVO_FAULT = 0;	// set servo fault output low
         	while ( SVO_ENABLE == 0 );	// wait for us to be enabled
		}
	}
	// to keep compiler happy....
	return 0;
}


