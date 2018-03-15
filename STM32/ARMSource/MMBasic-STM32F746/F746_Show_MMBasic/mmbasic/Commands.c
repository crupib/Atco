/***********************************************************************************************************************
MMBasic

commands.c

Handles all the commands in MMBasic

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

void flist(int, int, int);
void clearprog(void);
void execute_one_command(char *p);



// stack to keep track of nested FOR/NEXT loops
struct s_forstack {
	char *forptr;							// pointer to the FOR command in program memory
	char *nextptr;							// pointer to the NEXT command in program memory
	char *nextid;
	float *var;								// value of the for variable
	float tovalue;
	float stepvalue;
} forstack[MAXFORLOOPS] ;

int forindex;



// stack to keep track of nested DO/LOOP loops
struct s_dostack {
	char *evalptr;							// pointer to the expression to be evaluated
	char *loopptr;							// pointer to the loop statement
	char *loopid;
	char *doptr;							// pointer to the do statement
} dostack[MAXDOLOOPS] ;

int doindex;                                // counts the number of nested DO/LOOP loops



// stack to keep track of GOSUBs
char *gosubstack[MAXGOSUB];
int gosubindex;

int DimUsed = false;						// used to catch OPTION BASE after DIM has been used

char LastFile[256];							// used to keep track of the last file RUN, LOADed or SAVed

const unsigned int CaseOption = 0xffffffff;	// used to store the case of the listed output




/********************************************************************************************************************************************
 commands
 each function is responsible for decoding a command
 all function names are in the form cmd_xxxx() so, if you want to search for the function responsible for the GOSUB command look for cmd_gosub

 There are 4 items of information that are setup before the command is run.
 All these are globals.

 int cmdtoken		This is the token number of the command (some commands can handle multiple
				statement types and this helps them differentiate)

 char *cmdline	This is the command line terminated with a zero char and trimmed of leading
				spaces.  It may exist anywhere in memory (or even ROM).

 char *nextstmt	This is a pointer to the next statement to be executed.  The only thing a
				command can do with it is save it or change it to some other location.

 char *CurrentLinePtr  This is read only and is set to NULL if the command is in immediate mode.

 The only actions a command can do to change the program flow is to change nextstmt or
 execute longjmp(mark, 1) if it wants to abort the program.

 ********************************************************************************************************************************************/



void cmd_null(void) {
	// do nothing (this is just a placeholder for commands that have no action)
}

// the PRINT command
void cmd_print(void) {
	char *s, *p;
	float f;
	int i, t, fnbr;
	int printspace;													// this is used to make sure that only one space is printed
	int concatstr;													// this is used to keep track if we are concatenating strings
	int docrlf;														// this is used to suppress the cr/lf if needed

	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ";,");				// this is a macro and must be the first executable stmt

//	s = 123456; *s = 56;											// for testing the exception handler

	concatstr = printspace = false;
	docrlf = true;

	if(argc > 0 && *argv[0] == '#') {								// check if the first arg is a file number
		argv[0]++;
		fnbr = getinteger(argv[0]);									// get the number
		i = 1;
		if(argc >= 2 && *argv[1] == ',') i = 2;						// and set the next argument to be looked at
	}
	else {
		fnbr = 0;													// no file number so default to the standard output
		i = 0;
	}

	for(; i < argc; i++) {											// step through the arguments
		if(*argv[i] == ',') {
			MMfputc('\t', fnbr);									// print a tab for a comma
			docrlf = true;
		}
		else if(*argv[i] == ';') {
			docrlf = false;											// other than suppress cr/lf do nothing for a semicolon
		}
		else {														// we have a normal expression
			p = argv[i];
			while(*p) {
				t = T_NOTYPE;
				p = evaluate(p, &f, &s, &t, true);					// get the value and type of the argument
				if(t == T_NBR) {
					sprintf(inpbuf, "% g", (double)f);
					MMfputs(CtoM(inpbuf), fnbr);					// if numeric, convert to a MMBasic string and output
				}
				else if(t == T_STR) {
					MMfputs(s, fnbr);								// print if a string (s is a MMBasic string)
				}
			}
			docrlf = true;
		}
	}

	if(docrlf) MMfputs("\2\r\n", fnbr);								// print the terminating cr/lf unless it has been suppressed





  AutoLineWrap = true;
  PrintPixelMode = 0;
  CurTxtFgColour = DefTxtFgColour;                          // reset the text colours
  CurTxtBgColour = DefTxtBgColour;

}



void cmd_write(void) {
	char *s;
	float f;
	int i, t, fnbr;
	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ",");				// this is a macro and must be the first executable stmt

	if(argc > 0 && *argv[0] == '#') {
		argv[0]++;
		fnbr = getinteger(argv[0]);
		i = 1;
		if(argc >= 2 && *argv[1] == ',') i = 2;
	}
	else {
		fnbr = 0;
		i = 0;
	}

	for(; i < argc; i++) {
		if(*argv[i] == ',') {
			MMfputc(',', fnbr);
		}
		else {
			t = T_NOTYPE;
			evaluate(argv[i], &f, &s, &t, false);
			if(t == T_NBR) {
				sprintf(inpbuf, "%g", (double)f);
				MMfputs(CtoM(inpbuf), fnbr);						// convert to a MMBasic string and output
			}
			else if(t == T_STR) {
				MMfputc('"', fnbr);
				MMfputs(s, fnbr);									// output (s is a MMBasic string)
				MMfputc('"', fnbr);
			}
		}
	}


	MMfputs("\2\r\n", fnbr);								        // print the terminating cr/lf
}



// the LET command
// because the LET is implied (ie, line does not have a recognisable command)
// it ends up as the place where mistyped commands are discovered.  This is why
// the error message is "Unknown command"
void cmd_let(void) {
	int t, size;
	float f;
	char *s;
	char *p1, *p2;

	p1 = cmdline;

	// search through the line looking for the equals sign
	while(*p1 && tokenfunction(*p1) != op_equal)
			p1++;
	if(!*p1) error("Unknown command");

	// check that we have a straight forward variable
	p2 = skipvar(cmdline, false);
	skipspace(p2);
	if(p1 != p2) error("Invalid syntax");

	// create the variable and get the length if it is a string
	p2 = findvar(cmdline, V_FIND);
    size = vartbl[VarIndex].size;

	// step over the equals sign, evaluate the rest of the command and save in the variable
	p1++;
	if(vartype(cmdline) == T_STR) {
		t = T_STR;
		p1 = evaluate(p1, &f, &s, &t, false);
		if(*s > size) error("String too long");
		Mstrcpy(p2, s);
	}
	else {
		t = T_NBR;
		p1 = evaluate(p1, &f, &s, &t, false);
		(*(float *)p2) = f;
	}
	checkend(p1);
}



void cmd_list(void) {
	int fromnbr = 1;
	int tonbr = NOLINENBR;
	char ss[2];
	ss[0] = GetTokenValue("-");										// this will be used to split up the argument line
	ss[1] = 0;														// I blame Bill Gates for a poor choice of syntax
	{																// start a new block
		getargs(&cmdline, 4, ss);									// getargs macro must be the first executable stmt in a block

		if(argc == 1) fromnbr = tonbr = getinteger(argv[0]);		// this is a single line number eg: LIST 340
		if(argc == 2) {
			if(*argv[0] == *ss)
				tonbr = getinteger(argv[1]);						// this is LIST -340
			else if(*argv[1] == *ss)
				fromnbr = getinteger(argv[0]);						// this is LIST 230-
			else
				error("Invalid syntax");
		}
		if(argc == 3) {												// this is LIST 230-340
			fromnbr = getinteger(argv[0]);
			tonbr = getinteger(argv[2]);
		}
		flist(0, fromnbr, tonbr);
	}
}


