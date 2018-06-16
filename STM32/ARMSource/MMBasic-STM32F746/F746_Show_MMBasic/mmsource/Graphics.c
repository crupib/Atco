/***********************************************************************************************************************
MMBasic

custom.c

Space for custom commands and functions created by licensed recipients of the source code.

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

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

void getcoord(char *p, int *x, int *y);

	void get3coord(char *p, int *x1, int *y1, int *x2, int *y2, int *x3, int *y3);
	void getquadparam(char *p, int *x, int *y, int *w, int *h, int *angle);

	extern FIL MMFile;

	//--------------------------------------------------------------
	// BMP header
	// (480x272 landscape)
	//--------------------------------------------------------------
	uint8_t BMP_HEADER[54]={
	0x42,0x4D,0x36,0xFA,0x05,0x00,0x00,0x00,0x00,0x00, // ID=BM, Filsize=(480x272x3+54)
	0x36,0x00,0x00,0x00,0x28,0x00,0x00,0x00,           // Offset=54d, Headerlen=40d
	0xE0,0x01,0x00,0x00,0x10,0x01,0x00,0x00,0x01,0x00, // W=480d, H=272d (landscape)
	0x18,0x00,0x00,0x00,0x00,0x00,0x00,0xFA,0x05,0x00, // 24bpp, unkomprimiert, Data=(480x272x3)
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,           // nc
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};          // nc


int lastx = 0;			// the last x and y coordinates that were used
int lasty = 0;

/*******************************************************************************************
Video graphics related commands in MMBasic
==========================================
These are the functions responsible for executing the graphics related  commands in MMBasic
They are supported by utility functions that are grouped at the end of this file

Each function is responsible for decoding a command
all function names are in the form cmd_xxxx() (for a basic command) or fun_xxxx() (for a
basic function) so, if you want to search for the function responsible for the LOCATE command
look for cmd_name

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

 ********************************************************************************************/

void cmd_cls(void) {
	MMPrintString("\033[2J\033[H");									// vt100 clear screen and home cursor
	if(*cmdline) {                                                  // has the user provided a colour?
		uint16_t old,t;
		old = DefaultBgColour;
		t = getinteger(cmdline);                                    // get the background colour
		// uint16_t can't be less than 0 or more than 65535 ... i comment it out
		//if(t < 0 || t > 65535) error("Invalid colour");
		DefaultBgColour = t;                                        // overide the background colour
		MMcls();													// clear screen and home cursor for the video
		DefaultBgColour = old;                                      // restore the old background colour
	} else {
		MMcls();													// if no colour just clear screen
	}
}


void cmd_circle(void) {
	int x, y, radius, outcolor,incolor, fill;
	getargs(&cmdline, 9, ",");
	if(argc%2 == 0 || argc < 3) error("Invalid syntax");
	if(*argv[0] != '(') error("Expected opening bracket");
	if(toupper(*argv[argc - 1]) == 'F') {
		argc -= 2;
		fill = true;
	} else
		fill = false;
	getcoord(argv[0] + 1, &x, &y);
	radius = getinteger(argv[2]);
	if(radius < 1) error("Invalid argument");

	if(argc > 3 && *argv[4]) {
		outcolor = getinteger(argv[4]);
		DefaultFgColour = outcolor;}
	else
		outcolor = DefaultFgColour;

	if(argc > 5 && *argv[6]){
		incolor = getinteger(argv[6]);
		DefaultBgColour = incolor;}
	else
		incolor = DefaultBgColour;

	if(fill == true){
		GFX_DrawFullCircle(x,y,radius,incolor,outcolor,LCD_CurrentLayer);
	}
	else
	{
		GFX_DrawCircle(x,y,radius,outcolor,LCD_CurrentLayer);
	}

	lastx = x; lasty = y;
}

void cmd_line(void) {
	int x1, y1, x2, y2, w, h, colour, box, fill;
	char *p;
	getargs(&cmdline, 5, ",");

	// check if it is actually a LINE INPUT command
	if(argc > 0 && checkstring(argv[0], "INPUT")) {					// check if it is actually is a line input command
		cmd_lineinput();
		return;
	}
	if(argc%2 == 0 || argc < 1) error("Invalid syntax");
	x1 = lastx; y1 = lasty; colour = DefaultFgColour; box = false; fill = false;	// set the defaults for optional components
	p = argv[0];
	if(tokenfunction(*p) != op_subtract) {
		// the start point is specified - get the coordinates and step over to where the minus token should be
		if(*p != '(') error("Expected opening bracket");
		getcoord(p + 1, &x1, &y1);
		p = getclosebracket(p + 1) + 1;
		skipspace(p);
	}
	if(tokenfunction(*p) != op_subtract) error("Invalid syntax");
	p++;
	skipspace(p);
	if(*p != '(') error("Expected opening bracket");
	getcoord(p + 1, &x2, &y2);
	if(argc > 1 && *argv[2]){
		colour = getinteger(argv[2]);
		DefaultFgColour = colour;}
	if(argc == 5) {
		box = (strchr(argv[4], 'b') != NULL || strchr(argv[4], 'B') != NULL);
		fill = (strchr(argv[4], 'f') != NULL || strchr(argv[4], 'F') != NULL);
	}
	if(box) {
		if(x2>x1){
			w = x2 - x1;}
		else {
			w = x1 - x2;
			x1 = x2;}
		if(y2>y1){
			h = y2 - y1;}
		else {
			h = y1 - y2;
			y1 = y2;}
		if(fill > 0)
		{
			GFX_DrawFullRect(x1, y1, w, h, colour, colour, LCD_CurrentLayer);	// draw a filled box
		}
		else
		{
			GFX_DrawRect(x1, y1, w, h, colour, LCD_CurrentLayer);	// draw a box
		}
	}
	else
	{
		GFX_DrawUniLine(x1, y1, x2, y2, colour,LCD_CurrentLayer);		// or just a line
	}
	lastx = x2; lasty = y2;											// save in case the user wants the last value
}



void cmd_pset(void) {
#if !defined(STM32F7)  // PIC 
	int x, y;
	//	skipspace(cmdline);
	if(*cmdline != '(') error("Expected opening bracket");
	getcoord(cmdline + 1, &x, &y);
	plot(x, y, DefaultFgColour);
	lastx = x; lasty = y;
#else // STM32F746
	error("cmd_pset");
#endif // STM32F746
}



void cmd_preset(void) {
#if !defined(STM32F7)  // PIC 
	int x, y;
	//	skipspace(cmdline);
	if(*cmdline != '(') error("Expected opening bracket");
	getcoord(cmdline + 1, &x, &y);
	plot(x, y, 0);
	lastx = x; lasty = y;
#else // STM32F746
	error("cmd_preset");
#endif // STM32F746
}



void cmd_locate(void) {
#if !defined(STM32F7)  // PIC 
	char buf[12];
	getargs(&cmdline, 3, ",");
	if(argc != 3) error("Invalid syntax");
	lastx = MMPosX = getinteger(argv[0]);
	lasty = MMPosY = getinteger(argv[2]);
	// BJR: VT100 set cursor location: <esc>[y;xf
	//      where x and y are ASCII string integers.
	//      Assumes overall font size of 6x12 pixels (480/80 x 432/36), including gaps between characters and lines.
	sprintf(buf, "\033[%d;%df", (int)MMPosY/12, (int)MMPosX/6);
	USBPutEscape(buf);								            // send it to the USB
#else // STM32F746
	error("cmd_locate");
#endif // STM32F746
}



