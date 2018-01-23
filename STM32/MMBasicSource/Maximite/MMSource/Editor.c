/***********************************************************************************************************************
MMBasic

Editor.c

Implements the full screen editor.

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
#include <plib.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"




/********************************************************************************************************************************************
Miscelaneous commands and functions
===================================

Each function is responsible for decoding a command
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




                /**********************************************************************
                 *  WARNING - THIS IS PRELIMINARY CODE.                               *
                 *  IT WAS DEVELOPED TO TEST TECHNIQUES AND THE OPERATOR INTERFACE.   *
                 *  IT WORKS CORRECTLY BUT COULD BE IMPLEMENTED MORE EFFICIENTLY.     *
                 *  BECAUSE OF THIS IT MAY WELL BE COMPLETELY REPLACED IN FUTURE      *
                 *  VERSIONS WITH SOMETHING MORE EFFICIENT.                           *
                 **********************************************************************/





#define CTRLKEY(a) (a & 0x1f)


/********************************************************************************************************************************************
 THE COMMAND LINE EDITOR
********************************************************************************************************************************************/


void EditInputLine(void) {
    char *p = NULL;
    char buf[MAXKEYLEN + 3];
    int lastcmd_idx, lastcmd_edit;
    int insert, startline, maxchars;
    int CharIndex, BufEdited;
    int c, i, j;

    maxchars = HRes / (fontWidth * fontScale);
    if(strlen(inpbuf) >= maxchars) {
        MMPrintString(inpbuf);
        error("Line is too long to edit");
    }
    startline = MMCharPos - 1;                                                          // save the current cursor position
    MMPrintString(inpbuf);                                                              // display the contents of the input buffer (if any)
    CharIndex = strlen(inpbuf);                                                         // get the current cursor position in the line
    insert = false;
    Cursor = C_STANDARD;
    lastcmd_edit = lastcmd_idx = 0;
    BufEdited = false; //(CharIndex != 0);
    while(1) {
        c = MMgetchar();
        if(c == TAB) {
            strcpy(buf, "        ");
            switch (GetFlashOption(&TabOption)) {
              case CONFIG_TAB2:
                buf[2 - (CharIndex % 2)] = 0; break;
              case CONFIG_TAB4:
                buf[4 - (CharIndex % 4)] = 0; break;
              case CONFIG_TAB8:
                buf[8 - (CharIndex % 8)] = 0; break;
            }
        } else {
            buf[0] = c;
            buf[1] = 0;
        }
        do {
            switch(buf[0]) {
                case '\r':
                case '\n':  if(autoOn && atoi(inpbuf) > 0) autoNext = atoi(inpbuf) + autoIncr;
                            if(autoOn && !BufEdited) *inpbuf = 0;
                            goto saveline;
                            break;

                case '\b':  if(CharIndex > 0) {
                                BufEdited = true;
                                i = CharIndex - 1;
                                for(p = inpbuf + i; *p; p++) *p = *(p + 1);                 // remove the char from inpbuf
                                while(CharIndex)  { MMputchar('\b'); CharIndex--; }         // go to the beginning of the line
                                MMPrintString(inpbuf); MMputchar(' '); MMputchar('\b');     // display the line and erase the last char
                                for(CharIndex = strlen(inpbuf); CharIndex > i; CharIndex--)
                                    MMputchar('\b');                                        // return the cursor to the righ position
                            }
                            break;

                case CTRLKEY('S'):
                case LEFT:  if(CharIndex > 0) {
                                if(CharIndex == strlen(inpbuf)) {
                                    insert = true;
                                    Cursor = C_INSERT;
                                }
                                MMputchar('\b');
                                CharIndex--;
                            }
                            break;

                case CTRLKEY('D'):
                case RIGHT: if(CharIndex < strlen(inpbuf)) {
                                MMputchar(inpbuf[CharIndex]);
                                CharIndex++;
                            }
                            break;

                case CTRLKEY(']'):
                case DEL:   if(CharIndex < strlen(inpbuf)) {
                                BufEdited = true;
                                i = CharIndex;
                                for(p = inpbuf + i; *p; p++) *p = *(p + 1);                 // remove the char from inpbuf
                                while(CharIndex)  { MMputchar('\b'); CharIndex--; }         // go to the beginning of the line
                                MMPrintString(inpbuf); MMputchar(' '); MMputchar('\b');     // display the line and erase the last char
                                for(CharIndex = strlen(inpbuf); CharIndex > i; CharIndex--)
                                    MMputchar('\b');                                        // return the cursor to the right position
                            }
                            break;

                case CTRLKEY('N'):
                case INSERT:insert = !insert;
                            Cursor = C_STANDARD + insert;
                            break;

                case CTRLKEY('U'):
                case HOME:  if(CharIndex > 0) {
                                if(CharIndex == strlen(inpbuf)) {
                                    insert = true;
                                    Cursor = C_INSERT;
                                }
                                while(CharIndex)  { MMputchar('\b'); CharIndex--; }
                            }
                            break;

                case CTRLKEY('K'):
                case END:   while(CharIndex < strlen(inpbuf))
                                MMputchar(inpbuf[CharIndex++]);
                            break;

                case 0x91:
                case 0x92:
                case 0x93:
                case 0x94:
                case 0x95:
                case 0x96:
                case 0x97:
                case 0x98:
                case 0x99:
                case 0x9a:
                case 0x9b:
                case 0x9c:  if(*FunKey[buf[0] - 0x91])
                                strcpy(&buf[1], (char *)FunKey[buf[0] - 0x91]);                     // copy a function key string into the buffer
                            break;

                case CTRLKEY('E'):
                case UP:    if(!(BufEdited || autoOn /*|| CurrentLineNbr */)) {
                                while(CharIndex)  { MMputchar('\b'); CharIndex--; }         // go to the beginning of line
                                if(lastcmd_edit) {
                                    i = lastcmd_idx + strlen(&lastcmd[lastcmd_idx]) + 1;    // find the next command
                                    if(lastcmd[i] != 0 && i < STRINGSIZE - 1) lastcmd_idx = i;  // and point to it for the next time around
                                } else
                                    lastcmd_edit = true;
                                strcpy(inpbuf, &lastcmd[lastcmd_idx]);                      // get the command into the buffer for editing
                                goto insert_lastcmd;
                            }
                            break;


                case CTRLKEY('X'):
                case DOWN:  if(!(BufEdited || autoOn /*|| CurrentLineNbr */)) {
                                while(CharIndex)  { MMputchar('\b'); CharIndex--; }         // go to the beginning of line
                                if(lastcmd_idx == 0)
                                    *inpbuf = lastcmd_edit = 0;
                                else {
                                    for(i = lastcmd_idx - 2; i > 0 && lastcmd[i - 1] != 0; i--);// find the start of the previous command
                                    lastcmd_idx = i;                                        // and point to it for the next time around
                                    strcpy(inpbuf, &lastcmd[i]);                            // get the command into the buffer for editing
                                }
                                goto insert_lastcmd;                                        // gotos are bad, I know, I know
                            }
                            break;

                insert_lastcmd:                                                             // goto here if we are just editing a command
                            if(strlen(inpbuf) + startline >= maxchars) {                    // if the line is too long
                                while(CharIndex)  { MMputchar('\b'); CharIndex--; }         // go to the start of the line
                                MMPrintString(inpbuf);                                      // display the offending line
                                error("Line is too long to edit");
                            }
                            MMPrintString(inpbuf);                                          // display the line
                            CharIndex = strlen(inpbuf);                                     // get the current cursor position in the line
                            for(i = 1; i < maxchars - strlen(inpbuf) - startline; i++) {
                                MMputchar(' ');                                             // erase the rest of the line
                                CharIndex++;
                            }
                            while(CharIndex > strlen(inpbuf)) { MMputchar('\b'); CharIndex--; } // return the cursor to the right position
                            break;

                default:    if(buf[0] >= ' ' && buf[0] < 0x7f) {
                                BufEdited = true;                                           // this means that something was typed
                                i = CharIndex;
                                j = strlen(inpbuf);
                                if(insert) {
                                    if(strlen(inpbuf) >= maxchars - 1) break;               // sorry, line full
                                    for(p = inpbuf + strlen(inpbuf); j >= CharIndex; p--, j--) *(p + 1) = *p;
                                    inpbuf[CharIndex] = buf[0];                             // insert the char
                                    MMPrintString(&inpbuf[CharIndex]);                      // display new part of the line
                                    CharIndex++;
                                    for(j = strlen(inpbuf); j > CharIndex; j--)
                                        MMputchar('\b');                                    // return the cursor to the right position
                                } else {
                                    inpbuf[strlen(inpbuf) + 1] = 0;                         // incase we are adding to the end of the string
                                    inpbuf[CharIndex++] = buf[0];                           // overwrite the char
                                    MMputchar(buf[0]);                                      // display it
                                    if(CharIndex + startline >= maxchars) {                 // has the input gone beyond the end of the line?
                                        MMgetline(0, inpbuf);                               // use the old fashioned way of getting the line
                                        if(autoOn && atoi(inpbuf) > 0) autoNext = atoi(inpbuf) + autoIncr;
                                        goto saveline;
                                    }
                                }
                            }
                            break;
            }
            for(i = 0; i < MAXKEYLEN + 1; i++) buf[i] = buf[i + 1];                             // suffle down the buffer to get the next char
        } while(*buf);
    if(CharIndex == strlen(inpbuf)) {
        insert = false;
        Cursor = C_STANDARD;
        }
    }

    saveline:
    Cursor = C_STANDARD;
    MMPrintString("\r\n");
}


