#include "mbed.h"
#include "IOE2015.h"
#include "IOE2015_extrn.h"


DigitalOut Servo1_en_pin(PC_8);         // define servo 1 enable pin (1=enable, 0=disable)
DigitalOut Servo2_en_pin(PC_9);         // define servo 2 enable pin (1=enable, 0=disable)
DigitalOut Servo3_en_pin(PC_5);         // define servo 3 enable pin (1=enable, 0=disable)
DigitalOut Image_disable_pin(PC_4);     // define image system disable pin (1=enable, 0=disable)

DigitalIn Servo1_flt_pin(PC_0);         // define servo 1 fault pin (1=fault)
DigitalIn Servo2_flt_pin(PC_1);         // define servo 2 fault pin (1=fault)
DigitalIn Servo3_flt_pin(PC_2);         // define servo 3 fault pin (1=fault)
DigitalIn Estop_pin(PC_3);              // define emergrncy stop pin (1=Emergency Stop)

DigitalIn AddrIn_Pin(PB_8);             // define address input pin
DigitalOut AddrOut_Pin(PB_9);           // define address output output pin


// configure GPIO ports
//

void InitGPIO() {
    
    RCC->AHB1ENR |= 0x0000000F;     // Enable clock for GPIOA,GPIOB,GPIOC,GPIOD   
    
    GPIOA->MODER |= 0x0169300A;     // PA0,PA1,PA9,PA10 as alt, PA6 as analog, PA8,PA11,PA12 as output,  all others as input  
    GPIOB->MODER |= 0x5004A005;     // PB6,PB7 as alt, PB0,PB1,PB6,PB7,PB9 as output,  all others as input
    GPIOC->MODER |= 0x0155A500;     // PC6,PC7 as alt,PC4,PC5,PC8,PC9,PC10,PC11,PC12 as output, all others as input 
    GPIOD->MODER |= 0x00000010;     // PD2 as output, all others as input                           
   
    GPIOA->OTYPER |= 0x00000000;     // all outputs push pull
    GPIOB->OTYPER |= 0x00000000;     // all outputs push pull
    GPIOC->OTYPER |= 0x00000000;     // all outputs push pull
    GPIOD->OTYPER |= 0x00000000;     // all outputs push pull
    
    GPIOA->OSPEEDR |= 0x00000000;     // all outputs low speed
    GPIOB->OSPEEDR |= 0x00000000;     // all outputs low speed
    GPIOC->OSPEEDR |= 0x00000000;     // all outputs low speed
    GPIOD->OSPEEDR |= 0x00000000;     // all outputs low speed
    
    GPIOA->PUPDR |= 0x00144505;     // PA0,PA1,PA4,PA5,PA7,PA9,PA10 pull up
    GPIOB->PUPDR |= 0x51055005;     // PB0,PB1,PB6,PB7,PB8,PB9,PB14,PS12,PB15 pull up
    GPIOC->PUPDR |= 0x01555500;     // PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12 pull up
    GPIOD->PUPDR |= 0x00000010;     // PD2 Pull up


    GPIOA->AFR[0]  |= 0x00000011 ;    //  AF01 for PA0 & PA1 TMR2
    GPIOA->AFR[1]  |= 0x00000077 ;    // AF7 for PA9 & PA10 UART1    
    GPIOB->AFR[0]  |= 0x22000000 ;    //  AF02 for PB6 & PB7 TMR4
    GPIOB->AFR[1]  |= 0x00000000 ;    
    GPIOC->AFR[0]  |= 0x22000000 ;    //  AF02 for PC6 & PC7 TMR3
    GPIOC->AFR[1]  |= 0x00000000 ;    
 
    AddrOut(1);                         // initialize address out pin
    EnableServo(0x00);                  // enable servos and image system 
    
              
}

//**********************************************************
// get servo fault status
//**********************************************************
uint8_t GetServoFault(void) {
uint8_t status;

    status=0;
    if(Servo1_flt_pin) status|=0x01;
    if(Servo2_flt_pin) status|=0x02;
    if(Servo3_flt_pin) status|=0x04;
    if(Estop_pin) status|=0x08;                 // Check emergency stop
    
    if(status)                                  // latch servo flault flag
        servo_flt_flg=1;
               
//    if(remote_mode==ON) status|=0x10;         // remote mode    
    return(status);
}

//**********************************************************
// Disable / Enable servo 1, 2, 3 and Image system
//**********************************************************
void EnableServo(uint8_t iset) {

    if(iset & 0x10)  
        Servo1_en_pin=0;            // disable servo 1
    else
        Servo1_en_pin=1;            // enable servo 1
        
     if(iset & 0x20)  
        Servo2_en_pin=0;            // disable servo 2
    else
        Servo2_en_pin=1;            // enable servo 2       
        
     if(iset & 0x40)  
        Servo3_en_pin=0;             // disable servo 3
    else
        Servo3_en_pin=1;             // enable servo 3       

     if(iset & 0x80)  
        Image_disable_pin=0;         // disable Image System
    else
        Image_disable_pin=1;         // enable Image System 
        
       
}

//**********************************************************
// read address in 
//**********************************************************
uint8_t AddrIn(void) {
    return(AddrIn_Pin);
}

//**********************************************************
// set address out
//**********************************************************
void AddrOut(uint8_t i) {
    AddrOut_Pin=i;
}