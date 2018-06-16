/***********************************************************************************************************************
MMBasic

Onewire.h

Include file that contains the globals and defines for Onewire.c (One Wire support) in MMBasic.

Copyright 2012 Gerard Sexton
This file is free software: you can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

************************************************************************************************************************/


/**********************************************************************************
 the C language function associated with commands, functions or operators should be
 declared here
**********************************************************************************/
#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)

void cmd_onewire(void);
//void fun_owCRC8(void);
//void fun_owCRC16(void);
void fun_mmOW(void);
void fun_ds18b20(void);
void cmd_ds18b20(void);

#endif


/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE

	{ "OneWire",	T_CMD,		0, cmd_onewire      },
	{ "DS18B20 START", T_CMD,	0, cmd_ds18b20      },

#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE

//	{ "OWCRC8(",	T_FUN | T_NBR,	0, fun_owCRC8       },
//	{ "OWCRC16(",	T_FUN | T_NBR,	0, fun_owCRC16      },
	{ "MM.OneWire",	T_FNA | T_NBR,	0, fun_mmOW         },
	{ "DS18B20(",	T_FUN | T_NBR,	0, fun_ds18b20      },

#endif


/**********************************************************************************
 All other required definitions and global variables should be define here
**********************************************************************************/
#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
#ifndef ONEWIRE_HEADER
#define ONEWIRE_HEADER

#define INCLUDE_1WIRE_SEARCH

#endif
#endif
