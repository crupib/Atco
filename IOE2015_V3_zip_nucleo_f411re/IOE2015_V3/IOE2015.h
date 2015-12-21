//****************************************************************************
//                               IOE2015 
//****************************************************************************



#include "mbed.h"

#define SW_VERSION 0x30        // software version number
#define HW_ID 0x05             // hardware ID

#define TRUE 1
#define FALSE 0
#define ON 1
#define OFF 0
#define POS 0
#define NEG 1
#define PRESSED 0
#define QUAD_OUT 0              // quadrature out = 1, step & dir =0

#define STEP_TIMER 15666        // 60Hz = 16666 usec - 1000 usec dead time
#define PATH_TIMER 16666        // 60Hz = 16666 usec
#define ENCODER_READ 1000       // 1 msec 
#define REMOTE_TIMER 50000      // 20Hz = 50000 usec
// 10% deadband
#define X_DEADBAND 18           // approx +/- 10%
#define Y_DEADBAND 22           // approx +/- 10%
#define Z_DEADBAND 10            // approx +/- 10%
// Speed scale for max speed
#define X_SCALE 0.1              // X speed scale = 3,768 counts per second max
#define Y_SCALE 0.12             // Y speed scale = 4,460 counts per second max
#define Z_SCALE 0.054            // Z speed scale = 2,000 counts per second max

#define SEND_COUNTS 50000       // 20Hz = 50000 usec

//#define BUFFER_SIZE 10800       // path buffer size (60 positons per second (10800 = 180 sec))
#define BUFFER_SIZE 7200        // path buffer size (60 positons per second (720 = 120 sec))
#define CMD_SIZE 100            // maximum size of command buffer
#define RBUF_SIZE 100           // maximum size of serial receive buffer
#define TBUF_SIZE 100           // maximum size of serial receive buffer

#define BOM 0xAA                // beginning of message


//****************************************************************************
void InitEncoders();            // initialize encoder 1
void EncUpdate();               // update 16 bit counters to 32 bits

// Encoder 1, Timer 2
void ZeroEncoder1();            // zero encoder 1
int ReadEncoder1();             // read encoder 1
void SetEncoder1(int value);    // set encoder 1
void EnableEncoder1();          // enable counter
void DisableEncoder1();         // disable counter

// Encoder 2, timer 3
void ZeroEncoder2();            // zero encoder 2
int ReadEncoder2();             // read encoder 2
void SetEncoder2(int value);    // set encoder 2
void EnableEncoder2();          // enable counter
void DisableEncoder2();         // disable counter

// Encoder 3, timer 4
void ZeroEncoder3();            // zero encoder 3
int ReadEncoder3();             // read encoder 3
void SetEncoder3(int value);    // set encoder 3
void EnableEncoder3();          // enable counter
void DisableEncoder3();         // disable counter

//****************************************************************************
// General purpose I/O
void InitGPIO();                // initialize GPIO
uint8_t GetServoFault(void);    // get servo fault status
void EnableServo(uint8_t iset); // Enable/disable servos and image system
uint8_t AddrIn(void);           // Read address in pin
void AddrOut(uint8_t i);        // set address out pin


// Step & direction ticker interrupts
void Step1();                   // Step & Dir output #1 routine
void Step2();                   // Step & Dir output #2 routine
void Step3();                   // Step & Dir output #3 routine
void Step4();                   // Step & Dir output #4 routine
void Step5();                   // Step & Dir output #5 routine

void SendCount1(int16_t counts);    // send counts to servo 1
void SendCount2(int16_t counts);    // send counts to servo 2
void SendCount3(int16_t counts);    // send counts to servo 3
void SendCount4(int16_t counts);    // send counts to image system 4
void SendCount5(int16_t counts);    // send counts to image system 5

//****************************************************************************  
// Remote Control routines
void CheckRemote();             // Check remote control
void StartRemote();             // Start remote control
void StopRemote();              // Stop remote control
void NewRemote();               // New remote value 

//****************************************************************************  
// Motion routines
void StartMotion();             // Start motor motion  
void StopMotion();              // Stop motor motion
void StopMotionSmoothly();      // Stop motion smoothly
void NewPosition();             // Start new path position
void InitEncoderOutputs();      // Initialize encoder outputs to reset state
void EncoderMotionError();      // test for encoder motion error
void StartJogMode();            // Start Jog Mode
void StopJogMode();             // Stop Jog Mode
void DecodePathCmd();           // decode path inserted commands

//****************************************************************************
// Path Buffer control routines
void InitPathBuf();             // Initialize Path Buffer
void WritePathData();           // Write data to 5 path buffers
void ReadPathData();            // Read data from 5 path buffers
int16_t PathSpaceAvail();       // read spce available in path buffer.  0 = buffer empty

//****************************************************************************
// Command decoder
void DecodeCmd(void);           // Command decoder
void BuildCmd(void);            // Build command
uint8_t Checksum(uint8_t *s,uint8_t length); // calculate checksum
void SoftReset(void);           // soft reset
void ClearLatchedFlags(void);   // clear latched flags


//****************************************************************************
// Serial communication
void InitUart1();                       // initialize USART 1 hardware
void InitUart1Buf(void);                // initialize buffer pointers
void Uart1_Int(void);                   // TX and RX UART1 interrupt
uint8_t Uart1_Writeable(void);          // is TX buffer empty
uint8_t Uart1_Readable(void);           // is RX buffer full
void SetBaud(uint8_t baud);

void PutStatus(uint8_t status_request);
uint8_t RbufLen(void);                  // return length of receive buffer
uint8_t GetData(void);                  // get data from receive buffer
void PutData(uint8_t *pdat, uint8_t length);  //put binary dat into TX Buffer
            







