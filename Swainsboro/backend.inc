MACRO CONST = MACRO
'misc const values
CONST ENABLE =  1
CONST DISABLE = 0


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
' KeyVal& = GUICheckKey(CMsg&, CVal&)             (Check to see if key event occurred)
' EventName$ = GUIEventName(CMsg&)                (Return name of Event as a string. Used only for keyboard events right now)

' -----------------------------------------------------------------------------------
' Graphic Commands      Coordinates are in FULL INCHES using floating point values
' -----------------------------------------------------------------------------------
' Graphic_Scale X1!, Y1!, X2!, Y2!, MaxDrawStack&       (start draw cycle and scale window. Define coordinate system. MaxDrawStack& = maximum drawing tasks allowed this cycle)

' Graphic_ColorRGB FGColor&, BGColor&                   (define current FG and BG colors using actual RGB colors)
' Graphic_Color FGColor&, BGColor&                      (define current FG and BG colors using EZGUI color indexes)
' Graphic_Line X1!, Y1!, X2!, Y2!                       (draw Line from X1!,Y1! to X2!,Y2! using current color)
' Graphic_LineTo X2!, Y2!                               (draw line from end of last line or point to X2!,Y2! using current color)

' Graphic_Render                                        (end draw cycle and draw image using current draw stack)
' Graphic_Show                                          (show Graphic Window, which is above MAIN form)
' Graphic_CalcPoint X1!, Y1!,Length!,Degrees&,RX!,RY!   (calculate endpoint of line from X1!,Y1! which is Length! long at Degrees! angle. Return endpoint in RX!,RY!)
' XtoYAspect! = Graphic_GetAspectRatio                  (get aspect ratio of X axis to Y axis (X divided by Y) for Graphic Window. Call before Graphic_Scale)
' Graphic_Bitmap BWidth&, BHeight&                      (define Background Canvas Size in pixels)

FUNCTION BackEndThreadFunc(BYVAL IFlag&) AS LONG
    LOCAL filename AS STRING
    LOCAL filenumber AS INTEGER
    LOCAL myoffset AS LONG
    LOCAL tempstr AS STRING
    LOCAL tempx1, tempx2, tempy1, tempy2 AS DOUBLE
     ' =====================================================================
     IF IFlag&=0 THEN EXIT FUNCTION     ' only run this code once in thread
     ' =====================================================================
     LOCAL Control_ID&, CMsg&, CVal&, RV$, V#, CurrentTime AS EXTENDED, TimeSpan AS EXTENDED, KeyVal&
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
     GUISetButton 1, "Show Graphic"
     GUISetButton 2, "Draw Bitmap"
     ' disable scan stop button since no scanning yet
     GUI_STOPSCAN 0
      'wlc
     OPEN EZ_AppPath+"axscan.dat" FOR BINARY AS #1 BASE = 0
     myoffset = 0
     DO
          ' ----------------------------------------
          GUIGetUserInput Control_ID&, CMsg&, CVal&
          ' ----------------------------------------
          IF Control_ID& <> %GUINoInput THEN    ' make sure some input has occurred
          ' ----------------------------------------
               ' ------------------------------------------
               ' Test for Key Events
               ' ------------------------------------------
               KeyVal& = GUICheckKey(CMsg&, CVal&)
               IF KeyVal& <> 0 THEN
                    ' do something with keys
                    ' KeyVal& has Key value in it (see EZGUI key constants in ezgui50.inc)
                    ' CMsg& has EZGUI event (%EZ_KeyPress, %EZ_KeyDown, %EZ_KeyUp) or (%EZ_SysKeyPress, %EZ_SysKeyDown, %EZ_SysKeyUp)
                    ' Control_ID& has ID of control which has focus and gets key event
                    ' Remember that controls will still get the keys no matter what you do here
                    SELECT CASE KeyVal&
                         CASE %EZK_ENTER
                              GUIPrintStatus "Enter - " + GUIEventName(CMsg&) + "   ID =" + STR$(Control_ID&)
                         CASE %EZK_ESC
                              GUIPrintStatus "ESC - " + GUIEventName(CMsg&) + "   ID =" + STR$(Control_ID&)
                         CASE %EZK_END
                              GUIPrintStatus "End - " + GUIEventName(CMsg&) + "   ID =" + STR$(Control_ID&)
                         CASE %EZK_HOME
                              GUIPrintStatus "Home - " + GUIEventName(CMsg&) + "   ID =" + STR$(Control_ID&)
                         CASE ELSE
                    END SELECT
               END IF
               ' ------------------------------------------
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
                              Graphic_Show   ' Show Graphic Window above MAIN form
                         END IF
                    CASE 2    ' Extra Button 2
                         IF CMsg&=%EZ_Click THEN
                              GOSUB TestDrawBitmap
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
     EXIT FUNCTION


' Graphic_Scale X1!, Y1!, X2!, Y2!, MaxDrawStack&       (start draw cycle and scale window. Define coordinate system. MaxDrawStack& = maximum drawing tasks allowed this cycle)

