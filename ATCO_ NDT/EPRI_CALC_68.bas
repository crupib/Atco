
'11/04/16
'Original File Name:
'                    nModule_v104_AX_Beam_90-270_VertMount_wExt.BAS
'
'New File Name/s:
'                    nModule_v104_AX_Beam_90-270_VertMount_wExt_EPRI_CALC_1.BAS
'
'                    EPRI_CALC_1.BAS



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


'LOCAL lRetVal  AS LONG
'LOCAL string_variable AS STRING

'lRetVal = KLJMessageBox( "Calibration failed", "Atco Scanner",%MB_YESNOCANCEL )
'IF lRetVal = %MB_YES  THEN
'   PRINT "Yes"
'   WAITKEY$
'END IF
'string_variable = KLJInput("Enter X value", "ATCO Input ", "", 100,100)
'PRINT string_variable
'WAITKEY$

#COMPILE EXE
#COMPILER PBCC 6
'#CONSOLE OFF
#DIM ALL

#INCLUDE "COMDLG32.INC"
#INCLUDE "WIN32API.INC"

'MACRO Pi = 3.141592653589793##
'MACRO DegToRdn(dpDegrees) = (dpDegrees*0.0174532925199433##)
'MACRO RdnToDeg(dpRadians) = (dpRadians*57.29577951308232##)


'MACRO Pi  = 3.141592653589793#  '15 decimal places
'MACRO Pi2 = 3.141592653589793# * 2.00#
'MACRO PiHalf = 3.141592653589793# * 0.500#

MACRO PiHalf = (2 * ATN(1))
MACRO Pi = (4 * ATN(1))
MACRO Pi2 = (8 * ATN(1))


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

