#include "stm32f7xx_hal.h"
#include "tim.h"
#include "math.h"
#include "mcu16.h"
#include "mcu16_extrn.h"

// **********************************************************
// Initialize Path buffer to reset
// **********************************************************

void InitPathBuf() {

    StopMotion();                   // Stop motor motion
    
    PointerOut=0;                   // initialize output pointer
    PointerIn=0;                    // initialize input pointer
    DataInPathBuf=0;                // number of paths in buffer
    SpaceAvailable=BUFFER_SIZE;     // buffer space available 
    StepTimer=STEP_TIMER;           // 60Hz step timer, adds hold time
    PathTimer=PATH_TIMER;           // 60Hz path timer 
    
    PathsExecuted=0;                // total number of paths executed
    PathsPlusBuf=0;                 // total number of paths executed plus paths in buffer
}

// ***********************************************************
// Timer callback
// interrupt routine for Channel 1 Quad, Step/Dir output
// interrupt routine for new path position
// ***********************************************************

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {

  if(htim->Instance==TIM9) {
    if(remote_mode==ON)
       NewRemote();                       // new remote control position interrupt
    else
       NewPosition();                      // new path position interrupt
}

  if(htim->Instance==TIM10)
      QuadStep1();                        // output channel 1

  if(htim->Instance==TIM11)
      QuadStep2();                        // output channel 2

  if(htim->Instance==TIM12)
      QuadStep3();                        // output channel 3

  if(htim->Instance==TIM13)
      QuadStep4();                        // output channel 4

  if(htim->Instance==TIM14)
      QuadStep5();                        // output channel 5

}


// **********************************************************
// Write data to all 5 path encoder buffers
// **********************************************************

void WritePathData(){

    ++PointerIn;                        // increment data in pointer

    if(PointerIn==BUFFER_SIZE-1)
        PointerIn=0;                    // roll over pointer

    ++DataInPathBuf;                    // increment path counter   
    if(PointerIn==PointerOut)
        path_error=1;
    else {
        (PathBuffer1[PointerIn])=PathIn[0];
        (PathBuffer2[PointerIn])=PathIn[1];
        (PathBuffer3[PointerIn])=PathIn[2];
        (PathBuffer4[PointerIn])=PathIn[3];
        (PathBuffer5[PointerIn])=PathIn[4];
        path_error=0;
    }
}    

// **********************************************************    
// Read path data for all 5 encoder output buffers
// **********************************************************
   
void ReadPathData() {
  
    if(DataInPathBuf==0)
        status_byte|=0x02;                      //  Tried to read from empty Buffer, data lost
    else {
        ++PointerOut;                           // increment data out pointer
        --DataInPathBuf;                        // decrement path counter

        if(PointerOut==BUFFER_SIZE-1)
            PointerOut=0;                       // roll over pointer
        
        PathOut[0]=(PathBuffer1[PointerOut]);
        PathOut[1]=(PathBuffer2[PointerOut]);
        PathOut[2]=(PathBuffer3[PointerOut]);
        PathOut[3]=(PathBuffer4[PointerOut]);
        PathOut[4]=(PathBuffer5[PointerOut]);
                
    }
}

// **********************************************************
// return buffer space available
// 0 = path buffer is empty
// **********************************************************

int16_t PathSpaceAvail() {
    return(BUFFER_SIZE-DataInPathBuf);
}


// **********************************************************
// Start new path position
// **********************************************************
void NewPosition() {    
uint32_t x;


    if(DataInPathBuf) {                             // check for data in buffer

        if(DataInPathBuf==1) {                      // last path position
            last_path_flg=1;
            if(jog_mode==0) {                       // if Jog Mode OFF
                motion=OFF;            
                HAL_TIM_Base_Stop_IT(&htim9);       // stop channel 9 interrupt
            }      
        } //end if
        
// Get next path position
        ReadPathData();                             // get next path positions       
        PathsExecuted++;                            // increment total number of paths executed
        
                 
        PCount1=PathOut[0];                     
        PCount2=PathOut[1];
        PCount3=PathOut[2];
        PCount4=PathOut[3];
        PCount5=PathOut[4];                                                                        
               
// Set interrupt smoothing interval for channel 1                                                                                                                              
        if(PCount1<0) Dir1=NEG;                     // set direction negative
          else Dir1=POS;                            // set direction positive

        PCount1=abs(PCount1);                       // Make Path position positive
        
        if(PCount1==0) 
                HAL_TIM_Base_Stop_IT(&htim10);      // stop channel 1 interrupt      
        else {
                x=StepTimer / PCount1;              // calculate time spacing between positions
                TIM10->CNT=0;                       // clear timer
                TIM10->ARR=x;                       // initialize path interrupt rate                           
                HAL_TIM_Base_Start_IT(&htim10);     // start channel 1 interrupt                   
        }                             

// Set interrupt smoothing interval for channel 2                                 
        if(PCount2<0) Dir2=NEG;                     // set direction negative
        else Dir2=POS;                              // set direction positive

        PCount2=abs(PCount2);                       // Make Path position positive
          
        if(PCount2==0) 
                HAL_TIM_Base_Stop_IT(&htim11);      // stop channel 2 interrupt      
        else {
                x=StepTimer / PCount2;              // calculate time spacing between positions 
                TIM11->CNT=0;                       // clear timer
                TIM11->ARR=x;                       // initialize path interrupt rate                           
                HAL_TIM_Base_Start_IT(&htim11);     // start channel 2 interrupt                   
        }   

// Set interrupt smoothing interval for channel 3                                     
        if(PCount3<0) Dir3=NEG;                     // set direction negative
        else Dir3=POS;                              // set direction positive

        PCount3=abs(PCount3);                       // Make Path position positive
        
        if(PCount3==0) 
                HAL_TIM_Base_Stop_IT(&htim12);      // stop channel 3 interrupt      
        else {
                x=StepTimer / PCount3;              // calculate time spacing between positions 
                TIM12->ARR=x;                       // initialize path interrupt rate
                TIM12->CNT=0;                       // clear timer
                HAL_TIM_Base_Start_IT(&htim12);     // start channel 3 interrupt                   
        }  

// Set interrupt smoothing interval for channel 4      
        if(PCount4<0) Dir4=NEG;                     // set direction negative
        else  Dir4=POS;                             // set direction positive

        PCount4=abs(PCount4);                       // Make Path position positive
        
        if(PCount4==0) 
                HAL_TIM_Base_Stop_IT(&htim13);      // stop channel 4 interrupt      
        else {
                x=StepTimer / PCount4;              // calculate time spacing between positions 
                TIM13->ARR=x;                       // initialize path interrupt rate
                TIM13->CNT=0;                       // clear timer
                HAL_TIM_Base_Start_IT(&htim13);     // start channel 4 interrupt                   
        }  

// Set interrupt smoothing interval for channel 5           
        if(PCount5<0) Dir5=NEG;                     // set direction negative
        else Dir5=POS;                              // set direction positive

        PCount5=abs(PCount5);                       // Make Path position positive
        
        if(PCount5==0) 
                HAL_TIM_Base_Stop_IT(&htim14);      // stop channel 5 interrupt      
        else {
                x=StepTimer / PCount5;              // calculate time spacing between positions 
                TIM14->ARR=x;                       // initialize path interrupt rate 
                TIM14->CNT=0;                       // clear timer
                HAL_TIM_Base_Start_IT(&htim14);     // start channel 5 interrupt                   
        }  
            

    } // end if DataInPathBuf

} // end 

