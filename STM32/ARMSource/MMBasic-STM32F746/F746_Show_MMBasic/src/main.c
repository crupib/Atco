//--------------------------------------------------------------
// File     : main.c
// Datum    : 02.02.2016
// Version  : 1.0
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// Board    : STM32F746-Discovery-Board
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL
// Funktion : MMBasic-Port for STM32F746-Discovery Board
//--------------------------------------------------------------
// defines :  STM32F7, USE_USB_HS, USE_USB_FS
//--------------------------------------------------------------


/*****************************************************************************************************************************
Maximite

Main.c

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

#include "stm32_ub_system.h"
#include "stm32_ub_led.h"
#include "stm32_ub_lcd_480x272.h"
#include "stm32_ub_touch_480x272.h"
#include "stm32_ub_font.h"
#include "stm32_ub_uart.h"
#include <stdio.h>
#include <string.h>
#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"
#include "stm32_ub_fatfs.h"
#include "stm32_ub_usb_msc_host.h"
#include "stm32_ub_usb_hid_host.h"
#include "stm32_ub_qflash.h"
#include "editor.h"


extern uint8_t BMP_HEADER[];
void p_Basic_send_Screen(void);



/*****************************************************************************************************************************
Global memory locations
******************************************************************************************************************************/
int FileXfr = false;												// true if we are transfering a file
int USBOn, VideoOn;													// variables controlling the output of the print (and other) commands


// global variables used in MMBasic but must be maintained outside of the interpreter
int ListCnt;
int MMCharPos;
int ExitMMBasicFlag = false;
char *StartEditPoint;
int StartEditChar;
volatile int MMAbort = false;
char *InterruptReturn = NULL;
unsigned int _excep_peek;
int BreakKey = 3;											        // the numeric value of the key that we want to use to interrupt a running program
char *OnKeyGOSUB;                                                   // used to record the location in:  ON KEY location


// global variables added by UB
uint8_t com1_tx_data[50];
TIM_HandleTypeDef Tim7Handle;
volatile uint8_t usb_msc_enable=false;
volatile uint8_t usb_msc_blocked=false;
volatile uint8_t usb_hid_enable=false;
volatile uint8_t usb_hid_blocked=false;
extern uint8_t KBD_Layout;
volatile uint8_t led_d13_enable=true;
int mVCPTimer = 0;
int last_key=-1;
int FirstTimeRun = true;
int baud_console = COM1_BAUD;




// declare functions used in this file
void hardware_init(void);
void tim7_init(void);
void p_Basic_initFlash(void);
void showLogo(void);





#define UB_VERSION  "02.02.2016 / 1.00\r\n"


