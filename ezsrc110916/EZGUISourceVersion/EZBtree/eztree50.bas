' -------------------------------------------------------------------------------------------
'             Official EZGUI 2.0 Btree Engine !
' -------------------------------------------------------------------------------------------

' *************************************************************************************
'                     Copyright Christopher R. Boss 2001
' *************************************************************************************
%MakeFull   =  1

$IF %MakeFull
   $COMPILE DLL "ezgui5bt.dll"
$ELSE
   $COMPILE DLL "eztreelt.dll"
$ENDIF

$DEBUG ERROR OFF

'$INCLUDE "win32api.inc"

$RESOURCE "eztree50.pbr"
'                      Last Date worked on : 10/01/99
' *************************************************************************************

DECLARE FUNCTION EZ_SCANRECORD (BYVAL SPOS&, BYVAL F$, BYVAL CMP$, BYVAL P1&, BYVAL P2&, DBRET$, BYVAL AL& ) AS LONG
DECLARE FUNCTION EZ_REBALANCEBTREE (BYVAL F$, BYVAL KL&, BYVAL DL&, BYVAL IMAX&, BYVAL CBAddress AS DWORD) AS LONG
DECLARE FUNCTION EZ_IMPORTBTREE (BYVAL TStart&, BYVAL F$, BYVAL TF$, BYVAL FL1&, BYVAL FL2&, BYVAL FL3&, BYVAL FL4&, BYVAL FL5&, BYVAL FL6&, BYVAL FL7&, BYVAL FL8&, BYVAL PS$, BYVAL CBAddress AS DWORD) AS LONG
DECLARE FUNCTION EZ_ADDRECORD (BYVAL F$, BYVAL DBB$, BYVAL KL& ) AS LONG
DECLARE FUNCTION EZ_FINDRECORD (BYVAL F$, BYVAL DBB$, DBRET$, BYVAL KL&) AS LONG
DECLARE FUNCTION EZ_SAVERECORD (BYVAL F$, BYVAL DBB$, BYVAL KL&) AS LONG

DECLARE FUNCTION CheckExeCBX(BYVAL CT&, BYVAL MaxLevel&, BYVAL IFlag&) AS LONG

' *************************************************************************************

GLOBAL ShutDownFile&

FUNCTION LIBMAIN(BYVAL hInstance   AS LONG, _
                 BYVAL fwdReason   AS LONG, _
                 BYVAL lpvReserved AS LONG) EXPORT AS LONG

   SELECT CASE fwdReason
      CASE 1   '  %DLL_PROCESS_ATTACH
         '   initialize DLL here

      CASE 2   '  %DLL_THREAD_ATTACH

      CASE 3   '  %DLL_THREAD_DETACH

      CASE 0   '  %DLL_PROCESS_DETACH
         '   This is where app unloads the DLL
         '   Global Variables, etc. will be lost at this point
      CASE ELSE
   END SELECT

   LIBMAIN=1
END FUNCTION

' *************************************************************************************
$IF %MakeFull

FUNCTION EZ_SCANRECORD (BYVAL SPOS&, BYVAL F$, BYVAL CMP$, BYVAL P1&, BYVAL P2&, DBRET$, BYVAL AL& ) EXPORT AS LONG
DB1$=STRING$(AL&, " ")
CALL SCANFILE (SPOS&, F$, CMP$, P1&, P2&, DB1$)
IF SPOS&<>0 THEN
   DBRET$=DB1$
END IF
FUNCTION=SPOS&
END FUNCTION

' *************************************************************************************

FUNCTION EZ_REBALANCEBTREE (BYVAL F$, BYVAL KL&, BYVAL DL& , BYVAL IMAX&, BYVAL CBAddress AS DWORD) EXPORT AS LONG
IF IMAX&<199 THEN IMAX&=199
IF IMAX&>32000 THEN IMAX&=32000
CALL REBALANCE (F$, 1, KL&, DL&, IMAX&, CBAddress)
FUNCTION=-1
END FUNCTION

' *************************************************************************************

