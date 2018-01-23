This is the source to the generic PIC32 version of MMBasic.
Website: http://mmbasic.com

The following instructions assume that you are using a Windows (XP/Vista/Win7) platform.

You should install Microchip MPLAB IDE V8.56 or later and Microchip C32 C Compiler V2.01 Student (or Lite) version.
This source should build correctly using any version later than 1.11B.  1.11B is prefered as it creates slightly
smaller executables and throws less warnings during compile.

Unzip the source files keeping the directory structure.

If you are compiling for the Maximite you should load the project by double clicking on the file MPLAB\PIC32.mcp.

MPLAB defaults to a DEBUG build when it opens so you will need to change to a RELEASE build by clicking on the
drop down list box in the toolbar at the top of the window.

You will also need to change the locations of the library files to match where they were installed on your machine.
To do this navigate to:     Project -> Build Options... -> Project -> Directories -> Library Search Path

You might also have to tell MPLAB where the compiler and linker were installed on your machine although generally
MPLAB is able to work this out for itself.  These are specified in:   Project -> Set Language Tool Locations...

Then press F10 and the firmware should be built.

The build will create a subdirectory called Output and in there you will find the output file (.hex).
This file can be programmed directly into the chip by a programmer such as the PICKit 3.

Program summary.  Also see the README file in the MMBasic folder and the notes at the start of Main.c.
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
                    
   In the PIC32-Generic\Source directory are the hardware related files:
       Main.c		This file which is the entry point for the firmware.  It initialises the various subsystems and calls the MMBasic
       Memory.c	    Contains the code for managing the memory allocation for MMBasic


Copyright 2011 - 2013 Geoff Graham - http://mmbasic.com
This file and modified versions of this file are supplied to specific individuals under the following provisions:

- It may be used for personal use only and may not be distributed or copied without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) are for personal use only and may not be 
  distributed without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


