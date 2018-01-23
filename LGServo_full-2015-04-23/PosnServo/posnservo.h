/**
 * @author Lawrence Glaister VE7IT
 * 
 * @section DESCRIPTION
 * 
 * This library contains the code for a smart servo positioning loop.
 * The loop is tuned using quite traditional PID plus 2 feed forward 
 * terms. The library also implements a trapazodal motion profile.
 * This motion profile is tuned with max velocity and acceleration 
 * parameters. This allows for nicely controlled motion when giving the
 * loop a target position. It still allows for an external motion profile
 * planner to drip feed positions to this library on a regular interval,
 * with the bonus of large steps in position being handled in a nicely 
 * controlled manner.
 */
  
#ifndef POSNSERVO_H
#define POSNSERVO_H

/**
 * Includes
 */
#include "mbed.h"
 
/**
 * Defines
 */
 
 
 /**
 * Proportional-integral-derivative with trapazoidal motion controller.
 */
class POSNSERVO 
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
    POSNSERVO(float period_ns,  // typical 1000000ns = 1ms
              int   enable,     // 0 or 1
              int   deadband,   // position error where no loop correction occurs
              float pgain,      // loop parameter that compensates for position error
              float igain,      // loop parameter that compensates for long term error
              float dgain,      // loop parameter that is used to stablize loop
              float ff1gain,    // loop parameter that compensates for motor back emf
              float ff2gain);   // loop parameter that compensates for acceleration lag
      
    /**
     * PID calculation. 
     * Should be called every interval ns
     *
     * @return The controller output as a float 
     */
    float calcPID(int actual_posn, int cmd_posn);

    // get current settings
    float getPeriod_ns(void);
    int   getEnable(void);
    int   getDeadband(void);
    float getPgain(void);
    float getIgain(void);
    float getDgain(void);
    float getFF1gain(void);
    float getFF2gain(void);
    
    // with a pgain == 1.0, drive will be 1% per position count error
    float getDrive(void);
    int   getPosnErr(void);
 
    // set current settings
    void setPeriod_ns(float);
    void setEnable(int);
    void setDeadband(int);
    void setPgain(float);
    void setIgain(float);
    void setDgain(float);
    void setFF1gain(float);
    void setFF2gain(float);
   
 
 private:       // all the local variables used by posnservo
    float   period_ns;
    float   period_sec;
    int     enable;
    int     deadband;
    float   pgain;
    float   igain;
    float   dgain;
    float   ff1gain;
    float   ff2gain;

    // persistent vars used by PID calcs
    float error_i;   // cumulative integrator term
    int   prev_cmd;
    float prev_cmd_d;
    float prev_error;
    float drive;    //current drive (-1.0 to 1.0)(not affected by enable)
    int   errcnts;  // current posn error in motor encoder counts    
}; 
 
#endif /* POSNSERVO_H */