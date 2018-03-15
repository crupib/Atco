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
#if defined(COLOUR)
	if(*cmdline) {                                                  // has the user provided a colour?
    	int old, t;
    	old = DefaultBgColour;
    	t = getinteger(cmdline);                                    // get the background colour
    	if(t < 0 || t > 7) error("Invalid colour");
    	DefaultBgColour = t;                                        // overide the background colour
    	MMcls();													// clear screen and home cursor for the video
    	DefaultBgColour = old;                                      // restore the old background colour
    } else
#endif
    	MMcls();													// if no colour just clear screen
}


void cmd_circle(void) {
	int x, y, radius, colour, fill;
	float aspect;
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
	if(radius == 0) return;                                         //nothing to draw
	if(radius < 1) error("Invalid argument");

	if(argc > 3 && *argv[4])
	    colour = getinteger(argv[4]);
	else
        colour = DefaultFgColour;

	if(argc > 5 && *argv[6])
	    aspect = getnumber(argv[6]);
	else
	    aspect = 1;

	MMCircle(x, y, radius, fill, colour, aspect);
	lastx = x; lasty = y;
}



void cmd_line(void) {
	int x1, y1, x2, y2, colour, box, fill;
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
	if(argc > 1 && *argv[2])
		colour = getinteger(argv[2]);
	if(argc == 5) {
		box = (strchr(argv[4], 'b') != NULL || strchr(argv[4], 'B') != NULL);
		fill = (strchr(argv[4], 'f') != NULL || strchr(argv[4], 'F') != NULL);
	}
	if(box)
		MMbox(x1, y1, x2, y2, fill, colour);						// draw a box
	else
		MMline(x1, y1, x2, y2, colour);								// or just a line

	lastx = x2; lasty = y2;											// save in case the user wants the last value
}



void cmd_pset(void) {
	int x, y;
//	skipspace(cmdline);
	if(*cmdline != '(') error("Expected opening bracket");
	getcoord(cmdline + 1, &x, &y);
	plot(x, y, DefaultFgColour);
	lastx = x; lasty = y;
}



void cmd_preset(void) {
	int x, y;
//	skipspace(cmdline);
	if(*cmdline != '(') error("Expected opening bracket");
	getcoord(cmdline + 1, &x, &y);
	plot(x, y, 0);
	lastx = x; lasty = y;
}



void cmd_locate(void) {
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
}



// this function is only used by cmd_blit()  -  below
void DoBlit(int *p, int x1, int y1, int x2, int y2, int w, int h) {
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
}



void cmd_blit(void) {
    int x1, y1, x2, y2, w, h;
    char *c = "RGB";

	getargs(&cmdline, 13, ",");
	if(argc != 11 && argc != 13) error("Invalid syntax");
	x1 = getinteger(argv[0]);
	y1 = getinteger(argv[2]);
	x2 = getinteger(argv[4]);
	y2 = getinteger(argv[6]);
	w = getinteger(argv[8]);
	h = getinteger(argv[10]);
	if(argc >= 13) {
    	makeupper(argv[12]);
    	c = argv[12];
    }

	if(w < 1 || h < 1) return;
	if(x1 < 0) { x2 -= x1; w += x1; x1 = 0; }
	if(x2 < 0) { x1 -= x2; w += x2; x2 = 0; }
	if(y1 < 0) { y2 -= y1; h += y1; y1 = 0; }
	if(y2 < 0) { y1 -= y2; h += y2; y2 = 0; }
	if(x1 + w > HRes) w = HRes - x1;
	if(x2 + w > HRes) w = HRes - x2;
	if(y1 + h > VRes) h = VRes - y1;
	if(y2 + h > VRes) h = VRes - y2;
	if(w < 1 || h < 1 || x1 < 0 || x1 + w > HRes || x2 < 0 || x2 + w > HRes || y1 < 0 || y1 + h > VRes || y2 < 0 || y2 + h > VRes) return;

//	WriteCoreTimer(0);

#if defined(COLOUR)
   	int cnt = 0;
    if(VideoBufRed) {
        if(strchr(c, 'R')) DoBlit(VideoBufRed, x1, y1, x2, y2, w, h);
        if(++cnt == ModeC) goto exit_blit;
    }

    if(VideoBufGrn && VideoBufGrn != VideoBufRed) {
        if(strchr(c, 'G')) DoBlit(VideoBufGrn, x1, y1, x2, y2, w, h);
        if(++cnt == ModeC) goto exit_blit;
    }

    if(strchr(c, 'B')) DoBlit(VideoBufBlu, x1, y1, x2, y2, w, h);

exit_blit:;
#else
    DoBlit(VideoBuf, x1, y1, x2, y2, w, h);
#endif

}



