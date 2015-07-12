'====================================================================
'
'Ellipitical 1
'
'====================================================================

#COMPILER PBCC 6
#CONSOLE OFF
#DIM ALL




FUNCTION PBMAIN
    'wlc
    LOCAL filename AS STRING
    LOCAL filenumber AS INTEGER
    LOCAL myoffset AS LONG
    LOCAL tempstr AS STRING
    LOCAL hFont&



    LOCAL eScale##


    '*******************************************************************************************
    ' Screen varibles
    '*******************************************************************************************
    LOCAL BackClr&, ForeClr&, PlotClr&, HighClr&, LowClr&, NormClr&, Clr1&, Clr2&, Clr3&
    DIM hWin(10)AS LOCAL LONG ' Graphic Window handles
    LOCAL hWinCheck& 'check if user closed window

    'LOCAL oStyle&   'copy image style

    'LOCAL wClick&, xClick!,yClick!  ' mouse click
    'LOCAL PixPerInch!, xPix1!, yPix1!, xPix2!, yPix2!
    'LOCAL xSCRN&, ySCRN&, xPixReal!, yPixReal! '

    LOCAL wClick&, xClick!,yClick!  ' mouse click
    LOCAL PixPerInch!, xScrn1!, yScrn1!, XScrn2!, yScrn2!, xSCRN&, ySCRN&
    LOCAL k$, key1&


    '*******************************************************************************************
    ' Screen plot settings
    '*******************************************************************************************

    ySCRN& = 1900 : xSCRN& = 1100

    ySCRN& = 1200 : xSCRN& = 1000

    ySCRN& = 1400: xSCRN& = 800

    PixPerInch! = 0.04!  '0.035! '0.05! '0.010! '.040!   ' graphic window size
    yScrn1! = -(ySCRN& * .400!* PixPerInch!) : yScrn2! = ySCRN& * .400!* PixPerInch!

    xScrn1! = -(xSCRN& * .400!* PixPerInch!) : xScrn2! = (xSCRN& * .400!* PixPerInch!)

    PlotClr& = %WHITE 'black 'white 'Black 'WHITE 'black '%yellow '%magenta '%RED '%Black '%magenta '%WHITE '%BLACK
    BackClr& = %BLACK 'rgb_darkblue 'magenta 'plum 'black 'rgb_darkgray 'white 'black 'rgb_snow '%RGB_whitesmoke '%RGB_Linen '%rgb_azure '%rgb_mistyrose ' %RGB_GHOSTWHITE '%RGB_SNOW '%blACK 'darkgray 'black 'white '%Yellow '%Magenta '%BLACK '%WHITE
    ForeClr& = PlotClr& '%WHITE '%BLACK


    'wlc
    filename = "axscan.dat"
    filenumber = FREEFILE
    OPEN filename FOR BINARY AS filenumber BASE = 0
    OPEN "axscan.dat" FOR OUTPUT AS filenumber

    '----------------------------------------------------------------------------------------------------

    'assigned even numbers for standard windows, direct display
    GRAPHIC WINDOW "NOZZLE 'Top View'", 10, 10, ySCRN&, xSCRN& TO hWin(0) 'Create a graphic window and assign it a handle
    GRAPHIC ATTACH hWin(0), 0&                                  'Select standard window
    GRAPHIC COLOR ForeClr&, BackClr&                            'Set foreground and  background color
    GRAPHIC CLEAR                                               'Clear selected window with background color
    GRAPHIC SCALE(yScrn1!,xScrn1!)-(yScrn2!,xScrn2!)


    GRAPHIC ATTACH hWin(0), 0&, REDRAW       'Select standard window
    'GRAPHIC WINDOW STABILIZE hWin(0) 'user can't close window
    GRAPHIC SET FOCUS

    'GRAPHIC BITMAP NEW ; GRAPHIC BITMAP END; GRAPHIC COPY; GRAPHIC CLEAR

    '------------------------------------------------------------------

    'FONT NEW "Times New Roman", 10, 1 TO hFont&
    'GRAPHIC SET FONT hFont&

    FONT NEW "Times New Roman", 20, 1 TO hFont&
    GRAPHIC SET FONT hFont&


    clr1& = %RGB_LIGHTYELLOW

    'draw transducer sides x4 (rectangle)
    GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),clr1&  'RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    tempstr = MKD$( y(3))
    PUT$ filenumber,  tempstr
    tempstr = MKD$(x(3))
    PUT$ filenumber, tempstr
    tempstr = MKD$(y(4))
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(4) )
    PUT$ filenumber, tempstr


    GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),clr1&  'RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    tempstr = MKD$( y(5))
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(5))
    PUT$ filenumber, tempstr
    tempstr = MKD$(y(6))
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(6) )
    PUT$ filenumber, tempstr
    GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),clr1&  'RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO
    tempstr = MKD$( y(3))
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(3))
    PUT$ filenumber, tempstr
    tempstr = MKD$(y(5))
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(5) )
    PUT$ filenumber, tempstr


    GRAPHIC LINE(y(4),x(4))-(y(6),x(6)),clr1& 'RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    tempstr = MKD$( y(4))
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(4))
    PUT$ filenumber, tempstr
    tempstr = MKD$(y(6))
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(6) )
    PUT$ filenumber, tempstr

    'make sure all (4) corners of the rectangle are sealed before calling GRAPHIC PAINT, otherwise paint leaks out everywhere!!
    GRAPHIC SET PIXEL (y(3),x(3)),clr1&

    tempstr = MKD$(y(3) )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(3) )
    PUT$ filenumber, tempstr
    GRAPHIC SET PIXEL (y(4),x(4)),clr1&
    tempstr = MKD$(y(4) )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(4) )
    PUT$ filenumber, tempstr
    GRAPHIC SET PIXEL (y(5),x(5)),clr1&
    tempstr = MKD$(y(5) )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(5) )
    PUT$ filenumber, tempstr
    GRAPHIC SET PIXEL (y(6),x(6)),clr1&
    tempstr = MKD$(y(6) )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(6) )
    PUT$ filenumber, tempstr

    GRAPHIC PAINT (y(8), x(8)), %RGB_ORANGE, clr1&

    tempstr = MKD$(y(8) )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x(8) )
    PUT$ filenumber, tempstr


    GRAPHIC LINE(y1!,x1!)-(y2!,x2!),%RGB_WHITE 'RGB_WHITE 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    tempstr = MKD$(y1! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x1! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(y2! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x2! )
    PUT$ filenumber, tempstr

    GRAPHIC PAINT (y(8), x(8)), %RGB_ORANGE, clr1&

    '***********************************************************************************************************
    'draw line through index position along transducer length
    '***********************************************************************************************************

    '{cos B = (c^2 + a^2 - b^2)/2ca}  a## = aProbeXpos## : c## = haloRad## : b## = SQR(SQ(c##)-SQ(a##))
    'get angle of halo radius line, measured from current normal angle {cos B = (c^2 + a^2 - b^2)/2ca}
    'angleRads## = ArcCos((SQ(haloRad##)+SQ(aProbeXpos##)-(SQ(haloRad##)-SQ(aProbeXpos##)))/(2*haloRad##*aProbeXpos##))

