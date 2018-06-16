/***********************************************************************************************************************
MMBasic

MMBasic.c

Provides the core functions used in MMBasic.  These include parsing the command line and converting the key
words into tokens, storage and management of the program in memory, storage and management of variables,
the expression execution engine and other useful functions.

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
#include "MMBasic.h"

    #include "Functions.h"
    #include "Commands.h"
    #include "Operators.h"
    #include "Custom.h"
    #include "Hardware_Includes.h"


// this is the command table that defines the various tokens for commands in the source code
// most of them are listed in the .h files so you should not add your own here but instead add
// them to the appropiate .h file
#define INCLUDE_COMMAND_TABLE
const struct s_tokentbl commandtbl[] = {
    #include "Functions.h"
    #include "Commands.h"
    #include "Operators.h"
    #include "Custom.h"
    #include "Hardware_Includes.h"
    { "",   0,                  0, cmd_null,    }                   // this dummy entry is always at the end
};
#undef INCLUDE_COMMAND_TABLE



// this is the token table that defines the other tokens in the source code
// most of them are listed in the .h files so you should not add your own here
// but instead add them to the appropiate .h file
#define INCLUDE_TOKEN_TABLE
const struct s_tokentbl tokentbl[] = {
    #include "Functions.h"
    #include "Commands.h"
    #include "Operators.h"
    #include "Custom.h"
    #include "Hardware_Includes.h"
    { "",   0,                  0, cmd_null,    }                   // this dummy entry is always at the end
};
#undef INCLUDE_TOKEN_TABLE

// these are initialised at startup
int CommandTableSize, TokenTableSize;

struct s_vartbl *vartbl;                                            // this table stores all variables
int varcnt;                                                         // number of variables
int VarIndex;                                                       // Global set by findvar after a variable has been created or found
int LocalIndex;                                                     // used to track the level of local variables
int TempStringClearStart;                                           // used to prevent clearing of space in an expression that called a FUNCTION

char *subfun[MAXSUBFUN];                                            // table used to locate all subroutines and functions

#if defined(MMFAMILY) || defined(DOS)
char *ModuleTable[MAXMODULES];                                      // list of pointers to libraries a(also called modules) loaded in memory;
int NbrModules;                                                     // the number of libraries/modules currently loaded
#endif


char FunKey[NBRPROGKEYS][MAXKEYLEN + 1];                            // data storage for the programmable function keys


jmp_buf mark;                                                       // longjump to recover from an error
char inpbuf[STRINGSIZE];                                            // used to store user keystrokes until we have a line
char tknbuf[STRINGSIZE];                                            // used to store the tokenised representation of the users input line
char lastcmd[STRINGSIZE];                                           // used to store the last command in case it is needed by the EDIT command

char *PMemory;                                                      // program memory, this is where the program is stored
int PSize;                                                          // the size of the program stored in PMemory[]

int TraceOn;                                                        // used to track the state of TRON/TROFF
int NextData;                                                       // used to track the next item to read in DATA & READ stmts
int OptionBase;                                                     // track the state of OPTION BASE
int ProgramChanged;                                                 // true if the program in memory has been changed and not saved


///////////////////////////////////////////////////////////////////////////////////////////////
// Global information used by operators
//
int targ;                                                           // the type of the arguments being passed
float farg1, farg2, fret;                                           // the two float arguments and returned value
char *sarg1, *sarg2, *sret;                                         // the two string arguments and returned value

////////////////////////////////////////////////////////////////////////////////////////////////
// Global information used by functions
// functions use targ, fret and sret as defined for operators (above)
char *ep;                                                           // pointer to the argument to the function terminated with a zero byte.
                                                                    // it is NOT trimmed of spaces

////////////////////////////////////////////////////////////////////////////////////////////////
// Global information used by commands
//
int cmdtoken;                                                       // Token number of the command
char *cmdline;                                                      // Command line terminated with a zero char and trimmed of spaces
char *nextstmt;                                                     // Pointer to the next statement to be executed.
char *CurrentLinePtr;                                               // Pointer to the current line (used in error reporting)
char *ContinuePoint;                                                // Where to continue from if using the continue statement
char PromptString[MAXPROMPTLEN];                                    // the prompt for input, an empty string means use the default

int tokencnt;
char tokenvalue[TOKEN_LOOKUP_SIZE];                                 // initialised in InitBasic()
extern void SetTokenTableSize(void);

int autoOn, autoNext = 10, autoIncr = 10;                           // use by the AUTO command


/////////////////////////////////////////////////////////////////////////////////////////////////
// Functions only used within MMBasic.c
//
void getexpr(char *);
void checktype(int *, int);
char *doexpr(char *p, float *fa, char **sa, int *oo, int *t);
char *getvalue(char *p, float *fa, char **sa, int *oo, int *t);


/********************************************************************************************************************************************
 Program mamagement
 Includes the routines to initialise MMBasic, start running the interpreter, and to run a program in memory
*********************************************************************************************************************************************/


// Initialise MMBasic
void InitBasic(void) {
    CommandTableSize =  (sizeof(commandtbl)/sizeof(struct s_tokentbl));
    TokenTableSize =  (sizeof(tokentbl)/sizeof(struct s_tokentbl));

    ClearProgram();
    *PromptString = 0;

    // load the tokenvalue table with commonly used tokens
    // by placing them into a lookup table performance is improved considerably
    tokenvalue[TKN_THEN]  = GetTokenValue("THEN");
    tokenvalue[TKN_ELSE]  = GetTokenValue("ELSE");
    tokenvalue[TKN_GOTO]  = GetTokenValue("GOTO");
    tokenvalue[TKN_EQUAL] = GetTokenValue("=");
    tokenvalue[TKN_TO]    = GetTokenValue("TO");
    tokenvalue[TKN_STEP]  = GetTokenValue("STEP");
    tokenvalue[TKN_WHILE] = GetTokenValue("WHILE");
    tokenvalue[TKN_UNTIL] = GetTokenValue("UNTIL");
    tokenvalue[TKN_GOSUB] = GetTokenValue("GOSUB");
    tokenvalue[TKN_AS]    = GetTokenValue("AS");
    // IMPORTANT
    // If you add to this table you must change TOKEN_LOOKUP_SIZE in MMBasic.h
}



// run a program
// this will continuously execute a program until the end (marked by TWO zero chars)
// the argument p must point to the first line to be executed
void ExecuteProgram(char *p) {
    int i;
    PrepareProgram();

    skipspace(p);                                                   // just in case, skip any whitespace
    while(1) {
        if(*p == 0) p++;                                            // step over the zero byte marking the beginning of a new element
        CheckAbort();
        if(*p == T_LINENBR) {
            CurrentLinePtr = p;                                     // and pointer to the line for error reporting
            if(TraceOn) {
                sprintf(inpbuf, "[%d]", CountLines(p));
                MMPrintString(inpbuf);
            }
            p += 3;                                                 // and step over the number
        }
        skipspace(p);                                               // and skip any trailing whitespace

        if(p[0] == T_LABEL) {                                       // got a label
            p += p[1] + 2;                                          // skip over the label
            skipspace(p);                                           // and any following spaces
        }

        if(*p) {                                                    // if the line is not empty
            nextstmt = cmdline = p + 1;
            skipspace(cmdline);
            skipelement(nextstmt);
            if(*p && *p != '\'') {                                  // ignore a comment line
                if(*(char*)p >= C_BASETOKEN && *(char*)p - C_BASETOKEN < CommandTableSize - 1 && (commandtbl[*(char*)p - C_BASETOKEN].type & T_CMD)) {
                    cmdtoken = *(char*)p - C_BASETOKEN;
                    targ = T_CMD;
                    commandtbl[*(char*)p - C_BASETOKEN].fptr();            // execute the command
                } else {
            	    if(!isnamestart(*p)) error("Invalid character");
                    i = FindSubFun(p, false);                       // it could be a defined command
                    if(i >= 0)                                      // >= 0 means it is a user defined command
                        DefinedSubFun(false, p, i, NULL, NULL);
                    else
                        error("Unknown command");
                }
                ClearTempSpace();                                   // at the end of each command we need to clear any temporary string vars

                check_interrupt();                                  // check for an MMBasic interrupt or touch event and handle it
            }
            p = nextstmt;
        }
        if(p[0] == 0 && p[1] == 0) return;                          // the end of the program is marked by TWO zero chars
    }
}


/********************************************************************************************************************************************
 Code associated with processing user defined subroutines and functions
********************************************************************************************************************************************/