struct s_SpriteC *SpriteC;
struct s_SpriteP *SpriteP;
int SpriteNbr;                                                      // number of sprites loaded


// this function is only used by cmd_sprite()  -  below
void SpriteToVideo(unsigned short *sp, unsigned short *sm, int *p_dst, int x_dst, int y_dst) {
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
}




// this function is only used by cmd_sprite()  -  below
void SpriteFromVideo(unsigned short *sp, int *p_src, int x_src, int y_src) {
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
}



#define SPRITE_OFF  -10000



void fun_collision(void) {
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
}



void cmd_sprite(void) {
    char *p;

	if(*cmdline == GetTokenValue("LOAD")) {
        int i, j, k;
    	int fn;
    	char *fp;

    	if(SpriteNbr) error("Sprites already loaded");
    	p = cmdline + 1;                                            // step over the token
    	skipspace(p);
    	fn = FindFreeFileNbr();
    	fp = GetFileName(p, NULL);
    	MMfopen(fp, "r", fn);
		do { *inpbuf = 0; MMgetline(fn, inpbuf); } while(*inpbuf == '\'');	// get the parameters line
		p = inpbuf;
		{															// start a new block
			getargs(&p, 3, ",");									// getargs macro must be the first executable stmt in a block
			if(argc != 3 || getinteger(argv[0]) != 16) error("Invalid sprite file");
			SpriteNbr = getinteger(argv[2]);
			if(SpriteNbr < 1) error("Invalid sprite file");
		}
		SpriteP = getmemory(sizeof(struct s_SpriteP) * SpriteNbr);
		SpriteC = getmemory(sizeof(struct s_SpriteC) * SpriteNbr);
    	for(i = 0; i < SpriteNbr; i++) {
        	SpriteC[i].x = SPRITE_OFF;                              // show as not on display
        	for(j = 0; j < 16; j++) {
            	if(MMfeof(fn)) error("Corrupt sprite file");
        		do { *inpbuf = 0; MMgetline(fn, inpbuf); } while(*inpbuf == '\'');	// get the next data line
        		strcat(inpbuf, "                ");
        		for(k = 0; k < 16; k++) {
            		if(inpbuf[k] < '0' && inpbuf[k] > '7' && inpbuf[k] != ' ') error("Corrupt sprite file");
            		SpriteP[i].m[j] |= (inpbuf[k] != ' ') << k;
            		if(inpbuf[k] != ' ') {
                		#if defined (COLOUR)
                		    SpriteP[i].sr[j] |= (((inpbuf[k] - '0') & 4) >> 2) << k;
                		    SpriteP[i].sg[j] |= (((inpbuf[k] - '0') & 2) >> 1) << k;
                		    SpriteP[i].sb[j] |= (((inpbuf[k] - '0') & 1) >> 0) << k;
                		#else
                		    SpriteP[i].s[j] |= (inpbuf[k] != '0') << k;
                		#endif
            		}
                }
            }
        }
        //dump(SpriteP[0].sr, 32);
        //dump(SpriteP[0].sg, 32);
        //dump(SpriteP[0].m, 32);
    	MMfclose(fn);
        return;
    }


    // all of the sub commands following this depend on the sprite file being loaded into memory
    if(!SpriteNbr) error("Sprites not loaded");


	if((p = checkstring(cmdline, "ON")) != NULL) {
    	int i, x, y, c;
	    getargs(&p, 7, ",");
	    if(!(argc == 5 || argc == 7)) error("Invalid number of parameters");
    	i = getinteger(argv[0]);
	    x = getinteger(argv[2]);
	    y = getinteger(argv[4]);
	    if(argc == 7)
	        c = getinteger(argv[6]);
	    else
	        c = 0;
	    if(i < 1 || i > SpriteNbr) error("Sprite number");
	    i--;
	    if(SpriteC[i].x != SPRITE_OFF) error("Sprite is in use");
	    SpriteC[i].x = x; SpriteC[i].y = y;

        #if defined(COLOUR)
            {
               	int cnt = 0;
                if(VideoBufRed) {
                    if(argc == 7)
                        memset(&SpriteP[i].br, (c & RED) ? 0xff : 0, sizeof(unsigned short) * 16);
                    else
            	        SpriteFromVideo(SpriteP[i].br, VideoBufRed, x, y);
            	    SpriteToVideo(SpriteP[i].sr, SpriteP[i].m, VideoBufRed, x, y);
                    if(++cnt == ModeC) return;
                }

                if(VideoBufGrn && VideoBufGrn != VideoBufRed) {
                    if(argc == 7)
                        memset(&SpriteP[i].bg, (c & GREEN) ? 0xff : 0, sizeof(unsigned short) * 16);
                    else
            	        SpriteFromVideo(SpriteP[i].bg, VideoBufGrn, x, y);
            	    SpriteToVideo(SpriteP[i].sg, SpriteP[i].m, VideoBufGrn, x, y);
                    if(++cnt == ModeC) return;
                }

                if(argc == 7)
                    memset(&SpriteP[i].bb, (c & BLUE) ? 0xff : 0, sizeof(unsigned short) * 16);
                else
                    SpriteFromVideo(SpriteP[i].bb, VideoBufBlu, x, y);
                SpriteToVideo(SpriteP[i].sb, SpriteP[i].m, VideoBufBlu, x, y);
            }
        #else
            if(argc == 7)
                memset(&SpriteP[i].b, c ? 0xff : 0, sizeof(unsigned short) * 16);
            else
                SpriteFromVideo(SpriteP[i].b, VideoBuf, x, y);
            SpriteToVideo(SpriteP[i].s, SpriteP[i].m, VideoBuf, x, y);
        #endif

	    return;
    }


	if((p = checkstring(cmdline, "OFF")) != NULL) {
    	int i, j, k;
    	int sprites[MAX_ARG_COUNT];

    	getargs(&p, (MAX_ARG_COUNT * 2) - 1, ",");				    // getargs macro must be the first executable stmt in a block
    	if(argc == 0) error("Invalid syntax");

        // load the number of each sprite that is to be turned off into the array sprites[]
        if(checkstring(argv[0], "ALL")) {                           // if the argument is ALL load all active sprites into the array
            for(j = i = 0; i < SpriteNbr && j < MAX_ARG_COUNT; i++)
                if(SpriteC[i].x != SPRITE_OFF)
                    sprites[j++] = i;
        } else {                                                    // otherwise we have a list of sprite numbers
        	for(j = i = 0; i < argc; i += 2) {        	            // step through the arguments and put the sprite numbers into the array
        		k = getinteger(argv[i]);
        	    if(k < 1 || k > SpriteNbr) error("Sprite number");
        	    k--;
        	    // if(SpriteC[k].x == SPRITE_OFF) error("Sprite is not on");
        	    if(SpriteC[k].x != SPRITE_OFF) sprites[j++] = k;
    		}
        }

        // now, step through the array turning off each sprite
        for(k = 0; k < j; k++) {
        	i = sprites[k];
            #if defined(COLOUR)
                {
                   	int cnt = 0;
                    if(VideoBufRed) {
                	    SpriteToVideo(SpriteP[i].br, SpriteP[i].m, VideoBufRed, SpriteC[i].x, SpriteC[i].y);
                        if(++cnt == ModeC) goto exit_sprite_off;
                    }

                    if(VideoBufGrn && VideoBufGrn != VideoBufRed) {
                	    SpriteToVideo(SpriteP[i].bg, SpriteP[i].m, VideoBufGrn, SpriteC[i].x, SpriteC[i].y);
                        if(++cnt == ModeC) goto exit_sprite_off;
                    }

                    SpriteToVideo(SpriteP[i].bb, SpriteP[i].m, VideoBufBlu, SpriteC[i].x, SpriteC[i].y);
                }
                exit_sprite_off:
            #else
                SpriteToVideo(SpriteP[i].b, SpriteP[i].m, VideoBuf, SpriteC[i].x, SpriteC[i].y);
            #endif

    	        SpriteC[i].x = SPRITE_OFF;
    	}
    	return;
    }


	if((p = checkstring(cmdline, "MOVE")) != NULL) {
    	int i, x, y, c;
	    getargs(&p, 7, ",");
	    if(!(argc == 5 || argc == 7)) error("Invalid number of parameters");
    	i = getinteger(argv[0]);
	    x = getinteger(argv[2]);
	    y = getinteger(argv[4]);
	    if(argc == 7)
	        c = getinteger(argv[6]);
	    else
	        c = 0;
	    if(i < 1 || i > SpriteNbr) error("Sprite number");
	    i--;
	    if(SpriteC[i].x == SPRITE_OFF) error("Sprite is not on");

        #if defined(COLOUR)
            {
               	int cnt = 0;
                if(VideoBufRed) {
            	    SpriteToVideo(SpriteP[i].br, SpriteP[i].m, VideoBufRed, SpriteC[i].x, SpriteC[i].y);
                    if(argc == 7)
                        memset(&SpriteP[i].br, (c & RED) ? 0xff : 0, sizeof(unsigned short) * 16);
                    else
                	    SpriteFromVideo(SpriteP[i].br, VideoBufRed, x, y);
            	    SpriteToVideo(SpriteP[i].sr, SpriteP[i].m, VideoBufRed, x, y);
                    if(++cnt == ModeC) goto exit_sprite_move;
                }

                if(VideoBufGrn && VideoBufGrn != VideoBufRed) {
            	    SpriteToVideo(SpriteP[i].bg, SpriteP[i].m, VideoBufGrn, SpriteC[i].x, SpriteC[i].y);
                    if(argc == 7)
                        memset(&SpriteP[i].bg, (c & GREEN) ? 0xff : 0, sizeof(unsigned short) * 16);
                    else
            	        SpriteFromVideo(SpriteP[i].bg, VideoBufGrn, x, y);
            	    SpriteToVideo(SpriteP[i].sg, SpriteP[i].m, VideoBufGrn, x, y);
                    if(++cnt == ModeC) goto exit_sprite_move;
                }

                SpriteToVideo(SpriteP[i].bb, SpriteP[i].m, VideoBufBlu, SpriteC[i].x, SpriteC[i].y);
                if(argc == 7)
                    memset(&SpriteP[i].bb, (c & BLUE) ? 0xff : 0, sizeof(unsigned short) * 16);
                else
                    SpriteFromVideo(SpriteP[i].bb, VideoBufBlu, x, y);
                SpriteToVideo(SpriteP[i].sb, SpriteP[i].m, VideoBufBlu, x, y);
            }
        exit_sprite_move:
        #else
            SpriteToVideo(SpriteP[i].b, SpriteP[i].m, VideoBuf, SpriteC[i].x, SpriteC[i].y);
            if(argc == 7)
                memset(&SpriteP[i].b, c ? 0xff : 0, sizeof(unsigned short) * 16);
            else
                SpriteFromVideo(SpriteP[i].b, VideoBuf, x, y);
            SpriteToVideo(SpriteP[i].s, SpriteP[i].m, VideoBuf, x, y);
        #endif

	    SpriteC[i].x = x; SpriteC[i].y = y;
	    return;
    }


	if((p = checkstring(cmdline, "PASTE")) != NULL) {
    	int i, x, y;
	    getargs(&p, 5, ",");
	    if(argc != 5) error("Invalid number of parameters");
    	i = getinteger(argv[0]);
	    x = getinteger(argv[2]);
	    y = getinteger(argv[4]);
	    if(i < 1 || i > SpriteNbr) error("Sprite number");
	    i--;

        #if defined(COLOUR)
            {
               	int cnt = 0;
                if(VideoBufRed) {
            	    SpriteToVideo(SpriteP[i].sr, SpriteP[i].m, VideoBufRed, x, y);
                    if(++cnt == ModeC) return;
                }

                if(VideoBufGrn && VideoBufGrn != VideoBufRed) {
            	    SpriteToVideo(SpriteP[i].sg, SpriteP[i].m, VideoBufGrn, x, y);
                    if(++cnt == ModeC) return;
                }

                SpriteToVideo(SpriteP[i].sb, SpriteP[i].m, VideoBufBlu, x, y);
            }
        #else
            SpriteToVideo(SpriteP[i].s, SpriteP[i].m, VideoBuf, x, y);
        #endif
	    return;
    }


	if((p = checkstring(cmdline, "COPY")) != NULL) {
    	int is, id;
    	char s[2];
    	short unsigned int dummy_mask[16] = {0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff};

    	s[0] = tokenvalue[TKN_TO];
    	s[1] = 0;

        {
    	    getargs(&p, 3, s);                                      // must be the first in a block
    	    if(argc != 3) error("Invalid number of parameters");
        	is = getinteger(argv[0]);
    	    id = getinteger(argv[2]);

    	    if(is < 1 || is > SpriteNbr || id < 1 || id > SpriteNbr || is == id) error("Sprite number");
    	    is--; id--;

            #if defined(COLOUR)
                // copy the sprite
                memcpy(SpriteP[id].sr, SpriteP[is].sr, sizeof(unsigned short) * 16);
                memcpy(SpriteP[id].sb, SpriteP[is].sb, sizeof(unsigned short) * 16);
                memcpy(SpriteP[id].sg, SpriteP[is].sg, sizeof(unsigned short) * 16);
                memcpy(SpriteP[id].m, SpriteP[is].m, sizeof(unsigned short) * 16);

                // if the destination sprite is on, for each colour we then restore the background and copy the
                // new bitmap to the video over the background.  A bit like an abbreviated OFF followed by an ON
                if(SpriteC[id].x != SPRITE_OFF) {
                   	int cnt = 0;
                    if(VideoBufRed) {
//                	    SpriteToVideo(SpriteP[id].br, SpriteP[id].m, VideoBufRed, SpriteC[id].x, SpriteC[id].y);
                	    SpriteToVideo(SpriteP[id].br, dummy_mask, VideoBufRed, SpriteC[id].x, SpriteC[id].y);
                	    SpriteToVideo(SpriteP[id].sr, SpriteP[id].m, VideoBufRed, SpriteC[id].x, SpriteC[id].y);
                        if(++cnt == ModeC) return;
                    }

                    if(VideoBufGrn && VideoBufGrn != VideoBufRed) {
//                	    SpriteToVideo(SpriteP[id].bg, SpriteP[id].m, VideoBufGrn, SpriteC[id].x, SpriteC[id].y);
                	    SpriteToVideo(SpriteP[id].bg, dummy_mask, VideoBufGrn, SpriteC[id].x, SpriteC[id].y);
                	    SpriteToVideo(SpriteP[id].sg, SpriteP[id].m, VideoBufGrn, SpriteC[id].x, SpriteC[id].y);
                        if(++cnt == ModeC) return;
                    }

//                    SpriteToVideo(SpriteP[id].bb, SpriteP[id].m, VideoBufBlu, SpriteC[id].x, SpriteC[id].y);
                    SpriteToVideo(SpriteP[id].bb, dummy_mask, VideoBufBlu, SpriteC[id].x, SpriteC[id].y);
                    SpriteToVideo(SpriteP[id].sb, SpriteP[id].m, VideoBufBlu, SpriteC[id].x, SpriteC[id].y);
                }

            #else  // monochrome
                memcpy(SpriteP[id].s, SpriteP[is].s, sizeof(unsigned short) * 16);      // copy the sprite
                if(SpriteC[id].x != SPRITE_OFF) {                                       // do an OFF followed by an ON
//                    SpriteToVideo(SpriteP[id].b, SpriteP[id].m, VideoBuf, SpriteC[id].x, SpriteC[id].y);
                    SpriteToVideo(SpriteP[id].b, dummy_mask, VideoBuf, SpriteC[id].x, SpriteC[id].y);
                    SpriteToVideo(SpriteP[id].s, SpriteP[id].m, VideoBuf, SpriteC[id].x, SpriteC[id].y);
                }
            #endif

    	    return;
	    }
    }


	if((p = checkstring(cmdline, "UNLOAD")) != NULL) {
    	checkend(p);
    	FreeHeap(SpriteP);
    	FreeHeap(SpriteC);
    	SpriteNbr = 0;
    	return;
    }

    error("Invalid syntax");
}



