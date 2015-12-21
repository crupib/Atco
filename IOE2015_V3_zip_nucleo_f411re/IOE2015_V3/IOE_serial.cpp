//****************************************************************************
//                                   Serial IO 
//****************************************************************************
#include "mbed.h"
#include "IOE2015.h"
#include "IOE2015_extrn.h"


RawSerial Uart1(PA_9, PA_10);  // define UART TX and RX pins ************TEST ??????
DigitalOut TXEN_Pin(PA_8);     // define TX enable pin


//****************************************************************************
// initialize USART 1
//****************************************************************************

void InitUart1() {

USART1->CR1 |= 0x000020AC;      // Enable UART1, interrupt on TXE=1 and RXNE=1
USART1->CR2 |= 0x00000000;      // control register 2
USART1->CR3 |= 0x00000000;      // control register 3
USART1->GTPR |= 0x00000000;      // guard time and prescaler
USART1->DR = 0x00000000;         // data read or write register (TDR=TX, RDR=RX)

//    USART1->BRR                // Baud rate register (currently controled by RawSerial())
Uart1.baud(19200); 
}


//****************************************************************************
// USART 1 interrupt routine, loads receive buffer and emptys transmit buffer 
//****** Convert to a Interrupt routine ****************** 
//****************************************************************************/
void Uart1_Int(void) {
 
//INT_DISABLE;

// RX Buffer
  if(Uart1_Readable()) {            // receive data
     rbuf[r_in++] = USART1->DR;     // put data in buffer 

     if(r_in>=RBUF_SIZE)             
        r_in=0;                     // reset buffer index 
  }


// TX Buffer

//  TXEN_Pin=1;                     // enable network TX line 
 
  if(t_in!=t_out) {                 // data in tx buffer
        TXEN_Pin=1;                     // enable network TX line 
        txbuf_empty=0;                  // tx buffer not empty
                
        if(Uart1_Writeable())           // transmit buffer empty
            USART1->DR=tbuf[t_out++];  // transmit one byte 
   }         
                     
  else {
        txbuf_empty=1;
        if(USART1->SR & 0x00000040)     // transmission complete
           TXEN_Pin=0;                  // release network TX line         
  }
     
   if(t_out>=TBUF_SIZE)          // reset tbuf index
        t_out=0;
}



//INT_ENABLE;

//****************************************************************************
// USART 1 RX and TX buffer initialization  
//****************************************************************************/

void InitUart1Buf(void) {
//  INT_DISABLE;                     // disable interrupts 
  r_in=0;                          // reset receive buffer input index 
  r_out=0;                         // reset receive buffer output index

  t_in=0;                          // reset transmit buffer input index
  t_out=0;                         // reser transmit buffer output index


//  INT_ENABLE;                      // enable interrupts 
}


//****************************************************************************
//  set baud rate for host PC port
//****************************************************************************

void SetBaud(uint8_t baud) {

//  INT_DISABLE;

  switch(baud) {
  case 127:                                   // 9600 BAUD
     Uart1.baud(9600);                                      
  break;

  case 64:                                    // 19200 baud
     Uart1.baud(19200);           
  break;

  case 21:                                     // 57600 baud
     Uart1.baud(57600);       
  break;
 
  case 10:                                     // 115,200 baud
     Uart1.baud(115200);       
  break;

  case 5:                                     // 230,400 baud
     Uart1.baud(230400);         
  break;      
  }

//  INT_ENABLE;
}



//****************************************************************************
// return length of receive com buffer
// returns 0 if buffer is empty  
//****************************************************************************

uint8_t RbufLen(void) {
  return(r_in-r_out);
}

//****************************************************************************
// get data from receive com buffer
//****************************************************************************
uint8_t GetData(void) {
uint8_t c;

//  INT_DISABLE;
  c=rbuf[r_out++];           // get data from receive buffer 
  if(r_out>=RBUF_SIZE)             
     r_out=0;                // reset buffer index 

//  INT_ENABLE;

  return(c);
}



//****************************************************************************
// put binary data into to the transmit buffer
// waits for transmit buffer empty
// if ASCII_en flag set, convert binary to ASCII HEX (2 bytes)
//****************************************************************************

void PutData(uint8_t *pdat, uint8_t length) {

uint8_t i;


//  INT_DISABLE;
  t_in=0;                          // reset TX buffer pointers
  t_out=0;

  if(length>TBUF_SIZE)
     length=TBUF_SIZE;             // limit to max buffer size

 for(i=0;i<length;i++)
        tbuf[t_in++]=pdat[i];      // put character in buffer
//  INT_ENABLE;

}