// Scan through the program loaded in program memory and any loaded libraries/modules and build a table
// pointing to the definition of all user defined subroutines and functions.
// This pre processing speeds up the program when using defined subroutines and functions
void PrepareProgram(void) {
    int i, j;
    char *p, defcmdtoken, deffuntoken;

	defcmdtoken = GetCommandValue("SUB") + C_BASETOKEN;
	deffuntoken = GetCommandValue("FUNCTION") + C_BASETOKEN;
	i = 0;

#if defined(MMFAMILY) || defined(DOS)
    for(j = 0; j <= NbrModules; j++) {                              // scan the number of modules + 1 (the extra is for program memory)
        if(j)
            p = ModuleTable[j - 1] + FILENAME_LENGTH + 4;           // we are going to scan a library/module
        else
#endif
            p = PMemory;                                            // the first loop (i = 0) is code for scan program memory
    	while(1) {
    		while(*p) p++;											// look for the zero marking the start of an element
    		if(p[1] == 0) break;                                    // end of the program or module
    		if(p[1] == T_LINENBR) {
        		p += 3;                                             // skip over the line number
            }
    		p++;
    		skipspace(p);
    		if(p[0] == T_LABEL) {
    			p += p[1] + 2;										// skip over the label
    			skipspace(p);										// and any following spaces
    		}
    		if(*p == defcmdtoken || *p == deffuntoken) {            // found a SUB or FUN token
        		if(i >= MAXSUBFUN) error("Too many SUB and FUN");
        		subfun[i++] = p;
            }
        }
#if defined(MMFAMILY) || defined(DOS)
    }
#endif
    if(i < MAXSUBFUN) subfun[i] = NULL;
}



// searches the subfun[] table to locate a defined sub or fun
// returns with the index of the sub/function in the table or -1 if not found
// if type = 0 then look for a sub otherwise a function
int FindSubFun(char *p, int type) {
    char *p1, *p2, cmd;
    int i;

    cmd = GetCommandValue(type ? "FUNCTION" : "SUB") + C_BASETOKEN;
    for(i = 0;  i < MAXSUBFUN && subfun[i] != NULL; i++) {
        p2 = subfun[i];                                             // point to the command token
        if(cmd != *p2) continue;
        p2++; skipspace(p2);                                        // point to the identifier
        if(toupper(*p) != toupper(*p2)) continue;                   // quick first test
        p1 = p + 1;  p2++;
        while(isnamechar(*p1) && toupper(*p1) == toupper(*p2)) { p1++; p2++; };
        if(*p1 == '$' && *p2 == '$') { p1++; p2++; };
        if(*p1 == '$' || *p2 == '$') continue;
        if(!isnamechar(*p1) && !isnamechar(*p2)) return i;          // found it !
    }
    return -1;
}



// This function is responsible for executing a defined subroutine or function.
// As these two are similar they are processed in the one lump of code.
//
// The arguments when called are:
//   isfun    = true if we are executing a function
//   cmd      = pointer to the command name used by the caller (in program memory)
//   index    = index into subfun[i] which points to the definition of the sub or funct
//   fa and sa are pointers to where the return value is to be stored (used by functions only)
void DefinedSubFun(int isfun, char *cmd, int index, float *fa, char **sa) {
	char *p, *tp, *ttp, tcmdtoken;
	char *CallersLinePtr, *SubLinePtr = NULL;
    char *argbuf1; char **argv1; int argc1;
    char *argbuf2; char **argv2; int argc2;
    char fun_name[MAXVARLEN + 1];
	int t, i, size = 0, ArgIsFunct, oldclear, fun_type = T_NBR;
	float f;
	char *s;

    SubLinePtr = subfun[index];                                     // used for error reporting
    p =  SubLinePtr + 1;                                            // point to the sub or function definition
    skipspace(p);

    tp = p;
    p++; while(isnamechar(*p)) p++;                                 // find the end of the identifier in the definition
    if(*p == '$') { p++; fun_type = T_STR; }                        // and get the type of the function
    memcpy(fun_name, tp, p - tp); fun_name[p - tp] = 0;             // copy the sub/fun name into temp storage and terminate

    tp = cmd + (int)(p - tp);                                       // use tp to point to the end of the caller's identifier

    // from now on
    // tp  = the caller's argument list
    // p   = the argument list for the definition
    skipspace(tp); skipspace(p);
	CallersLinePtr = CurrentLinePtr;

    if(gosubindex >= MAXGOSUB) error("Too many nested sub/function");
	gosubstack[gosubindex++] = isfun ? NULL : nextstmt;             // NULL signifies that this is returned to by ending ExecuteProgram()
	LocalIndex++;

    // allocate memory for processing the arguments
    argbuf1 = getmemory(STRINGSIZE); argv1 = getmemory(MAX_ARG_COUNT * sizeof(char *));
    argbuf2 = getmemory(STRINGSIZE); argv2 = getmemory(MAX_ARG_COUNT * sizeof(char *));

    // now split up the arguments in the caller
    argc1 = 0;
    if(*tp) makeargs(&tp, MAX_ARG_COUNT, argbuf1, argv1, &argc1, (*tp == '(') ? "(," : ",");

    // split up the arguments in the definition
    CurrentLinePtr = SubLinePtr;                                    // any errors must be at the definition
    argc2 = 0;
    if(*p) makeargs(&p, MAX_ARG_COUNT, argbuf2, argv2, &argc2, (*p == '(') ? "(," : ",");

    // error checking
    CurrentLinePtr = CallersLinePtr;                                // report errors at the caller
    if(argc1 > argc2) error("Too many arguments");
    if(argc1 && (argc1 & 1) == 0) error("Invalid Syntax");
    CurrentLinePtr = SubLinePtr;                                    // any errors must be at the definition
    if(argc2 && (argc2 & 1) == 0) error("Invalid Syntax");

	// assign the callers command line values to local variables representing the argument list
    for(i = 0; i < argc2; i += 2) {
        ttp = NULL;
        ArgIsFunct = false;
        CurrentLinePtr = CallersLinePtr;                            // report errors at the caller
        // check if the argument is a valid variable, if so set ttp to point to the variable's data
        if(i < argc1 && isnamestart(*argv1[i]) && *skipvar(argv1[i], false) == 0) {
            ArgIsFunct = (FindSubFun(argv1[i], 1) >= 0);            // if it is a function set a flag
            if(!ArgIsFunct) {                                       // and find the variable if it is NOT a function
                if((vartype(argv1[i]) & (T_NBR | T_STR)) != (vartype(argv2[i]) & (T_NBR | T_STR))) error("Incompatible arguments");
                LocalIndex--;                                       // find the variable at the previous level
                ttp = findvar(argv1[i], V_FIND );
                size = vartbl[VarIndex].size;                       // get the size in case it is a string array
                LocalIndex++;                                       // reset to the current level
            }
        }

        // create a local variable from the defined subroutine's argument
        CurrentLinePtr = SubLinePtr;                                // report errors at the definition
        tp = findvar(argv2[i], V_FIND | V_LOCAL);                   // declare the local variable
        CurrentLinePtr = CallersLinePtr;                            // report errors at the caller

        if(i < argc1 && *argv1[i]) {
            if(ttp != NULL) {
                // we have created a local variable that needs to be converted to a pointer
                // we do this by freeing any memory allocated to the variable and changing the
                // data field of the variable to point to the variable supplied by the caller
                if(vartbl[VarIndex].type & T_STR)                   // only a string has memory allocated (arrays are not allowed)
                    FreeHeap(vartbl[VarIndex].val.s);               // free up its memory
                vartbl[VarIndex].size = size;                       // set the size in case the variable is an element of a string array
                vartbl[VarIndex].type |= T_PTR;                     // set the type to a pointer
                vartbl[VarIndex].val.s = ttp;                       // point to the data of the caller's variable
            } else {
                // otherwise the argument was an expression, we get its value and assign it to the variable
                if(!ArgIsFunct) LocalIndex--;                       // evaluate the expression at the previous level
            	if(vartype(argv2[i]) == T_STR) {
            		t = T_STR;
            		ttp = evaluate(argv1[i], &f, &s, &t, false);    // get a string
            		Mstrcpy(tp, s);
            	} else {
            		t = T_NBR;
            		ttp = evaluate(argv1[i], &f, &s, &t, false);    // get a float
            		(*(float *)tp) = f;
            	}
                if(!ArgIsFunct) LocalIndex++;                       // reset to the current level
            }
        }
    }

    // free the memory used in processing the arguments
    FreeHeap(argbuf1); FreeHeap((char *)argv1);
    FreeHeap(argbuf2); FreeHeap((char *)argv2);

    // if it is a defined command we simply point to the first statement in our command and allow ExecuteProgram() to carry on as before
    if(!isfun) {
        skipelement(p);
        nextstmt = p;                                               // point to the body of the subroutine
        return;
    }

    // if it is a defined function we have a lot more work to do.  We must:
    //   - Create a local variable for the function's name
    //   - Save the globals being used by the current command that caused the function to be called
    //   - Invoke another instance of ExecuteProgram() to execute the body of the function
    //   - When that returns we need to restore the global variables
    //   - Get the valuable's value and save that in the return value globals (fret or sret)
    //   - Return to the expression parser

    // create a local variable for the function's name
    CurrentLinePtr = SubLinePtr;                                    // report errors at the definition
    tp = findvar(fun_name, V_FIND | V_LOCAL);                       // declare the local variable
    if(fun_type == T_STR) {
        FreeHeap(vartbl[VarIndex].val.s);                           // free the memory if it is a string
        vartbl[VarIndex].type |= T_PTR;                             // convert it to a pointer
        vartbl[VarIndex].val.s = tp = GetTempStringSpace();         // and use our own memory
    }
    skipelement(p);                                                 // point to the body of the function

    // save the current don't erase level for GetTempStringSpace(), then calculate the new level for this index
    // this is to prevent GetTempStringSpace() from clearing space being used by the expression that called this function
    oldclear = TempStringClearStart;
    for(TempStringClearStart = 0; TempStringClearStart < MAXTEMPSTRINGS; TempStringClearStart++)
        if(strtmp[TempStringClearStart] == NULL) break;

    ttp = nextstmt;                                                 // save the globals used by commands
    tcmdtoken = cmdtoken;
    s = cmdline;

    ExecuteProgram(p);                                              // execute the function's code

    cmdline = s;                                                    // restore the globals
    cmdtoken = tcmdtoken;
    nextstmt = ttp;
    TempStringClearStart = oldclear;

    // return the value of the function's variable to the caller
    if(fun_type == T_NBR)
        *fa = *(float *)tp;
    else
        *sa = tp;                                                   // for a string we just need to return the local memory

	ClearVars(LocalIndex--);                                        // delete any local variables
	gosubindex--;
    CurrentLinePtr = CallersLinePtr;                                // report errors at the caller
}