FUNCTION EZ_IMPORTBTREE (BYVAL TStart&, BYVAL F$, BYVAL TF$, BYVAL FL1&, BYVAL FL2&, BYVAL FL3&, BYVAL FL4&, BYVAL FL5&, BYVAL FL6&, BYVAL FL7&, BYVAL FL8&, BYVAL PS$, BYVAL CBAddress AS DWORD) EXPORT AS LONG
CALL UPDATEEXT (TStart&, F$, TF$, FL1&, FL2&, FL3&, FL4&, FL5&, FL6&, FL7&, FL8&, PS$, CBAddress)
FUNCTION=1
END FUNCTION

' *************************************************************************************

$ENDIF

FUNCTION EZ_ADDRECORD (BYVAL F$, BYVAL DBB$, BYVAL KL& ) EXPORT AS LONG
OFLAG& = -1: CFLAG& = -1
FLAG&=0
WREC&=0
LEVEL&=0
CALL INSERTREC(1, F$, DBB$, 1, KL&, FLAG&, LEVEL&, WREC&, OFLAG&, CFLAG&)
FUNCTION=FLAG&
END FUNCTION

' *************************************************************************************

FUNCTION EZ_FINDRECORD (BYVAL F$, BYVAL DBB$, DBRET$, BYVAL KL&) EXPORT AS LONG
OFLAG& = -1: CFLAG& = -1
FLAG&=0
WREC&=0
LEVEL&=0
CALL INSERTREC(3, F$, DBB$, 1, KL&, FLAG&, LEVEL&, WREC&, OFLAG&, CFLAG&)
IF FLAG& THEN
   DBRET$=DBB$
END IF
FUNCTION=FLAG&
END FUNCTION

' *************************************************************************************

FUNCTION EZ_SAVERECORD (BYVAL F$, BYVAL DBB$, BYVAL KL&) EXPORT AS LONG
OFLAG& = -1: CFLAG& = -1
FLAG&=0
WREC&=0
LEVEL&=0
CALL INSERTREC(2, F$, DBB$, 1, KL&, FLAG&, LEVEL&, WREC&, OFLAG&, CFLAG&)
FUNCTION=FLAG&
END FUNCTION

' *************************************************************************************

SUB INSERTREC (INS&, F$, DBB$, ST&, STP&, FLAG&, LEVEL&, WREC&, OFLAG&, CFLAG&)
STATIC AFN?

REM INS&   1=INSERT & READ IF FOUND, 2=INSERT & SAVE IF FOUND, 3=FIND
REM F$-FILENAME,    DBB$-RECORD DATA,   ST&-START CHARACTER
REM STP&-STOP AFTER # OF CHARACTERS,   FLAG&--1=INSERTED OR FOUND
REM LEVEL&-LEVEL RECORD WAS PUT OR FOUND,  WREC&-RECORD LOCATION #

ShutDownFile&=0


DERROR& = 0
ERRORSTRING$ = ""

FLAG& = 0
LEVEL& = 1
INFO$ = DBB$ + MKL$(0) + MKL$(0)
CHECK$ = INFO$: L& = LEN(INFO$)
L2& = L& - 7: L3& = L& - 3
D1$ = MID$(INFO$, ST&, STP&)
ERRCOUNT& = 0
DERROR& = 0
ON ERROR GOTO DISKERROR



IF OFLAG& THEN
    AFN?=FREEFILE
    OPEN F$ FOR BINARY AS # AFN? LEN=512
END IF

LASTREC& = LOF(AFN?) / L&