//--------------------------------------------------------------
int main(void)
{

	static int PromptError = false;
    char *autorun;
    char normal[] = "AUTORUN.BAS";
	int r=0;


  // init system
  UB_System_Init();

  // init the complete hardware
  hardware_init();

  // init global variables
  USBOn = VideoOn = true;

  autorun = normal;



  InitHeap();              										// initilise memory allocation
  initFont();														// initialise the font table
  initVideo();    												// start the video state machine
  HAL_Delay(200); 												// let everything settle

  p_Basic_initFlash();                                     // init Flash and read settings

  // init console uart
  UB_Uart_Init(baud_console);

  MMPrintString("\033[2J\033[H");									// vt100 clear screen and home cursor
  MMcls();														// clear the video buffer


  showLogo();

  InitBasic();

  while(1) {
      if(setjmp(mark) == 0) {                                     // return to here on error or when we want to halt execution
          ShowCursor(false);                                      // just in case it was left on after a CTRL-C
          // if(CurrentLinePtr) StopAudio();                         // stop any background audio only if we were running a program
          if(MMAbort) autoOn = false;
          MMAbort = false;                                        // MMAbort is set on CTRL-C
          FileXfr = false;                                        // we are not doing a file transfer
          while(MMInkey() != -1);                                 // clear the input buffer

          // if this is the first time that MMBasic has been run check for AUTORUN
          if(FirstTimeRun) {
        	  FirstTimeRun = false;                               // we only run this code once
        	  if(DefaultDrive == SDFS) {
        		  if(UB_Fatfs_CheckMedia(MMC_1)==FATFS_OK) {
        			  OptionErrorAbort = false;                   // do not flag an error if the file does not exist
        			  r = SDCheckFileName(autorun);               // and check for the autorun file on the SDCard fs
        			  OptionErrorAbort = true;                    // restore normal file error handling

            		  if(r) {
            			  mergefile(autorun, NULL);                       // load the program
            			  ExecuteProgram(PMemory + 1);                    // and execute it
            		  }
        		  }
        	  }
        	  else if(DefaultDrive == USBFS) {
        		  if(UB_Fatfs_CheckMedia(USB_0)==FATFS_OK) {
        			  OptionErrorAbort = false;                   // do not flag an error if the file does not exist
        			  r = USBCheckFileName(autorun);               // and check for the autorun file on the SDCard fs
        			  OptionErrorAbort = true;                    // restore normal file error handling

            		  if(r) {
            			  mergefile(autorun, NULL);                       // load the program
            			  ExecuteProgram(PMemory + 1);                    // and execute it
            		  }
        		  }
        	  }
          }

          SetFont((GetFlashOption(&FontOption)-1), 1, 0); // set a reasonable default font

          DefaultBgColour = CurTxtBgColour;                  // reset colours
          CurrentBgColour = CurTxtBgColour;
          DefaultFgColour = CurTxtFgColour;                  // reset colours
          CurrentFgColour = CurTxtFgColour;

          // show edit layer
          UB_LCD_SetLayer_2();
          UB_LCD_SetTransparency(255);


          Cursor = C_STANDARD;
          AutoLineWrap = true;
          PrintPixelMode = 0;
          USBOn = VideoOn = true;                                 // turn on the outputs;

          ClearStack();
      	m_alloc(M_EDIT, false);                                 // clear any memory allocated to the editor
          TempStringClearStart = 0;                               // this should not be needed but it ensures that all temp space will be cleared
          ClearTempSpace();                                       // clear temp string space (the editor could have used a lot)

          if(MMCharPos > 1) MMPrintString("\r\n");                // prompt should be on a new line
          if((MMPosY % (fontHeight * fontScale)) != 0)
              MMPosY += (fontHeight * fontScale) - (MMPosY % (fontHeight * fontScale)); // and ensure that it is an even scan line

          CurrentLinePtr = NULL;                                  // do not use the line number in error reporting
          if(PromptError || *PromptString == 0) {                 // if there has been an error in printing the prompt or there is no prompt set
              PromptError = false;
              *PromptString = 0;                                  // reset the prompt in case we got here via an error while printing the prompt
              MMPrintString("> ");                                // print the simple (safe) prompt
          } else {
              PromptError = true;                                 // set a flag so that we will know if an error occured
              MMPrintString(getCstring(PromptString));            // evaluate prompt string and output the result
              PromptError = false;                                // no error occured so reset the flag
          }
          ClearTempSpace();                                       // clear temp string space (might have been used by the prompt)
          if(autoOn) {                                            // the AUTO command is running
              if(IsValidLine(autoNext)) {
                  MMputchar('*');                                 // indicate that this will overwrite
                  sprintf(inpbuf, "%3d ", autoNext);              // preload the buffer with the line bumber
              } else
                  sprintf(inpbuf, "%4d ", autoNext);
          } else
              *inpbuf = 0;                                        // empty the input buffer
          EditInputLine();                                        // get the input
          if(!*inpbuf) continue;                                  // ignore an empty line
          InsertLastcmd(inpbuf);                                  // save in case we want to edit it later
          tokenise(true);                                         // turn into executable code
          if(*tknbuf != T_LINENBR) {                              // if there is not a line number
        	  // ToDo : add "run xxx"
              //TryLoadProgram();                                   // try to load/run the program if this is an implied RUN command
              ExecuteProgram(tknbuf);                             // now execute whatever we have in the token buffer
          } else {                                                // we are adding this line to program memory
              ClearRuntime();                                     // clear any leftovers from the previous program
              AddProgramLine(false);	                            // add to program memory

          }
      }
      else {
          // we got here via a long jump which means an error or CTRL-C
          ContinuePoint = nextstmt;                               // save where we were in the program in case the user wants to invoke the continue command
      }
  }

}


// get a character from USB-Keyboard
int MMInkeyTaskUSB(void) {
	int c = -1;
	int key_c =-1, shift_s=-1;

	  // get char from USB-HID-Keyboard
	  key_c=Keyboard_getChar(&shift_s);
	  if(key_c>0) {
		c=key_c;
		if(c==BreakKey) MMAbort = true; // CTRL+"c"

		// check "special" key combinations	for STM32F746
		if((c==F12) && ((shift_s&SHIFTBIT_LALT)!=0)) { // ALT+F12 => send screenshot to pc
		  c=-1;
		  p_Basic_send_Screen();
		}
	    if((key_c==F11) && ((shift_s&SHIFTBIT_LALT)!=0)) { // ALT+F11 => change Keyboard Layout
	    	c=-1;
			  if(KBD_Layout==0) {
				  KBD_Layout=1;
				  MMPrintString("\r\n Keyboard Layout = QWERTY \r\n");
			  }
			  else if(KBD_Layout==1) {
				  KBD_Layout=2;
				  MMPrintString("\r\n Keyboard Layout = AZERTY \r\n");
			  }
			  else if(KBD_Layout==2) {
				  KBD_Layout=0;
				  MMPrintString("\r\n Keyboard Layout = QWERTZ \r\n");
			  }
		}
	  }

	return c;

}





