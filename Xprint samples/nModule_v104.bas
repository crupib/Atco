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


MACRO Pi = 3.141592653589793##
MACRO DegToRads(dpDegrees) = (dpDegrees*0.0174532925199433##)
MACRO RadsToDeg(dpRadians) = (dpRadians*57.29577951308232##)

'MACRO Pi =  3.1415926535897932384626433832795#
    'MACRO Pi =  3.14159265358979323846#
'MACRO DegToRads(dpDegrees) = (dpDegrees*0.01745329251994329576923690768489#) '0.0174532925199433#)
'MACRO RadsToDeg(dpRadians) = (dpRadians*57.295779513082320876798154814105#)

MACRO ArcCos(CosA) = ( Pi / 2 - ATN(CosA / SQR(1 - CosA * CosA)) )  'ArcCos in radians
MACRO ArcCosA(CosA) = ( ArcCos(CosA)*57.295779513082320876798154814105#)'ArcCos in degrees

MACRO ArcSin(SinA) = ATN(SinA / SQR(1 - SinA * SinA))'ArcSin in radians
MACRO ArcSinA(SinA) = ( ArcSin(SinA)*57.295779513082320876798154814105#)'ArcSin in degrees'

MACRO SQ(SquareIt) = (SquareIt*SquareIt) 'Macro to square a number, because PBCC doesn't like the use of ^caret in all cases

MACRO CONST = MACRO
CONST Rads0 = (0.000#)
CONST Rads9 = (Pi*0.050#)
CONST Rads22p5 = (Pi*0.125#)
CONST Rads45 = (Pi*0.250#)
CONST Rads90 = (Pi*0.500#)
CONST Rads135 = (Pi*0.750#)
CONST Rads180 = (Pi)
CONST Rads225 = (Pi*1.250#)
CONST Rads270 = (Pi*1.500#)
CONST Rads315 = (Pi*1.750#)
CONST Rads360 = (Pi*2.000#)
CONST Rads540 = (Pi*3.000#)

'CONST Rads0inv = Rads360    'for Scan begin, Rads0inv + Rads360 = 360 degrees, with MOD360 equals 0 degrees
'CONST Rads90inv = Rads270   ' "
'CONST Rads180inv = Rads180  ' "
'CONST Rads270inv = Rads90   ' "


'const uTheta0 = Rads270   'user start degree translation
'CONST uTheta90 = Rads0
'CONST uTheta180 = Rads90
'CONST uTheta270 = Rads180


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
     i_xIndexEnd_U AS INTEGER   'number of X-indexes to user set max index, has no impact on Model, ends X-index'ing


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

    ProbeWidth AS DOUBLE     'circ probe overall width, contact footprint
    ProbeLen AS DOUBLE       'circ probe overall length, contact footprint
    ProbeIdx AS DOUBLE       'cir probe index position, measured from front of wedge or wedge case
    cProbeXOffset AS DOUBLE   'circ scan probe only; offset distance: equals surface distance from index to beam intersection point at ID
    ProbeSkew AS DOUBLE      'circ scan skew angle

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
    ProbeWidth AS DOUBLE
    cProbeXOffset AS DOUBLE
    ProbeIdx AS DOUBLE 'set to (-) 'transducer index position, measured setback from front
    ProbeLen AS DOUBLE
    ProbeSkew AS DOUBLE
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

     probeClr AS LONG       'circ probe perimeter case color
     probefillClr AS LONG   'circ probe fill color

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


TYPE gScreen

    hWin(10 )AS LONG ' Graphic Window handles

    xMinR(10) AS SINGLE
    yMinR(10) AS SINGLE
    xMaxR(10) AS SINGLE
    yMaxR(10) AS SINGLE
    PixelR(10) AS SINGLE
    xPixels(10) AS LONG
    yPixels(10) AS LONG
    gFont(10) AS LONG
    fClr(10) AS LONG
    bClr(10) AS LONG

END TYPE


FUNCTION PBMAIN

    'storage memory for model generation and scan segments

    DIM nRay AS LOCAL FociRay

    DIM u_GFX AS LOCAL u_GFXvars

    DIM SCN AS LOCAL ScanVars

    DIM u_SCN AS LOCAL u_ScanVars

    DIM gWIN AS GLOBAL gScreen

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

    'LOCAL BackClr&, ForeClr&, PlotClr&, HighClr&, LowClr&, NormClr&, Clr1&, Clr2&, Clr3&

    'LOCAL hWinCheck& 'check if user closed window

    'global InchPerPixel!, xScrn1!, yScrn1!, XScrn2!, yScrn2!, xSCRN&, ySCRN&

    'LOCAL hFont&

    LOCAL numOfpaths, n60HzSegments AS LONG

    '*******************************************************************************************
    ' Main Graphics Window
    '*******************************************************************************************
    gWIN.yPixels(0) = 1800 : gWIN.xPixels(0) = 1000

    gWIN.PixelR(0) = 0.035!  '0.035! '0.05! '0.010! '.040!   ' graphic window size

    gWIN.yMinR(0) = -(gWIN.yPixels(0) * .500! * gWIN.PixelR(0))
    gWIN.yMaxR(0) =  gWIN.yPixels(0) * .500!* gWIN.PixelR(0)

    gWIN.xMinR(0) = -(gWIN.xPixels(0) * .500! * gWIN.PixelR(0))
    gWIN.xMaxR(0) = (gWIN.xPixels(0) * .500! * gWIN.PixelR(0))

    gWIN.bClr(0) = %BLACK
    gWIN.fClr(0) = %WHITE

    'assigned even numbers for standard windows, direct display
    GRAPHIC WINDOW NEW "NOZZLE 'Top View'", 10, 10,gWIN.yPixels(0) , gWIN.xPixels(0) TO gWIN.hWin(0) 'Create a graphic window and assign it a handle
    GRAPHIC ATTACH gWIN.hWin(0), 0&                                       'Select standard window
    GRAPHIC COLOR gWIN.fClr(0), gWIN.bClr(0)                              'Set foreground and  background color
    GRAPHIC CLEAR                                                         'Clear selected window with background color
    GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))
    GRAPHIC SET OVERLAP (TRUE)

    '*******************************************************************************************
    'Graphics Bitmap
    '*******************************************************************************************

    gWIN.yPixels(1) = 1800 : gWIN.xPixels(1) = 1000

    gWIN.PixelR(1) = 0.04!  '0.035! '0.05! '0.010! '.040!   ' per pixel inch value

    gWIN.yMinR(1) = -(gWIN.yPixels(1) * .500! * gWIN.PixelR(1))
    gWIN.yMaxR(1) =  gWIN.yPixels(1) * .500!* gWIN.PixelR(1)

    gWIN.xMinR(1) = -(gWIN.xPixels(1) * .500! * gWIN.PixelR(1))
    gWIN.xMaxR(1) = (gWIN.xPixels(1) * .500! * gWIN.PixelR(1))

    gWIN.bClr(1) = %BLACK
    gWIN.fClr(1) = %WHITE

    'assigned odd numbers for bitmaps or special use windows, used to store static images for copying to standard window
    GRAPHIC BITMAP NEW gWIN.yPixels(1),gWIN.xPixels(1) TO gWIN.hWin(1) 'bitmap window for current nozzle weld scan model
    GRAPHIC ATTACH gWIN.hWin(1), 0&                   'Select bitmap window #1
    GRAPHIC COLOR gWIN.fClr(1), gWIN.bClr(1)            'Set foreground and  background color
    GRAPHIC CLEAR                                'Clear selected window with background color
    GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))
    GRAPHIC SET OVERLAP (TRUE)

    '**********************************************************************************************************************
    ' Select Main Graphics Window
    '**********************************************************************************************************************
     'assigned even numbers for standard windows, direct display
    GRAPHIC ATTACH gWIN.hWin(0), 0&, REDRAW   'Select MAIN standard window
    GRAPHIC WINDOW STABILIZE gWIN.hWin(0)     'user can't close window
    GRAPHIC COLOR gWIN.fClr(0), gWIN.bClr(0)  'Set foreground and  background color
    GRAPHIC CLEAR                             'Clear selected window with background color

    GRAPHIC SET VIRTUAL gWIN.yPixels(0), gWIN.xPixels(0), USERSIZE
    GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))
    GRAPHIC SET OVERLAP (TRUE)

    GRAPHIC SET FOCUS

    FONT NEW "Times New Roman", 12, 1 TO gWIN.gFont(0)
    GRAPHIC SET FONT gWIN.gFont(0)

    'graphic waitkey$

    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    '!!!!!!!!!!!  - GENERATE THE NOZZLE MODEL -
    '            ONLY (5) USER inputs required, (excluding colors!)
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    '****************************************************************************************
    'BEGIN: added 10/4/15: nozzle parameters for prototyping new features
    '****************************************************************************************

    'pipe/nozzle/branch connection configuration
    LOCAL PipeOD, PipeID, PipeOR, BranchOD, BranchID, PipeChord, PipeChordAngle, PipeChordArc AS DOUBLE

    'weld dimensions
    LOCAL InnerHazDia, OuterHazDia, InnerWeldDia, OuterWeldDia AS DOUBLE

    'axial scan parameters
    LOCAL AxialInnerScanDia, AxialOuterScanDia, AxialScanStroke, AxialScanIndex, AxialOffset, AxialSkew  AS DOUBLE

    'circ scan parameters
    LOCAL CircInnerScanDia, CircOuterScanDia, CircScanStroke, CircScanIndex, CircOffset, CircSkew AS DOUBLE

    nRay.minorAxis = 18.00# '8.75#' 10.75# 'axial (flat) measure along pipe

    PipeOD = 6.00#

    'PipeOR = 18.00#

    'PipeChordAngle = 2.00# * ArcSin(nRay.minorAxis/PipeOD)

    nRay.majorAxis = 8.00# 'PipeOD * ArcSin(nRay.minorAxis/PipeOD) 'circ (arc) measurement around pipe

    PRINT nRay.majorAxis

    nRay.r_xIndexIncFixed = .150#  'user set x-axis index increment

    'scan start position: scanner degrees vs nozzle weld azimuth
    'user 0   degrees = 270 degrees nozzle weld azimuth
    'user 90  degrees = 0   degrees nozzle weld azimuth
    'user 180 degrees = 90  degrees nozzle weld azimuth
    'user 270 degrees = 180 degrees nozzle weld azimuth

    LOCAL uAngS AS EXT 'DOUBLE

    uAngS = 0 '270 '50.500# '95.00# 'mod 360.00# ''90.500#

    nRay.thetaS = DegToRads(uAngS)  '((213.23#/360.00#)* Rads360) MOD Rads360

    nRay.i_xExtraIndx = 7  '

    GRAPHIC ATTACH gWIN.hWin(0), 0&,REDRAW           'select standard window

    'FONT NEW "Times New Roman", 20, 1 TO gWIN.gFont(0)

    FONT NEW "Times New Roman", 8, 1, 1, 0, 2700 TO gWIN.gFont(0)

    GRAPHIC SET FONT gWIN.gFont(0)








    'generate the scan model
    GetIndexChords(VARPTR(nRay))
    GetIndexRays(VARPTR(nRay))




    FONT NEW "Times New Roman", 12, 1 TO gWIN.gFont(0)
    GRAPHIC SET FONT gWIN.gFont(0)


    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    '!!!!!!!!!!!  - DRAW THE NOZZLE WELD SCAN MODEL -
    '            ONLY (4) USER inputs required, (excluding colors!)
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    'user set colors for model
    u_GFX.eStartClr = %RGB_GREEN        'scan start; outer radial line color
    u_GFX.eEndClr = %RGB_YELLOW 'RED        'scan end; outer radial line color
    u_GFX.eExtraClr = %RGB_MAGENTA      'scan extra; outer radial line color
    u_GFX.eRadialClr = %RGB_BLUE '%RGB_GOLD    'all other; outer scan radial scan line
    u_GFX.eInsideClr = %RGB_BLUE '%RGB_GOLD    'center inside; radial line line color
    u_GFX.eOutPClr = %RGB_BLUE          'outer perimeter; line color
    u_GFX.eWeldClr = %RGB_GREEN         'weld; radial line color
    u_GFX.eWeldPClr = %RGB_GREEN        'weld; perimeter line color
    u_GFX.eHAZClr = %RGB_RED        'HAZ; radial line color
    u_GFX.eHAZPClr = %RGB_RED       'HAZ; perimeter line color

    'user set model parameters: weld width, HAZ width and length of scan lines
    nRay.Scan_Rad = 10.00#          'length of radial scan lines, normal to weld
    nRay.Weld_Haz = 0.250#          'width of HAZ (Heat Affected Zone), x2: outside HAZ and inner-side HAZ at weld edges
    nRay.Weld_Width = 1.00#         'width of weldment

    'select and draw the model to bitmap #1
    GRAPHIC ATTACH gWIN.hWin(1), 0&  'Select bitmap #1 window
    GRAPHIC CLEAR  ' clear the current screen before plotting

    DrawScanModel(VARPTR(nRay), VARPTR(u_GFX)) 'draw the model bitmap to reuse later

    GRAPHIC ATTACH gWIN.hWin(0), 0&,REDRAW           'select standard window

    GRAPHIC COPY gWIN.hwin(1), 0&

    'User set plotting colors
    u_GFX.probeClr = %RGB_GOLD 'RGB(90,90,90)' DARKGRAY 'lightGRAY 'white 'blue 'magenta 'hotpink 'blue 'ORANGE  '%RGB_LIGHTYELLOW      'probe perimeter case color
    u_GFX.probefillClr = %RGB_ORANGE '%RGB_WHITE  'lightGRAY 'white 'blue 'magenta 'hotpink 'blue 'orange 'aqua 'BLUE '%RGB_ORANGE       'probe fill color
    u_GFX.TngtLineClr = %RGB_MAGENTA 'RED            'weld tangent line color
    u_GFX.NormLineClr = %RGB_MAGENTA 'RED            'weld normal line color
    u_GFX.CentLineClr = %RGB_GOLD 'WHITE          'probe center line color, probe beam
    u_GFX.IdxLineClr = %RGB_GOLD 'WHITE           'probe index line color
    u_GFX.offsetBallClr = %RGB_WHITE 'red 'WHITE        'ball at offset color
    u_GFX.probeBallClr = %RGB_WHITE 'RED   '%RGB_BLACK         'ball at probe center color
    u_GFX.ballRad = 0.200#                  'meatball radius

    'user set crosshair line length radius in inches
    u_GFX.IdxLine = 5 '10 '1 '10
    u_GFX.CentLine = 5' 10 ' 1 ' 10
    u_GFX.TngtLine = 5 '10 ' 5' 10
    u_GFX.NormLine = 5 '10 '5' 10

    nRay.AxialBeam = TRUE

    'nRay.AxialBeam = FALSE

    IF nRay.AxialBeam THEN  'SET THE AXIAL TRANSDUCER SCAN PARAMETERS

       'user set Y-Scan begin and end
       nRay.r_yBegin = -2.00##'.450#  'y scan start
       nRay.r_yEnd = 8.00## '5.540#   'y scan end

        'needed if nRay.RasterAxial = False, meaning raster motion is Circ direction
        nRay.r_yIndexInc = .250#  'index increment for Circ Raster

        'set by user, RasterAxial is back and forth scan motion, to and from the weld
        'If RasterAxial is False, scan motion is side to side, parallel along the weld,
        nRay.RasterAxial = True  'True 'False 'True 'False

        nRay.skewDegs = 0'10.00#'-10.000# ' 10.00# '.0001# 'transducer skew
        nRay.xOffset = 0 '4.00# '0' .0001#' 2.00# '    'transducer offset, index distance, to UT beam @ ID

        'user set transducer length, width and index
        'has no effect on scan accuracy, all scan parameters taken from centerline of gimbal slide fixture
        '!!! CRITICAL !!!Index point of transducer MUST BE ALIGNED with CENTERLINE of GIMBAL SLIDE (plunger)
        u_SCN.ProbeLen = 1.900# 'transducer length
        u_SCN.ProbeIdx = 0.900#   '1.00# '0.800# 'transducer index position, measured setback from front
        u_SCN.ProbeWidth = 1.650# 'transducer width

        u_SCN.ProbeSkew = nRay.skewDegs

        'probe X offset distance, projected at 90 degrees from polar scan line, parallel with weld axis, based on beam angle and weld thickness
        'If offsetset is negative, ProbeIdx & ProbeLen is also negative
        u_SCN.cProbeXOffset = nRay.xOffset ' -7  '-6.20#  'Set to negative above if transducer beam is pointing CW, Positive if beam is pointing CCW


    ELSE    'SET THE CIRC TRANSDUCER SCAN PARAMETERS

        nRay.r_yBegin = -5.750# '0'0.800# :
        nRay.r_yEnd = 1.250# '10.800#

        'addtional value needed if nRay.RasterAxial = False, meaning raster motion is Circ direction
        nRay.r_yIndexInc = .250#  'index increment for Circ Raster

        'set by user, RasterAxial is back and forth scan motion, to and from the weld
         nRay.RasterAxial = FALSE 'False 'TRUE 'False 'False ' TRUE 'False 'True 'False
         nRay.RasterAxial = TRUE 'False 'TRUE 'False 'False ' TRUE 'False 'True 'False


         'nRay.AxialBeam = TRUE   'circ beam, axial beam = false
         'nRay.AxialBeam = False   'circ beam, axial beam = false

        nRay.skewDegs = -80.000# ' 10.00# '.0001# '-12.00#  'transducer skew: -skewDegs = transducer on -side, UT Beam pointing CW
        nRay.xOffset = 4 '.00001# '-1.00 '-4.330#    'transducer offset, index distance, to UT beam @ ID

         'user set transducer length, width and index
        u_SCN.ProbeLen = 2.100# 'transducer length
        u_SCN.ProbeIdx = 0.900#   '1.00# '0.800# 'transducer index position, measured setback from front
        u_SCN.ProbeWidth = 2.600# 'transducer width

        u_SCN.ProbeSkew = nRay.skewDegs

        'probe X offset distance, projected at 90 degrees from polar scan line, parallel with weld axis, based on beam angle and weld thickness
        'If offsetset is negative, ProbeIdx & ProbeLen is also negative
        u_SCN.cProbeXOffset = nRay.xOffset ' -7  '-6.20#  'Set to negative above if transducer beam is pointing CW, Positive if beam is pointing CCW

    END IF

    'calculate the number of segments
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

    NumofPaths = GenSegments (VARPTR(nRay))

    PRINT "Actual paths: "; NumOfPaths
    PRINT "PRESS ANY KEY"
    WAITKEY$

    'save the paths
    '************************************************************************************************************************************

    SaveFile(VARPTR(nRay), VARPTR(u_GFX), VARPTR(u_SCN))

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
    'n60HzSegments = Get60HzSegs(VARPTR(nRay))
    PRINT "Number Of Segments: "; n60HzSegments
    WAITKEY$

    LOCAL RetVal AS LONG

    RetVal = RunScan(VARPTR(nRay), VARPTR(u_SCN), VARPTR(u_GFX), VARPTR(gWIN.hWin(1)))

    IF RetVal THEN  ' user closed window

    END IF

    CON.INPUT.FLUSH

    BEEP

    PRINT "WAITKEY$"

    WAITKEY$

    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    'EXIT THE PROGRAM FOR NOW


ExitWindows2:

      'Close and exit all windows
    GRAPHIC ATTACH gWIN.hWin(0), 0&  'select the STANDARD Graphics window
    GRAPHIC WINDOW END          'close the selected STANDARD Graphics window

    GRAPHIC ATTACH gWIN.hWin(1), 0&  'select the Memory Bitmap Graphics window
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
        PRINT "Rads180"
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




FUNCTION SaveFile(BYVAL RayPtr AS DWORD, BYVAL u_GFXPtr AS DWORD, BYVAL u_ScanPtr AS DWORD) AS LONG

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
    @Ray.nNormAngRads = GetN360(ePosX, ePosY, @Ray.angleNF2Rads) 'polar real; Normal angle to radius of a specific point on weld perimeter
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


SUB PlotProbe2(xPos AS DOUBLE, yPos AS DOUBLE, zPos AS DOUBLE, thetaStart AS DOUBLE, UDTptr1 AS DWORD, UDTptr2 AS DWORD)


    '/ transducer plots derived from motor x,y,z position only, associated plots are projected from motor position

    'zpos (rotational degreees), includes skew degree, if any.  To plot normal, subtract skew degrees from zpos degrees

    'xPos, yPos = center of Z-Axis Rotational, Transducer index must be aligned with center of rotation for proper operation


    LOCAL uSCN AS u_ScanVars POINTER
    LOCAL uGFX AS u_GFXvars POINTER

    LOCAL thetaRads, pSkewRads AS DOUBLE

    DIM x(1 TO 12) AS LOCAL DOUBLE
    DIM y(1 TO 12) AS LOCAL DOUBLE

    uSCN = UDTptr1

    uGFX = UDTptr2

    pSkewRads = DegToRads(@uSCN.ProbeSkew)

    '@uGFX.probeClr = %RGB_LIGHTYELLOW      'probe perimeter case color
    '@uGFX.probefillClr = %RGB_ORANGE       'probe fill color

    '@uGFX.TngtLineClr = %RGB_RED            'tangent line color for/if probe skew
    '@uGFX.NormLineClr = %RGB_RED            'normal line color for/if probe skew

    '@uGFX.CentLineClr = %RGB_WHITE          'probe center line color, probe beam
    '@uGFX.IdxLineClr = %RGB_WHITE           'probe index line color

    '@uGFX.offsetBallClr = %RGB_WHITE        'crosshair ball at offset color
    '@uGFX.probeBallClr = %RGB_BLACK         'crosshair ball at probe center color

    '@uGFX.ballRad = 0.200#                  'meatball radius

    GRAPHIC WIDTH 1&

    'Locate x & y position of the near and far sides of the transducer case.
    '***************************************************************************************************************************
    'user input: measured from center of cross hair, along 0-180 degree line, X
    thetaRads = (DegToRads(zPos) + thetaStart + Rads90) MOD Rads360 'Current transducer degree position (0-360)

    'Locate near side of transducer case width, at current scan degree position, projected from cross hair 0-180 line
    x(1) = xPos - @uSCN.ProbeWidth * half * COS(thetaRads)
    y(1) = yPos - @uSCN.ProbeWidth * half * SIN(thetaRads)

    'Locate far side of transducer case width, at current scan degree postion, projected from cross hair 0-180 line
    x(2) = xPos + @uSCN.ProbeWidth * half * COS(thetaRads)
    y(2) = yPos + @uSCN.ProbeWidth * half * SIN(thetaRads)


    'Locate x & y position of the (4) transducer case corners
    '***************************************************************************************************************************
    thetaRads = (DegToRads(zPos)+ thetaStart) MOD Rads360

    'Leftside, front probe corner, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(3) = x(1) - @uSCN.ProbeIdx * COS(thetaRads)
    y(3) = y(1) - @uSCN.ProbeIdx * SIN(thetaRads)

    'Rightside, front probe corner, along +/- 90 degrees from NORMAL axis,+ offset from projected x(2) & y(2)
    x(4) = x(2) - @uSCN.ProbeIdx * COS(thetaRads)
    y(4) = y(2) - @uSCN.ProbeIdx * SIN(thetaRads)

    'Leftside, back probe corner, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(5) = x(1) + (@uSCN.ProbeLen - @uSCN.ProbeIdx) * COS(thetaRads)
    y(5) = y(1) + (@uSCN.ProbeLen - @uSCN.ProbeIdx) * SIN(thetaRads)

    'Rightside, back probe corner, along +/-90 degrees from Normal axis,+offset projected from x(2) & y(2)
    x(6) = x(2) + (@uSCN.ProbeLen - @uSCN.ProbeIdx) * COS(thetaRads)
    y(6) = y(2) + (@uSCN.ProbeLen - @uSCN.ProbeIdx) * SIN(thetaRads)

    'Center of transducer case length
    x(8) = xPos + (@uSCN.ProbeLen * half - @uSCN.ProbeIdx) * COS(thetaRads)
    y(8) = yPos + (@uSCN.ProbeLen * half - @uSCN.ProbeIdx) * SIN(thetaRads)

    '********************************************************************************************************************
    GRAPHIC WIDTH 4& 'set line width to 2

    'draw transducer sides x4 (rectangle)
    GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@uGFX.probeClr  'draw probe side 1
    GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),@uGFX.probeClr  'draw probe side 2
    GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),@uGFX.probeClr  'draw probe side 3
    GRAPHIC LINE(y(4),x(4))-(y(6),x(6)),@uGFX.probeClr  'draw probe side 4

    GRAPHIC WIDTH 1& 'set line width back to 1


     'draw meatball on transducer case, located on center of UT beam origin
    x(11) = xPos - @uGFX.ballRad 'transducer x position
    y(11) = yPos - @uGFX.ballRad 'transducer y position
    x(12) = xPos + @uGFX.ballRad 'transducer x position
    y(12) = yPos + @uGFX.ballRad 'transducer y position
    GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @uGFX.probeClr


    'paint all (4) corners of the transducer case
    LOCAL seg1, seg2, ang1, pCOS, pSIN, nCOS, nSIN AS DOUBLE
    seg2 = GetSegLen((x(3)-x(8)),(y(3)-y(8)))
    seg1 =  seg2 - (gWIN.PixelR(1)*4)
    ang1 = ArcCos( (@uSCN.ProbeLen*half)/seg2 )
    pCOS = Seg1*COS(thetaRads+ang1) : pSIN = Seg1*SIN(thetaRads+ang1)
    nCOS = Seg1*COS(thetaRads-ang1) : nSIN = Seg1*SIN(thetaRads-ang1)
    GRAPHIC SET MIX %MIX_MERGESRC  'set color mix transparent with background
    y(3) = y(8) + pSIN : x(3) = x(8) + pCOS : GRAPHIC PAINT (y(3), x(3)), @uGFX.probefillClr, @uGFX.probeClr, 5
    y(3) = y(8) - pSIN : x(3) = x(8) - pCOS : GRAPHIC PAINT (y(3), x(3)), @uGFX.probefillClr, @uGFX.probeClr, 5
    y(3) = y(8) + nSIN : x(3) = x(8) + nCOS : GRAPHIC PAINT (y(3), x(3)), @uGFX.probefillClr, @uGFX.probeClr, 5
    y(3) = y(8) - nSIN : x(3) = x(8) - nCOS : GRAPHIC PAINT (y(3), x(3)), @uGFX.probefillClr, @uGFX.probeClr, 5
    GRAPHIC SET MIX %MIX_COPYSRC  'set color mix back to default mode  - draw over existing image pixels

     'paint inside the transducer case
    'GRAPHIC SET MIX %MIX_MERGESRC  'set color mix transparent with background
    'GRAPHIC PAINT (y(8), x(8)), @uGFX.probefillClr, @uGFX.probeClr, 5 '6 = fill (paint) with hatch lines
    'GRAPHIC SET MIX %MIX_COPYSRC  'set color mix back to default mode  - draw over existing image pixels

    '***********************************************************************************************************
    'Draw CrossHair lines in reference to Weld Axis
    '***********************************************************************************************************
    'beam intersection point on weld at current cross hair position
    thetaRads = (DegToRads(zPos)+ thetaStart) MOD Rads360
    x(7) = xPos - @uSCN.cProbeXOffset * COS(thetaRads)
    y(7) = yPos - @uSCN.cProbeXOffset * SIN(thetaRads)

    IF @uSCN.cProbeXOffset OR pSkewRads THEN

       thetaRads = (DegToRads(zPos)+ thetaStart - pSkewRads)  MOD Rads360     'normal, subtract skew
       IF pSkewRads THEN
          @uGFX.CentLine = y(7)/SIN(thetaRads) 'yPos/SIN(thetaRads)
       ELSE
          PRINT "!!!!!  ZERO THETA !!!!!!!!!"
          @uGFX.CentLine = MAX(ABS(xPos),ABS(yPos))
       END IF

       GRAPHIC STYLE 2  '0:Solid(default) 1:Dash 2:Dot 3:DashDot 4:DashDotDot
       x(12) = x(7) - @uGFX.CentLine * COS(thetaRads)  'fore x
       y(12) = y(7) - @uGFX.CentLine * SIN(thetaRads)  'fore y
       GRAPHIC LINE(y(7),x(7))-(y(12),x(12)), %RGB_HOTPINK '@uGFX.IdxLineClr 'Draw forward line only
       GRAPHIC STYLE 0


       '   'draw line through transducer, parallel to UT beam axis, - subtract transducer skew angle
       '   thetaRads = (DegToRads(zPos)+ thetaStart - pSkewRads)  MOD Rads360     'normal, subtract skew
       '   x(11) = x(7) + @uGFX.NormLine * COS(thetaRads) 'xPos2# 'get real xPos of current angle
       '   y(11) = y(7) + @uGFX.NormLine * SIN(thetaRads) 'yPos2# 'get real yPos of current angle
       '   x(12) = x(7) - @uGFX.NormLine * COS(thetaRads) 'get real xPos of current angle
       '   y(12) = y(7) - @uGFX.NormLine * SIN(thetaRads) 'get real yPos of current angle
       '   GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),%RGB_HOTPINK '@uGFX.NormLineClr



       IF @uSCN.cProbeXOffset THEN
          'draw meatball on weld at UT beam intercept point
          x(11) = x(7) - @uGFX.ballRad ' x position top
          y(11) = y(7) - @uGFX.ballRad ' y position left
          x(12) = x(7) + @uGFX.ballRad 'outer cross hair x position bottom
          y(12) = y(7) + @uGFX.ballRad 'outer cross hair y position right
          GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @uGFX.offsetBallClr
       END IF


    END IF

    '***********************************************************************************************************
    'Draw Crosshair lines in reference to UT Beam Axis. If no Skew or offset, weld and beam reference are same!
    '***********************************************************************************************************

    'GRAPHIC STYLE 2  '0:Solid(default) 1:Dash 2:Dot 3:DashDot 4:DashDotDot

    'draw line through transducer index, left and right, 90 degrees to UT beam axis
    thetaRads = (DegToRads(zPos) + thetaStart + Rads90) MOD Rads360  'normal angle +90 of weld X,Y position
    x(11) = xPos + @uGFX.IdxLine * COS(thetaRads) 'right side x
    y(11) = yPos + @uGFX.IdxLine * SIN(thetaRads) 'right side y
    x(12) = xPos - @uGFX.IdxLine * COS(thetaRads)'left side x
    y(12) = yPos - @uGFX.IdxLine * SIN(thetaRads)'left side y
   ' GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.CentLineClr

    'draw line through transducer centerline, fore and aft, parallel and aligned with UT Beam axis
    thetaRads = (DegToRads(zPos) + thetaStart) MOD Rads360 'normal angle +90 of weld X,Y position
    x(11) = xPos + @uGFX.CentLine * COS(thetaRads) 'aft x
    y(11) = yPos + @uGFX.CentLine * SIN(thetaRads) 'aft y
    x(12) = xPos - @uGFX.CentLine * COS(thetaRads) 'fore x
    y(12) = yPos - @uGFX.CentLine * SIN(thetaRads) 'fore y
    'GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.CentLineClr

    'aft only
    'GRAPHIC LINE(yPos,xPos)-(y(11),x(11)),@uGFX.CentLineClr
    'x(12) = xPos + xPos * COS(thetaRads)' + xPos  'fore x
    'y(12) = yPos + xPos * SIN(thetaRads)' + yPos  'fore y

    'x(12) = xPos + (yPos * SIN(thetaRads))   ' + xPos  'fore x
    'y(12) = 0   'yPos + (xPos * COS(thetaRads))* SIN(thetaRads) 'fore y       '0  'yPos - (xPos * COS(thetaRads)) * SIN(thetaRads)' + yPos  'fore y

    IF @uSCN.cProbeXOffset THEN
       GRAPHIC STYLE 2
       GRAPHIC LINE(yPos,xPos)-(y(7),x(7)),@uGFX.IdxLineClr 'Draw forward line only
       GRAPHIC STYLE 0
    ELSE
       IF thetaRads THEN 'insure no 'divide by zero error' occurs, non critical, for plotting only!
          @uGFX.CentLine = yPos/SIN(thetaRads)
       ELSE
          PRINT "!!!!!  ZERO THETA !!!!!!!!!"
          @uGFX.CentLine = MAX(ABS(xPos),ABS(yPos))
       END IF

       GRAPHIC STYLE 2  '0:Solid(default) 1:Dash 2:Dot 3:DashDot 4:DashDotDot
       'FORE draw line from transducer centerline, aligned with UT Beam axis
       'x(11) = xPos + @uGFX.CentLine * COS(thetaRads) 'aft x
       'y(11) = yPos + @uGFX.CentLine * SIN(thetaRads) 'aft y
       x(12) = xPos - @uGFX.CentLine * COS(thetaRads)  'fore x
       y(12) = yPos - @uGFX.CentLine * SIN(thetaRads)  'fore y

       GRAPHIC LINE(yPos,xPos)-(y(12),x(12)),@uGFX.IdxLineClr 'Draw forward line only
    END IF


    GRAPHIC STYLE 0
    IF @uSCN.cProbeXOffset THEN    '
        'GRAPHIC LINE(y(1),x(1))-(y(7),x(7)),@uGFX.IdxLineClr  '
        'GRAPHIC LINE(y(2),x(2))-(y(7),x(7)),@uGFX.IdxLineClr  '
        GRAPHIC LINE(y(1),x(1))-(y(2),x(2)),@uGFX.IdxLineClr  'index line across transducer width

    ELSE
        GRAPHIC LINE(y(1),x(1))-(y(12),x(12)),@uGFX.IdxLineClr  '
        GRAPHIC LINE(y(2),x(2))-(y(12),x(12)),@uGFX.IdxLineClr  '
        GRAPHIC LINE(y(1),x(1))-(y(2),x(2)),@uGFX.IdxLineClr  '
    END IF
    GRAPHIC STYLE 0

    'draw meatball on transducer case, located on center of UT beam origin
    x(11) = xPos - @uGFX.ballRad 'transducer x position
    y(11) = yPos - @uGFX.ballRad 'transducer y position
    x(12) = xPos + @uGFX.ballRad 'transducer x position
    y(12) = yPos + @uGFX.ballRad 'transducer y position
   ' GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)),%RGB_ORANGE '@uGFX.probeClr  ' %rgb_blue 'black '@uGFX.probeBallClr

     'paint inside the transducer case
    GRAPHIC SET MIX %MIX_MERGESRC  'set color mix transparent with background
   ' GRAPHIC PAINT (y(8), x(8)), @uGFX.probefillClr, @uGFX.probeClr, 6 '6 = fill (paint) with hatch lines
    'GRAPHIC PAINT (y(8), x(8)), @uGFX.probefillClr, @uGFX.probeClr, 6 '6 = fill (paint) with hatch lines
    GRAPHIC SET MIX %MIX_COPYSRC  'set color mix back to default mode  - draw over existing image pixels

END SUB


SUB PlotProbe(xPos AS DOUBLE, yPos AS DOUBLE, zPos AS DOUBLE, thetaStart AS DOUBLE, UDTptr1 AS DWORD, UDTptr2 AS DWORD)


    '/ transducer plots derived from motor x,y,z position only, associated plots are projected from motor position

    'zpos (rotational degreees), includes skew degree, if any.  To plot normal, subtract skew degrees from zpos degrees

    'xPos, yPos = center of Z-Axis Rotational, Transducer index must be aligned with center of rotation for proper operation


    LOCAL uSCN AS u_ScanVars POINTER
    LOCAL uGFX AS u_GFXvars POINTER

    LOCAL thetaRads, pSkewRads AS DOUBLE

    DIM x(1 TO 12) AS LOCAL DOUBLE
    DIM y(1 TO 12) AS LOCAL DOUBLE

    uSCN = UDTptr1

    uGFX = UDTptr2

    pSkewRads = DegToRads(@uSCN.ProbeSkew)

    '@uGFX.probeClr = %RGB_LIGHTYELLOW      'probe perimeter case color
    '@uGFX.probefillClr = %RGB_ORANGE       'probe fill color

    '@uGFX.TngtLineClr = %RGB_RED            'tangent line color for/if probe skew
    '@uGFX.NormLineClr = %RGB_RED            'normal line color for/if probe skew

    '@uGFX.CentLineClr = %RGB_WHITE          'probe center line color, probe beam
    '@uGFX.IdxLineClr = %RGB_WHITE           'probe index line color

    '@uGFX.offsetBallClr = %RGB_WHITE        'crosshair ball at offset color
    '@uGFX.probeBallClr = %RGB_BLACK         'crosshair ball at probe center color

    '@uGFX.ballRad = 0.200#                  'meatball radius

    GRAPHIC WIDTH 1&

    'Locate x & y position of the near and far sides of the transducer case.
    '***************************************************************************************************************************
    'user input: measured from center of cross hair, along 0-180 degree line, X
    thetaRads = (DegToRads(zPos) + thetaStart + Rads90) MOD Rads360 'Current transducer degree position (0-360)

    'Locate near side of transducer case width, at current scan degree position, projected from cross hair 0-180 line
    x(1) = xPos - @uSCN.ProbeWidth * half * COS(thetaRads)
    y(1) = yPos - @uSCN.ProbeWidth * half * SIN(thetaRads)

    'Locate far side of transducer case width, at current scan degree postion, projected from cross hair 0-180 line
    x(2) = xPos + @uSCN.ProbeWidth * half * COS(thetaRads)
    y(2) = yPos + @uSCN.ProbeWidth * half * SIN(thetaRads)


    'Locate x & y position of the (4) transducer case corners
    '***************************************************************************************************************************
    thetaRads = (DegToRads(zPos)+ thetaStart) MOD Rads360

    'Leftside, front probe corner, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(3) = x(1) - @uSCN.ProbeIdx * COS(thetaRads)
    y(3) = y(1) - @uSCN.ProbeIdx * SIN(thetaRads)

    'Rightside, front probe corner, along +/- 90 degrees from NORMAL axis,+ offset from projected x(2) & y(2)
    x(4) = x(2) - @uSCN.ProbeIdx * COS(thetaRads)
    y(4) = y(2) - @uSCN.ProbeIdx * SIN(thetaRads)

    'Leftside, back probe corner, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(5) = x(1) + (@uSCN.ProbeLen - @uSCN.ProbeIdx) * COS(thetaRads)
    y(5) = y(1) + (@uSCN.ProbeLen - @uSCN.ProbeIdx) * SIN(thetaRads)

    'Rightside, back probe corner, along +/-90 degrees from Normal axis,+offset projected from x(2) & y(2)
    x(6) = x(2) + (@uSCN.ProbeLen - @uSCN.ProbeIdx) * COS(thetaRads)
    y(6) = y(2) + (@uSCN.ProbeLen - @uSCN.ProbeIdx) * SIN(thetaRads)

    'Center of transducer case length
    x(8) = xPos + (@uSCN.ProbeLen * half - @uSCN.ProbeIdx) * COS(thetaRads)
    y(8) = yPos + (@uSCN.ProbeLen * half - @uSCN.ProbeIdx) * SIN(thetaRads)

    '********************************************************************************************************************
    GRAPHIC WIDTH 4& 'set line width to 2

    'draw transducer sides x4 (rectangle)
    GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@uGFX.probeClr  'draw probe side 1
    GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),@uGFX.probeClr  'draw probe side 2
    GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),@uGFX.probeClr  'draw probe side 3
    GRAPHIC LINE(y(4),x(4))-(y(6),x(6)),@uGFX.probeClr  'draw probe side 4

    'paint inside the transducer case
    GRAPHIC SET MIX %MIX_MERGESRC  'set color mix transparent with background
    GRAPHIC PAINT (y(8), x(8)), @uGFX.probefillClr, @uGFX.probeClr, 6 '6 = fill (paint) with hatch lines
    GRAPHIC SET MIX %MIX_COPYSRC  'set color mix back to default mode  - draw over existing image pixels

    GRAPHIC WIDTH 1& 'set line width back to 1

    '***********************************************************************************************************
    'Draw CrossHair lines in reference to Weld Axis
    '***********************************************************************************************************
    IF @uSCN.cProbeXOffset OR pSkewRads THEN

       'beam intersection point on weld at current cross hair position
       thetaRads = (DegToRads(zPos)+ thetaStart) MOD Rads360
       x(7) = xPos - @uSCN.cProbeXOffset * COS(thetaRads)
       y(7) = yPos - @uSCN.cProbeXOffset * SIN(thetaRads)

       'draw tangent line in reference to weld normal angle - subtract transducer skew angle
       thetaRads = (DegToRads(zPos)+ thetaStart + Rads90 - pSkewRads) MOD Rads360  'normal, subtract skew
       x(11) = x(7) + @uGFX.TngtLine * COS(thetaRads) ' + xPos2# 'get real xPos of current angle
       y(11) = y(7) + @uGFX.TngtLine * SIN(thetaRads) ' + yPos2# 'get real yPos of current angle
       x(12) = x(7) - @uGFX.TngtLine * COS(thetaRads) ' - xPos2# 'get real xPos of current angle
       y(12) = y(7) - @uGFX.TngtLine * SIN(thetaRads) ' - yPos2# 'get real yPos of current angle
       GRAPHIC LINE(y(11),x(11))-(y(12),x(12)), @uGFX.TngtLineClr

       'draw tangent line through weld, 90 degrees to UT beam axis, projected sideways - subtract transducer skew angle
       thetaRads = (DegToRads(zPos)+ thetaStart - pSkewRads)  MOD Rads360     'normal, subtract skew
       x(11) = x(7) + @uGFX.NormLine * COS(thetaRads) 'xPos2# 'get real xPos of current angle
       y(11) = y(7) + @uGFX.NormLine * SIN(thetaRads) 'yPos2# 'get real yPos of current angle
       x(12) = x(7) - @uGFX.NormLine * COS(thetaRads) 'get real xPos of current angle
       y(12) = y(7) - @uGFX.NormLine * SIN(thetaRads) 'get real yPos of current angle
       GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.NormLineClr

       'draw meatball on weld at UT beam intercept point
       x(11) = x(7) - @uGFX.ballRad ' x position top
       y(11) = y(7) - @uGFX.ballRad ' y position left
       x(12) = x(7) + @uGFX.ballRad 'outer cross hair x position bottom
       y(12) = y(7) + @uGFX.ballRad 'outer cross hair y position right
       GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @uGFX.offsetBallClr

    END IF

    '***********************************************************************************************************
    'Draw Crosshair lines in reference to UT Beam Axis. If no Skew or offset, weld and beam reference are same!
    '***********************************************************************************************************

    'draw line through transducer centerline, fore and aft, parallel and aligned with UT Beam axis
    thetaRads = (DegToRads(zPos) + thetaStart + Rads90) MOD Rads360  'normal angle +90 of weld X,Y position
    x(11) = xPos + @uGFX.CentLine * COS(thetaRads)'get real xPos of current angle
    y(11) = yPos + @uGFX.CentLine * SIN(thetaRads)'get real yPos of current angle
    x(12) = xPos - @uGFX.CentLine * COS(thetaRads)'get real xPos of current angle
    y(12) = yPos - @uGFX.CentLine * SIN(thetaRads)'get real yPos of current angle
    GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.CentLineClr

    'draw line through transducer index, left and right, 90 degrees to UT beam axis
    thetaRads = (DegToRads(zPos) + thetaStart) MOD Rads360 'normal angle +90 of weld X,Y position
    x(11) = xPos + @uGFX.IdxLine * COS(thetaRads) 'get real xPos of current angle
    y(11) = yPos + @uGFX.IdxLine * SIN(thetaRads) 'get real yPos of current angle
    x(12) = xPos - @uGFX.IdxLine * COS(thetaRads) 'get real xPos of current angle
    y(12) = yPos - @uGFX.IdxLine * SIN(thetaRads) 'get real yPos of current angle
    GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@uGFX.IdxLineClr

    'draw meatball on transducer case, located on center of UT beam origin
    x(11) = xPos - @uGFX.ballRad 'transducer x position
    y(11) = yPos - @uGFX.ballRad 'transducer y position
    x(12) = xPos + @uGFX.ballRad 'transducer x position
    y(12) = yPos + @uGFX.ballRad 'transducer y position
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

    LOCAL offset1,offset2,offset3,cosA,sinA,Weld_Haz,Weld_Width,thetaRads AS DOUBLE
    LOCAL index360 AS DOUBLE

    LOCAL index AS LONG

    DIM x(1 TO 8) AS LOCAL DOUBLE
    DIM y(1 TO 8) AS LOCAL DOUBLE

    'user set weld width and HAZ width
    Weld_Haz = @Ray.Weld_Haz         'width of HAZ (Heat Affected Zone) -  for plotting weld
    Weld_Width = @Ray.Weld_Width         'width of weld - for plotting weld

    IF  @Ray.i_xIndexEnd <=  @Ray.i_xIndex360 THEN
        'not full 360

    END IF

    '***********************************************************************************************************
    'Get and store radial scan line x & y endpoint plot location
    '***********************************************************************************************************
    FOR index = 0 TO @Ray.i_xIndexEnd

        thetaRads = @Ray.eNormAngRads(index)

        @Ray.sXpos(index) = (@Ray.Scan_Rad*COS(thetaRads))+@Ray.eXpos(index) 'get upper xPos: based on angle and stroke length
        @Ray.sYpos(index) = (@Ray.Scan_Rad*SIN(thetaRads))+@Ray.eYpos(index) 'get upper yPos: based on angle and stroke length

    NEXT


    '***********************************************************************************************************
    '  DRAW RADIAL SCAN LINES         note: add weld toe + transducer offset,index + stroke length
    '***********************************************************************************************************
    GRAPHIC WIDTH 1& 'line width

    'draw radial lines at normal angle to weld perimeter, chord spacing based upon user set index
    FOR index = @Ray.i_xIndexEnd TO 0 STEP -1 '0 TO nRay.i_xIndexEnd   'changed to step -1 to not overwrite different color scan start line

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

    thetaRads = @Ray.eNormAngRads(@Ray.i_xIndexEnd): cosA = COS(thetaRads): sinA = SIN(thetaRads)

    offset1 = (Weld_Haz*2.00#) + Weld_Width 'subtracted from outer HAZ edge
    x(2) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset1 * cosA)
    y(2) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset1 * sinA)

    offset2 = Weld_Haz + Weld_Width         'subtracted from outer HAZ edge
    x(4) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset2 * cosA)
    y(4) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset2 * sinA)

    offset3 = Weld_Haz                      'subtracted from outer HAZ edge
    x(6) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset3 * cosA)
    y(6) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset3 * sinA)

    x(8) = @Ray.eXpos(@Ray.i_xIndexEnd)
    y(8) = @Ray.eYpos(@Ray.i_xIndexEnd)


    FOR index = @Ray.i_xIndexEnd TO 0 STEP -1 'step -1 so not to overwrite inner start marker color

        thetaRads = @Ray.eNormAngRads(index) : cosA =  COS(thetaRads) : sinA =  SIN(thetaRads)

        ' draw Inner HAZ: normal lines and perimeter
        '************************************************************************************************************************
        x(1) = @Ray.eXpos(index)-(offset1 * cosA) : y(1) = @Ray.eYpos(index)-(offset1 * sinA)
        GRAPHIC LINE(0, @Ray.eOriginX(index))-(y(1), x(1)),@uGFX.eInsideClr 'draw normal angle line to inside HAZ
        GRAPHIC LINE(y(1),x(1))-(y(2),x(2)),@uGFX.eHAZPClr                  'draw perimeter chords around inside HAZ
        'GRAPHIC SET PIXEL (0, @Ray.eOriginX(index)),@uGFX.eExtraClr         'focal, point of origin, plotted along X axis major

        ' draw Inner weld: normal lines and perimeter
        '************************************************************************************************************************
        x(3) = @Ray.eXpos(index)-(offset2 * cosA) : y(3) = @Ray.eYpos(index)-(offset2 * sinA)
        GRAPHIC LINE(y(1),x(1))-(y(3),x(3)),@uGFX.eHAZClr   'draw normal angle line to inside weld line
        GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@uGFX.eWeldPClr 'draw perimeter chords around inside weld

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



