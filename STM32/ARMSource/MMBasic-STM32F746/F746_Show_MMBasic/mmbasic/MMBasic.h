/***********************************************************************************************************************
MMBasic.h

Include file that contains the globals and defines for MMBasic.c in MMBasic.

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
//#ifndef float
//#define float double
//#endif

#include <stdlib.h>
#include <setjmp.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <math.h>

#if defined(MAXIMITE) || defined(UBW32) || defined(DUINOMITE) || defined(COLOUR)
  #define MMFAMILY
#endif

#include "Configuration.h"                          // memory configuration defines for the particular hardware this is running on

//#define REPORT_STACK_USAGE                        // define for stack usage report (TEST_STACK_OVERFLOW must also be defined)

// types used to define an item of data.  Used in tokens, variables and arguments to functions
#define T_NOTYPE        0                           // type not set or discovered
#define T_NBR       0x01                            // number (or float) type
#define T_STR       0x02                            // string type
#define T_PTR       0x04                            // the variable points to another variable's data
#define T_RES       0x08                            // reserved - may be used in the future for 32 bit integer type

// types of tokens.  These are or'ed with the data types above to fully define a token
#define T_INV       0                               // an invalid token
#define T_NA        0                               // an invalid token
#define T_CMD       0x10                            // a command
#define T_OPER      0x20                            // an operator
#define T_FUN       0x40                            // a function (also used for a function that can operate as a command)
#define T_FNA       0x80                            // a function that has no arguments

#define C_BASETOKEN 0x80                            // the base of the token numbers

#define T_CMDEND    0                               // flags used in the program lines
#define T_LINENBR   1
#define T_LABEL     2

#define E_END       255                             // dummy last operator in an expression

// these constants are used in the second argument of the findvar() function, they should be or'd together
#define V_FIND              0                       // a straight forward find, if the variable is not found it is created and set to zero
#define V_NOFIND_ERR        0x00001                 // throw an error if not found
#define V_NOFIND_NULL       0x00002                 // return a null pointer if not found
#define V_DIM_ARRAY         0x00004                 // dimension an array
#define V_LOCAL             0x00008                 // create a local variable


#if !defined(BOOL_ALREADY_DEFINED)
    #define BOOL_ALREADY_DEFINED
    typedef enum _BOOL { FALSE = 0, TRUE } BOOL;    // Undefined size
#endif

#ifndef true
    #define true        1
#endif

#ifndef false
    #define false       0
#endif

#define MAXLINENBR          65001                                   // maximim acceptable line number
#define NOLINENBR           (MAXLINENBR + 1)                        // dummy line number to indicate that a line number has not been used

// skip whitespace
// finishes with x pointing to the next non space char
#define skipspace(x)    while(*x == ' ') x++

// skip to the next element
// finishes pointing to the zero char that preceeds an element
#define skipelement(x)  while(*x) x++

// skip to the next line
// skips text and and element separators until it is pointing to the zero char marking the start of a new line.
// the next byte will be either the line number token or zero char if end of program
#define skipline(x)     while(!(x[-1] == 0 && (x[0] == T_LINENBR || x[0] == 0)))x++

// find a token
// finishes pointing to the token or zero char if not found in the line
#define findtoken(x)    while(*x != (tkn) && *x)x++

#define isnamestart(c)  (isalpha(c) || c == '_')                    // true if valid atart of a variable name
#define isnamechar(c)   (isalnum(c) || c == '_' || c == '.')        // true if valid part of a variable name
//#define isnameend(c)    (isalnum(c) || c == '$' || c == '(')        // true if valid end of a variable name

#define tokentype(i)    ((i >= C_BASETOKEN && i < TokenTableSize - 1 + C_BASETOKEN) ? (tokentbl[i - C_BASETOKEN].type) : 0)             // get the type of a token
#define tokenfunction(i)((i >= C_BASETOKEN && i < TokenTableSize - 1 + C_BASETOKEN) ? (tokentbl[i - C_BASETOKEN].fptr) : (tokentbl[0].fptr))    // get the function pointer  of a token
#define tokenname(i)    ((i >= C_BASETOKEN && i < TokenTableSize - 1 + C_BASETOKEN) ? (tokentbl[i - C_BASETOKEN].name) : "")            // get the name of a token

#define commandtype(i)  ((i >= C_BASETOKEN && i < CommandTableSize - 1 + C_BASETOKEN) ? (commandtbl[i - C_BASETOKEN].type) : 0)             // get the type of a token
#define commandfunction(i)((i >= C_BASETOKEN && i < CommandTableSize - 1 + C_BASETOKEN) ? (commandtbl[i - C_BASETOKEN].fptr) : (commandtbl[0].fptr))    // get the function pointer  of a token
#define commandname(i)  ((i >= C_BASETOKEN && i < CommandTableSize - 1 + C_BASETOKEN) ? (commandtbl[i - C_BASETOKEN].name) : "")        // get the name of a command

// this macro will allocate temporary memory space and build an argument table in it
// x = pointer to the basic text to be split up (char *)
// y = maximum number of args (will throw an error if exceeded) (int)
// s = a string of characters to be used in detecting where to split the text (char *)
#define getargs(x, y, s) char argbuf[STRINGSIZE + STRINGSIZE/2]; char *argv[y]; int argc; makeargs(x, y, argbuf, argv, &argc, s)

extern int CommandTableSize, TokenTableSize;
extern int TraceOn;

extern jmp_buf mark;                            // longjump to recover from an error

extern char *PMemory;                           // program memory
extern int PSize;                               // size of the program in program memory
extern int ProgMemSize;

extern int NextData;                            // used to track the next item to read in DATA & READ stmts
extern char *CurrentLinePtr;                    // pointer to the current line being executed
extern char *ContinuePoint;                     // Where to continue from if using the continue statement

extern char inpbuf[];                           // used to store user keystrokes until we have a line
extern char tknbuf[];                           // used to store the tokenised representation of the users input line
extern char lastcmd[];                          // used to store the command history in case the user uses the up arrow at the command prompt

extern float farg1, farg2, fret;                // Global floating point variables used by operators
extern char *sarg1, *sarg2, *sret;              // Global string pointers used by operators
extern int targ;                                // Global type of argument (string or float) returned by an operator

extern int cmdtoken;                            // Token number of the command
extern char *cmdline;                           // Command line terminated with a zero char and trimmed of spaces
extern char *nextstmt;                          // Pointer to the next statement to be executed.
extern char *ep;                                // Pointer to the argument to a function

extern char *subfun[];                          // Table of subroutines and functions built when the program starts running

struct s_tokentbl {                             // structure of the token table
    char *name;                                 // the string (eg, PRINT, FOR, ASC(, etc)
    char type;                                  // the type returned (T_NBR, T_STR)
    char precedence;                            // precedence used by operators only.  operators with equal precedence are processed left to right.
    void (*fptr)(void);                         // pointer to the function that will interpret that token
};
extern const struct s_tokentbl tokentbl[];
extern const struct s_tokentbl commandtbl[];

#define TKN_THEN            0
#define TKN_ELSE            1
#define TKN_GOTO            2
#define TKN_EQUAL           3
#define TKN_TO              4
#define TKN_STEP            5
#define TKN_WHILE           6
#define TKN_UNTIL           7
#define TKN_GOSUB           8
#define TKN_AS              9

#define TOKEN_LOOKUP_SIZE   10
extern char tokenvalue[TOKEN_LOOKUP_SIZE];

struct s_vartbl {                               // structure of the variable table
    char name[MAXVARLEN];                       // variable's name
    char type;                                  // its type (T_NUM or T_STR)
    char level;                                 // its subroutine or function level (used to track local variables)
    short int dims[MAXDIM];                     // the dimensions. it is an array if the first dimension is NOT zero
    unsigned char size;                         // the number of chars to allocate for each element in a string array
    union u_val {
        float f;                                // the value if it is a float
        float *fa;                              // pointer to the allocated memory if it is an array
        char *s;                                // pointer to the allocated memory (always STRINGSIZE bytes) if it is a string
    } val;
};
extern struct s_vartbl *vartbl;

extern int varcnt;                              // number of variables defined (eg, largest index into the variable table)
extern int VarIndex;                            // index of the current variable.  set after the findvar() function has found/created a variable
extern int LocalIndex;                          // used to track the level of local variables

extern int OptionBase;                          // value of OPTION BASE
extern int OptionErrorAbort;                    // value of OPTION ERROR
extern char PromptString[MAXPROMPTLEN];         // the command prompt

extern int autoOn, autoNext, autoIncr;          // use by the AUTO command
extern int TempStringClearStart;                // used to prevent clearing of space in an expression that called a FUNCTION

extern int ProgramChanged;                      // true if the program in memory has been changed and not saved

extern char FunKey[NBRPROGKEYS][MAXKEYLEN + 1]; // used by the programmable function keys

#if defined(MMFAMILY) || defined(DOS)
extern char *ModuleTable[MAXMODULES];           // list of pointers to library modules loaded in memory;
extern int NbrModules;                          // the number of library modules currently loaded
#endif

void error(char *msg) ;
void InitBasic(void);
void  error(char *);
int MMround(float);
void makeargs(char **tp, int maxargs, char *argbuf, char *argv[], int *argc, char *delim);
void *findvar(char *, int);
void erasearray(char *n);
void ClearVars(int level);
void ClearStack(void);
void ClearRuntime(void);
void ClearProgram(void);
char *evaluate(char *p, float *fa, char **sa, int *ta, int noerror);
float getnumber(char *p);
int getinteger(char *p);
int getint(char *p, int min, int max);
char *getstring(char *p);
void tokenise(int console);
void ExecuteProgram(char *);
void AddProgramLine(int append);
char *findline(int, int);
char *findlabel(char *labelptr);
char *skipvar(char *p, int noerror);
int vartype(char *p);
char *getclosebracket(char *p);
void makeupper(char *p);
void checkend(char *p);
int GetCommandValue(char *n);
int GetTokenValue(char *n);
char *checkstring(char *p, char *tkn);
int GetLineLength(char *p);
char *MtoC(char *p);
char *CtoM(char *p);
void Mstrcpy(char *dest, char *src);
void Mstrcat(char *dest, char *src);
int Mstrcmp(char *s1, char *s2);
char *getCstring(char *p);
int IsValidLine(int line);
void InsertLastcmd(char *s);
int CountLines(char *target);
void DefinedSubFun(int iscmd, char *cmd, int index, float *fa, char **sa);
int FindSubFun(char *p, int type);
void PrepareProgram(void);
void MMPrintString(char* s);
void MMfputs(char *p, int filenbr);



inline int str_equal(const char *s1, const char *s2);


int  strncasecmp (const char *s1, const char *s2, size_t n);
int mem_equal(char *s1, char *s2, int i);


