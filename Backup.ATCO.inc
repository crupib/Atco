
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
CONST PosDir = -1
CONST NegDir = 0
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
GLOBAL controlbyte AS BYTE
GLOBAL ExitSub AS INTEGER
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

'****************************************************************************************************
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
GLOBAL SCANstruc AS scanparms

TYPE HEADER
   hdr AS STRING * 20
END TYPE
'****************************************************************************************************
DECLARE SUB DelayX (Millisec) '
SUB DelayX (Millisec) '
   SLEEP Millisec
END SUB
DECLARE SUB SetAccel (address AS INTEGER)
SUB SetAccel (address AS INTEGER)
 LOCAL MtrNum AS INTEGER
 LOCAL Cmd AS STRING
 'set accel to ans intial value before enabling servo

 IF address < 1 THEN EXIT SUB

 MtrNum = address

 Cmd$ = CHR$(&H54) + CHR$(LoadAcc) + LongToStr(Glo.CmdAccel(MtrNum))

 SendCmd address, Cmd$

END SUB
DECLARE SUB SetGain (address AS INTEGER)
SUB SetGain (address AS INTEGER)

   LOCAL MtrNum, x AS INTEGER
   LOCAL Cmd AS STRING
   IF address < 1 THEN EXIT SUB

   MtrNum = address

   x = Glo.CL(MtrNum)
   IF x < 1 THEN
     x = (-x) AND 254
   ELSE
     x = x OR 1
   END IF

   Cmd$ = CHR$(&HD6) + IntToStr(Glo.Kp(MtrNum)) + IntToStr(Glo.Kd(MtrNum))
   Cmd$ = Cmd$ + IntToStr(Glo.Ki(MtrNum)) + IntToStr(Glo.IL(MtrNum))
   Cmd$ = Cmd$ + CHR$(Glo.ol(MtrNum)) + CHR$(x)
   Cmd$ = Cmd$ + IntToStr(Glo.EL(MtrNum)) + CHR$(Glo.SRD(MtrNum))

   SendCmd address, Cmd$

END SUB
DECLARE SUB EnableAmpl (Value AS INTEGER, address AS INTEGER)
SUB EnableAmpl (Value AS INTEGER, address AS INTEGER)
  LOCAL MtrNum AS INTEGER
  LOCAL Cmd AS STRING
  IF address < 1 THEN EXIT SUB


  MtrNum = address

  IF Value THEN
     Cmd$ = CHR$(&H17) + CHR$(EnableAmp)
     Glo.MiscMode(MtrNum) = Glo.MiscMode(MtrNum) OR AmpEnabled
  ELSE
     Cmd$ = CHR$(&H17) + CHR$(0)
     Glo.MiscMode(MtrNum) = (Glo.MiscMode(MtrNum) AND (NOT AmpEnabled))
  END IF

  SendCmd address, Cmd$

END SUB
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
'  ELSE
'      MSGBOX "Number of Modules  "+ STR$(Glo.NumModules)
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
    Glo.CkSumError = TRUE
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
DECLARE FUNCTION KeyDown ()
FUNCTION KeyDown


   IF GRAPHIC(INSTAT) THEN
       KEYDOWN = -1
   ELSE
       KEYDOWN = 0
   END IF

END FUNCTION

DECLARE FUNCTION CalLoad (FileNumber$)

FUNCTION CalLoad (FileNumber$)
   LOCAL TempStr AS HEADER
   LOCAL ECode AS INTEGER
   LOCAL BytesRead AS INTEGER
   TempStr.hdr = HdrVer
   CALL FOpen (filenum, 0,0, FileNumber$, ECode)
   IF ECode THEN
     CalLoad = FALSE
     EXIT FUNCTION
   END IF

   'read header label
'   CALL DFRead(HANDLE, VARSEG(HdrVer), VARPTR(HdrVer), LEN(HdrVer), BytesRead&, ECode)
   CALL DFRead(filenum, TempStr, 0, BytesRead, ECode)
   IF ECode THEN GOTO ExitCalLoad

   'Verify correct header
   IF HdrVer <> TempStr THEN
     ECode = TRUE
     GOTO ExitCalLoad
   END IF
   CALL DFRead2(filenum, ScanStruc, LEN(SCANparms), BytesRead, ECode)
   'CALL DFRead(HANDLE, VARSEG(SCAN), VARPTR(SCAN), LEN(SCAN), BytesRead&, ECode)
   IF ECode THEN GOTO ExitCalLoad


