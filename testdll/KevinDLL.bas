'==============================================================================
'
'                   Atco Source code testing program.
'
'==============================================================================

#COMPILE EXE
#INCLUDE ONCE "Win32api.inc"
TYPE ScanParms
   YCtr          AS SINGLE       'YCts/inch
   XCtr          AS SINGLE       'XCts/inch
   ACtr          AS SINGLE       'Aux Enc Cts/inch
   YCal          AS SINGLE       'Y Cal Inch distance
   XCal          AS SINGLE       'X Cal Inch distance
   ACal          AS SINGLE       'Aux Cal Inch distance
   XOffset       AS SINGLE       'X inch pos when counter zeroed
   YOffset       AS SINGLE       'Y inch pos when counter zeroed
   AOffset       AS SINGLE       'A Inch pos when counter zeroed
   XPos          AS SINGLE       'current X inch position
   YPos          AS SINGLE       'current Y inch position
   APos          AS SINGLE       'current A inch position
   XPlus         AS INTEGER      'X scan +/-
   YPlus         AS INTEGER      'Y scan +/-
   XDataStart    AS LONG         'x array position for scan start
   YDataStart    AS LONG         'y array position for scan start
   XDataEnd      AS LONG         'x array position for scan end
   YDataEnd      AS LONG         'y array position for scan end
   XIndex        AS SINGLE       'x inch index
   YIndex        AS SINGLE       'y inch index
   XIndexCts     AS LONG         'x actual value (+/-) counts per index
   YIndexCts     AS LONG         'y actual value (+/-) counts per index
   IndexLow      AS INTEGER      'Index towards High or Low
   XCts          AS LONG         'x absolute value scan start counts
   YCts          AS LONG         'y absolute value scan start counts
   ACts          AS LONG         'A absolute value scan start counts
   XStartCts     AS LONG         'x actual value (+/-) scan start counts
   YStartCts     AS LONG         'y actual value (+/-) scan start counts
   XEndCts       AS LONG         'x actual value (+/-) scan end counts
   YEndCts       AS LONG         'y actual value (+/-) scan end counts
   XLow          AS SINGLE       'x scan start inch position
   YLow          AS SINGLE       'y scan start inch position
   XHigh         AS SINGLE       'x scan end inch position
   YHigh         AS SINGLE       'y scan end inch position
   OverLap       AS SINGLE       'added si scan overlap
   XSpeed        AS SINGLE       'x scan speed in inches
   YSpeed        AS SINGLE       'y scan speed in inches
   XEnable       AS INTEGER      'flag true/false X axis on
   YEnable       AS INTEGER      'flag true/false Y axis on
   XSpdDir       AS INTEGER      'flag X speed cntrl direction
   IndexY        AS INTEGER      'flag true/false X or Y
   StopChk       AS INTEGER      'flag true/false autoOff on/off
   DualRas     AS INTEGER      'flag true/false step index
   AutoHold      AS INTEGER      'flag true/false Auto Hold
   IndexCt AS INTEGER            'index loop counter
   IndexInc AS INTEGER           'index loop incrementer
   ScanFlag AS INTEGER           '
   Index AS INTEGER              'scan direction
   NextFlag AS INTEGER           'added for si auto scan increment
   YCtrStr AS STRING * 10
   XCtrStr AS STRING * 10
   ACtrStr AS STRING * 10
   YCalStr AS STRING * 10      'Y Cal Inch distance
   XCalStr AS STRING * 10      'X Cal Inch distance
   ACalStr AS STRING * 10      'A Cal Inch distance
   XPosStr AS STRING * 10
   YPosStr AS STRING * 10
   APosStr AS STRING * 10
   XPlusSTR AS STRING * 10
   YPlusSTR AS STRING * 10
   XIndexSTR AS STRING * 10
   YIndexSTR AS STRING * 10
   IndexLowStr AS STRING * 10
   XLowStr AS STRING * 10
   YLowStr AS STRING * 10
   XHighStr AS STRING * 10
   YHighStr AS STRING * 10
   OverLapStr AS STRING * 10
   XSpeedSTR AS STRING * 10
   YSpeedSTR AS STRING * 10
   XEnableSTR AS STRING * 10
   YEnableSTR AS STRING * 10
   XSpdDirSTR AS STRING * 10
   IndexYSTR AS STRING * 10
   StopChkSTR AS STRING * 10
   DualRasSTR AS STRING * 10
   NextFlagSTR AS STRING * 10
   AutoHoldSTR AS STRING * 10
  END TYPE
MACRO CONST = MACRO
CONST KeyUP = 72
CONST KeyDN = 80
CONST KeyLft = 75
CONST KeyRgt = 77
CONST KeyEsc = 27
CONST KeyEnter = 13
GLOBAL SCANstruc AS scanparms

'--------------------------------------------------------------------
DECLARE FUNCTION LOAD_FILE LIB "MYDLL.DLL" _
          ALIAS "Load_File" () AS STRING
DECLARE FUNCTION SAVE_FILE LIB "MYDLL.DLL" _
          ALIAS "Save_File" () AS STRING
DECLARE FUNCTION SETUP_CALL LIB "MYDLL.DLL" _
          ALIAS "SETUP_CALL" (BYREF parm1 AS scanparms) AS STRING
DECLARE FUNCTION MyFunction1 LIB "MYDLL.DLL" _
          ALIAS "MyFunction1" (BYVAL Param1 AS LONG) AS LONG
'--------------------------------------------------------------------

