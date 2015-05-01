#COMPILE EXE
#DIM ALL
#INCLUDE "Win32API.inc"
#RESOURCE ICON, exeICON, "ATCO.ico"
DEFINT A-Z
#INCLUDE "ATCO.inc"
#INCLUDE "AtcoSer.inc"
#INCLUDE "mywindows.inc"
#INCLUDE "File.inc"
FUNCTION PBMAIN () AS LONG
'*******************************************************************************************************
'MCU                                                                                                   *
'*******************************************************************************************************
    DIM HdrVer AS STRING * 20
    DIM ThumbDisk AS STRING * 2
  'COM PORTS
    DIM  RecvSize AS LONG
    DIM  XmitSize AS LONG
    DIM  MemSize AS LONG
    DIM  PICPort AS STRING
    DIM  PICBaud AS LONG
    DIM KeyTable(20) AS STRING
  'delay timer
    DIM  DelayCtr AS LONG
    DIM  WaitX AS INTEGER
    DIM  LF(0 TO 255)
    DIM  LU(0 TO 255)
    DIM  Corr1(0 TO 255) AS BYTE
    DIM  Corr2(0 TO 255) AS BYTE
  'Vel & Accel pot tables
    DIM  XVel(255) AS LONG
    DIM  YVel(255) AS LONG
    DIM  XAcel(255) AS LONG
    DIM  YAcel(255) AS LONG
  'Speed Control tables
    DIM  XSpd(0 TO 255)
    DIM  YSpd(0 TO 255)
    DIM  StartLPos(3) AS BYTE
    DIM  CalSet AS INTEGER
    DIM lResult AS LONG
  '****************************************************************************************************
    HdrVer = "SCU-1.00"
    ThumbDisk = "C:\UCALS\"
    PICPort ="COM1"
    PICBaud = 19200
    nComm = FREEFILE
    DelayCtr = DelayFact
    WaitX = 1
    'joystick to pwm conversion table
    CALL SetTables
    StartLPos(0) = &H0
    StartLPos(1) = &H40
    StartLPos(2) = &H14
    StartLPos(3) = &H54
  'new keypad layout
    KeyTable(0) = ""
    KeyTable(1) = CHR$(0) + CHR$(77) 'RgtArrow
    KeyTable(2) = CHR$(0) + CHR$(75) 'LftArrow
    KeyTable(3) = CHR$(0) + CHR$(80) 'DnArrow
    KeyTable(4) = CHR$(0) + CHR$(72) 'UpArrow
    KeyTable(5) = CHR$(13)           'Ent
    KeyTable(6) = CHR$(32)           'Space
    KeyTable(7) = CHR$(8)            'BkSpace
    KeyTable(8) = CHR$(27)           'ESC
    KeyTable(9) = CHR$(46)           '.
    KeyTable(10) = CHR$(57)          '9
    KeyTable(11) = CHR$(54)          '6
    KeyTable(12) = CHR$(51)          '3
    KeyTable(13) = CHR$(48)          '0
    KeyTable(14) = CHR$(56)          '8
    KeyTable(15) = CHR$(53)          '5
    KeyTable(16) = CHR$(50)          '2
    KeyTable(17) = CHR$(46)          '.
    KeyTable(18) = CHR$(55)          '7
    KeyTable(19) = CHR$(52)          '4
    KeyTable(20) = CHR$(49)          '1
    DIM  ExtKey(49 TO 57, 0 TO 3) AS INTEGER
    ExtKey(49, 0) = 49: ExtKey(49, 1) = 65: ExtKey(49, 2) = 66: ExtKey(49, 3) = 67
    ExtKey(50, 0) = 50: ExtKey(50, 1) = 68: ExtKey(50, 2) = 69: ExtKey(50, 3) = 70
    ExtKey(51, 0) = 51: ExtKey(51, 1) = 71: ExtKey(51, 2) = 72: ExtKey(51, 3) = 73
    ExtKey(52, 0) = 52: ExtKey(52, 1) = 74: ExtKey(52, 2) = 75: ExtKey(52, 3) = 76
    ExtKey(53, 0) = 53: ExtKey(53, 1) = 77: ExtKey(53, 2) = 78: ExtKey(53, 3) = 79
    ExtKey(54, 0) = 54: ExtKey(54, 1) = 80: ExtKey(54, 2) = 81: ExtKey(54, 3) = 82
    ExtKey(55, 0) = 55: ExtKey(55, 1) = 83: ExtKey(55, 2) = 84: ExtKey(55, 3) = 85
    ExtKey(56, 0) = 56: ExtKey(56, 1) = 86: ExtKey(56, 2) = 87: ExtKey(56, 3) = 88
    ExtKey(57, 0) = 57: ExtKey(57, 1) = 89: ExtKey(57, 2) = 90: ExtKey(57, 3) = 196
   '***********************************************
   'Open & Check Com Buffers, Report & Fix errors
   '
   '  - check PIC, power on, etc..
   '***********************************************
 '   IF NOT OpenComPorts THEN
 '    MSGBOX "ERROR, POWER OFF/ON",, "OpenComPorts serial connection failed."
 '    DO
 '     EXIT FUNCTION
 '    LOOP
 '   END IF

 '   IF NOT InitNetWork THEN
 '    lResult& = MSGBOX("SETUP ERROR", %MB_OKCANCEL OR %MB_DEFBUTTON2 OR %MB_TASKMODAL, "InitNetWork Failed.")
 '    DO
 '      CALL DelayX(200)
 '      IF lResult& = %IDCANCEL THEN
 '          EXIT FUNCTION
 '      END IF
 '    LOOP UNTIL InitNetWork
 '   END IF
    DIM GloErr AS INTEGER

    CalSet = FALSE
    IF NOT KeyDown THEN  'do not load if user has key pressed
      IF CalLoad(ThumbDisk + "0.M2K") THEN
       CalSet = TRUE
      END IF
    END IF

  'if no cal on disk or corrupt then set defaults
    IF NOT CalSet THEN
      CALL SetDefaults
    END IF
    Scanstruc.NextFlag = FALSE 'incase cal was saved during scan
    CALL SetForAuto  'set velocity, etc. & motors on

    CALL DelayX(2000)


    IsSplashActive = 1
    ShowSplashDlg(5000, "atcosplash.bmp", 1, "MCU 2015",1)
    BUILDWINDOW()
    DIALOG SHOW MODAL hDlg, CALL DlgProc


END FUNCTION