ExitCalLoad:
   HdrVer = TempStr 'in case of corrupt hdr read
   CALL FClose(filenum)
   IF ECode THEN
     CalLoad = FALSE
   ELSE
     CalLoad = TRUE
   END IF

   EXIT FUNCTION


END FUNCTION

DECLARE SUB SetDefaults
SUB SetDefaults
  SCANstruc.YCtr = 14858 'cts per inch travel
  SCANstruc.XCtr = 62047
  SCANstruc.ACtr = 1000
  GetXyPos  'load current encoder position
  SCANstruc.XLow = 0: SCANstruc.XLowStr = QStr(SCANstruc.XLow, 10)
  SCANstruc.XHigh = 96: SCANstruc.XHighStr = QStr(SCANstruc.XHigh, 10)
  SCANstruc.YLow = 0: SCANstruc.YLowStr = QStr(SCANstruc.YLow, 10)
  SCANstruc.YHigh = 12: SCANstruc.YHighStr = QStr(SCANstruc.YHigh, 10)
  SCANstruc.XIndex = .25: SCANstruc.XIndexSTR = QStr(SCANstruc.XIndex, 10)
  SCANstruc.YIndex = .125: SCANstruc.YIndexSTR = QStr(SCANstruc.YIndex, 10)
  SCANstruc.IndexLow = FALSE: SCANstruc.IndexLowStr = "LOW - HIGH"
  SCANstruc.XPlus = TRUE:  SCANstruc.XPlusSTR = "POSITIVE  "
  SCANstruc.YPlus = FALSE: SCANstruc.YPlusSTR = "NEGATIVE  "
  SCANstruc.XSpeed = 2: SCANstruc.XSpeedSTR = QStr(SCANstruc.XSpeed, 10)
  SCANstruc.YSpeed = 16: SCANstruc.YSpeedSTR = QStr(SCANstruc.YSpeed, 10)
  SCANstruc.XCtrStr = QStr(SCANstruc.XCtr, 10)
  SCANstruc.YCtrStr = QStr(SCANstruc.YCtr, 10)
  SCANstruc.ACtrStr = QStr(SCANstruc.ACtr, 10)
  SCANstruc.XEnable = TRUE: SCANstruc.XEnableSTR = "ON        "
  SCANstruc.YEnable = TRUE: SCANstruc.YEnableSTR = "ON        "
  SCANstruc.XSpdDir = TRUE: SCANstruc.XSpdDirSTR = "FORWARD*"
  SCANstruc.AutoHold = TRUE: SCANstruc.AutoHoldSTR = "ON "
  SCANstruc.IndexY = FALSE: SCANstruc.IndexYSTR = "X         "
  SCANstruc.OverLap = 1: SCANstruc.OverLapStr = "1         "
  SCANstruc.DualRas = FALSE: SCANstruc.DualRasSTR = "OFF       "
END SUB
DECLARE SUB GetXyPos ()
SUB GetXyPos

    CALL GetStatus(&H255)   'get status of all servos (4)

    SCANstruc.XCts = ABS(Glo.Position(Servo1))
    SCANstruc.YCts = ABS(Glo.Position(Servo3))
    SCANstruc.ACts = ABS(Glo.Position(Servo4))

    SCANstruc.XPos = CLNG((SCANstruc.XCts / SCANstruc.XCtr) * 1000) / 1000
    SCANstruc.YPos = CLNG((SCANstruc.YCts / SCANstruc.YCtr) * 1000) / 1000
    SCANstruc.APos = CLNG((SCANstruc.ACts / SCANstruc.ACtr) * 1000) / 1000

    SCANstruc.XPosStr = QStr(SCANstruc.XPos, 10)
    SCANstruc.YPosStr = QStr(SCANstruc.YPos, 10)
    SCANstruc.APosStr = QStr(SCANstruc.APos, 10)

    CALL GetStatus(InOut1)   'get status of IO

END SUB
DECLARE FUNCTION QStr$ (BYVAL Amount!, BYVAL Places)
FUNCTION QStr$ (BYVAL Amount!, BYVAL Places) STATIC

    QStr$ = LEFT$(LTRIM$(STR$(Amount!)) + SPACE$(Places), Places)

