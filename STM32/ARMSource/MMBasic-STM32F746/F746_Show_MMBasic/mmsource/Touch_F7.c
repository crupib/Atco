/***********************************************************************************************************************
MMBasic

Touch_F7.c

Handles all the touch related commands and functions for the STM32F7 version of MMBasic.


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

#include <stdio.h>
#include <math.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"



/********************************************************************************************************************************************
 custom commands and functions
 each function is responsible for decoding a command
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

// List of 32 touch items
int item_active[MAX_NBR_OF_BTNS],item_touched[MAX_NBR_OF_BTNS],item_value[MAX_NBR_OF_BTNS], item_type[MAX_NBR_OF_BTNS],item_colour[MAX_NBR_OF_BTNS],
	item_top[MAX_NBR_OF_BTNS],item_left[MAX_NBR_OF_BTNS],item_bottom[MAX_NBR_OF_BTNS],item_right[MAX_NBR_OF_BTNS],
	item_max[MAX_NBR_OF_BTNS],item_flags[MAX_NBR_OF_BTNS];
char item_text[MAX_NBR_OF_BTNS][15];

int	item_sizex = 80;
int item_sizey = 25;
int touch_active = 0;
int last_item_hit = -1; // last item touched/hit
char *OnTouchGOSUB = NULL;



// ######################################################################################
// graphic primitives: button, slider etc.
// ######################################################################################

void fillbox(int x1, int y1, int x2, int y2, int colour) {
// simply fill a box, faster than MMbox; assumes x2 > x1 and y2 > y1
	if ((x2 < x1) || (y2 < y1)) return;
	GFX_DrawFullRect(x1,y1,(x2-x1),(y2-y1),colour,colour,LCD_CurrentLayer);
}


void greyboxdither(int x1, int y1, int x2, int y2, int colour1) {
// grey out a box by dithering to screen bg colour; assumes x2>x1 and y2>y1
	int x, y;

	if ((x2 < x1) || (y2 < y1)) return;

	for(y = y1; y<=y2; ++y) {
		for(x = x1; x<=x2; ++x){				// Draw pixels to fill the rectangle
			if((x ^ y) & 1)  {
				GFX_SetPixel(x,y,colour1,LCD_CurrentLayer);
			}
		}
	}
}

void fillboxdither(int x1, int y1, int x2, int y2, int colour1, int colour2) {
// simply fill a box with dithered colour; faster than MMbox; assumes x2>x1 and y2>y1
	int x, y;

	if ((x2 < x1) || (y2 < y1)) return;

	for(y = y1; y<=y2; ++y) {
		for(x = x1; x<=x2; ++x){				// Draw pixels to fill the rectangle
			if((x ^ y) & 1)  {
				GFX_SetPixel(x,y,colour1,LCD_CurrentLayer);
			}
			else {
				GFX_SetPixel(x,y,colour2,LCD_CurrentLayer);
			}
		}
	}
}



void drawButton(int index) {
 	int i,x1,x2,y1,y2,colour, pressed;
	char *s;
	int mm_x, mm_y, slen, item_sizex_half, item_sizey_half, w, h;
	int fontNbr_save, fontScale_save;
	int font_bgcoL_save, font_fgcol_save;

	s = item_text[index];
	x1=item_left[index];
	y1=item_top[index];
	x2=item_right[index];
    y2=item_bottom[index];
	colour=item_colour[index];
	pressed=item_value[index];

 	w=(x2-x1);
 	h=(y2-y1);

	// save data
	fontNbr_save = fontNbr;
	fontScale_save =fontScale;
	font_fgcol_save=CurTxtFgColour;
	font_bgcoL_save=CurTxtBgColour;
	mm_x = MMPosX;
	mm_y = MMPosY;

	item_sizex_half = w/2;
	item_sizey_half = h/2;

	if (pressed){
		GFX_DrawFullRect(x1,y1,w,h,TOUCH_AKTIV_COL,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box
		CurTxtFgColour=colour;  // text foreground color
		CurTxtBgColour=TOUCH_AKTIV_COL; // text background color
	}	else {
		GFX_DrawFullRect(x1,y1,w,h,colour,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box
		CurTxtFgColour=TOUCH_AKTIV_COL;  // text foreground color
		CurTxtBgColour=colour; // text background color
	}

	slen = strlen(s);
	SetFont(TOUCH_FONT_NR, TOUCH_FONT_SIZE, 0);
 	MMPosX = x1+item_sizex_half-(5*slen);	                        // center caption
	if (!(slen & 1)) MMPosX -= 3;
	MMPosY = y1+item_sizey_half-8;

    for(i = *s++; i > 0; i--) VideoPutc(*s++);// print string (s is a MMBasic string)

    // restore data
    SetFont(fontNbr_save, fontScale_save, 0);
	CurTxtFgColour=font_fgcol_save;
	CurTxtBgColour=font_bgcoL_save;
	MMPosX = mm_x;
	MMPosY = mm_y;
}

void drawPushButton(int index) {
 	int i,x1,x2,y1,y2,colour, pressed;
	char *s;
	int mm_x, mm_y, slen, item_sizex_half, item_sizey_half, w, h;
	int fontNbr_save, fontScale_save;
	int font_bgcoL_save, font_fgcol_save;

	s = item_text[index];
	x1=item_left[index];
	y1=item_top[index];
	x2=item_right[index];
    y2=item_bottom[index];
	colour=item_colour[index];
	pressed=item_value[index];

 	w=(x2-x1);
 	h=(y2-y1);

	// save data
	fontNbr_save = fontNbr;
	fontScale_save =fontScale;
	font_fgcol_save=CurTxtFgColour;
	font_bgcoL_save=CurTxtBgColour;
	mm_x = MMPosX;
	mm_y = MMPosY;

	item_sizex_half = w/2;
	item_sizey_half = h/2;

	if (pressed){
		GFX_DrawFullRect(x1,y1,w,h,TOUCH_AKTIV_COL,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box
		CurTxtFgColour=colour;  // text foreground color
		CurTxtBgColour=TOUCH_AKTIV_COL; // text background color
	}	else {
		GFX_DrawFullRect(x1,y1,w,h,colour,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box
		CurTxtFgColour=TOUCH_AKTIV_COL;  // text foreground color
		CurTxtBgColour=colour; // text background color
	}

	slen = strlen(s);
	SetFont(TOUCH_FONT_NR, TOUCH_FONT_SIZE, 0);
 	MMPosX = x1+item_sizex_half-(5*slen);	                        // center caption
	if (!(slen & 1)) MMPosX -= 3;
	MMPosY = y1+item_sizey_half-8;

    for(i = *s++; i > 0; i--) VideoPutc(*s++);// print string (s is a MMBasic string)

    // restore data
    SetFont(fontNbr_save, fontScale_save, 0);
	CurTxtFgColour=font_fgcol_save;
	CurTxtBgColour=font_bgcoL_save;
	MMPosX = mm_x;
	MMPosY = mm_y;
}


void drawSwitch(int index) {
 	int x1,x2,y1,y2,colour, pressed;
 	int mm_x, mm_y, item_sizex_half, item_sizey_half, w, h;
	int fontNbr_save, fontScale_save;
	int font_bgcoL_save, font_fgcol_save;

	x1=item_left[index];
	y1=item_top[index];
	x2=item_right[index];
    y2=item_bottom[index];
	colour=item_colour[index];
	pressed=item_value[index];

 	w=(x2-x1);
 	h=(y2-y1);

	// save data
	fontNbr_save = fontNbr;
	fontScale_save =fontScale;
	font_fgcol_save=CurTxtFgColour;
	font_bgcoL_save=CurTxtBgColour;
	mm_x = MMPosX;
	mm_y = MMPosY;

	SetFont(TOUCH_FONT_NR, TOUCH_FONT_SIZE, 0);
	item_sizex_half = w/2;
	item_sizey_half = h/2;

	if (pressed){
		GFX_DrawFullRect(x1,y1,w,h,TOUCH_AKTIV_COL,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box
		MMPosX = x1+item_sizex_half+(item_sizey_half/2)+2;			   // center caption
		MMPosY = y1+item_sizey_half-8;
		CurTxtFgColour=colour;  // text foreground color
		CurTxtBgColour=TOUCH_AKTIV_COL; // text background color
		DisplayString("ON");				// print string

	} else {
		GFX_DrawFullRect(x1,y1,w,h,colour,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box
	  	MMPosX = x1+(item_sizey_half/2)-3;			   // center caption
		MMPosY = y1+item_sizey_half-8;
		CurTxtFgColour=TOUCH_AKTIV_COL;  // text foreground color
		CurTxtBgColour=colour; // text background color
		DisplayString("OFF");				// print string
	}

    // restore data
    SetFont(fontNbr_save, fontScale_save, 0);
	CurTxtFgColour=font_fgcol_save;
	CurTxtBgColour=font_bgcoL_save;
	MMPosX = mm_x;
	MMPosY = mm_y;
}

void drawCheckbox(int index) {
 	int i,x1,y1,y2, colour, pressed;
	char *s;
 	int mm_x, mm_y, item_size, item_size_half, h;
	int fontNbr_save, fontScale_save;
	int font_bgcoL_save, font_fgcol_save;

	s = item_text[index];
	x1=item_left[index];
	y1=item_top[index];
    y2=item_bottom[index];
	colour=item_colour[index];
	pressed=item_value[index];

 	h=(y2-y1);

	// save data
	fontNbr_save = fontNbr;
	fontScale_save =fontScale;
	font_fgcol_save=CurTxtFgColour;
	font_bgcoL_save=CurTxtBgColour;
	mm_x = MMPosX;
	mm_y = MMPosY;

	item_size = h;
	item_size_half = item_size/2;

	GFX_DrawFullRect(x1,y1,h,h,colour,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box

 	if (pressed) { // draw V
 		GFX_DrawUniLine(x1+4, y1+item_size_half, x1+item_size_half, y2-4, TOUCH_AKTIV_COL,LCD_CurrentLayer);
 		GFX_DrawUniLine(x1+item_size_half, y2-4, x1+item_size-4, y1+4, TOUCH_AKTIV_COL,LCD_CurrentLayer);
        // double line for better visability
 		GFX_DrawUniLine(x1+5, y1+item_size_half, x1+item_size_half+1, y2-4, TOUCH_AKTIV_COL,LCD_CurrentLayer);
 		GFX_DrawUniLine(x1+item_size_half+1, y2-4, x1+item_size-3, y1+4, TOUCH_AKTIV_COL,LCD_CurrentLayer);
	}

	CurTxtFgColour=TOUCH_FRAME_COL;  // text foreground color
	CurTxtBgColour=CurrentBgColour; // text background color

	SetFont(TOUCH_FONT_NR, TOUCH_FONT_SIZE, 0);
 	MMPosX = x1+item_size+6;	                                    // align caption
	MMPosY = y1+item_size_half-8;					                // Text height center

	for(i = *s++; i > 0; i--) VideoPutc(*s++);		                // print string (s is a MMBasic string)

    // restore data
    SetFont(fontNbr_save, fontScale_save, 0);
	CurTxtFgColour=font_fgcol_save;
	CurTxtBgColour=font_bgcoL_save;
	MMPosX = mm_x;
	MMPosY = mm_y;
}


void drawRadioButton(int index) {
 	int i,x1,y1,y2,colour, pressed;
	char *s;
 	int mm_x, mm_y, item_size_half, item_size_third, h;
	int fontNbr_save, fontScale_save;
	int font_bgcoL_save, font_fgcol_save;

	s = item_text[index];
	x1=item_left[index];
	y1=item_top[index];
    y2=item_bottom[index];
	colour=item_colour[index];
	pressed=item_value[index];

 	h=(y2-y1);

	// save data
	fontNbr_save = fontNbr;
	fontScale_save =fontScale;
	font_fgcol_save=CurTxtFgColour;
	font_bgcoL_save=CurTxtBgColour;
	mm_x = MMPosX;
	mm_y = MMPosY;

	item_size_half = h/2;
	item_size_third = h/3;

	GFX_DrawFullCircle(x1+item_size_half, y1+item_size_half, item_size_half, colour,TOUCH_FRAME_COL, LCD_CurrentLayer);
	if(pressed) {
		GFX_DrawFullCircle(x1+item_size_half, y1+item_size_half, item_size_third, TOUCH_AKTIV_COL, TOUCH_AKTIV_COL, LCD_CurrentLayer);
	}
	else {
		GFX_DrawFullCircle(x1+item_size_half, y1+item_size_half, item_size_third, colour, TOUCH_FRAME_COL, LCD_CurrentLayer);
	}

	CurTxtFgColour=TOUCH_FRAME_COL;  // text foreground color
	CurTxtBgColour=CurrentBgColour; // text background color

	SetFont(TOUCH_FONT_NR, TOUCH_FONT_SIZE, 0);
 	MMPosX = x1+item_size_half+item_size_half+6;	                // align caption
	MMPosY = y1+item_size_half-8;					                // Text height center

	for(i = *s++; i > 0; i--) VideoPutc(*s++);		                // print string (s is a MMBasic string)

    // restore data
    SetFont(fontNbr_save, fontScale_save, 0);
	CurTxtFgColour=font_fgcol_save;
	CurTxtBgColour=font_bgcoL_save;
	MMPosX = mm_x;
	MMPosY = mm_y;
}


void drawLedButton(int index) {
 	int i,x1,y1,y2,colour, pressed;
	char *s;
 	int mm_x, mm_y, item_size,item_size_half, h;
	int fontNbr_save, fontScale_save;
	int font_bgcoL_save, font_fgcol_save;

	s = item_text[index];
	x1=item_left[index];
	y1=item_top[index];
    y2=item_bottom[index];
	colour=item_colour[index];
	pressed=item_value[index];

	h=(y2-y1);

	// save data
	fontNbr_save = fontNbr;
	fontScale_save =fontScale;
	font_fgcol_save=CurTxtFgColour;
	font_bgcoL_save=CurTxtBgColour;
	mm_x = MMPosX;
	mm_y = MMPosY;

	item_size = h;
	item_size_half = item_size/2;

	CurTxtFgColour=TOUCH_FRAME_COL;  // text foreground color
	CurTxtBgColour=CurrentBgColour; // text background color

	SetFont(TOUCH_FONT_NR, TOUCH_FONT_SIZE, 0);
 	MMPosX = x1+item_size+8;											// align caption
	MMPosY = y1+item_size_half-8;					                // Text height center
	for(i = *s++; i > 0; i--) VideoPutc(*s++);		                // print string (s is a MMBasic string)

	if(pressed) {
		GFX_DrawFullCircle(x1+item_size_half, y1+item_size_half, item_size_half, colour, TOUCH_FRAME_COL, LCD_CurrentLayer);
	}
	else {
		GFX_DrawFullCircle(x1+item_size_half, y1+item_size_half, item_size_half, TOUCH_AKTIV_COL, TOUCH_FRAME_COL, LCD_CurrentLayer);
	}

    // restore data
    SetFont(fontNbr_save, fontScale_save, 0);
	CurTxtFgColour=font_fgcol_save;
	CurTxtBgColour=font_bgcoL_save;
	MMPosX = mm_x;
	MMPosY = mm_y;
}


// draws/updates horizontal slider with fixed dimensions and returns input value within limits
int updateHorSlider(int index, int x_new) {
 	int x1,x2,y1,y2,colour,value,flags,x_max;
 	int x1_insert,x2_insert,y1_insert,y2_insert;
 	int x_btnsize,x_knobhalf;
	int w,h;

	x1=item_left[index];
	y1=item_top[index];
	x2=item_right[index];
    y2=item_bottom[index];
	value=item_value[index];
	x_max=item_max[index];
	flags=item_flags[index];
	colour=item_colour[index];

 	w=(x2-x1);
 	h=(y2-y1);

	x1_insert = x1+1;
	y1_insert = y1+1;
	x2_insert = x2-1;
	y2_insert = y2-1;

	if (flags & 32){
		x_btnsize = 1;					// slider knob X dimension = height Y
		x_knobhalf = 0;					// mid of slider knob
	} else {
		x_btnsize = ((y2 - y1)*3)/4;	// slider knob X dimension = height Y
		x_knobhalf = x_btnsize/2;		// mid of slider knob
	}

	if (x_new >= 0) value = (x_new - x_knobhalf) - x1;
	if (value < 0) value = 0;
	if (value > x_max) value = x_max;

	// check for redraw
	if((x_new>=0) && (item_value[index]==value)) return value;

	GFX_DrawFullRect(x1,y1,w,h,TOUCH_AKTIV_COL,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box

	if (flags & 8)
		fillboxdither(x1_insert, y1_insert, x1_insert+value-1, y2_insert, colour, TOUCH_AKTIV_COL);	// fill left scrolling area
	else
		fillbox(x1_insert, y1_insert, x1_insert+value-1, y2_insert, TOUCH_AKTIV_COL);			// clear left scrolling area
	x1_insert += value;
	if (flags & 16)
		fillboxdither(x1_insert+x_btnsize+1, y1_insert, x2_insert, y2_insert, colour, TOUCH_AKTIV_COL);// fill right scrolling area
	else
		fillbox(x1_insert+x_btnsize+1, y1_insert, x2_insert, y2_insert, TOUCH_AKTIV_COL);		// clear right scrolling area

	if (flags & 32){
		fillbox(x1_insert, y1_insert, x1_insert+1, y2_insert, TOUCH_FRAME_COL);								// just a bold line
	} else {
		x2_insert = x1_insert + x_btnsize;
		w=(x2_insert-x1_insert);
		h=(y2_insert-y1_insert);
		GFX_DrawFullRect(x1_insert,y1_insert,w,h,colour,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box
		x1_insert += 7;
		x2_insert -= 7;
		y1_insert += 5;
		y2_insert -= 5;
		fillboxdither(x1_insert, y1_insert, x2_insert, y2_insert, colour, TOUCH_FRAME_COL);			// knob insert
	}

	return value;
}

// draws/updates vertical slider with fixed dimensions and returns input value within limits
int updateVertSlider(int index, int y_new) {
 	int x1,x2,y1,y2,colour,value,flags,y_max;
 	int x1_insert,x2_insert,y1_insert,y2_insert;
 	int y_btnsize,y_knobhalf;
	int w,h;

	x1=item_left[index];
	y1=item_top[index];
	x2=item_right[index];
    y2=item_bottom[index];
	y_max=item_max[index];
	value=y_max-item_value[index];
	flags=item_flags[index];
	colour=item_colour[index];

 	w=(x2-x1);
 	h=(y2-y1);

	x1_insert = x1+1;
	y1_insert = y1+1;
	x2_insert = x2-1;
	y2_insert = y2-1;

	if (flags & 32){
		y_btnsize = 1;		// slider knob X dimension = height Y
		y_knobhalf = 0;		// mid of slider knob
	} else {
		y_btnsize = ((x2 - x1)*3)/4;	// slider knob X dimension = height Y
		y_knobhalf = y_btnsize/2;		// mid of slider knob
	}

	if (y_new >= 0) value = (y_new - y_knobhalf) - y1;
	if (value < 0) value = 0;
	if (value > y_max) value = y_max;

	// check for redraw
	if((y_new>=0) && (item_value[index]==(y_max-value))) return (y_max-value);

	GFX_DrawFullRect(x1,y1,w,h,TOUCH_AKTIV_COL,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box

	if (flags & 8)
		fillboxdither(x1_insert, y1_insert, x2_insert, y1_insert+value-1, colour, TOUCH_AKTIV_COL);	// fill upper scrolling area
	else
		fillbox(x1_insert, y1_insert, x2_insert, y1_insert+value-1, TOUCH_AKTIV_COL);			// clear upper scrolling area
	y1_insert += value;
	if (flags & 16)
		fillboxdither(x1_insert, y1_insert+y_btnsize+1, x2_insert, y2_insert, colour, TOUCH_AKTIV_COL);// fill lower scrolling area
	else
		fillbox(x1_insert, y1_insert+y_btnsize+1, x2_insert, y2_insert, TOUCH_AKTIV_COL);		// clear lower scrolling area
	y2_insert = y1_insert + y_btnsize;

	if (flags & 32){
		fillbox(x1_insert, y1_insert, x2_insert, y1_insert+1, TOUCH_FRAME_COL);								// just a bold line
	} else {
		w=(x2_insert-x1_insert);
		h=(y2_insert-y1_insert);
		GFX_DrawFullRect(x1_insert,y1_insert,w,h,colour,TOUCH_FRAME_COL,LCD_CurrentLayer); // draw a insert coloured box
		x1_insert += 5;
		x2_insert -= 5;
		y1_insert += 7;
		y2_insert -= 7;
		fillboxdither(x1_insert, y1_insert, x2_insert, y2_insert, colour, TOUCH_FRAME_COL);			// knob insert
	}

	return y_max-value;
}





void drawItemIdx(int index) {
// draw touch item by index from 0 to 31

	if (item_active[index] == TOUCH_ITEM_INVALID) return; // was not inited/active
	if (item_active[index] == TOUCH_ITEM_INACTIVE) {
		// greyed out
		if (item_type[index] != TOUCH_TYPE_NONE) {
			greyboxdither(item_left[index], item_top[index], item_right[index], item_bottom[index], DefaultBgColour);
		}
		return;
	}

	switch(item_type[index]) {
		case TOUCH_TYPE_NONE:
			break;
		case TOUCH_TYPE_BUTTON:
			drawButton(index);
			break;
		case TOUCH_TYPE_SWITCH:
			drawSwitch(index);
			break;
		case TOUCH_TYPE_RADIO:
			drawRadioButton(index);
			break;
		case TOUCH_TYPE_CHECK:
			drawCheckbox(index);
			break;
		case TOUCH_TYPE_PUSH:
			drawPushButton(index);
			break;
		case TOUCH_TYPE_LED:
			drawLedButton(index);
			break;
		case TOUCH_TYPE_HSLIDER:
			item_value[index] = updateHorSlider(index,-1); // -1 => do not check for X update
			break;
		case TOUCH_TYPE_VSLIDER:
			item_value[index] = updateVertSlider(index,-1); // -1 => do not check for Y update
			break;
	}
}

int checkItem(int x, int y, int index) {
// check if Item (idx) is touched - so x and y fall into item's coord scope
	if (item_active[index] < TOUCH_ITEM_ACTIVE) return 0;	// was not active
	if (x < item_left[index]-TOUCH_OVERLAP) return 0;		// not in bounds
	if (x > item_right[index]+TOUCH_OVERLAP) return 0;
	if (y < item_top[index]-TOUCH_OVERLAP) return 0;
	if (y > item_bottom[index]+TOUCH_OVERLAP) return 0;

	return 1;
}


void touch_index_error(void) {
	error("Index out of range (touch item)");
}

void touch_syntax_error(void) {
	error("Invalid syntax (touch)");
}

void touch_missing_error(void) {
	error("Missing value or parameter (touch)");
}


void remove_item(int index) {
// erase removed item to gackground color, make invalid
	if (item_active[index] && (item_type[index] != TOUCH_TYPE_NONE)) {
		fillbox(item_left[index], item_top[index], item_right[index], item_bottom[index], DefaultBgColour);
	}
	item_value[index] = 0;	// default OFF
	item_max[index] = 1;
	item_colour[index] = 0;
	item_touched[index] = 0;
	item_flags[index] = 0;
	item_active[index] = TOUCH_ITEM_INVALID;	// de-validize item
}

void enable_item(int index) {
// enable item
	if (item_active[index]) {	// > inactive (0)
		if (item_active[index] != TOUCH_ITEM_ACTIVE) {
			// redraw
			item_active[index] = TOUCH_ITEM_ACTIVE;
			drawItemIdx(index);
		}
	}
}

void disable_item(int index) {
// grey out item to make inactive state visible
	if (item_active[index]) {	// > inactive (0)
		if (item_active[index] != TOUCH_ITEM_INACTIVE) {
			// redraw
			item_active[index] = TOUCH_ITEM_INACTIVE;	// not active, but stays on screen greyed out
			drawItemIdx(index);
		}
	}
}



void cmd_touchval(void) {
// TouchItem(<itemnbr>) = 1 or 0 - set button/switch nbr on or off
int index, value,redraw=0,i;

	index = getinteger(cmdline);
    if(index < 0 || index > MAX_NBR_OF_BTNS) touch_index_error();

	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) touch_syntax_error();
	++cmdline;
	if(!*cmdline) touch_missing_error();
	value = getinteger(cmdline);
	// check if redraw needed
	if(item_value[index]!=value) redraw=1;

	item_value[index] = value;
	if (item_type[index] < TOUCH_TYPE_VSLIDER) {
		if(value)
		    item_value[index] = 1;	// button/switch ON
		else
		    item_value[index] = 0;
	}
	if(redraw) {
		drawItemIdx(index);
		if(item_type[index] ==TOUCH_TYPE_RADIO) {
			// deactivate all other radio buttons with the same color
			value=item_colour[index];
			 for(i = 0; i <= MAX_NBR_OF_BTNS; i++) {
			    	if((item_active[i] >= TOUCH_ITEM_ACTIVE) && (i!=index)) {
					  if((item_type[i] == TOUCH_TYPE_RADIO) && (item_colour[i] == value)) {
						item_value[i] = 0;	// shut off all other radio btns
						drawItemIdx(i);	// redraw radio btn
					  }
			    	}
			 }
		}
	}
}


void cmd_touch(void) {
   	int i, x, y, c, type, flags;
	char *s, *p;

	if((p = checkstring(cmdline, "CREATE")) != NULL) {
	    getargs(&p, 13, ",");
		if(argc < 5 || !(argc & 1)) error("Invalid syntax");

    	i = getinteger(argv[0]);
		if(i > MAX_NBR_OF_BTNS || i < 0) error("Touch index out of range");

	    x = getinteger(argv[2]);
	    y = getinteger(argv[4]);

		s = "OK";
		c = 0;

	    if(argc > 5) {
		    if(argc < 9) error("Invalid syntax");
			if(*argv[6]) {
				s = getstring(argv[6]);			// the caption string
			}

			c = getinteger(argv[8]);
		}

		type = TOUCH_TYPE_NONE;				// default empty graphic
		remove_item(i);						// reset item vals
		item_active[i] = 0x55AA;				// validize item
		item_left[i] = x;
		item_right[i] = x+item_sizex;
		item_top[i] = y;
		item_bottom[i] = y+item_sizey;
		item_colour[i] = c;
		flags = 0;
		if(argc > 11) {
			if (strchr(argv[12], 't') != NULL || strchr(argv[12], 'T') != NULL) flags |= 8;		// fill Top side of slider knob
			if (strchr(argv[12], 'b') != NULL || strchr(argv[12], 'B') != NULL) flags |= 16;	// fill Bottom side of knob
			if (strchr(argv[12], 'l') != NULL || strchr(argv[12], 'L') != NULL) flags |= 8;		// fill Left side of knob
			if (strchr(argv[12], 'r') != NULL || strchr(argv[12], 'R') != NULL) flags |= 16;	// fill Right side of knob
			if (strchr(argv[12], 'n') != NULL || strchr(argv[12], 'N') != NULL) flags |= 32;	// No slider knob
			if (strchr(argv[12], 'd') != NULL || strchr(argv[12], 'D') != NULL) flags |= 128;	// Disable touch automatic handling
		}
		if(argc >= 11) {
			if (strchr(argv[10], 'b') != NULL || strchr(argv[10], 'B') != NULL) type = TOUCH_TYPE_BUTTON;
			if (strchr(argv[10], 's') != NULL || strchr(argv[10], 'S') != NULL) type = TOUCH_TYPE_SWITCH;
			if (strchr(argv[10], 'r') != NULL || strchr(argv[10], 'R') != NULL) type = TOUCH_TYPE_RADIO;
			if (strchr(argv[10], 'c') != NULL || strchr(argv[10], 'C') != NULL) type = TOUCH_TYPE_CHECK;
			if (strchr(argv[10], 'h') != NULL || strchr(argv[10], 'H') != NULL) {
				type = TOUCH_TYPE_HSLIDER;
				item_max[i] = item_sizex;
				if (flags & 32){
					item_right[i] = x+item_sizex+3;									// adjust size to fit scroll area
				} else {
					item_right[i] = x+item_sizex+(item_sizey*3/4)+2;				// adjust size to fit scroll area
				}
			}
			if (strchr(argv[10], 'v') != NULL || strchr(argv[10], 'V') != NULL) {
				type = TOUCH_TYPE_VSLIDER;
				item_max[i] = item_sizey;
				if (flags & 32){
					item_bottom[i] = y+item_sizey+3;								// adjust size to fit scroll area
				} else {
					item_bottom[i] = y+item_sizey+(item_sizex*3/4)+2;				// adjust size to fit scroll area
				}
			}
			if (strchr(argv[10], 'l') != NULL || strchr(argv[10], 'L') != NULL) type = TOUCH_TYPE_LED;
			if (strchr(argv[10], 'p') != NULL || strchr(argv[10], 'P') != NULL) type = TOUCH_TYPE_PUSH;
		}

		item_flags[i] = flags;
		item_type[i] = type;
		strncpy(item_text[i],s,14);
		drawItemIdx(i);
		touch_active = 1;
		return;
	}
	if((p = checkstring(cmdline, "REMOVE")) != NULL) {
    	int k;
    	getargs(&p, (MAX_ARG_COUNT * 2) - 1, ",");		                        // getargs macro must be the first executable stmt in a block
        if(checkstring(argv[0], "ALL")) {
		    for(i = 0; i <= MAX_NBR_OF_BTNS; i++) remove_item(i);
			return;
		}
       	for(i = 0; i < argc; i += 2) {
       		k = getinteger(argv[i]);
       	    if(k < 0 || k > MAX_NBR_OF_BTNS) touch_index_error();
			remove_item(k);
   		}
		touch_active = 0;
	    for(i = 0; i <= MAX_NBR_OF_BTNS; i++) {
			if (item_active[i] >= TOUCH_ITEM_ACTIVE) touch_active = 1;	// any item still active?
		}
		return;
	}
	if((p = checkstring(cmdline, "ENABLE")) != NULL) {
    	int k;
    	getargs(&p, (MAX_ARG_COUNT * 2) - 1, ",");		// getargs macro must be the first executable stmt in a block
        if(checkstring(argv[0], "ALL")) {
		    for(i = 0; i <= MAX_NBR_OF_BTNS; i++) enable_item(i);
			return;
		}
       	for(i = 0; i < argc; i += 2) {
       		k = getinteger(argv[i]);
       	    if(k < 0 || k > MAX_NBR_OF_BTNS) touch_index_error();
			enable_item(k);
   		}
		return;
	}
	if((p = checkstring(cmdline, "DISABLE")) != NULL) {
    	int k;
    	getargs(&p, (MAX_ARG_COUNT * 2) - 1, ",");		// getargs macro must be the first executable stmt in a block
        if(checkstring(argv[0], "ALL")) {
		    for(i = 0; i <= MAX_NBR_OF_BTNS; i++) disable_item(i);
			return;
		}
       	for(i = 0; i < argc; i += 2) {
       		k = getinteger(argv[i]);
       	    if(k < 0 || k > MAX_NBR_OF_BTNS) touch_index_error();
			disable_item(k);
   		}
		return;
	}
	if((p = checkstring(cmdline, "SIZE")) != NULL) {
		getargs(&p, 3, ",");
		if(argc != 3) touch_syntax_error();
		item_sizex = getinteger(argv[0]);
		item_sizey = getinteger(argv[2]);
		if(item_sizex < 10 || item_sizey < 10) error("Item too small (touch)");
		return;
	}

	touch_missing_error();
}


void fun_touchval(void) {
// new by -cm, simplified, get touch item value (0/1 or slider value), automatic button reset
	int index, value;

	index = getinteger(ep);	                            // only one param
    if(index < 0 || index > MAX_NBR_OF_BTNS) touch_index_error();

	if (item_active[index] < TOUCH_ITEM_ACTIVE) {
		fret = 0;										// return 0 if not initialised
		return;
	}
	value = item_value[index];			                // get value formerly set by ISR : CheckTouch
	fret = (float)value;
}


// return touch position
void fun_touched(void) {
	int index, value;
	char *p;

	// syntax : touched(#x)
	if((p = checkstring(ep, "#X")) != NULL) { // x position
		fret=(float)(-1);
		UB_Touch_Read();
		if(Touch_Data.status==TOUCH_RELEASED) return;
		fret=(float)(Touch_Data.xp);
		return;
	}
	// syntax : touched(#y)
	if((p = checkstring(ep, "#Y")) != NULL) { // y position
		fret=(float)(-1);
		UB_Touch_Read();
		if(Touch_Data.status==TOUCH_RELEASED) return;
		fret=(float)(Touch_Data.yp);
		return;
	}
	// syntax : touched(#s)
	if((p = checkstring(ep, "#S")) != NULL) { // status, 0=released, 1=pressed
		fret=(float)(0);
		UB_Touch_Read();
		if(Touch_Data.status==TOUCH_RELEASED) return;
		fret=(float)(1);
		return;
	}
	// syntax : touched(nr)
	index = getinteger(ep);	                            // only one param
	if(index < 0 || index > MAX_NBR_OF_BTNS) touch_index_error();
	if (item_active[index] < TOUCH_ITEM_ACTIVE) {
		fret = 0;										// return 0 if not active
		return;
	}
	value = item_touched[index];			            // get value formerly set by ISR : CheckTouch
	fret = (float)value;
}

// return multi touch position
void fun_mtouched(void) {
	char *p;
	int temp;

	// syntax : Mtouched(#S)
	if((p = checkstring(ep, "#S")) != NULL) { // read all and get number of contacts
		UB_Touch_Read();
		fret=(float)(MultiTouch_Data.cnt);
		return;
	}
	// syntax : Mtouched(#x,1) to // mtouch(#x,5)
	if((p = checkstring(ep, "#X")) != NULL) { // x position
		fret=(float)(-1);
		skipspace(p);
		if(*p == ',') p++;
		temp = getinteger(p);
		if((temp<1) || (temp>5)) error("Invalid nr");
		if(MultiTouch_Data.cnt<temp) return;
		fret=(float)(MultiTouch_Data.p[temp-1].xp);
		return;
	}
	// syntax : Mtouched(#y,1) to // mtouch(#y,5)
	if((p = checkstring(ep, "#Y")) != NULL) { // y position
		fret=(float)(-1);
		skipspace(p);
		if(*p == ',') p++;
		temp = getinteger(p);
		if((temp<1) || (temp>5)) error("Invalid nr");
		if(MultiTouch_Data.cnt<temp) return;
		fret=(float)(MultiTouch_Data.p[temp-1].yp);
		return;
	}

	error("Invalid Syntax");
}


int checktouch(void) {
	int index, myitemtype, radio_hit, radio_col, old_val;

	// run one touchscreen cycle and check if button/switch hit
	if (!touch_active)	return false;	// leave if not activated
	// read touch
	UB_Touch_Read();
	if(Touch_Data.status==TOUCH_RELEASED) {
		// set all objekts to "untouched"
		for(index = 0; index <= MAX_NBR_OF_BTNS; index++) {
			item_touched[index] = 0; // mark untouched even if disabled
		}
		return false; // leave if not touched
	}

	// now Touch_Data.xp and Touch_Data.yp hold the current touch coordinates

	radio_hit = 0;
	last_item_hit = -1;

	// we now have the XY touch coordinates and can check if it falls in range of one item
    for(index = 0; index <= MAX_NBR_OF_BTNS; index++) {
    	myitemtype = item_type[index];
    	if (checkItem(Touch_Data.xp, Touch_Data.yp, index)) {	// have we found an item?
			last_item_hit = index;
			old_val=item_touched[index];
			item_touched[index] = 1;						// mark touched even if disabled
			if (item_flags[index] & 128) return false;		// was disabled, do nothing else
			switch(myitemtype) {
				case TOUCH_TYPE_RADIO:		            // is it a radio button?
					if((old_val!=0) || (item_value[index]==1)) break; // only at onclick
					radio_hit = 1;						// mark as radio button to erase others
					radio_col = item_colour[index];     // erease only same color buttons
					break;								// other action done in radio btn redraw loop
				case TOUCH_TYPE_BUTTON:
					// check if we need to redraw
					if(item_value[index]!=1) {
					  item_value[index] = 1;	            // is now ON
					  drawItemIdx(index);		            // redraw me
					}
					break;
				case TOUCH_TYPE_LED:					// is it a LED?
				case TOUCH_TYPE_SWITCH:		            // is it a switch?
				case TOUCH_TYPE_PUSH:		            // is it a pushbutton?
				case TOUCH_TYPE_CHECK:					// is it a check box?
					if(old_val!=0) break; // only at onclick
					item_value[index] ^= 1;				// Toggle
					drawItemIdx(index);		            // redraw me
					break;
				case TOUCH_TYPE_HSLIDER:
					item_value[index] = updateHorSlider(index, Touch_Data.xp);	// redraw me with new value
					return false;
					break;
				case TOUCH_TYPE_VSLIDER:
					item_value[index] = updateVertSlider(index, Touch_Data.yp);	// redraw me with new value
					return false;
					break;
				case TOUCH_TYPE_NONE:					// is it an empty box?
					item_value[index] = 1;	            // is now ON
			}

			// set the radio btn touched and cancel all other radio buttons in redraw loop
				if (radio_hit) {
					radio_hit=0;
				    for(index = 0; index <= MAX_NBR_OF_BTNS; index++) {
				    	if(item_active[index] >= TOUCH_ITEM_ACTIVE) {
						  if((item_type[index] == TOUCH_TYPE_RADIO) && (item_colour[index] == radio_col)) {
							if (index == last_item_hit) {
								item_value[index] = 1;	 // only last one is now ON
							}
							else {
								item_value[index] = 0;	// shut off all other radio btns
							}
							drawItemIdx(index);	// redraw radio btn
						  }
				    	}
					}
				}


    	}
    	else {
    		item_touched[index] = 0; // mark untouched even if disabled
    	}
    }
    return true;
}
