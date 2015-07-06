
MACRO CONST = MACRO
'****************************************************************************************************
'misc const values
CONST TRUE = -1
CONST FALSE = 0
'Number of servos in system, change as needed.
CONST Servo1 = 1     ' X1
CONST Servo2 = 2     ' X2 (Z for LMT 3D scanner) 5/30/15
CONST Servo3 = 3     ' Y
CONST Servo4 = 4     ' used for encoder only, no motor attached
CONST AllServos = &HFF
CONST LastServo  = 4
CONST InOut1 = 5

CONST ARM_IO = 6  'added 5/30/15 for Nucleo IO

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
CONST PicIoType = 2     'added 5/30/15
CONST ArmIoType = 5     'added 5/30/15

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
'            GLOBALS
'************************************************************************************
'File IO

GLOBAL filenum AS INTEGER
GLOBAL HdrVer AS STRING * 20

'Keypad Table
GLOBAL KeyTable() AS STRING

'COM Port
GLOBAL nComm AS LONG
GLOBAL PicPort AS STRING
GLOBAL PicBaud AS LONG
'kjl
GLOBAL McuPortNum AS LONG    ' GLOBAL McuPortNum AS LONG comm port file#
GLOBAL McuPortName AS STRING
GLOBAL McuPortBaud AS LONG
'_kjl

GLOBAL RecvSize AS LONG
GLOBAL XmitSize AS LONG
GLOBAL MemSize AS LONG

'Joystick to pwm conversion table

GLOBAL Corr1()  AS BYTE
GLOBAL Corr2()  AS BYTE
GLOBAL LF() AS BYTE
GLOBAL LU() AS BYTE

'Motors Vel & Accel pot tables

GLOBAL XVel() AS LONG
GLOBAL YVel() AS LONG
GLOBAL XAcel() AS LONG
GLOBAL YAcel() AS LONG

'Motors Speed Control tables
GLOBAL XSpd()  AS LONG
GLOBAL YSpd()  AS LONG

'memory line start positions for LCD
GLOBAL StartLPos() AS BYTE

'Long integer broken up into (4) separate bytes
GLOBAL A,B,C,D AS INTEGER
GLOBAL controlbyte AS BYTE
GLOBAL ExitSub AS INTEGER
GLOBAL USTOP AS BYTE
GLOBAL KeyDown AS BYTE
GLOBAL filename AS STRING
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
'Misc
'****************************************************************************************************
DECLARE SUB DelayX (Millisec AS INTEGER) '
DECLARE FUNCTION DelayFact& ()
DECLARE FUNCTION GetTick& ()

DECLARE FUNCTION CharsToLong& (BYVAL A AS INTEGER, B AS INTEGER, C AS INTEGER, D AS INTEGER)
DECLARE FUNCTION LongToStr$ (x AS LONG)
DECLARE FUNCTION IntToStr$ (x AS INTEGER)
DECLARE FUNCTION CharsToInt (BYVAL A AS INTEGER, B AS INTEGER)  AS INTEGER

DECLARE FUNCTION QStr (BYVAL Amount!, BYVAL Places AS INTEGER) AS STRING

DECLARE FUNCTION GoodLNG (Num AS STRING) AS INTEGER
DECLARE FUNCTION GoodSNG (Num AS STRING) AS INTEGER

'DECLARE FUNCTION KeyDown () AS INTEGER

' Motor control
'************************************************************************************
DECLARE SUB SetDefaults
DECLARE SUB GetXyPos ()
DECLARE SUB SetForAuto ()
DECLARE SUB ResetPosition (address AS INTEGER)
DECLARE FUNCTION GetXCord& (Cts&)
'DECLARE FUNCTION GetXCord (mCounts as long) as long
DECLARE FUNCTION GetYCord& (Cts&)
DECLARE FUNCTION GetYCord (mCounts AS LONG) AS LONG