END FUNCTION
DECLARE SUB GetStatus (Num)
SUB GetStatus (Num)

   LOCAL MtrNum AS INTEGER
   LOCAL Cmd AS STRING
   Cmd$ = CHR$(&HD)  'nop

   IF Num = &H255 THEN  'load status all servos
     FOR MtrNum = 1 TO LastServo
       SendCmd MtrNum, Cmd$
     NEXT
   ELSE                       'load status of one servo or io
     SendCmd Num, Cmd$
   END IF

END SUB

DECLARE SUB SetForAuto ()
SUB SetForAuto
  LOCAL XVelocity, YVelocity, XCel, YCel AS LONG
  LOCAL Xtime, YTime AS SINGLE
  LOCAL Axis AS INTEGER
  LOCAL Cmd AS STRING
  IF SCANstruc.XSpeed = 0 THEN SCANstruc.XSpeed = 2
  IF SCANstruc.YSpeed = 0 THEN SCANstruc.YSpeed = 1

  'determine cts/millisec needed based on inches travel/sec
  XVelocity& = SCANstruc.XSpeed * SCANstruc.XCtr * (1 / 1953) * 65536
  YVelocity& = SCANstruc.YSpeed * SCANstruc.YCtr * (1 / 1953) * 65536

  'set length of time in seconds to reach specified maximum velocity
  XTime! = .1: YTime! = .1

  'x & y acceleration, deceleration  calc's
  XCel& = (SCANstruc.XSpeed / XTime!) * SCANstruc.XCtr * (1 / 1953) * (1 / 1953) * 65536
  YCel& = (SCANstruc.YSpeed / YTime!) * SCANstruc.YCtr * (1 / 1953) * (1 / 1953) * 65536

  Glo.CmdVelocity(Servo1) = XVelocity&
  Glo.CmdVelocity(Servo2) = XVelocity&
  Glo.CmdVelocity(Servo3) = YVelocity&
  Glo.CmdAccel(Servo1) = XCel&
  Glo.CmdAccel(Servo2) = XCel&
  Glo.CmdAccel(Servo3) = YCel&

  'set gains
  FOR Axis = Servo1 TO Servo3
    IF Axis = Servo3 THEN  'y-axis
      Glo.Kp(Axis) = 200   '200
      Glo.Ki(Axis) = 50    '100 '100   REM changed 4/29/08
      Glo.Kd(Axis) = 2000  '4000
      Glo.IL(Axis) = 0     '10  '20   REM changed 4/29/08
    ELSE
      Glo.Kp(Axis) = 300   '300
      Glo.Ki(Axis) = 200     '200
      Glo.Kd(Axis) = 8000  '8000
      Glo.IL(Axis) = 40     '40
    END IF
    Glo.ol(Axis) = 255
    Glo.CL(Axis) = 0
    Glo.EL(Axis) = 16384
    Glo.SRD(Axis) = 1
    Cmd$ = CHR$(&HD6) + IntToStr(Glo.Kp(Axis)) + IntToStr(Glo.Kd(Axis))
    Cmd$ = Cmd$ + IntToStr(Glo.Ki(Axis)) + IntToStr(Glo.IL(Axis))
    Cmd$ = Cmd$ + CHR$(Glo.ol(Axis)) + CHR$(Glo.CL(Axis))
    Cmd$ = Cmd$ + IntToStr(Glo.EL(Axis)) + CHR$(Glo.SRD(Axis))
    SendCmd Axis, Cmd$
  NEXT Axis

  StopMtrs

END SUB
DECLARE SUB StopMtrs ()
SUB StopMtrs
  LOCAL Cmd AS STRING
  LOCAL x AS INTEGER
  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd AllServos, Cmd$

  FOR x = 1 TO 3
    Glo.CmdPwm(x) = 0
  NEXT

END SUB

DECLARE FUNCTION GoodLNG (Num$)
FUNCTION GoodLNG (Num$)

  IF VAL(Num$) > 2147483647 THEN
    GoodLNG = FALSE
    EXIT FUNCTION
  ELSEIF VAL(Num$) < -2147483648# THEN
    GoodLNG = FALSE
    EXIT FUNCTION
  ELSE
    GoodLNG = TRUE
    EXIT FUNCTION
  END IF
END FUNCTION

