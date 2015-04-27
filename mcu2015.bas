#COMPILE EXE
#DIM ALL
#INCLUDE "ATCO.inc"
#INCLUDE "Win32API.inc"
#RESOURCE ICON, exeICON, "ATCO.ico"
DEFINT A-Z

GLOBAL hDlg, hDlg1 AS DWORD, w, h AS LONG
GLOBAL IsSplashActive AS LONG
MACRO CONST = MACRO
'****************************************************************************************************
'misc const values
CONST TRUE = -1
CONST FALSE = NOT TRUE
'Number of servos in system, change as needed.
CONST Servo1 = 1
CONST Servo2 = 2
CONST Servo3 = 3
CONST Servo4 = 4
CONST AllServos = &HFF
CONST LastServo  = 4
CONST InOut1 = 5
'Key codes
CONST KeyUP = 72
CONST KeyDN = 80
CONST KeyLft = 75
CONST KeyRgt = 77
CONST KeyBKSPC = 8
CONST KeySPC = 32
CONST KeyEnter = 13
CONST KeyEsc = 27
'Sio error mode difinitions
CONST DoNothing = 0
CONST ErrorBox = 1
CONST AbortCom = 2
CONST ExitProgram = 3
'Module type definitions
CONST PicServoType = 0
'Status definitions bits for servo
CONST SendPos = 1
CONST SendAD = 2
CONST SendVel = 4
CONST SendAux = 8
CONST SendHome = 16
CONST SendID = 32
'Status definitions bits for io (SendID is shared with PIC)
CONST SendIO = 1
CONST SendAD1 = 2
CONST SendAD2 = 4
CONST SendAD3 = 8
CONST SendCtr = 16
CONST SendSyncIO = 64
CONST SendSyncCtr = 128
'Load Trajectory control byte
CONST LoadPos = 1
CONST LoadVel = 2
CONST LoadAcc = 4
CONST LoadPWM = 8
CONST PosMode = 16
CONST VelMode = 32
CONST RevDir = 64
CONST StartNow = 128
CONST PWMMode = 0 'PWM added KJL
'Stop control byte
CONST EnableAmp = 1
CONST MotorOff = 2
CONST StopAbrupt = 5
CONST StopSmooth = 9
'Homing control byte
CONST HomeOnLimit1 = 1
CONST HomeOnLimit2 = 2
CONST HomeOnIndex = 8
CONST HomeOnPerr = 64
CONST HomeOnCerr = 128
'Status byte
CONST MoveDone = 1
CONST CksumErr = 2
CONST OverCurrent = 4
CONST PowerOn = 8
CONST PosError = 16
CONST Limit1 = 32
CONST Limit2 = 64
CONST HomeInProg = 128
'Auxiliary status byte
CONST IndexPulse = 1
CONST PositionWrap = 2
CONST ServoOn = 4
CONST AccelDone = 8
CONST SlewDone = 16
CONST ServoOverrun = 32
'MiscMode bit definitions
CONST AmpEnabled = 1
CONST PWMSelected = 2
CONST VelSelected = 4
CONST PosSelected = 8
CONST OnL1Selected = 16
CONST OnL2Selected = 32
CONST OnIndexSelected = 64
CONST OnPeSelected = 128
CONST OnCeSelected = 256
CONST HomeFlagMask = &HFE0F
'****************************************************************************************************
'************************************************************************************
'* Motor control globals
GLOBAL filenum AS INTEGER
GLOBAL HdrVer AS STRING * 20
GLOBAL KeyTable() AS STRING
GLOBAL nComm AS LONG
GLOBAL PicPort AS STRING
GLOBAL PicBaud AS LONG
GLOBAL RecvSize AS LONG
GLOBAL XmitSize AS LONG
GLOBAL MemSize AS LONG
GLOBAL Corr1()  AS BYTE
GLOBAL Corr2()  AS BYTE
GLOBAL LF() AS BYTE
GLOBAL LU() AS BYTE
GLOBAL XVel() AS LONG
GLOBAL YVel() AS LONG
GLOBAL XAcel() AS LONG
GLOBAL YAcel() AS LONG
GLOBAL XSpd()  AS LONG
GLOBAL YSpd()  AS LONG
GLOBAL nComm AS LONG
GLOBAL A,B,C,D AS INTEGER
'****************************************************************************************************
TYPE GloRecord
   NumModules AS INTEGER
   StatusDef(5) AS LONG
   ModuleType(5) AS INTEGER
   ModuleVer(5) AS INTEGER
   Position(5) AS LONG
   CmdPosition(5) AS LONG
   HomePosition(5) AS LONG
   velocity(5) AS LONG
   CmdVelocity(5) AS LONG
   CmdAccel(5) AS LONG
   CmdPwm(5) AS INTEGER
   AdVal(5) AS INTEGER
   Stat(5) AS INTEGER
   AuxStat(5) AS INTEGER
   Kp(5) AS INTEGER
   Ki(5) AS INTEGER
   Kd(5) AS INTEGER
   IL(5) AS INTEGER
   ol(5) AS INTEGER
   CL(5) AS INTEGER
   EL(5) AS INTEGER
   SRD(5) AS LONG
   MiscMode(5) AS LONG
   SIOErrorMode AS LONG
   SIOError AS LONG
   CkSumError AS LONG
   SIOPort AS LONG
   AmpQuery AS LONG
   PowerQuery AS LONG
   baud AS LONG
   'added for PIC-IO
   IO1 AS INTEGER
   IO2 AS INTEGER
   Ad1 AS INTEGER
   Ad2 AS INTEGER
   Ad3 AS INTEGER
   Counter AS LONG
   SyncIO1 AS INTEGER
   SyncIO2 AS INTEGER
   SyncCounter AS INTEGER
 END TYPE
 GLOBAL Glo AS GloRecord
