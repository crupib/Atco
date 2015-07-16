#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
DIM myarrayPtr AS INTEGER POINTER
DIM myarray(0) AS INTEGER
LOCAL x AS INTEGER

myarrayPtr = VARPTR(myarray%(0))
myfunc(myarrayPtr)
FOR x =0 TO 9
    PRINT @myarrayPtr
    myarrayPtr= myarrayPtr+4
NEXT x

WAITKEY$
END FUNCTION

FUNCTION myfunc (BYVAL myarrayPtr AS INTEGER POINTER) AS BYTE
REDIM myarray(10) AS INTEGER AT myarrayPtr
LOCAL x AS INTEGER
FOR x =0 TO 9
    myarray(x) = 9999+x
NEXT x

myfunc = 0

END FUNCTION
