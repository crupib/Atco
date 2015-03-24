//---------------------------------------------------------------------
//	File:		commands.c
//
//	Written By:	Lawrence Glaister VE7IT
//
// Purpose: This set of routines deals used to implement
//          the serial command struct for configuring
//          the internal servo parameters.
//---------------------------------------------------------------------
//
// Revision History
//
// Aug 11 2006 --    first version Lawrence Glaister
// Sept 22 2006      added deadband programming
// Sept 25 2006      added programmable servo loop interval
// June 29 2009		added g,a,v commands for trapazoidal motion
// July 7 2009		added raw command for outputting raw pwm values
// Sep 2009			added command for saving params on dspic33,
//					multiple servo support
// 
//---------------------------------------------------------------------- 
#include "servo-dual.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//extern volatile unsigned short int timer_test;

//extern unsigned short int cmd_posn;			// current posn cmd from PC
//extern unsigned short int cmd_err;			// number of bogus encoder positions detected
//extern unsigned short int cmd_bits;			// a 4 bit number with old and new port values

extern struct PID pid[];

extern char rxbuff[];		// global rx buffer for serial data
extern char *rxbuffptr;		// local input ptr for storing data
extern short int rxrdy;		// flag to indicate a line of data is available in buffer
extern volatile struct MOVE move[];

extern void setup_move(int servo, long int dist, float maxv, float acc);
extern void set_pwm0(float percent);
extern void set_pwm0(float percent);
extern void WriteNV(void);

extern int  ain0buff[];		// arrays of analog samples for each channel
extern int  ain1buff[];
extern int  ain2buff[];
extern int  ain3buff[];

long int jerk;					// global used for loop tuning
int axis = 0;		// user sets to 0 or 1 for tuning or commands


void print_tuning(int servo)
{
	printf("\rCurrent Settings for axis=%1d (cksum=0x%04X):\r\n",servo+1,pid[servo].cksum);
	printf("servo enabled = %d\r\n",	pid[servo].enable);
	printf("(p) = %f\r\n",		(double)pid[servo].pgain);
	printf("(i) = %f\r\n",		(double)pid[servo].igain);
	printf("(d) = %f\r\n",		(double)pid[servo].dgain);
	printf("(ff0) = %f\r\n",	(double)pid[servo].ff0gain);
	printf("(ff1) = %f\r\n",	(double)pid[servo].ff1gain);
    printf("dead(b)and = %f\r\n",(double)pid[servo].deadband);
	printf("(m)ax Output = %f percent\r\n",(double)pid[servo].maxoutput);
	printf("(f)ault error = %f counts\r\n", (double)pid[servo].maxerror);
	printf("(x)pc cmd multiplier = %hu\r\n", pid[servo].multiplier);
	printf("(a)cceleration = %f\r\n",(double)pid[servo].accel);
	printf("(v)elocity = %f\r\n",(double)pid[servo].velocity);
}

