/*
 * posnservo.cpp
 *
 * Created on: 2010-11-17 orginally for xmos 4 core processor
 * Ported to mbed stm32f411 processor project in April 2015
 * @author Lawrence Glaister VE7IT
 */
 
 /**
 * Includes
 */
#include "SMP.h"

SMP::SMP(float Period_ns,  // typical 1000000ns = 1ms
         int   Mintravel,  // absolute position limits -
         int   Maxtravel,  // absolute position limits +
         float Maxv,       // maximum velocity allowed
         float Maxa)       // maximum accelleration allowed 


{
    period_ns = Period_ns;
    period_sec = period_ns * 1e-9f;    
    min_ = Mintravel;
    max_ = Maxtravel;
    maxv = Maxv;
    maxa = Maxa;
    
    old_in = 0.0f;
    old_out = 0.0f;
    old_v = 0.0f;
    
}


// Call repeatedly to calc a new motor position value for servo
// typically every 1ms.

// Limit the output signal to fall between min and max,
// limit its slew rate to less than maxv per second,
// and limit its second derivative to less than maxa per second squared.
// When the signal is a position, this means that the position, velocity,
// and acceleration are limited.

// this routine computes and returns a new target position
// each time it is called (on a periodic basis, typically 1ms/call)

int SMP::calcNewPosn(int in)
{

    float lin, lout, in_v, min_v, max_v, ramp_a, avg_v, err, dv, dp;
    float min_out, max_out, match_time, est_in, est_out;

    est_in = est_out = match_time = 0;

    // make sure our incoming position command is within limits
    lin = in;
    if ( lin < min_ ) lin = min_;
    if ( lin > max_ ) lin = max_;

    // calculate input derivative
    in_v = (lin - old_in) / period_sec;

    // determine v and out that can be reached in one period
    min_v = old_v - maxa * period_sec;
    if ( min_v < -maxv ) min_v = -maxv;

    max_v = old_v + maxa * period_sec;
    if ( max_v > maxv ) max_v = maxv;

    min_out = old_out + min_v * period_sec;
    max_out = old_out + max_v * period_sec;
    if ( ( lin >= min_out ) && ( lin <= max_out ) && ( in_v >= min_v ) && ( in_v <= max_v ) )
    {
        // we can follow the command without hitting a limit
        lout = lin;
        old_v = ( lout - old_out ) / period_sec;
    }
    else
    {
        // can't follow commanded path while obeying limits
        // determine which way we need to ramp to match v
        if ( in_v > old_v )
            ramp_a = maxa;
        else
            ramp_a = -maxa;

        // determine how long the match would take
        match_time = ( in_v - old_v ) / ramp_a;
        // where we will be at the end of the match
        avg_v = ( in_v + old_v + ramp_a * period_sec ) * 0.5f;
        est_out = old_out + avg_v * match_time;
        // calculate the expected command position at that time
        est_in = old_in + in_v * match_time;
        // calculate position error at that time
        err = est_out - est_in;
        // calculate change in final position if we ramp in the opposite direction for one period
        dv = -2.0 * ramp_a * period_sec;
        dp = dv * match_time;
        // decide what to do
        if ( fabs(err+dp*2.0f) < fabs(err) )
            ramp_a = -ramp_a;

        if ( ramp_a < 0.0f )
        {
            lout = min_out;
            old_v = min_v;
        }
        else
        {
            lout = max_out;
            old_v = max_v;
        }
    }
    old_out = lout;
    old_in = lin;

    return (int)lout;
}


float SMP::getPeriodns()
{
    return period_ns;   
}    

int   SMP::getMinTravel(void)
{
    return min_;
}
    
int   SMP::getMaxTravel(void)
{
    return max_;
}

float SMP::getMaxVel(void)
{
    return maxv;
}

float SMP::getMaxAccel(void)
{
    return maxa;
}

void SMP::setPeriod_ns(float ns)
{
    period_ns = ns;
    period_sec = period_ns * 1e-9f;
}

void  SMP::setMinTravel(int mintravel)
{
    min_ = mintravel;
}
    
void   SMP::setMaxTravel(int maxtravel)
{
    max_ = maxtravel;
}
    
void SMP::setMaxVel(float maxvel)
{
    maxv = maxvel;
}

void SMP::setMaxAccel(float maxaccel)
{
    maxa = maxaccel;
}