void cmd_pixel(void){
	int x, y, value;
	getcoord(cmdline, &x, &y);
	cmdline = getclosebracket(cmdline) + 1;
	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) error("Invalid syntax");
	++cmdline;
	if(!*cmdline) error("Invalid syntax");
	value = getinteger(cmdline);
	plot(x, y, value);
	lastx = x; lasty = y;
}



void fun_pixel(void){
	int x, y;
	getargs(&ep, 3, ",");										// this is a macro and must be the first executable stmt in a block
	if(argc != 3) error("Invalid Syntax");
	x = getinteger(argv[0]);
	y = getinteger(argv[2]);
	fret = pixel(x, y);
}



void fun_hres(void) {
	fret = (float)HRes;
}



void fun_vres(void) {
	fret = (float)VRes;
}



void fun_lastx(void) {
	fret = (float)lastx;
}



void fun_lasty(void) {
	fret = (float)lasty;
}


void fun_black(void) {
	fret = (float)0;
}


void fun_blue(void) {
	fret = (float)1;
}


void fun_green(void) {
	fret = (float)2;
}


void fun_cyan(void) {
	fret = (float)3;
}


void fun_red(void) {
	fret = (float)4;
}


void fun_purple(void) {
	fret = (float)5;
}


void fun_yellow(void) {
	fret = (float)6;
}