'************************************************************************************
'* Motor control Functions

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

DECLARE FUNCTION OpenComPorts ()
FUNCTION OpenComPorts
    LOCAL x AS INTEGER
    LOCAL ECode AS INTEGER
    COMM OPEN PicPort AS #nComm
    IF ERR THEN
        OpenComPorts = FALSE
        EXIT FUNCTION
    END IF
    XmitSize = 2048
    RecvSize = 2048
    COMM SET #nComm, TXBUFFER = xmitsize
    COMM SET #nComm, RXBUFFER = RecvSize   ' 2 Kb receive buffer
    COMM SET #nComm, BAUD   = PICBaud  ' 19200 baud
    COMM SET #nComm, BYTE   = 8     ' 8 bits
    COMM SET #nComm, PARITY = %FALSE        ' No parity
    COMM SET #nComm, STOP   = 0     ' 1 stop bit

    COMM SET #nComm, XINPFLOW = 0
    COMM SET #nComm, XOUTFLOW = 0
    CALL FlushBuffers(PICPort$, 0, ECode%)
    OpenComPorts = TRUE
END FUNCTION
DECLARE SUB SendCmd (address AS WORD, CmdString AS STRING)
SUB SendCmd (address AS WORD, CmdString AS STRING)
  LOCAL Cksum AS WORD
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
   ' PRINT "Bad ChkSum"
    CALL PrintClrStr(3, 1, "Bad ChkSum")
    FixSIOerror
    'CALL Delayx(500)
    'CALL PrintClrStr(3, 1, " ")
    Glo.CkSumError = TRUE
    'GloErr = GloErr + 1
  END IF

  EXIT SUB


NoStatExit:
  Glo.SIOError = TRUE
  CALL PrintClrStr(3, 1, "No Status")
  'PRINT "No Status"
  FixSIOerror
  'CALL Delayx(500)
  'CALL PrintClrStr(3, 1, " ")
  'GloErr = GloErr + 1
  EXIT SUB

NoChkSum:
  Glo.SIOError = TRUE
  CALL PrintClrStr(3, 1, "No ChkSum")
  'PRINT "No ChkSum"
  FixSIOerror
  'CALL Delayx(500)
  'CALL PrintClrStr(3, 1, " ")
  'GloErr = GloErr + 1
  EXIT SUB