// this function is only used by cmd_blit()  -  below
void DoBlit(int *p, int x1, int y1, int x2, int y2, int w, int h) {
#if !defined(STM32F7)  // PIC 
	int x, y, i;
	int *p1, *p2;
	int s1, s2;

	i = HBuf/32; w--;
#if defined(COLOUR)
	if(ModeC == 4) { x1 += 16; x2 += 16; }
#endif


	if(x1 >= x2 && y1 >= y2) {
		for(y = 0; y < h; y++) {
			p1 = &p[(y1 + y) * i + x1/32];
			p2 = &p[(y2 + y) * i + x2/32];
			s1 = 31 - (x1 & 0x1f);
			s2 = 31 - (x2 & 0x1f);
			for(x = 0; x <= w; x++) {
				*p2 = (*p2 & (~(1 << s2))) | (((*p1 >> s1) & 1) << s2);
				if(--s1 < 0) { p1++; s1 = 31; }
				if(--s2 < 0) { p2++; s2 = 31; }
			}
		}
		return;
	}

	if(x1 >= x2 && y1 < y2) {
		for(y = h - 1; y >= 0; y--) {
			p1 = &p[(y1 + y) * i + x1/32];
			p2 = &p[(y2 + y) * i + x2/32];
			s1 = 31 - (x1 & 0x1f);
			s2 = 31 - (x2 & 0x1f);
			for(x = 0; x <= w; x++) {
				*p2 = (*p2 & (~(1 << s2))) | (((*p1 >> s1) & 1) << s2);
				if(--s1 < 0) { p1++; s1 = 31; }
				if(--s2 < 0) { p2++; s2 = 31; }
			}
		}
		return;
	}

	if(x1 < x2 && y1 >= y2) {
		for(y = 0; y < h; y++) {
			p1 = &p[(y1 + y) * i + (x1 + w)/32];
			p2 = &p[(y2 + y) * i + (x2 + w)/32];
			s1 = 31 - ((x1 + w) & 0x1f);
			s2 = 31 - ((x2 + w) & 0x1f);
			for(x = w ; x >= 0; x--) {
				*p2 = (*p2 & (~(1 << s2))) | (((*p1 >> s1) & 1) << s2);
				if(++s1 > 31) { p1--; s1 = 0; }
				if(++s2 > 31) { p2--; s2 = 0; }
			}
		}
		return;
	}

	if(x1 < x2 && y1 < y2) {
		for(y = h - 1; y >= 0; y--) {
			p1 = &p[(y1 + y) * i + (x1 + w)/32];
			p2 = &p[(y2 + y) * i + (x2 + w)/32];
			s1 = 31 - ((x1 + w) & 0x1f);
			s2 = 31 - ((x2 + w) & 0x1f);
			for(x = w ; x >= 0; x--) {
				*p2 = (*p2 & (~(1 << s2))) | (((*p1 >> s1) & 1) << s2);
				if(++s1 > 31) { p1--; s1 = 0; }
				if(++s2 > 31) { p2--; s2 = 0; }
			}
		}
	}
#else // STM32F746
	error("DoBlit");
#endif // STM32F746
}



void cmd_blit(void) {
	// Syntax Blit sourceX,sourceY,width,height,DirX,DirY,Roll
	// Source X,Y	: from where we start
	// Width,Height	: Size to cut
	// DirX,DirY	: Direction we move the picture (in pixels)
	// Roll			: 1 we copy what go out of screen on other end.
	// srclayer		: Layer from where we get the graphics
	// This command will use the working buffer !
	// Before to use this command , you have to put some graphics
	// in the working buffer
	int srcx, srcy, dirx, diry, w, h,roll;
	getargs(&cmdline, 13, ",");
	if(argc != 13) error("Invalid syntax");
	srcx	= getinteger(argv[0]);
	srcy	= getinteger(argv[2]);
	w		= getinteger(argv[4]);
	h		= getinteger(argv[6]);
	dirx	= getinteger(argv[8]);
	diry	= getinteger(argv[10]);
	roll	= getinteger(argv[12]);
	GFX_Blit_DMA2D(srcx, srcy, w, h, dirx,  diry,  roll, LCD_CurrentLayer);
}



struct s_SpriteC *SpriteC;
struct s_SpriteP *SpriteP;
int SpriteNbr;                                                      // number of sprites loaded


// this function is only used by cmd_sprite()  -  below
void SpriteToVideo(unsigned short *sp, unsigned short *sm, int *p_dst, int x_dst, int y_dst) {
#if !defined(STM32F7)  // PIC 
	int x, y, xstart, xend, i;
	unsigned int *p;
	int shift;
	unsigned short ts, tm;

	i = HBuf/32;

	// compensate if the x & y coordinates start or end off the screen
	if(x_dst >= HRes) return;
	xstart = 0;
	if(x_dst < 0) { xstart = -x_dst; x_dst = 0; }
	xend = 16;
	if((x_dst + 16) >= HRes) xend -= (x_dst + 16) - HRes;

#if defined(COLOUR)
	if(ModeC == 4) x_dst += 16;
#endif

	// now copy the data
	for(y = 0; y < 16 && y_dst < VRes; y++, y_dst++) {
		if(y_dst < 0) continue;
		p = (unsigned int *)&p_dst[y_dst * i + x_dst/32];
		shift = 31 - (x_dst & 0x1f);
		ts = sp[y];
		tm = sm[y];
		for(x = xstart; x < xend; x++) {
			if(((tm >> x) & 1)) *p = (*p & (~(1 << shift))) | ((unsigned int)((ts >> x) & 1) << shift);
			if(--shift < 0) { p++; shift = 31; }
		}
	}
#else // STM32F746
	error("SpriteToVideo");
#endif // STM32F746
}




// this function is only used by cmd_sprite()  -  below
void SpriteFromVideo(unsigned short *sp, int *p_src, int x_src, int y_src) {
#if !defined(STM32F7)  // PIC 
	int x, y, xstart, xend, i;
	unsigned int *p;
	int shift;
	unsigned short *ts;

	i = HBuf/32;

	// compensate if the x & y coordinates start or end off the screen
	if(x_src >= HRes) return;
	xstart = 0;
	if(x_src < 0) { xstart = -x_src; x_src = 0; }
	xend = 16;
	if((x_src + 16) >= HRes) xend -= (x_src + 16) - HRes;

#if defined(COLOUR)
	if(ModeC == 4) x_src += 16;
#endif

	// now copy the data
	for(y = 0; y < 16 && y_src < VRes; y++, y_src++) {
		if(y_src < 0) continue;
		p = (unsigned int *)&p_src[y_src * i + x_src/32];
		shift = 31 - (x_src & 0x1f);
		ts = &sp[y];
		*ts = 0;
		for(x = xstart; x < xend; x++) {
			*ts |= (((*p >> shift) & 1) << x);
			if(--shift < 0) { p++; shift = 31; }
		}
	}
#else // STM32F746
	error("SpriteFromVideo");
#endif // STM32F746
}



