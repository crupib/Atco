'==============================================================================
'
'  Demonstrates the use of an internal object
'
'==============================================================================


#COMPILER PBCC 6
#COMPILE EXE
#DIM ALL

%TRUE  =  1
%FALSE = -1

' MathClass contains the IPrime Interface for
' testing if a value is a prime number
CLASS MathClass

  INTERFACE IPrime
    INHERIT IUNKNOWN

    ' While not the fastest way to determine if a number is prime,
    ' it will work with any integer from -2^63 to 2^63 -1
    PROPERTY GET IsPrime(BYVAL n AS QUAD) AS LONG
      LOCAL i AS QUAD

      IF n < 2 THEN
        ' Any value less than two is not a prime number
        PROPERTY = %FALSE
        EXIT PROPERTY
      ELSEIF n = 2 THEN
        ' Two is a prime number
        PROPERTY = %TRUE
        EXIT PROPERTY
      END IF

      ' Test the value and see value can be diveded by
      ' any number between two and the value minus 1
      FOR i = 2 TO n-1
        IF (n MOD i) = 0 THEN
          ' Not a prime number
          PROPERTY = %FALSE
          EXIT PROPERTY
        END IF

      NEXT i

      ' The value is a prime number
      PROPERTY = %TRUE

    END PROPERTY

    PROPERTY GET Absolute(BYVAL n AS QUAD) AS LONG
      LOCAL i AS QUAD

      PROPERTY = -n

    END PROPERTY

  END INTERFACE

END CLASS

' Application main entry point
FUNCTION PBMAIN()
  LOCAL Prime AS IPrime           ' Object reference to the IPrime Interface
  LOCAL n     AS QUAD
  LOCAL Num   AS STRING

  ' Create an instance of the MathClass object
  Prime = CLASS "MathClass"

  DO
    INPUT "Please enter a number or Q to exit the program: ", Num
    IF UCASE$(Num) = "Q" THEN EXIT LOOP

    n = VAL(Num)

    ' Call the IsPrime method of the IPrime interface
    IF Prime.IsPrime(n) = %TRUE THEN
      PRINT num + " is a Prime Number."
    ELSE
      PRINT num + " is not a Prime Number."
    END IF
    PRINT "Absolute of n = " Prime.Absolute(n)

  LOOP

END FUNCTION
