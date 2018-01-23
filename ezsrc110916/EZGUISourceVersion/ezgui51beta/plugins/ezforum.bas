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
'            The code may be used ROYALTY FREE by registered EZGUI 5.0 users !
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
'                              EZGUI 5.0 PlugIn Calls
' -------------------------------------------------------------------------------------------

FUNCTION EZ_PLUGIN_INIT(PType&) EXPORT AS STRING
    ' ----------------------------------------
    ' This function is called once to Initialize
    ' the PlugIn. Return the PlugIn name.
    ' If NULL string returned, PlugIn fails to
    ' Initialize.
    ' ----------------------------------------
    PType&=1    ' 1= Code Plugin
    FUNCTION="EZGUI Forum Code Cleaner"
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
        CASE ELSE
    END SELECT

    LOCAL N&, MaxN&, NewSData$, T$, T2$, AFlag&, BFlag&, EFlag&
    NewSData$=          "' Portions: Copyright Christopher R. Boss, 2003 to 2011 , All Rights Reserved !"+CHR$(13)+CHR$(10)
    NewSData$=NewSData$+"' Registered EZGUI 5.0 users may use this code Royalty Free !"+CHR$(13)+CHR$(10)+CHR$(13)+CHR$(10)
    EFlag&=0
    REPLACE CHR$(13)+CHR$(10) WITH CHR$(1) IN SData$
    MaxN&=PARSECOUNT(SData$,CHR$(1))
    BFlag&=0
    FOR N&=1 TO MaxN&
        AFlag&=0
        T$=PARSE$(SData$,CHR$(1), N&)
        T2$=UCASE$(TRIM$(T$))
        SELECT CASE LEFT$(T2$,3)
            CASE "'<<"  ' EZGUI smart tags leave alone
                AFlag&=1
                BFlag&=0
            CASE "' =", "' ["    ' special title remarks, so leave alone
                AFlag&=1
                BFlag&=0
            CASE "", "'"
                IF BFlag&=0 THEN
                    BFlag&=1
                    AFlag&=1    ' allows one line of spacing max
                    T$="'"
                END IF
            CASE ELSE
                IF LEFT$(T2$,1)<>"'" THEN
                    IF EFlag&=0 THEN
                        IF LEFT$(T2$,8)="EZ_MAIN " THEN EFlag&=1
                    END IF
                    IF LEFT$(T2$,7)="EZ_REG " THEN
                        IF EFlag&=1 THEN
                            T$="EZ_Reg %EZ_CUSTID,%EZ_REGNUM"   ' change EZ_Reg command line
                            EFlag&=2
                        END IF
                    END IF
                    BFlag&=0
                    AFlag&=1
                END IF
        END SELECT
        IF AFlag& THEN
            NewSData$=NewSData$+T$+CHR$(13)+CHR$(10)
        END IF
    NEXT N&
    FUNCTION=NewSData$
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