// get the file name for the RUN, LOAD, SAVE, KILL, COPY, DRIVE, FILES, FONT LOAD, LOADBMP, SAVEBMP, SPRITE LOAD and EDIT commands
// this function allows the user to omit the quote marks around a string constant when in immediate mode
// the first argument is a pointer to the file name (normally on the command line of the command)
// the second argument is a pointer to the LastFile buffer.  If this pointer is NULL the LastFile buffer feature will not be used
// This returns a temporary string to the filename
char *GetFileName(char* CmdLinePtr, char *LastFilePtr) {
    char *tp, *t;

	if(CurrentLinePtr) return getCstring(CmdLinePtr);               // if running a program get the filename as an expression

    // if we reach here we are in immediate mode
    if(*CmdLinePtr == 0 && LastFilePtr != NULL) return LastFilePtr; // if the command line is empty and we have a pointer to the last file, return that

   	if(strchr(CmdLinePtr, '"') == NULL && strchr(CmdLinePtr, '$') == NULL) {// quotes or a $ symbol indicate that it is an expression
        tp = GetTempStringSpace();                                  // this will last for the life of the command
    	strcpy(tp, CmdLinePtr);	                                    // save the string
    	t = strchr(tp, ' '); if(t) *t = 0;                          // trim any trailing spaces
    	for(t = tp; *t; t++) if(*t <= ' ' || *t > 'z') error("Filename must be quoted");
    	return tp;
    }
    else
		return getCstring(CmdLinePtr);	                            // treat the command line as a string expression and get its value
}



void cmd_run(void) {
	char *p = NULL;
	int fn;

	//skipspace(cmdline);
	// first see if this is RUN without any arguments (ie, run the program in memory)
	if(*cmdline == 0 || *cmdline == '\'') {
		p  = PMemory;
	}
	// check if there is a number following and run the specified line number
	else if(isdigit(*cmdline)) {
		p = findline(getinteger(cmdline), true);
	}
	// otherwise just assume that a file name has been provided
	else {
    	strcpy(LastFile, GetFileName(cmdline, LastFile));	        // get the file name and save into LastFile
		if(strchr(LastFile, '.') == NULL) strcat(LastFile, ".BAS");
		fn = FindFreeFileNbr();
		MMfopen(LastFile, "r", fn);				                    // first check if the file exists
		if(MMerrno) return;
		ClearProgram();							                    // and clear the program space so that the merge becomes a load
		mergefile(LastFile, NULL);					                // load the program
		p = PMemory;
		ProgramChanged = false;
	}
	ClearRuntime();
	PrepareProgram();
	nextstmt = p;

	#ifdef PROFILE
		StartProfiling();
	#endif
}



void cmd_continue(void) {
	if(CurrentLinePtr) error("Invalid in a program");
	if(ContinuePoint == NULL) error("Cannot continue, program changed");
	checkend(cmdline);
	nextstmt = ContinuePoint;
}



void cmd_save(void) {
    int fn;
	strcpy(LastFile, GetFileName(cmdline, LastFile));	            // get the file name and save into LastFile
	if(*LastFile == 0) error("Invalid Filename");
	if(strchr(LastFile, '.') == NULL) strcat(LastFile, ".BAS");
	fn = FindFreeFileNbr();
	MMfopen(LastFile, "w", fn);
	flist(fn, 1, MAXLINENBR);
	ProgramChanged = false;
}


void cmd_load(void) {
    if(CurrentLinePtr) error("Invalid in a program");
    strcpy(LastFile, GetFileName(cmdline, NULL));	                // get the file name and save into LastFile
    if(*LastFile == 0) error("Cannot find file");
	if(strchr(LastFile, '.') == NULL) strcat(LastFile, ".BAS");
	ClearProgram();								                    // clear the program space
	mergefile(LastFile, NULL);						                // load
	ProgramChanged = false;
	longjmp(mark, 1);							                    // jump back to the input prompt
}


void cmd_merge(void) {
    if(CurrentLinePtr) error("Invalid in a program");
	ClearRuntime();
	mergefile(GetFileName(cmdline, NULL), NULL);				    // get the file name and convert to a C style string
	longjmp(mark, 1);							                    // jump back to the input prompt
}



void cmd_chain(void) {
    char *d, *s;
    int i;

    if(*cmdline == 0) error("Invalid Filename");
	strcpy(LastFile, GetFileName(cmdline, LastFile));	            // get the file name and save into LastFile
	if(strchr(LastFile, '.') == NULL) strcat(LastFile, ".BAS");

#if defined(MMFAMILY)
    // copy the variable table to as high in memory as possible without overwriting the part of the heap in use
    d = HeapBottom();
    s = (char *)(vartbl + varcnt);
    while(s >= (char *)vartbl) *d-- = *s--;
#endif

	// clear the program space so that the merge becomes a load
	m_alloc(M_PROG, 256);                                           // init the variables for program memory
    PMemory[0] = PMemory[1] = PMemory[3] = PMemory[4] = 0;          // zero the start
    PSize = 1;
    autoOn = 0; autoNext = 10; autoIncr = 10;                       // use by the AUTO command
    StartEditPoint = NULL; StartEditChar = 0;
    ClearStack();

    // load the new file
	mergefile(LastFile, NULL);					                    // load the program

#if defined(MMFAMILY)
	if(PMemory + PSize > d) {                                       // if we have overwritten the saved variable table
    	ClearProgram();
    	error("Not enough memory");
    }
	m_alloc(M_VAR, varcnt * sizeof(struct s_vartbl));               // allocate memory for the variable table

	// copy the variable table back down to its new location
    s = (char *)vartbl; d++;
    while(s <= (char *)(vartbl + varcnt)) *s++ = *d++;

    // make sure that all interrupts are disabled
	for(i = 0; i < NBRPINS + 1; i++) inttbl[i].intp = NULL;			// disable all pin interrupts including the tick interrupt
	com1_interrupt = com2_interrupt = NULL;                         // disable the COM interrupts
    #if defined(DUINOMITE)
    	com3_interrupt = com4_interrupt = NULL;
    #endif
	InterruptReturn = NULL;
	InterruptUsed = false;
#endif

    // run the new program
    NextData = 0;                                                   // reset the DATA pointer to the start of the program
	d = PMemory;
	PrepareProgram();
	findlabel(NULL);                                                // clear the label cache
	nextstmt = d;
	ProgramChanged = false;
}


void cmd_new(void) {
	checkend(cmdline);
	ClearProgram();
	*LastFile = 0;
	longjmp(mark, 1);							                    // jump back to the input prompt
}


void cmd_clear(void) {
	checkend(cmdline);
	ClearVars(0);
}


void cmd_goto(void) {
	if(isnamestart(*cmdline))
		nextstmt = findlabel(cmdline);								// must be a label
	else
		nextstmt = findline(getinteger(cmdline), true);				// try for a line number
}



