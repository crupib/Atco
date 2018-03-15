/**
 * @author Lawrence Glaister VE7IT
 * 
 * @section DESCRIPTION
 * 
 * This library implements a trapazoidal motion profile planner.
 * This motion profile is tuned with max velocity and acceleration 
 * parameters. This allows for nicely controlled motion when given
 * a target position.
 */
  
#ifndef SMP_H
#define SMP_H

/**
 * Includes
 */
#include "mbed.h"
 
/**
 * Defines
 */
 
 
 /**
 * trapazoidal motion planner.
 */
class SMP 
{
public:
 
    /**
     * Constructor.
     *
     * Sets default limits, 
     * calculates tuning parameters
     *
     * @param Kc - Tuning parameter
     * @param tauI - Tuning parameter
     * @param tauD - Tuning parameter
     * @param interval PID calculation performed every interval seconds.
     */
    SMP(float period_ns,  // typical 1000000ns = 1ms
        int mintravel,    // absolute position limits -
        int maxtravel,    // absolute position limits +
        float maxv,       // maximum velocity allowed
        float maxa);      // maximum accelleration allowed 
     
    /**
     * new position calculation. 
     * Should be called every interval ns
     *
     * @return  computes and returns a new reasonable target position
     * that should be reachable during the next interval
     * each time it is called (on a periodic basis, typically 1ms/call)
     * ensure positioning occurs in a controlled manner with acceleration
     * and max velocity contrained.
     */

    int calcNewPosn(int in);        // where we want to get to
    
    // get current settings
    float getPeriodns(void);    
    int   getMinTravel(void);
    int   getMaxTravel(void);
    float getMaxVel(void);
    float getMaxAccel(void);

    // set current settings
    void setPeriod_ns(float);
    void setMinTravel(int);
    void setMaxTravel(int);
    void setMaxVel(float);
    void setMaxAccel(float);
    
 
 private:   // all the local variables used by simple motion planner
    float   period_ns;
    float   period_sec;
    int     min_;       // position travel limit
    int     max_;       // position travel limit
    float   maxa;       // max acceleration allowed
    float   maxv;       // max velocity allowed

    // persistent vars used by motion limit function
    float old_in;       // previous input
    float old_out;      // previous output
    float old_v;        // previous 1st derivative
}; 
 
#endif /* SMP_H */