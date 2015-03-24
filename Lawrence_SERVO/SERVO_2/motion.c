// motion.c
//=====================================================================
// a collection of subroutines and data structures used to provide
// a descrete time sampled solution to a requested motion profile
// written June 2009 (c) Lawrence P. Glaister VE7IT
// This code may be released in the public domain with no expectations
// of usability or correctness in any particular application.
//
//g commands:
//Note that the unit for position, velocity and
//acceleration are in encoder counts, counts/servo tick and counts/tick/tick.
//A servo tick is usually equal to 500 microseconds.
//
// Typical velocity and acceleration values are v=20.0 and a=0.01
// moves are spec'd as +-encoder counts
// v = 20.0 => 20.0 / servo period = 20 /.0005 = 40,000 counts/sec
// an example move... setup_move(100000L, 20.0, 0.01)
// adist = 20000 counts, atime = 2000 ticks = 1 second
// cvdist = 60000 counts, cvtime = 3000 ticks = 1.5seconds
// so we get 1 sec accel, cruise for 1.5 sec and then 1 sec decel
//
// compile this test code using
// gcc -lm -o  motion motion.c
//=====================================================================
#include "servo-dual.h"
#include <stdio.h>
#include <math.h>

// declaration moved to project header file
// control structure used for the duration of one trapazoidal
// or triangular move.
// struct MOVE
// {
//     int enable;         // flag used to sync between background and intr
//     int direction;      // -1 means move encoder towards smaller counts
//     float maxv;         // max counts/tick calculated for current move
//     float acc;          // the accelleration requested for current move
//     float atime;        // the calculated time to accellerate
//     float adist;        // the calculated distance to accelerate
//     float cvdist;       // the constant velocity distance in counts
//     float cvtime;       // the constant velocity time in ticks
//     long int totdist;   // the total number of counts to move (always+)
//     long int tottime;   // the total number of ticks to complete move
//     long int time;       // current time tick along move
//     long int posn;       // current position along move in counts
// };
volatile struct MOVE move[2];

// void setup_move()
// called before each move to precalulate the critical variables
// used during the motion cycle.
void setup_move(int servo, long int dist, float maxv, float acc)
{
	if (servo < 0 || servo > 1)
		return;
    move[servo].enable = 0;
    move[servo].acc = fabs(acc);
    move[servo].maxv = fabs(maxv);

	// avoid use of abs function
    if ( dist < 0 )
	{
        move[servo].direction = -1;
    	move[servo].totdist =  -dist;
	}
    else
	{
        move[servo].direction = 1;
    	move[servo].totdist =  dist;
	}

    move[servo].atime = move[servo].maxv / move[servo].acc;
    move[servo].adist = move[servo].maxv * move[servo].maxv / ( 2.0 * move[servo].acc );

    if ( (2.0 * move[servo].adist) > move[servo].totdist )
    {
        // this is a triangle move profile
        // move is capped by a max v lower than requested
        // (limited by acc and distance)
        move[servo].atime = sqrt( move[servo].totdist / move[servo].acc);
        move[servo].maxv = move[servo].atime * move[servo].acc;
        move[servo].adist = move[servo].maxv * move[servo].maxv / ( 2.0 * move[servo].acc );
    }

    move[servo].cvdist = move[servo].totdist - ( move[servo].adist * 2.0 );
    move[servo].cvtime = move[servo].cvdist / move[servo].maxv;
    move[servo].tottime = (long int)(move[servo].atime + move[servo].cvtime + move[servo].atime + 1.0);
    move[servo].time = move[servo].posn = 0L;
    move[servo].enable = 1;        // let isr know we have a move to do
}

// int calc_velocity()
// routine called during a move to calculate the number of encoder
// ticks to move during the current time slot (really a velocity).
// to make calcs easier to follow, all moves are assumed to be in the
// positive direction and the sign of the resulting calculated step value
// makes us move in the correct direction.
int calc_velocity( int servo )
{
    int steps;
    float required_posn;
    float time;

    if ( move[servo].enable != 1 )
        return 0;

    move[servo].time++;        // one more tick along motion profile

    // calculate where we should be along move
    if (move[servo].time < (long int)move[servo].atime)
    {
        // in accell phase of move
        // x=at^2/2
        time = (float)move[servo].time;
        required_posn = move[servo].acc * time * time * 0.5;
    }
    else if ( move[servo].time < (long int)( move[servo].atime + move[servo].cvtime))
    {
        // in constant velocity regime
        // x = vt
        time = (float)move[servo].time-move[servo].atime;
        required_posn = move[servo].adist + time * move[servo].maxv;
    }
    else if  ( move[servo].time < move[servo].tottime )
    {
        // we are in decel ramp
        // x = vt + 0.5at^2
        time = (float)move[servo].time - move[servo].atime - move[servo].cvtime;
        required_posn = move[servo].adist + move[servo].cvdist +
                        move[servo].maxv * time -
                        move[servo].acc * time * time * 0.5;
    }
    else
    {
        // we have been called more times than necessary to complete move
        move[servo].enable = 0;
		printf("OK%1d\r\n>",servo);	// hand shake with host
        return 0;
    }

    steps = (int)(required_posn - (float)move[servo].posn + 0.5);
    move[servo].posn += steps;

    return steps * move[servo].direction;
}

#if 0
// test main() for verification of code and an example of usage
int main( int argc, char **argv )
{
    long int i;
    int curmove;

    setup_move(-100000L, 20.0, 0.01);
    printf("     Tick   Step   Posn\n");
    for ( i=0L; move.enable == 1 ; i++ )
    {
        curmove = calc_velocity();
        printf("%6d %6d %6ld\n",i,curmove,move.posn);
    }
    printf("move by %ld completed in %ld ticks\n",move.posn * move.direction,move.time);
}

#endif