void cmd_if(void) {
	int r, i, testgoto, testelseif;
	char ss[3];														// this will be used to split up the argument line
	char *p, *tp, endiftoken, elseiftoken, elsetoken;
	char *rp = NULL;

	ss[0] = tokenvalue[TKN_THEN];
	ss[1] = tokenvalue[TKN_ELSE];
	ss[2] = 0;

	testgoto = false;
	testelseif = false;

retest_an_if:
	{																// start a new block
		getargs(&cmdline, 20, ss);									// getargs macro must be the first executable stmt in a block

		if(testelseif && argc > 2) error("Unexpected text");

		// if there is no THEN token retry the test with a GOTO.  If that fails flag an error
		if(argc < 2 || *argv[1] != ss[0]) {
			if(testgoto) error("IF without THEN");
			ss[0] = tokenvalue[TKN_GOTO];
			testgoto = true;
			goto retest_an_if;
		}


		// allow for IF statements embedded inside this IF
		if(argc >= 3 && *argv[2] == GetCommandValue("IF") + C_BASETOKEN) argc = 3;// this is IF xx=yy THEN IF ... so we want to evaluate only the first 3
		if(argc >= 5 && *argv[4] == GetCommandValue("IF") + C_BASETOKEN) argc = 5;// this is IF xx=yy THEN cmd ELSE IF ... so we want to evaluate only the first 5

		if(argc == 4 || (argc == 5 && *argv[3] != ss[1])) error("Invalid syntax");

		r = (getnumber(argv[0]) != 0);								// evaluate the expression controlling the if statement

		if(r) {
			// the test returned TRUE
			// first check if it is a multiline IF (ie, only 2 args)
			if(argc == 2) {
				// if multiline do nothing, control will fall through to the next line (which is what we want to execute next)
				;
			}
			else {
				// This is a standard single line IF statement
				// Because the test was TRUE we are just interested in the THEN cmd stage.
				if(*argv[1] == tokenvalue[TKN_GOTO]) {
					cmdline = argv[2];
					cmd_goto();
					return;
				} else if(isdigit(*argv[2])) {
					nextstmt = findline(getinteger(argv[2]), true);
				} else {
					if(argc == 5) {
						// this is a full IF THEN ELSE and the statement we want to execute is between the THEN & ELSE
						// this is handled by a special routine
						execute_one_command(argv[2]);
					} else {
						// easy - there is no ELSE clause so just point the next statement pointer to the byte after the THEN token
						for(p = cmdline; *p && *p != ss[0]; p++);	// search for the token
						nextstmt = p + 1;							// and point to the byte after
					}
				}
			}
		} else {
			// the test returned FALSE so we are just interested in the ELSE stage (if present)
			// first check if it is a multiline IF (ie, only 2 args)
			if(argc == 2) {
				// search for the next ELSE, or ENDIF and pass control to the following line
				// if an ELSEIF is found re execute this function to evaluate the condition following the ELSEIF
				endiftoken = GetCommandValue("ENDIF") + C_BASETOKEN;
				elseiftoken = GetCommandValue("ELSEIF") + C_BASETOKEN;
				elsetoken = GetCommandValue("ELSE") + C_BASETOKEN;
				i = 1; p = nextstmt;
				while(1) {
					while(*p) p++;									// look for the zero marking the start of an element
					if(p[1] == 0) error("Multiline IF without matching ENDIF");
					if(p[1] == T_LINENBR) {
						r = (p[2] << 8) | p[3];						// get the line number for error reporting in the ELSEIF stmt
						rp = ++p;									// and a pointer to the line also for error reporting
						p += 2;
					}

					p++;
					skipspace(p);

					if(p[0] == T_LABEL) {							// got a label
						p += p[1] + 2;								// skip over the label
						skipspace(p);								// and any following spaces
					}

					if(*p == cmdtoken + C_BASETOKEN) {
						// found a nested IF command, we now need to determine if it is a single or multiline IF
						// search for a THEN, then check if only white space follows.  If so, it is multiline.
						tp = p + 1;
						while(*tp && *tp != ss[0]) tp++;
						if(*tp) tp++;								// step over the THEN
						skipspace(tp);
						if(*tp == 0 || *tp == '\'')					// yes, only whitespace follows
							i++;									// count it as a nested IF
						else										// no, it is a single line IF
							skipelement(p);							// skip to the end so that we avoid an ELSE
						continue;
					}

					if(*p == elsetoken && i == 1) {
						// found an ELSE at the same level as this IF.  Step over it and continue with the statement after it
						skipelement(p);
						nextstmt = p;
						break;
					}

					if(*p == elseiftoken && i == 1) {
						// we have found an ELSEIF statement at the same level as our IF statement
						// setup the environment to make this function evaluate the test following ELSEIF and jump back
						// to the start of the function.  This is not very clean (it uses the dreaded goto for a start) but it works
						p++;                                        // step over the token
						skipspace(p);
						CurrentLinePtr = rp;
						if(*p == 0) error("Invalid Syntax");        // there must be a test after the elseif
						cmdline = p;
						skipelement(p);
						nextstmt = p;
						testgoto = false;
						testelseif = true;
						goto retest_an_if;
					}

					if(*p == endiftoken) i--;						// found an ENDIF so decrement our nested counter
					if(i == 0) {
						// found our matching ENDIF stmt.  Step over it and continue with the statement after it
						skipelement(p);
						nextstmt = p;
						break;
					}
				}
			}
			else {
				// this must be a single line IF statement
				// check if there is an ELSE on the same line
				if(argc == 5) {
					// there is an ELSE command
					if(isdigit(*argv[4]))
						// and it is just a number, so get it and find the line
						nextstmt = findline(getinteger(argv[4]), true);
					else {
						// there is a statement after the ELSE clause  so just point to it (the byte after the ELSE token)
						for(p = cmdline; *p && *p != ss[1]; p++);	// search for the token
						nextstmt = p + 1;							// and point to the byte after
					}
				} else {
					// no ELSE on a single line IF statement, so just continue with the next statement
					skipline(cmdline);
					nextstmt = cmdline;
				}
			}
		}
	}
}



void cmd_else(void) {
	int i;
	char *p, *tp, endiftoken, iftoken, thentoken;

	// search for the next ENDIF and pass control to the following line
	iftoken = GetCommandValue("IF") + C_BASETOKEN;
	endiftoken = GetCommandValue("ENDIF") + C_BASETOKEN;
	thentoken = tokenvalue[TKN_THEN];
	i = 1; p = nextstmt;

	if(cmdtoken ==  GetCommandValue("ELSE")) checkend(cmdline);

	while(1) {
		while(*p) p++;												// look for the zero marking the start of an element
		if(p[1] == 0) error("Multiline IF without matching ENDIF");
		if(p[1] == T_LINENBR) {
			p += 3;
		}
		p++;
		skipspace(p);

		if(p[0] == T_LABEL) {
			p += p[1] + 2;											// skip over the label
			skipspace(p);											// and any following spaces
		}

		if(*p == iftoken) { //cmdtoken + C_BASETOKEN) {
			// found a nested IF command, we now need to determine if it is a single or multiline IF
			// search for a THEN, then check if only white space follows.  If so, it is multiline.
			tp = p + 1;
			while(*tp && *tp != thentoken) tp++;
			if(*tp) tp++;											// step over the THEN
			skipspace(tp);
			if(*tp == 0 || *tp == '\'')								// yes, only whitespace follows
				i++;												// count it as a nested IF
		}
		if(*p == endiftoken) i--;									// found an ENDIF so decrement our nested counter
		if(i == 0) break;											// found our matching ENDIF stmt
	}
	// found a matching ENDIF.  Step over it and continue with the statement after it
	skipelement(p);
	nextstmt = p;
}



void cmd_end(void) {
    if(checkstring(cmdline, "SUB")) error("Multiple spaces between END SUB");

	checkend(cmdline);
	longjmp(mark, 1);												// jump back to the input prompt
}



void cmd_input(void) {
	char s[STRINGSIZE];
	char *p, *sp, *tp;
	int i, fnbr;
	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ",;");				// this is a macro and must be the first executable stmt

	// is the first argument a file number specifier?  If so, get it
	if(argc >= 3 && *argv[0] == '#') {
		argv[0]++;
		fnbr = getinteger(argv[0]);
		i = 2;
	}
	else {
		fnbr = 0;
		// is the first argument a prompt?
		// if so, print it followed by an optional question mark
		if(argc >= 3 && *argv[0] == '"' && (*argv[1] == ',' || *argv[1] == ';')) {
			*(argv[0] + strlen(argv[0]) - 1) = 0;
			argv[0]++;
			MMPrintString(argv[0]);
			if(*argv[1] == ';') MMPrintString("? ");
			i = 2;
		}
		else {
			MMPrintString("? ");									// no prompt?  then just print the question mark
			i = 0;
		}
	}

	if(argc - i < 1) error("Invalid syntax");						// no variable to input to

	*inpbuf = 0;													// start with an empty buffer
	if(fnbr == 0)
		EditInputLine();											// if keyboard get the line with editing
	else
		MMgetline(fnbr, inpbuf);									// otherwise use the old way of getting the input line
	p = inpbuf;

	// step through the variables listed for the input statement
	// and find the next item on the line and assign it to the variable
	for(; i < argc; i++) {
		sp = s;														// sp is a temp pointer into s[]
		if(*argv[i] == ',' || *argv[i] == ';') continue;
		skipspace(p);
		if(*p != 0) {
			if(*p == '"') {											// if it is a quoted string
				p++;												// step over the quote
				while(*p && *p != '"')  *sp++ = *p++;				// and copy everything upto the next quote
				while(*p && *p != ',') p++;							// then find the next comma
			} else {												// otherwise it is a normal string of characters
				while(*p && *p != ',') *sp++ = *p++;				// copy up to the comma
				while(sp > s && sp[-1] == ' ') sp--;				// and trim trailing whitespace
			}
		}
		*sp = 0;													// terminate the string
		tp = findvar(argv[i], V_FIND);								// get the variable and save its new value
		if(vartype(argv[i]) == T_STR) {
    		if(strlen(s) > vartbl[VarIndex].size) error("String too long");
			strcpy(tp, s);
			CtoM(tp);												// convert to a MMBasic string
		}
		else
			*((float *)tp) = (float)atof(s);
		if(*p == ',') p++;
	}
}




