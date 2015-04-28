'********************************************************************************************************
'AtcoSer.inc
'***'****************************************************************************************************
REM new RS232 PC compatible
DECLARE SUB CloseCommPort(ComPortNum$,ecode%)
DECLARE SUB FlushBuffers (ComPortNum$, WhichBuffer%, ECode%)
DECLARE SUB GetCharsInBuffer (ComPortNum$, RecvQue%, XmitQue%, ECode%)
DECLARE SUB ReadFromComm (ComPortNum$, ReadBuffer$, BytesRead%, ECode%)
DECLARE SUB WriteToComm (ComPortNum$, WriteBuffer$, BytesWritten%, ECode%)
DECLARE FUNCTION OpenComPorts ()
DECLARE SUB DeleteCommBuffers (ECode%)
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
