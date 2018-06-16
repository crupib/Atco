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
    FUNCTION="Group Alignment Dialog"
END FUNCTION

GLOBAL App_Mode&
GLOBAL App_Center&
GLOBAL App_Align&
GLOBAL App_Space&
GLOBAL App_SpaceVal!

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
    LOCAL N&, C!,R!,W!,H!
    App_Mode&=0
    App_Center&=0
    App_Align&=0
    App_Space&=0
    App_SpaceVal!=0
    EZ_MYFORM_Display "PARENT"


    IF App_Mode&<>0 THEN
         IF App_Center& THEN
              IF App_Mode&=1 OR App_Mode&=3 THEN
                   ' space vertically so center horizontally
                    C!=(CSize(0,3)-CSize(1,3))/2
                    CSize(1,1)=C!
              END IF
              IF App_Mode&=2 THEN
                   ' space horizontally so center vertically
                    R!=(CSize(0,4)-CSize(1,4))/2
                    CSize(1,2)=R!
              END IF
         END IF
         SELECT CASE App_Mode&
               CASE 1     ' space vert
                    IF App_Space& THEN   ' space by fixed value
                         IF CSize(0,2)<>0 THEN
                              App_SpaceVal!=App_SpaceVal!/CSize(0,2)
                         ELSE
                              App_SpaceVal!=0
                         END IF
                         FOR N&=2 TO CCount&
                              CSize(N&,2)=CSize(N&-1,2)+CSize(N&-1,4)+App_SpaceVal!
                         NEXT N&
                    ELSE
                         H!=CSize(CCount&,2)-(CSize(1,2)+CSize(1,4))
                         FOR N&=2 TO (CCount&-1)
                              H!=H!-CSize(N&,4)
                         NEXT N&
                         H!=H!/(CCount&-1)
                         IF H!<0 THEN H!=0
                         FOR N&=2 TO CCount&
                              CSize(N&,2)=CSize(N&-1,2)+CSize(N&-1,4)+H!
                         NEXT N&
                    END IF
               CASE 2     ' space horz
                    IF App_Space& THEN   ' space by fixed value
                         IF CSize(0,1)<>0 THEN
                              App_SpaceVal!=App_SpaceVal!/CSize(0,1)
                         ELSE
                              App_SpaceVal!=0
                         END IF
                         FOR N&=2 TO CCount&
                              CSize(N&,1)=CSize(N&-1,1)+CSize(N&-1,3)+App_SpaceVal!
                         NEXT N&
                    ELSE
                         W!=CSize(CCount&,1)-(CSize(1,1)+CSize(1,3))
                         FOR N&=2 TO (CCount&-1)
                              W!=W!-CSize(N&,3)
                         NEXT N&
                         W!=W!/(CCount&-1)
                         IF W!<0 THEN W!=0
                         FOR N&=2 TO CCount&
                              CSize(N&,1)=CSize(N&-1,1)+CSize(N&-1,3)+W!
                         NEXT N&
                    END IF
               CASE 3     ' no space, only align
         END SELECT
         SELECT CASE App_Align&
              CASE 1     ' align top/left
                    IF App_Mode&=1 OR App_Mode&=3 THEN ' left (vertical)
                         FOR N&=2 TO CCount&
                              CSize(N&,1)=CSize(1,1)
                         NEXT N&
                    END IF
                    IF App_Mode&=2 THEN ' top (horizontal)
                         FOR N&=2 TO CCount&
                              CSize(N&,2)=CSize(1,2)
                         NEXT N&
                    END IF
              CASE 2     ' align center
                    IF App_Mode&=1 OR App_Mode&=3 THEN ' center (vertical)
                         C!=CSize(1,1)+(CSize(1,3)/2)
                         FOR N&=2 TO CCount&
                              CSize(N&,1)=C!-(CSize(N&,3)/2)
                         NEXT N&
                    END IF
                    IF App_Mode&=2 THEN ' center (horizontal)
                         R!=CSize(1,2)+(CSize(1,4)/2)
                         FOR N&=2 TO CCount&
                              CSize(N&,2)=R!-(CSize(N&,4)/2)
                         NEXT N&
                    END IF
              CASE ELSE
         END SELECT
    END IF
    FUNCTION=1
END FUNCTION