void cmd_tron(void) {
	checkend(cmdline);
	TraceOn = true;
}



void cmd_troff(void) {
	checkend(cmdline);
	TraceOn = false;
}



// FOR command
void cmd_for(void) {
	int i, t, vlen;
	char ss[4];														// this will be used to split up the argument line
	char *p, *tp, *xp;
	float *vptr;
	char *vname;
	char fortoken, nexttoken;

	fortoken = GetCommandValue("FOR") + C_BASETOKEN;
	nexttoken = GetCommandValue("NEXT") + C_BASETOKEN;

	ss[0] = tokenvalue[TKN_EQUAL];
	ss[1] = tokenvalue[TKN_TO];
	ss[2] = tokenvalue[TKN_STEP];
	ss[3] = 0;

	{																// start a new block
		getargs(&cmdline, 7, ss);									// getargs macro must be the first executable stmt in a block
		if(argc < 5 || argc == 6 || *argv[1] != ss[0] || *argv[3] != ss[1]) error("FOR with misplaced = or TO");
		if(argc == 6 || (argc == 7 && *argv[5] != ss[2])) error("Invalid syntax");

		// get the variable name and trim any spaces
		vname = argv[0];
		if(*vname && *vname == ' ') vname++;
		while(*vname && vname[strlen(vname) - 1] == ' ') vname[strlen(vname) - 1] = 0;
		vlen = strlen(vname);

		vptr = findvar(argv[0], V_FIND);							// create the variable
		if(vartype(argv[0]) != T_NBR) error("Numeric variable required");	// sanity check

		// check if the FOR variable is already in the stack and remove it if it is
		// this is necessary as the program can jump out of the loop without hitting
		// the NEXT statement and this will eventually result in a stack overflow
		for(i = 0; i < forindex ;i++) {
			if(forstack[i].var == vptr) {
				while(i < forindex - 1) {
					forstack[i].forptr = forstack[i+1].forptr;
					forstack[i].nextptr = forstack[i+1].nextptr;
					forstack[i].nextptr = forstack[i+1].nextid;
					forstack[i].var = forstack[i+1].var;
					forstack[i].tovalue = forstack[i+1].tovalue;
					forstack[i].stepvalue = forstack[i+1].stepvalue;
					i++;
				}
				forindex--;
				break;
			}
		}

		if(forindex == MAXFORLOOPS) error("Too many nested FOR loops");

		forstack[forindex].var = vptr;								// save the variable index
		*vptr = getnumber(argv[2]);									// get the starting value and save
		forstack[forindex].tovalue = getnumber(argv[4]);			// get the to value and save
		if(argc == 7)
			forstack[forindex].stepvalue = getnumber(argv[6]);		// get the step value
		else
			forstack[forindex].stepvalue = 1;						// default is +1

		forstack[forindex].forptr = nextstmt + 1;					// return to here when looping

		// now find the matching NEXT command
		t = 1; tp = p = nextstmt;
	//	inexit = false;
		while(1) {
			while(*p) p++;											// search for the zero byte marking the start of a new element
			if(p[1] == 0) error("FOR without matching NEXT");
			tp = p + 1;
			if(p[1] == T_LINENBR) {									// skip over a line number
				p += 3;
			}
			p++;
			skipspace(p);
			if(p[0] == T_LABEL) {
				p += p[1] + 2;										// skip over the label
				skipspace(p);										// and any following spaces
			}
			if(*p == fortoken) t++;									// count the FOR
			if(*p == nexttoken) {									// is it NEXT
				xp = p + 1;											// point to after the NEXT token
				while(*xp && strncasecmp(xp, vname, vlen)) xp++;	// step through looking for our variable
				if(*xp && !isnamechar(xp[vlen]))					// is it terminated correctly?
					t = 0;											// yes, found the matching NEXT
				else
					t--;											// no luck, just decrement our stack counter
			}
			if(t == 0) {											// found the matching NEXT
				forstack[forindex].nextptr = tp;					// pointer to the start of the NEXT command
				forstack[forindex].nextid = p + 1;					// pointer to after the NEXT token
				break;
			}
		}

		while(*forstack[forindex].nextid == ' ') forstack[forindex].nextid++;	// step over any spaces at the destination

		if((forstack[forindex].stepvalue >= 0 && *vptr > forstack[forindex].tovalue)
						|| (forstack[forindex].stepvalue < 0 && *vptr < forstack[forindex].tovalue)) {
			// loop is invalid at the start, so go to the end of the NEXT command
			tp += 3;					// step over the line number
			skipelement(tp);            // find the command after the NEXT command
			nextstmt = tp;              // this is where we will continue
		} else
			forindex++;					// save the loop data and continue on with the command after the FOR statement
	}
}



void cmd_next(void) {
	int i, vindex;
	float *vtbl[MAXFORLOOPS];
	int vcnt;
	getargs(&cmdline, MAXFORLOOPS * 2, ",");						// getargs macro must be the first executable stmt in a block

	vindex = 0;														// keep lint happy

	for(vcnt = i = 0; i < argc; i++) {
		if(i & 0x01) {
			if(*argv[i] != ',') error("Illegal character in variable");
		}
		else
			vtbl[vcnt++] = findvar(argv[i], V_FIND | V_NOFIND_ERR); // find the variable and error if not found
	}

	loopback:
	// first search the for stack for a loop with the same variable specified on the NEXT's line
	if(vcnt) {
		for(i = forindex - 1; i >= 0; i--)
			for(vindex = vcnt - 1; vindex >= 0 ; vindex--)
				if(forstack[i].var == vtbl[vindex])
					goto breakout;
	} else {
		// if no variables specified search the for stack looking for an entry with the same program position as
		// this NEXT statement. This cheats by using the cmdline as an identifier and may not work inside an IF THEN ELSE
		for(i = 0; i < forindex; i++)
			if(forstack[i].nextid == cmdline)
				goto breakout;
	}

	error("Cannot find a matching FOR");

	breakout:

	// found a match
	// apply the STEP value to the variable and test against the TO value
	*forstack[i].var += forstack[i].stepvalue;
	if((forstack[i].stepvalue >= 0 && *forstack[i].var > forstack[i].tovalue) || (forstack[i].stepvalue < 0 && *forstack[i].var < forstack[i].tovalue)) {
		// the loop has terminated
		// remove the entry in the table, then skip forward to the next element and continue on from there
		while(i < forindex - 1) {
			forstack[i].forptr = forstack[i+1].forptr;
			forstack[i].nextptr = forstack[i+1].nextptr;
			forstack[i].nextid = forstack[i+1].nextid;
			forstack[i].var = forstack[i+1].var;
			forstack[i].tovalue = forstack[i+1].tovalue;
			forstack[i].stepvalue = forstack[i+1].stepvalue;
			i++;
		}
		forindex--;
		if(vcnt > 0) {
			// remove that entry from our FOR stack
			for(; vindex < vcnt - 1; vindex++) vtbl[vindex] = vtbl[vindex + 1];
			vcnt--;
			if(vcnt > 0)
				goto loopback;
			else
				return;
		}

	} else {
		// we have not reached the terminal value yet, so go back and loop again
		nextstmt = forstack[i].forptr;
	}
}