/********************************************************************************************************************************************
 THE EDIT COMMAND
********************************************************************************************************************************************/



// this is the only global variable, the default place for the cursor when the editor opens
char *StartEditPoint = NULL;
int StartEditChar = 0;

char *EdBuff;						// the buffer used for editing the text
int EdBuffSize;						// size of the buffer in characters
int nbrlines;						// size of the text held in the buffer (in lines)
int VWidth, VHeight;				// editing screen width and height in characters
int edx, edy;						// column and row at the top left hand corner of the editing screen (in characters)
int curx, cury;						// column and row of the current cursor (in characters) relative to the top left hand corner of the editing screen
char *txtp;							// position of the current cursor in the text being edited
int drawstatusline;					// true if the status line needs to be redrawn on the next keystroke
int insert;							// true if the editor is in insert text mode
char *filename;						// the name of the file we are editing
int tempx;							// used to track the prefered x position when up/down arrowing
int TextChanged;                    // true if the program has been modified and therefor a save might be required

#define EDIT	1					// used to select the status line string
#define MARK	2

void FullScreenEditor(void);
char *findLine(int ln);
void printLine(int ln);
void printScreen(void);
void SCursor(int x, int y);
int editInsertChar(char c);
void PrintFunctKeys(int);
void PrintStatus(void);
int SaveToProgMemory(void);
void editDisplayMsg(char *msg);
void editInsertFile(char *fname);
void SaveToFile(char *fname);
void GetInputString(char *prompt);
void Scroll(void);
void ScrollDown(void);
void MarkMode(char *cb, char *buf);
void PositionCursor(char *curp);

