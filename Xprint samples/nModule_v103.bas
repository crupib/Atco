'====================================================================
'
'Last File Name: NozzleScanPlan_Module_A_TEST_RUN_9_A_L_5_C_6.bas
'Started new name:    nModule.bas
'====================================================================

#COMPILER PBCC 6
'#CONSOLE OFF
#DIM ALL
#INCLUDE "win32api.inc"
#INCLUDE "COMDLG32.INC"


MACRO Pi =  3.14159265358979323846#

MACRO DegToRads(dpDegrees) = (dpDegrees * 0.0174532925199433#)
MACRO RadsToDeg(dpRadians) = (dpRadians*57.29577951308232#)

MACRO ArcCos(CosA) = ( Pi / 2 - ATN(CosA / SQR(1 - CosA * CosA)) )  'ArcCos in radians
MACRO ArcCosA(CosA) = ( ArcCos(CosA)*57.29577951308232# )'ArcCos in degrees

MACRO ArcSin(SinA) = ATN(SinA / SQR(1 - SinA * SinA))'ArcSin in radians
MACRO ArcSinA(SinA) = ( ArcSin(SinA)*57.29577951308232# )'ArcSin in degrees'

MACRO SQ(SquareIt) = (SquareIt*SquareIt) 'Macro to square a number, because PBCC doesn't like the use of ^caret in all cases

MACRO CONST = MACRO
CONST Rads0 = (0.000#)
CONST Rads9 = (Pi*0.050#)
CONST Rads45 = (Pi*0.250#)
CONST Rads90 = (Pi*0.500#)
CONST Rads135 = (Pi*0.750#)
CONST Rads180 = (Pi)
CONST Rads225 = (Pi*1.250#)
CONST Rads270 = (Pi*1.500#)
CONST Rads315 = (Pi*1.750#)
CONST Rads360 = (Pi*2.000#)
CONST Rads540 = (Pi*3.000#)

CONST Rads0inv = Rads360    'for Scan begin, Rads0inv + Rads360 = 360 degrees, with MOD360 equals 0 degrees
CONST Rads90inv = Rads270   ' "
CONST Rads180inv = Rads180  ' "
CONST Rads270inv = Rads90   ' "


CONST DegRatio= (1.00#/360.00#)
CONST RadsRatio =(1.00#/ (Pi*2.00#) )'/360.00# )
CONST Half = (0.500#)
CONST Fourth = (0.250#)
CONST TRUE = (-1)
CONST FALSE = (NOT -1)

CONST Mil = 1000000


'********************************************************************************************************************************
' User Defined Types
'********************************************************************************************************************************

TYPE FociRay

     majorAxisRad AS DOUBLE     'define the nozzle weld shape ellipse
     minorAxisRad AS DOUBLE
     majorAxis AS DOUBLE
     minorAxis AS DOUBLE
     arcSegment AS DOUBLE

     foci AS DOUBLE             'leg distance of foci point measured from the center of the major axis
     fociX2 AS DOUBLE           'length between the foci points, F1-F2 or Foci1-Foci2 (aSide)
     fXpos1 AS DOUBLE           'current chord point x" location measured from Foci1
     fYpos1 AS DOUBLE           'current chord point y" location measured from nozzle centerline
     fXpos2 AS DOUBLE           'current chord point x" position measured from Foci2
     fYpos2 AS DOUBLE           'same as yPos1#
     radF1 AS DOUBLE            'F1 radius length(bSide)
     radF2 AS DOUBLE            'F2 radius length(cSide)
     angleF1Rads AS DOUBLE      'Radius1 angle, measured from foci 1 {cos C = (a^2 + b^2 - c^2)/2ab}
     angleF2Rads AS DOUBLE      'Radius2 angle, measured from foci 2 {cos B = (c^2 + a^2 - b^2)/2ca}
     angleFiaRads AS DOUBLE     'included angle, between Radius1 and Radius2  {cos A = (b^2 + c^2 - a^2)/2bc}
     angleFia2Rads AS DOUBLE    'normal angle equals one-half the included angle between RadF1 and RadF2
     angleNF1Rads AS DOUBLE     'normal angle measured at X axis intersection on F1 side
     angleNF2Rads AS DOUBLE     'normal angle measured at X axis intersection on F2 side
     nXF1 AS DOUBLE             'distance from F1 to tangent line intersection along X axis
     radNF1 AS DOUBLE           'length of tangent line measured from chord X,Y position to X axis line
     nXF2 AS DOUBLE             'distance from F2 to tangent line intersection along X axis
     radNF2 AS DOUBLE           'length of tangent line measured from chord X,Y position to X axis line

     nAccumErr AS DOUBLE        'error accumulator
     plength AS DOUBLE          'perimeter length
     perimL AS DOUBLE           'length of nozzle weld perimeter, measured at outside HAZ edge,
     pflag AS LONG              'flag set to store perimeter length

     thetaS AS DOUBLE           'start angle / position
     thetaInv AS DOUBLE         'start angle inverse
     theta360 AS DOUBLE         'end angle / position
     thetaInc AS DOUBLE         'current degree increment
     theta AS DOUBLE            'current degree position
     thetaRads AS DOUBLE        'assigned thetaRads to theta
     theta405 AS DOUBLE         'overlap = nRay.theta360 + Rads45  'always add 45 degrees overlap
     thetaflag AS LONG          'Boolean flag
                                 'polar real; Normal angle to radius of a specific point on the weld perimeter.

     i_xIndexBegin AS INTEGER   'number of X-indexes to begin index
     i_xIndexEnd AS INTEGER     'number of X-indexes to last index

     i_xIndexBegin_U AS INTEGER 'number of X-indexes to begin index
     i_xIndexEnd_U AS INTEGER   'number of X-indexes to user set max index, has no impact on Model, ends X-index'ing short


     i_xIndex360 AS INTEGER     'number of X-indexes to reach 360 degrees
     i_xIndex405 AS INTEGER     'number of X-indexes to reach 360 degrees + i_xExtraIndx
     i_xExtraIndx AS INTEGER    'number of added X-indexes for overlap
     i_yIndexBegin AS INTEGER   'Integer: number of Y-Indexes to begin index
     i_yIndexEnd AS INTEGER     'Integer: number of Y-Indexes to last index

     r_xBegin AS DOUBLE         'Real: X-Axis Begin
     r_xEnd AS DOUBLE           'Real: X-Axis End
     r_xIndexIncFixed AS DOUBLE 'Real X-Index Increment set by user, fixed unless model is ran again
     r_yBegin AS DOUBLE         'Real: Y-Axis Begin
     r_yEnd AS DOUBLE           'Real: Y-Axis End
     r_yIndexInc AS DOUBLE      'Real: Y-Index increment for circ raster, ax or circ beam

     xOffset AS DOUBLE          'X-offset surface distance from index to beam at ID

     skewRads AS DOUBLE         'skew angle of probe in rads
     skewDegs AS DOUBLE         'skew angle of probe in degrees
     skewDir AS LONG            'skew direction, +/-, beam pointing from either negative or positive side of zero

     Weld_Haz AS DOUBLE         'width of HAZ "Heat Affected Zone" - for plotting scan model
     Weld_Width AS DOUBLE       'width of weld -                     for plotting scan model
     Scan_Rad AS DOUBLE         'set length of nozzle scan lines     for plotting scan model

     RasterAxial AS LONG        'true or false: False = raster in circ direction, True = raster in axial direction
     AxialBeam AS LONG          'true or false: False = circ beam, True = axial beam

     nNormAngRads AS DOUBLE     '0 to 360 Normal angle of chord, measured from X-Axis base to chord X,Y point
     nOriginX AS DOUBLE         'cartesian real; X offset to origin of the vector, Normal to a point on the weld.
     nRadiusNorm AS DOUBLE      'polar real; Vector magnitude, length of radius. Origin = (nRay.eOriginX,eNormYpos)
     nRotAngRads AS DOUBLE      'transducer rotational angle, 0 to 360 degrees translation
     nArcSeg AS DOUBLE          'single arc segment length
     nArcTotal AS DOUBLE        'arc segment total length to THIS point
     nXpos AS DOUBLE            'cartesian real; X coordinate of this point along weld edge, at far side edge of weld HAZ.
     nYpos AS DOUBLE            'cartesian real; Y coordinate of this point along weld edge, at far side edge of weld HAZ.
     nNormAngNF2Rads AS DOUBLE  'normal angle measured at X axis intersection on F2 side
     fTemp(10) AS DOUBLE

     eNormAngRads(1000) AS DOUBLE   '0 to 360 Normal angle of chord, measured from X-Axis base to chord X,Y point
     eOriginX(1000) AS DOUBLE       'cartesian real; X offset to origin of the vector, Normal to a point at weld .
     eRadiusNorm(1000) AS DOUBLE    'polar real; Vector magnitude, length of radius. Origin = (nRay.eOriginX,eNormYpos)
     eRotAngRads(1000) AS DOUBLE    'transducer rotational angle, 0 to 360 degrees translation
     eArcSeg(1000) AS DOUBLE        'single arc segment length
     eArcTotal(1000) AS DOUBLE      'arc segment total length to THIS point
     eXpos(1000) AS DOUBLE          'cartesian real; X coordinate of this point along weld, far side edge of weld HAZ.
     eYpos(1000) AS DOUBLE          'cartesian real; Y coordinate of this point along weld, far side edge of weld HAZ.
     eNormAngNF2Rads(1000) AS DOUBLE'normal angle measured at X axis intersection on F2 side

     sXpos(1000) AS DOUBLE          'cartesian real; X coordinate of eXpos point along weld, extended to outer y-stroke boundry
     sYpos(1000) AS DOUBLE          'cartesian real; Y coordinate of eYpos point along weld, extended to outer y-stroke boundry


END TYPE

'GLOBAL nRay AS FociRay


TYPE ScanVars

    YCtr        AS DOUBLE      'YCts/inch *OR: per any unit specified by user
    XCtr        AS DOUBLE      'XCts/inch
    ZCtr        AS DOUBLE      'ZCts/Degree
    ACtr        AS DOUBLE      'Aux Enc Cts/inch

    YCal        AS DOUBLE      'Y Cal Inch distance  *OR: per any unit specified by user
    XCal        AS DOUBLE      'X Cal Inch distance
    ZCal        AS DOUBLE      'Z Cal Degree distance
    ACal        AS DOUBLE      'Aux Cal Inch distance

    XOffset     AS DOUBLE      'X inch pos when counter zeroed   *OR: per any unit specified by user
    YOffset     AS DOUBLE      'Y inch pos when counter zeroed
    ZOffset     AS DOUBLE      'Z degree pos when counter zeroed
    AOffset     AS DOUBLE      'A Inch pos when counter zeroed

    XPos        AS DOUBLE      'current X inch position  *OR: per any unit specified by user
    YPos        AS DOUBLE      'current Y inch position
    ZPos        AS DOUBLE      'current Z inch position
    APos        AS DOUBLE      'current A inch position

    XPlus       AS LONG      'X scan +/-
    YPlus       AS LONG      'Y scan +/-
    ZPlus       AS LONG      'Z scan +/-

    XDataStart  AS LONG         'x array position for scan start
    YDataStart  AS LONG         'y array position for scan start
    ZDataStart  AS LONG         'Z array position for scan start

    XDataEnd    AS LONG         'x array position for scan end
    YDataEnd    AS LONG         'y array position for scan end
    ZDataEnd    AS LONG         'z array position for scan end

    XIndex      AS DOUBLE      'x inch index
    YIndex      AS DOUBLE      'y inch index
    ZIndex      AS DOUBLE      'z inch index

    XIndexCts   AS LONG         'x actual value (+/-) counts per index
    YIndexCts   AS LONG         'y actual value (+/-) counts per index
    ZIndexCts   AS LONG         'z actual value (+/-) counts per index

    IndexDir    AS LONG      'Index towards High or Low: RN IndexLow

    XCts        AS LONG         'x absolute value scan start counts
    YCts        AS LONG         'y absolute value scan start counts
    ZCts        AS LONG         'z absolute value scan start counts
    ACts        AS LONG         'a absolute value scan start counts

    XStartCts   AS LONG         'x actual value (+/-) scan start counts
    YStartCts   AS LONG         'y actual value (+/-) scan start counts
    ZStartCts   AS LONG         'z actual value (+/-) scan start counts

    r_xEndCts     AS LONG         'x actual value (+/-) scan end counts
    r_yEndCts     AS LONG         'y actual value (+/-) scan end counts
    ZEndCts     AS LONG         'z actual value (+/-) scan end counts

    XLow        AS DOUBLE      'x scan start inch position  *OR: per any unit specified by user
    YLow        AS DOUBLE      'y scan start inch position
    ZLow        AS DOUBLE      'z scan start inch position

    XHigh       AS DOUBLE      'x scan end inch position
    YHigh       AS DOUBLE      'y scan end inch position
    ZHigh       AS DOUBLE      'z scan end inch position

    OverLap     AS DOUBLE      'added si scan overlap

    XSpeed      AS DOUBLE      'x scan speed in inches
    YSpeed      AS DOUBLE      'y scan speed in inches
    ZSpeed      AS DOUBLE      'z scan speed in inches

    XEnable     AS LONG      'flag true/false X axis on
    YEnable     AS LONG      'flag true/false Y axis on
    ZEnable     AS LONG      'flag true/false Z axis on

    XSpdDir     AS LONG      'flag X speed cntrl direction
    IndexY      AS LONG      'flag true/false index on X or Y, circ or ax scan
    StopChk     AS LONG      'flag true/false autoOff on/off
    DualRas     AS LONG        'flag true/false double raster each index
    AutoHold    AS LONG      'flag true/false Auto Hold
    IndexCt     AS LONG      'index loop counter
    IndexInc    AS LONG      'index loop incrementer
    ScanFlag    AS LONG      '
    Index       AS LONG      'scan direction
    NextFlag    AS LONG      'added for si auto scan increment

    YCtrStr     AS STRING * 10
    XCtrStr     AS STRING * 10
    ZCtrStr     AS STRING * 10
    ACtrStr     AS STRING * 10

    YCalStr     AS STRING * 10  'Y Cal Inch distance
    XCalStr     AS STRING * 10  'X Cal Inch distance
    ZCalStr     AS STRING * 10  'Z Cal Inch distance
    ACalStr     AS STRING * 10  'A Cal Inch distance

    XPosStr     AS STRING * 10
    YPosStr     AS STRING * 10
    ZPosStr     AS STRING * 10
    APosStr     AS STRING * 10

    XPlusSTR    AS STRING * 10
    YPlusSTR    AS STRING * 10
    ZPlusSTR    AS STRING * 10

    XIndexSTR   AS STRING * 10
    YIndexSTR   AS STRING * 10
    ZIndexSTR   AS STRING * 10

    IndexLowStr AS STRING * 10

    XLowStr     AS STRING * 10
    YLowStr     AS STRING * 10
    ZLowStr     AS STRING * 10

    XHighStr    AS STRING * 10
    YHighStr    AS STRING * 10
    ZHighStr    AS STRING * 10

    OverLapStr  AS STRING * 10

    XSpeedSTR   AS STRING * 10
    YSpeedSTR   AS STRING * 10
    ZSpeedSTR   AS STRING * 10

    XEnableSTR  AS STRING * 10
    YEnableSTR  AS STRING * 10
    ZEnableSTR  AS STRING * 10

    XSpdDirSTR  AS STRING * 10

    IndexYSTR   AS STRING * 10

    StopChkSTR  AS STRING * 10

    DualRasSTR  AS STRING * 10

    NextFlagSTR AS STRING * 10

    AutoHoldSTR AS STRING * 10


    'NEW - added 7/9/15


    yStroke AS DOUBLE
    setIndex AS DOUBLE



    aProbeWidth AS DOUBLE   'axial probe overall width, contact footprint
    aProbeLen AS DOUBLE     'axial probe overall length, contact footprint
    aProbeIdx  AS DOUBLE    'axial probe index position, measured from front of wedge or wedge case

    cProbeWidth AS DOUBLE     'circ probe overall width, contact footprint
    cProbeLen AS DOUBLE       'circ probe overall length, contact footprint
    cProbeIdx AS DOUBLE       'cir probe index position, measured from front of wedge or wedge case
    cProbeXOffset AS DOUBLE   'circ scan probe only; offset distance: equals surface distance from index to beam intersection point at ID
    cProbeSkew AS DOUBLE      'circ scan skew angle

    weldWidth AS DOUBLE       'width of weld  ! move this to nozzle param
    weldHaz AS DOUBLE         'width of weld HAZ ! move this to nozzle param

END TYPE

'GLOBAL SCN AS ScanVars

'NEW - added 7/9/15
TYPE u_ScanVars

    'user enters these  directly

    yStroke AS DOUBLE
    setIndex AS DOUBLE
    aProbeLen AS DOUBLE '= 2.200# 'transducer length
    aProbeIdx  AS DOUBLE ' .800#   '1.00# '0.800# 'transducer index position, measured setback from front
    aProbeWidth AS DOUBLE '= 2.600# 'transducer width
    cProbeWidth AS DOUBLE
    cProbeXOffset AS DOUBLE
    cProbeIdx AS DOUBLE 'set to (-) 'transducer index position, measured setback from front
    cProbeLen AS DOUBLE
    cProbeSkew AS DOUBLE
    weldWidth AS DOUBLE
    weldHaz AS DOUBLE

END TYPE

'GLOBAL u_SCN AS u_ScanVars


TYPE u_GFXvars

     IdxLine AS DOUBLE     'set length/2 of projected index line along probe width axis, total line length drawn = x2
     CentLine AS DOUBLE    'set length/2 of projected center line along probe length axis, total line length drawn = x2
     ballRad  AS DOUBLE    'meatball radius


     'tangent and normal line are plotted in addition to index and center line for circ scans with probe skew
     TngtLine AS DOUBLE    'length of projected line tangent to weld axis, total line length drawn = x2
     NormLine AS DOUBLE    'length of projected line normal to weld axis, total line length drawn = x2


     IdxLineSW AS LONG     'SWitch line on/off
     CentLineSW AS LONG    'line on/off
     TngtLineSW AS LONG    'line on/off
     NormLineSW AS LONG    'line on/off
     offBallSW AS LONG     'offset ball on/off
     probeBallSW AS LONG   'probe ball on/off


     IdxLineClr AS LONG    'line colors
     CentLineClr AS LONG
     TngtLineClr AS LONG
     NormLineClr AS LONG


     aprobeClr AS LONG       'axial probe perimeter case color
     aprobefillClr AS LONG   'axial probe fill color

     cprobeClr AS LONG       'circ probe perimeter case color
     cprobefillClr AS LONG   'circ probe fill color

     offsetBallClr AS LONG  'ball at offset color
     probeBallClr AS LONG   'ball at probe center color

     'nozzle model colors
     eStartClr AS LONG      'scan start radial line color
     eEndClr AS LONG        'scan end radial line color
     eExtraClr AS LONG      'scan extra radial line color
     eRadialClr AS LONG     'all other scan radial scan line
     eInsideClr AS LONG     'center radial normal lines
     eOutPClr AS LONG       'outer perimeter line color
     eWeldClr AS LONG       'weld radial line color
     eWeldPClr AS LONG      'weld perimeter line color
     eHAZClr AS LONG        'HAZ radial line color
     eHAZPClr AS LONG       'HAZ perimeter line color

END TYPE

'GLOBAL u_GFX AS u_GFXvars



TYPE MoveProfile

     m1Sp AS DOUBLE   'speed
     m1Ve AS DOUBLE   'velocity

     m1Da AS DOUBLE   'distance traveled during acceleration
     m1Dd AS DOUBLE   'distance traveled during deceleration
     m1Ds AS DOUBLE   'distance traveled during slew speed
     m1Dt AS DOUBLE   'distance total distance moved = DA+DD+DS

     m1Ta AS DOUBLE   'time @ acceleration
     m1Td AS DOUBLE   'time @ decelartion
     m1Ts AS DOUBLE   'time @ slew speed
     m1Tm AS DOUBLE   'time to complete move = TA+TD+TS

     m1Tc AS DOUBLE   'time constant
     m1Gr AS DOUBLE   'Gear Ratio
     m1Ct AS DOUBLE   'Counts

     m1Ar AS DOUBLE    'Acceleration rate in inches/ sec / sec

     mTemp(20)AS DOUBLE 'temp calculations

END TYPE
'GLOBAL mTrap AS MoveProfile

FUNCTION PBMAIN

    'storage memory for model generation and scan segments

    DIM nRay AS LOCAL FociRay

    DIM u_GFX AS LOCAL u_GFXvars

    DIM SCN AS LOCAL ScanVars

    DIM u_SCN AS LOCAL u_ScanVars

    DIM NumOfSeg_G AS GLOBAL LONG
    DIM BeginSeg_G(5) AS GLOBAL DOUBLE
    DIM xMtrSeg_G(2000) AS GLOBAL DOUBLE
    DIM yMtrSeg_G(2000) AS GLOBAL DOUBLE
    DIM zMtrSeg_G(2000) AS GLOBAL DOUBLE
    DIM xImgSeg_G(2000) AS GLOBAL DOUBLE
    DIM yImgSeg_G(2000) AS GLOBAL DOUBLE
    DIM xySegLn_G(2000) AS GLOBAL DOUBLE

    '*******************************************************************************************
    ' Screen varibles
    '*******************************************************************************************

    LOCAL BackClr&, ForeClr&, PlotClr&, HighClr&, LowClr&, NormClr&, Clr1&, Clr2&, Clr3&

    DIM hWin(1)AS LONG ' Graphic Window handles

    LOCAL hWinCheck& 'check if user closed window

    LOCAL PixPerInch!, xScrn1!, yScrn1!, XScrn2!, yScrn2!, xSCRN&, ySCRN&

    LOCAL hFont&

    LOCAL numOfpaths, n60HzSegments AS LONG

    '*******************************************************************************************
    ' Screen plot settings
    '*******************************************************************************************
    ySCRN& = 1800 : xSCRN& = 1000

    PixPerInch! = 0.04!  '0.035! '0.05! '0.010! '.040!   ' graphic window size

    yScrn1! = -(ySCRN& * .400!* PixPerInch!) : yScrn2! = ySCRN& * .400!* PixPerInch!

    xScrn1! = -(xSCRN& * .400!* PixPerInch!) : xScrn2! = (xSCRN& * .400!* PixPerInch!)

    PlotClr& = %WHITE
    BackClr& = %BLACK
    ForeClr& = PlotClr&

    '----------------------------------------------------------------------------------------------------

    'assigned even numbers for standard windows, direct display
    GRAPHIC WINDOW "NOZZLE 'Top View'", 10, 10, ySCRN&, xSCRN& TO hWin(0) 'Create a graphic window and assign it a handle
    GRAPHIC ATTACH hWin(0), 0&                                  'Select standard window
    GRAPHIC COLOR ForeClr&, BackClr&                            'Set foreground and  background color
    GRAPHIC CLEAR                                               'Clear selected window with background color
    GRAPHIC SCALE(yScrn1!,xScrn1!)-(yScrn2!,xScrn2!)

    'assigned odd numbers for bitmaps or special use windows, used to store static images for copying to standard window
    GRAPHIC BITMAP NEW ySCRN&, xSCRN& TO hWin(1) 'bitmap window for current nozzle weld scan model
    GRAPHIC ATTACH hWin(1), 0&                   'Select bitmap window #1
    GRAPHIC COLOR ForeClr&, BackClr&             'Set foreground and  background color
    GRAPHIC CLEAR                                'Clear selected window with background color
    GRAPHIC SCALE(yScrn1!,xScrn1!)-(yScrn2!,xScrn2!)

    GRAPHIC ATTACH hWin(0), 0&, REDRAW       'Select standard window
    'GRAPHIC WINDOW STABILIZE hWin(0) 'user can't close window
    GRAPHIC SET FOCUS

    FONT NEW "Times New Roman", 12, 1 TO hFont&
    GRAPHIC SET FONT hFont&

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'!!!!!!!!!!!  - GENERATE THE NOZZLE MODEL -
'            ONLY (5) USER inputs required, (excluding colors!)
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    '**********************************************************************************************
    '   user set
    '**********************************************************************************************
    nRay.majorAxis = 8.7318# 'CIRC: (as measured on curve, 50" Diameter)

    nRay.minorAxis = 8.6875# 'AXIAL:(as measured on flat)

    nRay.r_xIndexIncFixed = .150#  'x index increment

    'scan start position: Scanner vs program
    'X_AXIS SIDE,transducer 0   Degrees = 270 Degrees program
    '                       90  Degrees = 0   Degrees program
    '                       180 Degrees = 90  Degrees program
    '                       270 Degrees = 180 Degrees program



    'transducer @ 0 Degrees = 0 program Degrees
    'nRay.thetaS = Rads270 'set start angle / position

    'transducer @ 90 Degrees = 0 program Degrees
    'nRay.thetaS = Rads0 'set start angle / position

    'transducer @ 180 Degrees = 0 program Degrees
    'nRay.thetaS = Rads90 'set start angle / position

    'transducer @ 270 Degrees = 0 program Degrees
    nRay.thetaS = Rads180 'set start angle / position


    nRay.i_xExtraIndx = 7

    GRAPHIC ATTACH hWin(0), 0&,REDRAW           'select standard window

    FONT NEW "Times New Roman", 20, 1 TO hFont&
    GRAPHIC SET FONT hFont&

    GenerateModel(VARPTR(nRay))

    FONT NEW "Times New Roman", 12, 1 TO hFont&
    GRAPHIC SET FONT hFont&
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'!!!!!!!!!!!  - DRAW THE NOZZLE WELD SCAN MODEL -
'            ONLY (4) USER inputs required, (excluding colors!)
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    'user set colors for model
    u_GFX.eStartClr = %GREEN        'scan start; outer radial line color
    u_GFX.eEndClr = %RGB_RED        'scan end; outer radial line color
    u_GFX.eExtraClr = %MAGENTA      'scan extra; outer radial line color
    u_GFX.eRadialClr = %RGB_GOLD    'all other; outer scan radial scan line
    u_GFX.eInsideClr = %RGB_GOLD    'center inside; radial line line color
    u_GFX.eOutPClr = %BLUE          'outer perimeter; line color
    u_GFX.eWeldClr = %GREEN         'weld; radial line color
    u_GFX.eWeldPClr = %GREEN        'weld; perimeter line color
    u_GFX.eHAZClr = %RGB_RED        'HAZ; radial line color
    u_GFX.eHAZPClr = %RGB_RED       'HAZ; perimeter line color


    'user set model parameters: weld width, HAZ width and length of scan lines
    nRay.Scan_Rad = 10.00#          'length of radial scan lines, normal to weld
    nRay.Weld_Haz = 0.250#          'width of HAZ (Heat Affected Zone), x2: outside HAZ and inner-side HAZ at weld edges
    nRay.Weld_Width = 1.00#         'width of weldment

    'select and draw the model to bitmap #1
    GRAPHIC ATTACH hWin(1), 0&  'Select bitmap #1 window
    GRAPHIC CLEAR  ' clear the current screen before plotting

    DrawScanModel(VARPTR(nRay), VARPTR(u_GFX)) 'draw the model bitmap to reuse later

    GRAPHIC ATTACH hWin(0), 0&,REDRAW           'select standard window

    GRAPHIC COPY hwin(1), 0&

    GOTO CircScan  'User selected Circ UT Beam Scan Path Segments: "GenCircSegments"

    'OR          'User selected Axial UT Beam Scan Path Segments: "GenAxialSegments", below

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'               GENERATE AXIAL SCAN PATH SEGMENTS
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    'USER selects generation of either Axial UT Beam Scan Path Segments: "GenAxialSegments"
    'OR USER selects generation of Circ UT Beam Scan Path Segments: "GenCircSegments"
    'Circ UT Beam: UT sound beam travels parallel to the weld axis
    'Axial UT Beam: UT sound beam travels perpendicular the the weld axis

    'user set Y-Scan begin and end
    'nRay.r_yBegin = y scan start
    'nRay.r_yEnd = = y scan end
    nRay.r_yBegin = .150# :  nRay.r_yEnd = 5.540#

    'addtional value needed if nRay.RasterAxial = False, meaning raster motion is Circ direction
    nRay.r_yIndexInc = .250#  'index increment for Circ Raster

    'set by user, RasterAxial is back and forth scan motion, to and from the weld
    'If RasterAxial is False, scan motion is side to side, parallel along the weld,
    nRay.RasterAxial = True  'True 'False 'True 'False

    nRay.AxialBeam = True 'True 'False
    '*********************************************************************************************
    'Set to values when nozzle was modeled previously in "GenerateModel(VARPTR(nRay))"
        'nRay.r_xIndexIncFixed = .25#  'x index increment
        'nRay.thetaS = Rads270 '= Rads270 'OR: Rads180 Rads90 Rads0 'set start angle / position
        'nRay.i_xExtraIndx = 2
        'values calculated and returned from "GenerateModel(VARPTR(nRay))"
          'nRay.i_xIndexEnd = total number of X indexes to run
          'nRay.i_xIndex360 = number of X indexes for a full 360 degrees back to 0
          'nRay.i_xIndex405 = number of indexes to reach minimum of 405 degrees,
                             'slightly more depending on user set index value
    'Set to values above in this section:
         'nRay.r_yBegin = -0.800#
         'nRay.r_yEnd = 10.800#
         'nRay.r_yIndexInc = .875# '1.00#  'y index inc: used circ direction scan, nRay.RasterAxial = False

    'nRay.i_xIndexEnd = nRay.i_xIndexEnd/2

    IF nRay.RasterAxial THEN   'towards and away from weld
       NumOfSeg_G =  (nRay.i_xIndexEnd) * 2
    ELSE  'circ, side to side scan
       NumOfSeg_G =  (nRay.i_xIndexEnd+1) * CLNG((ABS(nRay.r_yEnd-nRay.r_yBegin)/nRay.r_yIndexInc)+1)
    END IF

    PRINT "Calculated paths: "; NumOfSeg_G

    'adjust memory to store the required path segments
    REDIM xMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM zMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xySegLn_G(NumOfSeg_G) AS GLOBAL DOUBLE

    NumofPaths = GenAxialSegments (VARPTR(nRay))

    PRINT "Actual paths: "; NumOfPaths
    PRINT "PRESS ANY KEY"
    WAITKEY$


'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'               RUN THE ABOVE GENERATE AXIAL SCAN PATH, SIMULATOR AND/OR ACTUAL SCANNER
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    u_GFX.aprobeClr = %RGB_YELLOW      'probe perimeter case color
    u_GFX.aprobefillClr = %RGB_ORANGE  'probe fill color
    u_GFX.TngtLineClr = %RGB_RED            'tangent line color for/if probe skew
    u_GFX.NormLineClr = %RGB_RED            'normal line color for/if probe skew
    u_GFX.CentLineClr = %RGB_WHITE          'probe center line color, probe beam
    u_GFX.IdxLineClr = %RGB_WHITE           'probe index line color
    u_GFX.offsetBallClr = %RGB_WHITE  'ball at offset color
    u_GFX.probeBallClr = %RGB_BLACK   'ball at probe center color

    u_GFX.ballRad = 0.100#    'meatball radius
    u_GFX.IdxLine = 3
    u_GFX.CentLine = 10
    u_GFX.TngtLine = 10
    u_GFX.NormLine = 10

    'generic small probe - dimmensions taken from transducer used for qualification
    'has no effect on scan accuracy, all scan parameters taken from centerline of gimbal slide fixture
    '!!! CRITICAL !!!Index point of transducer MUST BE ALIGNED with CENTERLINE of GIMBAL SLIDE (plunger)
    'user input: Axial Probe length, width and index
    u_SCN.aProbeLen = 1.900## '1.92# 'transducer length
    u_SCN.aProbeIdx = 0.900#  '.95#   '1.00# '0.800# 'transducer index position, measured setback from front
    u_SCN.aProbeWidth = 1.650# '1.650# 'transducer width


'save the paths
'************************************************************************************************************************************
    SaveFile2(VARPTR(nRay), VARPTR(u_GFX), VARPTR(u_SCN))

    PRINT "File Saved! - PRESS ANY KEY"
    WAITKEY$

    'erase everything to verify its working 100%!!
    NumOfSeg_G =0
    REDIM BeginSeg_G(5) AS GLOBAL DOUBLE
    REDIM xMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM zMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xySegLn_G(NumOfSeg_G) AS GLOBAL DOUBLE

    PRINT "ERASED! - PRESS ANY KEY"
    WAITKEY$

    'load the paths  - just to be sure they saved correctly
    LoadFile

    PRINT "File Loaded! - PRESS ANY KEY"
    WAITKEY$

    PRINT "Getting Number of Segments............ "
    n60HzSegments = Get60HzSegs(VARPTR(nRay))
    PRINT "Number Of Segments: "; n60HzSegments
    WAITKEY$

    RunAxialScan(VARPTR(nRay), VARPTR(u_SCN), VARPTR(u_GFX), VARPTR(hWin(1)))

    BEEP

    PRINT "WAITKEY$"

    WAITKEY$

    GOTO ExitWindows2

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'EXIT THE PROGRAM FOR NOW



CircScan:

     'User selected Circ UT Beam Scan Path Segments: "GenCircSegments"
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'               GENERATE CIRC SCAN PATH SEGMENTS
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    'USER selects generation of either Axial UT Beam Scan Path Segments: "GenAxialSegments"
    'OR USER selects generation of Circ UT Beam Scan Path Segments: "GenCircSegments"
    'Circ UT Beam: UT sound beam travels parallel to the weld axis
    'Axial UT Beam: UT sound beam travels perpendicular the the weld axis

    'these values have already been set, and should match, "DrawScanModel"  generated above
    'nRay.r_yEnd value would be much smaller here for a CIRC UT BEAM scan, probably 2" or less
    nRay.r_yBegin = -1.750# '0'0.800# :
    nRay.r_yEnd = 0.250# '10.800#

    'addtional value needed if nRay.RasterAxial = False, meaning raster motion is Circ direction
    nRay.r_yIndexInc = .250#  'index increment for Circ Raster

    'set by user, RasterAxial is back and forth scan motion, to and from the weld
    'If RasterAxial is False, scan motion is side to side, parallel along the weld
    'normal for a CIRC UT BEAM Scan is RasterAxial = False
    nRay.RasterAxial = False 'False ' TRUE 'False 'True 'False
    nRay.AxialBeam = False   'circ beam, axial beam = false
    'In addtion to above values, specific to a CIRC UT BEAM Scan as opposed to a AXIAL UT BEAM Scan,
    'being more complex, requires the additional parameters:
    '!!BOTH MUST BE SET to either positive or negative!!
    nRay.skewDegs = .0001# '-12.00#  'transducer skew: -skewDegs = transducer on -side, UT Beam pointing CW
    nRay.xOffset = 4.330#    'transducer offset, index distance, to UT beam @ ID

    'OR:

    'nRay.skewDegs = .0001#  'transducer skew: +skewDegs = transducer on +side, UT Beam pointing CCW
    'nRay.xOffset = 4.330#    'transducer offset, index distance, to UT beam @ ID

    'nRay.i_xIndexEnd = nRay.i_xIndexEnd/2

    IF nRay.RasterAxial THEN   'towards and away from weld
       NumOfSeg_G =  (nRay.i_xIndexEnd) * 2
    ELSE  'circ, side to side scan
       NumOfSeg_G =  (nRay.i_xIndexEnd+1) * CLNG((ABS(nRay.r_yEnd-nRay.r_yBegin)/nRay.r_yIndexInc)+1)
    END IF

    PRINT "Calculated paths: "; NumOfSeg_G

    'adjust memory to store the required path segments
    REDIM xMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM zMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xySegLn_G(NumOfSeg_G) AS GLOBAL DOUBLE

    NumofPaths = GenCircSegments (VARPTR(nRay))

    PRINT "Actual paths: "; NumOfPaths
    PRINT "PRESS ANY KEY"
    WAITKEY$

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'               RUN THE ABOVE GENERATE CIRC SCAN PATH, SIMULATOR AND/OR ACTUAL SCANNER
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    u_GFX.cprobeClr = %RGB_LIGHTYELLOW      'probe perimeter case color
    u_GFX.cprobefillClr = %RGB_ORANGE       'probe fill color
    u_GFX.TngtLineClr = %RGB_RED            'tangent line color for/if probe skew
    u_GFX.NormLineClr = %RGB_RED            'normal line color for/if probe skew
    u_GFX.CentLineClr = %RGB_WHITE          'probe center line color, probe beam
    u_GFX.IdxLineClr = %RGB_WHITE           'probe index line color
    u_GFX.offsetBallClr = %RGB_WHITE        'ball at offset color
    u_GFX.probeBallClr = %RGB_BLACK         'ball at probe center color
    u_GFX.ballRad = 0.200#                  'meatball radius

    u_GFX.IdxLine = 10
    u_GFX.CentLine = 10
    u_GFX.TngtLine = 10
    u_GFX.NormLine = 10


    'user input: Circ Probe Skew, length, width and index
    u_SCN.cProbeLen = 2.100# 'transducer length
    u_SCN.cProbeIdx = 0.900#   '1.00# '0.800# 'transducer index position, measured setback from front
    u_SCN.cProbeWidth = 2.600# 'transducer width

    'probe X offset distance, projected at 90 degrees from polar scan line, parallel with weld axis, based on beam angle and weld thickness
    'If offsetset is negative, cProbeIdx & cProbeLen is also negative
    u_SCN.cProbeXOffset = nRay.xOffset ' -7  '-6.20#  'Set to negative above if transducer beam is pointing CW, Positive if beam is pointing CCW

    IF u_SCN.cProbeXOffset < 0 THEN
       u_SCN.cProbeSkew = ABS(nRay.skewDegs) 'opposite nRay.skew
       u_SCN.cProbeIdx = -(0.900#) 'set to (-) 'transducer index position, measured setback from front
       u_SCN.cProbeLen = -(2.100#) 'set to (-) 'probe length
    ELSE
       u_SCN.cProbeSkew = -(ABS(nRay.skewDegs)) ' opposite nRay.skew
       u_SCN.cProbeIdx = (0.900#) 'set to (+) 'transducer index position, measured setback from front
       u_SCN.cProbeLen = (2.100#) 'set to (+) 'probe length
    END IF


'save the paths
'************************************************************************************************************************************

    SaveFile2(VARPTR(nRay), VARPTR(u_GFX), VARPTR(u_SCN))

    PRINT "File Saved! - PRESS ANY KEY"
    WAITKEY$

    'erase everything to verify its working 100%!!
    NumOfSeg_G =0
    REDIM BeginSeg_G(5) AS GLOBAL DOUBLE
    REDIM xMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM zMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xySegLn_G(NumOfSeg_G) AS GLOBAL DOUBLE

    PRINT "ERASED! - PRESS ANY KEY"
    WAITKEY$

    'load the paths  - just to be sure they saved correctly
    LoadFile

    PRINT "File Loaded! - PRESS ANY KEY"
    WAITKEY$

    PRINT "Getting Number of Segments............ "
    n60HzSegments = Get60HzSegs(VARPTR(nRay))
    PRINT "Number Of Segments: "; n60HzSegments
    WAITKEY$

    RunCircScan(VARPTR(nRay), VARPTR(u_SCN), VARPTR(u_GFX), VARPTR(hWin(1)))

    BEEP

    PRINT "WAITKEY$"

    WAITKEY$

    GOTO ExitWindows2


'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'EXIT THE PROGRAM FOR NOW


    BEEP

    PRINT "WAITKEY$"

    WAITKEY$

    GOTO ExitWindows2



ExitWindows2:

      'Close and exit all windows
    GRAPHIC ATTACH hWin(0), 0&  'select the STANDARD Graphics window
    GRAPHIC WINDOW END          'close the selected STANDARD Graphics window

    GRAPHIC ATTACH hWin(1), 0&  'select the Memory Bitmap Graphics window
    GRAPHIC BITMAP END          'close the selected Memory Bitmap Graphics window


    BEEP


    'END if

    END FUNCTION



'**********************************************************************************************************************************************
'USER DEFINED FUNCTIONS

'----------------------------------------------------------------------------------------------------------------------------------------------
'Translate +/-degree's to 0-360 degree values
'X =xPos, Y =yPos, A =angle in degrees
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetX360(BYVAL X#, BYVAL Y#, BYVAL A#) AS DOUBLE
    IF (X#=>0) AND (Y#=>0) THEN
       FUNCTION = A#               'Quadrant(1),0-90 degrees,+COS(X),+SIN(Y) A# = 0 to 90
    ELSEIF (X#<0) AND (Y#>0) THEN
       FUNCTION = A#+180           'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y) A# = -89.999 to 0
    ELSEIF (X#=<0)AND (Y#<=0)THEN
       FUNCTION = A#+180           'Quadrant(3),180-270 degrees,-COS(X),-SIN(Y) A# = 0 to 90
    ELSEIF (X#>0) AND (Y#<0) THEN
       FUNCTION = A#+360           'Quadrant(4),270-360 degrees,+COS(X),-SIN(Y) A# = -89.999 to 0
    END IF
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Translate NORMAL ANGLE to 0-360 degree values  A# = Normal angle measured from foci 2 (foci 1 is opposite)
'X =xPos, Y =yPos, A =angle in rads
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetN360(BYVAL X#, BYVAL Y#, BYVAL A#) AS DOUBLE
    IF (X#>0) AND (Y#=0) THEN       'Single case only: X is on positive side, Y is at 0, can only be @ 0 degrees
       FUNCTION = 0#
    ELSEIF (X#<0) AND (Y#=0) THEN   'Single case only: X is on negative side, Y is at 0, can only be @ 180 degrees
       FUNCTION = Rads180
    ELSEIF (X#=>0) AND (Y#=>0) THEN 'Quadrant(1), 0-90 degrees, +COS(X),+SIN(Y)   (foci2)A# = 0 to 90 (foci1= 180 to 90)
       FUNCTION = A#
    ELSEIF (X#<0) AND (Y#>0) THEN   'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y)  (foci2)A# = 90 to 180 (foci1= 90 to 0)
       FUNCTION = A#
    ELSEIF (X#=<0)AND (Y#<=0)THEN   'Quadrant(3), 180-270 degrees,-COS(X),-SIN(Y) (foci2)A# = 180 to 90 (foci1= 0 to 90)
       FUNCTION = (Rads180-A#)+ Pi
    ELSEIF (X#>0) AND (Y#<0) THEN   'Quadrant(4), 270-360 degrees,+COS(X),-SIN(Y) (foci2)A# = 90 to 0 (foci1= 90 to 180)
       FUNCTION = (Rads90-A#) + Rads270
    END IF
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Translate +/-degree's to 0-360 degree values
'X =xPos, Y =yPos, A =angle  in rads
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION Get360(BYVAL X#, BYVAL Y#, BYVAL A#) AS DOUBLE
    IF (X#=>0) AND (Y#=>0) THEN
       FUNCTION = A#               'Quadrant(1),0-90 degrees,+COS(X),+SIN(Y) A# = 0 to 90
    ELSEIF (X#<0) AND (Y#>0) THEN
       FUNCTION = A#+Rads180           'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y) A# = -89.999 to 0
    ELSEIF (X#=<0)AND (Y#<=0)THEN
       FUNCTION = A#+Rads180           'Quadrant(3),180-270 degrees,-COS(X),-SIN(Y) A# = 0 to 90
    ELSEIF (X#>0) AND (Y#<0) THEN
       FUNCTION = A#+Rads360           'Quadrant(4),270-360 degrees,+COS(X),-SIN(Y) A# = -89.999 to 0
    END IF
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Find radius of any foci point:  RADIUS = (r1*r2)^3^.5 / (MajorAxisRadius*MinorAxisRadius)
' F1L=foci1 length,F2L=foci2 length,LAR=Major Axis Radius, SAR=Minor Axis Radius
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadiusE (BYVAL F1L#, BYVAL F2L#, BYVAL LAR#, BYVAL SAR#) AS DOUBLE
     FUNCTION = (F1L#*F2L#)^3^.5 / (LAR#*SAR#)
     'angleArads# = ArcSin(ABS(YP(n%))/GetRadius#)
     'angleB# = 90-AngleA#
     'x# = XP(n%) - ABS((YP(n%)/ Tan(angleArads#)
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Find Major Axis Radius:  RADIUS = MinorAxisRadius^2 / MajorAxisRadius
' LAR=Major Axis Radius, SAR=Minor Axis Radius
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadiusL (BYVAL LAR#, BYVAL SAR#) AS DOUBLE
         FUNCTION = SAR#^2 / LAR#
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Find Minor Axis Radius:  RADIUS = MinorAxisRadius^2 / MajorAxisRadius
' LAR=Major Axis Radius, SAR=Minor Axis Radius
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadiusS (BYVAL LAR#, BYVAL SAR#) AS DOUBLE
         FUNCTION = LAR#^2 / SAR#
END FUNCTION


'----------------------------------------------------------------------------------------------------------------------------------------------
'Segment length
'LAR = XY Point 1, SAR = XY Point 2
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetSegLen (BYVAL LAR#, BYVAL SAR#) AS DOUBLE
         FUNCTION = SQR( SQ(LAR#)+ SQ(SAR#) )'segment length
END FUNCTION


'*************************************************************************************

'File I/O
'**********************************************************************************************************************
FUNCTION LoadFile AS LONG

    LOCAL filenumber, FileExists AS LONG
    LOCAL retval AS LONG, hWnd AS LONG
    LOCAL sPath, sfilename AS STRING

    'DIM offset(8) AS LOCAL LONG

    sPath = CURDIR$

    OpenFileDialog(BYVAL %HWND_DESKTOP, _
        "Open existing file", _
        sFilename, _
        sPath, _
        "Nozzle Scan Files (*.nsf)|*.nsf", _
        "nsf", _
        %OFN_ALLOWMULTISELECT OR %OFN_EXPLORER OR _
        %OFN_FILEMUSTEXIST OR %OFN_NODEREFERENCELINKS _
    )

    FileExists = ISFILE(sFileName)

    IF FileExists THEN
        filenumber = FREEFILE
        OPEN sfilename FOR BINARY AS filenumber BASE = 0
    ELSE
        PRINT "FILE NOT FOUND" ;sfilename
        WAITKEY$
        'add popup " FILE Not Found "
        'Wrong File?"
        EXIT FUNCTION
    END IF

    'get the number of segments first
    GET filenumber,, NumOfSeg_G

    'set memory to storage needed
    REDIM xMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM zMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xySegLn_G(NumOfSeg_G) AS GLOBAL DOUBLE

    'get the numbers!!
    GET filenumber,, BeginSeg_G()
    GET filenumber,, xMtrSeg_G()
    GET filenumber,, yMtrSeg_G()
    GET filenumber,, zMtrSeg_G()
    GET filenumber,, xImgSeg_G()
    GET filenumber,, yImgSeg_G()
    GET filenumber,, xySegLn_G()

    CLOSE filenumber


END FUNCTION


FUNCTION SaveFile AS LONG

    LOCAL filenumber, fileoffset, FileExists AS LONG
    LOCAL retval, hWnd AS LONG
    LOCAL sPath, sfilename AS STRING

    sPath = CURDIR$

    SaveFileDialog(BYVAL %HWND_DESKTOP, _
        "Save File To Folder", _
        sFilename, _
        sPath, _
        "Nozzle Scan Files (*.nsf)|*.nsf", _
        "nsf", _
        %OFN_ALLOWMULTISELECT OR %OFN_EXPLORER OR _
        %OFN_FILEMUSTEXIST OR %OFN_NODEREFERENCELINKS _
    )


    FileExists = ISFILE(sfileName)

    IF FileExists THEN   'add popup " FILE OVERWRITE? "
        filenumber = FREEFILE
        OPEN sfilename FOR BINARY AS filenumber BASE = 0
    ELSE
        filenumber = FREEFILE
        OPEN sfilename FOR BINARY AS filenumber BASE = 0
    END IF

    PUT filenumber,, NumOfSeg_G
    PUT filenumber,, BeginSeg_G()
    PUT filenumber,, xMtrSeg_G()
    PUT filenumber,, yMtrSeg_G()
    PUT filenumber,, zMtrSeg_G()
    PUT filenumber,, xImgSeg_G()
    PUT filenumber,, yImgSeg_G()
    PUT filenumber,, xySegLn_G()

    CLOSE filenumber

END FUNCTION

FUNCTION LoadFile2(BYVAL RayPtr AS DWORD, BYVAL u_GFXPtr AS DWORD, BYVAL u_ScanPtr AS DWORD) AS LONG

    LOCAL uSCN AS u_ScanVars POINTER
    LOCAL uGFX AS u_GFXvars POINTER
    LOCAL Ray AS FociRay POINTER

    Ray = RayPtr
    uGFX = u_GFXPtr
    uSCN = u_ScanPtr

    LOCAL filenumber, FileExists AS LONG
    LOCAL retval AS LONG, hWnd AS LONG
    LOCAL sPath, sfilename AS STRING

    LOCAL LoadModel AS LONG
    LoadModel = False

    sPath = CURDIR$

    OpenFileDialog(BYVAL %HWND_DESKTOP, _
        "Open existing file", _
        sFilename, _
        sPath, _
        "Nozzle Scan Files (*.nsf)|*.nsf", _
        "nsf", _
        %OFN_ALLOWMULTISELECT OR %OFN_EXPLORER OR _
        %OFN_FILEMUSTEXIST OR %OFN_NODEREFERENCELINKS _
    )

    FileExists = ISFILE(sFileName)

    IF FileExists THEN
        filenumber = FREEFILE
        OPEN sfilename FOR BINARY AS filenumber BASE = 0
    ELSE
        PRINT "FILE NOT FOUND" ;sfilename
        WAITKEY$
        'add popup " FILE Not Found "
        'Wrong File?"
        EXIT FUNCTION
    END IF

    'get the number of segments first
    GET filenumber,, NumOfSeg_G

    'set memory to storage needed
    REDIM xMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM zMtrSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM yImgSeg_G(NumOfSeg_G) AS GLOBAL DOUBLE
    REDIM xySegLn_G(NumOfSeg_G) AS GLOBAL DOUBLE

    'get the numbers!!
    GET filenumber,, BeginSeg_G()
    GET filenumber,, xMtrSeg_G()
    GET filenumber,, yMtrSeg_G()
    GET filenumber,, zMtrSeg_G()
    GET filenumber,, xImgSeg_G()
    GET filenumber,, yImgSeg_G()
    GET filenumber,, xySegLn_G()


    IF LoadModel THEN
       GET filenumber,, @Ray
       GET filenumber,, @uGFX
       GET filenumber,, @uSCN
    END IF

    CLOSE filenumber


END FUNCTION


FUNCTION SaveFile2(BYVAL RayPtr AS DWORD, BYVAL u_GFXPtr AS DWORD, BYVAL u_ScanPtr AS DWORD) AS LONG

    LOCAL uSCN AS u_ScanVars POINTER
    LOCAL uGFX AS u_GFXvars POINTER
    LOCAL Ray AS FociRay POINTER

    Ray = RayPtr
    uGFX = u_GFXPtr
    uSCN = u_ScanPtr

    LOCAL filenumber, fileoffset, FileExists AS LONG
    LOCAL retval, hWnd AS LONG
    LOCAL sPath, sfilename AS STRING

    LOCAL SaveModel AS LONG
    SaveModel = True 'False

    sPath = CURDIR$

    SaveFileDialog(BYVAL %HWND_DESKTOP, _
        "Save File To Folder", _
        sFilename, _
        sPath, _
        "Nozzle Scan Files (*.nsf)|*.nsf", _
        "nsf", _
        %OFN_ALLOWMULTISELECT OR %OFN_EXPLORER OR _
        %OFN_FILEMUSTEXIST OR %OFN_NODEREFERENCELINKS _
    )


    FileExists = ISFILE(sfileName)

    IF FileExists THEN   'add popup " FILE OVERWRITE? "
        filenumber = FREEFILE
        OPEN sfilename FOR BINARY AS filenumber BASE = 0
    ELSE
        filenumber = FREEFILE
        OPEN sfilename FOR BINARY AS filenumber BASE = 0
    END IF

    PUT filenumber,, NumOfSeg_G
    PUT filenumber,, BeginSeg_G()
    PUT filenumber,, xMtrSeg_G()
    PUT filenumber,, yMtrSeg_G()
    PUT filenumber,, zMtrSeg_G()
    PUT filenumber,, xImgSeg_G()
    PUT filenumber,, yImgSeg_G()
    PUT filenumber,, xySegLn_G()

    IF SaveModel THEN
       PUT filenumber,, @Ray
       PUT filenumber,, @uGFX
       PUT filenumber,, @uSCN
    END IF

    CLOSE filenumber

END FUNCTION

'**********************************************************************************************************************

SUB GetFoci(BYVAL ePosX AS DOUBLE, BYVAL ePosY AS DOUBLE, BYVAL RayPtr AS DWORD)

    LOCAL Ray AS FociRay POINTER
    Ray = RayPtr ' Set the pointer from the DWORD param

    '--------------------------------------------------------------------------------------------------------
    ' Get FOCUS triangle parameters, at current chord X,Y location. Use SSS(Side-Side-Side) triangle solution
    ' Includes both F1, F2 radius angle and length, and angle between F1, F2 = included angle
    '--------------------------------------------------------------------------------------------------------
    @Ray.fXpos1 = @Ray.foci+ePosX   'ePosX = current chord point x" location measured from Foci1
    @Ray.fYpos1 = ePosY             'ePosY = current chord point y" location measured from nozzle centerline

    @Ray.fXpos2 = @Ray.foci-ePosX   'current chord point x" location measured from Foci2
    @Ray.fYpos2 = ePosY             'same as fYpos1

    'get length of sides (* length of Radius 1 and Radius 2 from foci, F1 and F2 *)
    @Ray.radF1 = SQR(SQ(@Ray.fXpos1) + SQ(@Ray.fYpos1)) '= F1 radius length(bSide)
    @Ray.radF2 = SQR(SQ(@Ray.fXpos2) + SQ(@Ray.fYpos2)) '= F2 radius length(cSide)

    'get Radius1 angle, measured from foci 1 {cos C = (a^2 + b^2 - c^2)/2ab}
    @Ray.angleF1Rads = ArcCos((SQ(@Ray.fociX2)+SQ(@Ray.radF1)-SQ(@Ray.radF2))/(2*@Ray.fociX2*@Ray.radF1))

    'get Radius2 angle, measured from foci 2 {cos B = (c^2 + a^2 - b^2)/2ca}
    @Ray.angleF2Rads = ArcCos((SQ(@Ray.radF2)+SQ(@Ray.fociX2)-SQ(@Ray.radF1))/(2*@Ray.radF2*@Ray.fociX2))

    'get included angle, between Radius1 and Radius2  {cos A = (b^2 + c^2 - a^2)/2bc}
    @Ray.angleFiaRads = ArcCos((SQ(@Ray.radF1)+SQ(@Ray.radF2)-SQ(@Ray.fociX2))/(2*@Ray.radF1*@Ray.radF2))


    '--------------------------------------------------------------------------------------------------------
    ' Get Normal angle
    '--------------------------------------------------------------------------------------------------------
    @Ray.angleFia2Rads = @Ray.angleFiaRads*half                         'normal angle equals one-half the included angle between RadF1 and RadF2

    @Ray.angleNF1Rads = Rads180 - (@Ray.angleF1Rads + @Ray.angleFia2Rads)'normal angle measured at X axis intersection on F1 side

    @Ray.angleNF2Rads = Rads180 - (@Ray.angleF2Rads + @Ray.angleFia2Rads)'normal angle measured at X axis intersection on F2 side

    @Ray.nXF1 = (@Ray.radF1*SIN(@Ray.angleFia2Rads))/SIN(@Ray.angleNF1Rads) 'distance from F1 to tangent line intersection along X axis
    @Ray.radNF1 = SQR(SQ(ABS(@Ray.fXpos1-@Ray.nXF1))+ SQ(ABS(@Ray.fYpos1))) 'length of tangent line measured from chord X,Y position to X axis line

    @Ray.nXF2 = (@Ray.radF2*SIN(@Ray.angleFia2Rads))/SIN(@Ray.angleNF2Rads) 'distance from F2 to tangent line intersection along X axis
    @Ray.radNF2 = SQR(SQ(ABS(@Ray.fXpos2-@Ray.nXF2))+ SQ(ABS(@Ray.fYpos2))) 'length of tangent line measured from chord X,Y position to X axis line

    '--------------------------------------------------------------------------------------------------------
    ' Get the Normal Angle values of the current weld X,Y point
    '--------------------------------------------------------------------------------------------------------
    @Ray.nNormAngRads = GetN360(ePosX, ePosY, @Ray.angleNF2Rads) '0 to 360 Normal angle of chord, measured from X-Axis base to chord X,Y point
                                                                 'polar real; Normal angle to radius of a specific point on weld perime
    @Ray.nRotAngRads = ( (@Ray.nNormAngRads + @Ray.thetaInv) MOD Rads360 )  'transducer rotational angle, 0 to 360 degrees translation

    '--------------------------------------------------------------------------------------------------------
    ' Get the resulting Normal Radius and vector Origin offset value along the X-Axis
    '--------------------------------------------------------------------------------------------------------
    IF @Ray.nNormAngRads = 0 THEN
       @Ray.nOriginX  = @Ray.majorAxisRad-((@Ray.minorAxisRad^2) / @Ray.majorAxisRad)'cartesian real; X offset to origin of the vector, Normal to a point on weld.
       @Ray.nRadiusNorm = (@Ray.minorAxisRad^2) / @Ray.majorAxisRad             'polar real; Vector magnitude, length of radius. Origin = (nRay.eOriginX,eNormYpos)
    ELSEIF @Ray.nNormAngRads = Rads180 THEN
       @Ray.nOriginX = ((@Ray.minorAxisRad^2) / @Ray.majorAxisRad)-@Ray.majorAxisRad
       @Ray.nRadiusNorm = (@Ray.minorAxisRad^2) / @Ray.majorAxisRad
    ELSEIF @Ray.radF1 < @Ray.radF2 THEN    'use F1 results
       @Ray.nOriginX = @Ray.nXF1-@Ray.foci 'centerline of nozzle, X Axis distance, to normal angle intersection.
       @Ray.nRadiusNorm = @Ray.radNF1       'length of normal radius, measured from base line to weld perimeter chord point, from F1 side
    ELSE                             'use F2 results
       @Ray.nOriginX = @Ray.foci-@Ray.nXF2 'centerline of nozzle, X Axis distance, to normal angle intersection.
       @Ray.nRadiusNorm = @Ray.radNF2       'length of normal radius, measured from base line to weld perimeter chord point, from F2 side
    END IF


END SUB


SUB PlotCircProbe(xPos AS DOUBLE, yPos AS DOUBLE, zPos AS DOUBLE, thetaStart AS DOUBLE, UDTptr1 AS DWORD, UDTptr2 AS DWORD)


    'thetaStart = Rads270 'thetaStart + Rads180

    LOCAL uSCN AS u_ScanVars POINTER
    LOCAL uGFX AS u_GFXvars POINTER

    LOCAL thetaRads, pSkewRads AS DOUBLE

    DIM x(1 TO 12) AS LOCAL DOUBLE
    DIM y(1 TO 12) AS LOCAL DOUBLE

    uSCN = UDTptr1

    uGFX = UDTptr2

    pSkewRads = DegToRads(@uSCN.cProbeSkew)

    '@uGFX.cprobeClr = %RGB_LIGHTYELLOW      'probe perimeter case color
    '@uGFX.cprobefillClr = %RGB_ORANGE       'probe fill color

    '@uGFX.TngtLineClr = %RGB_RED            'tangent line color for/if probe skew
    '@uGFX.NormLineClr = %RGB_RED            'normal line color for/if probe skew

    '@uGFX.CentLineClr = %RGB_WHITE          'probe center line color, probe beam
    '@uGFX.IdxLineClr = %RGB_WHITE           'probe index line color

    '@uGFX.offsetBallClr = %RGB_WHITE        'ball at offset color
    '@uGFX.probeBallClr = %RGB_BLACK         'ball at probe center color

    '@uGFX.ballRad = 0.200#                  'meatball radius

    GRAPHIC WIDTH 1&

    'Locate x & y position of the near and far sides of the transducer case.
    '***************************************************************************************************************************
    'user input: measured from center of cross hair, along 0-180 degree line, X

    thetaRads = (DegToRads(zPos) + thetaStart) MOD Rads360 'Current transducer degree position (0-360)

    'Locate near side of transducer case width, at current scan degree position, projected from cross hair 0-180 line
    x(1) = -(@uSCN.cProbeWidth*half) * COS(thetaRads) + xPos
    y(1) = -(@uSCN.cProbeWidth*half) * SIN(thetaRads) + yPos

    'Locate far side of transducer case width, at current scan degree postion, projected from cross hair 0-180 line
    x(2) = (@uSCN.cProbeWidth*half) * COS(thetaRads) + xPos
    y(2) = (@uSCN.cProbeWidth*half) * SIN(thetaRads) + yPos

    'Probe location, transducer center, along index: - offset from beam intersection point on weld, user set offset
    x(9) = xPos
    y(9) = yPos


    'Locate x & y position of the (4) transducer case corners
    '***************************************************************************************************************************
    thetaRads = (DegToRads(zPos)+ thetaStart + Rads90) MOD Rads360

    'find offset from index to probe center.
    x(10)= (@uSCN.cProbeLen*half)-@uSCN.cProbeIdx 'find offset from index to probe center.

    'Lower front probe corner, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(3) = x(1) - (@uSCN.cProbeIdx * COS(thetaRads))
    y(3) = y(1) - (@uSCN.cProbeIdx * SIN(thetaRads))

    'Upper front probe edge, along +/- 90 degrees from NORMAL axis,+ offset from projected x(2) & y(2)
    x(4) = x(2) - (@uSCN.cProbeIdx * COS(thetaRads))
    y(4) = y(2) - (@uSCN.cProbeIdx * SIN(thetaRads))

    'Lower back probe edge, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(5) = x(1) + ((@uSCN.cProbeLen-@uSCN.cProbeIdx) * COS(thetaRads))
    y(5) = y(1) + ((@uSCN.cProbeLen-@uSCN.cProbeIdx) * SIN(thetaRads))

    'Upper back probe edge, along +/-90 degrees from Normal axis,+offset projected from x(2) & y(2)
    x(6) = x(2) + ((@uSCN.cProbeLen-@uSCN.cProbeIdx) * COS(thetaRads))
    y(6) = y(2) + ((@uSCN.cProbeLen-@uSCN.cProbeIdx) * SIN(thetaRads))

    'Center of transducer case length, offset from index (used for paint also!)
    x(8) = x(9) + (x(10)* COS(thetaRads))
    y(8) = y(9) + (x(10)* SIN(thetaRads))

    'beam intersection point on weld at current cross hair position
    x(7) = x(9) - (@uSCN.cProbeXOffset * COS(thetaRads))
    y(7) = y(9) - (@uSCN.cProbeXOffset * SIN(thetaRads))

    '********************************************************************************************************************
    'draw transducer sides x4 (rectangle)
    GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@uGFX.cprobeClr  'draw probe side 1
    GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),@uGFX.cprobeClr  'draw probe side 2
    GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),@uGFX.cprobeClr  'draw probe side 3
    GRAPHIC LINE(y(4),x(4))-(y(6),x(6)),@uGFX.cprobeClr  'draw probe side 4

    'make sure all (4) corners of the rectangle are sealed before calling GRAPHIC PAINT, otherwise paint leaks out everywhere!!
    GRAPHIC SET PIXEL (y(3),x(3)),@uGFX.cprobeClr
    GRAPHIC SET PIXEL (y(4),x(4)),@uGFX.cprobeClr
    GRAPHIC SET PIXEL (y(5),x(5)),@uGFX.cprobeClr
    GRAPHIC SET PIXEL (y(6),x(6)),@uGFX.cprobeClr

    'paint inside the transducer case
    GRAPHIC PAINT (y(8), x(8)), @uGFX.cprobefillClr, @uGFX.cprobeClr

    '***********************************************************************************************************
    'draw tangent line in reference to weld normal angle
    '***********************************************************************************************************
    'IF @uSCN.cProbeSkew <> 0 THEN
    IF @uSCN.cProbeXOffset <> 0 THEN
        thetaRads = (DegToRads(zPos)+ thetaStart + Rads90 - pSkewRads) MOD Rads360
        x(11) = @uGFX.TngtLine * COS(thetaRads)+ x(7) ' + xPos2# 'get real xPos of current angle
        y(11) = @uGFX.TngtLine * SIN(thetaRads)+ y(7) ' + yPos2# 'get real yPos of current angle

        thetaRads = (DegToRads(zPos)+ thetaStart - Rads90 - pSkewRads) MOD Rads360
        x(12) = @uGFX.TngtLine * COS(thetaRads)+ x(7) 'xPos2# 'get real xPos of current angle
        y(12) = @uGFX.TngtLine * SIN(thetaRads)+ y(7) 'yPos2# 'get real yPos of current angle

        GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.TngtLineClr
    END IF

    '***********************************************************************************************************
    'draw line through centerline of transducer, fore and aft
    '***********************************************************************************************************
    thetaRads = (DegToRads(zPos)+ thetaStart + Rads90) MOD Rads360  'normal angle +90 of weld X,Y position
    x(11) = @uGFX.CentLine * COS(thetaRads)+ xPos 'get real xPos of current angle
    y(11) = @uGFX.CentLine * SIN(thetaRads)+ yPos 'get real yPos of current angle

    thetaRads = (DegToRads(zPos)+ thetaStart - Rads90) MOD Rads360  'normal angle -90 of weld X,Y position
    x(12) = @uGFX.CentLine * COS(thetaRads)+ xPos 'get real xPos of current angle
    y(12) = @uGFX.CentLine * SIN(thetaRads)+ yPos 'get real yPos of current angle

    GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.CentLineClr

    '***********************************************************************************************************
    'draw line through weld, 90 degrees to UT beam axis, projected sideways
    '***********************************************************************************************************
    'IF @uSCN.cProbeSkew <> 0 THEN
    IF @uSCN.cProbeXOffset <> 0 THEN
        thetaRads = (DegToRads(zPos)+ thetaStart - pSkewRads)  MOD Rads360
        x(11) = @uGFX.NormLine * COS(thetaRads)+ x(7) 'xPos2# 'get real xPos of current angle
        y(11) = @uGFX.NormLine * SIN(thetaRads)+ y(7) 'yPos2# 'get real yPos of current angle

        x(12) = x(7) - (@uGFX.NormLine * COS(thetaRads)) 'get real xPos of current angle
        y(12) = y(7) - (@uGFX.NormLine * SIN(thetaRads)) 'get real yPos of current angle

        GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.NormLineClr
    END IF

    '***********************************************************************************************************
    'draw line through transducer index, 90 degrees to UT beam axis, at UT beam exit point
    '***********************************************************************************************************
    thetaRads = (DegToRads(zPos) + thetaStart) MOD Rads360 'normal angle +90 of weld X,Y position
    x(11) = @uGFX.IdxLine * COS(thetaRads)+ x(9) 'get real xPos of current angle
    y(11) = @uGFX.IdxLine * SIN(thetaRads)+ y(9) 'get real yPos of current angle

    thetaRads = (DegToRads(zPos) + thetaStart) MOD Rads360 'normal angle -90 of weld X,Y position
    x(12) = x(9) - (@uGFX.IdxLine * COS(thetaRads)) 'get real xPos of current angle
    y(12) = y(9) - (@uGFX.IdxLine * SIN(thetaRads)) 'get real yPos of current angle

    GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.IdxLineClr


    'draw meatball at transducer offset distance
    x(11) = x(7) - @uGFX.ballRad ' x position top
    y(11) = y(7) - @uGFX.ballRad ' y position left
    x(12) = x(7) + @uGFX.ballRad 'outer cross hair x position bottom
    y(12) = y(7) + @uGFX.ballRad 'outer cross hair y position right
    GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @uGFX.offsetBallClr

    'meatball at x,y transducer center
    x(11) = x(9) - @uGFX.ballRad 'transducer x position
    y(11) = y(9) - @uGFX.ballRad 'transducer y position
    x(12) = x(9) + @uGFX.ballRad 'transducer x position
    y(12) = y(9) + @uGFX.ballRad 'transducer y position
    GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @uGFX.probeBallClr


END SUB


SUB PlotAxProbe(BYVAL xPos AS DOUBLE, BYVAL yPos AS DOUBLE, BYVAL zPos AS DOUBLE, BYVAL thetaStart AS DOUBLE, BYVAL uSCNptr AS DWORD, BYVAL uGFXptr AS DWORD)

    DIM uSCN AS u_ScanVars POINTER
    DIM uGFX AS u_GFXvars POINTER

    LOCAL thetaRads AS DOUBLE
    DIM x(1 TO 12) AS LOCAL DOUBLE
    DIM y(1 TO 12) AS LOCAL DOUBLE

    'DIM pSkewRads AS DOUBLE

    uSCN = uSCNptr

    uGFX = uGFXptr

    'pSkewRads = DegToRads(@uSCN.cProbeSkew)

    @uGFX.aprobeClr = %RGB_YELLOW      'probe perimeter case color
    @uGFX.aprobefillClr = %RGB_ORANGE  'probe fill color

    @uGFX.TngtLineClr = %RGB_RED            'tangent line color for/if probe skew
    @uGFX.NormLineClr = %RGB_RED            'normal line color for/if probe skew

    @uGFX.CentLineClr = %RGB_WHITE          'probe center line color, probe beam
    @uGFX.IdxLineClr = %RGB_WHITE           'probe index line color

    @uGFX.offsetBallClr = %RGB_WHITE  'ball at offset color
    @uGFX.probeBallClr = %RGB_BLACK   'ball at probe center color

    @uGFX.ballRad = 0.200#    'meatball radius

    thetaRads = (DegToRads(zPos) + thetaStart) MOD Rads360 'Current transducer degree position (0-360)

    'Locate near side of transducer case, at current scan degree position, on 0-180 line
    x(1) = xPos - (@uSCN.aProbeIdx * COS(thetaRads))
    y(1) = yPos - (@uSCN.aProbeIdx * SIN(thetaRads))

    'Locate far side of transducer case, at current scan degree postion, on 0-180 line
    x(2) = xPos + ((@uSCN.aProbeLen-@uSCN.aProbeIdx) * COS(thetaRads))
    y(2) = yPos + ((@uSCN.aProbeLen-@uSCN.aProbeIdx) * SIN(thetaRads))

    'Locate center of transducer case,at current scan degree position, on 0-180 line(used for paint!).
    x(8) = xPos + (((@uSCN.aProbeLen*half)-@uSCN.aProbeIdx) * COS(thetaRads))
    y(8) = yPos + (((@uSCN.aProbeLen*half)-@uSCN.aProbeIdx) * SIN(thetaRads))

    'True X,Y position of axial transducer at current position
    'Locate transducer index at current scan degree position, on 0-180 line
    x(9) = xPos
    y(9) = yPos


    'Locate x & y position of the (4) transducer case corners
    '***************************************************************************************************************************
    'Transducer Width: (halfwidth + side of normal) + (halfwidth-side of normal) = transducer width, should be centered

    thetaRads = ((DegToRads(zPos)+Rads90) + thetaStart) MOD Rads360
    x(3) = (@uSCN.aProbeWidth*half) * COS(thetaRads)+ x(1) 'get real xPos of current angle
    y(3) = (@uSCN.aProbeWidth*half) * SIN(thetaRads)+ y(1) 'get real xPos of current angle
    x(4) = (@uSCN.aProbeWidth*half) * COS(thetaRads)+ x(2) 'get real xPos of current angle
    y(4) = (@uSCN.aProbeWidth*half) * SIN(thetaRads)+ y(2) 'get real xPos of current angle

    thetaRads = ((DegToRads(zPos)-Rads90) + thetaStart) MOD Rads360
    x(5) = (@uSCN.aProbeWidth*half) * COS(thetaRads)+ x(1) 'get real xPos of current angle
    y(5) = (@uSCN.aProbeWidth*half) * SIN(thetaRads)+ y(1) 'get real xPos of current angle
    x(6) = (@uSCN.aProbeWidth*half) * COS(thetaRads)+ x(2) 'get real xPos of current angle
    y(6) = (@uSCN.aProbeWidth*half) * SIN(thetaRads)+ y(2) 'get real xPos of current angle

    'draw transducer sides x4 (rectangle)
    GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@uGFX.aprobeClr
    GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),@uGFX.aprobeClr
    GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),@uGFX.aprobeClr
    GRAPHIC LINE(y(4),x(4))-(y(6),x(6)),@uGFX.aprobeClr

    'make sure all (4) corners of the rectangle are sealed before calling GRAPHIC PAINT, otherwise paint leaks out everywhere!!
    GRAPHIC SET PIXEL (y(3),x(3)),@uGFX.aprobeClr
    GRAPHIC SET PIXEL (y(4),x(4)),@uGFX.aprobeClr
    GRAPHIC SET PIXEL (y(5),x(5)),@uGFX.aprobeClr
    GRAPHIC SET PIXEL (y(6),x(6)),@uGFX.aprobeClr

    GRAPHIC PAINT (y(8), x(8)), @uGFX.aprobefillClr, @uGFX.aprobeClr

    '***********************************************************************************************************
    'draw transducer index line
    '***********************************************************************************************************
    thetaRads = ((DegToRads(zPos)+Rads90) + thetaStart) MOD Rads360  'normal angle +90 of weld X,Y position
    x(11) = (@uGFX.IdxLine * COS(thetaRads))+ xPos 'get real xPos of current angle
    y(11) = (@uGFX.IdxLine * SIN(thetaRads))+ yPos 'get real yPos of current angle

    thetaRads = ((DegToRads(zPos)-Rads90) + thetaStart) MOD Rads360  'normal angle -90 of weld X,Y position
    x(12) = (@uGFX.IdxLine * COS(thetaRads))+ xPos 'get real xPos of current angle
    y(12) = (@uGFX.IdxLine * SIN(thetaRads))+ yPos 'get real yPos of current angle

    GRAPHIC LINE(y(11),x(11))-(y(12),x(12)), @uGFX.IdxLineClr

    '***********************************************************************************************************
    'draw transducer centerline
    '***********************************************************************************************************
    thetaRads = (DegToRads(zPos) + thetaStart) MOD Rads360 'normal angle +90 of weld X,Y position
    x(11) = @uGFX.CentLine * COS(thetaRads)+ xPos 'get real xPos of current angle
    y(11) = @uGFX.CentLine * SIN(thetaRads)+ yPos 'get real yPos of current angle

    thetaRads = (DegToRads(zPos) + thetaStart) MOD Rads360 'normal angle -90 of weld X,Y position
    x(12) = xPos - (@uGFX.CentLine * COS(thetaRads)) 'get real xPos of current angle
    y(12) = yPos - (@uGFX.CentLine * SIN(thetaRads)) 'get real yPos of current angle

    GRAPHIC LINE(y(11),x(11))-(y(12),x(12)), @uGFX.CentLineClr

    'meatball at x,y transducer center
    x(11) = xPos - @uGFX.ballRad 'transducer -x position
    y(11) = yPos - @uGFX.ballRad 'transducer -y position
    x(12) = xPos + @uGFX.ballRad  'transducer +x position
    y(12) = yPos + @uGFX.ballRad  'transducer +y position
    GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @uGFX.probeBallClr

END SUB


SUB DrawScanModel(BYVAL RayPtr AS DWORD, BYVAL uGFXptr AS DWORD)

    'user set colors for model
    'uGFX.eStartClr =  scan start radial line color
    'uGFX.eEndClr =    scan end radial line color
    'uGFX.eExtraClr =  scan extra radial line color
    'uGFX.eRadialClr = all other scan radial scan line
    'uGFX.eInsideClr = center radial normal lines
    'uGFX.eOutPClr =   outer perimeter line color
    'uGFX.eWeldClr =   weld radial line color
    'uGFX.eWeldPClr =  weld perimeter line color
    'uGFX.eHAZClr =    HAZ radial line color
    'uGFX.eHAZPClr =   HAZ perimeter line color

    LOCAL uGFX AS u_GFXvars POINTER
    LOCAL Ray AS FociRay POINTER

    Ray = RayPtr    'Set the pointer from the DWORD param
    uGFX = uGFXptr

    LOCAL offset1,offset2,offset3,cosA,sinA,ystroke,Weld_Haz,Weld_Width AS DOUBLE
    LOCAL index AS LONG

    DIM x(1 TO 8) AS LOCAL DOUBLE
    DIM y(1 TO 8) AS LOCAL DOUBLE

    ystroke = @Ray.Scan_Rad

    'user set weld width and HAZ width
    Weld_Haz = @Ray.Weld_Haz         'width of HAZ (Heat Affected Zone) -  for plotting weld
    Weld_Width = @Ray.Weld_Width         'width of weld - for plotting weld



    '***********************************************************************************************************
    '  DRAW RADIAL SCAN LINES         note: add weld toe + transducer offset,index + stroke length
    '***********************************************************************************************************

    FOR index = @Ray.i_xIndexEnd TO 0 STEP -1 '0 TO nRay.i_xIndexEnd   'step -1 so not to overwrite start marker color

        @Ray.thetaRads = @Ray.eNormAngRads(index)

        @Ray.sXpos(index) = (yStroke*COS(@Ray.thetaRads))+@Ray.eXpos(index) 'get upper xPos: based on angle and stroke length
        @Ray.sYpos(index) = (yStroke*SIN(@Ray.thetaRads))+@Ray.eYpos(index) 'get upper yPos: based on angle and stroke length

    NEXT


    GRAPHIC WIDTH 1& 'line width


    'draw radial lines at normal angle to weld perimeter, chord spacing based upon user set index
    FOR index = @Ray.i_xIndexEnd TO 0 STEP -1 '0 TO nRay.i_xIndexEnd   'us step -1 to not overwrite start marker color

        IF index = 0 THEN
           GRAPHIC LINE(@Ray.eYpos(index),@Ray.eXpos(index))-(@Ray.sYpos(index),@Ray.sXpos(index)),@uGFX.eStartClr   'scan start degree position
        ELSEIF index = @Ray.i_xIndexEnd THEN
           GRAPHIC LINE(@Ray.eYpos(index),@Ray.eXpos(index))-(@Ray.sYpos(index),@Ray.sXpos(index)),@uGFX.eEndClr 'scan end degree position
        ELSEIF @Ray.i_xExtraIndx AND (index > (@Ray.i_xIndexEnd-@Ray.i_xExtraIndx)) THEN
           GRAPHIC LINE(@Ray.eYpos(index),@Ray.eXpos(index))-(@Ray.sYpos(index),@Ray.sXpos(index)),@uGFX.eExtraClr 'scan overlap lines
        ELSE
           GRAPHIC LINE(@Ray.eYpos(index),@Ray.eXpos(index))-(@Ray.sYpos(index),@Ray.sXpos(index)),@uGFX.eRadialClr 'all other lines
        END IF

        IF index < @Ray.i_xIndexEnd THEN
           'draw outer perimeter chords
           GRAPHIC LINE(@Ray.sYpos(index),@Ray.sXpos(index))-(@Ray.sYpos(index+1),@Ray.sXpos(index+1)),@uGFX.eOutPClr
           'GRAPHIC LINE -(nRay.sYpos(index+1),nRay.sXpos(index+1)),%RED
        END IF

    NEXT

    GRAPHIC STYLE 0&



    '***********************************************************************************************************
    '  DRAW Nozzle weld and normal angles within perimeter
    '***********************************************************************************************************
    GRAPHIC WIDTH 1& 'line width

    @Ray.thetaRads = @Ray.eNormAngRads(@Ray.i_xIndexEnd+1) : cosA =  COS(@Ray.thetaRads) : sinA =  SIN(@Ray.thetaRads)

    offset1 = (Weld_Haz*2.00#) + Weld_Width  'subtracted from outer HAZ edge
    x(2) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset1 * cosA)
    y(2) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset1 * sinA)

    offset2 = Weld_Haz + Weld_Width           'subtracted from outer HAZ edge
    x(4) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset2 * cosA)
    y(4) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset2 * sinA)

    offset3 = Weld_Haz                       'subtracted from outer HAZ edge
    x(6) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset3 * cosA)
    y(6) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset3 * sinA)

    x(8) = @Ray.eXpos(@Ray.i_xIndexEnd)
    y(8) = @Ray.eYpos(@Ray.i_xIndexEnd)


    FOR index = @Ray.i_xIndexEnd TO 0 STEP -1 'step -1 so not to overwrite inner start marker color

        @Ray.thetaRads = @Ray.eNormAngRads(index) : cosA =  COS(@Ray.thetaRads) : sinA =  SIN(@Ray.thetaRads)

        ' draw Inner HAZ: normal lines and perimeter
        '************************************************************************************************************************
        x(1) = @Ray.eXpos(index)-(offset1 * cosA) : y(1) = @Ray.eYpos(index)-(offset1 * sinA)
        GRAPHIC LINE(0, @Ray.eOriginX(index))-(y(1), x(1)),@uGFX.eInsideClr 'draw normal angle line to inside HAZ
        GRAPHIC LINE(y(1),x(1))-(y(2),x(2)),@uGFX.eHAZPClr                  'draw perimeter around inside HAZ
        GRAPHIC SET PIXEL (0, @Ray.eOriginX(index)),@uGFX.eExtraClr   'added 7/19/15, origin

        ' draw Inner weld: normal lines and perimeter
        '************************************************************************************************************************
        x(3) = @Ray.eXpos(index)-(offset2 * cosA) : y(3) = @Ray.eYpos(index)-(offset2 * sinA)
        GRAPHIC LINE(y(1),x(1))-(y(3),x(3)),@uGFX.eHAZClr   'draw normal angle line to inside weld line
        GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@uGFX.eWeldPClr 'draw perimeter around inside weld

        ' draw Outer Weld: normal lines and perimeter
        '************************************************************************************************************************
        x(5) = @Ray.eXpos(index)-(offset3 * cosA) : y(5) = @Ray.eYpos(index)-(offset3 * sinA)
        GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),@uGFX.eWeldClr 'draw normal angle lines inside perimeter to outer weld
        GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),@uGFX.eWeldPClr 'draw outside perimeter around weld

        ' draw Outer HAZ: normal lines and perimeter
        '************************************************************************************************************************
        x(7) = @Ray.eXpos(index) : y(7) = @Ray.eYpos(index)
        GRAPHIC LINE(y(5),x(5))-(y(7),x(7)),@uGFX.eHAZClr 'draw normal angle lines inside perimeter to outside HAZ
        GRAPHIC LINE(y(7),x(7))-(y(8),x(8)),@uGFX.eHAZPClr 'draw chords around outside perimeter HAZ

        ' update old values to new values
        y(2) = y(1) : x(2) = x(1) : y(4) = y(3) : x(4) = x(3) : y(6) = y(5) : x(6) = x(5) : y(8) = y(7) : x(8) = x(7)

    NEXT



END SUB


SUB GenerateModel(BYVAL RayPtr AS DWORD)


    LOCAL Ray AS FociRay POINTER
    Ray = RayPtr ' Set the pointer from the DWORD param

    LOCAL eXpos1,eYpos1,eXpos2,eYpos2,ArcIndex,DoneRatio AS DOUBLE
    LOCAL index,x_index,DoneCtr1,DoneCtr2 AS INTEGER

    '**********************************************************************************************
    '   user set
    '**********************************************************************************************
    '@Ray.majorAxis = 9.00#
    '@Ray.minorAxis = 8.00#

    '@Ray.r_xIndexIncFixed = .50#  'index increment

    '@Ray.thetaS = Rads270 '= Rads270 'Rads180 Rads90 Rads0 'set start angle / position

    '@Ray.i_xExtraIndx = 2


    '***********************************************************************************************
    '***********************************************************************************************

    IF @Ray.majorAxis < @Ray.minorAxis THEN
       SWAP @Ray.majorAxis, @Ray.minorAxis
    END IF

    IF @Ray.majorAxis = @Ray.minorAxis THEN
       @Ray.majorAxis = @Ray.majorAxis + .001#
    END IF

    @Ray.majorAxisRad = @Ray.majorAxis * half
    @Ray.minorAxisRad = @Ray.minorAxis * half


    '***************************************************************************************************************************************************************
    '            *DEFINE THE WELD *
    '***************************************************************************************************************************************************************

    'focal definition of the weld - get the length of the triangle sides
    @Ray.foci = SQR(SQ(@Ray.majorAxisRad)-SQ(@Ray.minorAxisRad)) 'leg distance of foci point measured from the center of the major axis
    @Ray.fociX2 = @Ray.foci*2                                 'length between the foci points, F1-F2 or Foci1-Foci2 (aSide)

    '----------------------------------------------------------------------------------------------------------------
    '          Based on incrementing angles, measured from the nozzle x,y, centerline
    '          Specify major & minor radius, chord length index, start position in RADIANS
    '----------------------------------------------------------------------------------------------------------------

    IF @Ray.thetaS = Rads0 THEN
        @Ray.thetaInv = Rads0inv
    ELSEIF @Ray.thetaS = Rads90 THEN
        @Ray.thetaInv = Rads90inv
    ELSEIF @Ray.thetaS = Rads180 THEN
        @Ray.thetaInv = Rads180inv
    ELSEIF @Ray.thetaS = Rads270 THEN
        @Ray.thetaInv = Rads270inv
    END IF

    @Ray.theta360 = @Ray.thetaS + Rads360 'set end angle / position

    ''**************************************************************************************************************************************

    @Ray.thetaInc = @Ray.thetaS         'set current degree increment to start angle
    @Ray.theta = @Ray.thetaS            'set current degree position to start angle
    @Ray.thetaRads = @Ray.theta         'assign thetaRads to theta

    @Ray.theta405 = @Ray.theta360 + Rads45  'always add 45 degrees overlap

    'Get the initial x and y position at starting position angle in RADIANS
    'NOTE: There are inherent problems with zero degree angles due to the inaccurracies of converting degrees to radians and vice-versa,
    'eXpos2 = @Ray.majorAxisRad*COS(@Ray.thetaRads) 'Pi and radian numbers are not accurate enough. For example:
    'eYpos2 = @Ray.minorAxisRad*SIN(@Ray.thetaRads) 'SIN(180) should = 0; but it does not!! instead = -7.61380975627945E-16

    IF @Ray.thetaS = 0 THEN
       eXpos2 = @Ray.majorAxisRad
       eYpos2 = 0
    ELSEIF @Ray.thetaS = Rads180 THEN
       eXpos2 = -@Ray.majorAxisRad
       eYpos2 = 0
    ELSE
       eXpos2 = @Ray.majorAxisRad*COS(@Ray.thetaRads)
       eYpos2 = @Ray.minorAxisRad*SIN(@Ray.thetaRads)
    END IF


    @Ray.arcSegment = 0  'arc segment length
    @Ray.perimL = 0       'perimeter length
    @Ray.nAccumErr = 0  'error total acummulator, = accumulator + (target chord length - generated chord length)


    @Ray.thetaflag = True 'set flag to perform check if theta >= 360 degrees
    @Ray.pflag = true ' set flag to store length of weld HAZ perimeter
    @Ray.plength = 0 'stores length of weld HAZ perimeter


    'used to calculate percentage complete
    DoneRatio = 100.00#/(Rads360 + Rads45): DoneCtr1 = -1 'initilize to -1 so display starts at 0%

    arcIndex = @Ray.r_xIndexIncFixed 'set current chord index

    x_Index = 0  'intialize loop counter

    DO

        GetFoci(eXpos2, eYpos2, RayPtr)

        '--------------------------------------------------------------------------------------------------------
        ' Store the current weld X,Y point position and arc segment length
        '--------------------------------------------------------------------------------------------------------
        @Ray.eNormAngRads(x_Index) = @Ray.nNormAngRads  '0 to 360 Normal angle of chord, measured from X-Axis base to chord X,Y point
        @Ray.eOriginX(x_Index) = @Ray.nOriginX          'cartesian real; X offset to origin of the vector, Normal to a point on weld.
        @Ray.eRadiusNorm(x_Index) = @Ray.nRadiusNorm    'polar real; Vector magnitude, length of radius. Origin = (nRay.eOriginX,eNormYpos)
        @Ray.eRotAngRads(x_Index) = @Ray.nRotAngRads    'transducer rotational angle, 0 to 360 degrees translation

        @Ray.perimL = @Ray.perimL + @Ray.arcSegment     'build the perimeter length, arc by arc
        @Ray.eArcSeg(x_Index) = @Ray.arcSegment         'single arc segment length
        @Ray.eArcTotal(x_Index)= @Ray.perimL            'arc segment total length to THIS point

        @Ray.eXpos(x_Index) = eXpos2        'cartesian real; X coordinate of this point along weld, is far side edge of weld HAZ.
        @Ray.eYpos(x_Index) = eYpos2        'cartesian real; Y coordinate of this point along weld, is far side edge of weld HAZ.

        @Ray.eNormAngNF2Rads(x_Index) =  @Ray.angleNF2Rads 'normal angle measured at X axis intersection on F2 side

        'not needed or used at this time
        'eCtrAngle(n%) =  nRay.thetaRads   'polar real; Angle 0-360: center of nozzle to each X,Y point along weld HAZ perimeter.

        'Calculate percentage done - update screen if it has changed
        doneCtr2 = ROUND( ((@Ray.thetaInc-@Ray.thetaS)*DoneRatio), 0 )
        IF DoneCtr2 <> DoneCtr1 THEN
           GRAPHIC SET POS (0,0): GRAPHIC PRINT "% DONE: " + STR$(doneCtr2)+ "       "
           GRAPHIC REDRAW
           DoneCtr1 = DoneCtr2
        END IF

        IF @Ray.thetaflag AND (@Ray.thetaInc => @Ray.theta360) THEN
           @Ray.thetaflag = False
           @Ray.i_xIndex360 = x_Index
           'PRINT "Index at 360 Degrees: "; @Ray.i_xIndex360
        END IF

        'added 45 degrees scan overlap
        IF @Ray.thetaInc => @Ray.theta405 THEN
           @Ray.i_xIndex405 = x_Index  'at 405 degrees or more
           'PRINT "Index at 405 Degrees: "; @Ray.i_xIndex405
           EXIT DO  'exit loop: theta increment is => 405 degrees:
        END IF

        @Ray.nAccumErr = @Ray.perimL - (@Ray.r_xIndexIncFixed * x_Index) 'error accumulator
        'arcIndex = @Ray.r_xIndexIncFixed - @Ray.nAccumErr '*** uncomment for more accuracy, subtracts accumulated error from the target Index

        @Ray.arcSegment = 0 'reset arcSegment to zero

        DO

           '*********** Use Brute Force method to get the desired arc segement length ************
           eXpos1 = eXpos2 : eYpos1 = eYpos2
           @Ray.thetaInc = @Ray.thetaInc + 0.0000001#        'smaller increment = more accurate = more loops

           @Ray.thetaRads = @Ray.thetaInc MOD Rads360         'keep degrees in the 0 to 360 range

           eXpos2 = @Ray.majorAxisRad * COS(@Ray.thetaRads) 'get xPos of current incremented angle
           eYpos2 = @Ray.minorAxisRad * SIN(@Ray.thetaRads) 'get yPos of current incremented angle
           @Ray.arcSegment=@Ray.arcSegment + GetSegLen((eXpos2-eXpos1),(eYpos2-eYpos1))'arc segment length

           IF @Ray.pflag AND (@Ray.thetaInc >= @Ray.theta360) THEN  'at or past a full 360 degree excursion
              @Ray.pflag = False
              @Ray.plength = @Ray.perimL + @Ray.arcSegment  'store the weld HAZ perimeter final length
           END IF

        LOOP WHILE (@Ray.arcSegment < arcIndex) AND (@Ray.thetaInc < @Ray.theta405) '(nRay.thetaInc < nRay.theta360)

        IF x_Index < 1000 THEN  'increment loop counter
           INCR x_Index
        ELSE                'exit loop if n% = 1000  - should never happen unless error of some sort!!!


           EXIT DO
        END IF

        'PRINT
        'PRINT "nRay.thetaInc:  "; RadsToDeg(@Ray.thetaInc)
        'PRINT "nRay.thetaRads: "; RadsToDeg(@Ray.thetaRads)

    LOOP


    '0915 Change
    '**************************************************************************************

    GOTO Index180Mod

    '*************************************************************************************************************
    '  ADD INDEX OVERLAP, IF ANY
    '*************************************************************************************************************
    ' extra index increments: for nMax to end at zero (rare), the weld length must be evenly divisible by the index.
    ' if not evenly divisible then there will be an inherent partial index past 0 + i_xExtraIndx

    IF @Ray.i_xExtraIndx THEN

       FOR index = 0 TO @Ray.i_xExtraIndx  'start at 0 to take care of the inherent partial step past zero

           @Ray.eRotAngRads(@Ray.i_xIndex360+index) = @Ray.eRotAngRads(@Ray.i_xIndex360+index) + Rads360  'ex: 360+2.88= 362.88 or if 0: 360+0  360

       NEXT

       IF (@Ray.i_xIndex360 + @Ray.i_xExtraIndx) > @Ray.i_xIndex405 THEN
          @Ray.i_xIndexEnd = @Ray.i_xIndex405
       ELSE
          @Ray.i_xIndexEnd = @Ray.i_xIndex360 + @Ray.i_xExtraIndx
       END IF

    ELSE  ' no overlap!

       'make end of scan data equal to scan start data, nRay.thetaS, nMax as is, ends usually past nRay.thetaS
       @Ray.eNormAngRads(@Ray.i_xIndex360) = @Ray.eNormAngRads(0)
       @Ray.eOriginX(@Ray.i_xIndex360) =  @Ray.eOriginX(0)
       @Ray.eRadiusNorm(@Ray.i_xIndex360) = @Ray.eRadiusNorm(0)

       'Scan start transducer beam rotation angle: ALWAYS set to 0 degress
       'example of not setting to 0:
       'Start = 270, when crossing 360 to 0 degees, rotation zip's 360 degrees to 0, 1 full revolution - Yikes!!
       @Ray.eRotAngRads(0) = 0


       'Scan end transducer rotational angle, 0 to 360 degrees translation
       'DON'T zip a full 360 degress back to 0, YIKES!!!!
       @Ray.eRotAngRads(@Ray.i_xIndex360) = Rads360


       @Ray.i_xIndexEnd = @Ray.i_xIndex360

    END IF

    EXIT SUB

Index180Mod:


    '*************************************************************************************************************
    '  ADD INDEX OVERLAP, IF ANY
    '*************************************************************************************************************
    ' extra index increments: for nMax to end at zero (rare), the weld length must be evenly divisible by the index.
    ' if not evenly divisible then there will be an inherent partial index past 0 + i_xExtraIndx

     '0915 Change
     '**************************************************************************************
'     (abs(@Ray.xOffset)/@Ray.r_xIndexIncFixed + half)

    '@Ray.xOffset = 4.330#
    @Ray.i_xExtraIndx = 1

    IF @Ray.i_xExtraIndx THEN
       '@Ray.i_xIndexEnd = (@Ray.i_xIndex360 * half + half) + ((ABS(@Ray.xOffset)/@Ray.r_xIndexIncFixed) + half) + @Ray.i_xExtraIndx
       @Ray.i_xIndexEnd = (@Ray.i_xIndex360 * half + half) + @Ray.i_xExtraIndx


       @Ray.i_xIndexEnd = (@Ray.i_xIndex360 * fourth + half) + @Ray.i_xExtraIndx



       PRINT "@Ray.i_xIndexEnd = (@Ray.i_xIndex360 * half)  + @Ray.i_xExtraIndx"

       PRINT "ABS(@Ray.xOffset): "; ABS(@Ray.xOffset)
       PRINT "@Ray.r_xIndexIncFixed: "; @Ray.r_xIndexIncFixed
       PRINT "@Ray.i_xIndex360End: "; @Ray.i_xIndex360
       PRINT "@Ray.i_xIndex360 * half: "; @Ray.i_xIndex360*half
       PRINT "@Ray.i_xExtraIndx: "; @Ray.i_xExtraIndx
       PRINT "@Ray.i_xIndexEnd: "; @Ray.i_xIndexEnd
       WAITKEY$

    ELSE  ' no overlap!
       @Ray.i_xIndexEnd = (@Ray.i_xIndex360 * half + half) + (ABS(@Ray.xOffset)/@Ray.r_xIndexIncFixed + half)

    END IF


END SUB


FUNCTION GenAxialSegments (BYVAL RayPtr AS DWORD) AS LONG

    '**********************************************************************
    '  **** Generate Scan Path Segments for Axial UT Beam direction ****
    '**********************************************************************
    LOCAL Ray AS FociRay POINTER
    Ray = RayPtr

    LOCAL xPos1,xPos2,yPos1,yPos2,zPos1,zPos2,xImgPos1,xImgPos2,yImgPos1,yImgPos2,index,xIndexEnd AS DOUBLE
    LOCAL xIndexCtr&, yIndexCtr&, PathCtr&, pathbufflen AS LONG  'x,y index counterand Path loop counter

    'Availble for use: Ray.r_xBegin   Ray.r_xEnd


    IF @Ray.RasterAxial THEN  'raster in Axial direction

        'values below are for standalone test runs
        '@Ray.r_yBegin = 0.800# :  @Ray.r_yEnd = 10.800#

        'Scan start position
        xPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0)
        yPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0))
        zPos1# = RadsToDeg(@Ray.eRotAngRads(0))
        xImgPos1# = @Ray.eArcTotal(0)
        yImgPos1# = @Ray.r_yBegin

        'store the scan start position
        BeginSeg_G(0)=xPos1: BeginSeg_G(1)=yPos1: BeginSeg_G(2)=zPos1: BeginSeg_G(3)=xImgPos1:BeginSeg_G(4)=yImgPos1

        PathCtr = -1
        xIndexCtr = 0


        DO

             INCR PathCtr

             IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past allocated memory and crash the computer
                GenAxialSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - stroke away from weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * SIN(@Ray.eNormAngRads(xIndexCtr))
             zPos2# =  RadsToDeg(@Ray.eRotAngRads(xIndexCtr)) 'RadsToDeg(nRay.eNormAngRads(IndexCtr))
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yEnd

             xMtrSeg_G(PathCtr) = xPos2# - xPos1#
             yMtrSeg_G(PathCtr) = yPos2# - yPos1#
             zMtrSeg_G(PathCtr) = zPos2# - zPos1#
             xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
             yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

             xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

             xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

             'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr) 'segment length

             INCR xIndexCtr

             IF xIndexCtr > @Ray.i_xIndexEnd THEN EXIT DO  'finished - exit now

             INCR PathCtr

             IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenAxialSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - index at stroke end
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * SIN(@Ray.eNormAngRads(xIndexCtr))
             zPos2# =  RadsToDeg(@Ray.eRotAngRads(xIndexCtr)) 'RadsToDeg(nRay.eNormAngRads(IndexCtr))
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yEnd

             xMtrSeg_G(PathCtr) = xPos2# - xPos1#
             yMtrSeg_G(PathCtr) = yPos2# - yPos1#
             zMtrSeg_G(PathCtr) = zPos2# - zPos1#
             xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
             yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

             xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

             xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

             'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr) 'segment length

             INCR PathCtr

             IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenAxialSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - stroke to weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(xIndexCtr))
             zPos2# =  RadsToDeg(@Ray.eRotAngRads(xIndexCtr)) 'RadsToDeg(nRay.eNormAngRads(IndexCtr))
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yBegin

             xMtrSeg_G(PathCtr) = xPos2# - xPos1#
             yMtrSeg_G(PathCtr) = yPos2# - yPos1#
             zMtrSeg_G(PathCtr) = zPos2# - zPos1#
             xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
             yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

             xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

             xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

             'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)'segment length

             INCR xIndexCtr

             IF xIndexCtr > @Ray.i_xIndexEnd THEN EXIT DO

             INCR PathCtr

             IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenAxialSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - index at weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(xIndexCtr))
             zPos2# =  RadsToDeg(@Ray.eRotAngRads(xIndexCtr)) 'RadsToDeg(nRay.eNormAngRads(IndexCtr))
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yBegin

             xMtrSeg_G(PathCtr) = xPos2# - xPos1#
             yMtrSeg_G(PathCtr) = yPos2# - yPos1#
             zMtrSeg_G(PathCtr) = zPos2# - zPos1#
             xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
             yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

             xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

             xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

             'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)'segment length

             'WAITKEY$

        LOOP

        'PRINT "PATHS GENERATED: "; PathCtr; " "; "- PRESS ANY <KEY>....."

        'WAITKEY$




   ELSE   'Raster in the circ direction


        'values below are for standalone test runs
        '@Ray.r_yBegin = 0.800# :  @Ray.r_yEnd = 10.800#
        '@Ray.r_yIndexInc = 1.00#  'index increment


        'pathbufflen% = ((xIndexEnd#/indexInc#) + 2) * (@Ray.i_xIndexEnd + 1)


        '??  give command to move motors, XYZ into this position ??
        '    although motors should already be there, this would insure they are
        '    adjust by reading servo encoder offset counts just prior.

        'Scan start position
        xPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0)
        yPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0))
        zPos1# = RadsToDeg(@Ray.eRotAngRads(0))
        xImgPos1# = @Ray.eArcTotal(0)
        yImgPos1# = @Ray.r_yBegin

        'store the scan start position
        BeginSeg_G(0)=xPos1: BeginSeg_G(1)=yPos1: BeginSeg_G(2)=zPos1: BeginSeg_G(3)=xImgPos1:BeginSeg_G(4)=yImgPos1

        @Ray.i_yIndexEnd = ABS(@Ray.r_yEnd - @Ray.r_yBegin)/@Ray.r_yIndexInc

        PathCtr = -1
        yIndexCtr = 0  'current y index counter
        xIndexCtr = 0  'current x index counter
        Index# = 0    'current index real

        DO


            FOR xIndexCtr = 1 TO @Ray.i_xIndexEnd '@ start position: drive positive circ direction

                INCR PathCtr

                IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                   GenAxialSegments = (PathCtr-1)
                   EXIT FUNCTION
                END IF

                'get path target position - index at weld
                xPos2# = (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)
                yPos2# = (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(xIndexCtr))
                zPos2# =  RadsToDeg(@Ray.eRotAngRads(xIndexCtr))
                xImgPos2# = @Ray.eArcTotal(xIndexCtr)
                yImgPos2# = @Ray.r_yBegin + index#

                xMtrSeg_G(PathCtr) = xPos2# - xPos1#
                yMtrSeg_G(PathCtr) = yPos2# - yPos1#
                zMtrSeg_G(PathCtr) = zPos2# - zPos1#
                xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
                yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

                xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

                xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

                'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr) 'segment length

            NEXT


            'set xyz to end position at current index
            xPos1# = (@Ray.eRadiusNorm(@Ray.i_xIndexEnd)+ @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + @Ray.eOriginX(@Ray.i_xIndexEnd)
            yPos1# = (@Ray.eRadiusNorm(@Ray.i_xIndexEnd)+ @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(@Ray.i_xIndexEnd))
            zPos1# = RadsToDeg(@Ray.eRotAngRads(@Ray.i_xIndexEnd))
            xImgPos1# = @Ray.eArcTotal(@Ray.i_xIndexEnd)
            yImgPos1# = @Ray.r_yBegin + index#

            index# = index# + @Ray.r_yIndexInc 'set xyz to next index at end position

            INCR yIndexCtr

            IF yIndexCtr > @Ray.i_yIndexEnd THEN EXIT DO

            INCR PathCtr

            IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
               GenAxialSegments = (PathCtr-1)
               EXIT FUNCTION
             END IF

            'PRINT "index# : "; index# ; " "; "- PRESS ANY <KEY>....."
            'WAITKEY$

            'get path target position - index at weld
            xPos2# = (@Ray.eRadiusNorm(@Ray.i_xIndexEnd)+ @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + @Ray.eOriginX(@Ray.i_xIndexEnd)
            yPos2# = (@Ray.eRadiusNorm(@Ray.i_xIndexEnd)+ @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(@Ray.i_xIndexEnd))
            zPos2# = RadsToDeg(@Ray.eRotAngRads(@Ray.i_xIndexEnd))
            xImgPos2# = @Ray.eArcTotal(@Ray.i_xIndexEnd)
            yImgPos2# = @Ray.r_yBegin + index#

            xMtrSeg_G(PathCtr) = xPos2# - xPos1#
            yMtrSeg_G(PathCtr) = yPos2# - yPos1#
            zMtrSeg_G(PathCtr) = zPos2# - zPos1#
            xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
            yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

            xySegLn_G(PathCtr) = GetSegLen(xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

            xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

            'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)

            FOR xIndexCtr = (@Ray.i_xIndexEnd-1) TO 0 STEP -1 '@ end position: drive positive circ direction to next path coordinate

                INCR PathCtr

                IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                   GenAxialSegments = (PathCtr-1)
                   EXIT FUNCTION
                END IF

                'get path target position - index at weld
                xPos2# = (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)
                yPos2# = (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(xIndexCtr))
                zPos2# =  RadsToDeg(@Ray.eRotAngRads(xIndexCtr)) 'RadsToDeg(nRay.eNormAngRads(zCtr&))
                xImgPos2# = @Ray.eArcTotal(xIndexCtr)
                yImgPos2# = @Ray.r_yBegin + index#

                xMtrSeg_G(PathCtr) = xPos2# - xPos1#
                yMtrSeg_G(PathCtr) = yPos2# - yPos1#
                zMtrSeg_G(PathCtr) = zPos2# - zPos1#
                xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
                yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

                xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

                xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

                'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)

            NEXT

            'set xyz to start position at current index
            xPos1# = (@Ray.eRadiusNorm(0)+ @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0)
            yPos1# = (@Ray.eRadiusNorm(0)+ @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(0))
            zPos1# = RadsToDeg(@Ray.eRotAngRads(0))
            xImgPos1# = @Ray.eArcTotal(0)
            yImgPos1# = @Ray.r_yBegin + index#

            index# = index# + @Ray.r_yIndexInc   'set xyz to next index at start position

            INCR yIndexCtr

            IF yIndexCtr > @Ray.i_yIndexEnd THEN EXIT DO

            INCR PathCtr

            IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenAxialSegments = (PathCtr-1)
                EXIT FUNCTION
            END IF

            'PRINT "index# : "; index# ; " "; "- PRESS ANY <KEY>....."
            'WAITKEY$

            'get path target position - index at weld
            xPos2# = (@Ray.eRadiusNorm(0)+ @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0)
            yPos2# = (@Ray.eRadiusNorm(0)+ @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(0))
            zPos2# = RadsToDeg(@Ray.eRotAngRads(0))
            xImgPos2# = @Ray.eArcTotal(0)
            yImgPos2# = @Ray.r_yBegin + index#

            xMtrSeg_G(PathCtr) = xPos2# - xPos1#
            yMtrSeg_G(PathCtr) = yPos2# - yPos1#
            zMtrSeg_G(PathCtr) = zPos2# - zPos1#
            xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
            yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

            xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

            xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

            'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)

        LOOP

        'PRINT "PATHS GENERATED: "; PathCtr; " "; "- PRESS ANY <KEY>....."


        'PRINT "WAITKEY$"

   END IF

   GenAxialSegments = (PathCtr-1)
   EXIT FUNCTION

END FUNCTION


FUNCTION GenCircSegments (BYVAL RayPtr AS DWORD) AS LONG

    '**********************************************************************
    '  **** Generate Scan Path Segments for Axial UT Beam direction ****
    '**********************************************************************

    LOCAL Ray AS FociRay POINTER
    Ray = RayPtr

    LOCAL xPos1,xPos2,yPos1,yPos2,zPos1,zPos2,xImgPos1, xImgPos2, yImgPos1, yImgPos2, index AS DOUBLE
    LOCAL xIndexCtr, yIndexCtr, PathCtr, pathbufflen AS LONG 'Index and Path loop counter

    LOCAL xtheta AS DOUBLE ' transducer offset

    'scan start position: Scanner vs program
    'X_AXIS SIDE,scanner at 0   Degrees = 270 Degrees program
    '                       90  Degrees = 0   Degrees program
    '                       180 Degrees = 90  Degrees program
    '                       270 Degrees = 180 Degrees program

    IF @Ray.thetaS = Rads270 THEN
       xtheta = Rads0
    ELSEIF @Ray.thetaS = Rads0 THEN
       xtheta = Rads90
    ELSEIF @Ray.thetaS = Rads90 THEN
       xtheta = Rads180
    ELSEIF @Ray.thetaS = Rads180 THEN
       xtheta = Rads270
    END IF


    'NumOfSeg_G = 0  'tracks number of paths generated

    index# = 0         'current index

'    IF @Ray.skewDegs < 0 THEN
'       'Print "waiting" : waitkey$
'       @Ray.skewRads = ABS(DegToRads(@Ray.skewDegs)) 'set to positive
'       @Ray.xOffset = -(ABS(@Ray.xOffset))           'xOffset and skewDegs are negative while skewrads are positive
'    ELSE
'       @Ray.skewRads = -(DegToRads(@Ray.skewDegs))   'set to negative
'       @Ray.xOffset = ABS(@Ray.xOffset)              'xOffset and skewDegs are positive while skewrads are negative
'    END IF


    'Scan start position
    xPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
    yPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
    zPos1# = RadsToDeg( (@Ray.eRotAngRads(0)+ @Ray.skewRads) )
    xImgPos1# = @Ray.eArcTotal(0)
    yImgPos1# = @Ray.r_yBegin

    'store the scan start position
    BeginSeg_G(0)=xPos1#: BeginSeg_G(1)=yPos1#: BeginSeg_G(2)=zPos1#: BeginSeg_G(3)=xImgPos1#:  BeginSeg_G(4)=yImgPos1#

    PathCtr = -1
    yIndexCtr = 0
    xIndexCtr = 0


    IF @Ray.RasterAxial THEN  'raster in Axial direction

        DO

             INCR PathCtr

             IF PathCtr > NumOfSeg_G THEN  'make sure no go:  past memory allocated and crash the computer
                GenCircSegments = PathCtr
                EXIT FUNCTION
             END IF

             'get path target position - stroke away from weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr) + (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta + @Ray.skewRads))
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr) + xtheta + @Ray.skewRads))
             zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr) + @Ray.skewRads) )
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yEnd  'yZeroOffset# + @uSCN.yStroke


             xMtrSeg_G(PathCtr) = xPos2# - xPos1#
             yMtrSeg_G(PathCtr) = yPos2# - yPos1#
             zMtrSeg_G(PathCtr) = zPos2# - zPos1#
             xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
             yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

             xySegLn_G(PathCtr) = GetSegLen(xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

             xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

             'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr) 'segment length
             'PRINT "Index CTR : "; IndexCtr; RadsToDeg(@Ray.eRotAngRads(IndexCtr)); @Ray.skewRads

             INCR xIndexCtr

             IF xIndexCtr > @Ray.i_xIndexEnd THEN EXIT DO

             INCR PathCtr

             IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenCircSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - index at stroke end
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)+ (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta + @Ray.skewRads))
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr)+ xtheta + @Ray.skewRads))
             zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr)+ @Ray.skewRads) )
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yEnd

             xMtrSeg_G(PathCtr) = xPos2# - xPos1#
             yMtrSeg_G(PathCtr) = yPos2# - yPos1#
             zMtrSeg_G(PathCtr) = zPos2# - zPos1#
             xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
             yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

             xySegLn_G(PathCtr) = GetSegLen(xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

             xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

             'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr) 'segment length
             'PRINT "Index CTR : "; IndexCtr; RadsToDeg(@Ray.eRotAngRads(IndexCtr)); @Ray.skewRads

             INCR PathCtr

             IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenCircSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - stroke to weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)+ (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta + @Ray.skewRads))
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr) + xtheta + @Ray.skewRads))
             zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr)+ @Ray.skewRads) )
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yBegin

             xMtrSeg_G(PathCtr) = xPos2# - xPos1#
             yMtrSeg_G(PathCtr) = yPos2# - yPos1#
             zMtrSeg_G(PathCtr) = zPos2# - zPos1#
             xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
             yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

             xySegLn_G(PathCtr) = GetSegLen(xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

             xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

        '     PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)'segment length
        '     PRINT "Z CTR : "; zPos2#;RadsToDeg(@Ray.eRotAngRads(IndexCtr)); @Ray.skewRads#

             INCR xIndexCtr

             IF xIndexCtr > @Ray.i_xIndexEnd THEN EXIT DO

             INCR PathCtr

             IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenCircSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - index at weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)+ (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr) + xtheta + @Ray.skewRads))
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr) + xtheta + @Ray.skewRads))
             zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr) + @Ray.skewRads) )
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yBegin

             xMtrSeg_G(PathCtr) = xPos2# - xPos1#
             yMtrSeg_G(PathCtr) = yPos2# - yPos1#
             zMtrSeg_G(PathCtr) = zPos2# - zPos1#
             xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
             yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

             xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

             xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#


       '      PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)'segment length
       '      PRINT "Z CTR : "; zPos2# ;RadsToDeg(@Ray.eRotAngRads(IndexCtr)); @Ray.skewRads

       '      PRINT
       '
       '      WAITKEY$

        LOOP


        'PRINT "WAITKEY$"

        'WAITKEY$


    ELSE   'Raster in the circ direction

        'pathbufflen% = ((xIndexEnd#/indexInc#) + 2) * (@Ray.i_xIndexEnd + 1)

        'PRINT " pathbufflen: "; pathbufflen%
        'WAITKEY$

        '??  give command to move motors, XYZ into this position ??
        '    although motors should already be there, this would insure they are
        '    adjust by reading servo encoder offset counts just prior.

        'Scan start position
        xPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
        yPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0))+ (@Ray.xOffset * SIN(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
        zPos1# = RadsToDeg( (@Ray.eRotAngRads(0)+ @Ray.skewRads#) )
        xImgPos1# = @Ray.eArcTotal(0)
        yImgPos1# = @Ray.r_yBegin

        'store the scan start position
        BeginSeg_G(0)=xPos1: BeginSeg_G(1)=yPos1: BeginSeg_G(2)=zPos1: BeginSeg_G(3)=xImgPos1: BeginSeg_G(4)=yImgPos1

        @Ray.i_yIndexEnd = ABS(@Ray.r_yEnd-@Ray.r_yBegin)/@Ray.r_yIndexInc

        PathCtr = -1
        yIndexCtr = 0  'current y index counter
        xIndexCtr = 0  'current x index counter
        Index# = 0    'current index real

        DO


            FOR xIndexCtr = 1 TO @Ray.i_xIndexEnd '@ start position: drive positive circ direction to next path coordinate

                INCR PathCtr

                IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                    GenCircSegments = (PathCtr-1)
                    EXIT FUNCTION
                END IF

                'get path target position - move away from weld
                xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr) + (@Ray.XOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta + @Ray.skewRads))
                yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.XOffset * SIN(@Ray.eRotAngRads(xIndexCtr) + xtheta + @Ray.skewRads))
                zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr) + @Ray.skewRads#) )
                xImgPos2# = @Ray.eArcTotal(xIndexCtr)
                yImgPos2# = @Ray.r_yBegin + index#


                xMtrSeg_G(PathCtr) = xPos2# - xPos1#
                yMtrSeg_G(PathCtr) = yPos2# - yPos1#
                zMtrSeg_G(PathCtr) = zPos2# - zPos1#
                xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
                yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#
                xySegLn_G(PathCtr) = GetSegLen(xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

                xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

                'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr) 'segment length

            NEXT

            'set to end position at current index
            xPos1# =  (@Ray.eRadiusNorm(@Ray.i_xIndexEnd) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + @Ray.eOriginX(@Ray.i_xIndexEnd) + (@Ray.XOffset * COS(@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ xtheta + @Ray.skewRads))
            yPos1# =  (@Ray.eRadiusNorm(@Ray.i_xIndexEnd) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + (@Ray.XOffset * SIN(@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ xtheta + @Ray.skewRads))
            zPos1# = RadsToDeg( (@Ray.eRotAngRads(@Ray.i_xIndexEnd) + @Ray.skewRads) )
            xImgPos1# = @Ray.eArcTotal(@Ray.i_xIndexEnd)
            yImgPos1# = @Ray.r_yBegin + index#

            index# = index# + @Ray.r_yIndexInc 'set to next index position

            INCR yIndexCtr

            IF yIndexCtr > @Ray.i_yIndexEnd THEN EXIT DO

            INCR PathCtr

            IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
               GenCircSegments = (PathCtr-1)
               EXIT FUNCTION
             END IF

            'set to end position at next index
            xPos2# =  (@Ray.eRadiusNorm(@Ray.i_xIndexEnd) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + @Ray.eOriginX(@Ray.i_xIndexEnd) + (@Ray.xOffset * COS(@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ xtheta + @Ray.skewRads))
            yPos2# =  (@Ray.eRadiusNorm(@Ray.i_xIndexEnd) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ xtheta + @Ray.skewRads))
            zPos2# = RadsToDeg( (@Ray.eRotAngRads(@Ray.i_xIndexEnd) + @Ray.skewRads) )
            xImgPos2# = @Ray.eArcTotal(@Ray.i_xIndexEnd)
            yImgPos2# = @Ray.r_yBegin + index#

            xMtrSeg_G(PathCtr) = xPos2# - xPos1#
            yMtrSeg_G(PathCtr) = yPos2# - yPos1#
            zMtrSeg_G(PathCtr) = zPos2# - zPos1#
            xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
            yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

            xySegLn_G(PathCtr) = GetSegLen(xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

            xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

            'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)

            FOR xIndexCtr = (@Ray.i_xIndexEnd-1) TO 0 STEP -1 '@ end position: drive positive circ direction to next path coordinate

                INCR PathCtr

                IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                   GenCircSegments = (PathCtr-1)
                   EXIT FUNCTION
                END IF

                'get path target position - index at weld
                xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr) + (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta + @Ray.skewRads))
                yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr)+ xtheta + @Ray.skewRads))
                zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr) + @Ray.skewRads) )
                xImgPos2# = @Ray.eArcTotal(xIndexCtr)
                yImgPos2# = @Ray.r_yBegin + index#

                xMtrSeg_G(PathCtr) = xPos2# - xPos1#
                yMtrSeg_G(PathCtr) = yPos2# - yPos1#
                zMtrSeg_G(PathCtr) = zPos2# - zPos1#
                xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
                yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

                xySegLn_G(PathCtr) = GetSegLen(xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

                xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

                'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)

            NEXT

            'set to start position at current index
            xPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0)+ xtheta + @Ray.skewRads))
            yPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(0))+ (@Ray.xOffset * SIN(@Ray.eRotAngRads(0)+ xtheta + @Ray.skewRads))
            zPos1# = RadsToDeg( (@Ray.eRotAngRads(0)+ @Ray.skewRads#) )
            xImgPos1# = @Ray.eArcTotal(0)
            yImgPos1# = @Ray.r_yBegin + index#

            index# = index# + @Ray.r_yIndexInc 'set index to next position

            INCR yIndexCtr

            IF yIndexCtr > @Ray.i_yIndexEnd THEN EXIT DO

            INCR PathCtr

            IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenCircSegments = (PathCtr-1)
                EXIT FUNCTION
            END IF

            'set to start postion at next index
            xPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0)+ xtheta + @Ray.skewRads))
            yPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(0))+ (@Ray.xOffset * SIN(@Ray.eRotAngRads(0)+ xtheta + @Ray.skewRads))
            zPos2# = RadsToDeg( (@Ray.eRotAngRads(0)+ @Ray.skewRads#) )
            xImgPos2# = @Ray.eArcTotal(0)
            yImgPos2# = @Ray.r_yBegin + index#

            xMtrSeg_G(PathCtr) = xPos2# - xPos1#
            yMtrSeg_G(PathCtr) = yPos2# - yPos1#
            zMtrSeg_G(PathCtr) = zPos2# - zPos1#
            xImgSeg_G(PathCtr) = xImgPos2# - xImgPos1#
            yImgSeg_G(PathCtr) = yImgPos2# - yImgPos1#

            xySegLn_G(PathCtr) = GetSegLen (xMtrSeg_G(PathCtr), yMtrSeg_G(PathCtr))

            xPos1# = xPos2# : yPos1# = yPos2# : zPos1# = zPos2# : xImgPos1# = xImgPos2# : yImgPos1# = yImgPos2#

            'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr)

        LOOP

        'Print "PathCtr =: " ; PathCtr

        'BEEP

        'PRINT "WAITKEY$"

        'WAITKEY$

    END IF

    GenCircSegments = (PathCtr-1)
    EXIT FUNCTION