void cmd_do(void) {
	int i, whileloop;
	char *p, *tp, *evalp;
	char looptoken, whiletoken;

	whiletoken = GetCommandValue("WHILE") + C_BASETOKEN;
	whileloop = (cmdtoken + C_BASETOKEN == whiletoken);
	if(whileloop)
		looptoken = GetCommandValue("WEND") + C_BASETOKEN;
	else {
		looptoken = GetCommandValue("LOOP") + C_BASETOKEN;
		whiletoken = tokenvalue[TKN_WHILE];
	}

	if(whileloop)
		// if it is a WHILE WEND loop we can just point to the command line
		evalp = cmdline;
	else {
		// if it is a DO loop find the WHILE token and (if found) get a pointer to its expression
		while(*cmdline && *cmdline != whiletoken) cmdline++;
		if(*cmdline == whiletoken) {
			evalp = ++cmdline;
		}
		else
			evalp = NULL;
	}

	// check if this loop is already in the stack and remove it if it is
	// this is necessary as the program can jump out of the loop without hitting
	// the LOOP or WEND stmt and this will eventually result in a stack overflow
	for(i = 0; i < doindex ;i++) {
		if(dostack[i].doptr == nextstmt) {
			while(i < doindex - 1) {
				dostack[i].evalptr = dostack[i+1].evalptr;
				dostack[i].loopptr = dostack[i+1].loopptr;
				dostack[i].loopid = dostack[i+1].loopid;
				dostack[i].doptr = dostack[i+1].doptr;
				i++;
			}
			doindex--;
			break;
		}
	}

	// add our pointers to the top of the stack
	if(doindex == MAXDOLOOPS) error("Too many nested DO or WHILE loops");
	dostack[doindex].evalptr = evalp;
	dostack[doindex].doptr = nextstmt;

	// now find the matching LOOP command
	i = 1; tp = p = nextstmt;
	while(1) {
		while(*p) p++;												// look for the zero marking the start of an element
		if(p[1] == 0) {
			if(whileloop)
				error("WHILE without matching WEND");
			else
				error("DO without matching LOOP");
		}
		tp = p + 1;													// point to the start of the line
		if(p[1] == T_LINENBR) {
			p += 3;
		}
		p++;
		skipspace(p);
		if(p[0] == T_LABEL) {
			p += p[1] + 2;											// skip over the label
			skipspace(p);											// and any following spaces
		}
		if(*p == cmdtoken + C_BASETOKEN) i++;						// entered a nested DO or WHILE loop
		if(*p == looptoken) i--;									// exited a nested loop
		if(i == 0) {												// found our matching LOOP or WEND stmt
			dostack[doindex].loopptr = tp;
			dostack[doindex].loopid = p + 1;
			break;
		}
	}

	while(*dostack[doindex].loopid == ' ') dostack[doindex].loopid++;	// step over any spaces at the destination

	if(!whileloop  && dostack[doindex].evalptr != NULL) {
		// if this is a DO WHILE ... LOOP statement
		// search the LOOP statement for a WHILE or UNTIL token (p is pointing to the matching LOOP statement)
		p++;
		while(*p && *p < 0x80) p++;
		if(*p == tokenvalue[TKN_WHILE]) error("Matching LOOP also has a WHILE test");
		if(*p == tokenvalue[TKN_UNTIL]) error("Matching LOOP also has an UNTIL test");
	}

	// do the evaluation (if there is something to evaluate) and if false go straight to the LOOP or WEND statement
	if(dostack[doindex].evalptr != NULL && getnumber(dostack[doindex].evalptr) == 0)
		nextstmt = dostack[doindex].loopptr;

	doindex++;
}




void cmd_loop(void) {
	int tst = 0;                                                    // initialise tst to stop the compiler from complaining
	int i;

	// search the do table looking for an entry with the same program position as this LOOP statement
	for(i = 0; i < doindex ;i++) {
		if(dostack[i].loopid == cmdline) {
			// found a match
			// first check if the DO statement had a WHILE component
			// if not find the WHILE statement here and evaluate it
			if(dostack[i].evalptr == NULL) {						// if it was a DO without a WHILE
				if(*cmdline >= 0x80) {								// if there is something
					if(*cmdline == tokenvalue[TKN_WHILE])
						tst = (getnumber(++cmdline) != 0);			// evaluate the expression
					else if(*cmdline == tokenvalue[TKN_UNTIL])
						tst = (getnumber(++cmdline) == 0);			// evaluate the expression
					else
						error("Invalid syntax");
				}
				else {
					tst = 1;										// and loop forever
					checkend(cmdline);								// make sure that there is nothing else
				}
			}
			else {													// if was DO WHILE
				tst = (getnumber(dostack[i].evalptr) != 0);			// evaluate its expression
				checkend(cmdline);									// make sure that there is nothing else
			}

			// test the expression value and reset the program pointer if we are still looping
			// otherwise remove this entry from the do stack
			if(tst)
				nextstmt = dostack[i].doptr;						// loop again
			else {
				// the loop has terminated
				// remove the entry in the table, then just let the default nextstmt run and continue on from there
				while(i < doindex - 1) {
					dostack[i].evalptr = dostack[i+1].evalptr;
					dostack[i].loopptr = dostack[i+1].loopptr;
					dostack[i].loopid = dostack[i+1].loopid;
					dostack[i].doptr = dostack[i+1].doptr;
					i++;
				}
				doindex--;
				// just let the default nextstmt run
			}
			return;
		}
	}
	error("LOOP without a matching DO");
}



void cmd_exitfor(void) {
	if(forindex == 0) error("No FOR loop is in effect");
	nextstmt = forstack[--forindex].nextptr;
	checkend(cmdline);
	nextstmt += 3;
	skipelement(nextstmt);
}



void cmd_exit(void) {
	if(doindex == 0) error("No DO loop is in effect");
	nextstmt = dostack[--doindex].loopptr;
	checkend(cmdline);
	nextstmt += 3;
	skipelement(nextstmt);
}



void cmd_error(void) {
	if(*cmdline) {
    	CurrentLinePtr = NULL;                                      // suppress printing the line that caused the issue
		error(getCstring(cmdline));
	}
	else
		error("");
}



void cmd_randomize(void) {
	int i;
	i = getinteger(cmdline);
	if(i < 0) error("Number out of bounds");
	srand(i);
}



// this is the Sub or Fun command
// it simply skips over text until it finds the next return
void cmd_subfun(void) {
	char *p, returntoken;

	if(cmdtoken == GetCommandValue("SUB"))
	    returntoken = GetCommandValue("END SUB") + C_BASETOKEN;
	else
	    returntoken = GetCommandValue("END FUNCTION") + C_BASETOKEN;

	p = nextstmt;
	while(1) {
		while(*p) p++;												// look for the zero marking the start of an element
		if(p[1] == 0) error("Cannot find END SUB or FUN");          // end of the program
		if(p[1] == T_LINENBR) p += 3;                               // skip over the line number
		p++;
		skipspace(p);
		if(p[0] == T_LABEL) {
			p += p[1] + 2;											// skip over the label
			skipspace(p);											// and any following spaces
		}
		if(*p == returntoken) {                                     // found the next return
    		skipelement(p);
    		nextstmt = p;                                           // point to the next command
    		break;
        }
    }
}




void cmd_gosub(void) {
	if(gosubindex >= MAXGOSUB) error("Too many nested GOSUB");
	gosubstack[gosubindex++] = nextstmt;
	LocalIndex++;
	if(isnamestart(*cmdline))
		nextstmt = findlabel(cmdline);								// must be a label
	else
		nextstmt = findline(getinteger(cmdline), true);				// try for a line number
}



