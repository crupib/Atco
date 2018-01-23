/***********************************************************************************************************************
MMBasic

MM_Custom.c

Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

Handles all the custom commands and functions in the Maximite implementation of MMBasic.  These are commands and functions
that are not normally part of the Maximite.  This is a good place to insert your own customised commands.

************************************************************************************************************************/

#include <stdio.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"


/*************************************************************************************************************************
**************************************************************************************************************************
IMPORTANT:
This module is empty and should be used for your special functions and commands.  In the standard distribution this file  
will never be changed, so your code should be safe here.  You should avoid placing commands and functions in other files as
they may be changed and you would then need to re insert your changes in a new release of the source.

**************************************************************************************************************************
**************************************************************************************************************************/


/********************************************************************************************************************************************
 custom commands and functions
 each function is responsible for decoding a command
 all function names are in the form cmd_xxxx() (for a basic command) or fun_xxxx() (for a basic function) so, if you want to search for the
 function responsible for the NAME command look for cmd_name

 There are 4 items of information that are setup before the command is run.
 All these are globals.

 int cmdtoken	This is the token number of the command (some commands can handle multiple
				statement types and this helps them differentiate)

 char *cmdline	This is the command line terminated with a zero char and trimmed of leading
				spaces.  It may exist anywhere in memory (or even ROM).

 char *nextstmt	This is a pointer to the next statement to be executed.  The only thing a
				command can do with it is save it or change it to some other location.

 char *CurrentLinePtr  This is read only and is set to NULL if the command is in immediate mode.

 The only actions a command can do to change the program flow is to change nextstmt or
 execute longjmp(mark, 1) if it wants to abort the program.

Note:  When you add extra functions you may get an error during the link phase indicating that there is insufficient 
       flash space.  This is because the spare flash memory is allocated to the internal flash drive A:  As a result
       you will have to reduce the amount of flash allocated to drive A: to make space for your added functions.
       To do this reduce the number of pages allocated in files.h.  Look for this line:
            #define MONOCHROME_NBR_PAGES        nn
       and reduce the amount allocated by one and try recompiling.  If you still get an error reduce the number again
       and try another recompile until the error goes away.

 ********************************************************************************************************************************************/

