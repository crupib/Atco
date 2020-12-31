#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
    LOCAL Count1 AS QUAD
    Count1 = 0
    CON.SCREEN = 100,100
    CON.LOC = 100,100
    DO WHILE Count1 < 10000
           CON.CELL = 50,50
           CON.PRINT "|"
           CON.CELL = 50,50
           CON.PRINT "/"
           CON.CELL = 50,50
           CON.PRINT "-"
           CON.CELL = 50,50
           CON.PRINT "|"
           CON.CELL = 50,50
           CON.PRINT "\"
           CON.CELL = 50,50
           CON.PRINT "-"
           CON.CELL = 50,50

           Count1 = Count1 + 1
    LOOP



END FUNCTION
