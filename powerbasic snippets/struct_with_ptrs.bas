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
myarray(0) = 2.335
myarray(1) = 2.9
mystruc.R(0) = 1.0
mystruc.R(1) = 2.2
mystruc.S(1,2) = 2.33001
xPtr = VARPTR(myarray(0))
mystruc.xPtr = VARPTR(myarray(0))
PRINT @xPtr[0]
PRINT mystruc.@xPtr[0]
PRINT mystruc.R(0)
PRINT mystruc.S(1,2)
WAITKEY$
END FUNCTION