SendCmdExit:
  Glo.SIOError = TRUE
  CALL PrintClrStr(3, 1, "SER IN FAILED")
  'PRINT "SER IN FAILED"
  FixSIOerror
  'CALL Delayx(500)
  'CALL PrintClrStr(3, 1, " ")
  'GloErr = GloErr + 1
  EXIT SUB


GrpCmdExit:


END SUB
'***************************************************************************************************************************************
DECLARE SUB ShowSplashDlg(BYVAL nDelay AS LONG, BYVAL sBitmapID AS STRING, _
                          BYVAL IsFile AS LONG, OPTIONAL BYVAL sAppName AS STRING, _
                          OPTIONAL BYVAL nModeless AS LONG)

CALLBACK FUNCTION BTN_SETUP_CALL()
    DIALOG END hDlg
    BUILDSETUPWINDOW()
    DIALOG SHOW MODAL hDlg1, CALL DlgProc
    BUILDWINDOW()
    DIALOG SHOW MODAL hDlg, CALL DlgProc
END FUNCTION
CALLBACK FUNCTION BTN_JOYSTICK_CALL()
    MSGBOX "JoyStick, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_AJOG_CALL()
    MSGBOX "A-Jog, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_SAVE_CALL()
    MSGBOX "SAVE, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_AUTOSCAN_CALL()
    MSGBOX "AUTOSCAN, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_XSPDCTRL_CALL()
    MSGBOX "XSPD CTRL, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_MJOG_CALL()
    MSGBOX "MJOG, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_LOAD_CALL()
    MSGBOX "Load, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_CALENC_CALL()
    MSGBOX "Calculate Encoders, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
FUNCTION BUILDWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, 0, "Atco MCU2015",,, w/2, h/2,%WS_OVERLAPPEDWINDOW , 0 TO hDlg
    DIALOG SET ICON hDlg, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD BUTTON, hDlg, %SETUP_BUTTON, "Setup", 100, 100, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_SETUP_CALL()
    CONTROL SET FONT hDlg, %SETUP_BUTTON, NormalFont&

    CONTROL ADD BUTTON, hDlg, %JOYSTICK_BUTTON, "Joy Stick", 100, 200, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_JOYSTICK_CALL()
    CONTROL SET FONT hDlg, %JOYSTICK_BUTTON, NormalFont&

    CONTROL ADD BUTTON, hDlg,%AJOG, "A-Jog", 100, 300, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_AJOG_CALL()
    CONTROL SET FONT hDlg, %AJOG, NormalFont&


    CONTROL ADD BUTTON, hDlg,%SAVE, "&Save", 100, 400, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_SAVE_CALL()
    CONTROL SET FONT hDlg, %SAVE, NormalFont&

    CONTROL ADD BUTTON, hDlg,%AUTOSCAN, "&Auto Scan", 600, 100, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_AUTOSCAN_CALL()
    CONTROL SET FONT hDlg, %AUTOSCAN, NormalFont&

    CONTROL ADD BUTTON, hDlg,%XSPDCTRL, "&XSPD CTRL", 600, 200, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_XSPDCTRL_CALL()
    CONTROL SET FONT hDlg, %XSPDCTRL, NormalFont&

    CONTROL ADD BUTTON, hDlg,%MJOG, "M-Jog", 600, 300, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_MJOG_CALL()
    CONTROL SET FONT hDlg, %MJOG, NormalFont&

    CONTROL ADD BUTTON, hDlg,%LOAD, "Load", 600, 400, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_LOAD_CALL()
    CONTROL SET FONT hDlg, %LOAD, NormalFont&


 END FUNCTION
