//---------------------------------------------------------------------
// File:		pwm.c
//
// Written By:	Lawrence Glaister
//
// Purpose: This set of routines to run pwn output
//      
// 
//---------------------------------------------------------------------
//
// Revision History
//
// 19Aug2009 - ported from dspic30f to 33f code
//---------------------------------------------------------------------- 
#include "servo-dual.h"
#include <pwm.h>
#include <stdio.h>
#include <math.h>

extern struct PID pid[];
extern void calc_pid( int servo );
extern volatile struct MOVE move[];
extern int calc_velocity( int servo );

extern volatile unsigned short int cmd_posn0;			// current posn cmd from PC
extern volatile unsigned short int cmd_posn1;			// current posn cmd from PC

void set_pwm0(float percent);
void set_pwm1(float percent);

/*********************************************************************
  Function:        void __attribute__((__interrupt__)) _PWMInterrupt(void)

  PreCondition:    None.
 
  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:        handles pwm interrupts 
				   we get a pwm intr every 4 pwm cycles (250us)
                   - setup by PTCON
                   - try and keep code < 250us or we need to deal with reentrancy

  Note:            None.
********************************************************************/
void __attribute__((__interrupt__,no_auto_psv)) _MPWM1Interrupt(void)
{
	static short gear = 0;
	static unsigned short new_cmd0,last_cmd0, new_fb0,last_fb0 = 0;
	static short last_state0 = 0;	// last servo cycle enable/disable state

	static unsigned short new_cmd1,last_cmd1, new_fb1,last_fb1 = 0;
	static short last_state1 = 0;	// last servo cycle enable/disable state

    IFS3bits.PWM1IF =0;	// clr the interrrupt

	gear++;
	if ( gear >= 4 ) gear = 0;
	// 4 sets of cals done... moves servo 0, pid servo 0, moves servo 1, pid servo 1

	switch (gear)
	{
	case 0:
		// if in a motion profile, compute next position required
		// and update cmd_posn. cmd_posn is updated by this
		// bit of code or by changes coming in from the PC cmd lines
		// it is assumed that only one method of motion is in use
		// at a time, but both are possible.
		if ( move[0].enable )
			cmd_posn0 += calc_velocity(0);
		break;

	case 1:
		// time to do servo calcs for servo 0
		if ( pid[0].enable && (last_state0 == 0) )
		{
			// we just got enabled.. try to prevent jumps
			// setup servo loop internals so our current posn is the target posn
			new_cmd0 = last_cmd0 = new_fb0 = last_fb0 = 0;
			cmd_posn0 = POS1CNT;		// make 16bit incr registers match
			pid[0].command = 0L;		// make 32 bit counter match
			pid[0].feedback = 0L;
			pid[0].error_i = 0.0;		// reset internal error accumulators
			pid[0].error_d = 0.0;
			pid[0].error = 0.0;
			pid[0].cmd_d = 0.0;
			pid[0].prev_cmd = 0L;
        }
		// the servo calcs are run even if we are not enabled
		// this helps debugging because the s serial command can be used
		// to look at servo calc results without the motor going bezerk	
		if ( pid[0].raw_vel != 0.0 )
		{
			cmd_posn0 += (short)pid[0].raw_vel;
		}
		new_cmd0 = cmd_posn0;		// grab current cmd from pc
		new_fb0 = POS1CNT;		// grab current posn from encoder
		pid[0].command  += (long int)((short)(new_cmd0 - last_cmd0));
		pid[0].feedback += (long int)((short)(new_fb0  - last_fb0 ));
	    last_cmd0 = new_cmd0;
		last_fb0 = new_fb0;
		calc_pid(0);

		if ( pid[0].enable )
		{		
			if ( pid[0].raw_pwm != 0.0 )
			{
				// update motor drive for raw pwm mode
				set_pwm0( pid[0].raw_pwm );	
			}
			else
			{
				// update motor drive for posn (and vel) mode
				set_pwm0(pid[0].output);	
			}
		}
		else
		{
		    set_pwm0(0.0);
			pid[0].raw_pwm = 0.0;
			pid[0].raw_vel = 0.0;
		}

		last_state0 = pid[0].enable;

		break;

	case 2:
		// if in a motion profile, compute next position required
		// and update cmd_posn. cmd_posn is updated by this
		// bit of code or by changes coming in from the PC cmd lines
		// it is assumed that only one method of motion is in use
		// at a time, but both are possible.
		if ( move[1].enable )
			cmd_posn1 += calc_velocity(1);
		break;
	case 3:
		// time to do servo calcs for servo 1
		if ( pid[1].enable && (last_state1 == 0) )
		{
			// we just got enabled.. try to prevent jumps
			// setup servo loop internals so our current posn is the target posn
			new_cmd1 = last_cmd1 = new_fb1 = last_fb1 = 0;
			cmd_posn1 = POS2CNT;		// make 16bit incr registers match
			pid[1].command = 0L;		// make 32 bit counter match
			pid[1].feedback = 0L;
			pid[1].error_i = 0.0;		// reset internal error accumulators
			pid[1].error_d = 0.0;
			pid[1].error = 0.0;
			pid[1].cmd_d = 0.0;
			pid[1].prev_cmd = 0L;
        }
		// the servo calcs are run even if we are not enabled
		// this helps debugging because the s serial command can be used
		// to look at servo calc results without the motor going bezerk	
		if ( pid[1].raw_vel != 0.0 )
		{
			cmd_posn1 += (short)pid[1].raw_vel;
		}
		new_cmd1 = cmd_posn1;		// grab current cmd from pc
		new_fb1 = POS2CNT;		// grab current posn from encoder
		pid[1].command  += (long int)((short)(new_cmd1 - last_cmd1));
		pid[1].feedback += (long int)((short)(new_fb1  - last_fb1 ));
	    last_cmd1 = new_cmd1;
		last_fb1 = new_fb1;
		calc_pid(1);

		if ( pid[1].enable )
		{		
			if ( pid[1].raw_pwm != 0.0 )
			{
				// update motor drive for raw pwm mode
				set_pwm1( pid[1].raw_pwm );	
			}
			else
			{
				// update motor drive for posn (and vel) mode
				set_pwm1(pid[1].output);	
			}
		}
		else
		{
		    set_pwm1(0.0);
			pid[1].raw_pwm = 0.0;
			pid[1].raw_vel = 0.0;
		}

		last_state1 = pid[1].enable;

		break;
	}
}


