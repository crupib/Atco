TYPE GUIEvent
     MyID AS LONG
     MyText AS ASCIIZ*256
     MyParam1 AS DOUBLE
     MyParam2 AS DOUBLE
     MyParam3 AS DOUBLE
     MyParam4 AS DOUBLE
END TYPE

%EZ_TalkToGUI  = %EZ_UserEvent + 1

SUB SendEvent(EID AS LONG, EText AS STRING, EParam1 AS DOUBLE, EParam2 AS DOUBLE, EParam3 AS DOUBLE, EParam4 AS DOUBLE)
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

' This is where GUI code will call Kevins code to request some action
SUB ProcessInput(BYVAL TaskID AS LONG, Param1 AS DOUBLE, Param2 AS DOUBLE, Param3 AS DOUBLE, Param4 AS DOUBLE)
     ' TaskID are ID numbers for any Tasks the GUI needs to pass on to backend
     ' you define them
     SELECT CASE %BC_MY_TEST
              EZ_MsgBox  ( "MAIN",  "Test",  "Test",  "YN" )
              SendEvent(%BC_MY_TEST,"Back",0.0,0.0,0.0,0.0)
          CASE ELSE
     END SELECT
END SUB
