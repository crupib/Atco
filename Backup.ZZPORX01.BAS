#COMPILE EXE
#COMPILER PBCC 6

#RESOURCE ICON, 100, "Atco.ico"
#RESOURCE VERSIONINFO
#RESOURCE FILEVERSION 6, 0, 0, 0
#RESOURCE PRODUCTVERSION 6, 0, 0, 0
DEFINT A-Z

TYPE ScanPrams
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
  GLOBAL SCANparm AS ScanPrams

  TYPE glorecord
   NumModules AS INTEGER
   StatusDef(5) AS INTEGER
   ModuleType(5) AS INTEGER
   ModuleVer(5) AS INTEGER
   Position(5) AS LONG
   CmdPosition(5) AS LONG
   HomePosition(5) AS LONG
   velocity(5) AS INTEGER
   CmdVelocity(5) AS LONG
   CmdAccel(5) AS LONG
   CmdPwm(5) AS INTEGER 'LONG
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
   SRD(5) AS INTEGER
   MiscMode(5) AS INTEGER
   SIOErrorMode AS INTEGER
   SIOError AS INTEGER
   CkSumError AS INTEGER
   SIOPort AS INTEGER
   AmpQuery AS INTEGER
   PowerQuery AS INTEGER
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
   SyncCounter AS LONG
 END TYPE
 GLOBAL glo AS glorecord

TYPE HEADER
  hdr AS STRING * 20
END TYPE

'//////////////////////////////////////////////////////////////////
REM new RS232 PC compatible
'//////////////////////////////////////////////////////////////////
'DECLARE SUB SetIRQ (ComPortNum%, IRQ%, ECode%)
'DECLARE SUB SetPortAddr (ComPortNum%, PortAddress%, ECode%)
'DECLARE SUB CloseCommPort (ComPortNum%, ECode%)
DECLARE SUB CommError (ComPortNum%, ECode%)
DECLARE FUNCTION OpenComPorts ()
'DECLARE SUB FlushBuffers (ComPortNum%, WhichBuffer%, ECode%)
DECLARE SUB FlushBuffers (PICPort AS STRING, zero AS INTEGER, ECode AS INTEGER)
DECLARE SUB GetCharsInBuffer (PICPort AS STRING, RecvQue AS STRING, XmitQue AS INTEGER, ECode)
DECLARE SUB LineStatus (ComPortNum%, Cts%, DSR%, CD%, RI%, ECode%)
DECLARE SUB GetDTRState (ComPortNum%, DTRState%, ECode%)
DECLARE SUB GetRTSState (ComPortNum%, DTRState%, ECode%)
DECLARE SUB SetDTRSignal (ComPortNum%, DTRState%, ECode%)
DECLARE SUB SetRTSSignal (ComPortNum%, DTRState%, ECode%)
DECLARE SUB ReadFromComm (ComPortNum%, ReadBuffer$, BytesRead%, ECode%)
DECLARE SUB SetFlowControl (ComPortNum%, InFlow%, OutFlow%, InMin%, InMax%, XonChar%, XoffChar%, ECode%)
'DECLARE SUB WriteToComm (ComPortNum%, WriteBuffer$, BytesWritten%, ECode%)
DECLARE SUB WriteToComm (PICPort AS STRING, SendStr AS STRING, BytesWritten AS INTEGER, ECode AS INTEGER)
DECLARE SUB ChangeCommSettings (ComPortNum%, BaudRate&, DataBits%, Parity%, StopBits%, ECode%)
'DECLARE SUB OpenCommPort (ComPortNum%, BaudRate&, DataBits%, Parity%, StopBits%, ECode%)
DECLARE SUB UARTType (ComPortNum%, UART%, ECode%)
DECLARE SUB SetFIFOTriggerLevel (ComPortNum%, TriggerLevel%, ECode%)
DECLARE SUB CalcRequiredMem (PortSeg%, PortOfs%, RecvSeg%, RecvOfs%, XmitSeg%, XmitOfs%, NumPorts%, MemSize&, ECode%)
DECLARE SUB InitCommBuffers (ECode%)
DECLARE SUB DeleteCommBuffers (ECode%)
DECLARE SUB InitSharedHandler (PortSeg%, PortOfs%, NumPorts%, IRQ%, StatusRegisterAddr%, ECode%)
DECLARE SUB CloseCommPort (comport AS STRING, ecode AS INTEGER)

'REM new routines for Joe Loyd Drive
DECLARE SUB LoadInfo ()
DECLARE SUB SaveInfo ()
DECLARE SUB KeyWait ()
DECLARE FUNCTION GetFileName$ (RowPos%, EditFile$)
DECLARE FUNCTION GetDiskFile$ (FSpec$)
'DECLARE FUNCTION CheckDisk (DataDir, Drv$, WriteLen&, FileNumber$)

'motor soft controls
DECLARE FUNCTION GetXCord& (Cts&)
DECLARE FUNCTION ProfileScan ()
DECLARE SUB ReSetMotors ()
DECLARE SUB SetForAuto ()
DECLARE FUNCTION GetYCord& (Cts&)

DECLARE FUNCTION DoX (AbsPos&)
DECLARE FUNCTION DoY (AbsPosY&)

DECLARE SUB MoveXVel (dir)
DECLARE SUB MoveYVel (dir)
DECLARE SUB PrintPos ()

'new x-ray
'added from probas lib 7.1
DECLARE FUNCTION GetTick& ()
DECLARE SUB STRIPBLANKS (A$, Num, SLen) 'pro assembler
DECLARE SUB Strip (A$)   'pro basic
DECLARE SUB Delay18th (MiniDelay)
DECLARE FUNCTION DosInky$ ()
DECLARE FUNCTION DirFirst (FileSpec$, BYVAL FileAtrr)
DECLARE FUNCTION DirNext ()
DECLARE FUNCTION DirFileName$ ()

'REM J.L. added from probas lib 7.1
DECLARE FUNCTION LVal& (St$)
DECLARE FUNCTION StrRChr (St$, BYVAL SrchChar)
DECLARE SUB StripChar (St$, Ch$, SLen%)
DECLARE SUB CRC2 (Rec$, HiCRC%, LowCRC%)
DECLARE FUNCTION GetTick& ()
DECLARE FUNCTION FarPeek (BYVAL DSeg, BYVAL DOfs)
DECLARE SUB FarPoke (BYVAL DSeg, BYVAL DOfs, BYVAL PVal)
DECLARE SUB ShiftR (Value, COUNT)
DECLARE SUB ShiftL (Value, COUNT)
DECLARE FUNCTION GetByte (DSeg, DOfs)
DECLARE SUB PutByte (DSeg, DOfs, PVal)
DECLARE SUB BiosInKey (AscCode, ScanCode)
DECLARE FUNCTION GetKeyQ (AscCode, ScanCode)
DECLARE FUNCTION DosInky$ ()
DECLARE FUNCTION CheckDsk (Drv$)
DECLARE SUB STRIPBLANKS (A$, Num, SLen) 'pro assembler
DECLARE SUB Strip (A$)   'pro basic
DECLARE FUNCTION DirFirst (FileSpec$, BYVAL FileAttrib%)
DECLARE FUNCTION DirNext ()
DECLARE FUNCTION DirFileName$ ()
DECLARE FUNCTION DirFileSize& ()
'DECLARE SUB SCROLL (Ulr, Ulc, Lrr, Lrc, Tnum)
DECLARE FUNCTION CalcAttr2% (FORE, BACK)
DECLARE SUB IPtrSort (DSeg, DOfs1, DSeg2, DOfs2, Elements)
DECLARE SUB InitPtr (DSeg, DOfs, COUNT)
DECLARE SUB SFRead2 (HANDLE, St$, BR, ECode)
DECLARE SUB SFWrite (HANDLE, St$, BW, ECode)
DECLARE SUB ClrKbd ()
DECLARE SUB Delay18th (MiniDelay)
DECLARE FUNCTION SETDRV (Drv$)
DECLARE SUB COPYFILE (Fil$, DDrv$, ECode)


'new Si
DECLARE FUNCTION CalSave (FILENAME$)
DECLARE FUNCTION CalLoad (FileNumber$)