// edit command:
//  EDIT 				Will run the full screen editor on the current program memory, if run after an error will place the cursor on the error line
//  EDIT nbr			Will edit a specific line number
//  EDIT file-name      Will run the full screen editor on the file
void cmd_edit(void) {
	char *fromp, *p;
	int i, y, x;
	#if defined(COLOUR)
	    int OldModeC, OldModeP, OldFgColour, OldBgColour;
	    char tempCLine[512];
	#endif

	if(CurrentLinePtr) error("Invalid in a program");
	ClearRuntime();

	#if defined(COLOUR)
	    OldModeC = ModeC; OldModeP = ModeP;
    	OldFgColour = ConsoleFgColour; OldBgColour = ConsoleBgColour;
        if(CLine < (char *)&_stack) FreeHeap(CLine);
	    if(vga) {
        	SetMode(1, WHITE);
        	CLine = tempCLine;
        	memset(CLine, OldFgColour == 0 ? WHITE : OldFgColour, 512); // and set to the current monochrome colour
        }
	#endif

    m_alloc(M_EDIT, true);                                          // allocate the memory space and set the variables EdBuff and EdBuffSize
    *EdBuff = 0;

	VHeight = (VRes / (fontHeight * fontScale)) - 2;
	VWidth = HRes / (fontWidth * fontScale);
	edx = edy = curx = cury = y = x = tempx = 0;
	txtp = EdBuff;
	*tknbuf = 0;

   	if(*cmdline == 0 || isdigit(*cmdline)) {						// if the user wants to edit the program memory
		if(isdigit(*cmdline)) {
//    		StartEditPoint = findline(i = getinteger(cmdline), true);
    		StartEditPoint = findline(getinteger(cmdline), true);
    		StartEditChar = 0;
        }
		filename = NULL;
		fromp  = PMemory + 1;
		p = EdBuff;
		nbrlines = 0;
		while(1) {
			if(*fromp == T_LINENBR) {
				if(StartEditPoint == fromp) {
					y = nbrlines;									// we will start editing at this line
					tempx = x = StartEditChar;
					txtp = p + StartEditChar;
				}
				nbrlines++;
				i = (((fromp[1]) << 8) | (fromp[2]));				// get the line number
				fromp = llist(p, fromp);							// otherwise expand the line
				p += strlen(p);
				*p++ = '\n'; *p = 0;
				if(p + 256 > EdBuff + EdBuffSize) {
					error("Not enough memory");
				}
			}
			// finally, is it the end of the program?
			if(fromp[0] == 0) break;
		}
		--p; *p = 0;												// erase the last line terminator
	} else {
		filename = GetFileName(cmdline, NULL);
		editInsertFile(filename);
		StartEditPoint = NULL;
	}

	MMPrintString("\033[2J\033[H");									// vt100 clear screen and home cursor
	MMcls();														// same for the video
	SCursor(0, 0);
	PrintFunctKeys(EDIT);

	if(nbrlines > VHeight) {
		edy = y - VHeight/2;										// edy is the line displayed at the top
		if(edy < 0) edy = 0;										// compensate if we are near the start
		y = y - edy;												// y is the line on the screen
	}
	printScreen();													// draw the screen
	SCursor(x, y);
	drawstatusline = true;
	FullScreenEditor();
	memset(tknbuf, 0, STRINGSIZE);                                  // zero this so that nextstmt is pointing to the end of program

	#if defined(COLOUR)
    	SetMode(OldModeC, OldModeP);
	#endif
}



