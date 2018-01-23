/************************************************************************************************************************
Maximite

Video.h

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

// Global variables provided by Video.c and DrawChar.c
extern int VRes, HRes;												// Global vert and horiz resolution in pixels on the screen
//extern int screenWidth, screenHeight;								// Global vert and horiz resolution in the currently selected font
extern int VBuf, HBuf;												// Global vert and horiz resolution of the video buffer
extern int MMPosX, MMPosY;
extern int MMCharPos;
extern int ListCnt;													// line count used by the LIST and FILES commands
extern int vga;														// true if we are using the internal monochrome vga
extern int fontNbr, fontWidth, fontHeight, fontScale;



    extern int DefaultFgColour, DefaultBgColour;          // default colour for graphic output
    extern int CurrentFgColour, CurrentBgColour;          // current colour for graphic output
    extern int DefTxtFgColour , DefTxtBgColour;           // default colour for text output
    extern int CurTxtFgColour , CurTxtBgColour;           // current colour for text output
    extern void plotx(int x, int y, int c);
	#define BLACK   RGB_COL_BLACK
	#define BLUE    RGB_COL_BLUE
	#define GREEN   RGB_COL_GREEN
	#define CYAN    RGB_COL_CYAN
	#define RED     RGB_COL_RED
	#define PURPLE  RGB_COL_MAGENTA
	#define YELLOW  RGB_COL_YELLOW
	#define WHITE   RGB_COL_WHITE

	#define ORANGE  0xDC4A
	#define BROWN   0x6220
	#define LRED	0xFBAE
	#define DGREY	0x3186
	#define GREY	0x73AE
	#define LGREY	0xBDD7
	#define LGREEN	0xAFEC
	#define LBLUE	0xA53F



#define VCHARS (VRes / (fontHeight * fontScale))                    // number of lines in a screenfull

#define NBRFONTS_IN_FLASH   6   // fonts stored in flash (3 from MMBasic, 3 from UB)
#define FIRST_UB_FONT       3   // number of first font from UB
#define NBRFONTS	       10   // max number of fonts (loadable = NBRFONTS-NBRFONTS_IN_FLASH)

struct s_font {
	void *p;
	char width, height;
	char start, end;
};

extern struct s_font ftbl[NBRFONTS];	

// Facilities provided by Video.c and DrawChar.c
extern void MMCursor(int b);
extern void MMcls(void);
extern void initVideo(void);
//extern void haltVideo(void);
extern void plot(int x, int y, int b); 
extern int pixel(int x, int y);
extern void MMline(int x1, int y1, int x2, int y2, int colour) ;
extern void MMCircle(int x, int y, int radius, int fill, int colour, float aspect) ;
extern void MMbox(int x1, int y1, int x2, int y2, int fill, int colour);
extern void SetMode(int mc, int mp);


extern void HBar(int x1, int y1 , int x2, int y2 , int b);
extern void VBar(int x1, int y1 , int x2, int y2 , int b);


//extern void initDrawChar(void);
extern void VideoPutc(char c);
extern void DisplayString(char *p);
extern void SetFont(int font, int scale, int reverse);
extern void initFont(void);
extern void UnloadFont(int font);
extern void ScrollUp(int res);

// cursor definition
void ShowCursor(int show);
typedef enum {C_OFF = 0, C_STANDARD, C_INSERT } Cursor_e ;
extern Cursor_e Cursor;
extern int AutoLineWrap;		// true if auto line wrap is on
extern int PrintPixelMode;      // global used to track the pixel mode when we are printing

// definitions related to setting NTSC and PAL options
    #define CONFIG_PAL		0b111   // PAL is the default for the Maximite
    #define CONFIG_NTSC		0b001
    #define CONFIG_DISABLED	0b010


extern const unsigned int PalVgaOption;

// definitions related to setting the default font
#define DEFAULT_FONT	1       // the default font is #1
extern const unsigned int FontOption;

// definitions related to setting video off and on
#define CONFIG_ON		0b111
#define CONFIG_OFF		0b010
extern const unsigned int VideoOption;

extern char putPicaso(int len, char *p);