DECLARE SUB DFRead (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFRead2 (filenum AS INTEGER, passrec AS ScanPrams , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFWrite (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFWrite2 (filenum AS INTEGER, passrec AS ScanPrams , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB FCreate (filenumber AS INTEGER, myattr AS INTEGER, filename AS STRING, ECode AS INTEGER)
DECLARE SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING, ECode AS INTEGER)
DECLARE SUB FClose (filenumber AS INTEGER)

DECLARE FUNCTION Exist2 (FileNumber$)

REM 'added from crescent
'DECLARE FUNCTION Ascii (any$)
DECLARE FUNCTION FUsing$ (Num$, Image$)
'DECLARE SUB InitInt (SEG segm, Value, NumEls)
'DECLARE SUB ISortI (SEG segm1, SEG segm2, NumEls, diri)
DECLARE FUNCTION WriteTest (DRIVE$)
DECLARE FUNCTION DriveSpace& (Drv$)
DECLARE FUNCTION Valid (FileNumber$)
DECLARE SUB SetDrive (Drv$)
DECLARE SUB KillFile (FILENAME$)


'my subs
DECLARE FUNCTION QStr$ (BYVAL Amount!, BYVAL Places)
DECLARE SUB DelayX (Millisec) '
DECLARE FUNCTION DoX (Position&)
DECLARE SUB GoMtrs ()
DECLARE FUNCTION CharsToInt (BYVAL A AS INTEGER, B AS INTEGER)
DECLARE FUNCTION CharsToLong& (BYVAL A AS INTEGER, B AS INTEGER, C AS INTEGER, D AS INTEGER)
DECLARE SUB ClearBits (address AS INTEGER)
DECLARE SUB EnableAmpl (Value AS INTEGER, address AS INTEGER)
DECLARE SUB SetAccel (address AS INTEGER)
DECLARE FUNCTION InitNetWork ()
DECLARE FUNCTION IntToStr$ (x AS INTEGER)
DECLARE FUNCTION LongToStr$ (x AS LONG)
DECLARE SUB MtrOff (address AS INTEGER)
DECLARE SUB ResetPosition (address AS INTEGER)
DECLARE SUB SendCmd (address AS INTEGER, CmdString AS STRING)
DECLARE SUB SetGain (address AS INTEGER)
DECLARE FUNCTION SIOGetByte (Character AS INTEGER, TimeOutPeriod AS INTEGER)
DECLARE SUB StopMtrs ()
DECLARE SUB FixSIOerror ()
DECLARE SUB KEdit (Edit$, ExitCode)
DECLARE SUB AlphaNumIN (EditStr AS STRING, ExitCode AS INTEGER)
DECLARE FUNCTION DelayFact& ()

DECLARE SUB GetScanCal ()

DECLARE SUB CalEncoder (YXAxis)
DECLARE SUB ManYRGT ()
DECLARE SUB ManXUP ()
DECLARE SUB ManXDN ()
DECLARE SUB ManYLFT ()
DECLARE SUB SetPwm (MtrNum, PVal)
DECLARE FUNCTION KeyInBuff ()
DECLARE SUB JogAuto ()
DECLARE SUB JogMan ()
DECLARE SUB SetHomeCap ()
DECLARE SUB MoveX (PosCts&)
DECLARE SUB MoveY (PosCts&)
DECLARE SUB SetModePos ()
DECLARE SUB SetModePwm ()
DECLARE SUB SetModeVel ()
DECLARE SUB GetStatus (Num)
DECLARE SUB GoXMtrs ()
DECLARE SUB GoYMtr ()
DECLARE FUNCTION GoodLNG (Num$)
DECLARE FUNCTION GoodSNG (Num$)
DECLARE SUB SetTables ()
DECLARE SUB SetXCtrs ()
DECLARE SUB GetXyPos ()
DECLARE FUNCTION GetSelectKey ()
DECLARE FUNCTION GetYesNo$ ()
DECLARE SUB StopXMtrs ()
DECLARE SUB StopYMtr ()
DECLARE SUB PrintXPos ()
DECLARE SUB PrintYPos ()
DECLARE SUB PrintAPos ()
DECLARE SUB JogJoyStk ()
DECLARE SUB JogXSpd ()

'keypad & LCD stuff
DECLARE SUB StrobeInstr (SChar)
DECLARE SUB StrobeData (SChar)
DECLARE SUB InitDisplay ()
DECLARE SUB SetLcdPos (y, x)
DECLARE FUNCTION GetLcdRowPos ()
DECLARE FUNCTION GetLcdColPos ()
DECLARE SUB PrintChar (y, x, char$)    'print single char
DECLARE SUB PrintClrStr (y, x, Text$)  'print string & clear line
DECLARE SUB PrintStr (y , x , ptrstr AS STRING * 10)     'print string
DECLARE SUB ddelay (Nval)
DECLARE FUNCTION GetKeys$ ()
DECLARE SUB FlushKeys ()
DECLARE FUNCTION KeyDown ()
DECLARE SUB ClrLCD ()
DECLARE SUB SetPorts ()
DECLARE FUNCTION GetLcdMemPos ()
DECLARE SUB CursorON ()
DECLARE SUB CursorOFF ()

MACRO CONST = MACRO
CONST D10 = 150   ' ~ 1 usec (compiled code) x10 uncompiled
CONST D20 = 500   ' ~ 3 usec
CONST D50 = 1000  ' ~ 6 usec
CONST D100 = 2000 ' ~ 12 usec
CONST LcdLines = 4
CONST LcdColumns = 20

REM
CONST KeyReg = &H78 '&HFF00 Port 0 (keypad data bits)
CONST LcdReg = &H7A '&HFF10 Port 2 (LCD data bits)
CONST BitReg = &H7B '&HFF08 Port 3 (LCD and Keypad control bits)

CONST KeyModeReg = &H98 '&HFF01 Port 0 Mode Register (For Key Port)
CONST LcdModeReg = &H9A '&HFF11 Port 2 Mode Register (For LCD Port)
CONST BitModeReg = &H9B '&HFF09 Port 3 Mode Register (For Key/LCD)

CONST DataPortIn = &H0
CONST DataPortOut = &HFF

'Port 3 uses low nibble for SPI; safe to use high nibble only
CONST DataStbOn = &HA0     ' RS=1, R/W=0, L/E=1, K/E=0
CONST DataStbOff = &H80    ' RS=1, R/W=0, L/E=0, K/E=0
CONST InstrStbOn = &H20    ' RS=0, R/W=0, L/E=1, K/E=0
CONST InstrStbOff = &H0    ' RS=0, R/W=0, L/E=0, K/E=0
CONST LcdBusy = &H60       ' RS=0, R/W=1, L/E=1, K/E=0
CONST LcdPos = &H60        ' RS=0, R/W=1, L/E=1, K/E=0
CONST KeyStbOn = &H10      ' RS=0, R/W=0, L/E=0, K/E=1
CONST KeyStbOff = &H0      ' RS=0, R/W=0, L/E=0, K/E=0

CONST BusyFlag = &H80
CONST LcdAddress = &H7F
CONST LcdAddrSet = &H80

'miss const values
CONST TRUE = -1
CONST FALSE = NOT TRUE
CONST gain = 0
CONST NegDir = 0
CONST PosDir = -1

'Number of servos in system, change as needed.
CONST Servo1 = 1
CONST Servo2 = 2
CONST Servo3 = 3
CONST Servo4 = 4
CONST AllServos = &HFF
CONST LastServo = 4
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
CONST  AccelDone = 8
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


 'DIM SHARED Glo AS GLOBAL
  TYPE glorecord
   NumModules AS INTEGER
   StatusDef(5) AS INTEGER
   ModuleType(5) AS INTEGER
   ModuleVer(5) AS INTEGER
   Position(5) AS LONG
   CmdPosition(5) AS LONG
   HomePosition(5) AS LONG
   velocity(5) AS INTEGER
   CmdVelocity(5) AS LONG
   CmdAccel(5) AS LONG
   CmdPwm(5) AS INTEGER 'LONG
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
   SRD(5) AS INTEGER
   MiscMode(5) AS INTEGER
   SIOErrorMode AS INTEGER
   SIOError AS INTEGER
   CkSumError AS INTEGER
   SIOPort AS INTEGER
   AmpQuery AS INTEGER
   PowerQuery AS INTEGER
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
   SyncCounter AS LONG
 END TYPE
 GLOBAL glo AS glorecord
 GLOBAL filenum AS INTEGER
 GLOBAL HdrVer AS HEADER
 GLOBAL SCANPARAMS AS header
 GLOBAL nComm   AS LONG
 GLOBAL ThumbDisk AS STRING * 2
  'COM PORTS
 GLOBAL RecvSize AS LONG
 GLOBAL XmitSize AS LONG
 GLOBAL MemSize AS LONG
 ' GLOBAL PICPort AS INTEGER
 GLOBAL PICPort AS STRING
 GLOBAL PICBaud AS LONG
  'delay timer
 GLOBAL DelayCtr AS LONG
 GLOBAL WaitX AS INTEGER

FUNCTION PBMAIN
  DIM keyin AS STRING
  DIM myinput AS STRING
  HdrVer.hdr = "SCU-1.00            "
  ThumbDisk = "C:\UCALS\"
  'set com port numbers & baud
 ' PICPort = 1
  PICPort  =  "\\.\COM31"
  PICBaud = 19200

  DelayCtr = DelayFact
  WaitX = 1   'delay used in comm


  CALL SetTables

  'memory line start positions for LCD
'  DIM StartLPos(3) AS BYTE
' StartLPos(0) = &H0
'  StartLPos(1) = &H40
'  StartLPos(2) = &H14
'  StartLPos(3) = &H54

  DIM KeyTable(20) AS STRING
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

  DIM ExtKey(49 TO 57, 0 TO 3) AS INTEGER
  ExtKey(49, 0) = 49: ExtKey(49, 1) = 65: ExtKey(49, 2) = 66: ExtKey(49, 3) = 67
  ExtKey(50, 0) = 50: ExtKey(50, 1) = 68: ExtKey(50, 2) = 69: ExtKey(50, 3) = 70
  ExtKey(51, 0) = 51: ExtKey(51, 1) = 71: ExtKey(51, 2) = 72: ExtKey(51, 3) = 73
  ExtKey(52, 0) = 52: ExtKey(52, 1) = 74: ExtKey(52, 2) = 75: ExtKey(52, 3) = 76
  ExtKey(53, 0) = 53: ExtKey(53, 1) = 77: ExtKey(53, 2) = 78: ExtKey(53, 3) = 79
  ExtKey(54, 0) = 54: ExtKey(54, 1) = 80: ExtKey(54, 2) = 81: ExtKey(54, 3) = 82
  ExtKey(55, 0) = 55: ExtKey(55, 1) = 83: ExtKey(55, 2) = 84: ExtKey(55, 3) = 85
  ExtKey(56, 0) = 56: ExtKey(56, 1) = 86: ExtKey(56, 2) = 87: ExtKey(56, 3) = 88
  ExtKey(57, 0) = 57: ExtKey(57, 1) = 89: ExtKey(57, 2) = 90: ExtKey(57, 3) = 196

  '*********************************************************************
  ' intialize LCD, KeyPad, & Ports
  '*********************************************************************
  '*********************************************************************
  'wlc removed don't need LCD KeyPad or ports
  '*********************************************************************
  'CALL SetPorts
  'CALL InitDisplay
  '
  ClrLCD

  CALL PrintClrStr(1, 1, "       ATCO         ")
  CALL PrintClrStr(2, 1, "MCU-P2000      V1.01")
  CALL PrintClrStr(3, 1, "COPYRIGHT 1997- 2011")
  CALL PrintClrStr(4, 1, " ")
  CON.CAPTION$ = "Atco Motor controllor MCU-P3000"
  CON.SCREEN = 8,80

 'for debug with PC Keyboard to exit program
 'This won't work on a pc (pc to fast)
 'I know this is trying to grab the inkey$ will update it to 1000000
  FOR VV = 1 TO 10000
 'FOR VV = 1 TO 1000
    IF LEFT$(GG$, 1) = "Q" OR LEFT$(GG$, 1) = "q" THEN
       END
    END IF
  NEXT

  '***********************************************
  'Open & Check Com Buffers, Report & Fix errors
  '
  '  - check PIC, power on, etc..
  '***********************************************
  IF NOT OpenComPorts THEN
    CALL PrintClrStr(4, 1, "ERROR, POWER OFF/ON")
    DO
    LOOP
  END IF

  IF NOT InitNetWork THEN
    CALL PrintClrStr(4, 1, "SETUP ERROR")
    DO
      CALL DelayX(200)
    LOOP UNTIL InitNetWork
  END IF

  DIM  GloErr AS INTEGER

  CalSet = FALSE
  IF NOT KeyDown THEN  'do not load if user has key pressed
    IF CalLoad(ThumbDisk + "0.M2K") THEN
    CalSet = TRUE
    END IF
  END IF

  'if no cal on disk or corrupt then set defaults
  IF NOT CalSet THEN
    GOSUB SetDefaults
  END IF

  NextFlag = FALSE 'incase cal was saved during scan

  CALL SetForAuto  'set velocity, etc. & motors on

  CALL DelayX(2000)

BaseMenu:

  GetXyPos  'load current encoder position

  GOSUB PrintMainMenu

  'CALL SetLcdPos(1, 1)

  'CALL FlushKeys

  DO

    'RowPos = GetLcdRowPos
    'ColPos = GetLcdColPos

   'IF ColPos < 11 THEN
    IF mykey = 1 THEN       'Setup
         CALL PrintChar(1, 1, ">")
         DO: XCode = GetSelectKey
           LOOP UNTIL XCode
         IF XCode = KeyDN THEN
            CALL PrintChar(1, 1, " ")
            SetLcdPos 2, 1
         ELSEIF XCode = KeyRgt THEN
            CALL PrintChar(1, 1, " ")
            SetLcdPos 1, 11
         ELSEIF XCode = KeyEnter THEN 'do menu
            GetScanCal
            GOSUB PrintMainMenu
            SetLcdPos 1, 1
         END IF
    END IF
    IF mykey = 2 THEN     'joy stick
        CALL PrintChar(2, 1, ">")
        DO: XCode = GetSelectKey
           LOOP UNTIL XCode
         IF XCode = KeyDN THEN
           CALL PrintChar(2, 1, " ")
           SetLcdPos 3, 1
         ELSEIF XCode = KeyUP THEN
            CALL PrintChar(2, 1, " ")
            SetLcdPos 1, 1
         ELSEIF XCode = KeyRgt THEN
         CALL PrintChar(2, 1, " ")
            SetLcdPos 2, 11
         ELSEIF XCode = KeyEnter THEN
            CALL SetForAuto
            JogJoyStk
            GOSUB PrintMainMenu
            SetLcdPos 2, 1
         END IF
    END IF
    IF mykey = 3 THEN    ' Auto Jog
      CALL PrintChar(3, 1, ">")
      DO: XCode = GetSelectKey
         LOOP UNTIL XCode
      IF XCode = KeyUP THEN
         CALL PrintChar(3, 1, " ")
         SetLcdPos 2, 1
       ELSEIF XCode = KeyDN THEN
         CALL PrintChar(3, 1, " ")
         SetLcdPos 4, 1
       ELSEIF XCode = KeyRgt THEN
         CALL PrintChar(3, 1, " ")
         SetLcdPos 3, 11
       ELSEIF XCode = KeyEnter THEN 'do menu
         CALL SetForAuto
         JogAuto
         GOSUB PrintMainMenu
         SetLcdPos 3, 1
       END IF
    END IF
    IF mykey = 4 THEN   ' Save Setup
       CALL PrintChar(4, 1, ">")
       DO: XCode = GetSelectKey
       LOOP UNTIL XCode
       IF XCode = KeyUP THEN
         CALL PrintChar(4, 1, " ")
         SetLcdPos 3, 1
       ELSEIF XCode = KeyRgt THEN
         CALL PrintChar(4, 1, " ")
         SetLcdPos 4, 11
       ELSEIF XCode = KeyEnter THEN 'save setup
         ClrLCD
         CursorON
         CALL PrintClrStr(1, 1, "SAVE SETUP Y/N:* ")
         SetLcdPos 1, 18
         Ans$ = GetYesNo
         CursorOFF
         IF Ans$ = "Y" THEN
           Resp = CalSave(ThumbDisk + "0.M2K")
         END IF
         GOSUB PrintMainMenu
         SetLcdPos 4, 1
       END IF
    END IF

    IF mykey = 5 THEN   'begin scan Auto scan
       CALL PrintChar(1, 11, ">")
       DO: XCode = GetSelectKey
         LOOP UNTIL XCode
       IF XCode = KeyDN THEN
        CALL PrintChar(1, 11, " ")
        SetLcdPos 2, 11
       ELSEIF XCode = KeyLft THEN
        CALL PrintChar(1, 11, " ")
        SetLcdPos 1, 1
       ELSEIF XCode = KeyEnter THEN 'do menu
        GOSUB ScanMenu
        GOSUB PrintMainMenu
        SetLcdPos 1, 1
       END IF
    END IF
    IF mykey = 6 THEN  'XSPD Cntrol
         CALL PrintChar(2, 11, ">")
         DO: XCode = GetSelectKey
          LOOP UNTIL XCode
         IF XCode = KeyDN THEN
           CALL PrintChar(2, 11, " ")
           SetLcdPos 3, 11
         ELSEIF XCode = KeyUP THEN
           CALL PrintChar(2, 11, " ")
           SetLcdPos 1, 11
         ELSEIF XCode = KeyLft THEN
           CALL PrintChar(2, 11, " ")
           SetLcdPos 2, 1
         ELSEIF XCode = KeyEnter THEN
           CALL SetForAuto
           JogXSpd
           GOSUB PrintMainMenu
           SetLcdPos 2, 11
         END IF
    END IF
    IF mykey = 7 THEN  ' Manual Jog
         CALL PrintChar(3, 11, ">")
         DO: XCode = GetSelectKey
         LOOP UNTIL XCode
         IF XCode = KeyUP THEN
           CALL PrintChar(3, 11, " ")
           SetLcdPos 2, 11
         ELSEIF XCode = KeyDN THEN
           CALL PrintChar(3, 11, " ")
           SetLcdPos 4, 11
         ELSEIF XCode = KeyLft THEN
            CALL PrintChar(3, 11, " ")
            SetLcdPos 3, 1
         ELSEIF XCode = KeyEnter THEN 'do menu
            CALL SetForAuto
            JogMan
            GOSUB PrintMainMenu
            SetLcdPos 3, 11
         END IF
    END IF
    IF mykey = 8 THEN  ' Load setup
       CALL PrintChar(4, 11, ">")
       DO: XCode = GetSelectKey
       LOOP UNTIL XCode
       IF XCode = KeyUP THEN
         CALL PrintChar(4, 11, " ")
         SetLcdPos 3, 11
       ELSEIF XCode = KeyLft THEN
         CALL PrintChar(4, 11, " ")
         SetLcdPos 4, 1
       ELSEIF XCode = KeyEnter THEN 'Load setup
         ClrLCD
         CursorON
         CALL PrintClrStr(1, 1, "LOAD SETUP Y/N:* ")
         SetLcdPos 1, 18
         Ans$ = GetYesNo
         CursorOFF
         IF Ans$ = "Y" THEN
           Resp = CalLoad(ThumbDisk + "0.M2K")
         END IF
         GOSUB PrintMainMenu
         SetLcdPos 4, 11
       END IF
    END IF
  LOOP

PrintMainMenu:
  CALL ClrLCD

  CALL PrintClrStr(0, 0, "    Select Option number ")
  CALL PrintClrStr(1, 1, "1. SETUP     5. AUTOSCAN ")
  CALL PrintClrStr(2, 1, "2. JOYSTK    6. XSPD CTRL")
  CALL PrintClrStr(3, 1, "3. A-JOG     7. M-JOG    ")
  CALL PrintClrStr(4, 1, "4. SAVE      8. LOAD     ")
  CON.WAITKEY$ TO myinput
  mykey = VAL(myinput)
  RETURN

SetDefaults:
  SCANparm.YCtr = 14858 'cts per inch travel
  SCANparm.XCtr = 62047
  SCANparm.ACtr = 1000
  GetXyPos  'load current encoder position
  SCANparm.XLow = 0
  SCANparm.XLowStr = QStr$(SCANparm.XLow, 10)
  SCANparm.XHigh = 96
  SCANparm.XHighStr = QStr(SCANparm.XHigh, 10)
  SCANparm.YLow = 0: SCANparm.YLowStr = QStr(SCANparm.YLow, 10)
  SCANparm.YHigh = 12: SCANparm.YHighStr = QStr(SCANparm.YHigh, 10)
  SCANparm.XIndex = .25: SCANparm.XIndexSTR = QStr(SCANparm.XIndex, 10)
  SCANparm.YIndex = .125: SCANparm.YIndexSTR = QStr(SCANparm.YIndex, 10)
  SCANparm.IndexLow = FALSE
  SCANparm. IndexLowStr = "LOW - HIGH"
  SCANparm.XPlus = TRUE:  SCANparm.XPlusSTR = "POSITIVE  "
  SCANparm.YPlus = FALSE: SCANparm.YPlusSTR = "NEGATIVE  "
  SCANparm.XSpeed = 2: SCANparm.XSpeedSTR = QStr(SCANparm.XSpeed, 10)
  SCANparm.YSpeed = 16: SCANparm.YSpeedSTR = QStr(SCANparm.YSpeed, 10)
  SCANparm.XCtrStr = QStr(SCANparm.XCtr, 10)
  SCANparm.YCtrStr = QStr(SCANparm.YCtr, 10)
  SCANparm.ACtrStr = QStr(SCANparm.ACtr, 10)
  SCANparm.XEnable = TRUE: SCANparm.XEnableSTR = "ON        "
  SCANparm.YEnable = TRUE: SCANparm.YEnableSTR = "ON        "
  SCANparm.XSpdDir = TRUE: SCANparm.XSpdDirSTR = "FORWARD*"
  SCANparm.AutoHold = TRUE: SCANparm.AutoHoldSTR = "ON "
  SCANparm.IndexY = FALSE: SCANparm.IndexYSTR = "X         "
  SCANparm.OVERLAP = 1: SCANparm.OverLapStr = "1         "
  SCANparm.DualRas = FALSE: SCANparm.DualRasSTR = "OFF       "
  RETURN

XScan:
    DO WHILE IndexCt >= YDataStart AND IndexCt <= YDataEnd
      UStop = DoY(YIndexCts * IndexCt)'index Y axis into position
      IF UStop THEN EXIT DO 'check if user hit stop
      IF XCts > XStartCts + (XEndCts - XStartCts) / 2 THEN
     MoveToPos1& = XStartCts
     MoveToPos2& = XEndCts
      ELSE
     MoveToPos1& = XEndCts
     MoveToPos2& = XStartCts
      END IF
      UStop = DoX(MoveToPos1&) 'put x axis into position
      IF UStop THEN EXIT DO 'check if user hit stop
      IF DualRas THEN
    UStop = DoX(MoveToPos2&)'put x axis into position
    IF UStop THEN EXIT DO 'check if user hit stop
      END IF
      IndexCt = IndexCt + IndexInc
    LOOP
    RETURN

YScan:
    DO WHILE IndexCt >= XDataStart AND IndexCt <= XDataEnd
      UStop = DoX(XIndexCts * IndexCt)'index X axis into position
      IF UStop THEN EXIT DO 'check if user hit stop
      IF YCts > YStartCts + (YEndCts - YStartCts) / 2 THEN
    MoveToPos1& = YStartCts
    MoveToPos2& = YEndCts
      ELSE
    MoveToPos1& = YEndCts
    MoveToPos2& = YStartCts
      END IF
      UStop = DoY(MoveToPos1&)'put y axis into position
      IF UStop THEN EXIT DO 'check if user hit stop
      IF DualRas THEN
    UStop = DoY(MoveToPos2&)'put y axis into position
    IF UStop THEN EXIT DO 'check if user hit stop
      END IF
      IndexCt = IndexCt + IndexInc
    LOOP
    RETURN



ScanMenu:

  GOSUB PrintScanMenu

  'CALL SetLcdPos(1, 1)

  'CALL FlushKeys

  DO

   ' RowPos = GetLcdRowPos
   ' ColPos = GetLcdColPos

   ' IF RowPos = 1 THEN
   IF mykey = 1 THEN  'Begin Scan
     CALL PrintChar(1, 1, ">")
'     SetLcdPos 1, 1
     DO: XCode = GetSelectKey
        LOOP UNTIL XCode
     IF XCode = KeyDN THEN
        CALL PrintChar(1, 1, " ")
 '       SetLcdPos 2, 1
     ELSEIF XCode = KeyRgt THEN
        CALL PrintChar(1, 1, " ")
  '      SetLcdPos 1, 9
     ELSEIF XCode = KeyEnter THEN 'begin scan
       DO                     'Added 9/13/11
         LOOP WHILE KeyDown     'problem with key double press
      ' FlushKeys
       GOSUB BeginScan
       GOSUB PrintScanMenu
       SetLcdPos 1, 1
     END IF
   END IF
   IF mykey = 2 THEN  'Next
      CALL PrintChar(1, 9, ">")
   '   SetLcdPos 1, 9
      DO: XCode = GetSelectKey
         LOOP UNTIL XCode
      IF XCode = KeyDN THEN
         CALL PrintChar(1, 9, " ")
   '      SetLcdPos 2, 1
      ELSEIF XCode = KeyLft THEN
         CALL PrintChar(1, 9, " ")
   '      SetLcdPos 1, 1
      ELSEIF XCode = KeyRgt THEN
         CALL PrintChar(1, 9, " ")
   '      SetLcdPos 1, 16
      ELSEIF XCode = KeyEnter THEN 'Set to Next Scan
         ScanLength! = ABS(XHigh - XLow)
         IF IndexLow THEN
           IF XLow - ScanLength! >= 0 THEN
             XLow = XLow - ScanLength!
             XHigh = XHigh - ScanLength!
           END IF
         ELSE
           XLow = XLow + ScanLength!
           XHigh = XHigh + ScanLength!
         END IF
         SCANparm.XLowStr = QStr$(SCANparm.XLow, 10)
         SCANparm.XHighStr = QStr$(SCANparm.XHigh, 10)
         NextFlag = TRUE
         CALL PrintChar(1, 9, " ")
  '       SetLcdPos 1, 1
      END IF
   END IF
   IF mykey = 3 THEN  ' All Zero
           CALL PrintChar(1, 16, ">")
   '        SetLcdPos 1, 16
           DO: XCode = GetSelectKey
           LOOP UNTIL XCode
           IF XCode = KeyLft THEN
             CALL PrintChar(1, 16, " ")
    '         SetLcdPos 1, 9
           ELSEIF XCode = KeyDN THEN
             CALL PrintChar(1, 16, " ")
     '        SetLcdPos 2, 1
           ELSEIF XCode = KeyEnter THEN 'Zero All ctrs
           ClrLCD
           CALL PrintClrStr(1, 1, "ENTER TO 0 ALL CTRS")
           CALL PrintClrStr(2, 1, "ESC TO ABORT")
           DO: XCode = GetSelectKey
             LOOP UNTIL XCode
             GOSUB PrintScanMenu
             CALL PrintChar(1, 16, ">")
           IF XCode = KeyEnter THEN
             SCANparm.XPos = 0: SCANparm.YPos = 0: SCANparm.APos = 0
             SCANparm.XPosStr = QStr$(SCANparm.XPos, 10)
             SCANparm.YPosStr = QStr$(SCANparm.YPos, 10)
             SCANparm.APosStr = QStr$(SCANparm.APos, 10)
             SCANparm.XOffset = 0: SCANparm.YOffset = 0: SCANparm.AOffset = 0
             CALL ResetPosition(Servo1)
             CALL ResetPosition(Servo2)
             CALL ResetPosition(Servo3)
             CALL ResetPosition(Servo4)
             PrintStr (2, 7, SCANparm.XPosStr)
             PrintStr (3, 7, SCANparm.YPosStr)
             PrintStr (4, 7, SCANparm.APosStr)
           END IF
           XCode = 0
      '     SetLcdPos 1, 16
           END IF
   END IF

   IF mykey = 4 THEN  ' XPos
           CALL PrintChar(2, 1, ">")
           SetLcdPos 2, 8
           Temp$ = SCANparm.XPosStr
           CursorON
           CALL KEdit(Temp$, XCode)  'get input
           CursorOFF
           IF XCode = KeyEnter THEN
             IF GoodSNG(Temp$) THEN
               XPos = VAL(Temp$)
               SCANparm.XPosStr = QStr$(SCANparm.XPos, 10)
               SCANparm. XOffset = GetXCord(CLNG(SCANparm.XPos * SCANparm.XCtr))
               CALL ResetPosition(Servo1)
               CALL ResetPosition(Servo2)
             END IF
           END IF
           PrintStr 2, 8, SCANparm.XPosStr
           'SetLcdPos 2, 1
           IF XCode = KeyUP THEN
             CALL PrintChar(2, 1, " ")
           '  SetLcdPos 1, 1
           ELSEIF XCode = KeyDN THEN
             CALL PrintChar(2, 1, " ")
            ' SetLcdPos 3, 1
           END IF
   END IF
    IF mykey = 5 THEN  'YPos
           CALL PrintChar(3, 1, ">")
           SetLcdPos 3, 8: Temp$ = SCANparm.YPosStr
           CursorON
           CALL KEdit(Temp$, XCode)  'get input
           CursorOFF
           IF XCode = KeyEnter THEN
             IF GoodSNG(Temp$) THEN
               SCANparm.YPos = VAL(Temp$)
               SCANparm.YPosStr = QStr$(SCANparm.YPos, 10)
               SCANparm.YOffset = GetYCord(CLNG(SCANparm.YPos * SCANparm.YCtr))
               CALL ResetPosition(Servo3)
             END IF
           END IF
           PrintStr 3, 8, SCANparm.YPosStr
           SetLcdPos 3, 1
           IF XCode = KeyUP THEN
             CALL PrintChar(3, 1, " ")
             SetLcdPos 2, 1
           ELSEIF XCode = KeyDN THEN
             CALL PrintChar(3, 1, " ")
             SetLcdPos 4, 1
           END IF
    END IF
    IF mykey = 6 THEN  'APos
           CALL PrintChar(4, 1, ">")
           SetLcdPos 4, 8: Temp$ = SCANparm.APosStr
           CursorON
           CALL KEdit(Temp$, XCode)  'get input
           CursorOFF
           IF XCode = KeyEnter THEN
             IF GoodSNG(Temp$) THEN
               SCANparm.APos = VAL(Temp$)
               SCANparm.APosStr = QStr$(SCANparm.APos, 10)
               SCANparm.AOffset = GetXCord(CLNG(SCANparm.APos * SCANparm.ACtr))
               CALL ResetPosition(Servo4)
             END IF
           END IF
           PrintStr 4, 8, SCANparm.APosStr
           SetLcdPos 4, 1
           IF XCode = KeyUP THEN
             CALL PrintChar(4, 1, " ")
             SetLcdPos 3, 1
           END IF
    END IF

  LOOP UNTIL XCode = KeyEsc

  RETURN


PrintScanMenu:
  'GetXyPos
  CALL ClrLCD
  CALL PrintClrStr(1, 1, "1. BEGIN   2. NEXT   3. ALL0")
  CALL PrintClrStr(2, 1, "4. XPOS: " + SCANparm.XPosStr)
  CALL PrintClrStr(3, 1, "5. YPOS: " + SCANparm.YPosStr)
  CALL PrintClrStr(4, 1, "6. APOS: " + SCANparm.APosStr)
  CON.WAITKEY$ TO myinput
  mykey = VAL(myinput)
  RETURN

BeginScan:
  GOSUB Profiler  'make sure scan ok before next scan add or subtract
  IF ScanFlag = -1 THEN
    CALL PrintClrStr(1, 1, "XPOS:")
    CALL PrintClrStr(2, 1, "YPOS:")
    CALL PrintClrStr(3, 1, "APOS:")
    CALL PrintClrStr(4, 1, "HIT ANY KEY TO STOP")
    PrintPos
    CALL SetForAuto
    ReSetMotors
    SetXCtrs  'set x encoder cts to match
'    CALL FlushKeys    'added 9-1-02 Flash MPU seems to detect old keypress
    IF IndexY THEN  'X Scan, Y Index
      GOSUB XScan
    ELSE : GOSUB YScan   'Y Scan, X Index
    END IF
    IF UStop THEN   'user halted scan
      CALL StopMtrs
      CALL SetModeVel
'      CALL FlushKeys
      UStop = FALSE
    END IF
    CALL GetXyPos
  ELSE
    CALL PrintClrStr(4, 1, "CAL ERROR-PRESS KEY")
    DO
    LOOP UNTIL GetSelectKey
  END IF
  RETURN


Profiler:

  ScanFlag = 0

  'check all scan cal parameters
  IF XHigh > XLow THEN
    IF YHigh > YLow THEN
      IF XIndex > 0 AND YIndex > 0 THEN
    IF XPlus = TRUE OR XPlus = FALSE THEN
      IF YPlus = TRUE OR YPlus = FALSE THEN
        IF XSpeed > 0 THEN
          IF YSpeed > 0 THEN
        IF XEnable THEN
          IF YEnable THEN
            IF ProfileScan THEN
              ScanFlag = -1
            ELSE
              ScanFlag = 0
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
  RETURN
END FUNCTION
REM $STATIC
SUB AlphaNumIN (EditStr AS STRING, ExitCode AS INTEGER)

     'intialize values
     DIM S AS STRING * 10
     S = EditStr
     StrPos = 1 'cursur position within string
     Length = LEN(EditStr)

     ClrStr$ = SPACE$(Length)
     InFlag = TRUE

     y = GetLcdRowPos: x = GetLcdColPos

     PrintStr (y, x, S)

     SetLcdPos y, x

     ExitCode = 0

     DO
     K$ = GetKeys$
     IF LEN(K$) THEN
       KeyPress = FALSE
       IF LEN(K$) = 1 THEN  'Normal key
         AscCode = ASC(LEFT$(K$, 1))
         SELECT CASE AscCode
           CASE 48   '0
         GOSUB AlphaFlag
         MID$(s$, StrPos) = CHR$(AscCode)
         PrevKey = LastKey: LastKey = AscCode
         KeyPress = TRUE: T! = TIMER
           CASE 49 TO 57   '1 to 9
         GOSUB AlphaFlag
         PrevKey = LastKey: LastKey = AscCode
         IF (PrevKey = LastKey) AND (TIMER - T! < 3) THEN
           KeyNum = KeyNum + 1
         ELSE
           KeyNum = 0
         END IF
         MID$(s$, StrPos) = CHR$(ExtKey(AscCode, KeyNum MOD 4))
         KeyPress = TRUE: T! = TIMER
           CASE KeyBKSPC     'bkspc
         GOSUB AlphaFlag
         IF StrPos > 1 THEN
           StrPos = StrPos - 1
           IF StrPos < Length THEN
             MID$(s$, StrPos) = MID$(s$, StrPos + 1) + " "
           END IF
         END IF
           CASE KeySPC    'space
         GOSUB AlphaFlag
         IF StrPos < Length THEN
           IF StrPos < Length THEN
             s$ = s$
             MID$(s$, StrPos) = " " + MID$(s$, StrPos)
             IF LEN(s$) > Length THEN
               s$ = LEFT$(s$, Length)
             END IF
           ELSE
             MID$(s$, Length) = " "
           END IF
           StrPos = StrPos + 1:
         ELSE
           MID$(s$, StrPos) = " "
         END IF
           CASE KeyEnter    'enter
         ExitCode = KeyEnter
           CASE KeyEsc
         ExitCode = KeyEsc
         END SELECT

       ELSEIF LEN(K$) = 2 THEN 'Extended key
         ScanCode = ASC(RIGHT$(K$, 1))
         SELECT CASE ScanCode
           CASE KeyUP
         ExitCode = KeyUP
           CASE KeyDN   'dn arrow
         ExitCode = KeyDN
           CASE KeyLft   'left arrow
         IF StrPos > 1 THEN
           StrPos = StrPos - 1
         END IF
           CASE KeyRgt   'right arrow
         IF StrPos < Length THEN
           StrPos = StrPos + 1
         END IF
         END SELECT
       END IF

       PrintStr y, x, S
       SetLcdPos y, x + (StrPos - 1)

     END IF

     'move cursor if last key press > 3 secs
     IF KeyPress AND (TIMER - T! > 3) AND (StrPos < Length) THEN
        StrPos = StrPos + 1
        'PrintStr y, X, s$
        SetLcdPos y, x + (StrPos - 1)
        KeyPress = FALSE: T! = TIMER
     END IF

     LOOP UNTIL ExitCode

     Edit$ = s$         'pass edited string back

     EXIT SUB

AlphaFlag:

   IF InFlag THEN
      s$ = ClrStr$
      InFlag = FALSE
   END IF

  RETURN


END SUB

SUB CalEncoder (EncNum)

  'puts servo in velocity mode
  CALL StopMtrs

  CALL GetXyPos

  CALL ClrLCD

  IF EncNum = Servo1 OR EncNum = Servo4 THEN
    AxisNum = Servo1
  ELSE
    AxisNum = Servo3
  END IF


  IF AxisNum = Servo1 THEN 'X
    CALL PrintStr(1, 1, "Move X Axis to Start")
    CALL PrintStr(2, 1, "Pos; Press Enter Key")
    IF EncNum = Servo1 THEN
      CALL PrintStr(4, 1, "X Pos: ")
      CALL PrintStr(4, 8, SCANparm.XPosStr)
    ELSE
      CALL PrintStr(4, 1, "A Pos: ")
      CALL PrintStr(4, 8, SCANparm.APosStr)
    END IF
  ELSE           'Servo3 Y
    CALL PrintStr(1, 1, "Move Y Axis to Start")
    CALL PrintStr(2, 1, "Pos; Press Enter Key")
    CALL PrintStr(4, 1, "Y Pos: ")
    CALL PrintStr(4, 8, SCANparm.YPosStr)
  END IF

  MFlag = 1
  GOSUB MoveAxis

  IF KeyPress = KeyEsc THEN
    CALL StopMtrs
    EXIT SUB
  END IF

  IF AxisNum = Servo1 THEN 'X
    CALL PrintStr(1, 1, "Move X Axis to End  ")
    CALL PrintStr(2, 1, "Pos; Press Enter Key")
    IF EncNum = Servo1 THEN
      CALL PrintStr(4, 1, "X Pos: ")
      CALL PrintStr(4, 8, SCANparm.XPosStr)
    ELSE
      CALL PrintStr(4, 1, "A Pos: ")
      CALL PrintStr(4, 8, SCANparm.APosStr)
    END IF
  ELSE
    CALL PrintStr(1, 1, "Move Y Axis to End  ")
    CALL PrintStr(2, 1, "Pos; Press Enter Key")
    CALL PrintStr(4, 1, "Y Pos: ")
    CALL PrintStr(4, 8, SCANparm.YPosStr)
  END IF

  MFlag = 2
  GOSUB MoveAxis

  IF KeyPress = KeyEsc THEN
    CALL StopMtrs
    EXIT SUB
  END IF

  CALL PrintClrStr(2, 1, " ")
  CALL PrintClrStr(1, 1, "Enter Dis: ")
  CALL SetLcdPos(1, 12)

  GOSUB GetDis

  EXIT SUB

GetDis:

    Temp$ = SPACE$(10)
    CALL KEdit(Temp$, XCode)  'get input
    IF XCode = KeyEnter THEN
      IF VAL(Temp$) > 0 THEN
    IF AxisNum = Servo1 THEN
      IF EncNum = Servo1 THEN
        SCANparm.XCal = VAL(Temp$)
        SCANparm.XCalStr = QStr(SCANparm.XCal, 10)
      ELSE
        SCANparm.ACal = VAL(Temp$)
        SCANparm.ACalStr = QStr(SCANparm.ACal, 10)
      END IF
    ELSE
      SCANparm.YCal = VAL(Temp$)
      SCANparm.YCalStr = QStr(SCANparm.YCal, 10)
    END IF
    IF ABS(EndCts& - StartCts&) > 0 THEN
      IF AxisNum = Servo1 THEN
        IF EncNum = Servo1 THEN
          SCANparm.XCtr = ABS(EndCts& - StartCts&) / SCANparm.XCal
          SCANparm.XCtrStr = QStr(SCANparm.XCtr, 10)
        ELSE
          SCANparm.ACtr = ABS(EndCts& - StartCts&) / SCANparm.ACal
          SCANparm.ACtrStr = QStr(SCANparm.ACtr, 10)
        END IF
      ELSE
        SCANparm.YCtr = ABS(EndCts& - StartCts&) / SCANparm.YCal
        SCANparm.YCtrStr = QStr(SCANparm.YCtr, 10)
      END IF
    END IF
      END IF
    END IF

    RETURN

MoveAxis:

  DO
      DO
      LOOP UNTIL KeyInBuff

      KeyPress = GetSelectKey

      IF KeyPress = KeyUP AND AxisNum = 1 THEN
    CALL MoveXVel(PosDir)
    DO
       CALL GetXyPos
       IF EncNum = Servo1 THEN
         CALL PrintStr(4, 8, SCANparm.XPosStr)
       ELSE
         CALL PrintStr(4, 8, SCANparm.APosStr)
       END IF
    LOOP WHILE KeyDown
    CALL StopMtrs
 '   FlushKeys

      ELSEIF KeyPress = KeyDN AND AxisNum = 1 THEN
    CALL MoveXVel(NegDir)
    DO
       CALL GetXyPos
       IF EncNum = Servo1 THEN
         CALL PrintStr(4, 8, SCANparm.XPosStr)
       ELSE
         CALL PrintStr(4, 8, SCANparm.APosStr)
       END IF
    LOOP WHILE KeyDown
    CALL StopMtrs
 '   FlushKeys

      ELSEIF KeyPress = KeyLft AND AxisNum = 3 THEN
    CALL MoveYVel(NegDir)
    DO
       CALL GetXyPos
       CALL PrintStr(4, 8, SCANparm.YPosStr)
    LOOP WHILE KeyDown
    CALL StopMtrs
 '   FlushKeys

      ELSEIF KeyPress = KeyRgt AND AxisNum = 3 THEN
    CALL MoveYVel(PosDir)
    DO
       CALL GetXyPos
       CALL PrintStr(4, 8, SCANparm.YPosStr)
    LOOP WHILE KeyDown
    CALL StopMtrs
'    FlushKeys
      END IF
  LOOP UNTIL KeyPress = KeyEsc OR KeyPress = KeyEnter

  CALL GetXyPos

  IF MFlag = 1 THEN      'start position cts
    IF AxisNum = Servo1 THEN  'X encoder cal
      IF EncNum = Servo1 THEN
    StartCts& = Glo.Position(Servo1)
      ELSE
    StartCts& = Glo.Position(Servo4)
      END IF
    ELSE                 'Y encoder cal
      StartCts& = Glo.Position(Servo3)
    END IF
  ELSE                   'end position cts
    IF AxisNum = Servo1 THEN  'X encoder cal
      IF EncNum = Servo1 THEN
    EndCts& = Glo.Position(Servo1)
      ELSE
    EndCts& = Glo.Position(Servo4)
      END IF
    ELSE                 'Y encoder cal
      EndCts& = Glo.Position(Servo3)
    END IF
  END IF

  RETURN

END SUB

FUNCTION CalLoad (FileNumber$)
   LOCAL Temp AS header
   Temp = HdrVer

'   CALL FOpen(FileNumber$, 0, 0, HANDLE, ECode)
   'CALL FOpen(FileNumber$, 0, 0, Filler, ECode)
   FOpen (filenum, 0,0, FileNumber$, ECode)
   IF ECode THEN
     CalLoad = FALSE
     EXIT FUNCTION
   END IF

   'read header label
   'CALL DFRead(HANDLE, VARSEG(HdrVer), VARPTR(HdrVer), LEN(HdrVer), BytesRead&, ECode)
   CALL DFRead(filenum, temp, 0, BytesRead, ECode)
   IF ECode THEN GOTO ExitCalLoad

   'Verify correct header
   IF HdrVer.hdr <> Temp.hdr THEN
     ECode = TRUE
     GOTO ExitCalLoad
   END IF

   CALL DFRead2(filenum, SCANparm, LEN(SCANparm), BytesRead, ECode)
   IF ECode THEN GOTO ExitCalLoad


ExitCalLoad:
   HdrVer = Temp 'in case of corrupt hdr read
   CALL FClose(filenum)
   IF ECode THEN
     CalLoad = FALSE
   ELSE
     CalLoad = TRUE
   END IF

   EXIT FUNCTION


END FUNCTION

FUNCTION CalSave (FILENAMEX$)

   'CALL FCreate(FILENAMEX$, 0, HANDLE, ECode)
  ' call FCreate (FILENAMEX$, 0,0, filenum, ECode)
   FCreate (filenumber, 0, FILENAMEX$, ECode)
   IF ECode THEN
     CalSave = FALSE
     EXIT FUNCTION
   END IF
   CALL DFWrite(filenum, BYVAL VARPTR(HdrVer), 0, BytesRead, ECode)
  ' CALL DFWrite(HANDLE, VARSEG(HdrVer), VARPTR(HdrVer), LEN(HdrVer), BytesWrote&, ECode)
   IF ECode THEN GOTO ExitCalSave
  ' CALL DFWrite2(filenum, BYVAL VARPTR(SCANparm), VARPTR(HdrVer), LEN(SCANparm), BytesWrote&, ECode)
   CALL DFWrite2(filenum, BYVAL VARPTR(SCANparm),LEN(HdrVer), BytesRead, ECode)
   IF ECode THEN GOTO ExitCalSave

ExitCalSave:
   CALL FClose(filenum)
   IF ECode THEN
     CalSave = FALSE
   ELSE
     CalSave = TRUE
   END IF

END FUNCTION

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

'FUNCTION CheckDisk (DataDir, Drv$, WriteLen&, FileNumber$)
'
   'DataDir = Read from Disk or Write to Disk
'
   'check drive
'   DriveOK = WriteTest(Drv$)
'   IF NOT DriveOK THEN
'      CheckDisk = 1
'      EXIT FUNCTION
'   END IF

   'check disk space left
'   IF DriveSpace&(Drv$) < WriteLen& THEN
'      CheckDisk = 2
'      EXIT FUNCTION
'   END IF

   'check filename
'   GoodName = Valid(FileNumber$)
'   IF NOT GoodName THEN
'      CheckDisk = 4
'      EXIT FUNCTION
'   END IF

   'check exist
'   IF Exist2(FileNumber$) THEN
'      CheckDisk = 8
'      EXIT FUNCTION
'   END IF

'   CheckDisk = 0  'Disk OK

'   EXIT FUNCTION

'END FUNCTION

SUB ClearBits (address AS INTEGER)

 IF address < 1 THEN EXIT SUB

 'send a clear sticky bits command
 Cmd$ = CHR$(&HB)

 SendCmd address, Cmd$

END SUB

SUB CloseCommPort (comport AS STRING, ecode AS INTEGER)


  ' CALL CloseCommPort(PICPort, ECode)
  ' CALL DeleteCommBuffers(ECode)
  ' FarHeapSize& = SETMEM(MemSize)   'give far heap back to system
  COMM CLOSE nComm
  ecode = -1
END SUB

SUB ClrLCD

   'CALL StrobeInstr(&H1)    ' clear display
   CON.CLS
END SUB

SUB CursorOFF

     'CALL StrobeInstr(&HC)     ' display on, cursor off
                   ' b7-b4 = 0, b3 = 1
                   ' b2, D = 1    (display on)
                   ' b1, C = 0    (cursor off)
                   ' b0, B = 0    (blink off)

END SUB

SUB CursorON

     'CALL StrobeInstr(&HE)    ' turn on display and cursor
                   ' b7-b4 = 0, b3 = 1
                   ' b2, D = 1    (display on)
                   ' b1, C = 1    (cursor on)
                   ' b0, B = 0    (blink off)

END SUB

SUB ddelay (Nval)

   'to create tiny (~usecs) hardware delays

   FOR XX = 0 TO Nval
   NEXT

END SUB

FUNCTION DelayFact&

   'determine cts per milisec

   T! = TIMER 'times in seconds

   DO
     CtrBegin& = CtrEnd& + 1: CtrEnd& = CtrBegin& + 100000
     FOR Ctr& = CtrBegin& TO CtrEnd&: NEXT
     x! = TIMER - T!  'rollover at midnight, careful here!
   LOOP UNTIL x! > .5 'be > .5 seconds for accuracy and rollover

   DelayFact = Ctr& / (x! * 1000)  'divide counter by 1000 (millisecs)

   EXIT FUNCTION

END FUNCTION

SUB DelayX (Millisec) '

   ct& = DelayCtr * Millisec

   FOR Ctr& = 1 TO ct&
   NEXT

END SUB

FUNCTION DoX (MPos&)

   MoveToCts& = GetXCord(MPos&)

   CALL MoveX(MoveToCts&)

   DO
     IF KeyDown <> 0 THEN 'user pressed KEYPAD
  '     FlushKeys
       DoX = TRUE: EXIT FUNCTION
     END IF
     IF (Glo.Stat(Servo1) AND HomeInProg) THEN
    'OK
     ELSE  'user pressed ABORT switch
    DoX = TRUE: EXIT FUNCTION
     END IF
     PrintYPos
     PrintAPos
     PrintXPos
   LOOP UNTIL ABS(XCts - ABS(MoveToCts&)) < (XCtr / 8) 'REM

   DoX = FALSE: EXIT FUNCTION

END FUNCTION

FUNCTION DoY (MPos&)

   MoveToCts& = GetYCord(MPos&)

   CALL MoveY(MoveToCts&)

   DO
     IF KeyDown <> 0 THEN 'User pressed KEYPAD
 '      FlushKeys
       DoY = TRUE: EXIT FUNCTION
     END IF
     IF (Glo.Stat(Servo3) AND HomeInProg) THEN
    'OK
     ELSE  'user pressed ABORT switch
    DoY = TRUE: EXIT FUNCTION
     END IF
     PrintAPos
     PrintXPos
     PrintYPos
   LOOP UNTIL (ABS(YCts - ABS(MoveToCts&)) < (YCtr / 8))

   DoY = FALSE: EXIT FUNCTION

END FUNCTION

SUB EnableAmpl (Value AS INTEGER, address AS INTEGER)

  IF address < 1 THEN EXIT SUB

  'IF address > 'xMaxMtr THEN    'group command
  '  MtrNum = 1   'use motor 1 value's
  'ELSE
  '  MtrNum = address
  'END IF

  MtrNum = address

  IF Value THEN
     Cmd$ = CHR$(&H17) + CHR$(EnableAmp)
     Glo.MiscMode(MtrNum) = Glo.MiscMode(MtrNum) OR AmpEnabled
  ELSE
     Cmd$ = CHR$(&H17) + CHR$(0)
     Glo.MiscMode(MtrNum) = Glo.MiscMode(MtrNum) AND (NOT AmpEnabled)
  END IF

  SendCmd address, Cmd$

END SUB

SUB FixSIOerror
  LOCAL Recque AS STRING
  LOCAL xmtque AS INTEGER
  NullStr$ = STRING$(16, 0)

  'spit out a bunch of zeros
  CALL WriteToComm(PICPort, NullStr$, BytesWritten, ECode)
  XmtQue = 0
  DO
     CALL GetCharsInBuffer(PICPort, RecQue, XmtQue, ECode)
     Cts& = Cts& + 1
     IF Cts& > 100 * DelayCtr THEN EXIT DO
  LOOP UNTIL (XmtQue = XmitSize - 1)

  'wait for any responses
  CALL DelayX(75)

  'flush the input buffer
  CALL FlushBuffers(PICPort, 0, ECode)

END SUB

SUB FlushKeys

   'keypad flush
   'CALL ddelay(50): OUT BitReg, KeyStbOff 'disable
   'CALL ddelay(50): OUT BitReg, KeyStbOn  'enable
   'CALL ddelay(50): OUT BitReg, KeyStbOff 'disable

END SUB

SUB GetAD

END SUB

FUNCTION GetKeys$
LOCAL KeyNum AS STRING
 'get keypad press
' IF INP(KeyReg) AND &H20 THEN   'keypress
'   OUT BitReg, KeyStbOn  'enable
'   KBuff = INP(KeyReg)    'input data
'   OUT BitReg, KeyStbOff 'disable
'   KBuff = KBuff AND &H1F 'remove data ready bit
'   KeyNum = KBuff + 1       'return keypress
'   IF KeyNum > 20 THEN KeyNum = 0
' ELSE
'   KeyNum = 0            'return no keypress
' END IF
 CON.WAITKEY$ TO KeyNum
 GetKeys$ = KeyTable(keyNum)

END FUNCTION

FUNCTION GetLcdColPos

  Position = GetLcdMemPos

  'pull the present column position of the cursor
  Position = Position AND LcdAddress
  FOR i = 0 TO LcdLines - 1
   IF ((Position >= StartLPos(i)) AND (Position <= (StartLPos(i) + LcdColumns - 1))) THEN
      Temp = (Position - StartLPos(i))
   END IF
  NEXT
  GetLcdColPos = Temp + 1


END FUNCTION

FUNCTION GetLcdMemPos

  'Get the present row & col (mem) position of the cursor
  OUT LcdModeReg, DataPortIn 'set data port as input
  CALL ddelay(D20)
  OUT BitReg, LcdPos 'test busy flag & get mem position
  CALL ddelay(D20)

  GetLcdMemPos = INP(LcdReg)

  WHILE (INP(LcdReg) AND BusyFlag)  'loop while BF=1
  WEND
  OUT BitReg, DataStbOff
  OUT LcdModeReg, DataPortOut
  CALL ddelay(D20)

  EXIT FUNCTION


END FUNCTION

FUNCTION GetLcdRowPos

  Position = GetLcdMemPos

  Position = Position AND LcdAddress
  Temp = 0
  FOR i = 0 TO LcdLines - 1
   IF ((Position >= StartLPos(i)) AND (Position <= (StartLPos(i) + LcdColumns - 1))) THEN
     Temp = i
   END IF
  NEXT
  GetLcdRowPos = Temp + 1

END FUNCTION

SUB GetScanCal

 SetLcdPos 1, 1
 WindowNum = 1
 LastKey = KeyDN

 DO
    SELECT CASE WindowNum
      CASE 1
    CursorON
    CALL PrintClrStr(1, 1, " X START: " + XLowStr)
    CALL PrintClrStr(2, 1, "   X END: " + XHighStr)
    CALL PrintClrStr(3, 1, " Y START: " + YLowStr)
    CALL PrintClrStr(4, 1, "   Y END: " + YHighStr)
    IF LastKey = KeyUP THEN
      SetLcdPos 4, 1
    ELSE  'LastKey = UP
      SetLcdPos 1, 1
    END IF
    DO
       SELECT CASE GetLcdRowPos
         CASE 1   'XStart
           PrintChar 1, 1, ">"
           SetLcdPos 1, 11: Temp$ = XLowStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           XLow = ABS(VAL(Temp$))
           XLowStr = QStr$(XLow, 10)
         END IF
           END IF
           PrintStr 1, 11, XLowStr
           SetLcdPos 1, 1
           IF XCode = KeyUP THEN
         PrintChar 1, 1, " "
         SetLcdPos 1, 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 1, 1, " "
         SetLcdPos 2, 1
           END IF
         CASE 2  'XEnd
           PrintChar 2, 1, ">"
           SetLcdPos 2, 11: Temp$ = XHighStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           XHigh = ABS(VAL(Temp$))
           XHighStr = QStr$(XHigh, 10)
         END IF
           END IF
           PrintStr 2, 11, XHighStr
           SetLcdPos 2, 1
           IF XCode = KeyUP THEN
         PrintChar 2, 1, " "
         SetLcdPos 1, 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 2, 1, " "
         SetLcdPos 3, 1
           END IF
         CASE 3 ' Y START
           PrintChar 3, 1, ">"
           SetLcdPos 3, 11: Temp$ = YLowStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           YLow = ABS(VAL(Temp$))
           YLowStr = QStr$(YLow, 10)
         END IF
           END IF
           PrintStr 3, 11, YLowStr
           SetLcdPos 3, 1
           IF XCode = KeyUP THEN
         PrintChar 3, 1, " "
         SetLcdPos 2, 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 3, 1, " "
         SetLcdPos 4, 1
           END IF
         CASE 4 ' Y END
           PrintChar 4, 1, ">"
           SetLcdPos 4, 11: Temp$ = YHighStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           YHigh = ABS(VAL(Temp$))
           YHighStr = QStr$(YHigh, 10)
         END IF
           END IF
           PrintStr 4, 11, YHighStr
           SetLcdPos 4, 1
           IF XCode = KeyUP THEN
         PrintChar 4, 1, " "
         SetLcdPos 3, 1
           ELSEIF XCode = KeyDN THEN
         WindowNum = 2
           END IF
       END SELECT
    LOOP WHILE WindowNum = 1 AND XCode <> KeyEsc
    LastKey = XCode
      CASE 2
    CursorON
    CALL PrintClrStr(1, 1, " X INDEX: " + XIndexSTR)
    CALL PrintClrStr(2, 1, " Y INDEX: " + YIndexSTR)
    CALL PrintClrStr(3, 1, " X SPEED: " + XSpeedSTR)
    CALL PrintClrStr(4, 1, " Y SPEED: " + YSpeedSTR)
    IF LastKey = KeyUP THEN
      SetLcdPos 4, 1
    ELSE  'LastKey = UP
      SetLcdPos 1, 1
    END IF
    DO
       SELECT CASE GetLcdRowPos
         CASE 1 ' X INDEX
           PrintChar 1, 1, ">"
           SetLcdPos 1, 11: Temp$ = XIndexSTR
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           XIndex = ABS(VAL(Temp$))
           XIndexSTR = QStr$(XIndex, 10)
         END IF
           END IF
           PrintStr 1, 11, XIndexSTR
           SetLcdPos 1, 1
           IF XCode = KeyUP THEN
         WindowNum = 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 1, 1, " "
         SetLcdPos 2, 1
           END IF
         CASE 2 ' Y INDEX
           PrintChar 2, 1, ">"
           SetLcdPos 2, 11: Temp$ = YIndexSTR
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           YIndex = ABS(VAL(Temp$))
           YIndexSTR = QStr$(YIndex, 10)
         END IF
           END IF
           PrintStr 2, 11, YIndexSTR
           SetLcdPos 2, 1
           IF XCode = KeyUP THEN
         PrintChar 2, 1, " "
         SetLcdPos 1, 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 2, 1, " "
         SetLcdPos 3, 1
           END IF
         CASE 3
           PrintChar 3, 1, ">"
           SetLcdPos 3, 11: Temp$ = XSpeedSTR
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           XSpeed = ABS(VAL(Temp$))
           XSpeedSTR = QStr$(XSpeed, 10)
         END IF
           END IF
           PrintStr 3, 11, XSpeedSTR
           SetLcdPos 3, 1
           IF XCode = KeyUP THEN
         PrintChar 3, 1, " "
         SetLcdPos 2, 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 3, 1, " "
         SetLcdPos 4, 1
           END IF
         CASE 4
           PrintChar 4, 1, ">"
           SetLcdPos 4, 11: Temp$ = YSpeedSTR
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           YSpeed = ABS(VAL(Temp$))
           YSpeedSTR = QStr$(YSpeed, 10)
         END IF
           END IF
           PrintStr 4, 11, YSpeedSTR
           SetLcdPos 4, 1
           IF XCode = KeyUP THEN
         PrintChar 4, 1, " "
         SetLcdPos 3, 1
           ELSEIF XCode = KeyDN THEN
         WindowNum = 3
           END IF
       END SELECT
    LOOP WHILE WindowNum = 2 AND XCode <> KeyEsc
    LastKey = XCode
      CASE 3
    GetXyPos  'load current encoder position
    CursorON
    CALL PrintClrStr(1, 1, "   X POS: " + XPosStr)
    CALL PrintClrStr(2, 1, "   Y POS: " + YPosStr)
    CALL PrintClrStr(3, 1, " X CT/IN: " + XCtrStr)
    CALL PrintClrStr(4, 1, " Y CT/IN: " + YCtrStr)
    IF LastKey = KeyUP THEN
      SetLcdPos 4, 1
    ELSE  'LastKey = UP
      SetLcdPos 1, 1
    END IF
    DO
       SELECT CASE GetLcdRowPos
         CASE 1
           PrintChar 1, 1, ">"
           SetLcdPos 1, 11: Temp$ = XPosStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           XPos = ABS(VAL(Temp$))
           XPosStr = QStr$(XPos, 10)
           XOffset = GetXCord(CLNG(XPos * XCtr))
           CALL ResetPosition(Servo1)
           CALL ResetPosition(Servo2)
         END IF
           END IF
           PrintStr 1, 11, XPosStr
           SetLcdPos 1, 1
           IF XCode = KeyUP THEN
         WindowNum = 2
           ELSEIF XCode = KeyDN THEN
         PrintChar 1, 1, " "
         SetLcdPos 2, 1
           END IF
         CASE 2
           PrintChar 2, 1, ">"
           SetLcdPos 2, 11: Temp$ = YPosStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           YPos = ABS(VAL(Temp$))
           YPosStr = QStr$(YPos, 10)
           YOffset = GetYCord(CLNG(YPos * YCtr))
           CALL ResetPosition(Servo3)
         END IF
           END IF
           PrintStr 2, 11, YPosStr
           SetLcdPos 2, 1
           IF XCode = KeyUP THEN
         PrintChar 2, 1, " "
         SetLcdPos 1, 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 2, 1, " "
         SetLcdPos 3, 1
           END IF
         CASE 3 '" X CT/IN: " + XCtrSTR)
           PrintChar 3, 1, ">"
           SetLcdPos 3, 11: Temp$ = XCtrStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodLNG(Temp$) THEN
           XCtr = ABS(VAL(Temp$))
           XCtrStr = QStr$(XCtr, 10)
         END IF
           END IF
           PrintStr 3, 11, XCtrStr
           SetLcdPos 3, 1
           IF XCode = KeyUP THEN
         PrintChar 3, 1, " "
         SetLcdPos 2, 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 3, 1, " "
         SetLcdPos 4, 1
           END IF
         CASE 4
           PrintChar 4, 1, ">"
           SetLcdPos 4, 11: Temp$ = YCtrStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodLNG(Temp$) THEN
           YCtr = ABS(VAL(Temp$))
           YCtrStr = QStr$(YCtr, 10)
         END IF
           END IF
           PrintStr 4, 11, YCtrStr
           SetLcdPos 4, 1
           IF XCode = KeyUP THEN
         PrintChar 4, 1, " "
         SetLcdPos 3, 1
           ELSEIF XCode = KeyDN THEN
         WindowNum = 4
           END IF
       END SELECT
    LOOP WHILE WindowNum = 3 AND XCode <> KeyEsc
    LastKey = XCode
      CASE 4
    CursorON
    CALL PrintClrStr(1, 1, "   X +/-:*" + XPlusSTR)
    CALL PrintClrStr(2, 1, "   Y +/-:*" + YPlusSTR)
    CALL PrintClrStr(3, 1, "   INDEX:*" + IndexYSTR)
    CALL PrintClrStr(4, 1, " IDX H/L:*" + IndexLowStr)
    IF LastKey = KeyUP THEN
      SetLcdPos 4, 1
    ELSE  'LastKey = UP
      SetLcdPos 1, 1
    END IF
    DO
       SELECT CASE GetLcdRowPos
         CASE 1   'no user input - picklist   (POSITIVE or NEGATIVE)
           PrintChar 1, 1, ">"
           PrintStr 1, 11, XPlusSTR
           SetLcdPos 1, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyUP THEN
           WindowNum = 3
           EXIT DO
         ELSEIF XCode = KeyDN THEN
           PrintChar 1, 1, " "
           SetLcdPos 2, 1
           EXIT DO
         ELSEIF XCode = KeyLft THEN
           XPlus = TRUE
           XPlusSTR = "POSITIVE  "
           PrintStr 1, 11, XPlusSTR
           SetLcdPos 1, 1
         ELSEIF XCode = KeyRgt THEN
           XPlus = FALSE
           XPlusSTR = "NEGATIVE  "
           PrintStr 1, 11, XPlusSTR
           SetLcdPos 1, 1
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
         CASE 2   'no user input - picklist   (POSITIVE or NEGATIVE)
           PrintChar 2, 1, ">"
           PrintStr 2, 11, YPlusSTR
           SetLcdPos 2, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyUP THEN
           PrintChar 2, 1, " "
           SetLcdPos 1, 1
           EXIT DO
         ELSEIF XCode = KeyDN THEN
           PrintChar 2, 1, " "
           SetLcdPos 3, 1
           EXIT DO
         ELSEIF XCode = KeyLft THEN
           YPlus = TRUE
           YPlusSTR = "POSITIVE  "
           PrintStr 2, 11, YPlusSTR
           SetLcdPos 2, 1
         ELSEIF XCode = KeyRgt THEN
           YPlus = FALSE
           YPlusSTR = "NEGATIVE  "
           PrintStr 2, 11, YPlusSTR
           SetLcdPos 2, 1
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
         CASE 3   'no user input - picklist   (X or Y)
           PrintChar 3, 1, ">"
           PrintStr 3, 11, IndexYSTR
           SetLcdPos 3, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyUP THEN
           PrintChar 3, 1, " "
           SetLcdPos 2, 1
           EXIT DO
         ELSEIF XCode = KeyDN THEN
           PrintChar 3, 1, " "
           SetLcdPos 4, 1
           EXIT DO
         ELSEIF XCode = KeyLft THEN
           IndexY = TRUE
           IndexYSTR = "Y         "
           PrintStr 3, 11, IndexYSTR
           SetLcdPos 3, 1
         ELSEIF XCode = KeyRgt THEN
           IndexY = FALSE
           IndexYSTR = "X         "
           PrintStr 3, 11, IndexYSTR
           SetLcdPos 3, 1
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
         CASE 4   'no user input - picklist   (on or off)
           PrintChar 4, 1, ">"
           PrintStr 4, 11, IndexLowStr
           SetLcdPos 4, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyUP THEN
           PrintChar 4, 1, " "
           SetLcdPos 3, 1
           EXIT DO
         ELSEIF XCode = KeyDN THEN
           WindowNum = 5
           EXIT DO
         ELSEIF XCode = KeyLft THEN
           IndexLow = TRUE
           IndexLowStr = "HIGH - LOW"
           PrintStr 4, 11, IndexLowStr
           SetLcdPos 4, 1
         ELSEIF XCode = KeyRgt THEN
           IndexLow = FALSE
           IndexLowStr = "LOW - HIGH"
           PrintStr 4, 11, IndexLowStr
           SetLcdPos 4, 1
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
       END SELECT
    LOOP WHILE WindowNum = 4 AND XCode <> KeyEsc
    LastKey = XCode
      CASE 5
    CursorOFF
    CALL PrintClrStr(1, 1, " X ON/OF:*" + XEnableSTR)
    CALL PrintClrStr(2, 1, " Y ON/OF:*" + YEnableSTR)
    CALL PrintClrStr(3, 1, " AUTO HD:*" + AutoHoldSTR)
    CALL PrintClrStr(4, 1, " DUALRAS:*" + DualRasSTR)
    IF LastKey = KeyUP THEN
      SetLcdPos 4, 1
    ELSE  'LastKey = UP
      SetLcdPos 1, 1
    END IF
    DO
       SELECT CASE GetLcdRowPos
         CASE 1   'no user input - picklist   (on or off)
           PrintChar 1, 1, ">"
           PrintStr 1, 11, XEnableSTR
           SetLcdPos 1, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyUP THEN
           WindowNum = 4
           EXIT DO
         ELSEIF XCode = KeyDN THEN
           PrintChar 1, 1, " "
           SetLcdPos 2, 1
           EXIT DO
         ELSEIF XCode = KeyLft THEN
           XEnable = TRUE
           XEnableSTR = "ON        "
           CALL StopXMtrs
           'CALL EnableAmpl(XEnable, Servo1)
           'CALL EnableAmpl(XEnable, Servo2)
           PrintStr 1, 11, XEnableSTR
           SetLcdPos 1, 1
         ELSEIF XCode = KeyRgt THEN
           XEnable = FALSE
           XEnableSTR = "OFF       "
           CALL EnableAmpl(XEnable, Servo1)
           CALL EnableAmpl(XEnable, Servo2)
           PrintStr 1, 11, XEnableSTR
           SetLcdPos 1, 1
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
         CASE 2   'no user input - picklist   (on or off)
           PrintChar 2, 1, ">"
           PrintStr 2, 11, YEnableSTR
           SetLcdPos 2, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyUP THEN
           PrintChar 2, 1, " "
           SetLcdPos 1, 1
           EXIT DO
         ELSEIF XCode = KeyDN THEN
           PrintChar 2, 1, " "
           SetLcdPos 3, 1
           EXIT DO
         ELSEIF XCode = KeyLft THEN
           YEnable = TRUE
           YEnableSTR = "ON        "
           CALL StopYMtr
           'CALL EnableAmpl(YEnable, Servo3)
           'CALL EnableAmpl(YEnable, Servo3)
           PrintStr 2, 11, YEnableSTR
           SetLcdPos 2, 1
         ELSEIF XCode = KeyRgt THEN
           YEnable = FALSE
           YEnableSTR = "OFF       "
           CALL EnableAmpl(YEnable, Servo3)
           CALL EnableAmpl(YEnable, Servo3)
           PrintStr 2, 11, YEnableSTR
           SetLcdPos 2, 1
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
         CASE 3   'no user input - picklist   (true or false)
           PrintChar 3, 1, ">"
           PrintStr 3, 11, AutoHoldSTR
           SetLcdPos 3, 1
           DO
          XCode = GetSelectKey
          IF XCode = KeyUP THEN
            PrintChar 3, 1, " "
            SetLcdPos 2, 1
            EXIT DO
          ELSEIF XCode = KeyDN THEN
            PrintChar 3, 1, " "
            SetLcdPos 4, 1
            EXIT DO
          ELSEIF XCode = KeyLft THEN
            AutoHold = TRUE
            AutoHoldSTR = "ON        "
            PrintStr 3, 11, AutoHoldSTR
            SetLcdPos 3, 1
          ELSEIF XCode = KeyRgt THEN
            AutoHold = FALSE
            AutoHoldSTR = "OFF       "
            PrintStr 3, 11, AutoHoldSTR
            SetLcdPos 3, 1
          ELSEIF XCode = KeyEsc THEN
            EXIT DO
          END IF
           LOOP
         CASE 4   'no user input - picklist   (On or Off)
           PrintChar 4, 1, ">"
           PrintStr 4, 11, DualRasSTR
           SetLcdPos 4, 1
           DO
          XCode = GetSelectKey
          IF XCode = KeyUP THEN
            PrintChar 4, 1, " "
            SetLcdPos 3, 1
            EXIT DO
          ELSEIF XCode = KeyDN THEN
            WindowNum = 6
            EXIT DO
          ELSEIF XCode = KeyLft THEN
            DualRas = TRUE
            DualRasSTR = "ON        "
            PrintStr 4, 11, DualRasSTR
            SetLcdPos 4, 1
          ELSEIF XCode = KeyRgt THEN
            DualRas = FALSE
            DualRasSTR = "OFF       "
            PrintStr 4, 11, DualRasSTR
            SetLcdPos 4, 1
          ELSEIF XCode = KeyEsc THEN
            EXIT DO
          END IF
           LOOP
       END SELECT
    LOOP WHILE WindowNum = 5 AND XCode <> KeyEsc
    LastKey = XCode
      CASE 6
    CursorON
    CALL PrintClrStr(1, 1, " OVERLAP: " + OverLapStr)
    CALL PrintClrStr(2, 1, "   A POS: " + APosStr)
    CALL PrintClrStr(3, 1, " A CT/IN: " + ACtrStr)
    CALL PrintClrStr(4, 1, " ")
    IF LastKey = KeyUP THEN
      SetLcdPos 3, 1
    ELSE  'LastKey = UP
      SetLcdPos 1, 1
    END IF
    DO
       SELECT CASE GetLcdRowPos
         CASE 1     'OverLap
           PrintChar 1, 1, ">"
           SetLcdPos 1, 11: Temp$ = OverLapStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           OVERLAP = ABS(VAL(Temp$))
           OverLapStr = QStr$(OVERLAP, 10)
         END IF
           END IF
           PrintStr 1, 11, OverLapStr
           SetLcdPos 1, 1
           IF XCode = KeyUP THEN
         WindowNum = 5
           ELSEIF XCode = KeyDN THEN
         PrintChar 1, 1, " "
         SetLcdPos 2, 1
           END IF
         CASE 2
           PrintChar 2, 1, ">"
           SetLcdPos 2, 11: Temp$ = APosStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodSNG(Temp$) THEN
           APos = ABS(VAL(Temp$))
           APosStr = QStr$(APos, 10)
           AOffset = GetXCord(CLNG(APos * ACtr))
           CALL ResetPosition(Servo4)
         END IF
           END IF
           PrintStr 2, 11, APosStr
           SetLcdPos 2, 1
           IF XCode = KeyUP THEN
         PrintChar 2, 1, " "
         SetLcdPos 1, 1
           ELSEIF XCode = KeyDN THEN
         PrintChar 2, 1, " "
         SetLcdPos 3, 1
           END IF
         CASE 3
           PrintChar 3, 1, ">"
           SetLcdPos 3, 11: Temp$ = ACtrStr
           CALL KEdit(Temp$, XCode)  'get input
           IF XCode = KeyEnter THEN
         IF GoodLNG(Temp$) THEN
           ACtr = ABS(VAL(Temp$))
           ACtrStr = QStr$(ACtr, 10)
         END IF
           END IF
           PrintStr 3, 11, ACtrStr
           SetLcdPos 3, 1
           IF XCode = KeyUP THEN
         PrintChar 3, 1, " "
         SetLcdPos 2, 1
           ELSEIF XCode = KeyDN THEN
         WindowNum = 7
           END IF
       END SELECT
    LOOP WHILE WindowNum = 6 AND XCode <> KeyEsc
    LastKey = XCode
      CASE 7
    GOSUB EnterMenu
    SetLcdPos 1, 1
    DO
       SELECT CASE GetLcdRowPos
         CASE 1   'Cal X Encoder
           PrintChar 1, 1, ">"
           SetLcdPos 1, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyUP THEN
           WindowNum = 6
           EXIT DO
         ELSEIF XCode = KeyDN THEN
           PrintChar 1, 1, " "
           SetLcdPos 2, 1
           EXIT DO
         ELSEIF XCode = KeyEnter THEN
           CursorOFF
           CALL CalEncoder(Servo1)
           CursorON
           GOSUB EnterMenu
           SetLcdPos 1, 1
           EXIT DO
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
         CASE 2   'Cal Y Encoder
           PrintChar 2, 1, ">"
           SetLcdPos 2, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyDN THEN
           PrintChar 2, 1, " "
           SetLcdPos 3, 1
           EXIT DO
         ELSEIF XCode = KeyUP THEN
           PrintChar 2, 1, " "
           SetLcdPos 1, 1
           EXIT DO
         ELSEIF XCode = KeyEnter THEN
           CursorOFF
           CALL CalEncoder(Servo3)
           CursorON
           GOSUB EnterMenu
           SetLcdPos 2, 1
           EXIT DO
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
         CASE 3   'Cal A Encoder
           PrintChar 3, 1, ">"
           SetLcdPos 3, 1
           DO
         XCode = GetSelectKey
         IF XCode = KeyUP THEN
           PrintChar 3, 1, " "
           SetLcdPos 2, 1
           EXIT DO
         ELSEIF XCode = KeyEnter THEN
           CursorOFF
           CALL CalEncoder(Servo4)
           CursorON
           GOSUB EnterMenu
           SetLcdPos 3, 1
           EXIT DO
         ELSEIF XCode = KeyEsc THEN
           EXIT DO
         END IF
           LOOP
       END SELECT
     LOOP WHILE WindowNum = 7 AND XCode <> KeyEsc
     LastKey = XCode
    END SELECT

  LOOP UNTIL XCode = KeyEsc

  CursorOFF

  IF XHigh < XLow THEN
    SWAP XHigh, XLow
    SWAP XHighStr, XLowStr
  END IF
  IF YHigh < YLow THEN
    SWAP YHigh, YLow
    SWAP YHighStr, YLowStr
  END IF

  EXIT SUB

EnterMenu:
  CursorOFF
  CALL PrintClrStr(1, 1, " CAL X ENCODER")
  CALL PrintClrStr(2, 1, " CAL Y ENCODER")
  CALL PrintClrStr(3, 1, " CAL A ENCODER")
  CALL PrintClrStr(4, 1, " ")
  RETURN

END SUB

FUNCTION GetSelectKey

      XCode = 0

     K$ = GetKeys$
     IF LEN(K$) THEN
       IF LEN(K$) = 1 THEN  'Normal key
         ScanCode = ASC(LEFT$(K$, 1))
         SELECT CASE ScanCode
         CASE KeyEnter    'enter
           XCode = KeyEnter
         CASE KeyEsc
           XCode = KeyEsc
         END SELECT
       ELSEIF LEN(K$) = 2 THEN 'Extended key
         ScanCode = ASC(RIGHT$(K$, 1))
         SELECT CASE ScanCode
           CASE KeyUP
         XCode = KeyUP
           CASE KeyDN   'dn arrow
         XCode = KeyDN
           CASE KeyLft   'left arrow
         XCode = KeyLft
           CASE KeyRgt   'right arrow
         XCode = KeyRgt
         END SELECT
       END IF
     END IF
      GetSelectKey = XCode

END FUNCTION

SUB GetStatus (Num)


   Cmd$ = CHR$(&HD)  'nop

   IF Num = &H255 THEN  'load status all servos
     FOR MtrNum = 1 TO LastServo
       SendCmd MtrNum, Cmd$
     NEXT
   ELSE                       'load status of one servo or io
     SendCmd Num, Cmd$
   END IF

END SUB

FUNCTION GetXCord& (Cts&)
  IF XPlus = TRUE THEN 'X positive direction
    GetXCord& = Cts&
  ELSE
    GetXCord& = -Cts&   'X negative direction
  END IF

  EXIT FUNCTION

END FUNCTION

SUB GetXyPos

    CALL GetStatus(&H255)   'get status of all servos (4)

    XCts = ABS(Glo.Position(Servo1))
    YCts = ABS(Glo.Position(Servo3))
    ACts = ABS(Glo.Position(Servo4))

    XPos = CLNG((XCts / XCtr) * 1000) / 1000
    YPos = CLNG((YCts / YCtr) * 1000) / 1000
    APos = CLNG((ACts / ACtr) * 1000) / 1000

    XPosStr = QStr(XPos, 10)
    YPosStr = QStr(YPos, 10)
    APosStr = QStr(APos, 10)

    CALL GetStatus(InOut1)   'get status of IO

END SUB

FUNCTION GetYCord& (Cts&)

  IF YPlus = TRUE THEN 'Y positive cts
    GetYCord& = Cts&
  ELSE
    GetYCord& = -Cts&  'Y negative cts
  END IF

  EXIT FUNCTION

END FUNCTION

FUNCTION GetYesNo$

     x = GetLcdColPos
     y = GetLcdRowPos

     Ans$ = "N"

     DO
     XCode = GetSelectKey
     IF XCode = KeyLft THEN  'No
       CALL PrintChar(y, x, "N")
       Ans$ = "N"
       CALL SetLcdPos(y, x)
     ELSEIF XCode = KeyRgt THEN
       CALL PrintChar(y, x, "Y")
       Ans$ = "Y"
       CALL SetLcdPos(y, x)
     ELSEIF XCode = KeyEsc THEN
       EXIT DO
     ELSEIF XCode = KeyEnter THEN
       EXIT DO
     END IF
     LOOP

     GetYesNo$ = Ans$


END FUNCTION

SUB GoMtrs

  Cmd$ = CHR$(&H5)
  SendCmd AllServos, Cmd$

END SUB

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

SUB GoXMtrs

  Cmd$ = CHR$(&H5)
  SendCmd Servo1, Cmd$
  SendCmd Servo2, Cmd$

END SUB

SUB GoYMtr

  Cmd$ = CHR$(&H5)
  SendCmd Servo3, Cmd$

END SUB

SUB InitDisplay

  'Sets up lcd display and 8255
  OUT LcdModeReg, DataPortOut  ' set port as output
  CALL StrobeInstr(&H1)    ' clear display
  CALL StrobeInstr(&H38)   ' function set
                ' b7,b6 = 0, b5 = 1
                ' b4, DL = 1   (8 bit data)
                ' b3, N = 1    (4 lines)
                ' b2, F = 0    (5 x 7 char font)
                ' b1,b0 = 0    (dont care)
  CALL StrobeInstr(&HC)    ' turn on display and cursor
                ' b7-b4 = 0, b3 = 1
                ' b2, D = 1    (display on)
                ' b1, C = 0    (cursor off)
                ' b0, B = 0    (blink off)
  CALL StrobeInstr(&H6)    ' set entry mode increment right
                ' b7-b3 = 0, b2 = 1
                ' b1, I/D = 1  (increment)
                ' b0, S = 0    (shift off)

   CALL StrobeInstr(&H40)   ' set cg ram address
   CALL StrobeData(&H0)     ' 1 row
   CALL StrobeData(&H10)    ' 2 row
   CALL StrobeData(&H8)     ' 3 row
   CALL StrobeData(&H4)     ' 4 row
   CALL StrobeData(&H2)     ' 5 row
   CALL StrobeData(&H1)     ' 6 row
   CALL StrobeData(&H0)     ' 7 row
   CALL StrobeData(&H0)     ' 8 row

END SUB

FUNCTION InitNetWork

  'Initial Varibles
  Glo.SIOErrorMode = DoNothing
  Glo.SIOError = 0
  Glo.CkSumError = FALSE
  Glo.NumModules = 0
  Glo.AmpQuery = TRUE
  Glo.PowerQuery = TRUE

  FOR i = 1 TO 5
     Glo.StatusDef(i) = 0
     Glo.ModuleType(i) = -1 '*** changed from (0) to (-1) 9-3-02
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
  CALL FlushBuffers(PICPort, 0, ECode)

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

  'Taken because of com errors in newer Flash Micros
  'Cmd$ = CHR$(&H1A) + CHR$(10) 'set baudrate 115200
  'SendCmd &HFF, Cmd$
  'CALL Delayx(25)
  'CALL baud(10)   'Set Proccessor baudrate to 115200
  'CALL Delayx(25)
  'CALL FlushBuffers(PICPort, 0, ECode)

  'reset group command for pic-servo #4 to 253
  Cmd$ = CHR$(&H21) + CHR$(4) + CHR$(&HFD) 'set address
  SendCmd 4, Cmd$

  'reset group command for pic-io to 254
  Cmd$ = CHR$(&H21) + CHR$(5) + CHR$(&HFE) 'set address
  SendCmd 5, Cmd$

  'disable amp on Servo 4 since enabling disables servo
  CALL EnableAmpl(0, 4)

  CALL FlushBuffers(PICPort, 0, ECode)

  InitNetWork = TRUE

  EXIT FUNCTION

END FUNCTION

FUNCTION IntToStr$ (x AS INTEGER)

   B = x AND &HFF
   A = ((x AND &HFF00&) \ 256&) AND &HFF

   IntToStr = CHR$(B) + CHR$(A)

END FUNCTION

SUB JogAuto

  'add limit switch stop; enable with 'stop on find home'
  CALL ClrLCD

  IF NOT (XEnable AND YEnable) THEN
    PrintClrStr 1, 1, "* Check Motors On *"
    PrintClrStr 2, 1, "*  Press Any Key  *"
    DO
    LOOP UNTIL KeyInBuff
  '  FlushKeys
    EXIT SUB
  END IF

  'reset x encoders to insure they match
  CALL SetXCtrs

  PrintStr 1, 1, "X Pos: "
  PrintStr 2, 1, "Y Pos: "
  PrintStr 3, 1, "A Pos: "

  SetLcdPos 3, 1

  StopMtrs  'stop motors in velocity mode
  SetModeVel 'sets vel to 0

  'REMED
  'add home postion (limit button hit) check in case of error!

  DO

    DO
      PrintPos
    LOOP UNTIL KeyInBuff

    KeyPress = GetSelectKey

    SELECT CASE KeyPress
      CASE KeyEsc
    CALL StopMtrs
    SetModeVel 'sets vel to 0
    EXIT SUB

      CASE KeyUP
    CALL MoveXVel(PosDir)
    DO
      CALL PrintPos   'get stats also
    LOOP WHILE KeyDown '& limit not pressed
    CALL StopMtrs
    SetModeVel 'sets vel to 0

      CASE KeyDN
    CALL MoveXVel(NegDir)
    DO
      CALL PrintPos   'get stats also
    LOOP WHILE KeyDown
    CALL StopMtrs
    SetModeVel 'sets vel to 0

      CASE KeyLft
    CALL MoveYVel(NegDir)
    DO
      CALL PrintPos   'get stats also
    LOOP WHILE KeyDown
    CALL StopMtrs
    SetModeVel 'sets vel to 0

      CASE KeyRgt
    CALL MoveYVel(PosDir)
    DO
      CALL PrintPos   'get stats also
    LOOP WHILE KeyDown
    CALL StopMtrs
    SetModeVel 'sets vel to 0

    END SELECT

 LOOP


END SUB

SUB JogJoyStk

  'add limit switch stop; enable with 'stop on find home'
  'use PWM mode

  CALL ClrLCD

  IF NOT (XEnable) THEN
    PrintClrStr 1, 1, "* Check Motors On *"
    PrintClrStr 2, 1, "*  Press Any Key  *"
    DO
    LOOP UNTIL KeyInBuff
 '   FlushKeys
    EXIT SUB
  END IF

  PrintStr 1, 1, "X Pos: "
  PrintStr 2, 1, "Y Pos: "
  PrintStr 3, 1, "A Pos: "

  SetModePwm

  StopOn = FALSE

  DO

      IF GetSelectKey = KeyEsc THEN EXIT DO

      CALL PrintPos   'get stats also

      'calculated PWM output based on A/D 1 & 2
      IF Glo.Ad2 <= 127 THEN 'left
     Glo.CmdPwm(2) = CINT((LU(Corr1(Glo.Ad1)) / 100) * 255)
     Glo.CmdPwm(1) = CINT((LF(Corr2(Glo.Ad2)) / 100) * Glo.CmdPwm(2))
      ELSE 'right
     Glo.CmdPwm(1) = CINT((LU(Corr1(Glo.Ad1)) / 100) * 255)
     Glo.CmdPwm(2) = CINT((LF(Corr2(Glo.Ad2)) / 100) * Glo.CmdPwm(1))
      END IF


      IF Glo.CmdPwm(1) = 0 AND Glo.CmdPwm(2) = 0 THEN
    IF AutoHold THEN
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

  IF AutoHold THEN
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

SUB JogMan

  'add limit switch stop; enable with 'stop on find home'

  'use PWM mode

  CALL ClrLCD

  IF NOT (XEnable AND YEnable) THEN
    PrintClrStr 1, 1, "* Check Motors On *"
    PrintClrStr 2, 1, "*  Press Any Key  *"
    DO
    LOOP UNTIL KeyInBuff
 '   FlushKeys
    EXIT SUB
  END IF

  PrintStr 1, 1, "X Pos: "
  PrintStr 2, 1, "Y Pos: "
  PrintStr 3, 1, "A Pos: "

  SetModePwm

  DO

    DO
      PrintPos
    LOOP UNTIL KeyInBuff

    KeyPress = GetSelectKey

    SELECT CASE KeyPress
      CASE KeyEsc
    StopMtrs
    SetModeVel 'sets vel to 0
    EXIT SUB

      CASE KeyUP
    DO
      CALL PrintPos   'get stats also
      CALL ManXUP
    LOOP WHILE KeyDown
    SetModePwm

      CASE KeyDN
    DO
      CALL PrintPos   'get stats also
      CALL ManXDN
    LOOP WHILE KeyDown
    SetModePwm

      CASE KeyLft
    DO
      CALL PrintPos   'get stats also
      CALL ManYLFT
    LOOP WHILE KeyDown
    SetModePwm

      CASE KeyRgt
    DO
      CALL PrintPos   'get stats also
      CALL ManYRGT
    LOOP WHILE KeyDown
    SetModePwm

    END SELECT

 LOOP


END SUB

SUB JogXSpd

  'add limit switch stop; enable with 'stop on find home'

  'use PWM mode

  CALL ClrLCD

  IF NOT (XEnable) THEN
    PrintClrStr 1, 1, "* Check Motors On *"
    PrintClrStr 2, 1, "*  Press Any Key  *"
    DO
    LOOP UNTIL KeyInBuff
 '   FlushKeys
    EXIT SUB
  END IF

  PrintClrStr 1, 1, "Check XSPD Setting"
  PrintClrStr 2, 1, "  Press Any Key   "
  DO
  LOOP UNTIL KeyInBuff
 ' FlushKeys

  CALL ClrLCD
  PrintStr 1, 1, "X Pos: "
  PrintStr 2, 1, "Y Pos: "
  PrintStr 3, 1, "A Pos: "
  PrintStr 4, 1, XSpdDirSTR

  StopOn = FALSE

  SetModePwm

  DO

     DO

    CALL PrintPos   'get stats also

    'PWM output based on A/D 4
    IF XSpdDir THEN 'forward direction
      Glo.CmdPwm(1) = XSpd(Glo.AdVal(4))
      Glo.CmdPwm(2) = Glo.CmdPwm(1)
    ELSE 'reverse direction
      Glo.CmdPwm(1) = -(XSpd(Glo.AdVal(4)))
      Glo.CmdPwm(2) = Glo.CmdPwm(1)
    END IF

    IF Glo.CmdPwm(1) = 0 THEN  'glo.CmdPwm(2) = glo.CmdPwm(1)
      IF AutoHold THEN
        IF NOT StopOn THEN
          CALL StopMtrs 'put into velocity mode and set velocity to 0
          SetModeVel 'sets vel to 0
          StopOn = TRUE
        END IF
      ELSE
        GOSUB SetXSpdPwm
      END IF
    ELSE
      GOSUB SetXSpdPwm
    END IF

     LOOP UNTIL KeyInBuff

     SELECT CASE GetSelectKey
       CASE KeyRgt
     IF XSpdDir THEN
       XSpdDir = FALSE
       XSpdDirSTR = "REVERSE*"
       PrintStr 4, 1, XSpdDirSTR
     END IF
       CASE KeyLft
     IF NOT XSpdDir THEN
       XSpdDir = TRUE
       XSpdDirSTR = "FORWARD*"
       PrintStr 4, 1, XSpdDirSTR
     END IF
       CASE KeyEsc
     EXIT DO
     END SELECT

  LOOP

 ' FlushKeys

  IF AutoHold THEN
    CALL StopMtrs 'put into velocity mode and set velocity to 0
    SetModeVel 'sets vel to 0
  ELSE
    SetModePwm  'put into pwm mode and set output to zero
  END IF


  EXIT SUB

SetXSpdPwm:
   CALL SetPwm(Servo1, Glo.CmdPwm(1))
   CALL SetPwm(Servo2, Glo.CmdPwm(2))
   GoXMtrs
   StopOn = FALSE
   RETURN


END SUB

SUB KEdit (Edit$, ExitCode)

     'intialize values
     s$ = Edit$
     StrPos = 1 'cursur position within string
     Length = LEN(Edit$)

     ClrStr$ = SPACE$(Length)
     InFlag = TRUE

     y = GetLcdRowPos: x = GetLcdColPos

     PrintStr y, x, s$
     SetLcdPos y, x

     ExitCode = 0


     DO
    K$ = GetKeys$
     IF LEN(K$) THEN
       IF LEN(K$) = 1 THEN  'Normal key
         AscCode = ASC(LEFT$(K$, 1))
         SELECT CASE AscCode
           CASE 32 TO 125   'AlphaNum
         GOSUB CheckFlag
         MID$(s$, StrPos) = CHR$(AscCode)
         IF StrPos < Length THEN
           StrPos = StrPos + 1
         END IF
           CASE KeyBKSPC     'bkspc
         GOSUB CheckFlag
         IF StrPos > 1 THEN
           StrPos = StrPos - 1
           IF StrPos < Length THEN
             MID$(s$, StrPos) = MID$(s$, StrPos + 1) + " "
           END IF
         END IF
           CASE KeyTAB     'tab

           CASE KeySPC    'space
         GOSUB CheckFlag
         IF StrPos < Length THEN
           IF StrPos < Length THEN
             s$ = s$
             MID$(s$, StrPos) = " " + MID$(s$, StrPos)
             IF LEN(s$) > Length THEN
               s$ = LEFT$(s$, Length)
             END IF
           ELSE
             MID$(s$, Length) = " "
           END IF
           StrPos = StrPos + 1:
         ELSE
           MID$(s$, StrPos) = " "
         END IF
           CASE KeyEnter    'enter
         ExitCode = KeyEnter
           CASE KeyEsc
         ExitCode = KeyEsc
         END SELECT

       ELSEIF LEN(K$) = 2 THEN 'Extended key
         ScanCode = ASC(RIGHT$(K$, 1))
         SELECT CASE ScanCode
           CASE KeyUP
         ExitCode = KeyUP
           CASE KeyDN   'dn arrow
         ExitCode = KeyDN
           CASE KeyLft   'left arrow
         IF StrPos > 1 THEN
           StrPos = StrPos - 1
         END IF
           CASE KeyRgt   'right arrow
         IF StrPos < Length THEN
           StrPos = StrPos + 1
         END IF

           CASE KeyPGUP   'pgup

           CASE KeyPGDN   'pgdn

           CASE KeyHOME   'home
         StrPos = 1
           CASE KeyEND   'end
         StrPos = Length

           CASE KeyDEL   'del

         END SELECT

       END IF

       PrintStr y, x, s$
       SetLcdPos y, x + (StrPos - 1)

     END IF

     LOOP UNTIL ExitCode

     Edit$ = s$         'pass edited string back

     EXIT SUB

CheckFlag:
   IF InFlag THEN
      s$ = ClrStr$
      InFlag = FALSE
   END IF
   RETURN


END SUB

FUNCTION KeyDown

   'returns true only if user is holding down key that
   'was previously latched
   'Steps:
   '    1.) User presses key.
   '    2.) Latch detects keypress and doesn't allow new key scan
   '        until user releases key.
   '    3.) During this time we can tell if user released key.

'   KeyState = INP(KeyReg) 'read keyboard port
   a$ = CON.INKEY$
   IF LEN(a$) THEN
       keydown = -1
   ELSE : keydown = 0
   END IF
'   IF KeyState AND (NOT &H20) THEN  'key not released or not been pushed
'     IF (KeyState AND &H40) THEN    'user holding Key down
'       KeyDown = -1
'     ELSE : KeyDown = 0
'     END IF
'   ELSE : KeyDown = 0
'   END IF

END FUNCTION

FUNCTION KeyInBuff

 'check if key in buffer
 IF (INP(KeyReg) AND &H20) THEN   'yes
   KeyInBuff = TRUE
 ELSE
   KeyInBuff = FALSE            'no key in buffer
 END IF

END FUNCTION

SUB KeyWait

     DO
     LOOP UNTIL KeyInBuff

'    FlushKeys

END SUB

FUNCTION LongToStr$ (x AS LONG)

   D = x AND &HFF
   C = (x AND &HFF00&) \ 256&
   B = (x AND &HFF0000) \ 65536
   A = ((x AND &HFF000000) \ 16777216) AND &HFF

   LongToStr = CHR$(D) + CHR$(C) + CHR$(B) + CHR$(A)


END FUNCTION

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

SUB MoveX (PosCts&)

   CALL SetHomeCap 'stop on limit 1

   ControlByte = LoadPos OR LoadVel OR LoadAcc OR PosMode

   '**********************************************************
   'When user changes current position the counters get zeroed.
   'Adjust move-to position offset accordingly
   '**********************************************************
   ActPos& = PosCts& - XOffset

   'Build the command string
   Cmd$ = CHR$(&HD4) + CHR$(ControlByte) + LongToStr(ActPos&)
   Cmd$ = Cmd$ + LongToStr(Glo.CmdVelocity(Servo1)) + LongToStr(Glo.CmdAccel(Servo1))

   SendCmd Servo1, Cmd$

   SendCmd Servo2, Cmd$

   CALL GoMtrs

END SUB

SUB MoveXVel (MoveDir)

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

SUB MoveY (PosCts&)

  CALL StopYMtr

  CALL SetHomeCap 'stop on limit 1

  ControlByte = LoadPos OR LoadVel OR LoadAcc OR PosMode

  '**********************************************************
  'When user changes current position the counters get zeroed.
  'Adjust move-to position accordingly
  ActPos& = PosCts& - YOffset
  '**********************************************************

  'Build the command string
  Cmd$ = CHR$(&HD4) + CHR$(ControlByte) + LongToStr(ActPos&)
  Cmd$ = Cmd$ + LongToStr(Glo.CmdVelocity(Servo3)) + LongToStr(Glo.CmdAccel(Servo3))

  SendCmd Servo3, Cmd$

  'REMED
  'CALL GoYMtr

  CALL GoMtrs

END SUB

SUB MoveYVel (MoveDir)

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

SUB MtrOff (address AS INTEGER)
 IF address < 1 THEN EXIT SUB
 Cmd$ = CHR$(&H17) + CHR$(MotorOff)
 SendCmd address, Cmd$
END SUB
'''''''''''''''' Serial functions ''''''''''''''''''''''''''''''
FUNCTION OpenComPorts AS INTEGER
    LOCAL ECode AS INTEGER
    LOCAL x AS INTEGER
    nComm = FREEFILE
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
    COMM SET #nComm, PARITY = 0     ' No parity
    COMM SET #nComm, STOP   = 1     ' 1 stop bit
    CALL FlushBuffers(PICPort, 0, ECode)
    OpenComPorts = TRUE
END FUNCTION
SUB GetCharsInBuffer (PICPort AS STRING, RecvQue AS STRING, XmitQue AS INTEGER, ECode)
    LOCAL ncbData AS LONG
    ncbData = COMM(PICPort, RXQUE)
    IF ncbData THEN
            COMM RECV PICPort, ncbData, RecvQue
    END IF
    ncbData = COMM(PICPort, TXQUE)
    IF ncbData THEN
            COMM RECV PICPort, ncbData, XmitQue
    END IF

END SUB

SUB FlushBuffers (PICPort AS STRING, zero AS INTEGER, ECode AS INTEGER)
    LOCAL buffer_clear AS STRING
    buffer_clear = STRING$(2048, zero)
    COMM SEND #nComm, buffer_clear
END SUB

SUB WriteToComm (PICPort AS STRING, SendStr AS STRING, BytesWritten AS INTEGER, ECode AS INTEGER)
    COMM SEND #nComm, SendStr
END SUB


'FUNCTION OpenComPorts

   REM Changed to PC Serial routines

'   NumPorts = 1: RecvSize = 2048: XmitSize = 2048

'   PortSeg = VARSEG(PICPort): PortOff = VARPTR(PICPort)
'   RecvSeg = VARSEG(RecvSize): RecvOff = VARPTR(RecvSize)
'   XmitSeg = VARSEG(XmitSize): XmitOff = VARPTR(XmitSize)

'   CALL CalcRequiredMem(PortSeg, PortOff, RecvSeg, RecvOff, XmitSeg, XmitOff, NumPorts, MemSize, ECode)
'   IF ECode THEN
'     OpenComPorts = FALSE
'     EXIT FUNCTION
'   END IF

'   FarHeapSize& = SETMEM(-(MemSize))  'take some far heap

'   CALL InitCommBuffers(ECode)
'   IF ECode THEN
'     FarHeapSize& = SETMEM(MemSize)   'give far heap back to system
'     OpenComPorts = FALSE
'     EXIT FUNCTION
'   END IF

   ' Set the flow control to no flow control
'   CALL SetFlowControl(PICPort, 3, 3, 0, 0, 0, 0, ECode)
'   IF ECode THEN
'     CALL DeleteCommBuffers(ECode)
'     FarHeapSize& = SETMEM(MemSize)   'give far heap back to system
'     OpenComPorts = FALSE
'     EXIT FUNCTION
'   END IF

'   CALL SetFIFOTriggerLevel(PICPort, 14, ECode)

'   DataBits = 8: PARITY = 4: StopBits = 1

'   CALL OpenCommPort(PICPort, PICBaud, DataBits, PARITY, StopBits, ECode)
'   IF ECode THEN
'     CALL DeleteCommBuffers(ECode)
'     FarHeapSize& = SETMEM(MemSize)   'give far heap back to system
'     OpenComPorts = FALSE
'     EXIT FUNCTION
'   END IF

'   OpenComPorts = TRUE

'   CALL FlushBuffers(PICPort, 0, ECode)

'   EXIT FUNCTION

'END FUNCTION

SUB PrintAPos

    CALL GetStatus(Servo4)   'get status of aux encoder
    ACts = ABS(Glo.Position(Servo4))
    APos = CLNG((ACts / ACtr) * 1000) / 1000
    APosStr = QStr(APos, 10)
    CALL PrintStr(3, 7, APosStr)

END SUB

SUB PrintChar (y, x, char$)


   ' CALL SetLcdPos(y, x) 'position cursor
   ' CALL StrobeData(ASC(char$))
   PRINT ASC(char$)

END SUB

SUB PrintClrStr (y, x, Text$)

    YY = y: XX = x

    'CALL SetLcdPos(YY, XX) 'position cursor

    'FOR i = 1 TO LEN(Text$)
    '  IF XX <= LcdColumns THEN
    '    CALL StrobeData(ASC(MID$(Text$, i, 1))) 'print the char
    '    XX = XX + 1
    '  END IF
    'NEXT

    'WHILE XX <= LcdColumns ' clear rest of line
    '  CALL StrobeData(32) 'print spaces
    '  XX = XX + 1
    'WEND
    CON.CLS
    CON.PRINT Text$
END SUB
#IF 0
SUB PrintClrStr (y, x, Text$)

    YY = y: XX = x

    CALL SetLcdPos(YY, XX) 'position cursor

    FOR i = 1 TO LEN(Text$)
      IF XX <= LcdColumns THEN
        CALL StrobeData(ASC(MID$(Text$, i, 1))) 'print the char
        XX = XX + 1
      END IF
    NEXT

    WHILE XX <= LcdColumns ' clear rest of line
      CALL StrobeData(32) 'print spaces
      XX = XX + 1
    WEND

END SUB
#ENDIF


SUB PrintPos

    CALL GetXyPos

    CALL PrintClrStr(1, 7, XPosStr)
    CALL PrintClrStr(2, 7, YPosStr)
    CALL PrintClrStr(3, 7, APosStr)

END SUB

SUB PrintStr (y, x , ptrstr AS STRING * 10)

    YY = y: XX = x

    CALL SetLcdPos(YY, XX) 'position cursor

    FOR i = 1 TO LEN(ptrstr)
      IF XX <= LcdColumns THEN
        CALL StrobeData(ASC(MID$(ptrstr, i, 1))) 'print the char
        XX = XX + 1
      END IF
    NEXT


END SUB

SUB PrintXPos

    CALL GetStatus(Servo1)   'get status of X servo
    XCts = ABS(Glo.Position(Servo1))
    XPos = CLNG((XCts / XCtr) * 1000) / 1000
    XPosStr = QStr(XPos, 10)
    CALL PrintStr(1, 7, XPosStr)

END SUB

SUB PrintYPos

    CALL GetStatus(Servo3)   'get status of Y servo
    YCts = ABS(Glo.Position(Servo3))
    YPos = CLNG((YCts / YCtr) * 1000) / 1000
    YPosStr = QStr(YPos, 10)
    CALL PrintStr(2, 7, YPosStr)

END SUB

FUNCTION ProfileScan

   IF GoodLNG(STR$(XLow * XCtr + 1)) THEN
     XStartCts = CLNG(XLow * XCtr)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$((XHigh + OVERLAP) * XCtr + 1)) THEN
     XEndCts = CLNG((XHigh + OVERLAP) * XCtr)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$(YLow * YCtr + 1)) THEN
     YStartCts = CLNG(YLow * YCtr)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$(YHigh * YCtr + 1)) THEN
     YEndCts = CLNG(YHigh * YCtr)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$(XCtr * XIndex + 1)) THEN
     XIndexCts = CLNG(XCtr * XIndex)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   IF GoodLNG(STR$(YCtr * YIndex + 1)) THEN
     YIndexCts = CLNG(YCtr * YIndex)
   ELSE
     ProfileScan = FALSE
     EXIT FUNCTION
   END IF

   XDataStart = CLNG(XStartCts / XIndexCts)
   XDataEnd = CLNG(XEndCts / XIndexCts)

   YDataStart = CLNG(YStartCts / YIndexCts)
   YDataEnd = CLNG(YEndCts / YIndexCts)

   IndexCt = XDataStart

   ProfileScan = TRUE

   EXIT FUNCTION

END FUNCTION

FUNCTION QStr$ (BYVAL Amount!, BYVAL Places) STATIC

    QStr$ = LEFT$(LTRIM$(STR$(Amount!)) + SPACE$(Places), Places)

END FUNCTION

SUB ReSetMotors

  CALL GetStatus(AllServos)

  IF IndexY THEN 'X Scan, Y Index
    IF IndexLow THEN    'indexing towards low position
      IndexInc = -1
      IF YPlus = TRUE THEN 'scanning positive direction
    IndexSet = 1
      ELSE
    IndexSet = -1
      END IF
    ELSE   'POSDIR
      IndexInc = 1
      IF YPlus = TRUE THEN 'scanning positive direction
    IndexSet = -1
      ELSE
    IndexSet = 1
      END IF
    END IF

    LoopPos = CLNG(Glo.Position(3) / YIndexCts) + IndexSet

    IF YPlus THEN  'Y positive direction
       IF LoopPos > YDataEnd THEN
     IndexCt = YDataEnd
       ELSEIF LoopPos < YDataStart THEN
     IndexCt = YDataStart
       ELSE
     IndexCt = LoopPos
       END IF
    ELSE               'Y negative direction
       IF LoopPos < -YDataEnd THEN
     IndexCt = YDataEnd
       ELSEIF LoopPos > -YDataStart THEN
     IndexCt = YDataStart
       ELSE
     IndexCt = ABS(LoopPos)
       END IF
     END IF

  ELSE  'Y Scan, X Index

    'IndexSet is used to backup 1 raster for overlap of scan restarts
    IF IndexLow THEN  'Index towards low position
      IndexInc = -1
      IF XPlus = TRUE THEN 'scanning positive counts direction
    IndexSet = 1
      ELSE
    IndexSet = -1
      END IF
    ELSE                   'Index towards high position
      IndexInc = 1
      IF XPlus = TRUE THEN 'scanning positive counts direction
    IndexSet = -1
      ELSE
    IndexSet = 1
      END IF
    END IF

    LoopPos = CLNG(Glo.Position(1) / XIndexCts) + IndexSet

    IF XPlus THEN  'X positive direction
      IF LoopPos > XDataEnd THEN
    IndexCt = XDataEnd
      ELSEIF LoopPos < XDataStart THEN
    IndexCt = XDataStart
      ELSE
    IndexCt = LoopPos
      END IF
    ELSE               'X negative direction
      IF LoopPos < -XDataEnd THEN
    IndexCt = XDataEnd
      ELSEIF LoopPos > -XDataStart THEN
    IndexCt = XDataStart
      ELSE
    IndexCt = ABS(LoopPos)
      END IF
    END IF

    IF NextFlag THEN
      IF IndexLow THEN  'Index towards low position
    IndexCt = XDataEnd
      ELSE                   'Index towards high position
    IndexCt = XDataStart
      END IF
      NextFlag = FALSE
    END IF

  END IF

END SUB

SUB ResetPosition (address AS INTEGER)

 IF address < 1 THEN EXIT SUB

 Cmd$ = CHR$(&H0)

 SendCmd address, Cmd$

END SUB

SUB SendCmd (address AS INTEGER, CmdString AS STRING)

  Cksum = address

  Glo.SIOError = FALSE

  FOR i = 1 TO LEN(CmdString)
     Cksum = Cksum + ASC(MID$(CmdString, i, 1))
  NEXT i
  Cksum = Cksum AND 255

  'Send the command
  '** add for probas com routine
  SendStr$ = CHR$(&HAA) + CHR$(address) + CmdString + CHR$(Cksum)

  StrLen = LEN(SendStr$)

  'flush the com buffer
  REM   CALL FlushComPort
  'CALL FlushBuffers(PICPort, 0, ECode)


  REM 'FOR i = 1 TO StrLen
    'CALL xputchar(ASC(MID$(SendStr$, i, 1)))
      'NEXT i

  CALL WriteToComm(PICPort, SendStr$, BytesWritten, ECode)

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
    IF Glo.StatusDef(address) AND SendPos THEN
      IF SIOGetByte(D, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(C, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B + C + D
      ActPos& = CharsToLong(A, B, C, D)
      '****************************************
      'changed to adjust for user counter offset
      '****************************************
      IF address = 1 OR address = 2 THEN   'X Axis
    Glo.Position(address) = ActPos& + XOffset
      ELSEIF address = 3 THEN  'Y Axis
    Glo.Position(address) = ActPos& + YOffset
      ELSEIF address = 4 THEN  'A Axis
    Glo.Position(address) = ActPos& + AOffset
      ELSE
      END IF
    END IF

    'Get the A/D value
    IF Glo.StatusDef(address) AND SendAD THEN
      IF SIOGetByte(Glo.AdVal(address), 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.AdVal(address)
    END IF

    'Get velocity data
    IF Glo.StatusDef(address) AND SendVel THEN
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B
      Glo.velocity(address) = CharsToInt(A, B)
    END IF

    'Get the AUX status value
    IF Glo.StatusDef(address) AND SendAux THEN
      IF SIOGetByte(Glo.AuxStat(address), 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.AuxStat(address)
    END IF

    'Get home position data
    IF Glo.StatusDef(address) AND SendHome THEN
      IF SIOGetByte(D, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(C, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B + C + D
      Glo.HomePosition(address) = CharsToLong(A, B, C, D)
    END IF

    'Get the module type and version
    IF Glo.StatusDef(address) AND SendID THEN
     IF SIOGetByte(Glo.ModuleType(address), 1) = FALSE THEN GOTO SendCmdExit
     IF SIOGetByte(Glo.ModuleVer(address), 1) = FALSE THEN GOTO SendCmdExit
     Cksum = Cksum + Glo.ModuleType(address) + Glo.ModuleVer(address)
    END IF

  ELSE   'PicIO module

    'Get the I/0 values
    IF Glo.StatusDef(address) AND SendIO THEN
      IF SIOGetByte(Glo.IO1, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(Glo.IO2, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.IO1 + Glo.IO2
    END IF

    'Get the A/D 1 value
    IF Glo.StatusDef(address) AND SendAD1 THEN
      IF SIOGetByte(Glo.Ad1, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.Ad1
    END IF

    'Get the A/D 2 value
    IF Glo.StatusDef(address) AND SendAD2 THEN
      IF SIOGetByte(Glo.Ad2, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.Ad2
    END IF

    'Get the A/D 3 value
    IF Glo.StatusDef(address) AND SendAD3 THEN
      IF SIOGetByte(Glo.Ad3, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.Ad3
    END IF

    'Get Ctr value
    IF Glo.StatusDef(address) AND SendCtr THEN
      IF SIOGetByte(D, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(C, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B + C + D
      Glo.Counter = CharsToLong(A, B, C, D)
    END IF

    'Get the module type and version
    IF Glo.StatusDef(address) AND SendID THEN
      IF SIOGetByte(Glo.ModuleType(address), 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(Glo.ModuleVer(address), 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.ModuleType(address) + Glo.ModuleVer(address)
    END IF

    'Get the Sync I/0 values
    IF Glo.StatusDef(address) AND SendSyncIO THEN
      IF SIOGetByte(Glo.SyncIO1, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(Glo.SyncIO2, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + Glo.SyncIO1 + Glo.SyncIO2
    END IF

    'Get SyncCtr value
    IF Glo.StatusDef(address) AND SendSyncCtr THEN
      IF SIOGetByte(D, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(C, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(B, 1) = FALSE THEN GOTO SendCmdExit
      IF SIOGetByte(A, 1) = FALSE THEN GOTO SendCmdExit
      Cksum = Cksum + A + B + C + D
      Glo.SyncCounter = CharsToLong(A, B, C, D)
    END IF

  END IF

  IF SIOGetByte(CCksum, 1) = FALSE THEN GOTO NoChkSum

  Glo.CkSumError = FALSE

  IF (Cksum AND 255) <> CCksum THEN
    Glo.SIOError = TRUE
    'PRINT "Bad ChkSum"
    FixSIOerror
    'CALL Delayx(500)
    'CALL PrintClrStr(3, 1, " ")
    Glo.CkSumError = TRUE
    'GloErr = GloErr + 1
  END IF

  EXIT SUB


NoStatExit:
  Glo.SIOError = TRUE
  'CALL PrintClrStr(3, 1, "No Status")
  'PRINT "No Status"
  FixSIOerror
  'CALL Delayx(500)
  'CALL PrintClrStr(3, 1, " ")
  'GloErr = GloErr + 1
  EXIT SUB

NoChkSum:
  Glo.SIOError = TRUE
  'CALL PrintClrStr(3, 1, "No ChkSum")
  'PRINT "No ChkSum"
  FixSIOerror
  'CALL Delayx(500)
  'CALL PrintClrStr(3, 1, " ")
  'GloErr = GloErr + 1
  EXIT SUB


SendCmdExit:
  Glo.SIOError = TRUE
  'CALL PrintClrStr(3, 1, "SER IN FAILED")
  'PRINT "SER IN FAILED"
  FixSIOerror
  'CALL Delayx(500)
  'CALL PrintClrStr(3, 1, " ")
  'GloErr = GloErr + 1
  EXIT SUB


GrpCmdExit:


END SUB

SUB SetAccel (address AS INTEGER)

 'set accel to ans intial value before enabling servo

 IF address < 1 THEN EXIT SUB

 'IF address > xMaxMtr THEN
 '  MtrNum = 1
 'ELSE
 '  MtrNum = address
 'END IF

 MtrNum = address

 Cmd$ = CHR$(&H54) + CHR$(LoadAcc) + LongToStr(Glo.CmdAccel(MtrNum))

 SendCmd address, Cmd$

END SUB

SUB SetForAuto

  IF XSpeed = 0 THEN XSpeed = 2
  IF YSpeed = 0 THEN YSpeed = 1

  'determine cts/millisec needed based on inches travel/sec
  XVelocity& = XSpeed * XCtr * (1 / 1953) * 65536
  YVelocity& = YSpeed * YCtr * (1 / 1953) * 65536

  'set length of time in seconds to reach specified maximum velocity
  XTime! = .1: YTime! = .1

  'x & y acceleration, deceleration  calc's
  XCel& = (XSpeed / XTime!) * XCtr * (1 / 1953) * (1 / 1953) * 65536
  YCel& = (YSpeed / YTime!) * YCtr * (1 / 1953) * (1 / 1953) * 65536

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

SUB SetGain (address AS INTEGER)

   IF address < 1 THEN EXIT SUB

   'IF address > 'xMaxMtr THEN  'global
   '   MtrNum = 1
   'ELSE
   '   MtrNum = address
   'END IF

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

SUB SetHomeCap

  address = &HFF   'all Mtrs

  Cmd$ = CHR$(&H19) + CHR$(&H9)

  SendCmd address, Cmd$

END SUB

SUB SetLcdPos (ROW, COL)

  C = COL - 1: R = ROW - 1

  'Sets lcd position to line 'row', column 'col' (if in lcd range)
  'IF ((C < LcdColumns) AND (R < LcdLines)) THEN
  '  IF C >= 0 AND R >= 0 THEN
  '    CALL StrobeInstr((LcdAddrSet OR StartLPos(R)) + C)
  '  END IF
 ' END IF
 CON.CLS
END SUB

SUB SetModePos

   ControlByte = PosMode OR StartNow

   'Build the command string
   Cmd$ = CHR$(&H14) + CHR$(ControlByte)

   SendCmd &HFF, Cmd$

END SUB

SUB SetModePwm

  ControlByte = LoadPWM OR StartNow

  x = 0

  'Build the command string
  Cmd$ = CHR$(&H24) + CHR$(ControlByte) + CHR$(x)

  SendCmd &HFF, Cmd$

END SUB

SUB SetModeVel

    ControlByte = LoadVel OR PosMode OR VelMode OR StartNow

    X1& = 0  'velocity

    'build the command string
    Cmd$ = CHR$(&H54) + CHR$(ControlByte) + LongToStr(X1&)

    SendCmd &HFF, Cmd$

END SUB

SUB SetPorts
  'intialize port mode registers to input or output
  OUT KeyModeReg, DataPortIn  'port 0
  OUT LcdModeReg, DataPortOut 'port 2
  OUT BitModeReg, DataPortOut 'port 3 - output LCD/Keypad control lines

END SUB

SUB SetPwm (MtrNum, PwmVal)

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

SUB SetTables

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

SUB SetXCtrs

  CALL GetXyPos
  XPosStr = QStr$(XPos, 10)
  XOffset = GetXCord(CLNG(XPos * XCtr))
  CALL ResetPosition(Servo1)
  CALL ResetPosition(Servo2)

END SUB

FUNCTION SIOGetByte (Character AS INTEGER, TimeOutPeriod AS INTEGER)

 REM  Changed to PC serial port routine

 OneChr$ = " "

 STime& = GetTick&

 'loop till we get a byte from the serial port or timeout
 DO

    CALL ReadFromComm(PICPort, OneChr$, BytesRead, ECode)

    IF BytesRead > 0 THEN
      Character = ASC(OneChr$)
      SIOGetByte = TRUE
      EXIT FUNCTION
    END IF

    IF (ABS(GetTick& - STime&) > 18) THEN
      SIOGetByte = FALSE
      EXIT FUNCTION
    END IF

 LOOP

END FUNCTION

SUB StopMtrs

  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd AllServos, Cmd$

  FOR x = 1 TO 3
    Glo.CmdPwm(x) = 0
  NEXT

END SUB

SUB StopXMtrs

  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd Servo1, Cmd$
  SendCmd Servo2, Cmd$

  Glo.CmdPwm(1) = 0
  Glo.CmdPwm(2) = 0

END SUB

SUB StopYMtr

  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd Servo3, Cmd$

  Glo.CmdPwm(3) = 0

END SUB

SUB Strip (A$) STATIC

    CALL STRIPBLANKS(A$, 3, SLen)
    A$ = LEFT$(A$, SLen)

END SUB

SUB StrobeData (datab)

  'Strobes datab to the lcd
  OUT BitReg, DataStbOff ' strobe off
  CALL ddelay(D20)
  OUT LcdReg, datab      ' send data
  CALL ddelay(D20)
  OUT BitReg, DataStbOn  ' strobe on
  CALL ddelay(D50)
  OUT BitReg, DataStbOff ' strobe off
  CALL ddelay(D20)
  OUT LcdModeReg, DataPortIn ' set data port as input
  CALL ddelay(D20)
  OUT BitReg, LcdBusy  ' set up lcd to test busy flag (BF)
  CALL ddelay(D20)

  WHILE (INP(LcdReg) AND BusyFlag)    ' loop while BF=1
  WEND

  OUT LcdModeReg, DataPortOut ' set data port as output
  CALL ddelay(D20)

END SUB

SUB StrobeInstr (insb)

  'Strobes instructions to the lcd, also tests the busy flag
  OUT BitReg, InstrStbOff 'strobe off
  CALL ddelay(D20)
  OUT LcdReg, insb        'send data
  CALL ddelay(D20)
  OUT BitReg, InstrStbOn  'strobe on
  CALL ddelay(D50)
  OUT BitReg, InstrStbOff 'strobe off
  CALL ddelay(D20)
  OUT LcdModeReg, DataPortIn 'set data Port 1 as input
  CALL ddelay(D20)
  OUT BitReg, LcdBusy 'set up lcd to test busy flag (BF)
  CALL ddelay(D20)

  WHILE INP(LcdReg) AND BusyFlag  'loop while BF=1
  WEND

  OUT LcdModeReg, DataPortOut 'set Port 1 as output

  CALL ddelay(D20)
END SUB


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
SUB DFRead (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
    GET filenum, offset ,PASSREC
     ECode = -1
END SUB
SUB DFRead2 (filenum AS INTEGER, passrec AS scanprams , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
    GET filenum, offset ,PASSREC
    ECode = -1
END SUB
SUB DFWrite (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, Byteswritten AS INTEGER, ECode AS INTEGER)
        PUT filenum,  offset ,PASSREC
        ECode = -1
END SUB
SUB DFWrite2 (filenum AS INTEGER, passrec AS scanprams , OFFSET AS INTEGER, Byteswritten AS INTEGER, ECode AS INTEGER)
        PUT filenum,  offset ,PASSREC
        ECode = -1
END SUB

SUB FCreate (filenumber AS INTEGER, ATTR AS INTEGER, filename AS STRING, ECode AS INTEGER)
    LOCAL FileExists AS INTEGER
    FileExists = ISFILE(FileName)
    IF FileExists THEN
        OPEN filename FOR BINARY AS filenumber BASE = 0
        ECode = -1
    ELSE
        ecode = 0
        OPEN filename FOR BINARY AS filenumber BASE = 0
    END IF
END SUB
SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING, ECode AS INTEGER)
    LOCAL FileExists AS INTEGER
    FileExists = ISFILE(FileName)
    IF FileExists THEN
        OPEN filename FOR BINARY AS filenumber BASE = 0
        ecode = -1
    ELSE
        ecode = 0
    END IF
END SUB
SUB FClose (filenumber AS INTEGER)
    CLOSE filenumber
END SUB

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
