// Global Variables


int stest1=0;
int stest2=0; 
int stest3=0;
int stest4=0;
int stest5=0;
int stest10=0;

int EncPos1=0;                      // position of encoders, all 32 bits
int EncPos2=0;
int EncPos3=0;
int16_t UpperWord2=0;               // 16 to 32 bit encoder upper word
int16_t UpperWord3=0;               // 16 to 32 bit encoder upper word

uint8_t status_byte=0;              // status byte 
uint8_t status_packet=0;
uint8_t cmd_ready=0;                // command ready
uint8_t image_count_dis=0;          //  disable image sytem counts (1=disable)

uint16_t enc_error_band1=0;         // encoder motion error band 1
uint16_t enc_error_band2=0;         // encoder motion error band 2
uint16_t enc_error_band3=0;         // encoder motion error band 3
uint8_t enc_error_flg=0;            // encoder error flag
uint8_t servo_flt_flg=0;            // servo, emergency stop error, latched
uint8_t last_path_flg=0;            // last path executed flag, latched
uint8_t step_rate=1;                // step rate multiplier

uint16_t pos2_now=0;                 // current encoder 2 position 
uint16_t pos2_last=0;                // last ebcoder 2 position
uint16_t pos3_now=0;                 // current encoder 3 position 
uint16_t pos3_last=0;                // last ebcoder 3 position


uint8_t motion=0;                   // motor motion 1=on, 0=off
uint32_t StepTimer=0;               // Path position timer
uint32_t PathTimer=0;               // Path position timer
uint8_t path_error=0;               // path buffer error 
uint8_t jog_mode=0;                 // Jog Mode flag 1=on, 0=off
uint8_t remote_mode=0;              // remote mode 1=on, 0=off            


 
Ticker TStep1;                  // Step 1 pulse interrupt
Ticker TStep2;                  // Step 2 pulse interrupt  
Ticker TStep3;                  // Step 3 pulse interrupt
Ticker TStep4;                  // Step 4 pulse interrupt
Ticker TStep5;                  // Step 5 pulse interrupt

Ticker TPosition;               // Path position interrupt, 60Hz
Ticker EUpdate;                 // Encoder read update rate


// Path Buffers
// All buffers use the same input and output pointers

int16_t PathBuffer1[BUFFER_SIZE];   // Position path buffer 1
int16_t PathBuffer2[BUFFER_SIZE];   // Position path buffer 2
int16_t PathBuffer3[BUFFER_SIZE];   // Position path buffer 3
int16_t PathBuffer4[BUFFER_SIZE];   // Position path buffer 4
int16_t PathBuffer5[BUFFER_SIZE];   // Position path buffer 5

int16_t PathOut[5];                 // output path position
int16_t PathIn[5];                  // input path position

int PointerIn=0;                    // Buffer path input pointer
int PointerOut=0;                   // Buffer path output pointer 
int DataInPathBuf=0;                // number of paths in buffer
int SpaceAvailable=0;               // buffer space available

uint32_t PathsExecuted=0;           // total number of paths executed
uint32_t PathsPlusBuf=0;            // total number of paths executed plus paths in buffer


int PCount1;                        // Path 1 counter
int PCount2;                        // Path 2 counter
int PCount3;                        // Path 3 counter
int PCount4;                        // Path 4 counter
int PCount5;                        // Path 5 counter

uint8_t Dir1=0;                        // Direction 1
uint8_t Dir2=0;                        // Direction 2
uint8_t Dir3=0;                        // Direction 3
uint8_t Dir4=0;                        // Direction 4
uint8_t Dir5=0;                        // Direction 5

uint8_t quad_out=0;                 // Quadrature output for chan 4 & 5


uint8_t status_request=0;             // status request flag
uint8_t group_leader = 0;             // group leader flag

uint8_t cmd[CMD_SIZE];
uint8_t module_addr = 0;            // UT Interface Module address, default=0
uint8_t group_addr = 0xFF;          // Group address, default =0xFF


uint8_t rbuf[RBUF_SIZE];            // Com port receive buffer
uint8_t tbuf[TBUF_SIZE];            // Com port tranxmit buffer
uint8_t r_in=0;
uint8_t r_out=0;
uint8_t t_in=0;
uint8_t t_out=0;
uint8_t txbuf_empty=0;

uint8_t remote_dis=0;                // enable/disable remote, enable(default)
uint8_t remote_sw=0;                 // remote switch sataus (0=off)











