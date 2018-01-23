/***********************************************************************************************************************
MMBasic

Misc.c

Handles all the miscelaneous commands and functions in MMBasic.  These are commands and functions that do not
comfortably fit anywhere else.

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


#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

struct s_inttbl inttbl[NBRPINS + 1];
char *InterruptReturn;

int TickPeriod[NBRSETTICKS];
volatile int TickTimer[NBRSETTICKS];
char *TickInt[NBRSETTICKS];


int mSecTimer = 0;
int mPauseTimer = 0;
int iPauseTimer = 0;
int CursorTimer = 0;
const unsigned int DriveOption = 0x5fffffff;	 // use to hold the default drive
const unsigned int BGColorOption = 0x6fffffff;	 // use to hold the default background color
const unsigned int FGColorOption = 0x7fffffff;	 // use to hold the default foreground color
const unsigned int AutorunOption = 0x8fffffff;	 // use to hold the default autorun option
const unsigned int BaudrateOption = 0x9fffffff;	 // use to hold the default baudrate setting


// variables for spi1
int spi1 = 0;														// true if SPI1 is enabled
int spi1_ss =0;

// variables for spi2
int spi2 = 0;														// true if SPI2 is enabled
int spi2_ss =0;

int SecondsTimer =0;
int second = 0;						        // date/time counters
int minute = 0;
int hour = 0;
int day = 1;
int month = 1;
int year = 2016;
const char DaysInMonth[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };








/********************************************************************************************************************************************
Miscelaneous commands and functions
===================================

Each function is responsible for decoding a command
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

********************************************************************************************************************************************/



// this is invoked as a command (ie, TIMER = 0)
// search through the line looking for the equals sign and step over it,
// evaluate the rest of the command and save in the timer
void cmd_timer(void) {
	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) error("Invalid syntax");
	mSecTimer = getinteger(++cmdline);
}



// this is invoked as a function
void fun_timer(void) {
	fret = mSecTimer;
}



void cmd_pause(void) {
	static int interrupted = false;
    float f;
    f = getnumber(cmdline);
    if(f < 0) error("Number out of bounds");
    if(f < 0.05) return;

	if(InterruptReturn == NULL) {
		// we are running pause in a normal program
		// first check if we have reentered (from an interrupt) and only zero the timer if we have NOT been interrupted.
		// This means an interrupted pause will resume from where it was when interrupted
		if(!interrupted) mPauseTimer = 0;
		interrupted = false;

		while(mPauseTimer < MMround(f)) {
			MMInkeyPause();	// check for receiving a break key
			if(check_interrupt()) {
				// if there is an interrupt fake the return point to the start of this stmt
				// and return immediately to the program processor so that it can send us off
				// to the interrupt routine.  When the interrupt routine finishes we should reexecute
				// this stmt and because the variable interrupted is static we can see that we need to
				// resume pausing rather than start a new pause time.
				while(*cmdline && *cmdline != cmdtoken + C_BASETOKEN) cmdline--;	// step back to find the command token
				InterruptReturn = cmdline;							// point to it
				interrupted = true;								    // show that this stmt was interrupted
				return;											    // and let the interrupt run
			}
		}
	}
	else {
		// we are running pause in an interrupt, this is much simpler but note that
		// we use a different timer from the main pause code (above)
		iPauseTimer = 0;
		while(iPauseTimer < MMround(f)) {
			MMInkeyPause();	// check for receiving a break key
		}
	}
}



// this is invoked as a command (ie, date$ = "6/7/2010")
// search through the line looking for the equals sign and step over it,
// evaluate the rest of the command, split it up and save in the system counters
void cmd_date(void) {
	char *arg;
	int d, m, y;
	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) error("Invalid syntax");
	++cmdline;
	arg = getCstring(cmdline);
	{
		getargs(&arg, 5, "-/.");										// this is a macro and must be the first executable stmt in a block
		if(argc != 5) error("Invalid syntax");
		d = atoi(argv[0]);
		m = atoi(argv[2]);
		y = atoi(argv[4]);
		if(y >= 0 && y < 100) y += 2000;
		if(d < 1 || d > 31 || m < 1 || m > 12 || y < 2000 || y > 2999) error("Invalid date");

		day = d;
		month = m;
		year = y;
	}
}