FUNCTION BUILDSETUPWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, 0, "MCU 2015 Setup",,, w/2, h/2,%WS_OVERLAPPEDWINDOW  , 0 TO hDlg1
    DIALOG SET ICON hDlg1, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD BUTTON, hDlg1, %CALIBRATEENC, "Calibrate Encoders", 10, 400, 400, 50,%BS_PUSHLIKE , , _
    CALL BTN_CALENC_CALL()
    CONTROL SET FONT hDlg1, %CALIBRATEENC, NormalFont&

    TXT$ = "X Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX1, "", 100, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL1, TXT$,    10, 10, 50, 20

    TXT$ = "X End"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX2, "", 100, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL2, TXT$, 10,    40, 50, 20

    TXT$ = "Y Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX3 , "", 100, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL3, TXT$, 10,     70, 50, 20

    TXT$ = "Y End"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX4 , "", 100, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL4, TXT$, 10,     100, 50, 20

    TXT$ = "X Index"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX5 , "", 100, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL5, TXT$, 10,     130, 50, 20

    TXT$ = "Y Index"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX6 , "", 100, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL6, TXT$, 10,     160, 50, 20

    TXT$ = "X Speed"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX7 , "", 100, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL7, TXT$, 10,     190, 50, 20

    TXT$ = "Y Speed"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX8 , "", 100, 220, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL8, TXT$, 10,     220, 50, 20

    TXT$ = "X POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX9, "", 410, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL9, TXT$,    300, 10, 50, 20

    TXT$ = "Y POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX10, "", 410, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL10, TXT$, 300,    40, 50, 20

    TXT$ = "X CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX11 , "", 410, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL11, TXT$, 300,     70, 50, 20

    TXT$ = "Y CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX12 , "", 410, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL12, TXT$, 300,     100, 50, 20

    TXT$ = "X +/-"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX12 , "", 410, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL5, TXT$, 300,     130, 50, 20

    TXT$ = "Y +/-"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX13 , "", 410, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL13, TXT$, 300,     160, 50, 20

    TXT$ = "INDEX"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX14 , "", 410, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL14, TXT$, 300,     190, 50, 20

    TXT$ = "IDX H/L"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX15 , "", 410, 220, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL15, TXT$, 300,     220, 50, 20

    TXT$ = "X ON/OFF"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX20, "", 730, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL20, TXT$,    600, 10, 60, 20

    TXT$ = "Y ON/OFF"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX21, "", 730, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL21, TXT$, 600,    40, 60, 20

    TXT$ = "AUTO HD"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX22 , "", 730, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL22, TXT$, 600,     70, 60, 20

    TXT$ = "DUALRAS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX23 , "", 730, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL23, TXT$, 600,     100, 60, 20

    TXT$ = "OVERLAP"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX24 , "", 730, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL24, TXT$, 600,     130, 60, 20

    TXT$ = "A POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX25 , "", 730, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL13, TXT$, 600,     160, 60, 20

    TXT$ = "A CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX25, "", 730, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL25, TXT$, 600,     190, 60, 20

 END FUNCTION

CALLBACK FUNCTION EditControlCallback()
    LOCAL lResult AS LONG
    CONTROL GET CHECK hDlg, %OPT1 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        central_angle = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT2 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Chord_ab = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT3 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Ed = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT4 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        OE = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT5 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Arc_ab = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT6 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        Chord_AB = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        ED = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT7 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        Chord_AB = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        OE = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT8 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        ED = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        OE = VAL(TXT$)
    END IF

END FUNCTION
CALLBACK FUNCTION DlgProc () AS LONG
    LOCAL temp$
    SELECT CASE CB.MSG
        CASE %WM_INITDIALOG   ' <- Sent right before the dialog is shown
        CASE %WM_COMMAND      ' <- A control is calling
            SELECT CASE CB.CTL  ' <- Look at control's id
            CASE %IDCANCEL
             IF CB.CTLMSG = %BN_CLICKED THEN ' Exit on Esc
                DIALOG END CB.HNDL
             END IF
            END SELECT
         CASE %WM_NOTIFY
            SELECT CASE CB.NMID
                CASE %IDC_UpDown
                 SELECT CASE CB.NMCODE
                  CASE %UDN_DeltaPOS
                     LOCAL UPD AS NMUPDOWN PTR
                     UPD = CB.LPARAM
                     'old value will be @upd.iPos
                     'change (delta) to old value will be @upd.iDelta
               END SELECT
         END SELECT
    END SELECT
