MACRO CONST = MACRO
'misc const values
CONST ENABLE =  1
CONST DISABLE = 0

TYPE ScanVars

    YCtr        AS DOUBLE      'YCts/inch
    XCtr        AS DOUBLE      'XCts/inch
    ZCtr        AS DOUBLE      'ZCts/Degree
    ACtr        AS DOUBLE      'Aux Enc Cts/inch

    YCal        AS DOUBLE      'Y Cal Inch distance
    XCal        AS DOUBLE      'X Cal Inch distance
    ZCal        AS DOUBLE      'Z Cal Degree distance
    ACal        AS DOUBLE      'Aux Cal Inch distance

    XOffset     AS DOUBLE      'X inch pos when counter zeroed
    YOffset     AS DOUBLE      'Y inch pos when counter zeroed
    ZOffset     AS DOUBLE      'Z degree pos when counter zeroed
    AOffset     AS DOUBLE      'A Inch pos when counter zeroed

    XPos        AS DOUBLE      'current X inch position
    YPos        AS DOUBLE      'current Y inch position
    ZPos        AS DOUBLE      'current Z inch position
    APos        AS DOUBLE      'current A inch position

    XPlus       AS INTEGER      'X scan +/-
    YPlus       AS INTEGER      'Y scan +/-
    ZPlus       AS INTEGER      'Z scan +/-

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

    IndexDir    AS INTEGER      'Index towards High or Low: RN IndexLow

    XCts        AS LONG         'x absolute value scan start counts
    YCts        AS LONG         'y absolute value scan start counts
    ZCts        AS LONG         'z absolute value scan start counts
    ACts        AS LONG         'a absolute value scan start counts

    XStartCts   AS LONG         'x actual value (+/-) scan start counts
    YStartCts   AS LONG         'y actual value (+/-) scan start counts
    ZStartCts   AS LONG         'z actual value (+/-) scan start counts

    XEndCts     AS LONG         'x actual value (+/-) scan end counts
    YEndCts     AS LONG         'y actual value (+/-) scan end counts
    ZEndCts     AS LONG         'z actual value (+/-) scan end counts

    XLow        AS DOUBLE      'x scan start inch position
    YLow        AS DOUBLE      'y scan start inch position
    ZLow        AS DOUBLE      'z scan start inch position

    XHigh       AS DOUBLE      'x scan end inch position
    YHigh       AS DOUBLE      'y scan end inch position
    ZHigh       AS DOUBLE      'z scan end inch position

    OverLap     AS DOUBLE      'added si scan overlap

    XSpeed      AS DOUBLE      'x scan speed in inches
    YSpeed      AS DOUBLE      'y scan speed in inches
    ZSpeed      AS DOUBLE      'z scan speed in inches

    XEnable     AS INTEGER      'flag true/false X axis on
    YEnable     AS INTEGER      'flag true/false Y axis on
    ZEnable     AS INTEGER      'flag true/false Z axis on

    XSpdDir     AS INTEGER      'flag X speed cntrl direction
    IndexY      AS INTEGER      'flag true/false index on X or Y, circ or ax scan
    StopChk     AS INTEGER      'flag true/false autoOff on/off
    DualRas     AS INTEGER        'flag true/false double raster each index
    AutoHold    AS INTEGER      'flag true/false Auto Hold
    IndexCt     AS INTEGER      'index loop counter
    IndexInc    AS INTEGER      'index loop incrementer
    ScanFlag    AS INTEGER      '
    Index       AS INTEGER      'scan direction
    NextFlag    AS INTEGER      'added for si auto scan increment

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

END TYPE

GLOBAL SCN AS ScanVars

