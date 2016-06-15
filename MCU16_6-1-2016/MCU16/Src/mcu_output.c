
#include "stm32f7xx_hal.h"
#include "tim.h"
#include "math.h"
#include "mcu16.h"
#include "mcu16_extrn.h"


// **********************************************************
// Quadrature and Step and Direction output routines
// Initialize outputs to reset state
// **********************************************************

void InitOutputs() {     

    Dir1=0;                     // Direction 1
    Dir2=0;                     // Direction 2
    Dir3=0;                     // Direction 3
    Dir4=0;                     // Direction 4
    Dir5=0;                     // Direction 5


    HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,0);
    HAL_GPIO_WritePin(QUAD1B_o_GPIO_Port,QUAD1B_o_Pin,0);
    HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,0);
    HAL_GPIO_WritePin(QUAD2B_o_GPIO_Port,QUAD2B_o_Pin,0);
    HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,0);
    HAL_GPIO_WritePin(QUAD3B_o_GPIO_Port,QUAD3B_o_Pin,0);
    HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,0);
    HAL_GPIO_WritePin(QUAD4B_o_GPIO_Port,QUAD4B_o_Pin,0);
    HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,0);
    HAL_GPIO_WritePin(QUAD5B_o_GPIO_Port,QUAD5B_o_Pin,0);


    if(quad_out==0) {                                        // initialize for step and direction
      HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,1);  // initialize step = 1
      HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,1);  // initialize step = 1
      HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,1);  // initialize step = 1
      HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,1);  // initialize step = 1
      HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,1);  // initialize step = 1
    } 

}


// **********************************************************
// Quadrature, Step & Dir output #1
// **********************************************************
void QuadStep1() { 
uint8_t cstate;

    if(motor_count_dis) {                       // return if motor counts disabled
          PCount1==0;
          HAL_TIM_Base_Stop_IT(&htim10);        // disable interrupt
          return;   
    }

    if(quad_out) {

//  Quadrature output
     
        cstate=0;                               // get current state of quad output
        if(HAL_GPIO_ReadPin(QUAD1B_o_GPIO_Port,QUAD1B_o_Pin)) cstate=0x01;
        if(HAL_GPIO_ReadPin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin)) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir1==POS) HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,1);  // new state 10
            else HAL_GPIO_WritePin(QUAD1B_o_GPIO_Port,QUAD1B_o_Pin,1);           // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir1==POS) HAL_GPIO_WritePin(QUAD1B_o_GPIO_Port,QUAD1B_o_Pin,0);  // new state 00
            else HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,1);           // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir1==POS) HAL_GPIO_WritePin(QUAD1B_o_GPIO_Port,QUAD1B_o_Pin,1);  // new state 11
            else HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,0);           // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir1==POS) HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,0);  // new state 01
            else HAL_GPIO_WritePin(QUAD1B_o_GPIO_Port,QUAD1B_o_Pin,0);           // new state 10  
            break;                       
        } //end switch                                                                       
    } //end quad out

    
    else {

// Step & direction output 
// note: QUADxA = Step,   QUADxB = Dir                                               
                                                                  
                                                                // set direction pin
    if(Dir1==0)
        HAL_GPIO_WritePin(QUAD1B_o_GPIO_Port,QUAD1B_o_Pin,0);   // dirrection = positive     
    else 
        HAL_GPIO_WritePin(QUAD1B_o_GPIO_Port,QUAD1B_o_Pin,1);   // dirrection = negative 
                                         
        HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,0);
        HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,0);   // increse pulse width by one instruction
//        wait_us(0.5);                                         // pulse width = 0.5 usec                                                       
        HAL_GPIO_WritePin(QUAD1A_o_GPIO_Port,QUAD1A_o_Pin,1);   // send step pulse 

    } // end step & direction
 
    if(Dir1==POS) ++scount1;                   // update internal counter        
    else --scount1;                                                                     
           
    --PCount1;                                // decrement path position counter
        
    if(PCount1==0)
      HAL_TIM_Base_Stop_IT(&htim10);          // path count is 0, disable interrupt
           
}  