void cmd_return(void) {
 	checkend(cmdline);
	if(gosubindex == 0 || gosubstack[gosubindex - 1] == NULL) error("Nothing to return to");
	ClearVars(LocalIndex--);                                        // delete any local variables
	nextstmt = gosubstack[--gosubindex];                            // return to the caller
}




void cmd_endfun(void) {
 	checkend(cmdline);
	if(gosubindex == 0 || gosubstack[gosubindex - 1] != NULL) error("No function call to return to");
	nextstmt = "\0\0\0";                                            // now terminate this run of ExecuteProgram()
}



void cmd_read(void) {
	int i, len, dnbr, linenbr, nbrvalues;
	char *p, datatoken, *lineptr = NULL, *x;
	char *vtbl[MAX_ARG_COUNT];
	int vtype[MAX_ARG_COUNT];
	int vsize[MAX_ARG_COUNT];
	int vcnt, vidx;
	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ",");				// getargs macro must be the first executable stmt in a block

	if(argc == 0) error("No variables to read");

	// step through the arguments and save the pointer and type
	for(vcnt = i = 0; i < argc; i++) {
		if(i & 0x01) {
			if(*argv[i] != ',') error("Expected a comma");
		}
		else {
			vtbl[vcnt] = findvar(argv[i], V_FIND);
			vtype[vcnt] = vartype(argv[i]);
			vsize[vcnt] = vartbl[VarIndex].size;
			vcnt++;
		}
	}

	// setup for a search through the whole memory
	linenbr = vidx = dnbr = 0;
	datatoken = GetCommandValue("DATA") + C_BASETOKEN;
	p =PMemory;

	// search looking for a DATA statement.  We keep returning to this point until all the data is found
search_again:
	while(1) {
		while(*p) p++;												// look for the zero marking the start of an element
		if(p[1] == 0) error("No DATA to read");				        // end of the program and we still need more data
		if(p[1] == T_LINENBR) {
    		p++;
			linenbr = (p[1] << 8) | p[2];							// get the line number incase of error reading the DATA stmt
			lineptr = p;
			p += 2;
		}
		p++;
		skipspace(p);
		if(p[0] == T_LABEL) {										// if there is a label here
			p += p[1] + 2;											// skip over the label
			skipspace(p);											// and any following spaces
		}
		if(*p == datatoken) break;									// found a DATA statement
	}
	p++;															// step over the token
	skipspace(p);
	if(!*p || *p == '\'') { CurrentLinePtr = lineptr; error("No DATA to read"); }

        {
    	// we have a DATA statement, first split the line into arguments
		// new block, the getargs macro must be the first executable stmt in a block
		getargs(&p, (MAX_ARG_COUNT * 2) - 1, ",");
    	if((argc & 1) == 0) { CurrentLinePtr = lineptr; error("Invalid syntax"); }
		// check how much data is here and if not look for another DATA stmt
		nbrvalues = (argc / 2) + 1;									// number of values in the DATA statement
		if(dnbr + nbrvalues <= NextData) {
			dnbr += nbrvalues;
			goto search_again;
		}
		i = (NextData - dnbr) * 2;
		// now step through the variables on the READ line and get their new values from the argument list
		// we set the line number to the number of the DATA stmt so that any errors are reported correctly
		while(vidx < vcnt) {
			x = CurrentLinePtr;
			CurrentLinePtr = lineptr;
			if(vtype[vidx] == T_STR) {
    			char *p1, *p2;
				if(*argv[i] == '"') {								// if quoted string
    				for(len = 0, p1 = vtbl[vidx], p2 = argv[i] + 1; *p2 && *p2 != '"'; len++, p1++, p2++) {
    				   *p1 = *p2;                                   // copy up to the quote
    				}
				} else {                                            // else if not quoted
    				for(len = 0, p1 = vtbl[vidx], p2 = argv[i]; *p2 && *p2 != '\'' ; len++, p1++, p2++) {
    				    if(*p2 < 0x20 || *p2 >= 0x7f) error("Invalid character");
    				    *p1 = *p2;                                  // copy up to the comma
    				}
                }
        		if(len > vsize[vidx]) error("String too long");
    			*p1 = 0;                                            // terminate the string
				CtoM(vtbl[vidx]);									// convert to a MMBasic string
			}
			else
				*((float *)vtbl[vidx]) = getnumber(argv[i]);		// much easier if numeric variable

			NextData++;
			dnbr++;
			vidx++;
			i++;
			if(i < argc && *argv[i] != ',') error("Expected a comma");
			CurrentLinePtr = x;
			i++;
			if(vidx < vcnt && i >= argc) goto search_again;			// need more data?  go back and look for more
		}
	}
}





void cmd_restore(void) {
	checkend(cmdline);
	NextData = 0;
}



void cmd_lineinput(void) {
	char *vp;
	int i, fnbr;
	getargs(&cmdline, 3, ",;");										// this is a macro and must be the first executable stmt
	if(argc > 0 && (vp = checkstring(argv[0], "INPUT"))) {			// check if this was redirected from the LINE command
		skipspace(vp);
		argv[0] = vp;												// and, if so remove the word LINE from the first arg
	}
	if(argc == 0 || argc == 2) error("Invalid syntax");

	i = 0;
	fnbr = 0;
	if(argc == 3) {
		// is the first argument a file number specifier?  If so, get it
		if(*argv[0] == '#' && *argv[1] == ',') {
			argv[0]++;
			fnbr = getinteger(argv[0]);
		}
		else {
			// is the first argument a prompt?  if so, print it otherwise there are too many arguments
			if(*argv[1] != ',' && *argv[1] != ';') error("Invalid syntax");
			MMfputs(getstring(argv[0]), 0);
		}
	i = 2;
	}

	if(argc - i != 1) error("Invalid syntax");
	vp = findvar(argv[i], V_FIND);
	if(vartype(argv[i]) != T_STR) error("String variable required");
	*inpbuf = 0;													// start with an empty buffer
	if(fnbr == 0)
		EditInputLine();											// if keyboard get the line with editing
	else
		MMgetline(fnbr, inpbuf);									// otherwise use the old way of getting the input line
	if(strlen(inpbuf) > vartbl[VarIndex].size) error("String too long");
	strcpy(vp, inpbuf);
	CtoM(vp);														// convert to a MMBasic string
}



void cmd_delete(void) {
	char ss[2];
	char *p1 = NULL, *p2 = NULL;
	if(CurrentLinePtr) error("Invalid in a program");
	ss[0] = GetTokenValue("-");										// this will be used to split up the argument line
	ss[1] = 0;														// blame Microsoft for a poor choice of syntax
	{																// start a new block
		getargs(&cmdline, 4, ss);									// getargs macro must be the first executable stmt in a block

		if(argc == 1) {
			p2 = p1 = findline(getinteger(argv[0]), true);			// this is a single line number eg: DELETE 340
			p2 += 3;
			skipline(p2);
		}
		else if(argc == 2) {
			if(*argv[0] == *ss) {
				p1 = PMemory + 1;
				p2 = findline(getinteger(argv[1]), true);			// this is DELETE -340
				p2 += 3;
				skipline(p2);
			}
			else if(*argv[1] == *ss) {
				p1 = findline(getinteger(argv[0]), true);			// this is DELETE 230-
				p2 = PMemory + PSize;
			}
			else
				error("Invalid syntax");
		}
		else if(argc == 3) {										// this is DELETE 230-340
			p1 = findline(getinteger(argv[0]), true);
			p2 = findline(getinteger(argv[2]), true);
			p2 += 3;
			skipline(p2);
		}
		else
			error("Invalid syntax");

		// delete the lines and update the program size counter
		memmove(p1, p2, PSize - (p2 - PMemory));
		PSize -= (p2 - p1);
		PMemory[PSize] = PMemory[PSize + 1] = PMemory[PSize + 2] = PMemory[PSize + 3] = 0;// ensure that the last four are zero
    	longjmp(mark, 1);							// jump back to the input prompt
	}
}



