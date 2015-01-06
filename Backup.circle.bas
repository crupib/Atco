'====================================================================
'
'    ATCO
'
'====================================================================
#COMPILER PBWIN 10
#COMPILE EXE
#DIM ALL
#INCLUDE "circle.inc"

GLOBAL hDlg AS DWORD, w, h AS LONG
FUNCTION circle(CenterX AS LONG, CenterY AS LONG, Radius AS LONG ) AS LONG
    LOCAL x,y AS DOUBLE
    LOCAL k AS DOUBLE
    FOR k=0 TO 2 * Pi STEP .0001 ' or a larger step if you like
        x = SIN(k) * radius + CenterX
        y = COS(k) * radius + CenterY
        GRAPHIC SET PIXEL (x,y) , %BLUE
    NEXT k
    FUNCTION = 1
END FUNCTION
FUNCTION Calculate_Radis_Central_Angle() AS LONG
  arc_ABD =  (central_angle / 180) * Pi * radius
  arc_ABR = central_angle*(Pi/180)
  x = (centerX + radius * SIN(-arc_ABR))
  y = (centerY + radius * COS(-arc_ABR))
  x1 = (centerX + radius * SIN( arc_ABR))
  y1 = (centerY + radius * COS( arc_ABR))
  AB = SQR((x1-x)^2+(y1-y)^2)
  AO = radius
  AOE = SIN(Pi/180*(central_angle/2))
  AE = AOE*AO
  OE = SQR( AO^2 - AE^2 )
  ED = AO - OE
  circumference = 2 * Pi * AO
  circle_area = Pi*radius^2
  chord_AB = 2 * AOE * radius
  arclen_AB =  Central_angle*(Pi/180) * radius
  Sector_area = (Central_angle/360)*Pi*radius^2
  Triangle_area = (.5*radius*radius)*SIN((central_angle*Pi)/180)
  Segment_area =Sector_area - Triangle_area
END FUNCTION
SUB DrawDemo (BYVAL hDlg AS DWORD, BYVAL ID AS LONG)

  GRAPHIC CLEAR
  GRAPHIC WIDTH 3
  GRAPHIC ATTACH hDlg, ID, REDRAW        ' Use faster, buffered draw
  GRAPHIC COLOR %RGB_BLUE, %RGB_WHITE    ' Blue line, white background

  central_angle = 30
  centerX = 0 ' or any value you like
  centerY = 0
  radius = 200

  CALL  Calculate_Radis_Central_Angle()
   ' Calculate and draw circle based on center location of circle
  CALL  circle(centerX,centerY,radius)

  GRAPHIC PIE (-radius+CenterX, -radius+CenterY)-(radius+CenterX, radius+CenterY), 3*Pi/2-arc_ABR, 3*pi/2+arc_ABR, %GRAY, %LTGRAY, 4
  'line AO
  GRAPHIC LINE (centerX,centerY) - (x,y)
  ' line OB
  GRAPHIC LINE (centerX,centerY) - (x1,y1)
  GRAPHIC WIDTH 2
  ' line AB
  GRAPHIC LINE (x,y) - (x1,y1)
  'GRAPHIC PAINT BORDER (x+10, y-3), %RED, %BLUE, 0
 'line OD
  GRAPHIC LINE (centerX,centerY) - (centerX,radius+centerY)
' line CB
  GRAPHIC LINE (centerX,-radius+centerY) - (x1,y1)
' line AC
  GRAPHIC LINE (centerX,-radius+centerY) - (x,y)
  'GRAPHIC PAINT BORDER (x+10, y+2), %GREEN, %BLUE, 0
 ' GRAPHIC PAINT BORDER (x+radius-10, y+2), %GREEN, %BLUE, 0
  'GRAPHIC PIE (-radius+CenterX, -radius+CenterY)-(radius+CenterX, radius+CenterY), 3*Pi/2-arc_ABR, 3*pi/2+arc_ABR, %GRAY, %LTGRAY, 4
  GRAPHIC REDRAW
  DIALOG SET TEXT hDlg, "Atco Circle"