// get a character from USB-VCP
int MMInkeyTaskVCP(void) {
  int c = -1;

  // get char from USB-VCP-Port
  c=MM_Uart_ReveiveByte(COM1);

  if((c==-1) && (SerialConsole)) {										// if there is a serial console
	c = SerialGetchar(SerialConsole);							// get the char from the serial port (returns -1 if nothing)
  }

  return c;
}



// readout escape sequence
int MMInkeyESCSeq(void) {
  int c=-1;
  int tc = -1;
  int ttc = -1;
  static int c1 = -1;
  static int c2 = -1;
  static int c3 = -1;
  static int c4 = -1;

  if(c1 != -1) {													// check if there are discarded chars from a previous sequence
	c = c1; c1 = c2; c2 = c3; c3 = c4; c4 = -1;					// shuffle the queue down
	return c;													// and return the head of the queue
  }

  c = MMInkeyTaskVCP();
	if((c == 0x1b) && (!FileXfr)) {
		mVCPTimer = 0;												// start the timer
		while((c = MMInkeyTaskVCP()) == -1 && mVCPTimer < 2);		// get the second char with a delay to allow the next char to arrive
		if(c != '[') { c1 = c; return 0x1b; }						// must be a square bracket
		while((c = MMInkeyTaskVCP()) == -1 && mVCPTimer < 4);		// get the third char with delay
		if(c == 'A') return UP;										// the arrow keys are three chars
		if(c == 'B') return DOWN;
		if(c == 'C') return RIGHT;
		if(c == 'D') return LEFT;
		if(c < '1' && c > '6') { c1 = '['; c2 = c; return 0x1b; }	// the 3rd char must be in this range
		while((tc = MMInkeyTaskVCP()) == -1 && mVCPTimer < 6);		// delay some more to allow the final chars to arrive
		if(tc == '~') {												// all 4 char codes must be terminated with ~
			if(c == '1') return HOME;
			if(c == '2') return INSERT;
			if(c == '3') return DEL;
			if(c == '4') return END;
			if(c == '5') return PUP;
			if(c == '6') return PDOWN;
			c1 = '['; c2 = c; c3 = tc; return 0x1b;					// not a valid 4 char code
		}
		while((ttc = MMInkeyTaskVCP()) == -1 && mVCPTimer < 8);		// get the 5th char with delay
		if(ttc == '~') {											// must be a ~
			if(c == '1') {
				if(tc >='1' && tc <= '5') return F1 + (tc - '1');	// F1 to F5
				if(tc >='7' && tc <= '9') return F6 + (tc - '7'); 	// F6 to F8
			}
			if(c == '2') {
				if(tc =='0' || tc == '1') return F9 + (tc - '0'); 	// F9 and F10
				if(tc =='3' || tc == '4') return F11 + (tc - '3'); 	// F11 and F12
				if(tc =='5') return F3 + 0x20; 	                    // SHIFT-F3
			}
		}
		// nothing worked so bomb out
		c1 = '['; c2 = c; c3 = tc; c4 = ttc;
		return 0x1b;
	}


  return c;
}

// check if key is in buffer
int isKeyInBuffer(void) {
	int c;

    if(MM_Uart_GetRxStatus(COM1)>0) return true;
    if((SerialConsole==1) && (MM_Uart_GetRxStatus(COM6)>0)) return true;
    if((SerialConsole==2) && (MM_Uart_GetRxStatus(COM7)>0)) return true;
    c=MMInkeyTaskUSB();
    if(c>0) {
    	last_key=c;
    	return true;
    }
    if(last_key>0) return true;

    return false;
}


// get  a key from usb-vcp or keyboard
int MMInkey(void) {
	int c=-1;

	  // read Key (or ESC-Sequence) from USB-VCP
	  c=MMInkeyESCSeq();
	  // if no vcp input, read usb-keyboard
	  if(c==-1) {
	    // read Key from UBS-Keyboard
	    c = MMInkeyTaskUSB();
	  }
	  else {
		  if((c==BreakKey) && (!FileXfr)) MMAbort = true;
	  }

	if(MMAbort) longjmp(mark, 1);									// jump back to the input prompt

	if(last_key>0) {
		c=last_key;
		last_key=-1;
	}

    return c;
}