#define SPRITE_OFF  -10000



void fun_collision(void) {
#if !defined(STM32F7)  // PIC 
	int spr, r, i;

	getargs(&ep, 3, ",");
	if(argc != 3) error("Invalid syntax");

	spr = getinteger(argv[0]);
	if(spr < 1 || spr > SpriteNbr) error("Sprite number");
	spr--;
	if(!SpriteNbr || SpriteC[spr].x == SPRITE_OFF) error("Sprite is not on");

	r = 0;

	if(checkstring(argv[2], "EDGE")) {
		int x, lb, rb, tb, bb;
		for(x = i = 0; i < 16; i++) x |= SpriteP[spr].m[i];         // OR all the horizontal lines of the transparency mask together
		for(lb = 0; lb < 14; lb++) if((x >> lb) & 1) break;         // find the number of bits transparent at the left edge
		for(rb = 0; rb < 14; rb++) if((x << rb) & 0x8000) break;    // ditto for right edge
		for(tb = 0; tb < 14; tb++) if(SpriteP[spr].m[tb]) break;    // same for top and bottom edges
		for(bb = 0; bb < 14; bb++) if(SpriteP[spr].m[15 - bb]) break;

		if(SpriteC[spr].x + lb <= 0) r |= 0b0001;                   // collision with the left edge
		if(SpriteC[spr].x + 15 - rb >= HRes - 1) r |= 0b0010;       // collision with the right edge
		if(SpriteC[spr].y + tb <= 0) r |= 0b0100;                   // collision with the top edge
		if(SpriteC[spr].y + 15 - bb >= VRes - 1) r |= 0b1000;       // collision with the bottom edge
		fret = r;
		return;
	}

	if(checkstring(argv[2], "SPRITE")) {
		int z, x, y, xo, yo;
		for(z = 0; z < SpriteNbr; z++) {
			yo = SpriteC[z].y - SpriteC[spr].y;                     // offset to the other sprite on the y axis
			xo = SpriteC[z].x - SpriteC[spr].x;                     // offset to the other sprite on the x axis
			if(z != spr && SpriteC[z].x != SPRITE_OFF && abs(xo) <= 16 && abs(yo) <= 16) { // if they are close
				for(y = 0; y < 16; y++) {                           // step through each line of spr
					for(x = 0; x < 16; x++) {                       // and step thru each bit of spr
						if((SpriteP[spr].m[y] >> x) & 1) {          // of the bit is non transparent in spr
							if(x - xo >= 0 && x - xo < 16 && y - yo >= 0 && y - yo < 16 && ((SpriteP[z].m[y - yo] >> (x - xo)) & 1)) {
								// the sprites overlaps each other
								r = 0b10000;
								if(xo <= 0) r |= 0b0001;
								if(xo >= 0) r |= 0b0010;
								if(yo <= 0) r |= 0b0100;
								if(yo >= 0) r |= 0b1000;
								x = y = 16;                         // force the end of checking this sprite
							} else {
								// check if they are just touching
								if(x - xo - 1 >= 0 && x - xo - 1 < 16 && y - yo >= 0 && y - yo < 16 && ((SpriteP[z].m[y - yo] >> (x - xo - 1)) & 1))
									r |= 0b0001;                    // left edge
								if(x - xo + 1 >= 0 && x - xo + 1 < 16 && y - yo >= 0 && y - yo < 16 && ((SpriteP[z].m[y - yo] >> (x - xo + 1)) & 1))
									r |= 0b0010;                    // right edge
								if(x - xo >= 0 && x - xo < 16 && y - yo - 1 >= 0 && y - yo - 1 < 16 && ((SpriteP[z].m[y - yo - 1] >> (x - xo)) & 1))
									r |= 0b0100;                    // top edge
								if(x - xo >= 0 && x - xo < 16 && y - yo + 1 >= 0 && y - yo + 1 < 16 && ((SpriteP[z].m[y - yo + 1] >> (x - xo)) & 1))
									r |= 0b1000;                    // bottom edge
							}
						}
					}
				}
				// if nothing was found check for corners touching
				if(!r) {
					for(y = 0; y < 16; y++) {                           // step through each line of spr
						for(x = 0; x < 16; x++) {                       // and step thru each bit of spr
							if((SpriteP[spr].m[y] >> x) & 1) {          // of the bit is non transparent in spr
								if(x - xo + 1 >= 0 && x - xo + 1 < 16 && y - yo - 1 >= 0 && y - yo - 1 < 16 && ((SpriteP[z].m[y - yo - 1] >> (x - xo + 1)) & 1))
									r |= 0b0110;                    // top right corner
								if(x - xo - 1 >= 0 && x - xo - 1 < 16 && y - yo - 1 >= 0 && y - yo - 1 < 16 && ((SpriteP[z].m[y - yo - 1] >> (x - xo - 1)) & 1))
									r |= 0b0101;                    // top left corner
								if(x - xo + 1 >= 0 && x - xo + 1 < 16 && y - yo + 1 >= 0 && y - yo + 1 < 16 && ((SpriteP[z].m[y - yo + 1] >> (x - xo + 1)) & 1))
									r |= 0b1010;                    // bottom right corner
								if(x - xo - 1 >= 0 && x - xo - 1 < 16 && y - yo + 1 >= 0 && y - yo + 1 < 16 && ((SpriteP[z].m[y - yo + 1] >> (x - xo - 1)) & 1))
									r |= 0b1001;                    // bottom left corner
							}
						}
					}
				}
			}
		}
		fret = r;
		return;
	}

	error("Invalid syntax");
#else // STM32F746
	error("fun_collision");
#endif // STM32F746
}



void cmd_sprite(void) {
	char *p;	
	uint8_t LoadStatus = 0;
	// LoadStatus Values:	0 = no error
	//						3 = File open error

	// Syntax : Sprite Load "spritefile.bin"
	if(*cmdline == GetTokenValue("LOAD")) {
		// Load a Sprite File
		char *fp;

		p = cmdline + 1;                                            // step over the token
		skipspace(p);
		fp = GetFileName(p, NULL);
		LoadStatus = GFX_Load_Sprite(fp,0);
		if(LoadStatus != 0) error("Sprite Load error");
		return;
	}

	// Syntax : Sprite Set 3,0
	// This will put the 3rd Sprite info recorded to SDRAM into the Sprite array 0
	if((p = checkstring(cmdline, "SET")) != NULL) {
		// Put Sprite info in the Sprite Array
		int src, dst;

		getargs(&p, 3, ",");                                      // must be the first in a block
		if(argc != 3) error("Invalid number of parameters");
		src = getinteger(argv[0]);
		if((src < 0) | (src >= GFX_SPRITE_MAX)) error("Source Sprite must be 0 to 499");
		dst = getinteger(argv[2]);
		if((dst < 0) | (dst >= NbSpriteShow)) error("Destination Sprite must be 0 to 499");

		// We set the information into the Sprite array
		// Here the most important is the src , the other value are just initialized
		// to default.
		SpriteShow[dst].SprNum = src;
		SpriteShow[dst].x = 0;
		SpriteShow[dst].y = 0;
		return;
	}

	// Syntax : Sprite ON sprnum,x,y
	// sprnum is the number from the sprite array
	// x,y are the coordinate from the upper left corner from the sprite
	if((p = checkstring(cmdline, "ON")) != NULL) {
		// Show the Sprite on Current Selected Layer
		int sprnum, x, y, show_transparent,transp_color;
		p = cmdline + 2;                                            // step over the token
		skipspace(p);
		getargs(&p, 5, ",");
		if(argc != 5) error("Invalid number of parameters");
		sprnum = getinteger(argv[0]);
		x = getinteger(argv[2]);
		y = getinteger(argv[4]);
		SpriteShow[sprnum].x = x;
		SpriteShow[sprnum].y = y;

		GFX_Sprite_Show_DMA2D(SpriteShow[sprnum].SprNum,SpriteShow[sprnum].x,SpriteShow[sprnum].y,LCD_CurrentLayer);
		return;
	}
}

