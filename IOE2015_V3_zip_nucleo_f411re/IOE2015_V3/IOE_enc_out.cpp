#include "mbed.h"
#include "IOE2015.h"
#include "IOE2015_extrn.h"

// Step and Direction output
DigitalOut Step1_Pin(PA_11);    // define step1 output pin
DigitalOut Dir1_Pin(PA_12);     // define dir1 output pin
DigitalOut Step2_Pin(PC_10);    // define step2 output pin
DigitalOut Dir2_Pin(PC_11);     // define dir2 output pin
DigitalOut Step3_Pin(PC_12);    // define step3 output pin
DigitalOut Dir3_Pin(PD_2);      // define dir3 output pin
DigitalOut Step4_Pin(PB_0);     // define step4 output pin
DigitalOut Dir4_Pin(PB_1);      // define dir4 output pin
DigitalOut Step5_Pin(PB_14);    // define step5 output pin
DigitalOut Dir5_Pin(PB_15);     // define dir5 output pin

// Quadrature output
DigitalOut Quad1A_Pin(PA_11);    // define Quad1 A output pin
DigitalOut Quad1B_Pin(PA_12);    // define Quad1 B output pin
DigitalOut Quad2A_Pin(PC_10);    // define Quad2 A output pin
DigitalOut Quad2B_Pin(PC_11);    // define Quad2 B output pin
DigitalOut Quad3A_Pin(PC_12);    // define Quad3 A output pin
DigitalOut Quad3B_Pin(PD_2);     // define Quad3 B output pin
DigitalOut Quad4A_Pin(PB_0);     // define Quad4 A output pin
DigitalOut Quad4B_Pin(PB_1);     // define Quad4 B output pin
DigitalOut Quad5A_Pin(PB_14);    // define Quad5 A output pin
DigitalOut Quad5B_Pin(PB_15);    // define Quad5 B output pin


// Step and Direction pulse output routines
//**********************************************************
// Initialize encoder outputs to reset state
void InitEncoderOutputs() {     

    Dir1=0;                     // Direction 1
    Dir2=0;                     // Direction 2
    Dir3=0;                     // Direction 3
    Dir4=0;                     // Direction 4
    Dir5=0;                     // Direction 5


    quad_out=QUAD_OUT;            //1=quar out, 0=step / dir

    if(quad_out==0) {
        Step1_Pin=1;                // reset step1 output pin
        Dir1_Pin=0;                 // reset dir1 output pin
        Step2_Pin=1;                // reset step2 output pin
        Dir2_Pin=0;                 // reset dir2 output pin
        Step3_Pin=1;                // reset step3 output pin
        Dir3_Pin=0;                 // reset dir3 output pin
        Step4_Pin=1;                // reset step4 output pin
        Dir4_Pin=0;                 // reset dir4 output pin
        Step5_Pin=1;                // reset step5 output pin
        Dir5_Pin=0;                 // reset dir5 output pin    
    }   
// Quadrature output


    if(quad_out==1) {
        Quad1A_Pin=0;               // reset Quad1 A output pin
        Quad1B_Pin=0;               // reset Quad1 B output pin
        Quad2A_Pin=0;               // reset Quad2 A output pin
        Quad2B_Pin=0;               // reset Quad2 B output pin
        Quad3A_Pin=0;               // reset Quad3 A output pin
        Quad3B_Pin=0;               // reset Quad3 B output pin 
        Quad4A_Pin=0;               // reset Quad4 A output pin
        Quad4B_Pin=0;               // reset Quad4 B output pin
        Quad5A_Pin=0;               // reset Quad5 A output pin
        Quad5B_Pin=0;               // reset Quad5 B output pin
    } 
 
}


//**********************************************************
// Start motor motion
void StartMotion() {

  if(remote_mode==ON)
        status_byte|=0x08;              // error - cannot start motion in remote mode
    else { 
        jog_mode=0;                     // turn off jog mode
        motion=ON;
        StepTimer=STEP_TIMER;
        PathTimer=PATH_TIMER;                                                                                                              
        TPosition.attach_us(&NewPosition, PathTimer);  // start path timer
    }  
}