// get  a key from usb-vcp or keyboard (called by pause command)
int MMInkeyPause(void) {
	int c=-1;

	  // read Key (or ESC-Sequence) from USB-VCP
	  c=MMInkeyESCSeq();
	  // if no vcp input, read usb-keyboard
	  if(c==-1) {
	    // read Key from UBS-Keyboard
	    c = MMInkeyTaskUSB();
	  }
	  else {
		  if((c==BreakKey) && (!FileXfr)) MMAbort = true;
	  }

	if(MMAbort) longjmp(mark, 1);									// jump back to the input prompt

	if(c>0) last_key=c;

    return c;
}


// get a keystroke.  Will wait forever for input
// if the char is a cr then replace it with a newline (lf)
int MMgetchar(void) {
	int c=-1;

	do {
		ShowCursor(true);
		c = MMInkey();
		if(c == '\r') c = '\n';
	} while(c == -1);
	ShowCursor(false);
	return c;
}


/****************************************************************************************************************************
Video/USB output functions
*****************************************************************************************************************************/


// put a character out to the video screen, the serial console and the USB interface
char MMputchar(char c) {
	if(!FileXfr && VideoOn) VideoPutc(c);							// draw the char on the video screen
	if((c & 0x80) && !FileXfr) return c;                            // don't print anything with the top bit set to USB or console
	if(SerialConsole) SerialPutchar(SerialConsole, c);				// send it to the serial console if enabled
	if(!(SerialConsole && FileXfr)) USBPutchar(c);			        // send it to the USB
	return c;
}


// put a character out to the USB interface
void USBPutchar(char c) {
	if(!USBOn) return;
	UB_Uart_SendByte(COM1,c); // COM-1 => USB-VCP (CN14)
}


// put a vt100 escape sequence out on the USB
// escape sequences must not be split into separate USB transmissions
void USBPutEscape(char *p) {
	if(!USBOn) return;
	while(*p) UB_Uart_SendByte(COM1,*p++); // COM-1 => USB-VCP (CN14)
}





// return the current option state
int GetFlashOption(const unsigned int *w) {
	unsigned int t;
	unsigned char l,h;
	t = *w;

	// flash data allready in "mm_flash_data"
	if(t==FontOption) {
		// return font option
		if(mm_flash_data[MM_FLASH_FONT_BYTE]<1) return DEFAULT_FONT;
		if(mm_flash_data[MM_FLASH_FONT_BYTE]>NBRFONTS_IN_FLASH) return DEFAULT_FONT;
		if(mm_flash_data[MM_FLASH_FONT_BYTE]==3) return DEFAULT_FONT;
		return mm_flash_data[MM_FLASH_FONT_BYTE];
	}
	if(t==TabOption) {
		// return tab option
    	if(mm_flash_data[MM_FLASH_TAB_BYTE]==CONFIG_TAB2) return CONFIG_TAB2;
    	if(mm_flash_data[MM_FLASH_TAB_BYTE]==CONFIG_TAB4) return CONFIG_TAB4;
    	if(mm_flash_data[MM_FLASH_TAB_BYTE]==CONFIG_TAB8) return CONFIG_TAB8;
    	return CONFIG_TAB2; // default
    }
	if(t==VideoOption) {
		// return video option
		if(mm_flash_data[MM_FLASH_VIDEO_BYTE]==CONFIG_ON) return CONFIG_ON;
		if(mm_flash_data[MM_FLASH_VIDEO_BYTE]==CONFIG_OFF) return CONFIG_OFF;
		return CONFIG_ON; // default
	}
	if(t==KeyboardOption) {
		// return keyboard option
		if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_US) return CONFIG_US;
		if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_FR) return CONFIG_FR;
		if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_GR) return CONFIG_GR;
		return CONFIG_US;  // default
	}
	if(t==CaseOption) {
		// return case option
		if(mm_flash_data[MM_FLASH_CASE_BYTE]==CONFIG_TITLE) return CONFIG_TITLE;
		if(mm_flash_data[MM_FLASH_CASE_BYTE]==CONFIG_LOWER) return CONFIG_LOWER;
		if(mm_flash_data[MM_FLASH_CASE_BYTE]==CONFIG_UPPER) return CONFIG_UPPER;
		return CONFIG_TITLE;  // default
	}
	if(t==DriveOption) {
		// return drive option
		if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==FLASHFS) return FLASHFS;
		if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==SDFS) return SDFS;
		if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==USBFS) return USBFS;
		return DefaultDrive;  // default
	}
	if(t==BGColorOption) {
		// return background color option
		l=mm_flash_data[MM_FLASH_BGCOL_LOBYTE];
		h=mm_flash_data[MM_FLASH_BGCOL_HIBYTE];
		return ((h<<8)|l);
	}
	if(t==FGColorOption) {
		// return foreground color option
		l=mm_flash_data[MM_FLASH_FGCOL_LOBYTE];
		h=mm_flash_data[MM_FLASH_FGCOL_HIBYTE];
		return ((h<<8)|l);
	}
	if(t==AutorunOption) {
		// return autorun option
		if(mm_flash_data[MM_FLASH_AUTORUN_BYTE]==CONFIG_ON) return CONFIG_ON;
		if(mm_flash_data[MM_FLASH_AUTORUN_BYTE]==CONFIG_OFF) return CONFIG_OFF;
		return CONFIG_ON; // default
	}
	if(t==BaudrateOption) {
		// return baudrate option
		l=mm_flash_data[MM_FLASH_BAUD_LOBYTE];
		h=mm_flash_data[MM_FLASH_BAUD_HIBYTE];
		t=((h<<8)|l);
		return (t*10);
	}

  return 0b11;
}


