//---------------------------------------------------------------------
//	File:		pid.c
//
//	Written By:	Lawrence Glaister VE7IT
//
// Purpose: 
//              Proportional/Integeral/Derivative control loop used
//				for dual axis of position control.
//          
//          
//---------------------------------------------------------------------
//
// Revision History
//
// Sept 12 2009 --    first version Lawrence Glaister
// 
//---------------------------------------------------------------------- 
#include "servo-dual.h"
#include <math.h>

/***********************************************************************
*                STRUCTURES AND GLOBAL VARIABLES                       *
************************************************************************/

/* our servo loop data variable */
struct PID pid[2];

/***********************************************************************
*                  LOCAL FUNCTION DECLARATIONS                         *
************************************************************************/
void calc_pid(int servo);
void init_pid(void);

void init_pid(void)
{
    /* init all structure members */
    pid[0].enable = pid[1].enable = (SVO_ENABLE == 1);		// mirror state of PIN
    pid[0].command = pid[1].command = 0L;
    pid[0].feedback = pid[1].feedback = 0L;
	pid[0].maxposerror = pid[1].maxposerror = 0.0;
    pid[0].error = pid[1].error = 0.0;
    pid[0].output = pid[1].output = 0.0;
    pid[0].deadband = pid[1].deadband = 0.0;
    pid[0].maxerror = pid[1].maxerror = 1000.0;
    pid[0].error_i = pid[1].error_i = 0.0;
    pid[0].prev_error = pid[1].prev_error = 0.0;
    pid[0].error_d = pid[1].error_d = 0.0;
    pid[0].prev_cmd = pid[1].prev_cmd = 0L;
	pid[0].prev_vel = pid[1].prev_vel = 0.0;
    pid[0].limit_state = pid[1].limit_state = 0;
    pid[0].cmd_d = pid[1].cmd_d = 0.0;
    pid[0].pgain = pid[1].pgain = 0.5;
    pid[0].igain = pid[1].igain = 0.0;
    pid[0].dgain = pid[1].dgain = 0.5;
    pid[0].ff0gain = pid[1].ff0gain = 0.5;
    pid[0].ff1gain = pid[1].ff1gain = 0.0;
    pid[0].maxoutput = pid[1].maxoutput = 50.0;
	pid[0].multiplier = pid[1].multiplier = 1;
	pid[0].accel = pid[1].accel = 0.3;		// only used for profile moves
	pid[0].velocity = pid[1].velocity = 50.0;		// " 50cnts/tick * 50000ticks/sec
	pid[0].raw_pwm = pid[0].raw_vel = pid[1].raw_pwm = pid[1].raw_vel = 0.0;
}


/***********************************************************************
*                   REALTIME PID LOOP CALCULATIONS                     *
* 	this code is embedded inside a periodic ISR that defines the servo 
*	loop timing.
*
************************************************************************/
void calc_pid( int servo )
{
    float tmp1;
    float periodfp;
    long period = 250000;	/* thread period in ns (setup by pwm intr)*/

    /* precalculate some timing constants */
    periodfp = period * 0.000000001;		// usually .001 sec

    /* calculate the error */
    tmp1 = (float)(pid[servo].command - pid[servo].feedback);
    pid[servo].error = tmp1;

	// update a status variable we used to check for max error during a move
	if ( fabs(pid[servo].error) > fabs(pid[servo].maxposerror) )
		pid[servo].maxposerror = pid[servo].error;

    /* apply error limits (this is also the servo fault limit)*/
    if (pid[servo].maxerror != 0.0) 
	{
		if (tmp1 > pid[servo].maxerror) 
		{
	    	tmp1 = pid[servo].maxerror;
		} 
		else if (tmp1 < -pid[servo].maxerror) 
		{
	    	tmp1 = -pid[servo].maxerror;
		}
    }
    /* apply the deadband */
    if (tmp1 > pid[servo].deadband) 
	{
		tmp1 -= pid[servo].deadband;
    } 
	else if (tmp1 < -pid[servo].deadband) 
	{
		tmp1 += pid[servo].deadband;
    }
	else 
	{
		tmp1 = 0;
    }

    /* do integrator calcs only if enabled */
    if ((pid[servo].igain > 0.0) && (pid[servo].enable != 0)) 
	{
		/* if output is in limit, don't let integrator wind up */
		if ( pid[servo].limit_state == 0 ) 
		{
	    	/* compute integral term */
	    	pid[servo].error_i += tmp1 * periodfp;	/* *0.001 */
		}
    } 
	else 
	{
		/* not enabled, reset integrator */
		pid[servo].error_i = 0;
    }

    /* calculate derivative term */
    pid[servo].error_d = (tmp1 - pid[servo].prev_error);
    pid[servo].prev_error = tmp1;

    /* calculate derivative of posn command  ( used with ff0 tuning param ) */
    pid[servo].cmd_d = (float)(pid[servo].command - pid[servo].prev_cmd);
    pid[servo].prev_cmd = pid[servo].command;

    /* calculate derivative of vel command  ( used with ff1 tuning param ) */
    pid[servo].vel_d = pid[servo].cmd_d - pid[servo].prev_vel;
    pid[servo].prev_vel = pid[servo].cmd_d;

	pid[servo].drive_p =   pid[servo].pgain * tmp1;
	pid[servo].drive_i =   pid[servo].igain * pid[servo].error_i;
	pid[servo].drive_d =   pid[servo].dgain * pid[servo].error_d;
	pid[servo].drive_ff0 = pid[servo].cmd_d * pid[servo].ff0gain;		/* extra drive based on velocity */
	pid[servo].drive_ff1 = pid[servo].vel_d * pid[servo].ff1gain;		/* extra drive based on accel */

	/* apply integrator limits (25% of full drive) */
   	if (pid[servo].drive_i > 25.0) 
	{
		pid[servo].drive_i = 25.0;
    } 
	else if (pid[servo].drive_i < -25.0) 
	{
		pid[servo].drive_i = -25.0;
    }
	tmp1 = 	pid[servo].drive_p +
			pid[servo].drive_i +
			pid[servo].drive_d +
			pid[servo].drive_ff0 +
			pid[servo].drive_ff1 ;

	/* apply output limits */
   	if (tmp1 > pid[servo].maxoutput) 
	{
		tmp1 = pid[servo].maxoutput;
		pid[servo].limit_state = 1;
   	} 
	else if (tmp1 < -pid[servo].maxoutput) 
	{
		tmp1 = -pid[servo].maxoutput;
		pid[servo].limit_state = 1;
   	} 
	else 
	{
		pid[servo].limit_state = 0;
   	}
	pid[servo].output = tmp1;
}
