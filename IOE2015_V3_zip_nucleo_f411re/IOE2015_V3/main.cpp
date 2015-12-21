#include "mbed.h"
#include "IOE2015.h"
#include "IOE2015_global.h"


// IOE2015
// MBED output on debug port to host PC @ 9600 baud
// IO Extension board serial port 19200 baud

int main() {
     
    InitGPIO();                     // Initialize GPIO
    InitEncoders();                 // Initialize Encoder1 input    
    InitEncoderOutputs();           // Initialize step & direction outputs 
    InitUart1();                    // Initialize UART 1
    InitUart1Buf();                 // Initialize UART 1 buffer pointers
    InitPathBuf();                  // initialize 5 path buffers
    
    EUpdate.attach_us(&EncUpdate,ENCODER_READ);   // start encoder read and 32 bit update
                                                  // check for encoder motion errors
    AnalogIn ain6(PA_6);            // Remote control analog input
     
    Serial pc (USBTX,USBRX);        // debug uart port 
//    SystemCoreClockUpdate();                               
//    pc.printf("SystemCoreClock = %d Hz\n\r", SystemCoreClock);
 
                        
//***************************************************
//Uart1.attach(&uart1_int,USART1_IRQn);
//RawSerial Uart1(PA_9, PA_10);      
     
    
    while (1) {
                            
            if(RbufLen()){                  // check com buffer for data
                BuildCmd();                 // build command                 
            }
                                   
            if(cmd_ready){
                DecodeCmd();                // decode command
            }
            
            if(module_addr!=0) {            // check for errors if module is initialized                           
               if(GetServoFault()){         // get servo fault status and emergency stop status
                  StopMotion();             // stop motion if fault is detected              
                }
                
                if(enc_error_flg){          // check for encoder position error
//                  StopMotion();           // stop motion if fault is detected
                }         
                
            } // end if module addr         


            CheckRemote();      // Check remote control

                      
            Uart1_Int();                    // call UART1 Interrupt routine                                     

    }   
}

