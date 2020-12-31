#include "stm32f7xx_hal.h"
#include "tim.h"
#include "math.h"
#include "mcu16.h"
#include "mcu16_extrn.h"


// **********************************************************
// Initialize Mode
// **********************************************************
void InitMode() {

  remote_mode=OFF;      // turn off remote mode
  jog_mode=OFF;         // turn off jog mode
  motion=OFF;           // turn off motion
  remote_dis=OFF;       // enable remote
}
// **********************************************************
// Start motor motion
// **********************************************************
void StartMotion() {

  if(remote_mode==ON)
        status_byte|=0x08;                // error - cannot start motion in remote mode
    else { 
        jog_mode=0;                       // turn off jog mode
        motion=ON;

        HAL_TIM_Base_Stop_IT(&htim9); 
        TIM9->CNT=0;                      // clear timer
        TIM9->ARR=PathTimer;              // initialize path interrupt rate                           
        HAL_TIM_Base_Start_IT(&htim9);    // start channel 9 interrupt
                                          // 60Hz timer, 16,666 usec                                                                                                                     
    }  
}

// **********************************************************
// Stop motor motion abruptly
// **********************************************************
void StopMotion() {
    jog_mode=0;
    HAL_TIM_Base_Stop_IT(&htim9);       // stop channel 9 interrupt
    motion=OFF;   
}

// **********************************************************
// Stop motor motion smoothly
// **********************************************************
void StopMotionSmoothly() {
    jog_mode=0;
    HAL_TIM_Base_Stop_IT(&htim9);       // stop channel 9 interrupt
}

// **********************************************************
// Start Jog Mode
// **********************************************************
void StartJogMode() {                   // Start Jog Mode
    InitPathBuf();                      // clear path buffer
           
    jog_mode=1;                         // turn on jog mode
    motion=ON; 
     
    HAL_TIM_Base_Stop_IT(&htim9);
    TIM9->CNT=0;                        // clear timer
    TIM9->ARR=PathTimer;                // initialize path interrupt rate                           
    HAL_TIM_Base_Start_IT(&htim9);      // start channel 9 interrupt
                                        // 60Hz timer, 16,666 usec      
}

// **********************************************************
// Stop Jog Mode
// **********************************************************
void StopJogMode() {                    // Stop Jog Mode
    jog_mode=0;                         // turn off jog mode
    motion=OFF;   
    HAL_TIM_Base_Stop_IT(&htim9);       // stop channel 9 interrupt
    InitPathBuf();                      // clear path buffer  
}


