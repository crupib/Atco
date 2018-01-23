/***********************************************************************************************************************
MMBasic

Hardware_Includes.h

Provides the header files used in MMBasic for defining commands, functions and operators that are specific to the Maximite.

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
//#ifndef float
//#define float double
//#endif



#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)

#include "IOPorts - STM32F7.h"
#include "Maximite.h"
#include "Video.h"
#include "stm32_ub_uart.h"
#include "Serial.h"
#include "stm32_ub_fatfs.h"
#include "stm32_ub_usb_msc_host.h"
#include "stm32f7_random.h"
#include "stmF7_gfx.h"
#include "stm32_ub_jpg.h"
#include "stm32f7_keyboard.h"
#include "stm32_ub_touch_480x272.h"
#include "Touch_F7.h"
#include "stm32_ub_spi.h"
#include "stm32_ub_i2c1.h"
#include "stm32_ub_mpu6050.h"
#include "stm32_ub_qflash.h"
#include "lib3d.h"
#include "wm8994.h"

// global variables used in MMBasic but must be maintained outside of the interpreter

extern int ListCnt;
extern int MMCharPos;
extern char *StartEditPoint;
extern int StartEditChar;
extern int OptionErrorAbort;
extern int ExitMMBasicFlag;
extern char *InterruptReturn;
extern unsigned int _excep_peek;

// console related I/O
int MMInkey(void);
int MMInkeyPause(void);
int MMgetchar(void);
char MMputchar(char c);

//void CheckAbort(void);
void EditInputLine(void);

// empty functions used in MMBasic but must be maintained outside of the interpreter
void UnloadFont(int);


#endif

#include "Files.h"
#include "External.h"
#include "MM_Misc.h"
#include "Graphics.h"
#include "Touch_F7.h"
#include "Audio_F7.h"
#include "I2C_F7.h"
#include "Editor.h"
#include "Memory.h"
#include "Version.h"
#include "Configuration.h"


/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)


	{ "Copyright",  T_CMD,				0, cmd_copyright},


#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)

	{ "As",			T_NA,				0, op_invalid	},

#endif