void fun_white(void) {
	fret = (float)7;
}



// utility routine used to read a number of bytes
// only used by cmd_loadbmp() below
unsigned int xread(int nbr, int fnbr) {
    unsigned int i, t;
	for(t = i = 0; i < nbr; i++) {
    	if(MMfeof(fnbr)) error("Corrupt file");
    	t |= (MMfgetc(fnbr) & 0xff) << (i * 8);
    }
    return t;
}


void cmd_loadbmp(void) {
	char *p;
	int fp, i, j, k, x;
	int hpixels, vpixels, bpp, BytesPerRow, BitsPerByte, PixelMask;
	int cmap[16];
	int xOrigin, yOrigin;

	// get the command line arguments
	getargs(&cmdline, 5, ",");                            // this MUST be the first executable line in the function
    if(argc == 0) error("Invalid number of parameters");
	p = GetFileName(argv[0], NULL);
	xOrigin = yOrigin = 0;
	if(argc >= 3) xOrigin = getinteger(argv[2]);          // get the x origin (optional) argument
	if(argc == 5) yOrigin = getinteger(argv[4]);          // get the y origin (optional) argument

	// open the file
	if(strchr(p, '.') == NULL) strcat(p, ".BMP");
	fp = FindFreeFileNbr();
	MMfopen(p, "r", fp);

	// check the validity of the file
    if(MMfgetc(fp) != 'B' || MMfgetc(fp) != 'M') error("Corrupt file");
    x = xread(4, fp);
    if(xread(4, fp) != 0) error("Corrupt file");
    x = xread(4, fp);
    if(!(x == 62 || x == 118)) error("Corrupt file");

    // from now on assume that it is a BMP and relax error checking
    x = xread(4, fp);                                     // ignore the header size
    hpixels = xread(4, fp);                               // horiz nbr of pixels
    vpixels = xread(4, fp);                               // vert nbr of pixels
    if(xread(2, fp) != 1) error("Invalid format");        // nbr colour planes
    bpp = xread(2, fp);                                   // bits per pixel
    if(!(bpp == 1 || bpp == 4)) error("Number of colours");
    for(i = 0; i < 6; i++) xread(4, fp);                  // ignore these fields

    // finished reading the image header so we can now calculate the basic parameters
    BytesPerRow = (((hpixels * bpp)+31)/32)*4;
    BitsPerByte = 8 / bpp;
    if(bpp == 1) PixelMask = 1;
    if(bpp == 4) PixelMask = 0xf;

    // now load the colour table
    for(i = 0; i < (1 << bpp); i++) {
        cmap[i] = (MMfgetc(fp) != 0);                     // blue
        cmap[i] |= (MMfgetc(fp) != 0) << 1;               // green
        cmap[i] |= (MMfgetc(fp) != 0) << 2;               // red
        MMfgetc(fp);                                      // alpha (which we do not want)
    }

    // finally, draw the bitmap
	for(i = vpixels - 1; i >= 0; i--) {
		for(j = 0; j < BytesPerRow; j++) {
    		x = MMfgetc(fp);
        	for(k = 0; k < BitsPerByte; k++)
        		plot((j * BitsPerByte) + k + xOrigin, i + yOrigin, cmap[(x >> ((8 - bpp) - (k * bpp))) & PixelMask]);
        }
    }
    MMfclose(fp);
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
	int fp, i, j;

	unsigned int   zero = 0,										// a zero integer to make it easier writing zero values
                   #if defined(COLOUR)
                        bpp = 4,									// bits per pixel
                   #else
                        bpp = 1,									// bits per pixel
                   #endif
                   FileHeaderSize = 14, 							// the bmp header size in bytes
                   InfoHeaderSize = 40, 							// the DIB (image) header size in bytes
                   PaletteSize = pow(2,bpp)*4, 						// = 8 = number of bytes in palette
                   BytesPerRow,
                   FileSize,
                   OffBits,											// offset to the image
                   BytesSize; 										// number of bytes in the image

	if(VBuf == 0) error("Video is not enabled");

	// open the file
	p = GetFileName(cmdline, NULL);
	if(strchr(p, '.') == NULL) strcat(p, ".BMP");
	fp = FindFreeFileNbr();
	MMfopen(p, "w", fp);

	// calculate header information
    BytesPerRow=(((HRes * bpp)+31)/32)*4;
    BytesSize=BytesPerRow*VRes;
    FileSize=FileHeaderSize+InfoHeaderSize+PaletteSize+BytesSize;
    OffBits=FileHeaderSize+InfoHeaderSize+PaletteSize;

    // write the bmp file header
    xwrite("BM", 2, fp);											// file Type signature = BM
    xwrite((char *)&FileSize, 4, fp);								// FileSize
    xwrite((char *)&zero, 4, fp);									// two words, both zero for reserved 1 and 2
    xwrite((char *)&OffBits, 4, fp);								// offset to the image

    // write the DIB (image) header
    xwrite((char *)&InfoHeaderSize, 4, fp);							// size of the image header
    xwrite((char *)&HRes, 4, fp);									// width of image in pixels
    xwrite((char *)&VRes, 4, fp);									// height of image in pixels
    MMfputc(1, fp); MMfputc(0, fp); 								// number of planes = 1
    MMfputc(bpp, fp); MMfputc(0, fp); 								// bits of color per pixel
    xwrite((char *)&zero, 4, fp);									// compression type = 0
    xwrite((char *)&zero, 4, fp);									// Image Data Size, set to 0 when no compression
    xwrite((char *)&zero, 4, fp);									// reserved
    xwrite((char *)&zero, 4, fp);									// reserved
	MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);	// number of used colours = 8
    xwrite((char *)&zero, 4, fp);									// reserved 1

    // write the colour table (palette)
    // each colour is 4 bytes as Red, Green, Blue, Alpha (unused)
    // colour 0 = black
    MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
    #if defined(COLOUR)
        // colour 1 = blue
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(255, fp); MMfputc(0, fp);
        // colour 2 = green
        MMfputc(0, fp); MMfputc(255, fp); MMfputc(0, fp); MMfputc(0, fp);
        // colour 3 = cyan
        MMfputc(0, fp); MMfputc(255, fp); MMfputc(255, fp); MMfputc(0, fp);
        // colour 4 = red
        MMfputc(255, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
        // colour 5 = purple
        MMfputc(255, fp); MMfputc(0, fp); MMfputc(255, fp); MMfputc(0, fp);
        // colour 6 = yellow
        MMfputc(255, fp); MMfputc(255, fp); MMfputc(0, fp); MMfputc(0, fp);
        // colour 7 = white
        MMfputc(255, fp); MMfputc(255, fp); MMfputc(255, fp); MMfputc(0, fp);
        // the remaining eight colours are black (we only use 3 bits in each 4 bit nibble)
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
        MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp); MMfputc(0, fp);
    #else
        // colour 7 = white
        MMfputc(255, fp); MMfputc(255, fp); MMfputc(255, fp); MMfputc(0, fp);
    #endif

	// finally!!  write the video image.  note this must be inverted (ie start with the last row of pixels)
	// for colour two pixels are packed into each byte.  Format of each byte is xBGRxBGR where x is a zero bit, R is the bit representing red, etc
	// for monochrome eight pixels per byte
	for(i = VRes - 1; i >= 0; i--)
