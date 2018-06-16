/***********************************************************************************************************************
MMBasic

Graphics.h

Include file that contains the definition of the MMBasic commands for handling the video graphics.

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



/**********************************************************************************
 the C language function associated with commands, functions or operators should be
 declared here
**********************************************************************************/


	#include "stm32f7xx.h"
	#include "stm32_ub_lcd_480x272.h"
	#include "stm32_ub_font.h"



#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
// format:
//      void cmd_???(void)
//      void fun_???(void)
//      void op_???(void)

void cmd_cls(void);
void cmd_circle(void);
void cmd_line(void);
void cmd_pset(void);
void cmd_preset(void);
void cmd_locate(void);
void cmd_pixel(void);
void cmd_savebmp(void);
void cmd_loadbmp(void);
void cmd_blit(void);
void cmd_sprite(void);

void cmd_ellipse(void);
void cmd_triangle(void);
void cmd_setlayer(void);
void cmd_showlayer(void);
void cmd_copylayer(void);
void cmd_quad(void);
void cmd_oj3d(void);
void cmd_map(void);
void cmd_jpg(void);
void cmd_polypoint(void);
void cmd_polycenter(void);
void cmd_polymove(void);
void cmd_polygon(void);
void cmd_rotatepoly(void);
void cmd_loadpoly(void);
void cmd_rect(void);
void cmd_roundrect(void);

void fun_pixel(void);
void fun_hres(void);
void fun_vres(void);
void fun_lastx(void);
void fun_lasty(void);
void fun_collision(void);

void fun_black(void);
void fun_blue(void);
void fun_green(void);
void fun_cyan(void);
void fun_red(void);
void fun_purple(void);
void fun_yellow(void);
void fun_white(void);

void fun_orange(void);
void fun_brown(void);
void fun_lred(void);
void fun_dgrey(void);
void fun_grey(void);
void fun_lgrey(void);
void fun_lgreen(void);
void fun_lblue(void);



void fun_getlayer(void);

extern int lastx;			                                        // the last x and y coordinates that were used
extern int lasty;



#endif




/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)
	{ "Cls",		T_CMD,				0, cmd_cls		},
	{ "Circle",		T_CMD,				0, cmd_circle	},
	{ "Line",		T_CMD,				0, cmd_line		},
	{ "PSet",		T_CMD,				0, cmd_pset		},
	{ "PReset",		T_CMD,				0, cmd_preset	},
	{ "Locate",		T_CMD,				0, cmd_locate	},
	{ "Pixel(",		T_CMD | T_FUN,		0, cmd_pixel	},
	{ "SaveBMP",	T_CMD,				0, cmd_savebmp	},
	{ "LoadBMP",	T_CMD,				0, cmd_loadbmp	},
	{ "BLIT",   	T_CMD,				0, cmd_blit	    },
	{ "Sprite",   	T_CMD,				0, cmd_sprite	},
	{ "Ellipse",	T_CMD,				0, cmd_ellipse	},
	{ "Triangle",	T_CMD,				0, cmd_triangle	},
	{ "SetLayer",  	T_CMD,				0, cmd_setlayer	},
	{ "ShowLayer",	T_CMD,				0, cmd_showlayer},
	{ "CopyLayer",	T_CMD,				0, cmd_copylayer},
	{ "Quad",		T_CMD,				0, cmd_quad		},
	{ "Obj3D",		T_CMD,				0, cmd_oj3d		},
	{ "Map",		T_CMD,				0, cmd_map		},
	{ "LoadJPG",	T_CMD,				0, cmd_jpg		},
	{ "PolyPoint",	T_CMD,				0, cmd_polypoint},
	{ "PolyCenter",	T_CMD,				0, cmd_polycenter},
	{ "PolyMove",	T_CMD,				0, cmd_polymove},
	{ "Polygon",	T_CMD,				0, cmd_polygon	},
	{ "RotatePoly",	T_CMD,				0, cmd_rotatepoly},
	{ "LoadPoly",	T_CMD,				0, cmd_loadpoly},
	{ "Rect",		T_CMD,				0, cmd_rect},
	{ "RoundRect",	T_CMD,				0, cmd_roundrect},

#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)
	{ "Pixel(",		T_FUN | T_NBR,		0, fun_pixel	},
	{ "Collision(",	T_FUN | T_NBR,		0, fun_collision},
	{ "MM.HRes",	T_FNA | T_NBR,		0, fun_hres		},
	{ "MM.VRes",	T_FNA | T_NBR,		0, fun_vres		},
	{ "MM.HPos",	T_FNA | T_NBR,		0, fun_lastx	},
	{ "MM.VPos",	T_FNA | T_NBR,		0, fun_lasty	},
	{ "Black",	    T_FNA | T_NBR,		0, fun_black	},
	{ "Blue",	    T_FNA | T_NBR,		0, fun_blue 	},
	{ "Green",	    T_FNA | T_NBR,		0, fun_green 	},
	{ "Cyan",	    T_FNA | T_NBR,		0, fun_cyan 	},
	{ "Red",	    T_FNA | T_NBR,		0, fun_red  	},
	{ "Purple",	    T_FNA | T_NBR,		0, fun_purple	},
	{ "Yellow",	    T_FNA | T_NBR,		0, fun_yellow	},
	{ "White",	    T_FNA | T_NBR,		0, fun_white	},
	{ "Orange",	    T_FNA | T_NBR,		0, fun_orange	},
	{ "Brown",	    T_FNA | T_NBR,		0, fun_brown	},
	{ "Lred",	    T_FNA | T_NBR,		0, fun_lred		},
	{ "Dgrey",	    T_FNA | T_NBR,		0, fun_dgrey	},
	{ "Grey",	    T_FNA | T_NBR,		0, fun_grey		},
	{ "Lgrey",	    T_FNA | T_NBR,		0, fun_lgrey	},
	{ "Lgreen",	    T_FNA | T_NBR,		0, fun_lgreen	},
	{ "Lblue",	    T_FNA | T_NBR,		0, fun_lblue	},
	{ "GetLayer",   T_FNA | T_NBR,		0, fun_getlayer	},

#endif

