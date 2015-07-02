'was XRAY3,  renamed XRAYPC & changed some routines
'to work on PC 8/10/97

DEFINT A-Z
'$DYNAMIC

'Include rs232.bi
DECLARE SUB SetIRQ (ComPortNum%, IRQ%, ECode%)
DECLARE SUB SetPortAddr (ComPortNum%, PortAddress%, ECode%)
DECLARE SUB CloseCommPort (ComPortNum%, ECode%)
DECLARE SUB CommError (ComPortNum%, ECode%)
DECLARE SUB FlushBuffers (ComPortNum%, WhichBuffer%, ECode%)
DECLARE SUB GetCharsInBuffer (ComPortNum%, RecvQue%, XmitQue%, ECode%)
DECLARE SUB LineStatus (ComPortNum%, Cts%, DSR%, CD%, RI%, ECode%)
DECLARE SUB GetDTRState (ComPortNum%, DTRState%, ECode%)
DECLARE SUB GetRTSState (ComPortNum%, DTRState%, ECode%)
DECLARE SUB SetDTRSignal (ComPortNum%, DTRState%, ECode%)
DECLARE SUB SetRTSSignal (ComPortNum%, DTRState%, ECode%)
DECLARE SUB ReadFromComm (ComPortNum%, ReadBuffer$, BytesRead%, ECode%)
DECLARE SUB SetFlowControl (ComPortNum%, InFlow%, OutFlow%, InMin%, InMax%, XonChar%, XoffChar%, ECode%)
DECLARE SUB WriteToComm (ComPortNum%, WriteBuffer$, BytesWritten%, ECode%)
DECLARE SUB ChangeCommSettings (ComPortNum%, BaudRate&, DataBits%, Parity%, StopBits%, ECode%)
DECLARE SUB OpenCommPort (ComPortNum%, BaudRate&, DataBits%, Parity%, StopBits%, ECode%)
DECLARE SUB UARTType (ComPortNum%, UART%, ECode%)
DECLARE SUB SetFIFOTriggerLevel (ComPortNum%, TriggerLevel%, ECode%)
DECLARE SUB CalcRequiredMem (PortSeg%, PortOfs%, RecvSeg%, RecvOfs%, XmitSeg%, XmitOfs%, NumPorts%, MemSize&, ECode%)
DECLARE SUB InitCommBuffers (ECode%)
DECLARE SUB DeleteCommBuffers (ECode%)
DECLARE SUB InitSharedHandler (PortSeg%, PortOfs%, NumPorts%, IRQ%, StatusRegisterAddr%, ECode%)



   'motor soft controls
   DECLARE FUNCTION GetXCord& (Cts&)
   DECLARE SUB ProfileScan ()
   DECLARE SUB ReSetMotors ()
   DECLARE SUB SetForAuto ()
   DECLARE SUB SetForManual ()
   DECLARE FUNCTION GetYCord& (Cts&)
   DECLARE FUNCTION RoundOff# (BYVAL Value#, BYVAL Digits%)
   DECLARE FUNCTION DoX (AbsPos&)
   DECLARE FUNCTION DoY (AbsPosY&)
   DECLARE FUNCTION GetAbsXCts& ()
   DECLARE FUNCTION GetAbsYCts& ()
   DECLARE SUB MotorXStop ()
   DECLARE SUB MotorXGo (dir)
   DECLARE SUB MotorYStop ()
   DECLARE SUB MotorYGo (dir)
   DECLARE SUB MotorXMove (AbsCts&)
   DECLARE SUB MotorYMove (AbsCts&)
   DECLARE SUB PrintPos ()
   
   'my new x-ray
   
   'added from probas lib 7.1
   DECLARE SUB STRIPBLANKS (A$, Num, SLen) 'pro assembler
   DECLARE SUB Strip (A$)   'pro basic
   DECLARE SUB Delay18th (MiniDelay)


   'added from crescent
   DECLARE FUNCTION QPRound$ (BYVAL Amount#, BYVAL Places)
   DECLARE FUNCTION RoundOff# (BYVAL Value#, BYVAL Digits)
   DECLARE FUNCTION Ascii (Any$)
   DECLARE FUNCTION FUsing$ (Num$, Image$)
   DECLARE SUB InitInt (SEG segm, Value, NumEls)
   DECLARE SUB ISortI (SEG segm1, SEG segm2, NumEls, diri)
   DECLARE FUNCTION WriteTest (Drive$)
   DECLARE FUNCTION DriveSpace& (Drv$)
   DECLARE FUNCTION Valid (FileNumber$)
   DECLARE SUB SetDrive (Drv$)

   'my subs
   DECLARE FUNCTION QStr$ (BYVAL Amount#, BYVAL Places)
   DECLARE SUB DelayX (Millisec) '
   DECLARE FUNCTION DelayFact& () '
   DECLARE FUNCTION DoX% (Position&)
   DECLARE SUB GoMtrs ()
   DECLARE FUNCTION CharsToInt (BYVAL A AS INTEGER, B AS INTEGER)
   DECLARE FUNCTION CharsToLong& (BYVAL A AS INTEGER, B AS INTEGER, c AS INTEGER, d AS INTEGER)
DECLARE SUB ClearBits (address AS INTEGER)
DECLARE SUB EnableAmpl (Value AS INTEGER, address AS INTEGER)
DECLARE SUB LoadMotion (address AS INTEGER, Mode AS INTEGER)
DECLARE SUB InitializeAccel (address AS INTEGER)
DECLARE FUNCTION InitNetwork ()
DECLARE FUNCTION IntToStr$ (X AS INTEGER)
DECLARE FUNCTION LongToStr$ (X AS LONG)
DECLARE SUB MtrOff (address AS INTEGER)
DECLARE SUB ProgramExit ()
DECLARE SUB ResetPosition (address AS INTEGER)
DECLARE SUB SendCmd (address AS INTEGER, CmdString AS STRING)
DECLARE SUB SetGain (address AS INTEGER)
DECLARE FUNCTION SIOGetByte (Character AS INTEGER, TimeOutPeriod AS INTEGER)
DECLARE SUB StopAbort ()
DECLARE SUB StopNormal ()
DECLARE SUB FixSIOError ()
DECLARE SUB KEdit (Edit$, ExitCode)
DECLARE SUB ClrLCD ()
DECLARE FUNCTION TrapInt% (os%, ps%, fg%)
DECLARE SUB GetScanCal ()
DECLARE FUNCTION GetDiskFile$ ()
DECLARE SUB CloseComPorts ()
DECLARE FUNCTION OpenComPorts ()
DECLARE SUB CalEncoder ()


DECLARE FUNCTION RecordData ()
DECLARE SUB GetStatus (Num)
DECLARE FUNCTION GetUSN$ (UCode$)
DECLARE FUNCTION Filter$ (FiltStr$)
DECLARE FUNCTION GetSelectKey ()
DECLARE SUB DriveCrawler ()
DECLARE SUB PWMTable ()
DECLARE SUB SetDefaults ()



'keypad & LCD stuff
DECLARE SUB StrobeInstr (SChar)
DECLARE SUB StrobeData (SChar)
DECLARE SUB InitDisplay ()
DECLARE SUB SetCursor (Y, X)
DECLARE FUNCTION GetLcdRowPos ()
DECLARE FUNCTION GetLcdColPos ()
DECLARE SUB PrintChar (Y, X, Char$)    'print single char
DECLARE SUB PrintClrStr (Y, X, text$)  'print string & clear line
DECLARE SUB PrintStr (Y, X, text$)     'print string
DECLARE SUB PrintC (PChar$, X%, Y%, f%, h%)
DECLARE SUB ddelay (Nval)
DECLARE FUNCTION GetData ()
DECLARE FUNCTION GetKeys ()
DECLARE SUB FlushKeys ()
DECLARE FUNCTION Keydown ()

 'memory line start positions for LCD
 DIM SHARED StartLPos(3)
 StartLPos(0) = &H0
 StartLPos(1) = &H40
 StartLPos(2) = &H14
 StartLPos(3) = &H54

 CONST D10 = 1
 CONST D20 = 2
 CONST D50 = 8
 CONST D100 = 16
 CONST LcdLines = 4
 CONST LcdColumns = 20
 CONST KeyReg = &H268      ' 8255 Port 0 (keypad data bits)
 CONST DataReg = &H269     ' 8255 Port 1 (LCD data bits)
 CONST CtrlReg = &H26A     ' 8255 Port 2 (LCD and Keypad control bits)
 CONST ProgReg = &H26B     ' 8255 Control Port
 CONST DataPortOut = &H90  ' Port 0=in, 1=out, 2=out
 CONST DataPortIn = &H92   ' Port 0=in, 1=in, 2=out
 CONST DataStbOn = &HA     ' RS=1, R/W=0, E=1
 CONST DataStbOff = &H8    ' RS=1, R/W=0, E=0
 CONST InstrStbOn = &H2    ' RS=0, R/W=0, E=1
 CONST InstrStbOff = &H0   ' RS=0, R/W=0, E=0
 CONST LcdBusy = &H6       ' RS=0, R/W=1, E=1
 CONST BusyFlag = &H80     ' busy flag bits
 CONST LcdAddress = &H7F   ' cursor memory address bits
 CONST LcdAddrSet = &H80   ' instr to set cursor (mem) position
 CONST LcdPos = &H6        ' instr to get cursor (mem) position

 CONST KeyStbOn = &H1
 CONST KeyStbOff = &H0


 'miss const values
 CONST True = -1, False = NOT True, gain = 0, NEGDIR = -1, POSDIR = 1
 
 'Number of motors in system, change as needed.
 CONST Mtr1 = 1, Mtr2 = 2, Mtr3 = 3, AllMtrs = &HFF, MaxMtr = 3

 'Key codes
 CONST KeyUP = 72, KeyDN = 80, KeyLFT = 75, KeyRGT = 77
 CONST KeyPGUP = 73, KeyPGDN = 81, KeyHOME = 71, KeyEND = 79, KeyDEL = 83
 CONST KeyBKSPC = 8, KeyTAB = 9, KeySPC = 32, KeyEnter = 13, KeyEsc = 27
 CONST KeyF1 = 59, KeyF2 = 60, KeyF3 = 61, KeyF4 = 62
 

 'Sio error mode difinitions
 CONST DoNothing = 0, ErrorBox = 1, AbortCom = 2, ExitProgram = 3

 'Module type definitions
 CONST PicServoType = 0
 
 'Status definitions bits
 CONST SendPos = 1, SendAD = 2, SendVel = 4, SendAux = 8
 CONST SendHome = 16, SendID = 32
 
 'Load Trajectory control byte
 CONST LoadPos = 1, LoadVel = 2, LoadAcc = 4, LoadPWM = 8, PosMode = 16
 CONST VelMode = 32, RevDir = 64, StartNow = 128, PWMMode = 0'PWM added KJL
 
 'Stop control byte
 CONST EnableAmp = 1, MotorOff = 2, StopAbrupt = 4, StopSmooth = 8
 
 'Homing control byte
 CONST HomeOnLimit1 = 1, HomeOnLimit2 = 2, HomeOnIndex = 8, HomeOnPerr = 64
 CONST HomeOnCerr = 128
 
 'Status byte
 CONST MoveDone = 1, CksumErr = 2, OverCurrent = 4, PowerOn = 8, PosError = 16
 CONST Limit1 = 32, Limit2 = 64, HomeInProg = 128
 
 'Auxiliary status byte
 CONST IndexPulse = 1, PositionWrap = 2, ServoOn = 4, AccelDone = 8
 CONST SlewDone = 16, ServoOverrun = 32
 
 'MiscMode bit definitions
 CONST AmpEnabled = 1, PWMSelected = 2, VelSelected = 4, PosSelected = 8
 CONST OnL1Selected = 16, OnL2Selected = 32, OnIndexSelected = 64
 CONST OnPeSelected = 128, OnCeSelected = 256, HomeFlagMask = &HFE0F
 
 TYPE Global
   NumModules AS INTEGER
   StatusDef(3) AS INTEGER
   ModuleType(3) AS INTEGER
   ModuleVer(3) AS INTEGER
   Position(3) AS LONG
   CmdPosition(3) AS LONG
   HomePosition(3) AS LONG
   Velocity(3) AS INTEGER
   CmdVelocity(3) AS LONG
   CmdAccel(3) AS LONG
   CmdPWM(3) AS LONG
   ADVal(3) AS INTEGER
   Stat(3) AS INTEGER
   AuxStat(3) AS INTEGER
   Kp(3) AS INTEGER
   Ki(3) AS INTEGER
   Kd(3) AS INTEGER
   IL(3) AS INTEGER
   ol(3) AS INTEGER
   CL(3) AS INTEGER
   EL(3) AS INTEGER
   SRD(3) AS INTEGER
   MiscMode(3) AS INTEGER
   SIOErrorMode AS INTEGER
   CumSIOError AS INTEGER
   CkSumError AS INTEGER
   SIOPort AS INTEGER
   AmpQuery AS INTEGER
   PowerQuery AS INTEGER
   Baud AS LONG
 END TYPE
 DIM SHARED glo AS Global

 TYPE ScanPrams
   YCtr          AS SINGLE       'YCts/inch
   XCtr          AS SINGLE       'XCts/inch
   YCal          AS SINGLE       'Y Cal Inch distance
   XCal          AS SINGLE       'X Cal Inch distance
   XOffset       AS SINGLE       'X inch pos when counter zeroed
   YOffset       AS SINGLE       'Y inch pos when counter zeroed
   XPos          AS SINGLE       'current X inch position
   YPos          AS SINGLE       'current Y inch position
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
   XCts          AS LONG         'x absolute value scan start counts
   YCts          AS LONG         'y absolute value scan start counts
   XStartCts     AS LONG         'x actual value (+/-) scan start counts
   YStartCts     AS LONG         'y actual value (+/-) scan start counts
   XEndCts       AS LONG         'x actual value (+/-) scan end counts
   YEndCts       AS LONG         'y actual value (+/-) scan end counts
   XLow          AS SINGLE       'x scan start inch position
   YLow          AS SINGLE       'y scan start inch position
   XHigh         AS SINGLE       'x scan end inch position
   YHigh         AS SINGLE       'y scan end inch position
   XSpeed        AS SINGLE       'x scan speed in inches
   YSpeed        AS SINGLE       'y scan speed in inches
   XEnable       AS INTEGER      'flag true/false X axis on
   YEnable       AS INTEGER      'flag true/false Y axis on
   IndexAxis     AS INTEGER      'flag true/false X or Y
   StopChk       AS INTEGER      'flag true/false autoOff on/off
   StepIndex     AS INTEGER      'flag true/false step index
   IndexCt AS INTEGER            'index loop counter
   IndexInc AS INTEGER           'index loop incrementer
   LastXIndex AS INTEGER         'last X scan direction
   LastYIndex AS INTEGER         'last Y scan direction
   ScanFlag AS INTEGER           '
   Index AS INTEGER           'scan direction

   YCtrSTR   AS STRING * 10
   XCtrSTR AS STRING * 10
   XPosStr AS STRING * 10
   YPosStr AS STRING * 10
   XPlusSTR AS STRING * 10
   YPlusSTR AS STRING * 10
   XIndexSTR AS STRING * 10
   YIndexSTR AS STRING * 10
   XLowSTR AS STRING * 10
   YLowSTR AS STRING * 10
   XHighSTR AS STRING * 10
   YHighSTR AS STRING * 10
   XSpeedSTR AS STRING * 10
   YSpeedSTR AS STRING * 10
   XEnableSTR AS STRING * 10
   YEnableSTR AS STRING * 10
   IndexAxisSTR AS STRING * 10
   StopChkSTR AS STRING * 10
   StepIndexSTR AS STRING * 10
 END TYPE
 DIM SHARED Scan AS ScanPrams

   'define cts/inch for axial direction
   '500 line encoder in quad = 2000 cts/motor revolution
   '18.75:1 gear head = 2000 cts * 18.75 g/head = 37,500 cts/pulley revolution
   'pulley pitch diameter = .800 * PI  = 2.513274" travel/pulley revolution
   '37,500 cts / 2.513274" travel = 20,868 cts/inch travel
   Scan.YCtr = 14858 'cts per inch travel

   'define cts/inch for magnetic wheels
   '500 line encoder in quad = 2000 cts/motor revolution
   '35:1 gear head * 2:1 miter box * 2:1 sprocket =
   '2000 * 35 * 2 * 2 = 280000 'cts/wheel rev
   'wheel pitch diameter = 2.0 * PI  = 6.283185" travel/wheel revolution
   Scan.XCtr = 62047

 'COM PORTS
 DIM SHARED Port
 DIM SHARED RecvSize
 DIM SHARED XmitSize
 DIM SHARED MemSize AS LONG
 DIM SHARED PicPort AS INTEGER
 DIM SHARED PICBaud AS LONG

 'delay timer
 DIM SHARED DelayCtr AS LONG
 DIM SHARED WaitX AS INTEGER

 'set com port numbers & baud
 PicPort = 2: PICBaud = 19200

 DelayCtr = 100  'DelayFact
 WaitX = 1   'delay used in comm
       

  '*********************************************************************
  ' intialize LCD
  '*********************************************************************
 
  'REMED out for PC
  'CALL InitDisplay
  'CALL FlushKeys


  '***********************************************
  'Open & Check Com Buffers, Report & Fix errors
  '
  '  - check PIC, power on, etc..
  '***********************************************
  END

  CALL ClrLCD
  IF NOT OpenComPorts THEN
    PRINT "SERVO ERROR";
    PRINT "PRESS RESET";
    DO
    LOOP
  END IF
	
  DO
  LOOP UNTIL InitNetwork
   

  DO
     PrintPos
     XX& = XX& + 1
     LOCATE 20, 1: PRINT XX&;
     IF XX& > 10000 THEN XX& = 0
  LOOP

  'Change to load defaults?
  'save defaults when exiting program only
  IF DefFlag THEN
    DefFlag = 0
    GOSUB SetDefaults
  END IF

  PChar$ = "<F1=BEGIN SCAN>"
  CALL PrintC(PChar$, 30, 1, 15, 0)
  YOn = 12: Xon = 11

  PFlag = 1 'run scan profile if flag set

  Scan.XEnable = False
  'CmdBuf(1).axcmd = &H100 + MF: CmdBuf(1).arg = 0
  'CmdBuf(2).axcmd = &H200 + MF: CmdBuf(2).arg = 0
  ''Call Dc2Cmd(DC2B1, 2, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))
   
  Scan.YEnable = False
  'CmdBuf(1).axcmd = &H100 + MF: CmdBuf(1).arg = 0
  'Call Dc2Cmd(DC2B2, 1, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))
   
  CALL SetForManual

  DefFlag = 1

   'Scan Menu

       GOSUB PrintMainMenu

       SetCursor 1, 1
       
       DO
	
	SELECT CASE CSRLIN
	  CASE 1  'scan setup
	    SetCursor 1, 1: PRINT ">";
	    DO: XCode = GetSelectKey: LOOP UNTIL XCode
	    IF XCode = KeyUP THEN
	      SetCursor 1, 1: PRINT " ";
	      SetCursor 1
	    ELSEIF XCode = KeyDN THEN
	      SetCursor 1, 1: PRINT " ";
	      SetCursor 2
	    ELSEIF XCode = KeyEnter THEN 'do menu
	      GetScanCal
	      GOSUB PrintMainMenu
	      SetCursor 3
	    END IF
	  CASE 2 'begin scan
	    SetCursor 2, 1: PRINT ">";
	    DO: XCode = GetSelectKey: LOOP UNTIL XCode
	    IF XCode = KeyUP THEN
	      SetCursor 2, 1: PRINT " ";
	      SetCursor 1
	    ELSEIF XCode = KeyDN THEN
	      SetCursor 2, 1: PRINT " ";
	      SetCursor 3
	    ELSEIF XCode = KeyEnter THEN 'do menu
	      GOSUB Profiler
	      IF Scan.ScanFlag = -1 THEN
		 PChar$ = "ANY KEY STOPS SCAN"
		 CALL PrintC(PChar$, 30, 1, 15, 0)
		 PrintPos
		 CALL SetForAuto
		 ReSetMotors
		 IF Scan.IndexAxis THEN  'circ scan indexing loop
		    GOSUB XScan
		    ELSE : GOSUB YScan    'ax scan indexing loop
		 END IF
		 CALL SetForManual
		 PChar$ = "<F1=BEGIN SCAN>"
		 CALL PrintC(PChar$, 30, 1, IMenuFore, IMenuBack)
	      ELSE
		 PChar$ = "CAL ERROR-PRESS KEY"
		 CALL PrintC(PChar$, 30, 1, 15, 0)
		 DO
		 LOOP UNTIL KeyPress
	      END IF
	      GOSUB PrintMainMenu
	      SetCursor 3
	    END IF
	  CASE 3 'exit program
	    SetCursor 3, 1: PRINT ">";
	    DO: XCode = GetSelectKey: LOOP UNTIL XCode
	    IF XCode = KeyUP THEN
	      SetCursor 3, 1: PRINT " ";
	      SetCursor 2
	    ELSEIF XCode = KeyDN THEN
	      SetCursor 3, 1: PRINT " ";
	      SetCursor 3
	    ELSEIF XCode = KeyEnter THEN 'do menu
	      PChar$ = "EXIT (Y/N): "
	      CALL PrintC(PChar$, 30, 1, 15, 0)
	      DO
	      LOOP 'Until Y/N
	      IF PChar$ = "Y" THEN
		'shut off motors
		CALL ClrLCD: SCREEN 0, 0, 0: END
		'shut off comp
	      ELSE
		GOSUB PrintMainMenu
		SetCursor 3
	      END IF
	    END IF
	END SELECT

	IF XCode = KeyEsc THEN
	  Y = CSRLIN: X = POS(0)
	  DO
	    SetCursor 14, 1: PRINT "Exit Program (Y/N): ";
	    SetCursor 14, 20: temp$ = " ": CALL KEdit(temp$, XCode) 'get input
	    SetCursor 14, 1: PRINT SPACE$(22);
	  LOOP UNTIL temp$ = "Y" OR temp$ = "y" OR temp$ = "N" OR temp$ = "n"
	  SetCursor Y, X
	  IF temp$ = "N" OR temp$ = "n" THEN
	    XCode = -1
	  ELSE
	    XCode = KeyEsc
	  END IF
	END IF

	PrintPos
	GOSUB CheckMove

  LOOP UNTIL XCode = KeyEsc

  CloseComPorts

  'save header info to default file

  CALL ClrLCD

  END


PrintMainMenu:

       CALL ClrLCD: SetCursor 1, 1
       SetCursor 1, 1: PRINT "     Scan SetUp     ";
       SetCursor 2, 1: PRINT "     Begin Scan     ";
       SetCursor 3, 1: PRINT "    Exit Program    ";

       RETURN


SetDefaults:
  Scan.XLow = 0: Scan.XLowSTR = STR$(Scan.XLow)
  Scan.XHigh = 12: Scan.XHighSTR = STR$(Scan.XHigh)
  Scan.YLow = 0: Scan.YLowSTR = STR$(Scan.YLow)
  Scan.YHigh = 6: Scan.YHighSTR = STR$(Scan.YHigh)
  Scan.XIndex = .1: Scan.XIndexSTR = STR$(Scan.XIndex)
  Scan.YIndex = .1: Scan.YIndexSTR = STR$(Scan.YIndex)
  Scan.XPlus = True: Scan.XPlusSTR = "POSITIVE"
  Scan.YPlus = True: Scan.YPlusSTR = "POSITIVE"
  Scan.XSpeed = 2: Scan.XSpeedSTR = STR$(Scan.XSpeed)
  Scan.YSpeed = 8: Scan.YSpeedSTR = STR$(Scan.YSpeed)
  Scan.XCtrSTR = STR$(Scan.XCtr)
  Scan.YCtrSTR = STR$(Scan.YCtr)
  Scan.XEnable = False: Scan.XEnableSTR = "OFF"
  Scan.YEnable = False: Scan.YEnableSTR = "OFF"
  Scan.IndexAxis = False: Scan.IndexAxisSTR = "X"
  Scan.StopChk = True: Scan.StopChkSTR = "ON"
  Scan.StepIndex = False: Scan.StepIndexSTR = "OFF"
  RETURN

Profiler:
  'check all scan cal parameters
  IF Scan.XHigh > Scan.XLow THEN
    IF Scan.YHigh > Scan.YLow THEN
      IF Scan.XIndex > 0 AND Scan.YIndex > 0 THEN
	IF Scan.XPlus = True OR Scan.XPlus = False THEN
	  IF Scan.YPlus = True OR Scan.YPlus = False THEN
	    IF Scan.XSpeed > 0 THEN
	      IF Scan.YSpeed > 0 THEN
		IF Scan.XEnable THEN
		  IF Scan.YEnable THEN
		    IF PFlag THEN CALL ProfileScan
		    PFlag = 0
		    CALL SetForAuto
		    Scan.ScanFlag = -1
		  ELSE
		    Scan.ScanFlag = 0
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
   
CheckMove:
  IF Scan.StopChk THEN
    IF Scan.XEnable THEN
      IF ABS(PreXInch! - Scan.XPos) > .1 THEN
	Scan.XEnable = False
	Scan.XEnableSTR = "OFF       "
	CALL EnableAmpl(Scan.XEnable, Mtr1)
	CALL EnableAmpl(Scan.XEnable, Mtr2)
      END IF
    END IF
    IF Scan.YEnable THEN
      IF ABS(PreYInch! - Scan.YPos) > .1 THEN
	Scan.YEnable = False
	Scan.YEnableSTR = "OFF       "
	CALL EnableAmpl(Scan.YEnable, Mtr3)
      END IF
    END IF
  END IF
  RETURN

XScan:
    DO WHILE Scan.IndexCt >= Scan.YDataStart AND Scan.IndexCt <= Scan.YDataEnd
      MoveErr = DoY(Scan.YIndexCts * Scan.IndexCt)'index Y axis into position
      GOSUB CheckErr 'check for move error
      SELECT CASE GetAbsXCts
	CASE IS > Scan.XStartCts + (Scan.XEndCts - Scan.XStartCts) / 2
	  MoveToPos& = Scan.XStartCts
	CASE ELSE: MoveToPos& = Scan.XEndCts
      END SELECT
      MoveErr = DoX(MoveToPos&) 'put y axis into position
      GOSUB CheckErr 'check for move error
      Scan.IndexCt = Scan.IndexCt + Scan.IndexInc
      IF Scan.StepIndex THEN
	 S$ = "* PRESS ENTER KEY FOR NEXT STEP *"
	 CALL PrintC(S$, ScanRow(20), ScanCol(1) + 20, 15, 0)
	 DO
	 LOOP WHILE INKEY$ = ""
	 S$ = "                                 "
	 CALL PrintC(S$, ScanRow(20), ScanCol(1) + 20, 15, 0)
	 FlushKeys
      END IF
    LOOP
    PreYInch! = Scan.YPos
    PreXInch! = Scan.XPos
    RETURN

YScan:
    DO WHILE Scan.IndexCt >= Scan.XDataStart AND Scan.IndexCt <= Scan.XDataEnd
      MoveErr = DoX(Scan.XIndexCts * Scan.IndexCt)'index X axis into position
      GOSUB CheckErr 'check for move error
      SELECT CASE GetAbsYCts
	CASE IS > Scan.YStartCts + (Scan.YEndCts - Scan.YStartCts) / 2
	  MoveToPos& = Scan.YStartCts
	CASE ELSE: MoveToPos& = Scan.YEndCts
      END SELECT
      MoveErr = DoY(MoveToPos&)'put y axis into position
      GOSUB CheckErr 'check for move error
      Scan.IndexCt = Scan.IndexCt + Scan.IndexInc
      IF Scan.StepIndex THEN
	 S$ = "* PRESS ENTER KEY FOR NEXT STEP *"
	 CALL PrintC(S$, ScanRow(20), ScanCol(1) + 20, 15, 0)
	 DO
	 LOOP WHILE INKEY$ = ""
	 S$ = "                                 "
	 CALL PrintC(S$, ScanRow(20), ScanCol(1) + 20, 15, 0)
	  FlushKeys
      END IF
    LOOP
    PreYInch! = Scan.YPos
    PreXInch! = Scan.XPos
    RETURN


CheckErr:
  SELECT CASE MoveErr
    CASE 0 'axis X motor off
      CALL MotorXStop: CALL MotorYStop: SetForAuto
      Inlabel$ = "* STALL *  <ESC> TO CONTINUE "
      InLen = 0: WinXPos = 200: WinYPos = 180: WinClr = 9: InClr = 15
      temp$ = GetInput(Inlabel$, InLen, WinXPos, WinYPos, WinClr, InClr)
      GOTO ScanMenu
    CASE 1'axis Y motor off
      CALL MotorYStop: CALL MotorXStop: SetForAuto
      Inlabel$ = "* STALL *  <ESC> TO CONTINUE "
      InLen = 0: WinXPos = 200: WinYPos = 180: WinClr = 9: InClr = 15
      temp$ = GetInput(Inlabel$, InLen, WinXPos, WinYPos, WinClr, InClr)
      GOTO ScanMenu
    CASE 6
      'x, y & z move ok
      'continue
    CASE 7 'user halted scan
      CALL FlushKeys: CALL MotorYStop: CALL MotorXStop
      CALL SetForManual
      GOTO ScanMenu
  END SELECT
  RETURN
 

 Y = 1

'FOR X = 1 TO 32000
' CALL PrintClrStr(Y, 1, LTRIM$(STR$(X) + " Hello There!"))
' Y = Y + 1
' IF Y > 4 THEN
'   Y = 1
'   'CALL ddelay(10000)
' END IF
'NEXT


DO

   J = GetKeys

   IF J <> 0 THEN
     'CALL PrintChar(Y, X, Char$)
     X = X + 1
     IF X > 32000 THEN
       X = 0
       CALL PrintClrStr(2, 1, STR$(X))
     END IF
     CALL PrintClrStr(1, 1, STR$(J))
     CALL PrintClrStr(2, 1, STR$(X))
     WHILE Keydown
	CALL PrintClrStr(3, 1, "KEYDOWN")
     WEND
     CALL PrintClrStr(3, 1, "       ")
   END IF

LOOP

REM $STATIC
FUNCTION Ascii (GH$)

END FUNCTION

SUB CalEncoder

  'Input Screen & instructions

  'If user entered cts & OK then
  '   CalEncoder = Cts
  '   Exit Function
  'else
  '  CalEncoder = False
  '  Exit Function
  'end if
  
  'use PWM mode

  CALL ClrLCD:
  SetCursor 1, 1: PRINT "  - CALIBRATE ENCODER - ";
  SetCursor 2, 1: PRINT "Move crawler to start   ";
  SetCursor 3, 1: PRINT "position. Select 'Start ";
  SetCursor 4, 1: PRINT "Cal', press enter key.  ";
  SetCursor 5, 1: PRINT "Move crawler to end     ";
  SetCursor 6, 1: PRINT "position. Select 'End   ";
  SetCursor 7, 1: PRINT "Cal', press enter key.  ";
  SetCursor 8, 1: PRINT "Select 'Distance' enter ";
  SetCursor 9, 1: PRINT "measured distance.      ";

  SetCursor 11, 1: PRINT " Start Cts: "; "[              ]";
  SetCursor 12, 1: PRINT "   End Cts: "; "[              ]";
  SetCursor 13, 1: PRINT "  Distance: "; "["; Scan.XCal; "]";

  SetCursor 15, 1: PRINT "Enc Ct Pos: ";
  SetCursor 16, 1: PRINT "  Cts/Inch: "; Scan.XCtr;


  SetCursor 11, 1: PRINT ">Start Cts: ";

  

  ' turn motors on
  CALL EnableAmpl(True, AllMtrs)
  CALL ClearBits(AllMtrs)
  
  CALL GetStatus(AllMtrs) 'load status all motors

  DO

    IF glo.CkSumError THEN
      'comm error
    ELSE
      GOSUB CalSpeed 'adjust motor speed
    END IF
    
    'check velocity
    IF (glo.Velocity(Mtr1) = 0) OR (glo.Velocity(Mtr2) = 0) THEN
      'motors not moving
    END IF

    'check if EStop Hit or Power off
    IF (glo.Stat(Mtr1) AND PowerOn) OR (glo.Stat(Mtr2) AND PowerOn) THEN
      'Power is on
    ELSE
      'power off
      ' CALL ClearBits(AllMtrs)
    END IF
    
    CALL Delay18th(1)  'give a clock tick to scan keypad
    XCode = GetSelectKey

    'IF XCode = KeyEsc THEN EXIT DO

    'IF (XCode <> 0) AND (XCode <> KeyEsc) THEN
      SELECT CASE CSRLIN
       CASE 11
	 SetCursor 11, 1: PRINT ">Start Cts: ";
	 IF XCode = KeyEnter THEN
	   StartPos& = glo.Position(Mtr1)
	   temp$ = STR$(StartPos&)
	   CALL Strip(temp$)
	   temp$ = LEFT$(temp$ + SPACE$(14), 14)
	   SetCursor 11, 14: PRINT temp$;
	 END IF
	 IF (XCode = KeyUP) THEN
	   SetCursor 11, 1: PRINT " Start Cts: ";
	   SetCursor 11, 1
	 ELSEIF (XCode = KeyDN) OR (XCode = KeyEnter) THEN
	   SetCursor 11, 1: PRINT " Start Cts: ";
	   SetCursor 12, 1: PRINT ">  End Cts: ";
	 END IF
       CASE 12
	 SetCursor 12, 1: PRINT ">  End Cts: ";
	 IF XCode = KeyEnter THEN
	   EndPos& = glo.Position(Mtr1)
	   temp$ = STR$(EndPos&)
	   CALL Strip(temp$)
	   temp$ = LEFT$(temp$ + SPACE$(14), 14)
	   SetCursor 12, 1: PRINT "   End Cts: ";
	   SetCursor 12, 14: PRINT temp$;
	 END IF
	 IF (XCode = KeyUP) THEN
	   SetCursor 12, 1: PRINT "   End Cts: ";
	   SetCursor 11, 1: PRINT ">Start Cts: ";
	 ELSEIF (XCode = KeyDN) OR (XCode = KeyEnter) THEN
	   SetCursor 12, 1: PRINT "   End Cts: ";
	   SetCursor 13, 1: PRINT "> Distance: ";
	 END IF
       CASE 13
	 'Shut motors off before entering KEdit
	 glo.CmdPWM(Mtr1) = 0: glo.CmdPWM(Mtr2) = 0
	 CALL LoadMotion(AllMtrs, PWMMode)
	 CALL GoMtrs
	 SetCursor 13, 1: PRINT "> Distance: ";
	 'SetCursor 13, 14: temp$ = Scan.InchCal
	 CALL KEdit(temp$, XCode)  'get input
	 IF XCode = KeyEnter THEN
	   IF VAL(temp$) > 0 THEN
	     Mtr.XInchCal = VAL(temp$)
	     'Scan.InchCal = STR$(Mtr.XInchCal)
	     'CALL Strip(Scan.InchCal)
	     IF ABS(EndPos& - StartPos&) > 0 THEN
	       Mtr.XInchCts = ABS(EndPos& - StartPos&) / Mtr.XInchCal
	       'Scan.CtsInch = STR$(Mtr.XInchCts)
	       'CALL Strip(Scan.CtsInch)
	       Scan.CtsInch = LEFT$(Scan.CtsInch + SPACE$(14), 14)
	       SetCursor 16, 13: PRINT Scan.CtsInch;
	     END IF
	     SetCursor 13, 1
	   END IF
	 END IF
	 SetCursor 13, 14: PRINT Scan.InchCal;
	 SetCursor 13, 1
	 IF XCode = KeyUP THEN
	   SetCursor 13, 1: PRINT "  Distance: ";
	   SetCursor 12, 1: PRINT ">  End Cts: ";
	 ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
	   SetCursor 13, 1: PRINT "  Distance: ";
	   SetCursor 13
	 END IF
      END SELECT
    'END IF

   LOOP UNTIL XCode = KeyEsc
  
  'Shut motors off
  glo.CmdPWM(Mtr1) = 0: glo.CmdPWM(Mtr2) = 0
  CALL LoadMotion(AllMtrs, PWMMode)
  CALL GoMtrs
  
  
  EXIT SUB

CalSpeed:

    'calculated PWM output based on pot #1, NO steering
    glo.CmdPWM(Mtr1) = PwmOut(glo.ADVal(1))
    glo.CmdPWM(Mtr2) = glo.CmdPWM(Mtr1)
    CALL LoadMotion(Mtr1, PWMMode)
    CALL LoadMotion(Mtr2, PWMMode)
    CALL GoMtrs
    Y = CSRLIN: X = POS(0)
    SetCursor 15, 12: PRINT glo.Position(Mtr1);
    SetCursor Y, X
    RETURN

END SUB

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

FUNCTION CharsToLong& (BYVAL A AS INTEGER, B AS INTEGER, c AS INTEGER, d AS INTEGER)

 'Converts four bytes, (a=msb) to a signed long integer

 IF (A > 127) THEN
    A = A - 128
    CharsToLong = (A * 16777216 + B * 65536 + c * 256& + d) OR (&H80000000)
    EXIT FUNCTION
 ELSE
    CharsToLong = A * 16777216 + B * 65536 + c * 265& + d
    EXIT FUNCTION
 END IF


END FUNCTION

SUB ClearBits (address AS INTEGER)
  
 IF address < 1 THEN EXIT SUB

 'send a clear sticky bits command
 Cmd$ = CHR$(&HB)

 SendCmd address, Cmd$

END SUB

SUB CloseComPorts

   CALL CloseCommPort(PicPort, ECode)
   CALL DeleteCommBuffers(ECode)
   FarHeapSize& = SETMEM(MemSize)   'give far heap back to system

END SUB

SUB ClrLCD

   'REMED for PC
   CLS

   'reset cursor Y position to 1
   'range is 1 to 25 as normal screen

END SUB

SUB ddelay (Nval)
   FOR ll = 0 TO Nval
   NEXT
END SUB

FUNCTION DelayFact&

'determine cts per milisec

   T! = TIMER

   FOR Ctr& = 1 TO 1000000
   NEXT

   X! = TIMER - T!

   DelayFact = Ctr& / (X! * 1000)
   
   EXIT FUNCTION

END FUNCTION

SUB DelayX (Millisec) '

   ct& = DelayCtr * Millisec

   FOR Ctr& = 1 TO ct&
   NEXT

END SUB

FUNCTION DoX (MPos&)

   MoveToCts& = GetXCord(MPos&)
   glo.CmdPosition(Mtr1) = MoveToCts&
   glo.CmdPosition(Mtr2) = MoveToCts&
   CALL LoadMotion(Mtr1, PosMode)
   CALL LoadMotion(Mtr2, PosMode)
   CALL GoMtrs
  
   DO
     PrintPos
     'add print status ?
     IF Keydown <> 0 THEN
       DoX = 7: EXIT FUNCTION
     END IF
   LOOP UNTIL ABS(Scan.XCts - MoveToCts&) < Scan.XIndexCts

   'DO
     'wait for stop or time out?
     'this would insure motors are stopped
   'LOOP
  
   DoX = 6: EXIT FUNCTION

END FUNCTION

FUNCTION DoY (MPos&)
  
   MoveToCts& = GetYCord(MPos&)
   glo.CmdPosition(Mtr3) = MoveToCts&
   CALL LoadMotion(Mtr3, PosMode)
   CALL GoMtrs

   DO
     PrintPos
     'add print status ?
     IF Keydown <> 0 THEN
       DoY = 7: EXIT FUNCTION
     END IF
   LOOP UNTIL ABS(Scan.YCts - MoveToCts&) < Scan.YIndexCts


   'DO
     'wait for stop or time out?
     'this would insure motors are stopped
   'LOOP

   DoY = 6: EXIT FUNCTION

END FUNCTION

SUB DriveCrawler

  'use PWM mode

  EStr$ = STR$(Mtr.XInchCal)
  CALL Strip(EStr$)
  EStr$ = LEFT$(EStr$ + SPACE$(7), 7)

  CALL ClrLCD

  PrintStr 1, 1, " - DRIVE CRAWLER -  "
  PrintStr 3, 1, "X Pos: "
  PrintStr 4, 1, "Y Pos: "

  SetCursor 3, 1

  'set pwm  output to 0
  glo.CmdPWM(Mtr1) = 0: glo.CmdPWM(Mtr2) = 0
  CALL LoadMotion(AllMtrs, PWMMode)
  CALL GoMtrs
  
  'turn motors on
  CALL EnableAmpl(True, AllMtrs)
  CALL ClearBits(AllMtrs)

  CALL GetStatus(AllMtrs) 'load status all motors

  DO

    IF GetSelectKey = KeyEsc THEN EXIT DO
    
    IF Mtr.XInchCts > 0 THEN
      MtrXPos! = CLNG(glo.Position(Mtr1) / Mtr.XInchCts * 1000) / 1000
      MtrYPos! = CLNG(glo.Position(Mtr3) / Mtr.XInchCts * 1000) / 1000
      MtrX$ = QStr$(MtrXPos!, 10)
      MtrY$ = QStr$(MtrYPos!, 10)
      PrintClrStr 3, 8, MtrX$
      PrintClrStr 4, 8, MtrY$
    ELSE
      PrintClrStr 3, 8, QStr$(glo.Position(Mtr1))
      PrintClrStr 4, 8, QStr$(glo.Position(Mtr3))
    END IF

    'calculated PWM output based on pots
    IF glo.ADVal(2) <= 127 THEN 'left
      glo.CmdPWM(Mtr1) = PwmOut(glo.ADVal(1)) * (PwmOff(glo.ADVal(2)) / 100)
      glo.CmdPWM(Mtr2) = PwmOut(glo.ADVal(1))
    ELSE 'right
      glo.CmdPWM(Mtr2) = PwmOut(glo.ADVal(1)) * (PwmOff(glo.ADVal(2)) / 100)
      glo.CmdPWM(Mtr1) = PwmOut(glo.ADVal(1))
    END IF

    IF glo.CkSumError THEN
      'comm errror
    ELSE  'comm ok
      CALL LoadMotion(Mtr1, PWMMode)
      CALL LoadMotion(Mtr2, PWMMode)
      CALL GoMtrs
    END IF
    
    'check velocity
    IF (glo.Velocity(Mtr1) = 0) OR (glo.Velocity(Mtr2) = 0) THEN
      'motors not moving
    END IF

    'check if EStop Hit or Power off
    IF (glo.Stat(Mtr1) AND PowerOn) AND (glo.Stat(Mtr2) AND PowerOn) THEN
      'Power is on
    ELSE
      'power off
      CALL StopNormal
      CALL ClrLCD
      EXIT SUB
    END IF

  LOOP

  'Shut motors off
  glo.CmdPWM(Mtr1) = 0: glo.CmdPWM(Mtr2) = 0
  CALL LoadMotion(AllMtrs, PWMMode)
  CALL GoMtrs
  
  EXIT SUB


END SUB

SUB EnableAmpl (Value AS INTEGER, address AS INTEGER)

  IF address < 1 THEN EXIT SUB

  IF address > MaxMtr THEN    'group command
    MtrNum = 1   'use motor 1 value's
  ELSE
    MtrNum = address
  END IF

  IF Value THEN
     Cmd$ = CHR$(&H17) + CHR$(EnableAmp)
     glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) OR AmpEnabled
  ELSE
     Cmd$ = CHR$(&H17) + CHR$(0)
     glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) AND (NOT AmpEnabled)
  END IF
  
  SendCmd address, Cmd$