void cmd_map(void){
	char *p;
	uint8_t LoadStatus = 0;
	// LoadStatus Values:	0  = no error
	//						3  = File open error
	//						11 = Map too big for the Map buffer

	// Syntax : Map Load "mapfile.map"
	if(*cmdline == GetTokenValue("LOAD")) {
		// Load a Map File
		char *fp;

		p = cmdline + 1;                                            // step over the token
		skipspace(p);
		fp = GetFileName(p, NULL);
		LoadStatus = GFX_Load_Map(fp,0);
		if(LoadStatus != 0) error("Map Load error");
		return;
	}


	// Syntax : Map ON startx,starty,Width,Height,destx,desty,transparent,transparent color
	// startx,starty are the coordinate from the upper left corner from where we start to get the map
	// Width,Height are the size we want to get from the map
	// destx,desty are the coordinate from where we put the map into the screen
	// transparent at 0 will show the transparent color , other than 0 will hide it.
	// transparent color is the 16bit transparent color value (or Sprite background color)
	if((p = checkstring(cmdline, "ON")) != NULL) {
		// Show the Map on Current Selected Layer
		int sx , sy , w , h , dx , dy , show_transparent , transp_color;
		p = cmdline + 2;								// step over the token
		skipspace(p);
		getargs(&p, 15, ",");
		if(argc != 15) error("Invalid number of parameters");
		sx = getinteger(argv[0]);
		sy = getinteger(argv[2]);
		w  = getinteger(argv[4]);
		h  = getinteger(argv[6]);
		dx = getinteger(argv[8]);
		dy = getinteger(argv[10]);
		show_transparent = getinteger(argv[12]);
		transp_color = getinteger(argv[14]);

		GFX_Show_Map_DMA2D(sx, sy, w, h, dx, dy,LCD_CurrentLayer,show_transparent);
		return;
	}
}


void cmd_pixel(void){
	int x, y, colour;
	getcoord(cmdline, &x, &y);
	cmdline = getclosebracket(cmdline) + 1;
	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) error("Invalid syntax");
	++cmdline;
	if(!*cmdline) error("Invalid syntax");
	colour = getinteger(cmdline);
	DefaultFgColour = colour;
	GFX_SetPixel(x, y, colour,LCD_CurrentLayer);
	lastx = x; lasty = y;
}



void fun_pixel(void){
	// Get the pixel color at x,y in the selected layer
	// if used , Layer have to be 0,1,2 or 10 for the map buffer
	// You don't have to change the active layer for use this command'
	// Syntax : color = Pixel(x,y,[Layer])
	int x, y;
	int layer = -1;
	getargs(&ep, 5, ",");										// this is a macro and must be the first executable stmt in a block
	if(argc < 3) error("Invalid Syntax");
	x 		= getinteger(argv[0]);
	y 		= getinteger(argv[2]);
	if (argc == 5) layer = getinteger(argv[4]);
	if(layer != -1){
		if((layer != 0) & (layer != 1) & (layer != 2) & (layer != 10)) error("Layer number must be 0,1,2 or 10 for Map buffer");
		if(layer <=2)
			fret = GFX_GetPixel(x,y,layer);
		else
			fret = MapMemory[(Map_Width * y) + x];}
	else
		fret = GFX_GetPixel(x,y,LCD_CurrentLayer);
}


void fun_hres(void) {
	fret = (float)LCD_MAXX;
}


void fun_vres(void) {
	fret = (float)LCD_MAXY;
}


void fun_lastx(void) {
	fret = (float)lastx;
}


void fun_lasty(void) {
	fret = (float)lasty;
}


void fun_black(void) {
	fret = (float)RGB_COL_BLACK;
}


void fun_blue(void) {
	fret = (float)RGB_COL_BLUE;
}


void fun_green(void) {
	fret = (float)RGB_COL_GREEN;
}


void fun_cyan(void) {
	fret = (float)RGB_COL_CYAN;
}


void fun_red(void) {
	fret = (float)RGB_COL_RED;
}


void fun_purple(void) {
	fret = (float)RGB_COL_MAGENTA;
}


void fun_yellow(void) {
	fret = (float)RGB_COL_YELLOW;
}


void fun_white(void) {
	fret = (float)RGB_COL_WHITE;
}

void fun_orange(void) {fret = (float)ORANGE;}
void fun_brown(void)  {fret = (float)BROWN;}
void fun_lred(void) {fret = (float)LRED;}
void fun_dgrey(void)  {fret = (float)DGREY;}
void fun_grey(void)  {fret = (float)GREY;}
void fun_lgrey(void) {fret = (float)LGREY;}
void fun_lgreen(void)  {fret = (float)LGREEN;}
void fun_lblue(void)  {fret = (float)LBLUE;}


// utility routine used to read a number of bytes
// only used by cmd_loadbmp() below
unsigned int xread(int nbr, int fnbr) {
#if !defined(STM32F7)  // PIC 
	unsigned int i, t;
	for(t = i = 0; i < nbr; i++) {
		if(MMfeof(fnbr)) error("Corrupt file");
		t |= (MMfgetc(fnbr) & 0xff) << (i * 8);
	}
	return t;
#else // STM32F746
	error("xread");
	return 0;
#endif // STM32F746
}


void cmd_loadbmp(void) {
	char *p;
	int fp;
	int xOrigin, yOrigin,buffnum;
	int LoadStatus;

	// get the command line arguments
	getargs(&cmdline, 7, ",");                            // this MUST be the first executable line in the function
	if(argc == 0) error("Invalid number of parameters");
	p = GetFileName(argv[0], NULL);
	xOrigin = yOrigin = 0;
	buffnum = LCD_CurrentLayer;
	if(argc >= 3) xOrigin = getinteger(argv[2]);          // get the x origin (optional) argument
	if(argc >= 5) yOrigin = getinteger(argv[4]);          // get the y origin (optional) argument
	if(argc == 7) buffnum = getinteger(argv[6]);           // get the buffer (optional) argument
	if((buffnum != 0) & (buffnum != 1) & (buffnum != 2) & (buffnum != 10)) error("Wrong Layer number , must be 0,1,2 or 10");

	// open the file
	if(strchr(p, '.') == NULL) strcat(p, ".BMP");
	fp = FindFreeFileNbr();
	MMfopen(p, "r", fp);

	// load bmp
	LoadStatus = UB_Picture_DrawBmp(&MMFile,xOrigin,yOrigin,buffnum);
	// close file
	MMfclose(fp);

	// show error
	sprintf(p,"BMP Load error [%d]",LoadStatus);
	if(LoadStatus != 0) error(p);
}