CONST Rnd10 = 10000000000    '10 places
CONST Rnd11 = 100000000000   '11 places
CONST Rnd12 = 1000000000000  '12 places
CONST Rnd13 = 10000000000000 '13 places
CONST Rnd14 = 100000000000000'14 places


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
CONST OO1 = (0.00100#)

CONST TRUE = (-1)
CONST FALSE = (NOT -1)

CONST Mil = 1000000

CONST xG = 0
CONST yG = 1
CONST zG = 2
CONST cG = 3
CONST aG = 4


CONST KeyUP = 272  '72 + 200
CONST KeyDN = 280
CONST KeyLFT = 275
CONST KeyRGT = 277
CONST KeyHOM = 271
CONST KeyESC = 27
CONST KeyENT = 13



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

     nQx AS DOUBLE      'quartic X pos
     nQy AS DOUBLE      'quartic Y pos

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
     Index359 AS LONG        'number of indexes to reach <360 degrees
     Index360 AS LONG        'number of indexes to reach =>360 degrees
     Index405 AS LONG        'number of indexes to reach =>405 degrees
     Index AS DOUBLE         'index spatial resolution
     IndexCW AS LONG         'flag for clockwise or CCW scan; CW goes 360 to 0, CCW goes 0 to 360.
     Index0 AS LONG        'flag to use reference zero or circumference as starting point

     'theta360 as double

END TYPE
'GLOBAL nRay AS FociRay


'NEW - added 7/9/15
TYPE ScanVars        'Thoughts 06/20/16: Save to a file so user can retrieve and store probe setups on disk
    'user enters these  directly

     i_xIndexBegin AS LONG  'not used   'number of X-indexes to begin index
     xIndexEnd AS LONG      'number of X-indexes to last index

     yIndexBegin AS LONG    'not used  'Integer: number of Y-Indexes to begin index
     yIndexes AS LONG       'Integer: number of Y-Indexes to last index

     i_xIndexBegin_U AS LONG'not used 'number of X-indexes to begin index
     i_xIndexEnd_U AS LONG  'not used   'number of X-indexes to user set max index, has no impact on Model, ends X-index'ing

     yBegin AS DOUBLE       'Real: Y-Axis Begin
     yEnd AS DOUBLE         'Real: Y-Axis End
     yIndexInc AS DOUBLE    'Real: Y-Index increment for circ raster, ax or circ beam

     xBegin AS DOUBLE       'not used 'Real: X-Axis Begin  '******** could be implemented based on perimeter measurements
     xEnd AS DOUBLE         'not used 'Real: X-Axis End    '******** could be used for extra indexes
     xIndexInc AS DOUBLE    'Real X-Index Increment set by user, fixed unless model is ran again

     xIndexPlus AS LONG     'number of added Indexes for overlap

     skewOffset AS DOUBLE   'skew-offset surface distance from index to beam at ID
     skewRdn AS DOUBLE      'skew angle of probe in Rdn
     SkewDeg AS DOUBLE      '+/- skew angle of probe in degrees
     'skewDir AS LONG       'skew direction, +/-, beam pointing from either negative or positive side of zero

     WeldHaz AS DOUBLE      'width of HAZ "Heat Affected Zone" - for plotting scan model
     WeldWidth AS DOUBLE    'width of weld -                     for plotting scan model
     yRadius AS DOUBLE      'set length of nozzle scan lines     for plotting scan model

     AxialRaster AS LONG    'FLAG: TRUE or FALSE: FALSE = raster in circ direction, TRUE = raster in axial direction
     AxialBeam AS LONG      'FLAG: TRUE or FALSE: FALSE = circ beam, True = axial beam
     yIdxNeg AS LONG        'FLAG: TRUE or FALSE: FALSE = Y index start = yBegin, TRUE = Y index start = yEnd
     xNear AS LONG          'FLAG: TRUE or FALSE: FALSE = X axis on far side of nozzle, TRUE = X on near side
     MtrsRev AS LONG        'FLAG: TRUE or FALSE: FALSE = Mtrs are as is, FALSE = Mtrs are reversed: + = - and - = +

     'yStroke AS DOUBLE
     'setIndex AS DOUBLE
     'aProbeLen AS DOUBLE '= 2.200# 'transducer length
     'aProbeIdx  AS DOUBLE ' .800#   '1.00# '0.800# 'transducer index position, measured setback from front
     'aProbeWidth AS DOUBLE '= 2.600# 'transducer width

     ProbeWidth AS DOUBLE
     ProbeIdx AS DOUBLE 'set to (-) 'transducer index position, measured setback from front
     ProbeLen AS DOUBLE

'below added for EPRI Calc
'***********************************************************

     'Component Values
     PipeWT   AS DOUBLE 'Pipe Wall Thickness
     PipeOD   AS DOUBLE 'Pipe Outside Diameter
     BranchWT AS DOUBLE 'Branch Wall Thickness
     BranchOD AS DOUBLE 'Branch Connection Outside Diameter

     'Weld Dimensions
     InnerHazD  AS DOUBLE   'Inboard HAZ Diameter
     InnerWeldD AS DOUBLE   'Inboard Weld Diameter
     OuterWeldD AS DOUBLE   'Outboard Weld Diameter
     OuterHazD  AS DOUBLE   'Outboard HAZ Diameter

     'Axial Scan for Circ Flaw Data
     AxialStartD AS DOUBLE  'Ax Scan Start Diameter, in referance to index centerline
     AxialStopD AS DOUBLE   'Ax Scan Stop Diameter, in referance to index centerline
     AxialStroke AS DOUBLE  'Ax Scan Length
     AxialIndex AS DOUBLE   'Ax Scan Index resolution

     'Circ Scan for Axial Flaw Data
     CircOffsetD AS DOUBLE  'Circ Scan Zero Offset Diameter, in reference to index centerline
     CircStartD AS DOUBLE   'Circ Scan Start Diameter, in reference to index centerline
     CircStopD AS DOUBLE    'Circ Scan Stop Diameter, in reference to index centerline
     CircLength AS DOUBLE   'Scan Length
     CircIndex AS DOUBLE    'Circ Scan Index resolution

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
     eBaseClr AS LONG       'Outside egdes of HAZ, outer,inner, basemetal

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

    SetPixelR(10) AS SINGLE
    SetyMinR(10) AS SINGLE
    SetyMaxR(10) AS SINGLE
    SetxMinR(10) AS SINGLE
    SetxMaxR(10) AS SINGLE

    xNear AS LONG

END TYPE
'GLOBAL qWIN AS gScreen


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


   ' LOCAL ReturnValue AS LONG
   ' MessageBox 0, "This is a test message box.", "Test Message Box" , 5 TO ReturnValue
   ' PRINT;ReturnValue
   ' BEEP
   ' PRINT;"Keep on trucking."
   ' WAITKEY$




' MessageBox Value                  ReturnValue returns
' 0 = Okay                          1 = Okay
' 1 = Okay, Cancel                  2 = Cancel
' 2 = Abort, Retry, Ignore          3 = Abort
' 3 = Yes, No, Cancel               4 = Retry
' 4 = Yes, No                       5 = Ignore
' 5 = Retry, Cancel                 6 = Yes
' 6 = Cancel, Retry, Continue       7 = No
' 7 = Nothing                       8 = Not Defined
' 8 = Nothing                       9 = Not Defined
' 9 = Nothing                      10 = Try Again
'                                  11 = Continue



'FUNCTION KLJMessageBox (BYREF Message AS STRING , BYREF title AS STRING, BYVAL typebox AS LONG) AS LONG
'
'    KLJMessageBox = MSGBOX(Message, typebox, title)

'END FUNCTION


'FUNCTION KLJInput (BYREF prompt AS STRING , BYREF title AS STRING, BYREF defaultstring AS STRING, BYVAL xpos AS LONG, BYVAL ypos AS LONG) AS STRING
'
'    KLJInput = INPUTBOX$(prompt, title$, defaultstring, xpos, ypos)
'
'
'END FUNCTION


FUNCTION PBMAIN

    DIM MousePoint AS GLOBAL POINTAPI

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

    DIM aFont(360) AS GLOBAL LONG
    GLOBAL aFontNum AS LONG

    'play sound routine
    GLOBAL w AS waveheader, ww AS onesecwav

    GLOBAL Freq,Dur AS LONG

    'storage memory for mathamatical model generation and scan paths
    GLOBAL nPath, nIndex AS LONG
    GLOBAL eXpos(),eYpos(),eArc(),eAngle(), eOriginX(),eNormRdn(),eNormRad(),eRotDeg() AS DOUBLE
    DIM nRay AS FociRay, qRay AS QuarticRay, GFX AS GfxVars, nScan AS ScanVars

    DIM testvar(20) AS GLOBAL DOUBLE

    GLOBAL CaptionStr AS STRING


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


    Freq = 200 :Dur = 200 'WinBeep


    LOCAL numOfpaths, numOfindexes, n60HzSegs,nIndex2,lctr AS LONG
    LOCAL H, Hs, Ha, T, index AS DOUBLE

    'PipeOD = 36.00#
    'PipeOR = 18.00#
    'PipeChordAngle = 2.00# * ArcSin(nRay.minorDia/PipeOD)

    'user set colors for model
    GFX.eStartClr= %RGB_LIMEGREEN 'scan start; outer radial line color
    GFX.eEndClr= %RGB_YELLOW      'scan end; outer radial line color
    GFX.eExtraClr= %RGB_MAGENTA   'scan extra; outer radial line color
    GFX.eRadialClr= %RGB_BLUE     'all other; outer scan radial scan line
    GFX.eInsideClr= %RGB_BLUE     'center inside; radial line line color
    GFX.eOutPClr= %RGB_BLUE       'outer perimeter; line color
    GFX.eWeldClr= %RGB_GREEN 'GRAY 'DIMGRAY '%RGB_GREEN      'weld; radial line color
    GFX.eWeldPClr= %RGB_GRAY 'DIMGRAY '%RGB_GREEN     'weld; perimeter line color
    GFX.eHAZClr= %RGB_RED         'HAZ; radial line color
    GFX.eHAZPClr= %RGB_RED        'HAZ; perimeter line color
    GFX.eBaseClr = %RGB_GRAY      'outside edges of HAZ, base metal color

    'User set plotting colors
    GFX.probeClr= %RGB_GOLD       'probe perimeter case color
    GFX.probefillClr= %RGB_ORANGE 'probe fill color
    GFX.TngtLineClr= %RGB_MAGENTA 'weld tangent line color
    GFX.NormLineClr= %RGB_MAGENTA 'weld normal line color
    GFX.CentLineClr= %RGB_GOLD    'probe center line color, probe beam
    GFX.IdxLineClr= %RGB_GOLD     'probe index line color
    GFX.offsetBallClr= %RGB_WHITE 'ball at offset color
    GFX.probeBallClr= %RGB_WHITE  'ball at probe center color
    GFX.ballRad= .100# '0.050#           'meatball Rad

    'not set here - set dynamically in plot routine
    'user set crosshair line length Rad in inches
    ' GFX.CentLine = 5' USED !!  10 ' 1 ' 10
    ' GFX.IdxLine = 5  'NOT USED !!  '10 '1 '10
    ' GFX.TngtLine = 5 'NOT USED 10 ' 5' 10
    ' GFX.NormLine = 5 'NOT USED '10 '5' 10

    ' LOCAL ReturnValue AS LONG

    ' MessageBox gWIN.hWin(4), "QUIT?", "EXIT SCAN", 4 TO ReturnValue

    ' 'no = 7: yes = 6

    ' print ReturnValue

    ' waitkey$


'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'BEGIN USER INPUTS !!
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    'Component Values
    nScan.PipeWT = 4.00#   'Pipe Wall Thickness
    nScan.PipeOD = 36.00#  'Pipe Outside Diameter
    nScan.BranchWT = 1.00# 'Branch Wall Thickness
    nScan.BranchOD = 4.63# 'Branch Connection Outside Diameter

    'Weld Dimensions
    nScan.InnerHazD = 5.69#    'Inboard HAZ Diameter
    nScan.InnerWeldD = 6.19#   'Inboard Weld Diameter
    nScan.OuterWeldD = 10.19#  'Outboard Weld Diameter
    nScan.OuterHazD = 10.69#   'Outboard HAZ Diameter

    'Axial Scan for Circ Flaw Data
    nScan.AxialStartD = 11.32# 'Ax Scan Start Diameter, in referance to index centerline
    nScan.AxialStopD = 21.26#  'Ax Scan Stop Diameter, in referance to index centerline
   ' nScan.AxialStroke = 4.97# '5.39#  'Ax Scan Length
    nScan.AxialIndex = .075#   'Ax Scan Index resolution

    'Circ Scan for Axial Flaw Data
    nScan.CircOffsetD = 5.39#  'Circ Scan Zero Offset Diameter, in reference to index centerline
    nScan.CircStartD = 5.69#   'Circ Scan Start Diameter, in reference to index centerline
    nScan.CircStopD = 10.69#   'Circ Scan Stop Diameter, in reference to index centerline
    nScan.CircIndex = 0.25#    'Circ Scan Index resolution

    'Extra's needed for the program to be self-reliant
    '**********************************************************************************************
    'Axial Beam true or false?
    nScan.AxialBeam = TRUE

    nScan.AxialBeam = FALSE

    '------------------------------------------------------------------------------------------------------------
    ' IMPORTANT SCANNER OPTIONS
    '------------------------------------------------------------------------------------------------------------

    'Note: NOT SO OBVIOUS!!  In Degree's, 0 to 360 is CCW, 360 to 0 is CW

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

    nScan.yIdxNeg = TRUE    'y index's yBegin to yEnd, y must be at yBegin (outboard) when scan commences
    nScan.yIdxNeg = FALSE   'y index's yEnd to yBegin, y must be at yEnd (inboard) when scan commences

    nScan.xNear = TRUE  'X-Axis on near side of nozzle
    'nScan.xNear = FALSE 'X-Axis on far side of nozzle

    nScan.MtrsRev = TRUE    'x,y,z motor direction flipped, (+) = (-) and (-) = (+)
    nScan.MtrsRev = FALSE   'x,y,z motor direction unchanged

    gWin.xNear = nScan.xNear

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'END:   USER INPUTS !!
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


     '------------------------------------------------------------------------------------------------------------
     ' Setup raster scan parameters
     '------------------------------------------------------------------------------------------------------------

    IF nScan.AxialBeam THEN  'SET THE AXIAL UT BEAM SCAN PARAMETERS

        'set by user, AxialRaster is back and forth scan motion, to and from the weld
        'If AxialRaster is False, scan motion is side to side, parallel along the weld,
         nScan.AxialRaster = TRUE
        'nScan.AxialRaster = FALSE

        'NEW EPRI: Axial Beam for Circ Flaw Data
        '*****************************************************************************************************

        'user set Y-Scan begin and end
        'nScan.yBegin = (nScan.AxialStartD-nScan.OuterHazD) * Half 'y scan begin
        'nScan.yEnd = (nScan.AxialStopD-nScan.OuterHazD) * Half    'y scan end

        nScan.yBegin =(nScan.AxialStopD-nScan.OuterHazD) *Half 'y scan begin
        nScan.yEnd =  (nScan.AxialStartD-nScan.OuterHazD)*Half 'y scan end

        PRINT "nScan.yEnd - nScan.yBegin:"; nScan.yEnd; nScan.yBegin

        'needed if nScan.AxialRaster = False, meaning raster motion is Circ direction
        nScan.yIndexInc = .100#  'index increment for Circ Raster

        'needed for getting segment
        nScan.yIndexes = (nScan.yEnd-nScan.yBegin)/nScan.yIndexInc

        nScan.SkewDeg = 0 '90 ' transducer skew angle, in degrees usually always +/- 90 degrees to ray scan lines for circ scans
        nScan.skewRdn = DegToRdn(nScan.SkewDeg) ' transducer skew angle, converted to radians
        nScan.skewOffset = 0 '3.00 '4  '4.00# '0' .0001#' 2.00# '    'transducer offset, index distance, to UT beam @ ID

        nScan.yRadius = IIF(nScan.yEnd=>1.00#,nScan.yEnd,1.00#)

        'user set transducer length, width and index
        'has no effect on scan accuracy, all scan parameters taken from centerline of gimbal slide fixture
        '!!! CRITICAL !!!Index point of transducer MUST BE ALIGNED with CENTERLINE of GIMBAL SLIDE (plunger)
        'nScan.ProbeLen = 1.730# 'transducer length
        'nScan.ProbeIdx = 0.800# '0.500#   '1.00# '0.800# 'transducer index position, measured setback from front
        'nScan.ProbeWidth = 1.840# 'transducer width

        'changed for EPRI CALCS - not important, for display purpose only
        nScan.ProbeLen = 1.800# 'transducer length
        nScan.ProbeIdx = 0.900# '0.500#   '1.00# '0.800# 'transducer index position, measured setback from front
        nScan.ProbeWidth = 1.800# 'transducer width

        'set number of scan overlap x-indexes, = 0 if none
        nScan.xIndexPlus = 0 '40

        'nScan.xIndexInc = nScan.AxialIndex 'Ax Scan Index resolution 'set x index increments
        nScan.xIndexInc = 0.001#  'set x index increments

    ELSE    'SET THE CIRC UT BEAM SCAN PARAMETERS

        'set by user, AxialRaster is back and forth scan motion, to and from the weld
        nScan.AxialRaster = FALSE
        'nScan.AxialRaster = TRUE

        'NEW EPRI: Circ Beam for Axial Flaw Data
        '*****************************************************************************************************

        'user set Y-Scan begin and end
        nScan.yBegin = (nScan.CircStopD-nScan.OuterHazD) * Half 'y scan begin
        nScan.yEnd =   (nScan.CircStartD-nScan.OuterHazD) * Half    'y scan end

        'addtional value needed if nScan.AxialRaster = False, meaning raster motion is Circ direction
        nScan.yIndexInc = 0.250#  'index increment for Circ Raster

        'needed for generating the paths
        nScan.yIndexes = (nScan.yEnd-nScan.yBegin)/nScan.yIndexInc


        '90 = beam going CW;  -90 = beam going CCW
        nScan.SkewDeg = -90.00# '270.00# '@Ray.oFociRdn-270.000# ' 10.00# '.0001# '-12.00#  'transducer skew: -SkewDeg = transducer on -side, UT Beam pointing CW
        nScan.skewRdn = DegToRdn(nScan.SkewDeg) 'transducer skew angle, usually always +/- 90 degrees to ray scan lines for circ scans
        nScan.skewOffset = nScan.CircOffsetD  'transducer offset, index distance, in theory, to UT beam @ ID

        nScan.yRadius = nScan.yEnd 'IIF(nScan.yEnd=>1.00#,nScan.yEnd,1.00#)

        'user set transducer length, width and index
        'has no effect on scan accuracy, all scan parameters taken from centerline of gimbal slide fixture
        '!!! CRITICAL !!!Index point of transducer MUST BE ALIGNED with CENTERLINE of GIMBAL SLIDE (plunger)
        'nScan.ProbeLen = 1.730# 'transducer length
        'nScan.ProbeIdx = 0.800# '0.900#   '1.00# '0.800# 'transducer index position, measured setback from front
        'nScan.ProbeWidth = 1.840# '2.600# 'transducer width

        'changed for EPRI CALCS - not important, for display purpose only
        nScan.ProbeLen = 1.800# 'transducer length
        nScan.ProbeIdx = 0.900# '0.900#   '1.00# '0.800# 'transducer index position, measured setback from front
        nScan.ProbeWidth = 1.800# '2.600# 'transducer width

        'set number of scan overlap x-indexes, = 0 if none
        nScan.xIndexPlus = 0

        'nScan.xIndexInc = nScan.CircIndex 'Circ Scan Index resolution 'set x index increments
        nScan.xIndexInc = 0.001# '001# '0.100# '0.001#  'set x index increments

    END IF

    nRay.skewRdn = nScan.skewRdn

    nRay.skewDeg = nScan.SkewDeg

    nRay.Index = nScan.xIndexInc 'set model x index increments to x scan increments - must match!

'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

    '------------------------------------------------------------------------------------------------------------
    ' generate the mathamatical model
    '------------------------------------------------------------------------------------------------------------
    '********************************************************
    'all-inclusive data for scan model generation:          *
    nRay.oDeg = 270 '90 '270 '160.00#             'user start degrees     *
    nRay.oRdn = DegToRdn(nRay.oDeg)'user start in radians  *

    nRay.minorDia = nScan.OuterHazD 'AXIAL:(as measured on flat)

    'Note: If majorDia => PipeOD, program will crash !!!!!!!!!!!!!!!!!
    nRay.majorDia = ROUND((nScan.PipeOD*ArcSin(nRay.minorDia/nScan.PipeOD)),4)
    'nRay.majorDia = ROUND( (10.69##*ArcSin(nRay.minorDia/10.69##)), 4 )
    nRay.majorDia = ROUND( (14.80##*ArcSin(nRay.minorDia/14.80##)), 4 )

    IF nRay.majorDia => nScan.PipeOD THEN ' program will crash !!!!!!!!!!!!!!!!!
       PRINT "Error!! pipe OD is too small!"
       WAITKEY$
       END
    END IF

    'PRINT nRay.majorDia
    'WAITKEY$

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


    'nRay.circ360e  = 33.7144463933408# ' fix((nRay.circ360e)* 1000) / 1000 'nRay.circ360e-.001

    'calculate number of indexes, based on circumference and set index value
    'nIndex = 1.125#*nRay.circ360e/nRay.Index + 1000 '+10 index margin. 405/360 degrees = 1.125
    'added .075% margin: a steeper radius has more points in the first 45 degess of the 90 degree quadrant.
    nIndex = 1.200#*nRay.circ360e/nRay.Index '+.075% index margin. 405/360 degrees = 1.125

    REDIM eXpos(nIndex),eYpos(nIndex),eArc(nIndex),eAngle(nIndex) AS GLOBAL DOUBLE 'dim to estimate

    PRINT "guess nIndex:";nIndex

    'get the coordinates
    '*************************************************************************************************************
    nIndex = GetIndexCoord(VARPTR(nRay),nIndex) 'get the X,Y coordinate of each index along perimeter

    PRINT "Guess Circ:" ; nRay.circ360e
    PRINT "True  Circ:" ; nRay.circ360

    PRINT "eArc(0):" ; eArc(0)

    PRINT "nIndex:";nIndex
    PRINT "nRay.Index405:";nRay.Index405
    'PRINT "TIME:" ; TIMER - T 'elapsed time to calculate indexes

    PRINT nScan.yEnd;nScan.yBegin

    'BEEP

    'Print

    'T = GetRatio

    'PRINT "PRESS ANY KEY"
    'WAITKEY$

    REDIM PRESERVE eXpos(nIndex),eYpos(nIndex),eArc(nIndex),eAngle(nIndex) AS GLOBAL DOUBLE 'redim to actual; preserve data

    REDIM eOriginX(nIndex),eNormRdn(nIndex),eNormRad(nIndex),eRotDeg(nIndex) AS GLOBAL DOUBLE 'dim same as above
    GetIndexRays(VARPTR(nRay)) 'get the focal laws for each index

    '------------------------------------------------------------------------------------------------------------
    'math model complete

    'Set OverLap
    IF nScan.xIndexPlus THEN 'has overlap
       nScan.xIndexEnd =  MIN(nRay.Index360+nScan.xIndexPlus, nRay.Index405) 'make sure not past 360+45 (405) degrees
    ELSE  ' no overlap!
       nScan.xIndexEnd = nRay.Index360
    END IF

    'nScan.xIndexEnd = nScan.xIndexEnd * half + 7
    nScan.xIndexEnd = nScan.xIndexEnd + 7

'&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

    LOCAL ProbeOffset,ScanAxis,SkewAxis AS DOUBLE


    IF nScan.AxialBeam THEN
       ProbeOffset = nScan.ProbeLen * half + 0.200# 'added .100" gap to azimuth circle
    ELSE
       ProbeOffset = SQR(nScan.ProbeLen^2+nScan.Probewidth^2) * half + 0.200# 'added .100" gap to azimuth circle
    END IF

    ScanAxis = IIF(nScan.yBegin=>0,nScan.yBegin+nRay.majorRad+.500,nRay.majorRad+.500) + ProbeOffset

    SkewAxis =  nScan.skewOffset + ProbeOffset

    nScan.yRadius = IIF(nScan.AxialBeam,ScanAxis,SQR((ScanAxis^2)+(SkewAxis^2)))

    IF nScan.yRadius < nRay.majorRad+4.00 THEN nScan.yRadius = nRay.majorRad+4.00

    SetWindow(nScan.yRadius) ', nRay.MajorRad, nRay.MinorRad) ' set up the graphic window

    LOCAL RetVal AS LONG

    'needed for drawing only!!
    nScan.WeldWidth = (nScan.OuterWeldD-nScan.InnerWeldD) * half
    nScan.WeldHaz = (nScan.OuterHazD-nScan.OuterWeldD) * half

    RetVal = RunPlot(VARPTR(nRay),VARPTR(nScan),VARPTR(GFX),VARPTR(qRay))

    IF RetVal THEN  ' user closed window

    END IF

    'WinBeep 800,200

    WinBeep Freq,Dur

ExitWindows2:

    'Close and exit all windows
    GRAPHIC ATTACH gWIN.hWin(0), 0&  'select the STANDARD Graphics window
    GRAPHIC WINDOW END          'close the selected STANDARD Graphics window

    GRAPHIC ATTACH gWIN.hWin(1), 0&  'select the Memory Bitmap Graphics window
    GRAPHIC BITMAP END          'close the selected Memory Bitmap Graphics window

    GRAPHIC ATTACH gWIN.hWin(3), 0&  'select the Memory Bitmap Graphics window
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
FUNCTION Get360Rdn(BYVAL X#, BYVAL Y#, BYVAL A#) AS DOUBLE
    IF (X#=>0) AND (Y#=>0) THEN
       FUNCTION = A#                  'Quadrant(1),0-90 degrees,+COS(X),+SIN(Y) A# = 0 to 90
    ELSEIF (X#<0) AND (Y#>0) THEN
       FUNCTION = A#+Rdn180           'Quadrant(2), 90-180 degrees,-COS(X),+SIN(Y) A# = -89.999 to 0
    ELSEIF (X#=<0)AND (Y#<=0)THEN
       FUNCTION = A#+Rdn180           'Quadrant(3),180-270 degrees,-COS(X),-SIN(Y) A# = 0 to 90
    ELSEIF (X#>0) AND (Y#<0) THEN
       FUNCTION = A#+Rdn360           'Quadrant(4),270-360 degrees,+COS(X),-SIN(Y) A# = -89.999 to 0
    END IF
END FUNCTION


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
'Find Radius of any foci point:  Rad = (r1*r2)^3^.5 / (majorRad*minorRad)
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
'Segment length
'LAR = XY Point 1, SAR = XY Point 2
'----------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetXyLen (BYVAL x1 AS DOUBLE, BYVAL y1 AS DOUBLE,BYVAL x2 AS DOUBLE, BYVAL y2 AS DOUBLE) AS DOUBLE

         LOCAL x, y AS DOUBLE

         x = x1-x2 : y = y1-y2

         FUNCTION = SQR( SQ(x)+ SQ(y) )'segment length
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



FUNCTION Inside(x AS DOUBLE,y AS DOUBLE) AS LONG

         IF x < gWIN.xMinR(1) THEN FUNCTION = FALSE: EXIT FUNCTION
         IF x > gWIN.xMaxR(1) THEN FUNCTION = FALSE: EXIT FUNCTION
         IF y < gWIN.yMinR(1) THEN FUNCTION = FALSE: EXIT FUNCTION
         IF y > gWIN.yMaxR(1) THEN FUNCTION = FALSE: EXIT FUNCTION

         FUNCTION = TRUE

END FUNCTION


FUNCTION InsideBox(x1 AS DOUBLE,y1 AS DOUBLE,x2 AS DOUBLE,y2 AS DOUBLE) AS LONG

        IF (x1 < gWIN.xMinR(1)) AND (x2 < gWIN.xMinR(1)) THEN FUNCTION = FALSE: EXIT FUNCTION
        IF (x1 > gWIN.xMaxR(1)) AND (x2 > gWIN.xMaxR(1)) THEN FUNCTION = FALSE: EXIT FUNCTION
        IF (y1 < gWIN.yMinR(1)) AND (y2 < gWIN.yMinR(1)) THEN FUNCTION = FALSE: EXIT FUNCTION
        IF (y1 > gWIN.yMaxR(1)) AND (y2 > gWIN.yMaxR(1)) THEN FUNCTION = FALSE: EXIT FUNCTION

        FUNCTION = TRUE

END FUNCTION


'----------------------------------------------------------------------------------------------------------------------------------------------
'
' QUARTIC
'----------------------------------------------------------------------------------------------------------------------------------------------
'NEW
SUB GetQuartic(BYVAL xPos AS DOUBLE, BYVAL yPos AS DOUBLE, BYVAL RayPtr AS DWORD)

    LOCAL Ray AS FociRay POINTER : Ray = RayPtr

    LOCAL cb, cc, c_d, discrim, q, r, RRe, dum1, ERe, EIm, s, t, term1, _
          r13, sq_R, y1, z1Re, xRe, xIm, a, b, c, d, e, qy, qx, xPos2, yPos2 AS EXT

    LOCAL majorDia, minorDia AS EXT

    LOCAL rd AS LONG : rd = 14    'rounding places

    majorDia = @Ray.majorRad : minorDia = @Ray.minorRad

    xPos2 = ROUND(xPos,rd) : yPos2 = ROUND(yPos,rd)

    'bug out if direct match
    IF yPos2 = 0 THEN       'x>0=0;  x<0=180 degrees
       'xp = IIF(xPos2 > 0,@Ray.majorRad,-@Ray.majorRad) : EXIT SUB
       @Ray.nQx = IIF(xPos2 > 0,@Ray.majorRad,-@Ray.majorRad) : @Ray.nQy = yPos2 : EXIT SUB
    ELSEIF xPos2 = 0 THEN   'y>0=90; y<0=270 degrees
       'yp = IIF(yPos2 > 0,@Ray.minorRad,-@Ray.minorRad) : EXIT SUB
       @Ray.nQy = IIF(yPos2 > 0,@Ray.minorRad,-@Ray.minorRad) : @Ray.nQx = xPos2 : EXIT SUB
    END IF

    xPos2 = ABS(xPos) : yPos2 = ABS(yPos)

    a = (majorDia^2 - minorDia^2)^2
    b = -2.0 * majorDia^2 * xPos2 * (majorDia^2 - minorDia^2)
    c = majorDia^2 *(majorDia^2 * xPos2^2 + minorDia^2 * yPos2^2 - (majorDia^2 - minorDia^2)^2 )
    d = 2.0 * majorDia^4 * xPos2 * (majorDia^2 - minorDia^2)
    e = -majorDia^6 * xPos2^2

    IF a <> 1 THEN ' can't happen, but if it did: divide by zero GFP results
       b /= a : c /= a : d /= a : e /= a   'is always > 1 !!
    ELSE
       PRINT "Quartic ERROR 1" : BEEP :WAITKEY$
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
       PRINT "Quartic ERROR 3" : BEEP :WAITKEY$
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
       PRINT "Quartic ERROR 3" : PRINT sq_R : BEEP :WAITKEY$
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

    @Ray.nQy = IIF(yPos<0,-qY,qY) : @Ray.nQx = IIF(xPos<0,-qX,qX)


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

    'get the number of indexes
    GET filenumber,,nIndex
    REDIM eXpos(nIndex),eYpos(nIndex),eOriginX(nIndex),eNormRdn(nIndex), _
          eNormRad(nIndex),eRotDeg(nIndex),eArc(nIndex),eAngle(nIndex) AS GLOBAL DOUBLE

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

SUB PlotProbe(BYVAL xProbe AS DOUBLE,BYVAL yProbe AS DOUBLE,BYVAL zPos AS DOUBLE,BYVAL aPos AS DOUBLE,BYVAL xIdx AS LONG,_
              BYVAL RayPtr AS DWORD,BYVAL ScanPtr AS DWORD,BYVAL GfxPtr AS DWORD,BYVAL QPtr AS DWORD)

    'transducer plots derived from motor x,y,z position only, associated plots are projected from motor position
    'zpos (rotational degreees), !! INCLUDES skew degree, if any.  To plot normal, subtract skew degrees from zpos degrees
    'xPos, yPos = center of Z-Axis Rotational, Transducer index must be aligned with center of rotation for proper operation

    LOCAL nScan AS ScanVars POINTER, GFX AS GfxVars POINTER, nRay AS FociRay POINTER, Quartic AS QuarticRay POINTER
    LOCAL pSkewRdn,zRdn,zRdn90,zRdnNoSkew,seg1,seg2,ang1,pCOS,pSIN,nCOS,nSIN,COS_ZRdn,SIN_ZRdn,xPos1,yPos1,xPos2,yPos2,AngleRdn,xBeam,yBeam AS DOUBLE
    LOCAL fillprobe, Clr, pMethod AS LONG
    DIM x(16) AS LOCAL DOUBLE, y(16) AS LOCAL DOUBLE

    LOCAL A,B,C,D AS DOUBLE

    LOCAL ringOR,ringIR,ringOD,ringID,mtrL1,mtrL2,mtrW1,mtrW2 AS SINGLE

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
    x(1) = xProbe - @nScan.ProbeWidth * half * COS(zRdn90) : y(1) = yProbe - @nScan.ProbeWidth * half * SIN(zRdn90)
    'Locate far side of transducer case width, at current scan degree postion, projected from cross hair 0-180 line
    x(2) = xProbe + @nScan.ProbeWidth * half * COS(zRdn90) : y(2) = yProbe + @nScan.ProbeWidth * half * SIN(zRdn90)

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
    x(8) = xProbe + (@nScan.ProbeLen*half-@nScan.ProbeIdx) * COS_zRdn : y(8) = yProbe + (@nScan.ProbeLen*half-@nScan.ProbeIdx) * SIN_zRdn

    'Draw the transducer
    '********************************************************************************************************************
    GRAPHIC WIDTH 3& 'set line width to 3

    'GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@GFX.CentLineClr '@GFX.probeClr  'draw probe side 1
    'GRAPHIC LINE STEP -(y(6),x(6)),@GFX.CentLineClr '@GFX.probeClr       'draw probe side 2
    'GRAPHIC LINE STEP -(y(5),x(5)),@GFX.CentLineClr '@GFX.probeClr       'draw probe side 3
    'GRAPHIC LINE STEP -(y(3),x(3)),@GFX.CentLineClr '@GFX.probeClr       'draw probe side 4

    'draw transducer sides x4 (rectangle)
    GRAPHIC LINE(y(3),x(3))-(y(4),x(4)),@GFX.CentLineClr ',@GFX.probeClr  'draw probe side 1
    GRAPHIC LINE(y(5),x(5))-(y(6),x(6)),@GFX.CentLineClr ',@GFX.probeClr  'draw probe side 2
    GRAPHIC LINE(y(3),x(3))-(y(5),x(5)),@GFX.CentLineClr ',@GFX.probeClr  'draw probe side 3, Parallel with beam
    GRAPHIC LINE(y(4),x(4))-(y(6),x(6)),@GFX.CentLineClr ',@GFX.probeClr  'draw probe side 4, Parallel with beam

    GRAPHIC WIDTH 1& 'set line width back to 1
    GRAPHIC STYLE 2 :
    GRAPHIC LINE(y(1),x(1))-(y(2),x(2)), @GFX.IdxLineClr  'draw index line, transducer width
    GRAPHIC STYLE 0

    'draw meatball on transducer case, located on center of UT beam origin
    x(11) = xProbe - @GFX.ballRad : y(11) = yProbe - @GFX.ballRad 'transducer x,y position
    x(12) = xProbe + @GFX.ballRad : y(12) = yProbe + @GFX.ballRad 'transducer x,y position
    GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @GFX.probeClr
'******************************************************************
    'transducer is drawn!!


    'draw line from nozzel center through probe index center to outer edge
    IF GetSegLen(xProbe,yProbe) > @nScan.yRadius THEN  'probe is outside of circle
       GRAPHIC WIDTH 2:GRAPHIC LINE(0,0)-(yProbe,xProbe),%RGB_MAGENTA: GRAPHIC WIDTH 1
    ELSE                                               'probt is inside of circle
       AngleRdn = GetRdnE(xProbe,yProbe)
       yPos1 = @nScan.yRadius * SIN(AngleRdn)   'yRadius = inner diameter of compass
       xPos1 = @nScan.yRadius * COS(AngleRdn)
       GRAPHIC WIDTH 2:GRAPHIC LINE(0,0)-(yPos1,xPos1),%RGB_MAGENTA: GRAPHIC WIDTH 1
    END IF
    'draw .125" diameter circle at 0,0
    x(11) =-0.060# : y(11) = x(11)  ' x,y upper-left
    x(12) = 0.060# : y(12) = x(12) ' x,y Lower-right
    GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), %RGB_MAGENTA '@GFX.CentLineClr '@GFX.offsetBallClr

    'beam intersection point on weld at current cross hair position
    'rounded for more accurate fp compares, especially when approaching zero,e.g.,IF .0000000000001 = 0 THEN
    IF @nScan.skewOffset THEN 'x(7),Y(7) = center index of probe
       xBeam = ROUND( (xProbe-@nScan.skewOffset*COS_zRdn),10 )
       yBeam = ROUND( (yProbe-@nScan.skewOffset*SIN_zRdn),10 )
    ELSE
       xBeam = ROUND(eOriginX(xIdx),10)
       yBeam = 0
    END IF

    'GRAPHIC LINE(0,0)-(yBeam,xBeam), %RGB_MAGENTA   'nozzle center to weld UT beam intersection point

    'GRAPHIC LINE(yPos,xPos)-(yBeam,xBeam),%RGB_MAGENTA  'probe index center to weld UT beam intersection point

    'Draw dotted line UT beam
    GRAPHIC STYLE 2 :GRAPHIC LINE(yProbe,xProbe)-(yBeam,xBeam), @GFX.CentLineClr: GRAPHIC STYLE 0

    'Draw circle at UT beam end
    x(11) = xBeam - @GFX.ballRad : y(11) = yBeam - @GFX.ballRad ' x,y upper-left
    x(12) = xBeam + @GFX.ballRad : y(12) = yBeam + @GFX.ballRad ' x,y Lower-right
    GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @GFX.CentLineClr '@GFX.offsetBallClr

    'draw line: UT beam end to focus origin
    IF @nScan.skewOffset THEN
       x(13) = eOriginX(xIdx): y(13) = 0
       GRAPHIC LINE(y(13),x(13))-(yBeam,xBeam), @GFX.CentLineClr 'Focal line
       x(11) = x(13) - @GFX.ballRad : y(11) = y(13) - @GFX.ballRad ' x,y upper-left
       x(12) = x(13) + @GFX.ballRad : y(12) = y(13) + @GFX.ballRad ' x,y Lower-right
       GRAPHIC ELLIPSE (y(11),x(11))-(y(12),x(12)), @GFX.CentLineClr '@GFX.offsetBallClr
    END IF

    xPos1 = eXpos(xIdx) + 1.50 * COS(eNormRdn(xIdx))
    yPos1 = eYpos(xIdx) + 1.50 * SIN(eNormRdn(xIdx))
    xPos2 = eOriginX(xIdx) : yPos2 = 0
    GRAPHIC WIDTH 2
    GRAPHIC LINE(yPos1,xPos1)-(yPos2,xPos2), @GFX.CentLineClr 'Focal line
    GRAPHIC WIDTH 1
  '  AngleRdn = GetRdnE(xBeam,yBeam)
  '  yPos1 = @nScan.yRadius * SIN(AngleRdn)   'yRadius = inner diameter of compass
  '  xPos1 = @nScan.yRadius * COS(AngleRdn)
  '  GRAPHIC WIDTH 2:GRAPHIC LINE(0,0)-(yPos1,xPos1),%RGB_MAGENTA: GRAPHIC WIDTH 1
  '  GRAPHIC LINE(y(13),x(13))-(yBeam,xBeam), @GFX.CentLineClr 'Focal line






    EXIT SUB














    '******************************************************************
    'Draw Probe and UT Beam radial position indicators
    '******************************************************************
    LOCAL xIndex AS LONG
    LOCAL axPos,probeAngle,testAngle,tAngle,pAngle, aPosA AS DOUBLE


    'Draw radial UT BEAM travel from scan origin, parallel with perimeter
    '******************************************************************
    'compute beam end position
    xPos2 = aPos*COS(eNormRdn(0))+eXpos(0): yPos2 = aPos*SIN(eNormRdn(0))+eYpos(0)
    GRAPHIC SET POS(yPos2,xPos2)
    'GRAPHIC ELLIPSE (yPos2-.02,xPos2-.02)-(yPos2+.02,xPos2+.02),%RGB_YELLOW

    'draw the current y index perimeter, chords
    FOR xIndex = 1 TO xIdx STEP 100
        xPos2 = aPos*COS(eNormRdn(xIndex))+eXpos(xIndex): yPos2 = aPos*SIN(eNormRdn(xIndex))+eYpos(xIndex)
        GRAPHIC LINE STEP -(yPos2,xPos2),%RGB_YELLOW 'Chord: Draw index chord
    NEXT

    xPos2 = aPos*COS(eNormRdn(xIdx))+eXpos(xIdx): yPos2 = aPos*SIN(eNormRdn(xIdx))+eYpos(xIdx)
    GRAPHIC LINE STEP -(yPos2,xPos2),%RGB_YELLOW
    '******************************************************************


    'Draw radial PROBE travel from scan origin, parallel with perimeter
    '******************************************************************
    GetQuartic(xProbe,yProbe,RayPtr)  'x,y probe position
    'GRAPHIC ELLIPSE (@nRay.nQy-1,@nRay.nQx-1)-(@nRay.nQy+1,@nRay.nQx+1),%RGB_GREEN 'MAGENTA

    'SGN returns -1 for Negative, +1 for positive, 0 for zero
    axPos = GetSegLen(xProbe-@nRay.nQx,yProbe-@nRay.nQy) * SGN(GetSegLen(xProbe,yProbe)-GetSegLen(@nRay.nQx,@nRay.nQy))

    xPos2 = axPos*COS(eNormRdn(0))+eXpos(0): yPos2 = axPos*SIN(eNormRdn(0))+eYpos(0)
    GRAPHIC SET POS(yPos2,xPos2)

    'draw ellipse from zero to probe x,y position
    pAngle = GetAngleE(xProbe,yProbe)
    ProbeAngle = IIF(pAngle < @nRay.oFociDeg,pAngle+360,pAngle)

    FOR xIndex = 1 TO @nRay.Index360 STEP 100
        xPos2 = axPos*COS(eNormRdn(xIndex))+eXpos(xIndex): yPos2 = axPos*SIN(eNormRdn(xIndex))+eYpos(xIndex)
        tAngle = GetAngleE(xPos2,yPos2)
        TestAngle = IIF(tAngle<@nRay.oFociDeg,tAngle+360,tAngle)
        IF IIF(@nRay.IndexCW,ProbeAngle>TestAngle,TestAngle>ProbeAngle) THEN EXIT FOR
        GRAPHIC LINE STEP -(yPos2,xPos2), %RGB_MAGENTA 'Chord: Draw index chord
    NEXT

    xPos2 = axPos*COS(eNormRdn(xIdx))+eXpos(xIdx): yPos2 = axPos*SIN(eNormRdn(xIdx))+eYpos(xIdx)
    GRAPHIC LINE STEP -(yProbe,xProbe),%RGB_MAGENTA       'Draw end gap chord
    '******************************************************************

    EXIT SUB

    'position of beam - find the UT beam foci x,y coordinates along the perimeter
    GetQuartic(xBeam, yBeam, nRay) 'returns in @nRay.nQx & @nRay.nQy

'*************************************************************************************
'Begin find y (axial) in relation to a straight weld
'*************************************************************************************
    'get position of beam - need probe x,y,z to compute!!
    IF @nScan.skewOffset THEN
       x(14) = xProbe-@nScan.skewOffset*COS_zRdn : y(14) = yProbe-@nScan.skewOffset*SIN_zRdn
    ELSE
       x(14) = eOriginX(xIdx): y(14) = 0
    END IF

    'equals position of beam
    x(7) = x(14) : y(7) = y(14)  'x(7) = ROUND(x(14),10) : y(7) = ROUND(y(14),10)

    'compute Y (axial) position in relation to a straight weld
    axPos = GetSegLen(xBeam-@nRay.nQx,yBeam-@nRay.nQy) * SGN(GetSegLen(xBeam,yBeam)-GetSegLen(@nRay.nQx,@nRay.nQy))

'End find y
'*************************************************************************************

'*************************************************************************************
'Begin find x
'*************************************************************************************
    'need perimeter or focus x,y location
    LOCAL fAngle, FocusAngle AS DOUBLE
    fAngle = ROUND(GetRdnE(@nRay.nQx,@nRay.nQy),4) 'focus point to center angle
    FocusAngle = IIF(fAngle < @nRay.oFociRdn,fAngle+Rdn360,fAngle)

    FOR xIndex = 0 TO @nRay.Index360 '@Ray.Index405  '@nRay.Index360 'STEP 100
       tAngle = ROUND(GetRdnE(eXpos(xIndex),eYpos(xIndex)),4)
       TestAngle = IIF(tAngle<@nRay.oFociRdn,tAngle+Rdn360,tAngle)
       IF IIF(@nRay.IndexCW,FocusAngle=>TestAngle,TestAngle=>FocusAngle) THEN EXIT FOR
    NEXT

'End find x
'***********************************************************************************

    GRAPHIC LINE(@nRay.nQy,@nRay.nQx)-(yBeam,xBeam), %RGB_HOTPINK

    GRAPHIC ELLIPSE (@nRay.nQy-.1,@nRay.nQx-.1)-(@nRay.nQy+.1,@nRay.nQx+.1),%RGB_YELLOW'MAGENTA

    GRAPHIC ELLIPSE (yBeam-.1,xBeam-.1)-(yBeam+.1,xBeam+.1),%RGB_YELLOW'MAGENTA

'    GRAPHIC LINE(0,eOriginX(xIndex))-(eYpos(xIndex),eXpos(xIndex)), %RGB_yellow 'HOTPINK
'    GRAPHIC LINE(yPos,xPos)-(eYpos(xIndex),eXpos(xIndex)), %RGB_YELLOW 'HOTPINK
'
    GRAPHIC LINE(0,eOriginX(xIndex))-(yProbe,xProbe), %RGB_YELLOW 'HOTPINK

    GRAPHIC LINE(0,eOriginX(xIndex))-(yProbe,xProbe), %RGB_YELLOW 'HOTPINK

    GRAPHIC ELLIPSE (yProbe-@nScan.skewOffset,xProbe-@nScan.skewOffset)-(yProbe+@nScan.skewOffset,xProbe+@nScan.skewOffset),%RGB_YELLOW'MAGENTA

    EXIT SUB

'END of added 110616 for epri calculation
'************************************************************

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
       x(13) = xProbe-@nScan.skewOffset*COS_zRdn : y(13) = yProbe-@nScan.skewOffset*SIN_zRdn
    ELSE : x(13) = xProbe : y(13) = yProbe
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
         GetQuartic(x(7), y(7), nRay) 'find the UT beam foci x,y coordinates along the perimeter
         GetFoci(@nRay.nQx, @nRay.nQy, RayPtr)  'get focal laws at x,y position
         x(11) = @nRay.nQx + (@nScan.yRadius) * COS(zRdnNoSkew) : y(11) = @nRay.nQy + (@nScan.yRadius) * SIN(zRdnNoSkew)
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

'    IF @nScan.skewOffset OR pSkewRdn THEN 'focus, draw solid line
'       GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@GFX.IdxLineClr   '%RGB_HOTPINK '@GFX.IdxLineClr
'    ELSE  'beam, draw dotted line ' 0:Solid(default), 1:Dash, 2:Dot, 3:DashDot, 4:DashDotDot
'       GRAPHIC STYLE 2 : GRAPHIC LINE(y(11),x(11))-(y(12),x(12)),@GFX.IdxLineClr: GRAPHIC STYLE 0
'    END IF

    'draw circle at focus target point
'    GRAPHIC ELLIPSE(y(12)-@GFX.ballRad,x(12)-@GFX.ballRad)-(y(12)+@GFX.ballRad,x(12)+@GFX.ballRad),@GFX.offsetBallClr

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
       GRAPHIC STYLE 2: GRAPHIC LINE(y(7),x(7))-(yProbe,xProbe),@GFX.CentLineClr : GRAPHIC STYLE 0
    END IF

END SUB


'mod 1
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

    LOCAL GFX AS GfxVars POINTER, nScan AS ScanVars POINTER, nRay AS FociRay POINTER
    LOCAL cosA, sinA, yPos, xPos, yPos1, xPos1, yPos2, xPos2 AS DOUBLE
    LOCAL fillstyle, PixelClr, Clr, yIndexE, yIndex, xIndexS, xIndexE, xIndex, index AS LONG

    LOCAL yOff1,yOff2,xOff1,xOff2 AS DOUBLE

    GFX = GFXptr : nScan = Scanptr : nRay = RayPtr

    DIM x(20) AS SINGLE
    DIM y(20) AS SINGLE

    DIM pTarget(20) AS LOCAL DOUBLE

    DIM pLoc(20) AS LOCAL DOUBLE 'perimeter location

    pLoc(0) = -(@nScan.WeldHaz*2.00# + @nScan.WeldWidth+.500)'-.50" inboard from the inner exam zone
    pLoc(1) = -(@nScan.WeldHaz*2.00# + @nScan.WeldWidth)     'located on the negative (inboard) side of the referenced perimeter
    pLoc(2) = -(@nScan.WeldHaz + @nScan.WeldWidth)           'located on the negative (inboard) side of the referenced perimeter
    pLoc(3) = -(@nScan.WeldHaz)                              'located on the negative (inboard) side of the referenced perimeter
    pLoc(4) = 0                                              'zero reference, located at outer HAZ edge
    pLoc(5) = 0.500#                                         '+.50" outboard from the outer exam zone
    pLoc(6) = 2.375#


    DIM pClr(20) AS LONG
    'pClr(0) = @GFX.eInsideClr'inner Basemetal
    'pClr(1) = @GFX.eHAZClr   'inner HAZ
    'pClr(2) = @GFX.eWeldClr  'Weld
    'pClr(3) = @GFX.eHAZClr   'outer HAZ
    'pClr(4) = @GFX.eOutPClr  'outer Basemetal

    pClr(0) = @GFX.eBaseClr '%RGB_YELLOW
    pClr(1) = @GFX.eHAZClr   'HAZ
    pClr(2) = @GFX.eHAZClr   'HAZ
    pClr(3) = @GFX.eHAZClr   'HAZ
    pClr(4) = @GFX.eHAZClr   'HAZ
    pClr(5) = @GFX.eBaseClr '%RGB_Yellow
    pClr(6) = %RGB_WHITE '@GFX.eWeldClr '%RGB_Yellow

    '***********************************************************************************************************
    'DRAW Curved perimeters: Base Metal,HAZ and Weld
    '***********************************************************************************************************
    xIndexE = @nRay.Index359 : Clr = @GFX.eHAZClr

    FOR yIndex = 0 TO 5  'draw standard perimeters

        'set each start postion to one index before zero
        xPos1 = eXpos(0)+ pLoc(yIndex)*COS(eNormRdn(0))
        yPos1 = eYpos(0)+ pLoc(yIndex)*SIN(eNormRdn(0))
        GRAPHIC SET POS (yPos1, xPos1)

        'draw the current perimeter, 0 to 360
        FOR xIndex = 0 TO xIndexE STEP 100    'added STEP 11/14/16 to speed up plotting; = .100"
            xPos2 = eXpos(xIndex)+ pLoc(yIndex)*COS(eNormRdn(xIndex))
            yPos2 = eYpos(xIndex)+ pLoc(yIndex)*SIN(eNormRdn(xIndex))
            GRAPHIC LINE STEP -(yPos2,xPos2), pClr(yIndex)   'Chord: Draw border
        NEXT

        'added 11/14/16 for step above to make sure circle end connects and closes to contain painting
        xPos2 = eXpos(0)+ pLoc(yIndex)*COS(eNormRdn(0))
        yPos2 = eYpos(0)+ pLoc(yIndex)*SIN(eNormRdn(0))
        GRAPHIC LINE STEP -(yPos2,xPos2),pClr(yIndex)   'Chord: Draw border

    NEXT

    '***********************************************************************************
    'draw simulated branch connection ID & OD
    '***********************************************************************************
    GRAPHIC ELLIPSE (-2.313#,-2.313#)-(2.313#,2.313#),%RGB_DIMGRAY '%RGB_GAINSBORO
    GRAPHIC ELLIPSE (-1.313#,-1.313#)-(1.313#,1.313#),%RGB_DIMGRAY ' %RGB_GAINSBORO


    'GRAPHIC PAINT [BORDER | REPLACE] [STEP] (x!, y!) [, [rgbFill&] [, [rgbBorder&] [, [fillstyle&]]]]
    '0 Solid (default)
    '1 Horizontal Lines
    '2 Vertical Lines
    '3 Upward Diagonal Lines
    '4 Downward Diagonal Lines
    '5 Crossed Lines
    '6 Diagonal Crossed Lines


  '  pLoc(0) = -(@nScan.WeldHaz*2.00# + @nScan.WeldWidth+.500)'-.50" inboard side of the referenced perimeter
  '  pLoc(1) = -(@nScan.WeldHaz*2.00# + @nScan.WeldWidth)     'located on the negative (inboard) side of the referenced perimeter
  '  pLoc(2) = -(@nScan.WeldHaz + @nScan.WeldWidth)           'located on the negative (inboard) side of the referenced perimeter
  '  pLoc(3) = -(@nScan.WeldHaz)                              'located on the negative (inboard) side of the referenced perimeter
  '  pLoc(4) = 0                                              'zero reference, located at outer HAZ edge
  '  pLoc(5) = 0.500#                                         '+.50" outboard from zero reference


     'inches per pixel - graphic window size
'    gWIN.PixelR(0)

    DIM pMin(20) AS LOCAL DOUBLE 'perimeter locations
    DIM pMid(20) AS LOCAL DOUBLE
    DIM pMax(20) AS LOCAL DOUBLE

    pMin(6) = -(.500-(gWIN.PixelR(0)*2))    '.250  'outside basemetal; .500"
    pMid(6) = -.250
    pMax(6) = -(gWIN.PixelR(0)*2)

    pMin(7) = gWIN.PixelR(0)*2                  'outer HAZ
    pMid(7) = @nScan.WeldHaz*half
    pMax(7) = @nScan.WeldHaz-(gWIN.PixelR(0)*2)

    pMin(8) = @nScan.WeldHaz+(gWIN.PixelR(0)*2) 'weld
    pMid(8) = @nScan.WeldHaz+@nScan.WeldWidth*half
    pMax(8) = @nScan.WeldHaz+@nScan.WeldWidth-(gWIN.PixelR(0)*2)

    pMin(9) = @nScan.WeldHaz + @nScan.WeldWidth + (gWIN.PixelR(0)*2) 'inner HAZ
    pMid(9) = @nScan.WeldHaz + @nScan.WeldWidth + (@nScan.WeldHaz*half)
    pMax(9) = (@nScan.WeldHaz*2) + @nScan.WeldWidth - (gWIN.PixelR(0)*2)

    pMin(10) = @nScan.WeldWidth + (@nScan.WeldHaz*2) + (gWIN.PixelR(0)*2) 'inner basemetal
    pMid(10) = (@nScan.WeldWidth + (@nScan.WeldHaz*2) + .250)' 500)*half
    pMax(10) = @nScan.WeldWidth + (@nScan.WeldHaz*2) + .500 - (gWIN.PixelR(0)*2)

    pClr(6) = @GFX.eBaseClr '%RGB_YELLOW
    pClr(7) = @GFX.eHAZClr   'HAZ
    pClr(8) = @GFX.eWeldClr   'weld
    pClr(9) = @GFX.eHAZClr   'HAZ
    pClr(10)= @GFX.eBaseClr '%RGB_Yellow

    LOCAL NoPaint,Ctr AS LONG
    LOCAL pyLoc AS DOUBLE

    xIndexE = @nRay.Index359 : Clr = @GFX.eHAZClr

    FOR yIndex = 6 TO 10 'Paint inside perimeters

        NoPaint = TRUE

        FOR xIndex = 0 TO xIndexE STEP 100    'added STEP 11/14/16 to speed up plotting; = .100"

            xPos1 = eXpos(xIndex)-pMin(yIndex)*COS(eNormRdn(xIndex))
            yPos1 = eYpos(xIndex)-pMin(yIndex)*SIN(eNormRdn(xIndex))
            xPos2 = eXpos(xIndex)-pMax(yIndex)*COS(eNormRdn(xIndex))
            yPos2 = eYpos(xIndex)-pMax(yIndex)*SIN(eNormRdn(xIndex))

            IF InsideBox(xPos1,yPos1,xPos2,yPos2) THEN
               IF NoPaint THEN   'hasn't been painted or paint was previously blocked
                  pyLoc = pMid(yIndex) 'find inside position - start in the middle
                  xPos1 = eXpos(xIndex)-pyLoc*COS(eNormRdn(xIndex))
                  yPos1 = eYpos(xIndex)-pyLoc*SIN(eNormRdn(xIndex))
                  IF Inside(xPos1,yPos1) THEN
                     GRAPHIC PAINT REPLACE(yPos1,xPos1),pClr(yIndex),0,6
                     NoPaint = FALSE 'set to painted
                     'PRINT yIndex
                  ELSE
                     pyLoc = pMin(yIndex) 'try minimum position
                     xPos1 = eXpos(xIndex)-pyLoc*COS(eNormRdn(xIndex))
                     yPos1 = eYpos(xIndex)-pyLoc*SIN(eNormRdn(xIndex))
                     IF Inside(xPos1,yPos1) THEN
                        GRAPHIC PAINT REPLACE(yPos1,xPos1),pClr(yIndex),0,6
                        NoPaint = FALSE 'set to painted
                        'PRINT yIndex
                     ELSE
                        pyLoc = pMax(yIndex) 'try maximum position
                        xPos1 = eXpos(xIndex)-pyLoc*COS(eNormRdn(xIndex))
                        yPos1 = eYpos(xIndex)-pyLoc*SIN(eNormRdn(xIndex))
                        IF Inside(xPos1,yPos1) THEN
                           GRAPHIC PAINT REPLACE(yPos1,xPos1),pClr(yIndex),0,6
                           NoPaint = FALSE 'set to painted
                           'PRINT yIndex
                        ELSE   'outside of min,mid and max locations - have to search
                           FOR pyLoc = pMin(yIndex) TO pMax(yIndex) STEP (gWIN.PixelR(0)*2)'2 pixel step
                               xPos1 = eXpos(xIndex)-pyLoc*COS(eNormRdn(xIndex))
                               yPos1 = eYpos(xIndex)-pyLoc*SIN(eNormRdn(xIndex))
                               IF Inside(xPos1,yPos1) THEN
                                  GRAPHIC PAINT REPLACE(yPos1,xPos1),pClr(yIndex),0,6
                                  NoPaint = FALSE 'set to painted
                                  EXIT FOR
                               END IF
                           NEXT
                        END IF
                     END IF
                  END IF
               END IF   'inside box and painted:  paint already flowed here
            ELSE  'not inside, assume paint flow is now blocked
               NoPaint = TRUE
            END IF
        NEXT
    NEXT

    fillstyle = 6

    'paint branch connection
    GRAPHIC PAINT (1.813, 0),%RGB_DIMGRAY,%RGB_DIMGRAY,fillstyle' %RGB_GAINSBORO,%RGB_GAINSBORO,6
    GRAPHIC PAINT (-1.813,0),%RGB_DIMGRAY,%RGB_DIMGRAY,fillstyle' %RGB_GAINSBORO,%RGB_GAINSBORO,6
    GRAPHIC PAINT (0, 1.813),%RGB_DIMGRAY,%RGB_DIMGRAY,fillstyle' %RGB_GAINSBORO,%RGB_GAINSBORO,6
    GRAPHIC PAINT (0,-1.813),%RGB_DIMGRAY,%RGB_DIMGRAY,fillstyle' %RGB_GAINSBORO,%RGB_GAINSBORO,6

    'Draw weld Center line

    LOCAL WeldCL AS DOUBLE

    'GRAPHIC STYLE 2 'set for dotted line

    Clr = %RGB_LIGHTGRAY 'silver 'GRAY '%RGB_SLATEGRAY '%RGB_LIGHTSLATEGRAY '%RGB_gray 'darkgray 'WHITE

    WeldCL = -(@nScan.WeldHaz + @nScan.WeldWidth * half)

    Index = 0
    xPos1 = eXpos(Index) + WeldCL * COS(eNormRdn(Index))
    yPos1 = eYpos(Index) + WeldCL * SIN(eNormRdn(Index))
    GRAPHIC SET POS(yPos1,xPos1)

    FOR Index = 1 TO @nRay.Index359 STEP 100

         'current index x,y position along perimeter + -(WeldCL)
         xPos1 = eXpos(Index) + WeldCL * COS(eNormRdn(Index))
         yPos1 = eYpos(Index) + WeldCL * SIN(eNormRdn(Index))

         GRAPHIC LINE STEP -(yPos1,xPos1),Clr

    NEXT

    Index = 0 '@nRay.Index359
    xPos1 = eXpos(Index) + WeldCL * COS(eNormRdn(Index))
    yPos1 = eYpos(Index) + WeldCL * SIN(eNormRdn(Index))
    GRAPHIC LINE STEP -(yPos1,xPos1),Clr

    GRAPHIC STYLE 0 'set back to default solid line

    'exit sub


    '===============================================================================
    'Extra's:  Draw markers and Identifiers
    '===============================================================================



    '************************* Draw 0-360 degree azimuth markers ********************
    '********************************************************************************
    LOCAL iDeg AS LONG
    LOCAL fDeg, Rdn, fRdn, fRadi, fRado, oRdn, d10, d5, d1, GradL, foff,txtoff AS DOUBLE
    LOCAL StrPos2$

    d10 = .350# : d5 = .250# : d1 = .100#
    fRadi = @nScan.yRadius

    'compute degree offset for middle of text height vs pixel:inch ratio
    'trying to keep middle of text aligned with degree marker
    xPos1 = gWIN.PixelR(0)*2 'half of 4 pixel height for 10 pt font looks about right
    yPos1 = SQR( SQ(xPos1) + SQ(fRadi+d10))
    oRdn = Rdn90-ArcCos(xPos1/yPos1)
    txtOff = gWIN.PixelR(0)*2

    '   PRINT "RES:";ROUND(RdnToDeg(ArcCos(xPos1/yPos1)),3)
    'draw degree markers,print degree, 0 to 359 '360
    FOR iDeg = 0 TO 359

        fRdn = DegToRdn(iDeg)

        IF (iDeg MOD 10) = 0 THEN
           GradL = d10
           Rdn = fRdn + oRdn
           'xPos2 = (fRadi+GradL)*COS(Rdn)
           'yPos2 = (fRadi+GradL)*SIN(Rdn)
           xPos2 = (fRadi+GradL+txtOff)*COS(Rdn)
           yPos2 = (fRadi+GradL+txtOff)*SIN(Rdn)
           GRAPHIC SET FONT aFont((iDeg+270)MOD 360)
           GRAPHIC SET POS (yPos2,xPos2)
           'StrPos2$ = STR$(iDeg)
           StrPos2$ = USING$( "#" + CHR$(176),iDeg )
           GRAPHIC PRINT StrPos2$
        ELSEIF (iDeg MOD 5) = 0 THEN
           GradL = d5
        ELSE
           GradL = d1
        END IF

        xPos1 = (fRadi)*COS(fRdn) : yPos1 = (fRadi)*SIN(fRdn)
        xPos2 = (fRadi+GradL)*COS(fRdn) : yPos2 = (fRadi+GradL)*SIN(fRdn)
        GRAPHIC LINE (yPos1,xPos1)-(yPos2,xPos2), %RGB_WHITE       'Draw degree marker lines

    NEXT

   ' GRAPHIC SET FONT gFont(FontNum)  'set back to default font

    Clr = %RGB_WHITE

    'draw inner azimuth perimeter
    'ellipse not accurate
    'GRAPHIC WIDTH 2: GRAPHIC ELLIPSE (-fRad,-fRad)-(fRad,fRad), %RGB_WHITE : GRAPHIC WIDTH 1
    'GRAPHIC WIDTH 2 :
    DrawCircle(0, 0, fRadi, Clr): GRAPHIC WIDTH 1 'ELLIPSE not accurate, degree line markers don't match

    'draw outer azimuth perimeter
    fRado = @nScan.yRadius + d10 + (42 * gWIN.PixelR(0)) '= outside radius + Grad line length + 42 pixels

    GRAPHIC ELLIPSE (-fRado,-fRado)-(fRado,fRado),Clr
   'DrawCircle(0, 0, fRado, %RGB_HOTPINK): GRAPHIC WIDTH 1 'ELLIPSE not accurate, degree line markers don't match
    '****************  Finished Drawing 0-360 Azimuth markers  *******************                                                                     *
    '*****************************************************************************
    'exit sub


    '*************************** Draw Circ Inch markers **************************
    '*****************************************************************************
    d10 = .350# : d5 = .250# : d1 = .100#

    xPos1 = eXpos(xIndex)-pyLoc*COS(eNormRdn(xIndex))
    yPos1 = eYpos(xIndex)-pyLoc*SIN(eNormRdn(xIndex))

    LOCAL xOff, yOff,off1, Cos1, Sin1 AS DOUBLE
    LOCAL StrPos$

    'compute degree offset for middle of text height vs pixel:inch ratio
    'trying to keep middle of text aligned with degree marker
    xPos1 = gWIN.PixelR(0)*8 'half of 4 pixel height for 10 pt font looks about right
    yPos1 = SQR( SQ(xPos1) + SQ(@nRay.MinorRad+half+d10))
    oRdn = Rdn90-ArcCos(xPos1/yPos1)

    xIndexE = @nRay.Index359

    off1 = 1.5 'half

    txtOff = gWIN.PixelR(0)*2

    FOR xIndex = 0 TO xIndexE STEP 100  '.100" '100 = .100, 500 = .500, 1000 = 1.00

        Cos1 = COS(eNormRdn(xIndex)+oRdn) : Sin1 = SIN(eNormRdn(xIndex)+oRdn)

        IF (xIndex MOD 1000) = 0 THEN  '1.00"
           GradL = d10
           xPos2 = eXpos(xIndex) + (off1+GradL+txtOff)* Cos1
           yPos2 = eYpos(xIndex) + (off1+GradL+txtOff)* Sin1
           iDeg = RdnToDeg(eNormRdn(xIndex))
           GRAPHIC SET FONT aFont((iDeg+270)MOD 360)
           GRAPHIC SET POS (yPos2,xPos2)
           StrPos$ = USING$( "#.##" + CHR$(34),eArc(xIndex) )
           GRAPHIC PRINT StrPos$
        ELSEIF (xIndex MOD 500) = 0 THEN  '.500"
           GradL = d5
        ELSE
           GradL = d1  '100           '.100"
        END IF

        Cos1 = COS(eNormRdn(xIndex)) : Sin1 = SIN(eNormRdn(xIndex))
        xPos1 = eXpos(xIndex) + (off1*Cos1)
        yPos1 = eYpos(xIndex) + (off1*Sin1)
        xPos2 = xPos1 + (GradL*Cos1)
        yPos2 = yPos1 + (GradL*Sin1)

        GRAPHIC LINE (yPos1,xPos1)-(yPos2,xPos2), %RGB_WHITE       'Draw degree marker lines

    NEXT

    GRAPHIC SET FONT gFont(FontNum)  'set back to default font

    'exit sub
    Clr = %RGB_WHITE

    'draw inner azimuth perimeter
    'ellipse not accurate
    'GRAPHIC WIDTH 2: GRAPHIC ELLIPSE (-fRad,-fRad)-(fRad,fRad), %RGB_WHITE : GRAPHIC WIDTH 1
    'GRAPHIC WIDTH 2 :
    'DrawCircle(0, 0, fRadi, Clr): GRAPHIC WIDTH 1 'ELLIPSE not accurate, degree line markers don't match

    'draw outer azimuth perimeter
   ' GRAPHIC ELLIPSE (-fRado,-fRado)-(fRado,fRado),Clr

    '*****************  Finished Draw Circ Inch markers  *************************
    '*****************************************************************************


    ' fRado = @nScan.yRadius + d10 + (42 * gWIN.PixelR(0)) '= outside radius + Grad line length + 42 pixels

    'off1 = 1 'half 'fRadi- @nRay.minorRad
    Index = 0

    xPos1 = eXpos(Index) + off1 * COS(eNormRdn(Index))
    yPos1 = eYpos(Index) + off1 * SIN(eNormRdn(Index))

    GRAPHIC SET POS(yPos1,xPos1)

    xIndexE = @nRay.Index359

    FOR Index = 1 TO xIndexE STEP 100  '= .100 steps

        'current index x,y position
        xPos1 = eXpos(Index) + off1 * COS(eNormRdn(Index))
        yPos1 = eYpos(Index) + off1 * SIN(eNormRdn(Index))
         GRAPHIC LINE STEP -(yPos1,xPos1),Clr 'green 'red

    NEXT

    Index = 0 '@nRay.Index359
    xPos1 = eXpos(Index) + off1 * COS(eNormRdn(Index))
    yPos1 = eYpos(Index) + off1 * SIN(eNormRdn(Index))
    GRAPHIC LINE STEP -(yPos1,xPos1),Clr 'green 'red

   ' EXIT SUB

    LOCAL RadMin, RadMax AS DOUBLE

    RadMin = off1 + @nRay.minorRad + 2
    RadMax = off1 + @nRay.majorRad + 2

    'fRado = @nScan.yRadius + d10 + (42 * gWIN.PixelR(0)) '= outside radius + Grad line length + 42 pixels

    'draw outer perimeter
    'GRAPHIC ELLIPSE (-RadMin,-RadMax)-(RadMin,RadMax),Clr

    'draw dotted lines @ 0:360, 90, 180, 360 degree
    GRAPHIC STYLE 2 'set for dotted line
    GRAPHIC LINE (-(@nRay.minorRad+1.50),0)-((@nRay.minorRad+1.50),0),%RGB_WHITE
    GRAPHIC LINE (0,-(@nRay.majorRad+1.50))-(0,(@nRay.majorRad+1.50)),%RGB_WHITE
    GRAPHIC STYLE 0 'set for solid line

    'draw pipe: purpose to diagram pipe orientation to user, no size accuracy or relevance to actual pipe under test
    LOCAL FillClr AS LONG
    FillClr = %RGB_DIMGRAY '%RGB_BROWN

    GRAPHIC WIDTH 4

   'draw pipe right end and paint
    GRAPHIC ELLIPSE (fRado+.2,-(fRado+.2))-(fRado+2.2,fRado+.2),Clr,FillClr,4
    'draw pipe left end
    GRAPHIC ARC (-(fRado+.2),-(fRado+.2))-(-(fRado-2.8),fRado+.2),rdn90,rdn270,Clr
    'draw pipe top line
    GRAPHIC LINE (-(fRado-1.3),-(fRado+.2))-(fRado+1.2,-(fRado+.2)),Clr
    'draw pipe bottom line
    GRAPHIC LINE (-(fRado-1.3),fRado+.2)-(fRado+1.2,fRado+.2),Clr

    GRAPHIC WIDTH 1

    xPos1 = (fRado+.25) * COS(Rdn45) : yPos1 = (fRado+.25) * SIN(Rdn45)

    'paint pipe
    GRAPHIC PAINT(yPos1,xPos1),FillClr,Clr,3'6
    GRAPHIC PAINT(-yPos1,xPos1),FillClr,Clr,3'6
    GRAPHIC PAINT(yPos1,-xPos1),FillClr,Clr,3'6
    GRAPHIC PAINT(-yPos1,-xPos1),FillClr,Clr,3'6

    GRAPHIC PAINT(0, (frado+.1)),FillClr,Clr,3'6
    GRAPHIC PAINT(0,-(frado+.1)),FillClr,Clr,3'6
    GRAPHIC PAINT( (frado+.1),0),FillClr,Clr,3'6
    GRAPHIC PAINT(-(frado+.1),0),FillClr,Clr,3'6


     '  GRAPHIC PAINT(fRado,-fRado),FillClr,Clr,3'6
  '  GRAPHIC PAINT(-fRado,fRado),FillClr,Clr,3'6
  '  GRAPHIC PAINT(-fRado,-fRado),FillClr,Clr,3'6

    'paint pipe
    'GRAPHIC PAINT(0, (frado+.25)),FillClr,Clr,3'6
    'GRAPHIC PAINT(0,-(frado+.25)),FillClr,Clr,3'6
    'GRAPHIC PAINT( (frado+.25),0),FillClr,Clr,3'6
    'GRAPHIC PAINT(-(frado+.25),0),FillClr,Clr,3'6

    EXIT SUB


    '****************************************************************************************************
    'Draw Skewed ellipse -  for skew scans only
    '****************************************************************************************************

    IF @nScan.SkewDeg THEN

        Index = 0
        xPos1 = eXpos(Index) + @nScan.skewOffset * COS(eNormRdn(Index)+@nScan.skewRdn)
        yPos1 = eYpos(Index) + @nScan.skewOffset * SIN(eNormRdn(Index)+@nScan.skewRdn)
        GRAPHIC SET POS(yPos1,xPos1)

        FOR Index = 1 TO @nRay.Index359 STEP 200

            'xPos1 = (eNormRad(Index)+.500)*COS(eNormRdn(Index)) + @nScan.skewOffset * COS(eNormRdn(Index) +@nScan.skewRdn) + eOriginX(Index)
            'yPos1 = (eNormRad(Index)+.500)*SIN(eNormRdn(Index)) + @nScan.skewOffset * SIN(eNormRdn(Index)+@nScan.skewRdn)

            'current index x,y position along perimeter at skew offset distance and skew angle
            xPos1 = eXpos(Index) + @nScan.skewOffset * COS(eNormRdn(Index)+@nScan.skewRdn)
            yPos1 = eYpos(Index) + @nScan.skewOffset * SIN(eNormRdn(Index)+@nScan.skewRdn)

            GRAPHIC LINE STEP -(yPos1,xPos1),%RGB_YELLOW 'green 'red

        NEXT

        Index = 0 '@nRay.Index359
        xPos1 = eXpos(Index) + @nScan.skewOffset * COS(eNormRdn(Index)+@nScan.skewRdn)
        yPos1 = eYpos(Index) + @nScan.skewOffset * SIN(eNormRdn(Index)+@nScan.skewRdn)
        GRAPHIC LINE STEP -(yPos1,xPos1),%RGB_YELLOW 'green 'red

    END IF

    EXIT SUB


    'Draw measurement scale
    '************************************************************************************************************

   DIM xTxt(18) AS LOCAL SINGLE

    DIM yTxt(18) AS LOCAL SINGLE

    DIM pTxt(18) AS LOCAL STRING

    LOCAL pixOff AS SINGLE

    LOCAL iStep AS DOUBLE

    LOCAL sHeight, sWidth, inches, tenths, hunds, thous AS DOUBLE
    LOCAL x,y AS DOUBLE
    LOCAL InchStep, iCtr, pMin,pMin2,pMin5 AS LONG

    LOCAL clk3, clk6, clk9, clk12, opp AS LONG


     'Most plotting below is based on these reference points:
    xPos1 = -(@nScan.yRadius+2.05#) : xPos2 = (@nScan.yRadius+2.05#)
    yPos1 = -(@nScan.yRadius+2.05#) : yPos2 = (@nScan.yRadius+2.05#)

    GRAPHIC WIDTH 2

    'draw scale edge around model
   'GRAPHIC LINE (yPos1,xPos1)-(yPos1,xPos2),%RGB_RED '270 Degree, Vertical line 'Red for track side
    GRAPHIC LINE (yPos1,0)-(yPos1,xPos2),%RGB_MAGENTA '270 Degree, Vertical line 'Red for track side
    GRAPHIC LINE (yPos1,xPos1)-(yPos1,0),%RGB_DODGERBLUE '270 Degree, Vertical line 'Red for track side

    'GRAPHIC LINE (yPos1,xPos1)-(yPos2,xPos1),%RGB_WHITE '180 Degree, Horizontal
    GRAPHIC LINE (yPos1,xPos1)-(0,xPos1),%RGB_YELLOW    '180 Degree, Horizontal
    GRAPHIC LINE (0,xPos1)-(yPos2,xPos1),%RGB_LIME      '180 Degree, Horizontal

   'GRAPHIC LINE (yPos1,xPos2)-(yPos2,xPos2),%RGB_WHITE '0:360 Degree, Horizontal
    GRAPHIC LINE (yPos1,xPos2)-(0,xPos2),%RGB_YELLOW    '0:360 Degree, Horizontal
    GRAPHIC LINE (0,xPos2)-(yPos2,xPos2),%RGB_LIME      '0:360 Degree, Horizontal

   'GRAPHIC LINE (yPos2,xPos1)-(yPos2,xPos2),%RGB_WHITE '90  Degree, Vertical
    GRAPHIC LINE (yPos2,0)-(yPos2,xPos2),%RGB_MAGENTA '90  Degree, Vertical
    GRAPHIC LINE (yPos2,xPos1)-(yPos2,0),%RGB_DODGERBLUE '90  Degree, Vertical


    GRAPHIC WIDTH 1


    'calculate current screen size, inches
    sWidth = gWIN.yPix(0) * gWIN.PixelR(0)  '= width of the screen in inches
    sHeight = gWIN.xPix(0) * gWIN.PixelR(0) '= height of the screen in inches

    'get scale spatial values that fit current zoom
    thous  = FIX(0.001 / gWIN.PixelR(0)) 'number of pixels for .001"
    hunds  = FIX(0.010 / gWIN.PixelR(0)) 'number of pixels for .010"
    tenths = FIX(0.100 / gWIN.PixelR(0)) 'number of pixels for .100"
    inches = FIX(1.000 / gWIN.PixelR(0)) 'number of pixels for 1.00"

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


    IF @nScan.xNear THEN   'X Axis mounted near side of nozzle
       clk9 = 9: clk3 = 3: clk12 = 12: clk6 = 6: opp = FALSE
       pTxt(2) = "0:X": pTxt(3) = "X:0": pTxt(4) = "0:Y": pTxt(5) = "Y:0": pTxt(6) = "360:0"
    ELSE                   'X Axis mounted far side of nozzle
       clk9 = 3: clk3 = 9: clk12 = 6: clk6 = 12: opp = TRUE
       pTxt(2) = "X:0": pTxt(3) = "0:X": pTxt(4) = "Y:0": pTxt(5) = "0:Y": pTxt(6) = "0:360"
    END IF

    pTxt(7) = "180": pTxt(8) = "90": pTxt(9) = "270"

    '========================================================================================
    'Print text
    '========================================================================================

    'Print degree locations
    pixOff = 40 * gWIN.PixelR(0)    '40 pixel offset

    gText(pTxt(6), 0, xPos2,  clk6, pixOff, opp, 0)   '360:0 or 360:0
    gText(pTxt(7), 0, xPos1, clk12, pixOff, opp, 0)   '180
    gText(pTxt(8), yPos2, 0,  clk3, pixOff, opp, 900) '90
    gText(pTxt(9), yPos1, 0,  clk9, pixOff, opp, 900) '270

    pixOff = 20 * gWIN.PixelR(0)    '20 pixel space between print locations

    'Print X-Axis,  Vertical scale values
    FOR xPos = -iStep TO xPos1 STEP -iStep  'print 0 to max negative side of scale
        pTxt(1) = USING$("##.###",xPos)
        gText(pTxt(1), yPos2, xPos, clk3, pixOff, opp, 0)   '90 degrees
        gText(pTxt(1), yPos1, xPos, clk9, pixOff, opp, 0)   '270 degrees
    NEXT

    FOR xPos = iStep TO xPos2 STEP iStep    'print 0 to max positive side of scale
        pTxt(1) = USING$("##.###",xPos)
        gText(pTxt(1), yPos2, xPos, clk3, pixOff, opp, 0)   '90 degrees
        gText(pTxt(1), yPos1, xPos, clk9, pixOff, opp, 0)   '270 degrees
    NEXT

    'print X Axis 0" locations @ 90 & 270. "X:0"
    gText(pTxt(2), yPos2, 0, clk3, pixOff, opp, 0)  '90 degrees
    gText(pTxt(3), yPos1, 0, clk9, pixOff, opp, 0)  '270 degrees

    'Print Y-Axis,  Horizontal scale values
    FOR yPos = -iStep TO yPos1 STEP -iStep    'print 0 to max negative side of scale
        pTxt(1) = USING$("##.###",yPos) 'any blank decimal left (###.), a space is inserted, or 0 if right of decimal
        gText(pTxt(1), yPos, xPos2, clk6,  pixOff, opp, 2700) '0/360 degrees
        gText(pTxt(1), yPos, xPos1, clk12, pixOff, opp, 2700) '180 degrees
    NEXT

    FOR yPos = iStep TO yPos2 STEP iStep     'print 0 to max positive side of scale
        pTxt(1) = USING$("##.###",yPos)
        gText(pTxt(1), yPos, xPos2, clk6,  pixOff, opp, 2700) '0/360 degrees
        gText(pTxt(1), yPos, xPos1, clk12, pixOff, opp, 2700) '180 degrees
    NEXT

    'print Y Axis 0" locations @ 0 & 180. "Y:0"
    gText(pTxt(4), 0, xPos2, clk6,  pixOff, opp, 2700) '0/360 degrees
    gText(pTxt(5), 0, xPos1, clk12, pixOff, opp, 2700) '180 degrees

    '========================================================================================
    'Draw Scale markers
    '========================================================================================

    'Draw X-Axis, vertical scale markers
    pixOff = 15 * gWIN.PixelR(0)    'major scale

    FOR xPos = 0 TO xPos1 STEP -iStep
        GRAPHIC LINE (yPos1,xPos)-(yPos1-pixOff,xPos),%RGB_WHITE '270 degree
        GRAPHIC LINE (yPos2,xPos)-(yPos2+pixOff,xPos),%RGB_WHITE '90  degree
    NEXT

    FOR xPos = 0 TO xPos2 STEP iStep
        GRAPHIC LINE (yPos1,xPos)-(yPos1-pixOff,xPos),%RGB_WHITE '270 degree
        GRAPHIC LINE (yPos2,xPos)-(yPos2+pixOff,xPos),%RGB_WHITE '90  degree
    NEXT

    pixOff = 10 * gWIN.PixelR(0)    'minor scale

    FOR xPos = (-iStep * .5)  TO xPos1 STEP -iStep
        GRAPHIC LINE(yPos1,xPos)-(yPos1-pixOff,xPos),%RGB_WHITE '270 degree
        GRAPHIC LINE(yPos2,xPos)-(yPos2+pixOff,xPos),%RGB_WHITE '90 degree
    NEXT

    FOR xPos = (iStep * .5) TO xPos2 STEP iStep
        GRAPHIC LINE (yPos1,xPos)-(yPos1-pixOff,xPos),%RGB_WHITE '270 degree
        GRAPHIC LINE (yPos2,xPos)-(yPos2+pixOff,xPos),%RGB_WHITE '90 degree
    NEXT


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

    FOR yPos = (-iStep * .5) TO yPos1 STEP -iStep
        GRAPHIC LINE (yPos,xPos1)-(yPos,xPos1-pixOff),%RGB_WHITE '180
        GRAPHIC LINE (yPos,xPos2)-(yPos,xPos2+pixOff),%RGB_WHITE '360:0
    NEXT

    FOR yPos = (iStep * .5) TO yPos2 STEP iStep
        GRAPHIC LINE (yPos,xPos1)-(yPos,xPos1-pixOff),%RGB_WHITE '180
        GRAPHIC LINE (yPos,xPos2)-(yPos,xPos2+pixOff),%RGB_WHITE '360:0
    NEXT

    'end of scale plotting

    EXIT SUB

    IF @nScan.AxialRaster THEN EXIT SUB 'exit out if axial raster

    '***********************************************************************************************************
    'DRAW Curved Y-Axis Index chords: ! Circ Beam only
    '***********************************************************************************************************
    GRAPHIC STYLE 4 'set dotted line
    xIndexE=@nRay.Index359:  '-1: draw typical sliver index located at -1 index from 0
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

        yMid = yTxt*0.50: xMid = xTxt*0.50: xOffTxt = pOffset+xTxt: yOffTxt = pOffset+yTxt

        IF Angle THEN

           IF opp THEN
              pOffset = -pOffset : yMid = -yMid : xMid = -xMid
           ELSE
              xOffTxt = -xOffTxt : yOffTxt = -yOffTxt
           END IF

        ELSE

           IF opp THEN
              pOffset = -pOffset
           ELSE
              xOffTxt = -xOffTxt : yOffTxt = -yOffTxt : yMid = -yMid : xMid = -xMid
           END IF

        END IF


        SELECT CASE pLoc
           CASE 12 '12 o'clock = above graphics
             yPos += yMid : xPos += xOffTxt
           CASE 6 '6 o'clock  = below graphics
             yPos += yMid : xPos += pOffset
           CASE 3 '3 o'clock = right of graphics
             yPos += pOffset : xPos += xMid
           CASE 9 '9 o'clock = left of graphics
             yPos += yOffTxt : xPos += xMid
        END SELECT

        GRAPHIC SET POS(yPos,xPos)

        GRAPHIC PRINT pTxt

        FONT END sFont 'erase the temporary font

        GRAPHIC SET FONT gFont(fontNum) 'set back to current Font, fontNum is global

END SUB


FUNCTION GetRatio AS DOUBLE

       LOCAL xCts, xCtsNew AS DOUBLE

       'xCts# = 3768.024325157213#  '(37680.24325157213#)/10.00#  'cts per inch travel = (300564/1300) * (30/12) * (128*4)  / (2.5 * Pi)  =  cts/inch
       xCts = ROUND( (300564/1300) * (30/12) * (128*4)  / (2.5 * Pi),14)'  =  cts/inch

       'print xCts ' = ROUND( (300564/1300) * (30/12) * (128*4)  / (2.5 * Pi),14)'  =  cts/inch

       'xCtsNew = ROUND( (300564/1300) * (38/12) * (128*4)  / (3.1666667 * Pi),14)'  =  cts/inch
       xCtsNew = ROUND( (300564/1300) * (38/12) * (128*4)  / (3.1666 * Pi),14)'  =  cts/inch

       PRINT "xCtsOld:"; xCts
       PRINT "xCtsNew:"; xCtsNew

       FUNCTION = xCts

END FUNCTION


'11/10/16  Mod's for EPRI CALC done here, if any
FUNCTION GetAngleE(BYVAL ePosX AS DOUBLE, BYVAL ePosY AS DOUBLE) AS DOUBLE

    LOCAL radius, rdn, normRdn AS DOUBLE

    radius = SQR(SQ(ePosX)+SQ(ePosY)) '= Radius length(bSide)

    rdn = ArcCos(ePosX/radius)

    normRdn = GetN360Rdn(ePosX, ePosY, rdn ) 'polar real; Normal angle to Rad of a specific point on perimeter

    'get the resulting z-axis rotational angle, radians, offset from set zero reference
    'Function = RdnToDeg((normRdn MOD Rdn360))  ''probe center angle,from nozzel center, 0 to 360 degrees translation
    FUNCTION = RdnToDeg(normRdn)  ''probe center angle,from nozzel center, 0 to 360 degrees translation

END FUNCTION

'11/10/16  Mod's for EPRI CALC done here, if any
FUNCTION GetRdnE(BYVAL ePosX AS DOUBLE, BYVAL ePosY AS DOUBLE) AS DOUBLE

    LOCAL radius, rdn, normRdn AS DOUBLE

    radius = SQR(SQ(ePosX)+SQ(ePosY)) '= Radius length(bSide)

    rdn = ArcCos(ePosX/radius)

    normRdn = GetN360Rdn(ePosX, ePosY, rdn ) 'polar real; Normal angle to Rad of a specific point on perimeter

    'get the resulting z-axis rotational angle, radians, offset from set zero reference
    FUNCTION = normRdn 'MOD Rdn360  'probe center angle, in radians, from nozzel center, 0 to 360 degrees translation


END FUNCTION

SUB DrawArc(BYVAL xPos AS DOUBLE, BYVAL yPos AS DOUBLE, BYVAL sRdn AS DOUBLE, BYVAL eRdn AS DOUBLE, BYVAL Clr AS LONG)

    'local

    'for x =

END SUB

SUB DrawCircle(BYVAL xPos AS DOUBLE, BYVAL yPos AS DOUBLE, BYVAL Radius AS DOUBLE, BYVAL Clr AS LONG)

    LOCAL xPos2, yPos2, Rdn AS DOUBLE
    LOCAL Index AS LONG

    xPos2 = xPos+Radius : yPos2 = yPos
    GRAPHIC SET POS(yPos2,xPos2)

    FOR Index = 0 TO 359 'STEP 100
        Rdn = DegToRdn(Index)
        xPos2 = xPos+Radius*COS(Rdn): yPos2 = yPos+Radius*SIN(Rdn)
        GRAPHIC LINE STEP -(yPos2,xPos2), Clr'Chord: Draw index chord
    NEXT

    'xPos2 = Offset*COS(eNormRdn(xIdx))+eXpos(xIdx): yPos2 = Offset*SIN(eNormRdn(xIdx))+eYpos(xIdx)
    xPos2 = xPos+Radius: yPos2 = YPos
    GRAPHIC LINE STEP -(yPos2,xPos2),Clr      'Draw end gap chord

END SUB


FUNCTION SetTargetPos(BYVAL xt AS DOUBLE,BYVAL yt AS DOUBLE,BYVAL SkewType AS LONG,BYVAL RayPtr AS DWORD,BYVAL ScanPtr AS DWORD,aPos AS DOUBLE) AS DOUBLE

    LOCAL yi,xi,xp,yp,offset,tOffset,aMin,aMax,xSkew,ySkew,ap AS DOUBLE
    LOCAL Index,Idx,Idx2,IndexStart,IndexEnd,IndexStep,IndexMax,Last AS LONG
    LOCAL nScan AS ScanVars POINTER, nRay AS FociRay POINTER

    nScan = ScanPtr : nRay = RayPtr 'assign address to pointers
    IndexMax = @nRay.Index359
    aMin = @nScan.yEnd-0.500# : aMax = @nScan.yBegin+0.500#    'set min-max axial range
    xSkew = 0 : ySkew = 0 : offset = 1000 'set initial comparison to extreme value

   'By using (2) loop search algoritm (coarse/fine), speed increased from 40/second to 2500/second!!

    FOR Last = 0 TO 1

        IF Last THEN
           'IF IndexStep = 1 then exit Function 'bug out - can't get any more accurate!!
           IndexStart = Index-IndexStep
           IF IndexStart < 0 THEN
              IndexStart += IndexMax
              IndexEnd = IndexStart + (IndexStep*2)
           ELSE
              IndexEnd = Index + IndexStep
           END IF
           IndexStep = 1
        ELSE
           IndexStart = 0 : IndexEnd = IndexMax
           IndexStep = IndexMax/360   'step per 1 degree
           IF IndexStep < 1 THEN IndexStep = 1
        END IF


        FOR Idx2 = IndexStart TO IndexEnd STEP IndexStep  '@nRay.Index405

            'Idx = IiF(Idx2>IndexMax,Idx2-IndexMax-1,Idx2)
            Idx = IIF(Idx2>IndexMax,Idx2-IndexMax,Idx2)

            IF SkewType THEN 'probe position, else: focal position
               xSkew = @nScan.skewOffset*COS(eNormRdn(Idx)+@nScan.skewRdn)
               ySkew = @nScan.skewOffset*SIN(eNormRdn(Idx)+@nScan.skewRdn)
            END IF

            'current index x,y position along perimeter at skew offset distance and skew angle
            xi = eXpos(Idx) + xSkew : yi = eYpos(Idx) + ySkew

            'compute axial position
            ap = GetMinMax(GetXyLen(yt,xt,yi,xi)*SGN(GetSegLen(yt,xt)-GetSegLen(yi,xi)),aMin,aMax)

            'compute x and y position
            xp = (eNormRad(Idx)+ap)*COS(eNormRdn(Idx)) + xSkew + eOriginX(Idx)
            yp = (eNormRad(Idx)+ap)*SIN(eNormRdn(Idx)) + ySkew

            'compute current position to target offset distance
            tOffset = GetXyLen(yp,xp,yt,xt) 'returns ABS value

            IF (tOffset < offset) THEN 'copy new values if closer to target position
               Index = Idx : offset = tOffset : aPos = ap
               IF ROUND(tOffset,3) = 0 THEN 'equal - bug out
                  FUNCTION = Index
                  EXIT FUNCTION
               END IF
               'IF ROUND(tOffset,3) = 0.001# THEN EXIT FOR 'within 1 Mil - bug out
            END IF

        NEXT

    NEXT

    FUNCTION = Index

END FUNCTION

FUNCTION GetMinMax(BYVAL tVal AS DOUBLE, BYVAL MinVal AS DOUBLE, BYVAL MaxVal AS DOUBLE) AS DOUBLE

         IF MinVal > MaxVal THEN SWAP MinVal,MaxVal

         tVal = MAX(MinVal,tVal)'min
         tVal = MIN(MaxVal,tVal)'max

         FUNCTION = tVal

END FUNCTION



FUNCTION GetMajorE(pipeOD AS DOUBLE,minorDia AS DOUBLE) AS DOUBLE

         FUNCTION = pipeOD * ArcSin(minorDia/pipeOD)

END FUNCTION


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


    LOCAL arcTarget2,aSeg AS DOUBLE
    LOCAL idx2, x, y AS LONG

    'Set the initial x and y position at starting position angle in RADIANS
    'NOTE: There are inherent problems with oDeg  around zero degrees due to fP inaccurracies, converting degrees to radians and vice-versa,
    SELECT CASE @Ray.oDeg   '6/20/16 changed from Radians to Degrees!! Cut and dry.
      CASE   0.00#: eYpos2 = 0 : eXpos2 = @Ray.majorRad
      CASE  90.00#: eXpos2 = 0 : eYpos2 = @Ray.minorRad
      CASE 180.00#: eYpos2 = 0 : eXpos2 =-@Ray.majorRad
      CASE 270.00#: eXpos2 = 0 : eYpos2 =-@Ray.minorRad
      CASE ELSE   : eXpos2 = @Ray.majorRad*COS(@Ray.oRdn) : eYpos2 = @Ray.minorRad*SIN(@Ray.oRdn)
    END SELECT

    eXpos(0)= eXpos2 : eYpos(0)= eYpos2 : eAngle(0)= @Ray.oDeg

    theta = @Ray.oRdn    'set start degree position (in radians), to user start angle

    'theta inc based on a per chord inc accuracy of ~.00001"
    thetaInc = IIF(@Ray.IndexCW,-Rdn360/(pi*@Ray.majorDia*100000),Rdn360/(pi*@Ray.majorDia*100000))

    '= degree start position +/- 360 degrees = 1 revolution around ellipse
    @Ray.plus360Rdn = IIF(@Ray.IndexCW,@Ray.oRdn - Rdn360,@Ray.oRdn + Rdn360)

    '= 360 degrees +/- 45 degrees = 1.125 revolutions around ellipse
    @Ray.plus405Rdn = IIF(@Ray.IndexCW,@Ray.plus360Rdn - Rdn45,@Ray.plus360Rdn + Rdn45)

    idx = 1  'set index counter to 1

    Get360L = TRUE 'set flag to capture perimeter when theta >= 360 degrees

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
               @Ray.Index360=idx:@Ray.Index359=idx-1:@Ray.circ360 = arcSegment: Get360L = False'360L and index captured:set 360L false

        LOOP WHILE IIF(@Ray.Index0,arcSegment<arcTarget,arcTarget<arcSegment)

        eXpos(idx) = eXpos2: eYpos(idx) = eYpos2

        eArc(idx) = arcSegment

        eAngle(idx) = GetAngleE(eXpos2, eYpos2)

        IF IIF(@Ray.IndexCW,@Ray.plus405Rdn=>theta,theta=>@Ray.plus405Rdn) THEN _
           @Ray.Index405 = idx : EXIT LOOP 'capture index @ => 405 degrees and exit

        INCR idx

    LOOP UNTIL idx > nIndex  'error if loop exits here, correct exit is Index405

    'if scan started at 360
     IF NOT @Ray.Index0 THEN @Ray.Circ360 = @Ray.Circ360e

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

FUNCTION RunPlot(BYVAL RayPtr AS DWORD, BYVAL ScanPtr AS DWORD, BYVAL GFXPtr AS DWORD, BYVAL QPtr AS DWORD) AS LONG

    LOCAL Ray AS FociRay POINTER,nScan AS ScanVars POINTER,Quartic AS QuarticRay POINTER,GFX AS GfxVars POINTER

    Ray = RayPtr: nScan = ScanPtr: Quartic = qPtr: GFX = GFXPtr

    LOCAL xCtsF_Err,yCtsF_Err,zCtsF_Err,cCtsF_Err,aCtsF_Err,xCPi,yCPi,zCPi,cCPi,aCPi,xCPiR,yCPiR,zCPiR,cCPiR,aCPiR,_
          aMin,aMax,xPos,yPos,zPos,aPos,xPos2,yPos2,zPos2,cPos2,cPos3,cPos4,aPos2,xIncCtsF,yIncCtsF,cIncCtsF,aIncCtsF,_
          zIncCtsF,ScanVelF,ScanVelR,T,xySeg,n60HzSegsR,t60Hz,xm,ym,xmOld,ymOld,Oldxm,OldyM,dVar AS DOUBLE

    LOCAL xIncCtsL,yIncCtsL,zIncCtsL,cIncCtsL,aIncCtsL,SegCtr,n60HzSegs,pInc,pZoom,lVar AS LONG

    LOCAL InkeyVar AS STRING
    LOCAL NumericVar AS LONG


    'newly added for timer stuff
    '********************************************************************
   ' LOCAL TimeBegin, Time1, Time2, pos1, pos2 AS DOUBLE

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

    LOCAL ikey AS STRING

    LOCAL MouseL, MouseM, MouseR, mRight, mMiddle, mLeft, btndown, K, hFg AS LONG
    LOCAL mLeftDN, mLeftUP, mLeftCK AS LONG
    LOCAL mRightDN, mRightUP, mRightCK AS LONG
    LOCAL mMiddleDN, mMiddleUP, mMiddleCK, NotIn AS LONG

    LOCAL ReDrawModel, ReDrawPlot, ReDrawMouse, MouseIn AS LONG

    LOCAL lpPoint AS POINTAPI ' Pointer type defined in Win32Api

    LOCAL KeyOn, aKey, oldKey, zInc AS LONG
    LOCAL IncSpeed, WaitTime AS DOUBLE
    LOCAL tctr AS LONG

    'new pseudo text input box
    LOCAL sInput AS STRING
    LOCAL x1,y1,x2,y2,xI,yI AS LONG
    y1 = ((gWIN.yPix(0)-240) * half) + 240 - 200
    y2 = y1 + 400
    x1 = ( gWIN.xPix(0) * half)- 20
    x2 = x1 + 40
    yI = y1+10
    xI = x1+10

    DIM sTxt(40) AS LOCAL STRING

    '11/15/16 New Epri Calc
    LOCAL zRdn,ProbeRad,BeamRad,BeamDis,ProbeSkew,BeamX,BeamY,BeamOD,SkewOD AS DOUBLE


    'store axial min and max position: save calc'ing every time
    aMin = -(0.500# + @nScan.WeldWidth + @nScan.WeldHAZ * 2) : aMax = 0.500#

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


    'set all positions to scan start location
    'xPos2 = PathX(0): yPos2 = PathY(0): zPos2 = PathZ(0): cPos2 = PathC(0): aPos2 = PathA(0)

    xPos2 = eNormRad(0) * COS(eNormRdn(0)) + @nScan.skewOffset * COS(eNormRdn(0) + @nScan.skewRdn) + eOriginX(0)
    yPos2 = eNormRad(0) * SIN(eNormRdn(0)) + @nScan.skewOffset * SIN(eNormRdn(0) + @nScan.skewRdn)
    zPos2 = eRotDeg(0)
    cPos2 = eArc(0) 'Circ:  X position, parallel to weld axis, image encoder output
    aPos2 = 0

    GRAPHIC WINDOW CLICK gWIN.hWin(0) TO mclick, xCoord, yCoord 'clear any mouse clicks

    KeyOn = False

    ReDrawModel = TRUE

    ReDrawPlot = TRUE

    ReDrawMouse = FALSE

    GOSUB DrawScan

    LOCAL ReturnValue AS LONG

    'MessageBox gWIN.hWin(0), "Click OK to begin Scan", "Ready for Scan", 0 TO ReturnValue

    KeyOn = TRUE

    LOCAL PathNum, xIdx,xIdx2 AS LONG
    LOCAL xPosA,yPosA AS DOUBLE
    'local T as double
    LOCAL Increment AS LONG


    'GRAPHIC SET CAPTION "NEW CAPTION"

    DO

       GOSUB UserInput 'get user input, keystrokes and mouse

       GOSUB DrawScan

    LOOP


'****************************************************************************************************
DrawScan:
'****************************************************************************************************

    IF ReDrawModel THEN  'zoom or origin changed

       ReDrawModel = FALSE

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

       ReDrawPlot = TRUE

    END IF


    IF ReDrawPlot THEN  'Plot change

       ReDrawPlot = FALSE : ReDrawMouse = FALSE

       xPos = ROUND(xPos2,14) : yPos = ROUND(yPos2,14) : zPos = ROUND(zPos2,14) : aPos = ROUND(aPos2,14) 'was 10 places

       GRAPHIC COPY gWIN.hWin(1), 0&  'copy bitmap of nozzle scan model to standard window

       PlotProbe(xPos,yPos,zPos,aPos,xIdx,RayPtr,ScanPtr,GFXPtr,QPtr) 'Draw Probe and focal at current z rotational and x,y position

       zRdn = DegToRdn(zPos) MOD Rdn360

       'beam intersection point on weld at current cross hair position
       IF @nScan.skewOffset THEN  'CIRC BEAM
          BeamX = xPos-@nScan.skewOffset*COS(zRdn) : BeamY = yPos-@nScan.skewOffset*SIN(zRdn)
       ELSE                       'AXIAL BEAM
          BeamX = eOriginX(xIdx) : BeamY = 0
       END IF

       'find Probe Skew from ref 180
       ProbeRad = GetSegLen(xPos,yPos)   'a
       BeamRad = GetSegLen(BeamX,BeamY)  'b
       BeamDis = GetSegLen(xPos-BeamX,yPos-BeamY)'c
       'Angle B = ArcCos((SQ(c)+SQ(a)-SQ(b))/(2*c*a)) 'Angle A = ArcCos((SQ(b)+SQ(c)-SQ(a))/(2*b*c))
       ProbeSkew = ArcCos((SQ(BeamDis)+SQ(ProbeRad)-SQ(BeamRad))/(2*BeamDis*ProbeRad))

       'Find Beam OD and Skew OD
       SkewOD = ArcSIN(ABS(yPos-BeamY)/BeamDis)
       BeamOD = @nScan.PipeOD/COS(SkewOD)
       IF BeamOD > 9999.9999 THEN BeamOD = 0

       IF cPos2 > @Ray.Circ360e THEN
          cPos3 = cPos2-@Ray.Circ360e : cPos4 = cPos2  'Overlap
       ELSE
          cPos3 = cPos2 : cPos4 = 0      'Overlap
       END IF

       'added to stop rounding of weld circumference
       lVar =  INT(@Ray.Circ360*10000) 'drop decimal places 5+, no rounding!
       dVar = lVar / 10000

       sTxt(0)= USING$( "     X-Weld:###.###" + CHR$(34),cPos3 )
       sTxt(1)= USING$( "     Y-Weld:###.###" + CHR$(34),aPos2 )

       sTxt(2)= USING$( " X-Overlap:###.####" + CHR$(34),cPos4 )
       sTxt(3)= USING$( " Weld Circ:###.####" + CHR$(34),dVar) '@Ray.Circ360 )

       sTxt(4)= USING$( "CL Azimuth:###.####" + CHR$(176),GetAngleE(xPos,yPos) )
       sTxt(5)= USING$( "   CL Skew:###.####" + CHR$(176),RdnToDeg(ProbeSkew) )
       sTxt(6)= USING$( " CL Radial:###.####" + CHR$(34),ProbeRad )

       sTxt(7)= USING$( "  OD Pipe: ###.####" + CHR$(34),@nScan.PipeOD )
       sTxt(8)= USING$( "  OD Beam:####.####" + CHR$(34),BeamOD)
       sTxt(9)= USING$( "  OD Skew: ###.####" + CHR$(176),RdnToDeg(SkewOD) )

       sTxt(10)= USING$( "  X-Probe:###.####" + CHR$(34) ,xPos )
       sTxt(11)= USING$( "  Y-Probe:###.####" + CHR$(34) ,yPos )
       sTxt(12)= USING$( "  Z-Probe:###.####" + CHR$(176),(zPos MOD 360) )

       sTxt(13)= USING$( "  X-Focus:###.####" + CHR$(34),BeamX )
       sTxt(14)= USING$( "  Y-Focus:###.####" + CHR$(34),BeamY )

       sTxt(15)= USING$( "  X-Mouse:###.####" + CHR$(34),xm )
       sTxt(16)= USING$( "  Y-Mouse:###.####" + CHR$(34),ym )

       sTxt(17)= USING$( "  Pixel SR:#.#####" + CHR$(34),gWIN.PixelR(1))

       'Select Text bitmap
       GRAPHIC ATTACH gWIN.hWin(3), 0&, REDRAW

       'GRAPHIC CLEAR

       GRAPHIC CELL =  2,2 : GRAPHIC PRINT sTxt(0)
       GRAPHIC CELL =  3,2 : GRAPHIC PRINT sTxt(1)

       GRAPHIC CELL =  5,2 : GRAPHIC PRINT sTxt(2)
       GRAPHIC CELL =  6,2 : GRAPHIC PRINT sTxt(3)

       GRAPHIC CELL =  8,2 : GRAPHIC PRINT sTxt(4)
       GRAPHIC CELL =  9,2 : GRAPHIC PRINT sTxt(5)
       GRAPHIC CELL = 10,2 : GRAPHIC PRINT sTxt(6)

       GRAPHIC CELL = 12,2 : GRAPHIC PRINT sTxt(7)
       GRAPHIC CELL = 13,2 : GRAPHIC PRINT sTxt(8)
       GRAPHIC CELL = 14,2 : GRAPHIC PRINT sTxt(9)

       GRAPHIC CELL = 16,2 : GRAPHIC PRINT sTxt(10)
       GRAPHIC CELL = 17,2 : GRAPHIC PRINT sTxt(11)
       GRAPHIC CELL = 18,2 : GRAPHIC PRINT sTxt(12)

       GRAPHIC CELL = 20,2 : GRAPHIC PRINT sTxt(13)
       GRAPHIC CELL = 21,2 : GRAPHIC PRINT sTxt(14)

       GRAPHIC CELL = 23,2 : GRAPHIC PRINT sTxt(15)
       GRAPHIC CELL = 24,2 : GRAPHIC PRINT sTxt(16)

       GRAPHIC CELL = 28,2 : GRAPHIC PRINT sTxt(17)


       'draw border vertical line
       GRAPHIC WIDTH 5 : GRAPHIC LINE(236,0)-(236,1080), %RGB_CORNFLOWERBLUE '
       GRAPHIC WIDTH 2 : GRAPHIC LINE(236,0)-(236,1080), %RGB_LIGHTSKYBLUE '%rgb_blue
       GRAPHIC WIDTH 1 : GRAPHIC LINE(232,0)-(232,1080), %RGB_BLACK 'LIGHTSKYBLUE '%rgb_blue
       GRAPHIC REDRAW 'Re-Draw Bitmap

       'Select normal window
       GRAPHIC ATTACH gWIN.hWin(0), 0&, REDRAW
       GRAPHIC COPY gWIN.hWin(3), 0&  'copy text bitmap to desktop window
       GRAPHIC REDRAW                 'Re-Draw the screen snappily

    END IF

    IF ReDrawMouse THEN  'mouse move

       ReDrawMouse = FALSE

       'Select Text bitmap
       GRAPHIC ATTACH gWIN.hWin(3), 0&, REDRAW

       sTxt(15)= USING$( "  X-Mouse:###.####" + CHR$(34),xm )
       sTxt(16)= USING$( "  Y-Mouse:###.####" + CHR$(34),ym )

       GRAPHIC CELL = 23,2 : GRAPHIC PRINT sTxt(15)
       GRAPHIC CELL = 24,2 : GRAPHIC PRINT sTxt(16)

       GRAPHIC REDRAW                              'Re-Draw Text bitmap

       'Select normal window
       GRAPHIC ATTACH gWIN.hWin(0), 0&, REDRAW
       GRAPHIC COPY gWIN.hWin(3), 0&  'copy text bitmap to standard window
       GRAPHIC REDRAW                              'Re-Draw the screen snappily

    END IF


RETURN
'****************************************************************************************************
UserInput: ' process keypress and mouse clicks
'****************************************************************************************************
        IF keyOn THEN

           GRAPHIC INSTAT TO NumericVar
           IF (NumericVar) THEN          'got a keypress !!
              GRAPHIC INKEY$ TO inkeyVar
              IF LEN(inkeyVar)>1 THEN 'If VIRTUAL SCREEN ON; some extended keys don't work: UP, DN, LEFT, RIGHT !!
                 aKey=ASC(RIGHT$(inkeyVar,1)) + 200 'add 200 for extended keys
              ELSE
                 aKey = ASC(InKeyVar)
              END IF
           ELSE
              aKey = 0
           END IF


           IF aKey THEN

              SELECT CASE aKey

                CASE 113, 81, 27  ' "q" or "Q" or ESC key

                     'set mouse cursor back to default arrow pointer
                     IF NotIn = False THEN 'was in canvas
                        NotIn = True  'set to outside canvas
                        SystemParametersInfo(%SPI_SETCURSORS, 0, eNULL, 0) 'reset back to arrow
                     END  IF

                     MessageBox gWIN.hWin(0), "Quit?", "Exit Plot", 4 TO ReturnValue  'no = 7: yes = 6

                     IF ReturnValue = 6 THEN EXIT FUNCTION


                CASE KeyHOM   'Home Key = 71 + 200

                     'set pixel spatial resolution to original
                     gWIN.PixelR(1) = gWIN.SetPixelR(1)

                     'set window scale to original
                     gWIN.yMinR(1) = gWIN.SetyMinR(1) : gWIN.yMaxR(1) = gWIN.SetyMaxR(1)
                     gWIN.xMinR(1) = gWIN.SetxMinR(1) : gWIN.xMaxR(1) = gWIN.SetxMaxR(1)

                     pZoom = gWIN.SetPixelR(1) * 10000

                     ReDrawModel = TRUE

                CASE 43,45  '+, -   : ZOOM

                     '+increment: Image getting smaller -zoom, -increment: Image getting bigger +zoom
                     pInc = IIF(aKey=45,1,-1)
                     pZoom += pInc
                     pZoom = GetMinMax(pZoom,1,500) '+/- increment zoom: keep within defined limits

                     gWIN.PixelR(1) = OOO1 * pZoom '.0001# * pZoom

                     IF gWIN.PixelR(1) <> gWIN.PixelR(0) THEN 'if change

                        'IF pZoom < 21 THEN SLEEP 10

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

                        ReDrawModel = TRUE  'refresh the window on next draw

                     END IF

                CASE KeyUP, KeyDn

                     dVar = IIF(aKey=KeyUp,yPosA+.001#,yPosA-.001#)

                     dVar = GetMinMax(dVar,aMin,aMax)

                     IF dVar <> yPosA THEN 'if change
                        yPosA = dVar
                        xPos2 = (eNormRad(xIdx) + yPosA) * COS(eNormRdn(xIdx)) + @nScan.skewOffset * COS(eNormRdn(xIdx) + @nScan.skewRdn) + eOriginX(xIdx)
                        yPos2 = (eNormRad(xIdx) + yPosA) * SIN(eNormRdn(xIdx)) + @nScan.skewOffset * SIN(eNormRdn(xIdx) + @nScan.skewRdn)
                        zPos2 = eRotDeg(xIdx)
                        cPos2 = eArc(xIdx) 'Circ:  X position, parallel to weld axis, image encoder output
                        aPos2 = yPosA      'Ax
                        ReDrawPlot = TRUE
                     END IF

                CASE KeyLFT, KeyRGT

                     'goes round and round, no need to test if same

                     IF aKey = KeyLFT THEN
                        DECR xIdx
                        xIdx = IIF(xIdx < 0,@Ray.Index360+xIdx,xIdx)
                     ELSE
                        INCR xIdx
                        xIdx = IIF(xIdx > @Ray.Index359,xIdx-@Ray.Index360,xIdx)
                     END IF

                     xPosA = xIdx*0.001#

                     xPosA = ROUND(xPosA,3)

                     xPos2 = (eNormRad(xIdx) + yPosA) * COS(eNormRdn(xIdx)) + @nScan.skewOffset * COS(eNormRdn(xIdx) + @nScan.skewRdn) + eOriginX(xIdx)
                     yPos2 = (eNormRad(xIdx) + yPosA) * SIN(eNormRdn(xIdx)) + @nScan.skewOffset * SIN(eNormRdn(xIdx) + @nScan.skewRdn)
                     zPos2 = eRotDeg(xIdx)
                     cPos2 = eArc(xIdx) 'Circ:  X position, parallel to weld axis, image encoder output
                     aPos2 = yPosA      'Ax

                     ReDrawPlot = TRUE

                CASE 88,120 'X,x  : Enter new X position

                     GRAPHIC SCALE PIXELS
                     GRAPHIC WIDTH 2 : GRAPHIC BOX (y1,x1) - (y2, x2), 40, %RGB_WHITE ,%RGB_BLACK :GRAPHIC WIDTH 1
                     GRAPHIC SET POS(yI,xI)
                     GRAPHIC LINE INPUT "Enter X Postion: ", sInput
                     GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))

                     IF LEN(sInput) THEN

                        xPosA = VAL(sInput)

                        'if input = circ360 then position = 0
                        IF ROUND((xPosA*10000),0) = ROUND((@Ray.circ360*10000),0) THEN xPosA = 0

                        xPosA = ROUND(xPosA,3)

                        IF @Ray.Index0 THEN
                           xIdx = xPosA*1000
                        ELSE
                           dVar = eArc(0)-xPosA
                           xIdx = IIF(dVar < 0,(@Ray.circ360*1000)-dVar,dVar*1000)
                        END IF

                        PRINT xIdx

                        xIdx = GetMinMax(xIdx,0,@Ray.Index405)

                        PRINT xIdx
                        PRINT @Ray.Index405
                        PRINT @Ray.circ360

                        xPos2 = (eNormRad(xIdx) + yPosA) * COS(eNormRdn(xIdx)) + @nScan.skewOffset * COS(eNormRdn(xIdx) + @nScan.skewRdn) + eOriginX(xIdx)
                        yPos2 = (eNormRad(xIdx) + yPosA) * SIN(eNormRdn(xIdx)) + @nScan.skewOffset * SIN(eNormRdn(xIdx) + @nScan.skewRdn)
                        zPos2 = eRotDeg(xIdx)
                        cPos2 = eArc(xIdx) 'Circ:  X position, parallel to weld axis, image encoder output
                        aPos2 = yPosA      'Ax

                     END IF

                     ReDrawPlot = TRUE

                     GRAPHIC INPUT FLUSH 'clear key buffer

                CASE 89,121 'Y,y : Enter new Y position

                     GRAPHIC SCALE PIXELS
                     GRAPHIC WIDTH 2 : GRAPHIC BOX (y1,x1) - (y2, x2), 40, %RGB_WHITE ,%RGB_BLACK :GRAPHIC WIDTH 1
                     GRAPHIC SET POS(yI,xI)
                     GRAPHIC LINE INPUT "Enter Y Postion: ", sInput
                     GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))

                     IF LEN(sInput) THEN

                        YPosA = VAL(sInput)

                        'convert back to scan values
                        'yPosA = yPosA -(@nScan.WeldWidth + @nScan.WeldHAZ * 2)

                        IF yPosA > 0.500# THEN yPosA = 0.500# ': BEEP
                        IF yPosA < -(0.500# + @nScan.WeldWidth + @nScan.WeldHAZ * 2) THEN yPosA = -(0.500# + @nScan.WeldWidth + @nScan.WeldHAZ * 2)':BEEP

                        xPos2 = (eNormRad(xIdx) + yPosA) * COS(eNormRdn(xIdx)) + @nScan.skewOffset * COS(eNormRdn(xIdx) + @nScan.skewRdn) + eOriginX(xIdx)
                        yPos2 = (eNormRad(xIdx) + yPosA) * SIN(eNormRdn(xIdx)) + @nScan.skewOffset * SIN(eNormRdn(xIdx) + @nScan.skewRdn)
                        zPos2 = eRotDeg(xIdx)
                        cPos2 = eArc(xIdx) 'Circ:  X position, parallel to weld axis, image encoder output
                        aPos2 = yPosA      'Ax

                     END IF

                     ReDrawPlot = TRUE

                     GRAPHIC INPUT FLUSH 'clear key buffer

                CASE 80,112,70,102 '= P,p F,f '90,122 = Z,z :  New target

                     IF (Oldym = ym) AND (Oldxm = xm) AND (aKey = oldKey) THEN 'no change
                        'do nothing
                     ELSE

                        IF (aKey=80) OR (aKey=112) THEN 'Probe
                           xIdx2 = SetTargetPos(xm,ym,-1,RayPtr,ScanPtr,yPosA)
                        ELSE                            'Focus
                           xIdx2 = SetTargetPos(xm,ym,0,RayPtr,ScanPtr,yPosA)
                        END IF

                        'make sure Index is in range
                        xIdx = GetMinMax(xIdx2,0,@Ray.Index359)

                        yPosA = ROUND(yPosA,3)

                        xPos2 = (eNormRad(xIdx) + yPosA) * COS(eNormRdn(xIdx)) + @nScan.skewOffset * COS(eNormRdn(xIdx) + @nScan.skewRdn) + eOriginX(xIdx)
                        yPos2 = (eNormRad(xIdx) + yPosA) * SIN(eNormRdn(xIdx)) + @nScan.skewOffset * SIN(eNormRdn(xIdx) + @nScan.skewRdn)
                        zPos2 = eRotDeg(xIdx)
                        cPos2 = eArc(xIdx) 'Circ:  X position, parallel to weld axis, image encoder output
                        aPos2 = yPosA      'Ax

                        ReDrawPlot = TRUE

                        Oldym = ym : Oldxm = xm : oldKey = aKey

                     END IF

             END SELECT

           END IF

        END IF

    MouseIn = FALSE

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

          MouseIn = TRUE

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

          'copy current mouse x,y position
          ymOld = ym : xmOld = xm

          IF @nScan.xNear THEN 'X-Axis on near side of of nozzle
             ym = ymouse*gWIN.PixelR(0)+gWIN.yMinR(0) : xm = xmouse*gWIN.PixelR(0)+gWIN.xMinR(0)
          ELSE
             ym =-ymouse*gWIN.PixelR(0)+gWIN.yMinR(0) : xm =-xmouse*gWIN.PixelR(0)+gWIN.xMinR(0)
          END IF

          'update mouse position if changed
          IF (ym <> ymOld) OR (xm <> xmOld) THEN
             ReDrawMouse = TRUE
          END IF

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
             IF (gWIN.yMinR(1)<>gWIN.yMinR(0)) OR (gWIN.xMinR(1)<>gWIN.xMinR(0)) THEN ReDrawModel = TRUE

          END IF

          '*************************************************************************************************************
          IF mRightDN THEN   'right button: change zoom,  centered on mouse x,y position

             '+/- increment zoom: keep within defined limits
             IF pInc = 1 THEN                    '+increment: Image getting smaller -zoom
                zInc = IIF((pZoom > 9) AND (pZoom < 481), 10, 1)
             ELSE                                '-increment: Image getting bigger  +zoom
                zInc = IIF((pZoom > 19) AND (pZoom < 491), -10, -1)
             END IF

             pZoom += zInc : pZoom = GetMinMAx(pZoom,1,500)

             gWIN.PixelR(1) = OOO1 * pZoom  '.0001# * pZoom

             IF gWIN.PixelR(1) <> gWIN.PixelR(0) THEN 'if change

                IF (pZoom < 11) OR (pZoom > 489) THEN SLEEP 200

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

                ReDrawModel = TRUE  'refresh the window on next draw
             END IF
          END IF


          'check for left button double click
          GRAPHIC WINDOW CLICK gWIN.hWin(0) TO mclick, xCoord, yCoord

          IF mclick = 2 THEN

             xIdx2 = SetTargetPos(xm,ym,0,RayPtr,ScanPtr,yPosA)

             'make sure Index is in range
             xIdx = GetMinMax(xIdx2,0,@Ray.Index359)

             yPosA = ROUND(yPosA,3)

             xPos2 = (eNormRad(xIdx) + yPosA) * COS(eNormRdn(xIdx)) + @nScan.skewOffset * COS(eNormRdn(xIdx) + @nScan.skewRdn) + eOriginX(xIdx)
             yPos2 = (eNormRad(xIdx) + yPosA) * SIN(eNormRdn(xIdx)) + @nScan.skewOffset * SIN(eNormRdn(xIdx) + @nScan.skewRdn)
             zPos2 = eRotDeg(xIdx)
             cPos2 = eArc(xIdx) 'Circ:  X position, parallel to weld axis, image encoder output
             aPos2 = yPosA      'Ax
             ReDrawPlot = TRUE

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


SUB SetWindow(BYVAL yRadius AS DOUBLE)

    LOCAL sizeX,sizeY,sizeT,pSizeY,nSizeY,pSizeX,nSizeX AS SINGLE

    LOCAL fCtr,xTop, yTop, xVar, yVar,PixWidth,PixHeight,tPix AS LONG

    '*******************************************************************************************
    'Create Fonts
    '*******************************************************************************************
    FOR fCtr = 1 TO 30  'Courier New  Lucida Console
        FONT NEW "Courier New", fCtr, 1, 0, 0, 0 TO gFont(fCtr)
        'FONT NEW "Times New Roman", fCtr, 0, 0, 0, 0 TO gFont(fCtr) 'FONT NEW fontname$, points!, style&, charset&,
    NEXT                                                            'pitch&, escapement&] TO fhndl

    FOR fCtr = 0 TO 360                     '2
        FONT NEW "Lucida Console", 10, 0, 0, 1, (fctr*10) TO aFont(fCtr) 'FONT NEW fontname$, points!, style&, charset&,_
    NEXT                                                                   'pitch&, escapement&] TO fhndl

    FontNum = 12 'FontNum is Global

    '*******************************************************************************************
    'Compute Screen Size and Scale
    '*******************************************************************************************
    DESKTOP GET CLIENT TO PixWidth, PixHeight  ' desktop size:  screen that is not obscured by the system tray.
    DESKTOP GET LOC TO xTop, yTop 'screen tray's position determines the upper, left position of the client area.
    'DESKTOP GET SIZE TO ncWidth&, ncHeight& 'includes space taken up by the system tray and is same as the screen size
    'GRAPHIC GET PPI TO xVar, yVar

    'print PixWidth; PixHeight

    tPix = 240     'tested pixel width needed to contain printed Text on the left of screen

    xTop += 20  : yTop += 12

    gWIN.xPix(0) = PixHeight-50

    gWIN.yPix(0) = PixWidth-50

    sizeX = yRadius * 2 + 4 '= 2.0" clearance on each side

    'inches per pixel - graphic window size
    gWIN.PixelR(0) = sizeX/gWIN.xPix(0) 'spatial resolution based on x zize (vertical), largest dia, least pixels.

    pSizeX = gWIN.xPix(0) * gWIN.PixelR(0) * 0.500 'set positive and negative to equal size
    nSizeX = pSizeX

    sizeY = gWIN.yPix(0) * gWIN.PixelR(0) 'size y in inches
    sizeT = tPix * gWIN.PixelR(0)         'size text in inches

    pSizeY = (sizeY-sizeT) * 0.500 'Positive side = (total screen inch size - text width inch size) / 2
    nSizeY = sizeY - pSizeY        'Negative side = remaining width

    IF gWIN.xNear THEN
        gWIN.yMinR(0) = -nSizeY : gWIN.yMaxR(0) = pSizeY
        gWIN.xMinR(0) = -nSizeX : gWIN.xMaxR(0) = pSizeX
    ELSE
        gWIN.yMinR(0) = nSizeY : gWIN.yMaxR(0) = -pSizeY
        gWIN.xMinR(0) = nSizeX : gWIN.xMaxR(0) = -pSizeX
    END IF

    gWIN.bClr(0) = %BLACK : gWIN.fClr(0) = %WHITE

    gWIN.PixelR(1)  = gWIN.PixelR(0)

    gWIN.yPix(1) = gWIN.yPix(0) : gWIN.xPix(1) = gWIN.xPix(0)
    gWIN.yMinR(1)= gWIN.yMinR(0): gWIN.yMaxR(1)= gWIN.yMaxR(0)
    gWIN.xMinR(1)= gWIN.xMinR(0): gWIN.xMaxR(1)= gWIN.xMaxR(0)
    gWIN.bClr(1) = gWIN.bClr(0) : gWIN.fClr(1) = gWIN.fClr(0)


    'store the intial settings
    gWIN.SetPixelR(1) = gWIN.PixelR(1)
    gWIN.SetyMinR(1) = gWIN.yMinR(1) : gWIN.SetyMaxR(1) = gWIN.yMaxR(1)
    gWIN.SetxMinR(1) = gWIN.xMinR(1) : gWIN.SetxMaxR(1) = gWIN.xMaxR(1)


    '*******************************************************************************************
    'Create Graphic Bitmaps
    '*******************************************************************************************
    'text bitmap window
    'assigned odd numbers for bitmaps or special use windows, used to store static images for copying to standard window
    GRAPHIC BITMAP NEW 240,gWIN.xPix(1) TO gWIN.hWin(3) 'bitmap window for current nozzle weld scan model
    GRAPHIC ATTACH gWIN.hWin(3), 0&                   'Select bitmap window #3
    GRAPHIC COLOR gWIN.bClr(1), gWIN.fClr(1)            'Set foreground and  background color
    GRAPHIC CLEAR                                'Clear selected window with background color
    GRAPHIC SET FONT gFont(12) 'FontNum)
    GRAPHIC SET OVERLAP (TRUE)

    'graphic bitmap window
    'assigned odd numbers for bitmaps or special use windows, used to store static images for copying to standard window
    GRAPHIC BITMAP NEW gWIN.yPix(1),gWIN.xPix(1) TO gWIN.hWin(1) 'bitmap window for current nozzle weld scan model
    GRAPHIC ATTACH gWIN.hWin(1), 0&                   'Select bitmap window #1
    GRAPHIC COLOR gWIN.fClr(1), gWIN.bClr(1)            'Set foreground and  background color
    GRAPHIC CLEAR                                'Clear selected window with background color
    GRAPHIC SET FONT gFont(12) 'FontNum)
    GRAPHIC SCALE(gWIN.yMinR(1),gWIN.xMinR(1))-(gWIN.yMaxR(1),gWIN.xMaxR(1))
    GRAPHIC SET OVERLAP (TRUE)


    '**********************************************************************************************************************
    'Create Main Graphics Window
    '**********************************************************************************************************************
    'assigned even numbers for standard windows, direct display
    GRAPHIC WINDOW NEW "BRANCH CONNECTION 'Top View'", xTop, yTop, gWIN.yPix(0), gWIN.xPix(0) TO gWIN.hWin(0) 'Create a graphic window and assign it a handle
    GRAPHIC ATTACH gWIN.hWin(0), 0&                                       'Select standard window
    GRAPHIC COLOR gWIN.fClr(0), gWIN.bClr(0)                              'Set foreground and  background color
    GRAPHIC CLEAR                                                         'Clear selected window with background color
    GRAPHIC SET FONT gFont(12) 'FontNum)

    'GRAPHIC SET CLIP LeftMargin!, TopMargin!, RightMargin!, BottomMargin!
    'GRAPHIC SCALE PIXELS
    'GRAPHIC SET CLIP 230, 0, 0, 0

    GRAPHIC SCALE(gWIN.yMinR(0),gWIN.xMinR(0))-(gWIN.yMaxR(0),gWIN.xMaxR(0))
    GRAPHIC WINDOW STABILIZE gWIN.hWin(0)
    GRAPHIC SET OVERLAP (TRUE)


    'DO NOT USE !!!!!!!!!!!!!!!!
'#####################################################################################################################

    'KILLS THE UP/DN/LEFT/RIGHT and some other extended keys !!!!!!!!!

    'GRAPHIC SET VIRTUAL gWIN.yPix(0), gWIN.xPix(0), USERSIZE

'#####################################################################################################################


    GRAPHIC SET FOCUS

END SUB
