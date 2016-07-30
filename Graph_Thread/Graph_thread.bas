'=============================================================================
'
'  Multi-threading example for the PowerBASIC Console Compiler
'  Copyright (c) 1998-2011 PowerBASIC, Inc.
'  All Rights Reserved.
'
'=============================================================================
#COMPILER PBCC 6
#COMPILE EXE
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF
#DEBUG ERROR ON
DEFLNG a-z
#INCLUDE "WIN32API.INC"

THREAD FUNCTION MyMouseThread (BYVAL escape_passed AS LONG) AS LONG
    DIM MousePoint AS POINTAPI
    GRAPHIC ATTACH hGWin, 0
    DO
        SLEEP 1
        GetCursorPos Mousepoint
        ScreenToClient hGwin, mousepoint
        GRAPHIC SET POS (0,0): GRAPHIC PRINT "X:";Mousepoint.x;"   Y:";Mousepoint.y;"    ": GRAPHIC REDRAW
    LOOP
END FUNCTION
THREAD FUNCTION MyInputThread (BYVAL escape_passed AS LONG) AS LONG
    GRAPHIC ATTACH hGWin, 0
    DO
        GRAPHIC INKEY$ TO sKey$
        SLEEP 1
        SELECT CASE LEN(sKey$)
          CASE 1
              IF ASC(sKey$) = 27 THEN
                  EXIT LOOP    ' Esc to quit
              ELSEIF sKey$ = "r" THEN
                    THREAD RESUME Resumestartthread TO lResult&
                 ELSEIF sKey$ = "p" THEN
                       THREAD SUSPEND Resumestartthread TO lResult&
                 END IF
        END SELECT
    LOOP
FUNCTION = -1
END FUNCTION

FASTPROC mysafethread (BYVAL printsem AS LONG) THREADSAFE AS LONG
 CON.LOC = 100, 100
 PRINT "In FastProc"
END FASTPROC = -1

THREAD FUNCTION MyStartStopThread (BYVAL Filler AS LONG) AS LONG
   GRAPHIC ATTACH hGWin, 0
   DO
         GRAPHIC SET POS (50,50): GRAPHIC PRINT "|": GRAPHIC REDRAW
         GRAPHIC SET POS (50,50): GRAPHIC PRINT "/": GRAPHIC REDRAW
         GRAPHIC SET POS (50,50): GRAPHIC PRINT "-": GRAPHIC REDRAW
         GRAPHIC SET POS (50,50): GRAPHIC PRINT "|": GRAPHIC REDRAW
         GRAPHIC SET POS (50,50): GRAPHIC PRINT "\": GRAPHIC REDRAW
         GRAPHIC SET POS (50,50): GRAPHIC PRINT "-": GRAPHIC REDRAW
   LOOP
   FUNCTION = -1
END FUNCTION
FUNCTION PBMAIN () AS LONG
 'Variables
 DIM MousePoint AS POINTAPI
 DIM XVar AS INTEGER
 DIM YVar AS INTEGER
 DIM idThread(1 TO 10) AS LONG

 GLOBAL inthread_input, inthread_mouse AS LONG
 GLOBAL Resumestartthread AS LONG

 GLOBAL hGWin???, sKey$
 LOCAL ix AS LONG
 LOCAL nStatus AS LONG
 LOCAL escape_passed AS INTEGER

     GRAPHIC WINDOW "Graphic Window", 300, 300, 400, 300 TO hGWin
     GRAPHIC ATTACH hGWin, 0
     FONT NEW "Lucida Console",12,0,0,0,0 TO F1
     GRAPHIC SET FONT F1: GRAPHIC CHR SIZE TO W1,H1 ' Find pixel width and height of fnt1 graphic font
     escape_passed = 0
     THREAD CREATE MyInputThread(escape_passed) TO inthread_input
     THREAD CREATE MyMouseThread(escape_passed) TO inthread_mouse
     THREAD CREATE MyStartStopThread(0) TO Resumestartthread
     DO WHILE GRAPHIC(DC)
        GRAPHIC GET DC TO hGwin: IF hGwin=0 THEN EXIT DO
        THREAD STATUS inthread_input TO nStatus
        IF nStatus = -1 THEN
            THREAD CLOSE inthread_input TO nStatus
            THREAD CLOSE inthread_mouse TO nStatus
            THREAD CLOSE Resumestartthread TO nStatus
        END IF
        GRAPHIC REDRAW
     LOOP
     GRAPHIC WINDOW END
END FUNCTION