// set a new option state
void SetFlashOption(const unsigned int *w, int x) {
	unsigned int t,write_ok=0;
	t = *w;

  if(t==FontOption) {
	  // set font option
	if((x>=1) && (x<=NBRFONTS_IN_FLASH)) {
		mm_flash_data[MM_FLASH_FONT_BYTE]=(uint8_t)(x);
	}
	write_ok=1;
  }
  if(t==TabOption) {
	// set tab option
	if(x==CONFIG_TAB2) mm_flash_data[MM_FLASH_TAB_BYTE]=(uint8_t)(CONFIG_TAB2);
	if(x==CONFIG_TAB4) mm_flash_data[MM_FLASH_TAB_BYTE]=(uint8_t)(CONFIG_TAB4);
	if(x==CONFIG_TAB8) mm_flash_data[MM_FLASH_TAB_BYTE]=(uint8_t)(CONFIG_TAB8);
	write_ok=1;
  }
  if(t==VideoOption) {
	  // set video option
	if(x==CONFIG_ON) mm_flash_data[MM_FLASH_VIDEO_BYTE]=(uint8_t)(CONFIG_ON);
	if(x==CONFIG_OFF) mm_flash_data[MM_FLASH_VIDEO_BYTE]=(uint8_t)(CONFIG_OFF);
	write_ok=1;
  }
  if(t==KeyboardOption) {
	  // set keyboard option
	  if(x==CONFIG_US) mm_flash_data[MM_FLASH_KEYBRD_BYTE]=(uint8_t)(CONFIG_US);
	  if(x==CONFIG_FR) mm_flash_data[MM_FLASH_KEYBRD_BYTE]=(uint8_t)(CONFIG_FR);
	  if(x==CONFIG_GR) mm_flash_data[MM_FLASH_KEYBRD_BYTE]=(uint8_t)(CONFIG_GR);
	  write_ok=1;

		// activate keyboard settings
		if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_US) KBD_Layout=1;
		if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_FR) KBD_Layout=2;
		if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_GR) KBD_Layout=0;
  }
  if(t==CaseOption) {
	  // set case option
	  if(x==CONFIG_TITLE) mm_flash_data[MM_FLASH_CASE_BYTE]=(uint8_t)(CONFIG_TITLE);
	  if(x==CONFIG_LOWER) mm_flash_data[MM_FLASH_CASE_BYTE]=(uint8_t)(CONFIG_LOWER);
	  if(x==CONFIG_UPPER) mm_flash_data[MM_FLASH_CASE_BYTE]=(uint8_t)(CONFIG_UPPER);
	  write_ok=1;
  }
  if(t==DriveOption) {
	  // set drive option
	  if(x==FLASHFS) mm_flash_data[MM_FLASH_DRIVE_BYTE]=(uint8_t)(FLASHFS);
	  if(x==SDFS) mm_flash_data[MM_FLASH_DRIVE_BYTE]=(uint8_t)(SDFS);
	  if(x==USBFS) mm_flash_data[MM_FLASH_DRIVE_BYTE]=(uint8_t)(USBFS);
	  write_ok=1;

	// activate drive settings
	if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==FLASHFS) DefaultDrive=FLASHFS;
	if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==SDFS) DefaultDrive=SDFS;
	if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==USBFS) DefaultDrive=USBFS;
  }
  if(t==BGColorOption) {
	  // set background color option
	  mm_flash_data[MM_FLASH_BGCOL_LOBYTE]=(uint8_t)(x&0xFF);
	  mm_flash_data[MM_FLASH_BGCOL_HIBYTE]=(uint8_t)((x>>8)&0xFF);
	  write_ok=1;
	  // activate settings
	  DefaultBgColour=CurrentBgColour=DefTxtBgColour=CurTxtBgColour=(x&0xFFFF);
  }
  if(t==FGColorOption) {
	  // set foreground color option
	  mm_flash_data[MM_FLASH_FGCOL_LOBYTE]=(uint8_t)(x&0xFF);
	  mm_flash_data[MM_FLASH_FGCOL_HIBYTE]=(uint8_t)((x>>8)&0xFF);
	  write_ok=1;
	  // activate settings
	  DefaultFgColour=CurrentFgColour=DefTxtFgColour=CurTxtFgColour=(x&0xFFFF);
  }
  if(t==AutorunOption) {
	  // set autorun option
	if(x==CONFIG_ON) mm_flash_data[MM_FLASH_AUTORUN_BYTE]=(uint8_t)(CONFIG_ON);
	if(x==CONFIG_OFF) mm_flash_data[MM_FLASH_AUTORUN_BYTE]=(uint8_t)(CONFIG_OFF);
	write_ok=1;
  }
  if(t==BaudrateOption) {
	  // set baudrate option
	  t=(x/10);
	  mm_flash_data[MM_FLASH_BAUD_LOBYTE]=(uint8_t)(t&0xFF);
	  mm_flash_data[MM_FLASH_BAUD_HIBYTE]=(uint8_t)((t>>8)&0xFF);
	  write_ok=1;
  }

  if(write_ok==1) {
		// delete flash
		UB_QFlash_Erase_SubSector(MM_FLASH_DATA_SUBSECTOR);
		// write settings in flash
		UB_QFlash_Write_Block8b(MM_FLASH_DATA_START_ADR,MM_FLASH_DATA_CNT,mm_flash_data);
  }
}