DECLARE FUNCTION GoodSNG (Num$)
FUNCTION GoodSNG (Num$)

  IF VAL(Num$) < -3.402823E+38 THEN
    GoodSNG = FALSE
    EXIT FUNCTION
  ELSEIF VAL(Num$) > 3.402823E+38 THEN
    GoodSNG = FALSE
    EXIT FUNCTION
  ELSE
    GoodSNG = TRUE
    EXIT FUNCTION
  END IF
END FUNCTION
DECLARE SUB ResetPosition (address AS INTEGER)
SUB ResetPosition (address AS INTEGER)
 LOCAL Cmd AS STRING
 IF address < 1 THEN EXIT SUB

 Cmd$ = CHR$(&H0)

 SendCmd address, Cmd$

END SUB
DECLARE FUNCTION GetXCord& (Cts&)
FUNCTION GetXCord& (Cts&)
  IF SCANstruc.XPlus = TRUE THEN 'X positive direction
    GetXCord& = Cts&
  ELSE
    GetXCord& = -Cts&   'X negative direction
  END IF

  EXIT FUNCTION

END FUNCTION
DECLARE FUNCTION GetYCord& (Cts&)
FUNCTION GetYCord& (Cts&)

  IF SCANstruc.YPlus = TRUE THEN 'Y positive cts
    GetYCord& = Cts&
  ELSE
    GetYCord& = -Cts&  'Y negative cts
  END IF

  EXIT FUNCTION

END FUNCTION
DECLARE SUB StopXMtrs ()
SUB StopXMtrs
LOCAL Cmd AS STRING
  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd Servo1, Cmd$
  SendCmd Servo2, Cmd$

  Glo.CmdPwm(1) = 0
  Glo.CmdPwm(2) = 0

END SUB
DECLARE SUB StopYMtr ()
SUB StopYMtr
  LOCAL Cmd AS STRING

  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd Servo3, Cmd$

  Glo.CmdPwm(3) = 0

END SUB

DECLARE SUB CalEncoder (YXAxis)


DECLARE SUB MoveXVel (dir)
SUB MoveXVel (MoveDir)
   LOCAL ControlByte AS INTEGER
   LOCAL X1, X2 AS LONG
   LOCAL Cmd AS STRING
   CALL SetHomeCap 'stop on limit 1

   IF MoveDir = PosDir THEN
     ControlByte = LoadVel OR LoadAcc OR PosMode OR VelMode
   ELSE
     ControlByte = LoadVel OR LoadAcc OR PosMode OR VelMode OR RevDir
   END IF

   X1& = XVel(Glo.AdVal(4))  'glo.CmdVelocity(Servo1)
   X2& = XAcel(Glo.AdVal(4)) 'glo.CmdAccel(Servo1)

   'build the command string
   Cmd$ = CHR$(&H94) + CHR$(ControlByte) + LongToStr(X1&) + LongToStr(X2&)

   SendCmd Servo1, Cmd$

   SendCmd Servo2, Cmd$

   CALL GoXMtrs

END SUB

DECLARE SUB MoveYVel (dir)
SUB MoveYVel (MoveDir)
   LOCAL ControlByte AS INTEGER
   LOCAL X1, X2 AS LONG
   LOCAL Cmd AS STRING
   CALL SetHomeCap 'stop on limit 1

   IF MoveDir = PosDir THEN
     ControlByte = LoadVel OR LoadAcc OR PosMode OR VelMode
   ELSE
     ControlByte = LoadVel OR LoadAcc OR PosMode OR VelMode OR RevDir
   END IF

   X1& = YVel(Glo.Ad3)  'glo.CmdVelocity(Servo3)
   X2& = YAcel(Glo.Ad3) 'glo.CmdAccel(Servo3)

   'build the command string
   Cmd$ = CHR$(&H94) + CHR$(ControlByte) + LongToStr(X1&) + LongToStr(X2&)

   SendCmd Servo3, Cmd$

   CALL GoYMtr

END SUB
DECLARE SUB SetHomeCap ()
SUB SetHomeCap
  LOCAL address AS INTEGER
  LOCAL Cmd AS STRING
  address = &HFF   'all Mtrs

  Cmd$ = CHR$(&H19) + CHR$(&H9)

  SendCmd address, Cmd$

END SUB

