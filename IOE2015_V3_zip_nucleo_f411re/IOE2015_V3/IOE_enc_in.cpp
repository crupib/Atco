#include "mbed.h"
#include "IOE2015.h"
#include "IOE2015_extrn.h"


//**********************************************************

void InitEncoders() {

    step_rate=1;                // initialize step rate multiplier
    enc_error_band1=0;          // initialize encoder error band, 0=off
    enc_error_band2=0;          // initialize encoder error band, 0=off
    enc_error_band3=0;          // initialize encoder error band, 0=off
    UpperWord2=0;               // 16 to 32 bit encoder upper word
    UpperWord3=0;               // 16 to 32 bit encoder upper word   
    
// Encoder #1
// Timer2, configured as 4X Quadrature Encoder
   
    RCC->APB1ENR |= 0x00000001;  // Enable clock for TIM2
    
    TIM2->CR1   = 0x0000;       // CEN='0' disable counter for initialization    
    TIM2->CR2   = 0x0000;       // 
    TIM2->SMCR  = 0x0203;       // ETF='0010' filter N=4, SMS='011' encoder mode 3
//    TIM2->SMCR  = 0x0003;       // ETF='0010' filter N=0, SMS='011' encoder mode 3
    TIM2->DIER  = 0x0000;       // DMA/Interrupt register, disabled
    TIM2->SR    = 0x0000;       // Status register  (bit 0 set on over/under flow)
    TIM2->EGR   = 0x0000;       // Event registor
    TIM2->CCMR1 = 0xF1F1;       // CC1S='01' CC2S='01'
    TIM2->CCMR2 = 0x0000;       // Capture/compare register
    TIM2->CCER  = 0x0011;       // CC1P CC2P,  capture/compare enable register
    TIM2->PSC   = 0x0000;       // Prescaler = (0+1)
    TIM2->ARR   = 0xffffffff;   // Auto-reload register 
      
    TIM2->CNT = 0x80000000;     //reset the counter to 0, offset 0x80000000 = 0

   TIM2->CR1   = 0x0001;       // CEN='1' enable counter
    

// Encoder #2
// Timer3, configured as 4X Quadrature Encoder
   
    RCC->APB1ENR |= 0x00000002;  // Enable clock for TIM3
    
    TIM3->CR1   = 0x0000;       // CEN='0' disable counter for initialization    
    TIM3->CR2   = 0x0000;       // 
    TIM3->SMCR  = 0x0203;       // ETF='0010' filter N=4, SMS='011' encoder mode 3
//    TIM3->SMCR  = 0x0003;       // ETF='0010' filter N=0, SMS='011' encoder mode 3
    TIM3->DIER  = 0x0000;       // DMA/Interrupt register, disabled
    TIM3->SR    = 0x0000;       // Status register  (bit 0 set on over/under flow)
    TIM3->EGR   = 0x0000;       // Event registor
    TIM3->CCMR1 = 0xF1F1;       // CC1S='01' CC2S='01'
    TIM3->CCMR2 = 0x0000;       // Capture/compare register
    TIM3->CCER  = 0x0011;       // CC1P CC2P,  capture/compare enable register
    TIM3->PSC   = 0x0000;       // Prescaler = (0+1)
    TIM3->ARR   = 0xffff;       // Auto-reload register 
      
    TIM3->CNT = 0x0000;         //reset the counter to 0
    
    pos2_last = 0;              // initialize last encoder 2 position
    TIM3->CR1   = 0x0001;       // CEN='1' enable counter


// Encoder #3
// Timer4, configured as 4X Quadrature Encoder
   
    RCC->APB1ENR |= 0x00000004;  // Enable clock for TIM4
    
    TIM4->CR1   = 0x0000;       // CEN='0' disable counter for initialization    
    TIM4->CR2   = 0x0000;       // 
    TIM4->SMCR  = 0x0203;       // ETF='0010' filter N=4, SMS='011' encoder mode 3
//    TIM4->SMCR  = 0x0003;       // ETF='0010' filter N=0, SMS='011' encoder mode 3
    TIM4->DIER  = 0x0000;       // DMA/Interrupt register, disabled
    TIM4->SR    = 0x0000;       // Status register  (bit 0 set on over/under flow)
    TIM4->EGR   = 0x0000;       // Event registor
    TIM4->CCMR1 = 0xF1F1;       // CC1S='01' CC2S='01'
    TIM4->CCMR2 = 0x0000;       // Capture/compare register
    TIM4->CCER  = 0x0011;       // CC1P CC2P,  capture/compare enable register
    TIM4->PSC   = 0x0000;       // Prescaler = (0+1)
    TIM4->ARR   = 0xffff;       // Auto-reload register 
      
    TIM4->CNT = 0x0000;         //reset the counter to 0
    
    pos3_last = 0;              // initialize last encoder 3 position 
    TIM4->CR1   = 0x0001;       // CEN='1' enable counter


}


// Encoder 1 control
//**********************************************************
// Zero Encoder 1
void ZeroEncoder1() {
    TIM2->CNT=0x80000000;           //reset count to zero, offset 0x80000000 = 0
    stest1=0;                       // reset internal step counter
}