DECLARE SUB StopXMtrs ()
DECLARE SUB StopYMtr ()
DECLARE SUB StopMtrs ()
DECLARE SUB CalEncoder (YXAxis AS INTEGER)
DECLARE SUB MoveXVel (dir AS INTEGER)
DECLARE SUB MoveYVel (dir AS INTEGER)
DECLARE SUB SetHomeCap ()
DECLARE SUB GoXMtrs ()
DECLARE SUB GoYMtr ()
DECLARE SUB JogJoyStk ()
DECLARE SUB SetModePwm
DECLARE SUB SetModeVel ()
DECLARE SUB SetPwm (MtrNum AS INTEGER, PVal AS INTEGER)
DECLARE SUB JogAuto ()
DECLARE SUB SetXCtrs ()
DECLARE SUB JogMan ()
DECLARE SUB ManXDN()
DECLARE SUB ManXUP()
DECLARE SUB ManYLFT()
DECLARE SUB ManYRGT()
DECLARE SUB SetAccel (address AS INTEGER)
DECLARE SUB SetGain (address AS INTEGER)
DECLARE SUB EnableAmpl (Value AS INTEGER, address AS INTEGER)
DECLARE SUB SetTables ()
'************************************************************************************
'Motor Calibration File I/O                                                         *
'************************************************************************************
DECLARE FUNCTION CalSave(filename AS STRING) AS INTEGER
DECLARE FUNCTION CalLoad(filename AS STRING) AS INTEGER


SUB DelayX (Millisec AS INTEGER) '
   SLEEP Millisec
END SUB

SUB SetAccel (address AS INTEGER)
 LOCAL MtrNum AS INTEGER
 LOCAL Cmd AS STRING
 'set accel to ans intial value before enabling servo

 IF address < 1 THEN EXIT SUB

 MtrNum = address

 Cmd$ = CHR$(&H54) + CHR$(LoadAcc) + LongToStr(Glo.CmdAccel(MtrNum))

 SendCmd address, Cmd$

END SUB

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

FUNCTION IntToStr$ (x AS INTEGER)

   B = (x AND &HFF)
   A = (((x AND &HFF00&) \ 256&) AND &HFF )

   IntToStr = CHR$(B) + CHR$(A)

END FUNCTION

FUNCTION CharsToInt (BYVAL A AS INTEGER, B AS INTEGER) AS INTEGER
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


FUNCTION GetTick& ()
    GetTick& = GetTickCount()
END FUNCTION


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


FUNCTION LongToStr$ (x AS LONG)

   D = (x AND &HFF)
   C = ((x AND &HFF00&) \ 256& )
   B = ((x AND &HFF0000) \ 65536  )
   A = (((x AND &HFF000000) \ 16777216) AND &HFF)
   LongToStr = CHR$(D) + CHR$(C) + CHR$(B) + CHR$(A)
END FUNCTION


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

FUNCTION QStr(BYVAL Amount!, BYVAL Places AS INTEGER) AS STRING

    QStr = LEFT$(LTRIM$(STR$(Amount!)) + SPACE$(Places), Places)

END FUNCTION


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

SUB StopMtrs
  LOCAL Cmd AS STRING
  LOCAL x AS INTEGER
  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd AllServos, Cmd$

  FOR x = 1 TO 3
    Glo.CmdPwm(x) = 0
  NEXT

END SUB


FUNCTION GoodLNG (Num$) AS INTEGER

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


FUNCTION GoodSNG (Num$) AS INTEGER

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

SUB ResetPosition (address AS INTEGER)
 LOCAL Cmd AS STRING
 IF address < 1 THEN EXIT SUB

 Cmd$ = CHR$(&H0)

 SendCmd address, Cmd$

END SUB

FUNCTION GetXCord& (Cts&)
  IF SCANstruc.XPlus = TRUE THEN 'X positive direction
    GetXCord& = Cts&
  ELSE
    GetXCord& = -Cts&   'X negative direction
  END IF

  EXIT FUNCTION

END FUNCTION

FUNCTION GetYCord& (Cts&)

  IF SCANstruc.YPlus = TRUE THEN 'Y positive cts
    GetYCord& = Cts&
  ELSE
    GetYCord& = -Cts&  'Y negative cts
  END IF

  EXIT FUNCTION

