
#include "mcu16.h"

// Global Variables
int32_t testit,testit2;  // global test variable

int32_t scount1,scount2,scount3,scount4,scount5;  // encoder internal counters
int32_t EncPos1,EncPos2,EncPos3;                  // position of encoders, all 32 bits


int16_t UpperWord2,UpperWord3;                    // 16 to 32 bit encoder upper word

uint8_t status_byte;                  // status byte 
uint8_t status_packet;
uint8_t cmd_ready;                    // command ready
uint8_t image_count_dis;              //  disable image system counts (1=disable)
uint8_t cmdlen;                       // command length
uint8_t motor_count_dis;              // disable counts to image system 1=disable

uint16_t enc_error_band1;             // encoder motion error band 1
uint16_t enc_error_band2;             // encoder motion error band 2
uint16_t enc_error_band3;             // encoder motion error band 3

uint8_t enc_error_flg;                // encoder error flag
uint8_t enc_overflow;                 // encoder overflow flag
uint8_t servo_flt_flg;                // servo, emergency stop error, latched
uint8_t last_path_flg;                // last path executed flag, latched
uint8_t step_rate=1;                  // step rate multiplier
uint8_t ImageEn;                      // enable counts to image system

uint16_t pos2_now;                    // current encoder 2 position 
uint16_t pos2_last;                   // last ebcoder 2 position
uint16_t pos3_now;                    // current encoder 3 position 
uint16_t pos3_last;                   // last ebcoder 3 position

uint32_t StepTimer;                   // Path position timer
uint32_t PathTimer;                   // Path position timer

uint8_t path_error;                   // path buffer error 
uint8_t jog_mode;                     // Jog Mode flag 1=on, 0=off
uint8_t remote_mode;                  // remote mode 1=on, 0=off            
uint8_t motion;                       // motor motion 1=on, 0=off


// Path Buffers
// All buffers use the same input and output pointers

int16_t PathBuffer1[BUFFER_SIZE];   // Position path buffer 1
int16_t PathBuffer2[BUFFER_SIZE];   // Position path buffer 2
int16_t PathBuffer3[BUFFER_SIZE];   // Position path buffer 3
int16_t PathBuffer4[BUFFER_SIZE];   // Position path buffer 4
int16_t PathBuffer5[BUFFER_SIZE];   // Position path buffer 5

int16_t PathOut[5];                 // output path position
int16_t PathIn[5];                  // input path position

int16_t PointerIn=0;                    // Buffer path input pointer
int16_t PointerOut=0;                   // Buffer path output pointer 
int16_t DataInPathBuf=0;                // number of paths in buffer
int16_t SpaceAvailable=0;               // buffer space available

uint32_t PathsExecuted=0;           // total number of paths executed
uint32_t PathsPlusBuf=0;            // total number of paths executed plus paths in buffer


int16_t PCount1;                        // Path 1 counter
int16_t PCount2;                        // Path 2 counter
int16_t PCount3;                        // Path 3 counter
int16_t PCount4;                        // Path 4 counter
int16_t PCount5;                        // Path 5 counter

uint8_t Dir1,Dir2,Dir3,Dir4,Dir5;       // Direction

uint8_t quad_out;                       // Quadrature output for chan 4 & 5


uint8_t status_request;                 // status request flag
uint8_t group_leader;                   // group leader flag

uint8_t cmd[CMD_SIZE];
uint8_t module_addr;                    // UT Interface Module address, default=0
uint8_t group_addr = 0xFF;              // Group address, default =0xFF


uint8_t rbuf[RBUF_SIZE];                // Com port receive buffer
//uint8_t tbuf[TBUF_SIZE];                // Com port tranxmit buffer
uint8_t stat[TBUF_SIZE];                // status buffer
uint8_t r_in;
uint8_t r_out;
uint8_t t_in;
uint8_t t_out;
uint8_t txbuf_empty;

uint8_t remote_dis;                     // enable/disable remote, enable(default)
uint8_t remote_sw;                      // remote switch sataus (0=off)