// utility routine used to write a number of bytes
// only used by cmd_savebmp() below
void xwrite(char *p, int nbr, int fnbr) {
	while(nbr--) MMfputc(*p++, fnbr);
}


// write a BMP file
// based on bmpsuite.c by Jason Summers (entropymine.com/jason/bmpsuite/)
// and pf1bit_bmp.c by Adam Majewski (fraktal.republika.pl)
void cmd_savebmp(void) {
	char *p;
	int fp, x,y,buffnum;
	char r,g,b;
	uint16_t color;

	// get the command line arguments
	getargs(&cmdline, 3, ",");                            // this MUST be the first executable line in the function
	if(argc == 0) error("Invalid number of parameters");
	p = GetFileName(argv[0], NULL);
	buffnum = LCD_CurrentLayer;
	if(argc == 3) buffnum = getinteger(argv[2]);           // get the buffer (optional) argument
	if((buffnum != 0) & (buffnum != 1) & (buffnum != 2) & (buffnum != 10)) error("Wrong Layer number , must be 0,1,2 or 10");

	// open the file
	if(strchr(p, '.') == NULL) strcat(p, ".BMP");
	fp = FindFreeFileNbr();
	MMfopen(p, "w", fp);

	// save bmp header
	xwrite(BMP_HEADER,54,fp);

	  // save picture data
	  for(y=0;y<LCD_MAXY;y++) {
	    for(x=0;x<LCD_MAXX;x++) {
	      color=GFX_GetPixel(x,LCD_MAXY-y-1,buffnum); // save bottom to top
	      r=((color&0xF800)>>8);  // 5bit red
	      g=((color&0x07E0)>>3);  // 6bit green
	      b=((color&0x001F)<<3);  // 5bit blue
	      MMfputc(b, fp);
	      MMfputc(g, fp);
	      MMfputc(r, fp);
	    }
	  }

	MMfclose(fp);
}

// Show Ellipse on screen
// Syntax : Ellipse(x,y),radius1,radius2,outcolor,incolor,F
void cmd_ellipse(void){
		int x, y, radius1, radius2, incolor, outcolor, fill;
		getargs(&cmdline, 15, ",");
		if(*argv[0] != '(') error("Expected opening bracket");
		if(toupper(*argv[argc - 1]) == 'F') {
			argc -= 2;
			fill = true;
		} else
			fill = false;
		// Get x,y Coordinate
		getcoord(argv[0] + 1, &x, &y);
		// Get radius1
		radius1 = getinteger(argv[2]);
		if(radius1 == 0) return;                                         //nothing to draw
		if(radius1 < 1) error("Invalid argument for radius 1");
		// Get radius2
		radius2 = getinteger(argv[4]);
		if(radius2 == 0) return;                                         //nothing to draw
		if(radius2 < 1) error("Invalid argument for radius 2");
		// Get outcolor
		if(argc > 5 && *argv[6]) {
			outcolor = getnumber(argv[6]);
			DefaultFgColour = outcolor;}
		else
			outcolor = DefaultFgColour;
		// Get incolor
		if(argc > 7 && *argv[8]) {
			incolor = getnumber(argv[8]);
			DefaultBgColour = incolor;}
		else
			incolor = DefaultBgColour;
		if(fill == true)
			GFX_DrawFullEllipse(x, y, radius1, radius2, incolor, outcolor, LCD_CurrentLayer);
		else
		{
			GFX_DrawEllipse(x, y, radius1, radius2, outcolor, LCD_CurrentLayer);
		}
}

// Show Triangle on screen
// Syntax : Triangle(x1,y1,x2,y2,x3,y3),outcolor,incolor,F
void cmd_triangle(void){
		int x1,y1,x2,y2,x3,y3, incolor, outcolor, fill;
		TriPoint tr;
		getargs(&cmdline, 7, ",");  // get command with max 5 arguments
		if(argc < 1) error("Invalid syntax"); // minimum 1 argument
		// check argument zero '('
		if(*argv[0] != '(') error("Expected opening bracket");   // arg0 must be '('

		// check fill argument or nothing
		if(toupper(*argv[argc - 1]) == 'F') {
			argc -= 2; //
			fill = true;
		} else
			fill = false;

		// get 3 koordinate pairs
		get3coord(argv[0] + 1, &x1, &y1, &x2, &y2, &x3, &y3);

		// check color argument or nothing
		if(argc > 1 && *argv[2]) {
			outcolor = getinteger(argv[2]);
			DefaultFgColour = outcolor;
		}
		else
			outcolor = DefaultFgColour;

		if(argc > 3 && *argv[4]) {
			incolor = getnumber(argv[4]);
			DefaultBgColour = incolor;}
		else
			incolor = DefaultBgColour;

		tr.ax = (float)x1;
		tr.ay = (float)y1;
		tr.bx = (float)x2;
		tr.by = (float)y2;
		tr.cx = (float)x3;
		tr.cy = (float)y3;

		if(fill == true)
		{
			// draw filled triangle
			GFX_Draw_Full_Triangle(tr,incolor,outcolor,LCD_CurrentLayer);
		}
		else
		{
			// draw triangle
			GFX_Draw_Triangle(tr,outcolor,LCD_CurrentLayer);
		}
}

// Set the drawing layer
// Syntax : SetLayer num , num can be 0,1,2
void cmd_setlayer(void) {
		int LayerNumber;
		uint32_t l_addr = 0;
		if(*cmdline) {								// has the user provided a Layer number ?

			LayerNumber = getinteger(cmdline);		// get the Layer number
			if(LayerNumber < 0 || LayerNumber > 2) error("Invalid Layer number : use 0 to 2");
			switch (LayerNumber)
			{
			case 0:
				l_addr = GFX_FRAME_BUFFER;
				break;
			case 1:
				l_addr = GFX_FRAME_BUFFER + BUFFER_OFFSET;
				break;
			case 2:
				l_addr = GFX_FRAME_BUFFER + (2 * BUFFER_OFFSET);
				break;
			default:
				return;
			}
			LCD_CurrentFrameBuffer = l_addr;
			LCD_CurrentLayer = LayerNumber;
		}
		else
			error("Layer number required '0 to 2'");
}

// Set and show a layer
// Syntax : ShowLayer num , num can be 0 or 1
void cmd_showlayer(void) {
		static LTDC_HandleTypeDef  hLtdcHandler;
		int LayerNumber;
		uint32_t Previous_Layer = LCD_CurrentLayer;
		if(*cmdline) {				// has the user provided a Layer number ?
			LayerNumber = getinteger(cmdline);		// get the Layer number
			if(LayerNumber < 0 || LayerNumber > 1) error("Invalid Layer to show : use 0 or 1");
			switch (LayerNumber)
			{
			case 0:
				LCD_CurrentFrameBuffer = LCD_FRAME_BUFFER;
				LCD_CurrentLayer = 0;
				UB_LCD_Refresh();
				LCD_CurrentFrameBuffer = LCD_FRAME_BUFFER;
				LCD_CurrentLayer = 0;
				break;
			case 1:
				LCD_CurrentFrameBuffer = LCD_FRAME_BUFFER + LCD_FRAME_OFFSET;
				LCD_CurrentLayer = 1;
				UB_LCD_Refresh();
				LCD_CurrentFrameBuffer = LCD_FRAME_BUFFER + LCD_FRAME_OFFSET;
				LCD_CurrentLayer = 1;
				break;
			default:
				return;
			}
		}
		else
			error("Layer number required '0 to 1'");
}

