#include "mbed.h"
#include "IOE2015.h"
#include "IOE2015_extrn.h"


// Remote Control digital inputs
DigitalIn Xaxis_pin(PA_5);         // Xaxis button 0=ON
DigitalIn Yaxis_pin(PA_4);         // Yaxis button 0=ON
DigitalIn Zaxis_pin(PB_12);        // Zaxis button 0=ON
DigitalIn RemoteOn_pin(PA_7);      // Remote On/Off button 0=ON

// Analog Input
AnalogIn ain6(PA_6);               // Remote control analog input



//**********************************************************
// Turn remote control ON/OFF
// Assumes motiion is stopped
//**********************************************************
void CheckRemote() {

    if(RemoteOn_pin==PRESSED) remote_sw=ON;  // remote switch on
    else remote_sw=OFF;                      // remote switch off
        

    if((remote_dis==0)&&(motion==OFF)) { // if remote enabled and motion off
                               
        if((remote_sw==ON) && (remote_mode==OFF)) {
            remote_mode=ON;            // turn on remode mode
            StartRemote();             // start remote mode                
        }
        if((remote_sw==OFF) && (remote_mode==ON)) {
            remote_mode=OFF;            // turn off remode mode
            StopRemote();               // stop remote mode                
        }   
    }
}

//**********************************************************
// Start remote control 
//**********************************************************
void StartRemote() {

    TPosition.attach_us(&NewRemote, REMOTE_TIMER);  // remote sample timer  
    
}

//**********************************************************
// Stop remote control 
//**********************************************************
void StopRemote() {       

        remote_mode=OFF;                    // turn off remode mode        
        TPosition.detach();                 // turn off remote timer
        TStep1.detach();                    // disable interrupt
        TStep2.detach();                    // disable interrupt 
        TStep3.detach();                    // disable interrupt
        TStep4.detach();                    // disable interrupt 
        TStep5.detach();                    // disable interrupt      
} 

//**********************************************************
// New Remote values
//**********************************************************
void NewRemote() {
uint16_t speed;
uint32_t x;                               


       speed=ain6.read_u16()>>4;              // right justify
       PCount1=speed-2048;
       
        if(PCount1<0){
            Dir1=NEG;                           // set direction negative
            Dir2=NEG;
            Dir3=NEG;
            Dir4=NEG;
            Dir5=NEG;
        }
        else {
            Dir1=POS;                           // set direction positive
            Dir2=POS;
            Dir3=POS;
            Dir4=POS;
            Dir5=POS;
        }
        
        PCount1=abs(PCount1);                   // Make Path position positive, scale max
        if(PCount1>2048) PCount1=2048;          // clamp high
        PCount2=PCount1*Y_SCALE;                // scale counts
        PCount3=PCount1*Z_SCALE;                // scale counts
        PCount1=PCount1*X_SCALE;                // scale counts
               

        if(Xaxis_pin==PRESSED) {                 // Xasis pressed    
                                
            if(PCount1<=X_DEADBAND) {
                TStep1.detach();                 // path is 0, disable interrupt
                TStep4.detach();                 // image system
            }       
            else {
                PCount1-=X_DEADBAND;
                if(PCount1<=0) PCount1=0;

                PCount4=PCount1;                    // image system                                    
                x=(REMOTE_TIMER-50)/PCount1;        // calculate time spacing between positions                     
                TStep1.attach_us(&Step1, x);        // set smoothing time interval
                TStep4.attach_us(&Step4, (x-50));   // image system
            }    
        } //end Xaxis

        if(Yaxis_pin==PRESSED) {                    // Xasis pressed

            if(PCount2<=Y_DEADBAND){
                TStep2.detach();                    // path is 0, disable interrupt
                TStep5.detach();                    // image system
            }       
            else {
                PCount2-=Y_DEADBAND;
                if(PCount2<=0) PCount2=0;

                PCount5=PCount2;                    // image system                 
                x=(REMOTE_TIMER-50)/PCount2;        // calculate time spacing between positions                  
                TStep2.attach_us(&Step2, x);        // set smoothing time interval
                TStep5.attach_us(&Step5, (x-50));   // image system
            }    
        } //end Yaxis

        if(Zaxis_pin==PRESSED) {                    // Xasis pressed

            if(PCount3<=Z_DEADBAND)
                TStep3.detach();                    // path is 0, disable interrupt       
            else {
                PCount3-=Z_DEADBAND;
                if(PCount3<=0) PCount3=0;
                
                x=(REMOTE_TIMER-50)/PCount3;        // calculate time spacing between positions                      
                TStep3.attach_us(&Step3, x);        // set smoothing time interval
            }    
        } //end Zaxis
                  
}

             
