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

THREAD FUNCTION MyThread (BYVAL nThread AS LONG) AS LONG
    LOCAL ix AS LONG
    LOCAL t  AS SINGLE
    PRINT "Start thread"; nThread
    t = TIMER
    FOR ix = 1 TO 100
        mysafethread(ix)
        SLEEP 100
    NEXT
    t = TIMER - t
    PRINT "End thread"; nThread
    PRINT "Elapsed time (100*100 ms) =" + STR$(t, 5)
    FUNCTION = -1   ' signal the monitor loop this thread is done.
END FUNCTION

THREAD FUNCTION MyInputThread (BYVAL escape_passed AS LONG) AS LONG
    DO
        GRAPHIC INKEY$ TO sKey
        SLEEP 1
        SELECT CASE LEN(sKey)
          CASE 1
          IF ASC(sKey) = 27 THEN EXIT LOOP    ' Esc to quit
        END SELECT
    LOOP
FUNCTION = -1

END FUNCTION

FASTPROC mysafethread (BYVAL printsem AS LONG) THREADSAFE AS LONG
 CON.LOC = 100, 100
 PRINT "In FastProc"
END FASTPROC = -1

THREAD FUNCTION MyStartStopThread (BYVAL Filler AS LONG) AS LONG
   DO
        PRINT "Running!"
   LOOP
   FUNCTION = -1
END FUNCTION

FUNCTION PBMAIN () AS LONG
 'Variables
 DIM MousePoint AS POINTAPI
 DIM XVar AS INTEGER
 DIM YVar AS INTEGER
 DIM idThread(1 TO 10) AS LONG

 GLOBAL inthread AS LONG
 GLOBAL Resumestartthread AS LONG

 LOCAL hGWin???, sKey$
 LOCAL ix AS LONG
 LOCAL nStatus AS LONG
 LOCAL escape_passed AS INTEGER

     GRAPHIC WINDOW "Graphic Window", 300, 300, 400, 300 TO hGWin
     GRAPHIC ATTACH hGWin, 0
     FONT NEW "Lucida Console",12,0,0,0,0 TO F1
     GRAPHIC SET FONT F1: GRAPHIC CHR SIZE TO W1,H1 ' Find pixel width and height of fnt1 graphic font
     escape_passed = 0
     THREAD CREATE MyInputThread(escape_passed) TO inthread

     DO WHILE GRAPHIC(DC)
        GRAPHIC GET DC TO hGwin: IF hGwin=0 THEN EXIT DO
        THREAD STATUS inthread TO nStatus
        IF nStatus = -1 THEN
            THREAD CLOSE inthread TO nStatus
        END IF
        GRAPHIC REDRAW
     LOOP
        GetCursorPos Mousepoint
        ScreenToClient hGwin, mousepoint
        GRAPHIC SET POS (0,0): GRAPHIC PRINT "X:";Mousepoint.x;"   Y:";Mousepoint.y;"    ": GRAPHIC REDRAW

        GRAPHIC WINDOW END
     LOOP
END FUNCTION

 PRINT "Let's start some threads!"
 FOR ix = LBOUND(idThread) TO UBOUND(idThread)
        THREAD CREATE MyThread(ix) TO idThread(ix)
        SLEEP 750
 NEXT
 PRINT "10 threads started."
 PRINT "Wait for them to finish!"

    ' Here, we simply loop until all threads return -1.
    ' A running thread returns a status of &H103.
    ' In a real program, you might prefer the WaitForMultipleObjects API call,
    ' which doesn't eat up CPU time the way this loop does.
 DO
      SLEEP 500
      FOR ix = LBOUND(idThread) TO UBOUND(idThread)
            THREAD STATUS idThread(ix) TO nStatus
            IF nStatus <> -1 THEN EXIT FOR
      NEXT
 LOOP WHILE nStatus <> -1
 PRINT "Finished! Hit anykey to continue"
 CON.WAITKEY$
    ' Here we set nStatus to > -1 (99)
    ' We create a thread for input and pass a value to escape_passed
    ' The thread runs for escape_count < escape_passed
    ' Then sends a status of -1 to have the pbmain close thread.
 nStatus = 99
 INPUT "Input escape_passed > " escape_passed
 PRINT "Input thread started"
 PRINT "Press escape "+STR$(escape_passed)+" times"

PRINT "Input routine finished"
PRINT "Hit anykey to continue"
CON.WAITKEY$
PRINT "Pause and Resume"
PRINT "Type p to pause thread"
PRINT "Type r to resume thread"
PRINT "Hit escape to close thread"
CON.WAITKEY$
THREAD CREATE MyStartStopThread(0) TO Resumestartthread
DO
    CON.INKEY$ TO sKey$
    SLEEP 1
    SELECT CASE LEN(sKey$)
      CASE 1
      IF ASC(sKey$) = 27 THEN
        PRINT "Pressed escape key"
        EXIT LOOP
      END IF
      IF sKey$ = "r" THEN
        CON.CLS
        PRINT "Resume"
        THREAD RESUME Resumestartthread TO lResult&
      END IF
      IF sKey$ = "p" THEN
        CON.CLS
        PRINT "Pause"
        THREAD SUSPEND Resumestartthread TO lResult&
      END IF
    END SELECT
LOOP
PRINT "Program ended, press any key to continue (end program)"
CON.WAITKEY$

'------------------/GWProc
    CON.CELL = 50,50
           CON.PRINT "|"
           CON.CELL = 50,50
           CON.PRINT "/"
           CON.CELL = 50,50
           CON.PRINT "-"
           CON.CELL = 50,50
           CON.PRINT "|"
           CON.CELL = 50,50
           CON.PRINT "\"
           CON.CELL = 50,50
           CON.PRINT "-"
           CON.CELL = 50,50