IF LASTREC& = 0 THEN GOTO STARTTREE:
LASTREC& = LASTREC& + 1
AREC& = 1
DO
   PPTR& = (AREC& - 1) * L& + 1
   GET AFN?, PPTR&, CHECK$

   CMP& = 0
   D2$ = MID$(CHECK$, ST&, STP&)
   IF D1$ < D2$ THEN
      CMP& = 1
      LEVEL& = LEVEL& + 1
   ELSE
      IF D1$ > D2$ THEN CMP& = 2: LEVEL& = LEVEL& + 1
   END IF
   SELECT CASE CMP&
      CASE 1
         LPTR& = CVL(MID$(CHECK$, L2&, 4))
         IF LPTR& <> 0 THEN
            AREC& = LPTR&
         ELSE
            SELECT CASE INS&
               CASE 1, 2
                  MID$(CHECK$, L2&, 4) = MKL$(LASTREC&)
                  PUT AFN?, PPTR&, CHECK$

                  MID$(INFO$, L2&, 8) = MKL$(0) + MKL$(0)
                  PPTR& = (LASTREC& - 1) * L& + 1
                  PUT AFN?, PPTR&, INFO$

                  FLAG& = -1
                  WREC& = LASTREC&
                  EXIT DO
               CASE ELSE
                  FLAG& = 0
                  WREC& = 0
                  EXIT DO
            END SELECT
         END IF

      CASE 2
         RPTR& = CVL(MID$(CHECK$, L3&, 4))
         IF RPTR& <> 0 THEN
            AREC& = RPTR&
         ELSE
            SELECT CASE INS&
               CASE 1, 2
                  MID$(CHECK$, L3&, 4) = MKL$(LASTREC&)
                  PUT AFN?, PPTR&, CHECK$

                  MID$(INFO$, L2&, 8) = MKL$(0) + MKL$(0)
                  PPTR& = (LASTREC& - 1) * L& + 1
                  PUT AFN?, PPTR&, INFO$

                  WREC& = LASTREC&
                  FLAG& = -1
                  EXIT DO
               CASE ELSE
                  FLAG& = 0
                  WREC& = 0
                  EXIT DO
            END SELECT
         END IF
      CASE ELSE
         SELECT CASE INS&
            CASE 1
               DBB$ = LEFT$(CHECK$, L& - 8)
               WREC& = AREC&
               FLAG& = -1
               EXIT DO
            CASE 2
               MID$(CHECK$, 1, L& - 8) = DBB$
               PUT AFN?, PPTR&, CHECK$
               WREC& = AREC&
               FLAG& = -1
               EXIT DO
            CASE ELSE
               DBB$ = LEFT$(CHECK$, L& - 8)
               WREC& = AREC&
               FLAG& = -1
               EXIT DO
         END SELECT
   END SELECT
LOOP

IF CFLAG& THEN CLOSE AFN?
ON ERROR GOTO 0

FINISH1:

EXIT SUB

STARTTREE:
SELECT CASE INS&
   CASE 1, 2
      MID$(INFO$, L2&, 8) = MKL$(0) + MKL$(0)
      PUT AFN?, 1, INFO$

      FLAG& = -1
      WREC& = 1
   CASE ELSE
      WREC& = 0
      FLAG& = 0
END SELECT
IF CFLAG& THEN CLOSE AFN?
ON ERROR GOTO 0

EXIT SUB


DISKERROR:
DERROR& = ERR
SELECT CASE DERROR&
   CASE 52
      P$ = "BAD FILENAME OR NUMBER"
   CASE 53
      P$ = "FILE NOT FOUND"
   CASE 54
      P$ = "BAD FILE MODE"
   CASE 55
      P$ = "FILE ALREADY OPEN"
   CASE 57
      P$ = "DEVICE I/O ERROR "
   CASE 58
      P$ = "FILE ALREADY EXISTS"
   CASE 61
      P$ = "DISK IS FULL"
   CASE 62
      P$ = "INPUT PAST END OF FILE"
   CASE 63
      P$ = "BAD RECORD NUMBER"
   CASE 64
      P$ = "BAD FILE NAME"
   CASE 67
      P$ = "TOO MANY FILES"
   CASE 68
      P$ = "DEVICE UNAVAILABLE"
   CASE 70
      P$ = "PERMISSION DENIED"
   CASE 71
      P$ = "DISK NOT READY"
   CASE 72
      P$ = "DISK MEDIA ERROR"
   CASE 74
      P$ = "RENAME ACROSS DISKS"
   CASE 75
      P$ = "PATH-FILE ACCESS ERROR"
   CASE 76
      P$ = "PATH NOT FOUND"
   CASE ELSE
      P$ = "UNEXPECT ERROR #" + STR$(DERROR&) + " !"
END SELECT

REM EXIT subroutine AND SET ERROR flag
CLOSE AFN?
CFLAG& = -1
ON ERROR GOTO 0
ShutDownFile&=-1
MSGBOX "ERROR (Sub1): "+P$, %MB_ICONSTOP OR %MB_SYSTEMMODAL
FLAG& = 0: LEVEL& = -1
RESUME FINISH1

END SUB

' *************************************************************************************

$IF %MakeFull

