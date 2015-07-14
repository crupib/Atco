#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG

    LOCAL hWin AS DWORD
    LOCAL lRes&


  GRAPHIC WINDOW "Paint", 0, 0, 200, 200 TO hWin

  GRAPHIC ATTACH hWin, 0



  ' Draw a circle with blue foreground color

  ' and a box below it with red foreground color.

  GRAPHIC ELLIPSE (10, 10) - (70, 70), %BLUE

  GRAPHIC BOX (10, 80) - (70, 120), 0, %RED



  ' Fill the area inside the circle's blue borders

  ' with a green diagonal pattern.

  GRAPHIC PAINT BORDER (40, 40), %GREEN, %BLUE, 6



  'Retrieve the color at point 5,5 (outside the circle).

  GRAPHIC GET PIXEL (5, 5) TO lRes&



  ' Fill the area outside the circle by replacing the color

  ' at point 5,5 and outwards with a solid yellow color.

  GRAPHIC PAINT REPLACE (5, 5), RGB(255, 255, 223), lRes&, 0



 WAITKEY$



END FUNCTION
