#include "mbed.h"
#include "QEI.h"
#include "posnservo.h"
#include "SMP.h"

#define INTERVAL (0.001f)    // servo cycle time in seconds

// create all the components we need for servo demo
Serial      pc(USBTX, USBRX);   // serial port to PC for status/cmds  //mbed serial command
PwmOut      MotorDrive(D3);     // pwm signal to drive servo motor
Ticker      OnemsTimer;           // 1ms ticker for servo loop calcs

DigitalOut myled(LED1);
DigitalOut MotorDirection(A5);  // direction control bit for motor
DigitalOut MotorLimit(A4);      // indicates motor at 90% drive or more
DigitalOut MotorFault(A3);      // indicate a servo loop fault (stall?)

            
SMP planner( INTERVAL / 1e-9f, // create the planner object
             -10000,
             +10000,
             100000.0,
             30000.0); 
                       
 volatile int TargetPosn = 2500;  
 
          
// function to service the 1ms ticks 
// this should be run at a low priority so encoder intr can interrupt it
void mstimer() 
{
    float RequiredDrive;
    
    MotorFault = 1;
    volatile int MotorEncoder = MotorQei.pulses_;
    
    RequiredDrive = calcPID(MotorEncoder,calcNewPosn(TargetPosn)); 
    if ( RequiredDrive >= 0.0f )
    {
        MotorDirection = 0;
        MotorDrive = RequiredDrive;
    }        
    else
    {
        MotorDirection = 1;
        MotorDrive = -RequiredDrive;
    }
    MotorFault = 0;
}

int main() 
{
    volatile int MotorEncoder =  0; 
    volatile int OffsetEncoder = 0; 
    POSNSERVO PS = { INTERVAL / 1e-9f, // Initialze struct.
              0,                // disabled
              0,                // deadband
              1.0,              // pgain
              0.0,              // igain
              0.0,              // dgain
              0.0,              // ff1gain
              0.0               // ff2gain
	}; 
    SMP = planner{INTERVAL / 1e-9f, // create the planner object
             -10000,
             +10000,
             100000.0,
			 30000.0
	}; 
                       	
	QEI MotorQei  = {D2, D4, NC, 500, X4_ENCODING}; // software encoder on motor
    QEI OffsetQei = {D7, D8, NC,  65, X4_ENCODING}; // software encoder on offset wheel
    // init the pwm drive to motor
    MotorDrive.period_us(333);  // 3khz should be high enough
    MotorDrive = 0.0;           // set pwm pin duty cycle
    MotorDirection = 0;
    MotorLimit = 0;             // init the status outputs
    MotorFault = 1;    float   period_ns;     // typical 1000000ns = 1ms
	
    PS.period_sec;
	
    PS.enable = 1; 
    PS.pgain = 5.0;	
	PS.igain = 0.0;
	PS.dgain = 10.0;
	
	
    pc.baud(9600);              // set up coms with pc via USB serial port
    pc.format(8,SerialBase::None,1);
    
    // Splash screen :}
    pc.printf("\r\n\nLGSERVO demo program\r\n");
             
    // attach our service routine to 1ms timer for servo calcs
    OnemsTimer.attach_us(&mstimer, INTERVAL / 1e-6f); 
   

    while(1)
    {
        pc.printf("\r\n");
        MotorEncoder = MotorQei.pulses_;
        OffsetEncoder = OffsetQei.pulses_;
        pc.printf("motor encoder = %d\r\n", MotorEncoder);
        pc.printf("offset encoder = %d\r\n", OffsetEncoder);
        pc.printf("position error = %d\r\n",PS.errcnts);
        pc.printf("drive = %f%c\r\n",PS.drive * 100.0f,'%');
        TargetPosn = -TargetPosn;
        wait(2.0); 
     }
}