/********************************************************************************************************************************************
 take an input line and turn it into a line with tokens suitable saving into memory
********************************************************************************************************************************************/

//take an input string in inpbuf[] and copy it to tknbuf[] and:
// - convert the line number to a binary number
// - convert a label to the token format
// - convert keywords to tokens
// - convert the colon to a zero char
//the result in tknbuf[] is terminated with double zero chars
// if the arg console is true then do not add a line number

void tokenise(int console) {
    char *p, *op, *tp, c;
    int i, cmdlen;
    int firstnonwhite;
    int labelvalid;

    // first, make sure that only printable characters are in the line
    p = inpbuf;
    while(*p) {
        *p = *p & 0x7f;
        if(*p < ' ' || *p == 0x7f)  *p = ' ';
        p++;
    }

    // setup the input and output buffers
    p = inpbuf;
    op = tknbuf;
    *op = 0;

    // get the line number if it exists
    tp = p;
    skipspace(tp);
    if(isdigit(*tp)) {
        i = strtol(tp, &tp, 10);
        if(i < 0 || i >= MAXLINENBR) error("Invalid line number");
        *op++ = T_LINENBR;
        *op++ = (i>>8);
        *op++ = (i & 0xff);
        p = tp;
    } else if(!console) {
        *op++ = T_LINENBR;
        *op++ = (NOLINENBR>>8);
        *op++ = (NOLINENBR & 0xff);
    //  *op++ = ' ';
    }

    // process the rest of the line
    firstnonwhite = true;
    labelvalid = true;
    while(*p) {

        if(*p == ' ') {
            *op++ = *p++;
            continue;
        }

        // first look for quoted text and copy it across
        // this will also accept a string without the closing quote and it will add the quote in
        if(*p == '"') {
            do {
                *op++ = *p++;
            } while(*p != '"' && *p);
            *op++ = '"';
            if(*p == '"') p++;
            continue;
        }

        // copy anything after a comment (')
        if(*p == '\'') {
            do {
                *op++ = *p++;
            } while(*p);
            continue;
        }

        // check for multiline separator (colon) and replace with a zero char
        if(*p == ':') {
            *op++ = 0;
            p++;
            while(*p == ':') {                                      // insert a space between consecutive colons
                *op++ = ' ';
                *op++ = 0;
                p++;
            }
            firstnonwhite = true;
            continue;
        }

        // not whitespace or string or comment  - try a number
        if(isdigit(*p) || *p == '.') {                              // valid chars at the start of a number
            while(isdigit(*p) || *p == '.' || *p == 'E' || *p == 'e')
                if (*p == 'E' || *p == 'e') {   // check for '+' or '-' as part of the exponent
                    *op++ = *p++;                                   // copy the number
                    if (*p == '+' || *p == '-') {                   // BUGFIX by Gerard Sexton
                        *op++ = *p++;                               // copy the '+' or '-'
                    }
                } else {
                    *op++ = *p++;                                   // copy the number
                }
            firstnonwhite = false;
            continue;
        }

        // not whitespace or string or comment or number - see if we can find a label or a token identifier
        c = toupper(*p);                                            // get the first char to quickly identify a potential command or token
        if(firstnonwhite) {                                         // first entry on the line must be a command
            // first test if it is a command and, if so, convert the command into a command token
            for(i = 0 ; i < CommandTableSize - 1; i++) {
                tp = commandtbl[i].name;
                if(c == *tp && !strncasecmp(p, tp, cmdlen = strlen(tp))) { // we have found a potential match
                    if(!isnamechar(p[cmdlen]) || p[cmdlen - 1] == '(') {// check that the identifier is terminated correctly
                        tp = p + cmdlen; skipspace(tp);                 // find the character after the command
                        // only treat this as a command if there is not an equals following and it is not a function type command
                        if(*tp != '=' || (commandtbl[i].type & T_FUN) || i == GetCommandValue("REM")) {
                            if(c == '?')                                // if the command is a shortcut for PRINT insert the correct token
                                *op++ = GetCommandValue("Print") + C_BASETOKEN;
                            else
                                *op++ = i + C_BASETOKEN;                // otherwise insert the token found
                            p += cmdlen;                                // and step over it in the source text
                            if(i == GetCommandValue("REM"))             // check if it is a REM command
                                while(*p) *op++ = *p++;                 // just copy everything
                            firstnonwhite = false;
                            labelvalid = false;                         // we do not want any labels after this
                            break;
                        }
                    }
                }
            }
            if(i != CommandTableSize - 1) continue;                     // we have a command, so loop back to process the rest of the line


            // next test if it is a label
            if(labelvalid && isnamestart(*p)) {
                for(i = 0, tp = p + 1; i < MAXVARLEN - 1; i++, tp++)
                    if(!isnamechar(*tp)) break;                     // search for the first invalid char
                if(*tp == ':') {                                    // Yes !!  It is a label
                    labelvalid = false;                             // we do not want any more labels
                    *op++ = T_LABEL;                                // insert the token
                    *op++ = tp - p;                                 // insert the length of the label
                    for(i = tp - p; i > 0; i--) *op++ = *p++;       // copy the label
                    p++;                                            // step over the terminating colon
                    continue;
                }
            }

        } else {
            // test if there is a function or operator and, if so, convert it into a token
            for(i = 0 ; i < TokenTableSize - 1; i++) {
                tp = tokentbl[i].name;
                if(c == *tp && !strncasecmp(p, tp, cmdlen = strlen(tp))) { // we have found a potential match
                    // check that the identifier is terminated correctly - there is a special case with functions with arguments
                    // in that case we always assume that it is correctly terminated regardless
                    if(!isalpha(*p) || !isnamechar(p[cmdlen]) || (tokentbl[i].type & T_FUN)) {
                        i += C_BASETOKEN;
                        *op++ = i;                                  // insert the token found
                        p += cmdlen;                                // and step over it in the source text
                        if(i == tokenvalue[TKN_THEN] || i == tokenvalue[TKN_ELSE])
                            firstnonwhite = true;                   // a command is valid after a THEN or ELSE
                        else
                            firstnonwhite = false;
                        break;
                    }
                }
            }
            if(i != TokenTableSize - 1) continue;
        }

        // not whitespace or string or comment or token identifier or number
        // try for a variable name which could be a user defined subroutine or an implied let
        if(isnamestart(*p)) {                                       // valid chars at the start of a variable name
            if(firstnonwhite) {                                     // first entry on the line?
                tp = skipvar(p, true);                              // find the char after the variable
                skipspace(tp);
                if(*tp == '=')                                      // is it an implied let?
                    *op++ = GetCommandValue("LET") + C_BASETOKEN;   // find let's token value and copy into memory
                }
            while(isnamechar(*p)) *op++ = *p++;                     // copy the the variable name
            firstnonwhite = false;
            labelvalid = false;                                     // we do not want any labels after this
            continue;
        }


        // something else, so just copy the one character
        *op++ = *p++;
       labelvalid = false;                                          // we do not want any labels after this
       firstnonwhite = false;

    }
    // end of loop, trim any trailing blanks
    while(*(op - 1) == ' ') *--op = 0;
    // make sure that it is terminated properly
    *op++ = 0;  *op++ = 0;  *op++ = 0;                              // terminate with  zero chars
}




/********************************************************************************************************************************************
 routines for evaluating expressions
 the main functions are getnumber(), getinteger() and getstring()
********************************************************************************************************************************************/


// evaluate an expression.  p points to the start of the expression in memory
// returns either the float or string in the pointer arguments
// *t points to an integer which holds the type of variable we are looking for
//  if *t = T_STR or T_NBR will throw an error if the result is not the correct type
//  if *t = T_NOTYPE it will not throw an error and will return the type found in *t
// this will check that the expression is terminated correctly and throw an error if not.  noerror = true will suppress that check
char *evaluate(char *p, float *fa, char **sa, int *ta, int noerror) {
    int o;
    int t = *ta;
    char *s;

    p = getvalue(p, fa, &s, &o, &t);
    while(o != E_END) p = doexpr(p, fa, &s, &o, &t);
    if(*ta == T_NBR && t == T_STR) error("Expected a number");
    if(*ta == T_STR && t == T_NBR) error("Expected a string");
    if(o != E_END) error("Incorrect expression syntax");
    *ta = t;
    *sa = s;
    if(!noerror) {
        skipspace(p);
        if(!(*p == 0 || *p == ',' || *p == ')' || *p == '\''))  error("Incorrect expression syntax");
    }
    return p;
}


