
#COMPILE EXE
#REGISTER NONE
#DIM ALL

DECLARE SUB RTDisplayString LIB "RTTDLL.DLL" ALIAS "RTDisplayString" (s AS ASCIIZ) CDECL



MACRO PiHalf = (2 * ATN(1))
MACRO Pi = (4 * ATN(1))
MACRO Pi2 = (8 * ATN(1))
MACRO DegToRdn(dpDegrees) = (dpDegrees*(Pi/180.00#))
MACRO RdnToDeg(dpRadians) = (dpRadians*(180.00#/Pi))
MACRO DegToRdn2(dpDegrees) = (dpDegrees * 00.0174532925199433#)
MACRO RdnToDeg2(dpRadians) = (dpRadians * 57.29577951308232#)
MACRO ArcCos(CosA) = ( Pi / 2 - ATN(CosA / SQR(1 - CosA * CosA)) )
MACRO ArcCosA(CosA) = ( ArcCos(CosA)*(180.00#/Pi))
MACRO ArcSin(SinA) = ATN(SinA / SQR(1 - SinA * SinA))
MACRO ArcSinA(SinA) = ( ArcSin(SinA)*(180.00#/Pi))
MACRO SQ(SquareIt) = (SquareIt^2)
MACRO SQx3(SquareIt) = (SquareIt^3)
MACRO SQx4(SquareIt) = (SquareIt^4)
MACRO SQx6(SquareIt) = (SquareIt^6)

FUNCTION PBMAIN () AS LONG
    LOCAL V#, P#, P2#, S$

    PRINT "Powerbasic PBMain is now executing!"
    PRINT "Press: Any key to continue"
    S$ = WAITKEY$

    ' Test Trig Functions
'    CLS
    P# =  45
    P2# = 0.15
    V# = PiHalf
    V# = Pi : PRINT "V# (1) = "+STR$(V#)
    V# = Pi2 : PRINT "V# (2) = "+STR$(V#)
    V# = DegToRdn(P#) : PRINT "V# (3) = "+STR$(V#)
    V# = RdnToDeg(P#) : PRINT "V# (4) = "+STR$(V#)
    V# = DegToRdn2(P#) : PRINT "V# (5) = "+STR$(V#)
    V# = RdnToDeg2(P#) : PRINT "V# (6) = "+STR$(V#)
    V# = ArcCos(P2#) : PRINT "V# (7) = "+STR$(V#)
    V# = ArcCosA(P2#) : PRINT "V# (8) = "+STR$(V#)
    V# = ArcSin(P2#) : PRINT "V# (9) = "+STR$(V#)
    V# = ArcSinA(P2#) : PRINT "V# (10) = "+STR$(V#)
    V# = SQ(P#) : PRINT "V# (11) = "+STR$(V#)
    V# = SQx3(P#) : PRINT "V# (12) = "+STR$(V#)
    V# = SQx4(P#) : PRINT "V# (13) = "+STR$(V#)
    V# = SQx6(P#) : PRINT "V# (14) = "+STR$(V#)

    PRINT ""
    PRINT "Press: Any Key to Continue"
    S$ = WAITKEY$
'    CLS
    LOCAL N&, V2##
    V2## = .1
    FOR N&=1 TO 100
        PRINT STR$(N&)+" "+FORMAT$(V2##,"#############.####")
        V2##=V2##+V2##
        SELECT CASE N&
            CASE 26,51,76
                PRINT ""
                PRINT "Press: Any Key to Continue"
                S$ = WAITKEY$
'                CLS
            CASE ELSE
        END SELECT
    NEXT N&

    PRINT ""
    PRINT "Press: Any Key to Continue"
    S$ = WAITKEY$
'    CLS
    S$="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    FOR N&=1 TO 26
        PRINT STR$(N&)+" "+MID$(S$,N&,1) + " " + RIGHT$(S$,N&)
    NEXT N&


    PRINT ""
    PRINT "Press: Any Key to Continue"

    S$ = WAITKEY$
'    CLS

    LOCAL hF AS LONG, T$
    hF = FREEFILE
    OPEN "Test1.dat" FOR BINARY AS hF
    T$ = "teststring"
    PUT hF,,T$
    CLOSE hF
    PRINT "File Written"

    PRINT ""
    PRINT "Press: Any Key to Continue"
    S$ = WAITKEY$
'    CLS

    PRINT "(step1)"
    LOCAL hComm   AS LONG
    LOCAL Qty AS LONG
    PRINT "(step2)"
    hComm = FREEFILE
    PRINT "(step3)"
    COMM OPEN "COM1" AS hComm
    PRINT "(step4)"
    ' RTOS does not like ERRCLEAR function
'    IF ERRCLEAR THEN EXIT FUNCTION
    IF ERRCLEAR THEN GOTO SkipCOM
    PRINT "(step5)"
    COMM SET hComm, BAUD     = 9600
    COMM SET hComm, BYTE     = 8
    COMM SET hComm, PARITY   = 0
    COMM SET hComm, STOP     = 0
    COMM SET hComm, TXBUFFER = 256
    COMM SET hComm, RXBUFFER = 256
    PRINT "(step6)"
    FOR N&=1 TO 25
        Qty = COMM(hComm, RXQUE)
        IF Qty > 0 THEN
            COMM RECV hComm, Qty, S$
            PRINT S$
        ELSE
            PRINT STR$(N&)+" "+"Nothing Pending"
        END IF
    NEXT N&
    COMM CLOSE hComm
SkipCOM:
    PRINT "(step7)"

    PRINT "Now testing direct call to RT runtime"
    PRINT ""
    PRINT "Press: Any Key to Continue"
    PRINT "-------------------------------"
    S$ = WAITKEY$

    testsub "RTDisplayString called from PB!"
    PRINT ""
    testsub "Press: Any key to continue"
    S$ = WAITKEY$
    PRINT ""
    PRINT "PROGRAM WILL CLOSE AFTER KEY PRESS !"
    PRINT ""
    PRINT "Press: Any Key to Continue"
    PRINT ""
    S$ = WAITKEY$
'    CLS


END FUNCTION

SUB testsub(BYVAL T$)
    RTDisplayString BYVAL STRPTR(T$)
END SUB
