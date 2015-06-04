#COMPILE EXE
#DIM ALL

DECLARE SUB SumElements(N%, A!(), SUM!)

FUNCTION PBMAIN()
   DIM MyArray(1000) AS SINGLE

   ' Initialize array with random numbers (just to have some values in)
   LOCAL i AS INTEGER
   LOCAL TOT AS SINGLE
   RANDOMIZE TIMER
   FOR I%=0 TO 1000
      MyArray(I%) = RND
   NEXT I%

   CALL SumElements(100, MyArray(), TOT!)

   MSGBOX STR$(TOT!)


END FUNCTION

SUB SumElements(M%, B!(), S!)
    LOCAL j AS INTEGER
    S! = 0
    FOR J%=0 TO M%
       S! = S! + B!(J%)
    NEXT J%
END SUB