SUB DrawScanModel2(BYVAL RayPtr AS DWORD, BYVAL uGFXptr AS DWORD)

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

    LOCAL offset1,offset2,offset3,cosA,sinA,Weld_Haz,Weld_Width,thetaRads AS DOUBLE
    LOCAL index360 AS DOUBLE

    LOCAL index AS LONG

    DIM x(1 TO 8) AS LOCAL DOUBLE
    DIM y(1 TO 8) AS LOCAL DOUBLE

    'user set weld width and HAZ width
    Weld_Haz = @Ray.Weld_Haz         'width of HAZ (Heat Affected Zone) -  for plotting weld
    Weld_Width = @Ray.Weld_Width         'width of weld - for plotting weld

    IF  @Ray.i_xIndexEnd <=  @Ray.i_xIndex360 THEN
        'not full 360

    END IF

    '***********************************************************************************************************
    'Get and store radial scan line x & y endpoint plot location
    '***********************************************************************************************************
    FOR index = 0 TO @Ray.i_xIndexEnd

        thetaRads = @Ray.eNormAngRads(index)

        @Ray.sXpos(index) = (@Ray.Scan_Rad*COS(thetaRads))+@Ray.eXpos(index) 'get upper xPos: based on angle and stroke length
        @Ray.sYpos(index) = (@Ray.Scan_Rad*SIN(thetaRads))+@Ray.eYpos(index) 'get upper yPos: based on angle and stroke length

    NEXT


    '***********************************************************************************************************
    '  DRAW RADIAL SCAN LINES         note: add weld toe + transducer offset,index + stroke length
    '***********************************************************************************************************
    GRAPHIC WIDTH 1& 'line width

    'draw radial lines at normal angle to weld perimeter, chord spacing based upon user set index
    FOR index = @Ray.i_xIndexEnd TO 0 STEP -1 '0 TO nRay.i_xIndexEnd   'changed to step -1 to not overwrite different color scan start line

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

    thetaRads = @Ray.eNormAngRads(@Ray.i_xIndexEnd): cosA = COS(thetaRads): sinA = SIN(thetaRads)

    offset1 = (Weld_Haz*2.00#) + Weld_Width 'subtracted from outer HAZ edge
    x(2) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset1 * cosA)
    y(2) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset1 * sinA)

    offset2 = Weld_Haz + Weld_Width         'subtracted from outer HAZ edge
    x(4) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset2 * cosA)
    y(4) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset2 * sinA)

    offset3 = Weld_Haz                      'subtracted from outer HAZ edge
    x(6) = @Ray.eXpos(@Ray.i_xIndexEnd)-(offset3 * cosA)
    y(6) = @Ray.eYpos(@Ray.i_xIndexEnd)-(offset3 * sinA)

    x(8) = @Ray.eXpos(@Ray.i_xIndexEnd)
    y(8) = @Ray.eYpos(@Ray.i_xIndexEnd)


    FOR index = @Ray.i_xIndexEnd TO 0 STEP -1 'step -1 so not to overwrite inner start marker color

        thetaRads = @Ray.eNormAngRads(index) : cosA =  COS(thetaRads) : sinA =  SIN(thetaRads)

        ' draw Inner HAZ: normal lines and perimeter
        '************************************************************************************************************************
        x(1) = @Ray.eXpos(index)-(offset1 * cosA) : y(1) = @Ray.eYpos(index)-(offset1 * sinA)
        GRAPHIC LINE(0, @Ray.eOriginX(index))-(y(1), x(1)),@uGFX.eInsideClr 'draw normal angle line to inside HAZ
        GRAPHIC LINE(y(1),x(1))-(y(2),x(2)),@uGFX.eHAZPClr                  'draw perimeter chords around inside HAZ
        'GRAPHIC SET PIXEL (0, @Ray.eOriginX(index)),@uGFX.eExtraClr         'focal, point of origin, plotted along X axis major

        ' draw Inner weld: normal lines and perimeter
        '************************************************************************************************************************
        x(3) = @Ray.eXpos(index)-(offset2 * cosA) : y(3) = @Ray.eYpos(index)-(offset2 * sinA)
        GRAPHIC LINE(y(1),x(1))-(y(3),x(3)),@uGFX.eHAZClr   'draw normal angle line to inside weld line
        GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@uGFX.eWeldPClr 'draw perimeter chords around inside weld

        ' draw Outer Weld: normal lines and perimeter
        '************************************************************************************************************************
        x(5) = @Ray.eXpos(index)-(offset3 * cosA) : y(5) = @Ray.eYpos(index)-(offset3 * sinA)
        GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),@uGFX.eWeldClr 'draw normal angle lines inside perimeter to outer weld
        GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),@uGFX.eWeldPClr 'draw outside perimeter around weld

        ' draw ellipse
        '************************************************************************************************************************
        x(7) = @Ray.eXpos(index) : y(7) = @Ray.eYpos(index)
        GRAPHIC LINE(y(7),x(7))-(y(8),x(8)),@uGFX.eHAZPClr 'draw chords around outside perimeter HAZ

        ' update old values to new values
        y(8) = y(7) : x(8) = x(7)

    NEXT



