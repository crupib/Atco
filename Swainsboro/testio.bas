#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG

    LOCAL tempstr AS STRING
    LOCAL mydouble1 AS DOUBLE
    LOCAL mydouble2 AS DOUBLE
    LOCAL mydouble3 AS DOUBLE
    LOCAL mydouble4 AS DOUBLE
    LOCAL mydouble11 AS DOUBLE
    LOCAL mydouble21 AS DOUBLE
    LOCAL mydouble31 AS DOUBLE
    LOCAL mydouble41 AS DOUBLE
    OPEN "test.dat" FOR BINARY AS #1 BASE = 0
    mydouble1 = 100.50
    mydouble2 = 110.50
    mydouble3 = 120.50
    mydouble4 = 130.50

    PUT #1,0,  mydouble1
    PUT #1,10,  mydouble2
    PUT #1,20,  mydouble3
    PUT #1,30,  mydouble4
    CLOSE #1
    OPEN "test.dat" FOR BINARY AS #1 BASE = 0

    GET #1, 0,  mydouble11
    GET #1, 10, mydouble21
    GET #1, 20, mydouble31
    GET #1, 30, mydouble41

    CLOSE #1
    PRINT  mydouble11
    PRINT  mydouble21
    PRINT  mydouble31
    PRINT  mydouble41
    WAITKEY$

END FUNCTION