// this is invoked as a function
void fun_date(void) {
	sret = GetTempStringSpace();									// this will last for the life of the command
	sprintf(sret, "%02d-%02d-%04d", day, month, year);
	CtoM(sret);
}



// this is invoked as a command (ie, time$ = "6:10:45")
// search through the line looking for the equals sign and step over it,
// evaluate the rest of the command, split it up and save in the system counters
void cmd_time(void) {
	char *arg;
	int h = 0;
	int m = 0;
	int s = 0;

	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) error("Invalid syntax");
	++cmdline;
	arg = getCstring(cmdline);
	{
		getargs(&arg, 5, ":");								// this is a macro and must be the first executable stmt in a block
		if(argc%2 == 0) error("Invalid syntax");
		h = atoi(argv[0]);
		if(argc >= 3) m = atoi(argv[2]);
		if(argc == 5) s = atoi(argv[4]);
		if(h < 0 || h > 24 || m < 0 || m > 60 || s < 0 || s > 60) error("Invalid time");
		hour = h;
		minute = m;
		second = s;
		SecondsTimer = 0;
	}
}




// this is invoked as a function
void fun_time(void) {
	sret = GetTempStringSpace();									// this will last for the life of the command
	sprintf(sret, "%02d:%02d:%02d", hour, minute, second);
	CtoM(sret);
}



void cmd_ireturn(void){
	if(InterruptReturn == NULL) error("Return from interrupt when not in an interrupt");
	checkend(cmdline);
	nextstmt = InterruptReturn;
	InterruptReturn = NULL;
	if(LocalIndex) 	ClearVars(LocalIndex--);                        // delete any local variables
}


// set up the tick interrupt
void cmd_settick(void){
	int period;
	int irq;
	getargs(&cmdline, 5, ",");
	if(!(argc == 3 || argc == 5)) error("Invalid syntax");
	period = getinteger(argv[0]);
	if(argc == 5)
	    irq = getinteger(argv[4]) - 1;
	else
	    irq = 0;
	if(period < 0 || irq < 0 || irq >= NBRSETTICKS) error("Number out of bounds");
	if(period == 0)
		TickInt[irq] = NULL;										// turn off the interrupt
	else {
		TickPeriod[irq] = period;
		TickInt[irq] = GetIntAddress(argv[2]);					    // get a pointer to the interrupt routine
		TickTimer[irq] = 0;										    // set the timer running
		InterruptUsed = true;
	}
}



void cmd_copyright(void) {
	MMPrintString("STM32F746 MMBasic V" VERSION "\r\n");
	MMPrintString("Copyright (c) " YEAR " Geoff Graham.\r\n");
	MMPrintString("All Rights Reserved.  See http://mmbasic.com.\r\n\n");
	MMPrintString("This is free software and comes with absolutely\r\n");
	MMPrintString("no warranty implied or otherwise.\r\n\n");
	MMPrintString("Updates at http://mmbasic.com/downloads.html\r\n");
}

