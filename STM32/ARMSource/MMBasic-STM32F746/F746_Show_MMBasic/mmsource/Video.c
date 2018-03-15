/************************************************************************************************************************
Maximite

Video.c

The video generator is based on an idea and code by Lucio Di Jasio presented in his excellent book
"Programming 32-bit Microcontrollers in C - Exploring the PIC32".
The colour technique and some of the code was developed by Dr Kilian Singer.

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




#include <string.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"



// Graphics is 480x272 pixels.  This gives us 80 chars per line and 22 lines per screen
#define VGA_HRES	 	LCD_MAXX				// 480 pixels Horiz graphics resolution (pixels)
#define VGA_VRES	 	LCD_MAXY				// 272 pixels Vert graphics resolution (pixels)

// global variables used in other parts of the Maximite
int VRes, HRes;									// Global vert and horiz resolution in pixels on the screen

int DefaultFgColour= WHITE;          // default colour for graphic output
int DefaultBgColour = BLUE;
int CurrentFgColour = WHITE;          // current colour for graphic output
int CurrentBgColour = BLUE;
int DefTxtFgColour = WHITE;		       // default colour for text output
int DefTxtBgColour = BLUE;
int CurTxtFgColour = WHITE;		       // current colour for text output
int CurTxtBgColour = BLUE;



const unsigned int FontOption  = 0x4fffffff;     // use to hold the default font setting in flash
const unsigned int VideoOption = 0x3fffffff;	// use to hold the video off/on setting in flash




// configure a SPI channel and its associated DMA feed
void SetupSPI(int SPIchnl, int SPIint, int SPIpixt, void *SPIinput, int DMAchnl, int DMAsize, int *VBuffer) {

}


/**************************************************************************************************
Initialise the video components
 ***************************************************************************************************/
void initVideo( void) {
	VRes = VGA_VRES; HRes = VGA_HRES;
}











/**************************************************************************************************
Turn on or off a single pixel in the graphics buffer
This is the monochrome version
 ***************************************************************************************************/
void plot(int x, int y, int b) {
	if(b == 0)			// turn off the pixel
		GFX_SetPixel(x,y,CurTxtBgColour , LCD_CurrentLayer);
	else if(b == -1)	// invert the pixel
		if (GFX_GetPixel(x,y,LCD_CurrentLayer) == CurTxtBgColour)
			GFX_SetPixel(x,y,CurTxtFgColour , LCD_CurrentLayer);
		else
			GFX_SetPixel(x,y,CurTxtBgColour , LCD_CurrentLayer);
	else				// turn on the pixel
		GFX_SetPixel(x,y,CurTxtFgColour , LCD_CurrentLayer);
}


/**************************************************************************************************
Turn on or off a single pixel in the graphics buffer
This is for colour
 ***************************************************************************************************/
void plotx(int x, int y, int c) {
	GFX_SetPixel(x,y,c , LCD_CurrentLayer);
}







/**************************************************************************************************
Get the value of a single pixel in the graphics buffer
 ***************************************************************************************************/
int pixel(int x, int y) {
	return GFX_GetPixel(x,y,LCD_CurrentLayer);
}




/**************************************************************************************************
scroll the screen
if edit = true then do not scroll the bottom two lines and do not clear the new line (for the editor)
 ***************************************************************************************************/
void ScrollUp(int edit) {
	int split,lines,h,w;
	int src_addr = 0;
	int dst_addr = 0;

	lines=fontHeight * fontScale;
	if(edit)
	  split=((VRes / (fontHeight * fontScale)) - 3)*(fontHeight * fontScale);  // dont copy three status lines at the bottom of the screen
	else
	  split=VRes-lines;

	if(LCD_CurrentLayer==0) {
		src_addr = GFX_FRAME_BUFFER+((HRes*2)*lines);
		dst_addr = GFX_FRAME_BUFFER;
	}
	else if(LCD_CurrentLayer==1) {
		src_addr = GFX_FRAME_BUFFER+BUFFER_OFFSET+((HRes*2)*lines);
		dst_addr = GFX_FRAME_BUFFER+BUFFER_OFFSET;
	}
	else return;

	GFX_CopyBuffer(src_addr,dst_addr,HRes,split,0,0);
	h = VRes - split;
	w = HRes;
	if(!edit) GFX_DrawFullRect(0,split,w,h,CurTxtBgColour,CurTxtBgColour,LCD_CurrentLayer); // clear the new line
}




