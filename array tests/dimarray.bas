#COMPILE EXE
#DIM ALL
TYPE listOfPtr
    myarrayPtr1 AS INTEGER POINTER
    myarrayPtr2 AS INTEGER POINTER
    myarrayPtr3 AS INTEGER POINTER
    myarrayPtr4 AS INTEGER POINTER
END TYPE

FUNCTION PBMAIN () AS LONG
DIM myarrayPtr AS INTEGER POINTER
DIM myarray1(0) AS INTEGER
DIM myarray2(0) AS INTEGER
DIM myarray3(0) AS INTEGER
DIM myarray4(0) AS INTEGER
LOCAL mypointers AS listOfPtr
LOCAL x AS INTEGER
LOCAL l1,u1, l2, u2, l3, u3, l4, u4 AS  INTEGER
mypointers.myarrayPtr1 = VARPTR(myarray1%(0))
mypointers.myarrayPtr2 = VARPTR(myarray2%(0))
mypointers.myarrayPtr3 = VARPTR(myarray3%(0))
mypointers.myarrayPtr4 = VARPTR(myarray4%(0))
myfunc(mypointers)
PRINT UBOUND(myarray1())
WAITKEY$
FOR x =1 TO 10
    PRINT myarray1(x)
    PRINT myarray2(x)
    PRINT myarray3(x)
    PRINT myarray4(x)
NEXT x

WAITKEY$
END FUNCTION

FUNCTION myfunc (BYVAL mypointers AS listOfPtr) AS INTEGER
REDIM myarray1(10) AS INTEGER AT mypointers.myarrayPtr1
REDIM myarray2(10) AS INTEGER AT mypointers.myarrayPtr2
REDIM myarray3(10) AS INTEGER AT mypointers.myarrayPtr3
REDIM myarray4(10) AS INTEGER AT mypointers.myarrayPtr4

LOCAL x AS INTEGER

FOR x =1 TO 10
    myarray1(x) = 9999+x
    myarray2(x) = 9999+x+1000
    myarray3(x) = 9999+x+2000
    myarray4(x) = 9999+x+3000
NEXT x
PRINT UBOUND(myarray1())
END FUNCTION