// evaluate an expression to get a number
float getnumber(char *p) {
    int t = T_NBR;
    float f;
    char *s;

    evaluate(p, &f, &s, &t, false);
    return f;
}


// evaluate an expression and return an integer
// this will correctly round the number if it is a fraction of an integer
int getinteger(char *p) {
    return MMround(getnumber(p));
}


// evaluate an expression and return an integer
// this will correctly round the number if it is a fraction of an integer
int getint(char *p, int min, int max) {
    int i;
    i = MMround(getnumber(p));
    if(i < min || i > max) error("Number out of bounds");
    return i;
}


// evaluate an expression to get a string
char *getstring(char *p) {
    int t = T_STR;
    float f;
    char *s;

    evaluate(p, &f, &s, &t, false);
    return s;
}



// recursively evaluate an expression observing the rules of operator precedence
char *doexpr(char *p, float *fa, char **sa, int *oo, int *ta) {
    float fa1, fa2;
    int o1, o2;
    int t1, t2;
    char *sa1, *sa2;

    TestStackOverflow();                                            // throw an error if we have overflowed the PIC32's stack

    fa1 = *fa;
    sa1 = *sa;
    t1 = *ta;
    o1 = *oo;
    p = getvalue(p, &fa2, &sa2, &o2, &t2);

    while(1) {
        if(o2 == E_END || tokentbl[o1].precedence <= tokentbl[o2].precedence) {
            if(t1 != t2) error("Incompatible types in expression");
            if(!(tokentbl[o1].type & T_OPER) || !(tokentbl[o1].type & t1))
                error("Invalid operator in expression");
            farg1 = fa1; farg2 = fa2;                               // setup the float args (incase it is a float)
            sarg1 = sa1; sarg2 = sa2;                               // ditto string args
            targ = t1;
            tokentbl[o1].fptr();                                    // call the operator function
            *fa = fret;
            *sa = sret;
            *oo = o2;
            *ta = targ;
            return p;
        }
        // the next operator has a higher precedence, recursive call to evaluate it
        else
            p = doexpr(p, &fa2, &sa2, &o2, &t2);
    }
}



// get a value, either from a constant, function or variable
// also returns the next operator to the right of the value or E_END if no operator
char *getvalue(char *p, float *fa, char **sa, int *oo, int *ta) {
    float f = 0;
    char *s = NULL;
    int t = T_NOTYPE;
    char *tp, *p1, *p2;
    int i;

    TestStackOverflow();                                            // throw an error if we have overflowed the PIC32's stack

    skipspace(p);

    // special processing for the NOT operator
    // just get the next value and invert its logical value
    if(tokenfunction(*p) == op_not) {
        int ro;
        if(t == T_STR) error("Incompatible types in expression");
        p++; t = T_NBR;
        p = getvalue(p, &f, &s, &ro, &t);                           // get the next value
        f = (float)((f != 0)?0:1);                                  // invert the value returned
        skipspace(p);
        *fa = f;                                                    // save what we have
        *sa = s;
        *ta = t;
        *oo = ro;
        return p;                                                   // return straight away as we already have the next operator
    }

    // special processing for the uninary - operator
    // just get the next value and negate it
    if(tokenfunction(*p) == op_subtract) {
        int ro;
        if(t == T_STR) error("Incompatible types in expression");
        p++; t = T_NBR;
        p = getvalue(p, &f, &s, &ro, &t);                           // get the next value
        f = -f;                                                     // negate the value returned
        skipspace(p);
        *fa = f;                                                    // save what we have
        *sa = s;
        *ta = t;
        *oo = ro;
        return p;                                                   // return straight away as we already have the next operator
    }

    // if a function execute it and save the result
    if(tokentype(*p) & (T_FUN | T_FNA)) {
        tp = p;
        // if it is a function with arguments we need to locate the closing bracket and copy the argument to
        // a temporary variable so that functions like getarg() will work.
        if(tokentype(*p) & T_FUN) {
            p1 = p + 1;
            p = getclosebracket(p + 1);                             // find the closing bracket
            p2 = ep = GetTempStringSpace();                              // this will last for the life of the command
            while(p1 != p) *p2++ = *p1++;
          //  *p = 0;                                                 // temporarily remove the closing bracket
          //  strcpy(ep, tp + 1);                                     // save the string
          //  *p = ')';                                               // restore the closing quote
        }
        p++;                                                        // point to after the function (without argument) or after the closing bracket
        targ = (tokentype(*tp) & (T_NBR | T_STR | T_FUN | T_FNA));  // set the type of the function (which might need to know this)
        tokenfunction(*tp)();                                       // execute the function
        t = (tokentype(*tp) & (T_NBR | T_STR));                     // save the type of the function
        f = fret; s = sret;                                         // save the result
    }
    // if opening bracket then first evaluate the contents of the bracket
    else if(*p == '(') {
        p++;                                                        // step over the bracket
        p = evaluate(p, &f, &s, &t, true);                          // recursively get the contents
        if(*p != ')') error("No closing bracket in expression");
        ++p;                                                        // step over the closing bracket
    }
    // if it is a variable or a defined function, find it and get its value
    else if(isnamestart(*p)) {
        // first check if it is terminated with a bracket
        tp = p + 1;
        while(isnamechar(*tp)) tp++;                                // search for the end of the identifier
        if(*tp == '$') tp++;
        i = -1;
        if(*tp == '(') i = FindSubFun(p, 1);                        // if terminated with a bracket it could be a function
        t = vartype(p);
        if(i >= 0)                                                  // >= 0 means it is a user defined function
            DefinedSubFun(true, p, i, &f, &s);
        else {
            s = (char *)findvar(p, V_FIND);
            if(t == T_NBR) f = (*(float *)s);
        }
        p = skipvar(p, false);
    }
    // if it is a string constant, return a pointer to that.  Note: tokenise() guarantees that strings end with a quote
    else if(*p == '"') {
        p++;                                                        // step over the quote
        p1 = s = GetTempStringSpace();                                   // this will last for the life of the command
        tp = strchr(p, '"');
        while(p != tp) *p1++ = *p++;
        p++;
     //   *(tp = strchr(p, '"')) = 0;                                 // temporarily remove the closing quote
     //   strcpy(s, p);                                               // save the string
        CtoM(s);                                                    // convert to a MMBasic string
     //   *tp = '"';                                                  // restore the closing quote
     //   p = tp + 1;                                                 // point to after it
        t = T_STR;
    }
    // if it is a numeric constant starting with the & character then get its base and convert
    else if(*p == '&') {
        char ts[17], *tsp;
        p++;
        switch(toupper(*p)) {
            case 'H':   i = 16; break;
            case 'O':   i = 8;  break;
            case 'B':   i = 2;  break;
            default:    i = 0;  error("Invalid type specification following &");
        }
        p++;
        tsp = ts;
        while(((*p >= '0' && *p <= '9') || (toupper(*p) >= 'A' && toupper(*p) <= 'F')) && (tsp - ts) < 16)
            *tsp++ = *p++;                                          // copy the string to a temporary place
        *tsp = 0;                                                   // terminate it
        f = (float)strtol(ts, &tsp, i);                             // and convert to an integer (stored as a float)
        t = T_NBR;
    }
    // is it an ordinary numeric constant?  get its value if yes
    // a leading + or - might have been converted to a token so we need to check for them also
    else if(isdigit(*p) || *p == '+' || (tokenfunction(*p) == op_subtract) || *p == '-' || (tokenfunction(*p) == op_add) || *p == '+' || *p == '.') {
        char ts[17], *tsp;
        if(tokenfunction(*p) == op_subtract) *p = '-';
        if(tokenfunction(*p) == op_add) *p = '+';
        tsp = ts;
        while(((*p >= '0' && *p <= '9') || toupper(*p) == 'E' || *p == '-' || *p == '+' || *p == '.') && (tsp - ts) < 16)
            *tsp++ = *p++;                                          // copy the string to a temporary place
        *tsp = 0;                                                   // terminate it
        f = (float)strtod(ts, &tsp);                                // and convert to a float
        t = T_NBR;
    }
    else
        error("Invalid syntax");

    skipspace(p);
    *fa = f;                                                        // save what we have
    *sa = s;
    *ta = t;

    // get the next operator, if there is not an operator set the operator to end of expression (E_END)
    if(tokentype(*p) & T_OPER)
        *oo = *p++ - C_BASETOKEN;
    else
        *oo = E_END;

    return p;
}






/********************************************************************************************************************************************
 Program memory mamagement
*********************************************************************************************************************************************/

