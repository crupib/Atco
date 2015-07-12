'====================================================================
'
'Ellipitical 1
'
'====================================================================

#COMPILER PBCC 6
#CONSOLE OFF
#DIM ALL

MACRO Pi =  3.14159265358979323846##

MACRO DegToRads(dpDegrees) = (dpDegrees * 0.0174532925199433##)
MACRO RadsToDeg(dpRadians) = (dpRadians*57.29577951308232##)

MACRO ArcCos(CosA) = ( Pi / 2 - ATN(CosA / SQR(1 - CosA * CosA)) )  'ArcCos in radians
MACRO ArcCosA(CosA) = ( ArcCos(CosA)*57.29577951308232## )'ArcCos in degrees

MACRO ArcSin(SinA) = ATN(SinA / SQR(1 - SinA * SinA))'ArcSin in radians
MACRO ArcSinA(SinA) = ( ArcSin(SinA)*57.29577951308232## )'ArcSin in degrees'

MACRO SQ(SquareIt) = (SquareIt*SquareIt) 'Macro to square a number, because ProBasic doesn't like the use of ^caret in all cases

MACRO CONST = MACRO
CONST Rads0 = (0.000##)
CONST Rads45 = (Pi*0.250##)
CONST Rads90 = (Pi*0.500##)
CONST Rads135 = (Pi*0.750##)
CONST Rads180 = (Pi)
CONST Rads225 = (Pi*1.250##)
CONST Rads270 = (Pi*1.500##)
CONST Rads315 = (Pi*1.750##)
CONST Rads360 = (Pi*2.000##)
CONST Rads540 = (Pi*3.000##)

CONST Rads0inv = Rads360    'for Scan begin, Rads0inv + Rads360 = 360 degrees, with MOD360 equals 0 degrees
CONST Rads90inv = Rads270   ' "
CONST Rads180inv = Rads180  ' "
CONST Rads270inv = Rads90   ' "


CONST DegRatio= (1.00##/360.00##)
CONST RadsRatio =(1.00##/ (Pi*2.00##) )'/360.00## )
CONST Half = (0.500##)
CONST Forth = (0.250##)
CONST TRUE = (-1)
CONST FALSE = (NOT -1)



'**********************************************************************************************************************************************
'USER DEFINED FUNCTIONS

'----------------------------------------------------------------------------------------------------------------------------------------------
'Translate +/-degree's to 0-360 degree values
'X =xPos, Y =yPos, A =angle
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetX360(BYVAL X##, BYVAL Y##, BYVAL A##) AS EXT
    IF (X##=>0) AND (Y##=>0) THEN
       FUNCTION = A##               'Quadrant(1),0-90 degrees,+COS(X),+SIN(Y) A## = 0 to 90
    ELSEIF (X##<0) AND (Y##>0) THEN
       FUNCTION = A##+180           'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y) A## = -89.999 to 0
    ELSEIF (X##=<0)AND (Y##<=0)THEN
       FUNCTION = A##+180           'Quadrant(3),180-270 degrees,-COS(X),-SIN(Y) A## = 0 to 90
    ELSEIF (X##>0) AND (Y##<0) THEN
       FUNCTION = A##+360           'Quadrant(4),270-360 degrees,+COS(X),-SIN(Y) A## = -89.999 to 0
    END IF
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Translate NORMAL ANGLE to 0-360 degree values  A## = Normal angle measured from foci 2 (foci 1 is opposite)
'X =xPos, Y =yPos, A =angle
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetN360(BYVAL X##, BYVAL Y##, BYVAL A##) AS EXT
    IF (X##>0) AND (Y##=0) THEN       'Single case only: X is on positive side, Y is at 0, can only be @ 0 degrees
       FUNCTION = 0##
    ELSEIF (X##<0) AND (Y##=0) THEN   'Single case only: X is on negative side, Y is at 0, can only be @ 180 degrees
       FUNCTION = Rads180
    ELSEIF (X##=>0) AND (Y##=>0) THEN 'Quadrant(1), 0-90 degrees, +COS(X),+SIN(Y)   (foci2)A## = 0 to 90 (foci1= 180 to 90)
       FUNCTION = A##
    ELSEIF (X##<0) AND (Y##>0) THEN   'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y)  (foci2)A## = 90 to 180 (foci1= 90 to 0)
       FUNCTION = A##
    ELSEIF (X##=<0)AND (Y##<=0)THEN   'Quadrant(3), 180-270 degrees,-COS(X),-SIN(Y) (foci2)A## = 180 to 90 (foci1= 0 to 90)
       FUNCTION = (Rads180-A##)+ Pi
    ELSEIF (X##>0) AND (Y##<0) THEN   'Quadrant(4), 270-360 degrees,+COS(X),-SIN(Y) (foci2)A## = 90 to 0 (foci1= 90 to 180)
       FUNCTION = (Rads90-A##) + Rads270
    END IF
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Find radius of any foci point:  RADIUS = (r1*r2)^3^.5 / (MajorAxisRadius*MinorAxisRadius)
' F1L=foci1 length,F2L=foci2 length,LAR=Major Axis Radius, SAR=Minor Axis Radius
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadiusE (BYVAL F1L##, BYVAL F2L##, BYVAL LAR##, BYVAL SAR##) AS EXT
     FUNCTION = (F1L##*F2L##)^3^.5 / (LAR##*SAR##)
     'angleArads## = ArcSin(ABS(YP(n%))/GetRadius##)
     'angleB## = 90-AngleA##
     'x## = XP(n%) - ABS((YP(n%)/ Tan(angleArads##)
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Find Major Axis Radius:  RADIUS = MinorAxisRadius^2 / MajorAxisRadius
' LAR=Major Axis Radius, SAR=Minor Axis Radius
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadiusL (BYVAL LAR##, BYVAL SAR##) AS EXT
         FUNCTION = SAR##^2 / LAR##
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Find Minor Axis Radius:  RADIUS = MinorAxisRadius^2 / MajorAxisRadius
' LAR=Major Axis Radius, SAR=Minor Axis Radius
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadiusS (BYVAL LAR##, BYVAL SAR##) AS EXT
         FUNCTION = LAR##^2 / SAR##
END FUNCTION



'END DEFINED FUNCTIONS
'**********************************************************************************************************************************************

TYPE ELLIPSE

   MajorDia AS EXT
   MinorDia AS EXT
   '
   MajorRad AS EXT
   MinorRad AS EXT
   '
   xIndex AS EXT
   yindex AS EXT
   '
   xStart AS EXT
   xEnd AS EXT
   '
   yStart AS EXT
   yEnd AS EXT
   '
   xCounts AS EXT
   yCounts AS EXT

END TYPE



TYPE ScanParms
   YCtr          AS SINGLE       'YCts/inch
   XCtr          AS SINGLE       'XCts/inch
   ACtr          AS SINGLE       'Aux Enc Cts/inch
   YCal          AS SINGLE       'Y Cal Inch distance
   XCal          AS SINGLE       'X Cal Inch distance
   ACal          AS SINGLE       'Aux Cal Inch distance
   XOffset       AS SINGLE       'X inch pos when counter zeroed
   YOffset       AS SINGLE       'Y inch pos when counter zeroed
   AOffset       AS SINGLE       'A Inch pos when counter zeroed
   XPos          AS SINGLE       'current X inch position
   YPos          AS SINGLE       'current Y inch position
   APos          AS SINGLE       'current A inch position
   XPlus         AS INTEGER      'X scan +/-
   YPlus         AS INTEGER      'Y scan +/-
   XDataStart    AS LONG         'x array position for scan start
   YDataStart    AS LONG         'y array position for scan start
   XDataEnd      AS LONG         'x array position for scan end
   YDataEnd      AS LONG         'y array position for scan end
   XIndex        AS SINGLE       'x inch index
   YIndex        AS SINGLE       'y inch index
   XIndexCts     AS LONG         'x actual value (+/-) counts per index
   YIndexCts     AS LONG         'y actual value (+/-) counts per index
   IndexLow      AS INTEGER      'Index towards High or Low
   XCts          AS LONG         'x absolute value scan start counts
   YCts          AS LONG         'y absolute value scan start counts
   ACts          AS LONG         'A absolute value scan start counts
   XStartCts     AS LONG         'x actual value (+/-) scan start counts
   YStartCts     AS LONG         'y actual value (+/-) scan start counts
   XEndCts       AS LONG         'x actual value (+/-) scan end counts
   YEndCts       AS LONG         'y actual value (+/-) scan end counts
   XLow          AS SINGLE       'x scan start inch position
   YLow          AS SINGLE       'y scan start inch position
   XHigh         AS SINGLE       'x scan end inch position
   YHigh         AS SINGLE       'y scan end inch position
   OverLap       AS SINGLE       'added si scan overlap
   XSpeed        AS SINGLE       'x scan speed in inches
   YSpeed        AS SINGLE       'y scan speed in inches
   XEnable       AS INTEGER      'flag true/false X axis on
   YEnable       AS INTEGER      'flag true/false Y axis on
   XSpdDir       AS INTEGER      'flag X speed cntrl direction
   IndexY        AS INTEGER      'flag true/false X or Y
   StopChk       AS INTEGER      'flag true/false autoOff on/off
   DualRas     AS INTEGER      'flag true/false step index
   AutoHold      AS INTEGER      'flag true/false Auto Hold
   IndexCt AS INTEGER            'index loop counter
   IndexInc AS INTEGER           'index loop incrementer
   ScanFlag AS INTEGER           '
   Index AS INTEGER              'scan direction
   NextFlag AS INTEGER           'added for si auto scan increment
   YCtrStr AS STRING * 10
   XCtrStr AS STRING * 10
   ACtrStr AS STRING * 10
   YCalStr AS STRING * 10      'Y Cal Inch distance
   XCalStr AS STRING * 10      'X Cal Inch distance
   ACalStr AS STRING * 10      'A Cal Inch distance
   XPosStr AS STRING * 10
   YPosStr AS STRING * 10
   APosStr AS STRING * 10
   XPlusSTR AS STRING * 10
   YPlusSTR AS STRING * 10
   XIndexSTR AS STRING * 10
   YIndexSTR AS STRING * 10
   IndexLowStr AS STRING * 10
   XLowStr AS STRING * 10
   YLowStr AS STRING * 10
   XHighStr AS STRING * 10
   YHighStr AS STRING * 10
   OverLapStr AS STRING * 10
   XSpeedSTR AS STRING * 10
   YSpeedSTR AS STRING * 10
   XEnableSTR AS STRING * 10
   YEnableSTR AS STRING * 10
   XSpdDirSTR AS STRING * 10
   IndexYSTR AS STRING * 10
   StopChkSTR AS STRING * 10
   DualRasSTR AS STRING * 10
   NextFlagSTR AS STRING * 10
   AutoHoldSTR AS STRING * 10
  END TYPE
  GLOBAL Scanner AS scanparms



FUNCTION PBMAIN
    'wlc
    GLOBAL filename AS STRING
    GLOBAL filenumber AS INTEGER
    LOCAL myoffset AS LONG
    GLOBAL tempstr AS STRING
    LOCAL hFont&

    LOCAL xPlot&, yPlot&, MajorAxis##, MinorAxis##, ScaleMajor##, ScaleMinor##, majorAxisRad##, minorAxisRad##

    LOCAL eScale##

    LOCAL kbd$,i$

    LOCAL thetaS##, thetaE##, thetaInc##, thetaInv##, xCenter&, yCenter&, x1!, y1!, x2!, y2!, pX1%, pY1%, pX2%, pY2%

    LOCAL n%, nMax%, sCtr%, doneCtr%, doneCtr1%, doneCtr2%, doneRatio!, lCtr&, yCtr&, xCtr&, zCtr&, iCtr&  'loop counters

    LOCAL periL##, setIndex##, arcIndex##

    LOCAL xCol%, yRow% 'text position

    DIM sTxt(30) AS STRING

    '*******************************************************************************************
    ' Storage Arrays
    '*******************************************************************************************
    DIM eXpos(10000) AS LOCAL EXT      '(XP) X real position of referenced point along ellipse perimeter.
    DIM eYpos(10000) AS LOCAL EXT      '(YP) Y real position of referenced point along ellipse perimeter.
    DIM eNormXpos(10000) AS LOCAL EXT  'X real position of normal angle vector to referenced point along ellipse perimeter.
    DIM eNormYpos(10000) AS LOCAL EXT  'Y real position of normal angle vector to referenced point along ellipse perimeter.
    DIM eNormAngle(10000) AS LOCAL EXT 'Normal angle to referenced point along ellipse perimeter.
    DIM eRotAngle(10000) AS LOCAL EXT  'Rotational transducer angle
    DIM eNormRad(10000) AS LOCAL EXT   'Normal angle Radius.
   'DIM eCtrAngle(10000) AS LOCAL EXT  'Angle 0-360: center of ellipse to each X,Y point along ellipse perimeter.
    DIM eChord(10000) AS LOCAL EXT     'Chord length
    DIM eArcSeg(10000) AS LOCAL EXT    'Individual Arc Segment length per index
    DIM eArcTotal(10000) AS LOCAL EXT    'Total Arc Segment length at current index
    DIM sXpos(10000) AS LOCAL EXT      'Scan X real position
    DIM sYpos(10000) AS LOCAL EXT      'Scan Y real position

    DIM wXpos(10000) AS LOCAL EXT      'Weld Toe X real position
    DIM wYpos(10000) AS LOCAL EXT      'Weld Toe Y real position

    LOCAL AccumError## 'error accumulator
    LOCAL xPos1##, yPos1##, xPos2##, yPos2##, eXpos1##, eYpos1##, eXpos2##, eYpos2##, fXpos1##, fYpos1##, fXpos2##, fYpos2##
    LOCAL angleA1##, angleA2##
    LOCAL foci##, fociX2##, radF1##, radF2##, angleFiaRads##, angleFia##, angleF2Rads##, angleF2##, angleF1Rads##, angleF1##
    LOCAL angleNF1##, angleNF1Rads##, radNF1##, nXF1##
    LOCAL angleNF2##, angleNF2Rads##, radNF2##, nXF2##
    LOCAL angleFia2##, angleFia2Rads##
    LOCAL angleA1Rads##, angleA2Rads##, arcSegment##

    '*******************************************************************************************
    ' Segment calculation varibles
    '*******************************************************************************************
    LOCAL theta##, thetaRads##, theta2##

    '*******************************************************************************************
    'Scanner and Scan varibles
    '*******************************************************************************************
    LOCAL yStroke##, xMajor##, yMinor##, s1&, s2&, start1&, start2&, step1&, indexIncR##
    LOCAL yStart!, yEnd!, yIndex!, yOffset!,xOffset!

    LOCAL haloDia##, haloRad##, s1R##, s2R##, start1R##, start2R##, step1R##, indexR##, yMove!, xMove!
    LOCAL x1i!, x2i!, y1i!, y2i!, x1o!, x2o!, y1o!, y2o! 'halo plot lines: inner & outer radius
    LOCAL haloRadi##, haloRado##, haloRadc##, haloRadp##, cosA##, sinA##, angle##, angleRads##, a##,b##,c##

    LOCAL pipeRadi##, pipeRado##, pipeDia##, pipeCirc##, pipeCircRatio##, scanRad##, scanDia##, scanCirc##, scanCircRatio##
    LOCAL  hNormAngle##


    DIM x(20) AS LOCAL DOUBLE
    DIM y(20) AS LOCAL DOUBLE
    DIM offset(20) AS LOCAL DOUBLE

    'transducer positioning within halo
    LOCAL cProbeWidth##,cProbeLen##,cProbeIdx##,cProbeYpos##,cProbeXpos##,cProbeOffset##
    LOCAL aProbeWidth##,aProbeLen##,aProbeIdx##,aProbeYpos##,aProbeXpos##,aProbeOffset##
    LOCAL cProbeRad##, aProbeRad## 'effective radius, keep Halo radial excursion in check


    'transducer skew
    LOCAL pSkew##, pSkewRads##

    LOCAL weldWidth##, weldHaz##', Offset##

    LOCAL timeB##,timeE##,timeT##,TimeS##

    '********************************************************************************************
    ' Temps
    '********************************************************************************************
    LOCAL temp1##, temp2##, temp3##, temp4##, temp5##, tmpA&, tmpB&,tmpC&

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
    LOCAL yScrnOffset##
    myoffset = 0
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
    'OPEN filename FOR BINARY AS filenumber BASE = 0
    OPEN "axscan.dat" FOR OUTPUT AS filenumber

    '----------------------------------------------------------------------------------------------------

    'assigned even numbers for standard windows, direct display
    GRAPHIC WINDOW "NOZZLE 'Top View'", 10, 10, ySCRN&, xSCRN& TO hWin(0) 'Create a graphic window and assign it a handle
    GRAPHIC ATTACH hWin(0), 0&                                  'Select standard window
    GRAPHIC COLOR ForeClr&, BackClr&                            'Set foreground and  background color
    GRAPHIC CLEAR                                               'Clear selected window with background color
    GRAPHIC SCALE(yScrn1!,xScrn1!)-(yScrn2!,xScrn2!)

    'assigned odd numbers for bitmaps or special use windows, used to store static images for copying to standard window
    GRAPHIC BITMAP NEW ySCRN&, xSCRN& TO hWin(1) 'bitmap window for ellipse
    GRAPHIC ATTACH hWin(1), 0&                   'Select bitmap window #1
    GRAPHIC COLOR ForeClr&, BackClr&             'Set foreground and  background color
    GRAPHIC CLEAR                                'Clear selected window with background color
    GRAPHIC SCALE(yScrn1!,xScrn1!)-(yScrn2!,xScrn2!)

    'assigned even numbers for standard windows, direct display
    GRAPHIC WINDOW "NOZZLE 'End View'", 10, 10, ySCRN&, xSCRN& TO hWin(2) 'Create a graphic window and assign it a handle
    GRAPHIC ATTACH hWin(2), 0&                                  'Select standard window
    GRAPHIC COLOR ForeClr&, BackClr&                            'Set foreground and  background color
    GRAPHIC CLEAR                                               'Clear selected window with background color
    GRAPHIC SCALE(yScrn1!,xScrn1!)-(yScrn2!,xScrn2!)


    GRAPHIC WINDOW HIDE hWin(2)     'hide window
    'GRAPHIC WINDOW NORMALIZE hWin(2)'show window

    GRAPHIC ATTACH hWin(0), 0&, REDRAW       'Select standard window
    'GRAPHIC WINDOW STABILIZE hWin(0) 'user can't close window
    GRAPHIC SET FOCUS

    'GRAPHIC BITMAP NEW ; GRAPHIC BITMAP END; GRAPHIC COPY; GRAPHIC CLEAR

    '------------------------------------------------------------------

    'FONT NEW "Times New Roman", 10, 1 TO hFont&
    'GRAPHIC SET FONT hFont&

    FONT NEW "Times New Roman", 20, 1 TO hFont&
    GRAPHIC SET FONT hFont&

    ' 10.00## & 4.00## caused problems, fixed those problems.
    MajorAxis## = 9.00## '9.00## '8.764## '10.764## '8.24## '8.24## '8.24## '8.24## '5.0001## '10.00## '8.24##  '18.24## '40.00## '8.24## '10.00##  '8.24## '10.00## '4.12##
    MinorAxis## = 8.00## '8.750## '15.00##  '8.00## '5.00## '4.00## '5.00##

    IF MajorAxis## < MinorAxis## THEN
       SWAP MajorAxis##, MinorAxis##
    END IF

    IF MajorAxis## = MinorAxis## THEN
       MajorAxis## = MajorAxis## + .001##
    END IF


    majorAxisRad## = MajorAxis## * half
    minorAxisRad## = MinorAxis## * half

    yStroke## = 10.00## : 'haloDia## = 22.00## : haloRad## = haloDia##* half

    xMajor## = MajorAxis## + (yStroke##*2)
    yMinor## = MinorAxis## + (yStroke##*2)

    'determine pixel scale
    ScaleMajor## = xPlot& / xMajor## 'MajorAxis## 'get scale of horizontal plot screen area, in units/inches per pixel
    ScaleMinor## = yPlot& / yMinor## 'MinorAxis## 'get scale of vertical plot screen area, in units/inches per pixel
    IF ScaleMajor## > ScaleMinor## THEN
       eScale## = ScaleMinor##
    ELSE
       eScale## = ScaleMajor##
    END IF

    xCenter& = xSCRN&*half 'x coordinate of circle center
    yCenter& = ySCRN&*half 'y coordinate of circle center


'***************************************************************************************************************************************************************
'            *DEFINE AND DRAW THE ELLIPSE*
'***************************************************************************************************************************************************************

    'focal definition of the ellipse - get the length of the triangle sides
    foci## = SQR(SQ(majorAxisRad##)-SQ(minorAxisRad##)) 'leg distance of foci point measured from the center of the major axis
    fociX2## = foci##*2                                 'length between the foci points, F1-F2 or Foci1-Foci2 (aSide)

'----------------------------------------------------------------------------------------------------------------
'          Based on incrementing angles, measured from the ellipse x,y, centerline
'          Specify major & minor radius, chord length index, start position in RADIANS
'----------------------------------------------------------------------------------------------------------------

    thetaS## = Rads270 'Rads180 'Rads270 'Rads180'Rads180 'Rads270 '.000000001##'Rads180 'Rads90 'Rads180 ' 180## '90##                 'set start angle / position
    thetaInv## = Rads270inv

    thetaE## = thetaS## + Rads360 'set end angle / position
    thetaInc## = thetaS##         'set current degree increment to start angle
    theta## = thetaS##            'set current degree position to start angle
    thetaRads## = theta##         'assign thetaRads to theta

    pSkewRads## = DegToRads(15.00##)


    'Get the initial x and y position at starting position angle in RADIANS
    'NOTE: There are inherent problems with zero degree angles due to the inaccurracies of converting degrees to radians and vice-versa,
    'eXpos2## = majorAxisRad##*COS(thetaRads##) 'Pi and radian numbers are not accurate enough. For example:
    'eYpos2## = minorAxisRad##*SIN(thetaRads##) 'SIN(180) should = 0; but it does not!! instead = -7.61380975627945E-16

    IF thetaS## = 0 THEN
       eXpos2## = majorAxisRad##     'Pi and radian numbers are not accurate enough. For example:
       eYpos2## = 0                  'SIN(180) should = 0; but it does not!! instead = -7.6138097
    ELSEIF thetaS## = Rads180 THEN
       eXpos2## = -majorAxisRad##    'Pi and radian numbers are not accurate enough. For example:
       eYpos2## = 0                  'SIN(180) should = 0; but it does not!! instead = -7.6138097
    ELSE
       eXpos2## = majorAxisRad##*COS(thetaRads##) 'Pi and radian numbers are not accurate enough. For example:
       eYpos2## = minorAxisRad##*SIN(thetaRads##) 'SIN(180) should = 0; but it does not!! instead = -7.61380975627945E-16
    END IF

    setIndex## = .200##    'constant arc chord length
    arcIndex## = setIndex## 'set current chord index

    arcSegment## = 0  'arc segment length
    periL## = 0       'perimeter length
    AccumError## = 0  'error total acummulator, = accumulator + (target chord length - generated chord length)

    'used to calculate percentage complete
    DoneRatio! = 100.00##/Rads360 : DoneCtr1% = -1 'initilize to -1 so display starts at 0%

    n% = 0  'intialize loop counter

    DO

        '--------------------------------------------------------------------------------------------------------
        ' Get FOCUS triangle parameters, at current chord X,Y location. Use SSS(Side-Side-Side) triangle solution
        ' Includes both F1, F2 radius angle and length, and angle between F1, F2 = included angle
        '--------------------------------------------------------------------------------------------------------
        fXpos1## = foci##+eXpos2## 'current chord point x" location measured from Foci1
        fYpos1## = eYpos2##        'current chord point y" location measured from ellipse centerline

        fXpos2## = foci##-eXpos2## 'current chord point x" position measured from Foci2
        fYpos2## = eYpos2##        'same as yPos1##

        'get length of sides (* length of Radius 1 and Radius 2 from foci, F1 and F2 *)
        radF1## = SQR(SQ(fXpos1##) + SQ(fYpos1##)) '= F1 radius length(bSide)
        radF2## = SQR(SQ(fXpos2##) + SQ(fYpos2##)) '= F2 radius length(cSide)

        'get Radius1 angle, measured from foci 1 {cos C = (a^2 + b^2 - c^2)/2ab}
        angleF1Rads## = ArcCos((SQ(fociX2##)+SQ(radF1##)-SQ(radF2##))/(2*fociX2##*radF1##))

        'get Radius2 angle, measured from foci 2 {cos B = (c^2 + a^2 - b^2)/2ca}
        angleF2Rads## = ArcCos((SQ(radF2##)+SQ(fociX2##)-SQ(radF1##))/(2*radF2##*fociX2##))

        'get included angle, between Radius1 and Radius2  {cos A = (b^2 + c^2 - a^2)/2bc}
        angleFiaRads## = ArcCos((SQ(radF1##)+SQ(radF2##)-SQ(fociX2##))/(2*radF1##*radF2##))


        '--------------------------------------------------------------------------------------------------------
        ' Get Normal angle
        '--------------------------------------------------------------------------------------------------------
        angleFia2Rads = angleFiaRads##*half                         'normal angle equals one-half the included angle between RadF1 and RadF2

        angleNF1Rads## = Rads180 - (angleF1Rads## + angleFia2Rads##)'normal angle measured at X axis intersection on F1 side

        angleNF2Rads## = Rads180 - (angleF2Rads## + angleFia2Rads##)'normal angle measured at X axis intersection on F2 side

        nXF1## = (radF1##*SIN(angleFia2Rads##))/SIN(angleNF1Rads##) 'distance from F1 to tangent line intersection along X axis
        radNF1## = SQR(SQ(ABS(fXpos1##-nXF1##))+ SQ(ABS(fYpos1##))) 'length of tangent line measured from chord X,Y position to X axis line

        nXF2## = (radF2##*SIN(angleFia2Rads##))/SIN(angleNF2Rads##) 'distance from F2 to tangent line intersection along X axis
        radNF2## = SQR(SQ(ABS(fXpos2##-nXF2##))+ SQ(ABS(fYpos2##))) 'length of tangent line measured from chord X,Y position to X axis line

        '--------------------------------------------------------------------------------------------------------
        ' Store the resulting Normal Angle values of current ellipse X,Y point
        '--------------------------------------------------------------------------------------------------------
        eNormAngle(n%) = GetN360(eXpos2##, eYpos2##, angleNF2Rads##)'0 to 360 Normal angle of chord, measured from X-Axis base to chord X,Y point

        IF eNormAngle(n%) = 0 THEN
           eNormXpos(n%) = majorAxisRad##-((minorAxisRad##^2) / majorAxisRad##)
           eNormRad(n%) = (minorAxisRad##^2) / majorAxisRad##
        ELSEIF eNormAngle(n%) = Rads180 THEN
           eNormXpos(n%) = ((minorAxisRad##^2) / majorAxisRad##)-majorAxisRad##
           eNormRad(n%) = (minorAxisRad##^2) / majorAxisRad##
        ELSEIF radF1## < radF2## THEN    'use F1 results
           eNormXpos(n%) = nXF1##-foci## 'centerline of ellipse, X Axis distance, to normal angle intersection.
           eNormRad(n%) = radNF1##       'length of normal radius, measured from base line to ellipse perimeter chord point, from F1 side
        ELSE                             'use F2 results
           eNormXpos(n%) = foci##-nXF2## 'centerline of ellipse, X Axis distance, to normal angle intersection.
           eNormRad(n%) = radNF2##       'length of normal radius, measured from base line to ellipse perimeter chord point, from F2 side
        END IF

        eRotAngle(n%) = ( (eNormAngle(n%)+thetaInv##) MOD Rads360 )  'transducer rotational angle, 0 to 360 degrees translation

        'eRotAngle(n%) = ( (eNormAngle(n%)+thetaInv##)MOD Rads540 )  'transducer rotational angle, 0 to 360 degrees translation


        '--------------------------------------------------------------------------------------------------------
        ' Store the current ellipse X,Y point position and arc segment length
        '--------------------------------------------------------------------------------------------------------
        periL## = periL## + arcSegment## 'build the perimeter length, arc by arc

        eXpos(n%) = eXpos2##        'x position at radius end
        eYpos(n%) = eYpos2##        'y position at radius end
        eArcSeg(n%) = arcSegment##  'arc segment length
        eArcTotal(n%)= periL##

        'Calculate percentage done - update screen if it has changed
        doneCtr2% = ROUND( ((thetaInc##-thetaS##)*doneRatio!),0)  :
        IF DoneCtr2% <> DoneCtr1% THEN
           GRAPHIC SET POS (0,0): GRAPHIC PRINT "% DONE: " + STR$(doneCtr2%)+ "       "
           GRAPHIC REDRAW
           DoneCtr1% = DoneCtr2%
        END IF

        IF thetaInc## => thetaE## THEN EXIT DO  'exit loop if theta increment is => 360 degree:

        AccumError## = peril## - (setIndex## * n%) 'error accumulator
        'arcIndex## = setIndex## - AccumError## '*** uncomment for more accuracy, subtracts accumulated error from the target Index

        IF thetaInc## => thetaE## THEN EXIT DO  'exit loop if theta increment is => 360 degree:

        arcSegment## = 0 'reset arcSegment to zero

        DO
           '*********** Use Brute Force method to get the desired arc segement length ************
           eXpos1## = eXpos2## : eYpos1## = eYpos2##
           thetaInc## = thetaInc## + 0.0000001##        'smaller increment = more accurate = more loops
           thetaRads## = thetaInc## MOD Rads360         'keep degrees in the 0 to 360 range
           eXpos2## = majorAxisRad## * COS(thetaRads##) 'get xPos of current incremented angle
           eYpos2## = minorAxisRad## * SIN(thetaRads##) 'get yPos of current incremented angle
           arcSegment##=arcSegment##+SQR(SQ(ABS(eXpos2##-eXpos1##))+SQ(ABS(eYpos2##-eYpos1##)))'arc segment length

        LOOP WHILE (arcSegment## < arcIndex##) AND (thetaInc## < thetaE##)

        IF n% < 10000 THEN  'increment loop counter
           n% = n% + 1
        ELSE                'exit loop if n% = 10000
           EXIT DO
        END IF


    LOOP

    nMax% = n%

    'begin data is same as end data
    eNormAngle(nMax%) = eNormAngle(0)
    eNormXpos(nMax%) =  eNormXpos(0)
    eNormRad(nMax%) = eNormRad(0)

    eRotAngle(0) = 0  'transducer rotational angle, 0 to 360 degrees translation
    eRotAngle(nMax%) = Rads360  'transducer rotational angle, 0 to 360 degrees translation


    'BEEP

    'GRAPHIC WAITKEY$

    FONT NEW "Times New Roman", 12, 1 TO hFont&
    GRAPHIC SET FONT hFont&


    '-------------------------------------------------------------------------------------------------------------
    ' PLOT RESULTS
    '-------------------------------------------------------------------------------------------------------------

    GRAPHIC ATTACH hWin(1), 0&  'Select bitmap #1 window
    GRAPHIC CLEAR  ' clear the current screen before plotting

    nMax% = nMax%-1

'goto SkipRadial
    '***********************************************************************************************************
    '  DRAW RADIAL SCAN LINES         note: add weld toe + transducer offset,index + stroke length
    '***********************************************************************************************************

     FOR n% = (nMax%+1) TO 0 STEP -1 '0 TO nMax%   'step -1 so not to overwrite start marker color

        thetaRads## = eNormAngle(n%)

        sXpos(n%) = (yStroke##*COS(thetaRads##))+eXpos(n%) 'get upper xPos: based on angle and stroke length
        sYpos(n%) = (yStroke##*SIN(thetaRads##))+eYpos(n%) 'get upper yPos: based on angle and stroke length

     NEXT


    'yStroke## = 4.00## '12.00##
    GRAPHIC WIDTH 1& 'line width
    'GRAPHIC STYLE 2&


     FOR n% = nMax% TO 0 STEP -1 '0 TO nMax%   'step -1 so not to overwrite start marker color

                                                         'Chord spacing based upon user set index
        IF n% = 0 THEN   'scan start degree position
           GRAPHIC LINE(eYpos(n%),eXpos(n%))-(sYpos(n%),sXpos(n%)),%RED 'MAGENTA '%YELLOW   'normal angle scan lines extended from ellipse perimeter
        ELSE
           GRAPHIC LINE(eYpos(n%),eXpos(n%))-(sYpos(n%),sXpos(n%)),%RGB_GOLD 'LIGHTGOLDENRODYELLOW  'MAGENTA '%RGB_GOLD '%RGB_LIGHTGOLDENRODYELLOW '%magenta 'magenta 'green 'black '%RGB_MAGENTA 'normal angle scan lines exteneded from ellipse perimeter
        END IF

          'draw ellipse, a chord at a time
        GRAPHIC LINE(sYpos(n%),sXpos(n%))-(sYpos(n%+1),sXpos(n%+1)),%RED 'MAGENTA '%RGB_GOLD'Clr2 'Chord spacing based upon user set index

    NEXT

    GRAPHIC STYLE 0&

SkipRadial:

    '***********************************************************************************************************
    '  DRAW ELLIPSE and normal angles within perimeter
    '***********************************************************************************************************
    GRAPHIC WIDTH 1& 'line width

    Clr1& = %RED

    weldHaz## = 0.250##  : weldWidth## = 1.030##

    thetaRads## = eNormAngle(nMax%+1) : cosA## =  COS(thetaRads##) : sinA## =  SIN(thetaRads##)

    offset(1) = (weldHaz##*2.00##)+weldWidth##  'subtracted from ellipse
    x(2) = eXpos(nMax%+1)-(offset(1) * cosA##)
    y(2) = eYpos(nMax%+1)-(offset(1) * sinA##)

    offset(2) = weldHaz##+weldWidth##           'subtracted from ellipse
    x(4) = eXpos(nMax%+1)-(offset(2) * cosA##)
    y(4) = eYpos(nMax%+1)-(offset(2) * sinA##)

    offset(3) = weldHaz##                       'subtracted from ellipse
    x(6) = eXpos(nMax%+1)-(offset(3) * cosA##)
    y(6) = eYpos(nMax%+1)-(offset(3) * sinA##)

    x(8) = eXpos(nMax%+1)
    y(8) = eYpos(nMax%+1)


    FOR n% = nMax% TO 0 STEP -1 'step -1 so not to overwrite inner start marker color

        thetaRads## = eNormAngle(n%) : cosA## =  COS(thetaRads##) : sinA## =  SIN(thetaRads##)

        ' draw Inner HAZ: normal lines and perimeter
        '************************************************************************************************************************
        x(1) = eXpos(n%)-(offset(1) * cosA##) : y(1) = eYpos(n%)-(offset(1) * sinA##)
        GRAPHIC LINE(0, eNormXpos(n%))-(y(1), x(1)),%RGB_GOLD 'draw normal angle line to inside HAZ
        GRAPHIC LINE(y(1),x(1))-(y(2),x(2)),%RGB_RED            'draw perimeter around inside HAZ

        ' draw Inner weld: normal lines and perimeter
        '************************************************************************************************************************
        x(3) = eXpos(n%)-(offset(2) * cosA##) : y(3) = eYpos(n%)-(offset(2) * sinA##)
        GRAPHIC LINE(y(1),x(1))-(y(3),x(3)),%RGB_RED   'draw normal angle line to inside weld line
        GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),%RGB_GREEN 'draw perimeter around inside weld

        ' draw Outer Weld: normal lines and perimeter
        '************************************************************************************************************************
        x(5) = eXpos(n%)-(offset(3) * cosA##) : y(5) = eYpos(n%)-(offset(3) * sinA##)
        GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),%RGB_GREEN 'draw normal angle lines inside perimeter to outer weld
        GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),%RGB_GREEN 'draw outside perimeter around weld

        ' draw Outer HAZ: normal lines and perimeter
        '************************************************************************************************************************
        x(7) = eXpos(n%) : y(7) = eYpos(n%)
        GRAPHIC LINE(y(5),x(5))-(y(7),x(7)),%RGB_RED 'draw normal angle lines inside perimeter to outside HAZ
        GRAPHIC LINE(y(7),x(7))-(y(8),x(8)),%RGB_RED 'draw chords around outside HAZ

        ' update old values to new values
        y(2) = y(1) : x(2) = x(1) : y(4) = y(3) : x(4) = x(3) : y(6) = y(5) : x(6) = x(5) : y(8) = y(7) : x(8) = x(7)

    NEXT

    GOSUB DrawPipe 'draw the pipe cross section

    '***********************************************************************************************************
    '  DRAW CIRC SCAN LINES
    '***********************************************************************************************************



    '***********************************************************************************************************
    '  DRAW and MANIPULATE HALO RING
    '***********************************************************************************************************


    'Draw the bare Halo ring and store it in bitmap #2 window as a holding place to be copied later
    '***********************************************************************************************************
'    GRAPHIC ATTACH hWin(2), 0& : GRAPHIC CLEAR   'Select bitmap #2 window as the HALO window, clear the window
'
'    GRAPHIC WIDTH 4& 'set the line width to 4 pixels
'
'    x1! = haloRad## : y1! = 0  'set x & y plot starting position
'
'    FOR n% = 1 TO 720
'        theta## = n%*half                   'draw HALO ring in .5 degree chord increments
'        thetaRads## = DegToRads(theta##)
'        x2! = haloRad## * COS(thetaRads##) 'get xPos of current incremented angle
'        y2! = haloRad## * SIN(thetaRads##) 'get yPos of current incremented angle
'        GRAPHIC LINE(y1!,x1!)-(y2!,x2!), %GRAY 'black 'RGB_GHOSTWHITE 'blue 'crimson 'hotPINK 'YELLOW
'        x1! = x2! : y1! = y2!  'transfer new to old
'    NEXT


SkipDrawE:

    GRAPHIC ATTACH hWin(0), 0&,REDRAW           'select standard window

    nMax% = nMax% + 1

    zCtr& = 0 : indexR## = 0 : indexIncR## = 0 : lCtr& = 0 'loop counter

    'yOffset! = 3.00! '4.00! ': yStart! = yOffset! : yEnd! = yOffset! + YStroke##

    GRAPHIC ATTACH hWin(0), 0&,REDRAW           'select standard window

GOTO AxPlan


GOTO AxScan

    '*****************************************************************************************************************************
    'Perform Circumferential Scan
    '*****************************************************************************************************************************

'    'transducer positioning within halo
'    LOCAL cProbeWidth##,cProbeLen##,cProbeIdx##,cProbeYpos##,cProbeXpos##
'    LOCAL aProbeWidth##,aProbeLen##,aProbeIdx##,aProbeYpos##,aProbeXpos##
'    LOCAL cProbeRad##, aProbeRad## 'effective radius, keep Halo radial excursion in check

     'need to add overlap !!!!!

    DO

        cProbeRad## = 5.10## '1.50##

        'determine scan direction -
        IF lCtr& MOD 2 = 0 THEN 'even number: scan positive direction
           start1& = 0 : start2& = nMax% : step1& = 1
        ELSE                'odd number: scan negative direction
           start1& = nMax% : start2& = 0 : step1& = -1
        END IF
        arcSegment## = 0

        'Drive Halo, rotate, circ scan, from 0 to 360, positive direction at current axial position
        FOR zCtr& = start1& TO start2& STEP step1&

            timeB## = TIMER

            indexR## = (eNormRad(zCtr&)+indexIncR##)-1.8## ',-cProbeRad## 'haloRad## '+ yOffset! 'indexR = normal radius + Index - Halo Radius

            thetaRads## = eNormAngle(zCtr&)

            xPos2## = indexR## * COS(thetaRads##) + eNormXpos(zCtr&)'get xPos of current incremented angle
            yPos2## = indexR## * SIN(thetaRads##)                   'get yPos of current incremented angle

            GRAPHIC COPY hWin(1), 0&                    'copy component and scan layout to standard window

            GOSUB SetProbe                              'Draw transducer and features at current angle and position


            'GOSUB PlotPipe  'draw pipe features

          '   DO
          '   LOOP WHILE ABS(timeB##-TIMER) < 0.025##

            sTxt(0)="Index X :"+ STR$(ROUND(eArcTotal(zCtr&),4))+"00"
            sTxt(1)="Index Y :"+ STR$(ROUND((indexR##-eNormRad(zCtr&)),4))+"                           "
            sTxt(2)="Probe X :"+ STR$(ROUND(x(9),4))  +"            "
            sTxt(3)="Probe Y :"+ STR$(ROUND(y(9),4))  +"            "
            sTxt(4)="Beam  X :"+ STR$(ROUND(xPos2##,4))+"            "
            sTxt(5)="Beam  Y :"+ STR$(ROUND(yPos2##,4))+"            "
            sTxt(6)="Rot Ang :"+ STR$(ROUND((RadsToDeg(eRotAngle(zCtr&))),12)) + "           "
            sTxt(7)="Norm Ang:"+ STR$(ROUND(RadsToDeg(eNormAngle(zCtr&)),12)) + "           "




            GRAPHIC SET POS (-30.00!,-10.00!):GRAPHIC PRINT sTxt(0)
            GRAPHIC SET POS (-30.00!,-9.00!) :GRAPHIC PRINT sTxt(1)
            GRAPHIC SET POS (-30.00!,-8.00!) :GRAPHIC PRINT sTxt(2)
            GRAPHIC SET POS (-30.00!,-7.00!) :GRAPHIC PRINT sTxt(3)
            GRAPHIC SET POS (-30.00!,-6.00!) :GRAPHIC PRINT sTxt(4)
            GRAPHIC SET POS (-30.00!,-5.00!) :GRAPHIC PRINT sTxt(5)
            GRAPHIC SET POS (-30.00!,-4.00!) :GRAPHIC PRINT sTxt(6)
            GRAPHIC SET POS (-30.00!,-3.00!) :GRAPHIC PRINT sTxt(7)

            GRAPHIC REDRAW                              'Re-Draw the screen snappaly


            'set scan speed

            ' LOCAL timeB##, timeE## , timeT## , TimeS##

             'goto skipdo
             DO

                GRAPHIC INKEY$ TO k$
                IF LEN(k$)>0 THEN
                    GRAPHIC WAITKEY$
                END IF

             LOOP WHILE ABS(timeB##-TIMER) < 0.1##

'skipdo:
             ' GRAPHIC WAITKEY$

            'sleep 10&
            'slow down on long moves
           ' IF (ABS(thetaRads##-theta2##) > 0.10##) THEN
           '    SLEEP 50&
           ' ELSE
           '    SLEEP 5&
           ' END IF
           ' theta2##=thetaRads##



           ' SLEEP 10&
            'GRAPHIC INSTAT TO key1&
            'IF key1& THEN GOSUB ProcessKey

            IF lCtr& = 0 AND zCtr& = start1& THEN
               DO
                 GOSUB doMouse
               LOOP UNTIL  GRAPHIC(INSTAT)
               k$ = GRAPHIC$(INKEY$)
           ' ELSE
              ' DO
              ' LOOP WHILE ABS(timeB##-TIMER) < 0.025##
            END IF

            IF indexIncR## > (yStroke##-.200##) THEN
               GRAPHIC WAITKEY$
            END IF


        NEXT

        'GRAPHIC WAITKEY$

        indexIncR## = indexIncR## + 0.200##

        'IF indexIncR## > yStroke##  THEN EXIT DO

        IF indexIncR## > 2.10##  THEN EXIT DO

        lCtr& = lCtr& + 1

        'check if user closed the window
        GRAPHIC GET DC TO hWinCheck& : IF hWinCheck& = 0 THEN GOTO exitWindows

       ' GRAPHIC WINDOW CLICK TO wClick&, xClick!, yClick!
       ' IF wClick& THEN 'mouse click
       '    sTxt(0)="xMouse :"+ STR$(xClick!)+  "            "
       '    sTxt(1)="yMouse :"+ STR$(yClick!)+  "            "
       '    GRAPHIC SET POS (-35!,-19!) : GRAPHIC PRINT sTxt(0)
       '    GRAPHIC SET POS (-35!,-17!) : GRAPHIC PRINT sTxt(1)
       '    SLEEP 1000
       ' END IF

        SLEEP 200&

    LOOP
    'wlc
    CLOSE filenumber
    BEEP : GRAPHIC WAITKEY$



GOTO exitWindows

AxPlan:


    '*****************************************************************************************************************************
    'Perform Axial Scan
    '*****************************************************************************************************************************

    'need to add overlap!!!!!!!!

    step1R## = 0.200##

    zCtr& = 0 : indexR## = 0 : indexIncR## = 0 : lCtr& = 0 'loop counter

    'yStart!, yEnd!, yIndex!, yOffset!,xOffset!

     yOffset! = .80! '3.00! :

    yStart! = yOffset! : yEnd! = yOffset! + YStroke##

    'transducer positioning within halo
    'LOCAL cProbeWidth##,cProbeLen##,cProbeIdx##,cProbeYpos##,cProbeXpos##
    'LOCAL aProbeWidth##,aProbeLen##,aProbeIdx##,aProbeYpos##,aProbeXpos##
    'LOCAL cProbeRad##, aProbeRad## 'effective radius, keep Halo radial excursion in check

    'user input: Probe length, width and index
    aProbeLen## = 2.200## 'transducer length
    aProbeIdx## = 0.800## 'transducer index position, measured setback from front
    aProbeWidth## = 2.600## 'transducer width

    GRAPHIC ATTACH hWin(0), 0&,REDRAW           'select standard window

    FOR zCtr& = 0 TO nMax%

        'determine scan direction -
        IF zCtr& MOD 2& = 0 THEN 'even number: scan positive direction
          start1& = (yOffset!/step1R##) : start2& = (yOffset!+yStroke##)/step1R## : step1& = 1
        ELSE                     'odd number: scan negative direction
          start2& = (yOffset!/step1R##) : start1& = (yOffset!+yStroke##)/step1R## : step1& = -1
        END IF

        'Drive transducer along current scan path and angle.
        '*************************************************************************************************************************
        FOR lCtr& = start1& TO start2& STEP step1&

            indexIncR## = lCtr& * step1R##

            indexR## = eNormRad(zCtr&)+indexIncR## 'indexR = normal radius + Index

            thetaRads## = eNormAngle(zCtr&)

            xPos2## = indexR## * COS(thetaRads##) + eNormXpos(zCtr&) 'get xPos of current incremented angle
            yPos2## = indexR## * SIN(thetaRads##)                    'get yPos of current incremented angle

            GRAPHIC COPY hWin(1), 0&                    'copy static ellipse to standard window

            GOSUB SetProbe                              'Draw Transducer and features at current angle and position

 '           GOSUB PlotPipe  'draw pipe features


          '   DO
          '   LOOP WHILE ABS(timeB##-TIMER) < 0.025##

            'NOTE:  x(9) = xPos2##  y(9) = yPos2##

            sTxt(0)="Probe  X :"+ STR$(ROUND(eArcTotal(zCtr&),4))+"      "
            sTxt(1)="Probe  Y :"+ STR$(ROUND((indexR##-eNormRad(zCtr&)),4))+"                 "
            sTxt(2)="Motor  X :"+ STR$(ROUND(xPos2##,4))+"            "
            sTxt(3)="Motor  Y :"+ STR$(ROUND(yPos2##,4))+"            "
            sTxt(4)="Motor  Z :"+ STR$(ROUND((RadsToDeg(eRotAngle(zCtr&))),6)) + "           "
            sTxt(5)="Norm  Ang:"+ STR$(ROUND(RadsToDeg(eNormAngle(zCtr&)),6)) + "           "

            sTxt(6)="Norm   X :"+ STR$(ROUND(eNormXpos(zCtr&),4)) + "           "


            sTxt(7)="ZCtr    :"+ STR$(zCtr&) + "           "


            GRAPHIC SET POS (-26.00!,-10.00!):GRAPHIC PRINT sTxt(0)
            GRAPHIC SET POS (-26.00!,-9.00!) :GRAPHIC PRINT sTxt(1)
            GRAPHIC SET POS (-26.00!,-8.00!) :GRAPHIC PRINT sTxt(2)
            GRAPHIC SET POS (-26.00!,-7.00!) :GRAPHIC PRINT sTxt(3)
            GRAPHIC SET POS (-26.00!,-6.00!) :GRAPHIC PRINT sTxt(4)
            GRAPHIC SET POS (-26.00!,-5.00!) :GRAPHIC PRINT sTxt(5)
            GRAPHIC SET POS (-26.00!,-4.00!) :GRAPHIC PRINT sTxt(6)
            GRAPHIC SET POS (-26.00!,-3.00!) :GRAPHIC PRINT sTxt(7)



            GRAPHIC REDRAW                              'Re-Draw the screen snappaly

            IF lCtr& = start1& THEN SLEEP 100
            IF lCtr& = start2& THEN SLEEP 100


            GRAPHIC WINDOW CLICK hwin(0) TO wclick&, xClick!, yClick!
            IF wClick& THEN 'if mouse click then pause until another click
              DO
                 GRAPHIC WINDOW CLICK hwin(0) TO wclick&, xClick!, yClick!
              LOOP UNTIL wClick&  'another click, exit pause
            END IF

           IF zCtr& = 0 THEN
              DO
                 GRAPHIC WINDOW CLICK hwin(0) TO wclick&, xClick!, yClick!
              LOOP UNTIL wClick&  'another click, exit pause
           END IF


            'GRAPHIC INSTAT TO key1&
            'IF key1& THEN GOSUB ProcessKey

            'IF (zCtr& = 0) AND (lCtr& = 0) THEN SLEEP 1000
            SLEEP 20&

         NEXT

        'SLEEP 20&

        'check if user closed the window
        GRAPHIC GET DC TO hWinCheck& : IF hWinCheck& = 0 THEN GOTO exitWindows

    NEXT


    BEEP : GRAPHIC WAITKEY$


GOTO exitWindows


AxScan:


    '*****************************************************************************************************************************
    'Perform Axial Scan
    '*****************************************************************************************************************************

    'need to add overlap!!!!!!!!

    step1R## = 0.200##

    zCtr& = 0 : indexR## = 0 : indexIncR## = 0 : lCtr& = 0 'loop counter

    'yStart!, yEnd!, yIndex!, yOffset!,xOffset!

     yOffset! = .80! '3.00! :

    yStart! = yOffset! : yEnd! = yOffset! + YStroke##

    'transducer positioning within halo
    'LOCAL cProbeWidth##,cProbeLen##,cProbeIdx##,cProbeYpos##,cProbeXpos##
    'LOCAL aProbeWidth##,aProbeLen##,aProbeIdx##,aProbeYpos##,aProbeXpos##
    'LOCAL cProbeRad##, aProbeRad## 'effective radius, keep Halo radial excursion in check

    'user input: Probe length, width and index
    aProbeLen## = 2.200## 'transducer length
    aProbeIdx## = 0.800## 'transducer index position, measured setback from front
    aProbeWidth## = 2.600## 'transducer width




    GRAPHIC ATTACH hWin(0), 0&,REDRAW           'select standard window

    FOR zCtr& = 0 TO nMax%

        'determine scan direction -
        IF zCtr& MOD 2& = 0 THEN 'even number: scan positive direction
          start1& = (yOffset!/step1R##) : start2& = (yOffset!+yStroke##)/step1R## : step1& = 1
        ELSE                     'odd number: scan negative direction
          start2& = (yOffset!/step1R##) : start1& = (yOffset!+yStroke##)/step1R## : step1& = -1
        END IF

        'Drive transducer along current scan path and angle.
        '*************************************************************************************************************************
        FOR lCtr& = start1& TO start2& STEP step1&

            indexIncR## = lCtr& * step1R##

            indexR## = eNormRad(zCtr&)+indexIncR## 'indexR = normal radius + Index

            thetaRads## = eNormAngle(zCtr&)

            xPos2## = indexR## * COS(thetaRads##) + eNormXpos(zCtr&) 'get xPos of current incremented angle
            yPos2## = indexR## * SIN(thetaRads##)                    'get yPos of current incremented angle

            GRAPHIC COPY hWin(1), 0&                    'copy static ellipse to standard window

            GOSUB SetProbe                              'Draw Transducer and features at current angle and position

 '           GOSUB PlotPipe  'draw pipe features


          '   DO
          '   LOOP WHILE ABS(timeB##-TIMER) < 0.025##

            'NOTE:  x(9) = xPos2##  y(9) = yPos2##

            sTxt(0)="Probe  X :"+ STR$(ROUND(eArcTotal(zCtr&),4))+"      "
            sTxt(1)="Probe  Y :"+ STR$(ROUND((indexR##-eNormRad(zCtr&)),4))+"                 "
            sTxt(2)="Motor  X :"+ STR$(ROUND(xPos2##,4))+"            "
            sTxt(3)="Motor  Y :"+ STR$(ROUND(yPos2##,4))+"            "
            sTxt(4)="Motor  Z :"+ STR$(ROUND((RadsToDeg(eRotAngle(zCtr&))),6)) + "           "
            sTxt(5)="Norm  Ang:"+ STR$(ROUND(RadsToDeg(eNormAngle(zCtr&)),6)) + "           "

            sTxt(6)="Norm   X :"+ STR$(ROUND(eNormXpos(zCtr&),4)) + "           "


            sTxt(7)="ZCtr    :"+ STR$(zCtr&) + "           "


            GRAPHIC SET POS (-26.00!,-10.00!):GRAPHIC PRINT sTxt(0)
            GRAPHIC SET POS (-26.00!,-9.00!) :GRAPHIC PRINT sTxt(1)
            GRAPHIC SET POS (-26.00!,-8.00!) :GRAPHIC PRINT sTxt(2)
            GRAPHIC SET POS (-26.00!,-7.00!) :GRAPHIC PRINT sTxt(3)
            GRAPHIC SET POS (-26.00!,-6.00!) :GRAPHIC PRINT sTxt(4)
            GRAPHIC SET POS (-26.00!,-5.00!) :GRAPHIC PRINT sTxt(5)
            GRAPHIC SET POS (-26.00!,-4.00!) :GRAPHIC PRINT sTxt(6)
            GRAPHIC SET POS (-26.00!,-3.00!) :GRAPHIC PRINT sTxt(7)



            GRAPHIC REDRAW                              'Re-Draw the screen snappaly

            IF lCtr& = start1& THEN SLEEP 100
            IF lCtr& = start2& THEN SLEEP 100


            GRAPHIC WINDOW CLICK hwin(0) TO wclick&, xClick!, yClick!
            IF wClick& THEN 'if mouse click then pause until another click
              DO
                 GRAPHIC WINDOW CLICK hwin(0) TO wclick&, xClick!, yClick!
              LOOP UNTIL wClick&  'another click, exit pause
            END IF

           IF zCtr& = 0 THEN
              DO
                 GRAPHIC WINDOW CLICK hwin(0) TO wclick&, xClick!, yClick!
              LOOP UNTIL wClick&  'another click, exit pause
           END IF


            'GRAPHIC INSTAT TO key1&
            'IF key1& THEN GOSUB ProcessKey

            'IF (zCtr& = 0) AND (lCtr& = 0) THEN SLEEP 1000
            SLEEP 20&

         NEXT

        'SLEEP 20&

        'check if user closed the window
        GRAPHIC GET DC TO hWinCheck& : IF hWinCheck& = 0 THEN GOTO exitWindows

    NEXT


    BEEP : GRAPHIC WAITKEY$


GOTO exitWindows


'**********************************************************************************************************************************************
' SUBS
'**********************************************************************************************************************************************

SetProbe:

GOTO DrawAxScan



GOTO DrawCircScan



'GOTO DrawAxScan

DrawCircScan:


    GRAPHIC WIDTH 1&

    'LOCAL cProbeWidth##,cProbeLen##,cProbeIdx,cProbeYpos##,cProbeXpos##
    'LOCAL aProbeWidth##,aProbeLen##,aProbeIdx,aProbeYpos##,aProbeXpos##


    'User input transducer x position, transducer front/back edges parallel with 0 to 180 degree line.
    'cProbeXpos## = 4.50##  'user physical measurement, from center of Halo to centerline of transducer width
    'cProbeWidth## = 2.60## 'X probe width

    'Locate x & y position of the near and far sides of the transducer case.
    '***************************************************************************************************************************
    thetaRads## = (eNormAngle(zCtr&) + pSkewRads) 'MOD 360 'Current transducer degree position (0-360)

    'user input: measured from center of halo, along 0-180 degree line, X
    cProbeXpos## = 0 '3.50## '3.30 'X probe center
    cProbeWidth## = -2.60## 'X probe width

    'Locate near side of transducer case width, at current scan degree position, projected from halo 0-180 line
    x(1) = (cProbeXpos##-(cProbeWidth##*half)) * COS(thetaRads##) + xPos2##
    y(1) = (cProbeXpos##-(cProbeWidth##*half)) * SIN(thetaRads##) + yPos2##

    'Locate far side of transducer case width, at current scan degree postion, projected from halo 0-180 line
    x(2) = (cProbeXpos##+(cProbeWidth##*half)) * COS(thetaRads##) + xPos2##
    y(2) = (cProbeXpos##+(cProbeWidth##*half)) * SIN(thetaRads##) + yPos2##

    'Locate center of transducer case width,at current scan degree postion, projected from halo 0-180 line(used for paint!).
    x(7) = (cProbeXpos##) * COS(thetaRads##) + xPos2##
    y(7) = (cProbeXpos##) * SIN(thetaRads##) + yPos2##



    'Locate x & y position of the (4) transducer case corners
    '***************************************************************************************************************************
    thetaRads## = (eNormAngle(zCtr&)+Rads90 + pSkewRads) 'MOD 360

    'user input: measured from Halo centerline, along 90-270 degree line, Y
    cProbeYpos##= -6.00## '5.712## '3.200## 'probe Y location, measured to index
    cProbeLen## = -2.200## 'probe length
    cProbeIdx## = -0.800## 'transducer index position, measured setback from front

    cProbeOffset## = (cProbeLen##*half)-cProbeIdx## 'find offset from index to probe center.

    'Lower front probe corner, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(3) = ( cProbeYpos##-cProbeIdx## ) * COS(thetaRads##)+ x(1)
    y(3) = ( cProbeYpos##-cProbeIdx## ) * SIN(thetaRads##)+ y(1)

    'Upper front probe edge, along +/- 90 degrees from NORMAL axis,+ offset from projected x(2) & y(2)
    x(4) = ( cProbeYpos##-cProbeIdx## ) * COS(thetaRads##)+ x(2)
    y(4) = ( cProbeYpos##-cProbeIdx## ) * SIN(thetaRads##)+ y(2)

    'Lower back probe edge, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(5) = ( cProbeYpos##+(cProbeLen##-cProbeIdx##) ) * COS(thetaRads##)+ x(1)
    y(5) = ( cProbeYpos##+(cProbeLen##-cProbeIdx##) ) * SIN(thetaRads##)+ y(1)

    'Upper back probe edge, along +/-90 degrees from Normal axis,+offset projected from x(2) & y(2)
    x(6) = ( cProbeYpos##+(cProbeLen##-cProbeIdx##) ) * COS(thetaRads##)+ x(2)
    y(6) = ( cProbeYpos##+(cProbeLen##-cProbeIdx##) ) * SIN(thetaRads##)+ y(2)

    'Center of transducer case length, (used for paint!)
    x(8) = ( cProbeYpos##+cProbeOffset## ) * COS(thetaRads##)+ x(7)
    y(8) = ( cProbeYpos##+cProbeOffset## ) * SIN(thetaRads##)+ y(7)

    'True X,Y position of Circ transducer at current halo position
    x(9) = cProbeYpos## * COS(thetaRads##)+ x(7)
    y(9) = cProbeYpos## * SIN(thetaRads##)+ y(7)


    '********************************************************************************************************************
    clr1& = %RGB_LIGHTYELLOW

    'draw transducer sides x4 (rectangle)
    GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),clr1&  'RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw probe side 1
    GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),clr1&  'RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw probe side 2
    GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),clr1&  'RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw probe side 3
    GRAPHIC LINE(y(4),x(4))-(y(6),x(6)),clr1&  'RGB_LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw probe side 4

    'make sure all (4) corners of the rectangle are sealed before calling GRAPHIC PAINT, otherwise paint leaks out everywhere!!
    GRAPHIC SET PIXEL (y(3),x(3)),clr1&
    GRAPHIC SET PIXEL (y(4),x(4)),clr1&
    GRAPHIC SET PIXEL (y(5),x(5)),clr1&
    GRAPHIC SET PIXEL (y(6),x(6)),clr1&

    'paint inside the transducer case
    GRAPHIC PAINT (y(8), x(8)),%RGB_ORANGE, clr1& '%red, %rgb_white

    '***********************************************************************************************************
    'draw tangent line in reference to ellipse normal angle
    '***********************************************************************************************************
    thetaRads## = (eNormAngle(zCtr&)+Rads90) 'MOD 360 'normal angle +90 of ellipse X,Y position
    x1! = haloRad## * COS(thetaRads##)+ xPos2## 'get real xPos of current angle
    y1! = haloRad## * SIN(thetaRads##)+ yPos2## 'get real yPos of current angle

    thetaRads## = (eNormAngle(zCtr&)-Rads90) 'MOD 360 'normal angle -90 of ellipse X,Y position
    x2! = haloRad## * COS(thetaRads##)+ xPos2## 'get real xPos of current angle
    y2! = haloRad## * SIN(thetaRads##)+ yPos2## 'get real yPos of current angle

    GRAPHIC LINE(y1!,x1!)-(y2!,x2!),%RGB_RED 'WHITE 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    'added for SKEW
    '***********************************************************************************************************
    'draw line 0 degrees, UT Beam, through centerline of transducer width
    '***********************************************************************************************************
    thetaRads## = (eNormAngle(zCtr&)+Rads90+pSkewRads##) 'MOD 360 'normal angle +90 of ellipse X,Y position
    x1! = haloRad## * COS(thetaRads##)+ xPos2## 'get real xPos of current angle
    y1! = haloRad## * SIN(thetaRads##)+ yPos2## 'get real yPos of current angle

    thetaRads## = (eNormAngle(zCtr&)-Rads90+pSkewRads##) 'MOD 360 'normal angle -90 of ellipse X,Y position
    x2! = haloRad## * COS(thetaRads##)+ xPos2## 'get real xPos of current angle
    y2! = haloRad## * SIN(thetaRads##)+ yPos2## 'get real yPos of current angle

    GRAPHIC LINE(y1!,x1!)-(y2!,x2!),%RGB_WHITE 'RED 'WHITE 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    '***********************************************************************************************************
    'draw line 90 degrees to UT beam axis, projected sideways
    '***********************************************************************************************************
    thetaRads## =  eNormAngle(zCtr&) 'normal angle +90 of ellipse X,Y position
    x1! = haloRad## * COS(thetaRads##)+ xPos2## 'get real xPos of current angle
    y1! = haloRad## * SIN(thetaRads##)+ yPos2## 'get real yPos of current angle

    thetaRads## = eNormAngle(zCtr&) 'normal angle -90 of ellipse X,Y position
    x2! = xPos2## - (haloRad## * COS(thetaRads##)) 'get real xPos of current angle
    y2! = yPos2## - (haloRad## * SIN(thetaRads##)) 'get real yPos of current angle

    GRAPHIC LINE(y1!,x1!)-(y2!,x2!),%RGB_RED 'WHITE 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    '***********************************************************************************************************
    'draw line 90 degrees across projected UT beam
    '***********************************************************************************************************
    'added for Skew
    thetaRads## = (eNormAngle(zCtr&)+pSkewRads##) 'MOD 360 'normal angle +90 of ellipse X,Y position
    x1! = haloRad## * COS(thetaRads##)+ xPos2## 'get real xPos of current angle
    y1! = haloRad## * SIN(thetaRads##)+ yPos2## 'get real yPos of current angle

    thetaRads## = (eNormAngle(zCtr&)+pSkewRads##) 'MOD 360 'normal angle -90 of ellipse X,Y position
    'thetaRads## = (eNormAngle(zCtr&)-angleRads##) MOD 360 'normal angle -90 of ellipse X,Y position
    x2! = xPos2## - (haloRad## * COS(thetaRads##)) 'get real xPos of current angle
    y2! = yPos2## - (haloRad## * SIN(thetaRads##)) 'get real yPos of current angle
    GRAPHIC LINE(y1!,x1!)-(y2!,x2!),%RGB_WHITE 'red 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    '***********************************************************************************************************
    'draw line 90 degrees across transducer case at UT beam exit point
    '***********************************************************************************************************
    'added for Skew
    thetaRads## = (eNormAngle(zCtr&)+pSkewRads##) 'MOD 360 'normal angle +90 of ellipse X,Y position
    x1! = haloRad## * COS(thetaRads##)+ x(9) 'get real xPos of current angle
    y1! = haloRad## * SIN(thetaRads##)+ y(9) 'get real yPos of current angle

    thetaRads## = (eNormAngle(zCtr&)+pSkewRads##) 'MOD 360 'normal angle -90 of ellipse X,Y position
    'thetaRads## = (eNormAngle(zCtr&)-angleRads##) MOD 360 'normal angle -90 of ellipse X,Y position
    x2! = x(9) - (haloRad## * COS(thetaRads##)) 'get real xPos of current angle
    y2! = y(9) - (haloRad## * SIN(thetaRads##)) 'get real yPos of current angle

    GRAPHIC LINE(y1!,x1!)-(y2!,x2!),%RGB_WHITE 'red 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO

    'draw meatball at transducer offset distance
    x1! = x(7) - 0.250## ' x position top
    y1! = y(7) - 0.250## ' y position left
    x2! = x(7) + 0.250## 'outer halo x position bottom
    y2! = y(7) + 0.250## 'outer halo y position right
    GRAPHIC ELLIPSE (y1!,x1!)-(y2!,x2!), %RGB_WHITE', -1 'orange, -1 '%WHITE, -1 'clr1&

    'meatball at x,y transducer center
    x1! = x(9) - 0.20## 'transducer x position
    y1! = y(9) - 0.20## 'transducer y position
    x2! = x(9) + 0.20## 'x1!  'transducer x position
    y2! = y(9) + 0.20## 'y1!-10.00! 'transducer y position - 10"
    GRAPHIC ELLIPSE (y1!,x1!)-(y2!,x2!), %RGB_WHITE 'black ', -1  'BLACK, -1 'orange, -1 '%WHITE, -1 'clr1&


    RETURN




DrawAxScan:
    'wlc
    'goto SkipDrawProbe

    'LOCAL cProbeWidth##,cProbeLen##,cProbeIdx,cProbeYpos##,cProbeXpos##
    'LOCAL aProbeWidth##,aProbeLen##,aProbeIdx,aProbeYpos##,aProbeXpos##

    'transducer lined up with normal @ 0 degree halo line, running from 0 to 180 degrees

    'Locate x & y position of the near and far sides of the transducer case.
    '***************************************************************************************************************************
    thetaRads## = (eNormAngle(zCtr&))'Current transducer degree position (0-360)

    'user input: Probe length, width and index
    'aProbeLen## = 2.200## 'transducer length
    'aProbeIdx## = 0.800## 'transducer index position, measured setback from front
    'aProbeWidth## = 2.600## 'transducer width

    'Locate near side of transducer case, at current scan degree position, on 0-180 line
    x(1) = xPos2## - (aProbeIdx## * COS(thetaRads##))
    y(1) = yPos2## - (aProbeIdx## * SIN(thetaRads##))

    'Locate far side of transducer case, at current scan degree postion, on 0-180 line
    x(2) = xPos2##+ ((aProbeLen##-aProbeIdx##) * COS(thetaRads##))
    y(2) = yPos2##+ ((aProbeLen##-aProbeIdx##) * SIN(thetaRads##))

    'Locate center of transducer case,at current scan degree position, on 0-180 line(used for paint!).
    x(8) = xPos2## + (((aProbeLen##*half)-aProbeIdx##) * COS(thetaRads##))
    y(8) = yPos2## + (((aProbeLen##*half)-aProbeIdx##) * SIN(thetaRads##))

    'True X,Y position of axial transducer at current position
    'Locate transducer index at current scan degree position, on 0-180 line
    x(9) = xPos2##
    y(9) = yPos2##


    'Locate x & y position of the (4) transducer case corners
    '***************************************************************************************************************************

    'Transducer Width: (halfwidth + side of normal) + (halfwidth-side of normal) = transducer width, should be centered
    thetaRads## = (eNormAngle(zCtr&)+Rads90) MOD 360
    x(3) = (aProbeWidth##*half) * COS(thetaRads##)+ x(1) 'get real xPos of current angle
    y(3) = (aProbeWidth##*half) * SIN(thetaRads##)+ y(1) 'get real xPos of current angle
    x(4) = (aProbeWidth##*half) * COS(thetaRads##)+ x(2) 'get real xPos of current angle
    y(4) = (aProbeWidth##*half) * SIN(thetaRads##)+ y(2) 'get real xPos of current angle

    thetaRads## = (eNormAngle(zCtr&)-Rads90) MOD 360
    x(5) = (aProbeWidth##*half) * COS(thetaRads##)+ x(1) 'get real xPos of current angle
    y(5) = (aProbeWidth##*half) * SIN(thetaRads##)+ y(1) 'get real xPos of current angle
    x(6) = (aProbeWidth##*half) * COS(thetaRads##)+ x(2) 'get real xPos of current angle
    y(6) = (aProbeWidth##*half) * SIN(thetaRads##)+ y(2) 'get real xPos of current angle

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
    tempstr = MKD$( y(3))
    PUT$ filenumber, tempstr
    tempstr = MKD$( x(3))
    PUT$ filenumber, tempstr
    GRAPHIC SET PIXEL (y(4),x(4)),clr1&
    tempstr = MKD$( y(4))
    PUT$ filenumber, tempstr
    tempstr = MKD$( x(4))
    PUT$ filenumber, tempstr
    GRAPHIC SET PIXEL (y(5),x(5)),clr1&
    tempstr = MKD$( y(5))
    PUT$ filenumber, tempstr
    tempstr = MKD$( x(5))
    PUT$ filenumber, tempstr
    GRAPHIC SET PIXEL (y(6),x(6)),clr1&
    tempstr = MKD$( y(6))
    PUT$ filenumber, tempstr
    tempstr = MKD$( x(6))
    PUT$ filenumber, tempstr

    GRAPHIC PAINT (y(8), x(8)), %RGB_ORANGE, clr1&
    tempstr = MKD$( y(8))
    PUT$ filenumber, tempstr
    tempstr = MKD$( x(8))
    PUT$ filenumber, tempstr
    '***********************************************************************************************************
    'draw line through index position along transducer length
    '***********************************************************************************************************
     haloRad## = 10.00##
    '{cos B = (c^2 + a^2 - b^2)/2ca}  a## = aProbeXpos## : c## = haloRad## : b## = SQR(SQ(c##)-SQ(a##))
    'get angle of halo radius line, measured from current normal angle {cos B = (c^2 + a^2 - b^2)/2ca}
    'angleRads## = ArcCos((SQ(haloRad##)+SQ(xPos2##)-(SQ(haloRad##)-SQ(xPos2##)))/(2*haloRad##*xPos2##))
    'angleRads## = ArcCos(xPos2##/haloRad##)'simpler than above, appears to work same, above left just in case!!

    thetaRads## = (eNormAngle(zCtr&)+Rads90) MOD 360 'normal angle +90 of ellipse X,Y position
    x1! = (haloRad## * COS(thetaRads##))+ xPos2## 'get real xPos of current angle
    y1! = (haloRad## * SIN(thetaRads##))+ yPos2## 'get real yPos of current angle

    thetaRads## = (eNormAngle(zCtr&)-Rads90) MOD 360 'normal angle -90 of ellipse X,Y position
    x2! = (haloRad## * COS(thetaRads##))+ xPos2## 'get real xPos of current angle
    y2! = (haloRad## * SIN(thetaRads##))+ yPos2## 'get real yPos of current angle

    GRAPHIC LINE(y1!,x1!)-(y2!,x2!),%RGB_WHITE 'RGB_WHITE 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO
    tempstr = MKD$( y1!)
    PUT$ filenumber, tempstr
    tempstr = MKD$(x1!)
    PUT$ filenumber, tempstr
    tempstr = MKD$( y2!)
    PUT$ filenumber, tempstr
    tempstr = MKD$(x2!)
    PUT$ filenumber, tempstr

    'GRAPHIC PAINT (y(8), x(8)), %RGB_ORANGE, clr1&

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

    tempstr = MKD$( y1!)
    PUT$ filenumber, tempstr
    tempstr = MKD$(x1!)
    PUT$ filenumber, tempstr
    tempstr = MKD$( y2!)
    PUT$ filenumber, tempstr
    tempstr = MKD$(x2!)
    PUT$ filenumber, tempstr
    'meatball at x,y transducer center
    x1! = xPos2## - 0.100## 'transducer x position
    y1! = yPos2## - 0.100## 'transducer y position
    x2! = xPos2## + 0.100## 'x1!  'transducer x position
    y2! = yPos2## + 0.100## 'y1!-10.00! 'transducer y position - 10"
    GRAPHIC ELLIPSE (y1!,x1!)-(y2!,x2!), %RGB_BLACK, -1 'orange, -1 '%WHITE, -1 'clr1&
    tempstr = MKD$( y1!)
    PUT$ filenumber, tempstr
    tempstr = MKD$(x1!)
    PUT$ filenumber, tempstr
    tempstr = MKD$( y2!)
    PUT$ filenumber, tempstr
    tempstr = MKD$(x2!)
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
