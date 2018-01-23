/***********************************************************************************************************************
MMBasic

Touch_F7.h

Include file that contains the globals and defines for TouchF7.c in MMBasic.

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

#define TOUCH_FONT_NR        1
#define TOUCH_FONT_SIZE      1
#define TOUCH_FRAME_COL      WHITE
#define TOUCH_AKTIV_COL      BLACK

#define MAX_NBR_OF_BTNS		31	                // defines array bounds

#define TOUCH_OVERLAP		3		            // additional touch bounds in pixel


#define TOUCH_TYPE_NONE		0		            // for touch item list
#define TOUCH_TYPE_BUTTON	1		            // button, single action, latched
#define TOUCH_TYPE_SWITCH	2		            // switch, toggled
#define TOUCH_TYPE_RADIO	3		            // radio button, only one active at a time
#define TOUCH_TYPE_CHECK	4		            // checkbox, multiple choice, like switch
#define TOUCH_TYPE_PUSH		5		            // latching toggle pushbutton, like switch
#define TOUCH_TYPE_LED		9		            // LED or LED button
#define TOUCH_TYPE_VSLIDER	10		            // "analog" slider vertical
#define TOUCH_TYPE_HSLIDER	11		            // "analog" slider horizontal

#define TOUCH_ITEM_INVALID	0		            // item status
#define TOUCH_ITEM_INACTIVE	1					// inactive, greyed out
#define TOUCH_ITEM_ACTIVE	2					// active, highlighted






/**********************************************************************************
 the C language function associated with commands, functions or operators should be
 declared here
**********************************************************************************/
#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
// format:
//      void cmd_???(void)
//      void fun_???(void)
//      void op_???(void)

void cmd_touchval(void);
void cmd_touch(void);

void fun_touchval(void);
void fun_touched(void);
void fun_mtouched(void);

extern int touch_active;
extern char *OnTouchGOSUB;
extern int checktouch(void);
extern int item_active[MAX_NBR_OF_BTNS];

#endif




/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)
{ "TouchVal(",	T_CMD | T_FUN,	0, 	cmd_touchval},
{ "Touch",		T_CMD,		    0, 	cmd_touch},
#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)

{ "TouchVal(",	T_FUN | T_NBR,	0,	fun_touchval},
{ "Touched(",		T_FUN  | T_NBR,			0, fun_touched		},
{ "MTouched(",		T_FUN  | T_NBR,			0, fun_mtouched		},

#endif