// Copy one layer to another one
// Syntax : CopyLayer source,destination
void cmd_copylayer(void) {
		int srclayer, dstlayer;
		getargs(&cmdline, 3, ",");
		if(argc != 3) error("syntax error");
		srclayer = getinteger(argv[0]);
		if((srclayer < 0) || (srclayer > 2)) error("Source Layer have to be 0 to 2");
		dstlayer = getinteger(argv[2]);
		if((dstlayer < 0) || (dstlayer > 2)) error("Destination Layer have to be 0 to 2");
		if(srclayer == dstlayer) error("I cannot copy layer to itself");
		GFX_Layer_Copy((uint8_t)srclayer , (uint8_t)dstlayer);
}

// Return the actual layer used
// syntax : variable = GetLayer , or , Print GetLayer
void fun_getlayer(void) {
		fret = (float)LCD_CurrentLayer;
}

// Show a Quad on screen at a given angle
// Syntax : Quad(x,y,w,h,angle),outcolor,incolor,F
void cmd_quad(void) {
	int x,y,w,h,angle, incolor, outcolor, fill;
	getargs(&cmdline, 7, ",");  // get command with max 6 arguments
	if(argc < 1) error("Invalid syntax"); // minimum 1 argument
	// check argument zero '('
	if(*argv[0] != '(') error("Expected opening bracket");   // arg0 must be '('

	// check fill argument or nothing
	if(toupper(*argv[argc - 1]) == 'F') {
		argc -= 2; //
		fill = true;
	} else
		fill = false;

	// get 3 koordinate pairs
	getquadparam(argv[0] + 1, &x, &y, &w, &h, &angle);

	// check color argument or nothing
	if(argc > 1 && *argv[2]) {
		outcolor = getinteger(argv[2]);
		DefaultFgColour = outcolor;
	}
	else
		outcolor = DefaultFgColour;

	if(argc > 3 && *argv[4]) {
		incolor = getnumber(argv[4]);
		DefaultBgColour = incolor;}
	else
		incolor = DefaultBgColour;

	if(fill == true)
	{
		// draw filled quad
		GFX_DrawFullQuad(x,y,w,h,angle,incolor,outcolor,LCD_CurrentLayer);
	}
	else
	{
		// draw qaud
		GFX_DrawQuad(x,y,w,h,angle,outcolor,LCD_CurrentLayer);
	}
}

// Load and show 3D Objects
// Syntax : Obj3d Load "obj3d.b3d", Objnumber , incolor , outcolor
void cmd_oj3d(void){
	char *p;
	uint8_t	LoadStatus = 0;

	if(*cmdline == GetTokenValue("LOAD")) {
		// Load a Sprite File
		char *fp;
		int objnumber = 0;
		int incolor , outcolor;

		p = cmdline + 1;                                            // step over the token
		skipspace(p);
		getargs(&p, 7, ",");
		if(argc != 7) error("Invalid number of parameters");
		fp = GetFileName(argv[0], NULL);
		objnumber = getinteger(argv[2]);
		incolor   = getinteger(argv[4]);
		outcolor  = getinteger(argv[6]);
		LoadStatus = Load_3DObj(fp,objnumber,incolor,outcolor);
		if(LoadStatus == 1) error("Wrong Object number , must be 0 to 24");
		if(LoadStatus == 2) error("Too much Points or Faces in this Object , max is 599");
		if(LoadStatus == 3) error("Obj3D File open error");
		return;
	}

	// Syntax : Obj3d SET objnum,x,y,z,ax,ay,az,zoom,active
	// objnum		: object number
	// x,y,z		: object coordinate
	// ax,ay,az		: object angles
	// Zoom			: Size for object
	// Active		: Show this object when active is set to 1
	if((p = checkstring(cmdline, "SET")) != NULL) {
		// Show the Sprite on Current Selected Layer
		int objnumber;
		p = cmdline + 3;								// step over the token
		skipspace(p);
		getargs(&p, 17, ",");
		if(argc != 17) error("Invalid number of parameters");
		objnumber = getinteger(argv[0]);
		if((objnumber < 0) | (objnumber >= MaxObj)) error("ObjNumber must be 0 to 24");
		Object3D[objnumber].Coord.x =  getnumber(argv[2]);
		Object3D[objnumber].Coord.y =  getnumber(argv[4]);
		Object3D[objnumber].Coord.z =  getnumber(argv[6]);
		Object3D[objnumber].Angle.x = getinteger(argv[8])  % 360;
		Object3D[objnumber].Angle.y = getinteger(argv[10]) % 360;
		Object3D[objnumber].Angle.z = getinteger(argv[12]) % 360;
		Object3D[objnumber].Zoom 	= getnumber(argv[14]);
		Object3D[objnumber].Active 	= getinteger(argv[16]);
		return;
	}
	// Syntax : Obj3d ON filled
	// filled		: 1 = filled , != 1 not filled
	if((p = checkstring(cmdline, "ON")) != NULL) {
		// Show the Sprite on Current Selected Layer
		int filled,n;
		p = cmdline + 2;								// step over the token
		skipspace(p);
		getargs(&p, 1, " ");
		if(argc != 1) error("Invalid number of parameters");
		filled = getinteger(argv[0]);
		for(n=0;n < MaxObj;n++)	// Prevent to show 3D when none is loaded or active
			if((Object3D[n].Loaded == 1) & (Object3D[n].Active == 1)){
				Show_3DObject(filled,LCD_CurrentLayer);
				n = MaxObj + 1;}

		return;
	}
}

// Load and Show a JPG picture
// Syntax : LOADJPG "image.jpg", x , y , buffer
// buffer can be 0,1,2 or 10 for Map buffer
void cmd_jpg(void){
	char *p;
	int xOrigin, yOrigin,buffnum;
	int LoadStatus,fp;
	// LoadStatus Values:	0  = no error
	//						3  = File open error
	//						11 = Map too big for the Map buffer

	// Syntax : LoadJPG "image.jpg"[,x[,y[,buffnum]]]
	// buffnum 10 is the Map Layer

	// get the command line arguments
	getargs(&cmdline, 7, ",");                            // this MUST be the first executable line in the function
	if(argc == 0) error("Invalid number of parameters");
	p = GetFileName(argv[0], NULL);
	xOrigin = yOrigin = 0;
	buffnum = LCD_CurrentLayer;
	if(argc >= 3) xOrigin = getinteger(argv[2]);          // get the x origin (optional) argument
	if(argc >= 5) yOrigin = getinteger(argv[4]);          // get the y origin (optional) argument
	if(argc == 7) buffnum = getinteger(argv[6]);          // get the buffer (optional) argument
	if((buffnum != 0) & (buffnum != 1) & (buffnum != 2) & (buffnum != 10)) error("Wrong Layer number , must be 0,1,2 or 10");

	// open the file
	if(strchr(p, '.') == NULL) strcat(p, ".JPG");
	fp = FindFreeFileNbr();
	MMfopen(p, "r", fp);

	// load jgp
	LoadStatus = UB_Picture_DrawJpg(&MMFile,xOrigin,yOrigin,buffnum);
	// close file
	MMfclose(fp);

	// show error
	if(LoadStatus == 11) error("Picture too big for the Map Buffer");
	sprintf(p,"JPG Load error [%d]",LoadStatus);
	if(LoadStatus != 0) error(p);
}