// takes a program line (in the global tknbuf[]) and inserts it into the program
// memory starting at PMemory.  This will delete the program line if the incomming
// line is zero length.  If the line does not have a line number it is simply appended
// to the end of program memory.
// returns true if no error
void AddProgramLine(int append) {
    int nbr, i, length;
    char *p1, *p2;

    ProgramChanged = true;
    for(p1 = tknbuf + 3; !(p1[0]== 0 && p1[1] == 0); p1++) ;        // count the length of the line
    length = p1 - tknbuf + 1;                                       // the +1 includes the zero terminating char

    if(append) {
        // we only need to append to the program memory
        m_alloc(M_PROG, PSize + length + 4);                        // check enough memory, the 4 is a safty margin to ensure enough zeros at the end
        p1 = PMemory + PSize;                                       // point to the end of the program
        memmove(p1, tknbuf, length);                                // and add the new line
        PSize += length;
    }  else {
        // more complex - we are inserting a line with a line number
        // only used when a line is typed at the console
        nbr = (tknbuf[1] << 8) | tknbuf[2];                         // get the line number
        if(nbr < 1 || nbr > NOLINENBR) return;                      // make sure that the line number is valid
        if(nbr != NOLINENBR && tknbuf[3] == 0) length = 0;          // means that we are deleting a line

        p1 = PMemory; i = 0;
        // search for a matching or greater than line number
        while(1) {
            if(p1[0] == 0 && p1[1] == 0) {                          // if end of the program
                p1++;                                               // leave a zero byte between the old and new lines
                break;
            }
            if(*p1 == T_LINENBR) {
                i = (p1[1] << 8) | p1[2];                           // get the number
                if(i >= nbr && i != NOLINENBR) break;               // we are looking for a line greater or equals
                p1 += 3;
                continue;                                           // step over the line nbr
            }
            if(p1[0] == T_LABEL) {
                p1 += p1[1] + 2;
                continue;
            }
            p1++;
        }

        // found the spot to insert the code (p1), first check if we need to to delete an existing line
        // and if so, calculate the length of the line, then delete
        if(i == nbr && i != NOLINENBR) {
            for(p2 = p1 + 3; !(p2[0]== 0 && (p2[1] == T_LINENBR || p2[1] == 0)); p2++) ;
            p2++;                                                   // point to the next line's line number
            memmove(p1, p2, PSize - (p2 - PMemory));
            PSize -= (p2 - p1);
        }

        // insert the new line. if it has a line number we only insert if it is not empty
        if(length) {
            m_alloc(M_PROG, PSize + length + 4);                    // check enough memory, the 4 is a safty margin to ensure enough zeros at the end
            memmove(p1 + length, p1, PSize - (p1 - PMemory));       // move down the existing code to make space
            memmove(p1, tknbuf, length);                            // and insert the new line
            PSize += length;
        }
        StartEditPoint = NULL;
    }

    PMemory[PSize] = PMemory[PSize + 1] = PMemory[PSize + 2] = PMemory[PSize + 3] = 0;  // ensure that the last four are zero
    findlabel(NULL);                                                // flush the label cache
}



// search through program memory looking for a line number. Stops when it has a matching or larger number
// returns a pointer to the T_LINENBR token or a pointer to the two zero characters representing the end of the program
char *findline(int nbr, int mustfind) {
    char *p;
    int i;

    p = PMemory;
    while(1) {
        if(p[0] == 0 && p[1] == 0) {
            i = MAXLINENBR;
            break;
        }

        if(p[0] == T_LABEL) {
            p += p[1] + 2;
            continue;
        }

        if(p[0] == T_LINENBR) {
            i = (p[1] << 8) | p[2];
            if(i >= nbr && i != NOLINENBR) break;
            p += 3;
            continue;
        }
        p++;
    }
    if(mustfind && i != nbr)
        error("Invalid line number");
    return p;
}


#define LABEL_CACHE_SIZE    32
char *cache[LABEL_CACHE_SIZE];
char coffset[LABEL_CACHE_SIZE];


// search through program memory looking for a label.
// returns a pointer to the T_LINENBR token or throws an error if not found
char *findlabel(char *labelptr) {
    char *p, *lastp = PMemory + 1;
    int i;
    char label[MAXVARLEN + 1];

    // first, if we have a NULL argument it means that we should just flush the cache
    if(labelptr == NULL) {
        for(i = 1; i < LABEL_CACHE_SIZE; i++)
            cache[i] = NULL;
        return NULL;
    }

    // convert the label to the token format and load into label[]
    // this assumes that the first character has already been verified as a valid label character
    label[1] = *labelptr++;
    for(i = 2; ; i++) {
        if(!isnamechar(*labelptr)) break;                           // the end of the label
        if(i > MAXVARLEN ) error("Label is too long");              // too long, not a correctly formed label
        label[i] = *labelptr++;
    }
    label[0] = i - 1;                                               // the length byte

    // first scan the cache and return immediately if the label is found
    for(i = 0; i < LABEL_CACHE_SIZE && cache[i] != NULL; i++)
        if(mem_equal(cache[i], label, label[0] + 1))
            return cache[i] - coffset[i];

    // not found in the cache.  move the cache down so that we can insert the label when we find it
    for(i = 1; i < LABEL_CACHE_SIZE; i++) {
        cache[i] = cache[i - 1];
        coffset[i] = coffset[i - 1];
    }

    // now do the long search
    p = PMemory;
    while(1) {
        if(p[0] == 0 && p[1] == 0)                                  // end of the program
            error("Cannot find label");

        if(p[0] == T_LINENBR) {
            lastp = p;                                              // save in case this is the right line
            p += 3;                                                 // and step over the line number
            continue;
        }

        if(p[0] == T_LABEL) {
            p++;                                                    // point to the length of the label
            if(mem_equal(p, label, label[0] + 1)) {                 // compare the strings including the length byte
                cache[0] = p;                                       // got it!  Save the pointer in the cache
                coffset[0] = p - lastp;                             // and the offset to the beginning of the line
                return lastp;                                       // and return pointing to the beginning of the line
            }
            p += p[0] + 1;                                          // still looking! skip over the label
            continue;
        }

        p++;
    }
}



// returns true if 'line' is a valid line in the program
int IsValidLine(int nbr) {
    char *p;
    p = findline(nbr, false);
    if(p[0] == T_LINENBR) {
        if(((p[1] << 8) | p[2]) == nbr) return true;
    }
    return false;
}


// count the number of lines up to and including the line pointed to by the argument
// used for error reporting in programs that do not use line numbers
int CountLines(char *target) {
    char *p;
    int cnt, i;

    // Normally we search program memory but if the target is within a loaded library module we
    // set the search pointer to that module's start location.
    p = PMemory;
#if defined(MMFAMILY) || defined(DOS)
    for(i = 0; i < NbrModules; i++)
        if(target > ModuleTable[i] && target < ModuleTable[i] + *((int *)ModuleTable[i])) {
    	    p = ModuleTable[i] + FILENAME_LENGTH + 5;
    	    break;
	    }
#endif
    cnt = 0;

    while(1) {
        if(p[0] == 0 && p[1] == 0)                                  // end of the program
            return cnt;

        if(p[0] == T_LINENBR) {
            p += 3;                                                 // and step over the line number
            cnt++;
            if(p >= target) return cnt;
            continue;
        }

        if(p[0] == T_LABEL) {
            p += p[0] + 2;                                          // still looking! skip over the label
            continue;
        }

        if(p++ > target) return cnt;

    }
}



/********************************************************************************************************************************************
routines for storing and manipulating variables
********************************************************************************************************************************************/


