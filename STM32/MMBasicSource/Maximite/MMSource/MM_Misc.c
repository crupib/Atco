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

#include <stdio.h>
#include <plib.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

struct s_inttbl inttbl[NBRPINS + 1];
char *InterruptReturn;

int TickPeriod[NBRSETTICKS];
volatile int TickTimer[NBRSETTICKS];
char *TickInt[NBRSETTICKS];






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

    f = getnumber(cmdline);                                     // get the pulse width
    if(f < 0) error("Number out of bounds");
    if(f < 0.05) return;

	if(f < 1.5) {
		uSec(f * 1000);                                         // if less than 1.5mS do the pause right now
		return;                                                 // and exit straight away
    }

	if(InterruptReturn == NULL) {
		// we are running pause in a normal program
		// first check if we have reentered (from an interrupt) and only zero the timer if we have NOT been interrupted.
		// This means an interrupted pause will resume from where it was when interrupted
		if(!interrupted) PauseTimer = 0;
		interrupted = false;

		while(PauseTimer < MMround(f)) {
			CheckAbort();
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
		IntPauseTimer = 0;
		while(IntPauseTimer < MMround(f)) CheckAbort();
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
		getargs(&arg, 5, "-/");										// this is a macro and must be the first executable stmt in a block
		if(argc != 5) error("Invalid syntax");
		d = atoi(argv[0]);
		m = atoi(argv[2]);
		y = atoi(argv[4]);
		if(y >= 0 && y < 100) y += 2000;
		if(d < 1 || d > 31 || m < 1 || m > 12 || y < 2000 || y > 2999) error("Invalid date");

		mT4IntEnable(0);       										// disable the timer interrupt to prevent any conflicts while updating
		day = d;
		month = m;
		year = y;
		mT4IntEnable(1);       										// enable interrupt
	#if defined(COLOUR)
	    {
    	    int t;
    		t = ReadRTC(0);                                         // get the RTC seconds register
    		if(t != -1) {                                           // negative means that the RTC is not there
        		if(t & 0x80) {                                      // this is the first time that we have set the time/date
                    WriteRTC(0,0);                                  // zero seconds and start the clock running
                    WriteRTC(1,0);                                  // zero minutes
                    WriteRTC(2,0);                                  // zero hours
                    WriteRTC(7,0);                                  // zero the control register
                    SecondsTimer = second = minute = hour = 0;
                }
        		WriteRTC(4, ((d / 10) << 4) | (d % 10));
        		WriteRTC(5, ((m / 10) << 4) | (m % 10));
        		y -= 2000;
        		WriteRTC(6, ((y / 10) << 4) | (y % 10));
            }
        }
    #endif // COLOUR
	}
}



// this is invoked as a function
void fun_date(void) {
	sret = GetTempStringSpace();									// this will last for the life of the command
	mT4IntEnable(0);       											// disable the timer interrupt to prevent any conflicts while updating
	sprintf(sret, "%02d-%02d-%04d", day, month, year);
	mT4IntEnable(1);  	     										// enable interrupt
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
		mT4IntEnable(0);       										// disable the timer interrupt to prevent any conflicts while updating
		hour = h;
		minute = m;
		second = s;
		SecondsTimer = 0;
		mT4IntEnable(1);       										// enable interrupt
	#if defined(COLOUR)
	    {
        	int t;
    		t = ReadRTC(0);                                         // get the RTC seconds register
    		if(t != -1) {                                           // negative means that the RTC is not there
        		if(t & 0x80) {                                      // this is the first time that we have set the time/date
                    WriteRTC(4,0);                                  // zero date
                    WriteRTC(5,1);                                  // set month = Jan
                    WriteRTC(6,0);                                  // set year = 2000
                    WriteRTC(7,0);                                  // zero the control register
                    day = month = year = 0;
                }
        		WriteRTC(0, ((s / 10) << 4) | (s % 10));            // this will also start the clock running
        		WriteRTC(1, ((m / 10) << 4) | (m % 10));
        		WriteRTC(2, ((h / 10) << 4) | (h % 10));
            }
        }
    #endif // COLOUR
    }
}




