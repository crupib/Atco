#COMPILE EXE
#DIM ALL

TYPE report_struc
   step    AS INTEGER
   time_    AS DOUBLE
   input_  AS DOUBLE
   filter1 AS DOUBLE
   filter2 AS DOUBLE
   ovel    AS DOUBLE
   opos    AS DOUBLE
   oacc    AS DOUBLE
   ojerk   AS DOUBLE
END TYPE

FUNCTION PBMAIN () AS LONG

LOCAL MaxVel    AS DOUBLE
LOCAL MaxVelAdj AS DOUBLE
LOCAL Dist      AS DOUBLE
LOCAL MaxAcc    AS DOUBLE
LOCAL MaxJerk   AS DOUBLE

LOCAL MaxVelT    AS DOUBLE
LOCAL MaxposT    AS DOUBLE
LOCAL MaxAccT    AS DOUBLE
LOCAL MaxJerkT   AS DOUBLE
LOCAL itp       AS DOUBLE
LOCAL T4        AS DOUBLE
LOCAL FL1       AS DOUBLE
LOCAL FL2       AS DOUBLE
LOCAL N         AS DOUBLE
LOCAL TPOSMS    AS DOUBLE
LOCAL I         AS INTEGER
LOCAL time      AS DOUBLE
LOCAL filter1   AS DOUBLE
LOCAL input_    AS DOUBLE
LOCAL temp      AS DOUBLE
LOCAL tempa     AS DOUBLE
LOCAL offsetrows     AS DOUBLE
LOCAL height     AS DOUBLE
LOCAL tempd     AS DOUBLE
LOCAL Y         AS BYTE
LOCAL Z         AS BYTE
LOCAL sum       AS DOUBLE
LOCAL A1         AS STRING
LOCAL A2         AS STRING
LOCAL A3         AS STRING
LOCAL A4         AS STRING
LOCAL A5         AS STRING
LOCAL A6         AS STRING
LOCAL A7         AS STRING
LOCAL A8         AS STRING
LOCAL A9         AS STRING
LOCAL V1         AS DOUBLE
LOCAL W1         AS DOUBLE
LOCAL X1         AS DOUBLE
LOCAL Y1         AS DOUBLE
LOCAL Z1         AS DOUBLE
LOCAL maxnum     AS DOUBLE



DIM report_line (1 TO 220) AS report_struc

MaxVel  = 100
Dist    = 123.456
itp     = 10
MaxJerk = 1250
MaxAcc  = 250
MaxVelAdj =  MIN(MaxVel,(-(MaxAcc^2)+SQR(MaxAcc^4-4*MaxJerk*(-MaxJerk*MaxAcc*Dist)))/(2*MaxJerk))
T4 = Dist/MaxVelAdj*1000
FL1 = ROUND((MaxVelAdj/MaxAcc)*1000/itp,0)
FL2 = ROUND((MaxAcc/MaxJerk)*1000/itp,0)
N   = T4/itp
OPEN "excel.txt" FOR OUTPUT AS #1

TPOSms =  (FL2+FL1+N)*itp

input_ = 0
filter1 = 0

FOR I = 1 TO 219 STEP 1
   report_line(i).step = I
   report_line(i).time_ = (i-1) * itp/1000

   IF I = 1 THEN
       report_line(i).input_  = 0
       report_line(i).filter1 = 0
       report_line(i).filter2 = 0
       report_line(i).ovel    = 0
       report_line(i).opos    = 0
       report_line(i).oacc    = 0
       report_line(i).ojerk   = 0
   END IF

   IF I = 2 THEN
       IF (N - (ROUND(N,0))) > 0 THEN
           report_line(i).input_ =  N - (INT(N))
       ELSE
           report_line(i).input_ = 1
       END IF
       IF report_line(i).input_ > 0 THEN
           temp = report_line(i).input_
       ELSE
           temp = -1
       END IF
       tempa = i-1
       report_line(i).filter1 = MAX(0,MIN(FL1,report_line(tempa).filter1+temp))
       report_line(i).ovel = report_line(i).filter1/(FL2*MaxVelAdj)
   END IF
   IF I > 2 THEN
       IF(I < N+2) THEN
        report_line(i).input_ = 1
       ELSE
        report_line(i).input_ = 0
       END IF
        IF report_line(i).input_ > 0 THEN
           temp = report_line(i).input_
       ELSE
           temp = -1
       END IF
       tempa = i-1
       report_line(i).filter1 = MAX(0,MIN(FL1,report_line(tempa).filter1+temp))
    END IF