// find or create a variable
// if autocreate is false this will throw an error if the variable is NOT found
// there are four types of variable:
//  - T_NOTYPE a free slot that was used but is now free for reuse
//  - T_STR string variable (created if the last byte of the name is a $ char)
//  - T_NBR holds a float (created when the above criteria do not apply)
// if it is type T_NBR the value is held in the variable slot otherwise a block of memory of
// MAXSTRLEN size (or size determined by the LENGTH keyword) will be malloc'ed and the pointer stored in the variable slot.
void *findvar(char *p, int action) {
    char name[MAXVARLEN + 1];
//    char arg[STRINGSIZE];
    int i, j, size, ifree, nbr, vtype, vindex, namelen, tmp;
    char *s, *x;
    void *mptr;
    int dim[MAXDIM], dnbr;

    TestStackOverflow();                                                // prepare to test if we have overflowed the PIC32's stack

    vtype = T_NBR;
    dnbr = 0;

    // first zero the array used for holding the dimension values
    for(i = 0; i < MAXDIM; i++) dim[i] = 0;
    ifree = varcnt;

    // check the first char for a legal variable name
    skipspace(p);
    if(!isnamestart(*p)) error("Variable not found");

    // copy the variable name into name
    s = name; namelen = 0;
    do {
        *s++ = toupper(*p++);
        if(namelen++ > MAXVARLEN) error("Variable name too long");
    } while(isnamechar(*p));

    // check the terminating char.  If it is $ set the type and copy to name
    if(*p == '$') {
        vtype = T_STR;
        *s++ = *p++;
        if(namelen++  > MAXVARLEN) error("Variable name too long");
    }

    // check if this is an array
    if(*p == '(') {
        // this is an array, so we first copy the opening bracket into name
        *s++ = *p;
        if(namelen++  > MAXVARLEN) error("Variable name too long");
        {   // start a new block - getargs macro must be the first executable stmt in a block
            // split the argument into individual elements
            // find the value of each dimension and store in dims[]
            // the bracket in "(," is a signal to getargs that the list is in brackets
            getargs(&p, MAXDIM * 2, "(,");
            if((argc & 0x01) == 0) error("Invalid array dimension");
            dnbr = argc/2 + 1;
            if(dnbr >= MAXDIM) error("Too many dimensions");
            for(i = 0; i < argc; i += 2) {
                dim[i/2] = getinteger(argv[i]);
                if(dim[i/2] < OptionBase) error("Invalid array dimension");
            }
        }
    }

    // we now have the variable name and, if it is an array, the parameters
    // search the table looking for a match
    for(tmp = -1, i = 0; i < varcnt; i++) {
        if(vartbl[i].type == T_NOTYPE)
            ifree = i;
        else {
            if(*name != *vartbl[i].name) continue;                  // preliminary quick check
            s = name;  x = vartbl[i].name; j = namelen;
            while(j > 0 && *s == *x) {                              // compare each letter
                j--; s++; x++;
            }
            if(j == 0 && (*x == 0 || namelen == MAXVARLEN)) {       // found a matching name
                if(vartbl[i].level == 0)                            // if it is a global
                    if(LocalIndex == 0)                             // if we are NOT in a subroutine
                        break;                                      // exit with the index
                    else
                        tmp = i;                                    // otherwise just remember the index
                else                                                // else we are in a subroutine or function
                    if(vartbl[i].level == LocalIndex)               // and if the level match
                        break;                                      // just exit with the index
            }
        }
    }

    if(action & V_LOCAL) {
        if(i < varcnt) error("Variable already Local");
    } else {
        if(i >= varcnt && tmp >= 0) i = tmp;                        // use the global if it was found and a local was not
    }

    // if we found an existing and matching variable
    // set the global VarIndex indicating the index in the table
    if(i < varcnt && *vartbl[i].name != 0) {
        VarIndex = vindex = i;

        // if it is not an array this is easy, just calculate and return a pointer to the value
        if(vartbl[vindex].dims[0] == 0) {
            if(vartbl[vindex].type & (T_PTR | T_STR))
                return vartbl[vindex].val.s;                      // if it is a string or pointer just return the pointer to the data
            else
                return &(vartbl[vindex].val.f);                   // must be a straight number, point to its value
         }

        // if we reached this point it must be a reference to an existing array
        // check that we are not using DIM and that all parameters are within the dimensions
        if(vtype & T_PTR) error("Invalid use of an array");
        if(action & V_DIM_ARRAY) error("Cannot re dimension array");
        for(i = 0; i < MAXDIM && vartbl[vindex].dims[i] != 0; i++);
        if(i != dnbr) error("Number of dimensions");
        for(i = 0; i < dnbr; i++)
            if(dim[i] > vartbl[vindex].dims[i] || dim[i] < OptionBase)
                error("Array index out of bounds");

        // then calculate the index into the array.  Bug fix by Gerard Sexton.
        nbr = dim[0] - OptionBase;
        j = 1;
        for(i = 1; i < dnbr; i++) {
            j *= (vartbl[vindex].dims[i - 1] + 1 - OptionBase);
            nbr += (dim[i] - OptionBase) * j;
        }

        // finally return a pointer to the value
        if(vtype == T_NBR)
            return vartbl[vindex].val.s + (nbr * sizeof(float));
        else {
            return vartbl[vindex].val.s + (nbr * (vartbl[vindex].size + 1));
        }    
    }

    // we reached this point if no existing variable has been found
    if(action & V_NOFIND_ERR) error("Cannot find variable");
    if(action & V_NOFIND_NULL) return NULL;

    // set a default string size
    size = MAXSTRLEN;

    // if it is an array we must be dimensioning it
    // if it is a string array we skip over the dimension values and look for the LENGTH keyword
    // and if found find the string size and change the vartbl entry
    if(dnbr) {
        if(!(action & V_DIM_ARRAY)) error("Array must be dimensioned first");
        if(vtype == T_STR) {
            i = 0;
            do {
                if(*p == 0) error("Invalid Syntax");
                if(*p == '(') i++;
                if(*p == ')') i--;
                p++;
            } while(i);
            skipspace(p);
            if((s = checkstring(p, "LENGTH")) != NULL) {
                size = getinteger(s);
                if(size < 1 || size > MAXSTRLEN) error("Invalid string size");
            } else
                if(!(*p == ',' || *p == 0)) error("Unexpected text");
        }
    }


    // at this point we need to create the variable
    // as a result of the previous search ifree is the index to the entry that we should use

     // if we are adding to the top, increment the number of vars and inform the memory manager
    if(ifree == varcnt) {
        varcnt++;
        m_alloc(M_VAR, varcnt * sizeof(struct s_vartbl));
    }
    VarIndex = vindex = ifree;

    // initialise it: save the name, set the initial value to zero and set the type
    s = name;  x = vartbl[ifree].name; j = namelen;
    while(j--) *x++ = *s++;
    if(namelen < MAXVARLEN) *x = 0;
    vartbl[ifree].type = vtype;
    if(action & V_LOCAL)
        vartbl[ifree].level = LocalIndex;
    else
        vartbl[ifree].level = 0;
    for(j = 0; j < MAXDIM; j++) vartbl[ifree].dims[j] = 0;

    // the easy request is for is a non array numeric variable, so just initialise to
    // zero and return the pointer
    //if(dim[0] == 0 && vtype == T_NBR) {
    if(vtype == T_NBR && dnbr == 0) {
        vartbl[ifree].val.f = 0;
        return &(vartbl[ifree].val.f);
    }

    // if this is an array copy the array dimensions and calculate the overall size
    // for a non array string this will leave nbr = 1 which is just what we want
    for(nbr = 1, i = 0; i < dnbr; i++) {
        if(dim[i] <= OptionBase) error("Invalid array dimension");
        vartbl[vindex].dims[i] = dim[i];
        nbr *= (dim[i] + 1 - OptionBase);
    }

    // we now have a string, an array of strings or an array of numbers
    // all need some memory to be allocated (note: getmemory() zeros the memory)

    // First, set the important characteristics of the variable to indicate that the
    // variable is not allocated.  Thus, if getmemory() fails with "not enough memory",
    // the variable will remain not allocated
    vartbl[ifree].val.s = NULL;
    vartbl[ifree].type = T_NOTYPE;
    i = *vartbl[ifree].name;   *vartbl[ifree].name = 0;
	j = vartbl[ifree].dims[0]; vartbl[ifree].dims[0] = 0;


	// Now, grab the memory
    if(vtype == T_NBR)
        mptr = getmemory(nbr * sizeof(float));
    else
        mptr = getmemory(nbr * (size + 1));
        
    // If we reached here the memory request was successful, so restore the details of
    // the variable that were saved previously and set the variables pointer to the
    // allocated memory
    vartbl[ifree].type = vtype;
    *vartbl[ifree].name = i;
    vartbl[ifree].dims[0] = j;
    vartbl[ifree].size = size;
    vartbl[ifree].val.s = mptr;
    return mptr;
}




/********************************************************************************************************************************************
 utility routines
 these routines form a library of functions that any command or function can use when dealing with its arguments
 by centralising these routines it is hoped that bugs can be more easily found and corrected (unlike bwBasic !)
*********************************************************************************************************************************************/

// take a line of basic code and split it into arguments
// this function should always be called via the macro getargs
//
// a new argument is created by any of the chars in the string delim (not in brackets or quotes)
// with this function commands have much less work to do to evaluate the arguments
//
// The arguments are:
//   pointer to a pointer which points to the string to be broken into arguments.
//   the maximum number of arguments that are expected.  an error will be thrown if more than this are found.
//   buffer where the returned strings are to be stored
//   pointer to an array of strings that will contain (after the function has returned) the values of each argument
//   pointer to an integer that will contain (after the function has returned) the number of arguments found
//   pointer to a string that contains the characters to be used in spliting up the line.  If the first char of that
//       string is an opening bracket '(' this function will expect the arg list to be enclosed in brackets.
void makeargs(char **p, int maxargs, char *argbuf, char *argv[], int *argc, char *delim) {
    char *op;
    int inarg, expect_cmd, expect_bracket, then_tkn, else_tkn;
    char *tp;

    TestStackOverflow();                                            // throw an error if we have overflowed the PIC32's stack

    tp = *p;
    op = argbuf;
    *argc = 0;
    inarg = false;
    expect_cmd = false;
    expect_bracket = false;
    then_tkn = tokenvalue[TKN_THEN];
    else_tkn = tokenvalue[TKN_ELSE];

    // skip leading spaces
    while(*tp == ' ') tp++;

    // check if we are processing a list enclosed in brackets and if so
    //  - skip the opening bracket
    //  - flag that a closing bracket should be found
    if(*delim == '(') {
        if(*tp != '(')
            error("Invalid syntax");
        expect_bracket = true;
        delim++;
        tp++;
    }

    // the main processing loop
    while(*tp) {

        if(expect_bracket == true && *tp == ')') break;

        // comment char causes the rest of the line to be skipped
        if(*tp == '\'') {
            break;
        }

        // the special characters that cause the line to be split up are in the string delim
        // any other chars form part of the one argument
        if(strchr(delim, *tp) != NULL && !expect_cmd) {
            if(*tp == then_tkn || *tp == else_tkn) expect_cmd = true;
            if(inarg) {                                             // if we have been processing an argument
                while(op > argbuf && *(op - 1) == ' ') op--;        // trim trailing spaces
                *op++ = 0;                                          // terminate it
            } else if(*argc) {                                      // otherwise we have two delimiters in a row (except for the first argument)
                argv[(*argc)++] = op;                               // create a null argument to go between the two delimiters
                *op++ = 0;                                          // and terminate it
            }

            inarg = false;
            if(*argc >= maxargs) error("Invalid syntax");
            argv[(*argc)++] = op;                                   // save the pointer for this delimiter
            *op++ = *tp++;                                          // copy the token or char (always one)
            *op++ = 0;                                              // terminate it
            continue;
        }

        // check if we have a THEN or ELSE token and if so flag that a command should be next
        if(*tp == then_tkn || *tp == else_tkn) expect_cmd = true;


        // remove all spaces (outside of quoted text and bracketed text)
        if(!inarg && *tp == ' ') {
            tp++;
            continue;
        }

        // not a special char so we must start a new argument
        if(!inarg) {
            if(*argc >= maxargs) error("Invalid syntax");
            argv[(*argc)++] = op;                                   // save the pointer for this arg
            inarg = true;
        }

        // if an opening bracket '(' copy everything until we hit the matching closing bracket
        // this includes special characters such as , and ; and keeps track of any nested brackets
        if(*tp == '(' || ((tokentype(*tp) & T_FUN) && !expect_cmd)) {
            int x;
            x = (getclosebracket(tp + 1) - tp) + 1;
            memcpy(op, tp, x);
            op += x; tp += x;
            continue;
        }

        // if quote mark (") copy everything until the closing quote
        // this includes special characters such as , and ;
        // the tokenise() function will have ensured that the closing quote is always there
        if(*tp == '"') {
            do {
                *op++ = *tp++;
                if(*tp == 0) error("Invalid syntax");
            } while(*tp != '"');
            *op++ = *tp++;
            continue;
        }

        // anything else is just copied into the argument
        *op++ = *tp++;

        expect_cmd = false;
    }
    if(expect_bracket && *tp != ')') error("Invalid syntax");
    while(op - 1 > argbuf && *(op-1) == ' ') --op;                  // trim any trailing spaces on the last argument
    *op = 0;                                                        // terminate the last argument
}