SUB REBALANCE (F$, ST&, STP&, AL&, MAXT&, CBAddress AS DWORD)
FIXFLAG& = 0

L& = AL& + 8
RANDOMIZE (TIMER)
' MAXT& = 199
DIM ADDN&(0 TO MAXT&)
L2& = L& - 7: L3& = L& - 3
CHECK$ = STRING$(L2& - 1, " ") + MKL$(0) + MKL$(0)
CHECK2$ = CHECK$
INFO$ = CHECK$

ERRCOUNT& = 0
DERROR& = 0
ON ERROR GOTO DISKERROR2

AFN?=FREEFILE

OPEN F$ FOR BINARY AS # AFN?  LEN=24576

LASTREC& = LOF(AFN?) / L&
IF LASTREC& < 2 THEN
   ON ERROR GOTO 0
   CLOSE AFN?
   EXIT SUB
END IF
BREC& = 2: TREC& = LASTREC&


GET AFN?, 1, CHECK$

MID$(CHECK$, L2&, 8) = MKL$(0) + MKL$(0)
PUT AFN?, 1, CHECK$

FLIP& = -1
MAXLEVEL& = 0
DO
   N2& = TREC& - BREC&

   IF N2& > MAXT& THEN N2& = MAXT&
'   IF N2& <> MAXT& THEN GOSUB MAKETPL
'   IF BREC& = 2 THEN GOSUB MAKETPL
   GOSUB MAKETPL
   FOR REC& = 0 TO N2&
      LASTREC& = BREC& + ADDN&(REC&)
      PPTR& = (LASTREC& - 1) * L& + 1
      GET AFN?, PPTR&, INFO$


      LEVEL& = 1
      FIXFLAG& = -1
      GOSUB FIXPTR
      FIXFLAG& = 0
      IF LEVEL& > MAXLEVEL& THEN MAXLEVEL& = LEVEL&
      NN& = INT(MAXLEVEL& \ 3) + 1: IF NN& > 30 THEN NN& = 30
      IF CBAddress<>0 THEN
          CALL DWORD CBAddress USING CheckExeCBX((BREC&+REC&), MAXLEVEL&, 0) TO CancelDLL&
      END IF
   NEXT REC&
   BREC& = BREC& + N2& + 1
   IF BREC& > TREC& THEN EXIT DO
LOOP

CLOSE AFN?
ON ERROR GOTO 0

FINISH2:

EXIT SUB

MAKETPL:
FOR T& = 0 TO MAXT&
   ADDN&(T&) = T&
NEXT T&
T2& = N2&

FOR T& = 0 TO T2&
   NB& = INT((T2& + 1) * RND)
   IF NB&=T& THEN NB& = INT((T2& + 1) * RND)
   IF T& <> NB& THEN SWAP ADDN&(T&), ADDN&(NB&)
NEXT T&

FOR T& = 0 TO T2&
   NA& = INT((T2& + 1) * RND)
   NB& = INT((T2& + 1) * RND)
   IF NA& <> NB& THEN SWAP ADDN&(NA&), ADDN&(NB&)
NEXT T&
RETURN

FIXPTR:
SEEK 1, 1
GOSUB DODELAY
AREC& = 1
D1$ = MID$(INFO$, ST&, STP&)
DO
   PPTR& = (AREC& - 1) * L& + 1
   GET AFN?, PPTR&, CHECK$

   CMP& = 0
   D2$ = MID$(CHECK$, ST&, STP&)
   IF D1$ < D2$ THEN
      CMP& = 1: LEVEL& = LEVEL& + 1
   ELSE
      IF D1$ > D2$ THEN CMP& = 2: LEVEL& = LEVEL& + 1
   END IF
   SELECT CASE CMP&
      CASE 1
         LPTR& = CVL(MID$(CHECK$, L2&, 4))
         IF LPTR& <> 0 THEN
            AREC& = LPTR&
         ELSE
            MID$(CHECK$, L2&, 4) = MKL$(LASTREC&)
            PUT AFN?, PPTR&, CHECK$

            MID$(INFO$, L2&, 8) = MKL$(0) + MKL$(0)
            PPTR& = (LASTREC& - 1) * L& + 1
            PUT AFN?, PPTR&, INFO$

            FLAG& = -1
            WREC& = LASTREC&
            EXIT DO
         END IF

      CASE 2
         RPTR& = CVL(MID$(CHECK$, L3&, 4))
         IF RPTR& <> 0 THEN
            AREC& = RPTR&
         ELSE
            MID$(CHECK$, L3&, 4) = MKL$(LASTREC&)
            PUT AFN?, PPTR&, CHECK$

            MID$(INFO$, L2&, 8) = MKL$(0) + MKL$(0)
            PPTR& = (LASTREC& - 1) * L& + 1
            PUT AFN?, PPTR&, INFO$

            WREC& = LASTREC&
            FLAG& = -1
            EXIT DO
         END IF
      CASE ELSE
         EXIT DO
   END SELECT