//****************************************************************************
// put status packet into the transmit buffer
//****************************************************************************
void PutStatus(uint8_t status_request) {

uint8_t stat[TBUF_SIZE];                // status buffer
uint8_t i;
int32_t enc,clk;
uint16_t k;

  i=0;                    


  if(path_error)                        // path buffer data error
        status_byte |= 0x01;
  if(enc_error_flg)                     // encoder position error - latched
        status_byte |= 0x40;
  if(remote_sw==ON)
        status_byte|=0x08;              // remote switch status            
  if(GetServoFault())                   // check for servo error
        status_byte |= 0x80;
  if(servo_flt_flg)
        status_byte |= 0x04;            // servo emergency stop fault - latched
  if(last_path_flg)
        status_byte |= 0x10;            // last path executed flag - latched              
    

  stat[i++]=status_byte;                // load status byte

  if(status_request & 0x01){            // fetch encoder 1 data
     enc = ReadEncoder1();
        stat[i++]= enc & 0x000000FF;    // store LSB
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 2nd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 3rd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // MSB

     enc = ReadEncoder2();              // fetch encoder 2 data
        stat[i++]= enc & 0x000000FF;    // store LSB
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 2nd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 3rd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // MSB
        
     enc = ReadEncoder3();              // fetch encoder 3 data
        stat[i++]= enc & 0x000000FF;    // store LSB
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 2nd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 3rd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // MSB
    }
 
  if(status_request & 0x02){            // fetch servo 1 counter data
     enc = stest1*step_rate;
        stat[i++]= enc & 0x000000FF;    // store LSB
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 2nd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 3rd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // MSB

     enc = stest2*step_rate;            // fetch servo 2 counter  data
        stat[i++]= enc & 0x000000FF;    // store LSB
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 2nd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 3rd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // MSB
        
     enc = stest3*step_rate;            // fetch servo 3 counter  data
        stat[i++]= enc & 0x000000FF;    // store LSB
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 2nd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 3rd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // MSB
    }

  if(status_request & 0x04){            // fetch servo 4 (image sys) counter data
     enc = stest4*step_rate;
        stat[i++]= enc & 0x000000FF;    // store LSB
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 2nd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 3rd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // MSB

     enc = stest5*step_rate;            // fetch servo 5 (image sys) counter  data
        stat[i++]= enc & 0x000000FF;    // store LSB
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 2nd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // 3rd byte
        enc=enc>>8;
        stat[i++]= enc & 0x000000FF;    // MSB 
}

    if(status_request & 0x08){          // read system core clock 
//        SystemCoreClockUpdate();
        clk=SystemCoreClock;
         
        stat[i++]= clk & 0x000000FF;    // store LSB
        clk=clk>>8;
        stat[i++]= clk & 0x000000FF;    // 2nd byte
        clk=clk>>8;
        stat[i++]= clk & 0x000000FF;    // 3rd byte
        clk=clk>>8;
        stat[i++]= clk & 0x000000FF;    // MSB 
    }
 
    if(status_request & 0x10){          // send total paths executed plus paths in buffer
     
        PathsPlusBuf=PathsExecuted+DataInPathBuf;  // total number of paths executed + paths in buffer

        stat[i++]= PathsPlusBuf & 0x000000FF;    // store LSB
        PathsPlusBuf=PathsPlusBuf>>8;
        stat[i++]= PathsPlusBuf & 0x000000FF;    // 2nd byte
        PathsPlusBuf=PathsPlusBuf>>8;
        stat[i++]= PathsPlusBuf & 0x000000FF;    // 3rd byte
        PathsPlusBuf=PathsPlusBuf>>8;
        stat[i++]= PathsPlusBuf & 0x000000FF;    // MSB    
     
    }

    
   if(status_request & 0x20){       // send device ID and SW version
        stat[i++]=HW_ID;            // load hardware ID
        stat[i++]=SW_VERSION;       // load software version number
    }
    
   if(status_request & 0x40){       // send I/O byte
        stat[i++]=GetServoFault();  // get servo fault status

    }
    
   if(status_request & 0x80){       // send path positions space available
        k=PathSpaceAvail();         // get space available
        stat[i++]=k & 0x00FF;       // get LSB
        k = k>>8;
        stat[i++]=k & 0x00FF;       // get MSB
    }
 
   k=Checksum(&stat[0],i);          // calculate checksum
      stat[i++]=k;                  // send checksum
      
    PutData(&stat[0], i);           // put status packet into TX buffer
    txbuf_empty=0;                  // set TX buffer not empty flag      
  }
  
//**************************************************************
// Is TX buffer empty
//**************************************************************
uint8_t Uart1_Writeable(void) {
uint8_t x;
        if(USART1->SR & 0x00000080)
            x=1;
        else
            x=0;
        return(x);                          // TXE (bit7) TX data register empty        
}

//**************************************************************
// Is RX buffer full
//**************************************************************
uint8_t Uart1_Readable(void) {
uint8_t x;
        if(USART1->SR & 0x00000020)
            x=1;
        else
            x=0;
        return(x);                          // RXNE (bit5) RX data ready
        
}