// this is invoked as a function
void fun_time(void) {
	sret = GetTempStringSpace();									// this will last for the life of the command
	mT4IntEnable(0);       											// disable the timer interrupt to prevent any conflicts while updating
	sprintf(sret, "%02d:%02d:%02d", hour, minute, second);
	mT4IntEnable(1);  	     										// enable interrupt
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
    MMPrintString(MES_SIGNON);
    MMPrintString(MES_COPYRIGHT);
	MMPrintString("Updates at http://geoffg.net/maximite.html\r\n");
	MMPrintString("All Rights Reserved.  See website for details.\r\n\n");

#ifdef TFT_MAXIMITE
    MMPrintString("TFT video and touch Copyright 2013 Carsten Meyer.\r\n");
#endif
	MMPrintString("Video and keyboard routines from Lucio Di Jasio's\r\n");
	MMPrintString("book \"Programming 32-bit Microcontrollers in C\".\r\n");
#if defined(COLOUR)
	MMPrintString("Colour technique developed by Dr Kilian Singer.\r\n");
	MMPrintString("Colour Maximite logo designed by Nick Marentes.\r\n");
#endif
	MMPrintString("MOD Player Copyright 2012 Pascal Piazzalunga.\r\n");
	MMPrintString("I2C & 1-Wire Support Copyright 2011 Gerard Sexton.\r\n");
#if defined(INCLUDE_CAN)
	MMPrintString("CAN Support Copyright 2012 John Harding.\r\n");	// JDH
#endif
	MMPrintString("USB VID and PIDs are sublicensed by Microchip.\r\n");
	MMPrintString("USB/CDC and SD/FAT Support Copyright 2010, 2011\r\n");
	MMPrintString("Microchip Technology Incorporated.\r\n\n");

	MMPrintString("This is free software and comes with absolutely\r\n");
	MMPrintString("no warranty implied or otherwise.\r\n");
}



// output and get a byte via SPI
void fun_spi(void) {
	unsigned int b, in, out;
	register unsigned int t;
	unsigned int rx, tx, ck, rxn, txp, ckp;
	volatile unsigned int *rxi, *txh, *txl, *c_leading, *c_trailing;
	unsigned int speed = 0;
	int bits = 8;
	int mode = 3;

	getargs(&ep, 13, ",");
	if(argc < 5 || (argc & 0x01) == 0) error("Invalid number of parameters");
	rx = getinteger(argv[0]);
	tx = getinteger(argv[2]);
	ck = getinteger(argv[4]);

	if(argc >= 7 && *argv[6])
		out = getinteger(argv[6]);
	else
		out = 0;

	if(argc >= 9) {
		switch(toupper(*argv[8])) {
    		case 0:
			case 'H':	speed = 0; break;
			case 'M':	speed = 1; break;
			case 'L':	speed = 10; break;
			default:	error("Invalid speed");
		}
	}

	if(argc >= 11 && *argv[10]) mode = getinteger(argv[10]);
	if(argc >= 13 && *argv[12]) bits = getinteger(argv[12]);

	if(rx < 1 || rx > NBRPINS || tx < 1 || tx > NBRPINS || ck < 1 || ck > NBRPINS) error("Invalid pin");
	if(mode < 0 || mode > 3) error("Invalid mode");
	if(bits < 1 || bits > 23) error("Invalid number of bits");
	if(ExtCurrentConfig[rx] != EXT_DIG_IN) error("Pin not configured for input");
	if((ExtCurrentConfig[tx] != EXT_DIG_OUT && ExtCurrentConfig[tx] != EXT_OC_OUT) || (ExtCurrentConfig[ck] != EXT_DIG_OUT && ExtCurrentConfig[ck] != EXT_OC_OUT))
		error("Pin not configured for output");

	// get the port address for the I/O.  Much faster than calling functions to perform the I/O.
	rxi = GetPortAddr(rx, PORT);    rxn = GetPinBit(rx);
	txh = GetPortAddr(tx, LATSET);  txl = GetPortAddr(tx, LATCLR);  txp = 1 << GetPinBit(tx);

	// get the port address for the clock.  The clock polarity is inverted if mode 0 or 1 is used
	if(mode == 0 || mode == 3) {
    	c_trailing = GetPortAddr(ck, LATSET);  c_leading = GetPortAddr(ck, LATCLR);
    } else {
    	c_trailing = GetPortAddr(ck, LATCLR);  c_leading = GetPortAddr(ck, LATSET);
    }
    ckp = 1 << GetPinBit(ck);

	b = 1 << (bits - 1);
	t = in = 0;

	while(b) {
    	// output the data on the leading edge of the clock
		if(out & b)
		    *txh = txp;                                             // output the next bit (if high)
		else
		    *txl = txp;                                             // output the next bit (if low)
		*c_leading = ckp;										    // set the clock active - data out must be stable by now
    	nop;
    	nop;
		if(speed) uSec(speed);									    // delay to get the right speed
		// capture the input data on the trailing edge of the clock
		in <<= 1;												    // shift up the input data
		t = *rxi;                                                   // capture the input (the whole port actually)
		*c_trailing = ckp;											// set the clock to inactive - we must have sampled the input by now
		in |= (t >> rxn) & 1;									    // get our bit of data and add it to the input word
		if(speed) uSec(speed);									    // delay to get the right speed
		b >>= 1;												    // shift down the mask bit for the output
	}
	if(mode == 0 || mode == 2) *c_leading = ckp;					// reset the clock to inactive
	fret = (float)in;                                               // return the value
}