END SUB

FUNCTION Filter$ (FiltStr$)


  FOR X = 1 TO LEN(FiltStr$)  'only accept numbers and decimal point (.).
    G$ = MID$(FiltStr$, X, 1)
    IF (ASC(G$) >= 48) AND (ASC(G$) <= 57) OR (ASC(G$) = 46) THEN
      S$ = S$ + G$
    END IF
  NEXT

  Filter$ = S$

  EXIT FUNCTION
   
END FUNCTION

SUB FixSIOError
  
  'spit out a bunch of zeros
  FOR i = 1 TO 20
    CALL WriteToComm(PicPort, CHR$(0), BytesWritten, ECode)
    DelayX (1)
  NEXT

  'wait for any responses
  CALL DelayX(100)

  'flush the input buffer
  CALL FlushBuffers(PicPort, 0, ECode)
  
END SUB

SUB FlushKeys

   'keypad flush
   CALL ddelay(10): OUT CtrlReg, KeyStbOff'disable
   CALL ddelay(10): OUT CtrlReg, KeyStbOn 'enable
   CALL ddelay(10): OUT CtrlReg, KeyStbOff'disable


END SUB

	    FUNCTION FUsing$ (Amount$, Mask$)

END FUNCTION

FUNCTION GetAbsXCts&

    'x tell position command
    'CmdBuf(1).axcmd = &H100 + TP 'byte 1 command, byte 2 axis
    'CmdBuf(1).arg = 0     'bytes 3 through 6 contain parameter

    'x send command
    'Call Dc2Cmd(DC2B1, 1, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))

    'x position reply
    retnd1 = 1 'Dc2Rpy(DC2B1, VARPTR(RpyBuf(1)), VARSEG(RpyBuf(1)))


    GetAbsXCts = ABS(RpyBuf(1).Value)


