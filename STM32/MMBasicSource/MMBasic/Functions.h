/***********************************************************************************************************************
MMBasic

functions.h

Include file that contains the globals and defines for functions.c in MMBasic.
  
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

void fun_abs(void);
void fun_asc(void);
void fun_atn(void);
void fun_bin(void);
void fun_chr(void);
void fun_cint(void);
void fun_cos(void);
void fun_deg(void);
void fun_exp(void);
void fun_fix(void);
void fun_format(void);
void fun_hex(void);
void fun_inkey(void);
void fun_instr(void);
void fun_int(void);
void fun_lcase(void);
void fun_left(void);
void fun_len(void);
void fun_log(void);
void fun_log(void);
void fun_mid(void);
void fun_oct(void);
void fun_peek(void);
void fun_pi(void);
void fun_pos(void);
void fun_rad(void);
void fun_right(void);
void fun_rnd(void);
void fun_sgn(void);
void fun_sin(void);
void fun_space(void);
void fun_sqr(void);
void fun_str(void);
void fun_string(void);
void fun_tab(void);
void fun_tan(void);
void fun_ucase(void);
void fun_val(void);
void fun_version(void);
void fun_cmdline(void);


#endif




/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)

#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                    P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)
	{ "Abs(",		T_FUN  | T_NBR,			0, fun_abs		},
	{ "Asc(",		T_FUN  | T_NBR,			0, fun_asc		},
	{ "Atn(",		T_FUN  | T_NBR,			0, fun_atn		},
	{ "Bin$(",		T_FUN  | T_STR,			0, fun_bin		},
	{ "Chr$(",		T_FUN  | T_STR,			0, fun_chr,		},
	{ "Cint(",		T_FUN  | T_NBR,			0, fun_cint		},
	{ "Cos(",		T_FUN  | T_NBR,			0, fun_cos		},
	{ "Deg(",		T_FUN  | T_NBR,			0, fun_deg		},
	{ "Exp(",		T_FUN  | T_NBR,			0, fun_exp		},
	{ "Fix(",		T_FUN  | T_NBR,			0, fun_fix		},
	{ "Format$(",	T_FUN  | T_STR,			0, fun_format	},
	{ "Hex$(",		T_FUN  | T_STR,			0, fun_hex		},
	{ "Inkey$",		T_FNA | T_STR,		    0, fun_inkey	},
	{ "Instr(",		T_FUN  | T_NBR,			0, fun_instr	},
	{ "Int(",		T_FUN  | T_NBR,			0, fun_int		},
	{ "LCase$(",	T_FUN  | T_STR,			0, fun_lcase	},
	{ "Left$(",		T_FUN  | T_STR,			0, fun_left		},
	{ "Len(",		T_FUN  | T_NBR,			0, fun_len		},
	{ "Log(",		T_FUN  | T_NBR,			0, fun_log		},
	{ "Mid$(",		T_FUN  | T_STR,			0, fun_mid		},
	{ "MM.CmdLine$",T_FNA  | T_STR,			0, fun_cmdline	},
	{ "MM.Ver",		T_FNA  | T_NBR,			0, fun_version	},
	{ "Oct$(",		T_FUN  | T_STR,			0, fun_oct		},
	{ "Peek(",		T_FUN  | T_NBR,			0, fun_peek		},
	{ "Pi",			T_FNA  | T_NBR,			0, fun_pi		},
	{ "Pos",		T_FNA | T_NBR,		    0, fun_pos		},
	{ "Rad(",		T_FUN  | T_NBR,			0, fun_rad		},
	{ "Right$(",	T_FUN  | T_STR,			0, fun_right	},
	{ "Rnd(",		T_FUN  | T_NBR,			0, fun_rnd		},        // this must come before Rnd - without bracket
	{ "Rnd",		T_FNA  | T_NBR,			0, fun_rnd		},        // this must come after Rnd(
	{ "Sgn(",		T_FUN  | T_NBR,			0, fun_sgn		},
	{ "Sin(",		T_FUN  | T_NBR,			0, fun_sin		},
	{ "Space$(",	T_FUN  | T_STR,			0, fun_space	},
	{ "Spc(",		T_FUN  | T_STR,			0, fun_space	},
	{ "Sqr(",		T_FUN  | T_NBR,			0, fun_sqr		},
	{ "Str$(",		T_FUN  | T_STR,			0, fun_str		},
	{ "String$(",	T_FUN  | T_STR,			0, fun_string	},
	{ "Tab(",		T_FUN | T_STR,		    0, fun_tab,		},
	{ "Tan(",		T_FUN  | T_NBR,			0, fun_tan		},
	{ "UCase$(",	T_FUN  | T_STR,			0, fun_ucase	},
	{ "Val(",		T_FUN  | T_NBR,			0, fun_val		},

#endif
