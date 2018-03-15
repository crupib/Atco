' -------------------------------------------------------------------------------------------
'                        Button Plugin (Type 3)
'                        This plugin is called when a
'                        a OwnerDraw Button is to be drawn.
'
'                        Plugins should be copied to plugins folder !
'                        Change Plugin file extension to .ezp (instead of .dll)
'
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

#INCLUDE "..\includes\ezgui50.inc"
#INCLUDE "drawbtn.inc"

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
    PType&=3        ' Button Plugin
    ' ---------------------------
    FUNCTION="EZGUI 3D Button-A"
END FUNCTION

SUB EZ_PLUGIN_DRAWBUTTON (BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL BGColor&, BYVAL FGColor&, BYVAL FontN&, BYVAL RType&) EXPORT
    ' ----------------------------------------
    ' This sub is called when a button is to be drawn.
    ' FormName$ is Buttons parent form name
    ' CID& is Buttons ID number
    ' CVal& is CVal& of %EZ_OwnerDraw event
    ' BGColor& is EZGUI background color number
    ' FGColor& is EZGUI foreground (text) color number
    ' FontN& is EZGUI Font number
    ' RType& is buttons region Type (0 - none, 1 - ellipse, -2 - Rounded Rectangle
    '    EZGUI generates the region code for you ! Just draw based on the region type.
    ' ----------------------------------------
    SELECT CASE RType&
        CASE 1
            DrawMyButtonE FormName$, CID&, CVal&, BGColor&, FGColor&, FontN&
        CASE -2
            DrawMyButtonRR FormName$, CID&, CVal&, BGColor&, FGColor&, FontN&
        CASE ELSE
            DrawMyButton FormName$, CID&, CVal&, BGColor&, FGColor&, FontN&
    END SELECT
END SUB

FUNCTION EZ_PLUGIN_DRAWCODE(BYVAL IData$, BYVAL Mode&, BYVAL RType&) EXPORT AS STRING
    LOCAL RV$, Q$, CRLF$, INC_Path$
    IF Mode&=0 THEN
        IF RIGHT$(IData$,1)<>"\" THEN IData$=IData$+"\"
        INC_Path$=IData$        '   IData$ passes path to Designer (mode=0)
                                '   Designer stores inc files in subfolder named   : includes
                                '   Designer stores plugin files in subfolder named: plugins
    END IF
    ' Mode&=0 if the code is the include statements after all other includes.
    ' Mode&=1 if the code is the actual draw code used in the Buttons %EZ_OwnerDraw event
    Q$=CHR$(34)
    CRLF$=CHR$(13)+CHR$(10)
    SELECT CASE Mode&
        CASE 0      ' return include code for drawing code
            RV$="#INCLUDE "+Q$+INC_Path$+"plugins\drawbtn.inc"+Q$+CRLF$
        CASE 1      ' return name of draw routine only (no CRLF or parameters)
                    ' EZGUI assumes the parameters for your drawing sub are:
                    ' BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL BGColor&, BYVAL FGColor&, BYVAL FontN&
                    ' which are identical to the EZGUI Button drawing commands
            SELECT CASE RType&
                CASE 1
                    RV$="DrawMyButtonE"
                CASE -2
                    RV$="DrawMyButtonRR"
                CASE ELSE
                    RV$="DrawMyButton"
            END SELECT
        CASE ELSE
    END SELECT
    FUNCTION=RV$
END FUNCTION