END FUNCTION

FUNCTION GetAbsYCts&

    'CmdBuf(1).axcmd = TP: CmdBuf(1).arg = 0
    'Call Dc2Cmd(DC2B2, 1, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))

    retnd2 = 1 'Dc2Rpy(DC2B2, VARPTR(RpyBuf(1)), VARSEG(RpyBuf(1)))

    GetAbsYCts = ABS(RpyBuf(1).Value)

END FUNCTION

SUB GetAD

END SUB

FUNCTION GetData

  'Strobes datab to the lcd, also tests the busy flag
  OUT ProgReg, DataPortIn ' set data port as input
  OUT CtrlReg, &HE
  datab = INP(DataReg)
  OUT CtrlReg, &HC
  OUT ProgReg, DataPortOut ' set data port as output
  GetData = datab

END FUNCTION

FUNCTION GetDiskFile$

   CALL ClrLCD

   REDIM UTFile(100) AS STRING * 12
   'FSpec$ = "A:\*.*"
   FSpec$ = "C:\*.*"
   NumOfFiles = 0

   IF DirFirst%(FSpec$, 0) = 0 THEN ' found a file to match spec
     DO
       IF NumOfFiles < 100 THEN
	 NumOfFiles = NumOfFiles + 1
	 UTFile(NumOfFiles) = DirFileName$
       END IF
     LOOP UNTIL DirNext%               'try for next file
   END IF
 
   IF NumOfFiles = 0 THEN
     ERASE UTFile
     GetDiskFile$ = ""
     EXIT FUNCTION
   END IF
   
   ActiveFile = 1
   FileWindow = 1
   XOff = 5
   YOff = 2
   FilePointer = 1
   
   REDIM FileShown(10) AS STRING * 12

   FOR YY = 1 TO NumOfFiles 'put 10 files into window array
      IF YY > NumOfFiles OR YY > 10 THEN EXIT FOR  'check for < or > 10
      FileShown(YY) = UTFile(YY)
      CharString$ = FileShown(YY)
      SetCursor YOff + YY, XOff: PRINT " "; CharString$; " ";
   NEXT
     
   GOSUB FileHighColor

     DO
	K$ = DosInky
	 IF LEN(K$) THEN
	   IF LEN(K$) = 1 THEN  'Normal key
	     AscCode = ASC(LEFT$(K$, 1))
	     SELECT CASE AscCode
	       CASE 32 TO 125   'AlphaNum
	       CASE KeyBKSPC     'bkspc
	       CASE KeyTAB     'tab
	       CASE KeySPC    'space
	       CASE KeyEnter    'enter
		 GetDiskFile$ = FileShown(ActiveFile)
		 ExitCode = 1
	       CASE KeyEsc
		 GetDiskFile$ = CHR$(27) 'esc
		 ExitCode = 1
	     END SELECT
	   ELSEIF LEN(K$) = 2 THEN 'Extended key
	     ScanCode = ASC(RIGHT$(K$, 1))
	     SELECT CASE ScanCode
	       CASE KeyUP
		 GOSUB FileLowColor                                                   'remove highlight from current active file
		 IF ActiveFile - 1 >= 1 THEN                                          'active file > 1 within file window
		   ActiveFile = ActiveFile - 1                                       'increment 1 file below
		 ELSEIF FilePointer - 1 >= 1 THEN                                    'active file is @ first position in window
		   FilePointer = FilePointer - 1                                     'but virtual file position is > 1
		   IF FilePointer + 9 <= NumOfFiles THEN                                'is there 9 files above FilePointer
		     Start = FilePointer: Finish = FilePointer + 9                  'yes.. then
		     GOSUB ScrollFiles                                              'scroll files in window
		   ELSE                                                             'no.. then
		     Start = FilePointer: Finish = NumOfFiles                           'finish = last file
		     GOSUB ScrollFiles                                              'scroll files in window
		   END IF
		 END IF
		 GOSUB FileHighColor                                                  'add highlight to new active file
	       CASE KeyDN   'dn arrow
		 GOSUB FileLowColor
		 IF ActiveFile + 1 <= 10 AND FilePointer + ActiveFile <= NumOfFiles THEN
		   ActiveFile = ActiveFile + 1                                        'increment to next file in window
		 ELSEIF ActiveFile + 1 > 10 AND FilePointer + ActiveFile <= NumOfFiles THEN
		   FilePointer = FilePointer + 1                                      'active file is last in window
		   Start = FilePointer: Finish = FilePointer + 9                      'but not last in actual files
		   GOSUB ScrollFiles
		 END IF
		 GOSUB FileHighColor
	       CASE KeyLFT   'left arrow
	       CASE KeyRGT   'right arrow
	       CASE KeyPGUP   'pgup
	       CASE KeyPGDN   'pgdn
	       CASE KeyHOME   'home
	       CASE KeyEND   'end
	       CASE KeyDEL   'del
	     END SELECT
	   END IF
	 END IF
     LOOP UNTIL ExitCode
   
     ERASE UTFile
     ERASE FileShown

     EXIT FUNCTION

