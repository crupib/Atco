' -------------------------------------------------------------------------------------------
'                        Code Parsing Plugin (Type 1)
'                        This plugin is called when code
'                        is generated.
'
'                        Plugins should be copied to plugins folder !
'                        Change Plugin file extension to .ezp (instead of .dll)
' -------------------------------------------------------------------------------------------
' -------------------------------------------------------------------------------------------
'                        Copyright Christopher R. Boss, 2011
'                               Alls Rights Reserved
'               The code may be used ROYALTY FREE by registered EZGUI 5.0 users !
' -------------------------------------------------------------------------------------------

#DIM ALL
#DEBUG ERROR OFF
                            ' Plugin can have any name, but must hav extension.ezp
#COMPILE DLL                ' once compiled change .DLL extension to .EZP

GLOBAL DLL_Instance&

' -------------------------------------------------------------------------------------------
'                              DLL Entrance - LibMain
' -------------------------------------------------------------------------------------------

FUNCTION LIBMAIN(BYVAL hInst   AS LONG, _
                 BYVAL RFlag   AS LONG, _
                 BYVAL lpR     AS LONG) AS LONG
    SELECT CASE RFlag
        CASE 1      ' (Where DLL starts)
            DLL_Instance&=hInst
        CASE 0      ' (Where DLL exits)
        CASE ELSE
    END SELECT
    LIBMAIN=1
END FUNCTION

' -------------------------------------------------------------------------------------------
'                              EZGUI 3.5 PlugIn Calls
' -------------------------------------------------------------------------------------------

FUNCTION EZ_PLUGIN_INIT(PType&) EXPORT AS STRING
    ' ----------------------------------------
    ' This function is called once to Initialize
    ' the PlugIn. Return the PlugIn name.
    ' If NULL string returned, PlugIn fails to
    ' Initialize.
    ' ----------------------------------------
    PType&=1    ' 1= Code Plugin
    FUNCTION="EZGUI Test PlugIn"
END FUNCTION

%EZPM_ControlsOnly     =   0
%EZPM_SingleForm       =   1
%EZPM_MultiForm        =   2

FUNCTION EZ_PLUGIN_START(BYVAL Mode&) EXPORT AS LONG
    ' ----------------------------------------
    ' This function is called first before any
    ' code is passed to PlugIn.
    ' ----------------------------------------
    SELECT CASE Mode&
        CASE %EZPM_ControlsOnly     ' Only select controls generated
        CASE %EZPM_SingleForm       ' Entire Form is generated
        CASE %EZPM_MultiForm        ' Multiple Forms are generated
        CASE ELSE
    END SELECT
    FUNCTION=1
END FUNCTION

%EZPT_All           =   0
%EZPT_Declares      =   1
%EZPT_Globals       =   2
%EZPT_Main          =   3
%EZPT_Design        =   4
%EZPT_Events        =   5
%EZPT_Subs          =   6

FUNCTION EZ_PLUGIN_SEND(BYVAL SData$, BYVAL SType&) EXPORT AS STRING
    ' ----------------------------------------
    ' This function is called when the generated
    ' code strings are passed for parsing.
    ' ----------------------------------------
    SELECT CASE SType&
        CASE %EZPT_All          ' All Code Plus Skeleton
        CASE %EZPT_Declares     ' Declare Code only
        CASE %EZPT_Globals      ' Globals Code only
        CASE %EZPT_Main         ' EZ_Main Code only
        CASE %EZPT_Design       ' EZ_DesignWindow Code only
        CASE %EZPT_Events       ' EZ_Events Code only
        CASE %EZPT_Subs         ' Subs Code only
        CASE ELSE
    END SELECT

    ' --------------------------------------------------------------
    ' This is where you modify the source code passed from
    ' Designer to your plugin. The original source code is
    ' passed in the SData$ parameter and the modified code
    ' is return via this function.
    ' --------------------------------------------------------------
    SData$=UCASE$(SData$)   ' Example of modifying code. Put your own code here !
    ' --------------------------------------------------------------
    FUNCTION=SData$
END FUNCTION

%EZPD_Normal        =   1   '   Process Normally and Display Floating ToolBar
%EZPD_NoToolBar     =   2   '   Don't Display Floating ToolBar
%EZPD_NoToolBarClip =   3   '   Don't Displat Floating Toolbar, but Copy to ClipBoard

FUNCTION EZ_PLUGIN_DONE() EXPORT AS LONG
    ' ----------------------------------------
    ' This function is called last so PlugIn
    ' can tell Designer what to do next.
    ' ----------------------------------------
    FUNCTION=%EZPD_Normal
END FUNCTION