DECLARE SUB GoXMtrs ()
SUB GoXMtrs
  LOCAL Cmd AS STRING
  Cmd$ = CHR$(&H5)
  SendCmd Servo1, Cmd$
  SendCmd Servo2, Cmd$

END SUB
DECLARE SUB GoYMtr ()
SUB GoYMtr
  LOCAL Cmd AS STRING
  Cmd$ = CHR$(&H5)
  SendCmd Servo3, Cmd$

END SUB
DECLARE SUB JogJoyStk ()
SUB JogJoyStk
  LOCAL StopOn AS INTEGER
  LOCAL keyinbuff AS INTEGER 'to be removed
  'add limit switch stop; enable with 'stop on find home'
  'use PWM mode


'  IF NOT (SCANstruc.XEnable) THEN
    'PrintClrStr 1, 1, "* Check Motors On *"
    'PrintClrStr 2, 1, "*  Press Any Key  *"
'    DO
'    LOOP UNTIL KeyInBuff
    'FlushKeys
'    EXIT SUB
'  END IF

  'PrintStr 1, 1, "X Pos: "
  'PrintStr 2, 1, "Y Pos: "
  'PrintStr 3, 1, "A Pos: "

  SetModePwm

  StopOn = FALSE

'  DO

'      IF ExitSub THEN EXIT DO

      'calculated PWM output based on A/D 1 & 2

      IF Glo.Ad2 <= 127 THEN 'left
        Glo.CmdPwm(2) = CINT((LU(Corr1(Glo.Ad1)) / 100) * 255)
        Glo.CmdPwm(1) = CINT((LF(Corr2(Glo.Ad2)) / 100) * Glo.CmdPwm(2))
      ELSE 'right
        Glo.CmdPwm(1) = CINT((LU(Corr1(Glo.Ad1)) / 100) * 255)
        Glo.CmdPwm(2) = CINT((LF(Corr2(Glo.Ad2)) / 100) * Glo.CmdPwm(1))
      END IF

      IF Glo.CmdPwm(1) = 0 AND Glo.CmdPwm(2) = 0 THEN
         IF SCANstruc.AutoHold THEN
           IF NOT StopOn THEN
            CALL StopMtrs 'put into velocity mode and set velocity to 0
            SetModeVel 'sets vel to 0
            StopOn = TRUE
           END IF
         ELSE
         GOSUB SetJoyPwm
      END IF
      ELSE
         GOSUB SetJoyPwm
      END IF

'  LOOP

  'FlushKeys

  IF SCANstruc.AutoHold THEN
    CALL StopMtrs 'put into velocity mode and set velocity to 0
    SetModeVel 'sets vel to 0
  ELSE
    SetModePwm  'put into pwm mode and set output to zero
  END IF

  EXIT SUB

SetJoyPwm:

  CALL SetPwm(Servo1, Glo.CmdPwm(1))
  CALL SetPwm(Servo2, Glo.CmdPwm(2))
  GoXMtrs
  StopOn = FALSE
  RETURN

END SUB

DECLARE SUB SetModePwm
SUB SetModePwm
  LOCAL Cmd AS STRING
  LOCAL x AS INTEGER
  ControlByte = LoadPWM OR StartNow
  x = 0
  'Build the command string
  Cmd$ = CHR$(&H24) + CHR$(ControlByte) + CHR$(x)

  SendCmd &HFF, Cmd$

END SUB

DECLARE SUB SetModeVel ()
SUB SetModeVel
    LOCAL Cmd AS STRING
    LOCAL X1 AS LONG
    ControlByte = LoadVel OR PosMode OR VelMode OR StartNow

    X1& = 0  'velocity

    'build the command string
    Cmd$ = CHR$(&H54) + CHR$(ControlByte) + LongToStr(X1&)

    SendCmd &HFF, Cmd$

END SUB

DECLARE SUB SetPwm (MtrNum, PVal)
SUB SetPwm (MtrNum, PwmVal)
    LOCAL x AS INTEGER
    LOCAL Cmd AS STRING
    IF PwmVal > 0 THEN
      ControlByte = LoadPWM
      x = PwmVal
    ELSE
      ControlByte = LoadPWM OR RevDir
      x = -(PwmVal)  'Neg of a Neg number = postive number
    END IF

    'Build the command string
    Cmd$ = CHR$(&H24) + CHR$(ControlByte) + CHR$(x)

    SendCmd MtrNum, Cmd$

END SUB
