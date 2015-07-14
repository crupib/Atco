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
    LOCAL myx AS LONG
    LOCAL PixPerInch!, xScrn1!, yScrn1!, XScrn2!, yScrn2!, xSCRN&, ySCRN&
    LOCAL BackClr&, ForeClr&, PlotClr&, HighClr&, LowClr&, NormClr&, Clr1&, Clr2&, Clr3&
    LOCAL tempx1, tempx2, tempy1, tempy2 AS DOUBLE
    LOCAL tempSx1, tempSx2, tempSy1, tempSy2 AS SINGLE
    LOCAL myinput AS STRING
    DIM hWin(10)AS LOCAL LONG ' Graphic Window handles
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
    OPEN "axscan.dat" FOR BINARY AS #1 BASE = 0
    myoffset = 0
    '----------------------------------------------------------------------------------------------------

    'assigned even numbers for standard windows, direct display
    GRAPHIC WINDOW "NOZZLE 'Top View'", 10, 10, ySCRN&, xSCRN& TO hWin(0) 'Create a graphic window and assign it a handle
    GRAPHIC ATTACH hWin(0), 0&                                  'Select standard window
    GRAPHIC COLOR ForeClr&, BackClr&                            'Set foreground and  background color
    GRAPHIC CLEAR                                               'Clear selected window with background color
    GRAPHIC SCALE(yScrn1!,xScrn1!)-(yScrn2!,xScrn2!)

    WHILE ISFALSE EOF(1)

       clr1& = %RGB_LIGHTYELLOW
    'draw transducer sides x4 (rectangle)

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 8

        GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 8

        GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 8

        GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&


        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 8

        GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&

        'make sure all (4) corners of the rectangle are sealed before calling GRAPHIC PAINT, otherwise paint leaks out everywhere!!
        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8

        GRAPHIC SET PIXEL (tempy1,tempx1),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8

        GRAPHIC SET PIXEL (tempy1,tempx1),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8

        GRAPHIC SET PIXEL (tempy1,tempx1),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8

        GRAPHIC SET PIXEL (tempy1,tempx1),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 8
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 8

        GRAPHIC PAINT (tempy1, tempx1), %RGB_ORANGE, clr1&

        GET  #1, myoffset,  tempSy1
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSx1
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSy2
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSx2
        myoffset = myoffset + 4
        clr1& = %RGB_LIGHTYELLOW

        GRAPHIC LINE(tempSy1,tempSx1)-(tempSy2,tempSx2),clr1&  'RGB_WHITE 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO


        GET  #1, myoffset,  tempSy1
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSx1
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSy2
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSx2
        myoffset = myoffset + 4

        GRAPHIC LINE(tempSy1,tempSx1)-(tempSy2,tempSx2),clr1&

        GET  #1, myoffset,  tempSy1
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSx1
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSy2
        myoffset = myoffset + 4
        GET  #1, myoffset,  tempSx2
        myoffset = myoffset + 4
        GRAPHIC ELLIPSE (tempSy1,tempSx1)-(tempSy2,tempSx2), %RGB_WHITE, -1 'orange, -1 '%WHITE, -1 'clr1&

        SLEEP 25
        GRAPHIC CLEAR

        GRAPHIC INKEY$ TO MyInput
        IF MyInput = $ESC THEN Terminate

WEND
Terminate:

GRAPHIC WAITKEY$
END FUNCTION