END FUNCTION

SUB StopXMtrs
LOCAL Cmd AS STRING
  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd Servo1, Cmd$
  SendCmd Servo2, Cmd$

  Glo.CmdPwm(1) = 0
  Glo.CmdPwm(2) = 0

END SUB

SUB StopYMtr
  LOCAL Cmd AS STRING

  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd Servo3, Cmd$

  Glo.CmdPwm(3) = 0

END SUB

SUB MoveXVel (MoveDir AS INTEGER)
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


SUB MoveYVel (MoveDir AS INTEGER)
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

SUB SetHomeCap
  LOCAL address AS INTEGER
  LOCAL Cmd AS STRING
  address = &HFF   'all Mtrs

  Cmd$ = CHR$(&H19) + CHR$(&H9)

  SendCmd address, Cmd$

END SUB

SUB GoXMtrs
  LOCAL Cmd AS STRING
  Cmd$ = CHR$(&H5)
  SendCmd Servo1, Cmd$
  SendCmd Servo2, Cmd$

END SUB


SUB GoYMtr
  LOCAL Cmd AS STRING
  Cmd$ = CHR$(&H5)
  SendCmd Servo3, Cmd$
END SUB


SUB JogJoyStk
  LOCAL StopOn AS INTEGER
  LOCAL keyinbuff AS INTEGER 'to be removed
  LOCAL COUNT AS LONG
  'add limit switch stop; enable with 'stop on find home'
  'use PWM mode
  SetModePwm

  StopOn = FALSE
  COUNT = 5
  DO
      ' DIALOG DOEVENTS 20 TO COUNT

      'EZ_DoEvents  5
      IF ExitSub THEN EXIT DO
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

  LOOP

  'FlushKeys
  ExitSub = 0
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


SUB SetModePwm
  LOCAL Cmd AS STRING
  LOCAL x AS INTEGER
  ControlByte = LoadPWM OR StartNow
  x = 0
  'Build the command string
  Cmd$ = CHR$(&H24) + CHR$(ControlByte) + CHR$(x)

  SendCmd &HFF, Cmd$

END SUB


SUB SetModeVel
    LOCAL Cmd AS STRING
    LOCAL X1 AS LONG
    ControlByte = LoadVel OR PosMode OR VelMode OR StartNow

    X1& = 0  'velocity

    'build the command string
    Cmd$ = CHR$(&H54) + CHR$(ControlByte) + LongToStr(X1&)

    SendCmd &HFF, Cmd$

END SUB


SUB SetPwm (MtrNum AS INTEGER, PwmVal AS INTEGER)
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

SUB JogAuto

  'add limit switch stop; enable with 'stop on find home'

  'reset x encoders to insure they match
  CALL SetXCtrs

  StopMtrs  'stop motors in velocity mode
  SetModeVel 'sets vel to 0

  'REMED
  'add home postion (limit button hit) check in case of error!


END SUB

SUB SetXCtrs
  CALL GetXyPos
  SCANstruc.XPosStr = QStr$(SCANstruc.XPos, 10)
  SCANstruc.XOffset = GetXCord(CLNG(SCANstruc.XPos * SCANstruc.XCtr))
  CALL ResetPosition(Servo1)
  CALL ResetPosition(Servo2)
END SUB

  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
FUNCTION CalSave(filename AS STRING) AS INTEGER
    LOCAL ecode AS INTEGER
    LOCAL BytesRead AS INTEGER
    LOCAL filenumber AS INTEGER
    FCreate (filenumber, 0, filename, ECode)
    IF NOT ECode THEN
       CalSave = FALSE
       EXIT FUNCTION
    END IF
    CALL DFWrite(filenum, BYVAL VARPTR(HdrVer), 0, BytesRead, ECode)
    IF NOT ECode THEN GOTO ExitCalSave
        CALL DFWrite2(filenum, BYVAL VARPTR(SCANstruc),LEN(HdrVer), BytesRead, ECode)
    IF NOT ECode THEN GOTO ExitCalSave
    ExitCalSave:
    CALL FClose(filenum)
    IF NOT ECode THEN
      CalSave = FALSE
    ELSE
      CalSave = TRUE
    END IF
