'===========================================================================================
'
' Milestone program: has flipped +/- path for opposite far track mount,
' or, reversed +/- min-max graphics screen scale
'===========================================================================================


'====================================================================
'
'Last File Name: NozzleScanPlan_Module_A_TEST_RUN_9_A_L_5_C_6.bas
'Started new name:    nModule.bas
'====================================================================
#OPTIMIZE CODE ON
#OPTIMIZE SPEED
#COMPILER PBCC 6
'#CONSOLE OFF
#DIM ALL
#INCLUDE "win32api.inc"
#INCLUDE "COMDLG32.INC"

'MACRO Pi = 3.141592653589793##
'MACRO DegToRdn(dpDegrees) = (dpDegrees*0.0174532925199433##)
'MACRO RdnToDeg(dpRadians) = (dpRadians*57.29577951308232##)

MACRO Pi  = 3.141592653589793#  '15 decimal places
MACRO Pi2 = 3.141592653589793# * 2.00#
MACRO PiHalf = 3.141592653589793# * 0.500#

MACRO DegToRdn(dpDegrees) = (dpDegrees*(Pi/180.00#))
MACRO RdnToDeg(dpRadians) = (dpRadians*(180.00#/Pi))

MACRO DegToRdn2(dpDegrees) = (dpDegrees * 00.0174532925199433#) '16 decimal places
MACRO RdnToDeg2(dpRadians) = (dpRadians * 57.29577951308232#)  '14 decimal places

'MACRO RAD = 4.00 * ATN(1.00) / 180.00 'found on PB forum, haven't tested it

'MACRO Pi =  3.1415926535897932384626433832795#
'MACRO Pi =  3.14159265358979323846#
'MACRO DegToRdn(dpDegrees) = (dpDegrees*0.01745329251994329576923690768489#) '0.0174532925199433#)
'MACRO RdnToDeg(dpRadians) = (dpRadians*57.295779513082320876798154814105#)

MACRO ArcCos(CosA) = ( Pi / 2 - ATN(CosA / SQR(1 - CosA * CosA)) )  'ArcCos in radians
MACRO ArcCosA(CosA) = ( ArcCos(CosA)*(180.00#/Pi)) '* 57.295779513082320876798154814105#)'ArcCos in degrees

MACRO ArcSin(SinA) = ATN(SinA / SQR(1 - SinA * SinA))'ArcSin in radians
MACRO ArcSinA(SinA) = ( ArcSin(SinA)*(180.00#/Pi)) '* 57.295779513082320876798154814105#)'ArcSin in degrees'

'Macro's to square a number, because PBCC doesn't like the use of ^caret in all cases
MACRO SQ(SquareIt) = (SquareIt^2)   '(SquareIt*SquareIt)
MACRO SQx3(SquareIt) = (SquareIt^3) '*SquareIt*SquareIt)
MACRO SQx4(SquareIt) = (SquareIt^4) '*SquareIt*SquareIt*SquareIt)
MACRO SQx6(SquareIt) = (SquareIt^6) '*SquareIt*SquareIt*SquareIt*SquareIt*SquareIt)

MACRO CONST = MACRO
CONST Rdn0 = (0.000#)
CONST Rdn9 = (Pi*0.050#)
CONST Rdn22p5 = (Pi*0.125#)
CONST Rdn45 = (Pi*0.250#)
CONST Rdn90 = (Pi*0.500#)
CONST Rdn135 = (Pi*0.750#)
CONST Rdn180 = (Pi)
CONST Rdn225 = (Pi*1.250#)
CONST Rdn270 = (Pi*1.500#)
CONST Rdn315 = (Pi*1.750#)
CONST Rdn360 = (Pi*2.000#)
CONST Rdn540 = (Pi*3.000#)


'CONST Rdn0inv = Rdn360    'for Scan begin, Rdn0inv + Rdn360 = 360 degrees, with MOD360 equals 0 degrees
'CONST Rdn90inv = Rdn270   ' "
'CONST Rdn180inv = Rdn180  ' "
'CONST Rdn270inv = Rdn90   ' "


'const uTheta0 = Rdn270   'user start degree translation
'CONST uTheta90 = Rdn0
'CONST uTheta180 = Rdn90
'CONST uTheta270 = Rdn180


CONST DegRatio = (1.00#/360.00#)
CONST RdnRatio =(1.00#/(Pi*2.00#))
CONST Half = (0.500#)
CONST Fourth = (0.250#)
CONST OOO1 = (0.000100#)

CONST TRUE = (-1)
CONST FALSE = (NOT -1)

CONST Mil = 1000000

CONST xG = 0
CONST yG = 1
CONST zG = 2
CONST cG = 3
CONST aG = 4

'********************************************************************************************************************************
' Types
'********************************************************************************************************************************

TYPE FociRay

     majorRad AS DOUBLE 'define the nozzle weld shape ellipse
     minorRad AS DOUBLE
     majorDia AS DOUBLE
     minorDia AS DOUBLE

     foci AS DOUBLE    'leg distance of foci point measured from the center of the majorDia axis
     foci2 AS DOUBLE   'length between the foci points, F1-F2 or Foci1-Foci2 (aSide)

     fXpos1 AS DOUBLE  'current chord point x" location measured from Foci1
     fYpos1 AS DOUBLE  'current chord point y" location measured from nozzle centerline
     fXpos2 AS DOUBLE  'current chord point x" position measured from Foci2
     fYpos2 AS DOUBLE  'current chord point y" position measured from Foci2
     f1Rad AS DOUBLE   'F1 Rad length(bSide)
     f2Rad AS DOUBLE   'F2 Rad length(cSide)
     f1Rdn AS DOUBLE  'Rad1 angle, measured from foci 1 {cos C = (a^2 + b^2 - c^2)/2ab}
     f2Rdn AS DOUBLE  'Rad2 angle, measured from foci 2 {cos B = (c^2 + a^2 - b^2)/2ca}
     fiaRdn AS DOUBLE 'included angle, between Rad1 and Rad2  {cos A = (b^2 + c^2 - a^2)/2bc}

     nFiaRdn AS DOUBLE 'normal angle equals one-half the included angle between f1Rad and f2Rad
     nF1Rad AS DOUBLE   'length of tangent line measured from chord X,Y position to X axis line
     nF2Rad AS DOUBLE   'length of tangent line measured from chord X,Y position to X axis line
     nF1Rdn AS DOUBLE  'normal angle measured at X axis intersection on F1 side
     nF2Rdn AS DOUBLE  'normal angle measured at X axis intersection on F2 side
     nF1x AS DOUBLE     'distance from F1 to tangent line intersection along X axis
     nF2x AS DOUBLE     'distance from F2 to tangent line intersection along X axis

     nOriginX AS DOUBLE  'cartesian real; X offset to origin of the vector, Normal to a point on the weld.
     nNormRdn AS DOUBLE 'normal angle of x,y point: measured from X-Axis base to x,y point
     nNormRad AS DOUBLE  'polar real; Vector magnitude, length of Rad. Origin = (nRay.eOriginX,eNormYpos)
     nRotDeg AS DOUBLE  'rotational angle, 0 to 360 degrees translation

     oRdn  AS DOUBLE       'start angle radians
     oDeg  AS DOUBLE       'user set scan start angle position
     oFociDeg AS DOUBLE    'Foci angle Deg at user set start angle position, = thetaS if 0,90,180 or 270
     oFociRdn  AS DOUBLE   'Foci angle Rdn at user set start angle position, = thetaS if 0,90,180 or 270
     oFociRdnInv AS DOUBLE 'start angle radians inverse

    skewDeg AS DOUBLE
    skewRdn AS DOUBLE
    plus405Rdn AS DOUBLE    'overlap = nRay.plus360Rdn + Rdn45  'always add 45 degrees overlap
    plus360Rdn AS DOUBLE    'end angle
    circ360 AS DOUBLE       'measured circ along outermost exam volume
    circ360e AS DOUBLE      'estimated circ along outermost exam volume
    Index360 AS LONG        'number of indexes to reach 360 degrees
    Index405 AS LONG        'number of indexes to reach 405 degrees
    Index AS DOUBLE         'index spatial resolution
    IndexCW AS LONG         'flag for clockwise or CCW scan; CW goes 360 to 0, CCW goes 0 to 360.
    Index0 AS LONG        'flag to use reference zero or circumference as starting point

    'theta360 as double

END TYPE

'GLOBAL nRay AS FociRay



'NEW - added 7/9/15
TYPE ScanVars        'Thoughts 06/20/16: Save to a file so user can retrieve and store probe setups on disk
    'user enters these  directly

     i_xIndexBegin AS LONG'not used   'number of X-indexes to begin index
     xIndexEnd AS LONG          'number of X-indexes to last index

     yIndexBegin AS LONG 'not used  'Integer: number of Y-Indexes to begin index
     yIndexes AS LONG     'Integer: number of Y-Indexes to last index

     i_xIndexBegin_U AS LONG'not used 'number of X-indexes to begin index
     i_xIndexEnd_U AS LONG'not used   'number of X-indexes to user set max index, has no impact on Model, ends X-index'ing

     yBegin AS DOUBLE       'Real: Y-Axis Begin
     yEnd AS DOUBLE         'Real: Y-Axis End
     yIndexInc AS DOUBLE    'Real: Y-Index increment for circ raster, ax or circ beam

     xBegin AS DOUBLE 'not used 'Real: X-Axis Begin  '******** could be implemented based on perimeter measurements
     xEnd AS DOUBLE   'not used 'Real: X-Axis End    '******** could be used for extra indexes
     xIndexInc AS DOUBLE    'Real X-Index Increment set by user, fixed unless model is ran again

     xIndexPlus AS LONG      'number of added Indexes for overlap

     skewOffset AS DOUBLE   'skew-offset surface distance from index to beam at ID
     skewRdn AS DOUBLE     'skew angle of probe in Rdn
     SkewDeg AS DOUBLE     'skew angle of probe in degrees
     'skewDir AS LONG       'skew direction, +/-, beam pointing from either negative or positive side of zero

     WeldHaz AS DOUBLE     'width of HAZ "Heat Affected Zone" - for plotting scan model
     WeldWidth AS DOUBLE   'width of weld -                     for plotting scan model
     yRadius AS DOUBLE     'set length of nozzle scan lines     for plotting scan model

     AxialRaster AS LONG    'true or false: False = raster in circ direction, True = raster in axial direction
     AxialBeam AS LONG      'true or false: False = circ beam, True = axial beam

     yIdxNeg AS LONG       'FLAG: TRUE or FALSE: FALSE = Y index start = yBegin, TRUE = Y index start = yEnd

     xNear AS LONG          'FLAG: TRUE or FALSE: FALSE = X axis on far side of nozzle, FALSE = X on near side

     MtrsRev AS LONG        'FLAG: TRUE or FALSE: FALSE = Mtrs are as is, FALSE = Mtrs are reversed: + = - and - = +

     'yStroke AS DOUBLE
     'setIndex AS DOUBLE
     'aProbeLen AS DOUBLE '= 2.200# 'transducer length
     'aProbeIdx  AS DOUBLE ' .800#   '1.00# '0.800# 'transducer index position, measured setback from front
     'aProbeWidth AS DOUBLE '= 2.600# 'transducer width

     ProbeWidth AS DOUBLE
     ProbeIdx AS DOUBLE 'set to (-) 'transducer index position, measured setback from front
     ProbeLen AS DOUBLE

END TYPE

'GLOBAL Scan AS u_ScanVars

TYPE GfxVars

     IdxLine AS DOUBLE     'set length/2 of projected index line along probe width axis, total line length drawn = x2
     CentLine AS DOUBLE    'set length/2 of projected center line along probe length axis, total line length drawn = x2
     ballRad  AS DOUBLE    'meatball Rad

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

'GLOBAL GFX AS GfxVars

TYPE QuarticRay     'quartic, cubic solver for finding focus in 3D space about the ellipse

     x1 AS DOUBLE
     x2 AS DOUBLE
     x3 AS DOUBLE
     x4 AS DOUBLE

     y1 AS DOUBLE
     y2 AS DOUBLE
     y3 AS DOUBLE
     y4 AS DOUBLE

END TYPE

'GLOBAL qRay AS QuarticRay


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
    xPix(10) AS LONG
    yPix(10) AS LONG
    fClr(10) AS LONG
    bClr(10) AS LONG
    xNear AS LONG

END TYPE

TYPE WAVEheader

    rID AS STRING*4   ' Contains the characters "RIFF"
    rLen AS LONG      ' The length of the data in the next chunk
    wID AS STRING*4   ' Contains the characters "WAVE"
    fId AS STRING*4   ' Contains the characters "fmt "
    fLen AS LONG      ' Length of data in the format chunk
    wFormatTag AS INTEGER  ' specifies the wave format, eg 1 = Pulse Code Modulation
                           '(or in plain english, regular 8 bit sampled uncompressed sound)
    nChannels  AS INTEGER  ' Number of channels, 1=mono, 2=stereo
    nSamplesPerSec AS LONG ' Playback frequency
    nAvgBytesPerSec AS LONG' Indicates the average number of bytes a second the data should be
                           ' transferred at = nChannels * nSamplesPerSec * (nBitsPerSample / 8)
    nBlockAlign AS INTEGER ' Indicates the block alignment of the data in the data chunk. Software
                           ' needs to process a multiplt of nBlockAlign at a time.
                           ' nBlockAlign = nChannels * (nBitsPerSample / 8)
    wBitsPerSample AS INTEGER ' Format specific data area
    dId AS STRING*4 ' Contains the characters "data"
    dLen AS LONG    ' Length of data in the dData field

END TYPE
'GLOBAL w AS waveheader

TYPE onesecwav

     wv AS waveheader
     dta AS ASCIIZ * 88200   '44100   '22050
     ' dta AS ASCIIZ *30050

END TYPE
'GLOBAL ww AS onesecwav

TYPE TestOne
    t1 AS DOUBLE
    t2 AS DOUBLE
    t3 AS DOUBLE
    t4 AS DOUBLE
END TYPE


'TYPE focal
'
'   eXpos AS DOUBLE
'   eYpos AS DOUBLE
'   eArc  AS DOUBLE
'   eOriginX AS DOUBLE
'   eNormRdn AS DOUBLE
'   eNormRad AS DOUBLE
'   eRotRdn AS DOUBLE

'END TYPE

'   eNormRdn(100)
'   foci(100).eXps
''   foci(eYps,0)
'   foci(eArc,0)
'   foci(eOrgn,0)
'   foci(eNrdn,0)
'   foci(eNrad,0)
'   foci(eRrdn,0)

FUNCTION PBMAIN

    DIM test() AS TestOne

    DIM dCtr AS GLOBAL LONG

    DIM gError(10)  AS GLOBAL DOUBLE

    DIM PBhand AS GLOBAL DWORD

    DIM eNull AS GLOBAL DWORD

    PBhand = GetModuleHandle(BYVAL %NULL)

    'NEW mouse Cursor
    DIM AndArray(1 TO 128) AS GLOBAL BYTE
    DIM XorArray(1 TO 128) AS GLOBAL BYTE
    DIM hCursor AS GLOBAL DWORD
    DIM hCursorCopy AS GLOBAL DWORD

    'graphic windows
    DIM gWIN AS GLOBAL gScreen

    DIM gFont(30) AS GLOBAL LONG
    GLOBAL FontNum AS LONG 'current font

    'play sound routine
    GLOBAL w AS waveheader, ww AS onesecwav

    'storage memory for mathamatical model generation and scan paths
    GLOBAL nPath, nIndex AS LONG
    GLOBAL PathX(),PathY(),PathZ(),PathC(),PathA(),eXpos(),eYpos(),eArc(),eOriginX(),eNormRdn(),eNormRad(),eRotDeg() AS DOUBLE
    DIM nRay AS FociRay, qRay AS QuarticRay, GFX AS GfxVars, nScan AS ScanVars

    DIM testvar(20) AS GLOBAL DOUBLE


    '****************************************************************************************
    'BEGIN: added 10/4/15: nozzle parameters for prototyping new features
    '****************************************************************************************

    'pipe/nozzle/branch connection configuration
    'LOCAL PipeOD, PipeID, PipeOR, BranchOD, BranchID, PipeChord, PipeChordAngle, PipeChordArc AS DOUBLE

    'weld dimensions
    'LOCAL InnerHazDia, OuterHazDia, InnerWeldDia, OuterWeldDia AS DOUBLE

    'axial scan parameters
    'LOCAL AxialInnerScanDia, AxialOuterScanDia, AxialScanStroke, AxialScanIndex, AxialOffset, AxialSkew  AS DOUBLE

    'circ scan parameters
    'LOCAL CircInnerScanDia, CircOuterScanDia, CircScanStroke, CircScanIndex, CircOffset, CircSkew AS DOUBLE

    LOCAL numOfpaths, numOfindexes, n60HzSegs,nIndex2,lctr AS LONG
    LOCAL H, Hs, Ha, T, index AS DOUBLE
    'PipeOD = 35.00#

    'PipeOR = 18.00#

    'PipeChordAngle = 2.00# * ArcSin(nRay.minorDia/PipeOD)

    'user set colors for model
    GFX.eStartClr= %RGB_LIMEGREEN 'scan start; outer radial line color
    GFX.eEndClr= %RGB_YELLOW      'scan end; outer radial line color
    GFX.eExtraClr= %RGB_MAGENTA   'scan extra; outer radial line color
    GFX.eRadialClr= %RGB_BLUE     'all other; outer scan radial scan line
    GFX.eInsideClr= %RGB_BLUE     'center inside; radial line line color
    GFX.eOutPClr= %RGB_BLUE       'outer perimeter; line color
    GFX.eWeldClr= %RGB_GREEN      'weld; radial line color
    GFX.eWeldPClr= %RGB_GREEN     'weld; perimeter line color
    GFX.eHAZClr= %RGB_RED         'HAZ; radial line color
    GFX.eHAZPClr= %RGB_RED        'HAZ; perimeter line color


    'User set plotting colors
    GFX.probeClr= %RGB_GOLD       'probe perimeter case color
    GFX.probefillClr= %RGB_ORANGE 'probe fill color
    GFX.TngtLineClr= %RGB_MAGENTA 'weld tangent line color
    GFX.NormLineClr= %RGB_MAGENTA 'weld normal line color
    GFX.CentLineClr= %RGB_GOLD    'probe center line color, probe beam
    GFX.IdxLineClr= %RGB_GOLD     'probe index line color
    GFX.offsetBallClr= %RGB_WHITE 'ball at offset color
    GFX.probeBallClr= %RGB_WHITE  'ball at probe center color
    GFX.ballRad= 0.050#           'meatball Rad

    'not set here - set dynamically in plot routine
    'user set crosshair line length Rad in inches
    ' GFX.CentLine = 5' USED !!  10 ' 1 ' 10
    ' GFX.IdxLine = 5  'NOT USED !!  '10 '1 '10
    ' GFX.TngtLine = 5 'NOT USED 10 ' 5' 10
    ' GFX.NormLine = 5 'NOT USED '10 '5' 10     @Ray.nOriginX  = @Ray.majorRad-((@Ray.minorRad^2) / @Ray.majorRad)


    '------------------------------------------------------------------------------------------------------------
    ' Setup raster scan parameters
    '------------------------------------------------------------------------------------------------------------
        nScan.AxialBeam = TRUE

        'nScan.AxialBeam = FALSE

        IF nScan.AxialBeam THEN  'SET THE AXIAL UT BEAM SCAN PARAMETERS

           'user set Y-Scan begin and end
           nScan.yBegin = -0.25# '1.00# '0.00# '-1.50##'.450#  'y scan start
           nScan.yEnd = 2.250# '2.00# '8.00## '5.540#   'y scan end

           'needed if nScan.AxialRaster = False, meaning raster motion is Circ direction
           nScan.yIndexInc = .100#  'index increment for Circ Raster

           'needed for getting segment
           nScan.yIndexes = (nScan.yEnd-nScan.yBegin)/nScan.yIndexInc

           'set by user, AxialRaster is back and forth scan motion, to and from the weld
           'If AxialRaster is False, scan motion is side to side, parallel along the weld,
           nScan.AxialRaster = TRUE
           'nScan.AxialRaster = FALSE

           nScan.SkewDeg = 0 '90 ' transducer skew angle, in degrees usually always +/- 90 degrees to ray scan lines for circ scans
           nScan.skewRdn = DegToRdn(nScan.SkewDeg) ' transducer skew angle, converted to radians
           nScan.skewOffset = 0 '3.00 '4  '4.00# '0' .0001#' 2.00# '    'transducer offset, index distance, to UT beam @ ID

           nScan.yRadius = IIF(nScan.yEnd=>1.00#,nScan.yEnd,1.00#)

           'user set transducer length, width and index
           'has no effect on scan accuracy, all scan parameters taken from centerline of gimbal slide fixture
           '!!! CRITICAL !!!Index point of transducer MUST BE ALIGNED with CENTERLINE of GIMBAL SLIDE (plunger)
           nScan.ProbeLen = 1.900# 'transducer length
           nScan.ProbeIdx = 0.500#   '1.00# '0.800# 'transducer index position, measured setback from front
           nScan.ProbeWidth = 1.650# 'transducer width

           'set number of scan overlap x-indexes, = 0 if none
           nScan.xIndexPlus = 10'10

           nScan.xIndexInc = 0.100#  'set x index increments

        ELSE    'SET THE CIRC UT BEAM SCAN PARAMETERS

           nScan.yBegin = -1.75# '0 '-.750# '0'0.800# :
           nScan.yEnd = 0.250# '0.500# '10.800#

           'addtional value needed if nScan.AxialRaster = False, meaning raster motion is Circ direction
           nScan.yIndexInc = 0.250#  'index increment for Circ Raster

           'needed for generating the paths
           nScan.yIndexes = (nScan.yEnd-nScan.yBegin)/nScan.yIndexInc

           'set by user, AxialRaster is back and forth scan motion, to and from the weld
           nScan.AxialRaster = FALSE
           'nScan.AxialRaster = TRUE

           '90 = beam going CW;  -90 = beam going CCW
           nScan.SkewDeg = -90.00# '270.00# '@Ray.oFociRdn-270.000# ' 10.00# '.0001# '-12.00#  'transducer skew: -SkewDeg = transducer on -side, UT Beam pointing CW
           nScan.skewRdn = DegToRdn(nScan.SkewDeg) 'transducer skew angle, usually always +/- 90 degrees to ray scan lines for circ scans
           nScan.skewOffset = 5.00# '4.330# '.00001# '-1.00 '-4.330#    'transducer offset, index distance, to UT beam @ ID

           nScan.yRadius = IIF(nScan.yEnd=>1.00#,nScan.yEnd,1.00#)

           'user set transducer length, width and index
           'has no effect on scan accuracy, all scan parameters taken from centerline of gimbal slide fixture
           '!!! CRITICAL !!!Index point of transducer MUST BE ALIGNED with CENTERLINE of GIMBAL SLIDE (plunger)
           nScan.ProbeLen = 2.100# 'transducer length
           nScan.ProbeIdx = 0.900#   '1.00# '0.800# 'transducer index position, measured setback from front
           nScan.ProbeWidth = 1.800# '2.600# 'transducer width

           'set number of scan overlap x-indexes, = 0 if none
           nScan.xIndexPlus = 10

           nScan.xIndexInc = 0.100#  'set x index increments

        END IF

        nRay.skewRdn = nScan.skewRdn

        nRay.skewDeg = nScan.SkewDeg

        nRay.Index = nScan.xIndexInc 'set model x index increments to x scan increments - must match!

'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

        '------------------------------------------------------------------------------------------------------------
        ' IMPORTANT SCANNER OPTIONS
        '------------------------------------------------------------------------------------------------------------

        'Note: In Degree's, 0 to 360 is CCW, 360 to 0 is CW

        '@Ray.Index0 = TRUE:
        'CCW 0-90-180-270-360: X = 0 at start, increasing X as going CCW  to 360
        'CW  0-270-180-90-360: X = 0 at start, increasing X as going CW to 360

        '@Ray.Index0 = FALSE:
        'CCW SCAN: 0-90-180-270-360: X = circumference at start, X decreasing as going CCW to 0
        'CW  SCAN: 0-270-180-90-360: X = circumference at start, X decreasing as going CW to 0

        nRay.Index0 = FALSE     'Scan start position = circumference"
        nRay.Index0 = TRUE      'Scan start position = 0"

        nRay.IndexCW = TRUE     'CW  scan direction  360-270-180-90-0
        'nRay.IndexCW = FALSE    'CCW scan direction: 0-90-180-270-360

        nScan.yIdxNeg = TRUE   'y index from yBegin to yEnd, scanner y must be at yBegin when scan commences
        'nScan.yIdxNeg = FALSE  'y index from yEnd to yBegin, scanner y must be at yEnd when scan commences

        nScan.xNear = TRUE  'X-Axis on near side of nozzle
        nScan.xNear = FALSE 'X-Axis on far side of nozzle


        nScan.MtrsRev = TRUE    'x,y,z motor direction flipped, (+) = (-) and (-) = (+)
        nScan.MtrsRev = FALSE   'x,y,z motor direction unchanged

'************************************

         gWin.xNear = nScan.xNear

        '------------------------------------------------------------------------------------------------------------
        ' generate the mathamatical model
        '------------------------------------------------------------------------------------------------------------
        '********************************************************
        'all-inclusive data for scan model generation:          *
        'nRay.Index = 0.0500#           'Set above in Scan Setup*
        nRay.oDeg = 90.00#             'user start degrees     *
        nRay.oRdn = DegToRdn(nRay.oDeg)'user start in radians  *
        nRay.minorDia = 8.00# '8.00# '7.80# '8.50#           'set above              *
        nRay.majorDia = 8.50# '9.00# '12.50#         'set above              *

        'pallisades axial, actual, 50"
        'nRay.majorAxis = 8.7318# 'CIRC: (as measured on curve, 50" Diameter)
        'nRay.minorAxis = 8.6875# 'AXIAL:(as measured on flat)
        'nRay.r_xIndexIncFixed = .150#  'x index increment

        '**************************************************************************************

        'check user input data, adjust as needed
        IF nRay.majorDia < nRay.minorDia THEN SWAP nRay.majorDia,nRay.minorDia 'swap if reversed
        IF nRay.majorDia = nRay.minorDia THEN nRay.majorDia += 0.0010#  'majorDia must be minimally larger than minorDia

        'set majorDia/minorDia radius
        nRay.majorRad = nRay.majorDia*half : nRay.minorRad = nRay.minorDia*half

        'set focal definition of the model
        nRay.foci = SQR(SQ(nRay.majorRad)-SQ(nRay.minorRad))    'foci point measured from majorDia axis centerline
        nRay.foci2 = nRay.foci*2                                'length between both foci points

        'calculate the circumference of the elliptical weld, accurate to +/- .001" for x,y ratios => 0.50:1.00
        '(pi/2)(A+B)[1 + H^2/4 + H^4/64 + H^6/256 + 25H^8/16384 + 49H^5/65536 + 441H^6/1048576] 'H = |A-B|/(A+B)
        Hs = (nRay.majorDia-nRay.minorDia) : Ha = (nRay.majorDia+nRay.minorDia) : H = Hs/Ha
        nRay.circ360e = pihalf*Ha*(1+(H^2/4)+(H^4/64)+(25*H^8/16384)+(49*H^5/65536)+(441*H^6/1048576))

        'calculate number of indexes, based on circumference and set index value
        nIndex = 1.125#*nRay.circ360e/nRay.Index + 10 '+10 index margin. 405/360 degrees = 1.125
        REDIM eXpos(nIndex),eYpos(nIndex),eArc(nIndex) AS GLOBAL DOUBLE 'dim to estimate

        T=TIMER

        'get the coordinates
        '*************************************************************************************************************
        nIndex = GetIndexCoord(VARPTR(nRay),nIndex) 'get the X,Y coordinate of each index along perimeter

        PRINT "TIME:" ; TIMER - T 'elapsed time to calculate indexes

        REDIM PRESERVE eXpos(nIndex),eYpos(nIndex),eArc(nIndex) AS GLOBAL DOUBLE 'redim to actual; preserve data

        REDIM eOriginX(nIndex),eNormRdn(nIndex),eNormRad(nIndex),eRotDeg(nIndex) AS GLOBAL DOUBLE 'dim same as above
        GetIndexRays(VARPTR(nRay)) 'get the focal laws for each index

        'redim test
        REDIM test(10) AS TestOne
        test(0).t1 = 1 : test(0).t2 = 2 : test(0).t3 = 3 : test(0).t4 = 4

        REDIM PRESERVE test(100)' AS TestOne

        PRINT test(0).t1; test(0).t2; test(0).t3; test(0).t4
        PRINT
        PRINT "CIRC: Actual, Guess"
        PRINT ROUND(nRay.circ360,3); ROUND(nRay.circ360e,3);

        WAITKEY$

    '------------------------------------------------------------------------------------------------------------
    'math model complete

        'Set OverLap
        IF nScan.xIndexPlus THEN 'has overlap
           nScan.xIndexEnd =  MIN(nRay.Index360+nScan.xIndexPlus, nRay.Index405) 'make sure not past 360+45 (405) degrees
        ELSE  ' no overlap!
           nScan.xIndexEnd = nRay.Index360
        END IF

        PRINT nScan.xIndexEnd

        'calculate number of paths, based on axial or circ raster
        nPath = IIF( nScan.AxialRaster, (nScan.xIndexEnd*2)+1, (nScan.xIndexEnd+1)*(nScan.yIndexes+1)-1 )

        'erase and allocate memory storage for number of paths
        REDIM PathX(nPath), PathY(nPath), PathZ(nPath), PathC(nPath), PathA(nPath) AS GLOBAL DOUBLE

        PRINT "Calculated paths: "; nPath

        'get the motion paths
        NumOfPaths = GetPaths(VARPTR(nScan))

        PRINT "Actual paths: "; NumOfPaths

        IF NumOfPaths <> nPath THEN 'error if PathCtr > nPath
           PRINT "PATH ERROR: Number of Paths generated does not equal Paths allocated"
        ELSE
           PRINT "PATHS OK!"
        END IF

        PRINT "PRESS ANY KEY"
        BEEP
        WAITKEY$
        CLS

        n60HzSegs = Get60HzSegs(1.00#) 'Get60HzSegs(ScanSpd)
        PRINT "Number Of Segments: "; n60HzSegs
        BEEP : WAITKEY$

        SetWindow(nScan.yRadius, nRay.MajorRad, nRay.MinorRad) ' set up the graphic window

        LOCAL RetVal AS LONG

        'needed for drawing only!!
        nScan.WeldHaz = 0.250# : nScan.WeldWidth = 1.00#

        RetVal = RunScan(VARPTR(nRay),VARPTR(nScan),VARPTR(GFX),VARPTR(qRay))

        IF RetVal THEN  ' user closed window

        END IF

        CON.INPUT.FLUSH

        WinBeep 800,200

        BEEP

        PRINT "WAITKEY$"

        WAITKEY$


ExitWindows2:

    'Close and exit all windows
    GRAPHIC ATTACH gWIN.hWin(0), 0&  'select the STANDARD Graphics window
    GRAPHIC WINDOW END          'close the selected STANDARD Graphics window

    GRAPHIC ATTACH gWIN.hWin(1), 0&  'select the Memory Bitmap Graphics window
    GRAPHIC BITMAP END          'close the selected Memory Bitmap Graphics window


END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Translate +/-degree's to 0-360 degree values (all in Degrees)
'X = xPos, Y = yPos, A = angle in degrees
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION Get360Deg(BYVAL X#, BYVAL Y#, BYVAL A#) AS DOUBLE
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
'Translate +/-degree's (in Radians) to 0-360 degree values (in Radians)
'X =xPos, Y =yPos, A =angle  in Rdn
'----------------------------------------------------------------------------------------------------------------------------------------------
'FUNCTION Get360Rdn(BYVAL X#, BYVAL Y#, BYVAL A#) AS DOUBLE
'    IF (X#=>0) AND (Y#=>0) THEN
'       FUNCTION = A#                  'Quadrant(1),0-90 degrees,+COS(X),+SIN(Y) A# = 0 to 90
'    ELSEIF (X#<0) AND (Y#>0) THEN
'       FUNCTION = A#+Rdn180           'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y) A# = -89.999 to 0
'    ELSEIF (X#=<0)AND (Y#<=0)THEN
'       FUNCTION = A#+Rdn180           'Quadrant(3),180-270 degrees,-COS(X),-SIN(Y) A# = 0 to 90
'    ELSEIF (X#>0) AND (Y#<0) THEN
'       FUNCTION = A#+Rdn360           'Quadrant(4),270-360 degrees,+COS(X),-SIN(Y) A# = -89.999 to 0
'    END IF
'END FUNCTION


'----------------------------------------------------------------------------------------------------------------------------------------------
'Translate NORMAL ANGLE to 0-360 degree values  A# = Normal angle measured from foci 2 (foci 1 is opposite)
'X =xPos, Y =yPos, A =angle in Rdn
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetN360Rdn(BYVAL X#, BYVAL Y#, BYVAL A#) AS DOUBLE

    IF (X#>0) AND (Y#=0) THEN       'Single case only: X is on positive side, Y is at 0, can only be @ 0 degrees
       FUNCTION = 0#
    ELSEIF (X#<0) AND (Y#=0) THEN   'Single case only: X is on negative side, Y is at 0, can only be @ 180 degrees
       FUNCTION = Rdn180
    ELSEIF (X#=>0) AND (Y#=>0) THEN 'Quadrant(1), 0-90 degrees, +COS(X),+SIN(Y)   (foci2)A# = 0 to 90 (foci1= 180 to 90)
       FUNCTION = A#
    ELSEIF (X#<0) AND (Y#>0) THEN   'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y)  (foci2)A# = 90 to 180 (foci1= 90 to 0)
       FUNCTION = A#
    ELSEIF (X#=<0)AND (Y#<0)THEN   'Quadrant(3), 180-270 degrees,-COS(X),-SIN(Y) (foci2)A# = 180 to 90 (foci1= 0 to 90)
       FUNCTION = (Rdn180-A#)+ Pi
    ELSEIF (X#>0) AND (Y#<=0) THEN   'Quadrant(4), 270-360 degrees,+COS(X),-SIN(Y) (foci2)A# = 90 to 0 (foci1= 90 to 180)
       FUNCTION = (Rdn90-A#) + Rdn270
    END IF

END FUNCTION


'----------------------------------------------------------------------------------------------------------------------------------------------
'Translate NORMAL ANGLE to 0-360 degree values  A# = Normal angle measured from foci 2 (foci 1 is opposite)
'X =xPos, Y =yPos, A =angle in Rdn
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetN360Rdn_ORG(BYVAL X#, BYVAL Y#, BYVAL A#) AS DOUBLE

    'X# = Round(X#,4) : Y# = Round(Y#,4)  ' added because of bizzare error when start is set at 180 degrees
                                         ' the nozzle line plot at scan start, 180, has lines going off to east bum*** eygpt!
                                         ' only happens for smaller majorDia vs minorDia ratios, for example 9 and 8
                                         ' without rounding, this function doesn't return Rdn180 for a Rdn180 setting
                                         'NOTE: removed: worked but view the real cause: RdnToDeg and DegToRdn MACRO
    IF (X#>0) AND (Y#=0) THEN       'Single case only: X is on positive side, Y is at 0, can only be @ 0 degrees
       FUNCTION = 0#
    ELSEIF (X#<0) AND (Y#=0) THEN   'Single case only: X is on negative side, Y is at 0, can only be @ 180 degrees
       FUNCTION = Rdn180
    ELSEIF (X#=>0) AND (Y#=>0) THEN 'Quadrant(1), 0-90 degrees, +COS(X),+SIN(Y)   (foci2)A# = 0 to 90 (foci1= 180 to 90)
       FUNCTION = A#
    ELSEIF (X#<0) AND (Y#>0) THEN   'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y)  (foci2)A# = 90 to 180 (foci1= 90 to 0)
       FUNCTION = A#
    ELSEIF (X#=<0)AND (Y#<=0)THEN   'Quadrant(3), 180-270 degrees,-COS(X),-SIN(Y) (foci2)A# = 180 to 90 (foci1= 0 to 90)
       FUNCTION = (Rdn180-A#)+ Pi
    ELSEIF (X#>0) AND (Y#<0) THEN   'Quadrant(4), 270-360 degrees,+COS(X),-SIN(Y) (foci2)A# = 90 to 0 (foci1= 90 to 180)
       FUNCTION = (Rdn90-A#) + Rdn270
    END IF
END FUNCTION


'----------------------------------------------------------------------------------------------------------------------------------------------
'Find Rad of any foci point:  Rad = (r1*r2)^3^.5 / (majorRad*minorRad)
' F1L=foci1 length,F2L=foci2 length,LAR=majorDia Axis Rad, SAR=minorDia Axis Rad
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadE (BYVAL F1L#, BYVAL F2L#, BYVAL LAR#, BYVAL SAR#) AS DOUBLE
     FUNCTION = (F1L#*F2L#)^3^.5 / (LAR#*SAR#)
     'angleARdn# = ArcSin(ABS(YP(n%))/GetRad#)
     'angleB# = 90-AngleA#
     'x# = XP(n%) - ABS((YP(n%)/ Tan(angleARdn#)
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Find majorDia Axis Rad:  Rad = minorRad^2 / majorRad
' LAR=majorDia Axis Rad, SAR=minorDia Axis Rad
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadL (BYVAL LAR#, BYVAL SAR#) AS DOUBLE
         FUNCTION = SAR#^2 / LAR#
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'Find minorDia Axis Rad:  Rad = minorRad^2 / majorRad
' LAR=majorDia Axis Rad, SAR=minorDia Axis Rad
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRadS (BYVAL LAR#, BYVAL SAR#) AS DOUBLE
         FUNCTION = LAR#^2 / SAR#
END FUNCTION


'----------------------------------------------------------------------------------------------------------------------------------------------
'Segment length
'LAR = XY Point 1, SAR = XY Point 2
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetSegLen (BYVAL LAR#, BYVAL SAR#) AS DOUBLE
         FUNCTION = SQR( SQ(LAR#)+ SQ(SAR#) )'segment length
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
'
' ARC TAN2
'----------------------------------------------------------------------------------------------------------------------------------------------
'FUNCTION aTan2(y AS DOUBLE, x AS DOUBLE) AS DOUBLE
FUNCTION aTan2(y AS EXT, x AS EXT) AS EXT

'  1 /*
'  2  * (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
'  3  * See the copyright notice in the ACK home directory, in the file "Copyright".
'  4  *
'  5  * Author: Ceriel J.H. Jacobs
'  6  */
'  7 /* $Header: /users/cosc/staff/paul/CVS/minix1.7/src/lib/math/atan2.c,v 1.2 1996/04/10 21:15:02 paul Exp $ */
'  8
'  9 #include        <math.h>
' 10 #include        <errno.h>
' 11 #include        "localmath.h"
' 12
' 13 double
' 14 atan2(double y, double x)
' 15 {
' 16         double absx, absy, val;
' 17
' 18         if (x == 0 && y == 0) {
' 19                 errno = EDOM;
' 20                 return 0;
' 21         }
' 22         absy = y < 0 ? -y : y;
' 23         absx = x < 0 ? -x : x;
' 24         if (absy - absx == absy) {
' 25                 /* x negligible compared to y */
' 26                 return y < 0 ? -M_PI_2 : M_PI_2;
' 27         }
' 28         if (absx - absy == absx) {
' 29                 /* y negligible compared to x */
' 30                 val = 0.0;
' 31         }
' 32         else    val = atan(y/x);
' 33         if (x > 0) {
' 34                 /* first or fourth quadrant; already correct */
' 35                 return val;
' 36         }
' 37         if (y < 0) {
' 38                 /* third quadrant */
' 39                 return val - M_PI;
' 40         }
' 41         return val + M_PI;
' 42 }
' 43
'
    LOCAL absx, absy, rVal AS EXT 'DOUBLE

    IF (x = 0) AND (y = 0) THEN 'punch out
        FUNCTION = 0 : EXIT FUNCTION
    END IF

    absy = IIF(y < 0, -y, y) 'get abs value
    absx = IIF(x < 0, -x, x)

    IF (absy - absx) = absy THEN  'x negligible compared to y
        FUNCTION = IIF(y < 0,-Pi2, Pi2) : EXIT FUNCTION
    END IF

    rVal = IIF(absx-absy=absx,0.00#,ATN(y/x)) 'y negligible compared to x

    IF (x > 0)  THEN    'first or fourth quadrant; already correct
        FUNCTION = rVal
    ELSEIF (y < 0) THEN 'third quadrant; subtract Pi
        FUNCTION = rVal - Pi
    ELSE                'second quadrant; add Pi
        FUNCTION = rVal + Pi
    END IF


END FUNCTION

'-------------------------------------------------------------------------------------------------------------------------------------------
' https://forum.powerbasic.com/forum/user-to-user-discussions/source-code/51751-math-helper
' Cut and Paste from PB Math Helper  Cory Marshall
'-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION ExAtan2(BYVAL x AS EXTENDED, BYVAL y AS EXTENDED) AS EXTENDED

      LOCAL result AS EXTENDED

      SELECT CASE x
        CASE 0:
          IF y = 0 THEN
            result = 0
          ELSEIF y > 0 THEN
              result = PiHalf
          ELSE' y < 0
              result = -PiHalf
          END IF
        CASE > 0: result = ATN(y/x)
        CASE < 0:
          IF y => 0 THEN
            result = ATN(y / x) + Pi
          ELSE
            result = ATN(y / x) - Pi
          END IF
      END SELECT

      FUNCTION  = result

END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------------
' Math.pow(base, exponent)
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION pow (x AS EXT, y AS EXT) AS EXT
    FUNCTION = EXP(y * LOG(x))
END FUNCTION


'----------------------------------------------------------------------------------------------------------------------------------------------
'
' QUARTIC
'----------------------------------------------------------------------------------------------------------------------------------------------
'NEW
SUB GetQuartic(xp AS DOUBLE, yp AS DOUBLE, BYVAL RayPtr AS DWORD)

    LOCAL Ray AS FociRay POINTER : Ray = RayPtr

    LOCAL cb, cc, c_d, discrim, q, r, RRe, dum1, ERe, EIm, s, t, term1, _
          r13, sq_R, y1, z1Re, xRe, xIm, a, b, c, d, e, qy, qx, xPos2, yPos2 AS EXT

    LOCAL majorDia, minorDia AS EXT

    LOCAL rd AS LONG : rd = 14    'rounding places

    majorDia = @Ray.majorRad : minorDia = @Ray.minorRad

    xPos2 = ROUND(xp,rd) : yPos2 = ROUND(yp,rd)

    'bug out if direct match
    IF yPos2 = 0 THEN       'x>0=0;  x<0=180 degrees
       xp = IIF(xPos2 > 0,@Ray.majorRad,-@Ray.majorRad) : EXIT SUB
    ELSEIF xPos2 = 0 THEN   'y>0=90; y<0=270 degrees
       yp = IIF(yPos2 > 0,@Ray.minorRad,-@Ray.minorRad) : EXIT SUB
    END IF

    xPos2 = ABS(xp) : yPos2 = ABS(yp)

    a = (majorDia^2 - minorDia^2)^2
    b = -2.0 * majorDia^2 * xPos2 * (majorDia^2 - minorDia^2)
    c = majorDia^2 *(majorDia^2 * xPos2^2 + minorDia^2 * yPos2^2 - (majorDia^2 - minorDia^2)^2 )
    d = 2.0 * majorDia^4 * xPos2 * (majorDia^2 - minorDia^2)
    e = -majorDia^6 * xPos2^2

    IF a <> 1 THEN ' can't happen, but if it did: divide by zero GFP results
       b /= a : c /= a : d /= a : e /= a   'is always > 1 !!
    ELSE
       PRINT "ERROR 1" : BEEP :WAITKEY$
    END IF

    '// Coefficients for cubic solver
    cb = -c
    cc = -4.00##*e + d*b
    c_d = -(b*b*e + d*d) + 4.00##*c*e

    q = (3.00##*cc - (cb*cb))/9.00##                       'observation, all constants evenly divisible by 3.00
    r = -(27.00##*c_d) + cb*(9.00##*cc - 2.00##*(cb*cb))
    r /= 54.00##
    term1 = cb/3.00##
    discrim = ROUND(q*q*q + r*r,rd)

    'find y1
    IF discrim > 0 THEN   '1 root real, 2 are complex
       'print "ELSE 3"      'always ??
       s = r + SQR(discrim)
       s = IIF(s < 0, -pow(-s,(1.00##/3.00##)),pow(s,(1.00##/3.00##)))
       t = r - SQR(discrim)
       t = IIF(t < 0, -pow(-t,(1.00##/3.00##)),pow(t,(1.00##/3.00##)))
       y1 = -term1 + s + t
    ELSEIF (discrim < 0) THEN
       q = -q
       dum1 = q*q*q
       dum1 = ArcCos(r/SQR(dum1))
       r13 = 2.00##*SQR(q)
       y1 = -term1 + r13*COS(dum1/3.00##)
    ELSE  'discrim = 0     ???
       PRINT "ERROR 3" : BEEP :WAITKEY$
    END IF

    'Determined y1, a real root of the resolvent cubic.
    term1 = b/4.00##
    sq_R = ROUND(-c + term1*b + y1,rd)

    IF (sq_R > 0) THEN
       RRe = SQR(sq_R)
       z1Re = -(8.00##*d + b*b*b)/4.00## + b*c
       z1Re /= RRe
       z1Re = -z1Re
    ELSEIF sq_R = 0 THEN
       dum1 = -(4.00##*e) + y1*y1
       z1Re = 2.00##*SQR(dum1)
       z1Re = -z1Re
    ELSE  'sq_R < 0   'should not happen!
       PRINT "ERROR 3" : PRINT sq_R : BEEP :WAITKEY$
    END IF

    z1Re = ROUND(z1Re + -(2.00##*c + sq_R) + 3.00##*b*term1,rd) 'z1 real should be under the terms under the square root for E

    IF (z1Re >= 0) THEN
       ERe = SQR(z1Re)
    ELSE                     'negative: rare
       EIm = SQR(-z1Re)
    END IF

    xRe = -(term1 + RRe/2.00##) + ERe/2.00##
    xIm = EIm/2.00##

    qX = ROUND(xRe + xIm,rd)  'Real + Imaginary

    'solve for Y from X
    qY = ROUND(SQR((1.00##-qX^2/majorDia^2)*minorDia^2),rd) ' equation below used to solve for y;  general ellipse equation
                                                      '  X^2     Y^2           xPos^2         yPos^2
                                                      ' ----- + ----- = 1     --------    +  --------    = 1
                                                      '  A^2     B^2         majorRad^2     minorRad^2
    yp = IIF(yp<0,-qY,qY) : xp = IIF(xp<0,-qX,qX)


END SUB


'ORG
SUB GetQuartic_ORG (xPos2 AS DOUBLE, yPos2 AS DOUBLE, BYVAL RayPtr AS DWORD)

    LOCAL Ray AS FociRay POINTER : Ray = RayPtr ' Set the pointer from the DWORD param

    'Coefficients for cubic solver
    LOCAL cb, cc, c_d, discrim, q, r, RRe, RIm, DRe, D_Im, dum1, ERe, EIm, s, t, term1, r13, sq_R, _
          y1, z1Re, z1Im, z2Re, x1Re, x1Im, x2Re, x2Im, x3Re, x3Im, x4Re, x4Im, a, b, c, d, e, xp, yp AS EXT 'DOUBLE

    DIM qY(3) AS LOCAL EXT, qX(3) AS LOCAL EXT

    LOCAL majorDia, minorDia AS EXT

    majorDia = @Ray.majorRad : minorDia = @Ray.minorRad

    'bug out if direct match
    IF yPos2 = 0 THEN       'x>0=0;  x<0=180 degrees
       xPos2 = IIF(xPos2 > 0,@Ray.majorRad,-@Ray.majorRad) : EXIT SUB
    ELSEIF xPos2 = 0 THEN   'y>0=90; y<0=270 degrees
       yPos2 = IIF(yPos2 > 0,@Ray.minorRad,-@Ray.minorRad) : EXIT SUB
    END IF

    ' https://www.easycalculation.com/algebra/learn-quartic-equation.php
    ' Quartic Equation Formula: ax^4 + bx^3 + cx^2 + dx + e = 0

    ' where,
    ' a = coefficient of x^4
    ' b = coefficient of x^3
    ' c = coefficient of x^2
    ' d = coefficient of x
    ' e = constant

    'a=3 : b=6 : c=-123 : d=-126 : e=1080

    'LOCAL c0, c1, c2, c3, c4 AS DOUBLE
    'solve by quartic


    'c4 = (a^2-b^2)^2
'    a =  SQ( (SQ(@Ray.majorRad)-SQ(@Ray.minorRad)) )
    a =  (majorDia^2 - minorDia^2)^2


    'c3 = -2 a^2 X(a^2-b^2)
'    b = (-2.00#) * SQ(@Ray.majorRad) * xPos * ( SQ(@Ray.majorRad)-SQ(@Ray.minorRad) )
    b = -2.0 * majorDia^2 * xPos2 * (majorDia^2 - minorDia^2)


    'c2 = a^2 [ a^2 X^2 + b^2 Y^2 - (a^2-b^2)^2 ]
'    c = SQ(@Ray.majorRad) *( SQ(@Ray.majorRad)*SQ(xPos)+SQ(@Ray.minorRad)* SQ(yPos) - SQ( (SQ(@Ray.majorRad)-SQ(@Ray.minorRad))) )
    c = majorDia^2 *(majorDia^2 * xPos2^2 + minorDia^2 * yPos2^2 - (majorDia^2 - minorDia^2)^2 )


    'c1 = 2a^4X(a^2-b^2)
'    d = 2.00# * SQx4(@Ray.majorRad) * xPos * ( SQ(@Ray.majorRad)-SQ(@Ray.minorRad) )
    d = 2.0 * majorDia^4 * xPos2 * (majorDia^2 - minorDia^2)


    'c0 = -a^6 X^2
'    e = SQx6(-@Ray.majorRad) * SQ(xPos)
    e = -majorDia^6 * xPos2^2


    ' Quartic Equation solving formula:
    ' x1 = p + q + r - s
    ' x2 = p - q - r - s
    ' x3 = -p + q - r - s
    ' x4 = -p - q + r - s

    ' Example 1:
    ' Calculate the roots(x1,x2,x3,x4) of the quartic equation,
    ' 3x^4 + 6x^3 - 123x^2 - 126x + 1080 = 0


    ' ***************************************************************************
    ' Step 1:
    ' From the above equation, the value of a=3, b=6, c=-123, d=-126, e=1080



    'function quad4solve()
    '{
    '    var a = parseFloat($("#aIn").val());
    '    var b = parseFloat($("#bIn").val());
    '    var c = parseFloat($("#cIn").val());
    '    var d = parseFloat($("#dIn").val());
    '    var e = parseFloat($("#eIn").val());



    '    if (a == 0)
    '    {
    '        alert("The coefficient of the power four of x is 0. Please use the utility for a third degree quadratic.");
    '        return;
    '    }
    '    if (e == 0)
    '    {
    '        alert("One root is 0. Now divide through by x and use the utility for a third degree quadratic to solve the resulting equation for the other three roots.");
    '        return;
    '    }
    '    if (a != 1)
    '    {
    '        b /= a;
    '        c /= a;
    '        d /= a;
    '        e /= a;
    '    }
    '

    IF a = 0 THEN
       PRINT "The coefficient of the power four of x is 0. Please use the utility for a third degree quadratic.";
       EXIT SUB
    END IF

    IF e = 0 THEN
       PRINT "One root is 0. Now divide through by x and use the utility for a third degree quadratic to solve the resulting equation for the other three roots.";
       EXIT SUB
    END IF

    IF a <> 1 THEN b /= a : c /= a : d /= a : e /= a   'is always > 1 !!



    '// Coefficients for cubic solver
    '    var cb, cc, cd;
    '    var discrim, q, r, RRe, RIm, DRe, DIm, dum1, ERe, EIm, s, t, term1, r13, sqR, y1, z1Re, z1Im, z2Re;
    '
    '    cb = -c;
    '    cc = -4.0*e + d*b;
    '    cd = -(b*b*e + d*d) + 4.0*c*e;
    '    if (cd == 0)
    '    {
    '        alert("cd = 0.");
    '    }
    '    q = (3.0*cc - (cb*cb))/9.0;
    '    r = -(27.0*cd) + cb*(9.0*cc - 2.0*(cb*cb));
    '    r /= 54.0;
    '    discrim = q*q*q + r*r;
    '    term1 = (cb/3.0);

    ' Coefficients for cubic solver
    cb = -c
    cc = -4.00##*e + d*b
    c_d = -(b*b*e + d*d) + 4.00##*c*e
    IF c_d = 0 THEN PRINT "ALERT cd = 0.";

    q = (3.00##*cc - (cb*cb))/9.00##                       'observation, all const numbers evenly divisible by 3.00
    r = -(27.00##*c_d) + cb*(9.00##*cc - 2.00##*(cb*cb))
    r /= 54.00##
    discrim = q*q*q + r*r
    term1 = (cb/3.00##)


    '   if (discrim > 0)  '// 1 root real, 2 are complex
    '   {
    '     s = r + Math.sqrt(discrim);
    '     s = ((s < 0) ? -Math.pow(-s, (1.0/3.0)) : Math.pow(s, (1.0/3.0)));  Math.pow(base, exponent)
    '     t = r - Math.sqrt(discrim);
    '     t = ((t < 0) ? -Math.pow(-t, (1.0/3.0)) : Math.pow(t, (1.0/3.0)));
    '     y1 = -term1 + s + t;
    '   }
    '   else
    '   {
    '     if (discrim == 0)
    '     {
    '       r13 = ((r < 0) ? -Math.pow(-r,(1.0/3.0)) : Math.pow(r,(1.0/3.0)));
    '       y1 = -term1 + 2.0*r13;
    '     }
    '     else
    '     {
    '       q = -q;
    '       dum1 = q*q*q;
    '       dum1 = Math.acos(r/Math.sqrt(dum1));
    '       r13 = 2.0*Math.sqrt(q);
    '       y1 = -term1 + r13*Math.cos(dum1/3.0);
    '     }
    '   }

   ' EXP(y * LOG(x))
   ' FUNCTION pow (x AS EXT, y AS EXT) AS EXT

    IF discrim > 0 THEN   '1 root real, 2 are complex
       s = r + SQR(discrim)
       s = IIF(s < 0, -pow(-s,(1.00##/3.00##)),pow(s,(1.00##/3.00##)))
       t = r - SQR(discrim)
       t = IIF(t < 0, -pow(-t,(1.00##/3.00##)),pow(t,(1.00##/3.00##)))
       y1 = -term1 + s + t
    ELSEIF (discrim = 0) THEN
       r13 = IIF(r < 0, -pow(-r,(1.00##/3.00##)),pow(r,(1.00##/3.00##)))
       y1 = -term1 + 2.00##*r13
    ELSE  'discrim < 0
       q = -q
       dum1 = q*q*q
       dum1 = ArcCos(r/SQR(dum1))
       r13 = 2.00##*SQR(q)
       y1 = -term1 + r13*COS(dum1/3.00##)
    END IF




'    IF discrim > 0 THEN   '1 root real, 2 are complex
'       s = r + SQR(discrim)
'       s = IIF(s < 0, -(-s^(1.00#/3.00#)),(s^(1.00#/3.00#)))
'       t = r - SQR(discrim)
'       t = IIF(t < 0, -(-t^(1.00#/3.00#)),(t^(1.00#/3.00#)))
'       y1 = -term1 + s + t
'    ELSEIF (discrim = 0) THEN
'       r13 = IIF(r < 0, -(-r^(1.00#/3.00#)),(r^(1.00#/3.00#)))
'       y1 = -term1 + 2.00#*r13
'    ELSE  'discrim < 0
'       q = -q
'       dum1 = q*q*q
'       dum1 = ArcCos(r/SQR(dum1))
'       r13 = 2.00#*SQR(q)
'       y1 = -term1 + r13*COS(dum1/3.00#)
'    END IF


    '// Determined y1, a real root of the resolvent cubic.
    'term1 = b/4.0;
    'sqR = -c + term1*b + y1;
    'RRe = RIm = DRe = DIm = ERe = EIm = z1Re = z1Im = z2Re = 0;
    'if (sqR >= 0)
    '{
    '  if (sqR == 0)
    '  {
    '     dum1 = -(4.0*e) + y1*y1;
    '     if (dum1 < 0) //D and E will be complex
    '        z1Im = 2.0*Math.sqrt(-dum1);
    '     else
    '     {    //else (dum1 >= 0)
    '       z1Re = 2.0*Math.sqrt(dum1);
    '       z2Re = -z1Re;
    '     }
    '  }
    '  else
    '  {
    '   RRe = Math.sqrt(sqR);
    '   z1Re = -(8.0*d + b*b*b)/4.0 + b*c;
    '   z1Re /= RRe;
    '   z2Re = -z1Re;
    '   }
    '}
    'else
    '{
    ' RIm = Math.sqrt(-sqR);
    ' z1Im = -(8.0*d + b*b*b)/4.0 + b*c;
    ' z1Im /= RIm;
    ' z1Im = -z1Im;
    '}
    '
    'z1Re += -(2.0*c + sqR) + 3.0*b*term1;
    'z2Re += -(2.0*c + sqR) + 3.0*b*term1;
    '

    'Determined y1, a real root of the resolvent cubic.
    term1 = b/4.00##
    sq_R = -c + term1*b + y1
    RRe = 0: RIm = 0: DRe = 0: D_Im = 0: ERe = 0: EIm = 0: z1Re = 0: z1Im = 0: z2Re = 0
    IF (sq_R >= 0) THEN
       IF (sq_R = 0) THEN
          dum1 = -(4.00##*e) + y1*y1
          IF (dum1 < 0) THEN 'D and E will be complex
             z1Im = 2.00##*SQR(-dum1)
          ELSE   '(dum1 >= 0)
             z1Re = 2.00##*SQR(dum1)
             z2Re = -z1Re
          END IF
       ELSE
          RRe = SQR(sq_R)
          z1Re = -(8.00##*d + b*b*b)/4.00## + b*c
          z1Re /= RRe
          z2Re = -z1Re
       END IF
    ELSE
      RIm = SQR(-sq_R)
      z1Im = -(8.00##*d + b*b*b)/4.00## + b*c
      z1Im /= RIm
      z1Im = -z1Im
    END IF

    z1Re += -(2.00##*c + sq_R) + 3.00##*b*term1
    z2Re += -(2.00##*c + sq_R) + 3.00##*b*term1


'//At this point, z1 and z2 should be the terms under the square root for D and E
'    if (z1Im == 0)
'    {               // Both z1 and z2 real
'        if (z1Re >= 0)
'        {
'            DRe = Math.sqrt(z1Re);
'        }
'        else
'        {
'            DIm = Math.sqrt(-z1Re);
'        }
'        if (z2Re >= 0)
'        {
'            ERe = Math.sqrt(z2Re);
'        }
'        else
'        {
'            EIm = Math.sqrt(-z2Re);
'        }
'    }
'    else
'    {
'        r = Math.sqrt(z1Re*z1Re + z1Im*z1Im);
'        r = Math.sqrt(r);
'        dum1 = Math.atan2(z1Im, z1Re);
'        dum1 /= 2; //Divide this angle by 2
'        ERe = DRe = r*Math.cos(dum1);
'        DIm = r*Math.sin(dum1);
'        EIm = -DIm;
'    }
'    $("#x1Re").val(-term1 + (RRe + DRe)/2);
'    $("#x1Im").val((RIm + DIm)/2);
'    $("#x2Re").val(-(term1 + DRe/2) + RRe/2);
'    $("#x2Im").val((-DIm + RIm)/2);
'    $("#x3Re").val(-(term1 + RRe/2) + ERe/2);
'    $("#x3Im").val((-RIm + EIm)/2);
'    $("#x4Re").val(-(term1 + (RRe + ERe)/2));
'    $("#x4Im").val(-(RIm + EIm)/2);
'    return;
'}

    'AT THIS POINT, z1 AND z2 should be the terms under the square root FOR D AND E
    IF (z1Im = 0) THEN  'z1 imaginary = 0
        'Both z1 AND z2 real
        IF (z1Re >= 0) THEN
           DRe = SQR(z1Re)
        ELSE
           D_Im = SQR(-z1Re)
        END IF
        IF (z2Re >= 0) THEN
           ERe = SQR(z2Re)
        ELSE
           EIm = SQR(-z2Re)
        END IF
    ELSE
        'print z1im
        r = SQR(z1Re*z1Re + z1Im*z1Im)
        r = SQR(r)
        dum1 = exATan2(z1Im,z1Re) 'Coded function (see aTan2) MAY NOT BE CORRECT SEE 'C' langauge Math.atan2    dum1 = Math.atan2(z1Im, z1Re);
       ' testvar(1) =  RdnToDeg(dum1)
        PRINT "aTan2:"; RdnToDeg(dum1)
       ' testvar(0) = 1
        dum1 /= 2.00##  'Divide THIS angle by 2
        ERe = r*COS(dum1)
        DRe = ERe
        D_Im = r*SIN(dum1)
        EIm = -D_Im
    END IF

    x1Re = -term1 + (RRe + DRe)/2.00##  'real
    x1Im = (RIm + D_Im)/2.00##          'imaginary

    x2Re = -(term1 + DRe/2.00##) + RRe/2.00##
    x2Im = (-D_Im + RIm)/2.00##

    x3Re = -(term1 + RRe/2.00##) + ERe/2.00##
    x3Im = (-RIm + EIm)/2.00##

    x4Re = -(term1 + (RRe + ERe)/2.00##)
    x4Im = -(RIm + EIm)/2.00##

    'solve X results
    qX(0) = x1Re + x1Im  'Real + Imaginary
    qX(1) = x2Re + x2Im
    qX(2) = x3Re + x3Im
    qX(3) = x4Re + x4Im

    'solve for Y from X
    qY(0) = SQR((1.00##-qX(0)^2/majorDia^2)*minorDia^2)  ' equation below used to solve for y;  general ellipse equation
    qY(1) = SQR((1.00##-qX(1)^2/majorDia^2)*minorDia^2)  '  X^2     Y^2           xPos^2         yPos^2
    qY(2) = SQR((1.00##-qX(2)^2/majorDia^2)*minorDia^2)  ' ----- + ----- = 1     --------    +  --------    = 1
    qY(3) = SQR((1.00##-qX(3)^2/majorDia^2)*minorDia^2)  '  A^2     B^2         majorRad^2     minorRad^2

    IF yPos2 => 0 AND xPos2 > 0 THEN      '0 to 89.999 Degrees
       yPos2 = qY(2) : xPos2 = qX(2) 'y(3) and x(3)= opposite side
    ELSEIF yPos2 > 0 AND xPos2 =< 0 THEN  '90 to 179.999 Degress
       yPos2 = qY(1) : xPos2 = qX(1) 'y(0) and x(0)= opposite side
    ELSEIF yPos2 =< 0 AND xPos2 =< 0 THEN '180 to 269.999 Degrees
       yPos2 =-qY(1) : xPos2 = qX(1) 'x(0) and y(0)= opposite side
    ELSE'IF yPos <0 AND xPos= >0 THEN   '270 to 359.999 Degrees
       yPos2 =-qY(2) : xPos2 = qX(2) 'x(3) and y(3) = opposite side
    END IF

'     @Quartic.x1 = qX(0)
'     @Quartic.x2 = qX(1)
'     @Quartic.x3 = qX(2)
'     @Quartic.x4 = qX(3)
'
'    'solve for Y from X
'     @Quartic.y1 = qY(0)
'     @Quartic.y2 = qY(1)
'     @Quartic.y3 = qY(2)
'     @Quartic.y4 = qY(3)


END SUB

'Here's a simple function that you can use to determine the maximum font size to just fit a string within an area.
'This second approach, which assumes the font size will be no  - Gary Beene
'larger than 1000pts, gives a much better answer - and is very fast!
FUNCTION GetFontSize_Graphic2(w AS LONG, h AS LONG, TXT$, scalefactor AS SINGLE, fontName$) AS LONG
    LOCAL x AS LONG, y AS LONG
    GRAPHIC FONT fontName$, 1000, 1
    GRAPHIC TEXT SIZE TXT$ TO x,y
    FUNCTION =  1000/IIF( x/w > y/h , x/(w*scalefactor) , y/(h*scalefactor) )
END FUNCTION


SUB Bleep(freq1 AS LONG, freq2 AS LONG, duration AS LONG)   'duration IN msec Freq in Hz

    'https://forum.powerbasic.com/forum/user-to-user-discussions/powerbasic-for-windows/748204-doing-in-pbwin-what-sound-did-in-pbdos
    'From Paul Dixon Post in PB

    'DIM w AS waveheader
    'DIM ww AS onesecwav
    DIM p AS INTEGER PTR ,q AS INTEGER PTR
    LOCAL Samples, r AS LONG

    'pi2#=2*3.14159265358979323#    'already defined CONST

    Samples = duration*22050/1000

    w.rID             = "RIFF"
    w.rLen            = 36+Samples&*4
    w.wID             = "WAVE"
    w.fId             = "fmt "
    w.fLen            = 16
    w.wFormatTag      = 1
    w.nChannels       = 2 'nChannels
    w.nSamplesPerSec  = 22050 'nSamplesPerSec
    w.nAvgBytesPerSec = 88200  '44100  '88200 'nChannels * nSamplesPerSec * (wBitsPerSample / 8)
    w.nBlockAlign     = 4 ' nChannels * (wBitsPerSample / 8)
    w.wBitsPerSample  = 16 'wBitsPerSample
    w.dId             = "data"
    w.dLen            = Samples&*4 '-2500

    ww.wv=w

    p=VARPTR(ww.dta)

    FOR r& = 0 TO Samples&-1

      @p[r&*2+1] = SIN(pi2*r&*freq1/22050) * 30000 * SIN(10*(Samples&-r&)/22050) * SIN(pi2*r&*freq2/22050)
      @p[r&*2] = SIN(pi2*r&*freq1/22050) * 30000 * SIN(10*(r&/22050)) * SIN(pi2*r&*freq2/22050)

    NEXT

    'playsound BYVAL VARPTR(ww),0 ,%SND_MEMORY + %SND_ASYNC  'play from memory, one time and stop, +%SND_ASYNC = don't wait for it to finish

    playsound BYVAL VARPTR(ww),0 ,%SND_MEMORY + %SND_ASYNC + %SND_LOOP  '+%SND_LOOP = playing loops non-stop until reset
    'to stop looping play, Call playsound with null pointer:  playsound byval NULL, 0 ,%SND_MEMORY + %SND_LOOP



END SUB



'-----------------------------------------------------------------------------
'Load Hand Mouse Cursor array
'-----------------------------------------------------------------------------
FUNCTION HandCur(AndArray() AS BYTE, XorArray() AS BYTE)AS LONG
 LOCAL Counter AS LONG

 FOR Counter = 1 TO 128
   AndArray(Counter) = VAL("&H" & READ$(Counter))
 NEXT
 FOR Counter = 1 TO 128
   XorArray(Counter) = VAL("&H" & READ$(Counter + 128))
 NEXT

 'And Array             'bit = 0 = on , bit = 1 = off   '0E = low=0, high=E
 DATA ff, ff, ff, ff
 DATA f9, ff, ff, ff
 DATA f0, ff, ff, ff
 DATA f0, ff, ff, ff
 DATA f0, ff, ff, ff
 DATA f0, ff, ff, ff
 DATA f0, 24, ff, ff
 DATA f0, 00, 7f, ff
 DATA c0, 00, 7f, ff
 DATA 80, 00, 7f, ff
 DATA 80, 00, 7f, ff
 DATA 80, 00, 7f, ff
 DATA 80, 00, 7f, ff
 DATA 80, 00, 7f, ff
 DATA c0, 00, 7f, ff
 DATA e0, 00, 7f, ff
 DATA f0, 00, ff, ff
 DATA f0, 00, ff, ff
 DATA f0, 00, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff


 'XOr Array             'bit = 0 = off , bit = 1 = on
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 06, 00, 00, 00
 DATA 06, 00, 00, 00
 DATA 06, 00, 00, 00
 DATA 06, 00, 00, 00
 DATA 06, 00, 00, 00
 DATA 06, db, 00, 00
 DATA 06, db, 00, 00
 DATA 36, db, 00, 00
 DATA 36, db, 00, 00
 DATA 37, ff, 00, 00
 DATA 3f, ff, 00, 00
 DATA 3f, ff, 00, 00
 DATA 1f, ff, 00, 00
 DATA 0f, ff, 00, 00
 DATA 07, fe, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00

END FUNCTION


'-----------------------------------------------------------------------------
'Load Crosshair Mouse Cursor array
'-----------------------------------------------------------------------------
FUNCTION CrossCur(AndArray() AS BYTE, XorArray() AS BYTE)AS LONG
 LOCAL Counter AS LONG

 FOR Counter = 1 TO 128
   AndArray(Counter) = VAL("&H" & READ$(Counter))
 NEXT
 FOR Counter = 1 TO 128
   XorArray(Counter) = VAL("&H" & READ$(Counter + 128))
 NEXT

'And Array             'bit = 0 = on , bit = 1 = off   '0E = low=0, high=E
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff

 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff

 DATA 00, 0E, f0, 00

 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff
 DATA ff, ff, ff, ff

 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff
 DATA ff, fe, ff, ff

 'XOr Array              'bit = 0 = off , bit = 1 = on
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00

 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00

 DATA ff, E0, 0f, ff

 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00
 DATA 00, 00, 00, 00

 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00
 DATA 00, 01, 00, 00


END FUNCTION


'*************************************************************************************

'File I/O
'**********************************************************************************************************************
FUNCTION LoadFile AS LONG

    LOCAL filenumber, FileExists, retval, hWnd AS LONG
    LOCAL sPath, sfilename AS STRING

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

    'get the number of paths
    GET filenumber,,nPath
    REDIM PathX(nPath),PathY(nPath),PathZ(nPath),_
          PathC(nPath),PathA(nPath) AS GLOBAL DOUBLE 'set arrays to number of paths

    'get the paths!
    GET filenumber,,PathX()
    GET filenumber,,PathY()
    GET filenumber,,PathZ()
    GET filenumber,,PathC()
    GET filenumber,,PathA()

    'get the number of indexes
    GET filenumber,,nIndex
    REDIM eXpos(nIndex),eYpos(nIndex),eOriginX(nIndex),eNormRdn(nIndex), _
          eNormRad(nIndex),eRotDeg(nIndex),eArc(nIndex) AS GLOBAL DOUBLE

    'get the index data!
    GET filenumber,,eXpos()
    GET filenumber,,eYpos()
    GET filenumber,,eOriginX()
    GET filenumber,,eNormRdn()
    GET filenumber,,eNormRad()
    GET filenumber,,eRotDeg()
    GET filenumber,,eArc()

    CLOSE filenumber

END FUNCTION


FUNCTION SaveFile(BYVAL RayPtr AS DWORD, BYVAL GFXPtr AS DWORD, BYVAL ScanPtr AS DWORD) AS LONG

    LOCAL nScan AS ScanVars POINTER, GFX AS GfxVars POINTER, Ray AS FociRay POINTER
    LOCAL SaveModel, filenumber, fileoffset, FileExists, retval, hWnd AS LONG
    LOCAL sPath, sfilename AS STRING

    Ray = RayPtr : GFX = GFXPtr : nScan = ScanPtr

    SaveModel = FALSE
    SaveModel = TRUE

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

    PUT filenumber,,nPath
    PUT filenumber,,PathX()
    PUT filenumber,,PathY()
    PUT filenumber,,PathZ()
    PUT filenumber,,PathC()
    PUT filenumber,,PathA()

    PUT filenumber,,nIndex
    PUT filenumber,,eXpos()
    PUT filenumber,,eYpos()
    PUT filenumber,,eOriginX()
    PUT filenumber,,eNormRdn()
    PUT filenumber,,eNormRad()
    PUT filenumber,,eRotDeg()
    PUT filenumber,,eArc()

    IF SaveModel THEN
       PUT filenumber,,@Ray
       PUT filenumber,,@GFX
       PUT filenumber,,@nScan
    END IF

    CLOSE filenumber

END FUNCTION

SUB PlotProbe(BYVAL xPos AS DOUBLE,BYVAL yPos AS DOUBLE,BYVAL zPos AS DOUBLE,BYVAL aPos AS DOUBLE,_
              BYVAL RayPtr AS DWORD,BYVAL ScanPtr AS DWORD,BYVAL GfxPtr AS DWORD, BYVAL QPtr AS DWORD)

    'transducer plots derived from motor x,y,z position only, associated plots are projected from motor position
    'zpos (rotational degreees), !! INCLUDES skew degree, if any.  To plot normal, subtract skew degrees from zpos degrees
    'xPos, yPos = center of Z-Axis Rotational, Transducer index must be aligned with center of rotation for proper operation

    LOCAL nScan AS ScanVars POINTER, GFX AS GfxVars POINTER, nRay AS FociRay POINTER, Quartic AS QuarticRay POINTER
    LOCAL pSkewRdn,zRdn,zRdn90,zRdnNoSkew,seg1,seg2,ang1,pCOS,pSIN,nCOS,nSIN,COS_ZRdn,SIN_ZRdn,qx,qy AS DOUBLE
    LOCAL fillprobe, Clr, pMethod AS LONG
    DIM x(16) AS LOCAL DOUBLE, y(16) AS LOCAL DOUBLE

    LOCAL A,B,C,D AS DOUBLE

    GFX = GfxPtr : nScan = ScanPtr  : nRay = RayPtr : Quartic = QPtr

    fillprobe = FALSE

    pSkewRdn = @nScan.SkewRdn
    zRdn = DegToRdn(zPos) MOD Rdn360
    zRdn90 = (zRdn + Rdn90) MOD Rdn360
    zRdnNoSkew =(DegToRdn(zPos) - pSkewRdn)  MOD Rdn360

    'most often used, do them 1 time
    COS_ZRdn = COS(zRdn) : SIN_ZRdn = SIN(zRdn)

    '@GFX.probeClr = %RGB_LIGHTYELLOW   'probe perimeter case color
    '@GFX.probefillClr = %RGB_ORANGE    'probe fill color
    '@GFX.TngtLineClr = %RGB_RED        'tangent line color for/if probe skew
    '@GFX.NormLineClr = %RGB_RED        'normal line color for/if probe skew
    '@GFX.CentLineClr = %RGB_WHITE      'probe center line color, probe beam
    '@GFX.IdxLineClr = %RGB_WHITE       'probe index line color
    '@GFX.offsetBallClr = %RGB_WHITE    'crosshair ball at offset color
    '@GFX.probeBallClr = %RGB_BLACK     'crosshair ball at probe center color
    '@GFX.ballRad = 0.200#              'meatball Rad

    @GFX.probefillClr = %RGB_LIGHTSTEELBLUE
    @GFX.probeClr = %RGB_LIGHTSTEELBLUE

    'Locate x & y position of the near and far sides of the transducer case.
    '***************************************************************************************************************************
    'Locate near side of transducer case width, at current scan degree position, projected from cross hair 0-180 line
    x(1) = xPos - @nScan.ProbeWidth * half * COS(zRdn90) : y(1) = yPos - @nScan.ProbeWidth * half * SIN(zRdn90)
    'Locate far side of transducer case width, at current scan degree postion, projected from cross hair 0-180 line
    x(2) = xPos + @nScan.ProbeWidth * half * COS(zRdn90) : y(2) = yPos + @nScan.ProbeWidth * half * SIN(zRdn90)

    'Locate x & y position of the (4) transducer case corners
    '***************************************************************************************************************************
    'Leftside, front probe corner, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(3) = x(1) - @nScan.ProbeIdx * COS_zRdn : y(3) = y(1) - @nScan.ProbeIdx * SIN_zRdn
    'Rightside, front probe corner, along +/- 90 degrees from NORMAL axis,+ offset from projected x(2) & y(2)
    x(4) = x(2) - @nScan.ProbeIdx * COS_zRdn : y(4) = y(2) - @nScan.ProbeIdx * SIN_zRdn
    'Leftside, back probe corner, along +/-90 degrees from Normal axis,+ offset from projected x(1) & y(1)
    x(5) = x(1) + (@nScan.ProbeLen - @nScan.ProbeIdx) * COS_zRdn : y(5) = y(1) + (@nScan.ProbeLen - @nScan.ProbeIdx) * SIN_zRdn
    'Rightside, back probe corner, along +/-90 degrees from Normal axis,+offset projected from x(2) & y(2)
    x(6) = x(2) + (@nScan.ProbeLen - @nScan.ProbeIdx) * COS_zRdn : y(6) = y(2) + (@nScan.ProbeLen - @nScan.ProbeIdx) * SIN_zRdn
    'Center of transducer case length
    x(8) = xPos + (@nScan.ProbeLen*half-@nScan.ProbeIdx) * COS_zRdn : y(8) = yPos + (@nScan.ProbeLen*half-@nScan.ProbeIdx) * SIN_zRdn

    'Draw the transducer
    '********************************************************************************************************************
    GRAPHIC WIDTH 3& 'set line width to 3

    'draw transducer sides x4 (rectangle)
    'graphic set pos(y(3),x(3))

    GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@GFX.probeClr  'draw probe side 1
    GRAPHIC LINE STEP -(y(6),x(6)),@GFX.probeClr       'draw probe side 2
    GRAPHIC LINE STEP -(y(5),x(5)),@GFX.probeClr       'draw probe side 3
    GRAPHIC LINE STEP -(y(3),x(3)),@GFX.probeClr       'draw probe side 4

    'draw transducer sides x4 (rectangle)
    'GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@GFX.probeClr  'draw probe side 1
    'GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),@GFX.probeClr  'draw probe side 2
    'GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),@GFX.probeClr  'draw probe side 3
    'GRAPHIC LINE(y(4),x(4))-(y(6),x(6)),@GFX.probeClr  'draw probe side 4

    GRAPHIC WIDTH 1& 'set line width back to 1

    'draw meatball on transducer case, located on center of UT beam origin
    x(11) = xPos - @GFX.ballRad : y(11) = yPos - @GFX.ballRad 'transducer x,y position
    x(12) = xPos + @GFX.ballRad : y(12) = yPos + @GFX.ballRad 'transducer x,y position
    GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @GFX.probeClr

    IF fillprobe THEN
       'paint in all (4) corners of the transducer case
       seg2 = GetSegLen((x(3)-x(8)),(y(3)-y(8)))
       seg1 = seg2 - (gWIN.PixelR(1)*4)
       ang1 = ArcCos( (@nScan.ProbeLen*half)/seg2 )
       pCOS = Seg1*COS(zRdn+ang1) : pSIN = Seg1*SIN(zRdn+ang1)
       nCOS = Seg1*COS(zRdn-ang1) : nSIN = Seg1*SIN(zRdn-ang1)
       'GRAPHIC SET MIX %MIX_MERGESRC  'set color mix transparent with background
       y(3) = y(8) + pSIN : x(3) = x(8) + pCOS : GRAPHIC PAINT (y(3), x(3)), @GFX.probefillClr, @GFX.probeClr, 6'5
       y(3) = y(8) - pSIN : x(3) = x(8) - pCOS : GRAPHIC PAINT (y(3), x(3)), @GFX.probefillClr, @GFX.probeClr, 6'5
       y(3) = y(8) + nSIN : x(3) = x(8) + nCOS : GRAPHIC PAINT (y(3), x(3)), @GFX.probefillClr, @GFX.probeClr, 6'5
       y(3) = y(8) - nSIN : x(3) = x(8) - nCOS : GRAPHIC PAINT (y(3), x(3)), @GFX.probefillClr, @GFX.probeClr, 6'5
       'GRAPHIC SET MIX %MIX_COPYSRC  'set color mix back to default mode  - draw over existing image pixels
    END IF

    'draw line through transducer centerline, parallel and aligned with UT Beam axis
    x(11) = x(8) + (@nScan.ProbeLen * half) * COS_zRdn : y(11) = y(8) + (@nScan.ProbeLen * half) * SIN_zRdn 'aft x,y
    x(12) = x(8) - (@nScan.ProbeLen * half) * COS_zRdn : y(12) = y(8) - (@nScan.ProbeLen * half) * SIN_zRdn 'fore x,y
    GRAPHIC LINE(y(11),x(11))-(y(12),x(12)), @GFX.CentLineClr

    GRAPHIC LINE(y(1),x(1))-(y(2),x(2)), @GFX.IdxLineClr  'draw index line, transducer width

    'TRANSDUCER IS NOW COMPLETELY DRAWN, DONE!!

    '***********************************************************************************************************
    'Draw CrossHair lines in reference to WELD Axis. If no SKEW or OFFSET, WELD and BEAM axis lines are the same!
    '***********************************************************************************************************
    'beam intersection point on weld at current cross hair position
    IF @nScan.skewOffset THEN 'x(7),Y(7) = center index of probe
       x(13) = xPos-@nScan.skewOffset*COS_zRdn : y(13) = yPos-@nScan.skewOffset*SIN_zRdn
    ELSE : x(13) = xPos : y(13) = yPos
    END IF

    'rounded for more accurate fp compares, especially when approaching zero,e.g.,IF .0000000000001 = 0 THEN
    x(7) = ROUND(x(13),10) : y(7) = ROUND(y(13),10)                    'evaluates FALSE; TRUE when rounded!!

    pMethod = 4

    SELECT CASE pMethod  'plot focal line to focus point, UT Beam
       CASE 1
         'Method #1
         'find x(11), y(11) & x(12), y(12): needs only xPos and yPos to solve, semi-accurate, has focal point jitter
         'plot line from ellipse focal center (Y=0) through PROBE CENTER ONLY, not to outboard radius edge
         IF y(7) = 0 THEN  '@ 0 or 180 degrees  'added rounding 6/21/16    '5
            y(11)=0: x(11)= IIF(X(7)> 0,x(7)+@nScan.ProbeLen,x(7)-@nScan.ProbeLen)
            y(12)=0: x(12)= IIF(X(7)> 0,ABS(@GFX.TngtLine),-ABS(@GFX.TngtLine))
         ELSEIF ABS(y(7)) < 0.500# THEN      'approximate when calculating line length based on steep angle
            x(13) = ABS(x(7)) - ABS(@GFX.TngtLine) : y(13) = ABS(y(7))
            x(14) = SQR(x(13)^2 + y(13)^2)   'length of line irrelevent of angle A^2+B^2=C^2
            x(12) = x(7) - x(14) * COS(zRdnNoSkew) : y(12) = y(7) - x(14) * SIN(zRdnNoSkew)
            x(11) = x(7) + @nScan.ProbeLen * COS(zRdnNoSkew) : y(11) = y(7) + @nScan.ProbeLen * SIN(zRdnNoSkew)
         ELSE
            @GFX.CentLine = ABS(y(7)/SIN(zRdnNoSkew))
            x(12) = x(7) - @GFX.CentLine * COS(zRdnNoSkew)   : y(12) = y(7) - @GFX.CentLine * SIN(zRdnNoSkew)  'fore x,y
            x(11) = x(7) + @nScan.ProbeLen * COS(zRdnNoSkew) : y(11) = y(7) + @nScan.ProbeLen * SIN(zRdnNoSkew)'aft  x,y
         END IF
       CASE 2
         'Method #2
         'find x(11), y(11) & x(12), y(12): needs xPos,yPos and aPos to solve, semi-accurate, has focal point jitter
         'plot line from focal center (Y=0) through PROBE CENTER to EXACT OUTBOARD RADIUS EDGE
         IF y(7) = 0 THEN  '@ 0 or 180 degrees  'added rounding 6/21/16    '5
            y(12)=0: x(12)= IIF(X(7)> 0,ABS(@GFX.TngtLine),-ABS(@GFX.TngtLine))
         ELSEIF ABS(y(7)) < 0.500# THEN      'approximate when calculating line length based on steep angle
            x(13) = ABS(x(7)) - ABS(@GFX.TngtLine) : y(13) = ABS(y(7))
            x(14) = SQR(x(13)^2 + y(13)^2)   'length of line irrelevent of angle A^2+B^2=C^2
            x(12) = x(7) - x(14) * COS(zRdnNoSkew) : y(12) = y(7) - x(14) * SIN(zRdnNoSkew)
         ELSE
            @GFX.CentLine = ABS(y(7)/SIN(zRdnNoSkew))
            x(12) = x(7) - @GFX.CentLine * COS(zRdnNoSkew): y(12) = 0 'y(7) - @GFX.CentLine * SIN(zRdnNoSkew)  'fore x,y
         END IF
         x(11) = x(7) + (@nScan.yRadius-aPos) * COS(zRdnNoSkew)
         y(11) = y(7) + (@nScan.yRadius-aPos) * SIN(zRdnNoSkew)
       CASE 3  'doesn't work with travel to opposite side of weld. In practice, never happens.
         'Method #3  note: quartic solver has uncertainty, jitter, in a few areas, accurate in all other respects
         'find x(11), y(11) & x(12), y(12):  only needs xPos and yPos to solve, more math but only needs x & y pos to solve all
         'plot line from EXACT focal center (Y12=0) through PROBE CENTER to EXACT OUTBOARD RADIUS EDGE
         qx = x(7) : qy = y(7)
         GetQuartic(qx, qy, nRay) 'find the x,y UT beam coordinates along the perimeter
         GetFoci(qx, qy, RayPtr)  'get the focal laws at x,y position
         x(11) = qx + (@nScan.yRadius) * COS(zRdnNoSkew) : y(11) = qy + (@nScan.yRadius) * SIN(zRdnNoSkew)
         x(12) = @nRay.nOriginX : y(12) = 0
       CASE ELSE 'works best, only downside: needs x,y and aPos, method #3 above needs only x and yPos to solve
         'Method #4
         'find x(11), y(11) & x(12), y(12): needs xPos,yPos,aPos to solve, ultra-accurate
         'plot line from EXACT focal center (Y12=0) through PROBE CENTER to EXACT OUTBOARD RADIUS EDGE
         'getfoci at zero azimuth only, returns far focus due to floating point inaccuracies > ~13 places, fine at 10
         x(13) = ROUND(x(7) - aPos * COS(zRdnNoSkew),10) : y(13) = ROUND(y(7) - aPos * SIN(zRdnNoSkew),10)
         x(11) = x(13) + @nScan.yRadius * COS(zRdnNoSkew): y(11) = y(13) + @nScan.yRadius * SIN(zRdnNoSkew)
         GetFoci(x(13), y(13), RayPtr): x(12) = @nRay.nOriginX : y(12) = 0
    END SELECT

    IF @nScan.skewOffset OR pSkewRdn THEN 'focus, draw solid line
       GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@GFX.IdxLineClr   '%RGB_HOTPINK '@GFX.IdxLineClr
    ELSE  'beam, draw dotted line ' 0:Solid(default), 1:Dash, 2:Dot, 3:DashDot, 4:DashDotDot
       GRAPHIC STYLE 2 : GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@GFX.IdxLineClr: GRAPHIC STYLE 0
    END IF

    'draw circle at focus target point
    GRAPHIC ELLIPSE(y(12)-@GFX.ballRad,x(12)-@GFX.ballRad)-(y(12)+@GFX.ballRad,x(12)+@GFX.ballRad),@GFX.offsetBallClr

    '************************************************************************************************
    'Beam Axis - Extra plots for skew or offset
    '************************************************************************************************
    IF (@nScan.skewOffset = 0) AND pSkewRdn THEN   'special case: draw line probe center, parallel and aligned with UT Beam axis
       x(11) = x(8) - @nScan.ProbeIdx * COS_zRdn : y(11) = y(8) - @nScan.ProbeIdx * SIN_zRdn 'aft  x,y
       x(12) = x(11)- @GFX.CentLine * COS_zRdn : y(12) = y(11)- @GFX.CentLine * SIN_zRdn 'projected forward x,y
       GRAPHIC STYLE 2 :GRAPHIC LINE(y(11),x(11))-(y(12),x(12)), @GFX.CentLineClr: GRAPHIC STYLE 0  'UT beam, draw dotted line
    END IF

    IF @nScan.skewOffset THEN  'draw meatball on focal line at UT beam intercept point and UT beam to focal line, dotted line
       x(11) = x(7) - @GFX.ballRad : y(11) = y(7) - @GFX.ballRad ' x,y upper-left
       x(12) = x(7) + @GFX.ballRad : y(12) = y(7) + @GFX.ballRad ' x,y Lower-right
       GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @GFX.offsetBallClr
       GRAPHIC STYLE 2: GRAPHIC LINE(y(7),x(7))-(yPos,xPos), @GFX.CentLineClr : GRAPHIC STYLE 0
    END IF

END SUB


'ORIGINAL, additional Mods
SUB DrawScanModel(BYVAL RayPtr AS DWORD, BYVAL GFXptr AS DWORD, BYVAL Scanptr AS DWORD)

    'user set colors for model
    'GFX.eStartClr =  scan start radial line color
    'GFX.eEndClr =    scan end radial line color
    'GFX.eExtraClr =  scan extra radial line color
    'GFX.eRadialClr = all other scan radial scan line
    'GFX.eInsideClr = center radial normal lines
    'GFX.eOutPClr =   outer perimeter line color
    'GFX.eWeldClr =   weld radial line color
    'GFX.eWeldPClr =  weld perimeter line color
    'GFX.eHAZClr =    HAZ radial line color
    'GFX.eHAZPClr =   HAZ perimeter line color

    LOCAL GFX AS GfxVars POINTER, nScan AS ScanVars POINTER, Ray AS FociRay POINTER
    LOCAL cosA, sinA, yPos, xPos, yPos1, xPos1, yPos2, xPos2 AS DOUBLE
    LOCAL Clr, yIndexE, yIndex, xIndexS, xIndexE, xIndex, index AS LONG

    LOCAL yOff1,yOff2,xOff1,xOff2 AS DOUBLE

    GFX = GFXptr : nScan = Scanptr : Ray = RayPtr

    DIM pLoc(4) AS LOCAL DOUBLE 'perimeter location
    pLoc(0) = -(@nScan.WeldHaz*2.00# + @nScan.WeldWidth)  'located on the negative (inboard) side of the referenced perimeter
    pLoc(1) = -(@nScan.WeldHaz + @nScan.WeldWidth)        'located on the negative (inboard) side of the referenced perimeter
    pLoc(2) = -(@nScan.WeldHaz)                          'located on the negative (inboard) side of the referenced perimeter
    pLoc(3) = 0                                         'zero reference, located at outer HAZ edge
    pLoc(4) = @nScan.yRadius                            'normally located on the positive (outboard)side of the referenced perimeter

    DIM pClr(4) AS LONG
    pClr(0) = @GFX.eInsideClr'inner Basemetal
    pClr(1) = @GFX.eHAZClr   'inner HAZ
    pClr(2) = @GFX.eWeldClr  'Weld
    pClr(3) = @GFX.eHAZClr   'outer HAZ
    pClr(4) = @GFX.eOutPClr  'outer Basemetal

    '***********************************************************************************************************
    'DRAW Linear x index lines
    '***********************************************************************************************************
    xIndexE = @Ray.Index360-1

    FOR xIndex = xIndexE TO 0 STEP -1 'step -1 to connect typical sliver index chord to 0
        cosA = COS(eNormRdn(xIndex)): sinA = SIN(eNormRdn(xIndex))
        GRAPHIC SET POS(0, eOriginX(xIndex))
        FOR yIndex = 0 TO 4
            xPos = eXpos(xIndex)+pLoc(yIndex)*cosA : yPos = eYpos(xIndex)+pLoc(yIndex)*sinA
            GRAPHIC LINE STEP -(yPos,xPos),pClr(yIndex)
        NEXT
    NEXT

    GRAPHIC STYLE 2 'set dotted line

    'draw scan start marker: dotted line
    xPos2 = eXpos(0)+ @nScan.yRadius*COS(eNormRdn(0))
    yPos2 = eYpos(0)+ @nScan.yRadius*SIN(eNormRdn(0))
    GRAPHIC LINE (eYpos(0),eXpos(0))-(yPos2,xPos2),@GFX.eStartClr 'scan start degree position

    'draw scan end marker: dotted line
    xPos2 = eXpos(@nScan.xIndexEnd)+ @nScan.yRadius*COS(eNormRdn(@nScan.xIndexEnd))
    yPos2 = eYpos(@nScan.xIndexEnd)+ @nScan.yRadius*SIN(eNormRdn(@nScan.xIndexEnd))  'Outer perimeter: stroke end
    GRAPHIC LINE(eYpos(@nScan.xIndexEnd),eXpos(@nScan.xIndexEnd))-(yPos2,xPos2),@GFX.eEndClr 'scan end degree position

    'draw extra index markers, if any
    IF @nScan.xIndexPlus THEN
       xIndexS = @nScan.xIndexEnd-1 : xIndexE = @Ray.Index360
       FOR index = xIndexS TO xIndexE STEP -1
           xPos2 = @nScan.yRadius*COS(eNormRdn(index))+ eXpos(index)
           yPos2 = @nScan.yRadius*SIN(eNormRdn(index))+ eYpos(index)
           GRAPHIC LINE (eYpos(index),eXpos(index))-(yPos2,xPos2),@GFX.eExtraClr 'scan overlap lines
       NEXT
    END IF

    GRAPHIC STYLE 0 'set back to solid line

    '***********************************************************************************************************
    'DRAW Curved perimeters: Base Metal,HAZ and Weld
    '***********************************************************************************************************
    xIndexE = @Ray.Index360-1 : Clr = @GFX.eHAZClr

    FOR yIndex = 0 TO 4  'draw standard perimeters

        IF yIndex = 4 THEN Clr = @GFX.eRadialClr  'change color for outer perimeter

        'set each start postion to one index before zero
        xPos1 = eXpos(xIndexE)+ pLoc(yIndex)*COS(eNormRdn(xIndexE))
        yPos1 = eYpos(xIndexE)+ pLoc(yIndex)*SIN(eNormRdn(xIndexE))
        GRAPHIC SET POS (yPos1, xPos1)

        'draw the current perimeter, 0 to 360
        FOR xIndex = 0 TO xIndexE
            xPos2 = eXpos(xIndex)+ pLoc(yIndex)*COS(eNormRdn(xIndex))
            yPos2 = eYpos(xIndex)+ pLoc(yIndex)*SIN(eNormRdn(xIndex))
            GRAPHIC LINE STEP -(yPos2,xPos2), Clr   'Chord: Draw border
        NEXT

    NEXT

    'exit sub

    '===============================================================================
    'Extra's:  Draw markers and Identifiers
    '===============================================================================
    xPos1 = -(@nScan.yRadius+@Ray.MajorRad) : xPos2 = (@nScan.yRadius+@Ray.MajorRad)
    yPos1 = -(@nScan.yRadius+@Ray.MinorRad) : yPos2 = (@nScan.yRadius+@Ray.MinorRad)


    'draw dotted lines @ 0:360, 90, 180, 360 degree
    GRAPHIC STYLE 2 'set for dotted line
    GRAPHIC LINE (0,0)-(0,xPos1),%RGB_WHITE : GRAPHIC LINE (0,0)-(0,xPos2),%RGB_WHITE
    GRAPHIC LINE (0,0)-(yPos1,0),%RGB_WHITE : GRAPHIC LINE (0,0)-(yPos2,0),%RGB_WHITE
    GRAPHIC STYLE 0 'set for solid line

    DIM xTxt(12) AS LOCAL SINGLE

    DIM yTxt(12) AS LOCAL SINGLE

    DIM pTxt(12) AS LOCAL STRING

    LOCAL pixOff AS SINGLE

    LOCAL pLoc AS LONG

    'print text at degree locations
    pTxt(0) = "0:360"
    pTxt(1) = "180"
    pTxt(2) = "360:0"
    pTxt(3) = "270"
    pTxt(4) = "90"

    pixOff = 40 * gWIN.PixelR(0)        '5 pixel space offset

    ' Set red foreground and blue background color.

    ' GRAPHIC COLOR %RED

    IF @nScan.xNear THEN    'X-Axis on near side of of nozzle
       gText(pTxt(1), 0, xPos1, 12, pixOff, 0, 0) '180
       gText(pTxt(2), 0, xPos2,  6, pixOff, 0, 0) '360 : 0
       gText(pTxt(3), yPos1, 0,  9, pixOff, 0, 900) '270
       gText(pTxt(4), yPos2, 0,  3, pixOff, 0, 900) '90

    ELSE                    'X-Axis on far side of nozzle
       gText(pTxt(1), 0, xPos1,  6, pixOff, 1, 0) '180
       gText(pTxt(0), 0, xPos2, 12, pixOff, 1, 0) '0 : 360
       gText(pTxt(3), yPos1, 0,  3, pixOff, 1, 900) '270
       gText(pTxt(4), yPos2, 0,  9, pixOff, 1, 900) '90
    END IF
   ' GRAPHIC COLOR %white



   LOCAL x1,y1,x2,y2,iStep AS DOUBLE 'single

    'draw scale edge lines on model
    'xPos1 = -(@nScan.yRadius+@Ray.MajorRad)-1 : xPos2 = (@nScan.yRadius+@Ray.MajorRad)+1
    'yPos1 = -(@nScan.yRadius+@Ray.MinorRad)-1 : yPos2 = (@nScan.yRadius+@Ray.MinorRad)+1

    xPos1 = -(@nScan.yRadius+@Ray.MajorRad): xPos2 = (@nScan.yRadius+@Ray.MajorRad)
    yPos1 = -(@nScan.yRadius+@Ray.MinorRad): yPos2 = (@nScan.yRadius+@Ray.MinorRad)

    GRAPHIC LINE (yPos1,xPos1)-(yPos1,xPos2),%RGB_WHITE '270 Degree, Vertical line
    GRAPHIC LINE (yPos1,xPos1)-(yPos2,xPos1),%RGB_WHITE '180 Degree, Horizontal
    GRAPHIC LINE (yPos2,xPos1)-(yPos2,xPos2),%RGB_WHITE '90  Degree, Vertical
    GRAPHIC LINE (yPos1,xPos2)-(yPos2,xPos2),%RGB_WHITE '0:360 Degree, Horizontal



    'Draw measurement scale
    '************************************************************************************************************

    LOCAL sHeight, sWidth, inches, tenths, hunds, thous AS DOUBLE
    LOCAL x,y AS DOUBLE
    LOCAL InchStep, iCtr, pMin,pMin2,pMin5 AS LONG

    'calculate current screen size, inches
    sWidth = gWIN.yPix(0) * gWIN.PixelR(0)  '= width of the screen in inches
    sHeight = gWIN.xPix(0) * gWIN.PixelR(0) '= height of the screen in inches

    'get scale spatial values that fit current zoom
    inches = FIX(1.000 / gWIN.PixelR(0)) 'number of pixels for 1.00"
    tenths = FIX(0.100 / gWIN.PixelR(0)) 'number of pixels for .100"
    hunds  = FIX(0.010 / gWIN.PixelR(0)) 'number of pixels for .010"
    thous  = FIX(0.001 / gWIN.PixelR(0)) 'number of pixels for .001"

    pMin = 24 : pMin2 = pMin/2 : pmin5 = pMin/5 'pixel spatial resolution

    'even scale resolutions
    IF thous >= pMin THEN
       iStep = .001
    ELSEIF thous >= pMin2 THEN
       iStep = .002
    ELSEIF thous >= pMin5 THEN
       iStep = .005

    ELSEIF hunds >= pMin THEN
       iStep = .01
    ELSEIF hunds >= pMin2 THEN
       iStep = .02
    ELSEIF hunds >= pMin5 THEN
       iStep = .05

    ELSEIF tenths >= pMin THEN
       iStep = .10
    ELSEIF tenths >= pMin2 THEN
       iStep = .20
    ELSEIF tenths >= pMin5 THEN
       iStep = .50

    ELSEIF inches >= pMin THEN
       iStep = 1.00
    ELSEIF inches >= pMin2 THEN
       iStep = 2.00
    ELSEIF inches >= pMin5 THEN
       iStep = 5.00

    ELSE
       EXIT SUB
    END IF

    LOCAL clk3, clk6, clk9, clk12, opp AS LONG

    'Print X-Axis,  Vertical scale values
    pixOff = 20 * gWIN.PixelR(0) '20 pixel offset from print location

     'X Axis mounted near side of nozzle
    IF @nScan.xNear THEN
       clk9 = 9 : clk3 = 3 : clk12 = 12 : clk6 = 6 : opp = 0 : pTxt(2) = "0:X" : pTxt(3) = "X:0" : pTxt(4) = "0:Y" : pTxt(5) = "Y:0"
    ELSE
       clk9 = 3 : clk3 = 9 : clk12 = 6 : clk6 = 12 : opp = 1 : pTxt(3) = "0:X" : pTxt(2) = "X:0" : pTxt(5) = "0:Y" : pTxt(4) = "Y:0"
    END IF

    FOR xPos = -iStep TO xPos1 STEP -iStep        'print 0 to max negative side of scale
        pTxt(1) = USING$("##.###",xPos)
        gText(pTxt(1), yPos2, xPos, clk3, pixOff, opp, 0) '900
        gText(pTxt(1), yPos1, xPos, clk9, pixOff, opp, 0) '1, 0) '900
    NEXT

    FOR xPos = iStep TO xPos2 STEP iStep         'print 0 to max positive side of scale
        pTxt(1) = USING$("##.###",xPos)
        gText(pTxt(1), yPos2, xPos, clk3, pixOff, opp, 0) '900
        gText(pTxt(1), yPos1, xPos, clk9, pixOff, opp, 0) '1, 0) '900
    NEXT

    'X:0
    gText(pTxt(2), yPos2, 0, clk3, pixOff, opp, 0) '900
    gText(pTxt(3), yPos1, 0, clk9, pixOff, opp, 0) '1, 0) '900


    'Draw X-Axis, vertical scale markers
    pixOff = 15 * gWIN.PixelR(0)    'major scale

    FOR xPos = 0 TO xPos1 STEP -iStep
        GRAPHIC LINE (yPos1,xPos)-(yPos1-pixOff,xPos),%RGB_WHITE  '270 degree
        GRAPHIC LINE (yPos2,xPos)-(yPos2+pixOff,xPos),%RGB_WHITE  '90  degree
    NEXT

    FOR xPos = 0 TO xPos2 STEP iStep
        GRAPHIC LINE (yPos1,xPos)-(yPos1-pixOff,xPos),%RGB_WHITE  '270 degree
        GRAPHIC LINE (yPos2,xPos)-(yPos2+pixOff,xPos),%RGB_WHITE  '90  degree
    NEXT

    pixOff = 10 * gWIN.PixelR(0)    'minor scale

    FOR xPos = 0 TO xPos1 STEP (-iStep * .5)
        GRAPHIC LINE (yPos1,xPos)-(yPos1-pixOff,xPos),%RGB_WHITE '270 degree
        GRAPHIC LINE (yPos2,xPos)-(yPos2+pixOff,xPos),%RGB_WHITE '90 degree
    NEXT

    FOR xPos = 0 TO xPos2 STEP (iStep * .5)
        GRAPHIC LINE (yPos1,xPos)-(yPos1-pixOff,xPos),%RGB_WHITE  '270 degree
        GRAPHIC LINE (yPos2,xPos)-(yPos2+pixOff,xPos),%RGB_WHITE '90 degree
    NEXT

    '******************************************************************************

    'Print Y-Axis,  Horizontal scale values
    pixOff = 20 * gWIN.PixelR(0) '20 pixel offset from print location

    FOR yPos = -iStep TO yPos1 STEP -iStep    'print 0 to max negative side of scale
        pTxt(1) = USING$("##.###",yPos) 'any blank decimal left (###.), a space is inserted, or 0 if right of decimal
        gText(pTxt(1), yPos, xPos2, clk6,  pixOff, opp, 2700)
        gText(pTxt(1), yPos, xPos1, clk12, pixOff, opp, 2700)
    NEXT

    FOR yPos = iStep TO yPos2 STEP iStep     'print 0 to max positive side of scale
        pTxt(1) = USING$("##.###",yPos)
        gText(pTxt(1), yPos, xPos2, clk6,  pixOff, opp, 2700)
        gText(pTxt(1), yPos, xPos1, clk12, pixOff, opp, 2700)
    NEXT

    'Y:0
    gText(pTxt(4), 0, xPos2, clk6,  pixOff, opp, 2700)
    gText(pTxt(5), 0, xPos1, clk12, pixOff, opp, 2700)


    'Draw Y-Axis,  horizontal scale markers
    pixOff = 15 * gWIN.PixelR(0)    'major scale

    FOR yPos = 0 TO yPos1 STEP -iStep
        GRAPHIC LINE (yPos,xPos1)-(yPos,xPos1-pixOff),%RGB_WHITE '180
        GRAPHIC LINE (yPos,xPos2)-(yPos,xPos2+pixOff),%RGB_WHITE '360:0

    NEXT

    FOR yPos = 0 TO yPos2 STEP iStep
        GRAPHIC LINE (yPos,xPos1)-(yPos,xPos1-pixOff),%RGB_WHITE '180
        GRAPHIC LINE (yPos,xPos2)-(yPos,xPos2+pixOff),%RGB_WHITE '360:0
    NEXT

    pixOff = 10 * gWIN.PixelR(0)    'minor scale

    FOR yPos = 0 TO yPos1 STEP (-iStep * .5)
        GRAPHIC LINE (yPos,xPos1)-(yPos,xPos1-pixOff),%RGB_WHITE '180
        GRAPHIC LINE (yPos,xPos2)-(yPos,xPos2+pixOff),%RGB_WHITE '360:0
    NEXT

    FOR yPos = 0 TO yPos2 STEP (iStep * .5)
        GRAPHIC LINE (yPos,xPos1)-(yPos,xPos1-pixOff),%RGB_WHITE '180
        GRAPHIC LINE (yPos,xPos2)-(yPos,xPos2+pixOff),%RGB_WHITE '360:0
    NEXT

    EXIT SUB


    IF @nScan.AxialRaster THEN EXIT SUB 'exit out if axial raster

    '***********************************************************************************************************
    'DRAW Curved Y-Axis Index chords: ! Circ Beam only
    '***********************************************************************************************************
    GRAPHIC STYLE 4 'set dotted line
    xIndexE=@Ray.Index360-1:  '-1: draw typical sliver index located at -1 index from 0
    yIndexE=((@nScan.yEnd-@nScan.yBegin)/@nScan.yIndexInc) '-1 '-1:outside perimeter already drawn above.

    FOR yIndex = 0 TO yIndexE

        'get y axis position
        yPos = ROUND(@nScan.yBegin + @nScan.yIndexInc*yIndex,10)

        'set plot zone color
        SELECT CASE yPos
            CASE >  pLoc(3):Clr = @GFX.eRadialClr 'outer basemetal
            CASE => pLoc(2):Clr = @GFX.eHAZClr    'outer HAZ
            CASE >  pLoc(1):Clr = @GFX.eWeldClr   'weld
            CASE => pLoc(0):Clr = @GFX.eHAZClr    'inner HAZ
            CASE ELSE      :Clr = @GFX.eRadialClr 'inner basemetal
        END SELECT

        'set plot starting postion
        xPos1 = yPos*COS(eNormRdn(xIndexE))+ eXpos(xIndexE)
        yPos1 = yPos*SIN(eNormRdn(xIndexE))+ eYpos(xIndexE)
        GRAPHIC SET POS (yPos1, xPos1)

        'draw the current y index perimeter, chords
        FOR xIndex = 0 TO xIndexE 'go 0-360
            xPos2 = yPos*COS(eNormRdn(xIndex))+ eXpos(xIndex)
            yPos2 = yPos*SIN(eNormRdn(xIndex))+ eYpos(xIndex)
            GRAPHIC LINE STEP -(yPos2,xPos2), Clr     'Chord: Draw index chord
        NEXT

    NEXT

    GRAPHIC STYLE 0 'set back to solid line

END SUB


SUB gText(BYVAL pTxt AS STRING,BYVAL yPos AS SINGLE,BYVAL xPos AS SINGLE, BYVAL pLoc AS LONG, _
          BYVAL pOffset AS SINGLE, BYVAL opp AS LONG, BYVAL Angle AS LONG)

        LOCAL yTxt, xTxt, yMid, xMid, yOffTxt, xOffTxt AS SINGLE

        LOCAL sfont AS LONG

        FONT NEW "Times New Roman", 10, 0, 0, 0, Angle TO sFont

        GRAPHIC SET FONT sFont

        IF Angle THEN
           GRAPHIC TEXT SIZE pTxt TO xTxt,yTxt
        ELSE
           GRAPHIC TEXT SIZE pTxt TO yTxt,xTxt
        END IF

        yMid = yTxt*0.50 : xMid = xTxt*0.50 : xOffTxt = pOffset+xTxt : yOffTxt = pOffset+yTxt

        IF Angle THEN

          IF opp THEN
             pOffset = -pOffset : yMid = -yMid : xMid = -xMid
          ELSE:
             yMid = yMid  : xMid = xMid  : xOffTxt = -xOffTxt : yOffTxt = -yOffTxt
          END IF

        ELSE

          IF opp THEN
             pOffset = -pOffset
          ELSE:
             yMid = -yMid : xMid = -xMid : xOffTxt = -xOffTxt : yOffTxt = -yOffTxt
          END IF

        END IF


        SELECT CASE pLoc
           CASE 12 '12 o'clock = above graphics
             yPos += yMid : xPos += xOffTxt
           CASE 6 '6 o'clock  = below graphics
             yPos += yMid : xPos += pOffset
           CASE 3 '3 o'clock = right of graphics
             yPos += pOffset
             xPos += xMid
           CASE 9 '9 o'clock = left of graphics
             yPos += yOffTxt : xPos += xMid
        END SELECT

        GRAPHIC SET POS(yPos,xPos)

        GRAPHIC PRINT pTxt

        FONT END sFont 'erase the temporary font

        GRAPHIC SET FONT gFont(fontNum) 'set back to current Font

END SUB


SUB GetFoci(BYVAL ePosX AS DOUBLE, BYVAL ePosY AS DOUBLE, BYVAL RayPtr AS DWORD)

    LOCAL Ray AS FociRay POINTER : Ray = RayPtr ' Set the pointer from the DWORD param

    '--------------------------------------------------------------------------------------------------------
    ' Get FOCUS triangle parameters, at current chord X,Y location. Use SSS(Side-Side-Side) triangle solution
    ' Includes both F1, F2 Rad angle and length, and angle between F1, F2 = included angle
    '--------------------------------------------------------------------------------------------------------
    @Ray.fXpos1 = @Ray.foci+ePosX   'ePosX = current chord point x" location measured from Foci1
    @Ray.fYpos1 = ePosY             'ePosY = current chord point y" location measured from nozzle centerline
    @Ray.fXpos2 = @Ray.foci-ePosX   'current chord point x" location measured from Foci2
    @Ray.fYpos2 = ePosY             'same as fYpos1
    'get length of sides (* length of Rad 1 and Rad 2 from foci, F1 and F2 *)
    @Ray.f1Rad = SQR(SQ(@Ray.fXpos1) + SQ(@Ray.fYpos1)) '= F1 Radius length(bSide)
    @Ray.f2Rad = SQR(SQ(@Ray.fXpos2) + SQ(@Ray.fYpos2)) '= F2 Radius length(cSide)
    'get Rad1 angle, measured from foci 1 {cos C = (a^2 + b^2 - c^2)/2ab}
    @Ray.f1Rdn = ArcCos((SQ(@Ray.foci2)+SQ(@Ray.f1Rad)-SQ(@Ray.f2Rad))/(2*@Ray.foci2*@Ray.f1Rad))
    'get Rad2 angle, measured from foci 2 {cos B = (c^2 + a^2 - b^2)/2ca}
    @Ray.f2Rdn = ArcCos((SQ(@Ray.f2Rad)+SQ(@Ray.foci2)-SQ(@Ray.f1Rad))/(2*@Ray.f2Rad*@Ray.foci2))
    'get included angle, between Rad1 and Rad2  {cos A = (b^2 + c^2 - a^2)/2bc}
    @Ray.fiaRdn = ArcCos((SQ(@Ray.f1Rad)+SQ(@Ray.f2Rad)-SQ(@Ray.foci2))/(2*@Ray.f1Rad*@Ray.f2Rad))

    'get normal FOCI angle, radians
    @Ray.nFiaRdn = @Ray.fiaRdn*half 'normal angle equals one-half the included angle between f1Rad and f2Rad
    @Ray.nF1Rdn = Rdn180 - (@Ray.f1Rdn + @Ray.nFiaRdn)'normal angle measured at X axis intersection on F1 side
    @Ray.nF2Rdn = Rdn180 - (@Ray.f2Rdn + @Ray.nFiaRdn)'normal angle measured at X axis intersection on F2 side
    @Ray.nF1x = (@Ray.f1Rad*SIN(@Ray.nFiaRdn))/SIN(@Ray.nF1Rdn) 'distance from F1 to tangent line intersection along X axis
    @Ray.nF1Rad = SQR(SQ(ABS(@Ray.fXpos1-@Ray.nF1x))+ SQ(ABS(@Ray.fYpos1))) 'length of tangent line measured from chord X,Y position to X axis line
    @Ray.nF2x = (@Ray.f2Rad*SIN(@Ray.nFiaRdn))/SIN(@Ray.nF2Rdn) 'distance from F2 to tangent line intersection along X axis
    @Ray.nF2Rad = SQR(SQ(ABS(@Ray.fXpos2-@Ray.nF2x))+ SQ(ABS(@Ray.fYpos2))) 'length of tangent line measured from chord X,Y position to X axis line

    'get the resulting normal angle, radians,
    @Ray.nNormRdn = GetN360Rdn(ePosX, ePosY, @Ray.nF2Rdn) 'polar real; Normal angle to Rad of a specific point on perimeter

    'get the resulting z-axis rotational angle, radians, offset from set zero reference
    @Ray.nRotDeg = RdnToDeg( ((@Ray.nNormRdn + @Ray.oFociRdnInv ) MOD Rdn360) )  'z-rotational angle, 0 to 360 degrees translation

    'Get the resulting normal FOCI radius and FOCI vector origin
    IF @Ray.nNormRdn = 0 THEN
       @Ray.nOriginX  = @Ray.majorRad-((@Ray.minorRad^2) / @Ray.majorRad)'cartesian real; X offset to origin of the vector, Normal to a point on weld.
       @Ray.nNormRad = (@Ray.minorRad^2) / @Ray.majorRad             'polar real; Vector magnitude, length of Rad. Origin = (nRay.eOriginX,eNormYpos)
    ELSEIF @Ray.nNormRdn = Rdn180 THEN
       @Ray.nOriginX = ((@Ray.minorRad^2) / @Ray.majorRad)-@Ray.majorRad
       @Ray.nNormRad = (@Ray.minorRad^2) / @Ray.majorRad
    ELSEIF @Ray.f1Rad < @Ray.f2Rad THEN    'use F1 results
       @Ray.nOriginX = @Ray.nF1x-@Ray.foci 'centerline of nozzle, X Axis distance, to normal angle intersection.
       @Ray.nNormRad = @Ray.nF1Rad       'length of normal Rad, measured from base line to weld perimeter chord point, from F1 side
    ELSE                             'use F2 results
       @Ray.nOriginX = @Ray.foci-@Ray.nF2x 'centerline of nozzle, X Axis distance, to normal angle intersection.
       @Ray.nNormRad = @Ray.nF2Rad       'length of normal Rad, measured from base line to weld perimeter chord point, from F2 side
    END IF

END SUB


'Note: In Degree's, 0 to 360 is CCW, 360 to 0 is CW

'@Ray.Index0 = TRUE:
'CCW 0-90-180-270-360: X = 0 at start, increasing X as going CCW  to 360
'CW  0-270-180-90-360: X = 0 at start, increasing X as going CW to 360

'@Ray.Index0 = FALSE:
'CCW SCAN: 0-90-180-270-360: X = circumference at start, X decreasing as going CCW to 0
'CW  SCAN: 0-270-180-90-360: X = circumference at start, X decreasing as going CW to 0

FUNCTION GetIndexCoord(BYVAL RayPtr AS DWORD, BYVAL nIndex AS LONG) AS LONG 'test reverse

    LOCAL Ray AS FociRay POINTER : Ray = RayPtr

    LOCAL eXpos1,eYpos1,eXpos2,eYpos2,arcTarget,arcSegment,thetaInc,theta,idxInc,sign AS DOUBLE
    LOCAL hfont, idx, Get360L, GetA0, GetA90, GetA180, GetA270, GetA360 AS LONG

    'Set the initial x and y position at starting position angle in RADIANS
    'NOTE: There are inherent problems with oDeg  around zero degrees due to fP inaccurracies, converting degrees to radians and vice-versa,
    SELECT CASE @Ray.oDeg   '6/20/16 changed from Radians to Degrees!! Cut and dry.
      CASE   0.00#: eYpos2 = 0 : eXpos2 = @Ray.majorRad
      CASE  90.00#: eXpos2 = 0 : eYpos2 = @Ray.minorRad
      CASE 180.00#: eYpos2 = 0 : eXpos2 =-@Ray.majorRad
      CASE 270.00#: eXpos2 = 0 : eYpos2 =-@Ray.minorRad
      CASE ELSE   : eXpos2 = @Ray.majorRad*COS(@Ray.oRdn) : eYpos2 = @Ray.minorRad*SIN(@Ray.oRdn)
    END SELECT

    eXpos(0)= eXpos2 : eYpos(0)= eYpos2

    theta = @Ray.oRdn    'set start degree position (in radians), to user start angle

    'theta inc based on a per chord inc accuracy of ~.00001"
    thetaInc = IIF(@Ray.IndexCW,-Rdn360/(pi*@Ray.majorDia*100000),Rdn360/(pi*@Ray.majorDia*100000))

    '= degree start position +/- 360 degrees = 1 revolution around ellipse
    @Ray.plus360Rdn = IIF(@Ray.IndexCW,@Ray.oRdn - Rdn360,@Ray.oRdn + Rdn360)

    '= 360 degrees +/- 45 degrees = 1.125 revolutions around ellipse
    @Ray.plus405Rdn = IIF(@Ray.IndexCW,@Ray.plus360Rdn - Rdn45,@Ray.plus360Rdn + Rdn45)

    idx = 1  'set index counter to 1

    Get360L = TRUE 'set flag to capture perimeter when theta >= 360 degrees

   ' IF (@Ray.oDeg MOD 90.00#) THEN  'odd start angle
   '    GetDegL = TRUE

   ' end if

    IF @Ray.Index0 THEN    'scan starts at 0"
       arcTarget = 0 : eArc(0) = 0 : arcSegment = 0 : idxInc = @Ray.index : sign = 1
    ELSE                   'scan starts at circumference
       arcTarget=@Ray.circ360e: eArc(0)=@Ray.circ360e: arcSegment=@Ray.circ360e: idxInc=-@Ray.index: sign = -1
    END IF

    DO: arcTarget += idxInc     'increment to next target position

        DO: theta += thetaInc   'increment current theta position until reaching set target position

            eXpos1 = eXpos2: eXpos2 = @Ray.majorRad*COS(theta) 'get x pos of current incremented angle
            eYpos1 = eYpos2: eYpos2 = @Ray.minorRad*SIN(theta) 'get y pos of current incremented angle

            arcSegment += GetSegLen(eXpos2-eXpos1,eYpos2-eYpos1) * sign 'Index zero: sign=+1; Index Circ: sign=-1

            IF Get360L AND IIF(@Ray.IndexCW,@Ray.plus360Rdn=>theta,theta=>@Ray.plus360Rdn) THEN _
               @Ray.Index360 = idx: @Ray.circ360 = arcSegment: Get360L = False'360L and index captured:set 360L false

        LOOP WHILE IIF(@Ray.Index0,arcSegment<arcTarget,arcTarget<arcSegment)

        eXpos(idx) = eXpos2: eYpos(idx) = eYpos2: eArc(idx) = arcSegment

        IF IIF(@Ray.IndexCW,@Ray.plus405Rdn=>theta,theta=>@Ray.plus405Rdn) THEN _
           @Ray.Index405 = idx : EXIT LOOP 'capture index @ => 405 degrees and exit

        INCR idx

    LOOP UNTIL idx > nIndex  'error if loop exits here, correct exit is Index405

    '*************************************************************************************************************
    '* user starting angle (@Ray.oRdn ), based on circle center origin.                                          *
    '* FOCI angle is based upon focal origin. Same X,Y coord'= different FOCI angle as compared to circle angle. *
    '* Convert user circle angle to corrected FOCI angle: (IF 0,90,180 or 270 FOCI' same as circle)              *
    IF (@Ray.oDeg MOD 90.00#) THEN          'Not 0,90,180 or 270                                                 *
       GetFoci(eXpos(0),eYpos(0),RayPtr)    'Get the FOCI at user start position                                 *
       @Ray.oFociRdn  = @Ray.nNormRdn       'Set FOCI start angle                                                *
       @Ray.oFociDeg = RdnToDeg(@Ray.oFociRdn)  '                                                                *
    ELSE                                        '                                                                *
       @Ray.oFociRdn = @Ray.oRdn            'FOCI angle is same as orginal start angle                           *
       @Ray.oFociDeg = @Ray.oDeg            '                                                                    *
    END IF                                  '                                                                    *
                                            '                                                                    *
    @Ray.oFociRdnInv = Rdn360-@Ray.oFociRdn 'get Z-Rotational offset to equal 0 degrees at scan start            *
    '*************************************************************************************************************

    FUNCTION = idx  'error if > max array

END FUNCTION


SUB GetIndexRays(BYVAL RayPtr AS DWORD)

    LOCAL Ray AS FociRay POINTER, idx AS LONG : Ray = RayPtr
    LOCAL r360 AS DOUBLE: r360 = IIF(@Ray.IndexCW,-360,360) 'CW or CCW

    FOR idx = 0 TO @Ray.Index405
        GetFoci(eXpos(idx),eYpos(idx),RayPtr)'get the Foci of X,Y point along outboard edge of exam zone
        eOriginX(idx) = @Ray.nOriginX 'cartesian real; X offset to origin of the vector, Normal to a point on weld.
        eNormRad(idx) = @Ray.nNormRad 'polar real; Vector magnitude, length of Rad. Origin = (nRay.eOriginX,eNormYpos)
        eNormRdn(idx) = @Ray.nNormRdn 'normal angle at current azimuth, measured from X-Axis base to X,Y point
        eRotDeg(idx)  = IIF(idx<@Ray.Index360,@Ray.nRotDeg,@Ray.nRotDeg+r360) + @Ray.skewDeg + @Ray.oFociDeg 'add 360 if past 0 to not zip back 360
    NEXT

    'rotational always starts at 0 degrees, irrevelant of start azimuth degrees
    'for CCW scan, 0 must be set to 360 otherwise, a full 360 rotate on first index going from 0 to 359.99x
    eRotDeg(0) = IIF(@Ray.IndexCW,360,0) + @Ray.skewDeg + @Ray.oFociDeg  'technically, 360 attributes are same as 0 degrees

END SUB

FUNCTION GetPaths(BYVAL ScanPtr AS DWORD) AS LONG   'Generate Scan Path's

    LOCAL yposA, yposB, yIdxInc AS DOUBLE

    LOCAL xIdx, xIncA, xIncB, PathCtr, yIdx, yIndexes AS LONG

    LOCAL nScan AS ScanVars POINTER : nScan = ScanPtr

    PathCtr= 0 : yIdx =  0 : xIdx= 0 : xIncA= 1 : xIncB= -1

    IF @nScan.yIdxNeg THEN  'y zero reference at yBegin, indexing towards yEnd
       yPosA = @nScan.yEnd : yPosB = @nScan.yBegin : yIdxInc = -@nScan.yIndexInc
    ELSE                    'y zero reference at yEnd, indexing towards yBegin
       yPosA = @nScan.yBegin : yPosB = @nScan.yEnd : yIdxInc = @nScan.yIndexInc
    END IF

    DO  'convert polar coordinates to cartesian coordinates: referenced to a defined elliptical shaped weld
        PathX(PathCtr) = (eNormRad(xIdx) + yPosA) * COS(eNormRdn(xIdx)) + @nScan.skewOffset * COS(eNormRdn(xIdx) + @nScan.skewRdn) + eOriginX(xIdx)
        PathY(PathCtr) = (eNormRad(xIdx) + yPosA) * SIN(eNormRdn(xIdx)) + @nScan.skewOffset * SIN(eNormRdn(xIdx) + @nScan.skewRdn)
        PathZ(PathCtr) = eRotDeg(xIdx)
        PathC(PathCtr) = eArc(xIdx) 'Circ:  X position, parallel to weld axis, image encoder output
        PathA(PathCtr) = yPosA      'Axial: Y position, 90 deg's to weld axis, image encoder output

        IF @nScan.AxialRaster THEN  'axial raster: Index on X, Exit Do Loop when X reaches set end point
           IF (PathCtr AND 1) THEN  'ODD path counter: index x-axis
              IF xIdx < @nScan.xIndexEnd THEN INCR xIdx ELSE EXIT LOOP 'exit if xIdx = max x
           ELSE: SWAP yPosA, yPosB  'EVEN path counter: flip Y target to start or end position
           END IF
        ELSE                'circ raster: Index on Y, Exit Do Loop when Y index reaches set end point
           xIdx += xIncA    'increment x index counter, +1 or -1
           IF (xIdx > @nScan.xIndexEnd) OR (xIdx < 0) THEN '? x Index > max or < min index >------------|
              IF yIdx < @nScan.yIndexes THEN INCR yIdx ELSE EXIT LOOP 'exit if yIdx = number of indexes |
              yPosA += yIdxInc                  'increment y to next y index position                   |
              SWAP xIncA,xIncB : xIdx += xIncA  'flip incr : set x Index to min or max     <------------|
           END IF
        END IF

        INCR PathCtr 'increment path counter for every move, x or y

    LOOP UNTIL PathCtr > nPath 'error if PathCtr > nPath; Loop should exit from above

    FUNCTION = PathCtr

END FUNCTION


FUNCTION GetPathsReturn(BYVAL ScanPtr AS DWORD) AS LONG   'Generate Scan Path's

    LOCAL yposA, yposB, yIdxInc AS DOUBLE

    LOCAL xIdx, xIncA, xIncB, PathCtr, yIdx, yIndexes AS LONG

    LOCAL nScan AS ScanVars POINTER : nScan = ScanPtr

    PathCtr= 0 : yIdx =  0 : xIdx= 0 : xIncA= 1 : xIncB= -1

    IF @nScan.yIdxNeg THEN  'y zero reference at yBegin, indexing towards yEnd
       yPosA = @nScan.yEnd : yPosB = @nScan.yBegin : yIdxInc = -@nScan.yIndexInc
    ELSE                    'y zero reference at yEnd, indexing towards yBegin
       yPosA = @nScan.yBegin : yPosB = @nScan.yEnd : yIdxInc = @nScan.yIndexInc
    END IF

    DO  'convert polar coordinates to cartesian coordinates: referenced to a defined elliptical shaped weld
        PathX(PathCtr) = (eNormRad(xIdx) + yPosA) * COS(eNormRdn(xIdx)) + @nScan.skewOffset * COS(eNormRdn(xIdx) + @nScan.skewRdn) + eOriginX(xIdx)
        PathY(PathCtr) = (eNormRad(xIdx) + yPosA) * SIN(eNormRdn(xIdx)) + @nScan.skewOffset * SIN(eNormRdn(xIdx) + @nScan.skewRdn)
        PathZ(PathCtr) = eRotDeg(xIdx)
        PathC(PathCtr) = eArc(xIdx) 'Circ:  X position, parallel to weld axis, image encoder output
        PathA(PathCtr) = yPosA      'Axial: Y position, 90 deg's to weld axis, image encoder output

        IF @nScan.AxialRaster THEN  'axial raster: Index on X, Exit Do Loop when X reaches set end point
           IF (PathCtr AND 1) THEN  'ODD path counter: index x-axis
              IF xIdx < @nScan.xIndexEnd THEN INCR xIdx ELSE EXIT LOOP 'exit if xIdx = max x
           ELSE: SWAP yPosA, yPosB  'EVEN path counter: flip Y target to start or end position
           END IF
        ELSE                'circ raster: Index on Y, Exit Do Loop when Y index reaches set end point
           xIdx += xIncA    'increment x index counter, +1 or -1
           IF (xIdx > @nScan.xIndexEnd) OR (xIdx < 0) THEN '? x Index > max or < min index >------------|
              IF yIdx < @nScan.yIndexes THEN INCR yIdx ELSE EXIT LOOP 'exit if yIdx = number of indexes |
              yPosA += yIdxInc                  'increment y to next y index position                   |
              SWAP xIncA,xIncB : xIdx += xIncA  'flip incr : set x Index to min or max     <------------|
           END IF
        END IF

        INCR PathCtr 'increment path counter for every move, x or y

    LOOP UNTIL PathCtr > nPath 'error if PathCtr > nPath; Loop should exit from above

    FUNCTION = PathCtr

END FUNCTION


FUNCTION Get60HzSegs(BYVAL ScanVelF AS DOUBLE) AS LONG  'Get total number of 60Hz path segments

    '                    **   X
    '                    *   *   Y
    '                  ^ *      *
    '                  | *         *   S     = Resulting X or Y, Axial or Circ, PROBE MOTION
    '                  | *            *   E
    '                  | *               *   G
    '  =Y AXIS MOTION  | *                  *   M
    '                  | *                     *   E
    '                  | *                        *   N
    '                  | *                           *   T
    '                  | *                              *
    '                  ^ *                                 *
    '                    * * * * * * * * * * * * * * * * * * *
    '                         >-------------------->
    '                             =X AXIS MOTION

    LOCAL xySeg, ScanVelR AS DOUBLE, lctr,n60Hz AS LONG  'nPath is defined as GLOBAL in PBMAIN

    ScanVelR = 1.00#/ScanVelF 'All axis's have to move at the same speed for coord' motion

    FOR lctr = 1 TO nPath     'Note: 'the resulting X-Y image vector output distance is ALWAYS >= the individual X or Y axis travel distance
        xySeg = GetSegLen(PathX(lCtr)-PathX(lCtr-1),PathY(lCtr)-PathY(lCtr-1))
        n60Hz += MAX((xySeg*ScanVelR*60.00#),1.00#)'number of 60Hz path segments
    NEXT

    FUNCTION = n60Hz

END FUNCTION


FUNCTION RunScan(BYVAL RayPtr AS DWORD, BYVAL ScanPtr AS DWORD, BYVAL GFXPtr AS DWORD, BYVAL QPtr AS DWORD) AS LONG

    LOCAL Ray AS FociRay POINTER,nScan AS ScanVars POINTER,Quartic AS QuarticRay POINTER,GFX AS GfxVars POINTER

    Ray = RayPtr: nScan = ScanPtr: Quartic = qPtr: GFX = GFXPtr

    LOCAL xCtsF_Err,yCtsF_Err,zCtsF_Err,cCtsF_Err,aCtsF_Err,xCPi,yCPi,zCPi,cCPi,aCPi,xCPiR, _
          yCPiR,zCPiR,cCPiR,aCPiR,xPos,yPos,zPos,aPos,xPos2,yPos2,zPos2,cPos2,aPos2,xIncCtsF, _
          yIncCtsF,cIncCtsF,aIncCtsF,zIncCtsF,ScanVelF,ScanVelR,T,xySeg,n60HzSegsR,t60Hz,xm,ym AS DOUBLE

    LOCAL xIncCtsL,yIncCtsL,zIncCtsL,cIncCtsL,aIncCtsL,idx,SegCtr,n60HzSegs,pInc,pZoom AS LONG

    'newly added for timer stuff
    '********************************************************************
    LOCAL TimeBegin, Time1, Time2, pos1, pos2 AS DOUBLE

    'newly added for screen stuff
    '********************************************************************
    LOCAL xPix, yPix AS SINGLE

    'GET CANVAS: current viewport has no effect on returned value. ex., GW=1800 pixels, scale=0.001, returns 1.8

    LOCAL xCanvas, yCanvas AS SINGLE  'GRAPHIC GET CANVAS

    'returns visible GW viewport in pixels.
    'GET CLIENT: if viewport H&W=100%, returns VISIBLE size in pixels, if <100%: includes +17 for scrollbars.
    'GRAPHIC GET CLIENT To xSize, HeightVar!
    LOCAL xSize, ySize AS SINGLE 'GRAPHIC GET CLIENT: Get VISIBLE window size in pixels, including the scrollbar, if any
    LOCAL xClient, yClient AS SINGLE     '

    'returns left-upper corner of screen viewport offset position in set scaled units
    'GRAPHIC GET VIEW TO xView, yView
    LOCAL xView, yView AS SINGLE

    'used with GRAPHIC CLICK, mouse
    LOCAL mClick AS LONG : LOCAL xCoord, yCoord AS SINGLE

    'newly added varibles for mouse click stuff
    '********************************************************************

    LOCAL xmouse, ymouse,xmouse2, ymouse2, xmouseOff, ymouseOff, xmouseOld, xmouseNew, ymouseOld, ymouseNew AS LONG

    LOCAL InkeyVar$

    LOCAL MouseL, MouseM, MouseR, mRight, mMiddle, mLeft, btndown, K, hFg AS LONG
    LOCAL mLeftDN, mLeftUP, mLeftCK AS LONG
    LOCAL mRightDN, mRightUP, mRightCK AS LONG
    LOCAL mMiddleDN, mMiddleUP, mMiddleCK, NotIn AS LONG

    LOCAL RefreshWin AS LONG

    LOCAL lpPoint AS POINTAPI ' Pointer type defined in Win32Api

    LOCAL KeyOn AS LONG
    LOCAL IncSpeed, WaitTime AS DOUBLE
    LOCAL tctr AS LONG

    DIM sTxt(16) AS LOCAL STRING

    MouseL = %VK_LBUTTON
    MouseM = %VK_MBUTTON
    MouseR = %VK_RBUTTON     ' Only these 3 are allowed

    'determine length of foci lines for plotting on nozzle model
    GetFoci(@Ray.majorRad, 0, RayPtr)   'Get focal of major axis Rad
    @GFX.NormLine = @Ray.nNormRad : @GFX.TngtLine = @Ray.nOriginX  'length of normal Rad

    yPix = gWIN.yPix(0) : xPix = gWIN.xPix(0)

    'load cursor arrays
    CrossCur AndArray(), XorArray() 'HandCur AndArray(), XorArray()
    'create the mouse cursor,

    hCursor = CreateCursor(%NULL, 15, 15, 32, 32, VARPTR(AndArray(1)), VARPTR(XorArray(1)))
    'HCURSOR WINAPI CreateCursor(
                                      '  _In_opt_       HINSTANCE hInst,
                                      '  _In_           int       xHotSpot,
                                      '  _In_           int       yHotSpot,
                                      '  _In_           int       nWidth,
                                      '  _In_           int       nHeight,
                                      '  _In_     const VOID      *pvANDPlane,
                                      '  _In_     const VOID      *pvXORPlane
                                       ');

    NotIn = TRUE 'mouse cursor is not in scan window

    pZoom = gWIN.PixelR(1) * 10000 '10000 = 1/0.0001# 'store current zoom as long integer

    ScanVelF = 1.00# '1.00#
    ScanVelR = 1.00#/ScanVelF 'constant for PROBE scan speed - not motors!

    'reset offset error counts to 0
    xCtsF_Err= 0: yCtsF_Err= 0: zCtsF_Err= 0: cCtsF_Err= 0: aCtsF_Err= 0

    'be sure to set step count multiplier on servo's to 10x
    'set counts inch - divide by 10 to make life easier for Nucleo's output counts
    xCPi = 3768.024325157213#   '(37680.24325157213#)/10.00#  'cts per inch travel = (300564/1300) * (30/12) * (128*4)  / (2.5 * Pi)  =  cts/inch
    yCPi = 4460.5440#           '(44605.440#)/10.00#          'cts per inch travel = (4356/100) * (128*4) / 0.500 = cts/inch
    zCPi = 270.412955465587#    '(2704.12955465587#)/10.00#   'cts per degree rotate = (341550/2470) * (110/24) * (36/12) * (128*4) / 360 = cts/degree
    cCPi = 1000.00#             'user set - image system must match set resolution
    aCPi = 1000.00#             'user set - image system must match set resolution

    xCPiR=1.00#/xCPi: yCPiR=1.00#/yCPi: zCPiR=1.00#/zCPi: cCPiR=1.00#/cCPi: aCPiR=1.00#/aCPi 'reciprocal: counts per inch

    t60Hz = 1.00#/60.00# ' used for plot timing only

    'set all positions to scan start location
    xPos2 = PathX(0): yPos2 = PathY(0): zPos2 = PathZ(0): cPos2 = PathC(0): aPos2 = PathA(0)

    RefreshWin = TRUE

    GRAPHIC WINDOW CLICK gWIN.hWin(0) TO mclick, xCoord, yCoord 'clear any mouse clicks

    GOSUB DrawScan

    BEEP

    GRAPHIC WAITKEY$

    TimeBegin = TIMER

    KeyOn = TRUE

    FOR idx = 1 TO nPath

        'Note: X&Y axis travel distance is always <= the X&Y image distance output.
        '      X&Y image output distance is always >= the X&Y axis travel distance.
        'Note:  6/10/16  Need to consider the Z-Axis max speed at some point, make sure it has
        '       sufficient rotational velocity to keep up with possible higher X & Y scan speed.

        'xySeg = ABS( GetSegLen(PathX(idx)-PathX(idx-1), PathY(idx)-PathY(idx-1)) )

        xySeg = ABS( SQR((PathX(idx)-PathX(idx-1))^2 + (PathY(idx)-PathY(idx-1))^2) )

        IF xySeg = 0 THEN PRINT "PATH IS ZERO!!!" : BEEP: ITERATE FOR  'should not happen!

        'n60HzSegs must equal at least 1!!: .10" Path/12 IPS=.00833 secs/.0166 =.50 path!!
        n60HzSegs = MAX((xySeg*ScanVelR*60.00#),1.00#)
        n60HzSegsR = 1.00#/n60HzSegs 'n60HzSegs reciprocal

        'calculate max scan speed based on segment length: scan speed = xySeg * 60.00
        'locate 20,1: print "Max Scan Speed:";round(xySeg * 60.00#,4);"        "

        'calculate segment length based scan speed: segment length  = scan speed / 60.00
        'locate 20,1: print "Max Scan Speed:";round(xySeg * 60.00#,4);"        "

        'need to add a simple fixed accel/deccel rate !!!!!!!!!! out of time to implement this!!!

        IF @nScan.MtrsRev THEN
           'convert each axis, in 60Hz increments, to motor counts
           xIncCtsF = n60HzSegsR * -( PathX(idx)-PathX(idx-1) ) * xCPi
           yIncCtsF = n60HzSegsR * -( PathY(idx)-PathY(idx-1) ) * yCPi
           zIncCtsF = n60HzSegsR * -( PathZ(idx)-PathZ(idx-1) ) * zCPi
        ELSE
           'convert each axis, in 60Hz increments, to motor counts
           xIncCtsF = n60HzSegsR * ( PathX(idx)-PathX(idx-1) ) * xCPi
           yIncCtsF = n60HzSegsR * ( PathY(idx)-PathY(idx-1) ) * yCPi
           zIncCtsF = n60HzSegsR * ( PathZ(idx)-PathZ(idx-1) ) * zCPi
        END IF

        cIncCtsF = n60HzSegsR * ( PathC(idx)-PathC(idx-1) ) * cCPi
        aIncCtsF = n60HzSegsR * ( PathA(idx)-PathA(idx-1) ) * aCPi

        T=TIMER

        FOR SegCtr = 1 TO n60HzSegs  ' each and every 60Hz segment will run for 1/60 second
            'Translating floats to integer position counts results in rounding errors, normally in the range of +/- 1 count.
            'Over the full scan path, these small errors per increment can/will accumulate into large position errors.
            'Track and correct the accumlated error on each increment:
            xIncCtsL = (xIncCtsF + xCtsF_Err)'| 'integrate rounding error into every cycle
            yIncCtsL = (yIncCtsF + yCtsF_Err)'|
            zIncCtsL = (zIncCtsF + zCtsF_Err)'|--------> 60Hz Increments transmitted to MCU Nucleo
            cIncCtsL = (cIncCtsF + cCtsF_Err)'|
            aIncCtsL = (aIncCtsF + aCtsF_Err)'|

            'capture rounding error
            xCtsF_Err += (xIncCtsF - xIncCtsL)
            yCtsF_Err += (yIncCtsF - yIncCtsL)
            zCtsF_Err += (zIncCtsF - zIncCtsL)
            cCtsF_Err += (cIncCtsF - cIncCtsL)
            aCtsF_Err += (aIncCtsF - aIncCtsL)

            'convert motor counts back to X, Y, Z real position coordinates.
            IF @nScan.MtrsRev THEN
               xPos2 += -(xIncCtsL * xCPiR)
               yPos2 += -(yIncCtsL * yCPiR)         'NOTE: for plotting and tracking probe movement - not for motor control
               zPos2 += -(zIncCtsL * zCPiR)
            ELSE
               xPos2 += (xIncCtsL * xCPiR)
               yPos2 += (yIncCtsL * yCPiR)         'NOTE: for plotting and tracking probe movement - not for motor control
               zPos2 += (zIncCtsL * zCPiR)
            END IF

            cPos2 += (cIncCtsL * cCPiR)
            aPos2 += (aIncCtsL * aCPiR)

            GOSUB UserInput 'get user input, keystrokes and mouse

            GOSUB DrawScan  'update probe position and redraw the model
        NEXT
    NEXT

    PRINT "Time: " TIMER - Timebegin
    BEEP
    KeyOn = False

    DO UNTIL GRAPHIC(INSTAT)
       GOSUB UserInput
       GOSUB DrawScan
    LOOP

    IF NotIn = False THEN 'was in canvas
       NotIn = True  'set to outside canvas
       SystemParametersInfo(%SPI_SETCURSORS, 0, eNULL, 0) 'reset back to arrow
    END  IF

    GRAPHIC WINDOW END

    EXIT FUNCTION

'make into a thread ??

'****************************************************************************************************
DrawScan:
'****************************************************************************************************

    IF RefreshWin THEN  'zoom or origin changed

       RefreshWin = FALSE

       'set normal window to equal bitmap pixel spatial resolution
       gWIN.PixelR(0) = gWIN.PixelR(1)

       'set window scale to equal bitmap scale
       gWIN.yMinR(0) = gWIN.yMinR(1) : gWIN.yMaxR(0) = gWIN.yMaxR(1)
       gWIN.xMinR(0) = gWIN.xMinR(1) : gWIN.xMaxR(0) = gWIN.xMaxR(1)

       'Select bitmap, update coordinates and draw model at new scale
       GRAPHIC ATTACH gWIN.hWin(1), 0&, REDRAW

       GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))

       GRAPHIC CLEAR : DrawScanModel(RayPtr, GFXPtr, ScanPtr) : GRAPHIC REDRAW

       'Select normal window and set new coordinates
       GRAPHIC ATTACH gWIN.hWin(0), 0&, REDRAW

       GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))

    END IF

    IF KeyOn THEN
       'IF ScanVelF <= 12.00# THEN          'no delay if > 12.00
           WaitTime = T + (SegCtr * t60Hz)  'hold time to plot at ~ set scan speed
           DO WHILE (TIMER  < WaitTime) : SLEEP 0 : LOOP
       'ELSE : T = TIMER
       'END IF
    END IF

    GRAPHIC COPY gWIN.hWin(1), 0&  'copy bitmap of nozzle scan model to standard window

    xPos = ROUND(xPos2,14) : yPos = ROUND(yPos2,14) : zPos = ROUND(zPos2,14) : aPos = ROUND(aPos2,14) 'was 10 places

    PlotProbe(xPos,yPos,zPos,aPos,RayPtr,ScanPtr,GFXPtr,QPtr) 'Draw Probe and focal at current z rotational and x,y position

    sTxt(0)="Weld X Pos: " + STR$(ROUND(cPos2,3))
    sTxt(1)="Weld Y Pos: " + STR$(ROUND(aPos2,3))
    sTxt(2)="Weld Z Deg: " + STR$(ROUND( (zPos2-@nScan.SkewDeg) MOD 360,3))

    sTxt(3)="Probe X Pos: "+ STR$(ROUND(xPos2,3))
    sTxt(4)="Probe Y Pos: "+ STR$(ROUND(yPos2,3))
    sTxt(5)="Probe Z Deg: "+ STR$(ROUND((zPos2 MOD 360),3))

    sTxt(6)="Scan Speed: "+ STR$(ROUND(ScanVelF,3))

    IF @nScan.AxialRaster THEN
      sTxt(7)="IPS Speed: "+ STR$(ROUND(( ABS(aPos2 - Pos1)/(TIMER - Time1)),1))
      Pos1 = aPos2 : Time1 = TIMER
    ELSE
      sTxt(7)="IPS Speed: "+ STR$(ROUND(( ABS(cPos2 - Pos1)/(TIMER - Time1)),1))
      Pos1 = cPos2 : Time1 = TIMER
    END IF

    GRAPHIC CELL = 2, 2 : GRAPHIC PRINT sTxt(0)
    GRAPHIC CELL = 3, 2 : GRAPHIC PRINT sTxt(1)
    GRAPHIC CELL = 4, 2 : GRAPHIC PRINT sTxt(2)
    '5
    GRAPHIC CELL = 6, 2 : GRAPHIC PRINT sTxt(3)
    GRAPHIC CELL = 7, 2 : GRAPHIC PRINT sTxt(4)
    GRAPHIC CELL = 8, 2 : GRAPHIC PRINT sTxt(5)
    '9
    GRAPHIC CELL = 10,2 : GRAPHIC PRINT sTxt(6)
    GRAPHIC CELL = 11,2 : GRAPHIC PRINT sTxt(7)
    GRAPHIC CELL = 12,2 : GRAPHIC PRINT sTxt(8)

    GRAPHIC REDRAW                              'Re-Draw the screen snappaly

RETURN


'****************************************************************************************************
UserInput: ' process keypress and mouse clicks
'****************************************************************************************************
    IF keyOn THEN
       DO WHILE GRAPHIC(INSTAT)
          SELECT CASE GRAPHIC$(INKEY$)
             CASE "+" : ScanVelF = IIF(ScanVelF =< 100.00#,ScanVelF+0.100#,100.00#): ScanVelR = 1.00#/ScanVelF
             CASE "-" : ScanVelF = IIF(ScanVelF => 0.100#, ScanVelF-0.050#,0.050#) : ScanVelR = 1.00#/ScanVelF
             CASE "q", "Q"
                'set mouse cursor back to default arrow pointer before leaving
                IF NotIn = False THEN 'was in canvas
                   NotIn = True  'set to outside canvas
                   SystemParametersInfo(%SPI_SETCURSORS, 0, eNULL, 0) 'reset back to arrow
                END  IF
                GRAPHIC WINDOW END
                EXIT FUNCTION
             CASE ELSE : GRAPHIC WAITKEY$ : EXIT DO
          END SELECT
          SLEEP 10 : GOSUB DrawScan
       LOOP
    END IF

    hFg = GetForegroundWindow() ' When switching to a PB GW, the handle gets 0 before returning hGW
    IF hFg = gWIN.hWin(0) THEN  ' Graphic Window is on top

       'GET CLIENT: returns VISIBLE window size in pixels, including the scrollbar, if any
       GRAPHIC GET CLIENT TO yClient, xClient  '= height and width of the window in pixels

       'if x/y size < x/y pixels, then scroll bars appear, subtract for scroll bar, 17 pixels.
       xSize = IIF(yClient=yPix,xClient,xClient-17) : ySize = IIF(xClient=xPix,yClient,yClient-17)

       GetCursorPos(lpPoint)    'win32 Read cursor position
       ScreenToClient(gWIN.hWin(0),lpPoint) 'win32 Get pixel coordinates within specified graphic window, not desktop window!
       SWAP lpPoint.x, lpPoint.y 'screen setup with y = x and x = y

       IF (lpPoint.y > 0) AND (lpPoint.y < ySize) AND (lpPoint.x > 0) AND (lpPoint.x < xSize) THEN 'mouse pointer within canvas area

          'local method, mouse cursor shape in code, data array
          IF NotIn THEN 'True - set to custom cursor
             hCursorCopy = CopyCursor(hCursor)      'copy cursor
             SetSystemCursor(hCursorCopy,%OCR_NORMAL)   'set new cursor
             NotIn = False 'set to False
          END  IF

          'GET CANVAS: returns ENTIRE window size in scaled units, inches. Changes with zoom factor.
          GRAPHIC GET CANVAS TO yCanvas, xCanvas

          'GET VIEW: returns upper-left scrolled-offset position of screen viewport in scaled units, inches, based on zoom.
          GRAPHIC GET VIEW TO yView, xView

          'correction of return value, returns neg of pitch scale when no scroll.
          yView = IIF(yView<0,0,yView): xView = IIF(xView<0,0,xView)

          'compensate reported mouse position, in pixels, for scrolled window position, if any
          ymouse = lpPoint.y + (yView/gWIN.PixelR(0)): xmouse = lpPoint.x + (xView/gWIN.PixelR(0))

          IF @nScan.xNear THEN 'X-Axis on near side of of nozzle
             ym = ymouse*gWIN.PixelR(0)+gWIN.yMinR(0) : xm = xmouse*gWIN.PixelR(0)+gWIN.xMinR(0)
          ELSE
             ym =-ymouse*gWIN.PixelR(0)+gWIN.yMinR(0) : xm =-xmouse*gWIN.PixelR(0)+gWIN.xMinR(0)
          END IF

          LOCATE 5,1: PRINT "ymouse; xmouse;"; ROUND(ym,3); ROUND(xm,3); SPC(10)

          'Check LEFT mouse button: up to down transition registers down button
          K = GetAsyncKeyState(MouseL)
          btnDown =  BIT(K, 15)
          IF (btnDown AND mLeftUP) THEN                     'true when button was up before being pressed down.
             mLeftUP = FALSE : mLeftDN = TRUE               'set button states
             ymouseNew = ymouse: xmouseNew = xmouse         'capture new x,y position
             ymouseOld = ymouseNew: xmouseOld = xmouseNew   'set old positions to new
             ymouseOff = 0 : xmouseOff = 0                  'set offset to 0
          ELSEIF btnDown THEN                           '---'left button still down      --- '
             ymouseNew= ymouse: xmouseNew= xmouse           'capture new x,y position      |
             ymouseOff= ymouseNew - ymouseOld               'get new to old transient      |  continues until button goes up
             xmouseOff= xmouseNew - xmouseOld               'ditto                         |
             ymouseOld= ymouseNew: xmouseOld= xmouseNew '---'processed above, new is old --- '
          ELSE                                              'button up
             mLeftUP = TRUE : mLeftDN = FALSE               'reset button states
          END IF

          '*************************************************************************************************************
          'Check MIDDLE mouse button: dn to up transition triggers one click, flips pInc to +/-1
          K = GetAsyncKeyState(MouseM)
          btnDown =  BIT(K, 15)
          IF btnDown THEN
             mMiddleDN = TRUE    'button down, wait for up
          ELSEIF mMiddleDN THEN  'button up from previous down = click
                 mMiddleDN = FALSE   'reset button sate
                 pInc = IIF(pInc= -1,1,-1) 'flip pInc to +/-1
          END IF

          '*************************************************************************************************************
          'Check RIGHT mouse button: button down or up
          K = GetAsyncKeyState(MouseR)
          btnDown =  BIT(K, 15)
          IF btnDown THEN mRightDN = TRUE ELSE mRightDN = FALSE

          '*************************************************************************************************************
          IF mLeftDN  THEN  'left button down: change plot to new origin

             IF @nScan.xNear THEN 'X-Axis on nozzle near side
                gWIN.yMinR(1) -= (ymouseOff * gWIN.PixelR(1)) : gWIN.yMaxR(1) -= (ymouseOff * gWIN.PixelR(1))
                gWIN.xMinR(1) -= (xmouseOff * gWIN.PixelR(1)) : gWIN.xMaxR(1) -= (xmouseOff * gWIN.PixelR(1))
             ELSE                 'X-Axis on nozzle far side
                gWIN.yMinR(1) += (ymouseOff * gWIN.PixelR(1)) : gWIN.yMaxR(1) += (ymouseOff * gWIN.PixelR(1))
                gWIN.xMinR(1) += (xmouseOff * gWIN.PixelR(1)) : gWIN.xMaxR(1) += (xmouseOff * gWIN.PixelR(1))
             END IF

             'if any change, set window refresh flag True
             IF (gWIN.yMinR(1)<>gWIN.yMinR(0)) OR (gWIN.xMinR(1)<>gWIN.xMinR(0)) THEN RefreshWin = TRUE

          END IF

          '*************************************************************************************************************
          IF mRightDN THEN   'right button: change zoom,  centered on mouse x,y position

             '+/- increment zoom: keep within defined limits
             IF pInc = 1 THEN                            '+1 increment = -zoom
                pZoom = IIF(pZoom < 1000, pZoom+1, 1000)
             ELSE: pZoom = IIF(pZoom > 2, pZoom-1, 1)  '-1 increment = +zoom
             END IF

             gWIN.PixelR(1) = OOO1 * pZoom '.0001# * pZoom

             IF gWIN.PixelR(1) <> gWIN.PixelR(0) THEN 'if change

                IF @nScan.xNear THEN 'X-Axis on near side of of nozzle
                   'compute so mouse pointer is the zoom origin, i.e.,  x,y origin is retained irrevelant of zoom
                   gWIN.yMinR(1) = ymouse * (gWIN.PixelR(0) - gWIN.PixelR(1)) + gWIN.yMinR(0)
                   gWIN.yMaxR(1) = yPix * gWIN.PixelR(1) + gWIN.yMinR(1)
                   gWIN.xMinR(1) = xmouse * (gWIN.PixelR(0) - gWIN.PixelR(1)) + gWIN.xMinR(0)
                   gWIN.xMaxR(1) = xPix * gWIN.PixelR(1) + gWIN.xMinR(1)
                ELSE                 'X-Axis on far side of of nozzle
                   'compute so mouse pointer is the zoom origin, i.e.,  x,y origin is retained irrevelant of zoom
                   gWIN.yMinR(1) = -ymouse * (gWIN.PixelR(0) - gWIN.PixelR(1)) + gWIN.yMinR(0)
                   gWIN.yMaxR(1) = -yPix * gWIN.PixelR(1) + gWIN.yMinR(1)
                   gWIN.xMinR(1) = -xmouse * (gWIN.PixelR(0) - gWIN.PixelR(1)) + gWIN.xMinR(0)
                   gWIN.xMaxR(1) = -xPix * gWIN.PixelR(1) + gWIN.xMinR(1)
                END IF

                RefreshWin = TRUE  'refresh the window on next draw
             END IF
          END IF

       ELSE  'Inside GW but outside of canvas area
          mLeftCK = FALSE : mMiddleCK = FALSE : mRightCK = FALSE
          mLeftUP = FALSE : mMiddleUP = FALSE : mRightUP = FALSE
          mLeftDN = FALSE

          IF NotIn = False THEN 'was in canvas
             NotIn = True  'set to outside canvas
             SystemParametersInfo(%SPI_SETCURSORS, 0, eNULL, 0) 'reset back to arrow
          END  IF

       END IF

    ELSE 'Outside of GW
       mLeftCK = FALSE : mMiddleCK = FALSE : mRightCK = FALSE
       mLeftUP = FALSE : mMiddleUP = FALSE : mRightUP = FALSE
       mLeftDN = FALSE

       IF NotIn = False THEN 'was in canvas
          NotIn = True  'set to outside canvas
          SystemParametersInfo(%SPI_SETCURSORS, 0, eNULL, 0) 'reset back to arrow
       END  IF
    END IF


RETURN

END FUNCTION


SUB SetWindow(BYVAL yRadius AS DOUBLE, BYVAL MajorRad AS DOUBLE, BYVAL MinorRad AS DOUBLE)

    LOCAL sizeX,sizeY,pSizeY,nSizeY,pSizeX,nSizeX AS SINGLE

    LOCAL fCtr AS LONG
    '*******************************************************************************************
    ' Main Graphics Window
    '*******************************************************************************************
    gWIN.yPix(0) = 1400 : gWIN.xPix(0) = 1000

    sizeX = (yRadius + MajorRad) * 2 + 4.00# ' 1.0" clearance on each side, size in pixels
    sizeY = (yRadius + MinorRad) * 2 + 4.00# ' 1.0" clearance on each side

    '0.02! 'value. inches per pixel - graphic window size
    gWIN.PixelR(0) = ROUND(sizeX/gWIN.xPix(0),4) 'spatial resolution based on x zize, largest dia, least pixels.

    pSizeY = (sizeY/2) 'size in inches, set positive size to the far side edge of the screen
    nSizeY = ( (gWIN.yPix(0) * gWIN.PixelR(0)) - pSizeY ) 'set negative side to screen size - posY

    pSizeX = gWIN.xPix(0) * gWIN.PixelR(0) * 0.500 'set positive and negative to equal size
    nSizeX = pSizeX

    IF gWIN.xNear THEN
        gWIN.yMinR(0) = -nSizeY : gWIN.yMaxR(0) = pSizeY
        gWIN.xMinR(0) = -nSizeX : gWIN.xMaxR(0) = pSizeX
    ELSE
        gWIN.yMinR(0) = nSizeY : gWIN.yMaxR(0) = -pSizeY
        gWIN.xMinR(0) = nSizeX : gWIN.xMaxR(0) = -pSizeX
    END IF

    gWIN.bClr(0) = %BLACK : gWIN.fClr(0) = %WHITE

    'assigned even numbers for standard windows, direct display
    GRAPHIC WINDOW NEW "NOZZLE 'Top View'", 10, 10,gWIN.yPix(0) , gWIN.xPix(0) TO gWIN.hWin(0) 'Create a graphic window and assign it a handle
    GRAPHIC ATTACH gWIN.hWin(0), 0&                                       'Select standard window
    GRAPHIC COLOR gWIN.fClr(0), gWIN.bClr(0)                              'Set foreground and  background color
    GRAPHIC CLEAR                                                         'Clear selected window with background color
    GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))
    'SetScale(0)

    GRAPHIC WINDOW STABILIZE gWIN.hWin(0)
    GRAPHIC SET OVERLAP (TRUE)

    '*******************************************************************************************
    'Graphics Bitmap
    '*******************************************************************************************
    gWIN.PixelR(1)  = gWIN.PixelR(0)

    gWIN.yPix(1) = gWIN.yPix(0) : gWIN.xPix(1) = gWIN.xPix(0)
    gWIN.yMinR(1)= gWIN.yMinR(0): gWIN.yMaxR(1)= gWIN.yMaxR(0)
    gWIN.xMinR(1)= gWIN.xMinR(0): gWIN.xMaxR(1)= gWIN.xMaxR(0)
    gWIN.bClr(1) = gWIN.bClr(0) : gWIN.fClr(1) = gWIN.fClr(0)

    'assigned odd numbers for bitmaps or special use windows, used to store static images for copying to standard window
    GRAPHIC BITMAP NEW gWIN.yPix(1),gWIN.xPix(1) TO gWIN.hWin(1) 'bitmap window for current nozzle weld scan model
    GRAPHIC ATTACH gWIN.hWin(1), 0&                   'Select bitmap window #1
    GRAPHIC COLOR gWIN.fClr(1), gWIN.bClr(1)            'Set foreground and  background color
    GRAPHIC CLEAR                                'Clear selected window with background color

    GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))

    GRAPHIC SET OVERLAP (TRUE)

    'FONT NEW fontname$, points!, style&, charset&, pitch&, escapement&] TO fhndl

    FOR fCtr = 1 TO 30
      FONT NEW "Times New Roman", fCtr, 0, 0, 0, 0 TO gFont(fCtr)
    NEXT

    FontNum = 12

    GRAPHIC SET FONT gFont(FontNum)

    '**********************************************************************************************************************
    ' Select Main Graphics Window
    '**********************************************************************************************************************
    'assigned even numbers for standard windows, direct display
    GRAPHIC ATTACH gWIN.hWin(0), 0&, REDRAW   'Select MAIN standard window
    GRAPHIC WINDOW STABILIZE gWIN.hWin(0)     'user can't close window
    GRAPHIC COLOR gWIN.fClr(0), gWIN.bClr(0)  'Set foreground and  background color
    GRAPHIC CLEAR                             'Clear selected window with background color

    GRAPHIC SET VIRTUAL gWIN.yPix(0), gWIN.xPix(0), USERSIZE

    GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))

    GRAPHIC SET OVERLAP (TRUE)

    GRAPHIC SET FOCUS

    GRAPHIC SET FONT gFont(FontNum)

END SUB