// **********************************************************
// Quadrature, Step & Dir output #2
// **********************************************************
void QuadStep2() { 
uint8_t cstate;

    if(motor_count_dis) {                       // return if motor counts disabled
          PCount2==0;
          HAL_TIM_Base_Stop_IT(&htim11);        // disable interrupt
          return;   
    }

    if(quad_out) {

//  Quadrature output
     
        cstate=0;                               // get current state of quad output
        if(HAL_GPIO_ReadPin(QUAD2B_o_GPIO_Port,QUAD2B_o_Pin)) cstate=0x01;
        if(HAL_GPIO_ReadPin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin)) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir2==POS) HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,1);  // new state 10
            else HAL_GPIO_WritePin(QUAD2B_o_GPIO_Port,QUAD2B_o_Pin,1);           // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir2==POS) HAL_GPIO_WritePin(QUAD2B_o_GPIO_Port,QUAD2B_o_Pin,0);  // new state 00
            else HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,1);           // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir2==POS) HAL_GPIO_WritePin(QUAD2B_o_GPIO_Port,QUAD2B_o_Pin,1);  // new state 11
            else HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,0);           // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir2==POS) HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,0);  // new state 01
            else HAL_GPIO_WritePin(QUAD2B_o_GPIO_Port,QUAD2B_o_Pin,0);           // new state 10  
            break;                       
        } //end switch                                                                       
    } //end quad out

    
    else {

// Step & direction output 
// note: QUADxA = Step,   QUADxB = Dir                                               
                                                                // set direction pin
    if(Dir2==0)
        HAL_GPIO_WritePin(QUAD2B_o_GPIO_Port,QUAD2B_o_Pin,0);   // dirrection = positive     
    else 
        HAL_GPIO_WritePin(QUAD2B_o_GPIO_Port,QUAD2B_o_Pin,1);   // dirrection = negative 
                                         
        HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,0);
        HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,0);   // increse pulse width by one instruction
//        wait_us(0.5);                                         // pulse width = 0.5 usec                                                       
        HAL_GPIO_WritePin(QUAD2A_o_GPIO_Port,QUAD2A_o_Pin,1);   // send step pulse 

    } // end step & direction
 
    if(Dir2==POS) ++scount2;                   // update internal counter        
    else --scount2;                                                                     
           
    --PCount2;                              // decrement path position counter
        
    if(PCount2==0)
      HAL_TIM_Base_Stop_IT(&htim11);          // path count is 0, disable interrupt            
}  

// **********************************************************
// Quadrature, Step & Dir output #3
// **********************************************************
void QuadStep3() {
uint8_t cstate;

    if(motor_count_dis) {                       // return if motor counts disabled
          PCount1==3;
          HAL_TIM_Base_Stop_IT(&htim12);        // disable interrupt
          return;   
    }

    if(quad_out) {

//  Quadrature output
     
        cstate=0;                               // get current state of quad output
        if(HAL_GPIO_ReadPin(QUAD3B_o_GPIO_Port,QUAD3B_o_Pin)) cstate=0x01;
        if(HAL_GPIO_ReadPin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin)) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir3==POS) HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,1);  // new state 10
            else HAL_GPIO_WritePin(QUAD3B_o_GPIO_Port,QUAD3B_o_Pin,1);           // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir3==POS) HAL_GPIO_WritePin(QUAD3B_o_GPIO_Port,QUAD3B_o_Pin,0);  // new state 00
            else HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,1);           // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir3==POS) HAL_GPIO_WritePin(QUAD3B_o_GPIO_Port,QUAD3B_o_Pin,1);  // new state 11
            else HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,0);           // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir3==POS) HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,0);  // new state 01
            else HAL_GPIO_WritePin(QUAD3B_o_GPIO_Port,QUAD3B_o_Pin,0);           // new state 10  
            break;                       
        } //end switch                                                                       
    } //end quad out

    
    else {

// Step & direction output 
// note: QUADxA = Step,   QUADxB = Dir                                               
                                                                // set direction pin
    if(Dir3==0)
        HAL_GPIO_WritePin(QUAD3B_o_GPIO_Port,QUAD3B_o_Pin,0);   // dirrection = positive     
    else 
        HAL_GPIO_WritePin(QUAD3B_o_GPIO_Port,QUAD3B_o_Pin,1);   // dirrection = negative 
                                         
        HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,0);
        HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,0);   // increse pulse width by one instruction
//        wait_us(0.5);                                         // pulse width = 0.5 usec                                                       
        HAL_GPIO_WritePin(QUAD3A_o_GPIO_Port,QUAD3A_o_Pin,1);   // send step pulse 

    } // end step & direction
 
    if(Dir3==POS) ++scount3;                   // update internal counter        
    else --scount3;                                                                     
           
    --PCount3;                                  // decrement path position counter
       
    if(PCount3==0)
      HAL_TIM_Base_Stop_IT(&htim12);            // path count is 0, disable interrupt             
}  

