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
' GUISetXPos validXPOS&                           (sets X POS)
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
     DO                                                  'Kevins MAIN
          GUIGetUserInput CID&, CMsg&, CVal&
          IF CID&<>%GUINoInput THEN
               SELECT CASE CID&
                    CASE 0
                         IF CMsg&=%EZ_Close THEN
                              GUISetClose
                              EXIT LOOP
                         END IF
                    CASE 105
                          GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string
                          GUISetXPOS 20
                    CASE ELSE
                         GUIPrintStatus "Control ID: "+STR$(CID&)+"  Control Message: "+STR$(CMsg&)+"  Value: "+STR$(CVal&)+" " + bc_string
                         GUISetXMotor 0
               END SELECT
          END IF                                       'Kevins MAIN
     LOOP
     FUNCTION=0
END FUNCTION

FUNCTION mystring(BYVAL bc_string$) AS STRING
    mystring = "Kevin"
END FUNCTION
