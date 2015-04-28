#COMPILE EXE
#DIM ALL
#INCLUDE "Win32API.inc"
#RESOURCE ICON, exeICON, "ATCO.ico"
DEFINT A-Z
#INCLUDE "ATCO.inc"
#INCLUDE "AtcoSer.inc"
'************************************************************************************
'* Motor control Functions
DECLARE FUNCTION IntToStr$ (x AS INTEGER)
FUNCTION IntToStr$ (x AS INTEGER)

   B = (x AND &HFF)
   A = (((x AND &HFF00&) \ 256&) AND &HFF )

   IntToStr = CHR$(B) + CHR$(A)

END FUNCTION
DECLARE FUNCTION CharsToInt (BYVAL A AS INTEGER, B AS INTEGER)
FUNCTION CharsToInt (BYVAL A AS INTEGER, B AS INTEGER)
'converts two bytes, (a=msb) to a signed integer

 IF (A > 127) THEN
    A = A - 128
    CharsToInt = (A * 256& + B) OR (&H8000)
    EXIT FUNCTION
 ELSE
    CharsToInt = A * 256& + B
    EXIT FUNCTION
 END IF

END FUNCTION

DECLARE FUNCTION SIOGetByte (Character AS INTEGER, TimeOutPeriod AS INTEGER)
FUNCTION SIOGetByte (Character AS INTEGER, TimeOutPeriod AS INTEGER)
 LOCAL OneChr AS STRING
 LOCAL STime, Stime2 AS LONG
 LOCAL BytesRead, ECode AS INTEGER
 REM  Changed to PC serial port routine

 OneChr$ = " "

 STime& = GetTick&
 'loop till we get a byte from the serial port or timeout
 DO

    CALL ReadFromComm(PICPort, OneChr$, BytesRead, ECode%)

    IF BytesRead > 0 THEN
      Character = ASC(OneChr$)
      SIOGetByte = TRUE
      EXIT FUNCTION
    END IF
    Stime2& = getTick&
    IF (ABS(Stime2& - STime&) > 1000) THEN
      SIOGetByte = FALSE
      EXIT FUNCTION
    END IF

 LOOP

END FUNCTION