END SUB


SUB GetIndexChords(BYVAL RayPtr AS DWORD)

    'GRAPHIC PRINT " Chord Begin - Press any Key"
    'GRAPHIC REDRAW
    'GRAPHIC WAITKEY$

    LOCAL Ray AS FociRay POINTER
    Ray = RayPtr ' Set the pointer from the DWORD param

    LOCAL eXpos1,eYpos1,eXpos2,eYpos2,ArcIndex,DoneRatio,thetaInc,thetaRads,plength,arcSegment,nAccumErr AS DOUBLE

    LOCAL index, hfont, pflag, thetaflag AS LONG
    LOCAL x_index,DoneCtr1,DoneCtr2,PlotPoints AS LONG

    LOCAL cRad,x1,x2,y1,y2 AS SINGLE

    IF @Ray.majorAxis < @Ray.minorAxis THEN
       SWAP @Ray.majorAxis, @Ray.minorAxis
    END IF

    IF @Ray.majorAxis = @Ray.minorAxis THEN
       @Ray.majorAxis = @Ray.majorAxis + .001#
    END IF

    @Ray.majorAxisRad = @Ray.majorAxis * half
    @Ray.minorAxisRad = @Ray.minorAxis * half

    'Get the initial x and y position at starting position angle in RADIANS
    'NOTE: There are inherent problems with zero degree angles due to the inaccurracies of converting degrees to radians and vice-versa,
    'eXpos2 = @Ray.majorAxisRad*COS(@Ray.thetaRads) 'Pi and radian numbers are not accurate enough. For example:
    'eYpos2 = @Ray.minorAxisRad*SIN(@Ray.thetaRads) 'SIN(180) should = 0; but it does not!! instead = -7.61380975627945E-16

    IF @Ray.thetaS = 0 THEN
       eXpos2 = @Ray.majorAxisRad : eYpos2 = 0
    ELSEIF @Ray.thetaS = Rads90 THEN
       eXpos2 = 0 : eYpos2 = @Ray.minorAxisRad
    ELSEIF @Ray.thetaS = Rads180 THEN
       eXpos2 = -@Ray.majorAxisRad : eYpos2 = 0
    ELSEIF @Ray.thetaS = Rads270 THEN
       eXpos2 = 0 : eYpos2 = -@Ray.minorAxisRad
    ELSE
       eXpos2 = @Ray.majorAxisRad*COS(@Ray.thetaS) : eYpos2 = @Ray.minorAxisRad*SIN(@Ray.thetaS)
    END IF


    thetaInc = @Ray.thetaS         'set current degree increment to start angle

    @Ray.theta = @Ray.thetaS      'set current degree position to start angle

    'not used for ANYTHING IN THIS PROGRAM
    '@Ray.theta = @Ray.thetaS      'set current degree position to start angle
    '@Ray.thetaRads = @Ray.theta   'assign thetaRads to theta

    @Ray.theta360 = @Ray.thetaS + Rads360  '= degree position begin  + 360 degrees = 1 revolution around ellipse

    @Ray.theta405 = @Ray.theta360 + Rads45 '= (degree position begin + 360 degrees) + 45 degrees = 1.25 revolutions around ellipse

    @Ray.perimL = 0 'perimeter length

    arcSegment = 0  'arc segment length

    nAccumErr = 0   'error total acummulator, = accumulator + (target chord length - generated chord length)

    thetaflag = True 'set flag to perform check if theta >= 360 degrees
    pflag = True ' set flag to increment and capture outer weld HAZ perimeter
    plength = 0 ' reset to 0, captures length of outer weld HAZ perimeter incrementally

    'used to calculate percentage complete
    DoneRatio = 100.00#/(Rads360 + Rads45): DoneCtr1 = -1 'initilize to -1 so display starts at 0%

    arcIndex = @Ray.r_xIndexIncFixed 'set chord index

    x_Index = 0  'intialize loop counter

    PlotPoints = True

    DO

        IF PlotPoints THEN 'plot the index points

            'goto skipg
            'plot the chord in the current grahpic window
            x1 = eXpos2' * 3 :
            y1 = eYpos2' * 3
            cRad = @Ray.r_xIndexIncFixed * half ' * 3 * half ' '.10!

            INCR index
            IF pflag THEN ' not past 360 yet
                'GRAPHIC WIDTH 6
                IF index MOD 2 THEN
                    'GRAPHIC LINE(@Ray.eYpos(x_Index)*3, @Ray.eXpos(x_Index)*3)-(eYpos2*3,eXpos2*3), %RGB_YELLOW
                    GRAPHIC ELLIPSE(y1-cRad,x1-cRad)-(y1+cRad,x1+cRad), %RGB_YELLOW,-1&
                ELSE
                    'GRAPHIC LINE(@Ray.eYpos(x_Index)*3, @Ray.eXpos(x_Index)*3)-(eYpos2*3,eXpos2*3), %RGB_GREEN
                    GRAPHIC ELLIPSE(y1-cRad,x1-cRad)-(y1+cRad,x1+cRad), %RGB_GREEN,-1&
                END IF
            ELSE
                'GRAPHIC WIDTH 2
                'GRAPHIC LINE(@Ray.eYpos(x_Index)*3, @Ray.eXpos(x_Index)*3)-(eYpos2*3,eXpos2*3), %RGB_red
                GRAPHIC ELLIPSE(y1-cRad,x1-cRad)-(y1+cRad,x1+cRad), %RGB_RED ',-1&
            END IF

            'GRAPHIC set pixel(@Ray.eYpos(x_Index)*4, @Ray.eXpos(x_Index)*4), %RGB_blue 'yellow
            GRAPHIC REDRAW

        END IF


        'store the resulting x,y perimeter coordinates
        @Ray.eXpos(x_Index) = eXpos2        'cartesian real; X coordinate of this point along weld, is far side edge of weld HAZ.
        @Ray.eYpos(x_Index) = eYpos2        'cartesian real; Y coordinate of this point along weld, is far side edge of weld HAZ.

        plength = plength + arcSegment      'build the perimeter length, arc by arc
        @Ray.eArcSeg(x_Index) = arcSegment  'single arc segment length
        @Ray.eArcTotal(x_Index)= plength    'arc segment total length to THIS point


        'not needed or used at this time
        'eCtrAngle(n%) =  @Ray.thetaRads   'polar real; Angle 0-360: center of nozzle to each X,Y point along weld HAZ perimeter.

       ' print RadsToDeg(thetaRads); RadsToDeg(Get360(eXpos2,eYpos2,ATN(eYpos2/eXpos2)))
        'PRINT RadsToDeg(thetaRads); RadsToDeg(ATN(eYpos2/eXpos2))


        'Calculate percentage done - update screen if it has changed
        doneCtr2 = ROUND( ((thetaInc-@Ray.thetaS)*DoneRatio), 0 )
        IF DoneCtr2 <> DoneCtr1 THEN
           GRAPHIC SET POS (0,0): GRAPHIC PRINT "% DONE: " + STR$(doneCtr2)+ "       "
           GRAPHIC REDRAW
           DoneCtr1 = DoneCtr2
        END IF

        IF thetaflag AND (thetaInc => @Ray.theta360) THEN
        '   print "@Ray.thetaflag = False"
           thetaflag = False
           @Ray.i_xIndex360 = x_Index
           'PRINT "Index at 360 Degrees: "; @Ray.i_xIndex360
        END IF


        'added 45 degrees scan overlap
        IF thetaInc => @Ray.theta405 THEN
           @Ray.i_xIndex405 = x_Index  'at 405 degrees or more
           'PRINT "Index at 405 Degrees: "; @Ray.i_xIndex405
           EXIT DO  'exit loop: theta increment is => 405 degrees:
        END IF

        nAccumErr = plength - (@Ray.r_xIndexIncFixed * x_Index) 'error accumulator
        'arcIndex = @Ray.r_xIndexIncFixed - nAccumErr '*** uncomment for more accuracy, subtracts accumulated error from the target Index

        arcSegment = 0 'reset arcSegment to zero


        DO

           '*********** Use Brute Force method to get the desired arc segement length ************
           eXpos1 = eXpos2 : eYpos1 = eYpos2 'capture previous values

           thetaInc = thetaInc + 0.0000001#  'smaller increment = more accurate = more loops

           thetaRads = thetaInc MOD Rads360  'keep degrees in the 0 to 360 range

           eXpos2 = @Ray.majorAxisRad * COS(thetaRads) 'get xPos of current incremented angle
           eYpos2 = @Ray.minorAxisRad * SIN(thetaRads) 'get yPos of current incremented angle

           arcSegment = arcSegment + GetSegLen((eXpos2-eXpos1),(eYpos2-eYpos1))'arc segment length

           IF pflag AND (thetaInc => @Ray.theta360) THEN  'at or past a full +360 degree excursion
              pflag = False
              @Ray.perimL = plength + arcSegment  'store the weld HAZ perimeter final length
           END IF

        LOOP WHILE (arcSegment < arcIndex) AND (thetaInc < @Ray.theta405) '(nRay.thetaInc < nRay.theta360)


        IF x_Index < 1000 THEN  'increment loop counter
           INCR x_Index
        ELSE                'exit loop if n% = 1000, max array size
           EXIT DO
        END IF

    LOOP

    IF @Ray.i_xExtraIndx THEN 'overlap

       IF (@Ray.i_xIndex360 + @Ray.i_xExtraIndx) > @Ray.i_xIndex405 THEN
          @Ray.i_xIndexEnd = @Ray.i_xIndex405
       ELSE
          @Ray.i_xIndexEnd = @Ray.i_xIndex360 + @Ray.i_xExtraIndx
       END IF

    ELSE  ' no overlap!

       @Ray.i_xIndexEnd = @Ray.i_xIndex360

    END IF

    PRINT " @Ray.perimL: "; @Ray.perimL

    'FONT NEW "Times New Roman", 8, 1 TO hFont&
    'GRAPHIC SET FONT hFont&
    'graphic set font "Times New Roman", 12, 1
    GRAPHIC PRINT " Finished - Press any Key"
    GRAPHIC REDRAW
    GRAPHIC WAITKEY$

