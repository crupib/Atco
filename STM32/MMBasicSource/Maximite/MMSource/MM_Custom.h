/***********************************************************************************************************************
MMBasic

MM_Custom.h

Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

Include file that contains the globals and defines for MMCustom.c in the Maximite version of MMBasic.

Note:  When you add extra functions you may get an error during the link phase indicating that there is insufficient 
       flash space.  This is because the spare flash memory is allocated to the internal flash drive A:  As a result
       you will have to reduce the amount of flash allocated to drive A: to make space for your added functions.
       To do this reduce the number of pages allocated in files.h.  Look for this line:
            #define MONOCHROME_NBR_PAGES        nn
       and reduce the amount allocated by one and try recompiling.  If you still get an error reduce the number again
       and try another recompile until the error goes away.

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

#endif




/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)

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

