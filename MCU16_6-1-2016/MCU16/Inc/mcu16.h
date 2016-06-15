
#include "stm32f7xx_hal.h"

// Global constants
#define SW_VERSION 0x02        // software version number
#define HW_ID 0x10             // hardware ID

#define TRUE 1
#define FALSE 0
#define ON 1
#define OFF 0
#define POS 0
#define NEG 1

#define PRESSED 0

#define BUFFER_SIZE 7200        // path buffer size (60 positons per second (720 = 120 sec))
#define CMD_SIZE 100            // maximum size of command buffer
#define TBUF_SIZE 100           // maximum size of serial transmit buffer
#define RBUF_SIZE 100           // maximum size of serial receive buffer
#define BOM 0xAA                // beginning of message

#define PATH_TIMER 16666        // 60Hz = 16666 usec
#define STEP_TIMER 15500        // 60Hz = 1166 usec dead time, step counts

//#define ENCODER_READ 1000     // 1 msec 
#define REMOTE_TIMER 50000      // 20Hz = 50000 usec

#define SEND_COUNTS 16666       // send counts command, count rate

// 10% deadband
#define X_DEADBAND 18           // approx +/- 10%
#define Y_DEADBAND 22           // approx +/- 10%
#define Z_DEADBAND 10            // approx +/- 10%

// Speed scale for max speed
#define X_SCALE 0.1              // X speed scale = 3,768 counts per second max
#define Y_SCALE 0.12             // Y speed scale = 4,460 counts per second max
#define Z_SCALE 0.054            // Z speed scale = 2,000 counts per second max



// ****************************************************
// Prototypes located in mcu_serial_cmd.c
// ****************************************************
void BuildCmd();                 // load receive buffer
void DecodeCmd();                // decode comand
uint8_t Checksum(uint8_t *s,uint8_t length); // calculate check sum
void PutStatus(uint8_t status_request);      // put status in tx buffer
void InitSerCmd();
void ClearLatchedFlags();         // clear latched flags
void InitComVar();                // initialize command variables

// ****************************************************
// Prototypes located in mcu_gpio.c
// ****************************************************

uint8_t AddrIn();                 // read address input
void AddrOut(uint8_t i);          // set address output
void InitGPIO();                  // initialize GPIO
uint8_t GetFault();               // get motor fault, estop 
void EnableMotors(uint8_t iset);  // enable motors and image system


// *******************************************************
// prototypes located in mcu_encoder.c
// *******************************************************

void InitEncoders();            // initialize encoder 1
void EncUpdate();               // update 16 bit counters to 32 bits
void EncoderMotionError();      // encoder motion error

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


// ****************************************************
// Prototypes located in mcu_PathControl.c
// ****************************************************
void InitPathBuf();
void WritePathData();
void ReadPathData();
int16_t PathSpaceAvail();
void NewPosition();


// ****************************************************
// Prototypes located in mcu_mode.c
// ****************************************************

void InitMode();
void StartMotion();
void StopMotion();
void StopMotionSmoothly();
void StartJogMode();
void StopJogMode();


// ****************************************************
// Prototypes located in mcu_Remote.c
// ****************************************************
void CheckRemote();
void StopRemote();  
void StartRemote();
void NewRemote();

// ****************************************************
// Prototypes located in mcu_output.c
// ****************************************************
void InitOutputs();
void QuadStep1();
void QuadStep2();
void QuadStep3();
void QuadStep4();
void QuadStep5();
void SendCount1(int16_t counts);
void SendCount2(int16_t counts);
void SendCount3(int16_t counts);
void SendCount4(int16_t counts);
void SendCount5(int16_t counts);