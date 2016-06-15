#include "stm32f7xx_hal.h"
#include "mcu16.h"
#include "mcu16_extrn.h"



// *******************************************************
// configure GPIO ports
// *******************************************************

void InitGPIO() { 
 
    AddrOut(1);                         // initialize address out pin

    HAL_GPIO_WritePin(MTR1_EN_o_GPIO_Port,MTR1_EN_o_Pin,1);  // enable motor 1
    HAL_GPIO_WritePin(MTR2_EN_o_GPIO_Port,MTR2_EN_o_Pin,1);  // enable motor 2
    HAL_GPIO_WritePin(MTR3_EN_o_GPIO_Port,MTR3_EN_o_Pin,1);  // enable motor 3
    HAL_GPIO_WritePin(IMAGE_EN_o_GPIO_Port,IMAGE_EN_o_Pin,1); // enable image system


    EnableMotors(0x00);                  // enable motors and image system 
    
              
}



// **********************************************************
// get servo fault status
// **********************************************************
uint8_t GetFault(void) {
uint8_t status;

    status=0;                                   // get motor fault, 1=fault
    if(HAL_GPIO_ReadPin(MTR1_FLT_i_GPIO_Port,MTR1_FLT_i_Pin)) status|=0x01;
    if(HAL_GPIO_ReadPin(MTR2_FLT_i_GPIO_Port,MTR2_FLT_i_Pin)) status|=0x02;
    if(HAL_GPIO_ReadPin(MTR3_FLT_i_GPIO_Port,MTR3_FLT_i_Pin)) status|=0x04;

    if(HAL_GPIO_ReadPin(ESTOP_i_GPIO_Port,ESTOP_i_Pin)) status|=0x08;   // Check emergency stop
    
    if(status)                                  // latch servo flault flag
        servo_flt_flg=1;
              
       
    return(status);
}



// **********************************************************
// Disable / Enable servo 1, 2, 3 and Image system
// **********************************************************
void EnableMotors(uint8_t iset) {

    if(iset & 0x10)
        HAL_GPIO_WritePin(MTR1_EN_o_GPIO_Port,MTR1_EN_o_Pin,0);   // disable motor 1 
    else
        HAL_GPIO_WritePin(MTR1_EN_o_GPIO_Port,MTR1_EN_o_Pin,1);   // enable motor 1 
        
     if(iset & 0x10)
        HAL_GPIO_WritePin(MTR2_EN_o_GPIO_Port,MTR2_EN_o_Pin,0);   // disable motor 2        
    else
        HAL_GPIO_WritePin(MTR2_EN_o_GPIO_Port,MTR2_EN_o_Pin,1);   // enable motor 2      
        
     if(iset & 0x10)
        HAL_GPIO_WritePin(MTR3_EN_o_GPIO_Port,MTR3_EN_o_Pin,0);   // disable motor 3   
    else
        HAL_GPIO_WritePin(MTR3_EN_o_GPIO_Port,MTR3_EN_o_Pin,1);   // enable motor 3      

     if(iset & 0x80)
        HAL_GPIO_WritePin(IMAGE_EN_o_GPIO_Port,IMAGE_EN_o_Pin,0);   // disable image system       
    else
        HAL_GPIO_WritePin(IMAGE_EN_o_GPIO_Port,IMAGE_EN_o_Pin,1);   // enable image system       
       
}


// **********************************************************
// read address in 
// **********************************************************
uint8_t AddrIn(void) {
    return(HAL_GPIO_ReadPin(ADDR_i_GPIO_Port,ADDR_i_Pin));  // read address input
}

// **********************************************************
// set address out
// **********************************************************
void AddrOut(uint8_t i) {
    HAL_GPIO_WritePin(ADDR_o_GPIO_Port,ADDR_o_Pin,i);  // set address out
}