END FUNCTION
'________________________________________________________________________________________
'
' Splash Dialog Box function
' ==========================
'
' Function to display a splash-screen for specified amount of time
'
' Update: now includes modal\modeless dialog (return immediately).
'
'
' By KGP Software, June 2002. Posted April 2004.
'________________________________________________________________________________________


'#If Not %Def(%FUNCTION_SPLASH)

'%FUNCTION_SPLASH = 1




'------------------------------------------------------------------------------
' Callback for the splash dialog
'------------------------------------------------------------------------------
CALLBACK FUNCTION dlgSplashProc

  SELECT CASE CBMSG

         CASE %WM_TIMER, %WM_LBUTTONDOWN, %WM_RBUTTONDOWN, %WM_KEYDOWN
              ' React to mouse or key movements, or when the dialog times out...
              KillTimer CBHNDL, 100
              IsSplashActive = %False
              DeleteObject SendDlgItemMessage(CBHNDL, 100, %STM_GETIMAGE, %IMAGE_BITMAP, 0)
              DIALOG END CBHNDL
  END SELECT

END FUNCTION


'------------------------------------------------------------------------------
' Displays splash dialog
'
'  nDelay is number of milliseconds to display
'  sBitmapID is either a resource ID or file name
'  IsFile is nonzero if sBitmapID is a file name
'  sAppName is an (optional) string to display on the screen
'  nModeless is nonzero to return from function immediately.
'
'------------------------------------------------------------------------------
SUB ShowSplashDlg(BYVAL nDelay AS LONG, BYVAL sBitmapID AS STRING, BYVAL isfilea AS LONG, OPTIONAL BYVAL sAppName AS STRING,  OPTIONAL BYVAL nModeless AS LONG)

    LOCAL hDlg AS DWORD, hBmp AS DWORD, tObj AS BITMAP

    IsSplashActive = 1

    ' Default delay...
    IF nDelay = 0 THEN nDelay = 2500

    IF isfilea THEN
       hBmp = LoadImage(0, BYCOPY sBitmapID, %IMAGE_BITMAP, 0, 0, %LR_LOADFROMFILE)
    ELSE
       hBmp = LoadImage(GetModuleHandle(BYVAL %NULL), BYCOPY sBitmapID, %IMAGE_BITMAP, 0,0,0)
    END IF

    ' Get size of bitmap and size window accordingly...
    IF GetObject(hBmp, SIZEOF(tObj), tObj) = 0 THEN EXIT SUB

    ' Create the dialog...
    DIALOG NEW 0, "", , , 0, 0, %DS_3DLOOK ,%WS_EX_TOPMOST  TO hDlg
    SetWindowPos hDlg, 0, (GetSystemMetrics(%SM_CXSCREEN)/2)-(tObj.bmWidth/2), _
                          (GetSystemMetrics(%SM_CYSCREEN)/2)-(tObj.bmHeight/2), _
                          tObj.bmWidth, tObj.bmHeight, %SWP_NOZORDER

    ' Create the label (image) and size it also...
    CONTROL ADD LABEL, hDlg, 100, "", 0, 0, 0, 0, %SS_BITMAP OR %SS_CENTERIMAGE
    SetWindowPos GetDlgItem(hDlg, 100), 0, 0, 0, tObj.bmWidth, tObj.bmHeight, %SWP_NOZORDER
    CONTROL SEND hDlg, 100, %STM_SETIMAGE, %IMAGE_BITMAP, hBmp

    ' Display application data string if specified...
    IF LEN(sAppName) THEN
       CONTROL ADD LABEL, hDlg, 10, sAppName, 0, 0, 200, 10
       SetWindowPos GetDlgItem(hDlg, 10), 0, 15, tObj.bmHeight-20, 0, 0, %SWP_NOSIZE OR %SWP_NOZORDER
       CONTROL SET COLOR hDlg, 10, RGB(255,255,255), -2
    END IF

    SetTimer hDlg, 100, nDelay, 0

    IF nModeless = %False THEN
       DIALOG SHOW MODAL hDlg CALL dlgSplashProc
    ELSE
       DIALOG SHOW MODELESS hDlg CALL dlgSplashProc
    END IF
END SUB
'#EndIf
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