/*********************************************************************
  Function:        void setupPWM1(void)

  PreCondition:    None.
 
  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:        port setup for the 3 phase pwm module


  Note:            None.
********************************************************************/
void setup_pwm1(void)
{
    /* Configure pwm interrupt enable/disable and set interrupt priorties */
    IFS3bits.PWM1IF  = 0;	// clear the Interrupt flag 
    IPC14bits.PWM1IP = 4;   // Set priority for the period match
    IEC3bits.PWM1IE  = 1;	// enable /disable of interrupt Period match
    IEC3bits.FLTA1IE = 0;  	// enable /disable of interrupt Fault A.

    /* Configure PWM to generate 0 current*/
    PWM1CON2bits.UDIS = 0;
    P1DC1 = (FCY/FPWM - 1);

    P1TPERbits.PTPER = (FCY/FPWM/2 - 1);      // set the pwm period register(/2 for cnt up/dwn)
    P1SECMPbits.SEVTCMP = 0x00;

	PWM1CON1bits.PMOD1 = 1;		// pwmxh and pwmxl pins are independant
	PWM1CON1bits.PMOD2 = 1;
	PWM1CON1bits.PMOD3 = 1;

	PWM1CON1bits.PEN1H = 1;		// enable pwm for servo 1
	PWM1CON1bits.PEN2H = 0;		// disable
	PWM1CON1bits.PEN3H = 0;		// disable

	PWM1CON1bits.PEN1L = 0;		// disable
	PWM1CON1bits.PEN2L = 0;		// disable
	PWM1CON1bits.PEN3L = 0;		// disable

    /* set dead time options (not used), scale = 1, 10*FCY (about 250ns) */
    P1DTCON1bits.DTBPS = 0;		//pwmb unit prescale of 1 tcy
    P1DTCON1bits.DTAPS = 0;		//pwma unit prescale of 1 tcy
	P1DTCON1bits.DTA = 10;		// dead time 
	P1DTCON1bits.DTB = 10;		//
  
    /* set up the fault mode override bits and mode */
	/* no fault pin used in this application */
    P1FLTACONbits.FAEN1 = 0;
    P1FLTACONbits.FAEN2 = 0;
    P1FLTACONbits.FAEN3 = 0;

    /* set special event post scaler, output override sync select and pwm update enable */
    PWM1CON2bits.SEVOPS = 0;	// prescale of 1
    PWM1CON2bits.OSYNC = 1;		// output overides are symced to pwm
	PWM1CON2bits.UDIS = 0;		// allow updates to duty cycle and period registers
	PWM1CON2bits.IUE = 0;		// updates to pdc regs is symced to pwm cycle

     // we get a pwm intr every 4 pwm cycles (250us)
    P1TCONbits.PTSIDL = 0;	// pwm runs in idle mode
    P1TCONbits.PTOPS = 3;	// post scale of 4
    P1TCONbits.PTCKPS = 0;	// pwm time base prescale of 1 TCY
    P1TCONbits.PTMOD = 2;	// mode is continuous up/dwm
    P1TCONbits.PTEN = 1;	// enable pwm timer 
}