FileLowColor:
   CharString$ = FileShown(ActiveFile)
   SetCursor YOff + ActiveFile, XOff: PRINT " "; CharString$; " ";
   RETURN

FileHighColor:
   CharString$ = FileShown(ActiveFile)
   SetCursor YOff + ActiveFile, XOff: PRINT "["; CharString$; "]";
   RETURN

ScrollFiles:
   Ctr = 1
   FOR YY = Start TO Finish      'scroll files
     FileShown(Ctr) = UTFile(YY) 'get shown file from file array
     CharString$ = FileShown(Ctr)  'print new file
     SetCursor YOff + Ctr, XOff: PRINT " "; CharString$; " ";
     Ctr = Ctr + 1
   NEXT
   RETURN

END FUNCTION

FUNCTION GetKeys

 'get keypad press
 IF (INP(KeyReg) AND &H20) THEN  'keypress
   OUT CtrlReg, KeyStbOn         'enable read
   KBuff = INP(KeyReg)           'input data
   OUT CtrlReg, KeyStbOff        'disable read
   KBuff = KBuff AND &H1F        'remove data ready bit from byte
   GetKeys = KBuff + 1           'return keypress
 ELSE
   GetKeys = 0                   'return no keypress
 END IF

END FUNCTION

FUNCTION GetLcdColPos

  'REMED
  GetLcdColPos = POS(0)
  EXIT FUNCTION
  
  'Returns the present column position of the cursor
  OUT ProgReg, DataPortIn
  OUT CtrlReg, LcdPos
  Position = INP(DataReg)
  OUT CtrlReg, DataStbOff
  OUT ProgReg, DataPortOut

  Position = Position AND LcdAddress
  FOR i = 0 TO LcdLines - 1
   IF ((Position >= StartLPos(i)) AND (Position <= (StartLPos(i) + LcdColumns - 1))) THEN
      temp = (Position - StartLPos(i))
   END IF
  NEXT
  GetLcdColPos = temp

END FUNCTION

FUNCTION GetLcdRowPos
  
  'REMED
  GetLcdRowPos = CSRLIN
  EXIT FUNCTION

  'Returns the present row position of the cursor
  OUT ProgReg, DataPortIn
  OUT CtrlReg, LcdPos
  Position = INP(DataReg)
  OUT CtrlReg, DataStbOff
  OUT ProgReg, DataPortOut

  Position = Position AND LcdAddress
  temp = 0
  FOR i = 0 TO LcdLines - 1
   IF ((Position >= StartLPos(i)) AND (Position <= (StartLPos(i) + LcdColumns - 1))) THEN
     temp = i
   END IF
  NEXT
  GetLcdRowPos = temp

END FUNCTION

