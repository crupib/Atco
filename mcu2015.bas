#COMPILE EXE
#DIM ALL
#INCLUDE "Win32API.inc"
#RESOURCE ICON, exeICON, "ATCO.ico"
DEFINT A-Z
#INCLUDE "ATCO.inc"
#INCLUDE "AtcoSer.inc"
#INCLUDE "mywindows.inc"
#INCLUDE "File.inc"
#INCLUDE "splash.inc"    'used for splash screen

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
    DIM  lResult AS LONG
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

   '***********************************************
   'Open & Check Com Buffers, Report & Fix errors
   '
   '  - check PIC, power on, etc..
   '***********************************************
    IsSplashActive = 1
    ShowSplashDlg(1000, "atcosplash.bmp", 1, "MCU 2015",1)
    IF NOT OpenComPorts THEN
     MSGBOX "ERROR, POWER OFF/ON",, "OpenComPorts serial connection failed."
     DO
      EXIT FUNCTION
     LOOP
    END IF
    IF NOT InitNetWork THEN
     lResult& = MSGBOX("SETUP ERROR", %MB_OKCANCEL OR %MB_DEFBUTTON2 OR %MB_TASKMODAL, "InitNetWork Failed.")
     DO
       CALL DelayX(200)
       IF lResult& = %IDCANCEL THEN
           EXIT FUNCTION
       END IF
     LOOP UNTIL InitNetWork
    END IF
    CALL SetDefaults
    Scanstruc.NextFlag = FALSE 'incase cal was saved during scan
    CALL SetForAuto  'set velocity, etc. & motors on
    CALL DelayX(200)
    BUILDWINDOW()
    DIALOG SHOW MODAL hDlg, CALL DlgProc


END FUNCTION
