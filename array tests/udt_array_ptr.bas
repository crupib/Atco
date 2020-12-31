#COMPILE EXE
#DIM ALL


FUNCTION array_fill_random(a() AS LONG, n1 AS LONG, n2 AS LONG) AS LONG
    LOCAL i, n, r AS LONG

    FOR i = LBOUND(a) TO UBOUND(a)
        r = RND(n1, n2)
        a(i) = r
    NEXT
END FUNCTION
'-------------------------------
FUNCTION array_fill_random_by_ptr(p AS DWORD, n1 AS LONG, n2 AS LONG) AS LONG
    LOCAL i, n, r AS LONG
    DIM a (1 TO 10) AS LONG AT p

    FOR i = LBOUND(a) TO UBOUND(a)
        r = RND(n1, n2)
        a(i) = r
    NEXT
END FUNCTION

FUNCTION PBMAIN () AS LONG
    LOCAL i AS LONG
    LOCAL x() AS LONG
    LOCAL s1, s2 AS STRING
    LOCAL p AS DWORD
    ' as array
    DIM x(1 TO 10)
    array_fill_random(x(), 100, 200)
    FOR i = LBOUND(x) TO UBOUND(x)
        s1 += STR$(i) + STR$(x(i)) + $CRLF
    NEXT
    ' by pointer, pointer does not provide the array boundaries
    p = VARPTR(x(1))
    array_fill_random_by_ptr(p, 100, 200)
    FOR i = LBOUND(x) TO UBOUND(x)
        s2 += STR$(i) + STR$(x(i)) + $CRLF
    NEXT
    ? s1 + $CRLF + $CRLF + s2
END FUNCTION