LOOP
GOSUB DODELAY
RETURN

DODELAY:
'  IF NOCACHE& THEN CALL DELAY(.125)
RETURN

DPROBLEM2:
CLOSE AFN?
ON ERROR GOTO 0
EXIT SUB

DISKERROR2:
DERROR& = ERR
SELECT CASE DERROR&
   CASE 52
      P$ = "BAD FILENAME OR NUMBER"
   CASE 53
      P$ = "FILE NOT FOUND"
   CASE 54
      P$ = "BAD FILE MODE"
   CASE 55
      P$ = "FILE ALREADY OPEN"
   CASE 57
      P$ = "DEVICE I/O ERROR "
   CASE 58
      P$ = "FILE ALREADY EXISTS"
   CASE 61
      P$ = "DISK IS FULL"
   CASE 62
      P$ = "INPUT PAST END OF FILE"
   CASE 63
      P$ = "BAD RECORD NUMBER"
   CASE 64
      P$ = "BAD FILE NAME"
   CASE 67
      P$ = "TOO MANY FILES"
   CASE 68
      P$ = "DEVICE UNAVAILABLE"
   CASE 70
      P$ = "PERMISSION DENIED"
   CASE 71
      P$ = "DISK NOT READY"
   CASE 72
      P$ = "DISK MEDIA ERROR"
   CASE 74
      P$ = "RENAME ACROSS DISKS"
   CASE 75
      P$ = "PATH-FILE ACCESS ERROR"
   CASE 76
      P$ = "PATH NOT FOUND"
   CASE ELSE
      P$ = "UNEXPECT ERROR #" + STR$(DERROR&) + " !"
END SELECT

CLOSE AFN?
CFLAG& = -1
ON ERROR GOTO 0
MSGBOX "ERROR (Sub2): "+P$, %MB_ICONSTOP OR %MB_SYSTEMMODAL
FLAG& = 0: LEVEL& = -1
RESUME FINISH2

END SUB

' ******************************************************************************************

SUB UPDATEEXT (TStart&, F$, TF$, FL1&, FL2&, FL3&, FL4&, FL5&, FL6&, FL7&, FL8&, PS$, CBAddress AS DWORD)
' PS$ is an order string
Count&=0

SEP$=","
IF INSTR(PS$,"|") THEN SEP$="|"
IF INSTR(PS$,"/") THEN SEP$="/"
IF INSTR(PS$,CHR$(34)) THEN REMQ&=-1 ELSE REMQ&=0
APS$=LTRIM$(RTRIM$(PS$))+"00000000"
CHPARTS& = 0: ADPARTS& = 0
ERRCOUNT& = 0
ON ERROR GOTO DISKERROR3
DERROR& = 0
AFN?=FREEFILE
OPEN F$ FOR INPUT AS # AFN? LEN=24576       ' 24 KB Buffer for Read
DIM DF$(0 TO 10), DTMP$(0 TO 10)
REC& = 0

OFLAG&=-1   ' Open BTree flag
CFLAG&=0    ' Close BTree flag