SUB GetScanCal

 SetCursor 1, 1
 WindowNum = 1

 DO
    SELECT CASE WindowNum
      CASE 1
	CALL PrintClrStr(1, 1, " X START: " + Scan.XLowSTR)
	CALL PrintClrStr(2, 1, "   X END: " + Scan.XHighSTR)
	CALL PrintClrStr(3, 1, " Y START: " + Scan.YLowSTR)
	CALL PrintClrStr(4, 1, "   Y END: " + Scan.YHighSTR)
	IF LastKey = DOWN THEN
	  SetCursor 1, 1
	ELSE  'LastKey = UP
	  SetCursor 4, 1
	END IF
	DO
	   SELECT CASE GetLcdRowPos
	     CASE 1   'XStart
	       PrintChar 1, 1, ">"
	       SetCursor 1, 17: temp$ = Scan.XLowSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.XLow = VAL(temp$)
		 Scan.XLowSTR = LEFT$(STR$(Scan.XLow) + SPC10, 10)
		 PFlag = 1
	       END IF
	       PrintChar 1, 1, " "
	       PrintStr 1, 17, Scan.XLowSTR
	       IF XCode = KeyUP THEN
		 SetCursor 1, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 2, 1
	       END IF
	     CASE 2  'XEnd
	       PrintChar 2, 1, ">"
	       SetCursor 2, 17: temp$ = Scan.XHighSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.XHigh = VAL(temp$)
		 Scan.XHighSTR = QStr$(Scan.XHigh, 10)
		 PFlag = 1
	       END IF
	       PrintChar 2, 1, " "
	       PrintStr 2, 17, Scan.XHighSTR
	       IF XCode = KeyUP THEN
		 SetCursor 1, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 3, 1
	       END IF
	     CASE 3 ' Y START
	       PrintChar 3, 1, ">"
	       SetCursor 3, 17: temp$ = Scan.YLowSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.YLow = VAL(temp$)
		 Scan.YLowSTR = QStr$(Scan.YLow, 10)
		 PFlag = 1
	       END IF
	       PrintChar 3, 1, " "
	       PrintStr 3, 17, Scan.YLowSTR
	       IF XCode = KeyUP THEN
		 SetCursor 2, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 4, 1
	       END IF
	     CASE 4 ' Y END
	       PrintChar 4, 1, ">"
	       SetCursor 4, 17: temp$ = Scan.YHighSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.YHigh = VAL(temp$)
		 Scan.YHighSTR = QStr$(Scan.YHigh, 10)
		 PFlag = 1
	       END IF
	       PrintChar 4, 1, " "
	       PrintStr 4, 17, Scan.YHighSTR
	       IF XCode = KeyUP THEN
		 SetCursor 3, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 WindowNum = 2
	       END IF
	   END SELECT
	LOOP WHILE WindowNum = 1 AND XCode <> KeyEsc
      CASE 2
	CALL PrintClrStr(1, 1, " X INDEX: " + Scan.XIndexSTR)
	CALL PrintClrStr(2, 1, " Y INDEX: " + Scan.YIndexSTR)
	CALL PrintClrStr(3, 1, " X SPEED: " + Scan.XSpeedSTR)
	CALL PrintClrStr(4, 1, " Y SPEED: " + Scan.YSpeedSTR)
	IF LastKey = DOWN THEN
	  SetCursor 1, 1
	ELSE  'LastKey = UP
	  SetCursor 4, 1
	END IF
	DO
	   SELECT CASE GetLcdRowPos
	     CASE 1 ' X INDEX
	       PrintChar 1, 1, ">"
	       SetCursor 1, 17: temp$ = Scan.XIndexSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.XIndex = VAL(temp$)
		 Scan.XIndexSTR = QStr$(Scan.XIndex, 10)
		 PFlag = 1
	       END IF
	       PrintChar 1, 1, " "
	       PrintStr 1, 17, Scan.XIndexSTR
	       IF XCode = KeyUP THEN
		 WindowNum = 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 2, 1
	       END IF
	     CASE 2 ' Y INDEX
	       PrintChar 2, 1, ">"
	       SetCursor 2, 17: temp$ = Scan.YIndexSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.YIndex = VAL(temp$)
		 Scan.YIndexSTR = QStr$(Scan.YIndex, 10)
		 PFlag = 1
	       END IF
	       PrintChar 2, 1, " "
	       PrintStr 2, 17, Scan.YIndexSTR
	       IF XCode = KeyUP THEN
		 SetCursor 1, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 3, 1
	       END IF
	     CASE 3
	       PrintChar 3, 1, ">"
	       SetCursor 3, 17: temp$ = Scan.XSpeedSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.XSpeed = VAL(temp$)
		 Scan.XSpeedSTR = QStr$(Scan.XSpeed, 10)
	       END IF
	       PrintChar 3, 1, " "
	       PrintStr 3, 17, Scan.XSpeedSTR
	       IF XCode = KeyUP THEN
		 SetCursor 2, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 4, 1
	       END IF
	     CASE 4
	       PrintChar 4, 1, ">"
	       SetCursor 4, 17: temp$ = Scan.YSpeedSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.YSpeed = VAL(temp$)
		 Scan.YSpeedSTR = QStr$(Scan.YSpeed, 10)
	       END IF
	       PrintChar 4, 1, " "
	       PrintStr 4, 17, Scan.YSpeedSTR
	       IF XCode = KeyUP THEN
		 SetCursor 3, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 WindowNum = 3
	       END IF
	   END SELECT
	LOOP WHILE WindowNum = 2 AND XCode <> KeyEsc
      CASE 3
	CALL PrintClrStr(1, 1, "   X POS: " + Scan.XPosStr)
	CALL PrintClrStr(2, 1, "   Y POS: " + Scan.YPosStr)
	CALL PrintClrStr(3, 1, " X CT/IN: " + Scan.XCtrSTR)
	CALL PrintClrStr(4, 1, " Y CT/IN: " + Scan.YCtrSTR)
	IF LastKey = DOWN THEN
	  SetCursor 1, 1
	ELSE  'LastKey = UP
	  SetCursor 4, 1
	END IF
	DO     'REMED add update to current X, Y position in loop
	   SELECT CASE GetLcdRowPos
	     CASE 1
	       PrintChar 1, 1, ">"
	       SetCursor 1, 17: temp$ = Scan.XPosStr
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.XPos = VAL(temp$)
		 Scan.XPosStr = QStr$(Scan.XPos, 10)
		 Scan.XOffset = Scan.XPos
		 CALL ResetPosition(Mtr1)
		 CALL ResetPosition(Mtr2)
	       END IF
	       PrintChar 1, 1, " "
	       PrintStr 1, 17, Scan.XPosStr
	       IF XCode = KeyUP THEN
		 WindowNum = 2
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 2, 1
	       END IF
	     CASE 2
	       PrintChar 2, 1, ">"
	       SetCursor 2, 17: temp$ = Scan.YPosStr
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.YPos = VAL(temp$)
		 Scan.YPosStr = QStr$(Scan.YPos, 10)
		 Scan.YOffset = Scan.YPos
		 CALL ResetPosition(Mtr3)
	       END IF
	       PrintChar 2, 1, " "
	       PrintStr 2, 17, Scan.YPosStr
	       IF XCode = KeyUP THEN
		 SetCursor 1, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 3, 1
	       END IF
	     CASE 3 '" X CT/IN: " + Scan.XCtrSTR)
	       PrintChar 3, 1, ">"
	       SetCursor 3, 17: temp$ = Scan.XCtrSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.XCtr = VAL(temp$)
		 Scan.XCtrSTR = QStr$(Scan.XCtr, 10)
		 PFlag = 1
	       END IF
	       PrintChar 3, 1, " "
	       PrintStr 3, 17, Scan.XCtrSTR
	       IF XCode = KeyUP THEN
		 SetCursor 2, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 SetCursor 4, 1
	       END IF
	     CASE 4
	       PrintChar 4, 1, ">"
	       SetCursor 4, 17: temp$ = Scan.YCtrSTR
	       CALL KEdit(temp$, XCode)  'get input
	       IF XCode = KeyEnter THEN
		 Scan.YCtr = VAL(temp$)
		 Scan.YCtrSTR = QStr$(Scan.YCtr, 10)
		 PFlag = 1
	       END IF
	       PrintChar 4, 1, " "
	       PrintStr 4, 17, Scan.YCtrSTR
	       IF XCode = KeyUP THEN
		 SetCursor 3, 1
	       ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		 WindowNum = 4
	       END IF
	   END SELECT
	LOOP WHILE WindowNum = 3 AND XCode <> KeyEsc
      CASE 4
	CALL PrintClrStr(1, 1, "   X +/-:*" + Scan.XPlusSTR)
	CALL PrintClrStr(2, 1, "   Y +/-:*" + Scan.YPlusSTR)
	CALL PrintClrStr(3, 1, "   INDEX:*" + Scan.IndexAxisSTR)
	CALL PrintClrStr(4, 1, " X ON/OF:*" + Scan.XEnableSTR)
	IF LastKey = DOWN THEN
	  SetCursor 1, 1
	ELSE  'LastKey = UP
	  SetCursor 4, 1
	END IF
	DO
	   SELECT CASE GetLcdRowPos
	     CASE 1   'no user input - picklist   (POSITIVE or NEGATIVE)
	       PrintChar 1, 1, ">"
	       PrintStr 1, 17, Scan.XPlusSTR
	       SetCursor 1, 1
	       DO
		 XCode = GetSelectKey
		 IF XCode = KeyUP THEN
		   WindowNum = 4
		   EXIT DO
		 ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		   PrintChar 1, 1, " "
		   SetCursor 2, 1
		   EXIT DO
		 ELSEIF XCode = KeyLFT THEN
		   Scan.XPlus = True
		   Scan.XPlusSTR = "POSITIVE  "
		   PFlag = 1
		   PrintStr 11, 17, Scan.XPlusSTR
		   SetCursor 11, 1
		 ELSEIF XCode = KeyRGT THEN
		   Scan.XPlus = False
		   Scan.XPlusSTR = "NEGATIVE  "
		   PFlag = 1
		   PrintStr 1, 17, Scan.XPlusSTR
		   SetCursor 1, 1
		 ELSEIF XCode = KeyEsc THEN
		   EXIT DO
		 END IF
	       LOOP
	     CASE 2   'no user input - picklist   (POSITIVE or NEGATIVE)
	       PrintChar 2, 1, ">"
	       PrintStr 2, 17, Scan.YPlusSTR
	       SetCursor 2, 1
	       DO
		 XCode = GetSelectKey
		 IF XCode = KeyUP THEN
		   PrintChar 2, 1, " "
		   SetCursor 1, 1
		   EXIT DO
		 ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		   PrintChar 2, 1, " "
		   SetCursor 3, 1
		   EXIT DO
		 ELSEIF XCode = KeyLFT THEN
		   Scan.YPlus = True
		   Scan.YPlusSTR = "POSITIVE  "
		   PFlag = 1
		   PrintStr 2, 17, Scan.YPlusSTR
		   SetCursor 2, 1
		 ELSEIF XCode = KeyRGT THEN
		   Scan.YPlus = False
		   Scan.YPlusSTR = "NEGATIVE  "
		   PFlag = 1
		   PrintStr 2, 17, Scan.YPlusSTR
		   SetCursor 2, 1
		 ELSEIF XCode = KeyEsc THEN
		   EXIT DO
		 END IF
	       LOOP
	     CASE 3   'no user input - picklist   (X or Y)
	       PrintChar 3, 1, ">"
	       PrintStr 3, 17, Scan.IndexAxisSTR
	       SetCursor 3, 1
	       DO
		 XCode = GetSelectKey
		 IF XCode = KeyUP THEN
		   PrintChar 3, 1, " "
		   SetCursor 2, 1
		   EXIT DO
		 ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		   PrintChar 3, 1, " "
		   SetCursor 4, 1
		   EXIT DO
		 ELSEIF XCode = KeyLFT THEN
		   Scan.IndexAxis = True
		   Scan.IndexAxisSTR = "X         "
		   PFlag = 1
		   PrintStr 3, 17, Scan.IndexAxisSTR
		   SetCursor 3, 1
		 ELSEIF XCode = KeyRGT THEN
		   Scan.IndexAxis = False
		   Scan.IndexAxisSTR = "Y         "
		   PFlag = 1
		   PrintStr 3, 17, Scan.IndexAxisSTR
		   SetCursor 3, 1
		 ELSEIF XCode = KeyEsc THEN
		   EXIT DO
		 END IF
	       LOOP
	     CASE 4   'no user input - picklist   (on or off)
	       PrintChar 4, 1, ">"
	       PrintStr 4, 17, Scan.XEnableSTR
	       SetCursor 4, 1
	       DO
		 XCode = GetSelectKey
		 IF XCode = KeyUP THEN
		   PrintChar 4, 1, " "
		   SetCursor 3, 1
		   EXIT DO
		 ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		   WindowNum = 5
		   EXIT DO
		 ELSEIF XCode = KeyLFT THEN
		   Scan.XEnable = True
		   Scan.XEnableSTR = "ON        "
		   CALL EnableAmpl(Scan.XEnable, Mtr1)
		   CALL EnableAmpl(Scan.XEnable, Mtr2)
		   PrintStr 4, 17, Scan.XEnableSTR
		   SetCursor 4, 1
		 ELSEIF XCode = KeyRGT THEN
		   Scan.XEnable = False
		   Scan.XEnableSTR = "OFF       "
		   CALL EnableAmpl(Scan.XEnable, Mtr1)
		   CALL EnableAmpl(Scan.XEnable, Mtr2)
		   PrintStr 4, 17, Scan.XEnableSTR
		   SetCursor 4, 1
		 ELSEIF XCode = KeyEsc THEN
		   EXIT DO
		 END IF
	       LOOP
	   END SELECT
	LOOP WHILE WindowNum = 4 AND XCode <> KeyEsc
      CASE 5
	CALL PrintClrStr(1, 1, " Y ON/OF:*" + Scan.YEnableSTR)
	CALL PrintClrStr(2, 1, "    AUTO:*" + Scan.StopChkSTR)
	CALL PrintClrStr(3, 1, "    STEP:*" + Scan.StepIndexSTR)
	IF LastKey = DOWN THEN
	  SetCursor 1, 1
	ELSE  'LastKey = UP
	  SetCursor 4, 1
	END IF
	DO
	   SELECT CASE GetLcdRowPos
	     CASE 1   'no user input - picklist   (on or off)
	       PrintChar 1, 1, ">"
	       PrintStr 1, 17, Scan.YEnableSTR
	       SetCursor 1, 1
	       DO
		 XCode = GetSelectKey
		 IF XCode = KeyUP THEN
		   WindowNum = 4
		   EXIT DO
		 ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		   PrintChar 1, 1, " "
		   SetCursor 2, 1
		   EXIT DO
		 ELSEIF XCode = KeyLFT THEN
		   Scan.YEnable = True
		   Scan.YEnableSTR = "ON        "
		   CALL EnableAmpl(Scan.YEnable, Mtr3)
		   CALL EnableAmpl(Scan.YEnable, Mtr3)
		   PrintStr 1, 17, Scan.YEnableSTR
		   SetCursor 1, 1
		 ELSEIF XCode = KeyRGT THEN
		   Scan.YEnable = False
		   Scan.YEnableSTR = "OFF       "
		   CALL EnableAmpl(Scan.YEnable, Mtr3)
		   CALL EnableAmpl(Scan.YEnable, Mtr3)
		   PrintStr 1, 17, Scan.YEnableSTR
		   SetCursor 1, 1
		 ELSEIF XCode = KeyEsc THEN
		   EXIT DO
		 END IF
	       LOOP
	     CASE 2   'no user input - picklist   (true or false)
	       PrintChar 2, 1, ">"
	       PrintStr 2, 17, Scan.StopChkSTR
	       SetCursor 2, 1
	       DO
		  XCode = GetSelectKey
		  IF XCode = KeyUP THEN
		    PrintChar 2, 1, " "
		    SetCursor 1, 1
		    EXIT DO
		  ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		    PrintChar 2, 1, " "
		    SetCursor 3, 1
		    EXIT DO
		  ELSEIF XCode = KeyLFT THEN
		    Scan.StopChk = True
		    Scan.StopChkSTR = "ON        "
		    PrintStr 2, 17, Scan.StopChkSTR
		    SetCursor 2, 1
		  ELSEIF XCode = KeyRGT THEN
		    Scan.StopChk = False
		    Scan.StopChkSTR = "OFF       "
		    PrintStr 2, 17, Scan.StopChkSTR
		    SetCursor 2, 1
		  ELSEIF XCode = KeyEsc THEN
		    EXIT DO
		  END IF
	       LOOP
	     CASE 3   'no user input - picklist   (On or Off)
	       PrintChar 3, 1, ">"
	       PrintStr 3, 17, Scan.StepIndexSTR
	       SetCursor 3, 1
	       DO
		  XCode = GetSelectKey
		  IF XCode = KeyUP THEN
		    PrintChar 3, 1, " "
		    SetCursor 2, 1
		    EXIT DO
		  ELSEIF XCode = KeyDN OR XCode = KeyEnter THEN
		    PrintChar 3, 1, " "
		    SetCursor 3, 1
		    EXIT DO
		  ELSEIF XCode = KeyLFT THEN
		    Scan.StepIndex = True
		    Scan.StepIndexSTR = "ON        "
		    PrintStr 3, 17, Scan.StepIndexSTR
		    SetCursor 3, 1
		  ELSEIF XCode = KeyRGT THEN
		    Scan.StepIndex = False
		    Scan.StepIndexSTR = "OFF       "
		    PrintStr 3, 17, Scan.StepIndexSTR
		    SetCursor 3, 1
		  ELSEIF XCode = KeyEsc THEN
		    EXIT DO
		  END IF
	       LOOP
	   END SELECT
	LOOP WHILE WindowNum = 4 AND XCode <> KeyEsc
    END SELECT
  LOOP UNTIL XCode = KeyEsc
  
  EXIT SUB

END SUB

FUNCTION GetSelectKey

      XCode = 0
	 
	 K$ = DosInky
	 IF LEN(K$) THEN
	   IF LEN(K$) = 1 THEN  'Normal key
	     ScanCode = ASC(RIGHT$(K$, 1))
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
	       CASE KeyLFT   'left arrow
		 XCode = KeyLFT
	       CASE KeyRGT   'right arrow
		 XCode = KeyRGT
	     END SELECT
	   END IF
	 END IF
      GetSelectKey = XCode

END FUNCTION

SUB GetStatus (Num)

   Cmd$ = CHR$(&HD)  'nop

   IF Num > MaxMtr THEN  'load status all motors
     FOR MtrNum = 1 TO MaxMtr
       SendCmd MtrNum, Cmd$
     NEXT
   ELSE                       'load status of one motor
     SendCmd Num, Cmd$
   END IF

END SUB

FUNCTION GetXCord& (Cts&)

  IF Scan.XPlus = True THEN 'X positive direction
    GetXCord& = Cts&
  ELSE
    GetXCord& = -Cts&   'X negative direction
  END IF

  EXIT FUNCTION

END FUNCTION

FUNCTION GetYCord& (Cts&)

  IF Scan.YPlus = True THEN 'Y positive cts
    GetYCord& = Cts&
  ELSE
    GetYCord& = -Cts&  'Y negative cts
  END IF
 
  EXIT FUNCTION

END FUNCTION

SUB GoMtrs

  Cmd$ = CHR$(&H5)
  SendCmd AllMtrs, Cmd$
  
END SUB