//**********************************************************
// Stop motor motion abruptly
void StopMotion() {
    jog_mode=0;
    TPosition.detach();                                  // turn off 60HZ timer
    motion=OFF;   
}

//**********************************************************
// Stop motor motion smoothly
void StopMotionSmoothly() {
    jog_mode=0;
    TPosition.detach();                                 // turn off 60HZ timer
}

//**********************************************************
// Start Jog Mode
void StartJogMode() {                                   // Start Jog Mode
    jog_mode=1;                                         // turn on jog mode
    motion=ON; 
    InitPathBuf();                                      // clear path buffer       
    StepTimer=STEP_TIMER;
    PathTimer=PATH_TIMER; 
    TPosition.attach_us(&NewPosition, PathTimer);      // 60Hz timer, 16,666 usec    
}

//**********************************************************
// Stop Jog Mode
void StopJogMode() {                                    // Stop Jog Mode
    jog_mode=0;                                         // turn off jog mode
    motion=OFF;   
    TPosition.detach();                                 // turn off 60HZ timer
    InitPathBuf();                                      // clear path buffer  
}



//**********************************************************
// Start new path position
void NewPosition() {    
uint32_t x;

    if(DataInPathBuf) {                                 // check for data in buffer

//        PositionTimer=POSITION_TIMER;        
//        TPosition.attach_us(&NewPosition, PATH_TIMER);  // 60Hz timer, 16,666 usec       

        if(DataInPathBuf==1) {                          // last path position
            last_path_flg=1;
            if(jog_mode==0) {                           // if Jog Mode OFF
                motion=OFF;            
                TPosition.detach();                     // turn off 60HZ timer
            }      
        } //end if
        
// Get next path position
        ReadPathData();                         // get next path positions       
        PathsExecuted++;                        // increment total number of paths executed
        
        if(PathOut[0]>=0xFFF0)                  // Path Command
            DecodePathCmd();                     // decode command

        else {                                  // execute path                   
            PCount1=PathOut[0];                     
            PCount2=PathOut[1];
            PCount3=PathOut[2];
            PCount4=PathOut[3];
            PCount5=PathOut[4];                                                                        
               
// Set interrupt smoothing interval for channel 1                                                                                                                              
            if(PCount1<0) Dir1=NEG;                 // set direction negative
            else Dir1=POS;                          // set direction positive

            PCount1=abs(PCount1);                   // Make Path position positive
        
            if(PCount1==0) 
                TStep1.detach();         // path is 0, disable interrupt       
            else {
                x=StepTimer / PCount1;              // calculate time spacing between positions    
                TStep1.attach_us(&Step1, x);        // set smoothing time interval
            }                             

// Set interrupt smoothing interval for channel 2                                 
            if(PCount2<0) Dir2=NEG;                 // set direction negative
            else Dir2=POS;                          // set direction positive

            PCount2=abs(PCount2);                   // Make Path position positive
        
            if(PCount2==0)
                TStep2.detach();                        // path is 0, disable interrupt       
            else {
                x=StepTimer / PCount2;                  // calculate time spacing between positions       
                TStep2.attach_us(&Step2, x);            // set smoothing time interval
            }   

// Set interrupt smoothing interval for channel 3                                     
            if(PCount3<0) Dir3=NEG;                     // set direction negative
            else Dir3=POS;                              // set direction positive

            PCount3=abs(PCount3);                   // Make Path position positive
        
            if(PCount3==0)
                TStep3.detach();                    // path is 0, disable interrupt       
            else {
                x=StepTimer/PCount3;                // calculate time spacing between positions       
                TStep3.attach_us(&Step3, x);        // set smoothing time interval
            }

// Set interrupt smoothing interval for channel 4      
            if(PCount4<0) Dir4=NEG;                 // set direction negative
            else  Dir4=POS;                         // set direction positive

            PCount4=abs(PCount4);                   // Make Path position positive
        
            if(PCount4==0)
                TStep4.detach();                    // path is 0, disable interrupt       
            else {
                x=StepTimer/PCount4;                // calculate time spacing between positions       
                TStep4.attach_us(&Step4, x);        // set smoothing time interval
            }

// Set interrupt smoothing interval for channel 5           
            if(PCount5<0) Dir5=NEG;                 // set direction negative
            else Dir5=POS;                          // set direction positive

            PCount5=abs(PCount5);                   // Make Path position positive
        
            if(PCount5==0)
                TStep5.detach();                    // path is 0, disable interrupt       
            else {
                x=StepTimer / PCount5;              // calculate time spacing between positions       
                TStep5.attach_us(&Step5, x);        // set smoothing time interval
            }
                        
        } //end else 
    } // end if DataInPathBuf
} // end 