void cmd_on(void) {
	int r;
	char ss[4];													    // this will be used to split up the argument line

    char *p;
    // first check if this is:   ON KEY location
   	if((p = checkstring(cmdline, "KEY")) != NULL) {
   		skipspace(p);
   		if(*p == '0' && !isdigit(*(p+1)))
   		    OnKeyGOSUB = NULL;                                      // the program wants to turn the interrupt off
   		else {
   			OnKeyGOSUB = GetIntAddress(p);						    // get a pointer to the interrupt routine
       	    InterruptUsed = true;
   		}
   		return;
   	}

	// if we got here the command must be the traditional:  ON nbr GOTO|GOSUB line1, line2,... etc

	ss[0] = tokenvalue[TKN_GOTO];
	ss[1] = tokenvalue[TKN_GOSUB];
	ss[2] = ',';
	ss[3] = 0;
	{																// start a new block
		getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ss);				// getargs macro must be the first executable stmt in a block
		if(argc < 3 || !(*argv[1] == ss[0] || *argv[1] == ss[1])) error("Invalid syntax");
		if(argc%2 == 0) error("Invalid syntax");

		r = getinteger(argv[0]);									// evaluate the expression controlling the statement
		if(r < 0 || r > 255) error("Number out of range");
		if(r == 0 || r > argc/2) return;							// microsoft say that we just go on to the next line

		if(*argv[1] == ss[1]) {
			// this is a GOSUB, same as a GOTO but we need to first push the return pointer
			if(gosubindex >= MAXGOSUB) error("Too many nested GOSUB");
			gosubstack[gosubindex++] = nextstmt;
        	LocalIndex++;
		}

		if(isnamestart(*argv[r*2]))
			nextstmt = findlabel(argv[r*2]);						// must be a label
		else
			nextstmt = findline(getinteger(argv[r*2]), true);		// try for a line number
	}
}



void cmd_dim(void) {
	int i;
	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ",");				// getargs macro must be the first executable stmt in a block

	if((argc & 0x01) == 0) error("Invalid syntax");

	for(i = 0; i < argc; i += 2) {
		findvar(argv[i], V_FIND | V_DIM_ARRAY);
//		if(vartbl[VarIndex].dims[0] == 0) error("Not an array");
    	if(vartbl[VarIndex].dims[0] != 0) DimUsed = true;
//		checkend(skipvar(argv[i], false));
	}
}



void cmd_local(void) {
	int i;
	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ",");				// getargs macro must be the first executable stmt in a block

	if((argc & 0x01) == 0) error("Invalid syntax");
	if(LocalIndex == 0) error("Local invalid here");

	for(i = 0; i < argc; i += 2) {
		findvar(argv[i], V_FIND | V_DIM_ARRAY | V_LOCAL);
    	if(vartbl[VarIndex].dims[0] != 0) DimUsed = true;
//		checkend(skipvar(argv[i], false));
	}
}



void cmd_erase(void) {
	int i,j,k, len;
	char p[MAXVARLEN + 1], *s, *x;
	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ",");				// getargs macro must be the first executable stmt in a block

	if((argc & 0x01) == 0) error("Invalid syntax");

	for(i = 0; i < argc; i += 2) {
		strcpy((char *)p, argv[i]);
		strcat((char *)p, "(");                                     // must be an array
		makeupper(p);                                               // all variables are stored as uppercase
		for(j = 0; j < varcnt; j++) {
            s = p;  x = vartbl[j].name; len = strlen(p);
            while(len > 0 && *s == *x) {                            // compare the variable to the name that we have
                len--; s++; x++;
            }
            if(!(len == 0 && (*x == 0 || strlen(p) == MAXVARLEN))) continue;
    		// found the variable
			FreeHeap(vartbl[j].val.s);						       	// free the memory
			vartbl[j].type = T_NOTYPE;                              // empty slot
			*vartbl[j].name = 0;                                    // safety precaution
			for(k = 0; k < MAXDIM; k++) vartbl[j].dims[k] = 0;      // and again
			if(j == varcnt - 1) { j--; varcnt--; }
			break;
		}
		if(j == varcnt) error("Cannot find variable");
	}
}



void cmd_option(void) {
	char *tp;

	tp = checkstring(cmdline, "BASE");
	if(tp) {
		if(DimUsed) error("OPTION BASE must be before DIM or LOCAL");
		OptionBase = getinteger(tp);
		if(OptionBase < 0 || OptionBase > 1) error("Number out of range");
		return;
	}

	tp = checkstring(cmdline, "ERROR");
	if(tp) {
		if(checkstring(tp, "CONTINUE")) {
				OptionErrorAbort = false;
				MMerrno = 0;
				return;
			}
		if(checkstring(tp, "ABORT")) {
				OptionErrorAbort = true;
				return;
			}
	}

	tp = checkstring(cmdline, "PROMPT");
	if(tp) {
		skipspace(tp);
		if(strlen(tp) >= MAXPROMPTLEN) error("String too long");
		getstring(tp);												// check for any expression errors
		strcpy(PromptString, tp);									// and save for later evaluation
		return;
	}

	tp = checkstring(cmdline, "USB");
	if(tp) {
		if(checkstring(tp, "ON")) {
				USBOn = true;
				return;
			}
		if(checkstring(tp, "OFF")) {
				USBOn = false;
				return;
			}
	}

	tp = checkstring(cmdline, "BREAK");
	if(tp) {
		BreakKey = getinteger(tp);
		return;
	}

	tp = checkstring(cmdline, "VIDEO");
	if(tp) {
		if(checkstring(tp, "ON")) {
    		    VideoOn = true;
				return;
			}
		if(checkstring(tp, "OFF")) {
				VideoOn = false;
				return;
			}
	}

	// check for a programmable function key
	if(toupper(*cmdline) == 'F') {
		int i;
		for(i = 1; i <= NBRPROGKEYS; i++) {
			if(atoi(cmdline+1) == i) {								// is this a match to a key number
				cmdline += 2 + (i < 10 ? 0:1);						// step over the number
				skipspace(cmdline);
				tp = getCstring(cmdline);							// get the string
				if(strlen(tp) > MAXKEYLEN) error("String too long");
				strcpy((char *)FunKey[i - 1], tp);							// save into our array
				return;
			}
		}
	}

	error("Unrecognised option");
}



void cmd_poke(void) {
    unsigned int i;
    char *p;
    
	getargs(&cmdline, 5, ",");
	if(argc != 5) error("Invalid syntax");
	i = 0;
#if defined(MMFAMILY)
    #if defined(COLOUR)
        if(checkstring(argv[0], "RVIDEO"))
            i = (unsigned int)VideoBufRed;
        else if(checkstring(argv[0], "GVIDEO"))
            i = (unsigned int)VideoBufGrn;
        else if(checkstring(argv[0], "BVIDEO"))
            i = (unsigned int)VideoBufBlu;
        else
    #else
        if(checkstring(argv[0], "VIDEO"))
            i = (unsigned int)VideoBuf;
        else
    #endif   // COLOUR
    if(checkstring(argv[0], "KBUF"))
        i = (unsigned int)InpQueue;
    else if(checkstring(argv[0], "KHEAD"))
        i = (unsigned int)&InpQueueHead;
    else if(checkstring(argv[0], "KTAIL"))
        i = (unsigned int)&InpQueueTail;
    else
#endif
    if(checkstring(argv[0], "PROGMEM"))
        i = (unsigned int)PMemory;
	else if((p = checkstring(argv[0], "VAR")))
		i = (unsigned int)findvar(p, true);
    else if(checkstring(argv[0], "VARTBL"))
        i = (unsigned int)vartbl;
    else
        i = getinteger(argv[0]) << 16;

    if(i == 0) error("Invalid argument");
//    _excep_peek = true;
	*(char *)(i + getinteger(argv[2])) = getinteger(argv[4]);
//	_excep_peek = false;
}