'    angleRads## = ArcCos(aProbeXPos##/haloRad##)'simpler than above, appears to work same as above, left it just in case!!

    thetaRads## = eNormAngle(zCtr&) 'normal angle +90 of ellipse X,Y position
    x1! = haloRad## * COS(thetaRads##)+ xPos2## 'get real xPos of current angle
    y1! = haloRad## * SIN(thetaRads##)+ yPos2## 'get real yPos of current angle

    thetaRads## = eNormAngle(zCtr&) 'normal angle -90 of ellipse X,Y position
    x2! = xPos2## - (haloRad## * COS(thetaRads##)) 'get real xPos of current angle
    y2! = yPos2## - (haloRad## * SIN(thetaRads##)) 'get real yPos of current angle

    GRAPHIC LINE(y1!,x1!)-(y2!,x2!),%RGB_WHITE 'RGB_WHITE 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO
    tempstr = MKD$(y1! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x1! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(y2! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x2! )
    PUT$ filenumber, tempstr

    'meatball at x,y transducer center
    x1! = xPos2## - 0.100## 'transducer x position
    y1! = yPos2## - 0.100## 'transducer y position
    x2! = xPos2## + 0.100## 'x1!  'transducer x position
    y2! = yPos2## + 0.100## 'y1!-10.00! 'transducer y position - 10"
    GRAPHIC ELLIPSE (y1!,x1!)-(y2!,x2!), %RGB_BLACK, -1 'orange, -1 '%WHITE, -1 'clr1&
    tempstr = MKD$(y1! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x1! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(y2! )
    PUT$ filenumber, tempstr
    tempstr = MKD$(x2! )
    PUT$ filenumber, tempstr

    RETURN






PlotPipe:

    RETURN

    scanRad## = pipeRado## + 4.00##
    scanDia## = scanRad## * 2.00##
    scanCirc## = scanDia## * Pi
    scanCircRatio## = 1.00##/scanCirc##


'   thetaRads## = Rads270 + ( (x(9)/pipeCirc##) * Rads360 ) 'OR  thetaRads## = Rads270 + ( x(9) * pipeCircRatio## * Rads360 )
'   x1! = 0              'x position radius center
'   y1! = yScrnOffset##  'y position radius center
'   x2! = pipeRado##*COS(thetaRads##)                 'x position, outer radius
'   y2!=( pipeRado##*sin(thetaRads##) )+yScrnOffset## 'y position, outer radius


    'draw current transducer position and angle on pipe radius
    '***************************************************************************************************************************************
    hNormAngle## = Rads270 + ( x(9) * pipeCircRatio## * Rads360 )
    x(10) = 0              'x position radius center
    y(10) = yScrnOffset##  'y position radius center
    x(11) = scanRad##*COS(hNormAngle##)                 'x position, outer radius
    y(11)=( scanRad##*SIN(hNormAngle##) )+yScrnOffset## 'y position, outer radius
    GRAPHIC LINE(y(10),x(10))-(y(11),x(11)), %RGB_HOTPINK 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO


    'draw reference line +/-90 degrees from current transducer angle
    thetaRads## = (hNormAngle##+Rads90) MOD 360
    x(13) = (haloRad##) * COS(thetaRads##)+ x(11) 'get real xPos of current angle
    y(13) = (haloRad##) * SIN(thetaRads##)+ y(11) 'get real xPos of current angle

    thetaRads## = (hNormAngle##-Rads90) MOD 360
    x(12) = (haloRad##) * COS(thetaRads##)+ x(11) 'get real xPos of current angle
    y(12) = (haloRad##) * SIN(thetaRads##)+ y(11) 'get real xPos of current angle

    GRAPHIC LINE(y(12),x(12))-(y(13),x(13)), %RGB_HOTPINK 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO
    '***************************************************************************************************************************************



    'draw current halo center position and angle
    '***************************************************************************************************************************************
    hNormAngle## = Rads270 + ( xPos2## * pipeCircRatio## * Rads360 )
    'x(10) = 0              'x position radius center
    'y(10) = yScrnOffset##  'y position radius center
    x(14) = scanRad##*COS(hNormAngle##)                 'x position, outer radius
    y(14)=( scanRad##*SIN(hNormAngle##) )+yScrnOffset## 'y position, outer radius
    GRAPHIC LINE(y(10),x(10))-(y(14),x(14)), %RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    'draw reference line +/-90 degrees from current halo angle
    thetaRads## = (hNormAngle##+Rads90) MOD 360
    x(16) = (haloRad##) * COS(thetaRads##)+ x(14) 'get real xPos of current angle
    y(16) = (haloRad##) * SIN(thetaRads##)+ y(14) 'get real xPos of current angle
    thetaRads## = (hNormAngle##-Rads90) MOD 360
    x(15) = (haloRad##) * COS(thetaRads##)+ x(14) 'get real xPos of current angle
    y(15) = (haloRad##) * SIN(thetaRads##)+ y(14) 'get real xPos of current angle
    GRAPHIC LINE(y(15),x(15))-(y(16),x(16)), %RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO
    '***************************************************************************************************************************************


    RETURN



DrawPipe:

   RETURN
   '----------------------------------------------------------------------------------------------------------
    'draw pipe
    '----------------------------------------------------------------------------------------------------------
    GRAPHIC WIDTH 2& 'set the line width

    clr1& = %RGB_DARKGRAY 'outside edge line 'WHITE 'RGB_LIGHTYELLOW ' 'LIGHTGOLDENRODYELLOW '%RGB_red 'crimson 'hotPINK 'YELLOW
    clr2& = %RGB_BLACK 'darkgray 'gold  'paint inside

    pipeRadi## = 41.624## * half
    pipeRado## = pipeRadi## + 4.00##
    pipeDia## = pipeRado## * 2.00##
    pipeCirc## = pipeDia## * Pi
    pipeCircRatio## = 1.00##/pipeCirc## 'pipe circumference ratio


    yScrnOffset## =65.00##

    thetaRads## = DegToRads(200) '(20) '180
    cosA## = COS(thetaRads##) : sinA## = SIN(thetaRads##)
    x1i! = pipeRadi## * cosA## 'x position of inner radius
    y1i! = (pipeRadi## * sinA##)+yScrnOffset## 'y position of inner radius
    x1o! = pipeRado## * cosA## 'x position of outer radius
    y1o! = (pipeRado## * sinA##)+yScrnOffset## 'y position of outer radius


    FOR n% = 201 TO 340 '21 to 160 '181 TO 360 '45 '180 'set to 720 for half degree steps

        theta##=n%
        thetaRads## = DegToRads(theta##)
        cosA## = COS(thetaRads##) : sinA## = SIN(thetaRads##)
        x2i! = pipeRadi## * cosA## 'x position of inner radius
        y2i! =(pipeRadi## * sinA##)+yScrnOffset## 'y position of inner radius
        x2o! = pipeRado## * cosA## 'x position of outer radius
        y2o! =(pipeRado## * sinA##)+yScrnOffset## 'y position of outer radius

        GRAPHIC LINE(y1o!,x1o!)-(y2o!,x2o!),clr1& 'draw OD chord
        GRAPHIC LINE(y1i!,x1i!)-(y2i!,x2i!),clr1& 'draw ID chord

        IF n% = 201 THEN  'draw a line ID to OD at start
           GRAPHIC LINE(y1i!,x1i!)-(y1o!,x1o!),clr1&
           GRAPHIC SET PIXEL(y1i!,x1i!),clr1&
           GRAPHIC SET PIXEL(y1o!,x1o!),clr1&
        ELSEIF n% = 340 THEN  ' draw a line ID to OD at end
           GRAPHIC LINE(y2i!,x2i!)-(y2o!,x2o!),clr1&
           GRAPHIC SET PIXEL(y2i!,x2i!),clr1&
           GRAPHIC SET PIXEL(y2o!,x2o!),clr1&
        END IF

        y1i! = y2i! : x1i! = x2i! : y1o! = y2o! : x1o! = x2o! 'transfer current data to next starting point

    NEXT



    'paint the pipe!!
    temp1## = ( (pipeRado##-pipeRadi##)*half )+ pipeRadi## 'center of thickness radius
    thetaRads## = DegToRads(270) '(20) '180
    cosA## = COS(thetaRads##) : sinA## = SIN(thetaRads##)
    x1i! =  temp1## * cosA## 'x position pipe centerwall
    y1i! = (temp1## * sinA##) + yScrnOffset## 'y position pipe centerwall
    GRAPHIC PAINT(y1i!,x1i!),clr2&, clr1&


    RETURN



doMouse:

   GRAPHIC WINDOW CLICK hwin(0) TO wclick&, xClick!, yClick!
   IF wClick& THEN 'mouse click
      'beep
      sTxt(0)="xMouse :"+ STR$(xClick!)+  "            "
      sTxt(1)="yMouse :"+ STR$(yClick!)+  "            "
      GRAPHIC SET POS (-30.00!,-10.00!) : GRAPHIC PRINT sTxt(0)
      GRAPHIC SET POS (-30.00!,-9.00!) :  GRAPHIC PRINT sTxt(1)
      GRAPHIC REDRAW
      'SLEEP 100
   END IF

   RETURN
   'End Program:

ProcessKey:

   ' BEEP
    GRAPHIC INKEY$ TO k$
    'Graphic inkey$ to k$

            'Graphic inkey$ to
   'PixPerInch! = PixPerInch! + 0.001! '0.05! '0.010! '.040!   ' graphic window size
   'yScrn1! = -(ySCRN& * 0.500!* PixPerInch!) : yScrn2! = ySCRN& * 0.500!* PixPerInch!
   'xScrn1! = -(xSCRN& * 0.500!* PixPerInch!) : xScrn2! = xSCRN& * 0.500!* PixPerInch!
   'GRAPHIC ATTACH hWin(4), 0&
   'GRAPHIC ATTACH hWin(0), 0&                                  'Select standard window
   'GRAPHIC SCALE(yScrn1!,xScrn1!)-(yScrn2!,xScrn2!)

   RETURN

exitWindows:

      'Close and exit all windows
    GRAPHIC ATTACH hWin(0), 0&  'select the STANDARD Graphics window
    GRAPHIC WINDOW END          'close the selected STANDARD Graphics window

    GRAPHIC ATTACH hWin(1), 0&  'select the Memory Bitmap Graphics window
    GRAPHIC BITMAP END          'close the selected Memory Bitmap Graphics window

'    GRAPHIC ATTACH hWin(2), 0&  'select the Memory Bitmap Graphics window
'    GRAPHIC BITMAP END          'close the selected Memory Bitmap Graphics window

'    GRAPHIC ATTACH hWin(3), 0&  'select the Memory Bitmap Graphics window
'    GRAPHIC BITMAP END          'close the selected Memory Bitmap Graphics window

'    GRAPHIC ATTACH hWin(4), 0&  'select the Memory Bitmap Graphics window
'    GRAPHIC BITMAP END          'close the selected Memory Bitmap Graphics window

    BEEP


   END FUNCTION