//--------------------------------------------------------------
// function from ub for STM32F746-Disco
//--------------------------------------------------------------


//--------------------------------------------------------------
void hardware_init(void)
{
  // led init
  UB_Led_Init();
  UB_Led_Off(LED_GREEN);

  // init lcd and clear screen
  UB_LCD_Init();
  UB_LCD_LayerInit_Fullscreen();
  UB_LCD_SetLayer_2();
  UB_LCD_FillLayer(DefaultBgColour);

  // init Touch
  UB_Touch_Init();

  // USB-HID-Host
  UB_USB_HID_HOST_Init();

  // FATFS
#if FATFS_USE_USB_MEDIA==1
  // USB-MSC-Host
  UB_USB_MSC_HOST_Init();
#endif
  UB_Fatfs_Init();

  HAL_Delay(100);

  // init and start timer-7
  tim7_init();

  // enable usb_hid
  usb_hid_enable=true;
  usb_hid_blocked=false;

  // enable usb_msc
  usb_msc_enable=true;
  usb_msc_blocked=false;

  // Random number init
  Random_Init();

  // Init 3DObjects data
  Init3d();

  // Init Polygons data
  GFX_PolyInit();

  // init external QFlash
  UB_QFlash_Init();
}

//--------------------------------------------------------------
// timer-7 (1ms)
//--------------------------------------------------------------
void tim7_init(void)
{
  uint32_t prescaler = 0;


  // 1ms = 1kHz
  prescaler = (uint32_t)((SystemCoreClock / 2) / 1000000) - 1; // 1000 kHz
  Tim7Handle.Instance = TIM7;
  Tim7Handle.Init.Period            = 1000 - 1; // 1kHz
  Tim7Handle.Init.Prescaler         = prescaler;
  Tim7Handle.Init.ClockDivision     = 0;
  Tim7Handle.Init.CounterMode       = TIM_COUNTERMODE_UP;
  Tim7Handle.Init.RepetitionCounter = 0;
  HAL_TIM_Base_Init(&Tim7Handle);
  HAL_TIM_Base_Start_IT(&Tim7Handle);
}