DO
   IF EOF(AFN?) THEN EXIT DO
   D$=""
   LINE INPUT # AFN?, D$
   Count&=Count&+1
   IF Count&>=TStart& THEN
       DBB$=""
       FOR T&=1 TO 8
          DF$(T&)=""
          DTMP$(T&)=""
       NEXT T&
       CT&=0
       P1&=1
       DO
           AP&=INSTR(P1&, D$, SEP$)
           IF AP&>0 THEN
              CT&=CT&+1
              IF CT&>10 THEN EXIT DO
              DTMP$(CT&)=MID$(D$,P1&, AP&-P1&)
              P1&=AP&+1
           ELSE
              CT&=CT&+1
              IF CT&>10 THEN EXIT DO
              DTMP$(CT&)=MID$(D$,P1&)
              EXIT DO
              ' last item
           END IF
       LOOP
       IF REMQ& THEN
          FOR T&=1 TO 8
             DO
                P&=INSTR(DTMP$(T&), CHR$(34))
                IF P&=0 THEN EXIT DO
                DTMP$(T&)=LEFT$(DTMP$(T&), P&-1)+MID$(DTMP$(T&), P&+1)
             LOOP
          NEXT T&
       END IF
       FOR T&=1 TO 8
           L&=0
           N&=VAL(MID$(APS$,T&,1))
           SELECT CASE T&
              CASE 1
                 L&=FL1&
              CASE 2
                 L&=FL2&
              CASE 3
                 L&=FL3&
              CASE 4
                 L&=FL4&
              CASE 5
                 L&=FL5&
              CASE 6
                 L&=FL6&
              CASE 7
                 L&=FL7&
              CASE 8
                 L&=FL8&
              CASE ELSE
           END SELECT
           IF L&>0 THEN
              DF$(N&)=LEFT$(LTRIM$(RTRIM$(DTMP$(T&)))+STRING$(L&," "), L&)
           END IF
       NEXT T&
       DBB$=""
       KL&=LEN(DF$(1))
       FOR T&=1 TO 8
          DBB$=DBB$+DF$(T&)
       NEXT T&
       WREC&=0
       FLAG&=0
       IF RTRIM$(DBB$)<>"" THEN
'
'          INSERTREC 3, TF$, DBB$, 1, KL&, FLAG&, LEVEL&, WREC&, OFLAG&, CFLAG&
'          OFLAG&=0    ' is already open now
'          IF FLAG& THEN
              INSERTREC 2, TF$, DBB$, 1, KL&, FLAG&, LEVEL&, WREC&, OFLAG&, CFLAG&
              OFlag&=0    ' added
              IF ShutDownFile& THEN EXIT DO
'          ELSE
'              INSERTREC 1, TF$, DBB$, 1, KL&, FLAG&, LEVEL&, WREC&, OFLAG&, CFLAG&
'              IF ShutDownFile& THEN EXIT DO
'          END IF
       END IF
       MaxLevel&=LEVEL&
       InsFlag&=FLAG&
   ELSE
       MaxLevel&=0
       InsFlag&=0
   END IF
   IF CBAddress<>0 THEN
      CALL DWORD CBAddress USING CheckExeCBX(Count&, MaxLevel&, InsFlag&) TO CancelDLL&
      IF CancelDLL& THEN EXIT DO
   END IF
LOOP
CLOSE

FINISH3:
EXIT SUB

DISKERROR3:
DERROR& = ERR
SELECT CASE DERROR&
   CASE 52
      P$ = "BAD FILENAME OR NUMBER"
   CASE 53
      P$ = "FILE NOT FOUND"
   CASE 54
      P$ = "BAD FILE MODE"
   CASE 55
      P$ = "FILE ALREADY OPEN"
   CASE 57
      P$ = "DEVICE I/O ERROR "
   CASE 58
      P$ = "FILE ALREADY EXISTS"
   CASE 61
      P$ = "DISK IS FULL"
   CASE 62
      P$ = "INPUT PAST END OF FILE"
   CASE 63
      P$ = "BAD RECORD NUMBER"
   CASE 64
      P$ = "BAD FILE NAME"
   CASE 67
      P$ = "TOO MANY FILES"
   CASE 68
      P$ = "DEVICE UNAVAILABLE"
   CASE 70
      P$ = "PERMISSION DENIED"
   CASE 71
      P$ = "DISK NOT READY"
   CASE 72
      P$ = "DISK MEDIA ERROR"
   CASE 74
      P$ = "RENAME ACROSS DISKS"
   CASE 75
      P$ = "PATH-FILE ACCESS ERROR"
   CASE 76
      P$ = "PATH NOT FOUND"
   CASE ELSE
      P$ = "UNEXPECT ERROR #" + STR$(DERROR&) + " !"
END SELECT

