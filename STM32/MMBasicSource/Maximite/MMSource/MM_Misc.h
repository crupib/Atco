/***********************************************************************************************************************
MMBasic

MM_Misc.h

Include file that contains the globals and defines for Misc.c in MMBasic.
These are miscelaneous commands and functions that do not easily sit anywhere else.

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

void cmd_pause(void);
void cmd_timer(void);
void cmd_date(void);
void cmd_time(void);
void cmd_ireturn(void);
void cmd_settick(void);
void cmd_copyright(void);
void cmd_mode(void);
void cmd_colour(void);
void cmd_cline(void);
void cmd_font(void);
void cmd_memory(void);
void cmd_config(void);
void cmd_watchdog(void);

void fun_timer(void);
void fun_date(void);
void fun_time(void);
void fun_spi(void);
void fun_at(void);
void fun_device(void);
void fun_clr(void);
void fun_keydown(void);
void fun_mmwatchdog(void);

#endif




/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)

	{ "Config",		T_CMD,				0, cmd_config	},
	{ "Pause",		T_CMD,				0, cmd_pause	},
	{ "Timer",		T_CMD | T_FUN,		0, cmd_timer	},
	{ "Date$",		T_CMD | T_FUN,		0, cmd_date		},
	{ "Time$",		T_CMD | T_FUN,		0, cmd_time		},
	{ "IReturn",	T_CMD,				0, cmd_ireturn 	},
	{ "SetTick",	T_CMD,				0, cmd_settick 	},
	{ "Copyright",  T_CMD,				0, cmd_copyright},
	{ "Colour",  	T_CMD,				0, cmd_colour	},
	{ "Color",  	T_CMD,				0, cmd_colour	},
	{ "ScanLine",  	T_CMD,				0, cmd_cline	},
	{ "Mode",  		T_CMD,				0, cmd_mode		},
	{ "Font",  		T_CMD,				0, cmd_font		},
	{ "Memory",		T_CMD,				0, cmd_memory	},
	{ "WatchDog",	T_CMD,				0, cmd_watchdog	},

#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)
	{ "Timer",		T_FNA | T_NBR,		0, fun_timer	},
	{ "Date$",		T_FNA | T_STR,		0, fun_date		},
	{ "Time$",		T_FNA | T_STR,		0, fun_time		},
	{ "SPI(",		T_FUN | T_NBR,		0, fun_spi,		},
	{ "Load",		T_NA,				0, op_invalid	},
	{ "@(",			T_FUN | T_STR,		0, fun_at		},
	{ "MM.Device$",	T_FNA | T_STR,		0, fun_device   },
	{ "CLR$(",		T_FUN | T_STR,		0, fun_clr		},
	{ "KeyDown",    T_FNA | T_NBR,		0, fun_keydown	},

#endif


#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
// General definitions used by other modules

#ifndef MISC_HEADER
#define MISC_HEADER

extern char *InterruptReturn;
extern int check_interrupt(void);
extern char *GetIntAddress(char *p);

// struct for the interrupt configuration
// the tick interrupt uses pin number 0 which is not a valid physical pin
#define T_LOHI   1
#define T_HILO   2
#define T_BOTH   3
struct s_inttbl {
	int last;					// the last value of the pin (ie, hi or low)
	char *intp;					// pointer to the interrupt routine
	unsigned int lohi;			// trigger on lo to hi if true.  Also used for the tic period
};

extern struct s_inttbl inttbl[NBRPINS + 1];
extern int TickPeriod[NBRSETTICKS];
extern volatile int TickTimer[NBRSETTICKS];
extern char *TickInt[NBRSETTICKS];

#endif
#endif