// init SPI Port
void cmd_spi(void) {
    char *p;

    if((p = checkstring(cmdline, "OPEN")) != NULL) {
    	int spiport, speed=3, mode = 3, ss=0, order=0;
    	getargs(&p, 9, ",");
    	if(argc < 1) error("Invalid syntax");
    	spiport = getinteger(argv[0]);
    	if(spiport < 1 || spiport > 2) error("Invalid SPI port");

    	if(argc >= 3) {
    		speed = getinteger(argv[2]);
    		if(speed < 0 || speed > 7) error("Invalid speed");
    	}

    	if(argc >= 5 && *argv[4]) mode = getinteger(argv[4]);
    	if(mode < 0 || mode > 3) error("Invalid mode");

    	if(argc >= 7) {
    		if(str_equal(argv[6], "M")) order = 0;	// msb
    		if(str_equal(argv[6], "L")) order = 1;	// lsb
    	}

    	if(argc >= 9) {
    		if(str_equal(argv[6], "SS")) ss = 1;	// get the ss option
    	}

    	if(spiport==1) {
    		// SPI-1
    		if(spi1) error("SPI port is already open");
    		spi1_ss=ss;

    		ExtCfg(P_SPI1_SCK_PIN_NBR, EXT_COM_RESERVED);	// reserve the pin for com use
    		ExtCfg(P_SPI1_MOSI_PIN_NBR, EXT_COM_RESERVED);	// reserve the pin for com use
    		ExtCfg(P_SPI1_MISO_PIN_NBR, EXT_COM_RESERVED);	// reserve the pin for com use
    		if(spi1_ss) ExtCfg(P_SPI1_SS_PIN_NBR, EXT_COM_RESERVED);	// reserve the pin for com use

    		MM_SPI2_Init(mode,speed,order,spi1_ss);

    		spi1 = true;
    	}
    	if(spiport==2) {
    		// SPI-2
    		if(spi2) error("SPI port is already open");
    		spi2_ss=ss;

    		ExtCfg(P_SPI2_SCK_PIN_NBR, EXT_COM_RESERVED);	// reserve the pin for com use
    		ExtCfg(P_SPI2_MOSI_PIN_NBR, EXT_COM_RESERVED);	// reserve the pin for com use
    		ExtCfg(P_SPI2_MISO_PIN_NBR, EXT_COM_RESERVED);	// reserve the pin for com use
    		if(spi2_ss) ExtCfg(P_SPI2_SS_PIN_NBR, EXT_COM_RESERVED);	// reserve the pin for com use

    		MM_SPI5_Init(mode,speed,order,spi2_ss);

    		spi2 = true;
    	}

    }
    else if((p = checkstring(cmdline, "CLOSE")) != NULL) {
    	int spiport;
    	getargs(&p, 3, ",");
    	if(argc != 1) error("Invalid syntax");

    	spiport = getinteger(argv[0]);
    	if(spiport < 1 || spiport > 2) error("Invalid SPI port");

    	SpiClose(spiport);
    }
    else error("Unknown command");
}

void SpiClose(int spi_nr)
{
	if(spi_nr==1 && spi1) {
		// SPI-1
		spi1 = false;
		ExtCfg(P_SPI1_SCK_PIN_NBR, EXT_NOT_CONFIG);
		ExtCfg(P_SPI1_MOSI_PIN_NBR, EXT_NOT_CONFIG);
		ExtCfg(P_SPI1_MISO_PIN_NBR, EXT_NOT_CONFIG);
		if(spi1_ss) ExtCfg(P_SPI1_SS_PIN_NBR, EXT_NOT_CONFIG);

		MM_SPI2_DeInit();
	}
	if(spi_nr==2 && spi2) {
		// SPI-2
		spi2 = false;
		ExtCfg(P_SPI2_SCK_PIN_NBR, EXT_NOT_CONFIG);
		ExtCfg(P_SPI2_MOSI_PIN_NBR, EXT_NOT_CONFIG);
		ExtCfg(P_SPI2_MISO_PIN_NBR, EXT_NOT_CONFIG);
		if(spi2_ss) ExtCfg(P_SPI2_SS_PIN_NBR, EXT_NOT_CONFIG);

		MM_SPI5_DeInit();
	}
}

// output and get a byte via SPI
void fun_spi(void) {
	int spiport;
	unsigned int in=0,out;

	getargs(&ep, 3, ",");
	if(argc < 3 || (argc & 0x01) == 0) error("Invalid number of parameters");

	spiport = getinteger(argv[0]);
	if(spiport < 1 || spiport > 2) error("Invalid SPI port");

	out = getinteger(argv[2]);
	if(out>255) error("Invalid value");

	if(spiport==1) {
	  // SPI-1
	  if(!spi1) error("SPI port not open");
	  in=MM_SPI2_SendByte(out,spi1_ss);
	}
	if(spiport==2) {
	  // SPI-2
	  if(!spi2) error("SPI port not open");
	  in=MM_SPI5_SendByte(out,spi2_ss);
	}
	fret = (float)in;
}



