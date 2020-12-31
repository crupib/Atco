'********************************************************************************************************
'AtcoSer.inc
'********************************************************************************************************
' RS232 Port Control
DECLARE FUNCTION OpenComPorts () AS INTEGER
DECLARE SUB CloseCommPort(ComPortNum$,ecode%)
DECLARE SUB FlushBuffers (ComPortNum$, WhichBuffer%, ECode%)
DECLARE SUB ReadFromComm (ComPortNum$, ReadBuffer$, BytesRead%, ECode%)
DECLARE SUB WriteToComm (ComPortNum$, WriteBuffer$, BytesWritten%, ECode%)
DECLARE FUNCTION OpenComPorts () AS INTEGER
DECLARE SUB DeleteCommBuffers (ECode%)

'Serial Communication routines
DECLARE SUB GetCharsInBuffer (ComPortNum$, RecvQue%, XmitQue%, ECode%)
DECLARE FUNCTION InitNetWork AS INTEGER
DECLARE SUB SendCmd (address AS WORD, CmdString AS STRING)
DECLARE FUNCTION SIOGetByte (Character AS INTEGER, TimeOutPeriod AS INTEGER) AS INTEGER
DECLARE SUB FixSIOerror
DECLARE SUB GetStatus (Num AS INTEGER)


SUB GetStatus (Num AS INTEGER)

   LOCAL MtrNum AS INTEGER
   LOCAL Cmd AS STRING
   Cmd$ = CHR$(&HE)  'nop

   IF Num = &H255 THEN  'load status all servos
     FOR MtrNum = 1 TO LastServo
       SendCmd MtrNum, Cmd$
     NEXT
   ELSE                       'load status of one servo or io
     SendCmd Num, Cmd$
   END IF

END SUB


FUNCTION SIOGetByte (Character AS INTEGER, TimeOutPeriod AS INTEGER) AS INTEGER
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

FUNCTION OpenComPorts AS INTEGER
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
    COMM SET #nComm, PARITY = FALSE        ' No parity
    COMM SET #nComm, STOP   = 0     ' 1 stop bit

    COMM SET #nComm, XINPFLOW = 0
    COMM SET #nComm, XOUTFLOW = 0
    CALL FlushBuffers(PICPort$, 0, ECode%)
    OpenComPorts = TRUE
END FUNCTION
SUB CloseComPorts
   LOCAL ecode AS INTEGER
   CALL CloseCommPort(PICPort$,ecode%)
   CALL DeleteCommBuffers(ECode%)
END SUB

SUB DeleteCommBuffers (ecode%)
END SUB

SUB CloseCommPort (ComPortNum$,ecode%)
END SUB

SUB WriteToComm (ComPortNum$, WriteBuffer$, BytesWritten%, ECode%)
    LOCAL qty AS INTEGER
    COMM SEND #nComm, WriteBuffer$
    SLEEP 200
END SUB

SUB ReadFromComm (ComPortNum$, ReadBuffer$, BytesRead%, ECode%)
      LOCAL ncbData AS LONG    ' bytes of data waiting

      ncbData = COMM(#nComm, RXQUE)
      IF ncbData THEN
            COMM RECV #nComm, 1, ReadBuffer$
      END IF
      BytesRead% = 1
END SUB
SUB FlushBuffers (ComPortNum$, WhichBuffer%, ECode%)
      LOCAL Qty AS LONG
      LOCAL emptybuffer AS STRING
      Qty& = COMM(#nComm, RXQUE)
      IF Qty& THEN
            COMM RECV #nComm, Qty&, emptybuffer
      END IF
END SUB
'****************************************************************************************************
DECLARE FUNCTION InitNetWork () AS INTEGER
FUNCTION InitNetWork AS INTEGER
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