END FUNCTION

  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
FUNCTION CalLoad(filename AS STRING) AS INTEGER
   LOCAL ecode AS INTEGER
   LOCAL BytesRead AS INTEGER
   LOCAL filenumber AS INTEGER
   LOCAL temphdr AS HEADER
   CALL FOpen (filenum, 0,0, filename, ECode)
   IF NOT ECode THEN
     CalLoad = FALSE
     EXIT FUNCTION
   END IF
   CALL DFRead(filenum, BYVAL VARPTR(temphdr),0,BytesRead, ECode)
   IF NOT ECode THEN GOTO ExitCalLoad
   'Verify correct header
   IF HdrVer <> Temphdr THEN
     ECode = TRUE
     GOTO ExitCalLoad
   END IF
   CALL DFRead2(filenum, BYVAL VARPTR (ScanStruc), LEN(temphdr), BytesRead, ECode)
   IF NOT ECode THEN GOTO ExitCalLoad
ExitCalLoad:
   CALL FClose(filenum)
   IF NOT ECode THEN
     CalLoad = FALSE
   ELSE
     CalLoad = TRUE
   END IF
END FUNCTION

SUB JogMan
  SetModePwm
END SUB
SUB ManXDN

    CALL SetHomeCap 'stop on limit 1

    'calculated PWM output based on pots
    Glo.CmdPwm(1) = -(XSpd(Glo.AdVal(4)))
    Glo.CmdPwm(2) = Glo.CmdPwm(1)

    CALL SetPwm(Servo1, Glo.CmdPwm(1))
    CALL SetPwm(Servo2, Glo.CmdPwm(2))

    GoXMtrs

END SUB

SUB ManXUP

    CALL SetHomeCap 'stop on limit 1

    'calculated PWM output based on pots
    Glo.CmdPwm(1) = XSpd(Glo.AdVal(4))
    Glo.CmdPwm(2) = Glo.CmdPwm(1)

    CALL SetPwm(Servo1, Glo.CmdPwm(1))
    CALL SetPwm(Servo2, Glo.CmdPwm(2))

    GoXMtrs

END SUB

SUB ManYLFT

    CALL SetHomeCap 'stop on limit 1

    Glo.CmdPwm(3) = -(YSpd(Glo.Ad3))   '(-) = reverse motion

    CALL SetPwm(Servo3, Glo.CmdPwm(3))

    GoYMtr

END SUB

SUB ManYRGT

    CALL SetHomeCap 'stop on limit 1

    Glo.CmdPwm(3) = YSpd(Glo.Ad3)   '(-) = reverse motion

    CALL SetPwm(Servo3, Glo.CmdPwm(3))

    GoYMtr

END SUB

SUB Profiler
  SCANstruc.ScanFlag = 0

  'check all scan cal parameters
  IF SCANstruc.XHigh > SCANstruc.XLow THEN
    IF SCANstruc.YHigh > SCANstruc.YLow THEN
      IF (SCANstruc.XIndex > 0 AND SCANstruc.YIndex > 0) THEN
    IF (SCANstruc.XPlus = TRUE OR SCANstruc.XPlus = FALSE) THEN
      IF (SCANstruc.YPlus = TRUE OR SCANstruc.YPlus = FALSE) THEN
        IF SCANstruc.XSpeed > 0 THEN
          IF SCANstruc.YSpeed > 0 THEN
        IF SCANstruc.XEnable THEN
          IF SCANstruc.YEnable THEN
            IF ProfileScan THEN
              SCANstruc.ScanFlag = -1
            ELSE
              SCANstruc.ScanFlag = 0
            END IF
          END IF
        END IF
          END IF
        END IF
      END IF
    END IF
      END IF
    END IF
  END IF
 END SUB