END SUB




SUB GetIndexRays(BYVAL RayPtr AS DWORD)


    LOCAL Ray AS FociRay POINTER
    Ray = RayPtr ' Set the pointer from the DWORD param

    LOCAL eXpos1,eYpos1,eXpos2,eYpos2,ArcIndex,DoneRatio AS DOUBLE
    LOCAL index,x_index,DoneCtr1,DoneCtr2 AS INTEGER


    'focal definition of the weld - get the length of the triangle sides
    @Ray.foci = SQR(SQ(@Ray.majorAxisRad)-SQ(@Ray.minorAxisRad)) 'leg distance of foci point measured from the center of the major axis
    @Ray.fociX2 = @Ray.foci*2                                    'length between the foci points, F1-F2 or Foci1-Foci2 (aSide)

    '----------------------------------------------------------------------------------------------------------------
    '          Based on incrementing angles, measured from the nozzle x,y, foci origin
    '          Specify major & minor radius, chord length index, start position in RADIANS
    '----------------------------------------------------------------------------------------------------------------

    '***********************************************************************************************************************
    '* user starting angle (@Ray.thetaS), based on a circles enter origin.                                                 *
    '* FOCI angle is based upon focal origin. Same X,Y coord'= slightly different FOCI angle as compared to circle angle.  *
    '* Convert user circle angle to corrected FOCI angle:                                                                  *
    eXpos2 = @Ray.eXpos(0)    'cartesian real; X coordinate of this point along weld, is far side edge of weld HAZ.        *
    eYpos2 = @Ray.eYpos(0)    'cartesian real; Y coordinate of this point along weld, is far side edge of weld HAZ.        *
    GetFoci(eXpos2, eYpos2, RayPtr)   'Get the FOCI                                                                        *
    @Ray.thetaS = @Ray.nNormAngRads   'Get the FOCI start                                                                  *
    '***********************************************************************************************************************

    @Ray.thetaInv = Rads360-@Ray.thetaS ' thetaS (theta start) + thetaInv = 360 degrees (in radians)

    'used to calculate percentage complete
    DoneRatio = 100.00#/ @Ray.i_xIndexEnd : DoneCtr1 = -1 'initilize to -1 so display starts at 0%


    FOR x_Index = 0 TO @Ray.i_xIndexEnd

        eXpos2 = @Ray.eXpos(x_Index)    'cartesian real; X coordinate of this point along weld, is far side edge of weld HAZ.
        eYpos2 = @Ray.eYpos(x_Index)    'cartesian real; Y coordinate of this point along weld, is far side edge of weld HAZ.

        GetFoci(eXpos2, eYpos2, RayPtr)

        '--------------------------------------------------------------------------------------------------------
        ' Store the resulting data
        '--------------------------------------------------------------------------------------------------------
        @Ray.eNormAngRads(x_Index) = @Ray.nNormAngRads  'actual Normal angle of chord at current azimuth, measured from X-Axis base to chord X,Y point
        @Ray.eRotAngRads(x_Index) = @Ray.nRotAngRads    'transducer rotational angle, ALWAYS begins at 0 degrees, irrespective of actual chord angle above

        @Ray.eOriginX(x_Index) = @Ray.nOriginX          'cartesian real; X offset to origin of the vector, Normal to a point on weld.
        @Ray.eRadiusNorm(x_Index) = @Ray.nRadiusNorm    'polar real; Vector magnitude, length of radius. Origin = (nRay.eOriginX,eNormYpos)
        @Ray.eNormAngNF2Rads(x_Index) =  @Ray.angleNF2Rads 'normal angle measured at X axis intersection on F2 side

        'not needed or used at this time
        'eCtrAngle(n%) =  @Ray.thetaRads   'polar real; Angle 0-360: center of nozzle to each X,Y point along weld HAZ perimeter.

        'Calculate percentage done - update screen if it has changed
        doneCtr2 = ROUND( (x_Index*DoneRatio), 0 )
        IF DoneCtr2 <> DoneCtr1 THEN
           GRAPHIC SET POS (0,0): GRAPHIC PRINT "% DONE: " + STR$(doneCtr2)+ "       "
           GRAPHIC REDRAW
           DoneCtr1 = DoneCtr2
        END IF


    NEXT


    @Ray.eRotAngRads(0) = 0  'Scan start angle always equals 0!



    '0915 Change
    '**************************************************************************************

    'GOTO Index180Mod

    '*************************************************************************************************************
    '  ADD INDEX OVERLAP, IF ANY
    '*************************************************************************************************************
    ' extra index increments: for nMax to end at zero (rare), the weld length must be evenly divisible by the index.
    ' if not evenly divisible then there will be an inherent partial index past 0 + i_xExtraIndx

    IF @Ray.i_xExtraIndx THEN

       FOR index = @Ray.i_xIndex360 TO @Ray.i_xIndexEnd  'start at +360 to take care of the inherent partial step past zero
           'if @Ray.eRotAngRads(index) < Rads45 then 'be sure since circle +360 vs elliptical +360 are not exactly the same azimuth
           @Ray.eRotAngRads(index) = @Ray.eRotAngRads(index) + Rads360  'ex: 360+2.88= 362.88 or if 0: 360+0  360
           'end if
       NEXT

       '@Ray.eRotAngRads(0) = 0

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


       '@Ray.i_xIndexEnd = (@Ray.i_xIndex360 * fourth + half) + @Ray.i_xExtraIndx

       '@Ray.eRotAngRads(0) = 0


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
       '@Ray.eRotAngRads(0) = 0

    END IF


