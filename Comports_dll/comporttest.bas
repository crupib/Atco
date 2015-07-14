#COMPILE EXE
#DIM ALL
<<<<<<< HEAD
'atcondt_lib includes functions specific for atco. This includes getting the number of FTDI comm ports:
'
#INCLUDE "atcondt_lib.inc"

=======
#INCLUDE "atcondt_lib.inc"
>>>>>>> b2cb08ee7962d6e68f5072d0943eb0a966ad16a5
FUNCTION PBMAIN () AS LONG
DIM comports(10) AS STRING
LOCAL num_comports AS LONG
LOCAL I AS LONG
LOCAL mycount AS LONG
DIM product AS STRING * 10
DIM version AS STRING * 10
DIM serialno AS STRING * 10
LOCAL MyInput AS STRING

LOCAL retcode AS INTEGER
num_comports = comportlist(comports())
IF  num_comports = 0 THEN
    PRINT "No Serial FTDI ports"
END IF

FOR I = 0 TO num_comports - 1
         PRINT comports(I)
     NEXT
retcode = QSB_InitComm(3)
IF retcode = %QSB_SUCCESS THEN
    PRINT "Success"
END IF

retcode = QSB_GetDeviceInfo(3,product,version,serialno)
PRINT product , version, serialNo
retcode = QSB_GetCount(3, mycount)
'print mycount
'mycount = 100
'retcode = QSB_SetCount(3, mycount)
'print retcode
QSB_SetCounterMode(3,0)
WAITSTAT
DO
    MyInput = INKEY$ ' get them

    IF MyInput = $ESC THEN Terminate

    retcode = QSB_GetCount(3, mycount)
    PRINT mycount
LOOP
WAITSTAT
Terminate:
QSB_CloseComm(3)
END FUNCTION