SUB ReSetMotors
  LOCAL indexset AS INTEGER
  LOCAL LoopPos AS LONG
  CALL GetStatus(AllServos)

  IF SCANstruc.IndexY THEN 'X Scan, Y Index
    IF SCANstruc.IndexLow THEN    'indexing towards low position
      SCANstruc.IndexInc = -1
      IF SCANstruc.YPlus = TRUE THEN 'scanning positive direction
    IndexSet = 1
      ELSE
    IndexSet = -1
      END IF
    ELSE   'POSDIR
      SCANstruc.IndexInc = 1
      IF SCANstruc.YPlus = TRUE THEN 'scanning positive direction
    IndexSet = -1
      ELSE
    IndexSet = 1
      END IF
    END IF

    LoopPos = CLNG(Glo.Position(3) / SCANstruc.YIndexCts) + IndexSet

    IF SCANstruc.YPlus THEN  'Y positive direction
       IF LoopPos > SCANstruc.YDataEnd THEN
     SCANstruc.IndexCt = SCANstruc.YDataEnd
       ELSEIF LoopPos < SCANstruc.YDataStart THEN
     SCANstruc.IndexCt = SCANstruc.YDataStart
       ELSE
     SCANstruc.IndexCt = LoopPos
       END IF
    ELSE               'Y negative direction
       IF LoopPos < -SCANstruc.YDataEnd THEN
     SCANstruc.IndexCt = SCANstruc.YDataEnd
       ELSEIF LoopPos > -SCANstruc.YDataStart THEN
     SCANstruc.IndexCt = SCANstruc.YDataStart
       ELSE
     SCANstruc.IndexCt = ABS(LoopPos)
       END IF
     END IF

  ELSE  'Y Scan, X Index

    'IndexSet is used to backup 1 raster for overlap of scan restarts
    IF SCANstruc.IndexLow THEN  'Index towards low position
      SCANstruc.IndexInc = -1
      IF SCANstruc.XPlus = TRUE THEN 'scanning positive counts direction
    IndexSet = 1
      ELSE
    IndexSet = -1
      END IF
    ELSE                   'Index towards high position
      SCANstruc.IndexInc = 1
      IF SCANstruc.XPlus = TRUE THEN 'scanning positive counts direction
    IndexSet = -1
      ELSE
    IndexSet = 1
      END IF
    END IF

    LoopPos = CLNG(Glo.Position(1) / SCANstruc.XIndexCts) + IndexSet

    IF SCANstruc.XPlus THEN  'X positive direction
      IF LoopPos > SCANstruc.XDataEnd THEN
    SCANstruc.IndexCt = SCANstruc.XDataEnd
      ELSEIF LoopPos < SCANstruc.XDataStart THEN
    SCANstruc.IndexCt = SCANstruc.XDataStart
      ELSE
    SCANstruc.IndexCt = LoopPos
      END IF
    ELSE               'X negative direction
      IF LoopPos < -SCANstruc.XDataEnd THEN
    SCANstruc.IndexCt = SCANstruc.XDataEnd
      ELSEIF LoopPos > -SCANstruc.XDataStart THEN
    SCANstruc.IndexCt = SCANstruc.XDataStart
      ELSE
    SCANstruc.IndexCt = ABS(LoopPos)
      END IF
    END IF

    IF SCANstruc.NextFlag THEN
      IF SCANstruc.IndexLow THEN  'Index towards low position
    SCANstruc.IndexCt = SCANstruc.XDataEnd
      ELSE                   'Index towards high position
    SCANstruc.IndexCt = SCANstruc.XDataStart
      END IF
      SCANstruc.NextFlag = FALSE
    END IF

  END IF

END SUB

