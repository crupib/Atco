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
    
//    #include <p32xxxx.h>								// device specific defines
//    #include <plib.h>									// peripheral libraries
    
    #if defined(MAXIMITE)
    	#include "./IOPorts/IOPorts - Maximite.h"
    #endif
    
    #if defined(UBW32)
    	#include "./IOPorts/IOPorts - UBW32.h"
    #endif
    
    #if defined(DUINOMITE)
    	#include "./IOPorts/IOPorts - DUINOMITE.h"
    #endif
    
    #if defined(TFT_MAXIMITE)
    	#include "./IOPorts/IOPorts - TFT_Maximite.h"
    #else
        #if defined(COLOUR)
        	#include "./IOPorts/IOPorts - ColourMM.h"
        #endif
    #endif
    
    #include "Maximite.h"
    #include "Video.h"
    #include "Keyboard.h"
    #include "Timers.h"
    #include "Serial.h"
    #include "./SDCard/SDCard.h"
    #include "./SDCard/FSconfig.h"
#endif

#include "Files.h"
#include "External.h"
#include "Graphics.h"
#include "MM_Misc.h"
#include "MM_Custom.h"
#include "I2C.h"
#include "Onewire.h"
#include "XModem.h"
#include "Editor.h"
#include "Memory.h"
#include "Audio.h"

#if defined(INCLUDE_CAN)
	#include "CAN2.h"    // JDH
#endif

#if defined(TFT_MAXIMITE)
    #include "Touch.h"
#endif
