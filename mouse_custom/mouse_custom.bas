'Generate Mouse Pointer
'kevinl@atcondt.com   6/19/16   Keep this message at the top of your inbox
'To: Bill Crupi Cc: William Crupi
'new mouse Cursor
#COMPILE EXE
#DIM ALL
#CONSOLE OFF
#REGISTER NONE
DEFLNG A-Z
#INCLUDE "Win32Api.Inc"

FUNCTION PBMAIN () AS LONG
DIM PBhand AS GLOBAL DWORD
DIM AndArray(1 TO 128) AS GLOBAL BYTE
DIM XorArray(1 TO 128) AS GLOBAL BYTE
DIM hCursorHand AS GLOBAL DWORD
DIM hCursorHand2 AS DWORD
DIM eNull AS LOCAL DWORD
DIM ink AS STRING
LOCAL hWin AS LONG
GRAPHIC WINDOW "Show Cursor Position and input any characters.  Return for next line.  Esc to end.",0,0,800,600 TO hwin
GRAPHIC ATTACH hWin, 0, REDRAW

'load array

HandCur AndArray(), XorArray() 'Get Hand data arrays api

hCursorHand = CreateCursor(%NULL, 5, 2, 32, 32, VARPTR(AndArray(1)), VARPTR(XorArray(1)))

SetCursor hCursorHand

hCursorHand2 = CopyCursor(hCursorHand)        'copy your custom cursor because SetSystemCursor destroys it !!!

SetSystemCursor(hCursorHand2,%OCR_NORMAL)     'set cursor to your cursor
DO
   GRAPHIC INKEY$ TO ink: SLEEP 1
  '---------------------------------------------------------------------------------------------
   GRAPHIC REDRAW
 LOOP UNTIL ink=CHR$(27)

SystemParametersInfo(%SPI_SETCURSORS, 0, eNULL, 0)  'set cursor back to system normal  - arrow


GRAPHIC WINDOW END

END FUNCTION
'-----------------------------------------------------------------------------
'
'Load Hand Cursor array
'-----------------------------------------------------------------------------
FUNCTION HandCur(AndArray() AS BYTE, XorArray() AS BYTE)AS LONG
LOCAL Counter AS LONG

FOR Counter = 1 TO 128
AndArray(Counter) = VAL("&H" & READ$(Counter))
NEXT

FOR Counter = 1 TO 128
XorArray(Counter) = VAL("&H" & READ$(Counter + 128))
NEXT

'And Array
DATA ff, ff, ff, ff, f9, ff, ff, ff, f0, ff, ff, ff, f0, ff, ff, ff
DATA f0, ff, ff, ff, f0, ff, ff, ff, f0, 24, ff, ff, f0, 00, 7f, ff
DATA c0, 00, 7f, ff, 80, 00, 7f, ff, 80, 00, 7f, ff, 80, 00, 7f, ff
DATA 80, 00, 7f, ff, 80, 00, 7f, ff, c0, 00, 7f, ff, e0, 00, 7f, ff
DATA f0, 00, ff, ff, f0, 00, ff, ff, f0, 00, ff, ff, ff, ff, ff, ff
DATA ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff
DATA ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff
DATA ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff, ff
'XOr Array
DATA 00, 00, 00, 00, 00, 00, 00, 00, 06, 00, 00, 00, 06, 00, 00, 00
DATA 06, 00, 00, 00, 06, 00, 00, 00, 06, 00, 00, 00, 06, db, 00, 00
DATA 06, db, 00, 00, 36, db, 00, 00, 36, db, 00, 00, 37, ff, 00, 00
DATA 3f, ff, 00, 00, 3f, ff, 00, 00, 1f, ff, 00, 00, 0f, ff, 00, 00
DATA 07, fe, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
DATA 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
DATA 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
DATA 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00

END FUNCTION