FUNCTION PBMAIN () AS LONG
    LOCAL filename AS STRING
    LOCAL setupcall AS STRING
    LOCAL lRes AS LONG
    LOCAL hwnd AS LONG
    LOCAL ROW, COL, tmprow, tmpcol AS LONG
    LOCAL keynum AS STRING
    LOCAL Q AS LONG
  '  lRes = MyFunction1(lRes)
  '  filename =  LOAD_FILE()
  '  PRINT filename
  '  WAITKEY$
    ROW = 25
    COL = 80

    CON.SCREEN = ROW, COL

    CON.PRINT   " Setup        AutoScan"
    CON.PRINT   " JoyStk       XSPD CTRL"
    CON.PRINT   " A-JOG        M-JOG"
    CON.PRINT   " SAVE         LOAD"
    ROW = 1
    COL = 1
    CON.CELL = ROW,COL
    CON.PRINT ">"
    ROW = 1
    COL = 1
    CON.CELL = ROW,COL
    DO
        CON.INKEY$ TO keynum
        IF LEN(keynum) > 1 THEN
             Q=ASC(RIGHT$(keynum,1))
             IF Q =  KeyRgt  THEN
                 IF COL < 14 THEN
                    PRINT " "
                    COL = 14
                 END IF
                 IF COL = 14 THEN
                        CON.CELL = ROW,COL
                        PRINT ">"
                 END IF
                 CON.CELL = ROW,COL
             END IF
             IF Q =  KeyLft  THEN
                 IF COL > 1 THEN
                    PRINT " "
                    COL = 1
                    IF COL = 1 THEN
                        CON.CELL = ROW,COL
                        PRINT ">"
                        COL = 1
                    END IF
                    IF COL = 13 THEN
                        PRINT " "
                    END IF
                 END IF
                 CON.CELL = ROW,COL
             END IF
             IF Q =  Keydn  THEN
                 IF ROW < 4 THEN
                    ROW = ROW + 1
                 END IF
                 IF COL = 1 THEN
                     ROW = ROW - 1
                     CON.CELL = ROW,COL
                     PRINT " "
                     ROW = ROW + 1
                     PRINT ">"
                 END IF
                 IF COL = 14 THEN
                     CON.CELL = ROW,COL
                     PRINT ">"
                     ROW = ROW - 1
                     CON.CELL = ROW,COL
                     PRINT " "
                     ROW = ROW + 1
                 END IF
                 CON.CELL = ROW,COL
             END IF
             IF Q =  Keyup  THEN
                 IF ROW > 1 THEN
                    ROW = ROW - 1
                 END IF
                 IF COL = 1 THEN
                     CON.CELL = ROW,COL
                     PRINT ">"
                     ROW = ROW + 1
                     CON.CELL = ROW,COL
                     PRINT " "
                     ROW = ROW - 1
                 END IF
                 IF COL = 14 THEN
                     CON.CELL = ROW,COL
                     PRINT ">"
                     ROW = ROW + 1
                     CON.CELL = ROW,COL
                     PRINT " "
                     ROW = ROW - 1
                 END IF
                 CON.CELL = ROW,COL
             END IF
        ELSE
            Q=ASC(keynum)
            IF Q=KeyEsc THEN
              EXIT DO
            END IF
            IF Q=KeyEnter THEN
              IF ROW = 1 AND COL = 1 THEN
                setupcall = SETUP_CALL(SCANstruc)
              END IF
              IF ROW = 2 AND COL = 1 THEN
                tmprow = 15
                tmpcol = 20
                CON.CELL = tmprow,tmpcol
                PRINT "Joystk not implemenetd"
                SLEEP 3600
                CON.CELL = tmprow,tmpcol
                PRINT "                      "
                CON.CELL = ROW,COL
              END IF
              IF ROW = 3 AND COL = 1 THEN
                tmprow = 15
                tmpcol = 20
                CON.CELL = tmprow,tmpcol
                PRINT "A-Jog not implemenetd"
                SLEEP 3600
                CON.CELL = tmprow,tmpcol
                PRINT "                      "
                CON.CELL = ROW,COL
              END IF
              IF ROW = 4 AND COL = 1 THEN
                filename = SAVE_FILE()
              END IF
              IF ROW = 4 AND COL = 14 THEN
                filename =  LOAD_FILE()
              END IF
              IF ROW = 1 AND COL = 14 THEN
                tmprow = 15
                tmpcol = 20
                CON.CELL = tmprow,tmpcol
                PRINT "AutoScan not implemented"
                SLEEP 3600
                CON.CELL = tmprow,tmpcol
                PRINT "                        "
                CON.CELL = ROW,COL
              END IF
              IF ROW = 2 AND COL = 14 THEN
                tmprow = 15
                tmpcol = 20
                CON.CELL = tmprow,tmpcol
                PRINT "XSPD CTRL not implemented"
                SLEEP 3600
                CON.CELL = tmprow,tmpcol
                PRINT "                         "
                CON.CELL = ROW,COL
              END IF
              IF ROW = 3 AND COL = 14 THEN
                tmprow = 15
                tmpcol = 20
                CON.CELL = tmprow,tmpcol
                PRINT "M-JOG     not implemented"
                SLEEP 3600
                CON.CELL = tmprow,tmpcol
                PRINT "                         "
                CON.CELL = ROW,COL
              END IF
            END IF
        END IF
    LOOP

  '  ScanStruc.XPlusSTR = "Test"
  '  setupcall = SETUP_CALL(SCANstruc)
  '  PRINT SCANstruc.XPlusSTR
  '  IF SCANstruc.xplusstr <> "NEGITIVE" THEN
   '    scanstruc.xplusstr = "NOT VALID"
  '     setupcall = SETUP_CALL(SCANstruc)
   ' END IF
'   filename = SAVE_FILE()
'    PRINT filename
END FUNCTION