void cmd_mode(void) {
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
}



void cmd_colour(void) {
#if defined(COLOUR)
    int fg, bg = 0;
	getargs(&cmdline, 31, ",");
	if((argc & 0x01) == 0) error("Invalid syntax");
	fg = getinteger(argv[0]);										// the foreground colour
	if(fg < 0 || fg > 7) error("Invalid colour");
	if(argc == 3) bg = getinteger(argv[2]);						    // the background colour
	if(bg < 0 || bg > 7) error("Invalid colour");
	if(ModeC == 1) {
	    if(fg != ModeP && fg != BLACK) fg = ModeP;
	    if(bg != ModeP && bg != BLACK) bg = BLACK;
	}
	CurrentFgColour = DefaultFgColour = fg;
	CurrentBgColour = DefaultBgColour = bg;
	if(CurrentLinePtr == 0) {
    	ConsoleFgColour = CurrentFgColour;                          // if we are in command mode set the colours for the command prompt
    	ConsoleBgColour = CurrentBgColour;
    }
#endif
}


void cmd_cline(void) {
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
}



// this function creates a short string with embedded colour selection characters
void fun_clr(void) {
	getargs(&ep, 3, ",");
	sret = GetTempStringSpace();									// this will last for the life of the command
#if defined(COLOUR)
	sret[0] = 2;                                                    // always two characters

	if(argc == 0)                                                   // foreground
	    sret[1] = DefaultFgColour + 128;
	else
	    sret[1] = getinteger(argv[0]) + 128;

	if(argc < 3 || *argv[2] == 0)                                   // background
	    sret[2] = DefaultBgColour + 192;
	else
	    sret[2] = getinteger(argv[2]) + 192;
#else
	sret[0] = 0;
#endif
}