void cmd_mode(void) {
#if !defined(STM32F7) // PIC
#if defined(COLOUR)
	int mc;
	int mp;

	getargs(&cmdline, 3, ",");
	if((argc & 0x01) == 0) error("Invalid syntax");
	mc = getinteger(argv[0]);										// the mode
	if(mc < 1 || mc > 4) error("Invalid mode");
	if(mc == 1) mp = 7;
	if(mc == 2) mp = 1;
	if(argc == 3) mp = getinteger(argv[2]);			                // the palette
	if(mc == 1 && (mp < 1 || mp > 7)) error("Invalid palette");
	if(mc == 2 && (mp < 1 || mp > 6)) error("Invalid palette");
	SetMode(mc, mp);
#endif
#else // STM32F746
	//error("cmd_mode");  // command has no effect in F746
#endif // STM32F746
}



void cmd_colour(void) {
    uint16_t fg, bg = DefaultBgColour;
	getargs(&cmdline, 31, ",");
	if((argc & 0x01) == 0) error("Invalid syntax");
	fg = getinteger(argv[0]);										// the foreground colour
        // uint16_t can't be less than 0 or more than 65535 ... i comment it out
	// if(fg < 0 || fg > 7) error("Invalid colour");
	if(argc == 3) bg = getinteger(argv[2]);						    // the background colour
        // uint16_t can't be less than 0 or more than 65535 ... i comment it out
	// if(bg < 0 || bg > 7) error("Invalid colour");
	CurTxtFgColour = CurrentFgColour = DefaultFgColour = fg;
	CurTxtBgColour = CurrentBgColour = DefaultBgColour = bg;
	if(CurrentLinePtr == 0) {
		DefTxtFgColour = CurTxtFgColour = CurrentFgColour;                          // if we are in command mode set the colours for the command prompt
		DefTxtBgColour = CurTxtBgColour = CurrentBgColour;
    }
}


void cmd_cline(void) {
#if !defined(STM32F7) // PIC
#if defined(COLOUR)
	int colour;
	int start;
	int end;

	getargs(&cmdline, 5, ",");
	if(VBuf == 0) return;
	if(ModeC != 1 || ModeP != 7) error("Valid in MODE 1,7 only");
	if((argc & 0x01) == 0 || argc < 3) error("Invalid syntax");
	colour = getinteger(argv[0]);									// the colour
	if(colour < 0 || colour > 7) error("Invalid colour");
	if(VBuf == 0) return;
	start = getinteger(argv[2]);								    // the start line
	if(start < 0) start = 0;  if(start > VBuf - 1) start = VBuf - 1;
	end = start;
	if(argc == 5) end = getinteger(argv[4]);					    // the end line
	if(end < start) end = start;  if(end > VBuf - 1) end = VBuf - 1;

	if(CLine == NULL) {
	    CLine = getmemory(VBuf);                                    // get the buffer
	    memset(CLine, ModeP, VBuf);                                 // and set to the current monochrome colour
	}
	while(start <= end) CLine[start++] = colour;                    // set the required scan lines
#endif
#else // STM32F746
	// error("cmd_cline"); // command has no effect in F746
#endif // STM32F746
}



// this function creates a short string with embedded colour selection characters
void fun_clr(void) {
	getargs(&ep, 3, ",");
	sret = GetTempStringSpace();									// this will last for the life of the command
	sret[0] = 2;                                                    // always two characters

	if(argc == 0)  {                                                // foreground
	    sret[1] = 128;
	    CurTxtFgColour = DefTxtFgColour;
	}
	else {
	    sret[1] = 128;
	    CurTxtFgColour = getinteger(argv[0]);
	}

	if(argc < 3 || *argv[2] == 0)  {                                 // background
	    sret[2] = 192;
	    CurTxtBgColour = DefTxtBgColour;
	}
	else {
	    sret[2] = 192;
	    CurTxtBgColour = getinteger(argv[2]);
	}
}




