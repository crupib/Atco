//---------------------------------------------------------------------
//	File:		servo-dual.h
//
//	Written By:	Lawrence Glaister VE7IT
//
// Purpose: Various header info for the project
//      
// 
//---------------------------------------------------------------------
//
// Revision History
// Aug 17 2009	-- intial config for dspic33fj128mc202
//	
//---------------------------------------------------------------------- 
// define which chip we are using (peripherals change)
#include "p33FJ128MC202.h"

// the following version string is printed on powerup (also in every object module)
#define CPWRT  "\r\nservo-dual by L.Glaister\r\n"
#define VERSION "(c) 12 Sept 2009 by VE7IT"

#define FCY  39374500    // 14.318Mhz; with * 22 PLL -> 39 MIPS
#define FPWM 20000       // 20 kHz, so that no audible noise is present.

// define some i/o bits for the various modules
// output bits
#define SERVO_FAULT _LATB7		// hi on pic pin = fault
#define DIR0     	_LATB15
#define DIR1     	_LATB9

// input bits
#define SVO_ENABLE _RA3

// for some reason PI may not be defined in math.h on some systems
#ifndef M_PI
#define M_PI (3.14159265358979323846)
#endif

#define	TRUE	(1)
#define	FALSE	(0)	

struct PID{
	// the first block of params must survive powerfails and cksums
    // keep params together followed by cksum so that calc_cksum() works
    float pgain;		 /* param: proportional gain                 */
    float igain;		 /* param: integral gain                     */
    float dgain;		 /* param: derivative gain                   */
    float ff0gain;		 /* param: feedforward proportional          */
    float ff1gain;		 /* param: feedforward derivative            */
    float maxoutput;	 /* param: limit for PID output              */
    float deadband;		 /* param: deadband                          */
    float maxerror;		 /* param: limit for error                   */
	float accel;		 /* param: accel for trapazoidal moves       */
	float velocity;		 /* param: max velocity for trapazoidal moves*/
	short multiplier;	 /* param: pc command multiplier             */
    short cksum;		 /* data block cksum used to verify eeprom   */

	// the following block of temp vars is related to axis servo calcs
    // but should not be cksumed
    long int command;	/* commanded value */
    long int feedback;	/* feedback value */
    long int prev_cmd;	/* previous command for differentiator */
	float raw_vel;		/* non zero value forces velocity control mode */
	float raw_pwm;		/* non zero value forces raw pwm control mode */
    float error;		/* command - feedback */
    float maxposerror;  /* status: maximum position error so far */
    float error_i;		/* opt. param: integrated error */
    float prev_error;	/* previous error for differentiator */
    float error_d;		/* opt. param: differentiated error */
    float cmd_d;		/* current velocity */
	float vel_d;		/* current acceleration */
 	float prev_vel;		/* previous servo cycle velocity */
	float drive_p;		/* computed drive components summed into output */
	float drive_i;
	float drive_d;
	float drive_ff0;
	float drive_ff1;
    float output;		/* the output value */
    short enable;		/* enable input */
    short limit_state;	/* 1 if in limit, else 0 */
};

// control structure used for the duration of one trapazoidal
// or triangular move.
struct MOVE
{
    short enable;// flag used to sync between background and intr
    short direction;      // -1 means move encoder towards smaller counts
    float maxv;         // max counts/tick calculated for current move
    float acc;          // the accelleration requested for current move
    float atime;        // the calculated time to accellerate
    float adist;        // the calculated distance to accelerate
    float cvdist;       // the constant velocity distance in counts
    float cvtime;       // the constant velocity time in ticks
    long int totdist;   // the total number of counts to move (always+)
    long int tottime;   // the total number of ticks to complete move
    long int time;      // current time tick along move
    long int posn;      // current position along move in counts
};
