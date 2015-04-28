
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