void cmd_font(void) {
	int font, scale, reverse;
//	char ss[3];														// this will be used to split up the argument line
//	char *p, *fname;
//	unsigned short *p16;
//	unsigned int *p32;
//	int ch, bt, row, bheight;
//	int filenbr, width, height, start, end;

	// This block of code handles the command:   FONT #n, size, reverse
	{																// start a new block
		getargs(&cmdline, 5, ",");									// must be first in the block
		if(argc < 1 || (argc & 0x01) == 0) error("Invalid number of parameters");
		if(*argv[0] == '#') argv[0]++;
		font = getinteger(argv[0]);
		if(font < 1 || font > NBRFONTS || ftbl[font - 1].p == NULL) error("Invalid font number");
		font--;
		scale = 1;
		reverse = 0;
		if(argc >= 3) {
		    if(*argv[2])
		        scale = getinteger(argv[2]);
		    else
		        if(fontNbr == font) scale = fontScale;
		}
		if(argc == 5) reverse = getinteger(argv[4]);
		if(scale < 1 || scale > 8) error("Invalid scale");
		SetFont(font, scale, reverse);
	}
}



void cmd_config(void) {
	char *tp;
	int x;

	tp = checkstring(cmdline, "VIDEO");
	if(tp) {
		if(checkstring(tp, "ON"))		{ SetFlashOption(&VideoOption, CONFIG_ON);		return; }
		if(checkstring(tp, "OFF"))		{ SetFlashOption(&VideoOption, CONFIG_OFF); 	return; }
	}
	tp = checkstring(cmdline, "FONT");
	if(tp) {
		if(checkstring(tp, "1"))		{ SetFlashOption(&FontOption, 1);	return; }
		if(checkstring(tp, "2"))		{ SetFlashOption(&FontOption, 2); 	return; }
		// font #3 cant be set in flash
		if(checkstring(tp, "4"))		{ SetFlashOption(&FontOption, 4); 	return; }
		if(checkstring(tp, "5"))		{ SetFlashOption(&FontOption, 5); 	return; }
		if(checkstring(tp, "6"))		{ SetFlashOption(&FontOption, 6); 	return; }
	}
	tp = checkstring(cmdline, "CASE");
	if(tp) {
		if(checkstring(tp, "LOWER"))	{ SetFlashOption(&CaseOption, CONFIG_LOWER); 	return; }
		if(checkstring(tp, "UPPER"))	{ SetFlashOption(&CaseOption, CONFIG_UPPER); 	return; }
		if(checkstring(tp, "TITLE"))	{ SetFlashOption(&CaseOption, CONFIG_TITLE); 	return; }
	}
	tp = checkstring(cmdline, "KEYBOARD");
	if(tp) {
		if(checkstring(tp, "US"))		{ SetFlashOption(&KeyboardOption, CONFIG_US); 	return; }
		if(checkstring(tp, "FR"))		{ SetFlashOption(&KeyboardOption, CONFIG_FR); 	return; }
		if(checkstring(tp, "GR"))		{ SetFlashOption(&KeyboardOption, CONFIG_GR); 	return; }
	}
	tp = checkstring(cmdline, "TAB");
	if(tp) {
		if(checkstring(tp, "2"))		{ SetFlashOption(&TabOption, CONFIG_TAB2);	    return; }
		if(checkstring(tp, "4"))		{ SetFlashOption(&TabOption, CONFIG_TAB4);	    return; }
		if(checkstring(tp, "8"))		{ SetFlashOption(&TabOption, CONFIG_TAB8);	    return; }
	}
	tp = checkstring(cmdline, "DRIVE");
	if(tp) {
		if(checkstring(tp, "A"))		{ SetFlashOption(&DriveOption, FLASHFS);    return; }
		if(checkstring(tp, "B"))		{ SetFlashOption(&DriveOption, SDFS);	    return; }
		if(checkstring(tp, "C"))		{ SetFlashOption(&DriveOption, USBFS);	    return; }
	}
	tp = checkstring(cmdline, "BGCOLOR");
	if(tp) {
		x=getinteger(tp);
		SetFlashOption(&BGColorOption, x);return;
	}
	tp = checkstring(cmdline, "FGCOLOR");
	if(tp) {
		x=getinteger(tp);
		SetFlashOption(&FGColorOption, x);return;
	}
	tp = checkstring(cmdline, "AUTORUN");
	if(tp) {
		if(checkstring(tp, "ON"))		{ SetFlashOption(&AutorunOption, CONFIG_ON);	return; }
		if(checkstring(tp, "OFF"))		{ SetFlashOption(&AutorunOption, CONFIG_OFF); 	return; }
	}
	tp = checkstring(cmdline, "BAUDRATE");
	if(tp) {
		x=getinteger(tp);
		SetFlashOption(&BaudrateOption, x);return;
	}
	error("Unrecognised option");
}



