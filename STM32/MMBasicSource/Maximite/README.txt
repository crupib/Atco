This is the source to MMBasic for the Maximite and similar platforms (UBW32, DuinoMite, etc).

The following instructions assume that you are using a Windows (XP/Vista/Win7) platform.

You should install Microchip MPLAB IDE V8.56 or later and Microchip C32 C Compiler V2.02 Student (or Lite) version.
These can be downloaded from Microchip (http://www.microchip.com).  Note that Microchip is promoting its new development
environment called MPLABX and the XC32 compiler but, at this time, MMBasic has not been ported to this tool set.

Unzip the source files keeping the directory structure.

If you are compiling for the Colour Maximite you should load the project by double clicking on the file MPLAB\ColourMM.mcp.
Note that the UBW32 can load the Colour Maximite hex file so there is no special project for the UBW32.

If you are compiling for the Maximite you should load the project by double clicking on the file MPLAB\Maximite.mcp.
Similar for the DuiniMite and the TFT_Maximite.

MPLAB defaults to a DEBUG build when it opens so you will need to change to a RELEASE build by clicking on the
drop down list box in the toolbar at the top of the window.

You will also need to change the locations of the library files to match where they were installed on your machine.
To do this navigate to:     Project -> Build Options... -> Project -> Directories -> Library Search Path

You might also have to tell MPLAB where the compiler and linker were installed on your machine although generally
MPLAB is able to work this out for itself.  These are specified in:   Project -> Set Language Tool Locations...

Then press F10 and the firmware should be built.

The build will create a subdirectory called Maximite\Output and in there you will find the output file (.hex).
This file can be loaded via the bootloader or programmed directly into the chip by a programmer such as the PICKit 3.
Note that this output file does not include the bootloader which is a separate piece of firmware loaded into a part
of memory reserved for such things.

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
                    
   In the Maximite\MMSource directory is the hardware related files:
       Main.c		This file which is the entry point for the firmware.  It initialises the various subsystems and calls the MMBasic
       Memory.c	    Contains the code for managing the memory allocation for MMBasic
       External.c	Contains the commands and code for dealing with the 10 external input/output pins on the Maximite (PIN, SETPIN, etc)
       Files.c		File and console related commands (OPEN, CLOSE, etc)
       Graphics.c	Graphics related commands (LINE, CIRCLE, etc)
       I2C.c		The commands for handling the I2C protocol.
       MM_Misc.c	Miscellaneous commands that do not fit anywhere else (TIMER, SETTICK, etc)
       MM_Custom.c  This is empty and should be used for your special functions and commands.  In the standard distribution
                    this file will never be changed, so your code should be safe here.
       Keyboard.c   Handles the keyboard
       Timers.c 	Managers the internal timers (clock, pause, etc)
       Serial.c 	Handles the asynchronous serial interface.
       Video.c      The video and character font routines
       Touch.c      The touch sensitive for the TFT_Maximite only
       Audio.c      The routines for generating sound.
       mod32.c      The routines for playing MOD files
       SDCard       These routines are from the Microchip Solutions v2010-10-19 download and have only been slightly changed
       USB          Again these routines are from the Microchip Solutions v2010-08-04 download and have only been slightly changed


Colour Maximite only:
  In Video.c in the function SetupSPI() there is a number of nop instructions which may or may not be commented out.
  Due to a bug in the PIC32 SPI (Microchip Errata #13) this nop may be required to get all three colours into proper registration on the 
  VGA monitor.


Go to http://geoffg.net for updates, errata and helpful notes
or http://mmbasic.com for details on MMBasic and licensing.

Copyright 2011 - 2014 Geoff Graham - http://mmbasic.com
This file and modified versions of this file are supplied to specific individuals under the following provisions:

- It may be used for personal use only and may not be distributed or copied without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) are for personal use only and may not be 
  distributed without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