REM EXIT subroutine AND SET ERROR flag
CLOSE
CFLAG& = -1
ON ERROR GOTO 0

MSGBOX "ERROR (Sub3): "+P$, %MB_ICONSTOP OR %MB_SYSTEMMODAL
FLAG& = 0: LEVEL& = -1
RESUME FINISH3

END SUB

' ******************************************************************************************

SUB SCANFILE (SPOS&, F$, CMP$, P1&, P2&, DB1$)
DBB$=DB1$
RL&=LEN(DBB$)
L&=RL&
IF RL&=0 THEN
   SPOS&=0
   EXIT SUB
END IF
RL&=RL&+8   ' add extra for pointers
ON ERROR GOTO DISKERROR4
DERROR& = 0
AFN?=FREEFILE
OPEN F$ FOR BINARY AS # AFN? LEN=24576
LREC&=LOF(AFN?)/RL&
IF SPOS&<1 THEN SPOS&=1
IF P1&<1 THEN P1&=1
IF P1&>L& THEN P1&=L&
IF P2&<1 THEN P2&=1
IF P2&>L& THEN P2&=L&
IF P1&>P2& THEN SWAP P1&, P2&
IF SPOS&<=LREC& THEN
   MAXB&=(24576\RL&)
   BL&=MAXB&*RL&
   Buffer$=STRING$(BL&, " ")
   BF1&=0
   BF2&=0
   FREC&=SPOS&
   SPOS&=0
   FOR AREC&=FREC& TO LREC&
      IF AREC&>=BF1& AND AREC&<=BF2& THEN
                  ' get from buffer
                  N&=AREC&-BF1&  ' 0 indexed
                  DBB$=MID$(Buffer$, (N&*RL&)+1, RL&-8)
      ELSE
         ' load new buffer
         DIF&=(LREC&-AREC&)+1
         IF DIF&<MAXB& THEN MAXB&=DIF&
         Buffer$=STRING$(MAXB&*RL&, " ")
         PPTR&=((AREC&-1)*RL&)+1
         BF1&=AREC&
         BF2&=AREC&+MAXB&-1
         GET AFN?, PPTR&, Buffer$
                  N&=0  ' 0 indexed
                  DBB$=MID$(Buffer$, (N&*RL&)+1, RL&-8)
      END IF
      ' do compare here
      ' SPOS& should return Next start pos or zero
      IF INSTR(UCASE$(MID$(DBB$, P1&, (P2&-P1&)+1)), UCASE$(CMP$))<>0 THEN
         SPOS&=AREC&+1
         DB1$=DBB$
         EXIT FOR
      END IF
   NEXT AREC&
ELSE
   SPOS&=0
END IF
CLOSE AFN?
FINISH4:
EXIT SUB


DISKERROR4:
DERROR& = ERR
SELECT CASE DERROR&
   CASE 52
      P$ = "BAD FILENAME OR NUMBER"
   CASE 53
      P$ = "FILE NOT FOUND"
   CASE 54
      P$ = "BAD FILE MODE"
   CASE 55
      P$ = "FILE ALREADY OPEN"
   CASE 57
      P$ = "DEVICE I/O ERROR "
   CASE 58
      P$ = "FILE ALREADY EXISTS"
   CASE 61
      P$ = "DISK IS FULL"
   CASE 62
      P$ = "INPUT PAST END OF FILE"
   CASE 63
      P$ = "BAD RECORD NUMBER"
   CASE 64
      P$ = "BAD FILE NAME"
   CASE 67
      P$ = "TOO MANY FILES"
   CASE 68
      P$ = "DEVICE UNAVAILABLE"
   CASE 70
      P$ = "PERMISSION DENIED"
   CASE 71
      P$ = "DISK NOT READY"
   CASE 72
      P$ = "DISK MEDIA ERROR"
   CASE 74
      P$ = "RENAME ACROSS DISKS"
   CASE 75
      P$ = "PATH-FILE ACCESS ERROR"
   CASE 76
      P$ = "PATH NOT FOUND"
   CASE ELSE
      P$ = "UNEXPECT ERROR #" + STR$(DERROR&) + " !"
END SELECT

REM EXIT subroutine AND SET ERROR flag
CLOSE AFN?
ON ERROR GOTO 0

