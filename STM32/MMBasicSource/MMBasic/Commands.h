/***********************************************************************************************************************
MMBasic

Commands.h

Include file that contains the globals and defines for commands.c in MMBasic.

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

void cmd_auto(void);
void cmd_clear(void);
void cmd_continue(void);
void cmd_delete(void);
void cmd_dim(void);
void cmd_do(void);
void cmd_else(void);
void cmd_end(void);
void cmd_endfun(void);
void cmd_endsub(void);
void cmd_erase(void);
void cmd_error(void);
void cmd_exit(void);
void cmd_exitfor(void);
void cmd_for(void);
void cmd_subfun(void);
void cmd_gosub(void);
void cmd_goto(void);
void cmd_if(void);
void cmd_input(void);
void cmd_let(void);
void cmd_lineinput(void);
void cmd_list(void);
void cmd_load(void);
void cmd_local(void);
void cmd_loop(void);
void cmd_merge(void);
void cmd_chain(void);
void cmd_new(void);
void cmd_next(void);
void cmd_null(void);
void cmd_on(void);
void cmd_option(void);
void cmd_poke(void);
void cmd_print(void);
void cmd_randomize(void);
void cmd_read(void);
void cmd_restore(void);
void cmd_return(void);
void cmd_run(void);
void cmd_save(void);
void cmd_troff(void);
void cmd_tron(void);
void cmd_write(void);

#endif




/**********************************************************************************
 All command tokens tokens (eg, PRINT, FOR, etc) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_COMMAND_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is always T_CMD
// and P is the precedence (which is only used for operators and not commands)

	{ "?",			T_CMD,				0, cmd_print	},
	{ "Auto",		T_CMD,				0, cmd_auto		},
	{ "Clear",		T_CMD,				0, cmd_clear	},
	{ "Continue",	T_CMD,				0, cmd_continue	},
	{ "Data",		T_CMD,				0, cmd_null		},
	{ "Delete",		T_CMD,				0, cmd_delete	},
	{ "Dim",		T_CMD,				0, cmd_dim		},
	{ "Do",			T_CMD,				0, cmd_do		},
	{ "Else",		T_CMD,				0, cmd_else		},
	{ "ElseIf",		T_CMD,				0, cmd_else		},
	{ "End Function",T_CMD,				0, cmd_endfun	},      // this entry must come before END and FUNCTION
	{ "End Sub",	T_CMD,				0, cmd_return	},      // this entry must come before END and SUB
	{ "End",		T_CMD,				0, cmd_end		},
	{ "EndIf",		T_CMD,				0, cmd_null		},
	{ "Erase",		T_CMD,				0, cmd_erase	},
	{ "Error",		T_CMD,				0, cmd_error	},
	{ "Exit For",	T_CMD,				0, cmd_exitfor	},      // this entry must come before EXIT and FOR
	{ "Exit Sub",   T_CMD,				0, cmd_return	},      // this entry must come before EXIT and SUB
	{ "Exit Function",T_CMD,			0, cmd_endfun	},      // this entry must come before EXIT and FUNCTION
	{ "Exit Do",	T_CMD,				0, cmd_exit		},
	{ "Exit",		T_CMD,				0, cmd_exit		},
	{ "For",		T_CMD,				0, cmd_for		},
	{ "Function",	T_CMD,				0, cmd_subfun	},
	{ "GoSub",		T_CMD,				0, cmd_gosub	},
	{ "GoTo",		T_CMD,				0, cmd_goto		},
	{ "If",			T_CMD,				0, cmd_if		},
	{ "Line Input",	T_CMD,				0, cmd_lineinput},      // this entry must come before INPUT
	{ "Input",		T_CMD,				0, cmd_input	},
	{ "Let",		T_CMD,				0, cmd_let		},
	{ "List",		T_CMD,				0, cmd_list		},
	{ "Load",		T_CMD,				0, cmd_load		},
	{ "Local",		T_CMD,				0, cmd_local	},
	{ "Loop",		T_CMD,				0, cmd_loop		},
	{ "Merge",		T_CMD,				0, cmd_merge	},
	{ "Chain",		T_CMD,				0, cmd_chain	},
	{ "New",		T_CMD,				0, cmd_new		},
	{ "Next",		T_CMD,				0, cmd_next		},
	{ "On",			T_CMD,				0, cmd_on		},
	{ "Option",		T_CMD,				0, cmd_option	},
	{ "Poke",		T_CMD,				0, cmd_poke		},
	{ "Print",		T_CMD,				0, cmd_print	},
	{ "Randomize",	T_CMD,				0, cmd_randomize},
	{ "Read",		T_CMD,				0, cmd_read		},
	{ "Rem",		T_CMD,				0, cmd_null,	},
	{ "Restore",	T_CMD,				0, cmd_restore	},
	{ "Return",		T_CMD,				0, cmd_return,	},
	{ "Run",		T_CMD,				0, cmd_run		},
	{ "Save",		T_CMD,				0, cmd_save		},
	{ "Sub",		T_CMD,				0, cmd_subfun   },
	{ "TROFF",		T_CMD,				0, cmd_troff	},
	{ "TRON",		T_CMD,				0, cmd_tron		},
	{ "Wend",		T_CMD,				0, cmd_loop		},
	{ "While",		T_CMD,				0, cmd_do		},
	{ "Write",		T_CMD,				0, cmd_write	},

#endif


/**********************************************************************************
 All other tokens (keywords, functions, operators) should be inserted in this table
**********************************************************************************/
#ifdef INCLUDE_TOKEN_TABLE
// the format is:
//    TEXT      	TYPE                P  FUNCTION TO CALL
// where type is T_NA, T_FUN, T_FNA or T_OPER argumented by the types T_STR and/or T_NBR
// and P is the precedence (which is only used for operators)

	{ "For",		T_NA,				0, op_invalid	},
	{ "Else",		T_NA,				0, op_invalid	},
	{ "GoSub",		T_NA,				0, op_invalid	},
	{ "GoTo",		T_NA,				0, op_invalid	},
	{ "Step",		T_NA,				0, op_invalid	},
	{ "Then",		T_NA,				0, op_invalid	},
	{ "To",			T_NA,				0, op_invalid	},
	{ "Until",		T_NA,				0, op_invalid	},
	{ "While",		T_NA,				0, op_invalid	},

#endif




#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)

extern int forindex;
extern int doindex;
extern char *gosubstack[MAXGOSUB];
extern int gosubindex;
extern int DimUsed;

extern char *GetFileName(char* CmdLinePtr, char *LastFilePtr);
extern void mergefile(char *fname, char *MemPtr);
extern char *llist(char *b, char *p);
extern char LastFile[];

// definitions related to setting video off and on
#define CONFIG_TITLE		0b111
#define CONFIG_LOWER		0b001
#define CONFIG_UPPER		0b010
extern const unsigned int CaseOption;

#endif
