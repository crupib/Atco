#DIM ALL

%UPARROW   = &h4800
%DOWNARROW = &h5000
%ENTER     = &h000D

DECLARE FUNCTION fncKeyPress() AS LONG
DECLARE SUB MainMenu()
DECLARE SUB DrawScreen()
DECLARE SUB DrawMenu()
DECLARE SUB DrawFrame (row1 AS LONG, row2 AS LONG, col1 AS LONG, col2 AS LONG, _
                       FgColor AS LONG, BgColor AS LONG, HiLite AS LONG)


FUNCTION PBMAIN () AS LONG

    CURSOR OFF
    CALL DrawScreen()

    LOCATE 23, 2 : COLOR 15, 1
    PRINT "Press the space bar to activate the menu"
    WAITKEY$


    CALL MainMenu()
    CURSOR ON

END FUNCTION

'======================================
'//////////////////////////////////////
'======================================

SUB MainMenu()

DO
    LOCAL iK             AS LONG          'stores the key pressed
    LOCAL sMenuItem()    AS STRING        'an array of menu choices
    LOCAL iMenuPosition  AS LONG          'the physical screen position of the menu item
    LOCAL iColPos        AS LONG          'the physical column position of the menu's left side
    LOCAL iChoice        AS LONG          'stores the menu item selected
    LOCAL i              AS LONG          'loop counter

    DIM sMenuItem(3 TO 8)                    'subscripts match the *physical* screen row of the
                                          'menu item.
    sMenuItem(3) = " New     "            'This is row 3 on the screen.. etc.
    sMenuItem(4) = " Save    "
    sMenuItem(5) = " Save As "
    sMenuItem(6) = " Rename  "
    sMenuItem(7) = " ------  "
    sMenuItem(8) = " Close   "

    iMenuPosition = 3                      'initial start positon in the menu.
    iColPos       = 5
    CALL DrawFrame (2, 9, 4, 13, 0, 3, 0)  'draws a frame around the menu items.

    DO
        FOR i = 3 TO 8
          IF iMenuPosition = i THEN COLOR 15, 1      'reverse color to highlight
          LOCATE i, iColPos                          'the current menu item.
          PRINT sMenuItem(i)
          COLOR 0, 3                                 'normal color for remaining menu items.
        NEXT                                         'this over-rides the previous menu colors
                                                     'if the current item does not equal the
                                                     'value of i

        iK = fncKeyPress                             'trap the key pressed.
        SELECT CASE(iK)
            CASE %UPARROW
                 iMenuPosition = iMenuPosition - 1
                 IF iMenuPosition = 7 THEN iMenuPosition = 6   'skip over the separator bar
            CASE %DOWNARROW
                 iMenuPosition = iMenuPosition + 1
                 IF iMenuPosition = 7 THEN iMenuPosition = 8
            CASE %ENTER
                 iChoice = iMenuPosition              '<ENTER> selects the menu choice
            EXIT DO
        END SELECT

        IF iMenuPosition < 3 THEN iMenuPosition = 8
        IF iMenuPosition > 8 THEN iMenuPosition = 3

    LOOP

    SELECT CASE iChoice

        CASE 3
            PCOPY 1, 2                                 'save the current screen
            CALL DrawFrame (10, 14, 20, 60, 0, 3, 15)
            LOCATE 12, 22
            PRINT "This is the NEW option"
            WAITKEY$
            PCOPY 2, 1                                 'restore the screen
        CASE 4
            PCOPY 1, 2
            CALL DrawFrame (10, 14, 20, 60, 0, 3, 15)
            LOCATE 12, 22
            PRINT "This is the SAVE option"
            WAITKEY$
            PCOPY 2, 1
        CASE 5
            PCOPY 1, 2
            CALL DrawFrame (10, 14, 20, 60, 0, 3, 15)
            LOCATE 12, 22
            PRINT "This is the SAVE AS option"
            WAITKEY$
            PCOPY 2, 1
        CASE 6
            PCOPY 1, 2
            CALL DrawFrame (10, 14, 20, 60, 0, 3, 15)
            LOCATE 12, 22
            PRINT "This is the RENAME option"
            WAITKEY$
            PCOPY 2, 1

        'CASE 7 -do nothing. this is the separator bar

        CASE 8            'Exits program
            EXIT

        CASE ELSE

    END SELECT
LOOP

END SUB

'///////////////////////////////////////////////
'==============================================
'//////////////////////////////////////////////

FUNCTION fncKeyPress () AS LONG
  DIM sKey AS LOCAL STRING
  sKey = WAITKEY$
  IF LEN(sKey) = 1 THEN            'not an extended ASCII code
     FUNCTION = ASC(sKey)
  ELSE
     FUNCTION = CVI(sKey)          'extneded ASCII code
  END IF
END FUNCTION

'///////////////////////////////////////////////
'==============================================
'//////////////////////////////////////////////

SUB DrawScreen()

    LOCAL i AS LONG
    LOCAL j AS LONG

    CALL DrawFrame (2, 24, 1, 79, 15, 0, 15)

    LOCATE 1, 1
    COLOR 3, 3
    PRINT STRING$(80, " ")

    COLOR 0, 3
    LOCATE 1, 5 : PRINT "File"
    '
    '
    COLOR 8, 0             'this will just print some jibberish to the window area
    FOR i = 3 TO 23
       LOCATE i, 2
       PRINT STRING$(78, CHR$(178))
    NEXT
    '
    '
END SUB

'////////////////////////////////////////////////
'===============================================
'////////////////////////////////////////////////

SUB DrawFrame (row1 AS LONG, row2 AS LONG, col1 AS LONG, col2 AS LONG, _
               FgColor AS LONG, BgColor AS LONG, HiLite AS LONG)

   LOCAL i AS LONG  'loop counter
   COLOR HiLite, BgColor
   LOCATE row1, col1
   PRINT CHR$(201); STRING$(col2 - col1, CHR$(205)); CHR$(187)
   INCR row1
   FOR i = row1 TO row2 - 1
       LOCATE i, col1
       COLOR HiLite, BgColor
       PRINT CHR$(186); STRING$(col2 - col1, " ");
       COLOR FgColor, Bgcolor
       PRINT CHR$(186)
   NEXT
   LOCATE row2, col1
   PRINT CHR$(200); STRING$(col2 - col1, CHR$(205)); CHR$(188)
END SUB