END SUB



FUNCTION GenSegments (BYVAL RayPtr AS DWORD) AS LONG

    '**********************************************************************
    '  **** Generate Scan Path Segments for Axial UT Beam direction ****
    '**********************************************************************

    LOCAL Ray AS FociRay POINTER
    Ray = RayPtr

    LOCAL xPos1,xPos2,yPos1,yPos2,zPos1,zPos2,xImgPos1, xImgPos2, yImgPos1, yImgPos2, index AS DOUBLE
    LOCAL xIndexCtr, yIndexCtr, PathCtr, pathbufflen AS LONG 'Index and Path loop counter

    LOCAL xtheta AS DOUBLE ' transducer offset angle,  transducer is always +/- 90 degrees to ray scan lines for circ scans

    'scan start position: Scanner vs program
    'X_AXIS SIDE,scanner at 0   Degrees = 270 Degrees program
    '                       90  Degrees = 0   Degrees program
    '                       180 Degrees = 90  Degrees program
    '                       270 Degrees = 180 Degrees program

    xtheta = (@Ray.thetaS ) MOD Rads360  ' transducer offset angle,  transducer is always +/- 90 degrees to ray scan lines for circ scans

    @Ray.skewRads = DegToRads(@Ray.skewDegs)

    PRINT "@Ray.eRotAngRads(0): "; RadsToDeg(@Ray.eRotAngRads(0))
    WAITKEY$

    'NumOfSeg_G = 0  'tracks number of paths generated

    index# = 0         'current index


    'Scan start position
    xPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
    yPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
    zPos1# = RadsToDeg( (@Ray.eRotAngRads(0) + @Ray.skewRads) )
    'zPos1# = RadsToDeg(@Ray.eRotAngRads(0))

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
                GenSegments = PathCtr
                EXIT FUNCTION
             END IF

             'get path target position - stroke away from weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr) + (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta+ @Ray.skewRads))
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr) + xtheta+ @Ray.skewRads))
             zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr)+ @Ray.skewRads) )
             'zPos2# = RadsToDeg(@Ray.eRotAngRads(xIndexCtr))
             xImgPos2# = @Ray.eArcTotal(xIndexCtr)
             yImgPos2# = @Ray.r_yEnd  'yZeroOffset# + @uSCN.yStroke


             'capture the relative movement distance
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
                GenSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - index at stroke end
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)+ (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta+ @Ray.skewRads))
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yEnd) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr)+ xtheta+ @Ray.skewRads))
             zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr) + @Ray.skewRads) )
             'zPos2# = RadsToDeg(@Ray.eRotAngRads(xIndexCtr))
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
                GenSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - stroke to weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)+ (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta+ @Ray.skewRads))
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr) + xtheta+ @Ray.skewRads))
             zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr) + @Ray.skewRads) )
             'zPos2# = RadsToDeg(@Ray.eRotAngRads(xIndexCtr))
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
                GenSegments = (PathCtr-1)
                EXIT FUNCTION
             END IF

             'get path target position - index at weld
             xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr)+ (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr) + xtheta + @Ray.skewRads))
             yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr) + xtheta+ @Ray.skewRads))
             zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr) + @Ray.skewRads) )
             'zPos2# = RadsToDeg(@Ray.eRotAngRads(xIndexCtr))
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
        xPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0) + xtheta+ @Ray.skewRads))
        yPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0))+ (@Ray.xOffset * SIN(@Ray.eRotAngRads(0) + xtheta+ @Ray.skewRads))
        zPos1# = RadsToDeg( (@Ray.eRotAngRads(0) + @Ray.skewRads) )
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
                    GenSegments = (PathCtr-1)
                    EXIT FUNCTION
                END IF

                'get path target position - move away from weld
                xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr) + (@Ray.XOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta+ @Ray.skewRads))
                yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.XOffset * SIN(@Ray.eRotAngRads(xIndexCtr) + xtheta + @Ray.skewRads))
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

                'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr) 'segment length
                PRINT "xIndexCtr: "; xIndexCtr
                PRINT "RadsToDeg( @Ray.eRotAngRads(xIndexCtr) ): "; RadsToDeg( @Ray.eRotAngRads(xIndexCtr) )
                PRINT "@Ray.eRotAngRads(xIndexCtr): "; @Ray.eRotAngRads(xIndexCtr)
                'waitkey$

            NEXT

            'set to end position at current index
            xPos1# =  (@Ray.eRadiusNorm(@Ray.i_xIndexEnd) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + @Ray.eOriginX(@Ray.i_xIndexEnd) + (@Ray.XOffset * COS(@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ xtheta + @Ray.skewRads))
            yPos1# =  (@Ray.eRadiusNorm(@Ray.i_xIndexEnd) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + (@Ray.XOffset * SIN(@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ xtheta + @Ray.skewRads))
            zPos1# = RadsToDeg( (@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ @Ray.skewRads) )
            xImgPos1# = @Ray.eArcTotal(@Ray.i_xIndexEnd)
            yImgPos1# = @Ray.r_yBegin + index#

            index# = index# + @Ray.r_yIndexInc 'set to next index position

            INCR yIndexCtr

            IF yIndexCtr > @Ray.i_yIndexEnd THEN EXIT DO

            INCR PathCtr

            IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
               GenSegments = (PathCtr-1)
               EXIT FUNCTION
             END IF

            'set to end position at next index
            xPos2# =  (@Ray.eRadiusNorm(@Ray.i_xIndexEnd) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + @Ray.eOriginX(@Ray.i_xIndexEnd) + (@Ray.xOffset * COS(@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ xtheta+ @Ray.skewRads))
            yPos2# =  (@Ray.eRadiusNorm(@Ray.i_xIndexEnd) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(@Ray.i_xIndexEnd)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ xtheta+ @Ray.skewRads))
            zPos2# = RadsToDeg( (@Ray.eRotAngRads(@Ray.i_xIndexEnd)+ @Ray.skewRads) )
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
                   GenSegments = (PathCtr-1)
                   EXIT FUNCTION
                END IF

                'get path target position - index at weld
                xPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(xIndexCtr)) + @Ray.eOriginX(xIndexCtr) + (@Ray.xOffset * COS(@Ray.eRotAngRads(xIndexCtr)+ xtheta+ @Ray.skewRads))
                yPos2# =  (@Ray.eRadiusNorm(xIndexCtr) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(xIndexCtr)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(xIndexCtr)+ xtheta+ @Ray.skewRads))
                zPos2# = RadsToDeg( (@Ray.eRotAngRads(xIndexCtr)+ @Ray.skewRads) )
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
                'PRINT "Path Segment Length: "; PathCtr;xySegLn_G(PathCtr) 'segment length
                PRINT "xIndexCtr: "; xIndexCtr
                PRINT "RadsToDeg( @Ray.eRotAngRads(xIndexCtr) ): "; RadsToDeg( @Ray.eRotAngRads(xIndexCtr) )
                PRINT "@Ray.eRotAngRads(xIndexCtr): "; @Ray.eRotAngRads(xIndexCtr)
                'WAITKEY$

                NEXT

            'set to start position at current index
            xPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0)+ xtheta + @Ray.skewRads))
            yPos1# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(0))+ (@Ray.xOffset * SIN(@Ray.eRotAngRads(0)+ xtheta + @Ray.skewRads))
            zPos1# = RadsToDeg( (@Ray.eRotAngRads(0) + @Ray.skewRads) )
            xImgPos1# = @Ray.eArcTotal(0)
            yImgPos1# = @Ray.r_yBegin + index#

            index# = index# + @Ray.r_yIndexInc 'set index to next position

            INCR yIndexCtr

            IF yIndexCtr > @Ray.i_yIndexEnd THEN EXIT DO

            INCR PathCtr

            IF PathCtr > NumOfSeg_G THEN  'make sure we don't go past memory allocated and crash the computer
                GenSegments = (PathCtr-1)
                EXIT FUNCTION
            END IF

            'set to start postion at next index
            xPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin + index#) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0)+ xtheta + @Ray.skewRads))
            yPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin + index#) * SIN(@Ray.eNormAngRads(0))+ (@Ray.xOffset * SIN(@Ray.eRotAngRads(0)+ xtheta + @Ray.skewRads))
            zPos2# = RadsToDeg( (@Ray.eRotAngRads(0) + @Ray.skewRads) )
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

    GenSegments = (PathCtr-1)
    EXIT FUNCTION