SUB InitDisplay

  'Sets up lcd display and 8255
  OUT ProgReg, DataPortOut  ' set up 8255
  CALL StrobeInstr(&H1)    ' clear display
  CALL StrobeInstr(&H38)   ' function set
				' b7,b6 = 0, b5 = 1
				' b4, DL = 1   (8 bit data)
				' b3, N = 1    (4 lines)
				' b2, F = 0    (5 x 7 char font)
				' b1,b0 = 0    (dont care)
  CALL StrobeInstr(&HE)    ' turn on display and cursor
				' b7-b4 = 0, b3 = 1
				' b2, D = 1    (display on)
				' b1, C = 1    (cursor on)
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

SUB InitializeAccel (address AS INTEGER)
 'set accel to ans intial value before enabling servo

 IF address < 1 THEN EXIT SUB

 IF address > MaxMtr THEN
   MtrNum = 1
 ELSE
   MtrNum = address
 END IF

 Cmd$ = CHR$(&H54) + CHR$(LoadAcc OR StartNow) + LongToStr(glo.CmdAccel(MtrNum))

 SendCmd address, Cmd$

END SUB

FUNCTION InitNetwork
  
  'Initial Varibles
  glo.SIOErrorMode = DoNothing
  glo.CumSIOError = 0
  glo.CkSumError = False
  glo.NumModules = 0
  glo.AmpQuery = True
  glo.PowerQuery = True

  FOR i = 1 TO 3
     glo.StatusDef(i) = 0
     glo.ModuleType(i) = 0
     glo.Position(i) = 0
     glo.CmdPosition(i) = 1000000
     glo.HomePosition(i) = 0
     glo.Velocity(i) = 0
     glo.CmdVelocity(i) = 2000000
     glo.CmdAccel(i) = 1000
     glo.CmdPWM(i) = 0
     glo.ADVal(i) = 0
     glo.Stat(i) = 0
     glo.AuxStat(i) = 0
     glo.Kp(i) = 400   '200
     glo.Ki(i) = 100   '0
     glo.Kd(i) = 4000 '2000
     glo.IL(i) = 10   '0
     glo.ol(i) = 255
     glo.CL(i) = 0
     glo.EL(i) = 16383
     glo.SRD(i) = 1
     glo.MiscMode(i) = PWMSelected
  NEXT i
  
  'start network
  CALL FlushBuffers(PicPort, 0, ECode)
  
  glo.CumSIOError = 0: CurNumError = 0: i = 1

  glo.SIOErrorMode = DoNothing


  'do twice to get controllers to respond in order
  Cmd$ = CHR$(&HF)  'reset all modules
  SendCmd AllMtrs, Cmd$
  CALL DelayX(100)
  
  Cmd$ = CHR$(&HF)  'reset all modules
  SendCmd AllMtrs, Cmd$
  CALL DelayX(100)
  
  FOR i = 1 TO 3

    Cmd$ = CHR$(&H21) + CHR$(i) + CHR$(&HFF) 'set address
    SendCmd 0, Cmd$

    IF glo.CumSIOError > CurNumError THEN
      EXIT FOR
    END IF

    'define what status is requested from PIC, set for device id only
    glo.StatusDef(i) = &H20
    Cmd$ = CHR$(&H12) + CHR$(glo.StatusDef(i)) '
    SendCmd i, Cmd$

    IF glo.ModuleType(i) = 0 THEN
      CALL InitializeAccel(i)
      CALL SetGain(i)
      glo.NumModules = glo.NumModules + 1
    ELSE
      EXIT FOR
    END IF
  
  NEXT
  
  IF glo.NumModules = 3 THEN 'passed
    glo.StatusDef(1) = &HF
    glo.StatusDef(2) = &HF
    glo.StatusDef(3) = &HF
    Cmd$ = CHR$(&H12) + CHR$(&HF) '
    SendCmd AllMtrs, Cmd$
    InitNetwork = True
    EXIT FUNCTION
  ELSE
    InitNetwork = False
    EXIT FUNCTION
  END IF

END FUNCTION

FUNCTION IntToStr$ (X AS INTEGER)

   B = X AND &HFF
   A = ((X AND &HFF00&) \ 256&) AND &HFF

   IntToStr = CHR$(B) + CHR$(A)

END FUNCTION

SUB KEdit (Edit$, ExitCode)

     'intialize values
     S$ = Edit$
     StrPos = 1 'cursur position within string
     Length = LEN(Edit$)

     X = POS(0): Y = CSRLIN

     OldX = X: OldY = Y

     ExitCode = 0

     

     DO
	K$ = DosInky
	 IF LEN(K$) THEN
	   IF LEN(K$) = 1 THEN  'Normal key
	     AscCode = ASC(LEFT$(K$, 1))
	     SELECT CASE AscCode
	       CASE 32 TO 125   'AlphaNum
		 MID$(S$, StrPos) = CHR$(AscCode)
		 IF StrPos < Length THEN
		   StrPos = StrPos + 1
		 END IF
	       CASE KeyBKSPC     'bkspc
		 IF StrPos > 1 THEN
		   StrPos = StrPos - 1
		   IF StrPos < Length THEN
		     MID$(S$, StrPos) = MID$(S$, StrPos + 1) + " "
		   END IF
		 END IF
	       CASE KeyTAB     'tab

	       CASE KeySPC    'space
		 IF StrPos < Length THEN
		   IF StrPos < Length THEN
		     S$ = S$
		     MID$(S$, StrPos) = " " + MID$(S$, StrPos)
		     IF LEN(S$) > Length THEN
		       S$ = LEFT$(S$, Length)
		     END IF
		   ELSE
		     MID$(S$, Length) = " "
		   END IF
		   StrPos = StrPos + 1:
		 ELSE
		   MID$(S$, StrPos) = " "
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
	       CASE KeyLFT   'left arrow
		 IF StrPos > 1 THEN
		   StrPos = StrPos - 1
		 END IF
	       CASE KeyRGT   'right arrow
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

	   SetCursor Y, X: PRINT S$;
	   SetCursor Y, X + (StrPos - 1)

	   

	 END IF
     
     LOOP UNTIL ExitCode

     SetCursor OldY, OldX  'put cursur back were it was

	    'update display region to cursor position

     Edit$ = S$         'pass edited string back


END SUB

FUNCTION Keydown

   'returns true only if user is holding down key that
   'was previously latched
   'Steps:
   '    1.) User presses key.
   '    2.) Latch detects keypress and doesn't allow new key scan
   '        until user releases key.
   '    3.) During this time we can tell if user released key.

   KeyState = INP(KeyReg) 'read keyboard port

   IF KeyState AND (NOT &H20) THEN  'key not released or not been pushed
     IF (KeyState AND &H40) THEN    'user holding Key down
       Keydown = -1
     ELSE : Keydown = 0
     END IF
   ELSE : Keydown = 0
   END IF

END FUNCTION

SUB LoadMotion (address AS INTEGER, Mode AS INTEGER)

 IF address < 1 THEN EXIT SUB

 IF address > MaxMtr THEN   'group command, use motor 1 values
   MtrNum = 1
 ELSE
   MtrNum = address
 END IF

 IF Mode = PWMMode THEN
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) OR PWMSelected
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) AND (NOT VelSelected)
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) AND (NOT PosSelected)

   IF glo.CmdPWM(MtrNum) > 0 THEN
     ControlByte = LoadPWM
     X = glo.CmdPWM(MtrNum)
   ELSE
     ControlByte = LoadPWM OR RevDir
     X = -(glo.CmdPWM(MtrNum))  'Neg of a Neg number = postive number
   END IF
   
   'Build the command string
   Cmd$ = CHR$(&H24) + CHR$(ControlByte) + CHR$(X)

 ELSEIF Mode = VelMode THEN
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) OR VelSelected
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) AND (NOT PWMSelected)
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) AND (NOT PosSelected)

   IF glo.CmdVelocity(MtrNum) > 0 THEN
     ControlByte = LoadVel OR LoadAcc OR PosMode OR VelMode
     x1& = glo.CmdVelocity(MtrNum)
   ELSE
     ControlByte = LoadVel OR LoadAcc OR PosMode OR VelMode OR RevDir
     x1& = -glo.CmdVelocity(MtrNum)
   END IF

   'build the command string
   Cmd$ = CHR$(&H94) + CHR$(ControlByte) + LongToStr(x1&) + LongToStr(glo.CmdAccel(MtrNum))

 ELSEIF Mode = PosMode THEN
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) OR PosSelected
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) AND (NOT VelSelected)
   glo.MiscMode(MtrNum) = glo.MiscMode(MtrNum) AND (NOT PWMSelected)

   ControlByte = LoadPos OR LoadVel OR LoadAcc OR PosMode

   'Build the command string
   'Cmd$ = CHR$(&HD4) + CHR$(ControlByte) + LongToStr(glo.CmdPosition(MtrNum))
   'Cmd$ = Cmd$ + LongToStr(glo.CmdVelocity(MtrNum)) + LongToStr(glo.CmdAccel(MtrNum))

   'Build the command string
   'changed to adjust for user counter offset
   IF MtrNum = 1 OR MtrNum = 2 THEN  'X Axis
     IF Scan.XPlus THEN     'X going positive direction
       ActPos& = glo.CmdPosition(MtrNum) - (Scan.XOffset * Scan.XCtr)
     ELSE
       ActPos& = glo.CmdPosition(MtrNum) + (Scan.XOffset * Scan.XCtr)
     END IF
   ELSEIF MtrNum = 3 THEN  'Y Axis
     IF Scan.YPlus THEN     'Y going positive direction
       ActPos& = glo.CmdPosition(MtrNum) - (Scan.YOffset * Scan.YCtr)
     ELSE
       ActPos& = glo.CmdPosition(MtrNum) + (Scan.YOffset * Scan.YCtr)
     END IF
   ELSE
     STOP  'change before beta out
   END IF

   Cmd$ = CHR$(&HD4) + CHR$(ControlByte) + LongToStr(ActPos&)
   Cmd$ = Cmd$ + LongToStr(glo.CmdVelocity(MtrNum)) + LongToStr(glo.CmdAccel(MtrNum))
 
 END IF

 SendCmd address, Cmd$

END SUB

FUNCTION LongToStr$ (X AS LONG)
  
   d = X AND &HFF
   c = (X AND &HFF00&) \ 256&
   B = (X AND &HFF0000) \ 65536
   A = ((X AND &HFF000000) \ 16777216) AND &HFF

   LongToStr = CHR$(d) + CHR$(c) + CHR$(B) + CHR$(A)


END FUNCTION

SUB MotorXGo (dir)
    
    IF dir = POSDIR THEN
       'define direction (+)
       'CmdBuf(1).axcmd = &H100 + MR: CmdBuf(1).arg = 2200000
       'CmdBuf(2).axcmd = &H200 + MR: CmdBuf(2).arg = 2200000
     ELSE
       'define direction (-)
       'CmdBuf(1).axcmd = &H100 + MR: CmdBuf(1).arg = -2200000
       'CmdBuf(2).axcmd = &H200 + MR: CmdBuf(2).arg = -2200000
    END IF

    'send go command to
    'Call Dc2Cmd(DC2B1, 2, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))
    
END SUB

SUB MotorXMove (XCts&)

    'CmdBuf(1).axcmd = &H100 + MA: CmdBuf(1).arg = GetXCord(XCts&)
    'CmdBuf(2).axcmd = &H200 + MA: CmdBuf(2).arg = GetXCord(XCts&)
    'Call Dc2Cmd(DC2B1, 2, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))

END SUB

SUB MotorXStop

    'define command
    'CmdBuf(1).axcmd = &H100 + AB: CmdBuf(1).arg = 0
    'CmdBuf(2).axcmd = &H200 + AB: CmdBuf(2).arg = 0

    'send  command to
    'Call Dc2Cmd(DC2B1, 2, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))

END SUB

SUB MotorYGo (dir)

   IF dir = POSDIR THEN
      'define go command
      'CmdBuf(1).axcmd = &H100 + MR   'byte 1 command, byte 2 axis
      'CmdBuf(1).arg = 300000          'bytes 3 through 6 contain parameter
    ELSE
      'CmdBuf(1).axcmd = &H100 + MR   'byte 1 command, byte 2 axis
      'CmdBuf(1).arg = -300000          'bytes 3 through 6 contain parameter
   END IF

   'send command to
    'Call Dc2Cmd(DC2B2, 1, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))

END SUB

SUB MotorYMove (YCts&)
    
    'CmdBuf(1).axcmd = &H100 + MA: CmdBuf(1).arg = GetYCord(YCts&)
    'Call Dc2Cmd(DC2B2, 1, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))

END SUB

SUB MotorYStop

    'define  command
    'CmdBuf(1).axcmd = &H100 + AB   'byte 1 command, byte 2 axis
    'CmdBuf(1).arg = 0              'bytes 3 through 6 contain parameter

    'send  command to
    'Call Dc2Cmd(DC2B2, 1, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1)))


END SUB

SUB MtrOff (address AS INTEGER)

 IF address < 1 THEN EXIT SUB

 Cmd$ = CHR$(&H17) + CHR$(MotorOff)

 SendCmd address, Cmd$

END SUB

FUNCTION OpenComPorts

   NumPorts = 1

   RecvSize = 2048
   XmitSize = 2048
   

   PortSeg = VARSEG(PicPort)
   PortOff = VARPTR(PicPort)
   RecvSeg = VARSEG(RecvSize)
   RecvOff = VARPTR(RecvSize)
   XmitSeg = VARSEG(XmitSize)
   XmitOff = VARPTR(XmitSize)

   CALL CalcRequiredMem(PortSeg, PortOff, RecvSeg, RecvOff, XmitSeg, XmitOff, NumPorts, MemSize, ECode)
   IF ECode THEN
     OpenComPorts = False
     EXIT FUNCTION
   END IF

   FarHeapSize& = SETMEM(-(MemSize))  'take some far heap

   CALL InitCommBuffers(ECode)
   IF ECode THEN
     FarHeapSize& = SETMEM(MemSize)   'give far heap back to system
     OpenComPorts = False
     EXIT FUNCTION
   END IF
   
   ' Set the flow control to no flow control
     CALL SetFlowControl(PicPort, 3, 3, 0, 0, 0, 0, ECode)
     IF ECode THEN
       CALL DeleteCommBuffers(ECode)
       FarHeapSize& = SETMEM(MemSize)   'give far heap back to system
       OpenComPorts = False
       EXIT FUNCTION
     END IF
   
   

   DataBits = 8: Parity = 4: StopBits = 1:

   CALL OpenCommPort(PicPort, PICBaud, DataBits, Parity, StopBits, ECode)
   IF ECode THEN
     CALL DeleteCommBuffers(ECode)
     FarHeapSize& = SETMEM(MemSize)   'give far heap back to system
     OpenComPorts = False
     EXIT FUNCTION
   END IF

   CALL FlushBuffers(PicPort, 0, ECode)
   
   OpenComPorts = True

   EXIT FUNCTION