END FUNCTION


SUB RunAxialScan(BYVAL RayPtr AS DWORD, BYVAL SCNPtr AS DWORD, BYVAL GFXPtr AS DWORD, BYVAL gWinPtrBitmap AS DWORD)

        LOCAL Ray AS FociRay POINTER
        Ray = RayPtr

        LOCAL gWinBitMap AS LONG POINTER
        gWinBitMap = gWinPtrBitmap


        LOCAL xPos_Error, yPos_Error, zPos_Error, xImg_Error, yImg_Error AS DOUBLE
        LOCAL xCts, yCts, zCts, xImgCts, yImgCts, pathtime AS DOUBLE
        LOCAL xCtsF, yCtsF, zCtsF, xImgCtsF, yImgCtsF AS DOUBLE
        LOCAL xPos2, yPos2, zPos2, xImgPos2, yImgPos2, eXpos2, eYpos2, yPos1 AS DOUBLE
        LOCAL xPosCtsR, yPosCtsR, zPosCtsR, xImgCtsR, yImgCtsR AS DOUBLE
        LOCAL xPosCts2, yPosCts2, zPosCts2, xImgCts2, yImgCts2, n60HzSegments, lctr, pctr AS LONG
        LOCAL x60Hz, y60Hz, z60Hz, xImg60Hz, yImg60Hz AS DOUBLE
        LOCAL xspeed, yspeed AS DOUBLE   'should always be the same for coord' motion
        DIM sTxt(15) AS LOCAL STRING

        'Scan start position
        xPos2# =  (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0)
        yPos2# =  (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0))
        zPos2# =  RadsToDeg(@Ray.eRotAngRads(0))
        xImgPos2# = @Ray.eArcTotal(0)
        yImgPos2# = @Ray.r_yBegin

        GRAPHIC COPY @gWinBitmap, 0&    'copy bitmap to standard window

        PlotAxProbe(xPos2#, yPos2#, zPos2#, @Ray.thetaS, SCNPtr, GFXPtr) 'Draw Transducer and features at current angle and position

        GRAPHIC REDRAW                              'Re-Draw the screen snappaly

  '     PRINT "Run Axial Scans"

'       GRAPHIC WAITKEY$


        xspeed# = 1.00# : yspeed# = 1.00#  'should always be the same for coord' motion

        'reset offset error counts to 0
        xPos_Error# = 0
        yPos_Error# = 0
        zPos_Error# = 0
        xImg_Error# = 0
        yImg_Error# = 0


        'be sure to set step count multiplier on servo's to 10x
        'set counts inch - divide by 10 to make life easier for Nucleo's output counts
        xCts# = 3768.024325157213#  '(37680.24325157213#)/10.00#  'cts per inch travel = (300564/1300) * (30/12) * (128*4)  / (2.5 * Pi)  =  cts/inch
        yCts# = 4460.5440#          '(44605.440#)/10.00#          'cts per inch travel = (4356/100) * (128*4) / 0.500 = cts/inch
        zCts# = 270.412955465587#   '(2704.12955465587#)/10.00#   'cts per degree rotate = (341550/2470) * (110/24) * (36/12) * (128*4) / 360 = cts/degree
        xImgCts# = 1000.00#         'user set - image system must match set resolution
        yImgCts# = 1000.00#         'user set - image system must match set resolution

        xCtsF# = 1.00#/xCts# 'perform division once
        yCtsF# = 1.00#/yCts#
        zCtsF# = 1.00/zCts#
        xImgCtsF# = 1.00#/xImgCts#
        yImgCtsF# = 1.00#/yImgCts#


        FOR lctr& = 0 TO NumOfSeg_G

            'Note:'the X&Y axis travel distance is always <= the X&Y image distance output.
            'the X&Y image output distance is always >= the X&Y axis travel distance

            'combined X-Axis and Y-Axis motion moves the transducer axially in reference to weld
            IF (xImgSeg_G(lCtr&)=0) AND (yImgSeg_G(lCtr&)<>0) THEN       'image output on y axis only

                IF ABS(xySegLn_G(lCtr&)) > ABS(yImgSeg_G(lCtr&)) THEN  'physical probe movement distance > generated distance
                   pathtime# = ABS(xySegLn_G(lCtr&)/yspeed#)               ' segment excursion time in seconds
                ELSE
                   pathtime# = ABS(yImgSeg_G(lCtr&)/yspeed#)               ' segment excursion time in seconds
                END IF

            'combined X-Axis and Y-Axis motion moves the transducer circumferently in reference to weld
            ELSEIF (yImgSeg_G(lCtr&)=0) AND (xImgSeg_G(lCtr&)<>0) THEN   'image output on x axis only

                IF ABS(xySegLn_G(lCtr&)) > ABS(xImgSeg_G(lCtr&)) THEN        'Seg_XyL = physical surface distance
                   pathtime# = ABS(xySegLn_G(lCtr&)/xspeed#)               ' segment excursion time in seconds
                ELSE
                   pathtime# = ABS(xImgSeg_G(lCtr&)/xspeed#)               ' segment excursion time in seconds
                END IF

            ELSE

   '             PRINT "shouldn't be here"
   '             WAITKEY$

            END IF

            n60HzSegments& = CLNG( (pathtime#*60.00#) + 0.51# )          ' number of path segments at 60 Hz

            'need to add a simple fixed accel/deccel rate !!!!!!!!!! out of time to implement this!!!

            x60Hz# = xMtrSeg_G(lCtr&)/n60HzSegments&
            y60Hz# = yMtrSeg_G(lCtr&)/n60HzSegments&
            z60Hz# = zMtrSeg_G(lCtr&)/n60HzSegments&

            xImg60Hz# = xImgSeg_G(lCtr&)/n60HzSegments&
            yImg60Hz# = yImgSeg_G(lCtr&)/n60HzSegments&


            FOR pctr& = 1 TO n60HzSegments&

                 'numbers used for actual scanner manipulation and image output

                 'convert to nucleo encoded output counts!
                 xPosCtsR# = x60Hz# * xCts#         'use real numbers: to later correct for rounding errors
                 yPosCtsR# = y60Hz# * yCts#
                 zPosCtsR# = z60Hz# * zCts#
                 xImgCtsR# = xImg60Hz# * xImgCts#
                 yImgCtsR# = yImg60Hz# * yImgCts#


                 'Here is where to load the 60Hz segment pieces of the full path






                 'Translating from real to integer position counts results in rounding errors, normally in the range of +/- 1 count.
                 'Over the full scan path, these small errors per path increment can/will accumulate into large position errors.
                 'Track and correct the accumlated error on each path increment:
                 xPosCts2& = (xPosCtsR# + xPos_Error#) 'add rounding error back in
                 yPosCts2& = (yPosCtsR# + yPos_Error#)
                 zPosCts2& = (zPosCtsR# + zPos_Error#)
                 xImgCts2& = (xImgCtsR# + xImg_Error#)
                 yImgCts2& = (yImgCtsR# + yImg_Error#)

                 'capture rounding error
                 xPos_Error# = (xPosCtsR# + xPos_Error#) - xPosCts2&
                 yPos_Error# = (yPosCtsR# + yPos_Error#) - yPosCts2&
                 zPos_Error# = (zPosCtsR# + zPos_Error#) - zPosCts2&
                 xImg_Error# = (xImgCtsR# + xImg_Error#) - xImgCts2&
                 yImg_Error# = (yImgCtsR# + yImg_Error#) - yImgCts2&

                 '******************************************************************************************************
                 'numbers used only for graphic plots
                 xPos2# = xPos2# + (xPosCts2& * xCtsF#)
                 yPos2# = yPos2# + (yPosCts2& * yCtsF#)
                 zPos2# = zPos2# + (zPosCts2& * zCtsF#)
                 xImgPos2# = xImgPos2# + (xImgCts2& * xImgCtsF#)
                 yImgPos2# = yImgPos2# + (yImgCts2& * yImgCtsF#)
                 '******************************************************************************************************


                '*********************************************************************************************************************************
                '            BELOW FOR TESTING ONLY!!   TEST FINDING XYZ IN 3D Space from an Unknown location
                '*********************************************************************************************************************************

                 'angular position of transducer in reference to x,y centerline of nozzle
                 @Ray.thetaRads = Get360(xPos2#,yPos2#,ATN(yPos2#/xPos2#)) 'foci calculations performed with this result!

                 'cartesian real; X coordinate of this point along weld, on far side edge of weld HAZ.
                 eXpos2# = @Ray.majorAxisRad * COS(@Ray.thetaRads) 'get xPos of current incremented angle along weld HAZ perimeter

                 'cartesian real; Y coordinate of this point along ellipse, on far side edge of weld HAZ.
                 eYpos2# = @Ray.minorAxisRad * SIN(@Ray.thetaRads) 'get yPos of current incremented angle along weld HAZ perimeter

                 'get segment length:
                 'from current cartesian X,Y scanner probe coordinate located somewhere in 3D space to UT beam intercept point along weld perimeter (HAZ)
                 yPos1# = GetSegLen((xPos2#-eXpos2#),(yPos2#-eYpos2#))


                 'store old
                 @Ray.ftemp(0) = @Ray.majorAxis
                 @Ray.ftemp(1) = @Ray.minorAxis
                 @Ray.ftemp(2) = @Ray.majorAxisRad
                 @Ray.ftemp(3) = @Ray.minorAxisRad
                 @Ray.ftemp(4) = @Ray.foci
                 @Ray.ftemp(5) = @Ray.fociX2


                 'in with the new
                 @Ray.majorAxis = @Ray.majorAxis + (yPos1#*2)
                 @Ray.minorAxis = @Ray.minorAxis + (yPos1#*2)
                 @Ray.majorAxisRad = @Ray.majorAxis * half
                 @Ray.minorAxisRad = @Ray.minorAxis * half
                 @Ray.foci = SQR(SQ(@Ray.majorAxisRad)-SQ(@Ray.minorAxisRad))
                 @Ray.fociX2 = @Ray.foci*2

                 'try to find unknown location
                 GetFoci(xPos2#,yPos2#,Ray)

                 'out with the new and in with the old
                 @Ray.majorAxis = @Ray.ftemp(0)
                 @Ray.minorAxis = @Ray.ftemp(1)
                 @Ray.majorAxisRad = @Ray.ftemp(2)
                 @Ray.minorAxisRad = @Ray.ftemp(3)
                 @Ray.foci = @Ray.ftemp(4)
                 @Ray.fociX2 = @Ray.ftemp(5)


                 '**************************************************************************************************************************************************

                 GRAPHIC COPY @gWinBitmap, 0&                    'copy static nozzle scan model to standard window


                 PlotAxProbe(xPos2#, yPos2#, zPos2#, @Ray.thetaS, SCNPtr, GFXPtr) 'Draw Transducer and features at current angle and position


                 'TEST results: draw line at our newly found location
                 'visually see how well it lines up with known coordiantes
                 GRAPHIC LINE(0,@Ray.nOriginX)-(yPos2#,xPos2#), %RGB_HOTPINK

                 'goto skiptext

                 sTxt(0)="Probe   X: " + STR$(ROUND(xImgPos2#,3))+ "        "
                 sTxt(1)="Probe   Y: " + STR$(ROUND(yImgPos2#,3))+ "        "
                 sTxt(2)="Unknown Y: " + STR$(ROUND(yPos1#,3))   + "        "

                 sTxt(3)="Motor   Z: "+ STR$(ROUND(zPos2#,3))+ "           "
                 sTxt(4)="Unknown Z: "+ STR$(ROUND(RadsToDeg(@Ray.nRotAngRads),3))+ "           "
                 sTxt(5)="Error   Z: "+ STR$(ROUND((RadsToDeg(@Ray.nRotAngRads)-zPos2#),3)) + "           "


                 sTxt(7)="Motor  X : "+ STR$(ROUND(xPos2#,4))+"           "
                 sTxt(8)="Motor  Y : "+ STR$(ROUND(yPos2#,4))+"           "
                 sTxt(9)="Motor  Z : "+ STR$(ROUND(zPos2#,6))+"           "

                 sTxt(10)="xPos_Error# : " + STR$(ROUND(xPos_Error#,6))+"            "
                 sTxt(11)="yPos_Error# : " + STR$(ROUND(yPos_Error#,6))+"            "
                 sTxt(12)="zPos_Error# : " + STR$(ROUND(zPos_Error#,6))+"            "
                 sTxt(13)="xImg_Error# : " + STR$(ROUND(xImg_Error#,6))+"            "
                 sTxt(14)="yImg_Error# : " + STR$(ROUND(yImg_Error#,6))+"            "


                 GRAPHIC SET POS(-26.00!,-16.00!):GRAPHIC PRINT sTxt(0)
                 GRAPHIC SET POS(-26.00!,-15.00!):GRAPHIC PRINT sTxt(1)
                 GRAPHIC SET POS(-26.00!,-14.00!):GRAPHIC PRINT sTxt(2)
                 GRAPHIC SET POS(-26.00!,-13.00!):GRAPHIC PRINT sTxt(3)

                 GRAPHIC SET POS(-26.00!,-12.00!):GRAPHIC PRINT sTxt(4)
                 GRAPHIC SET POS(-26.00!,-11.00!):GRAPHIC PRINT sTxt(5)
                 GRAPHIC SET POS(-26.00!,-10.00!):GRAPHIC PRINT sTxt(6)

                 GRAPHIC SET POS(-26.00!,-9.00!):GRAPHIC PRINT sTxt(7)
                 GRAPHIC SET POS(-26.00!,-8.00!):GRAPHIC PRINT sTxt(8)
                 GRAPHIC SET POS(-26.00!,-7.00!):GRAPHIC PRINT sTxt(9)
                 GRAPHIC SET POS(-26.00!,-6.00!):GRAPHIC PRINT sTxt(10)


                 GRAPHIC SET POS(-26.00!,-5.00!):GRAPHIC PRINT sTxt(11)
                 GRAPHIC SET POS(-26.00!,-4.00!):GRAPHIC PRINT sTxt(12)
                 GRAPHIC SET POS(-26.00!,-3.00!):GRAPHIC PRINT sTxt(13)
                 GRAPHIC SET POS(-26.00!,-2.00!):GRAPHIC PRINT sTxt(14)
                 GRAPHIC SET POS(-26.00!,-1.00!):GRAPHIC PRINT sTxt(15)

                 GRAPHIC REDRAW                              'Re-Draw the screen snappaly

                 IF (yImgSeg_G(lCtr&)=0) AND (xImgSeg_G(lCtr&)<>0) THEN 'x index
                     SLEEP 10
                 END IF

                 'GRAPHIC WAITKEY$

                 '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


            NEXT

            SLEEP 10 '500
        NEXT



    'BEEP

'    DO
'
'       K$ = INKEY$
'    LOOP UNTIL K$ = ""

    BEEP : GRAPHIC WAITKEY$

END SUB

SUB RunCircScan(BYVAL RayPtr AS DWORD, BYVAL SCNPtr AS DWORD, BYVAL GFXPtr AS DWORD, BYVAL gWinPtrBitmap AS DWORD)

        LOCAL Ray AS FociRay POINTER
        Ray = RayPtr

        LOCAL gWinBitMap AS LONG POINTER  'graphic window pointer - yikes!
        gWinBitMap = gWinPtrBitmap

        LOCAL xPos_Error,yPos_Error,zPos_Error,xImg_Error,yImg_Error,xCts,yCts,zCts,xImgCts,yImgCts AS DOUBLE
        LOCAL xCtsF,yCtsF,zCtsF,xImgCtsF,yImgCtsF,xPos2,yPos2,zPos2,xImgPos2,yImgPos2 AS DOUBLE
        LOCAL pathtime,xPosCtsR,yPosCtsR,zPosCtsR,xImgCtsR,yImgCtsR AS DOUBLE
        LOCAL x60Hz,y60Hz,z60Hz,xImg60Hz,yImg60Hz AS DOUBLE
        LOCAL xspeed, yspeed AS DOUBLE  'should always be the same for coord' motion

        LOCAL xPosCts2,yPosCts2,zPosCts2,xImgCts2,yImgCts2 AS LONG
        LOCAL lctr,pctr,n60HzSegments AS LONG

        DIM sTxt(16) AS LOCAL STRING

        LOCAL xtheta AS DOUBLE ' transducer offset

        'scan start position: Scanner vs program
        'X_AXIS SIDE,scanner at 0   Degrees = 270 Degrees program
        '                       90  Degrees = 0   Degrees program
        '                       180 Degrees = 90  Degrees program
        '                       270 Degrees = 180 Degrees program

        IF @Ray.thetaS = Rads270 THEN
            xtheta = Rads0
        ELSEIF @Ray.thetaS = Rads0 THEN
            xtheta = Rads90
        ELSEIF @Ray.thetaS = Rads90 THEN
            xtheta = Rads180
        ELSEIF @Ray.thetaS = Rads180 THEN
            xtheta = Rads270
        END IF


        'Scan start position
        xPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
        yPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
        zPos2# = RadsToDeg( (@Ray.eRotAngRads(0)+ @Ray.skewRads) )
        xImgPos2# = @Ray.eArcTotal(0)
        yImgPos2# = @Ray.r_yBegin



        GRAPHIC COPY @gWinBitmap, 0&    'copy bitmap to standard window

        PlotCircProbe(xPos2#, yPos2#, zPos2#, @Ray.thetaS, SCNPtr, GFXPtr) 'Draw Transducer and features at current angle and position

        GRAPHIC REDRAW                              'Re-Draw the screen snappaly

        PRINT "Run Circ Scan"

        GRAPHIC WAITKEY$



        xspeed# = 1.00# : yspeed# = 1.00#  'should always be the same for coord' motion

        'reset offset error counts to 0
        xPos_Error# = 0
        yPos_Error# = 0
        zPos_Error# = 0
        xImg_Error# = 0
        yImg_Error# = 0

        'be sure to set step count multiplier on servo's to 10x
        'set counts inch - divide by 10 to make life easier for Nucleo's output counts
        xCts# = 3768.024325157213#  '(37680.24325157213#)/10.00#  'cts per inch travel = (300564/1300) * (30/12) * (128*4)  / (2.5 * Pi)  =  cts/inch
        yCts# = 4460.5440#          '(44605.440#)/10.00#          'cts per inch travel = (4356/100) * (128*4) / 0.500 = cts/inch
        zCts# = 270.412955465587#   '(2704.12955465587#)/10.00#   'cts per degree rotate = (341550/2470) * (110/24) * (36/12) * (128*4) / 360 = cts/degree
        xImgCts# = 1000.00#         'user set - image system must match set resolution
        yImgCts# = 1000.00#         'user set - image system must match set resolution

        xCtsF# = 1.00#/xCts# 'perform division once
        yCtsF# = 1.00#/yCts#
        zCtsF# = 1.00#/zCts#
        xImgCtsF# = 1.00#/xImgCts#
        yImgCtsF# = 1.00#/yImgCts#


        FOR lctr& = 0 TO NumOfSeg_G

            'Note:'the X&Y axis travel distance is always <= the X&Y image distance output.
            'the X&Y image output distance is always >= the X&Y axis travel distance

            'combined X-Axis and Y-Axis motion moves the transducer axially in reference to weld
            IF (xImgSeg_G(lCtr&)=0) AND (yImgSeg_G(lCtr&)<>0) THEN       'image output on y axis only

                IF ABS(xySegLn_G(lCtr&)) > ABS(yImgSeg_G(lCtr&)) THEN  'physical probe movement distance > generated distance
                   pathtime# = ABS(xySegLn_G(lCtr&)/yspeed#)               ' segment excursion time in seconds
                ELSE
                   pathtime# = ABS(yImgSeg_G(lCtr&)/yspeed#)               ' segment excursion time in seconds
                END IF

            'combined X-Axis and Y-Axis motion moves the transducer circumferently in reference to weld
            ELSEIF (yImgSeg_G(lCtr&)=0) AND (xImgSeg_G(lCtr&)<>0) THEN   'image output on x axis only

                IF ABS(xySegLn_G(lCtr&)) > ABS(xImgSeg_G(lCtr&)) THEN        'Seg_XyL = physical surface distance
                   pathtime# = ABS(xySegLn_G(lCtr&)/xspeed#)               ' segment excursion time in seconds
                ELSE
                   pathtime# = ABS(xImgSeg_G(lCtr&)/xspeed#)               ' segment excursion time in seconds
                END IF

            ELSE
               PRINT xImgSeg_G(lCtr&);yImgSeg_G(lCtr&)

               PRINT "shouldn't be here"
               ' WAITKEY$

            END IF

            n60HzSegments& = CLNG( (pathtime#*60.00#) + 0.51# )          ' number of path segments at 60 Hz

            'need to add a simple fixed accel/deccel rate !!!!!!!!!! out of time to implement this!!!

            x60Hz# = xMtrSeg_G(lCtr&)/n60HzSegments&
            y60Hz# = yMtrSeg_G(lCtr&)/n60HzSegments&
            z60Hz# = zMtrSeg_G(lCtr&)/n60HzSegments&

            xImg60Hz# = xImgSeg_G(lCtr&)/n60HzSegments&
            yImg60Hz# = yImgSeg_G(lCtr&)/n60HzSegments&


            FOR pctr& = 1 TO n60HzSegments&  ' each and every segment will run for 1/60 second

                 'numbers used for actual scanner manipulation and image output

                 'convert to nucleo encoded output counts!
                 xPosCtsR# = x60Hz# * xCts#         'use real numbers: track and correct for rounding errors belows
                 yPosCtsR# = y60Hz# * yCts#
                 zPosCtsR# = z60Hz# * zCts#
                 xImgCtsR# = xImg60Hz# * xImgCts#
                 yImgCtsR# = yImg60Hz# * yImgCts#


                 'Translating from real to integer position counts results in rounding errors, normally in the range of +/- 1 count.
                 'Over the full scan path, these small errors per path increment can/will accumulate into large position errors.
                 'Track and correct the accumlated error on each path increment:
                 xPosCts2& = (xPosCtsR# + xPos_Error#) 'add rounding error back in
                 yPosCts2& = (yPosCtsR# + yPos_Error#)
                 zPosCts2& = (zPosCtsR# + zPos_Error#)
                 xImgCts2& = (xImgCtsR# + xImg_Error#)
                 yImgCts2& = (yImgCtsR# + yImg_Error#)

                 'capture rounding error
                 xPos_Error# = (xPosCtsR# + xPos_Error#) - xPosCts2&
                 yPos_Error# = (yPosCtsR# + yPos_Error#) - yPosCts2&
                 zPos_Error# = (zPosCtsR# + zPos_Error#) - zPosCts2&
                 xImg_Error# = (xImgCtsR# + xImg_Error#) - xImgCts2&
                 yImg_Error# = (yImgCtsR# + yImg_Error#) - yImgCts2&

                 '******************************************************************************************************
                 'get reals from counts for plotting purposes - these numbers used for graphic plots only
                 xPos2# = xPos2# + (xPosCts2& * xCtsF#)
                 yPos2# = yPos2# + (yPosCts2& * yCtsF#)
                 zPos2# = zPos2# + (zPosCts2& * zCtsF#)
                 xImgPos2# = xImgPos2# + (xImgCts2& * xImgCtsF#)
                 yImgPos2# = yImgPos2# + (yImgCts2& * yImgCtsF#)
                 '******************************************************************************************************

                 GRAPHIC COPY @gWinBitmap, 0&                    'copy static nozzle scan model to standard window

                 PlotCircProbe(xPos2#, yPos2#, zPos2#, @Ray.thetaS, SCNPtr, GFXPtr) 'Draw Transducer and features at current angle and position

                 sTxt(0)="Probe  X :"+ STR$(ROUND(xImgPos2#,4))+"      "
                 sTxt(1)="Probe  Y :"+ STR$(ROUND(yImgPos2#,4))+"                 "
                 'sTxt(2)="Probe  Z :"+ STR$(ROUND(RadsToDeg(zPos2),6)) + "           "

                 sTxt(4)="Motor  X :"+ STR$(ROUND(xPos2#,4))+"            "
                 sTxt(5)="Motor  Y :"+ STR$(ROUND(yPos2#,4))+"            "
                 sTxt(6)="Motor  Z :"+ STR$(ROUND(zPos2#,6)) + "           "

                 sTxt(11)= "xPos_Error#: " + STR$(ROUND(xPos_Error#,6))+"            "
                 sTxt(12)= "yPos_Error#: " + STR$(ROUND(yPos_Error#,6))+"            "
                 sTxt(13)= "zPos_Error#: " + STR$(ROUND(zPos_Error#,6))+"            "
                 sTxt(14)="xImg_Error#:  " + STR$(ROUND(xImg_Error#,6))+"            "
                 sTxt(15)="yImg_Error#:  " + STR$(ROUND(yImg_Error#,6))+"            "


                 GRAPHIC SET POS(-26.00!,-16.00!):GRAPHIC PRINT sTxt(0)
                 GRAPHIC SET POS(-26.00!,-15.00!):GRAPHIC PRINT sTxt(1)
                 GRAPHIC SET POS(-26.00!,-14.00!):GRAPHIC PRINT sTxt(2)
                 GRAPHIC SET POS(-26.00!,-13.00!):GRAPHIC PRINT sTxt(3)

                 GRAPHIC SET POS(-26.00!,-12.00!):GRAPHIC PRINT sTxt(4)
                 GRAPHIC SET POS(-26.00!,-11.00!):GRAPHIC PRINT sTxt(5)
                 GRAPHIC SET POS(-26.00!,-10.00!):GRAPHIC PRINT sTxt(6)

                 GRAPHIC SET POS(-26.00!,-5.00!):GRAPHIC PRINT sTxt(11)
                 GRAPHIC SET POS(-26.00!,-4.00!):GRAPHIC PRINT sTxt(12)
                 GRAPHIC SET POS(-26.00!,-3.00!):GRAPHIC PRINT sTxt(13)
                 GRAPHIC SET POS(-26.00!,-2.00!):GRAPHIC PRINT sTxt(14)
                 GRAPHIC SET POS(-26.00!,-1.00!):GRAPHIC PRINT sTxt(15)

                 GRAPHIC REDRAW                              'Re-Draw the screen snappaly

                 IF (yImgSeg_G(lCtr&)=0) AND (xImgSeg_G(lCtr&)<>0) THEN 'x index
                     SLEEP 10
                 END IF

            NEXT

            SLEEP 10 '500
        NEXT



        '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


   ' BEEP : GRAPHIC WAITKEY$

END SUB


FUNCTION Get60HzSegs(BYVAL RayPtr AS DWORD) AS LONG

        LOCAL Ray AS FociRay POINTER
        Ray = RayPtr

        LOCAL xPos_Error,yPos_Error,zPos_Error,xImg_Error,yImg_Error,xCts,yCts,zCts,xImgCts,yImgCts AS DOUBLE
        LOCAL xCtsF,yCtsF,zCtsF,xImgCtsF,yImgCtsF,xPos2,yPos2,zPos2,xImgPos2,yImgPos2 AS DOUBLE
        LOCAL pathtime,xPosCtsR,yPosCtsR,zPosCtsR,xImgCtsR,yImgCtsR AS DOUBLE
        LOCAL x60Hz,y60Hz,z60Hz,xImg60Hz,yImg60Hz AS DOUBLE
        LOCAL xspeed, yspeed AS DOUBLE  'should always be the same for coord' motion

        LOCAL xPosCts2,yPosCts2,zPosCts2,xImgCts2,yImgCts2 AS LONG
        LOCAL lctr,pctr,n60HzSegments AS LONG

        LOCAL n60HzCtr AS LONG  'count number of path segments

        IF @Ray.AxialBeam THEN
            'AXIAL BEAM Scan start position
            xPos2# =  (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0)
            yPos2# =  (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0))
            zPos2# =  RadsToDeg(@Ray.eRotAngRads(0))
            xImgPos2# = @Ray.eArcTotal(0)
            yImgPos2# = @Ray.r_yBegin
        ELSE
            'CIRC BEAM Scan start position
            xPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0) + @Ray.skewRads))
            yPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0))+ (@Ray.xOffset * SIN(@Ray.eRotAngRads(0) + @Ray.skewRads))
            zPos2# = RadsToDeg( (@Ray.eRotAngRads(0)+ @Ray.skewRads) )
            xImgPos2# = @Ray.eArcTotal(0)
            yImgPos2# = @Ray.r_yBegin
        END IF

        xspeed# = 1.00# : yspeed# = 1.00#  'should always be the same for coord' motion

        'reset offset error counts to 0
        xPos_Error# = 0
        yPos_Error# = 0
        zPos_Error# = 0
        xImg_Error# = 0
        yImg_Error# = 0


         'be sure to set step count multiplier on servo's to 10x
        'set counts inch - divide by 10 to make life easier for Nucleo's output counts
        xCts# = 3768.024325157213#  '(37680.24325157213#)/10.00#  'cts per inch travel = (300564/1300) * (30/12) * (128*4)  / (2.5 * Pi)  =  cts/inch
        yCts# = 4460.5440#          '(44605.440#)/10.00#          'cts per inch travel = (4356/100) * (128*4) / 0.500 = cts/inch
        zCts# = 270.412955465587#   '(2704.12955465587#)/10.00#   'cts per degree rotate = (341550/2470) * (110/24) * (36/12) * (128*4) / 360 = cts/degree
        xImgCts# = 1000.00#         'user set - image system must match set resolution
        yImgCts# = 1000.00#         'user set - image system must match set resolution


        xCtsF# = 1.00#/xCts# 'perform division once
        yCtsF# = 1.00#/yCts#
        zCtsF# = 1.00#/zCts#
        xImgCtsF# = 1.00#/xImgCts#
        yImgCtsF# = 1.00#/yImgCts#

        n60HzCtr = 0

        FOR lctr& = 0 TO NumOfSeg_G

            'Note:'the X&Y axis travel distance is always <= the X&Y image distance output.
            'the X&Y image output distance is always >= the X&Y axis travel distance

            'combined X-Axis and Y-Axis motion moves the transducer axially in reference to weld
            IF (xImgSeg_G(lCtr&)=0) AND (yImgSeg_G(lCtr&)<>0) THEN       'image output on y axis only

                IF ABS(xySegLn_G(lCtr&)) > ABS(yImgSeg_G(lCtr&)) THEN  'physical probe movement distance > generated distance
                   pathtime# = ABS(xySegLn_G(lCtr&)/yspeed#)               ' segment excursion time in seconds
                ELSE
                   pathtime# = ABS(yImgSeg_G(lCtr&)/yspeed#)               ' segment excursion time in seconds
                END IF

            'combined X-Axis and Y-Axis motion moves the transducer circumferently in reference to weld
            ELSEIF (yImgSeg_G(lCtr&)=0) AND (xImgSeg_G(lCtr&)<>0) THEN   'image output on x axis only

                IF ABS(xySegLn_G(lCtr&)) > ABS(xImgSeg_G(lCtr&)) THEN        'Seg_XyL = physical surface distance
                   pathtime# = ABS(xySegLn_G(lCtr&)/xspeed#)               ' segment excursion time in seconds
                ELSE
                   pathtime# = ABS(xImgSeg_G(lCtr&)/xspeed#)               ' segment excursion time in seconds
                END IF

            ELSE

      '          PRINT "shouldn't be here"
      '          WAITKEY$

            END IF

            n60HzSegments& = CLNG( (pathtime#*60.00#) + 0.51# )          ' number of path segments at 60 Hz

            'need to add a simple fixed accel/deccel rate !!!!!!!!!! out of time to implement this!!!

            x60Hz# = xMtrSeg_G(lCtr&)/n60HzSegments&
            y60Hz# = yMtrSeg_G(lCtr&)/n60HzSegments&
            z60Hz# = zMtrSeg_G(lCtr&)/n60HzSegments&

            xImg60Hz# = xImgSeg_G(lCtr&)/n60HzSegments&
            yImg60Hz# = yImgSeg_G(lCtr&)/n60HzSegments&


            FOR pctr& = 1 TO n60HzSegments&  ' each and every segment will run for 1/60 second

                 'numbers used for actual scanner manipulation and image output

                 'convert to nucleo encoded output counts!
                 xPosCtsR# = x60Hz# * xCts#         'use real numbers: track and correct for rounding errors belows
                 yPosCtsR# = y60Hz# * yCts#
                 zPosCtsR# = z60Hz# * zCts#
                 xImgCtsR# = xImg60Hz# * xImgCts#
                 yImgCtsR# = yImg60Hz# * yImgCts#


                 'Translating from real to integer position counts results in rounding errors, normally in the range of +/- 1 count.
                 'Over the full scan path, these small errors per path increment can/will accumulate into large position errors.
                 'Track and correct the accumlated error on each path increment:
                 xPosCts2& = (xPosCtsR# + xPos_Error#) 'add rounding error back in
                 yPosCts2& = (yPosCtsR# + yPos_Error#)
                 zPosCts2& = (zPosCtsR# + zPos_Error#)
                 xImgCts2& = (xImgCtsR# + xImg_Error#)
                 yImgCts2& = (yImgCtsR# + yImg_Error#)

                 'capture rounding error
                 xPos_Error# = (xPosCtsR# + xPos_Error#) - xPosCts2&
                 yPos_Error# = (yPosCtsR# + yPos_Error#) - yPosCts2&
                 zPos_Error# = (zPosCtsR# + zPos_Error#) - zPosCts2&
                 xImg_Error# = (xImgCtsR# + xImg_Error#) - xImgCts2&
                 yImg_Error# = (yImgCtsR# + yImg_Error#) - yImgCts2&

                 '******************************************************************************************************
                 'get reals from counts for plotting purposes - these numbers used for graphic plots only
                 'xPos2# = xPos2# + (xPosCts2& * xCtsF#)
                 'yPos2# = yPos2# + (yPosCts2& * yCtsF#)
                 'zPos2# = zPos2# + (zPosCts2& * zCtsF#)
                 'xImgPos2# = xImgPos2# + (xImgCts2& * xImgCtsF#)
                 'yImgPos2# = yImgPos2# + (yImgCts2& * yImgCtsF#)
                 '******************************************************************************************************

                 INCR n60HzCtr

            NEXT

        NEXT

        Get60HzSegs = n60HzCtr

        '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


   ' BEEP : GRAPHIC WAITKEY$

END FUNCTION



'END USER DEFINED FUNCTIONS
'**********************************************************************************************************************************************