END FUNCTION




FUNCTION RunScan(BYVAL RayPtr AS DWORD, BYVAL SCNPtr AS DWORD, BYVAL GFXPtr AS DWORD, BYVAL gWinPtrBitmap AS DWORD) AS LONG

        LOCAL Ray AS FociRay POINTER
        Ray = RayPtr

        LOCAL gWinBitMap AS LONG POINTER  'graphic window pointer - yikes!
        gWinBitMap = gWinPtrBitmap

        LOCAL xPos_Err,yPos_Err,zPos_Err,xImg_Err,yImg_Err,xCts,yCts,zCts,xImgCts,yImgCts AS DOUBLE
        LOCAL xCtsF,yCtsF,zCtsF,xImgCtsF,yImgCtsF,xPos2,yPos2,zPos2,xImgPos2,yImgPos2 AS DOUBLE
        LOCAL pathtime,xPosCtsR,yPosCtsR,zPosCtsR,xImgCtsR,yImgCtsR AS DOUBLE
        LOCAL x60Hz,y60Hz,z60Hz,xImg60Hz,yImg60Hz,T AS DOUBLE

        LOCAL xspeed, yspeed AS DOUBLE  'should always be the same for coord' motion

        LOCAL xPosCts2,yPosCts2,zPosCts2,xImgCts2,yImgCts2 AS LONG
        LOCAL lctr,pctr,n60HzSegments AS LONG

        LOCAL eXpos2#, eYpos2#,yPos1# 'testing to find lost position


        'newly added varibles for mouse click stuff
        '**********************************************************
        LOCAL mclick&, xmouse!, ymouse!

        LOCAL ypRatioL, ypRatioH, xpRatioL, xpRatioH AS DOUBLE

        LOCAL WidthVar!, HeightVar!

        LOCAL InkeyVar$

        LOCAL pIncR AS DOUBLE

        LOCAL MouseL, MouseM, MouseR, mRight, mMiddle, mLeft, btndown, K, hFg AS LONG
        LOCAL mLeftDN, mLeftUP, mLeftCK AS LONG
        LOCAL mRightDN, mRightUP, mRightCK AS LONG
        LOCAL mMiddleDN, mMiddleUP, mMiddleCK AS LONG

        LOCAL lpPoint AS POINTAPI     ' Pointer type defined in Win32Api

        MouseL = %VK_LBUTTON
        MouseM = %VK_MBUTTON
        MouseR = %VK_RBUTTON          ' Only those 3 are allowed


        pIncR = .0001#

        ypRatioL = 0.500# : ypRatioH = 0.500#  : xpRatioL = 0.500# : xpRatioH = 0.500#


        '*********************************************************************************

        DIM sTxt(16) AS LOCAL STRING

        LOCAL xtheta AS DOUBLE ' transducer offset

        'scan start position: Scanner vs program
        'X_AXIS SIDE,scanner at 0   Degrees = 270 Degrees program
        '                       90  Degrees = 0   Degrees program
        '                       180 Degrees = 90  Degrees program
        '                       270 Degrees = 180 Degrees program

        'CONST uTheta0 = Rads270   'user start degree translation
        'CONST uTheta90 = Rads0
        'CONST uTheta180 = Rads90
        'CONST uTheta270 = Rads180
        'nRay.thetaS = uTheta90 + Rads45

        'IF @Ray.thetaS = Rads270 THEN
        '    xtheta = Rads0
        'ELSEIF @Ray.thetaS = Rads0 THEN
        '    xtheta = Rads90
        'ELSEIF @Ray.thetaS = Rads90 THEN
        '    xtheta = Rads180
        'ELSEIF @Ray.thetaS = Rads180 THEN
        '    xtheta = Rads270
        'END IF

        'xtheta = Rads90 + Rads45

        @Ray.skewRads = DegToRads(@Ray.skewDegs)

        xtheta = (@Ray.thetaS ) MOD Rads360  ' transducer offset angle,  transducer is always +/- 90 degrees to ray scan lines for circ scans

        'Scan start position
        xPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
        yPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0)) + (@Ray.xOffset * SIN(@Ray.eRotAngRads(0) + xtheta + @Ray.skewRads))
        zPos2# = RadsToDeg( (@Ray.eRotAngRads(0)+ @Ray.skewRads) )
        'zPos2# = RadsToDeg( (@Ray.eRotAngRads(0) ) '+ @Ray.skewRads) )

        xImgPos2# = @Ray.eArcTotal(0)
        yImgPos2# = @Ray.r_yBegin


        GRAPHIC ATTACH gWIN.hWin(1), 0&, REDRAW                                  'Select bitmap window
        GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))
        GRAPHIC CLEAR
        DrawScanModel(RayPtr, GFXPtr) 'draw the model to bitmap screen
        GRAPHIC REDRAW

        GRAPHIC ATTACH gWIN.hWin(0), 0&, REDRAW                                  'Select standard window
        GRAPHIC COLOR gWIN.fClr(0), -2  'foreground& [, background&]
        GRAPHIC WINDOW STABILIZE gWIN.hWin(0)

        'make sure both bitmap and visible window scales match:
        gWIN.yMinR(0) = gWIN.yMinR(1): gWIN.yMaxR(0) = gWIN.yMaxR(1): gWIN.xMinR(0)= gWIN.xMinR(1): gWIN.xMaxR(0) = gWIN.xMaxR(1)
        GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))

        GRAPHIC COPY @gWinBitmap, 0&                    'copy static nozzle scan model to standard window
        PlotProbe2(xPos2#, yPos2#, zPos2#, @Ray.thetaS, SCNPtr, GFXPtr) 'Draw Transducer and features at current angle and position
        GRAPHIC REDRAW                              'Re-Draw the screen snappaly

        GRAPHIC SET FOCUS

        GRAPHIC WAITKEY$

        'clear any mouse clicks
        GRAPHIC WINDOW CLICK gWIN.hWin(0) TO mclick&, xmouse!, ymouse!

        xspeed# = 1.00#

        yspeed# = xSpeed#  'should always be the same for coord' motion

        'reset offset error counts to 0
        xPos_Err# = 0
        yPos_Err# = 0
        zPos_Err# = 0
        xImg_Err# = 0
        yImg_Err# = 0

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

        T = TIMER


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
                PRINT lctr&; NumOfSeg_G

                 WAITKEY$

            END IF

            n60HzSegments& = CLNG( (pathtime#*60.00#) + 0.51# )          ' number of path segments at 60 Hz

            'need to add a simple fixed accel/deccel rate !!!!!!!!!! out of time to implement this!!!

            x60Hz# = xMtrSeg_G(lCtr&)/n60HzSegments&
            y60Hz# = yMtrSeg_G(lCtr&)/n60HzSegments&
            z60Hz# = zMtrSeg_G(lCtr&)/n60HzSegments&

            xImg60Hz# = xImgSeg_G(lCtr&)/n60HzSegments&
            yImg60Hz# = yImgSeg_G(lCtr&)/n60HzSegments&



            FOR pctr& = 1 TO n60HzSegments&  ' each and every path segment will run for 1/60 second

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
                xPosCts2& = (xPosCtsR# + xPos_Err#) 'add rounding error back in
                yPosCts2& = (yPosCtsR# + yPos_Err#)
                zPosCts2& = (zPosCtsR# + zPos_Err#)
                xImgCts2& = (xImgCtsR# + xImg_Err#)
                yImgCts2& = (yImgCtsR# + yImg_Err#)

                'capture rounding error
                xPos_Err# = (xPosCtsR# + xPos_Err#) - xPosCts2&
                yPos_Err# = (yPosCtsR# + yPos_Err#) - yPosCts2&
                zPos_Err# = (zPosCtsR# + zPos_Err#) - zPosCts2&
                xImg_Err# = (xImgCtsR# + xImg_Err#) - xImgCts2&
                yImg_Err# = (yImgCtsR# + yImg_Err#) - yImgCts2&

                '******************************************************************************************************
                'get reals from counts for plotting purposes - these numbers used for graphic plots only
                xPos2# = xPos2# + (xPosCts2& * xCtsF#)
                yPos2# = yPos2# + (yPosCts2& * yCtsF#)
                zPos2# = zPos2# + (zPosCts2& * zCtsF#)
                xImgPos2# = xImgPos2# + (xImgCts2& * xImgCtsF#)
                yImgPos2# = yImgPos2# + (yImgCts2& * yImgCtsF#)
                '******************************************************************************************************

                GRAPHIC INKEY$ TO InkeyVar$

                IF LEN(InkeyVar$) THEN
                   'print InKeyVar$
                   IF InKeyVar$ = "+" THEN 'beep
                      xspeed# += 0.100#
                      IF xSpeed# > 12.000# THEN
                         xSpeed# = 12.000#
                      END IF
                      ySpeed# = xSpeed#  'should always be the same for coord' motion
                   ELSEIF InKeyVar$ = "-" THEN 'beep
                      xspeed# -= 0.100#
                      IF xSpeed# < 0.100# THEN
                         xSpeed# = 0.100#
                      END IF
                      ySpeed# = xSpeed#  'should always be the same for coord' motion
                   END IF
                END IF


                hFg = GetForegroundWindow() ' When switching to a PB GW, the handle gets 0 before returning hGW
                IF hFg = gWIN.hWin(0) THEN    'mouse pointer within  GW

                   'mLeftDN = BIT(GetAsyncKeyState(MouseL),15)
                   'mMiddleDN = bit(GetAsyncKeyState(MouseM),15)
                   'mRightDN = BIT(GetAsyncKeyState(MouseR),15)

                   'if mLeftDN or mMiddleDN or MRightDN then  'mouse down

                   GRAPHIC GET CLIENT TO WidthVar!, HeightVar!

                   WidthVar! -= 20! : HeightVar! -= 20!  'subtract for right and bottom slider height and width

                   GetCursorPos(lpPoint)    'Read cursor position
                   ScreenToClient(gWIN.hWin(0),lpPoint) ' Convert to relative cursor coordinates

                   IF (lpPoint.x > 0) AND (lpPoint.x < WidthVar!) AND (lpPoint.y > 0) AND (lpPoint.y < HeightVar!) THEN 'mouse pointer within canvas area

                        'Check status of left mouse button: up to down transition triggers one click
                        K = GetAsyncKeyState(MouseL)
                        btnDown =  BIT(K, 15)
                        IF btnDown THEN
                           IF mLeftUP THEN   'new click: button down now, was up before
                              mLeftUP = FALSE
                              mLeftCK = TRUE
                           END IF
                        ELSE                 'button is up: reset click trigger
                           mLeftUP = TRUE
                           mLeftCK = FALSE
                        END IF


                        'Check status of middle mouse button: down to up transition triggers one click
                        K = GetAsyncKeyState(MouseM)
                        btnDown =  BIT(K, 15)
                        IF btnDown THEN
                            mMiddleDN = TRUE    'button down, wait for up
                        ELSEIF mMiddleDN THEN   'button up from previous down
                            mMiddleDN = False
                            mMiddleCK = TRUE
                        ELSE
                        '   mMiddleDN = FALSE
                        '   mMiddleCK = TRUE
                        END IF

                        'Check status of right mouse button: button down = click, repeats while down
                        K = GetAsyncKeyState(MouseR)
                        btnDown =  BIT(K, 15)
                        IF btnDown THEN
                           mRightCK = TRUE
                        ELSE
                           'mRightUP  = FALSE
                           mRightCK = FALSE
                        END IF


                   ELSE  'Inside GW but outside of canvas area

                       mLeftCK = FALSE : mMiddleCK = FALSE : mRightCK = FALSE
                       mLeftUP = FALSE : mMiddleUP = FALSE : mRightUP = FALSE

                   END IF

                ELSE 'Outside of GW

                   mLeftCK = FALSE : mMiddleCK = FALSE : mRightCK = FALSE
                   mLeftUP = FALSE : mMiddleUP = FALSE : mRightUP = FALSE

                END IF


                IF mMiddleCK  THEN
                   mMiddleCK = FALSE
                   IF pIncR = (-.0001#) THEN
                      pIncR = (.0001#)
                   ELSE
                      pIncR = (-.0001#)
                   END IF
                END IF



                IF mLeftCK THEN    'left single click: change center of origin plot

                   mLeftCK = False

                   ymouse! = ((lpPoint.y * gWIN.PixelR(1))+ gWIN.xMinR(1))
                   xmouse! = ((lpPoint.x * gWIN.PixelR(1))+ gWIN.yMinR(1))

                   GRAPHIC GET VIEW TO WidthVar!, HeightVar!

                   'PRINT round(WidthVar!,4); Round(HeightVar!,4)
                   'print xmouse!; ymouse!

                   gWIN.yMinR(1) -= (xmouse! + WidthVar!)
                   gWIN.yMaxR(1) -= (xmouse! + WidthVar!)

                   gWIN.xMinR(1) -= (ymouse! + HeightVar!)
                   gWIN.xMaxR(1) -= (ymouse! + HeightVar!)

                   'GET CANVAS: current viewport has no effect on returned value. ex., GW=1800 pixels, scale=0.001, returns 1.8
                   'GRAPHIC GET CANVAS To WidthVar!, HeightVar!

                   'returns visible GW viewport in pixels.
                   'GET CLIENT: if viewport H&W=100%, returns VISIBLE size in pixels, if <100%: includes +17 for scrollbars.
                   'GRAPHIC GET CLIENT To WidthVar!, HeightVar!

                   'returns left-upper corner of screen viewport offset position in set scaled units
                   'GRAPHIC GET VIEW TO WidthVar!, HeightVar!


                   GRAPHIC ATTACH gWIN.hWin(1), 0&, REDRAW                                  'Select bitmap window
                   GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))
                   GRAPHIC CLEAR
                   DrawScanModel(RayPtr, GFXPtr) 'draw the model to bitmap screen
                   GRAPHIC REDRAW


                   'Update standard window to match bitmap

                   gWIN.yMinR(0) = gWIN.yMinR(1)
                   gWIN.yMaxR(0) = gWIN.yMaxR(1)

                   gWIN.xMinR(0) = gWIN.xMinR(1)
                   gWIN.xMaxR(0) = gWIN.xMaxR(1)

                   GRAPHIC ATTACH gWIN.hWin(0), 0&, REDRAW                                  'Select standard window
                   GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))

                   '******************************************************************************************************
                END IF


                IF mRightCK THEN   'right button click:  change window scale; maintain x,y zero location

                   mRightCK = FALSE

                   gWIN.PixelR(1) += pIncR
                   'PRINT gWIN.PixelR(1)

                   'keep scale within limits, = inches per pixel
                   IF gWIN.PixelR(1) <  0.001# THEN
                      gWIN.PixelR(1) = 0.001#
                   ELSEIF gWIN.PixelR(1) >  0.100# THEN
                      gWIN.PixelR(1) = 0.100#
                   END IF

                   'get current screen ratio of ymin" vs ymax" and xmin" vs xmax"
                   ypRatioH = ABS(gWIN.yMaxR(1))/(ABS(gWIN.yMinR(1))+ ABS(gWIN.yMaxR(1)))
                   ypRatioL = 1.00# - ypRatioH
                   xpRatioH = ABS(gWIN.xMaxR(1))/(ABS(gWIN.xMinR(1))+ ABS(gWIN.xMaxR(1)))
                   xpRatioL = 1.00# - xpRatioH

                   gWIN.yMaxR(1) = gWIN.yPixels(1)* gWIN.PixelR(1) * ypRatioH
                   gWIN.yMinR(1) = -(gWIN.yPixels(1)* gWIN.PixelR(1) * ypRatioL)
                   gWIN.xMaxR(1) = gWIN.xPixels(1) * gWIN.PixelR(1) * xpRatioH
                   gWIN.xMinR(1) = -(gWIN.xPixels(1) * gWIN.PixelR(1) * xpRatioL)


                   GRAPHIC ATTACH gWIN.hWin(1), 0&, REDRAW  'Select bitmap window
                   GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))
                   GRAPHIC CLEAR

                   DrawScanModel(RayPtr, GFXPtr) 'draw the model to bitmap screen
                   GRAPHIC REDRAW


                   'change visible window scale to match bitmap scale
                   gWIN.PixelR(0) = gWIN.PixelR(1)

                   gWIN.yMinR(0) = gWIN.yMinR(1)
                   gWIN.yMaxR(0) = gWIN.yMaxR(1)
                   gWIN.xMinR(0) = gWIN.xMinR(1)
                   gWIN.xMaxR(0) = gWIN.xMaxR(1)

                   GRAPHIC ATTACH gWIN.hWin(0), 0&, REDRAW                                  'Select standard window
                   GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))

                   '******************************************************************************************************

                END IF


                '*******************************************************************************************************************************
                '            BELOW FOR TESTING ONLY!!   TEST FINDING XYZ IN 3D Space from an Unknown location
                '*********************************************************************************************************************************

                LOCAL Radius#, Radius1#, Radius2#, NewMajorRad#, NewMinorRad#, OldOrigin#, eSQ#, rSQ#

                'angular position of transducer in reference to x,y centerline of nozzle
                @Ray.thetaRads = Get360(xPos2#,yPos2#,ATN(yPos2#/xPos2#))

                rSQ = ( SQ(@Ray.majorAxisRad)* SQ(@Ray.minorAxisRad) ) / ( (SQ(@Ray.majorAxisRad)*SQ(SIN(@Ray.thetaRads))) + (SQ(@Ray.minorAxisRad)*SQ(COS(@Ray.thetaRads))) )

                Radius1 = SQR(rSQ)
                Radius2 = GetSegLen(xPos2#,yPos2#)
                Radius = Radius2-Radius1

                eYpos2 = Radius1 * SIN(@Ray.thetaRads)
                eXpos2 = Radius1 * COS(@Ray.thetaRads)

                NewMajorRad = @Ray.majorAxisRad + Radius
                NewMinorRad = @Ray.minorAxisRad + Radius

                'store old
                @Ray.ftemp(0) = @Ray.majorAxis
                @Ray.ftemp(1) = @Ray.minorAxis
                @Ray.ftemp(2) = @Ray.majorAxisRad
                @Ray.ftemp(3) = @Ray.minorAxisRad
                @Ray.ftemp(4) = @Ray.foci
                @Ray.ftemp(5) = @Ray.fociX2

                'in with the new
                @Ray.majorAxisRad = NewMajorRad
                @Ray.minorAxisRad = NewMinorRad
                @Ray.majorAxis = @Ray.majorAxisRad * 2
                @Ray.minorAxis = @Ray.minorAxisRad * 2
                @Ray.foci = SQR(SQ(@Ray.majorAxisRad)-SQ(@Ray.minorAxisRad))
                @Ray.fociX2 = @Ray.foci*2

                'try to find foci coordinates
                GetFoci(xPos2#,yPos2#,Ray)

                'out with the new and in with the old
                @Ray.majorAxis = @Ray.ftemp(0)
                @Ray.minorAxis = @Ray.ftemp(1)
                @Ray.majorAxisRad = @Ray.ftemp(2)
                @Ray.minorAxisRad = @Ray.ftemp(3)
                @Ray.foci = @Ray.ftemp(4)
                @Ray.fociX2 = @Ray.ftemp(5)

                '*******************************************************************************************************************************
                '            ABOVE FOR TESTING ONLY!!   TEST FINDING XYZ IN 3D Space from an Unknown location
                '*******************************************************************************************************************************


SkipSome:

                 GRAPHIC COPY @gWinBitmap, 0&                                    'copy static nozzle scan model to standard window

                 PlotProbe2(xPos2#, yPos2#, zPos2#, @Ray.thetaS, SCNPtr, GFXPtr) 'Draw Transducer and features at current angle and position

                 GRAPHIC ELLIPSE (-NewMinorRad, -NewMajorRad  ) - (NewMinorRad , NewMajorRad ), %RGB_WHITE

                 'TEST results: draw line at our newly found location
                 'visually see how well it lines up with known coordiantes
                 GRAPHIC LINE(0,@Ray.nOriginX)-(yPos2#,xPos2#), %RGB_HOTPINK

                 GRAPHIC LINE(0,0)-(yPos2#,xPos2#), %RGB_MAGENTA

                 GRAPHIC LINE(eYpos2,eXpos2)-(yPos2#,xPos2#), %RGB_WHITE

                 sTxt(0)="Probe  X :"+ STR$(ROUND(xImgPos2#,4))
                 sTxt(1)="Probe  Y :"+ STR$(ROUND(yImgPos2#,4))
                 sTxt(2)="Motor  X :"+ STR$(ROUND(xPos2#,4))
                 sTxt(3)="Motor  Y :"+ STR$(ROUND(yPos2#,4))
                 sTxt(4)="Motor  Z :"+ STR$(ROUND(zPos2#,4))
                 'sTxt(5)="Motor  Z2:"+ STR$(ROUND(RadsToDeg(@Ray.nRotAngRads),4))
                 'sTxt(5)="Motor  Z2:"+ STR$(ROUND(RadsToDeg(@Ray.angleFiaRads),4))
                 sTxt(5)="Motor  Z2:"+ STR$(ROUND(RadsToDeg(@Ray.thetaRads),4))


                 sTxt(6)="Scan SPD :"+ STR$(ROUND(xSpeed#,4))

                 GRAPHIC CELL = 2, 2 :GRAPHIC PRINT sTxt(0)
                 GRAPHIC CELL = 3, 2 :GRAPHIC PRINT sTxt(1)

                 GRAPHIC CELL = 5, 2 :GRAPHIC PRINT sTxt(2)
                 GRAPHIC CELL = 6, 2 :GRAPHIC PRINT sTxt(3)
                 GRAPHIC CELL = 7, 2 :GRAPHIC PRINT sTxt(4)
                 GRAPHIC CELL = 8, 2 :GRAPHIC PRINT sTxt(5)

                 GRAPHIC CELL = 10, 2 :GRAPHIC PRINT sTxt(6)

                 GRAPHIC REDRAW                              'Re-Draw the screen snappaly

                 IF (yImgSeg_G(lCtr&)=0) AND (xImgSeg_G(lCtr&)<>0) THEN 'x index
                     'SLEEP 10
                 END IF

            NEXT

            SLEEP 10 '500
        NEXT

      PRINT "Time: " TIMER - T#

        '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


    'BEEP : GRAPHIC WAITKEY$

END FUNCTION


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

        xPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * COS(@Ray.eNormAngRads(0)) + @Ray.eOriginX(0) + (@Ray.xOffset * COS(@Ray.eRotAngRads(0) + @Ray.skewRads))
        yPos2# = (@Ray.eRadiusNorm(0) + @Ray.r_yBegin) * SIN(@Ray.eNormAngRads(0))+ (@Ray.xOffset * SIN(@Ray.eRotAngRads(0) + @Ray.skewRads))
        zPos2# = RadsToDeg( (@Ray.eRotAngRads(0)+ @Ray.skewRads) )
        xImgPos2# = @Ray.eArcTotal(0)
        yImgPos2# = @Ray.r_yBegin

        xspeed# = 1.00#   'should always be the same for coord' motion
        yspeed# = xspeed#

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

                'PRINT "shouldn't be here"
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