void FullScreenEditor(void) {
	int c, i;
	char buf[STRINGSIZE + 2], clipboard[STRINGSIZE];
	char *p, *tp;
	char lastkey = 0;
	int x, y, statuscount;

	clipboard[0] = 0;
	insert = true;
	TextChanged = false;
    while(1) {
		statuscount = 0;
		Cursor = C_STANDARD + insert;
		do {
			ShowCursor(true);
			c = MMInkey();
			if(statuscount++ == 5000) PrintStatus();
		} while(c == -1);
		ShowCursor(false);

		if(drawstatusline) PrintFunctKeys(EDIT);
		drawstatusline = false;
		if(c == TAB) {
            strcpy(buf, "        ");
            switch (GetFlashOption(&TabOption)) {
              case CONFIG_TAB2:
                buf[2 - ((edx + curx) % 2)] = 0; break;
              case CONFIG_TAB4:
                buf[4 - ((edx + curx) % 4)] = 0; break;
              case CONFIG_TAB8:
                buf[8 - ((edx + curx) % 8)] = 0; break;
            }
		} else {
			buf[0] = c;
			buf[1] = 0;
		}
		do {
			switch(buf[0]) {

//				case 1:     { char foo[] = "\"T.BMP\""; cmdline = foo; cmd_savebmp();}
//							return;

				case '\r':
				case '\n':	// first count the spaces at the beginning of the line
							if(txtp != EdBuff && (*txtp == '\n' || *txtp == 0)) {	// we only do this if we are at the end of the line
								for(tp = txtp - 1, i = 0; *tp != '\n' && tp >= EdBuff; tp--)
									if(*tp != ' ')
										i = 0;										// not a space
									else
										i++;										// potential space at the start
								if(tp == EdBuff && *tp == ' ') i++;					// correct for a counting error at the start of the buffer
								if(buf[1] != 0)
									i = 0;											// do not insert spaces if buffer too small or has something in it
								else
									buf[i + 1] = 0;									// make sure that the end of the buffer is zeroed
								while(i) buf[i--] = ' ';							// now, place our spaces in the typeahead buffer
							}
							if(!editInsertChar('\n')) break;						// insert the newline
							TextChanged = true;
							nbrlines++;
							y = cury;
							if(cury < VHeight - 1)									// if we are NOT at the bittom
								y++;												// just increment the cursor
							else
								edy++;												// otherwise scroll
							printScreen();											// redraw everything
							//SCursor(0, y);
							PositionCursor(txtp);
							break;

                case CTRLKEY('E'):
				case UP:	if(cury == 0 && edy == 0) break;
							if(*txtp == '\n') txtp--;								// step back over the terminator if we are right at the end of the line
							while(txtp != EdBuff && *txtp != '\n') txtp--;			// move to the beginning of the line
							if(txtp != EdBuff) {
								txtp--;												// step over the terminator to the end of the previous line
								while(txtp != EdBuff && *txtp != '\n') txtp--;		// move to the beginning of that line
								if(*txtp == '\n') txtp++;							// and position at the start
							}
							for(i = 0; i < edx + tempx && *txtp != 0 && *txtp != '\n'; i++, txtp++);  // move the cursor to the column

							if(cury > 2 || edy == 0) {								// if we are more that two lines from the top
								if(cury > 0) SCursor(i, cury - 1);					// just move the cursor up
							}
							else if(edy > 0) {										// if we are two lines or less from the top
								curx = i;
								ScrollDown();
							}
							PositionCursor(txtp);
							break;

                case CTRLKEY('X'):
				case DOWN:	p = txtp;
							while(*p != 0 && *p != '\n') p++;						// move to the end of this line
							if(*p == 0) break;										// skip if it is at the end of the file
							p++;													// step over the line terminator to the start of the next line
							for(i = 0; i < edx + tempx && *p != 0 && *p != '\n'; i++, p++);  // move the cursor to the column
							txtp = p;

							if(cury < VHeight - 3 || edy + VHeight == nbrlines) {
								if(cury < VHeight - 1) SCursor(i, cury + 1);
							}
							else if(edy + VHeight < nbrlines) {
								curx = i;
								Scroll();
							}
							PositionCursor(txtp);
							break;

                case CTRLKEY('S'):
				case LEFT:	if(txtp == EdBuff) break;
							if(*(txtp - 1) == '\n') {								// if at the beginning of the line wrap around
								buf[1] = UP;
								buf[2] = END;
								buf[3] = 1;
								buf[4] = 0;
							} else {
								txtp--;
    							PositionCursor(txtp);
								//SCursor(curx - 1, cury);
							}
							break;

                case CTRLKEY('D'):
				case RIGHT:	if(*txtp == '\n') {										// if at the end of the line wrap around
								buf[1] = HOME;
								buf[2] = DOWN;
								buf[3] = 0;
								break;
							}
							if(curx >= VWidth) {
								editDisplayMsg(" LINE IS TOO LONG ");
								break;
							}
					 		if(*txtp == 0) break;									// end of buffer
							txtp++;													// now we can move the cursor
							PositionCursor(txtp);
							//SCursor(curx + 1, cury);
							break;

				// backspace
				case BKSP:	if(txtp == EdBuff) break;
							if(*(txtp - 1) == '\n') {								// if at the beginning of the line wrap around
								buf[1] = UP;
								buf[2] = END;
								buf[3] = DEL;
								buf[4] = 0;
								break;
							}
							// find how many spaces are between the cursor and the start of the line
							for(p = txtp - 1; *p == ' ' && p != EdBuff; p--);
							if((p == EdBuff || *p == '\n') && txtp - p > 1) {
							    i = txtp - p - 1;
    							// we have have the number of continuous spaces between the cursor and the start of the line
    							// now figure out the number of backspaces to the nearest tab stop
                                switch (GetFlashOption(&TabOption)) {
                                  case CONFIG_TAB2:
                                    i = (i % 2); if(i == 0) i = 2; break;
                                  case CONFIG_TAB4:
                                    i = (i % 4); if(i == 0) i = 4; break;
                                  case CONFIG_TAB8:
                                    i = (i % 8); if(i == 0) i = 8; break;
                                }
                                // load the corresponding number of deletes in the type ahead buffer
                                buf[i + 1] = 0;
                                while(i--) {
                                    buf[i + 1] = DEL;
                                    txtp--;
                                }
                                // and let the delete case take care of deleting the characters
							    PositionCursor(txtp);
							    break;
							}
							// this is just a normal backspace (not a tabbed backspace)
							txtp--;
							PositionCursor(txtp);
							// fall through to delete the char

                case CTRLKEY(']'):
				case DEL:	if(*txtp == 0) break;
							p = txtp;
							c = *p;
							while(*p) {
								p[0] = p[1];
								p++;
							}
							x = curx; y = cury;
							if(c == '\n') {
								printScreen();
								nbrlines--;
							}
							else
								printLine(edy + cury);
							//SCursor(x, y);
							TextChanged = true;
							PositionCursor(txtp);
							break;

                case CTRLKEY('N'):
				case INSERT:insert = !insert;
							break;

                case CTRLKEY('U'):
				case HOME:	if(txtp == EdBuff) break;
							if(lastkey == HOME || lastkey == CTRLKEY('U')) {
								edx = edy = curx = cury = 0;
								txtp = EdBuff;
								MMPrintString("\033[2J\033[H");						// vt100 clear screen and home cursor
								MMcls();											// same for the video
								printScreen();
								PrintFunctKeys(EDIT);
    							PositionCursor(txtp);
								//SCursor(0, 0);
								break;
							}
							if(*txtp == '\n') txtp--;								// step back over the terminator if we are right at the end of the line
							while(txtp != EdBuff && *txtp != '\n') txtp--;			// move to the beginning of the line
							if(*txtp == '\n') txtp++;								// skip if no more lines above this one
							PositionCursor(txtp);
							//SCursor(0, cury);
							break;

                case CTRLKEY('K'):
				case END:	if(*txtp == 0) break;									// already at the end
							if(lastkey == END || lastkey == CTRLKEY('K')) {			// jump to the end of the file
								i = 0; p = txtp = EdBuff;
								while(*txtp != 0) {
									if(*txtp == '\n') { p = txtp + 1; i++; }
									txtp++;
								}

								if(i >= VHeight) {
									edy = i - VHeight + 1;
									printScreen();
									cury = VHeight - 1;
								} else {
									cury = i;
								}
								txtp = p;
								curx = 0;
							}

							while(curx < VWidth && *txtp != 0 && *txtp != '\n') {
								txtp++;
    							PositionCursor(txtp);
								//SCursor(curx + 1, cury);
							}
							if(curx > VWidth) editDisplayMsg(" LINE IS TOO LONG ");
							break;

                case CTRLKEY('P'):
				case PUP:	if(edy == 0) {											// if we are already showing the top of the text
								buf[1] = HOME;										// force the editing point to the start of the text
								buf[2] = HOME;
								buf[3] = 0;
								break;
							} else if(edy >= VHeight - 1) {							// if we can scroll a full screenfull
								i = VHeight + 1;
								edy -= VHeight;
							} else {												// if it is less than a full screenfull
								i = edy + 1;
								edy = 0;
							}
							while(i--) {
								if(*txtp == '\n') txtp--;							// step back over the terminator if we are right at the end of the line
								while(txtp != EdBuff && *txtp != '\n') txtp--;		// move to the beginning of the line
								if(txtp == EdBuff) break;							// skip if no more lines above this one
							}
							if(txtp != EdBuff) txtp++;								// and position at the start of the line
							for(i = 0; i < edx + curx && *txtp != 0 && *txtp != '\n'; i++, txtp++);  // move the cursor to the column
							y = cury;
							/* if(cury != 0) */ printScreen();
							PositionCursor(txtp);
							// SCursor(i, y);
							break;

                case CTRLKEY('L'):
				case PDOWN:	if(nbrlines <= edy + VHeight + 1) {						// if we are already showing the end of the text
								buf[1] = END;										// force the editing point to the end of the text
								buf[2] = END;
								buf[3] = 0;
								break;												// cursor to the top line
							} else if(nbrlines - edy - VHeight >= VHeight) {		// if we can scroll a full screenfull
								edy += VHeight;
								i = VHeight;
							} else {												// if it is less than a full screenfull
								i = nbrlines - VHeight - edy;
								edy = nbrlines - VHeight;
							}
							if(*txtp == '\n') i--;									// compensate if we are right at the end of a line
							while(i--) {
								if(*txtp == '\n') txtp++;							// step over the terminator if we are right at the start of the line
								while(*txtp != 0 && *txtp != '\n') txtp++;			// move to the end of the line
								if(*txtp == 0) break;								// skip if no more lines after this one
							}
							if(txtp != EdBuff) txtp++;								// and position at the start of the line
							for(i = 0; i < edx + curx && *txtp != 0 && *txtp != '\n'; i++, txtp++);  // move the cursor to the column
							y = cury;
							printScreen();
							PositionCursor(txtp);
							// SCursor(i, y);
							break;


				// CTRL-F - Insert file
				case CTRLKEY('F'):
				            GetInputString("File to insert: ");
							if(*inpbuf == 0) break;
							editDisplayMsg(" WAIT ");
							OptionErrorAbort = false;
							MMfopen(inpbuf, "r", 1);								// first check if the file exists
							OptionErrorAbort = true;
							if(MMerrno) {
								editDisplayMsg(" FILE NOT FOUND ");
								break;
							}
							TextChanged = true;
							MMfclose(1);
							editInsertFile(inpbuf);
							x = curx; y = cury;
							PrintFunctKeys(EDIT);
							printScreen();
							PositionCursor(txtp);
							// SCursor(x, y);
							break;

				// Abort without saving
				case ESC:	if(TextChanged) {
    				            #if defined(TFT_MAXIMITE)
								    GetInputString("Discard all changes (Y/N): ");
								#else
								    GetInputString("Exit and discard all changes (Y/N): ");
								#endif
								if(toupper(*inpbuf) != 'Y') break;
							}
							MMPrintString("\033[2J\033[H");							// vt100 clear screen and home cursor
							MMcls();												// same for the video
							m_alloc(M_EDIT, false);                                 // Signifies that we do not need the memory
							return;

				// Save and exit
                case CTRLKEY('Q'):
				case F1:	editDisplayMsg(" WAIT ");
							if(filename == NULL) {
								if(!SaveToProgMemory()) break;
							} else
								SaveToFile(filename);
							MMPrintString("\033[2J\033[H");							// vt100 clear screen and home cursor
							MMcls();												// same for the video
							m_alloc(M_EDIT, false);                                 // Signifies that we do not need the memory
							return;

				// Save, exit and run
                case CTRLKEY('W'):
				case F2:	editDisplayMsg(" WAIT ");
							if(!SaveToProgMemory()) break;
							MMPrintString("\033[2J\033[H");							// vt100 clear screen and home cursor
							MMcls();												// same for the video
							if(filename != NULL) SaveToFile(filename);
							m_alloc(M_EDIT, false);                                 // Signifies that we do not need the memory
							ClearRuntime();
                            PrepareProgram();
							nextstmt = PMemory;
							return;

				// Search
                case CTRLKEY('R'):
				case F3:	GetInputString("Find (Use SHIFT-F3 to repeat): ");
							if(*inpbuf == 0 || *inpbuf == ESC) break;
							if(!(*inpbuf == 0xb3 || *inpbuf == F3)) strcpy(tknbuf, inpbuf);
							// fall through

                case CTRLKEY('G'):
				case 0xB3:  // SHIFT-F3
							p = txtp;
							if(*p == 0) p = EdBuff - 1;
							i = strlen(tknbuf);
							while(1) {
								p++;
								if(p == txtp) break;
								if(*p == 0) p = EdBuff;
								if(p == txtp) break;
								if(mem_equal(p, tknbuf, i)) break;
							}
							if(p == txtp) {
								editDisplayMsg(" NOT FOUND ");
								break;
							}
							for(y = x = 0, txtp = EdBuff; txtp != p; txtp++) {		// find the line and column of the string
								x++;
								if(*txtp == '\n') {
									y++;											// y is the line
									x = 0;											// x is the column
								}
							}
							edy = y - VHeight/2;									// edy is the line displayed at the top
							if(edy < 0) edy = 0;									// compensate if we are near the start
							y = y - edy;											// y is the line on the screen
							printScreen();
							PositionCursor(txtp);
							// SCursor(x, y);
							break;

				// Mark
                case CTRLKEY('T'):
				case F4:  	MarkMode(clipboard, &buf[1]);
							printScreen();
							PrintFunctKeys(EDIT);
							PositionCursor(txtp);
							break;

                case CTRLKEY('Y'):
				case F5:	if(*clipboard == 0) {
								editDisplayMsg(" CLIPBOARD IS EMPTY ");
								break;
							}
							for(i = 0; clipboard[i]; i++) buf[i + 1] = clipboard[i];
							buf[i + 1] = 0;
							break;

				// F6 to F12 - Normal programmable function keys
				case F6:
				case F7:
				case F8:
				case F9:
				case F10:
				case F11:
				case F12:	if(*FunKey[buf[0] - 0x91])
								strcpy(&buf[1], (char *)FunKey[buf[0] - 0x91]);		// copy a function key string into the buffer
							break;

				// a normal character
				default:	c = buf[0];
							if(c < ' ' || c > '~') break;							// make sure that this is valid
							if(curx >= VWidth) {
								editDisplayMsg(" LINE IS TOO LONG ");
								break;
							}
							TextChanged = true;
							if(insert || *txtp == '\n' || *txtp == 0) {
								if(!editInsertChar(c)) break;						// insert it
							} else
								*txtp++ = c;										// or just overtype
							MMputchar(c);											// and echo
							x = ++curx;
							if(insert &&  *txtp != '\n' && *txtp != 0) printLine(edy + cury);
							PositionCursor(txtp);
							// SCursor(x, cury);
							tempx = cury;											// used to track the preferred cursor position
							break;

			}
			lastkey = buf[0];
			if(buf[0] != UP && buf[0] != DOWN && buf[0] != CTRLKEY('E') && buf[0] != CTRLKEY('X')) tempx = curx;
			buf[STRINGSIZE + 1] = 0;
			for(i = 0; i < STRINGSIZE + 1; i++) buf[i] = buf[i + 1];				// suffle down the buffer to get the next char
		} while(*buf);
	}
}


