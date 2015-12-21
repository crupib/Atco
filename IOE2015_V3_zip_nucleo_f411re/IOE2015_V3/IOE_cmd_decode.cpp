 
//****************************************************************************
//                               Command Decoder 
//****************************************************************************
#include "mbed.h"
#include "IOE2015.h"
#include "IOE2015_extrn.h"


//DigitalIn AddrIn_Pin(PB_8);        // define address input pin
//DigitalOut AddrOut_Pin(PB_9);     // define address output output pin
                                            
//****************************************************************************
// decode command 
//****************************************************************************
void DecodeCmd(void) {

uint8_t command,checklen,k;
uint8_t i,pathcount;
int32_t eset,tset;
int16_t iset, cset;
uint16_t xset;

//int addr;
//int *pkaddr; 

  status_byte=0;                      // clear status byte
  
  if((cmd[1]==module_addr)||group_leader)
     status_request=1;                // return status packet
  else
     status_request=0;                // do not return status packet



  checklen=(((cmd[2]>>4)&0x0F)+2);    // calculate checksum byte length

  k=Checksum(&cmd[1],checklen);       // validate checksum

  if(k!=cmd[checklen+1]) {
     status_byte|=0x02;               // set check sum error bit
     if(status_request)
        PutStatus(status_packet);     // request status packet
     cmd_ready=0;                     // clear command ready flag 
     return;                          // return checksum error   
  }


   
  command=cmd[2] & 0x0F;              // mask command byte


  switch(command){

//***************************************************************************
  case 0x00:                          // Set encoders
  
    i=4;                   
    tset=0;
    eset=0; 
    tset=cmd[i++];
    eset=eset | tset;                   // load LSB
    tset=cmd[i++]<<8;                
    eset=eset | tset;                   // load 2d=nd byte
    tset=cmd[i++]<<16;
    eset=eset | tset;                   // load 3rd byte
    tset=cmd[i++]<<24;
    eset=eset | tset;                   // load MSB        

    if(cmd[3] & 0x01) SetEncoder1(eset);  // set encoder 1 
    if(cmd[3] & 0x02) SetEncoder2(eset);  // set encoder 2 
    if(cmd[3] & 0x04) SetEncoder3(eset);  // set encoder 2 
    if(cmd[3] & 0x08) stest1=eset;         // set servo 1 internal counter
    if(cmd[3] & 0x10) stest2=eset;         // set servo 2 internal counter
    if(cmd[3] & 0x20) stest3=eset;         // set servo 3 internal counter
    if(cmd[3] & 0x40) stest4=eset;         // set servo 4 internal counter
    if(cmd[3] & 0x80) stest5=eset;         // set servo 5 internal counter



                      
     if(status_request)
        PutStatus(status_packet);     // send status packet
  break;
//***************************************************************************
  case 0x01:                          // set address
     
     module_addr=cmd[3];              // get module address

     if((cmd[4]&0x80)==0)             // check MSB for group leader
        group_leader=1;
     else
        group_leader=0;   
 
     group_addr=cmd[4]|0x80;          // get group address, set MSB

     if(module_addr!=0)         
        AddrOut(0);               // enable next device on network
//     else
//        AddrOut_Pin=1;              // disable next device on network
     if(status_request)
        PutStatus(status_packet);     // send status packet
        

  break;
//***************************************************************************
  case 0x02:                          // define status
     status_packet=cmd[3];            // set status packet request register
     if(status_request)
        PutStatus(status_packet);     // send status packet
  break;
//***************************************************************************
  case 0x03:                          // read status
    if(status_request)
        PutStatus(cmd[3]);            // send requested status packet
  break;
/***************************************************************************/
  case 0x04:                           // Jog Mode
    if(cmd[3]&0x01)
        StartJogMode();                // Start Jog Mode
    if(cmd[3]&0x02)
        StopJogMode();                 // Stop Jog Mode

    if(status_request)
        PutStatus(status_packet);      // send status packet
  break;
//***************************************************************************
  case 0x05:                          // Sart Motion
        StartMotion();       
       
    if(status_request)
        PutStatus(status_packet);      // send status packet
  break;
//***************************************************************************
  case 0x06:                          // Step Rate Multiplier
    step_rate=cmd[3];                 // set step rate multiplier
 
    if(status_request)
        PutStatus(status_packet);      // send status packet   
    
  break;
//***************************************************************************
  case 0x07:                           // Stop Motion
  
    if(cmd[3]&0x01)
        image_count_dis=1;            // disable counts to image system
    else
        image_count_dis=0;            // enable counts to image system

      if(cmd[3]&0x02)
        InitPathBuf();                 // reset path position buffer

    if(cmd[3] & 0x04) {                // Stop motion abruptly
        StopMotion();      
    }

    if(cmd[3] & 0x08) {                 // Stop motion smoothly
        StopMotionSmoothly();
    }

    EnableServo(cmd[3]);                // Bits 7,6,5,4 enable/disable servos and image system
    
    if(status_request)
        PutStatus(status_packet);      // send status packet
  break;
//***************************************************************************
  case 0x08:                                // Test for encoder position error

    xset=(cmd[5]<<8) | cmd[4];              // combine LSB and MSB, load Path buffer

    if(cmd[3]&0x01) enc_error_band1=xset;  //set error count band
    if(cmd[3]&0x02) enc_error_band2=xset;
    if(cmd[3]&0x04) enc_error_band3=xset;           

    if(status_request)
        PutStatus(status_packet);           // send status packet
  break;
//***************************************************************************
  case 0x09:                                // Quadrature output for channel 4 & 5
     if(cmd[3]&0x01)
        quad_out=1;                         // quadrature output
    else
        quad_out=0;                         // step & direction outpur  

    if(cmd[3]&0x02) {                         // remote control
        remote_dis=1;                        // disable remote
        StopRemote();                       // stop remote mode
    }
    else
        remote_dis=0;                        // enable remote


    if(status_request)
        PutStatus(status_packet);           // send status packet

  break;
//***************************************************************************
  case 0x0A:                          // set baud rate

    SetBaud(cmd[3]);
    
    if(status_request)
        PutStatus(status_packet);      // send status packet
  break;
//***************************************************************************
  case 0x0B:                           // clear latched status bits

    ClearLatchedFlags();
          
    if(status_request)
        PutStatus(status_packet);      // send status packet

  break;
//***************************************************************************
  case 0x0C:                             // send counts to servos and image system

        i=4;
        
        cset=0;
        iset=0; 
        cset=cmd[i++];
        iset=iset | cset;               // load LSB
        cset=cmd[i++]<<8;                
        iset=iset | cset;               // load 2nd byte
        
        if(cmd[3] & 0x01)               // send counts to servo channel 1
            SendCount1(iset);
             
        if(cmd[3] & 0x02)               // send counts to servo channel 2
            SendCount2(iset);         
 
        if(cmd[3] & 0x04)               // send counts to servo channel 3
            SendCount3(iset);
                      
        if(cmd[3] & 0x08)               // send counts to image system channel 4
            SendCount4(iset);               

        if(cmd[3] & 0x10)               // send counts to image system channel 5
            SendCount5(iset);  


    if(status_request)
        PutStatus(status_packet);      // send status packet

  break;

//***************************************************************************
  case 0x0D:                             // Add path points to path buffer
  
    i=0; 
    pathcount=1;                            // 1 path per command
//    pathcount=(cmd[2]>>4)&0x0F;          // get number of paths to store
                                            // use for multiple paths per command 
    while(pathcount>0) {
        PathIn[0]=0;
        PathIn[0]=(cmd[4+i]<<8) | cmd[3+i];  // combine LSB and MSB, load Path buffer
        PathIn[1]=0;
        PathIn[1]=(cmd[6+i]<<8) | cmd[5+i];
        PathIn[2]=0;    
        PathIn[2]=(cmd[8+i]<<8) | cmd[7+i];
        PathIn[3]=0;
        PathIn[3]=(cmd[10+i]<<8) | cmd[9+i]; 
        PathIn[4]=0;
        PathIn[4]=(cmd[12+i]<<8) | cmd[11+i];
        i+=10;                               // update path counter

        WritePathData();                 // store path in buffer
        --pathcount;                     // decrement path count     
    }

     if(status_request)
        PutStatus(status_packet);        // request status packet        

        
  break;


//***************************************************************************
  case 0x0E:                             // NOP
     if(status_request)
        PutStatus(status_packet);        // request status packet
  break;
//***************************************************************************
  case 0x0F:                             // soft reset
     
    SoftReset(); 
  
  break;
//***************************************************************************


  default:                          


  break;

//**************************************************************************

  }
  cmd_ready=0;                             // clear command ready flag 
}






