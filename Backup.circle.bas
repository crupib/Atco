'====================================================================
'
'    ATCO
'
'====================================================================
#COMPILER PBWIN 10
#COMPILE EXE
#DIM ALL
#INCLUDE "circle.inc"
#RESOURCE ICON, exeICON, "ATCO.ico"

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
FUNCTION Calculate_Radius_Arc_AB() AS LONG
  AO = radius
  '''''''''''''''''''''''''''''''''''''''''''''''''''''
  circumference = 2 * Pi * AO
  Central_Angle = (Arc_AB / Circumference) * 360
  arc_ABD =  (central_angle / 180) * Pi * radius
  arc_ABR = central_angle*(Pi/180)
  x = (centerX + radius * SIN(-arc_ABR))
  y = (centerY + radius * COS(-arc_ABR))
  x1 = (centerX + radius * SIN( arc_ABR))
  y1 = (centerY + radius * COS( arc_ABR))
  ''''''''''''''''''''''''''''''''''''
  Chord_AB = 2*SIN ((pi/180)*(central_angle/2)) * radius
  AE = .5*Chord_ab
  oe = SQR( AO^2 - AE^2 )
  ED = AO - OE

  circle_area = Pi*radius^2
  arclen_AB =  Central_angle*(Pi/180) * radius
  Sector_area = (Central_angle/360)*Pi*radius^2
  Triangle_area = (.5*radius*radius)*SIN((central_angle*Pi)/180)
  Segment_area =Sector_area - Triangle_area

  TXT$ =  STR$(chord_ab)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX3, TXT$
  TXT$ =  STR$(ED)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX4, TXT$
  TXT$ =  STR$(central_angle)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX5, TXT$
  TXT$ =  STR$(OE)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX6, TXT$
  TXT$ =  STR$(circumference)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX7, TXT$
  TXT$ =  STR$(Segment_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX8, TXT$
  TXT$ =  STR$(Triangle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX9, TXT$
  TXT$ =  STR$(Sector_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX10, TXT$
  TXT$ =  STR$(circle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX11, TXT$
END FUNCTION
FUNCTION Calculate_Chord_AB_Segment_Height_ED() AS LONG
    AE=Chord_ab/2
    eb=chord_ab/2
    ce=(ae*eb)/ed
    radius = (CE+ED/2)
END FUNCTION
FUNCTION Calculate_Radius_OE() AS LONG
  AO = radius
  AE = SQR(AO^2 - OE^2)
  aoe = ATN(ae/oe)
  chord_ab = 2*AE
  ED = AO - OE
  central_angle = 2*(aoe*(180/pi))
  arc_ABD =  (central_angle / 180) * Pi * radius
  arc_ABR = central_angle*(Pi/180)
  x = (centerX + radius * SIN(-arc_ABR))
  y = (centerY + radius * COS(-arc_ABR))
  x1 = (centerX + radius * SIN( arc_ABR))
  y1 = (centerY + radius * COS( arc_ABR))
  AOE = SIN(Pi/180*(central_angle/2))
  circumference = 2 * Pi * AO
  circle_area = Pi*radius^2
  arclen_AB =  Central_angle*(Pi/180) * radius
  Sector_area = (Central_angle/360)*Pi*radius^2
  Triangle_area = (.5*radius*radius)*SIN((central_angle*Pi)/180)
  Segment_area =Sector_area - Triangle_area

  TXT$ =  STR$(chord_ab)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX3, TXT$
  TXT$ =  STR$(ED)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX4, TXT$
  TXT$ =  STR$(central_angle)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX5, TXT$
  TXT$ =  STR$(arclen_AB)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX6, TXT$
  TXT$ =  STR$(circumference)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX7, TXT$
  TXT$ =  STR$(Segment_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX8, TXT$
  TXT$ =  STR$(Triangle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX9, TXT$
  TXT$ =  STR$(Sector_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX10, TXT$
  TXT$ =  STR$(circle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX11, TXT$
END FUNCTION
FUNCTION Calculate_Radius_ED() AS LONG
  AO = radius
  oe = AO - ED
  AE = SQR(AO^2 - OE^2)
  aoe = ATN(ae/oe)
  chord_ab = 2*AE
  central_angle = 2*(aoe*(180/pi))
  arc_ABD =  (central_angle / 180) * Pi * radius
  arc_ABR = central_angle*(Pi/180)
  x = (centerX + radius * SIN(-arc_ABR))
  y = (centerY + radius * COS(-arc_ABR))
  x1 = (centerX + radius * SIN( arc_ABR))
  y1 = (centerY + radius * COS( arc_ABR))
  AOE = SIN(Pi/180*(central_angle/2))
  circumference = 2 * Pi * AO
  circle_area = Pi*radius^2
  arclen_AB =  Central_angle*(Pi/180) * radius
  Sector_area = (Central_angle/360)*Pi*radius^2
  Triangle_area = (.5*radius*radius)*SIN((central_angle*Pi)/180)
  Segment_area =Sector_area - Triangle_area

  TXT$ =  STR$(chord_ab)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX3, TXT$
  TXT$ =  STR$(OE)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX4, TXT$
  TXT$ =  STR$(central_angle)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX5, TXT$
  TXT$ =  STR$(arclen_AB)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX6, TXT$
  TXT$ =  STR$(circumference)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX7, TXT$
  TXT$ =  STR$(Segment_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX8, TXT$
  TXT$ =  STR$(Triangle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX9, TXT$
  TXT$ =  STR$(Sector_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX10, TXT$
  TXT$ =  STR$(circle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX11, TXT$

'  radius = Chord_AB/(2*AOE)
END FUNCTION
FUNCTION Calculate_Radius_Chord_AB() AS LONG
  ae = .5*chord_ab
  AO = radius
  oe = SQR( AO^2 - AE^2 )
  aoe = ATN(ae/oe)
  chord_AB = 2 * AOE * radius
  central_angle = 2*(aoe*(180/pi))
  arc_ABD =  (central_angle / 180) * Pi * radius
  arc_ABR = central_angle*(Pi/180)
  x = (centerX + radius * SIN(-arc_ABR))
  y = (centerY + radius * COS(-arc_ABR))
  x1 = (centerX + radius * SIN( arc_ABR))
  y1 = (centerY + radius * COS( arc_ABR))
  AOE = SIN(Pi/180*(central_angle/2))
  ED = AO - OE
  circumference = 2 * Pi * AO
  circle_area = Pi*radius^2
  arclen_AB =  Central_angle*(Pi/180) * radius
  Sector_area = (Central_angle/360)*Pi*radius^2
  Triangle_area = (.5*radius*radius)*SIN((central_angle*Pi)/180)
  Segment_area =Sector_area - Triangle_area

  TXT$ =  STR$(ED)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX3, TXT$
  TXT$ =  STR$(OE)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX4, TXT$
  TXT$ =  STR$(central_angle)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX5, TXT$
  TXT$ =  STR$(arclen_AB)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX6, TXT$
  TXT$ =  STR$(circumference)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX7, TXT$
  TXT$ =  STR$(Segment_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX8, TXT$
  TXT$ =  STR$(Triangle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX9, TXT$
  TXT$ =  STR$(Sector_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX10, TXT$
  TXT$ =  STR$(circle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX11, TXT$

'  radius = Chord_AB/(2*AOE)
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

  TXT$ =  STR$(chord_AB)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX3, TXT$
  TXT$ =  STR$(OE)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX4, TXT$
  TXT$ =  STR$(chord_AB)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX5, TXT$
  TXT$ =  STR$(arclen_AB)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX6, TXT$
  TXT$ =  STR$(circumference)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX7, TXT$
  TXT$ =  STR$(Segment_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX8, TXT$
  TXT$ =  STR$(Triangle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX9, TXT$
  TXT$ =  STR$(Sector_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX10, TXT$
  TXT$ =  STR$(circle_area)
  CONTROL SET TEXT hDlg, %IDC_EDITBOX11, TXT$

END FUNCTION
SUB DrawSystem (BYVAL hDlg AS DWORD, BYVAL ID AS LONG)
  LOCAL lResult AS LONG
  GRAPHIC CLEAR
  GRAPHIC WIDTH 3
  GRAPHIC ATTACH hDlg, ID, REDRAW        ' Use faster, buffered draw
  GRAPHIC COLOR %RGB_BLUE, %RGB_WHITE    ' Blue line, white background
  centerX = 0 ' or any value you like
  centerY = 0
  CONTROL GET CHECK hDlg, %OPT1 TO lResult&
  IF  lResult <> 0 THEN
    CALL  Calculate_Radis_Central_Angle()
  END IF
  CONTROL GET CHECK hDlg, %OPT2 TO lResult&
  IF  lResult <> 0 THEN
    CALL  Calculate_Radius_Chord_AB()
  END IF
  CONTROL GET CHECK hDlg, %OPT3 TO lResult&
  IF  lResult <> 0 THEN
    CALL  Calculate_Radius_ED()
  END IF
  CONTROL GET CHECK hDlg, %OPT4 TO lResult&
  IF  lResult <> 0 THEN
    CALL Calculate_Radius_OE()
  END IF
  CONTROL GET CHECK hDlg, %OPT5 TO lResult&
  IF  lResult <> 0 THEN
    CALL Calculate_Radius_Arc_AB()
  END IF
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
    LOCAL lResult AS LONG
    CONTROL GET CHECK hDlg, %OPT1 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        central_angle = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT2 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Chord_ab = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT3 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Ed = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT4 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        OE = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT5 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Arc_ab = VAL(TXT$)
    END IF


END FUNCTION
CALLBACK FUNCTION Calc_button()
     DrawSystem hDlg, %IDC_GRAPHIC1
END FUNCTION
CALLBACK FUNCTION Button_call()
    LOCAL lResult AS LONG
    CONTROL GET CHECK hDlg, %OPT1 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Radius"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
    CONTROL GET CHECK hDlg, %OPT2 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Radius"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
    CONTROL GET CHECK hDlg, %OPT3 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Radius"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
    CONTROL GET CHECK hDlg, %OPT4 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Radius"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
    CONTROL GET CHECK hDlg, %OPT5 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Radius"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = " ARC AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
    CONTROL GET CHECK hDlg, %OPT6 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Radius
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
    CONTROL GET CHECK hDlg, %OPT7 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Radius
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
    CONTROL GET CHECK hDlg, %OPT8 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Segment Height ED "
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Radius
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
    CONTROL GET CHECK hDlg, %OPT9 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Radius
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
END FUNCTION

FUNCTION BUILDWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    exeICON = "exeICON"
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, 0, "Atco Circles",,, w, h,%WS_OVERLAPPEDWINDOW , 0 TO hDlg
    ' Set up a pixel-based coordinate system in the Graphic control
    DIALOG SET ICON hDlg, exeICON$
    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 0, 0, 600, 600
    TXT$ = ""
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX1, "", 800, 150, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL1, TXT$, 700, 150, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX2, "", 800, 170, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL2, TXT$, 700, 170, 100, 20
    CONTROL ADD BUTTON, hDlg, %IDOK, "Calculate", 800, 190, 80, 20, _
     %WS_GROUP , , CALL Calc_button()
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX3, "", 700, 210, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL3, TXT$, 700, 210, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX4, "", 800, 230, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL4, TXT$, 700, 230, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX5, "", 800, 250, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL5, TXT$, 700, 250, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX6, "", 800, 270, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL6, TXT$, 700, 270, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX7, "", 800, 290, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL7, TXT$, 700, 290, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX8, "", 800, 310, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL8, TXT$, 700, 310, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX9, "", 800, 330, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL9, TXT$, 700, 330, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX10, "", 800, 350, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL10, TXT$, 700, 350, 100, 20
    CONTROL ADD TEXTBOX, hDlg, %IDC_EDITBOX11, "", 800, 370, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg, %IDC_LABEL11, TXT$, 700, 370, 100, 20
    CONTROL ADD OPTION, hDlg, %OPT1, "Radius and Central Angle", 800, 6, 180, 14, _
    %WS_GROUP OR %WS_TABSTOP, , CALL Button_call()
    CONTROL ADD OPTION, hDlg, %OPT2, "Radius & Chord AB", 800, 20, 180, 14 , _
     , , CALL Button_call()
    CONTROL ADD OPTION, hDlg, %OPT3, "Radius & Segment Height ED", 800, 34, 180, 14 , _
     , , CALL Button_call()
    CONTROL ADD OPTION, hDlg, %OPT4, "Radius & Apothem OE", 900, 48, 180, 14   , _
     , , CALL Button_call()
    CONTROL ADD OPTION, hDlg, %OPT5, "Radius & Arc AB", 900, 62, 180, 14  , _
     , , CALL Button_call()
    CONTROL ADD OPTION, hDlg, %OPT6, "Chord AB & Segment Height ED", 800, 76, 180, 14   , _
     , , CALL Button_call()
    CONTROL ADD OPTION, hDlg, %OPT7, "Chord AB & Apothem OE", 800, 90, 180, 14 , _
     , , CALL Button_call()
    CONTROL ADD OPTION, hDlg, %OPT8, "Segment Height ED & Apothem OE ", 800, 104, 180, 14  , _
     , , CALL Button_call()
    CONTROL ADD OPTION, hDlg, %OPT9, "Chord AB & Arc AB", 800, 118, 180, 14    , _
     , , CALL Button_call()

  ' Set the initial state to OPTION button 3
    CONTROL SET OPTION hDlg, %OPT1, %OPT1, %OPT9
    GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1, REDRAW
    GRAPHIC COLOR %RGB_BLUE, RGB(255,255,255)
    GRAPHIC CLEAR
    GRAPHIC REDRAW
    GRAPHIC SET FOCUS
    GRAPHIC SCALE (-299,-299)-(299,299)  'work with symmetric screen
    Pi = 4 * ATN(1)      ' Calculate Pi
    CONTROL GET CHECK hDlg, %OPT1 TO lResult&
    IF  lResult <> 0 THEN
        TXT$ = "Radius"
        CONTROL SET TEXT hDlg, %IDC_LABEL1, TXT$
        TXT$ = "Central Angle"
        CONTROL SET TEXT hDlg, %IDC_LABEL2, TXT$
        TXT$ = "Segment Height ED"
        CONTROL SET TEXT hDlg, %IDC_LABEL3, TXT$
        TXT$ = "Apothem OE"
        CONTROL SET TEXT hDlg, %IDC_LABEL4, TXT$
        TXT$ = "Chord AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL5, TXT$
        TXT$ = "Arc AB"
        CONTROL SET TEXT hDlg, %IDC_LABEL6, TXT$
        TXT$ = "Circumference"
        CONTROL SET TEXT hDlg, %IDC_LABEL7, TXT$
        TXT$ = "Segment Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL8, TXT$
        TXT$ = "Triangle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL9, TXT$
        TXT$ = "Sector Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL10, TXT$
        TXT$ = "Total Circle Area"
        CONTROL SET TEXT hDlg, %IDC_LABEL11, TXT$
    END IF
 END FUNCTION

' Program entry point
'
FUNCTION PBMAIN () AS LONG
    BUILDWINDOW()
    DIALOG SHOW MODAL hDlg, CALL DlgProc
END FUNCTION