/*******************************************************************************************************************
  UTILITY FUNCTIONS USED BY THE FULL SCREEN EDITOR
*******************************************************************************************************************/


// send a string only to the vt100 terminal on the USB or console
void VT100Send(char *p) {
	USBPutEscape(p);									            // send it to the USB
	for(; *p; p++) {
		if(SerialConsole) SerialPutchar(SerialConsole, *p);			// send it to the serial console if enabled
	}
}


void PositionCursor(char *curp) {
	int ln, col;
	char *p;

	for(p = EdBuff, ln = col = 0; p < curp; p++) {
		if(*p == '\n') {
			ln++;
			col = 0;
		} else
			col++;
	}
	if(ln < edy || ln >= edy + VHeight) return;
	SCursor(col, ln - edy);
}



// mark mode
// implement the mark mode (when the user presses F4)
void MarkMode(char *cb, char *buf) {
	char c, *p, *mark, *oldmark;
	int x, y, i, oldx, oldy, txtpx, txtpy, errmsg = false;

	PrintFunctKeys(MARK);
	oldmark = mark = txtp;
	txtpx = oldx = curx; txtpy = oldy = cury;
	while(1) {
		c = MMgetchar();
		if(errmsg) 	PrintFunctKeys(MARK);
		errmsg = false;
		switch(c) {
			case ESC:	curx = txtpx; cury = txtpy;
						return;

            case CTRLKEY('E'):
			case UP:	if(cury <= 0) continue;
						p = mark;
						if(*p == '\n') p--;										// step back over the terminator if we are right at the end of the line
						while(p != EdBuff && *p != '\n') p--;					// move to the beginning of the line
						if(p != EdBuff) {
							p--;												// step over the terminator to the end of the previous line
							for(i = 0; p != EdBuff && *p != '\n'; p--, i++);	// move to the beginning of that line
							if(*p == '\n') p++;									// and position at the start
							if(i >= VWidth) {
								editDisplayMsg(" LINE IS TOO LONG ");
								errmsg = true;
								continue;
							}
						}
						mark = p;
						for(i = 0; i < edx + curx && *mark != 0 && *mark != '\n'; i++, mark++);  // move the cursor to the column
						curx = i; cury--;
						break;

            case CTRLKEY('X'):
			case DOWN:	if(cury == VHeight -1) continue;
						for(p = mark, i = curx; *p != 0 && *p != '\n'; p++, i++);// move to the end of this line
						if(*p == 0) continue;									// skip if it is at the end of the file
						if(i >= VWidth) {
							editDisplayMsg(" LINE IS TOO LONG ");
							errmsg = true;
							continue;
						}
						mark = p + 1;											// step over the line terminator to the start of the next line
						for(i = 0; i < edx + curx && *mark != 0 && *mark != '\n'; i++, mark++);  // move the cursor to the column
						curx = i; cury++;
						break;

            case CTRLKEY('S'):
			case LEFT:	if(curx == edx) continue;
						mark--;
						curx--;
						break;

            case CTRLKEY('D'):
			case RIGHT: if(curx >= VWidth || *mark == 0 || *mark == '\n') continue;
						mark++;
						curx++;
						break;

            case CTRLKEY('U'):
			case HOME:	if(mark == EdBuff) break;
						if(*mark == '\n') mark--;								// step back over the terminator if we are right at the end of the line
						while(mark != EdBuff && *mark != '\n') mark--;			// move to the beginning of the line
						if(*mark == '\n') mark++;								// skip if no more lines above this one
						break;

            case CTRLKEY('K'):
			case END:	if(*mark == 0) break;
						for(p = mark, i = curx; *p != 0 && *p != '\n'; p++, i++);// move to the end of this line
						if(i >= VWidth) {
							editDisplayMsg(" LINE IS TOO LONG ");
							errmsg = true;
							continue;
						}
						mark = p;
						break;

            case CTRLKEY('Y'):
            case CTRLKEY('T'):
			case F5:
			case F4:	if(txtp - mark > MAXSTRLEN || mark - txtp > MAXSTRLEN) {
							editDisplayMsg(" MARKED TEXT EXCEEDS 255 CHARACTERS ");
							errmsg = true;
							break;
						}
						if(mark <= txtp) {
							p = mark;
							while(p < txtp) *cb++ = *p++;
						} else {
							p = txtp;
							while(p <= mark - 1) *cb++ = *p++;
						}
						*cb = 0;
						if(c == F5 || c == CTRLKEY('Y')) {
							PositionCursor(txtp);
							return;
						}
						// fall through

            case CTRLKEY(']'):
			case DEL:	if(mark < txtp) {
							p = txtp;  txtp = mark; mark = p;					// swap txtp and mark
						}
						for(p = txtp; p <= mark; p++) if(*p == '\n') nbrlines--;
						for(p = txtp; *mark; ) *p++ = *mark++;
						*p++ = 0; *p++ = 0;
						TextChanged = true;
						PositionCursor(txtp);
						return;

			default:	continue;
		}

		x = curx; y = cury;

		// first unmark the area not marked as a result of the keystroke
		if(oldmark < mark) {
			PositionCursor(oldmark);
			p = oldmark;
			while(p < mark) {
				if(*p == '\n') MMputchar('\r');
				MMputchar(*p++);
			}
		} else if(oldmark > mark) {
			PositionCursor(mark);
			p = mark;
			while(oldmark > p) {
				if(*p == '\n') MMputchar('\r');
				MMputchar(*p++);
			}
		}

		oldmark = mark; oldx = x; oldy = y;

		// now draw the marked area
		if(mark < txtp) {
			PositionCursor(mark);
			SetFont((GetFlashOption(&FontOption) == CONFIG_FONT1) ? 0:1, 1, 1); // reverse video
			VT100Send("\033[7m");
			p = mark;
			while(p < txtp) {
				if(*p == '\n') MMputchar('\r');
				MMputchar(*p++);
			}
		} else if(mark > txtp) {
			PositionCursor(txtp);
			SetFont((GetFlashOption(&FontOption) == CONFIG_FONT1) ? 0:1, 1, 1);	// reverse video
			VT100Send("\033[7m");
			p = txtp;
			while(p < mark) {
				if(*p == '\n') MMputchar('\r');
				MMputchar(*p++);
			}
		}
		VT100Send("\033[0m");										// normal video
		SetFont((GetFlashOption(&FontOption) == CONFIG_FONT1) ? 0:1, 1, 0);

		oldx = x; oldy = y; oldmark = mark;
		PositionCursor(mark);
	}
}