END SUB
' Main dialog callback procedure
'
CALLBACK FUNCTION DlgProc () AS LONG

    SELECT CASE CB.MSG

    CASE %WM_INITDIALOG   ' <- Sent right before the dialog is shown

    CASE %WM_COMMAND      ' <- A control is calling
        SELECT CASE CB.CTL  ' <- Look at control's id

        CASE %IDCANCEL
            IF CB.CTLMSG = %BN_CLICKED THEN ' Exit on Esc
                DIALOG END CB.HNDL
            END IF

        END SELECT

    END SELECT

END FUNCTION
CALLBACK FUNCTION EditControlCallback()
    CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
    radius = VAL(TXT$)
    CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
    central_angle = VAL(TXT$)
    DrawDemo hDlg, %IDC_GRAPHIC1
END FUNCTION
 CALLBACK FUNCTION Calc_button()
     MSGBOX STR$(radius)
 END FUNCTION
 FUNCTION BUILDWINDOW() AS LONG
    DIALOG NEW PIXELS, 0, "Atco Circles",,, 1920, 1080,%WS_OVERLAPPEDWINDOW , 0 TO hDlg
    ' Set up a pixel-based coordinate system in the Graphic control
    CONTROL GET CLIENT hDlg, %IDC_GRAPHIC1 TO w, h  ' Get client size
    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 0, 0, 400, 400
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX1, "", 600, 150, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX2, "", 600, 170, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX3, "", 600, 210, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX4, "", 600, 230, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX5, "", 600, 250, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX6, "", 600, 270, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX7, "", 600, 290, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX8, "", 600, 310, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX9, "", 600, 330, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX10, "", 600, 350, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX11, "", 600, 370, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    TXT$ = ""
    CONTROL ADD LABEL, hDlg, %IDC_LABEL1, TXT$, 500, 100, 60, 20
    CONTROL ADD OPTION, hDlg, %OPT1, "Radius and Central Angle", 600, 6, 180, 14, _
    %WS_GROUP OR %WS_TABSTOP
    CONTROL ADD OPTION, hDlg, %OPT2, "Radius & Chord AB", 600, 20,180 , 14
    CONTROL ADD OPTION, hDlg, %OPT3, "Radius & Segment Height ED", 600, 34, 180, 14
    CONTROL ADD OPTION, hDlg, %OPT4, "Radius & Apothem OE", 600, 48, 180, 14
    CONTROL ADD OPTION, hDlg, %OPT5, "Radius & Arc AB", 600, 62, 180, 14
    CONTROL ADD OPTION, hDlg, %OPT6, "Chord AB & Segment Height ED", 600, 76, 180, 14
    CONTROL ADD OPTION, hDlg, %OPT7, "Chord AB & Apothem OE", 600, 90, 180, 14
    CONTROL ADD OPTION, hDlg, %OPT8, "Segment Height ED & Apothem OE ", 600, 104, 180, 14
    CONTROL ADD OPTION, hDlg, %OPT9, "Chord AB & Arc AB", 600, 118, 180, 14
    CONTROL ADD BUTTON, hDlg, %IDOK, "Calculate", 600, 190, 80, 20, _
    %WS_GROUP , , CALL Calc_button()

  ' Set the initial state to OPTION button 3
    CONTROL SET OPTION hDlg, %OPT1, %OPT1, %OPT9
    GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1, REDRAW
    GRAPHIC COLOR %RGB_BLUE, RGB(255,255,255)
    GRAPHIC CLEAR
    GRAPHIC REDRAW
    GRAPHIC SET FOCUS
    GRAPHIC SCALE (-399,-399)-(399,399)  'work with symmetric screen
    Pi = 4 * ATN(1)      ' Calculate Pi

 END FUNCTION

' Program entry point
'
FUNCTION PBMAIN () AS LONG
    BUILDWINDOW()
'    DrawDemo hDlg, %IDC_GRAPHIC1
    DIALOG SHOW MODAL hDlg, CALL DlgProc
END FUNCTION
