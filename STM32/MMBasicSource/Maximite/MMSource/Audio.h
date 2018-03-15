/***********************************************************************************************************************
MMBasic

Audio.h

Include file that contains the globals and defines for Music.c in the Maximite version of MMBasic.
  
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
    void cmd_sound(void);
    void cmd_playmod(void);
    void fillAudioBuffer(void);                                          // Pascal
    void StopAudio(void);
    typedef enum { P_NOTHING, P_IDLE, P_PWM, P_TONE, P_SOUND, P_MOD } e_CurrentlyPlaying;
    extern e_CurrentlyPlaying CurrentlyPlaying;
    
#endif




/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)
	{ "Sound",		    T_CMD,				0, cmd_sound	},
	{ "PWM",	    	T_CMD,				0, cmd_sound	},
	{ "PlayMOD",     	T_CMD,				0, cmd_playmod	},
	{ "Tone",        	T_CMD,				0, cmd_playmod	},

#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)

#endif