// search through the text in the editing buffer looking for a specific line
// enters with ln = the line required
// exits pointing to the start of the line or pointing to a zero char if not that many lines in the buffer
char *findLine(int ln) {
	char *p;
	p = EdBuff;
	while(ln && *p) {
		if(*p == '\n') ln--;
		p++;
	}
	return p;
}



// print a line starting at the current column (edx) at the current cursor.
// the line is padded with spaces (if necessary) to the end of the screen width (80 chars)
// if the line is beyond the end of the text then just print spaces
// enters with the line number to be printed
void printLine(int ln) {
	char *p;
	int i;

	p = findLine(ln);
	i = curx;
	while(i-- && *p && *p != '\n') p++;
	i = VWidth - curx;
	while(i && *p && *p != '\n') {
		MMputchar(*p++);
		i--;
	}
	if(VideoOn) while(i--) VideoPutc(' ');                          // clear the video to the end of the line
	VT100Send("\033[K");                                            // clear to the end of the line on a vt100 emulator
	curx = VWidth - 1;
}



// print a full screen starting with the top left corner specified by edx, edy
// this draws the full screen including blank areas so there is no need to clear the screen first
// it then returns the cursor to its original position
void printScreen(void) {
	int i;

	SCursor(0, 0);
	for(i = 0; i <VHeight; i++) {
		printLine(i + edy);
		MMputchar('\r');
		MMputchar('\n');
		curx = 0;
		cury = i + 1;
	}
	while(MMInkey() != -1);											// consume any keystrokes accumulated while redrawing the screen
}