// Record a point for a Polygon
// Syntax : PolyPoint Polygon number,point number,x,y
// Polygon number must be between 0 and 99
// Point number must be between 0 and 99
// x,y are the point coordinate
void cmd_polypoint(void){
	int polynum,pointnum,x,y;

	getargs(&cmdline, 7, ",");
	if(argc != 7) error("syntax error");
	// Get the polygon number
	polynum = getinteger(argv[0]);
	if((polynum < 0) | (polynum > (MaxPolygon - 1))) error("Polygon number must be between 0 and 99");
	// Get the point number
	pointnum = getinteger(argv[2]);
	if((pointnum < 0) | (pointnum > (MaxPolyPoint - 1))) error("Point number must be between 0 and 99");
	x = getinteger(argv[4]);
	y = getinteger(argv[6]);
	PolySet[polynum].Pts[pointnum].x = (int16_t)(x);
	PolySet[polynum].Pts[pointnum].y = (int16_t)(y);
}

// Set the Center point from the polygon
// Syntax : PolyCenter Polygon number,x,y
// Polygon number must be between 0 and 99
// x,y are the center point coordinate
void cmd_polycenter(void){
	int polynum,x,y;

	getargs(&cmdline, 5, ",");
	if(argc != 5) error("syntax error");
	// Get the polygon number
	polynum = getinteger(argv[0]);
	if((polynum < 0) | (polynum > (MaxPolygon - 1))) error("Polygon number must be between 0 and 99");
	x = getinteger(argv[2]);
	y = getinteger(argv[4]);
	PolySet[polynum].Center.x = (int16_t)(x);
	PolySet[polynum].Center.y = (int16_t)(y);
}

// Move the polygon
// Syntax : PolyMove Polygon number,x,y
// Polygon number must be between 0 and 99
// x,y are the coordinate where we move the center point and all other polygon point relative to center
void cmd_polymove(void){
	int polynum,x,y;
	int diffx,diffy;
	int cnt = 0;

	diffx = diffy = 0;

	getargs(&cmdline, 5, ",");
	if(argc != 5) error("syntax error");
	// Get the polygon number
	polynum = getinteger(argv[0]);
	if((polynum < 0) | (polynum > (MaxPolygon - 1))) error("Polygon number must be between 0 and 99");
	x = getinteger(argv[2]);
	y = getinteger(argv[4]);
	// Get difference between old center point and the actual x,y coordinate
	diffx = x - PolySet[polynum].Center.x;
	diffy = y - PolySet[polynum].Center.y;
	// Move all points and center point from the polygon
	PolySet[polynum].Center.x += (int16_t)(diffx);
	PolySet[polynum].Center.y += (int16_t)(diffy);
	for(cnt = 0;cnt < MaxPolyPoint;cnt++){
		PolySet[polynum].Pts[cnt].x += (int16_t)(diffx);
		PolySet[polynum].Pts[cnt].y += (int16_t)(diffy);
	}
}

// Draw a Filled or Empty Polygon
// Syntax : Polygon Polygon number , number of point , outcolor , incolor , F
// Polygon number must be between 0 and 99
// number of point must be between 3 and 100
// 'F' is for Fill the polygon
// If 'F' is specified you have to give the incolor
void cmd_polygon(void){
	int polynum,pointnum,incolor,outcolor,filled;

	getargs(&cmdline, 9, ",");
	if(argc < 5) error("syntax error");

	// check fill argument or nothing
	if(toupper(*argv[argc - 1]) == 'F') {
		argc -= 2; //
		filled = true;
	} else
		filled = false;

	// Get the polygon number
	polynum = getinteger(argv[0]);
	// Get the number of point from the polygon
	pointnum = getinteger(argv[2]);
	if((pointnum < 3) | (pointnum > MaxPolyPoint)) error("Number of points must be between 3 and 100");

	// Get the colors
	outcolor 	= getinteger(argv[4]);
	if(argc > 5 && *argv[6])
		incolor = getinteger(argv[6]);
	else
		incolor = 0;

	if(filled == true)
	{	// draw filled Polygon
		GFX_DrawFullPolygon(polynum, pointnum, incolor, outcolor, LCD_CurrentLayer);
		}
	else
	{	// draw empty Polygon
		GFX_DrawPolygon(polynum, pointnum, outcolor, LCD_CurrentLayer);}
}

// Draw a Filled or Empty Rotated Polygon
// Syntax : RotatePoly Polygon number , number of point , Angle , outcolor , incolor , F
// Polygon number must be between 0 and 99
// number of point must be between 3 and 100
// Angle : Angle for the rotation
// 'F' is for Fill the polygon
// If 'F' is specified you have to give the incolor
void cmd_rotatepoly(void){
	int polynum,pointnum,angle,incolor,outcolor,filled;

	getargs(&cmdline, 11, ",");
	if(argc < 7) error("syntax error");

	// check fill argument or nothing
	if(toupper(*argv[argc - 1]) == 'F') {
		argc -= 2; //
		filled = true;
	} else
		filled = false;

	// Get the polygon number
	polynum = getinteger(argv[0]);
	// Get the number of point from the polygon
	pointnum = getinteger(argv[2]);
	if((pointnum < 3) | (pointnum > MaxPolyPoint)) error("Number of points must be between 3 and 100");

	// Angle to rotate
	angle = getinteger(argv[4]) % 360;
	// Get the colors
	outcolor 	= getinteger(argv[6]);
	if(argc > 7 && *argv[8])
		incolor = getinteger(argv[8]);
	else
		incolor = 0;

	if(filled == true)
	{	// draw filled Polygon
		GFX_RotatePolygon(polynum, pointnum, angle, incolor, outcolor, 1, LCD_CurrentLayer);}
	else
	{	// draw empty Polygon
		GFX_RotatePolygon(polynum, pointnum, angle, 0, outcolor, 0, LCD_CurrentLayer);}
}

