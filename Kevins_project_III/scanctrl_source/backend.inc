UNION MyData
     Q AS QUAD
     D AS DOUBLE
     S AS STRING*8
     OF AS ASCIIZ*1024
END UNION

TYPE GUIEvent
     MyID AS LONG
     MyText AS ASCIIZ*1024
     MyParam1 AS MyData
     MyParam2 AS MyData
     MyParam3 AS MyData
     MyParam4 AS MyData
END TYPE

%EZ_TalkToGUI  = %EZ_UserEvent + 1

SUB SendEvent(EID AS LONG, EText AS STRING, EParam1 AS MyData, EParam2 AS MyData, EParam3 AS MyData, EParam4 AS MyData)
     LOCAL E AS GUIEvent
     E.MyID = EID
     E.MyText = EText
     E.MyParam1 = EParam1
     E.MyParam2 = EParam2
     E.MyParam3 = EParam3
     E.MyParam4 = EParam4
     EZ_SendEvent "MAIN", 0, %EZ_TalkToGUI, VARPTR(E)
     EID = E.MyID
     EText = E.MyText
     EParam1 = E.MyParam1
     EParam2 = E.MyParam2
     EParam3 = E.MyParam3
     EParam4 = E.MyParam4
END SUB

' ----------------------------------
'           Task ID List
' ----------------------------------
%TA_GetXYRMotorDefaults            = 1  ' return X,Y and R Motor State Default values in Par1,Par2,Par3 using Quad values
%TA_GetXYRPosDefaults              = 2  ' return X,Y and R Position Default values in Par1, Par2, Par3 using Doubles
%OPEN_FILE_NAME                    = 3
%SAVE_FILE_NAME                    = 4
%SET_XPOS_SET                      = 5
' ----------------------------------
SUB ProcessInput(BYVAL TaskID AS LONG, Par1 AS MyData, Par2 AS MyData, Par3 AS MyData, Par4 AS MyData, SPar AS STRING, ErrFlag AS LONG)
     LOCAL F AS STRING
     LOCAL EText$, RV$
     ' TaskID are ID numbers for any Tasks the GUI needs to pass on to backend
     ' ie. of using parameter which is MyData (UNION)
     '    Par1.Q is a Quad Integer value
     '    Par1.D is a Double floating point value
     '    Par1.S is an 8 byte fixed length string
     SELECT CASE TaskID
          CASE %TA_GetXYRMotorDefaults
               Par1.Q = 0
               Par2.Q = 0
               Par3.Q = 0
               ErrFlag&=0
          CASE %TA_GetXYRPosDefaults
               Par1.D = 0.999#
               Par2.D = 0.999#
               Par3.D = 0.999#
               ErrFlag&=0
          CASE %OPEN_FILE_NAME
               F$=EZ_OpenFile("MAIN","Select any file you want:","",_
               "Cal (*.cal))|*.cal|All Files (*.*)|*.*|",_
               "PRZ")
               ErrFlag = 0
               Par1.OF = F$
           CASE %SAVE_FILE_NAME
               F$ = EZ_SaveFile("MAIN","Save your file", "", _
                                     "mycalfile.cal", _
                                     "Cal*.cal|All Files|*.*|", _
                                     "cal", "PNS")
               ErrFlag = 0
               Par1.OF = F$
          CASE %SET_XPOS_SET
              EText$=EZ_GetText("MAIN", %MAIN_TEXTXPOS)
              RV$=ShowInputBox("Set CRUX Position", "Enter New X Position",EText$, 1)
              IF RV$<>EText$ THEN
                   EZ_SetText "MAIN", %MAIN_TEXTXPOS, RV$
              END IF
          CASE ELSE
     END SELECT
END SUB