// throw an error
// this uses longjump to skip back to the command input and cleanup the stack
void error(char *msg) {
    char *p, *tp;
    int i;
    if(MMCharPos > 1) MMPrintString("\r\n");
#if defined(MMFAMILY)
    if(CurrentLinePtr) StopAudio();
    SetFont((GetFlashOption(&FontOption) == CONFIG_FONT1) ? 0:1, 1, 0); // set a reasonable default font
    #if defined(COLOUR)
        CurrentFgColour = ConsoleFgColour;                          // reset the text colours
        CurrentBgColour = ConsoleBgColour;
        CLine = NULL;
    #endif
#endif
    if(CurrentLinePtr) {
        // Normally we search program memory but if the target is within a loaded library module we
        // set the search pointer to that module's start location.
        tp = p = PMemory;
#if defined(MMFAMILY) || defined(DOS)
        for(i = 0; i < NbrModules; i++)
            if(CurrentLinePtr > ModuleTable[i] && CurrentLinePtr < ModuleTable[i] + *((int *)ModuleTable[i])) {
                MMPrintString("In library "); MMPrintString(ModuleTable[i] + 4); MMPrintString("\r\n");
        	    tp = p = ModuleTable[i] + FILENAME_LENGTH + 5;
        	    break;
    	    }
#endif
        if(*CurrentLinePtr != T_LINENBR) {
            // normally CurrentLinePtr points to a T_LINENBR token but in this case it does not
            // so we have to search for the start of the line and set CurrentLinePtr to that
        	while(1) {
        		while(*p) p++;										// look for the zero marking the start of an element
        		if(p >= CurrentLinePtr || p[1] == 0) {              // the previous line was the one that we wanted
            		CurrentLinePtr = tp;
            		break;
                }
        		if(p[1] == T_LINENBR) {
            		tp = ++p;                                       // save because it might be the line we want
            		p += 2;                                         // skip over the line number
        		}
        		p++;                                                // step over the zero marking the start of the element
        		skipspace(p);
        		if(p[0] == T_LABEL) p += p[1] + 2;					// skip over the label
            }
        }

#if defined(MMFAMILY) || defined(DOS)
        // if the error was not in a library module set the editing points for when the editor is invoked
        if(i == NbrModules) {
            StartEditPoint = CurrentLinePtr;
            StartEditChar = 0;
        }
#endif

       // we now have CurrentLinePtr pointing to the start of the line
       llist(tknbuf, CurrentLinePtr);
        p = tknbuf; skipspace(p);
        sprintf(inpbuf, "%s[%d] %1.250s\r\nError%s%s\r\n", MMCharPos > 1 ? "\r\n" : "", CountLines(CurrentLinePtr), p, *msg?": ":"", msg);
    }
    else
        sprintf(inpbuf, "%sError%s%s\r\n", MMCharPos> 1 ? "\r\n" : "", *msg?": ":"", msg);
    MMPrintString(inpbuf);
    longjmp(mark, 1);
}


/**********************************************************************************************
Various routines to clear memory or the interpreter's state
**********************************************************************************************/


// clear (or delete) variables
// if level is not zero it will only delete local variables at that level
// if level is zero to will delete all variables and reset global settings
void ClearVars(int level) {
    int i;

    // first step through the variable table and clear any heap allocated to a variable
    for(i = 0; i < varcnt; i++) {
        if(level == 0 || level == vartbl[i].level) {                // if this is for deletion
            if(((vartbl[i].type & T_STR) || vartbl[i].dims[0] != 0) && !(vartbl[i].type & T_PTR)) {
                FreeHeap(vartbl[i].val.s);                          // free any memory (if allocated)
            }
        	vartbl[i].type = T_NOTYPE;                              // empty slot
        	*vartbl[i].name = 0;                                    // safety precaution
        	vartbl[i].dims[0] = 0;                                  // and again
        	if(i == varcnt - 1) { i--; varcnt--; }
        }
    }
    if(level != 0) return;

    TempStringClearStart = 0;                                       // signal that all space is to be cleared
    ClearTempSpace();                                               // clear temp string space

    // we can now delete all variables by zeroing the counters
    varcnt = 0;
    OptionBase = 0;
    DimUsed = false;
}


// clear all stack pointers (eg, FOR/NEXT stack, DO/LOOP stack, GOSUB stack, etc)
// this is done at the command prompt or at any break
void ClearStack(void) {
    NextData = 0;
    forindex = 0;
    doindex = 0;
    gosubindex = 0;
    LocalIndex = 0;
    InterruptReturn = NULL;
}


// clear the runtime (eg, variables, external I/O, fonts, etc) includes ClearStack()
// this is done before running a program
void ClearRuntime(void) {
    int i;
    ClearStack();
    ClearVars(0);
    CloseAllFiles();
    findlabel(NULL);                                                // clear the label cache
    for(i = NBRFONTS_IN_FLASH; i < NBRFONTS - 1; i++) UnloadFont(i);
	ClearExternalIO();                                              // this MUST come before InitHeap() as PlayMOD might be running or sprites may be loaded
    MMerrno = 0;
	#if defined(MMFAMILY) || defined(DOS)
	    NbrModules = 0;
    #endif
    InitHeap();
    #if defined(COLOUR)
        CurrentFgColour = DefaultFgColour;                          // reset the text colours
        CurrentBgColour = DefaultBgColour;
    #endif
    m_alloc(M_VAR, 0);
    varcnt = 0;
    OptionErrorAbort = true;
    ContinuePoint = NULL;
    for(i = 0;  i < MAXSUBFUN; i++)  subfun[i] = NULL;

}



// clear everything including program memory (includes ClearStack() and ClearRuntime())
// this is used before loading a program
void ClearProgram(void) {
    m_alloc(M_PROG, 256);                                           // init the variables for program memory
    ClearRuntime();
    PMemory[0] = PMemory[1] = PMemory[3] = PMemory[4] = 0;
    PSize = 1;
    autoOn = 0; autoNext = 10; autoIncr = 10;                       // use by the AUTO command
    StartEditPoint = NULL;
    StartEditChar = 0;
    ProgramChanged = false;
    TraceOn = false;
}




// round a float to an integer
int MMround(float x) {
    if(x < INT_MIN-0.5 || x > INT_MAX+0.5)
        error("Number too large for an integer");
    return (x >= 0 ? (int)(x + 0.5) : (int)(x - 0.5)) ;
}



// make a string uppercase
void makeupper(char *p) {
    while(*p) {
        *p = toupper(*p);
        p++;
    }
}


// find the value of a command token given its name
int GetCommandValue(char *n) {
    int i;
    for(i = 0; i < CommandTableSize - 1; i++)
        if(str_equal(n, commandtbl[i].name))
            return i;
    error("Internal fault (sorry)");
    return 0;
}



// find the value of a token given its name
int GetTokenValue(char *n) {
    int i;
    for(i = 0; i < TokenTableSize - 1; i++)
        if(str_equal(n, tokentbl[i].name))
            return i + C_BASETOKEN;
    error("Internal fault (sorry)");
    return 0;
}