END FUNCTION

SUB PrintC (PChar$, X, Y, f, h)

END SUB

SUB PrintChar (Y, X, Char$)

 'REMED
 LOCATE Y, X: PRINT Char$;
 EXIT SUB

 CALL SetCursor(Y, X) 'position cursor
 CALL StrobeData(ASC(Char$))

END SUB

SUB PrintClrStr (YY, XX, text$)

      'REMED

      LOCATE Y, 1: PRINT SPACE$(80);
      LOCATE Y, X: PRINT text$;
      EXIT SUB

	X = XX: Y = YY

	CALL SetCursor(Y, X) 'position cursor

	FOR i = 1 TO LEN(text$)
	  IF X < LcdColumns THEN
	    CALL StrobeData(ASC(MID$(text$, i, 1))) 'print the char
	    X = X + 1
	  END IF
	NEXT

	WHILE X < LcdColumns' clear rest of line
	  CALL StrobeData(32) 'print spaces
	  X = X + 1
	WEND

END SUB

SUB PrintPos

    Fore = 15: Back = 0:
    
    CALL GetStatus(&H255)   'get status of all motors (3)
    
    Scan.XCts = ABS(glo.CmdPosition(Mtr1))
    Scan.YCts = ABS(glo.CmdPosition(Mtr3))
    
    Scan.XPos = CLNG((Scan.XCts / Scan.XCtr) * 100) / 100
    Scan.YPos = CLNG((Scan.YCts / Scan.YCtr) * 100) / 100
    
    Scan.XPosStr = LEFT$(STR$(Scan.XPos) + "        ", 10)
    Scan.YPosStr = LEFT$(STR$(Scan.YPos) + "        ", 10)

    LOCATE 10, 1: PRINT Scan.XPosStr
    LOCATE 11, 1: PRINT Scan.YPosStr

    'CALL PrintC(PChar$, ScanRow(11), ScanColNum(1), Fore, Back)
    'CALL PrintC(PChar$, ScanRow(12), ScanColNum(1), Fore, Back)

END SUB

SUB PrintStr (Y, X, text$)

	'REMED
	LOCATE Y, X: PRINT text$;
	EXIT SUB


	CALL SetCursor(Y, X) 'position cursor

	FOR i = 1 TO LEN(text$)
	  IF X <= LcdColumns THEN
	    CALL StrobeData(ASC(MID$(text$, i, 1))) 'print the char
	    X = X + 1
	  END IF
	NEXT

END SUB

SUB ProfileScan
   
   IF Scan.XHigh < Scan.XLow THEN SWAP Scan.YHigh, Scan.YLow
   Scan.XStartCts = CLNG(Scan.XLow * Scan.XCtr)
   Scan.XEndCts = CLNG(Scan.XHigh * Scan.XCtr)
   
   IF Scan.YHigh < Scan.YLow THEN SWAP Scan.YHigh, Scan.YLow
   Scan.YStartCts = CLNG(Scan.YLow * Scan.YCtr)
   Scan.YEndCts = CLNG(Scan.YHigh * Scan.YCtr)
   
   Scan.XIndexCts = CLNG(Scan.XCtr / Scan.XIndex)
   Scan.YIndexCts = CLNG(Scan.YCtr / Scan.YIndex)

   Scan.XDataStart = CLNG(Scan.XStartCts / Scan.XIndexCts)
   Scan.XDataEnd = CLNG(Scan.XEndCts / Scan.XIndexCts)

   Scan.YDataStart = CLNG(Scan.YStartCts / Scan.YIndexCts)
   Scan.YDataEnd = CLNG(Scan.YEndCts / Scan.YIndexCts)

   Scan.IndexCt = Scan.XDataStart

   IF Scan.IndexAxis THEN
      Scan.LastYIndex = Scan.YDataEnd
      Scan.IndexInc = 1
   ELSE
      Scan.LastXIndex = Scan.XDataEnd
      Scan.IndexInc = 1
   END IF

   EXIT SUB


END SUB

SUB ProgramExit

 Cmd$ = CHR$(&HF)
 SendCmd AllMtrs, Cmd$

 FOR tt! = 1 TO 1000: NEXT  'delay

 END

END SUB

SUB PWMTable
  
  'A/D #1 Speed & Forward/Reverse control
  ' 0=-255, 123 to 131=0, 255 = 255
  '9 positions (4 each side of TDC are 0, make easier to set motors to 0
  'full ccw = -255, full cw = +255
  FOR X = 0 TO 123
    PwmOut(123 - X) = (X / 123) * -255
  NEXT
  FOR X = 131 TO 255
    PwmOut(X) = ((X - 131) / 124) * 255
  NEXT

  'A/D #2 Left/Right Control
  'CCW (LEFT): 0-123 = -100 to 100
  FOR X = 0 TO 61
    PwmOff(61 - X) = (X / 61) * -100
  NEXT
  FOR X = 62 TO 123
    PwmOff(X) = ((X - 62) / 61) * 100
  NEXT

  'CW (Right): 131-255 = 100 to -100
  FOR X = 131 TO 192
    PwmOff(X) = 100 - (((X - 131) / 61) * 100)
  NEXT
  FOR X = 193 TO 255
    PwmOff(X) = ((X - 193) / 62) * -100
  NEXT

  'Center: 124-130 = 100
  FOR X = 124 TO 130
    PwmOff(X) = 100
  NEXT

END SUB