#if defined(COLOUR)
		for(j = ((ModeC == 4) ? 8:0); j < BytesPerRow + ((ModeC == 4) ? 8:0); j++) {
        	char b;
    		b = 0;
    		if(VideoBufBlu) b |= (((VideoBufBlu[(i * HBuf/32) + (j>>4)] >> (31 - (j%16) * 2)) & 1) << 6) | (((VideoBufBlu[(i * HBuf/32) + (j>>4)] >> (30 - (j%16) * 2)) & 1) << 2);
    		if(VideoBufGrn) b |= (((VideoBufGrn[(i * HBuf/32) + (j>>4)] >> (31 - (j%16) * 2)) & 1) << 5) | (((VideoBufGrn[(i * HBuf/32) + (j>>4)] >> (30 - (j%16) * 2)) & 1) << 1);
    		if(VideoBufRed) b |= (((VideoBufRed[(i * HBuf/32) + (j>>4)] >> (31 - (j%16) * 2)) & 1) << 4) | (((VideoBufRed[(i * HBuf/32) + (j>>4)] >> (30 - (j%16) * 2)) & 1));
    		MMfputc(b, fp);
#else
		for(j = 0; j < BytesPerRow; j++) {
    		MMfputc(*((char *)&VideoBuf[(i * HBuf/32) + (j>>2)] + (3 - (j%4))), fp);
#endif
		}

	MMfclose(fp);
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