#INCLUDE "..\includes\ezgui50.inc"                          ' EZGUI Include file for Declares

SUB EZ_MYFORM_Display(BYVAL FParent$)     ' (PROTECTED)
     EZ_Color 0, 25
     EZ_FormEx "MYFORM", FParent$, "Align Controls (Plugin)", 0, 0, 51, 16, "CMR", CODEPTR(EZ_MYFORM_Design), CODEPTR(EZ_MYFORM_ParseEvents)
END SUB

SUB EZ_MYFORM_Design()     ' (PROTECTED)
     LOCAL CText$
     EZ_Color 0, 25
     EZ_UseFont 4
     EZ_Radio 101, 15.125, 1.0625, 18.875, 1.5625, "Space Controls Vertically", "GT"
     EZ_SetCheck "{ME}",101, 1
     ' -----------------------------------------------
     EZ_Color 0, 25
     EZ_UseFont 4
     EZ_Radio 102, 15.125, 2.875, 18.875, 1.5625, "Space Controls Horizontally", "T"
     ' -----------------------------------------------
     EZ_Color 0, 25
     EZ_UseFont 4
     EZ_Radio 103, 15.125, 4.6875, 18.25, 1.5625, "Align Controls Vertically", "T"
     ' -----------------------------------------------
     EZ_Color 0, 25
     EZ_UseFont 4
     EZ_CheckBox 201, 10.875, 6.9375, 27.25, 1.1875, "Center First Control to Form when Spacing", "GT"
     ' -----------------------------------------------
     EZ_Color 0, 25
     EZ_UseFont 4
     EZ_CheckBox 202, 10.875, 8.5, 27.5, 1.1875, "Align Left or Top of Controls to First", "T"
     ' -----------------------------------------------
     EZ_Color 0, 25
     EZ_UseFont 4
     EZ_CheckBox 203, 10.875, 10.0625, 27.25, 1.1875, "Align Controls to Center of First Control", "T"
     ' -----------------------------------------------
     EZ_Color 0, 25
     EZ_UseFont 4
     EZ_CheckBox 204, 10.875, 11.625, 23, 1.1875, "Space Controls using Fixed value", "T"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_Text 300, 34.125, 11.6875, 9, 1.25, "", "EST"
     EZ_Color 0, 25
     EZ_Label 301, 44,11.6875, 6,1.25,"Pixels","^L"
     ' -----------------------------------------------
     EZ_Color 0,25
     EZ_UseFont 4
     EZ_Button 500, 1, 13.5, 49, 2, "Apply", "T"
     ' -----------------------------------------------
END SUB


SUB EZ_MYFORM_ParseEvents(CID&, CMsg&, CVal&, Cancel&)     ' (PROTECTED)
     SELECT CASE CID&
          CASE %EZ_Window
               MYFORM_Events CID&, CMsg&, CVal&, Cancel&
          CASE 500
               IF CMsg&=%EZ_Click THEN   ' apply
                    IF EZ_GetCheck("{ME}",101)=1 THEN App_Mode&=1
                    IF EZ_GetCheck("{ME}",102)=1 THEN App_Mode&=2
                    IF EZ_GetCheck("{ME}",103)=1 THEN App_Mode&=3
                    IF EZ_GetCheck("{ME}",201)=1 THEN App_Center&=1
                    IF EZ_GetCheck("{ME}",202)=1 THEN
                         App_Align&=1
                    ELSE
                         IF EZ_GetCheck("{ME}",203)=1 THEN App_Align&=2
                    END IF
                    IF EZ_GetCheck("{ME}",204)=1 THEN
                         App_Space&=1
                         App_SpaceVal!=VAL(TRIM$(EZ_GetText("{ME}",300)))
                    END IF
                    EZ_UnloadForm "{ME}"
               END IF
          CASE ELSE
               MYFORM_Events CID&, CMsg&, CVal&, Cancel&
     END SELECT
END SUB

SUB MYFORM_Events(CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE CID&
          CASE %EZ_Window
               SELECT CASE CMsg&
                    CASE %EZ_Loading
                    CASE %EZ_Loaded
                    CASE %EZ_Started
                    CASE %EZ_Close
                    CASE ELSE
               END SELECT
          CASE ELSE
     END SELECT
END SUB