//--------------------------------------------------------------
// ISR (1ms)
//--------------------------------------------------------------
void TIM7_IRQHandler(void)
{
  static uint32_t led_delay=0;

  HAL_TIM_IRQHandler(&Tim7Handle);

  mSecTimer++;  // For timer function
  mPauseTimer++;// For Pause function
  iPauseTimer++;// For Pause function
  mKeyDelayTimer++; // For USB-Keyboard delay
  mVCPTimer++; // For VCP delay

  SecondsTimer++;
  if(SecondsTimer>=1000) {
	  SecondsTimer=0;
		if(++second >= 60) {										// keep track of the time and date
			second = 0 ;
			if(++minute >= 60) {
				minute = 0;
				if(++hour >= 24) {
					hour = 0;
					if(++day > DaysInMonth[month + ((month == 2 && (year % 4) == 0)?1:0)]) {
						day = 1;
						if(++month > 12) {
							month = 1;
							year++;
						}
					}
				}
			}
		}
  }

	if(InterruptUsed) {
  	int i;
	    for(i = 0; i < NBRSETTICKS; i++) TickTimer[i]++;			// used in the interrupt tick
	}


  // usb-hid
  if(usb_hid_enable==true) {
	  if(usb_hid_blocked==false) {
		  usb_hid_blocked=true;
		  UB_USB_HID_HOST_Do();
		  usb_hid_blocked=false;
	  }
  }
  else led_delay=0; // to display error

#if FATFS_USE_USB_MEDIA==1
  // usb-msc
  if(usb_msc_enable==true) {
	  if(usb_msc_blocked==false) {
		  usb_msc_blocked=true;
		  UB_USB_MSC_HOST_Do();
		  usb_msc_blocked=false;
	  }
  }
#endif

  if(++CursorTimer > CURSOR_OFF + CURSOR_ON) CursorTimer = 0;		// used to control cursor blink rate


  if(led_d13_enable==true) {
    led_delay++;
    if(led_delay>500) {
	  led_delay=0;
	  UB_Led_Toggle(LED_GREEN);
    }
  }
}

//--------------------------------------------------------------
void HAL_TIM_Base_MspInit(TIM_HandleTypeDef *htim)
{

  __HAL_RCC_TIM7_CLK_ENABLE();
  HAL_NVIC_SetPriority(TIM7_IRQn, 3, 0);
  HAL_NVIC_EnableIRQ(TIM7_IRQn);
}


//--------------------------------------------------------------
// send screenshot
//--------------------------------------------------------------
void p_Basic_send_Screen(void)
{
  uint32_t n,adr;
  uint16_t x,y,color;
  uint8_t r,g,b;

  // send bmp header
  for(n=0;n<54;n++) {
    UB_Uart_SendByte(COM1,BMP_HEADER[n]);
  }

  // set screen buffer to send
  adr=LCD_CurrentFrameBuffer;

  // send picture data
  for(y=0;y<LCD_MAXY;y++) {
    for(x=0;x<LCD_MAXX;x++) {
      n=(LCD_MAXY-y-1)*(LCD_MAXX*2)+(x*2);
      color=*(volatile uint16_t*)(adr+n);
      r=((color&0xF800)>>8);  // 5bit red
      g=((color&0x07E0)>>3);  // 6bit green
      b=((color&0x001F)<<3);  // 5bit blue
      UB_Uart_SendByte(COM1,b);
      UB_Uart_SendByte(COM1,g);
      UB_Uart_SendByte(COM1,r);
    }
  }
}

//--------------------------------------------------------------
// show logo
//--------------------------------------------------------------
void showLogo(void)
{
	DMA2D_Koord koord;

	koord.dest_xp=0;
	koord.dest_yp=0;
	koord.source_h=logo.height;
	koord.source_w=logo.width;
	koord.source_xp=0;
	koord.source_yp=0;
	GFX_CopyImgDMA(&logo,koord);

	// move cursor under logo (only on lcd)
	USBOn = false;
	SCursor(47,5);
	CurTxtBgColour = BLACK;
	CurTxtFgColour = RED;
	MMPrintString(UB_VERSION);
	CurTxtBgColour = DefTxtBgColour;
	CurTxtFgColour = DefTxtFgColour;
	SCursor(0,8);
	USBOn = true;

	// print copyright (only on console)
	VideoOn = false;
	MMPrintString(MES_SIGNON);
	MMPrintString(MES_COPYRIGHT);
	MMPrintString("\r\n");
	VideoOn = true;
}

