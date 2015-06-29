#INCLUDE "scanctrl.inc"
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
' GUISetXPos validXPOS&                       'bc (sets X POS) 'Calls SetXPOSValue (places value in text box, converts from numeral to string. STR$)
' GUISetYPos validYPOS&                       'bc (sets Y POS) 'Calls SetXPOSValue (places value in text box, converts from numeral to string. STR$)
' GUISetRPos validRPOS&                       'bc (sets R POS) 'Calls SetRPOSValue (places value in text box, converts from numeral to string. STR$)
' GUIGoAutoScan enable disable button         GENDIS = ENDIS - example; GuiGoAutoscan 0 '(DISABLE)    GuiGoAutoscan 1 '(ENABLE)
' GUIStopScan enable disable button           GENDIS = ENDIS - example; GuiStopscan 0 '(DISABLE)    GuiStopscan 1 '(ENABLE)
' GUIAllOff (disable/enable) button           GENDIS = ENDIS - example; GUIAllOff 0 '(DISABLE)    GUIAllOff 1 '(ENABLE)
'GUISetXPLUS   (disable/enable) button           GENDIS = ENDIS - example - See above
'GUISetXMINUS  (disable/enable) button           GENDIS = ENDIS - example - See above
'GUISetAllPOS  (disable/enable) button           GENDIS = ENDIS - example - See above
'GuiAllOff     (disable/enable) button           GENDIS = ENDIS - example - See above
'GuiAllOn      (disable/enable) button           GENDIS = ENDIS - example - See above
DECLARE FUNCTION mystring(BYVAL bc_string$) AS STRING

GLOBAL bc_string AS STRING
'%MAIN_BUTTONXPOS         = 105                'bc Brought over from scanctrl.bas - maybe we can put these in an include file   ; I added the include file, but not in the main scanctrl.bas
GLOBAL bc_string AS STRING

FUNCTION BackEndThreadFunc(BYVAL IFlag&) AS LONG
     LOCAL CID&, CMsg&, CVal&
     IF IFlag&=0 THEN EXIT FUNCTION
     ' Initial all your controls here
     GUISetXMotor 1
     GUISetYMotor 1
     GUISetRMotor 1
     bc_string = "Bill"
     bc_string = mystring(bc_string)
     'bc - step 4 to add button
     DO                                                  'Kevins MAIN start
          GUIGetUserInput CID&, CMsg&, CVal&             'Main routine to recieve button clicks and keyboard presses
          IF CID&<>%GUINoInput THEN
               SELECT CASE CID&
                    CASE 0
                         IF CMsg&=%EZ_Close THEN
                              GUISetClose
                              EXIT LOOP
                         END IF
                    CASE %MAIN_BUTTONXPOS
                          bc_string = "Set XPOS"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          SCN.XPos = 25     'bc - updated falue then sent to form.
                          GUISetXPOS SCN.XPos  '*** bc - Kevin this only updates the Value in the XPOS Box - it does not ask user for input. That would be a higher level call - see what Chris thinks'
                    CASE %MAIN_BUTTONYPOS
                          bc_string = "Set YPOS"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GUISetYPOS 30  '*** bc - Kevin this only updates the Value in the YPOS Box - it does not ask user for input. That would be a higher level call - see what Chris thinks'
                    CASE %MAIN_BUTTONRPOS
                          bc_string = "Set RPOS"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GUISetRPOS 35  '*** bc - Kevin this only updates the Value in the RPOS Box - it does not ask user for input. That would be a higher level call - see what Chris thinks'
                    CASE %MAIN_BUTTONGOSCAN
                          bc_string = "GoAutoSCAN button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GuiGoAutoscan DISABLE
                    CASE %MAIN_BUTTONSTOPSCAN
                          bc_string = "StopSCAN button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GuiStopscan DISABLE
                    CASE %MAIN_BUTTONALLON
                          bc_string = "AllOn button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GuiAllOn DISABLE
                    CASE %MAIN_BUTTONALLOFF
                          bc_string = "AllOff button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GuiAllOff DISABLE
                     CASE %MAIN_BUTTONALLPOS
                          bc_string = "Set All Position  button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GUISetAllPOS DISABLE
                     CASE %MAIN_BUTTONJOGXPLUS
                          bc_string = "Set XPLUS  button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GUISetXPLUS DISABLE
                     CASE %MAIN_BUTTONJOGXMINUS
                          bc_string = "Set X MINUS   button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GUISetXMINUS  DISABLE
                     CASE %MAIN_BUTTONJOGYPLUS
                          bc_string = "Set YPLUS  button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GUISetYPLUS DISABLE
                     CASE %MAIN_BUTTONJOGYMINUS
                          bc_string = "Set Y MINUS   button hit!"
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string       'I added bc_string whoo hoo!
                          GUISetYMINUS  DISABLE
                    CASE ELSE
                         bc_string = "Default string"
                         GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string
                         GUISetXMotor 0    'bc I did this as a test
               END SELECT
          END IF                                       'Kevins MAIN atop
     LOOP
     FUNCTION=0
END FUNCTION

FUNCTION mystring(BYVAL bc_string$) AS STRING
    mystring = "Kevin"
END FUNCTION