//**********************************************************
// Quadrature, Step & Dir output #1
//**********************************************************
void Step1() { 
uint8_t cstate;

    if(quad_out) {
//  *******   Quadrature output        
        cstate=0;                               // get current state of quad output
        if(Quad1B_Pin) cstate=0x01;
        if(Quad1A_Pin) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir1==POS) Quad1A_Pin=1;         // new state 10
            else Quad1B_Pin=1;                  // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir1==POS) Quad1B_Pin=0;         // new state 00
            else Quad1A_Pin=1;                  // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir1==POS) Quad1B_Pin=1;         // new state 11
            else Quad1A_Pin=0;                  // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir1==POS) Quad1A_Pin=0;         // new state 01
            else Quad1B_Pin=0;                  // new state 10  
            break;                       
        } //end switch                                                                       
    } //end quad out
    
    else {
// *******     Step & direction output                                                 
                                                // set direction pin
    if(Dir1==0)
        Dir1_Pin=0;                             // dirrection = positive     
    else 
        Dir1_Pin=1;                             // dirrection = negative 
                                         
        Step1_Pin=0;
        Step1_Pin=0;                            // increse pulse width by one instruction
//        wait_us(0.5);                         // pulse width = 0.5 usec                                                       
        Step1_Pin=1;                            // send step pulse 

    } // end step & direction
 
    if(Dir1==POS) ++stest1;                   // update internal counter        
    else --stest1;                                                                     
           
    --PCount1;                              // decrement path position counter
        
    if(PCount1==0)
        TStep1.detach();                    // path is 0, disable interrupt              
}  

//**********************************************************
// Quadrature, Step & Dir output #2
//**********************************************************
void Step2() {
uint8_t cstate;

    if(quad_out) {
//  *******   Quadrature output   
        cstate=0;                               // get current state of quad output
        if(Quad2B_Pin) cstate=0x01;
        if(Quad2A_Pin) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir2==POS) Quad2A_Pin=1;         // new state 10
            else Quad2B_Pin=1;                  // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir2==POS) Quad2B_Pin=0;         // new state 00
            else Quad2A_Pin=1;                  // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir2==POS) Quad2B_Pin=1;         // new state 11
            else Quad2A_Pin=0;                  // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir2==POS) Quad2A_Pin=0;         // new state 01
            else Quad2B_Pin=0;                  // new state 10  
            break;                       
        } //end switch                                                   
     } // end quad out              

    else {
// *******     Step & direction output 
    if(Dir2==0)
        Dir2_Pin=0;                             // dirrection = positive     
    else
        Dir2_Pin=1;                             // dirrection = negative                                   
 
        Step2_Pin=0;
        Step2_Pin=0;                            // increse pulse width by one instruction
//        wait_us(0.5);                         // pulse width = 0.5 usec                                                       
        Step2_Pin=1;                            // send step pulse 
    } // end step & direction

    if(Dir2==POS) ++stest2;                   // update internal counter        
    else --stest2;
    
    --PCount2;                              // decrement path position counter
        
    if(PCount2==0)
        TStep2.detach();                    // path is 0, disable interrupt  

} 