// **********************************************************
// Quardrature / Step & Direction output #4
// **********************************************************
void QuadStep4() {
uint8_t cstate;

    if(image_count_dis) {                       // return if motor counts disabled
          PCount1==4;
          HAL_TIM_Base_Stop_IT(&htim13);        // disable interrupt
          return;   
    }

    if(quad_out) {

//  Quadrature output
     
        cstate=0;                               // get current state of quad output
        if(HAL_GPIO_ReadPin(QUAD4B_o_GPIO_Port,QUAD4B_o_Pin)) cstate=0x01;
        if(HAL_GPIO_ReadPin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin)) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir4==POS) HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,1);  // new state 10
            else HAL_GPIO_WritePin(QUAD4B_o_GPIO_Port,QUAD4B_o_Pin,1);           // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir4==POS) HAL_GPIO_WritePin(QUAD4B_o_GPIO_Port,QUAD4B_o_Pin,0);  // new state 00
            else HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,1);           // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir4==POS) HAL_GPIO_WritePin(QUAD4B_o_GPIO_Port,QUAD4B_o_Pin,1);  // new state 11
            else HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,0);           // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir4==POS) HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,0);  // new state 01
            else HAL_GPIO_WritePin(QUAD4B_o_GPIO_Port,QUAD4B_o_Pin,0);           // new state 10  
            break;                       
        } //end switch                                                                       
    } //end quad out

    
    else {

// Step & direction output 
// note: QUADxA = Step,   QUADxB = Dir                                               
                                                                // set direction pin
    if(Dir4==0)
        HAL_GPIO_WritePin(QUAD4B_o_GPIO_Port,QUAD4B_o_Pin,0);   // dirrection = positive     
    else 
        HAL_GPIO_WritePin(QUAD4B_o_GPIO_Port,QUAD4B_o_Pin,1);   // dirrection = negative 
                                         
        HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,0);
        HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,0);   // increse pulse width by one instruction
//        wait_us(0.5);                                         // pulse width = 0.5 usec                                                       
        HAL_GPIO_WritePin(QUAD4A_o_GPIO_Port,QUAD4A_o_Pin,1);   // send step pulse 

    } // end step & direction
 
    if(Dir4==POS) ++scount4;                   // update internal counter        
    else --scount4;                                                                     
           
    --PCount4;                              // decrement path position counter
        
    if(PCount4==0)
      HAL_TIM_Base_Stop_IT(&htim13);          // path count is 0, disable interrupt             
}  


// **********************************************************
// Quardrature / Step & Direction output #5
// **********************************************************
void QuadStep5() {                                    
uint8_t cstate;

    if(image_count_dis) {                       // return if motor counts disabled
          PCount5==0;
          HAL_TIM_Base_Stop_IT(&htim14);        // disable interrupt
          return;   
    }

    if(quad_out) {

//  Quadrature output
     
        cstate=0;                               // get current state of quad output
        if(HAL_GPIO_ReadPin(QUAD5B_o_GPIO_Port,QUAD5B_o_Pin)) cstate=0x01;
        if(HAL_GPIO_ReadPin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin)) cstate |= 0x02;

        switch(cstate){
        case 0x00:                              // state 00
            if(Dir5==POS) HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,1);  // new state 10
            else HAL_GPIO_WritePin(QUAD5B_o_GPIO_Port,QUAD5B_o_Pin,1);           // new state 01
            break;
        case 0x01:                              // state 01
            if(Dir5==POS) HAL_GPIO_WritePin(QUAD5B_o_GPIO_Port,QUAD5B_o_Pin,0);  // new state 00
            else HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,1);           // new state 11
            break;            
        case 0x02:                              // state 10
            if(Dir5==POS) HAL_GPIO_WritePin(QUAD5B_o_GPIO_Port,QUAD5B_o_Pin,1);  // new state 11
            else HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,0);           // new state 00                   
            break;            
        case 0x03:                              // state 11
            if(Dir5==POS) HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,0);  // new state 01
            else HAL_GPIO_WritePin(QUAD5B_o_GPIO_Port,QUAD5B_o_Pin,0);           // new state 10  
            break;                       
        } //end switch                                                                       
    } //end quad out

    
    else {

// Step & direction output 
// note: QUADxA = Step,   QUADxB = Dir                                               
                                                                // set direction pin
    if(Dir5==0)
        HAL_GPIO_WritePin(QUAD5B_o_GPIO_Port,QUAD5B_o_Pin,0);   // dirrection = positive     
    else 
        HAL_GPIO_WritePin(QUAD5B_o_GPIO_Port,QUAD5B_o_Pin,1);   // dirrection = negative 
                                         
        HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,0);
        HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,0);   // increse pulse width by one instruction
