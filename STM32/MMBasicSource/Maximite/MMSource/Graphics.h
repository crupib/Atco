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

extern int lastx;			                                        // the last x and y coordinates that were used
extern int lasty;

struct s_SpriteP {
    #if defined(COLOUR)
        unsigned short sr[16], sg[16], sb[16];                      // sprite pixels for each colour
        unsigned short br[16], bg[16], bb[16];                      // background pixels for each colour
    #else
        unsigned short s[16];                                       // sprite pixels for monochrome
        unsigned short b[16];                                       // background pixels for monochrome
    #endif
    unsigned short m[16];                                           // transparent mask
    };
    
struct s_SpriteC {
    short x, y;                                                      // current position of the sprite.  x == SPRITE_OFF if sprite is OFF
    };
    
    
extern struct s_SpriteC *SpriteC;   
extern struct s_SpriteP *SpriteP;
extern int SpriteNbr;                                                // number of sprites loaded

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

#endif