' Graphic_ColorRGB FGColor&, BGColor&                   (define current FG and BG colors using actual RGB colors)
' Graphic_Color FGColor&, BGColor&                      (define current FG and BG colors using EZGUI color indexes)
' Graphic_Line X1!, Y1!, X2!, Y2!                       (draw Line from X1!,Y1! to X2!,Y2! using current color)
' Graphic_LineTo X2!, Y2!                               (draw line from end of last line or point to X2!,Y2! using current color)

' Graphic_Render                                        (end draw cycle and draw image using current draw stack)
' Graphic_Show                                          (show Graphic Window, which is above MAIN form)
' Graphic_CalcPoint X1!, Y1!,Length!,Degrees&,RX!,RY!   (calculate endpoint of line from X1!,Y1! which is Length! long at Degrees! angle. Return endpoint in RX!,RY!)
' YtoXAspect! = Graphic_GetAspectRatio                  (get aspect ratio of Y axis to X axis (Y divided by X) for Graphic Window. Call before Graphic_Scale)
' Graphic_Bitmap BWidth&, BHeight&                      (define Background Canvas Size in pixels)

TestDrawBitmap:
LOCAL DG&, RX!, RY!, CircleDiam!
LOCAL ySCRN&, xSCRN&, PlotClr&, ForeClr&,BackClr&
LOCAL yScrn1!, xScrn1!, yScrn2!, xScrn2! , PixPerInch!
yScrn& = 1200
xScrn& = 800

PixPerInch! = 0.04!
yScrn1! = -(ySCRN& * .400! * PixPerInch!): yScrn2! = ySCRN& * .400! * PixPerInch!
xScrn1! = -(xSCRN& * .400! * PixPerInch!): xScrn2! = xSCRN& * .400! * PixPerInch!


PlotClr& = 15  ' white  DOS color index
BackClr& = 0   ' black DOS color index
ForeClr& = PlotClr&

Graphic_Bitmap ySCRN&, xSCRN& ' call before drawing

Graphic_Scale yScrn1!, xScrn1!, yScrn2!, xScrn2!, 1000 ' last parameter defines stack size for number of Graphic calls allowed
' Graphic Scale must come before all other commands, except Graphic_Bitmap
Graphic_Color ForeClr&, BackClr&
Graphic_Clear
CircleDiam! = xScrn2! * 0.95!
'FOR DG& = 0 TO 360 STEP 2
'     Graphic_CalcPoint 0!,0!, CircleDiam!, DG&, RX!, RY!
'     IF DG& <> 0 THEN
'          Graphic_Color ForeClr&,BackClr&       ' set colors to light yellow on black
'          Graphic_LineTo RX!, RY!  ' add outside of circle line
'     END IF
'     Graphic_Color ForeClr&, BackClr&   ' set colors to light blue on black
     Graphic_Line 0!,0!, RX!, RY!  ' draw radius line
'NEXT DG&
 WHILE ISFALSE EOF(1)

       'clr1& = %RGB_LIGHTYELLOW
    'draw transducer sides x4 (rectangle)

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 10

       ' GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&
        Graphic_Line tempy1,tempx1, tempy2, tempx2  ' draw radius line
        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 10

        'GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&
        Graphic_Line tempy1,tempx1, tempy2, tempx2  ' draw radius line
        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 10

        'GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&
        Graphic_Line tempy1,tempx1, tempy2, tempx2  ' draw radius line

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 10

        'GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&
        Graphic_Line tempy1,tempx1, tempy2, tempx2  ' draw radius line
        'make sure all (4) corners of the rectangle are sealed before calling GRAPHIC PAINT, otherwise paint leaks out everywhere!!
        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10

       ' GRAPHIC SET PIXEL (tempy1,tempx1),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10

        'GRAPHIC SET PIXEL (tempy1,tempx1),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10

        'GRAPHIC SET PIXEL (tempy1,tempx1),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10

        'GRAPHIC SET PIXEL (tempy1,tempx1),clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10

        'GRAPHIC PAINT (tempy1, tempx1), %RGB_ORANGE, clr1&

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 10
        'clr1& = %RGB_LIGHTYELLOW

        'GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&  'RGB_WHITE 'LIGHTGOLDENRODYELLOW '%RGB_GHOSTWHITE 'draw line on HALO
        Graphic_Line tempy1,tempx1, tempy2, tempx2

        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 10

        'GRAPHIC LINE(tempy1,tempx1)-(tempy2,tempx2),clr1&
        Graphic_Line tempy1,tempx1, tempy2, tempx2
        GET  #1, myoffset,  tempy1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx1
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempy2
        myoffset = myoffset + 10
        GET  #1, myoffset,  tempx2
        myoffset = myoffset + 10
        'GRAPHIC ELLIPSE (tempy1,tempx1)-(tempy2,tempy2), %RGB_WHITE, -1 'orange, -1 '%WHITE, -1 'clr1&

        'SLEEP 25
        'Graphic_Clear
        Graphic_Render
        Graphic_Show
        'GRAPHIC INKEY$ TO MyInput
        'IF MyInput = $ESC THEN Terminate

WEND
Terminate:

'GRAPHIC WAITKEY$

'Graphic_Render
'Graphic_Show
RETURN


END FUNCTION