MSGBOX "ERROR (Sub4): "+P$, %MB_ICONSTOP OR %MB_SYSTEMMODAL
FLAG& = 0: LEVEL& = -1
RESUME FINISH4

END SUB


FUNCTION EZ_RANDOMIZE(BYVAL F$, BYVAL F2$, BYVAL MAXI&) EXPORT AS LONG
RANDOMIZE (TIMER)
IF MAXI&<199 THEN MAXI&=199
IF MAXI&>32000 THEN MAXI&=32000
DIM ADDN&(0 TO MAXI&)
DIM INFO$(0 TO MAXI&)

ERRCOUNT& = 0
ON ERROR GOTO DISKERROR9
DERROR& = 0
IF DIR$(F2$)<>"" THEN KILL F2$
AFN?=FREEFILE
OPEN F$ FOR INPUT AS # AFN? LEN=24576       ' 24 KB Buffer for Read
AFN2?=FREEFILE
OPEN F2$ FOR OUTPUT AS # AFN2? LEN=24576       ' 24 KB Buffer for Read
FLAG&=1

DO
    IF EOF(AFN?) THEN EXIT DO
    COUNT&=-1
    FOR X&=0 TO MAXI&
       IF EOF(AFN?) THEN EXIT FOR
       D$=""
       LINE INPUT # AFN?, D$
       IF D$<>"" THEN
           COUNT&=COUNT&+1
           INFO$(COUNT&)=D$
       END IF
    NEXT X&
    IF COUNT&>=0 THEN
        MAXT& = COUNT&
        GOSUB MAKETPL2
        FOR X&=0 TO MAXT&
            PRINT # AFN2?, INFO$(ADDN&(X&))
        NEXT X&
    END IF
LOOP
CLOSE AFN?
CLOSE AFN2?
FINISH9:
FUNCTION=FLAG&
EXIT FUNCTION

MAKETPL2:
FOR T& = 0 TO MAXT&
   ADDN&(T&) = T&
NEXT T&

FOR T& = 0 TO MAXT&
   NB& = INT((MAXT& + 1) * RND)
   IF NB&=T& THEN NB& = INT((MAXT& + 1) * RND)
   IF T& <> NB& THEN SWAP ADDN&(T&), ADDN&(NB&)
NEXT T&

FOR T& = 0 TO MAXT&
   NA& = INT((MAXT& + 1) * RND)
   NB& = INT((MAXT& + 1) * RND)
   IF NA& <> NB& THEN SWAP ADDN&(NA&), ADDN&(NB&)
NEXT T&
RETURN

DISKERROR9:
DERROR& = ERR
SELECT CASE DERROR&
   CASE 52
      P$ = "BAD FILENAME OR NUMBER"
   CASE 53
      P$ = "FILE NOT FOUND"
   CASE 54
      P$ = "BAD FILE MODE"
   CASE 55
      P$ = "FILE ALREADY OPEN"
   CASE 57
      P$ = "DEVICE I/O ERROR "
   CASE 58
      P$ = "FILE ALREADY EXISTS"
   CASE 61
      P$ = "DISK IS FULL"
   CASE 62
      P$ = "INPUT PAST END OF FILE"
   CASE 63
      P$ = "BAD RECORD NUMBER"
   CASE 64
      P$ = "BAD FILE NAME"
   CASE 67
      P$ = "TOO MANY FILES"
   CASE 68
      P$ = "DEVICE UNAVAILABLE"
   CASE 70
      P$ = "PERMISSION DENIED"
   CASE 71
      P$ = "DISK NOT READY"
   CASE 72
      P$ = "DISK MEDIA ERROR"
   CASE 74
      P$ = "RENAME ACROSS DISKS"
   CASE 75
      P$ = "PATH-FILE ACCESS ERROR"
   CASE 76
      P$ = "PATH NOT FOUND"
   CASE ELSE
      P$ = "UNEXPECT ERROR #" + STR$(DERROR&) + " !"
END SELECT

REM EXIT subroutine AND SET ERROR flag
CLOSE
ON ERROR GOTO 0

MSGBOX "ERROR (Sub9): "+P$, %MB_ICONSTOP OR %MB_SYSTEMMODAL
FLAG& = 0
RESUME FINISH9


END FUNCTION

$ENDIF