// position the cursor on the screen
void SCursor(int x, int y) {
	char s[12];

	MMPosX = x * (fontWidth * fontScale);
	MMPosY = y * (fontHeight * fontScale);

	sprintf(s, "\033[%d;%dH", y + 1, x + 1);
	VT100Send(s);
	curx = x; cury = y;
}



// move the text down by one char starting at the current position in the text
// and insert a character
int editInsertChar(char c) {
	char *p;

	for(p = EdBuff; *p; p++);										// find the end of the text in memory
	if(p >= EdBuff + EdBuffSize - 1) {								// and check that we have the space
		editDisplayMsg(" OUT OF MEMORY ");
		return false;
	}
	for(; p >= txtp; p--) *(p + 1) = *p;							// shift everything down
	*txtp++ = c;													// and insert our char
	return true;
}



// print the function keys at the bottom of the screen
void PrintFunctKeys(int typ) {
	int x, y, i;
	char *p;

	if(typ == EDIT) {
#if defined(COLOUR)
    	if(vga) for(i = VHeight * (fontHeight * fontScale); i < VRes; i++) CLine[i] = CYAN;   // colour the status line
#endif
		if(VWidth > 70) {
			p = "ESC:Exit  F1:Save  F2:Run  F3:Find  F4:Mark  F5:Paste";
		} else if(VWidth > 40) {
			p = "Esc Save Run Find Mark Paste";
		} else {
    		p = "EDIT MODE";
        }
	} else {
#if defined(COLOUR)
    	if(vga) for(i = VHeight * (fontHeight * fontScale); i < VRes; i++) CLine[i] = GREEN;  // colour the status line
#endif
		if(VWidth > 40)
    		p = "MARK MODE   ESC=Exit  DEL:Delete  F4:Cut  F5:Copy";
    	else
    		p = "MARK MODE";
	}

	x = curx; y = cury;
#if defined(COLOUR)
    if(vga) CLine[VHeight * (fontHeight * fontScale) + (fontHeight * fontScale)/2] = YELLOW;          // colour the horizontal line
#endif
	MMline(0, VHeight * (fontHeight * fontScale) + (fontHeight * fontScale)/2, (VWidth * (fontWidth * fontScale)) - 1, VHeight * (fontHeight * fontScale) + (fontHeight * fontScale)/2, 1);
	SCursor(0, VHeight + 1);
	for(i = 0; i < VWidth; i++)
		if(*p)
			MMputchar(*p++);
		else
			MMputchar(' ');
	SCursor(x, y);
}



// print the current status
void PrintStatus(void) {
	char s[40];

	if(VWidth > 70)
		sprintf(s, "   Ln: %-2d  Col: %-2d   %s", edy + cury + 1, edx + curx + 1, insert?"INS":"OVR");
	else
		sprintf(s, " Ln:%-2d Col:%-2d %s", edy + cury + 1, edx + curx + 1, insert?"INS":"OVR");
	SCursor(VWidth - strlen(s), VHeight + 1);
	MMPrintString(s);
	PositionCursor(txtp);
}