/*********************************************************************
  Function:        void setupPWM2(void)

  PreCondition:    None.
 
  Input:           None

  Output:          None.

  Side Effects:    None.

  Overview:        port setup for the 1 phase pwm module
				   in the dspic33. No intr used... pwm1 module
				   times updates and does calcs in its intr.


  Note:            None.
********************************************************************/
void setup_pwm2(void)
{
    /* Configure pwm interrupt enable/disable and set interrupt priorties */
    IFS4bits.PWM2IF  = 0;	// clear the Interrupt flag 
    IPC18bits.PWM2IP = 4;   // Set priority for the period match
    IEC4bits.PWM2IE  = 0;	// enable /disable of interrupt Period match
    IEC4bits.FLTA2IE = 0;  	// enable /disable of interrupt Fault A.

    /* Configure PWM to generate 0 current*/
    PWM2CON2bits.UDIS = 0;
    P2DC1 = (FCY/FPWM - 1);

    P2TPERbits.PTPER = (FCY/FPWM/2 - 1);      // set the pwm period register(/2 for cnt up/dwn)
    P2SECMPbits.SEVTCMP = 0x00;

	PWM2CON1bits.PMOD1 = 1;		// pwmxh and pwmxl pins are independant
	PWM2CON1bits.PEN1H = 1;		// enable pwm for servo 1
	PWM2CON1bits.PEN1L = 0;		// disable lower fet drive

    /* set dead time options (not used), scale = 1, 20*FCY (about 500ns) */
    P2DTCON1bits.DTBPS = 0;		//pwmb unit prescale of 1 tcy
    P2DTCON1bits.DTAPS = 0;		//pwma unit prescale of 1 tcy
	P2DTCON1bits.DTA = 20;		// dead time 
	P2DTCON1bits.DTB = 20;		//
  
    /* set up the fault mode override bits and mode */
	/* no fault pin used in this application */
    P2FLTACONbits.FAEN1 = 0;

    /* set special event post scaler, output override sync select and pwm update enable */
    PWM2CON2bits.SEVOPS = 0;	// prescale of 1
    PWM2CON2bits.OSYNC = 1;		// output overides are symced to pwm
	PWM2CON2bits.UDIS = 0;		// allow updates to duty cycle and period registers
	PWM2CON2bits.IUE = 0;		// updates to pdc regs is symced to pwm cycle

     // we get a pwm intr every 4 pwm cycles (250us)
    P2TCONbits.PTSIDL = 0;	// pwm runs in idle mode
    P2TCONbits.PTOPS = 3;	// post scale of 4
    P2TCONbits.PTCKPS = 0;	// pwm time base prescale of 1 TCY
    P2TCONbits.PTMOD = 2;	// mode is continuous up/dwm
    P2TCONbits.PTEN = 1;	// enable pwm timer 
}