// Load Polygon from File
// Syntax : LoadPoly "polyname.pol" , Polygon Number
// Polygon number must be between 0 and 99
// Polygon file format
//     Number of point     : 1 word
//     Coord Center X      : 1 word
//     Coord Center Y      : 1 word
//     Coord X pts 0       : 1 word
//     Coord Y pts 0       : 1 word
//     Coord x pts ...
//     Coord Y pts ...
//     Coord X last point  : 1 word
//     Coord Y last point  : 1 word
//	   End of File
void cmd_loadpoly(void) {
	char *p;
	int fp;
	int NbPoint,PolyNum, cnt;
	char b1,b2;

	// get the command line arguments
	getargs(&cmdline, 3, ",");
	if(argc == 0) error("Invalid number of parameters");
	p = GetFileName(argv[0], NULL);
	PolyNum = 0;
	PolyNum = getinteger(argv[2]);          // get the polygon number

	// open the file
	if(strchr(p, '.') == NULL) strcat(p, ".POL");
	fp = FindFreeFileNbr();
	MMfopen(p, "r", fp);

	// load the polygon
	// Get the number of point from the polygon
	b1 = MMfgetc(fp);			// LSB NbPoint
	b2 = MMfgetc(fp);			// MSB NbPoint
	NbPoint = (b2 << 8) + b1;
	if((NbPoint < 3) | (NbPoint > (MaxPolyPoint - 1))) {
		// close file
		MMfclose(fp);
		error("NbPoint must be between 3 and 100");
	}
	// Get the Center point point from the polygon
	b1 = MMfgetc(fp);			// LSB Center X
	b2 = MMfgetc(fp);			// MSB Center Y
	PolySet[PolyNum].Center.x = (b2 << 8) + b1;
	b1 = MMfgetc(fp);			// LSB Center Y
	b2 = MMfgetc(fp);			// MSB Center Y
	PolySet[PolyNum].Center.y = (b2 << 8) + b1;
	// Read all Data point from the polygon
	for(cnt = 0 ; cnt < NbPoint ; cnt++) {
		// Get the X coordinate from the point
		b1 = MMfgetc(fp);			// LSB X coord
		b2 = MMfgetc(fp);			// MSB X coord
		PolySet[PolyNum].Pts[cnt].x = (int16_t)((b2 << 8) + b1);
		// Get the Y coordinate from the point
		b1 = MMfgetc(fp);			// LSB Y coord
		b2 = MMfgetc(fp);			// MSB Y coord
		PolySet[PolyNum].Pts[cnt].y = (int16_t)((b2 << 8) + b1);
	}
	// close file
	MMfclose(fp);
}

// Draw a filled or Empty rectangle
// Syntax : Rect x , y , width , height , outcolor , incolor , F
// x , y			: coordinate from the upper left corner from the rectangle
// width , height	: Size of the rectangle
// outcolor			: Rectangle border color
// incolor			: Fill color
// F				: We fill the rectangle if specified
void cmd_rect(void){
	int x,y,width,height,outcolor,incolor,filled;

	getargs(&cmdline, 13, ",");
	if(argc < 9) error("syntax error");

	// check fill argument or nothing
	if(toupper(*argv[argc - 1]) == 'F') {
		argc -= 2; //
		filled = true;
	} else
		filled = false;

	// Get the x coordinate
	x = getinteger(argv[0]);
	// Get the y coordinate
	y = getinteger(argv[2]);
	// Get the width
	width = getinteger(argv[4]);
	// Get the height
	height = getinteger(argv[6]);
	// Get the border color
	outcolor = getinteger(argv[8]);
	if(argc > 9 && *argv[10])
		incolor = getinteger(argv[10]);
	else
		incolor = 0;

	if(filled == true)
	{	// draw filled rectangle
		GFX_DrawFullRect(x, y, width, height, incolor, outcolor, LCD_CurrentLayer);}
	else
	{	// draw empty rectangle
		GFX_DrawRect(x, y, width, height, outcolor, LCD_CurrentLayer);}
}

// Draw a filled or Empty rounded corner rectangle
// Syntax : RoundRect x , y , width , height , radius , outcolor , incolor , F
// x , y			: coordinate from the upper left corner from the rectangle
// width , height	: Size of the rectangle
// radius			: Rounded corner radius
// outcolor			: Rectangle border color
// incolor			: Fill color
// F				: We fill the rectangle if specified
void cmd_roundrect(void){
	int x,y,width,height,radius,outcolor,incolor,filled;

	getargs(&cmdline, 15, ",");
	if(argc < 11) error("syntax error");

	// check fill argument or nothing
	if(toupper(*argv[argc - 1]) == 'F') {
		argc -= 2; //
		filled = true;
	} else
		filled = false;

	// Get the x coordinate
	x = getinteger(argv[0]);
	// Get the y coordinate
	y = getinteger(argv[2]);
	// Get the width
	width = getinteger(argv[4]);
	// Get the height
	height = getinteger(argv[6]);
	// Get the radius
	radius = getinteger(argv[8]);
	// Get the border color
	outcolor = getinteger(argv[10]);
	if(argc > 11 && *argv[12])
		incolor = getinteger(argv[12]);
	else
		incolor = 0;

	if(filled == true)
	{	// draw filled Polygon
		GFX_FullRoundedRectangle(x, y, width, height, radius, outcolor, incolor, LCD_CurrentLayer);}
	else
	{	// draw empty Polygon
		GFX_RoundedRectangle(x, y, width, height, radius, outcolor, LCD_CurrentLayer);}
}

/***********************************************************************************************
utility functions used by the custom commands
 ************************************************************************************************/


void getcoord(char *p, int *x, int *y) {
		char *tp, *ttp;
		char b[STRINGSIZE];

		tp = getclosebracket(p);
		*tp = 0;														// remove the closing brackets
		strcpy(b, p);													// copy the coordinates to the temp buffer
		*tp = ')';														// put back the closing bracket
		ttp = b;														// kludge (todo: fix this)
		{
			getargs(&ttp, 3, ",");										// this is a macro and must be the first executable stmt in a block
			if(argc != 3) error("Invalid Syntax");
			*x = getinteger(argv[0]);
			*y = getinteger(argv[2]);
		}
}

void get3coord(char *p, int *x1, int *y1, int *x2, int *y2, int *x3, int *y3) {
		char *tp, *ttp;
		char b[STRINGSIZE];

		tp = getclosebracket(p);
		*tp = 0;														// remove the closing brackets
		strcpy(b, p);													// copy the coordinates to the temp buffer
		*tp = ')';														// put back the closing bracket
		ttp = b;														// kludge (todo: fix this)
		{
			getargs(&ttp, 11, ",");										// this is a macro and must be the first executable stmt in a block
			if(argc != 11) error("Invalid Syntax");
			*x1 = getinteger(argv[0]);
			*y1 = getinteger(argv[2]);
			*x2 = getinteger(argv[4]);
			*y2 = getinteger(argv[6]);
			*x3 = getinteger(argv[8]);
			*y3 = getinteger(argv[10]);
		}
}

void getquadparam(char *p, int *x, int *y, int *w, int *h, int *angle) {
	char *tp, *ttp;
	char b[STRINGSIZE];

	tp = getclosebracket(p);
	*tp = 0;														// remove the closing brackets
	strcpy(b, p);													// copy the coordinates to the temp buffer
	*tp = ')';														// put back the closing bracket
	ttp = b;														// kludge (todo: fix this)
	{
		getargs(&ttp, 9, ",");										// this is a macro and must be the first executable stmt in a block
		if(argc != 9) error("Invalid Syntax");
		*x = getinteger(argv[0]);
		*y = getinteger(argv[2]);
		*w = getinteger(argv[4]);
		*h = getinteger(argv[6]);
		*angle = getinteger(argv[8]);
	}
}