// display a message in the status line
void editDisplayMsg(char *msg) {
	int i; //, x, y;

	//x = curx; y = cury;
	SCursor(0, VHeight + 1);
	SetFont((GetFlashOption(&FontOption) == CONFIG_FONT1) ? 0:1, 1, 1);
	VT100Send("\033[7m");
#if defined(COLOUR)
	if(vga) for(i = (VHeight + 1) * (fontHeight * fontScale); i < VRes; i++) CLine[i] = RED;                       // colour the status line
#endif
	MMPrintString(msg);
	VT100Send("\033[0m");
	SetFont((GetFlashOption(&FontOption) == CONFIG_FONT1) ? 0:1, 1, 0);
	for(i = VWidth - strlen(msg); i > 0; i--) MMputchar(' ');
	//SCursor(x, y);
	PositionCursor(txtp);
	drawstatusline = true;
}



// save the program in the editing buffer into the program memory
int SaveToProgMemory(void) {
	char *tp, *xp;
	int ln;

    // prepare the program memory by clearing it and setting up the pointers
    ClearProgram();
	if(*EdBuff == 0) return true;
	tp = EdBuff;
	ln = 0;
	while(1) {
		xp = inpbuf;												// setup for the next line
		while(*tp != 0 && *tp != '\n') *xp++ = *tp++;				// copy the line from the editing buffer
		*xp = 0;													// terminate the buffer
		while(xp != inpbuf && *(xp - 1) == ' ') *(--xp) = 0;		// trim trailing spaces
		tokenise(false);											// do some magic
		if(ln++ == edy + cury) {	                                // record out position in case the editor is invoked again
    		StartEditPoint = PMemory + PSize;
    		StartEditChar = edx + curx;
        }
		AddProgramLine(true);
		if(*tp == 0) return true;									// end of the text
		tp++;														// and step over the new line
	}
}



// save memory to a file
void SaveToFile(char *fname) {
	char *tp;

	MMfopen(fname, "w", 1);

	tp = EdBuff;
	if(*tp == 0) return;
	while(*tp) {
		if(*tp == '\n') MMfputc('\r', 1);
		MMfputc(*tp++, 1);
	}
	MMfclose(1);
	TextChanged = false;
}


// insert a file into memory
void editInsertFile(char *fname) {
	char *tp;
	int c, i;

	MMfopen(fname, "r", 1);

	tp = txtp;
	c = i = 0;
	while(1) {
		if(MMfeof(1)) break;

		if(i >= MAXSTRLEN) {										// break up lines that are too long
			if(!editInsertChar('\n')) break;
			i = 0;
		}

		// make sure that we get only one line for each CF/LF pair
		switch(c) {
			case '\r':	c = MMfgetc(1);
						if(c == '\n') { c = 0; continue; }
						break;
			case '\n':	c = MMfgetc(1);
						if(c == '\r') { c = 0; continue; }
						break;
			default  :	c = MMfgetc(1);
		}

		if(c == '\t') {
			while(((++i) % 8) && i <= MAXSTRLEN) {
				if(!editInsertChar(' ')) break;						// expand tabs to spaces
			}
		} else if(isprint(c)) {
			if(!editInsertChar(c)) break;							// if printable save in the input buffer
			i++;
		} else if(c == '\r' || c == '\n') {							// end of a line
			if(!editInsertChar('\n')) break;
			nbrlines++;
			i = 0;
		}
	}
	//if(*(txtp - 1) == '\n') *(txtp - 1) = 0;						// erase any last newline
	txtp = tp;
	MMfclose(1);
}



// get an input string from the user and save into inpbuf
void GetInputString(char *prompt) {
	int i; //x, y, i;
	char *p;

	//x = curx; y = cury;
	SCursor(0, VHeight + 1);
	MMPrintString(prompt);
	for(i = 0; i < VWidth - strlen(prompt); i++) MMputchar(' ');
	SCursor(strlen(prompt), VHeight + 1);
	Cursor = C_STANDARD;
	for(p = inpbuf; (*p = MMgetchar()) != '\n'; p++) {				// get the input
		if(*p == 0xb3 || *p == F3 || *p == ESC) { p++; break; }		// return if it is SHIFT-F3, F3 or ESC
		if(isprint(*p)) MMputchar(*p);								// echo the char
		if(*p == '\b') {
			p--;													// backspace over a backspace
			if(p >= inpbuf){
				p--;												// and the char before
				MMPrintString("\b \b");								// erase on the screen
			}
		}
	}
	*p = 0;															// terminate the input string
	PrintFunctKeys(EDIT);
	PositionCursor(txtp);
	//SCursor(x, y);
}


// scroll up the video screen
void Scroll(void) {
	int i, j;

    ScrollUp(3);

	edy++;
	j = VideoOn;
	SCursor(0, 0);
	for(i = 0; i < VHeight - 1; i++) {
		VideoOn = false;
		printLine(i + edy);
		VideoOn = j;
		MMputchar('\r'); MMputchar('\n');
		curx = 0;
		cury = i + 1;
	}
	printLine(i + edy);
	PositionCursor(txtp);
	while(MMInkey() != -1);									// consume any keystrokes accumulated while redrawing the screen
}


// scroll down the video screen
void ScrollDown(void) {
	int *pd, *ps, i, j;

    #if defined(COLOUR)
        pd = VideoBufRed;                                   // we are always in monochrome so any colour channel will do
        if(!pd && VideoBufGrn) pd = VideoBufGrn;
        if(!pd && VideoBufBlu) pd = VideoBufBlu;
    #else
        pd = VideoBuf;
    #endif
    if(pd != NULL) {                                    // only scroll the video if it is turned on
        pd += (HBuf/32) * VHeight * (fontHeight * fontScale);
       	ps = pd - ((HBuf/32) * (fontHeight * fontScale));
       	for(i=0; i<(HBuf/32) * (VHeight - 1) * (fontHeight * fontScale); i++) *pd-- = *ps--;	// scroll down
   	}

	edy--;
	j = VideoOn;
	SCursor(0, 0);
	printLine(edy);
	for(i = 1; i < VHeight; i++) {
		MMputchar('\r'); MMputchar('\n');
		curx = 0;
		cury = i + 1;
		VideoOn = false;
		printLine(i + edy);
		VideoOn = j;
	}

	PositionCursor(txtp);
	while(MMInkey() != -1);									// consume any keystrokes accumulated while redrawing the screen
}