/*********************************************************************
  Function:        void set_pwm0(float percent)

  PreCondition:    None.
 
  Input:           drive request -100 to +100 percent

  Output:          None.

  Side Effects:    None.

  Overview:        Sets up pwm outputs as required...

  Note:            None.
********************************************************************/
void set_pwm0(float percent)
{
    const long int pwm_max = ((FCY/FPWM)*0.95) - 1;	// 95% full on
    long temp_pwm;

	if ((SVO_ENABLE == 0) || (percent == 0.0))
	{
		P1DC1 = 0;		// turn of pwm for 1st half bridge top fet
		_RB15= 0;		// forward
		return;
	}

	// for tuning its nice to keep an upper limit on output drive
	if (pid[0].maxoutput > 0.0)
	{
		if ( percent > pid[0].maxoutput ) percent = pid[0].maxoutput;
		if ( percent < -pid[0].maxoutput ) percent = -pid[0].maxoutput;
	}

	// compute value required in one of the 2 pwm regs
    temp_pwm = (long int)((float)pwm_max/100.0 * percent);

	// insure that at least 1 count of pwm/cycle is off to charge bs caps
	if (temp_pwm > pwm_max ) temp_pwm = pwm_max;
	if (temp_pwm < -pwm_max ) temp_pwm = -pwm_max;

	if ( percent > 0.0 )  // FORWARD
	{
	    P1DC1 = temp_pwm; // start pwm 
		_RB15= 0;		// forward
	}
    else if ( percent < 0.0 )	//REVERSE
	{
        P1DC1 = -temp_pwm;
		_RB15 = 1;		// rev
	}
}
/*********************************************************************
  Function:        void set_pwm1(float percent)

  PreCondition:    None.
 
  Input:           drive request -100 to +100 percent

  Output:          None.

  Side Effects:    None.

  Overview:        Sets up pwm outputs as required...

  Note:            None.
********************************************************************/
void set_pwm1(float percent)
{
    const long int pwm_max = ((FCY/FPWM)*0.95) - 1;	// 95% full on
    long temp_pwm;

	if ((SVO_ENABLE == 0) || (percent == 0.0))
	{
		P2DC1 = 0;		// turn off pwm
		_RB9= 0;		// forward
		return;
	}

	// for tuning its nice to keep an upper limit on output drive
	if (pid[1].maxoutput > 0.0)
	{
		if ( percent > pid[1].maxoutput ) percent = pid[1].maxoutput;
		if ( percent < -pid[1].maxoutput ) percent = -pid[1].maxoutput;
	}

	// compute value required in one of the 2 pwm regs
    temp_pwm = (long int)((float)pwm_max/100.0 * percent);

	// insure that at least 1 count of pwm/cycle is off to charge bs caps
	if (temp_pwm > pwm_max ) temp_pwm = pwm_max;
	if (temp_pwm < -pwm_max ) temp_pwm = -pwm_max;

	if ( percent > 0.0 )  // FORWARD
	{
	    P2DC1 = temp_pwm; // start pwm
		_RB9= 0;		// forward
	}
    else if ( percent < 0.0 )	//REVERSE
	{
        P2DC1 = -temp_pwm;
		_RB9 = 1;		// rev
	}
}

