#COMPILE EXE
#DIM ALL

TYPE udt1

  x AS STRING * 12
  y AS LONG
  z AS INTEGER

  r (0 TO 100) AS SINGLE
  s (0 TO 100, 0 TO 100) AS DOUBLE
  xPtr AS DOUBLE POINTER
END TYPE

GLOBAL mystruc AS udt1

FUNCTION PBMAIN () AS LONG
DIM myarray(10) AS DOUBLE
DIM xPtr AS DOUBLE POINTER
    myarray(0) = 4.335
    myarray(1) = 5.9
    mystruc.R(0) = 6.0
    mystruc.R(1) = 7.2
    mystruc.S(1,2) = 8.33001
    mystruc.S(0,0) = 9.33001
    xPtr = VARPTR(myarray(0))
    mystruc.xPtr = VARPTR(myarray(0))
    PRINT "xPtr " @xPtr[0]
    PRINT "mystruc.xPtr " mystruc.@xPtr[1]
    PRINT "R " mystruc.R(0)
    PRINT "S " mystruc.S(1,2)
    PRINT "S " mystruc.S(0,0)
    WAITKEY$
END FUNCTION