' Extra Buttons have IDs 1 to 18
' File menu has IDs from 50 to 56
' Setup menu has IDs from 60 to 66
' Window menu has ID's from 70 to 76
' ------------------------------
' GUI Commands are listed below
' ------------------------------
' GUIGetUserInput CID&, CMsg&, CVal&              (returns three values. CID& is control ID, CMsg& is EZGUI event constant, CVal& is a parameter for the event)
' GUISetClose                                     (sets a flag telling GUI it is allowed to close the app)
' GUIPrintStatus SText$                           (sets Status bar text)
' GUISetXMotor State&                             (sets X Motor ON/OFF button state. 1 = ON, 0 = OFF)
' GUISetYMotor State&                             (sets Y Motor ON/OFF button state. 1 = ON, 0 = OFF)
' GUISetRMotor State&                             (sets R Motor ON/OFF button state. 1 = ON, 0 = OFF)
' GUIMsgBox T$                                    (display a messagebox, T$ is text to display)
' GUIWarningBox T$                                (display warning messagebox, T$ is text to display)
' RV& = GUIQuestionBox(T$, BProp$)                (display a question box, T$ is text to display, BProp$ is property string as follows)
'                                                 ( "OKC" = OK/Cancel, "RC" = Retry/Cancel, "YN" = Yes/No, "YNC" = Yes/No/Cancel, "ARI" = Abort/Retry/Ignore)
' GUISetPolarCartesian PState&                    (set Polar/Cartesion state. 1 = Polar, 0 = Cartesian)
' GUISetContinuousStep PState&                    (set Continuous/Step state. 1 = Continuous,  0 = Step)
' RV$ = GUIShowInputBox(Prompt$)
' GUISetButton ButtonNumber&, ButtonText$         (set and show extra buttons. 0 = Extra Scan Button, 1 to 18 = button array buttons)
' GUISetXText T$                                  (set X Position Textbox)
' GUISetYText T$                                  (set Y Position Textbox)
' GUISetRText T$                                  (set R Position Textbox)
' GUISetXPos XPos#                                (set X Position passing a Double value)
' GUISetYPos YPos#                                (set Y Position passing a Double value)
' GUISetRPos RPos#                                (set R Position passing a Double value)
' GUISetTrackBar MinPos&, MaxPos&, CurrentPos&    (set Trackbar min,max and position)
' GUISetJogText T$                                (set Jog rate text)
' T$ = GUIDoubleToStr(V#)                         (convert a Double value to a string)
' --------------------------- Enable/Disable controls --------------------------------
' GUI_XPOS EnableFlag&                            (Enables or Disables XPOS Button)
' GUI_XONOFF EnableFlag&                          (Enables or Disables XONOFF Button)
' GUI_YPOS EnableFlag&                            (Enables or Disables YPOS Button)
' GUI_YONOFF EnableFlag&                          (Enables or Disables YONOFF Button)
' GUI_RPOS EnableFlag&                            (Enables or Disables RPOS Button)
' GUI_RONOFF EnableFlag&                          (Enables or Disables RONOFF Button)
' GUI_POLAR EnableFlag&                           (Enables or Disables POLAR Button)
' GUI_CARTESIAN EnableFlag                        (Enables or Disables CARTESIAN Button)
' GUI_ALLPOS EnableFlag&                          (Enables or Disables ALLPOS Button)
' GUI_ALLOFF EnableFlag&                          (Enables or Disables ALLOFF Button)
' GUI_ALLON EnableFlag&                           (Enables or Disables ALLON Button)
' GUI_GOSCAN EnableFlag&                          (Enables or Disables GOSCAN Button)
' GUI_EXTRASCAN EnableFlag&                       (Enables or Disables EXTRASCAN Button)
' GUI_STOPSCAN EnableFlag&                        (Enables or Disables STOPSCAN Button)
' GUI_JOGYPLUS EnableFlag&                        (Enables or Disables JOGYPLUS Button)
' GUI_JOGXMINUS EnableFlag&                       (Enables or Disables JOGXMINUS Button)
' GUI_JOGXPLUS EnableFlag&                        (Enables or Disables JOGXPLUS Button)
' GUI_JOGYMINUS EnableFlag&                       (Enables or Disables JOGYMINUS Button)
' GUI_JOGRPLUS EnableFlag&                        (Enables or Disables JOGRPLUS Button)
' GUI_JOGRMINUS EnableFlag&                       (Enables or Disables JOGRMINUS Button)
' GUI_TRACKBAR EnableFlag&                        (Enables or Disables JOG Rate TRACKBAR)
' GUI_JOGCONT EnableFlag&                         (Enables or Disables JOGCONT Button)
' GUI_JOGSTEP EnableFlag&                         (Enables or Disables JOGSTEP Button)
' GUI_EXTRA BN&, EnableFlag&                      (Enables or Disables EXTRA Buttons, BN& is Button number 1 to 18)