//**********************************************************
// Quadrature, Step & Dir output #3
//**********************************************************
void Step3() {
uint8_t cstate;

    if(quad_out) {
//  *******   Quadrature output                       
        cstate=0;                               // get current state of quad output
        if(Quad3B_Pin) cstate=0x01;
        if(Quad3A_Pin) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir3==POS) Quad3A_Pin=1;         // new state 10
            else Quad3B_Pin=1;                  // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir3==POS) Quad3B_Pin=0;         // new state 00
            else Quad3A_Pin=1;                  // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir3==POS) Quad3B_Pin=1;         // new state 11
            else Quad3A_Pin=0;                  // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir3==POS) Quad3A_Pin=0;         // new state 01
            else Quad3B_Pin=0;                  // new state 10  
            break;                       
        } //end switch                                               
    } // end quad out
             
    else {
// *******     Step & direction output 
    if(Dir3==0)
        Dir3_Pin=0;                             // dirrection = positive
    else 
        Dir3_Pin=1;                             // dirrection = negative
    
        Step3_Pin=0;
        Step3_Pin=0;                            // increse pulse width by one instruction
//        wait_us(0.5);                         // pulse width = 0.5 usec                                                       
        Step3_Pin=1;                            // send step pulse  
    }
    
// ********* // end step & direction
  
    if(Dir3==POS) ++stest3;                   // update internal counter        
    else --stest3;        
             
    --PCount3;                              // decrement path position counter
        
    if(PCount3==0)
        TStep3.detach();                    // path is 0, disable interrupt  

} 


//**********************************************************
// Quardrature / Step & Direction output #4
//**********************************************************
void Step4() {
uint8_t cstate;

    if(image_count_dis==0) {                    // sent pulse if image system counts enabled

    if(quad_out) {
        
//  *******   Quadrature output

        cstate=0;                               // get current state of quad output
        if(Quad4B_Pin) cstate=0x01;
        if(Quad4A_Pin) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir4==POS) Quad4A_Pin=1;         // new state 10
            else Quad4B_Pin=1;                  // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir4==POS) Quad4B_Pin=0;         // new state 00
            else Quad4A_Pin=1;                  // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir4==POS) Quad4B_Pin=1;         // new state 11
            else Quad4A_Pin=0;                  // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir4==POS) Quad4A_Pin=0;         // new state 01
            else Quad4B_Pin=0;                  // new state 10  
            break;                       
        } //end switch                                                  
     } // end quad out


    else {
// *******     Step & direction output    
        if(Dir4==0)
            Dir4_Pin=0;                             // direction = positive
        else 
            Dir4_Pin=1;                             // direction = negative
                                   
  
        Step4_Pin=0;
//        Step4_Pin=0;                            // increase pulse width by one instruction
        wait_us(0.5);                             // pulse width = 0.5 usec                                                        
        Step4_Pin=1;                            // send step pulse 
 
        }
     } // ********* end Qadrature and Step output
 
    if(Dir4==POS) ++stest4;                   // update internal counter        
    else --stest4;     
    
    --PCount4;                              // decrement path position counter
        
    if(PCount4==0)
        TStep4.detach();                    // path is 0, disable interrupt  

}


//**********************************************************
// Quardrature / Step & Direction output #5
//**********************************************************
void Step5() {                                    
uint8_t cstate;

    if(image_count_dis==0) {                    // sent pulse if image system counts enabled

     if(quad_out) {
        
//  *******   Quadrature output
        cstate=0;                               // get current state of quad output
        if(Quad5B_Pin) cstate=0x01;
        if(Quad5A_Pin) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir5==POS) Quad5A_Pin=1;         // new state 10
            else Quad5B_Pin=1;                  // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir5==POS) Quad5B_Pin=0;         // new state 00
            else Quad5A_Pin=1;                  // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir5==POS) Quad5B_Pin=1;         // new state 11
            else Quad5A_Pin=0;                  // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir5==POS) Quad5A_Pin=0;         // new state 01
            else Quad5B_Pin=0;                  // new state 10  
            break;                       
        } //end switch 
    }


    else {
// *******     Step & direction output    
        if(Dir5==0)
            Dir5_Pin=0;                             // direction = positive
        else
            Dir5_Pin=1;                             // direction = negative
  
        Step5_Pin=0;
//        Step5_Pin=0;                              // increase pulse width by one instruction
        wait_us(0.5);                               // pulse width = 0.5 usec                                                        
        Step5_Pin=1;                                // send step pulse 
 
        }
    } // ********* end Qadrature and Step output

        if(Dir5==0) ++stest5;                   // update internal counter        
        else --stest5;  
            
        --PCount5;                              // decrement path position counter
        
        if(PCount5==0)
            TStep5.detach();                    // path is 0, disable interrupt  
}