void process_serial_buffer()
{
	switch( rxbuff[0] )
	{

	case '1':	
		axis = 0;		// make 1st axis default
		print_tuning(axis);
		break;		

	case '2':
		axis = 1;		// make second axis default
		print_tuning(axis);
		break;		


	case 'a':	// set the maximum acceleration for a g command
		if (rxbuff[1])
		{
			if (rxbuff[1] == 'n')
			{
				printf(" %05u %05u %05u %05u\r\n",ain0buff[1],ain1buff[1],ain2buff[1],ain3buff[1]);
				break;
			}
			else
				pid[axis].accel = atof(&rxbuff[1]);
		}
		print_tuning(axis);
		break;		

	case 'b':	// set deadband
		if (rxbuff[1])
			pid[axis].deadband = atof(&rxbuff[1]);
		print_tuning(axis);
		break;		

	case 'd':	//set d gain
		if (rxbuff[1])
			pid[axis].dgain = atof(&rxbuff[1]);
		print_tuning(axis);
		break;		


	case 'e':	// print raw encoder value from pics 16bit encoder register
		printf("\rencoders = %05d, %05d\r\n",POS1CNT & 0x0ffff, POS2CNT & 0xffff);
		break;	

	case 'f':	//set the ff0, ff1 or fault tolerance
		if (rxbuff[1] == 'f' && rxbuff[2] == '0' && rxbuff[3])
			pid[axis].ff0gain = atof(&rxbuff[3]); //set ff0 gain (extra boost based on velocity)
		else if (rxbuff[1] == 'f' && rxbuff[2] == '1' && rxbuff[3])
			pid[axis].ff1gain = atof(&rxbuff[3]); 	// set ff1 gain (extra boost based on accel)
		else if (rxbuff[1])
			pid[axis].maxerror = atof(&rxbuff[1]);	// fault tolerance
		print_tuning(axis);
		break;		

	case 'g':	// goto a new position using a and v limits
		if (rxbuff[1])
		{
			long int moveby;
			moveby = atol(&rxbuff[1]) - pid[axis].command;
		 	setup_move(axis,moveby,pid[axis].velocity,pid[axis].accel);
		}
		break;		

	case 'i':	//set igain
		if (rxbuff[1])
		{
			pid[axis].igain = atof(&rxbuff[1]);
			pid[axis].error_i = 0.0;	//reset integrator
		}
		print_tuning(axis);
		break;		

	case 'j':	// alternate between 2 positions with step in commanded position
		if (rxbuff[1])
			jerk = atol(&rxbuff[1]);	
		break;


	case 'l':	//list the current tuning parameters
		print_tuning(axis);
		break;

	case 'm':	//set max motor drive output in percent
		if (rxbuff[1])
		{
			pid[axis].maxoutput = atof(&rxbuff[1]);
			if (pid[axis].maxoutput > 100.0) pid[axis].maxoutput = 100.0;
			if (pid[axis].maxoutput < 0.0) pid[axis].maxoutput = 0.0;
		}
		print_tuning(axis);
		break;		

	case 'p':	//set pgain
		if (rxbuff[1])
			pid[axis].pgain = atof(&rxbuff[1]);
		print_tuning(axis);
		break;		

	case 'r':	// set raw velocity or raw pwm value
		if ((rxbuff[1]=='p') && (rxbuff[2]))
		{
			move[axis].enable = 0;	// cancel g moves
			pid[axis].raw_vel = 0.0;	// cancel raw vel moves
			pid[axis].raw_pwm = atof(&rxbuff[2]);
		}
		if ((rxbuff[1]=='v') && (rxbuff[2]))
		{
			move[axis].enable = 0;	// cancel g moves
			pid[axis].raw_pwm = 0.0;	// cancel raw pwm moves
			pid[axis].raw_vel = atof(&rxbuff[2]);
		}
		break;		

	case 's':	
		if (rxbuff[1]=='a')
		{
			WriteNV();		// sa cmd.... save current tuning params
			break;
		}
		// print the current status of the servo loop calcs
		printf("\rServo Loop Internal Calcs for axis %1d:\r\n",axis+1);
		if (pid[axis].enable) 
			printf("Servo Enabled\r\n");
		else
			printf("Servo Disabled\r\n");
		printf("command: %ld\r\n",pid[axis].command);
		printf("feedback: %ld\r\n",pid[axis].feedback);
		printf("error: %f\r\n",(double)pid[axis].error);
		printf("max error: %f\r\n",(double)pid[axis].maxposerror);
		pid[axis].maxposerror = 0.0;
		printf("P:%5.1f I:%5.1f D:%5.1f FF0:%5.1f FF1:%5.1f\r\n",
			(double)pid[axis].drive_p, (double)pid[axis].drive_i, 
			(double)pid[axis].drive_d, (double)pid[axis].drive_ff0, 
			(double)pid[axis].drive_ff1);
		printf("PWM output:  %f percent\r\n",(double)pid[axis].output);
		printf("limit_state: %d\r\n",(int)pid[axis].limit_state);
		break;

	case 'v':	// set the maximum velocity for a g command
		if (rxbuff[1])
			pid[axis].velocity = atof(&rxbuff[1]);
		print_tuning(axis);
		break;		

	case 'x':	// set the step multiplier for commands from pc
		if (rxbuff[1])
		{
			pid[axis].multiplier = (short)atof(&rxbuff[1]);
			if ( pid[axis].multiplier < 1 ) pid[axis].multiplier = 1;
			if ( pid[axis].multiplier > 64 ) pid[axis].multiplier = 64;
		}
		print_tuning(axis);
		break;		


	default:
		pid[axis].raw_pwm = pid[axis].raw_vel = 0.0;
		printf("\r\nUSAGE:\r\n");
		printf("1 select 1st axis for tuning/cmds\r\n");
		printf("2 select 2nd axis for tuning/cmds\r\n");
		printf("p x.x set proportional gain\r\n");
        printf("i x.x set integral gain\r\n"); 
		printf("d x.x set differential gain\r\n"); 
        printf("ff0 x.x set FF0 gain(vel helper)\r\n"); 
		printf("ff1 x.x set FF1 gain(acc helper)\r\n"); 
		printf("b x.x set deadband\r\n");
		printf("m x.x set max output drive(percent)\r\n"); 
		printf("f x.x set max error before drive faults(counts)\r\n");
		printf("x n   set pc command multiplier (1-64)\r\n");
		printf("e print current encoder count\r\n"); 
		printf("l print current loop tuning values\r\n"); 
        printf("s print internal loop components\r\n");
        printf("j x.x alternately posn for loop tuning\r\n");
		printf("v x.x set max velocity for g command\r\n");
		printf("a x.x set max acceleration for g command\r\n");
		printf("g x.x go x.x encoder counts using v and a\r\n");
		printf("r[p,v] x.x set [pwm,vel] to raw value\r\n");
		printf("an retrieves the current analog values\r\n");
		printf("sa save tuning params to non volatile storage\r\n");
		printf("? print this help\r\n");
	}

	// reset input buffer state
	rxrdy = 0;
	rxbuff[0] = 0;
	rxbuffptr = &rxbuff[0];
	putchar('>');
}
