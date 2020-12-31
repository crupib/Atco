'==============================================================================
'
'  Martini.bas example for PowerBASIC for Windows
'  Copyright (c) 2011 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Demonstration of using the PowerThread object
'
'==============================================================================

#COMPILE EXE
#DIM ALL

' Embed the Martini images into the EXE file
#RESOURCE BITMAP,   Olive, "olive.bmp"
#RESOURCE BITMAP,   Onion, "onion.bmp"
#RESOURCE BITMAP,   Lemon, "lemon.bmp"
#RESOURCE BITMAP,   Lime,  "lime.bmp"

' Garnish equates
ENUM Garnish
  Olive = 1
  Onion
  Lemon
  Lime
END ENUM

%GR_WIDTH  = 320         ' Width of the graphic window
%GR_HEIGHT = 240         ' Height of the graphic window
%SPACER    = 5           ' Number of pixels between console and graphic window

' Martini Record
TYPE MartiniRec
  Gin      AS SINGLE     ' Ounces of Gin to use
  Vermouth AS SINGLE     ' Ounces of Vermouth to use
  Garnish  AS LONG       ' Type of garnish to use
  hGrWin   AS LONG       ' Handle to the graphic window
END TYPE

' Create the Martini Thread Object
CLASS cMartini
  ' Martini record passed to the Martinti Thread Object
  INSTANCE ThreadParam AS MartiniRec PTR

  ' Thread method that is automatically executed when the Thread is launched
  THREAD METHOD MAIN() AS LONG
    ' Attach the graphic window
    GRAPHIC ATTACH @ThreadParam.hGrWin, 0

    SELECT CASE @ThreadParam.Garnish
      CASE %Garnish.Olive:
        ' Display a Martini with a olive
        GRAPHIC RENDER "Olive", (0,0)-(%GR_WIDTH, %GR_HEIGHT)

      CASE %Garnish.Onion:
        ' Display a Martini with a onion
        GRAPHIC RENDER "Onion", (0,0)-(%GR_WIDTH, %GR_HEIGHT)

      CASE %Garnish.Lemon:
        ' Display a Martini with a lemom
        GRAPHIC RENDER "Lemon", (0,0)-(%GR_WIDTH, %GR_HEIGHT)

      CASE %Garnish.Lime:
        ' Display a Martini with a lime
        GRAPHIC RENDER "Lime", (0,0)-(%GR_WIDTH, %GR_HEIGHT)
    END SELECT
  END METHOD

  ' Inherit the methods and properties of the PowerThread object
  INTERFACE iMartini
    INHERIT IPOWERTHREAD
  END INTERFACE
END CLASS

' Application main entry point
FUNCTION PBMAIN
  LOCAL oMartini AS iMartini    ' Martini Thread Object
  LOCAL Martini  AS MartiniRec  ' Martini record
  LOCAL s        AS STRING      ' Retreived Textbox control text
  LOCAL i        AS LONG        ' Selected index of a Combobox control
  LOCAL w        AS LONG        ' Width of the desktop client area
  LOCAL h        AS LONG        ' Height of the desktop client area

  ' Reposition the console so that the console and graphic window are centered on the screen
  DESKTOP GET CLIENT TO w, h
  CON.LOC = (w - CON.SIZE.X + %GR_WIDTH + %SPACER)\2, (h-CON.SIZE.Y + %GR_HEIGHT)\2

  CON.PRINT "Martini PowerThread Sample"
  CON.PRINT

GetAmounts:
  INPUT "How many ounces of Gin? ", Martini.Gin
  INPUT "How many ounces of Vermouth? ", Martini.Vermouth

  IF (Martini.Gin) = 0 AND (Martini.Vermouth) = 0 THEN
    CON.PRINT "Please enter at least one ounce of Gin or Vermouth"
    GOTO GetAmounts
  END IF

GetGarnish:
  CON.PRINT
  CON.PRINT "Enter the type of garnish:"
  CON.PRINT "1) Olive"
  CON.PRINT "2) Onion"
  CON.PRINT "3) Lemon"
  CON.PRINT "4) Lime"

  s = CON.WAITKEY$
  Martini.Garnish = VAL(s)
  IF (Martini.Garnish < 1) OR (Martini.Garnish > 4) THEN
    CON.PRINT "Invalid garnish. Please try again"
    GOTO GetGarnish
  END IF

  SELECT CASE Martini.Garnish
    CASE %Garnish.Olive:
      CON.PRINT "Garnish = Olive"

    CASE %Garnish.Onion:
      CON.PRINT "Garnish = Onion"

    CASE %Garnish.Lemon:
      CON.PRINT "Garnish = Lemon"

    CASE %Garnish.Lime:
      CON.PRINT "Garnish = Lime"
  END SELECT

  ' Create the graphic window
  GRAPHIC WINDOW NEW "Martini", CON.LOC.X - %GR_WIDTH - %SPACER, CON.LOC.Y, 320, 240 TO Martini.hGrWin
  ' Do not allow the user to close the graphic window
  GRAPHIC WINDOW STABILIZE

  ' Create the Thread Object
  oMartini = CLASS "cMartini"

  ' Begin execution of the Thread Object and pass it the Martini record
  oMartini.Launch(BYVAL VARPTR(Martini))

  ' Wait till the thread has finished running
  WHILE oMartini.IsAlive
    ' Give some time slices back to windows to avoid using 100% of the cpu
    INCR i
    IF (i MOD 25) = 0 THEN SLEEP 1
  WEND

  ' Release the Thread Objects handle
  oMartini.Close

  CONSOLE SET FOCUS
  CON.PRINT
  CON.PRINT "Your Martini is served."
  CON.PRINT
  CON.PRINT "Press any key to exit."
  CON.WAITKEY$
END FUNCTION
