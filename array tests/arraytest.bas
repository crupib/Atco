#COMPILE EXE
#DIM ALL

DECLARE SUB SumElements(N%, A!(), SUM!)

FUNCTION PBMAIN()
   DIM MyArray(1000) AS SINGLE
   DIM MyMulti(10,10) AS SINGLE
   LOCAL Answer AS STRING
   LOCAL x,z AS INTEGER
   ' Initialize array with random numbers (just to have some values in)
   LOCAL i,j AS INTEGER
   LOCAL TOT AS SINGLE
   RANDOMIZE TIMER
   FOR I%=0 TO 1000
      MyArray(I%) = RND
   NEXT I%
   FOR I%=0 TO 10
       FOR J%=0 TO 10
           MyMulti(I,J) = RND
       NEXT J%
   NEXT I%

   CALL SumElements(ARRAYATTR(MyArray(),4), MyArray(), TOT!)
   CALL SumMultiElements(ARRAYATTR(MyMulti(),4), MyMulti(), TOT!)
   MSGBOX STR$(TOT!)

   FOR x = 0 TO 5

      Answer = Answer + FORMAT$(x)

      Answer = Answer + $TAB

      Answer = Answer + FORMAT$(ARRAYATTR(MyArray(),x))

      Answer = Answer + $CRLF

      MSGBOX  Answer


   NEXT x
   FOR x = 0 TO 5

      Answer = Answer + FORMAT$(x)

      Answer = Answer + $TAB

      Answer = Answer + FORMAT$(ARRAYATTR(MyMulti(),x))

      Answer = Answer + $CRLF

      MSGBOX  Answer

   NEXT x



END FUNCTION

SUB SumElements(M%, B!(), S!)
    LOCAL i,j AS INTEGER
    S! = 0
    FOR J%=0 TO M%
       S! = S! + B!(J%)
    NEXT J%
END SUB
SUB SumMultiElements(M%, B!(), S!)
    LOCAL l1,u1, l2, u2, l3, u3 AS  INTEGER
    LOCAL i,j AS INTEGER
    l1 = LBOUND(B!)
    u1 = UBOUND(B!())
    l2 = LBOUND(B!(2))
    u2 = UBOUND(B!,2)
    l3 = LBOUND(B!(3))
    u3 = UBOUND(B!,3)
    MSGBOX STR$(l1)
    MSGBOX STR$(u1)
    MSGBOX STR$(l2)
    MSGBOX STR$(u2)
    MSGBOX STR$(l3)
    MSGBOX STR$(u3)
    S! = 0
    FOR i%=l1 TO u1
       FOR j%=l2 TO u2
           S! = S! + B!(i%,j%)
       NEXT j%
    NEXT i%


END SUB