//--------------------------------------------------------------
// check and init external Flash
//--------------------------------------------------------------
void p_Basic_initFlash(void)
{
	uint8_t magic_ok=0;
	uint8_t magic_ver=0;
	uint8_t write_ok=0;
	int t;

	// read all flash data
	UB_QFlash_Read_Block8b(MM_FLASH_DATA_START_ADR,MM_FLASH_DATA_CNT,mm_flash_data);

	// check magic number
	if(mm_flash_data[MM_FLASH_MAGIC_NR1]!='U') magic_ok=1;
	if(mm_flash_data[MM_FLASH_MAGIC_NR2]!='w') magic_ok=1;
	if(mm_flash_data[MM_FLASH_MAGIC_NR3]=='e') magic_ver=1; // version 1 (initial)
	if(mm_flash_data[MM_FLASH_MAGIC_NR3]=='2') magic_ver=2; // version 2 (add fg+bg color)
	if(mm_flash_data[MM_FLASH_MAGIC_NR3]=='3') magic_ver=3; // version 3 (baudrate+autorun)

    if((magic_ok!=0) || (magic_ver<1)) { // version 1
    	magic_ver=0;
		// init error, set default settings
		mm_flash_data[MM_FLASH_MAGIC_NR1]='U';
		mm_flash_data[MM_FLASH_MAGIC_NR2]='w';
		mm_flash_data[MM_FLASH_MAGIC_NR3]='e';
		// default values
		mm_flash_data[MM_FLASH_FONT_BYTE]=(uint8_t)(DEFAULT_FONT);
		mm_flash_data[MM_FLASH_TAB_BYTE]=(uint8_t)(CONFIG_TAB2);
		mm_flash_data[MM_FLASH_VIDEO_BYTE]=(uint8_t)(CONFIG_ON);
		mm_flash_data[MM_FLASH_KEYBRD_BYTE]=(uint8_t)(CONFIG_US);
		mm_flash_data[MM_FLASH_CASE_BYTE]=(uint8_t)(CONFIG_TITLE);
		mm_flash_data[MM_FLASH_DRIVE_BYTE]=(uint8_t)(DefaultDrive);
		write_ok=1;
	}
    if(magic_ver<2) { // version 2
    	// version
    	mm_flash_data[MM_FLASH_MAGIC_NR3]='2';
    	// default values
		mm_flash_data[MM_FLASH_BGCOL_LOBYTE]=(uint8_t)(DefTxtBgColour&0xFF);
		mm_flash_data[MM_FLASH_BGCOL_HIBYTE]=(uint8_t)((DefTxtBgColour>>8)&0xFF);
		mm_flash_data[MM_FLASH_FGCOL_LOBYTE]=(uint8_t)(DefTxtFgColour&0xFF);
		mm_flash_data[MM_FLASH_FGCOL_HIBYTE]=(uint8_t)((DefTxtFgColour>>8)&0xFF);
    	write_ok=1;
    }
    if(magic_ver<3) { // version 3
    	// version
    	mm_flash_data[MM_FLASH_MAGIC_NR3]='3';
    	// default values
    	mm_flash_data[MM_FLASH_AUTORUN_BYTE]=(uint8_t)(CONFIG_ON);
    	t=(COM1_BAUD/10);
		mm_flash_data[MM_FLASH_BAUD_LOBYTE]=(uint8_t)(t&0xFF);
		mm_flash_data[MM_FLASH_BAUD_HIBYTE]=(uint8_t)((t>>8)&0xFF);
		write_ok=1;
    }
    if(write_ok!=0) {
		// delete flash
		UB_QFlash_Erase_SubSector(MM_FLASH_DATA_SUBSECTOR);
		// write settings in flash
		UB_QFlash_Write_Block8b(MM_FLASH_DATA_START_ADR,MM_FLASH_DATA_CNT,mm_flash_data);
    }

	// activate keyboard settings
	if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_US) KBD_Layout=1;
	if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_FR) KBD_Layout=2;
	if(mm_flash_data[MM_FLASH_KEYBRD_BYTE]==CONFIG_GR) KBD_Layout=0;

	// activate drive settings
	if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==FLASHFS) DefaultDrive=FLASHFS;
	if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==SDFS) DefaultDrive=SDFS;
	if(mm_flash_data[MM_FLASH_DRIVE_BYTE]==USBFS) DefaultDrive=USBFS;

	// activate color settings
	DefaultBgColour=CurrentBgColour=DefTxtBgColour=CurTxtBgColour=GetFlashOption(&BGColorOption);
	DefaultFgColour=CurrentFgColour=DefTxtFgColour=CurTxtFgColour=GetFlashOption(&FGColorOption);

	// activate autorun
	if(mm_flash_data[MM_FLASH_AUTORUN_BYTE]==CONFIG_ON) FirstTimeRun=true;
	if(mm_flash_data[MM_FLASH_AUTORUN_BYTE]==CONFIG_OFF) FirstTimeRun=false;

	// activate baudrate
	baud_console = GetFlashOption(&BaudrateOption);
}