FUNCTION QPRound$ (BYVAL Amount#, BYVAL Places%) STATIC
'External routines required:  ASCII%
'                             FUsing

    Amount$ = STR$(Amount#)                     'first convert into a string

    Lead = INSTR(LTRIM$(Amount$), ".")  'get the number of leading digits
    IF Lead > 1 THEN Lead = Lead - 1
    IF Lead = 0 THEN Lead = LEN(LTRIM$(Amount$))

    Dec$ = MID$(".", ABS(Places% = 0) + 1)      'make a "." if needed
    Plus$ = MID$("+", SGN(Amount#) + 2)         'make a "+" if needed
    Mask$ = Plus$ + STRING$(Lead% + 1, "#") + Dec$ + STRING$(Places%, "#") '+1
    Mask$ = FUsing$(Amount$, Mask$)             'let Chris do the dirty work

    IF Ascii%(Mask$) = 48 THEN                  'if there's a leading zero
       Mask$ = MID$(Mask$, 2)                   'strip it
    END IF

    QPRound$ = LTRIM$(Mask$)                    'assign the function

END FUNCTION

FUNCTION QStr$ (BYVAL Amount#, BYVAL Places) STATIC

    QStr$ = LEFT$(LTRIM$(STR$(Amount)) + SPACE$(Places), Places)

END FUNCTION

SUB ReSetMotors

  IF Scan.IndexAxis THEN 'Y Index Scan
    IF Scan.LastYIndex = NEGDIR THEN
      IF Scan.YPlus = True THEN 'scanning positive direction
	Scan.IndexInc = -1
	IndexSet = 1
      ELSE
	Scan.IndexInc = 1
	IndexSet = -1
      END IF
    ELSE   'POSDIR
      IF Scan.YPlus = True THEN 'scanning positive direction
	Scan.IndexInc = 1
	IndexSet = -1
      ELSE
	Scan.IndexInc = -1
	IndexSet = 1
      END IF
    END IF

    LoopPos = CLNG(GetAbsYCts / Scan.YIndexCts) + IndexSet
    SELECT CASE LoopPos
      CASE IS > Scan.YDataEnd: Scan.IndexCt = Scan.YDataEnd
      CASE IS < Scan.YDataStart: Scan.IndexCt = Scan.YDataStart
      CASE ELSE: Scan.IndexCt = LoopPos
    END SELECT

  ELSE  ' X Index Scan
    IF Scan.LastXIndex = NEGDIR THEN
      IF Scan.XPlus = True THEN 'scanning positive direction
	Scan.IndexInc = -1
	IndexSet = 1
      ELSE
	Scan.IndexInc = 1
	IndexSet = -1
      END IF
    ELSE   'POSDIR
      IF Scan.XPlus = True THEN 'scanning positive direction
	Scan.IndexInc = 1
	IndexSet = -1
      ELSE
	Scan.IndexInc = -1
	IndexSet = 1
      END IF
    END IF

    LoopPos = CLNG(GetAbsXCts / Scan.XIndexCts) + IndexSet
    SELECT CASE LoopPos
      CASE IS > Scan.XDataEnd: Scan.IndexCt = Scan.XDataEnd
      CASE IS < Scan.XDataStart: Scan.IndexCt = Scan.XDataStart
      CASE ELSE: Scan.IndexCt = LoopPos
    END SELECT

  END IF

END SUB

SUB ResetPosition (address AS INTEGER)

 IF address < 1 THEN EXIT SUB

 Cmd$ = CHR$(&H0)

 SendCmd address, Cmd$
 
END SUB

FUNCTION RoundOff# (BYVAL Value#, BYVAL Digits)

   Mult& = 10 ^ Digits
   RoundOff# = FIX((Mult& * Value#) + (SGN(Value#)) * .5) / Mult&

END FUNCTION

SUB SendCmd (address AS INTEGER, CmdString AS STRING)

  Cksum = address

  FOR i = 1 TO LEN(CmdString)
     Cksum = Cksum + ASC(MID$(CmdString, i, 1))
  NEXT i
  Cksum = Cksum AND 255

  'Send the command
  '** add for probas com routine
  SendStr$ = CHR$(&HAA) + CHR$(address) + CmdString + CHR$(Cksum)

  strlen = LEN(SendStr$)

  
  'flush the com buffer
  CALL FlushBuffers(PicPort, 0, ECode)
  
  CALL WriteToComm(PicPort, SendStr$, BytesWritten, ECode)
  
  'start a timeout timer
  TimeOutTime& = TIMER + 2
  '***************** ADD check for rollover @ midnight
  
  DO
    CALL GetCharsInBuffer(PicPort, RecQue, XmtQue, ECode)
  LOOP UNTIL (XmtQue = XmitSize(PicPort) - 1) OR (TIMER > TimeOutTime&)
  
  CALL DelayX(WaitX)
  
  'no reply if group command
  IF address = &HFF THEN
    GOTO GrpCmdExit
  END IF

  'Get new address value if change address command
  IF ASC(MID$(CmdString, 1, 1)) = &H21 THEN address = ASC(MID$(CmdString, 2, 1))

  IF address = 0 THEN address = 1 'for testing on axis 0

  'Get the status byte
  IF SIOGetByte(glo.Stat(address), 1) = False THEN
    SetCursor 23, 1: PRINT "No Status byte";
    FixSIOError
    CALL DelayX(500)
    SetCursor 23, 1: PRINT "                      ";  'REMED
    '**** add counter for number of no responses
    'in case of disconnect/power lose
    EXIT SUB
  END IF
    '***** clear no response counter here
  
  Cksum = glo.Stat(address)

  'Get position data
  'IF glo.StatusDef(address) AND SendPos THEN
  '  IF SIOGetByte(d, 1) = False THEN GOTO SendCmdExit
  '  IF SIOGetByte(c, 1) = False THEN GOTO SendCmdExit
  '  IF SIOGetByte(B, 1) = False THEN GOTO SendCmdExit
  '  IF SIOGetByte(A, 1) = False THEN GOTO SendCmdExit
  '  Cksum = Cksum + A + B + c + d
  '  glo.position(address) = CharsToLong(A, B, c, d)
  'END IF

  'Get position data
  'changed to adjust for user counter offset
  IF glo.StatusDef(address) AND SendPos THEN
    IF SIOGetByte(d, 1) = False THEN GOTO SendCmdExit
    IF SIOGetByte(c, 1) = False THEN GOTO SendCmdExit
    IF SIOGetByte(B, 1) = False THEN GOTO SendCmdExit
    IF SIOGetByte(A, 1) = False THEN GOTO SendCmdExit
    Cksum = Cksum + A + B + c + d
    ActPos& = CharsToLong(A, B, c, d)
    IF address = 1 OR address = 2 THEN   'X Axis
      IF Scan.XPlus THEN     'X going positive direction
	glo.Position(address) = ActPos& + (Scan.XOffset * Scan.XCtr)
      ELSE                   'X going negative direction
	glo.Position(address) = ActPos& - (Scan.XOffset * Scan.XCtr)
      END IF
    ELSEIF address = 3 THEN  'Y Axis
      IF Scan.YPlus THEN     'Y going positive direction
	glo.Position(address) = ActPos& + (Scan.YOffset * Scan.YCtr)
      ELSE                   'Y going negative direction
	glo.Position(address) = ActPos& - (Scan.YOffset * Scan.YCtr)
      END IF
    ELSE
      STOP  'REMED change before beta out
    END IF
  END IF
  
  'Get the A/D value
  IF glo.StatusDef(address) AND SendAD THEN
    IF SIOGetByte(glo.ADVal(address), 1) = False THEN GOTO SendCmdExit
    Cksum = Cksum + glo.ADVal(address)
  END IF

  'Get velocity data
  IF glo.StatusDef(address) AND SendVel THEN
     IF SIOGetByte(B, 1) = False THEN GOTO SendCmdExit
     IF SIOGetByte(A, 1) = False THEN GOTO SendCmdExit
     Cksum = Cksum + A + B
     glo.Velocity(address) = CharsToInt(A, B)
  END IF

  'Get the AUX status value
  IF glo.StatusDef(address) AND SendAux THEN
    IF SIOGetByte(glo.AuxStat(address), 1) = False THEN GOTO SendCmdExit
    Cksum = Cksum + glo.AuxStat(address)
  END IF

  'Get home position data
  IF glo.StatusDef(address) AND SendHome THEN
    IF SIOGetByte(d, 1) = False THEN GOTO SendCmdExit
    IF SIOGetByte(c, 1) = False THEN GOTO SendCmdExit
    IF SIOGetByte(B, 1) = False THEN GOTO SendCmdExit
    IF SIOGetByte(A, 1) = False THEN GOTO SendCmdExit
    Cksum = Cksum + A + B + c + d
    glo.HomePosition(address) = CharsToLong(A, B, c, d)
  END IF
    
  'Get the module type and version
  IF glo.StatusDef(address) AND SendID THEN
    IF SIOGetByte(glo.ModuleType(address), 1) = False THEN GOTO SendCmdExit
    IF SIOGetByte(glo.ModuleVer(address), 1) = False THEN GOTO SendCmdExit
    Cksum = Cksum + glo.ModuleType(address) + glo.ModuleVer(address)
  END IF

  IF SIOGetByte(CCksum, 1) = False THEN
    SetCursor 23, 1: PRINT "No Cksum byte";
    FixSIOError
    CALL DelayX(500)
    SetCursor 23, 1: PRINT "                      ";  'REMED
    EXIT SUB
  END IF

  glo.CkSumError = False

  IF (Cksum AND 255) <> CCksum THEN
    SetCursor 23, 1: PRINT "Checksum error!";  'REMED
    FixSIOError
    CALL DelayX(500)
    SetCursor 23, 1: PRINT "                      ";  'REMED
    glo.CumSIOError = glo.CumSIOError + 1
    glo.CkSumError = True
  END IF


  EXIT SUB

SendCmdExit:
    SetCursor 23, 1: PRINT "No Return Byte";  'REMED
    FixSIOError
    CALL DelayX(500)
    SetCursor 23, 1: PRINT "                      ";  'REMED

GrpCmdExit:

END SUB

SUB SetCursor (row, col)

  'REMED for PC
  LOCATE row, col
  EXIT SUB


  c = col - 1: r = row - 1

  'Sets lcd position to line 'row', column 'col' (if in lcd range)
  IF ((c < LcdColumns) AND (r < LcdLines)) THEN
    CALL StrobeInstr((LcdAddrSet OR StartLPos(r)) + c)
  END IF
	     
END SUB

SUB SetForAuto

  IF Scan.XSpeed = 0 THEN Scan.XSpeed = 2
  IF Scan.YSpeed = 0 THEN Scan.YSpeed = 1

  'determine cts/millisec needed based on inches travel/sec
  XVel& = Scan.XSpeed * Scan.XCtr * .001 * 65536
  YVel& = Scan.YSpeed * Scan.YCtr * .001 * 65536

  'set length of time in seconds to reach specified maximum velocity
  XTime! = .4: YTime! = .1

  'x & y acceleration, deceleration  calc's
  XCel& = (Scan.XSpeed / XTime!) * Scan.XCtr * .001 * .001 * 65536
  YCel& = (Scan.YSpeed / YTime!) * Scan.YCtr * .001 * .001 * 65536

  'x motor's celleration's
  'CmdBuf(1).axcmd = &H100 + DS: CmdBuf(1).arg = XCel&
  'CmdBuf(2).axcmd = &H100 + SA: CmdBuf(2).arg = XCel&

  'x motor's velocity's
  'CmdBuf(3).axcmd = &H100 + SV: CmdBuf(3).arg = XVel&

  'x motor's error setting's
  'CmdBuf(4).axcmd = &H100 + SE: CmdBuf(4).arg = 32767

  'x integral gain
  'CmdBuf(5).axcmd = &H100 + SI: CmdBuf(5).arg = 7

  'x integral limit
  'CmdBuf(6).axcmd = &H100 + IL: CmdBuf(6).arg = 70

  'x proportional gain
  'CmdBuf(7).axcmd = &H100 + SG: CmdBuf(7).arg = 280

  'x derivative gain
  'CmdBuf(8).axcmd = &H100 + SD: CmdBuf(8).arg = 280

  'x torque limit
  'CmdBuf(9).axcmd = &H100 + SQ: CmdBuf(9).arg = 2046
  
  'x motor's celleration's
  'CmdBuf(10).axcmd = &H200 + DS: CmdBuf(10).arg = XCel&
  'CmdBuf(11).axcmd = &H200 + SA: CmdBuf(11).arg = XCel&

  'x motor's velocity's
  'CmdBuf(12).axcmd = &H200 + SV: CmdBuf(12).arg = XVel&

  'x motor's error setting's
  'CmdBuf(13).axcmd = &H200 + SE: CmdBuf(13).arg = 32767

  'x integral gain
  'CmdBuf(14).axcmd = &H200 + SI: CmdBuf(14).arg = 7

  'x integral limit
  'CmdBuf(15).axcmd = &H200 + IL: CmdBuf(15).arg = 70

  'x proportional gain
  'CmdBuf(16).axcmd = &H200 + SG: CmdBuf(16).arg = 280

  'x derivative gain
  'CmdBuf(17).axcmd = &H200 + SD: CmdBuf(17).arg = 280

  'x torque limit
  'CmdBuf(18).axcmd = &H200 + SQ: CmdBuf(18).arg = 2046
  
  'turn motors 1-2 on
  ''CmdBuf(19).axcmd = &H100 + MN: CmdBuf(19).arg = 0
  'CmdBuf(20).axcmd = &H200 + MN: CmdBuf(20).arg = 0
  'PChar$ = "ON"
  'CALL PrintC(PChar$, ScanRow(15), ScanColNum(1), 15, 0)

  'Call Dc2Cmd(DC2B1, 18, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1))) 'send command

  'y motor's celleration's
  'CmdBuf(1).axcmd = &H100 + DS: CmdBuf(1).arg = YCel&
  'CmdBuf(2).axcmd = &H100 + SA: CmdBuf(2).arg = YCel&

  'y motor's velocity's
  'CmdBuf(3).axcmd = &H100 + SV: CmdBuf(3).arg = YVel&

  'y motor's error setting's
  'CmdBuf(4).axcmd = &H100 + SE: CmdBuf(4).arg = 32767

  'y integral gain
  'CmdBuf(5).axcmd = &H100 + SI: CmdBuf(5).arg = 24

  'y integral limit
  'CmdBuf(6).axcmd = &H100 + IL: CmdBuf(6).arg = 240

  'y proportional gain
  'CmdBuf(7).axcmd = &H100 + SG: CmdBuf(7).arg = 900

  'y derivative gain
  'CmdBuf(8).axcmd = &H100 + SD: CmdBuf(8).arg = 1200

  'y torque limit
  'CmdBuf(9).axcmd = &H100 + SQ: CmdBuf(9).arg = 2046
  
  'turn motor 1  on (Y-Axis)
  ''CmdBuf(10).axcmd = &H100 + MN: CmdBuf(10).arg = 0
  'PChar$ = "ON"
  'CALL PrintC(PChar$, ScanRow(16), ScanColNum(1), 15, 0)

  'Call Dc2Cmd(DC2B2, 9, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1))) 'send command

END SUB

SUB SetForManual

  'determine cts/millisec needed based on inches travel/sec
  XVel& = 2& * Scan.XCtr * .001 * 65536
  YVel& = 2& * Scan.YCtr * .001 * 65536

  'set length of time in seconds to reach specified maximum velocity
  XTime! = .3: YTime! = .3

  'x & y acceleration, deceleration  calc's
  XCel& = (1& / XTime!) * Scan.XCtr * .001 * .001 * 65536
  YCel& = (2& / YTime!) * Scan.YCtr * .001 * .001 * 65536

  'x motor's celleration's
  'CmdBuf(1).axcmd = &H100 + DS: CmdBuf(1).arg = XCel&
  'CmdBuf(2).axcmd = &H100 + SA: CmdBuf(2).arg = XCel&

  'x motor's velocity's
  'CmdBuf(3).axcmd = &H100 + SV: CmdBuf(3).arg = XVel&

  'x motor's error setting's
  'CmdBuf(4).axcmd = &H100 + SE: CmdBuf(4).arg = 32767

  'x integral limit
  'CmdBuf(5).axcmd = &H100 + IL: CmdBuf(5).arg = 50

  'x integral gain
  'CmdBuf(6).axcmd = &H100 + SI: CmdBuf(6).arg = 7


  'x proportional gain
  'CmdBuf(7).axcmd = &H100 + SG: CmdBuf(7).arg = 200  '180

  'x derivative gain
  'CmdBuf(8).axcmd = &H100 + SD: CmdBuf(8).arg = 740

  'x torque limit
  'CmdBuf(9).axcmd = &H100 + SQ: CmdBuf(9).arg = 2046

  'x motor's celleration's
  'CmdBuf(10).axcmd = &H200 + DS: CmdBuf(10).arg = XCel&
  'CmdBuf(11).axcmd = &H200 + SA: CmdBuf(11).arg = XCel&

  'x motor's velocity's
  'CmdBuf(12).axcmd = &H200 + SV: CmdBuf(12).arg = XVel&

  'x motor's error setting's
  'CmdBuf(13).axcmd = &H200 + SE: CmdBuf(13).arg = 32767


  'x integral limit
  'CmdBuf(14).axcmd = &H200 + IL: CmdBuf(14).arg = 50

  'x integral gain
  'CmdBuf(15).axcmd = &H200 + SI: CmdBuf(15).arg = 7
  
  'x proportional gain
  'CmdBuf(16).axcmd = &H200 + SG: CmdBuf(16).arg = 200 '180

  'x derivative gain
  'CmdBuf(17).axcmd = &H200 + SD: CmdBuf(17).arg = 740 '640

  'x torque limit
  'CmdBuf(18).axcmd = &H200 + SQ: CmdBuf(18).arg = 2046

  'turn motors 1-2 on
  ''CmdBuf(19).axcmd = &H100 + MN: CmdBuf(19).arg = 0
  ''CmdBuf(20).axcmd = &H200 + MN: CmdBuf(20).arg = 0
  'PChar$ = "ON"
  'CALL PrintC(PChar$, ScanRow(15), ScanColNum(1), 15, 0)

  'Call Dc2Cmd(DC2B1, 18, VARPTR('CmdBuf(1)), VARSEG('CmdBuf(1))) 'send command


  'y motor's celleration's
  'CmdBuf(1).axcmd = &H100 + DS: CmdBuf(1).arg = YCel&
  'CmdBuf(2).axcmd = &H100 + SA: CmdBuf(2).arg = YCel&

  'y motor's velocity's
  'CmdBuf(3).axcmd = &H100 + SV: CmdBuf(3).arg = YVel&

  'y motor's error setting's
  'CmdBuf(4).axcmd = &H100 + SE: CmdBuf(4).arg = 32767

  'y integral limit
  'CmdBuf(5).axcmd = &H100 + IL: CmdBuf(5).arg = 60

  'y integral gain
  'CmdBuf(6).axcmd = &H100 + SI: CmdBuf(6).arg = 6


  'y proportional gain
  'CmdBuf(7).axcmd = &H100 + SG: CmdBuf(7).arg = 240

  'y derivative gain
  'CmdBuf(8).axcmd = &H100 + SD: CmdBuf(8).arg = 280

  'x torque limit
  'CmdBuf(9).axcmd = &H100 + SQ: CmdBuf(9).arg = 2046

  'turn motor 1 on (Y-Axis)
  'CmdBuf(10).axcmd = &H100 + MN: CmdBuf(10).arg = 0
  'PChar$ = "ON"
  'CALL PrintC(PChar$, ScanRow(16), ScanColNum(1), 15, 0)

  'Call Dc2Cmd(DC2B2, 9, VARPTR(CmdBuf(1)), VARSEG(CmdBuf(1))) 'send command

END SUB

SUB SetGain (address AS INTEGER)

   IF address < 1 THEN EXIT SUB
   
   IF address > MaxMtr THEN  'global
      MtrNum = 1
   ELSE
      MtrNum = address
   END IF

   X = glo.CL(MtrNum)
   IF X < 1 THEN
     X = (-X) AND 254
   ELSE
     X = X OR 1
   END IF

   Cmd$ = CHR$(&HD6) + IntToStr(glo.Kp(MtrNum)) + IntToStr(glo.Kd(MtrNum))
   Cmd$ = Cmd$ + IntToStr(glo.Ki(MtrNum)) + IntToStr(glo.IL(MtrNum))
   Cmd$ = Cmd$ + CHR$(glo.ol(MtrNum)) + CHR$(X)
   Cmd$ = Cmd$ + IntToStr(glo.EL(MtrNum)) + CHR$(glo.SRD(MtrNum))
   
   SendCmd address, Cmd$
   
END SUB

FUNCTION SIOGetByte (Character AS INTEGER, TimeOutPeriod AS INTEGER)

 'start a timeout timer
 TimeOutTime& = TIMER + 2
 '***************** ADD check for rollover @ midnight

 OneChr$ = " "


 'loop till we get a byte from the serial port
 DO
   
    CALL ReadFromComm(PicPort, OneChr$, BytesRead, ECode)

    IF BytesRead > 0 THEN
      Character = ASC(OneChr$)
      SIOGetByte = True
      EXIT FUNCTION
    END IF

    'check if there has been no char for a long time
    IF TIMER > TimeOutTime& THEN '
      SIOGetByte = False
      glo.CumSIOError = glo.CumSIOError + 1
      IF glo.SIOErrorMode > DoNothing THEN
	SetCursor 20, 20: PRINT "Com Error"
	FixSIOError
      END IF
      EXIT FUNCTION
    END IF

 LOOP


END FUNCTION

SUB StopAbort
  
  Cmd$ = CHR$(&H17) + CHR$(StopAbrupt)

  SendCmd AllMtrs, Cmd$

END SUB

SUB StopNormal

  Cmd$ = CHR$(&H17) + CHR$(StopSmooth)

  SendCmd &HFF&, Cmd$
  

END SUB

SUB Strip (A$) STATIC
     CALL STRIPBLANKS(A$, 3, SLen)
     A$ = LEFT$(A$, SLen)
END SUB

     SUB STRIPBLANKS (A$, w, SLen)

END SUB

SUB StrobeData (datab)

  'Strobes datab to the lcd, also tests the busy flag
  OUT CtrlReg, DataStbOff ' strobe off
  OUT DataReg, datab      ' send data
  OUT CtrlReg, DataStbOn  ' strobe on
  OUT CtrlReg, DataStbOff ' strobe off

  'may not be necessary
  OUT ProgReg, DataPortIn ' set data port as input
  OUT CtrlReg, LcdBusy    ' set up lcd to test busy flag (BF)
  WHILE (INP(DataReg) AND BusyFlag)  ' loop while BF=1
  WEND
  OUT ProgReg, DataPortOut ' set data port as output
  
END SUB

SUB StrobeInstr (insb)

  'Strobes instructions to the lcd, also tests the busy flag

  OUT CtrlReg, InstrStbOff 'strobe off
  CALL ddelay(D10)
  OUT DataReg, insb        'send data
  CALL ddelay(D10)
  OUT CtrlReg, InstrStbOn  'strobe on
  CALL ddelay(D50)
  OUT CtrlReg, InstrStbOff 'strobe off
  CALL ddelay(D10)
  OUT ProgReg, DataPortIn  'set data Port 1 as input
  CALL ddelay(D10)
  OUT CtrlReg, LcdBusy     'set up lcd to test busy flag (BF)
  CALL ddelay(D10)
  
  WHILE (INP(DataReg) AND BusyFlag) 'loop while BF=1
  WEND

  CALL ddelay(D10)
  OUT ProgReg, DataPortOut 'set Port 1 as output

END SUB

   FUNCTION TrapInt (os, ps, fg)

END FUNCTION