// skip to the end of a variable
char *skipvar(char *p, int noerror) {
    char *tp;
    int i;

    tp = p;
    // check the first char for a legal variable name
    skipspace(p);
    if(!isnamestart(*p)) return tp;

    do {
        p++;
    } while(isnamechar(*p));

    // check the terminating char.
    if(*p == '$') p++;

    if(p - tp > MAXVARLEN) {
        if(noerror) return p;
        error("Variable name too long");
    }

    if(*p == '(') {
        // this is an array

        p++;
        if(p - tp > MAXVARLEN) {
            if(noerror) return p;
            error("Variable name too long");
        }

        // step over the parameters keeping track of nested brackets
        i = 1;
        while(1) {
            if(*p == 0) {
                if(noerror) return p;
                error("Expected closing bracket");
            }
            if(*p == ')') if(--i == 0) break;
            if(*p == '(' || (tokentype(*p) & T_FUN)) i++;
            p++;
        }
        p++;        // step over the closing bracket
    }
    return p;
}


// return the type of a variable (string or numeric)
// p must point to a valid variable
int vartype(char *p) {
    skipspace(p);
    if(!isnamestart(*p)) return -1;
    p++;
    while(isnamechar(*p)) p++;
    if(*p == '$')
        return T_STR;
    else
        return T_NBR;
}


// scans text looking for the matching closing bracket
// it will handle nested brackets and functions
// it expects to be called pointing at the opening bracket or function
char *getclosebracket(char *p) {
    int i = 1;
    int inquote = false;

    do {
        if(*p == 0) error("Expected closing bracket");
        if(*p == '\"') inquote = !inquote;
        if(!inquote) {
            if(*p == ')') i--;
            if(*p == '(' || (tokentype(*p) & T_FUN)) i++;
        }
        p++;
    } while(i);
    return p - 1;
}


// check that there is no excess text following an element
// will skip spaces and abort if a zero char is not found
void checkend(char *p) {
    skipspace(p);
    if(*p == '\'') return;
    if(*p)
        error("Unexpected text");
}


// check if the next text in an element (a basic statement) corresponds to an alpha string
// leading whitespace is skipped and the string must be terminated with a non alpha character
// returns a pointer to the end of the string if found or NULL is not
char *checkstring(char *p, char *tkn) {
    while(*p == ' ') p++;                                           // skip leading spaces
    while(*tkn && (*tkn == toupper(*p))) { tkn++; p++; }            // compare the strings
    if(*tkn == 0 && !isalpha(*p)) return p;                         // return the string if successful
    return NULL;                                                    // or NULL is not
}



// count the length of a program line excluding the terminating zero byte
// the pointer p must be pointing to the T_LINENBR token at the start of the line
int GetLineLength(char *p) {
    char *start;
    start = p;
    p += 3;                                                         // step over the line number
    while(!(p[0] == 0 && (p[1] == 0 || p[1] == T_LINENBR))) p++;
    return (p - start);
}


// insert a string into the start of the lastcmd buffer.
// the buffer is a sequence of strings separated by a zero byte.
// using the up arrow usere can call up the last few commands executed.
void InsertLastcmd(char *s) {
int i, slen;
    if(strcmp(lastcmd, s) == 0) return;                             // don't duplicate
    slen = strlen(s);
    if(slen < 1 || slen > MAXSTRLEN) return;
    slen++;
    for(i = STRINGSIZE - 1; i >=  slen ; i--)
        lastcmd[i] = lastcmd[i - slen];                             // shift the contents of the buffer up
    strcpy(lastcmd, s);                                             // and insert the new string in the beginning
    for(i = MAXSTRLEN; lastcmd[i]; i--) lastcmd[i] = 0;             // zero the end of the buffer
}



/********************************************************************************************************************************************
A couple of I/O routines that do not belong anywhere else
*********************************************************************************************************************************************/


// print a string to the console interfaces
void MMPrintString(char* s) {
	while(*s) {
		MMputchar(*s);
		s++;
	}
}


// output a string to a file
// the string must be a MMBasic string
void MMfputs(char *p, int filenbr) {
	int i;
	i = *p++;
	while(i--) MMfputc(*p++, filenbr);
}





/********************************************************************************************************************************************
 string routines
 these routines form a library of functions for manipulating MMBasic strings.  These strings differ from ordinary C strings in that the length
 of the string is stored in the first byte and the string is NOT terminated with a zero valued byte.  This type of string can store the full
 range of binary values (0x00 to 0xff) in each character.
*********************************************************************************************************************************************/

// convert a MMBasic string to a C style string
// if the MMstr contains a null byte that byte is skipped and not copied
char *MtoC(char *p) {
    int i;
    char *p1, *p2;
    i = *p;
    p1 = p + 1; p2 = p;
    while(i) {
        if(p1) *p2++ = *p1;
        p1++;
        i--;
    }
    *p2 = 0;
    return p;
}


// convert a c style string to a MMBasic string
char *CtoM(char *p) {
    int len, i;
    char *p1, *p2;
    len = i = strlen(p);
    if(len > MAXSTRLEN) error("String is too long");
    p1 = p + len; p2 = p + len - 1;
    while(i--) *p1-- = *p2--;
    *p = len;
    return p;
}


// copy a MMBasic string to a new location
void Mstrcpy(char *dest, char *src) {
    int i;
    i = *src + 1;
    while(i--) *dest++ = *src++;
}



// concatenate two MMBasic strings
void Mstrcat(char *dest, char *src) {
    int i;
    i = *src;
    *dest += i;
    dest += *dest + 1 - i; src++;
    while(i--) *dest++ = *src++;
}



// evaluate an expression to get a string using the C style for a string
// as against the MMBasic style returned by getstring()
char *getCstring(char *p) {
    char *tp;
    tp = GetTempStringSpace();                                      // this will last for the life of the command
    Mstrcpy(tp, getstring(p));                                      // get the string and save in a temp place
    MtoC(tp);                                                       // convert to a C style string
    return tp;
}



// compare two MMBasic style strings
// returns 1 if s1 > s2  or  0 if s1 = s2  or  -1 if s1 < s2
int Mstrcmp(char *s1, char *s2) {
    register int i;
    register char *p1, *p2;

    // get the smaller length
    i = *s1 < *s2 ? *s1 : *s2;

    // skip the length byte and point to the char array
    p1 = s1 + 1; p2 = s2 + 1;

    // compare each char
    while(i--) {
        if(*p1 > *p2) return 1;
        if(*p1 < *p2) return -1;
        p1++; p2++;
    }
    // up to this point the strings matched - make the decision based on which one is shorter
    if(*s1 > *s2) return 1;
    if(*s1 < *s2) return -1;
    return 0;
}



////////////////////////////////////////////////////////////////////////////////////////////////////
// these library functions went missing in the PIC32 C compiler ver 1.12 and later
////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 * strncasecmp.c --
 *
 *  Source code for the "strncasecmp" library routine.
 *
 * Copyright (c) 1988-1993 The Regents of the University of California.
 * Copyright (c) 1995-1996 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: strncasecmp.c,v 1.3 2007/04/16 13:36:34 dkf Exp $
 */

/*
 * This array is designed for mapping upper and lower case letter together for
 * a case independent comparison. The mappings are based upon ASCII character
 * sequences.
 */

const static char charmap[] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
    0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
    0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
    0x40, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
    0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
    0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,
    0x78, 0x79, 0x7a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f,
    0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
    0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
    0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,
    0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f,
    0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
    0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
    0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
    0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
    0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7,
    0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
    0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
    0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
    0xc0, 0xe1, 0xe2, 0xe3, 0xe4, 0xc5, 0xe6, 0xe7,
    0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
    0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7,
    0xf8, 0xf9, 0xfa, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
    0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7,
    0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
    0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7,
    0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff,
};


/*
 *----------------------------------------------------------------------
 *
 * strncasecmp --
 *
 *  Compares two strings, ignoring case differences.
 *
 * Results:
 *  Compares up to length chars of s1 and s2, returning -1, 0, or 1 if s1
 *  is lexicographically less than, equal to, or greater than s2 over
 *  those characters.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */


int
strncasecmp(
    const char *s1,         /* First string. */
    const char *s2,         /* Second string. */
    size_t length)      /* Maximum number of characters to compare
                         * (stop earlier if the end of either string
                         * is reached). */
{
    register unsigned char u1, u2;

    for (; length != 0; length--, s1++, s2++) {
        u1 = (unsigned char) *s1;
        u2 = (unsigned char) *s2;
        if (charmap[u1] != charmap[u2]) {
            return charmap[u1] - charmap[u2];
        }
        if (u1 == '\0') {
            return 0;
        }
    }
    return 0;
}



// Compare two strings, ignoring case differences.
// Returns true if the strings are equal (ignoring case) otherwise returns false.
inline int str_equal(const char *s1, const char *s2) {
    if(charmap[*(unsigned char *)s1] != charmap[*(unsigned char *)s2]) return 0;
    for ( ; ; ) {
        if(*s2 == '\0') return 1;
        s1++; s2++;
        if(charmap[*(unsigned char *)s1] != charmap[*(unsigned char *)s2]) return 0;
    }
}


// Compare two areas of memory, ignoring case differences.
// Returns true if they are equal (ignoring case) otherwise returns false.
int mem_equal(char *s1, char *s2, int i) {
    if(charmap[*(unsigned char *)s1] != charmap[*(unsigned char *)s2]) return 0;
    while (--i) {
        if(charmap[*(unsigned char *)++s1] != charmap[*(unsigned char *)++s2])
            return 0;
    }
    return 1;
}