void cmd_auto(void) {
	getargs(&cmdline, 3, ",");
	if(CurrentLinePtr) error("Invalid in a program");
	if(argc == 0) {													// if there are no arguments just stuff the lines into program memory
		ClearRuntime();												// clear any leftovers from the previous program
		while(1) {													// while forever (actually until CTRL-C)
			*inpbuf = 0;											// clear the input buffer
			EditInputLine();										// get the input
			tokenise(false);										// turn into executable code
			AddProgramLine(true);		                            // add to program memory
		}
	}

	if(argc == 2) error("Invalid syntax");
	if(argc >= 1) autoNext = getinteger(argv[0]);
	if(argc == 3) autoIncr = getinteger(argv[2]);
	autoOn = true;
}






/***********************************************************************************************
utility functions used by the various commands
************************************************************************************************/

// merge a file into program memory or memory allocated to a module
// when loading into program memory MemPtr should be NULL
// when loading a library/module MemPtr should point to the start of the allocated memory
void mergefile(char *fname, char *MemPtr) {
	char *tp, *p1;
	signed char c;
	int fn, i;

	fn = FindFreeFileNbr();
	MMfopen(fname, "r", fn);

	tp = inpbuf;
	c = i = 0;
	while(1) {
		if(MMfeof(fn) && tp == inpbuf) break;

		if(i > MAXSTRLEN)
			error("Input line is too long");

		// make sure that we get only one line for each CF/LF pair
		switch(c) {
			case '\r':	c = MMfgetc(fn);
						if(c == '\n') { c = 0; continue; }
						break;
			case '\n':	c = MMfgetc(fn);
						if(c == '\r') { c = 0; continue; }
						break;
			default  :	c = MMfgetc(fn);
		}

		if(c == '\t') {
			while(((++i) % 8) && i <= MAXSTRLEN) *tp++ = ' ';		// expand tabs to spaces
		} else if(isprint(c)) {
			*tp++ = c;												// if printable save in the input buffer
			i++;
		} else if(c == '\r' || c == '\n' || MMfeof(fn)) {			// end of a line
			if(MMfeof(fn) && tp == inpbuf) break;					// don't bother if EOF and a zero length line
			*tp = 0;												// terminate the buffer
			tokenise(false);										// do some magic
			if(MemPtr) {
                if(((tknbuf[1] << 8) | tknbuf[2]) != NOLINENBR) error("Library uses line numbers");
    		    for(p1 = tknbuf + 3; !(p1[0]== 0 && p1[1] == 0); p1++) ;        // count the length of the line
                memmove(MemPtr, tknbuf, p1 - tknbuf + 2);                       // and add the new line
                MemPtr += p1 - tknbuf + 1;                                          // update the pointer
		    } else
		        AddProgramLine(false);      		                // add to program memory - this will accept lines with line numbers
			tp = inpbuf;											// setup for the next line
			i = 0;
		}
	}
	MMfclose(fn);
}



// utility function used by llist() below
// it copys a command or function honouring the case selected by the user
void strCopyWithCase(char *d, char *s) {
	if(GetFlashOption(&CaseOption) == CONFIG_LOWER) {
		while(*s)
			*d++ = tolower(*s++);
	} else if(GetFlashOption(&CaseOption) == CONFIG_UPPER) {
		while(*s)
			*d++ = toupper(*s++);
	} else {
		while(*s)
			*d++ = *s++;
	}
	*d = 0;
}


// list a line into a buffer (b) given a pointer to the beginning of the line (p).
// this is used by flist() and cmd_edit()
char *llist(char *b, char *p) {
	int i, firstnonwhite = true;

	while(1) {
		if(*p == T_LINENBR) {
			i = (((p[1]) << 8) | (p[2]));							// get the line number
			p += 3;													// and step over the number
			if(i != NOLINENBR) {
				b += sprintf(b, "%d", i);
				if(*p != ' ') *b++ = ' ';
			}
			firstnonwhite = true;
			continue;
			}

		if(*p == T_LABEL) {											// got a label
			for(i = p[1], p += 2; i > 0; i--)
				*b++ = *p++;										// copy to the buffer
			*b++ = ':';												// terminate with a colon
			if(*p && *p != ' ') *b++ = ' ';							// and a space if necessary
			firstnonwhite = true;
			}														// this deliberately drops through in case the label is the only thing on the line

		if(*p >= C_BASETOKEN) {
			if(firstnonwhite) {
				if(*p - C_BASETOKEN == GetCommandValue("LET"))
					*b = 0;											// use nothing if it LET
				else
					strCopyWithCase(b, commandname(*p));			// expand the command (if it is not LET)
				firstnonwhite = false;
			} else {												// not a command so must be a token
				strCopyWithCase(b, tokenname(*p));					// expand the token
				if(*p == tokenvalue[TKN_THEN] || *p == tokenvalue[TKN_ELSE])
					firstnonwhite = true;
				else
					firstnonwhite = false;
			}
			b += strlen(b);											// update pointer to the end of the buffer
			p++;
			continue;
		}

		// hey, an ordinary char, just copy it to the output
		if(*p) {
			*b = *p;												// place the char in the buffer
			if(*p != ' ') firstnonwhite = false;
			p++;  b++;												// move the pointers
			continue;
		}

		// at this point the char must be a zero
		// zero char can mean both a separator or end of line
		if(!(p[1] == T_LINENBR || p[1] == 0)) {
			*b++ = ':';												// just a separator
			firstnonwhite = true;
			p++;
			continue;
		}

		// must be the end of a line - so return to the caller
		*b = 0;														// terminate the output buffer
		return ++p;
	} // end while
}



// lists the program to a specified file handle
// this decodes line numbers and tokens and outputs them in plain english
// LISTing a program is exactly the same as listing to a file (ie, SAVE)
void flist(int fnbr, int fromnbr, int tonbr) {
	char *fromp  = PMemory + 1;
	char b[STRINGSIZE];
	int i;

	if(fromnbr != 1) fromp = findline(fromnbr, (fromnbr == tonbr) ? true : false);	// set our pointer to the start line
	ListCnt = 1;

	while(1) {

		if(*fromp == T_LINENBR) {
			i = (((fromp[1]) << 8) | (fromp[2]));					// get the line number
			if(i != NOLINENBR && i > tonbr) break;					// end of the listing
			fromp = llist(b, fromp);								// otherwise expand the line
			MMfputs(CtoM(b), fnbr);									// convert to a MMBasic string and output
            	MMfputs("\2\r\n", fnbr);							// print the terminating cr/lf
			if(i != NOLINENBR && i >= tonbr) break;					// end of the listing
			// check if it is more than a screenfull
			if(fnbr == 0 && ListCnt >= VCHARS && !(fromp[0] == 0 && fromp[1] == 0)) {
				MMPrintString("PRESS ANY KEY ...");
				MMgetchar();
				MMPrintString("\r                 \r");
				ListCnt = 1;
			}
		}
		//else
		//	error("Internal error in flist()");

		// finally, is it the end of the program?
		if(fromp[0] == 0) break;
	}
	if(fnbr != 0) MMfclose(fnbr);
}



void execute_one_command(char *p) {
    int cmd, i;

	CheckAbort();
	targ = T_CMD;
	skipspace(p);													// skip any whitespace
	if(*p >= C_BASETOKEN && *p - C_BASETOKEN < CommandTableSize - 1 && (commandtbl[*p - C_BASETOKEN].type & T_CMD)) {
    	cmd = *p  - C_BASETOKEN;
    	if(cmd == GetCommandValue("WHILE") || cmd == GetCommandValue("DO") || cmd == GetCommandValue("FOR")) error("Invalid inside THEN ... ELSE") ;
		cmdtoken = *p;
		cmdline = p + 1;
        skipspace(cmdline);
		commandtbl[cmd].fptr();						                // execute the command
	} else {
	    if(!isnamestart(*p)) error("Invalid character");
        i = FindSubFun(p, false);                                   // it could be a defined command
        if(i >= 0)                                                  // >= 0 means it is a user defined command
            DefinedSubFun(false, p, i, NULL, NULL);
        else
            error("Unknown command");
	}
	ClearTempSpace();											    // at the end of each command we need to clear any temporary string vars

}