//        wait_us(0.5);                                         // pulse width = 0.5 usec                                                       
        HAL_GPIO_WritePin(QUAD5A_o_GPIO_Port,QUAD5A_o_Pin,1);   // send step pulse 

    } // end step & direction
 
    if(Dir5==POS) ++scount5;                   // update internal counter        
    else --scount5;                                                                     
           
    --PCount5;                              // decrement path position counter
        
    if(PCount5==0)
      HAL_TIM_Base_Stop_IT(&htim14);          // path count is 0, disable interrupt                 
}  
// **********************************************************
// Send counts to channel 1, uses timer 10
// Assumes motion is stopped
// **********************************************************
void SendCount1(int16_t counts) {
uint32_t x;   

        if(counts==0) return;                 // return if counts = 0

        PCount1=counts;
            
        if(PCount1<0) 
            Dir1=1;                             // direction = negative
        else
            Dir1=0;                             // direction = positive

        PCount1=abs(PCount1);                   // Make Path position positive
  
        x=SEND_COUNTS/PCount1;                  // calculate time spacing between positions                     

        TIM10->ARR=x;                           // initialize path interrupt rate                           
        HAL_TIM_Base_Start_IT(&htim10);         // start channel 1 interrupt
} 

// **********************************************************
// Send counts to channel 2, uses timer 11
// Assumes motion is stopped
// **********************************************************
void SendCount2(int16_t counts) {
uint32_t x;   

        if(counts==0) return;                   // return if counts = 0

        PCount2=counts;
            
        if(PCount2<0) 
            Dir2=1;                             // dirrection = negative
        else
            Dir2=0;                             // dirrection = positive

        PCount2=abs(PCount2);                   // Make Path position positive

        x=SEND_COUNTS/PCount2;                  // calculate time spacing between positions                     

        TIM11->ARR=x;                           // initialize path interrupt rate                           
        HAL_TIM_Base_Start_IT(&htim11);         // start channel 2 interrupt

}
                

// **********************************************************
// Send counts to channel 3, uses timer 12
// Assumes motion is stopped
// **********************************************************
void SendCount3(int16_t counts) {
uint32_t x;   

        if(counts==0) return;                   // return if counts = 0

        PCount3=counts;
            
        if(PCount3<0) 
            Dir3=1;                             // dirrection = negative
        else
            Dir3=0;                             // dirrection = positive

        PCount3=abs(PCount3);                   // Make Path position positive
        
        x=SEND_COUNTS/PCount3;                  // calculate time spacing between positions                     

        TIM12->ARR=x;                           // initialize path interrupt rate                           
        HAL_TIM_Base_Start_IT(&htim12);         // start channel 3 interrupt

}

// **********************************************************
// Send counts to channel 4, uses timer 13
// Assumes motion is stopped
// **********************************************************
void SendCount4(int16_t counts) {
uint32_t x;   

        if(counts==0) return;                   // return if counts = 0

        PCount4=counts;
            
        if(PCount4<0) 
            Dir4=1;                             // dirrection = negative
        else
            Dir4=0;                             // dirrection = positive

        PCount4=abs(PCount4);                   // Make Path position positive
        
        x=SEND_COUNTS/PCount4;                  // calculate time spacing between positions                     

        TIM13->ARR=x;                           // initialize path interrupt rate                           
        HAL_TIM_Base_Start_IT(&htim13);         // start channel 4 interrupt
                
} 


// **********************************************************
// Send counts to channel 5, uses timer 14
// Assumes motion is stopped
// **********************************************************
void SendCount5(int16_t counts) {
uint32_t x;   

        if(counts==0) return;                   // return if counts = 0

        PCount5=counts;
            
        if(PCount5<0) 
            Dir5=1;                             // dirrection = negative
        else
            Dir5=0;                             // dirrection = positive

        x=SEND_COUNTS/PCount5;                  // calculate time spacing between positions                     

        TIM14->ARR=x;                           // initialize path interrupt rate                           
        HAL_TIM_Base_Start_IT(&htim14);         // start channel 5 interrupt
                 
} 