DECLARE FUNCTION DelayFact& ()
FUNCTION DelayFact&

   'determine cts per milisec
   LOCAL T,x AS DOUBLE
   LOCAL CtrBegin AS LONG
   LOCAL CtrEnd,Ctr   AS LONG
   T# = TIMER 'times in seconds

   DO
     CtrBegin& = CtrEnd& + 1: CtrEnd& = CtrBegin& + 100000
     FOR Ctr& = CtrBegin& TO CtrEnd&: NEXT
     x# = TIMER - T#  'rollover at midnight, careful here!
   LOOP UNTIL x# > .5 'be > .5 seconds for accuracy and rollover

   DelayFact = Ctr& / (x# * 1000)  'divide counter by 1000 (millisecs)

   EXIT FUNCTION

END FUNCTION
DECLARE FUNCTION GetTick& ()
FUNCTION GetTick& ()
    GetTick& = GetTickCount()
END FUNCTION
'************************************************************************************
' MCU SUBS
DECLARE SUB SetTables ()
SUB SetTables
  LOCAL x AS INTEGER

  '**************************************************************************
  '                   JoyStick Conversion Table
  '**************************************************************************

  'Correction factor for Left/Right
  FOR x = 0 TO 59
    Corr2(x) = 0   '0 to 29 = 0
  NEXT
  FOR x = 60 TO 100
   Corr2(x) = CINT((x - 60) / 40 * 127)   '30 to 100 = 0 to 127
  NEXT
  FOR x = 100 TO 173
   Corr2(x) = 127     '100 to 173 = 127
  NEXT
  FOR x = 174 TO 255
   Corr2(x) = CINT((x - 174) / 81 * 128) + 127 '174 to 255 = 127 to 255
  NEXT

  'Correction factor for up/dn
  FOR x = 0 TO 29
    Corr1(x) = 0   '0 to 29 = 0
  NEXT
  FOR x = 30 TO 125
   Corr1(x) = CINT((x - 30) / 95 * 127)   '30 to 125 = 0 to 127
  NEXT
  FOR x = 125 TO 150
   Corr1(x) = 127     '125 to 150 = 127
  NEXT
  FOR x = 151 TO 255
   Corr1(x) = CINT((x - 151) / 104 * 128) + 127 '151 to 255 = 127 to 255
  NEXT

  FOR x = 0 TO 63
     LF(x) = CINT(-((63 - x) / 63 * 100)) '0 to 63 = -100% to 0%
     LF(255 - x) = LF(x)                  '255 to 192 =-100% to 0%
  NEXT

  FOR x = 64 TO 127
     LF(x) = CINT((x - 64) / 63 * 100)    '64 to 127 = 0% to 100%
     LF(255 - x) = LF(x)                  '191 to 128 = 0% to 100%
  NEXT

  'Speed table for forward/reverse crawler motion
  FOR x = 127 TO 255
    LU(x) = CINT((x - 127) / 128 * 100)   '127 to 255 = 0% to 100%
  NEXT
  FOR x = 0 TO 126
    LU(x) = CINT((126 - x) / 126 * -100)  '0 to 126 = -100% to 0%
  NEXT

  '**************************************************************************
  '                  End JoyStick Conversion Table
  '**************************************************************************

  'Velocity Mode Tables
  'velocity = (((RPM / 60) * EncCts\Rev) / ServoTics) * 65536
  LOCAL MaxXVel, MaxYVel AS LONG
  MaxXVel& = (((6150 / 60) * 2000) / 1953) * 65536
  MaxYVel& = (((10000 / 60) * 2000) / 1953) * 65536

  'accel = velocity / ( #secstovel * ServoTics )
  FOR x = 0 TO 5
    XVel(x) = 0
    XAcel(x) = 0
    YVel(x) = 0
    YAcel(x) = 0
  NEXT

  FOR x = 6 TO 255
    XVel(x) = CLNG((MaxXVel& / 249) * (x - 6))
    XAcel(x) = CLNG(XVel(x) / (.5 * 1953))
    YVel(x) = CLNG((MaxYVel& / 249) * (x - 6))
    YAcel(x) = CLNG(YVel(x) / (.5 * 1953))
  NEXT

  'speed control tables
  FOR x = 0 TO 5
    XSpd(x) = 0
    YSpd(x) = 0
  NEXT

  FOR x = 6 TO 255
    XSpd(x) = CINT((255 / 249) * (x - 6))
    YSpd(x) = CINT((255 / 249) * (x - 6))
  NEXT
END SUB
DECLARE FUNCTION CharsToLong& (BYVAL A AS INTEGER, B AS INTEGER, C AS INTEGER, D AS INTEGER)
FUNCTION CharsToLong& (BYVAL A AS INTEGER, B AS INTEGER, C AS INTEGER, D AS INTEGER)

 'Converts four bytes, (a=msb) to a signed long integer

 IF (A > 127) THEN
    A = A - 128
    CharsToLong = (A * 16777216 + B * 65536 + C * 256& + D) OR (&H80000000)
    EXIT FUNCTION
 ELSE
    CharsToLong = A * 16777216 + B * 65536 + C * 256& + D
    EXIT FUNCTION
 END IF
END FUNCTION

DECLARE FUNCTION LongToStr$ (x AS LONG)
FUNCTION LongToStr$ (x AS LONG)

   D = (x AND &HFF)
   C = ((x AND &HFF00&) \ 256& )
   B = ((x AND &HFF0000) \ 65536  )
   A = (((x AND &HFF000000) \ 16777216) AND &HFF)
   LongToStr = CHR$(D) + CHR$(C) + CHR$(B) + CHR$(A)
END FUNCTION

DECLARE FUNCTION InitNetWork ()
FUNCTION InitNetWork
  LOCAL ECode,i  AS INTEGER
  LOCAL Cmd AS STRING
  'Initial Varibles
  Glo.SIOErrorMode = DoNothing
  Glo.SIOError = 0
  Glo.CkSumError = FALSE
  Glo.NumModules = 0
  Glo.AmpQuery = TRUE
  Glo.PowerQuery = TRUE

  FOR i = 1 TO 5
     Glo.StatusDef(i) = 0
     Glo.ModuleType(i) = -1
     Glo.Position(i) = 0
     Glo.CmdPosition(i) = 0
     Glo.HomePosition(i) = 0
     Glo.velocity(i) = 0
     Glo.CmdVelocity(i) = 0
     Glo.CmdAccel(i) = 0
     Glo.CmdPwm(i) = 0
     Glo.AdVal(i) = 0
     Glo.Stat(i) = 0
     Glo.AuxStat(i) = 0
     IF i <> 3 THEN
       Glo.Kp(i) = 300
       Glo.Ki(i) = 200
       Glo.Kd(i) = 8000
       Glo.IL(i) = 40
     ELSE  'Y-Axis - Changed for new OPA-549 Power Amps used for Matrix
       Glo.Kp(i) = 200
       Glo.Ki(i) = 100
       Glo.Kd(i) = 2000
       Glo.IL(i) = 10
     END IF
     Glo.ol(i) = 255
     Glo.CL(i) = 0
     Glo.EL(i) = 16384
     Glo.SRD(i) = 1
     Glo.MiscMode(i) = PWMSelected
  NEXT i

  'start network

  'flush the input buffer
  CALL FlushBuffers(PICPort$, 0, ECode%)

  Glo.SIOErrorMode = DoNothing

  'reset controllers
  Cmd$ = CHR$(&HF)  'reset all modules
  SendCmd AllServos, Cmd$
  CALL DelayX(200)

  FOR i = 1 TO 5

    Cmd$ = CHR$(&H21) + CHR$(i) + CHR$(&HFF) 'set address
    SendCmd 0, Cmd$
    IF Glo.SIOError THEN EXIT FOR

    'define what status is requested from PIC, set for device id only
    Glo.StatusDef(i) = &H20
    Cmd$ = CHR$(&H12) + CHR$(Glo.StatusDef(i))
    SendCmd i, Cmd$
    IF Glo.SIOError THEN EXIT FOR

    IF Glo.ModuleType(i) = 0 THEN  'pic servo
      CALL SetAccel(i)
      CALL SetGain(i)
      Glo.NumModules = Glo.NumModules + 1
    ELSEIF Glo.ModuleType(i) = 2 THEN 'pic i/o
      Glo.NumModules = Glo.NumModules + 1
    ELSE                'unknown
      EXIT FOR
    END IF

  NEXT

  IF Glo.NumModules <> 5 THEN 'Failed
    InitNetWork = FALSE
    EXIT FUNCTION
  END IF

  'set status return for servos
  Glo.StatusDef(1) = &H3: Glo.StatusDef(2) = &H3: Glo.StatusDef(3) = &H3
  Glo.StatusDef(4) = &H3: Glo.StatusDef(5) = &HE: Cmd$ = CHR$(&H12) + CHR$(&H3)
  SendCmd AllServos, Cmd$

  'set status return for IO
  Cmd$ = CHR$(&H12) + CHR$(&HE) '
  SendCmd InOut1, Cmd$

  'reset group command for pic-servo #4 to 253
  Cmd$ = CHR$(&H21) + CHR$(4) + CHR$(&HFD) 'set address
  SendCmd 4, Cmd$

  'reset group command for pic-io to 254
  Cmd$ = CHR$(&H21) + CHR$(5) + CHR$(&HFE) 'set address
  SendCmd 5, Cmd$

  'disable amp on Servo 4 since enabling disables servo
  CALL EnableAmpl(0, 4)

  CALL FlushBuffers(PICPort$, 0, ECode%)

  InitNetWork = TRUE

  EXIT FUNCTION

END FUNCTION


DECLARE SUB SendCmd (address AS WORD, CmdString AS STRING)
SUB SendCmd (address AS WORD, CmdString AS STRING)
  LOCAL Cksum AS WORD
  LOCAL CCksum AS WORD
  LOCAL SendStr AS STRING
  LOCAL StrLen, i AS INTEGER
  LOCAL BytesWritten, ECode AS INTEGER
  LOCAL ACTPOS AS LONG
  Cksum = address

  Glo.SIOError = FALSE

  FOR i = 1 TO LEN(CmdString)
     Cksum = Cksum + ASC(MID$(CmdString, i, 1))
  NEXT i
  Cksum = (Cksum AND 255)

  'Send the command

  SendStr$ = CHR$(&HAA) + CHR$(address) + CmdString + CHR$(Cksum)

  StrLen = LEN(SendStr$)

  CALL WriteToComm(PICPort$, SendStr$, BytesWritten, ECode%)

  'no reply if group command
  IF address = &HFF THEN
    GOTO GrpCmdExit
  END IF

  'Get new address value if change address command
  IF ASC(MID$(CmdString, 1, 1)) = &H21 THEN address = ASC(MID$(CmdString, 2, 1))

  IF address = 0 THEN address = 1 'for testing on axis 0

  'Get the status byte
  IF SIOGetByte(Glo.Stat(address), 1) = FALSE THEN
    GOTO NoStatExit
  END IF

  Cksum = Glo.Stat(address)
  IF Glo.ModuleType(address) = 0 THEN 'pic servo

    'Get position data
    IF (Glo.StatusDef(address) AND SendPos) THEN
      IF SIOGetByte(D, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(C, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B + C + D
      ActPos& = CharsToLong(A, B, C, D)
      '****************************************
      'changed to adjust for user counter offset
      '****************************************
      IF (address = 1 OR address = 2) THEN   'X Axis
    Glo.Position(address) = ActPos& + SCANstruc.XOffset
      ELSEIF address = 3 THEN  'Y Axis
    Glo.Position(address) = ActPos& + SCANstruc.YOffset
      ELSEIF address = 4 THEN  'A Axis
    Glo.Position(address) = ActPos& + SCANstruc.AOffset
      ELSE
      END IF
    END IF

    'Get the A/D value
    IF (Glo.StatusDef(address) AND SendAD) THEN
      IF SIOGetByte(Glo.AdVal(address), 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.AdVal(address)
    END IF

    'Get velocity data
    IF (Glo.StatusDef(address) AND SendVel) THEN
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B
      Glo.velocity(address) = CharsToInt(A, B)
    END IF

    'Get the AUX status value
    IF (Glo.StatusDef(address) AND SendAux) THEN
      IF SIOGetByte(Glo.AuxStat(address), 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.AuxStat(address)
    END IF

    'Get home position data
    IF (Glo.StatusDef(address) AND SendHome) THEN
      IF SIOGetByte(D, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(C, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B + C + D
      Glo.HomePosition(address) = CharsToLong(A, B, C, D)
    END IF

    'Get the module type and version

    IF (Glo.StatusDef(address) AND SendID) THEN
     IF SIOGetByte(Glo.ModuleType(address), 1) = FALSE THEN GOTO SendCmdExit
     IF SIOGetByte(Glo.ModuleVer(address), 1) = FALSE THEN GOTO SendCmdExit
     Cksum = Cksum + Glo.ModuleType(address) + Glo.ModuleVer(address)
    END IF

  ELSE   'PicIO module

    'Get the I/0 values
    IF (Glo.StatusDef(address) AND SendIO) THEN
      IF SIOGetByte(Glo.IO1, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(Glo.IO2, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.IO1 + Glo.IO2
    END IF

    'Get the A/D 1 value
    IF (Glo.StatusDef(address) AND SendAD1) THEN
      IF SIOGetByte(Glo.Ad1, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.Ad1
    END IF

    'Get the A/D 2 value
    IF (Glo.StatusDef(address) AND SendAD2) THEN
      IF SIOGetByte(Glo.Ad2, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.Ad2
    END IF

    'Get the A/D 3 value
    IF (Glo.StatusDef(address) AND SendAD3) THEN
      IF SIOGetByte(Glo.Ad3, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.Ad3
    END IF

    'Get Ctr value
    IF (Glo.StatusDef(address) AND SendCtr) THEN
      IF SIOGetByte(D, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(C, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B + C + D
      Glo.Counter = CharsToLong(A, B, C, D)
    END IF



    'Get the Sync I/0 values
    IF (Glo.StatusDef(address) AND SendSyncIO) THEN
      IF SIOGetByte(Glo.SyncIO1, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(Glo.SyncIO2, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.SyncIO1 + Glo.SyncIO2
    END IF

    'Get SyncCtr value
    IF (Glo.StatusDef(address) AND SendSyncCtr) THEN
      IF SIOGetByte(D, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(C, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B + C + D
      Glo.SyncCounter = CharsToLong(A, B, C, D)
    END IF
    'Get the module type and version
    IF (Glo.StatusDef(address) AND SendID) THEN
      IF SIOGetByte(Glo.ModuleType(address), 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(Glo.ModuleVer(address), 1) = FALSE THEN GOTO SendCmdExit

      Cksum = Cksum + Glo.ModuleType(address) + Glo.ModuleVer(address)
    END IF
  END IF

  IF SIOGetByte(CCksum, 1) = FALSE THEN GOTO NoChkSum

  Glo.CkSumError = FALSE

  IF (Cksum AND 255) <> CCksum THEN
    Glo.SIOError = TRUE
    MSGBOX "Bad Check Sum"
    FixSIOerror
    'CALL Delayx(500)
    'CALL PrintClrStr(3, 1, " ")
    Glo.CkSumError = TRUE
    'GloErr = GloErr + 1
  END IF

  EXIT SUB


NoStatExit:
  Glo.SIOError = TRUE
  MSGBOX "No Status"
  FixSIOerror
  EXIT SUB

NoChkSum:
  Glo.SIOError = TRUE
  MSGBOX "No Status"
  FixSIOerror
  EXIT SUB


SendCmdExit:
  Glo.SIOError = TRUE
  MSGBOX  "SER IN FAILED"
  FixSIOerror
  EXIT SUB
GrpCmdExit:
END SUB

DECLARE SUB GetCharsInBuffer (ComPortNum$, RecvQue%, XmitQue%, ECode%)
SUB GetCharsInBuffer (ComPortNum$, RecvQue%, XmitQue%, ECode%)
END SUB

DECLARE SUB FixSIOerror  ()
SUB FixSIOerror
  LOCAL NullStr AS STRING
  LOCAL bytesWritten, ECode, RecQue, XmtQue AS INTEGER
  LOCAL CTS, DelayCtr AS LONG

  NullStr$ = STRING$(16, 0)

  'spit out a bunch of zeros
  CALL WriteToComm(picport$,   NullStr$, BytesWritten, ECode%)

  DO
     CALL GetCharsInBuffer(picport$, RecQue, XmtQue, ECode%)
     Cts& = Cts& + 1
     IF Cts& > 100 * DelayCtr THEN EXIT DO
  LOOP UNTIL (XmtQue = XmitSize - 1)

  'wait for any responses
  CALL DelayX(75)

  'flush the input buffer
  CALL FlushBuffers(PICPort$, 0, ECode%)

END SUB

#INCLUDE "mywindows.inc"
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
    IF NOT OpenComPorts THEN
     MSGBOX "ERROR, POWER OFF/ON",, "OpenComPorts serial connection failed."
     DO
     LOOP
    END IF

    IF NOT InitNetWork THEN
     MSGBOX "SETUP ERROR",, "InitNetWork Failed."
     DO
       CALL DelayX(200)
     LOOP UNTIL InitNetWork
    END IF

    IsSplashActive = 1
    ShowSplashDlg(5000, "atcosplash.bmp", 1, "MCU 2015",1)
    BUILDWINDOW()
    DIALOG SHOW MODAL hDlg, CALL DlgProc


END FUNCTION
