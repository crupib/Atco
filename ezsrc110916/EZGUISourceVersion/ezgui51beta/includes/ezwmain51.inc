' *************************************************************************************
'                    Copyright Christopher R. Boss 1999 to 2009
'                                   All Rights reserved !
'                Licensed users of EZGUI 5.0 may use this code Royalty Free
' *************************************************************************************


'    Note:     Do NOT change the names of the subroutines that are predefined here !
' *************************************************************************************
'            PBV Program Entrance and Main Window/Dialog Procedures in DLL Library
' *************************************************************************************

    ' ----------------------------------------------------------------------
DECLARE FUNCTION EZ_GuiRun LIB "ezgui51.dll" (BYVAL appInstance AS LONG,_
                                              BYVAL hPrevInstance AS LONG, _
                                              BYVAL lpszCmdLine AS ASCIIZ PTR,_
                                              BYVAL iCmdShow AS LONG, _
                                              BYVAL CB1 AS DWORD, _
                                              BYVAL CB2 AS DWORD, _
                                              BYVAL CB3 AS DWORD, _
                                              BYVAL GUIStyle AS DWORD) AS LONG
    ' ----------------------------------------------------------------------

FUNCTION WINMAIN (BYVAL appInstance AS LONG, BYVAL hPrevInstance AS LONG, BYVAL lpszCmdLine AS ASCIIZ PTR, BYVAL iCmdShow AS LONG) AS LONG
     LOCAL MX AS EZGUIMAX, STARTUPCODE AS DWORD
     STARTUPCODE=0
     #IF %DEF(%EZGUI_MaxColors)
         #IF %DEF(%EZGUI_MaxFonts)
             #IF %DEF(%EZGUI_MaxImages)
                 #IF %DEF(%EZGUI_MaxControls)
                     #IF %DEF(%EZGUI_MaxForms)
                         #IF %DEF(%EZGUI_MaxMenus)
                             MX.MaxColors=%EZGUI_MaxColors
                             MX.MaxFonts=%EZGUI_MaxFonts
                             MX.MaxImages=%EZGUI_MaxImages
                             MX.MaxControls=%EZGUI_MaxControls
                             MX.MaxForms=%EZGUI_MaxForms
                             MX.MaxMenus=%EZGUI_MaxMenus
                             STARTUPCODE=VARPTR(MX)
                         #ENDIF
                     #ENDIF
                 #ENDIF
             #ENDIF
         #ENDIF
     #ENDIF
     FUNCTION=EZ_GuiRun(appInstance, hPrevInstance, BYVAL lpszCmdLine, iCmdShow, CODEPTR(EZ_Main), CODEPTR(EZ_Events), CODEPTR(EZ_DesignWindow), STARTUPCODE)
END FUNCTION
' *************************************************************************************
