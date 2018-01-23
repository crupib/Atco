/***********************************************************************************************************************
MMBasic

External.h

Define the MMBasic commands for reading and writing to the digital and analog input/output pins

Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following 
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

************************************************************************************************************************/



/**********************************************************************************
 the C language function associated with commands, functions or operators should be
 declared here
**********************************************************************************/
#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
// format:
//      void cmd_???(void)
//      void fun_???(void)
//      void op_???(void)

void cmd_setpin(void);
void cmd_pulse(void);

void cmd_pin(void);
void fun_pin(void);

void cmd_port(void);
void fun_port(void);

void cmd_ir(void);
void cmd_lcd(void);
void cmd_keypad(void);
void fun_distance(void);

#endif



/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)

	{ "Pin(",		T_CMD | T_FUN,		0, cmd_pin		},
	{ "SetPin",		T_CMD,				0, cmd_setpin	},
	{ "Pulse",		T_CMD,				0, cmd_pulse	},
	{ "Port(",		T_CMD | T_FUN,		0, cmd_port	    },
	{ "IR",         T_CMD,			    0, cmd_ir       },
	{ "LCD",        T_CMD,			    0, cmd_lcd      },
	{ "KeyPad",     T_CMD,			    0, cmd_keypad   },

#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)
	{ "Pin(",		T_FUN | T_NBR,		0, fun_pin		},
	{ "Port(",		T_FUN | T_NBR,		0, fun_port		},
	{ "Distance(",	T_FUN | T_NBR,		0, fun_distance	},

#endif


#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
// General definitions used by other modules

#ifndef EXTERNAL_HEADER
#define EXTERNAL_HEADER

#define NBR_PULSE_SLOTS     5                       // number of concurrent pulse commands, each entry is 8 bytes


extern char *InterruptReturn;
extern int check_interrupt(void);
extern void ClearExternalIO(void);


/****************************************************************************************************************************
New, more portable, method of manipulating an I/O pin
*****************************************************************************************************************************/

// the basic functions
extern inline void PinSetBit(int pin, unsigned int offset);
extern inline int PinRead(int pin);
extern inline volatile unsigned int *GetPortAddr(int pin, unsigned int offset);
extern inline int GetPinBit(int pin);

// some useful defines
#define PinOpenCollectorOn(x)   PinSetBit(x, ODCSET)
#define PinOpenCollectorOff(x)  PinSetBit(x, ODCCLR)
#define PinHigh(x)              PinSetBit(x, LATSET)
#define PinLow(x)               PinSetBit(x, LATCLR)
#define PinSetOutput(x)         PinSetBit(x, TRISCLR)
#define PinSetInput(x)          PinSetBit(x, TRISSET)

// Define the offsets from the PORT address
#define TRIS                -1
#define TRISCLR             -3
#define TRISSET             -2
#define TRISINV             -1
#define PORT                0
#define PORTCLR             1
#define PORTSET             2
#define PORTINV             3
#define LAT                 4
#define LATCLR              5
#define LATSET              6
#define LATINV              7
#define ODC                 8
#define ODCCLR              9
#define ODCSET              10
#define ODCINV              11

/* Speed Tests
   Using PinSetBit() to switch a pin hi/lo in a tight loop the squarewave output will be about 1.3MHz.
   Using GetPortAddr() and GetPinBit() to get the constants into local variables and using them to point 
   to the LATCLR/SET registers the loop generated a 25MHz squarewave.
****************************************************************************************************************************/


#define EXT_NOT_CONFIG			0
#define EXT_ANA_IN				1
#define EXT_DIG_IN				2
#define EXT_FREQ_IN				3
#define EXT_PER_IN				4
#define EXT_CNT_IN				5
#define EXT_INT_HI				6
#define EXT_INT_LO				7
#define EXT_DIG_OUT				8
#define EXT_OC_OUT				9
#define EXT_INT_BOTH			10
#define EXT_COM_RESERVED        100                 // this pin is reserved and SETPIN and PIN cannot be used
#define EXT_CONSOLE_RESERVED	EXT_COM_RESERVED + 1	// this must be one higher than EXT_COM_RESERVED

extern int ExtCurrentConfig[NBRPINS + 1];
extern volatile int INT1Count, INT1Value;
extern volatile int INT2Count, INT2Value;
extern volatile int INT3Count, INT3Value;
extern volatile int INT4Count, INT4Value;

extern void initExtIO(void);
extern void ExtCfg(int pin, int cfg) ;
extern void ExtSet(int pin, int val);
extern int ExtInp(int pin);
extern int GetPinNbr(char *p);

extern int InterruptUsed;

// IR related stuff
extern float *IrDev, *IrCmd;
extern char IrState, IrGotMsg;
extern int IrBits, IrCount;
extern char *IrInterrupt;
void IrInit(void);
void IrReset(void);
void IRSendSignal(int pin, int half_cycles);

// numpad declares
extern char *KeypadInterrupt;
int KeypadCheck(void);

#define IR_CLOSED           0
#define IR_WAIT_START       1
#define IR_WAIT_START_END   2
#define IR_WAIT_BIT_START   3
#define IR_WAIT_BIT_END     4
#define elapsed             ((1000 * TMR1) / (CLOCKFREQ / 8000))


#endif
#endif

