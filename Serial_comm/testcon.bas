#COMPILE EXE

#DIM ALL

%TRUE  = -1

%FALSE = 0



DECLARE SUB DISPLAY(BYVAL sData AS STRING)



FUNCTION PBMAIN

  LOCAL hComm   AS LONG

  LOCAL Echo    AS LONG

  LOCAL Qty     AS LONG

  LOCAL Stuf    AS STRING

  LOCAL MyInput AS STRING



  hComm = FREEFILE

  COMM OPEN "COM4" AS #hComm

  IF ERRCLEAR THEN EXIT FUNCTION 'Exit if port cannot be opened



  COMM SET #hComm, BAUD     = 230400    ' 14K4 baud

  COMM SET #hComm, BYTE     = 8        ' 8 bits

  COMM SET #hComm, PARITY   = %FALSE   ' No parity

  COMM SET #hComm, STOP     = 0        ' 1 stop bit

  COMM SET #hComm, TXBUFFER = 1024     ' 1 Kb transmit buffer

  COMM SET #hComm, RXBUFFER = 1024     ' 1 Kb receive buffer



  Echo = -1                         ' Set echo ON
  COMM SEND #hComm, "R0E"+&H0D
  WHILE %TRUE                       ' loop forever

    WHILE NOT INSTAT                ' unless key pressed

      Qty = COMM(#hComm, RXQUE)

      IF ISTRUE Qty THEN

        COMM RECV #hComm, Qty, Stuf ' read incoming characters

        DISPLAY Stuf                ' display the raw data

      END IF                        ' transmitter

    WEND



    WHILE INSTAT                    ' Any keypresses?

      MyInput = INKEY$              ' get them

      IF MyInput = $ESC THEN Terminate

      COMM SEND #hComm, MyInput     ' send typed characters

      IF Echo THEN DISPLAY MyInput  ' display them

    WEND

  WEND                ' check for more incoming characters



Terminate:

  COMM CLOSE #hComm   ' Close the comm port and exit



END FUNCTION



SUB DISPLAY(BYVAL sData AS STRING)  ' handles embedded CR/LF bytes

  LOCAL sDataPtr AS BYTE PTR

  LOCAL y AS LONG



  REPLACE $LF WITH "" IN sData      ' reduce CR/LF to CR



  sDataPtr = STRPTR(sData)



  FOR y = 0 TO LEN(sData) - 1

    IF @sDataPtr[y] = 13& THEN

      PRINT                         ' force new line on CR

      ITERATE FOR

    END IF

    PRINT CHR$(@sDataPtr[y]);       ' display current char

  NEXT y

END SUB