' ---------------------------------------
' Graphic Commands
' ---------------------------------------
' Graphic_Start X1&, Y1&, X2&, Y2&, MaxDrawStack&       (start draw cycle. Define coordinate system. MaxDrawStack& = maximum drawing tasks allowed this cycle)
' Graphic_Color FGColor&, BGColor&                      (define current FG and BG RGB colors)
' Graphic_Line X1&, Y1&, X2&, Y2&                       (draw Line from X1&,Y1& to X2&,Y2& using current color)
' Graphic_LineTo X2&, Y2&                               (draw line from end of last line or point to X2&,Y2& using current color)


FUNCTION BackEndThreadFunc(BYVAL IFlag&) AS LONG
     ' =====================================================================
     IF IFlag&=0 THEN EXIT FUNCTION     ' only run this code once in thread
     ' =====================================================================
     LOCAL Control_ID&, CMsg&, CVal&, RV$, V#, CurrentTime AS EXTENDED, TimeSpan AS EXTENDED
     LOCAL P AS STRING
     LOCAL cw,ch, LP, LN,X,Y,X1,Y1, X2, Y2,pw, dg, L AS LONG
     LOCAL h,w,scalex, scaley AS SINGLE
     STATIC ScanningFlag&, ScanCount&, ScanTime AS EXTENDED
     ' Initialize everything here before DO LOOP
     ScanningFlag& = 0 ' default not scanning


     ' set default values for Motor ON/OFF buttons
     GUISetXMotor 1
     GUISetYMotor 1
     GUISetRMotor 1
     ' set default state Polar or Cartesian
     GUISetPolarCartesian 1
     ' set default state Continuous or Step
     GUISetContinuousStep 1
     ' set default values for X,Y,R Position textboxes
     GUISetXPos  0.98#
     GUISetYPos  0.97#
     GUISetRPos  0.96#
     ' set default min,max and position for Jog rate TrackBar
     GUISetTrackBar 0, 200, 10
     ' set default text for Jog rate
     GUISetJogText "10"
     ' define some of the extra buttons
     GUISetButton 1, "Button 1"
     GUISetButton 2, "Button 2"
     ' disable scan stop button since no scanning yet
     GUI_STOPSCAN 0
     DO
          ' ----------------------------------------
          GUIGetUserInput Control_ID&, CMsg&, CVal&
          ' ----------------------------------------
          IF Control_ID& <> %GUINoInput THEN    ' make sure some input has occurred
          ' ----------------------------------------
               SELECT CASE Control_ID&
                    ' -------------------------------------
                    ' Main Form events
                    ' -------------------------------------
                    CASE 0    ' Forms ID
                         IF CMsg&=%EZ_Close THEN
                              GUISetClose
                              EXIT LOOP
                         END IF
                    ' -------------------------------------
                    ' Main Canvas events
                    ' -------------------------------------
                    CASE %MAIN_MAINCANVAS
                    ' -------------------------------------
                    ' Jog Rotation control event
                    ' -------------------------------------
                    CASE %MAIN_CANVASJOGCONTROL
                    ' -------------------------------------
                    ' Scan Setting Buttons
                    ' -------------------------------------
                    CASE %MAIN_BUTTONXPOS
                         IF CMsg&=%EZ_Click THEN
                              RV$ = GUIShowInputBox("Enter new X Position")
                              IF RV$ <> "" THEN
                                   V# = VAL(RV$)
                                   GUISetXPos V#
                                   ' ----------------
                                   ' alternate method
                                   ' ----------------
                                   ' GUISetXText RV$
                              END IF
                         END IF
                    CASE %MAIN_BUTTONXONOFF
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click X ON/OFF"
                         END IF
                    CASE %MAIN_BUTTONYPOS
                         IF CMsg&=%EZ_Click THEN
                              RV$ = GUIShowInputBox("Enter new Y Position")
                              IF RV$ <> "" THEN
                                   V# = VAL(RV$)
                                   GUISetYPos V#
                                   ' ----------------
                                   ' alternate method
                                   ' ----------------
                                   ' GUISetYText RV$
                              END IF
                         END IF
                    CASE %MAIN_BUTTONYONOFF
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click Y ON/OFF
                         END IF
                    CASE %MAIN_BUTTONRPOS
                         IF CMsg&=%EZ_Click THEN
                              RV$ = GUIShowInputBox("Enter new R Position")
                              IF RV$ <> "" THEN
                                   V# = VAL(RV$)
                                   GUISetRPos V#
                                   ' ----------------
                                   ' alternate method
                                   ' ----------------
                                   ' GUISetRText RV$
                              END IF
                         END IF
                    CASE %MAIN_BUTTONRONOFF
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click R ON/OFF"
                         END IF
                    CASE %MAIN_BUTTONPOLAR
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click Polar"
                         END IF
                    CASE %MAIN_BUTTONCARTESIAN
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click Cartesian"
                         END IF
                    CASE %MAIN_BUTTONALLPOS
                         IF CMsg&=%EZ_Click THEN
                              RV$ = GUIShowInputBox("Enter new Position for All")
                              IF RV$ <> "" THEN
                                   V# = VAL(RV$)
                                   GUISetXPos V#
                                   GUISetYPos V#
                                   GUISetRPos V#
                                   ' ----------------
                                   ' alternate method
                                   ' ----------------
                                   ' GUISetXText RV$
                                   ' GUISetYText RV$
                                   ' GUISetRText RV$
                              END IF
                         END IF
                    CASE %MAIN_BUTTONALLOFF
                         IF CMsg&=%EZ_Click THEN
                              GUISetXMotor 0
                              GUISetYMotor 0
                              GUISetRMotor 0
                         END IF
                    CASE %MAIN_BUTTONALLON
                         IF CMsg&=%EZ_Click THEN
                              GUISetXMotor 1
                              GUISetYMotor 1
                              GUISetRMotor 1
                         END IF
                    CASE %MAIN_BUTTONGOSCAN
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "SCANNING Now!"
                              ScanCount& = 0
                              ScanningFlag& = 1
                              GUI_GOSCAN 0   ' disable Scan button while scanning
                              GUI_STOPSCAN 1 ' enable Stop Scan button
                              ScanTime = EZ_GetPTime ' this function should be Thread safe
                         END IF
                    CASE %MAIN_BUTTONEXTRASCAN
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click Button Extra Scan"
                         END IF
                    CASE %MAIN_BUTTONSTOPSCAN
                         IF CMsg&=%EZ_Click THEN
                              IF ScanningFlag& <> 0 THEN
                                   ScanCount& = 0
                                   GUI_GOSCAN 1   ' Enable Scan button while scanning
                                   GUI_STOPSCAN 0 ' Disable Stop Scan button
                                   ScanningFlag& = 0
                                   GUIPrintStatus "SCAN Terminated!"
                              END IF
                         END IF
                    ' -------------------------------------
                    ' Jog Rate Buttons
                    ' -------------------------------------
                    CASE %MAIN_BUTTONJOGYPLUS
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click JOG Y+"
                         END IF
                    CASE %MAIN_BUTTONJOGXMINUS
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click JOG X-"
                         END IF
                    CASE %MAIN_BUTTONJOGXPLUS
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click JOG X+"
                         END IF
                    CASE %MAIN_BUTTONJOGYMINUS
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click JOG Y-"
                         END IF
                    CASE %MAIN_BUTTONJOGRPLUS
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click JOG R+"
                         END IF
                    CASE %MAIN_BUTTONJOGRMINUS
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click JOG R-"
                         END IF
                    CASE %MAIN_TRACKBARJOGRATE
                         IF CMsg&=%EZ_Change THEN
                              GUIPrintStatus "JOG TrackBar value "+STR$(CVal&)
                         END IF
                    CASE %MAIN_BUTTONJOGCONT
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click JOG Continuous"
                         END IF
                    CASE %MAIN_BUTTONJOGSTEP
                         IF CMsg&=%EZ_Click THEN
                              GUIPrintStatus "Click JOG Step"
                         END IF
                    ' -------------------------------------
                    ' Extra Buttons
                    ' -------------------------------------
                    CASE 1    ' Extra Button 1
                         IF CMsg&=%EZ_Click THEN
                              'GUIMsgBox "You clicked Extra Button 1"
                             EZ_GetCanvasSize "MAIN", %MAIN_MAINCANVAS, CW&, CH&
                             ScaleX!=CW&/800
                             ScaleY!=CH&/1050
                             EZ_StartDraw "MAIN", %MAIN_MAINCANVAS, CW&, CH&, ""
                             EZ_Color 15,0
                             EZ_CDraw %EZ_RECT, 0, 0, CW&-1, CH&-1, 1, 1
                             EZ_DefFont 50, "Arial", 24*ScaleY!, "BC"
                             EZ_UseFont 50
                             P$=EZ_LoadPicture(EZ_AppPath+"nice.bmp")
                             EZ_CDrawPicture CW&/2,0, CW&/2, CH&/2, P$, ""
                             EZ_FreeImage P$
                             Y1&=0
                             X1&=0
                             X2&=CW&/2
                             Y2&=CH&/2

                             PW&=INT(1)

                             EZ_Color 14,15
                             EZ_CDraw %EZ_ELLIPSE, X1&, Y1&, X2&, Y2&, PW&, 0
                             EZ_CDraw %EZ_RECT, X1&, Y&, X2&, Y2&, PW&, 0
                             EZ_CDraw %EZ_LINE, X1&, Y1&, X2&, Y2&, PW&, 0
                             L&=100
                             DG&=135 ' 45 degrees down (90+45)
                             ' X2& and Y2& are for return values
                             EZ_CalcPoint X1&, Y1&, L&, DG&, X2&, Y2&
                             EZ_CDraw %EZ_LINE, X1&,Y1&, X2&, Y2&, 1, 0
                             EZ_Color 12,12
                             Y1&=20
                             X1&=20
                             X2&=40
                             Y2&=40
                             FOR lp& = 1 TO 10
                               EZ_Color 12,12
                               EZ_CDraw %EZ_RECT, X1&, Y1&, X2&, Y2&, PW&, 1
                               EZ_COLOR 0,0
                               'X1& = X1&-20
                               'X2& = X2&-20
                               'Y1& = X1&-20
                              ' Y2& = X2&-20
                               EZ_CDraw %EZ_RECT, X1&-1, Y1&-1, X2&-1, Y2&-1, PW&, 1
                               EZ_CalcPoint X1&, Y1&, L&, DG&, X2&, Y2&
                               EZ_Color 14,15
                               EZ_CDraw %EZ_LINE, X1&,Y1&, X2&, Y2&, 1, 0
                               X1& = X1&+20
                               X2& = X2&+20
                               Y1& = X1&+20
                               Y2& = X2&+20
                             NEXT lp&
                             EZ_FreeFont 50
                             EZ_EndDraw

                         END IF
                    CASE 2    ' Extra Button 2
                         IF CMsg&=%EZ_Click THEN
                              GUIWarningBox "Warning! You clicked Extra Button 2"
                         END IF
'                    Add Extra Buttons as you need them using ID's 2 to 18
                    CASE ELSE
                         GUIPrintStatus "Control ID: "+STR$(Control_ID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)
               END SELECT
          ' ----------------------------------------
          ELSE ' no user input occurred so do something else
          ' ----------------------------------------
               IF ScanningFlag&<>0 THEN ' scanning is ON
                    ' do your scanning here
                    CurrentTime = EZ_GetPTime ' this function should be thread safe
                    IF ScanTime > CurrentTime THEN ScanTime = EZ_GetPTime ' clock has flipped back to zero
                    TimeSpan = CurrentTime - ScanTime
                    IF TimeSpan >= 0.03125## THEN ' this allows timing of GUI output to 1/32 second intervals
                         ScanCount& = ScanCount& +1
                         IF ScanCount& > 2000000000 THEN ScanCount& = 0
                         ScanTime = CurrentTime
                         GUIPrintStatus "Counting: "+STR$(ScanCount&)
                    END IF
                    ' do your hardware scanning here
               END IF
          ' ----------------------------------------
          END IF
     LOOP
     FUNCTION=0
END FUNCTION
