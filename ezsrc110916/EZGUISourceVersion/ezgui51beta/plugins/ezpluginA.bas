' -------------------------------------------------------------------------------------------
'                        Control Alignment Plugin (Type 7)
'                        This plugin is called when a group of
'                   controls is selected and the plugins menu item is selected.
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
    PType&=7    ' 7 = Alignment plugin
    FUNCTION="Test Alignment"
END FUNCTION

FUNCTION EZ_PLUGIN_ALIGN(BYVAL CCount&, BYVAL ArrayPtr AS DWORD) EXPORT AS LONG
    ' --------------------------------------------------
    ' This function is called when a group of
    ' of controls is selected and the plugin is
    ' selected from Group menu
    ' CCount& passes the number of controls selected.
    ' ArrayPtr passes pointer to array with data in it.
    ' --------------------------------------------------
    ' DIM array using DIM AT syntax like this:
    ' DIM CSize!(0 TO CCount&,1 TO 5) AT ArrayPtr
    ' --------------------------------------------------
    ' Array holds following data (all Singles):
    ' Index zero (0) Form info
    ' Index 1 to CCount control info
    ' CSize!(0,1) = Character Unit Size (X) in Pixels
    ' CSize!(0,2) = Character Unit Size (Y) in Pixels
    ' CSize!(0,3) = Form Client Width (Character Units)
    ' CSize!(0,4) = Form Client Height (Character Units)
    ' CSize!(N&,1) = Controls Left Coordinate (Character Units)
    ' CSize!(N&,2) = Controls Top Coordinate (Character Units)
    ' CSize!(N&,3) = Controls Width (Character Units)
    ' CSize!(N&,4) = Controls Height (Character Units)
    ' CSize!(N&,5) = Controls ID
    ' --------------------------------------------------
    ' If you display a Form to allow input of data use
    ' the following:
    ' Parent Forms name must be "PARENT"
    ' You must use the EZ_FormEX command to create your
    ' popup Form and your popup Form should use the name:
    '       "MYFORM"
    ' Controls exist on a Form called "MAIN" so you can
    ' poll them for their class name if you wish.
    ' Do not though change any controls or even size them!
    ' The Designer will use the coordinates you return in
    ' array and will move/size the controls for you.
    ' --------------------------------------------------
    DIM CSize(0 TO CCount&,1 TO 5) AS SINGLE AT ArrayPtr

    FUNCTION=1
END FUNCTION