// this function positions the cursor within a PRINT command
void fun_at(void) {
    char buf[12];
	getargs(&ep, 7, ",");
	if(commandfunction(cmdtoken) != cmd_print) error("Invalid function");
	if(!(argc == 3 || argc == 5)) error("Incorrect number of arguments");
	AutoLineWrap = false;
	lastx = MMPosX = getinteger(argv[0]);
	lasty = MMPosY = getinteger(argv[2]);
	if(argc == 5) {
	    PrintPixelMode = getinteger(argv[4]);
    	if(PrintPixelMode < 0 || PrintPixelMode > 7) {
        	PrintPixelMode = 0;
        	error("Number out of bounds");
        }
    } else
	    PrintPixelMode = 0;

    // BJR: VT100 set cursor location: <esc>[y;xf
    //      where x and y are ASCII string integers.
    //      Assumes overall font size of 6x12 pixels (480/80 x 432/36), including gaps between characters and lines.
    sprintf(buf, "\033[%d;%df", (int)MMPosY/12, (int)MMPosX/6);
    USBPutEscape(buf);								                // send it to the USB
    sret = "\0";                                                    // normally pointing sret to a string in flash is illegal
}



// function (which looks like a pre defined variable) to return the type of platform
void fun_device(void){
    sret = GetTempStringSpace();									// this will last for the life of the command
    strcpy(sret, "STM32F746 MMBasic");
    CtoM(sret);
}



void fun_keydown(void) {
	fret = KeyDown;											        // this is the character
	while(MMInkey() != -1);                                         // clear anything in the input buffer
}


// when originally planned the watchdog command was going to use the hardware watchdog timer
// but it turned out that the watchdog postscaler is set in the configuration bits which are
// set in the bootloader.  Because it is impossible to change all the bootloaders (especially
// the DuinoMite's) the watchdog function was changed to use a software timer.
void cmd_watchdog(void) {
#if !defined(STM32F7) // PIC
    int i;

    if(checkstring(cmdline, "OFF") != NULL) {
        WDTimer = 0;
    } else {
        i = getinteger(cmdline);
        if(i < 1) error("Invalid argument");
        WDTimer = i;
    }
#else // STM32F746
	error("cmd_watchdog");
#endif // STM32F746
}


/***********************************************************************************************
interrupt check
************************************************************************************************/

