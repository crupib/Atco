/*
 * posnservo.cpp
 *
 * Created on: 2010-11-17 orginally for xmos 4 core processor
 * Ported to mbed stm32f411 processor in April 2015
 * @author Lawrence Glaister VE7IT
 */
 
 /**
 * Includes
 */
#include "posnservo.h"

POSNSERVO::POSNSERVO(float Period_ns,  // typical 1000000ns = 1ms
              int   Enable,     // 0 or 1
              int   Deadband,   // position error where no loop correction occurs
              float Pgain,      // loop parameter that compensates for position error
              float Igain,      // loop parameter that compensates for long term error
              float Dgain,      // loop parameter that is used to stablize loop
              float Ff1gain,    // loop parameter that compensates for motor back emf
              float Ff2gain)    // loop parameter that compensates for acceleration lag
{
    // set up all our tuning parameters and motion limits
    period_ns = Period_ns;
    enable = Enable;
    deadband = Deadband;
    pgain = Pgain;
    dgain =Dgain;
    ff1gain = Ff1gain;
    ff2gain = Ff2gain;

    
    // calc internal variables
    period_sec = period_ns * 1e-9f;        // usually .001 sec   
}                  

// Call repeatedly to calc a new motor drive value for selected servo
// typically every 1ms.
// Returns afloat representing the motor drive required.
// -100.0 <= drive <= +100.0
// Note: due to static vars used to hold data between calls, this function
// is NOT thread safe.
//
float POSNSERVO::calcPID(int actual_posn, int cmd_posn)
{
    float tmp1;
    float max_i;
    float error_d;  // derivative term
    float cmd_d;    // cycle by cycle delta posncmd = commanded velocity
    float cmd_dd;   // cycle by cycle delta velocity = commanded accel

    // calculate the error
    errcnts = cmd_posn - actual_posn;   // posn err in encoder cnts

    // apply the deadband
    if (errcnts > deadband)
        errcnts -= deadband;
    else if (errcnts < -deadband)
            errcnts += deadband;
    else
        errcnts = 0;

    tmp1 = (float)errcnts;              // position error in fp counts

    // do integrator calcs only if enabled
    if ((igain > 0) && (enable != 0))
    {
        // update integral term
        error_i += tmp1 * period_sec; // scale so it builds slowly (integer igain can be higher)

        // apply a fixed integrator limit of 25% drive(could be made tunable)
        max_i = 25.0f / igain;
        if (error_i > max_i)
            error_i = max_i;
        else if (error_i < -max_i)
            error_i = -max_i;
    }
    else
    {
        // not enabled, reset integrator
        error_i = 0.0f;
    }

    /* calculate derivative term */
    error_d = (tmp1 - prev_error);
    prev_error = tmp1;

    /* calculate derivative of commanded posn = velocity ( used with ff1 tuning param ) */
    cmd_d = (float)(cmd_posn - prev_cmd);
    prev_cmd = cmd_posn;

    /* calculate derivative of velocity = accel (used with ff2 tuning param) */
    cmd_dd = cmd_d - prev_cmd_d;
    prev_cmd_d = cmd_d;

    // calculate the output value by summing drive components
    // because gain components are ints, not fp, 
    // we use some scaling to improve tuning ease
    tmp1 =  (pgain  * tmp1) / 1000.0f;     // position error   component
    tmp1 += (igain  * error_i) / 1000.0f;              // integral error   component
    tmp1 += (dgain  * error_d) / 1000.0f;     // differential     component
    tmp1 += (ff1gain * cmd_d)/ 1000.0f;     // velocity feedfwd component
    tmp1 += (ff2gain * cmd_dd) / 1000.0f;     // accel    feedfwd component

    drive = tmp1;

    // limit drive to max on time of pwm waveform
    if (drive > 1.0f)
        drive = 1.0f;
    else if (drive < -1.0f)
        drive = -1.0f;

    if (enable)
        return(drive);  //  return drive;
    else
        return(0.0f);   // shut off drive for disabled axis
}

// all the get functions for the parameters
float POSNSERVO::getPeriod_ns()
{
    return period_ns;   
}

int   POSNSERVO::getEnable(void)
{
    return enable;   
}
int   POSNSERVO::getDeadband(void)
{
    return deadband;   
}
float POSNSERVO::getPgain(void)
{
    return pgain;   
}
float POSNSERVO::getIgain(void)
{
    return igain;   
}
float POSNSERVO::getDgain(void)
{
    return dgain;   
}
float POSNSERVO::getFF1gain(void)
{
    return ff1gain;   
}
float POSNSERVO::getFF2gain(void)
{
    return ff2gain;   
}
float POSNSERVO::getDrive(void)
{
    return drive;
}

int POSNSERVO::getPosnErr(void)
{
    return errcnts;   
}    
// all the parameter set functions
void POSNSERVO::setPeriod_ns(float ns)
{
    period_ns = ns;
    period_sec = period_ns * 1e-9f;
}

void POSNSERVO::setEnable(int Enable)
{
    enable = Enable;
} 
   
void POSNSERVO::setDeadband(int db)
{
    deadband = db;    
} 
   
void POSNSERVO::setPgain(float Pgain)
{
    pgain = Pgain;    
} 
   
void POSNSERVO::setIgain(float Igain)
{
    igain = Igain;        
} 
   
void POSNSERVO::setDgain(float Dgain)
{
    dgain = Dgain;    
}
    
void POSNSERVO::setFF1gain(float Ff1gain)
{
    ff1gain = Ff1gain;
} 
   
void POSNSERVO::setFF2gain(float Ff2gain)
{
    ff2gain = Ff2gain;
}    