//****************************************************************************
// build command 
//****************************************************************************
void BuildCmd(void) {

static int8_t c_in=0;
static int8_t cmdlen=0;
uint8_t c;
//int8_t x;

  while(RbufLen()&&(!cmd_ready)) {
     c=GetData();

     if(AddrIn() && (module_addr==0)) // check network address in
        return;                    // return if module is disabled

     switch(c_in) {

     case 0:                       // first byte must be BOM 
        if(c==BOM) 
          cmd[c_in++]=c;           // place BOM in buffer               
     break;


     case 1:                       // second byte must be module address
        if((c==module_addr)||(c==group_addr))
           cmd[c_in++]=c;          // place module address in buffer
        else 
           c_in=0;                 // clear index, not for this module 
     break;

     case 2:                       // third byte is data length and command 
        cmd[c_in++]=c;             // place data length and command in buffer 
        cmdlen=((c>>4)&0x0F)+4;    // calculate command length
        if(cmdlen>CMD_SIZE)        // check for max size
           c_in=0;

     break;

     default:
        cmd[c_in++]=c;             // place data in buffer
        if(c_in==cmdlen) {
           cmd_ready=1;            // set command ready flag  
           c_in=0;                 // reset command buffer index 
        }
     break;
     }
  }


}

//****************************************************************************
// calculate 8 bit checksum
//****************************************************************************


uint8_t Checksum(uint8_t *s,uint8_t length) {
    
uint8_t checksum,i;

  checksum=0;
  for(i=0;i<length;i++)
     checksum=checksum + s[i];
  return(checksum);
}

//****************************************************************************
// soft reset
//****************************************************************************
void SoftReset(void) {
  
    StopMotion();
    module_addr=0; 
    status_packet=0; 
    group_addr = 0xFF;
    remote_dis=0;
     
    InitGPIO();             // Initialize GPIO
    InitEncoders();         // Initialize Encoders    
    InitEncoderOutputs();   // Initialize step & direction outputs 
    InitUart1();            // Initialize UART 1
    InitUart1Buf();         // Initialize UART 1 buffer pointers
    InitPathBuf();          // initialize 5 path buffers
    
    stest1=0;               // initialize internal counters
    stest2=0; 
    stest3=0;
    stest4=0;
    stest5=0;
    stest10=0;
    
    
    ClearLatchedFlags();     

}

//****************************************************************************
// clear latched flags
//****************************************************************************
void ClearLatchedFlags(void) {
    status_byte=0;                     
    enc_error_flg=0;                   // clear encoder error flag
    servo_flt_flg=0;                   // clear servo fault flag
    last_path_flg=0;                   // clear last path executed flag  
}