NEXT

FOR I = 2 TO 219 STEP 1
       sum = 0
       IF (report_line(i).step =< FL2) THEN
           offsetrows = MIN(FL2,report_line(i).step)
           height     = MIN(FL2,report_line(i).step)
           offsetrows = (offsetrows*-1)+1
           offsetrows = offsetrows + I
           height     = height
           FOR Z = offsetrows TO height STEP 1
             sum = sum + report_line(Z).filter1
           NEXT
       ELSE
           offsetrows =  I - 19
           height     =  I
           FOR Z = offsetrows TO height STEP 1
             sum = sum + report_line(Z).filter1
           NEXT
       END IF

 '      FOR Z = offsetrows TO height STEP 1
 '          sum = sum + report_line(Z).filter1
 '      NEXT
       report_line(I).filter2 = sum/FL1
NEXT
FOR I = 2 TO 219 STEP 1
    report_line(i).ovel =  report_line(I).filter2 /(FL2*.01)
    temp = i - 1
    V1 =   report_line(i).ovel +  report_line(temp).ovel
    W1 =   V1/2
    X1 =   W1*itp
    Y1 =   X1/1000
    report_line(i).opos = Y1 + report_line(temp).opos
    V1 =   report_line(i).ovel -  report_line(temp).ovel
    W1 = V1/10
    X1 = W1*1000
    report_line(i).oacc =  X1
    V1 = report_line(i).oacc - report_line(temp).oacc
    W1 = V1/10
    X1 = W1*1000
    report_line(i).ojerk = X1

NEXT

maxnum = 0
FOR I = 1 TO 219 STEP 1
 IF report_line(i).ovel > maxnum THEN
    maxnum = report_line(i).ovel
 END IF
 MaxVelT = maxnum
NEXT
maxnum = 0
FOR I = 1 TO 219 STEP 1
 IF report_line(i).opos > maxnum THEN
    maxnum = report_line(i).opos
 END IF
 MaxPosT = maxnum
NEXT
maxnum = 0
FOR I = 1 TO 219 STEP 1
 IF report_line(i).oacc > maxnum THEN
    maxnum = report_line(i).oacc
 END IF
 MaxAccT = maxnum
NEXT

maxnum = 0
FOR I = 1 TO 219 STEP 1
 IF report_line(i).ojerk > maxnum THEN
    maxnum = report_line(i).ojerk
 END IF
 MaxJerkT = maxnum
NEXT

PRINT  "Max Vel", MaxVel
PRINT  "Max Vel adj", MaxVelAdj
PRINT  "Dist", Dist
PRINT  "Max Acc", MaxAcc
PRINT  "Max Jerk", MaxJerk
PRINT  "itp", itp
PRINT  "T4", T4
PRINT  "FL1", FL1
PRINT  "FL2",FL2
PRINT  "N", N
PRINT  "T(Pos)ms", TPOSms
PRINT "Max Vel 2", MaxVelT
PRINT "Max Pos", MaxPosT
PRINT "Max Acc 2", MaxAccT
PRINT "Max Jerk 2", MaxJerkT

FOR I = 1 TO 219 STEP 1
     A1$ = FORMAT$(report_line(i).step,     "####.########")
     A2$ = FORMAT$(report_line(i).time_,    "####.########")
     A3$ = FORMAT$(report_line(i).input_,   "####.########")
     A4$ = FORMAT$(report_line(i).filter1,  "####.########")
     A5$ = FORMAT$(report_line(i).filter2,  "####.########")
     A6$ = FORMAT$(report_line(i).ovel,     "####.########")
     A7$ = FORMAT$(report_line(i).opos,     "####.########")
     A8$ = FORMAT$(report_line(i).oacc,     "####.########")
     A9$ = FORMAT$(report_line(i).ojerk,     "####.########")
  '   WRITE #1,  A1$, A2$, A3$, A4$, A5$, A6 ' PRINT a1$, a2$, a3$, a4$, A5$
     PRINT "--------------------------------------------------------"
     PRINT a1$, a2$, a3$, a4$, A5$ ,a6$, a7$, a8$, a9$

     WAITKEY$
NEXT
END FUNCTION