void cmd_font(void) {
	int font, scale, reverse;
	char ss[3];														// this will be used to split up the argument line
	char *p, *fname;
	unsigned short *p16;
	unsigned int *p32;
	int ch, bt, row, bheight;
	int filenbr, width, height, start, end;

	ss[0] = tokenvalue[TKN_AS];
	ss[1] = GetTokenValue("LOAD");
	ss[2] = 0;

	// This block of code handles the command:   FONT LOAD "filename" AS #n
	if(*cmdline == ss[1]) {											// start a new block
		getargs(&cmdline, 4, ss);									// getargs macro must be the first executable stmt in a block
		if(argc != 4) error("Invalid Syntax");
		fname = GetFileName(argv[1], NULL);
		if(*argv[3] == '#') argv[3]++;
		font = getinteger(argv[3]);
		if(font < 1 || font > NBRFONTS) error("Invalid font number");
		font--;
		if(ftbl[font].p != NULL) error("Font number is in use");
		filenbr = FindFreeFileNbr();
		MMfopen(fname, "r", filenbr);
		do { *inpbuf = 0; MMgetline(filenbr, inpbuf); } while(*inpbuf == '\'');	// get the parameters line
		p = inpbuf;
		{															// start a new block
			getargs(&p, 7, ",");									// getargs macro must be the first executable stmt in a block
			if(argc != 7) error("Invalid font file format");
			ftbl[font].height = height = getinteger(argv[0]);
			ftbl[font].width = width = getinteger(argv[2]);
			ftbl[font].start = start = getinteger(argv[4]);
			ftbl[font].end = end = getinteger(argv[6]);
			if(height < 1 || height > 64 || width < 1 || start < 20 || start > 126 || end < start || end > 126) error("Invalid font file parameters");
		}
		if(height > 32) bheight = 8;
		else if(height > 16) bheight = 4;
		else bheight = 2;
		ftbl[font].p = getmemory((bheight * width) * ((end + 1) - start));	// get the memory
		p16 = (unsigned short *)ftbl[font].p;  p32 = (unsigned int *)ftbl[font].p;
		for(ch = 0; ch <= end - start; ch++) {
			for(row = 0; row < height; row++) {
				if(MMfeof(filenbr)) {								// if end of file then something is wrong
					UnloadFont(font);
					error("Invalid font file format");				// and bail out
				}
				do { *inpbuf = 0; MMgetline(filenbr, inpbuf); } while(*inpbuf == '\'');	// get the next data line
				for(bt = 0; bt < width && inpbuf[bt] != 0; bt++) {
					if(inpbuf[bt] != ' ') {
						if(bheight == 2)
							p16[bt] |= (1 <<  row);
						else if(bheight == 4)
							p32[bt] |= (1 <<  row);
						else {
							if(row < 32)
								p32[bt] |= (1 <<  row);
							else
								p32[bt + width] |= (1 <<  (row - 32));
						}
					}
				}
			}
			p16 += width; p32 += (width * (bheight/4));
		}
		//dump(ftbl[font].p, (height * width)/8);
		MMfclose(filenbr);
		return;
	}

	p = cmdline;
	// this block of code handles the command:   FONT UNLOAD #n
	if((p = checkstring(p, "UNLOAD")) != NULL) {
		skipspace(p);
		if(*p == '#') p++;
		font = getinteger(p);
		if(font < 1 || font > NBRFONTS) error("Invalid font number");
		if(font <= 3) error("Cannot unload this font");
		font--;
		if(ftbl[font].p == NULL) error("Font is not loaded");
		UnloadFont(font);
		return;
	}

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

	tp = checkstring(cmdline, "COMPOSITE");
	if(tp) {
		if(checkstring(tp, "DISABLED"))	{ SetFlashOption(&PalVgaOption, CONFIG_DISABLED);return; }
		if(checkstring(tp, "NTSC"))		{ SetFlashOption(&PalVgaOption, CONFIG_NTSC);  	return; }
		if(checkstring(tp, "PAL"))		{ SetFlashOption(&PalVgaOption, CONFIG_PAL);  	return; }
	}
	tp = checkstring(cmdline, "VIDEO");
	if(tp) {
		if(checkstring(tp, "ON"))		{ SetFlashOption(&VideoOption, CONFIG_ON);		return; }
		if(checkstring(tp, "OFF"))		{ SetFlashOption(&VideoOption, CONFIG_OFF); 	return; }
	}
	tp = checkstring(cmdline, "FONT");
	if(tp) {
		if(checkstring(tp, "1"))		{ SetFlashOption(&FontOption, CONFIG_FONT1);	return; }
		if(checkstring(tp, "2"))		{ SetFlashOption(&FontOption, CONFIG_FONT2); 	return; }
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
		if(checkstring(tp, "IT"))		{ SetFlashOption(&KeyboardOption, CONFIG_IT); 	return; }
		if(checkstring(tp, "BE"))		{ SetFlashOption(&KeyboardOption, CONFIG_BE); 	return; }
		if(checkstring(tp, "UK"))		{ SetFlashOption(&KeyboardOption, CONFIG_UK); 	return; }
		if(checkstring(tp, "ES"))		{ SetFlashOption(&KeyboardOption, CONFIG_ES); 	return; }
	}
	tp = checkstring(cmdline, "TAB");
	if(tp) {
		if(checkstring(tp, "2"))		{ SetFlashOption(&TabOption, CONFIG_TAB2);	    return; }
		if(checkstring(tp, "4"))		{ SetFlashOption(&TabOption, CONFIG_TAB4);	    return; }
		if(checkstring(tp, "8"))		{ SetFlashOption(&TabOption, CONFIG_TAB8);	    return; }
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
    #ifdef MAXIMITE
        strcpy(sret, "Maximite");
    #endif

    #ifdef UBW32
        strcpy(sret, "UBW32");
    #endif

    #ifdef DUINOMITE
        strcpy(sret, "DuinoMite");
    #endif

    #ifdef TFT_MAXIMITE
        strcpy(sret, "TFT Maximite");
    #else
        #ifdef COLOUR
            strcpy(sret, "Colour Maximite");
        #endif
    #endif
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
    int i;

    if(checkstring(cmdline, "OFF") != NULL) {
        WDTimer = 0;
    } else {
        i = getinteger(cmdline);
        if(i < 1) error("Invalid argument");
        WDTimer = i;
    }
}


/***********************************************************************************************
interrupt check
************************************************************************************************/

// check if an interrupt has occured and if so, set the next command to the interrupt routine
// will return true if interrupt detected or false if not
int check_interrupt(void) {
	int i, v;
	char *intaddr;
	static char rti[2];

    #if defined(TFT_MAXIMITE)
        static int LastTouch = false;
        if(touch_active) {                                          // if the touch elements are on the screen
            if(TouchTimer-- <= 0) {                                 // if it is time to check for a touch
                TouchTimer = TOUCH_CHECK;
                i = checktouch();                                   // check for touch and get the state (true means touch detected)
                if(OnTouchGOSUB && !LastTouch && i) {               // if we are interrupting on touch and this is a new touch
                    LastTouch = i;                                  // remember the touch state for next time
                    intaddr = OnTouchGOSUB;							// set the next stmt to the interrupt location
            		goto GotAnInterrupt;
                }
                LastTouch = i;                                      // remember the touch state for next time
            }
        }        
    #endif

    if(!InterruptUsed) return 0;                                    // quick exit if there are no interrupts set
	if(InterruptReturn != NULL || CurrentLinePtr == NULL) return 0;	// skip if we are in an interrupt or in immediate mode

    // check for an  ON KEY loc  interrupt
    if(OnKeyGOSUB && isKeyInBuffer()) {
        intaddr = OnKeyGOSUB;							            // set the next stmt to the interrupt location
		goto GotAnInterrupt;
    }

//	GS I2C Start
	if ((I2C_Status & I2C_Status_Interrupt) && (I2C_Status & I2C_Status_Completed)) {
		I2C_Status &= ~I2C_Status_Completed;						// clear completed flag
		intaddr = I2C_IntLine;										// set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}
	if ((I2C_Status & I2C_Status_Slave_Receive_Rdy)) {
		I2C_Status &= ~I2C_Status_Slave_Receive_Rdy;	            // clear completed flag
		intaddr = I2C_Slave_Receive_IntLine;						// set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}
	if ((I2C_Status & I2C_Status_Slave_Send_Rdy)) {
		I2C_Status &= ~I2C_Status_Slave_Send_Rdy;					// clear completed flag
		intaddr = I2C_Slave_Send_IntLine;							// set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}
//	GS I2C End

	// interrupt routines for the serial ports
	if(com1_interrupt != NULL && SerialRxStatus(1) >= com1_ilevel) {// do we need to interrupt?
		intaddr = com1_interrupt;									// set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}
	if(com2_interrupt != NULL && SerialRxStatus(2) >= com2_ilevel) {// do we need to interrupt?
		intaddr = com2_interrupt;									// set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}
    if(IrGotMsg && IrInterrupt != NULL) {
        IrGotMsg = false;
		intaddr = IrInterrupt;									    // set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}

    if(KeypadInterrupt != NULL && KeypadCheck()) {
		intaddr = KeypadInterrupt;									// set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}

#if defined(DUINOMITE)
	if(com3_interrupt != NULL && SerialRxStatus(3) >= com3_ilevel) {// do we need to interrupt?
		intaddr = com3_interrupt;									// set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}
	if(com4_interrupt != NULL && SerialRxStatus(4) >= com4_ilevel) {// do we need to interrupt?
		intaddr = com4_interrupt;									// set the next stmt to the interrupt location
		goto GotAnInterrupt;
	}
#endif

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
