/************************************************************************************************************************
Maximite

I2C.h

Routines to handle I2C access.

Copyright 2011 Gerard Sexton
This file is free software: you can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

************************************************************************************************************************/

#define INCLUDE_I2C_SLAVE                                           // uncomment this to include i2c slave functions

/**********************************************************************************
 the C language function associated with commands, functions or operators should be
 declared here
**********************************************************************************/
#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)


void cmd_i2c(void);
void cmd_rtc(void);

//void cmd_num2byte(void);
//void fun_byte2num(void);

void fun_mmi2c(void);

#endif




/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE

	{ "I2C",	T_CMD,		0, cmd_i2c              },
	{ "RTC",	T_CMD,		0, cmd_rtc              },
//	{ "NUM2BYTE",	T_CMD,		0, cmd_num2byte         },

#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE

//	{ "BYTE2NUM(",	T_FUN | T_NBR,	0, fun_byte2num         },
	{ "MM.I2C",	T_FNA | T_NBR,	0, fun_mmi2c		},

#endif



#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
#ifndef I2C_HEADER
#define I2C_HEADER

#define mI2C1BSetIntFlag()	(IFS0SET = _IFS0_I2C1BIF_MASK)			// macro to set the I2C1 bus collision interrupt flag
#define mI2C1MSetIntFlag()	(IFS0SET = _IFS0_I2C1MIF_MASK)			// macro to set the I2C1 master interrupt flag
#define mI2C1SSetIntFlag()	(IFS0SET = _IFS0_I2C1SIF_MASK)			// macro to set the I2C1 slave interrupt flag

// states of the master state machine
#define I2C_State_Idle     0					    // Bus Idle
#define I2C_State_Start    1					    // Sending Start or Repeated Start
#define I2C_State_10Bit    2					    // Sending a 10 bit address
#define I2C_State_10BitRcv 3					    // 10 bit address receive
#define I2C_State_RcvAddr  4					    // Receive address
#define I2C_State_Send     5					    // Sending Data
#define I2C_State_Receive  6					    // Receiving data
#define I2C_State_Ack      7					    // Sending Acknowledgement
#define I2C_State_Stop     8					    // Sending Stop

// defines for I2C_Status
#define I2C_Status_Enabled			0x00000001
#define I2C_Status_MasterCmd			0x00000002
#define I2C_Status_NoAck			0x00000010
#define I2C_Status_Timeout			0x00000020
#define I2C_Status_InProgress			0x00000040
#define I2C_Status_Completed			0x00000080
#define I2C_Status_Interrupt			0x00000100
#define I2C_Status_BusHold			0x00000200
#define I2C_Status_10BitAddr			0x00000400
#define I2C_Status_BusOwned			0x00000800
#define I2C_Status_Send				0x00001000
#define I2C_Status_Receive		    	0x00002000
#define I2C_Status_Disable			0x00004000
#define I2C_Status_Master			0x00008000
#define I2C_Status_Slave			0x00010000
#define I2C_Status_Slave_Send			0x00020000
#define I2C_Status_Slave_Receive		0x00040000
#define I2C_Status_Slave_Send_Rdy		0x00080000
#define I2C_Status_Slave_Receive_Rdy            0x00100000
#define I2C_Status_Slave_Receive_Full           0x00200000

// Global variables provided by I2C.c
extern volatile unsigned int I2C_State;                             // the state of the master state machine
extern volatile unsigned int I2C_Status;                            // status flags
extern unsigned int I2C_Timer;                                      // master timeout counter
extern char *I2C_IntLine;                                           // pointer to the master interrupt line number
extern char *I2C_Slave_Send_IntLine;                                // pointer to the slave send interrupt line number
extern char *I2C_Slave_Receive_IntLine;                             // pointer to the slave receive interrupt line number

extern void i2c_disable(void);
extern void i2c_slave_disable(void);

#endif
#endif