// check if an interrupt has occured and if so, set the next command to the interrupt routine
// will return true if interrupt detected or false if not
int check_interrupt(void) {
	static int KeyF7Timer=0;
	static int TouchF7Timer=0;
	static int LastTouch = false;
	char *intaddr;
	static char rti[2];
	int i, v;

	if(KeyF7Timer-- <= 0) {  // if it is time to check for a input (key or vcp)
		KeyF7Timer=30; // check input every 30 commands
		MMInkeyPause();	// check for receiving a break key
	}


    if(touch_active) {                                          // if the touch elements are on the screen
        if(TouchF7Timer-- <= 0) {                                 // if it is time to check for a touch
            TouchF7Timer = 100;
            i = checktouch();                                   // check for touch and get the state (true means touch detected)
            if(OnTouchGOSUB && !LastTouch && i) {               // if we are interrupting on touch and this is a new touch
                LastTouch = i;                                  // remember the touch state for next time
                intaddr = OnTouchGOSUB;							// set the next stmt to the interrupt location
        		goto GotAnInterrupt;
            }
            LastTouch = i;                                      // remember the touch state for next time
        }
    }


	if(!InterruptUsed) return 0;                                    // quick exit if there are no interrupts set
	if(InterruptReturn != NULL || CurrentLinePtr == NULL) return 0;	// skip if we are in an interrupt or in immediate mode


    // check for an  ON KEY loc  interrupt
    if(OnKeyGOSUB && isKeyInBuffer()) {
        intaddr = OnKeyGOSUB;							            // set the next stmt to the interrupt location
		goto GotAnInterrupt;
    }

	for(i = 1; i < NBRPINS + 1; i++) {
		if(inttbl[i].intp != NULL) {								// if an interrupt is enabled for this pin
			v = ExtInp(i);											// get the current value
			// check if interrupt occured
			if((inttbl[i].lohi == T_HILO && v < inttbl[i].last) || (inttbl[i].lohi == T_LOHI && v > inttbl[i].last) || (inttbl[i].lohi == T_BOTH && v != inttbl[i].last)) {
				intaddr = inttbl[i].intp;							// set the next stmt to the interrupt location
				inttbl[i].last = v;									// save the new pin value
				goto GotAnInterrupt;
			} else
				inttbl[i].last = v;									// no interrupt, just update the pin value
		}
	}

	// check if one of the tick interrupts is enabled and if it has occured
	for(i = 0; i < NBRSETTICKS; i++) {
    	if(TickInt[i] != NULL && TickTimer[i] > TickPeriod[i]) {
    		// reset for the next tick but skip any ticks completely missed
    		while(TickTimer[i] > TickPeriod[i]) TickTimer[i] -= TickPeriod[i];
    		intaddr = TickInt[i];
    		goto GotAnInterrupt;
    	}
    }

    // if no interrupt was found then return having done nothing
	return 0;

    // an interrupt was found if we jumped to here
GotAnInterrupt:
    LocalIndex++;                                                   // IRETURN will decrement this
    InterruptReturn = nextstmt;                                     // for when IRETURN is executed
    // if the interrupt is pointing to a SUB token we need to call a subroutine
    if(*intaddr == GetCommandValue("SUB") + C_BASETOKEN) {
        rti[0] = GetCommandValue("IRETURN") + C_BASETOKEN;          // setup a dummy IRETURN command
        rti[1] = 0;
        if(gosubindex >= MAXGOSUB) error("Too many nested sub/function");
    	gosubstack[gosubindex++] = rti;                             // return from the subroutine to the dummy IRETURN command
        LocalIndex++;                                               // return from the subroutine will decrement LocalIndex
        skipelement(intaddr);                                       // point to the body of the subroutine
    }

    nextstmt = intaddr;                                             // the next command will be in the interrupt routine
    return 1;
}



// get the address for a MMBasic interrupt
// this will handle a line number, a label or a subroutine
// all areas of MMBasic that can generate an interrupt use this function
char *GetIntAddress(char *p) {
    int i;
	if(isnamestart(*p)) {                                           // if it starts with a valid name char
    	i = FindSubFun(p, 0);                                       // try to find a matching subroutine
    	if(i == -1)
		    return findlabel(p);					                // if a subroutine was NOT found it must be a label
		else
		    return subfun[i];                                       // if a subroutine was found, return the address of the sub
	}
	
	return findline(getinteger(p), true);	                        // otherwise try for a line number
}    