FUNCTION ProfileScan AS INTEGER

   IF GoodLNG(STR$(SCANstruc.XLow * SCANstruc.XCtr + 1)) THEN
     SCANstruc.XStartCts = CLNG(SCANstruc.XLow * SCANstruc.XCtr)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$((SCANstruc.XHigh + SCANstruc.OverLap) * SCANstruc.XCtr + 1)) THEN
     SCANstruc.XEndCts = CLNG((SCANstruc.XHigh + SCANstruc.OverLap) * SCANstruc.XCtr)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$(SCANstruc.YLow * SCANstruc.YCtr + 1)) THEN
     SCANstruc.YStartCts = CLNG(SCANstruc.YLow * SCANstruc.YCtr)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$(SCANstruc.YHigh * SCANstruc.YCtr + 1)) THEN
     SCANstruc.YEndCts = CLNG(SCANstruc.YHigh * SCANstruc.YCtr)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$(SCANstruc.XCtr * SCANstruc.XIndex + 1)) THEN
     SCANstruc.XIndexCts = CLNG(SCANstruc.XCtr * SCANstruc.XIndex)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$(SCANstruc.YCtr * SCANstruc.YIndex + 1)) THEN
     SCANstruc.YIndexCts = CLNG(SCANstruc.YCtr * SCANstruc.YIndex)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   SCANstruc.XDataStart = CLNG(SCANstruc.XStartCts / SCANstruc.XIndexCts)
   SCANstruc.XDataEnd = CLNG(SCANstruc.XEndCts / SCANstruc.XIndexCts)

   SCANstruc.YDataStart = CLNG(SCANstruc.YStartCts / SCANstruc.YIndexCts)
   SCANstruc.YDataEnd = CLNG(SCANstruc.YEndCts / SCANstruc.YIndexCts)

   SCANstruc.IndexCt = SCANstruc.XDataStart

   ProfileScan = TRUE

   EXIT FUNCTION

END FUNCTION

SUB XScan
    LOCAL MoveToPos1, MoveToPos2 AS LONG
    'EZ_DoEvents  5
    DO WHILE SCANstruc.IndexCt >= (SCANstruc.YDataStart AND SCANstruc.IndexCt) <= SCANstruc.YDataEnd
      'EZ_DoEvents  5
      UStop = DoY(SCANstruc.YIndexCts * SCANstruc.IndexCt)'index Y axis into position
      IF UStop THEN EXIT DO 'check if user hit stop
      IF SCANstruc.XCts > SCANstruc.XStartCts + (SCANstruc.XEndCts - SCANstruc.XStartCts) / 2 THEN
        MoveToPos1& = SCANstruc.XStartCts
        MoveToPos2& = SCANstruc.XEndCts
      ELSE
        MoveToPos1& = SCANstruc.XEndCts
        MoveToPos2& = SCANstruc.XStartCts
      END IF
      UStop = DoX(MoveToPos1&) 'put x axis into position
      IF UStop THEN EXIT DO 'check if user hit stop
      IF SCANstruc.DualRas THEN
        UStop = DoX(MoveToPos2&)'put x axis into position
        IF UStop THEN EXIT DO 'check if user hit stop
      END IF
      SCANstruc.IndexCt = SCANstruc.IndexCt + SCANstruc.IndexInc
    LOOP
END SUB

SUB YScan
    LOCAL MoveToPos1, MoveToPos2 AS LONG
    'EZ_DoEvents  5
    DO WHILE SCANstruc.IndexCt >= (SCANstruc.XDataStart AND SCANstruc.IndexCt) <= SCANstruc.XDataEnd
     ' EZ_DoEvents  5
      UStop = DoX(SCANstruc.XIndexCts * SCANstruc.IndexCt)'index X axis into position
      IF UStop THEN EXIT DO 'check if user hit stop
      IF SCANstruc.YCts > SCANstruc.YStartCts + (SCANstruc.YEndCts - SCANstruc.YStartCts) / 2 THEN
         MoveToPos1& = SCANstruc.YStartCts
         MoveToPos2& = SCANstruc.YEndCts
      ELSE
         MoveToPos1& = SCANstruc.YEndCts
         MoveToPos2& = SCANstruc.YStartCts
      END IF
      UStop = DoY(MoveToPos1&)'put y axis into position
      IF UStop THEN EXIT DO 'check if user hit stop
      IF SCANstruc.DualRas THEN
        UStop = DoY(MoveToPos2&)'put y axis into position
        IF UStop THEN EXIT DO 'check if user hit stop
      END IF
      SCANstruc.IndexCt = SCANstruc.IndexCt + SCANstruc.IndexInc
    LOOP
 END SUB