//**********************************************************
// Read Encoder 1, subtract offset
int ReadEncoder1() {
    int value=EncPos1-0x80000000;      // get encoder 1, subtract offset
    return(value);
}

//**********************************************************
// Set Encoder 1, add offset
void SetEncoder1(int value) {
    TIM2->CNT=value+0x80000000;      // set timer 2, encoder 1, add offset
}

//**********************************************************
// Enable Encoder 1
void EnableEncoder1() {
    TIM2->CR1   |= 0x0001;          // CEN='1' enable counter
}

//**********************************************************
// Disable Encoder 1
void DisableEncoder1() {
    TIM2->CR1   &= 0xFFFE;          // CEN='0' disable counter
}



// Encoder 2 control
//**********************************************************
// Zero Encoder 2
void ZeroEncoder2() {
    UpperWord2=0;
    pos2_last = 0;                  // initialize last encoder 2 position
    TIM3->CNT=0x0000;               //reset count to zero
    stest2=0;                       // reset internal step counter
}

//**********************************************************
// Read Encoder 2
int ReadEncoder2() {
 
    return(EncPos2);                  // read timer 3, encoder 2

}

//**********************************************************
// Set Encoder 2
void SetEncoder2(int value) {
    UpperWord2 = value>>16;         // get upper word
    pos2_last = value & 0xC000;     // initialize last encoder 2 position
    TIM3->CNT=value;                // set timer 3, encoder 2, add offset
}

//**********************************************************
// Enable Encoder 2
void EnableEncoder2() {
    TIM3->CR1   |= 0x0001;          // CEN='1' enable counter
}

//**********************************************************
// Disable Encoder 2
void DisableEncoder2() {
    TIM3->CR1   &= 0xFFFE;          // CEN='0' disable counter
}



// Encoder 3 control
//**********************************************************
// Zero Encoder 3
void ZeroEncoder3() {
    UpperWord3=0;
    pos3_last = 0;                  // initialize last encoder 2 position 
    TIM4->CNT=0x0000;               // reset count to zero
    stest3=0;                       // reset internal step counter
}

//**********************************************************
// Read Encoder 3
int ReadEncoder3() {
  
    return(EncPos3);                  // read timer 4, encoder 3
}

//**********************************************************
// Set Encoder 3
void SetEncoder3(int value) {
    UpperWord3 = value>>16;         // get upper word
    pos3_last = value & 0xC000;     // initialize last encoder 3 position 
    TIM4->CNT=value;                // set timer 4, encoder 3, add offset
}

//**********************************************************
// Enable Encoder 3
void EnableEncoder3() {
    TIM4->CR1   |= 0x0001;          // CEN='1' enable counter
}

//**********************************************************
// Disable Encoder 3
void DisableEncoder3() {
    TIM4->CR1   &= 0xFFFE;          // CEN='0' disable counter
}

//**********************************************************
// Encoder motion error
void EncoderMotionError() {
      
    if(enc_error_band1) {           // test for encoder 1 error, 0=OFF        
        if(abs(ReadEncoder1()-(stest1*step_rate)) > enc_error_band1) {
            if(enc_error_flg==0) enc_error_flg=1; // latch error
        }
    }        
    if(enc_error_band2) {           // test for encoder 2 error
        if(abs(ReadEncoder2()-(stest2*step_rate)) > enc_error_band2) {
            if(enc_error_flg==0) enc_error_flg=1; // latch error      
        } 
    }        
    if(enc_error_band3) {           // test for encoder 3 error
        if(abs(ReadEncoder3()-(stest3*step_rate)) > enc_error_band3) {
            if(enc_error_flg==0) enc_error_flg=1; // latch error  
        }
     }
              
      
}

//**********************************************************
// Read Encoder 1, 2 and 3
// exetnd Encoder 2 and 3 to 32 bits
//**********************************************************
void EncUpdate() {
uint16_t temp2,temp3;


    EncPos1=TIM2->CNT;                  // get encoder 1 value, 32 bits
    temp2=TIM3->CNT;                    // get encoder 2 value, 16 bits
    temp3=TIM4->CNT;                    // get encoder 3 value, 16 bits

    pos2_now = temp2&0xC000;            // get quadrant of position now
    pos3_now = temp3&0xC000;            // get quadrant of position now
    
    if(pos2_now==0  &&  pos2_last==0xC000) UpperWord2++;
    if(pos2_now==0xC000  &&  pos2_last==0) UpperWord2--;    
    pos2_last=pos2_now;

    if(pos3_now==0  &&  pos3_last==0xC000) UpperWord3++;
    if(pos3_now==0xC000  &&  pos3_last==0) UpperWord3--;   
    pos3_last=pos3_now;

    EncPos2= (UpperWord2<<16)  | temp2;  // Combine upper and lower words
    EncPos3= (UpperWord3<<16)  | temp3;  // Combine upper and lower words
    
// check for encoder motion error here to avoid interrupt issues 

    EncoderMotionError();                    // test for encoder motion error
//        StopMotion();                    // stop motion if fault is detected      
}