/**************************************************************************************************
clear the screen
 ***************************************************************************************************/
void MMcls(void) {
	lastx = lasty = MMPosX = MMPosY = 0;
	GFX_Clear(LCD_CurrentLayer,(uint16_t)(DefaultBgColour));
}








/**************************************************************************************************
Draw a line on a the video output
	(x1, y1) - the start coordinate
	(x2, y2) - the end coordinate
	colour - zero for erase, non zero to draw
 ***************************************************************************************************/
#define abs( a)     (((a)> 0) ? (a) : -(a))

void MMline(int x1, int y1, int x2, int y2, int colour) {
	if(colour==-1) {
			if (GFX_GetPixel(x1,y1,LCD_CurrentLayer) == CurTxtBgColour)
				GFX_DrawUniLine(x1, y1, x2, y2, CurTxtFgColour,LCD_CurrentLayer);
			else
				GFX_DrawUniLine(x1, y1, x2, y2, CurTxtBgColour,LCD_CurrentLayer);}
	else
	  GFX_DrawUniLine(x1, y1, x2, y2, colour,LCD_CurrentLayer);
}



extern void HBar(int x1, int y1 , int x2, int y2 , int b)
{	// Draw a Horizontal bar with inverse color check
	int tmpx = 0;
	int cntx = 0;
	if(x2 < x1){
		tmpx = x1;
		x1 = x2;
		x2 = tmpx;
	}
	for(cntx = x1;cntx <= x2;cntx++){
		if(b == 1)			// set the pixel in all case
			GFX_SetPixel(cntx,y1,CurTxtFgColour,LCD_CurrentLayer);
		else if (b == 0)	// delete the pixel in all case
			GFX_SetPixel(cntx,y1,CurTxtBgColour,LCD_CurrentLayer);
		else				// we invert the pixel
			if (GFX_GetPixel(cntx,y1,LCD_CurrentLayer) == CurTxtBgColour)
				GFX_SetPixel(cntx,y1,CurTxtFgColour,LCD_CurrentLayer);
			else
				GFX_SetPixel(cntx,y1,CurTxtBgColour,LCD_CurrentLayer);
	}
}

extern void VBar(int x1, int y1 , int x2, int y2 , int b)
{
	int tmpy = 0;
	int cnty = 0;
	if(y2 < y1){
		tmpy = y1;
		y1 = y2;
		y2 = tmpy;
	}
	for(cnty = y1;cnty <= y2;cnty++){
		if(b == 1)			// set the pixel in all case
			GFX_SetPixel(x1,cnty,CurTxtFgColour,LCD_CurrentLayer);
		else if (b == 0)	// delete the pixel in all case
			GFX_SetPixel(x1,cnty,CurTxtBgColour,LCD_CurrentLayer);
		else				// we invert the pixel
			if (GFX_GetPixel(x1,cnty,LCD_CurrentLayer) == CurTxtBgColour)
				GFX_SetPixel(x1,cnty,CurTxtFgColour,LCD_CurrentLayer);
			else
				GFX_SetPixel(x1,cnty,CurTxtBgColour,LCD_CurrentLayer);
	}
}




/**********************************************************************************************
Draw a box on the video output
     (x1, y1) - the start coordinate
     (x2, y2) - the end coordinate
     fill  - 0 or 1
     colour - 0 or 1
 ***********************************************************************************************/
void MMbox(int x1, int y1, int x2, int y2, int fill, int colour) {
	int w,h;
	if(fill) {
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
		GFX_DrawFullRect(x1, y1, w, h, colour, colour, LCD_CurrentLayer);
	}
	else {
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
		GFX_DrawRect(x1, y1, w, h, colour, LCD_CurrentLayer);
	}
}





/***********************************************************************************************
Draw a circle on the video output
	(x,y) - the center of the circle
	radius - the radius of the circle
	fill - non zero
	colour - to use for both the circle and fill
	aspect - the ration of the x and y axis (a float).  0.83 gives an almost perfect circle
 ***********************************************************************************************/
void MMCircle(int x, int y, int radius, int fill, int colour, float aspect) {
	if(fill) {
		// Here we use aspect parameter for the outcolor parameter on filled circle
		GFX_DrawFullCircle(x,y,radius,colour,(uint16_t)aspect,LCD_CurrentLayer);}
	else {
		GFX_DrawCircle(x,y,radius,colour,LCD_CurrentLayer);
	}
}