//**********************************************************
// Send counts to Servo system channel 1
// Assumes motiion is stopped
//**********************************************************
void SendCount1(int16_t counts) {
uint32_t x;   

        PCount1=counts;
            
        if(PCount1<0) 
            Dir1=1;                             // dirrection = negative
        else
            Dir1=0;                             // dirrection = positive

        PCount1=abs(PCount1);                   // Make Path position positive
        
        x=(SEND_COUNTS-1000)/PCount1;           // calculate time spacing between positions                     
        TStep1.attach_us(&Step1, x);            // set smoothing time interval
                  
} 

//**********************************************************
// Send counts to Servo system channel 2
// Assumes motiion is stopped
//**********************************************************
void SendCount2(int16_t counts) {
uint32_t x;   

        PCount2=counts;
            
        if(PCount2<0) 
            Dir2=1;                             // dirrection = negative
        else
            Dir2=0;                             // dirrection = positive

        PCount2=abs(PCount2);                   // Make Path position positive
        
        x=(SEND_COUNTS-1000)/PCount2;           // calculate time spacing between positions                     
        TStep2.attach_us(&Step2, x);            // set smoothing time interval                   
} 

//**********************************************************
// Send counts to Servo system channel 3
// Assumes motiion is stopped
//**********************************************************
void SendCount3(int16_t counts) {
uint32_t x;   

        PCount3=counts;
            
        if(PCount3<0) 
            Dir3=1;                             // dirrection = negative
        else
            Dir3=0;                             // dirrection = positive

        PCount3=abs(PCount3);                   // Make Path position positive
        
        x=(SEND_COUNTS-1000)/PCount3;           // calculate time spacing between positions                     
        TStep3.attach_us(&Step3, x);            // set smoothing time interval                   
} 


//**********************************************************
// Send counts to image system channel 4
// Assumes motiion is stopped
//**********************************************************
void SendCount4(int16_t counts) {
uint32_t x;   

        PCount4=counts;
            
        if(PCount4<0) 
            Dir2=1;                             // dirrection = negative
        else
            Dir2=0;                             // dirrection = positive

        PCount4=abs(PCount4);                   // Make Path position positive
        
        x=(SEND_COUNTS-1000)/PCount4;           // calculate time spacing between positions                     
        TStep4.attach_us(&Step4, x);            // set smoothing time interval                   
} 


//**********************************************************
// Send counts to image system channel 5
// Assumes motiion is stopped
//**********************************************************
void SendCount5(int16_t counts) {
uint32_t x;   

        PCount4=counts;
            
        if(PCount4<0) 
            Dir2=1;                             // dirrection = negative
        else
            Dir2=0;                             // dirrection = positive

        PCount4=abs(PCount4);                   // Make Path position positive
        
        x=(SEND_COUNTS-1000)/PCount4;           // calculate time spacing between positions                     
        TStep4.attach_us(&Step4, x);            // set smoothing time interval                   
} 

//**********************************************************
// Decode Path related commands
// commands in path buffer, Xaxis
//**********************************************************
void DecodePathCmd() {
        switch(PathOut[0]) {
        case 0xFFF0:    // speed control
        
        
        break;
        case 0xFFF1:    // unused
        
        break;        
        }  //end switch
}
