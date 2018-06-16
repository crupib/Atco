/***********************************************************************************************************************
MMBasic

Keyboard.h

Include file that contains the globals and defines for Keyboard.c in MMBasic.
  
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


// global keyboard functions
extern void initKeyboard(void);

// global variables
extern volatile int KeyDown;

// the values returned by the standard control keys
#define TAB     	0x9
#define BKSP    	0x8
#define ENTER   	0xd
#define ESC     	0x1b

// the values returned by the function keys
#define F1      	0x91
#define F2      	0x92
#define F3      	0x93
#define F4      	0x94
#define F5      	0x95
#define F6      	0x96
#define F7      	0x97
#define F8      	0x98
#define F9      	0x99
#define F10     	0x9a
#define F11     	0x9b
#define F12     	0x9c

// the values returned by special control keys
#define UP			0x80
#define DOWN		0x81
#define LEFT		0x82
#define RIGHT		0x83
#define INSERT		0x84
#define DEL			0x7f
#define HOME		0x86
#define END			0x87
#define PUP			0x88
#define PDOWN		0x89
#define NUM_ENT		ENTER
#define SLOCK		0x8c
#define ALT			0x8b



// definitions related to setting the keyboard type
#define CONFIG_US		0b111
#define CONFIG_FR		0b001
#define CONFIG_GR		0b010
#define CONFIG_IT		0b011
#define CONFIG_BE		0b100
#define CONFIG_UK		0b101
#define CONFIG_ES		0b110


extern const unsigned int KeyboardOption;

// definitions related to setting the tab spacing
#define CONFIG_TAB2		0b111
#define CONFIG_TAB4		0b001
#define CONFIG_TAB8		0b010
extern const unsigned int TabOption;


