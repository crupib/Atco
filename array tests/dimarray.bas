#COMPILE EXE
#DIM ALL
TYPE listOfPtr
    myvectors(4) AS INTEGER POINTER
END TYPE

FUNCTION PBMAIN () AS LONG

DIM myarray1(0) AS INTEGER
DIM myarray2(0) AS INTEGER
DIM myarray3(0) AS INTEGER
DIM myarray4(0) AS INTEGER
LOCAL mypointers AS listOfPtr
LOCAL x AS INTEGER
LOCAL l1,u1, l2, u2, l3, u3, l4, u4 AS  INTEGER
mypointers.myvectors(0) = VARPTR(myarray1(0))
mypointers.myvectors(1) = VARPTR(myarray2(0))
mypointers.myvectors(2) = VARPTR(myarray3(0))
mypointers.myvectors(3) = VARPTR(myarray4(0))
myfunc(mypointers)
'PRINT UBOUND(myarray1())

FOR x = 0 TO 9
     PRINT myarray1(x)
     PRINT myarray2(x)
     PRINT myarray3(x)
     PRINT myarray4(x)
NEXT x

WAITKEY$
END FUNCTION

FUNCTION myfunc (BYVAL mypointers AS listOfPtr) AS INTEGER
DIM myarray1(10) AS INTEGER
DIM myarray2(10) AS INTEGER
DIM myarray3(10) AS INTEGER
DIM myarray4(10) AS INTEGER

LOCAL x AS INTEGER

FOR x =0 TO 9
    myarray1(x) = 9999+x
    myarray2(x) = 9999+x+1000
    myarray3(x) = 9999+x+2000
    myarray4(x) = 9999+x+3000
NEXT x
mypointers.myvectors(0) = VARPTR(myarray1(0))
mypointers.myvectors(1) = VARPTR(myarray2(0))
mypointers.myvectors(2) = VARPTR(myarray3(0))
mypointers.myvectors(3) = VARPTR(myarray4(0))
PRINT UBOUND(myarray1())
END FUNCTION
