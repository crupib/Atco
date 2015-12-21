//External variables

extern int stest1,stest2,stest3,stest4,stest5,stest10;
extern int EncPos1, EncPos2, EncPos3;

extern int16_t UpperWord2;              // 16 to 32 bit encoder upper word
extern int16_t UpperWord3;              // 16 to 32 bit encoder upper word

extern uint8_t status_byte;             // status byte
extern uint8_t status_packet;
extern uint8_t cmd_ready;               // command ready
extern uint8_t image_count_dis;         //  disable image sytem counts (1=disable)


extern uint16_t enc_error_band1;        // encoder motion error band
extern uint16_t enc_error_band2;        // encoder motion error band
extern uint16_t enc_error_band3;        // encoder motion error band
extern uint8_t enc_error_flg;           // encoder error flag
extern uint8_t servo_flt_flg;           // servo, emergency stop error latched flag
extern uint8_t last_path_flg;            // last path executed flag, latched
extern uint8_t step_rate;                // step rate multiplier

extern uint16_t pos2_now;                // current encoder2  position 
extern uint16_t pos2_last;               // last ebcoder 2 position
extern uint16_t pos3_now;                // current encoder 3 position 
extern uint16_t pos3_last;               // last ebcoder 3 position 

extern uint8_t motion;                  // motor motion 1=on, 0=off
extern uint32_t StepTimer;              // Path position timer
extern uint32_t PathTimer;              // Path position timer
extern uint8_t path_error;              // path buffer error
extern uint8_t jog_mode;                // Jog Mode flag 1=on, 0=off
extern uint8_t remote_mode;             // remote mode 1=on, 0=off   

extern Ticker TStep1;                   // Step 1 pulse interrupt
extern Ticker TStep2;                   // Step 2 pulse interrupt  
extern Ticker TStep3;                   // Step 3 pulse interrupt
extern Ticker TStep4;                   // Step 4 pulse interrupt
extern Ticker TStep5;                   // Step 5 pulse interrupt

extern Ticker TPosition;                // Path position interrupt, 60Hz
extern Ticker EUpdate;                  // Encoder read update rate


// Position path buffers
// All buffers use the same input and output pointers

extern int16_t PathBuffer1[BUFFER_SIZE];   // Position path buffer 1
extern int16_t PathBuffer2[BUFFER_SIZE];   // Position path buffer 2
extern int16_t PathBuffer3[BUFFER_SIZE];   // Position path buffer 3
extern int16_t PathBuffer4[BUFFER_SIZE];   // Position path buffer 4
extern int16_t PathBuffer5[BUFFER_SIZE];   // Position path buffer 5

extern int16_t PathOut[5];                  // output path position
extern int16_t PathIn[5];                   // input path position

extern int PointerIn;                       // Buffer path input pointer
extern int PointerOut;                      // Buffer path output pointer 
extern int DataInPathBuf;                   // number of paths in buffer
extern int SpaceAvailable;                  // buffer space available

extern uint32_t PathsExecuted;              // total number of paths executed
extern uint32_t PathsPlusBuf;               // total number of paths executed plus paths in buffer


extern int PCount1;                        // Path 1 counter
extern int PCount2;                        // Path 2 counter
extern int PCount3;                        // Path 3 counter
extern int PCount4;                        // Path 4 counter
extern int PCount5;                        // Path 5 counter

extern uint8_t Dir1;                        // Direction 1
extern uint8_t Dir2;                        // Direction 2
extern uint8_t Dir3;                        // Direction 3
extern uint8_t Dir4;                        // Direction 4
extern uint8_t Dir5;                        // Direction 5

extern uint8_t quad_out;                    // Quadrature output for chan 4 & 5

extern uint8_t status_request;              // status request flag
extern uint8_t group_leader;                // group leader flag

extern uint8_t cmd[];
extern uint8_t module_addr;                 // UT Interface Module address, default=0
extern uint8_t group_addr;                  // Group address, default =0xFF

extern uint8_t rbuf[];                      // Com port receive buffer
extern uint8_t tbuf[];                      // Com port tranxmit buffer
extern uint8_t r_in;                        // receive input pointer
extern uint8_t r_out;                       // receive output pointer
extern uint8_t t_in;                        // transmit input pointer
extern uint8_t t_out;                       // transmit output pointer
extern uint8_t txbuf_empty;                 // tranmit buffer empty flag

extern uint8_t remote_dis;                  // enabl/disable remote, enable(default)
extern uint8_t remote_sw;                   // remote switch sataus (0=off)
















