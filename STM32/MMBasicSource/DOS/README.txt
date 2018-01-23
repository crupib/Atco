This is the source to MMBasic for DOS on Windows XP, Vista or Win7.

The following instructions assume that you are using a Windows (XP/Vista/Win7) platform.

First:  Rename the file "DOS\BuildAll.bat.txt" to "DOS\BuildAll.bat"
        This was forced on me because some email systems reject .bat files because they are an executable.

You should install the free Watcom version 1.9 C/C++ compiler for Windows 32 bit.
This is available from http://www.openwatcom.org and (at the time of writing) the download file is:
     http://ftp.heanet.ie/pub/openwatcom/open-watcom-c-win32-1.9.exe

When installing the compiler is best to let it install at its default location (C:\WATCOM).  If you install it
somewhere else you will have to edit the file BuildAll.bat to suit.

MMBasic does not use any special features of the compiler so it should compile with later versions of the Watcom compiler.

This source will also compile with Microsoft Visual C/C++ Express which is also free to download and use.  This is
more complex to setup so only use it if you have had some experience with it.  In this case you will have to instruct 
Visual C/C++ Express to make all chars unsigned by default.  You will also have to set the paths of include files and 
add the following switches to the compiler's command line: /TC /D "MSVCC"

Unzip the MMBasic source files keeping the directory structure.

To compile the source (using the Watcom compiler) simply run the batch command file:  BuildAll.bat
This will create the executable (MMBasic.exe) in the same directory.

Program summary.  Also see the README file in the MMBasic folder.
This program consists of a number of code blocks:
   
   In the MMBasic directory is the BASIC language interpreter:
       MMBasic.c	This is the core of the interpreter.  It contains the routines for starting the interpreter, converting a program line
       				into tokenised code, program storage, variable storage, resolving expressions and a host of functions to aid in
       				decoding BASIC commands and functions.
	   Operators.c	Code for executing the BASIC operators (ie, *, -, +, etc)
       Commands.c	Standard BASIC commands (GOTO, FOR...NEXT, etc)
       Functions.c  Standard BASIC functions (INT, SIN, etc)
       Misc.c		Miscellaneous commands that do not fit anywhere else.
       Custom.c     This is empty and should be used for your special functions and commands.  In the standard distribution
                    this file will never be changed, so your code should be safe here.
                    
   In the DOS\DOS_Suurce directory are the hardware related files:
       Main.c		This file which is the entry point for the firmware.  It initialises the various subsystems and calls the MMBasic
       Memory.c		Memory management routines for DOS
       DOS_IO.c		File and console related commands and functions (OPEN, CLOSE, etc)


Go to http://mmbasic.com for updates and licensing

Copyright 2011 - 2013 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following 
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