DECLARE FUNCTION DoX (AbsPos AS LONG) AS INTEGER

FUNCTION DoX (MPos AS LONG) AS INTEGER
   LOCAL MoveToCts AS LONG
   MoveToCts& = GetXCord(MPos&)
   CALL MoveX(MoveToCts&)
  ' EZ_DoEvents  5
   DO
     'DIALOG DOEVENTS 1
      'EZ_DoEvents  5
      IF KeyDown <> 0 THEN 'user pressed KEYPAD
       DoX = TRUE: EXIT FUNCTION
      END IF
      IF (Glo.Stat(Servo1) AND HomeInProg) THEN
    'OK
      ELSE  'user pressed ABORT switch
       DoX = TRUE: EXIT FUNCTION
     END IF
   LOOP UNTIL ABS(SCANstruc.XCts - ABS(MoveToCts&)) < (SCANstruc.XCtr / 8) 'REM

   DoX = FALSE: EXIT FUNCTION

END FUNCTION

DECLARE FUNCTION DoY (AbsPosY AS LONG) AS INTEGER

FUNCTION DoY (MPos AS LONG) AS INTEGER
   LOCAL MoveToCts AS LONG
   MoveToCts& = GetYCord(MPos&)
   CALL MoveY(MoveToCts&)
   'EZ_DoEvents  5
   DO
     'DIALOG DOEVENTS 1
     'EZ_DoEvents  5
     IF KeyDown <> 0 THEN 'User pressed KEYPAD
       DoY = TRUE: EXIT FUNCTION
     END IF
     IF (Glo.Stat(Servo3) AND HomeInProg) THEN
    'OK
     ELSE  'user pressed ABORT switch
    DoY = TRUE: EXIT FUNCTION
     END IF
   LOOP UNTIL (ABS(SCANstruc.YCts - ABS(MoveToCts&)) < (SCANstruc.YCtr / 8))

   DoY = FALSE: EXIT FUNCTION

END FUNCTION

DECLARE SUB MoveX (PosCts&)
SUB MoveX (PosCts&)
   LOCAL ActPos AS LONG
   LOCAL Cmd AS STRING
   CALL SetHomeCap 'stop on limit 1

   ControlByte = LoadPos OR LoadVel OR LoadAcc OR PosMode

   '**********************************************************
   'When user changes current position the counters get zeroed.
   'Adjust move-to position offset accordingly
   '**********************************************************
   ActPos& = PosCts& - SCANstruc.XOffset

   'Build the command string
   Cmd$ = CHR$(&HD4) + CHR$(ControlByte) + LongToStr(ActPos&)
   Cmd$ = Cmd$ + LongToStr(Glo.CmdVelocity(Servo1)) + LongToStr(Glo.CmdAccel(Servo1))

   SendCmd Servo1, Cmd$

   SendCmd Servo2, Cmd$

   CALL GoMtrs

END SUB
DECLARE SUB MoveY (PosCts&)
SUB MoveY (PosCts&)
  LOCAL ActPos AS LONG
  LOCAL Cmd AS STRING
  CALL StopYMtr

  CALL SetHomeCap 'stop on limit 1

  ControlByte = LoadPos OR LoadVel OR LoadAcc OR PosMode

  '**********************************************************
  'When user changes current position the counters get zeroed.
  'Adjust move-to position accordingly
  ActPos& = PosCts& - SCANstruc.YOffset
  '**********************************************************

  'Build the command string
  Cmd$ = CHR$(&HD4) + CHR$(ControlByte) + LongToStr(ActPos&)
  Cmd$ = Cmd$ + LongToStr(Glo.CmdVelocity(Servo3)) + LongToStr(Glo.CmdAccel(Servo3))

  SendCmd Servo3, Cmd$

  CALL GoMtrs

END SUB
SUB GoMtrs
  LOCAL Cmd AS STRING
  Cmd$ = CHR$(&H5)
  SendCmd AllServos, Cmd$

END SUB
