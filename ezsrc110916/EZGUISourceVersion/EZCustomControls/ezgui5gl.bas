#DIM ALL
#DEBUG ERROR OFF    ' change to ON if GPF's to test for array out of bounds
#COMPILE DLL "ezgui5gl.dll"

' #INCLUDE "C:\Pbdll60\winapi\win32api.inc"
#INCLUDE "glwinclean.inc"
#INCLUDE "ez_glu.inc"
#RESOURCE ".\glrcdata\ezgltex.pbr"

%MaxInitObjects     = 1000
%MaxInitMaterials   = 1000
%MaxInitPalettes    = 1000
%MaxStringData      = 64000     ' maximum length of string allowed for EZ_SetText calls to control


TYPE EZObjHeader    ' must be 84 bytes total!
    OType AS INTEGER     ' 2 bytes  ( = 7 if STL Enhanced, = 8 if EZGUI Optimized)
    Count1 AS INTEGER    ' 2 bytes  ( = count if less than 32000, = -1 if > 32000
    Count2 AS LONG       ' 4 bytes  ( actual count if first one is -1)
    ScaleX AS SINGLE     ' 4 bytes
    ScaleY AS SINGLE     ' 4 bytes
    ScaleZ AS SINGLE     ' 4 bytes
    ColorFlag AS SINGLE  ' 4 bytes
    dummy AS STRING*42   ' 42 bytes
    Version AS LONG      ' 4 bytes
    WhoAmI AS STRING*10  ' has the text: "EZGUIModel"  (you can use any name you prefer, but EZGUI requires this name)
    STLSize AS DWORD     ' 4 bytes  (STL Header polygon count)
END TYPE

$OPENGLCLASS        =   "EZGLCANVAS32"

' ------------------------------------
'  Property Index List:
' ------------------------------------
' 1 - Window DC for OpenGL drawing
' 2 - OpenGL Resource Context for window
' 3 - Memory DC for handling Canvas Bitmap
' 4 - Bitmap handle to Canvas front buffer
' 5 - Pointer to Canvas Bitmap DIB bits
' 6 - Old Bitmap handle to Memory DC (1x1 mono)
' 7 - Width of client area and bitmaps in pixels
' 8 - Height of client area and bitmaps in pixels
' 9 - GLMode 1= double buffer, 0= front buffer only
' 10 - Background Draw Mode (0) - use GL color, (1) - update and use copy of Canvas Bitmap, (2) - use GL copy of Canvas Bitmap only
' 11 - Background RGB color to clear with when no Canvas Bitmap copy used
' 12 - Callback address for OpenGL customizing routines  (all routines use one callback now)
' 13 - Background Bitmap Cutoff value (0% to 95%)
' 14 - Brightness Factor  (value is divided by 100 to get a percentage)
' 15 - Zoom X factor (1 to 100)
' 16 - Zoom Y factor (1 to 100)
' 17 - Accumulation Buffer available flag (1 = available)
' 18 - Store Current Scene Object string
' 19 - Perspective distance value (0 to 180)
' 20 - Light Y Degrees (0 to 360)
' 21 - Light X Degree (0 to 90)
' 22 - Light Distance (0 to 100+)
' 23 - Light Ambient Level (0 to 100)
' 24 - Light Diffuse Level (0 to 100)
' 25 - Light#2 ON/OFF
' 26 - Light#2 Y Degrees (0 to 360)
' 27 - Light#2 X Degree (0 to 90)
' 28 - Light#2 Distance (0 to 100+)
' 29 - Light#2 Ambient Level (0 to 100)
' 30 - Light#2 Diffuse Level (0 to 100)
' 31 - Store Last Info String
' 32 - Store Flags for Quality settings (bit flags)


%PROP_COLOR         =  11
' 12    callback 1
%PROP_BGCUTOFF      =  13
%PROP_BRIGHT        =  14
%PROP_ZOOMX         =  15
%PROP_ZOOMY         =  16
' 17 accum BFlag
' 18 scene string data
%PROP_PERSP         =  19
%PROP_LIGHTY        =  20
%PROP_LIGHTX        =  21
%PROP_LIGHTZ        =  22
%PROP_LIGHTA        =  23   ' ambient
%PROP_LIGHTD        =  24   ' diffuse
%PROP_LIGHT2        =  25   ' is light 2 on or off
%PROP_LIGHT2Y       =  26
%PROP_LIGHT2X       =  27
%PROP_LIGHT2Z       =  28
%PROP_LIGHT2A       =  29   ' ambient
%PROP_LIGHT2D       =  30   ' diffuse
%PROP_INFOSTR       =  31   ' last info string
%PROP_QUALITY       =  32   ' Hint quality flags

%EZGL_SETBGMODE     =   %WM_USER+500
%EZGL_GETBGMODE     =   %WM_USER+501
%EZGL_DRAWNOW       =   %WM_USER+502
%EZGL_SETCALLBACKS  =   %WM_USER+504


' ------------------------------------
'%EZCVS_DIBSECTION    =   8      ' style for DIB section
'%EZCVS_DOUBLEBUFFER  =   16
'%EZCVS_16BIT         =   2
'%EZCVS_24BIT         =   4
'%EZCVS_32BIT         =   6



     DECLARE SUB EZ_SuperClass LIB "ezgui50.dll" (BYVAL NewClass$, BYVAL UseClass$, BYVAL CP AS DWORD)
     DECLARE FUNCTION EZ_GetSuperAddress LIB "ezgui50.dll" () AS DWORD
     DECLARE FUNCTION EZ_CallSuperProc LIB "ezgui50.dll" (BYVAL CP AS DWORD, BYVAL hWnd AS LONG, BYVAL Msg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
     DECLARE SUB EZ_SetSuperClassProp LIB "ezgui50.dll" (BYVAL hWnd&, BYVAL N&, BYVAL V&)
     DECLARE FUNCTION EZ_GetSuperClassProp LIB "ezgui50.dll" (BYVAL hWnd&, BYVAL N&) AS LONG
     DECLARE SUB EZ_InitSuperClassProps LIB "ezgui50.dll" (BYVAL hWnd&)
     DECLARE SUB EZ_FreeSuperClassProps LIB "ezgui50.dll" (BYVAL hWnd&)
     DECLARE SUB EZ_SetSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&, BYVAL D$)
     DECLARE FUNCTION EZ_GetSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&) AS STRING
     DECLARE SUB EZ_FreeSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&)
     DECLARE SUB EZ_LockSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&, lpAddress AS DWORD, SLen&)
     DECLARE SUB EZ_UnlockSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&)
     DECLARE FUNCTION EZGL_GetSpriteBitmap LIB "ezgui50.dll" (BYVAL I&) AS LONG

DECLARE SUB InitObjectList(BYVAL MaxN&)
DECLARE SUB FreeObjectList()
DECLARE SUB AddCoreObjects()
DECLARE SUB InitMaterials(BYVAL MaxN&)
DECLARE SUB FreeMaterials()
DECLARE SUB AddCoreMaterials()
DECLARE SUB InitDefBitmaps()
DECLARE SUB FreeDefBitmaps()
DECLARE SUB GenNormals(BYVAL P AS SINGLE PTR, BYVAL N AS SINGLE PTR)
DECLARE SUB SetInfoString(BYVAL hWnd AS LONG, BYVAL T$)
DECLARE FUNCTION GetInfoString(BYVAL hWnd AS LONG) AS STRING
DECLARE SUB Optimize3DObject(BYVAL QName AS QUAD)

GLOBAL DLL_Instance&
GLOBAL App_ReturnValue&
GLOBAL App_EndCoreObjects&

DECLARE SUB RegisterOpenGLClass()

DECLARE SUB TE(BYVAL I&)
DECLARE SUB TA(BYVAL T$)

GLOBAL App_GLVendor$
GLOBAL App_GLRenderer$
GLOBAL App_GLVersion$
GLOBAL App_GLExtensions$

FUNCTION LIBMAIN(BYVAL hInstance   AS LONG, _
                 BYVAL fwdReason   AS LONG, _
                 BYVAL lpvReserved AS LONG) EXPORT AS LONG
    SELECT CASE AS LONG fwdReason
        CASE %DLL_PROCESS_ATTACH    ' =1 - Where DLL starts
            DLL_Instance&=hInstance
        CASE %DLL_THREAD_ATTACH
        CASE %DLL_THREAD_DETACH
        CASE %DLL_PROCESS_DETACH    ' =0 - Where DLL exits
        CASE ELSE
    END SELECT
    LIBMAIN=1
END FUNCTION

' calling these routines from LIBMAIN makes OpenGL and EZGUI unstable!


SUB InitGLClass() EXPORT
    RegisterOpenGLClass
    InitObjectList %MaxInitObjects
    InitMaterials  %MaxInitMaterials
    InitDefBitmaps
    AddCoreObjects
    AddCoreMaterials
END SUB

SUB FreeGLClass()EXPORT
    FreeObjectList
    FreeMaterials
    FreeDefBitmaps
END SUB


SUB RegisterOpenGLClass()
    ' class Macro @CVS forces Canvas class to use the %CS_OWNDC class style required by OpenGL
    EZ_SuperClass $OPENGLCLASS, "@CVS", CODEPTR(OpenGLClassWndProc)
END SUB

'SUB CalcPoint (BYVAL AX!,BYVAL AY!,BYVAL AL!,BYVAL ADG&,RX!,RY!)
'    LOCAL X#, Y#, R#, MFV&, DG&, X1#, Y1#, DG1#
'    ' X#=Center Horizontal Position
'    ' Y#=Center Vertical Position
'    ' R#=Radius of Circle in Pixels
'    ' DM&=Number of degrees to move for next position
'    X#=AX!
'    Y#=AY!
'    R#=AL! ' radius equals line length
'    MFV&=ADG&
'    IF MFV&<0 THEN MFV&=0
'    IF MFV&>360 THEN MFV&=MFV&-360
'    IF MFV&=0 THEN MFV&=360
'    SELECT CASE MFV&
'       CASE 1 TO 89
'          X1#=1
'          Y1#=-1
'          DG&=90-MFV&
'       CASE 90
'          X1#=R#
'          Y1#=0
'          DG&=0
'       CASE 91 TO 179
'          X1#=1
'          Y1#=1
'          DG&=MFV&-90
'       CASE 180
'          X1#=0
'          Y1#=R#
'          DG&=0
'       CASE 181 TO 269
'          X1#=-1
'          Y1#=1
'          DG&=270-MFV&
'       CASE 270
'          X1#=-R#
'          Y1#=0
'          DG&=0
'       CASE 271 TO 359
'          X1#=-1
'          Y1#=-1
'          DG&=MFV&-270
'       CASE ELSE
'          X1#=0
'          Y1#=-R#
'          DG&=0
'    END SELECT
'    IF DG&<>0 THEN
'       DG1#=DG&
'       DG1#=DG1#*.01745333
'       X1#=X1#*INT(COS(DG1#)*R#)
'       Y1#=Y1#*INT(SIN(DG1#)*R#)
'    END IF
'    X1#=X#+X1#
'    Y1#=Y#+Y1#
'    RX!=INT(X1#)
'    RY!=INT(Y1#)
'END SUB


SUB CalcPointF (BYVAL AX!,BYVAL AY!,BYVAL AL!,BYVAL ADG!,RX!,RY!)
    LOCAL X#, Y#, R#, MFV#, DG#, X1#, Y1#, DG1#, MFI&
    ' X#=Center Horizontal Position
    ' Y#=Center Vertical Position
    ' R#=Radius of Circle in Pixels
    ' DM&=Number of degrees to move for next position
    X#=AX!
    Y#=AY!
    R#=AL! ' radius equals line length
    MFV#=ADG!
    DO
        IF MFV#>=0 THEN EXIT LOOP
        IF MFV#<0 THEN MFV#=MFV#+360
    LOOP
    DO
        IF MFV#<=360 THEN EXIT LOOP
        MFV#=MFV#-360
    LOOP
    IF MFV#=0 THEN MFV#=360
    MFI&=INT(MFV#*1000) ' speeds up test by using Longs (accurate up to 1000th of a degree)
    SELECT CASE AS LONG MFI&
       CASE 90000   ' 90.000
          X1#=R#
          Y1#=0
          DG#=0
       CASE 180000  ' 180.000
          X1#=0
          Y1#=R#
          DG#=0
       CASE 270000  ' 270.000
          X1#=-R#
          Y1#=0
          DG#=0
       CASE 360000  ' 360.000
          X1#=0
          Y1#=-R#
          DG#=0
       CASE ELSE
           IF MFI&<90000 THEN
              ' 1 TO 89
              X1#=1
              Y1#=-1
              DG#=90-MFV#
           ELSEIF MFI&<180000 THEN
              ' 91 TO 179
              X1#=1
              Y1#=1
              DG#=MFV#-90
           ELSEIF MFI&<270000 THEN
              ' 181 TO 269
              X1#=-1
              Y1#=1
              DG#=270-MFV#
           ELSEIF MFI&<360000 THEN
              ' 271 TO 359
              X1#=-1
              Y1#=-1
              DG#=MFV#-270
           END IF
    END SELECT
'    SELECT CASE MFV#
'    END SELECT
    IF DG#<>0 THEN
       DG1#=DG#
       DG1#=DG1#*.01745333
       X1#=X1#*INT(COS(DG1#)*R#)
       Y1#=Y1#*INT(SIN(DG1#)*R#)
    END IF
    X1#=X#+X1#
    Y1#=Y#+Y1#
    RX!=INT(X1#)
    RY!=INT(Y1#)
END SUB

FUNCTION QObject(OName$) AS QUAD
    FUNCTION=CVQ(LEFT$(UCASE$(OName$)+STRING$(8, CHR$(0)),8))
END FUNCTION

SUB glGetI(BYVAL PN AS DWORD, RV&)
    glGetIntegerv PN, RV&   ' you can pass the first item of an Integer array to get multiple values
END SUB

SUB glGetF(BYVAL PN AS DWORD, RV!)
    glGetFloatv PN, RV!   ' you can pass the first item of an Single array to get multiple values
END SUB

FUNCTION FloatToLong(BYVAL V!) AS LONG
    LOCAL L AS LONG PTR
    L=VARPTR(V!)
    FUNCTION=@L
END FUNCTION

FUNCTION LongToFloat(BYVAL L&) AS SINGLE
    LOCAL F AS SINGLE PTR
    F=VARPTR(L&)
    FUNCTION=@F
END FUNCTION

SUB InitOpenGLWindow(BYVAL hWnd AS LONG, hDC AS LONG, hGLRC AS LONG, BYVAL mode&, ABuffer&)
    LOCAL PF AS PIXELFORMATDESCRIPTOR, PF1 AS PIXELFORMATDESCRIPTOR, PF2 AS PIXELFORMATDESCRIPTOR
    LOCAL   IPF&, zPTR AS ASCIIZ PTR
    STATIC FirstRC&
    PF.nSize=SIZEOF(PF)
    PF.nVersion     =   1
'    PF.dwFlags      =      ' set below
    PF.iPixelType   =   %PFD_TYPE_RGBA
    PF.cColorBits   =   24
'    PF.cRedBits     =
'    PF.cRedShift    =
'    PF.cGreenBits   =
'    PF.cGreenShift  =
'    PF.cBlueBits    =
'    PF.cBlueShift   =
    PF.cAlphaBits   = 8
'    PF.cAlphaShift  =
    PF.cAccumBits   = 64


'    PF.cAccumRedBits    =
'    PF.cAccumGreenBits  =
'    PF.cAccumBlueBits   =
'    PF.cAccumAlphaBits  =
    PF.cDepthBits        =  16  ' depth of z planes
'    PF.cStencilBits     =
'    PF.cAuxBuffers      =
'    PF.iLayerType       =
'    PF.bReserved        =
'    PF.dwLayerMask      =
'    PF.dwVisibleMask    =
'    PF.dwDamageMask     =
    PF1=PF  ' for window DC

    ' some other flags to use:
'   %PFD_GENERIC_FORMAT
'   %PFD_GENERIC_ACCELERATED
'   %PFD_SUPPORT_COMPOSITION

    SELECT CASE AS LONG mode&
        CASE 1,2
            PF1.dwFlags      =   %PFD_DRAW_TO_WINDOW OR %PFD_SUPPORT_OPENGL OR %PFD_DOUBLEBUFFER OR %PFD_GENERIC_ACCELERATED OR %PFD_SUPPORT_COMPOSITION
        CASE ELSE   ' not currently used anymore
            PF1.dwFlags      =   %PFD_DRAW_TO_WINDOW OR %PFD_SUPPORT_OPENGL OR %PFD_GENERIC_ACCELERATED OR %PFD_SUPPORT_COMPOSITION
    END SELECT
    hDC=GetDC(hWnd)
    IPF&=ChoosePixelFormat(hDC, PF1)
    IF IPF&<>0 THEN
        IF PF1.cAccumBits<>0 THEN
            ' accum buffers available
            ABuffer&=1
        ELSE
            ABuffer&=0
        END IF
        SetPixelFormat hDC,IPF&, PF1
        hGLRC=wglCreateContext(hDC)
        IF FirstRC&=0 THEN
            FirstRC&=1
            wglMakeCurrent hDC, hGLRC
            zPTR=glGetString(%GL_VENDOR)
            App_GLVendor$=@zPTR
            zPTR=glGetString(%GL_RENDERER)
            App_GLRenderer$=@zPTR
            zPTR=glGetString(%GL_VERSION)
            App_GLVersion$=@zPTR
'            zPTR=glGetString(%GL_EXTENSIONS)
'            App_GLExtensions$=@zPTR
            wglMakeCurrent hDC, %NULL

'            msgbox App_GLVendor$+chr$(13)+chr$(10)+App_GLRenderer$+CHR$(13)+CHR$(10)+App_GLVersion$+CHR$(13)+CHR$(10)+"Buffer Mode ="+str$(IPF&)
        END IF
        ' add this later for drawing to a Bitmap instead
'        PF2=PF  ' for memory DC
'        PF2.dwFlags      =   %PFD_DRAW_TO_BITMAP OR %PFD_SUPPORT_OPENGL OR %PFD_SUPPORT_GDI
    ELSE
        hGLRC=0
    END IF
END SUB

SUB GetWH(BYVAL hWnd AS LONG, W&, H&)
    LOCAL R AS RECT
    GetClientRect hWnd, R
    W&=R.nRight-R.nLeft
    H&=R.nBottom-R.nTop
END SUB

SUB ResizeOpenGLWindow(BYVAL hWnd AS LONG, hDC AS LONG, hGLRC AS LONG)
    LOCAL W&, H&
    IF hWnd<>0 THEN
        GetWH hWnd, W&,H&
        wglMakeCurrent hDC, hGLRC
        glViewPort 0,0, W&, H&
        wglMakeCurrent hDC, %NULL
    END IF
END SUB

SUB FreeOpenGLWindow(BYVAL hWnd AS LONG, hDC AS LONG, hGLRC AS LONG)
    wglDeleteContext hGLRC
    DeleteDC hDC
END SUB

%EZCV_GETLASTXPOS               =   %WM_USER+100
%EZCV_GETLASTYPOS               =   %WM_USER+101
%EZCV_GETMEMDC                  =   %WM_USER+102
%EZCV_SETVIEW                   =   %WM_USER+103
%EZCV_GETDIBPOINTER             =   %WM_USER+104
%EZCV_CLEAR                     =   %WM_USER+105
%EZCV_SELECTBUFFER              =   %WM_USER+106
%EZCV_COPYBUFFER                =   %WM_USER+107
%EZCV_DRAW                      =   %WM_USER+108
%EZCV_GETBITMAP                 =   %WM_USER+109

%EZCVS_DIBSECTION    =   8      ' style for DIB section
%EZCVS_DOUBLEBUFFER  =   16
%EZCVS_16BIT         =   2
%EZCVS_24BIT         =   4
%EZCVS_32BIT         =   6

TYPE EZ_RGB32   ' DIB section format
    B   AS BYTE
    G   AS BYTE
    R   AS BYTE
    Reserved AS BYTE
END TYPE

GLOBAL ErrorList$


SUB TE(BYVAL I&)    ' track error
    LOCAL E AS DWORD, T$
    E=glGetError
    IF E<>0 THEN
        T$=""
        SELECT CASE E
            CASE &H0500
                T$="Invalid Enum"
            CASE &H0501
                T$="Invalid Value"
            CASE &H0502
                T$="Invalid Operation"
            CASE &H0503
                T$="Stack Overflow"
            CASE &H0504
                T$="Stack Underflow"
            CASE &H0505
                T$="Out of Memory"
            CASE ELSE
                T$="&H"+HEX$(E)
        END SELECT
        IF LEN(ErrorList$)>1024 THEN ErrorList$=""
        ErrorList$=ErrorList$+"#"+STR$(I&)+" Error: "+T$+CHR$(13)+CHR$(10)
    END IF
END SUB

SUB TA(BYVAL T$)
    IF LEN(ErrorList$)>1024 THEN ErrorList$=""
    ErrorList$=ErrorList$+T$+CHR$(13)+CHR$(10)
END SUB

SUB ConvertRGBtoFloats(BYVAL C&, C1!, C2!, C3!)
    LOCAL B AS BYTE PTR, V!
    B=VARPTR(C&)
    V!=@B
    C1!=V!/255!
    INCR B
    V!=@B
    C2!=V!/255!
    INCR B
    V!=@B
    C3!=V!/255!
END SUB

SUB ClearBuffers(BYVAL ColorFlag&, BYVAL C&, BYVAL DepthFlag&, BYVAL D AS DOUBLE)
    LOCAL M AS DWORD, C1!,C2!,C3!
    IF ColorFlag&<>0 THEN
        M=M OR %GL_COLOR_BUFFER_BIT
        ConvertRGBtoFloats C&, C1!, C2!, C3!
        glClearColor C1!,C2!,C3!,0
    END IF
    IF DepthFlag&<>0 THEN
        M=M OR %GL_DEPTH_BUFFER_BIT
        glClearDepth D
    END IF
    IF M<>0 THEN
        glClear M
    END IF
END SUB

SUB EnableDepth(BYVAL DepthTFlag&)
    IF DepthTFlag& THEN
        glEnable %GL_DEPTH_TEST
    ELSE
        glDisable %GL_DEPTH_TEST
    END IF
END SUB

'%GL_ZERO                        = 0&
'%GL_ONE                         = 1&
'%GL_SRC_COLOR                   = &H00000300
'%GL_ONE_MINUS_SRC_COLOR         = &H00000301
'%GL_SRC_ALPHA                   = &H00000302
'%GL_ONE_MINUS_SRC_ALPHA         = &H00000303
'%GL_DST_ALPHA                   = &H00000304
'%GL_ONE_MINUS_DST_ALPHA         = &H00000305


SUB EnableBlend(BYVAL BFlag&, BYVAL Mode&)
    IF BFlag& THEN
        glEnable %GL_BLEND
        SELECT CASE AS LONG Mode&
            CASE 1  ' normal transparency
                glBlendFunc %GL_SRC_ALPHA, %GL_ONE_MINUS_SRC_ALPHA
            CASE ELSE
                glBlendFunc %GL_SRC_ALPHA, %GL_ONE_MINUS_SRC_ALPHA   'same as #1 right now
        END SELECT

    ELSE
        glDisable %GL_BLEND
    END IF
END SUB

' fog, line_smooth, perspective, point_smooth, polygon_smooth

SUB SetDrawQuality(BYVAL FQ&, BYVAL LNQ&, BYVAL PERQ&, BYVAL PTQ&, BYVAL POLYQ&)
    IF FQ& THEN
        glHint %GL_FOG_HINT, %GL_NICEST
    ELSE
        glHint %GL_FOG_HINT, %GL_FASTEST
    END IF
    IF LNQ& THEN
        glHint %GL_LINE_SMOOTH_HINT, %GL_NICEST
    ELSE
        glHint %GL_LINE_SMOOTH_HINT, %GL_FASTEST
    END IF
    IF PERQ& THEN
        glHint %GL_PERSPECTIVE_CORRECTION_HINT, %GL_NICEST
    ELSE
        glHint %GL_PERSPECTIVE_CORRECTION_HINT, %GL_FASTEST
    END IF
    IF PTQ& THEN
        glHint %GL_POINT_SMOOTH_HINT, %GL_NICEST
    ELSE
        glHint %GL_POINT_SMOOTH_HINT, %GL_FASTEST
    END IF
    IF POLYQ& THEN
        glHint %GL_POLYGON_SMOOTH_HINT, %GL_NICEST
    ELSE
        glHint %GL_POLYGON_SMOOTH_HINT, %GL_FASTEST
    END IF
END SUB

FUNCTION CreateNewDib(BYVAL hDC AS LONG, BYVAL W&, BYVAL H&, PA AS DWORD) AS LONG
    LOCAL BM AS BITMAPINFO, RV&
    BM.bmiHeader.biSize=SIZEOF(BM.bmiHeader)
    BM.bmiHeader.biWidth=W&
    BM.bmiHeader.biHeight=H&    ' creates a bottom up DIB
    BM.bmiHeader.biPlanes=1
    BM.bmiHeader.biBitCount=32
    BM.bmiHeader.biCompression=%BI_RGB
    BM.bmiHeader.biSizeImage=0
    BM.bmiHeader.biXPelsPerMeter=0
    BM.bmiHeader.biYPelsPerMeter=0
    BM.bmiHeader.biClrUsed=0
    BM.bmiHeader.biClrImportant=0
    RV&=CreateDIBSection(hDC, BM, %DIB_RGB_COLORS, VARPTR(PA), %NULL, %NULL)
    FUNCTION=RV&
END FUNCTION

SUB CreateBuffers(BYVAL hWnd AS LONG, BYVAL mode&)
    LOCAL W&, H&, hTempDC&, OW&, OH&, NFlag&, hMemDC&, hBmp&, PA AS DWORD, hOldBmp&
    LOCAL hDC AS LONG, hGLRC AS LONG
    IF mode&=1 OR mode&=2 THEN
        GetWH hWnd, W&,H&
        IF mode&=1 THEN
            NFlag&=1
        ELSE
            NFlag&=0
            OW&=EZ_GetSuperClassProp(hWnd,7)
            OH&=EZ_GetSuperClassProp(hWnd,8)
            IF OW&<>W& THEN NFlag&=1
            IF OH&<>H& THEN NFlag&=1
        END IF
        IF NFlag& THEN
            IF mode&=2 THEN
                GOSUB GetMyProps
                GOSUB FreeMyDC
            END IF
            hTempDC& = GetDC(%HWND_DESKTOP)
            hBmp&=CreateNewDib(hTempDC&, W&, H&, PA)
            hMemDC&=CreateCompatibleDC(hTempDC&)
            ReleaseDC %HWND_DESKTOP, hTempDC&
            hOldBmp&=SelectObject(hMemDC&, hBmp&)
            EZ_SetSuperClassProp hWnd,3, hMemDC&
            EZ_SetSuperClassProp hWnd,4, hBmp&
            EZ_SetSuperClassProp hWnd,5, PA
            EZ_SetSuperClassProp hWnd,6, hOldBmp&
            EZ_SetSuperClassProp hWnd,7, W&
            EZ_SetSuperClassProp hWnd,8, H&
            hDC=EZ_GetSuperClassProp(hWnd,1)
            hGLRC=EZ_GetSuperClassProp(hWnd,2)
            ResizeOpenGLWindow hWnd, hDC, hGLRC     ' sets the viewport
        END IF
    ELSE
        GOSUB GetMyProps
        GOSUB FreeMyDC
    END IF
    EXIT SUB

GetMyProps:
    hMemDC&=EZ_GetSuperClassProp(hWnd,3)
    hBmp&=EZ_GetSuperClassProp(hWnd,4)
    PA=EZ_GetSuperClassProp(hWnd,5)
    hOldBmp&=EZ_GetSuperClassProp(hWnd,6)
RETURN

FreeMyDC:
    SelectObject hMemDC&, hOldBmp&
    DeleteObject hBmp&
    DeleteDC hMemDC&
RETURN

END SUB

DECLARE SUB OpenGLCallBackX(BYVAL Msg&, BYVAL Param1&, BYVAL Param2&, BYVAL Param3&, BYVAL Param4 AS DWORD, BYVAL Float1!, BYVAL Float2!,BYVAL Float3!)

FUNCTION TestExtension(BYVAL EName$, BYVAL mode&, BYVAL FName$) AS DWORD
    LOCAL zPTR AS ASCIIZ PTR, RV AS DWORD, zFN AS ASCIIZ*256
    RV=0
    IF mode&=1 THEN ' load if not loaded yet
        IF App_GLExtensions$="" THEN
            zPTR=glGetString(%GL_EXTENSIONS)
            App_GLExtensions$=@zPTR
            IF RIGHT$(App_GLExtensions$,1)<>" " THEN App_GLExtensions$=App_GLExtensions$+" "
        END IF
        IF INSTR(App_GLExtensions$,EName$+" ") THEN
            ' extension exists
            IF FName$="" THEN   ' simply test for extension
                RV=1
            ELSE
                zFN=FName$+CHR$(0)
                RV=wglGetProcAddress(zFN)
            END IF
        END IF
    END IF
    IF mode&=0 THEN         ' clear current extension list
        App_GLExtensions$=""
    END IF
    FUNCTION=RV
END FUNCTION

TYPE EZMaterial
    CType AS LONG   ' 0- undefined, 1- color, 2-texture
    Red AS SINGLE
    Green AS SINGLE
    Blue AS SINGLE
    Alpha AS SINGLE
    AlphaFlag AS LONG
    Specular AS SINGLE  ' use for all 3 values of specular material
    Shiny AS LONG
    BmpW AS LONG
    BmpH AS LONG
    TexMin AS SINGLE    ' for glGentextCoord call
    TexMax AS SINGLE
END TYPE

GLOBAL App_LastMaterial&
GLOBAL App_EndCoreMaterials&
GLOBAL App_Material() AS EZMaterial
GLOBAL App_MaterialDataMap() AS STRING
GLOBAL App_Palettes() AS STRING


SUB InitMaterials(BYVAL MaxN&)
    REDIM App_Material(0 TO MaxN&) AS GLOBAL EZMaterial
    REDIM App_MaterialDataMap(0 TO MaxN&) AS GLOBAL STRING
    REDIM App_Palettes(0 TO %MaxInitPalettes) AS GLOBAL STRING
    App_LastMaterial&=-1
    App_EndCoreMaterials&=-1
END SUB

SUB FreeMaterials()
    ERASE App_Material
    ERASE App_MaterialDataMap
    ERASE App_Palettes
END SUB

SUB FreeAllMaterialsExceptCore()
    LOCAL I&, N1&, N2&, Tmp AS EZMaterial
    N1&=App_EndCoreMaterials&+1
    N2&=UBOUND(App_Material)
    FOR I&=N1& TO n2&
        App_Material(I&)=Tmp
        App_MaterialDataMap(I&)=""
    NEXT I&
    App_LastMaterial&=N1&-1
END SUB


'TYPE EZ_RGBA
'    R   AS BYTE
'    G   AS BYTE
'    B   AS BYTE
'    Alpha AS BYTE
'END TYPE


SUB GetBitmapPixelData(BYVAL hBmp&, Buffer$, W&, H&, BYVAL CFlag&, BYVAL TColor&)
    LOCAL BI AS BITMAPINFO, MemDC AS LONG
    LOCAL U&, BH AS BITMAP, BSize&
    LOCAL PT1 AS BYTE PTR, PT2 AS BYTE PTR
    REGISTER I&, CT&
    W&=0
    H&=0
    IF GetObjectType(hBmp&)<>%OBJ_BITMAP THEN
        Buffer$=""
        EXIT SUB
    END IF
    GetObject hBmp&, SIZEOF(BH), BH
    BSize&=(BH.bmWidth*4)*BH.bmHeight
    ON ERROR RESUME NEXT
    Buffer$=STRING$(BSize&,CHR$(0))
    ON ERROR GOTO 0
    IF ERR=0 THEN    ' succeeded in creating Buffer !
        MemDC=CreateCompatibleDC(%NULL)     ' get screen mem DC
        ' don't select bitmap into DC when using GetDIBits
        U&=%DIB_RGB_COLORS   ' for Bitmap with RGB colors
        BI.bmiHeader.biSize=SIZEOF(BI.bmiHeader)
        BI.bmiHeader.biWidth=BH.bmWidth
        BI.bmiHeader.biHeight=BH.bmHeight  ' bottom up DIB
        BI.bmiHeader.biPlanes=1
        BI.bmiHeader.biBitCount=32      'BH.bmBitsPixel
        BI.bmiHeader.biCompression=%BI_RGB
        BI.bmiHeader.biSizeImage=0
        BI.bmiHeader.biXPelsPerMeter=0
        BI.bmiHeader.biYPelsPerMeter=0
        BI.bmiHeader.biClrUsed=0
        BI.bmiHeader.biClrImportant=0
        W&=BH.bmWidth
        H&=BH.bmHeight
        GetDIBits MemDC, hBmp&, 0, BH.bmHeight, BYVAL STRPTR(Buffer$), BI, U&
        DeleteDC MemDC
        IF CFlag& THEN  ' convert to RGBA format by swapping bits and then blend with material color
            ' swap bits to RGBA
            PT1=STRPTR(Buffer$)
            PT2=PT1+2
            CT&=W&*H&
            FOR I&=1 TO CT&
                SWAP @PT1, @PT2
                @PT2[1]=255 ' set alpha byte to solid
                PT1=PT1+4
                PT2=PT2+4
            NEXT I&
'            IF TColor&<>-1 THEN  ' if -1 then don't modify pixels
'                ' blend colors
'                PT2=VARPTR(TColor&)
'                PT1=STRPTR(Buffer$) ' dword pointer
'                CT&=W&*H&
'                FOR I&=1 TO CT&
'                    @PT1[0]=MIN((@PT1[0]+@PT2[0])/2&,255)
'                    @PT1[1]=MIN((@PT1[1]+@PT2[1])/2&,255)
'                    @PT1[2]=MIN((@PT1[2]+@PT2[2])/2&,255)
'                    ' don't mess with alpha byte
'                    PT1=PT1+4
'                NEXT I&
'            END IF
        END IF
    ELSE
        Buffer$=""
    END IF
END SUB



'      Index, RGB color, Specular, Shiny  (Specular and Shiny can be from 0 to 100), bitmap
SUB DefMaterial(BYVAL I&, BYVAL C!, BYVAL Sp!, BYVAL Sh!, BYVAL hBmp&, BYVAL TxMin!, BYVAL TxMax!, BYVAL AlphaV!)
    LOCAL RR!,GG!,BB!, AC&
    IF I&>=0 AND I&<=UBOUND(App_Material) THEN
        IF I&>App_LastMaterial& THEN App_LastMaterial&=I&
        C!=ABS(C!)
        IF C!>RGB(255,255,255) THEN C!=RGB(255,255,255)
        AC&=INT(C!)
        ConvertRGBtoFloats AC&, RR!,GG!,BB!
        App_Material(I&).BmpW=0
        App_Material(I&).BmpH=0
        IF hBmp&=0 THEN
            App_Material(I&).CType&=1   ' defined as color
            App_MaterialDataMap(I&)=""
        ELSE
            ' get DIB Bits and convert to RGBA format
            GetBitmapPixelData hBmp&, App_MaterialDataMap(I&), App_Material(I&).BmpW, App_Material(I&).BmpH, 1, AC&
            IF App_MaterialDataMap(I&)<>"" THEN
                App_Material(I&).CType&=2   ' defined as texture
            ELSE
                App_Material(I&).CType&=1   ' No valid Bitmap data so defined as color
            END IF
        END IF
        App_Material(I&).Red=RR!
        App_Material(I&).Green=GG!
        App_Material(I&).Blue=BB!
        IF AlphaV!=0 OR AlphaV!=1 THEN
            App_Material(I&).Alpha=1.0!
            App_Material(I&).AlphaFlag=0
        ELSE
            App_Material(I&).Alpha=AlphaV!/100
            App_Material(I&).AlphaFlag=1
        END IF
        Sp!=ABS(Sp!)
        IF Sp!>100 THEN SP!=100
        SP!=SP!/100
        Sh!=ABS(Sh!)
        IF Sh!>100 THEN Sh!=100
        Sh!=Sh!*1.28    ' convert to values from 0 to 128
        App_Material(I&).Specular=Sp!
        App_Material(I&).Shiny=INT(Sh!)
        App_Material(I&).TexMin=TxMin!
        App_Material(I&).TexMax=TxMax!
    END IF
END SUB

%MaxDefBitmaps  =    16

GLOBAL App_DefaultBitmaps() AS LONG


SUB InitDefBitmaps()
    LOCAL D AS ASCIIZ * 32, N&
    REDIM App_DefaultBitmaps(1 TO %MaxDefBitmaps) AS GLOBAL LONG
    FOR N&=1 TO %MaxDefBitmaps
        GOSUB LoadTexture
    NEXT N&
    EXIT SUB

    LoadTexture:
        D="EZ_TEXTURE"+LTRIM$(STR$(N&))+CHR$(0)
        App_DefaultBitmaps(N&)=LoadImage(DLL_Instance&, D, %Image_Bitmap, 0, 0, 0)
    RETURN
END SUB

SUB FreeDefBitmaps()
    LOCAL N&
    FOR N&=1 TO %MaxDefBitmaps
        IF App_DefaultBitmaps(N&)<>0 THEN
            DeleteObject App_DefaultBitmaps(N&)
        END IF
    NEXT N&
    ERASE App_DefaultBitmaps
END SUB

SUB LoadDefTextures(BYVAL MatID&, TColor&(), BYVAL  Sp!, BYVAL Sh!, BYVAL TXMin!, BYVAL TXMax!, BYVAL CoreFlag&)
    LOCAL D AS ASCIIZ * 32, N1&, N2&, N&, CT&
    LOCAL I&
    N1&=LBOUND(TColor&)
    N2&=UBOUND(TColor&)
    CT&=N2&-N1&+1
    IF CoreFlag&<>0 THEN
        MatID&=App_EndCoreMaterials&+1
    END IF
    IF MatID&<=App_EndCoreMaterials& THEN EXIT SUB
    IF MatID&+(%MaxDefBitmaps*CT&)-1>UBOUND(App_Material) THEN EXIT SUB
    FOR I&=1 TO 8   ' %MaxDefBitmaps
        FOR N&=N1& TO N2&
            DefMaterial MatID&,TColor&(N&),Sp!,Sh!, App_DefaultBitmaps(I&),TXMin!,TXMax!,0
            IF CoreFlag&<>0 THEN
                App_EndCoreMaterials&=MatID&
            END IF
            MatID&=MatID&+1
        NEXT N&
    NEXT I&
    FOR N&=9 TO 16
         ' change color to RGB(128,128,128) if not good appearance
        IF N&<>15 THEN
            DefMaterial MatID&,RGB(255,255,255),Sp!,Sh!, App_DefaultBitmaps(N&),0,2,0
        ELSE
            DefMaterial MatID&,RGB(255,255,255),Sp!,Sh!, App_DefaultBitmaps(N&),0,1.0,0
        END IF
        IF CoreFlag&<>0 THEN
            App_EndCoreMaterials&=MatID&
        END IF
        MatID&=MatID&+1
    NEXT N&
END SUB

%CL_HIGH    = 160   ' originally 255
%CL_MEDHIGH = 108   ' originally 196
%CL_MED     = 80   ' originally 128
%CL_P1      = -10
%CL_P2      = -10
%CL_P3      =  10

FUNCTION QBColor(N&) AS LONG
LOCAL RV AS LONG
SELECT CASE AS LONG N&
    CASE 0
        RV=RGB(16,16,16)       ' Black (don't want exact black)
    CASE 1
        RV=RGB(0,0,%CL_MED)     ' Blue
    CASE 2
        RV=RGB(0,%CL_MED,0)     ' Green
    CASE 3
'        RV=RGB(0,%CL_MED,%CL_MED)   ' Cyan
        RV=RGB(0,%CL_MED+%CL_P1,%CL_MED-%CL_P2)   ' Cyan
    CASE 4
'        RV=RGB(%CL_MEDHIGH,0,0)     ' Red
        RV=RGB(%CL_MEDHIGH+%CL_P3,0,0)     ' Red
    CASE 5
'        RV=RGB(%CL_MED,0,%CL_MED)   ' Magenta (Purple)
        RV=RGB(%CL_MEDHIGH-10,%CL_MED-35,0)   ' Orange
    CASE 6
        RV=RGB(%CL_MED,64,0)   ' Brown
    CASE 7
        RV=RGB(%CL_MEDHIGH,%CL_MEDHIGH,%CL_MEDHIGH) ' White
    CASE 8
        RV=RGB(%CL_MED,%CL_MED,%CL_MED) ' Gray
    CASE 9
'        RV=RGB(0,0, %CL_HIGH)    ' Lt. Blue
        RV=RGB(0,0, %CL_HIGH-10)    ' Lt. Blue
    CASE 10
        RV=RGB(0,%CL_HIGH,0)    ' Lt. Green
    CASE 11
'        RV=RGB(0,%CL_HIGH,%CL_HIGH)  ' Lt. Cyan
        RV=RGB(0,%CL_HIGH+%CL_P1-10,%CL_HIGH-%CL_P2-10)  ' Lt. Cyan
    CASE 12
'        RV=RGB(%CL_HIGH,0,0)    ' Lt. Red
        RV=RGB(%CL_HIGH+%CL_P3,0,0)    ' Lt. Red
    CASE 13
'        RV=RGB(%CL_HIGH,0,%CL_HIGH)  ' Lt. magenta (Purple)
        RV=RGB(%CL_HIGH+15,%CL_MED-10,0)  ' Lt. orange
    CASE 14
        RV=RGB(%CL_HIGH,%CL_HIGH,0)  ' Yellow
    CASE 15
        RV=RGB(%CL_HIGH,%CL_HIGH,%CL_HIGH)' Bright White
    CASE 16
        RV=RGB(%CL_MEDHIGH-32,%CL_MEDHIGH-32,%CL_MEDHIGH-32)
    CASE 17
'        RV=RGB(%CL_MED,%CL_MEDHIGH-36,%CL_HIGH)
        RV=RGB(%CL_MED-50,%CL_MEDHIGH-36,%CL_HIGH+20) ' very light blue
    CASE 18
        RV=RGB(%CL_MEDHIGH-36,%CL_HIGH,%CL_MEDHIGH-36)
    CASE 19
'        RV=RGB(%CL_MEDHIGH-36,%CL_HIGH,%CL_HIGH)
        RV=RGB(%CL_MEDHIGH-36,%CL_HIGH+%CL_P1,%CL_HIGH-%CL_P2)
    CASE 20
'        RV=RGB(%CL_HIGH,%CL_MEDHIGH-36,%CL_MEDHIGH-36)
        RV=RGB(%CL_HIGH+20,%CL_MED-30,%CL_MED-30)
    CASE 21
'        RV=RGB(%CL_HIGH,%CL_MEDHIGH-36,%CL_HIGH)
        RV=RGB(%CL_HIGH+15,%CL_MED+15, %CL_MED)  ' very light orange
    CASE 22
        RV=RGB(%CL_HIGH,%CL_HIGH,%CL_MEDHIGH-36)
    CASE 23
        RV=RGB(%CL_HIGH-43,%CL_HIGH-43,%CL_HIGH-43)
    CASE 24
        RV=RGB(%CL_MEDHIGH-16,%CL_MEDHIGH-16,%CL_MEDHIGH-16)
    CASE 25
'        RV=RGB(%CL_MEDHIGH-8,%CL_HIGH-35,%CL_HIGH)
        RV=RGB(%CL_MEDHIGH-30,%CL_HIGH-35,%CL_HIGH+40)   ' very, very light blue
    CASE 26
        RV= RGB(%CL_HIGH-35,%CL_HIGH,%CL_HIGH-35)
    CASE 27
'        RV=RGB(%CL_HIGH-35,%CL_HIGH,%CL_HIGH)
        RV=RGB(%CL_HIGH-35,%CL_HIGH+%CL_P1,%CL_HIGH-%CL_P2)
    CASE 28
'        RV=RGB(%CL_HIGH,%CL_HIGH-35,%CL_HIGH-35)
        RV=RGB(%CL_HIGH+40,%CL_MEDHIGH,%CL_MEDHIGH)
    CASE 29
'        RV=RGB(%CL_HIGH,%CL_HIGH-35,%CL_HIGH)
        RV=RGB(%CL_HIGH+50,%CL_MED+50, %CL_MED) ' very, very light orange
    CASE 30
'        RV=RGB(%CL_HIGH,%CL_HIGH,%CL_HIGH-35)
        RV=RGB(%CL_HIGH,%CL_HIGH,%CL_MEDHIGH)
    CASE 31
        RV=RGB(%CL_HIGH-27,%CL_HIGH-27,%CL_HIGH-27)
    CASE ELSE
        RV=RGB(16,16,16)
END SELECT
FUNCTION=RV
END FUNCTION


SUB AddCoreMaterials()
    LOCAL N&, C&, TColor&()
    DIM TColor&(1 TO 8)
    '96 predefined color materials:
    ' Flat Default colors
    FOR N&=0 TO 31
        C&=QBColor(N&)
        DefMaterial N&,C&,3,3,0,0,0,0
        App_EndCoreMaterials&=App_EndCoreMaterials&+1
    NEXT N&
    ' Semi-Gloss default colors
    FOR N&=0 TO 31
        C&=QBColor(N&)
        DefMaterial N&+32,C&,25,25,0,0,0,0
        App_EndCoreMaterials&=App_EndCoreMaterials&+1
    NEXT N&
    ' Gloss default colors
    FOR N&=0 TO 31
        C&=QBColor(N&)
        DefMaterial N&+64,C&,100,100,0,0,0,0
        App_EndCoreMaterials&=App_EndCoreMaterials&+1
    NEXT N&
    ' Transparent default colors
    FOR N&=0 TO 31
        C&=QBColor(N&)
        DefMaterial N&+96,C&,100,100,0,0,0,60
        App_EndCoreMaterials&=App_EndCoreMaterials&+1
    NEXT N&
    FOR N&=1 TO 8     ' 8 colors x 8 bitmaps = 64 textures
        TColor&(N&)=QBColor(16+N&-1)
    NEXT N&
    LoadDefTextures 0, TColor&(), 25,25,0, 8, 1    ' add to core materials
END SUB


GLOBAL App_LastObject&
GLOBAL App_ObjName() AS QUAD    ' objects name stored in quad format
GLOBAL App_ObjDraw() AS STRING  ' object draw steps


SUB InitObjectList(BYVAL MaxN&)
    App_LastObject&=0
    DIM App_ObjName(1 TO MaxN&) AS GLOBAL QUAD     ' objects name
    DIM App_ObjDraw(1 TO MaxN&) AS GLOBAL STRING   ' object draw steps
    App_EndCoreObjects&=0
END SUB

SUB FreeObjectList()
    ERASE App_ObjName
    ERASE App_ObjDraw
END SUB

SUB FreeAllObjectsExceptCore()
    LOCAL I&, N1&, N2&
    N1&=App_EndCoreObjects&+1
    N2&=UBOUND(App_ObjName)
    FOR I&=N1& TO n2&
        App_ObjName(I&)=0
        App_ObjDraw(I&)=""
    NEXT I&
    App_LastObject&=N1&-1
END SUB

FUNCTION ConvVString(DString$) AS STRING
    LOCAL V$, CT&, PT AS BYTE PTR, RV$
    LOCAL I&, LB AS BYTE, RB AS BYTE, B1&, N&, N2&, DType&, PCount&
    LOCAL Temp$, L&, PTS AS DWORD, J&, F() AS SINGLE, FPTR AS DWORD, FCount&
    DIM F(1 TO 20) AS SINGLE    ' make sure no more paramaters than 20 in commands
    FPTR=VARPTR(F(1))
    LB=ASC("(")
    RB=ASC(")")
    RV$=""
    N&=1
    L&=LEN(DString$)
    PTS=STRPTR(DString$)
    DO
        IF N&+3>L& THEN EXIT LOOP   ' must be at least one character pass Macro
        SELECT CASE AS CONST$ MID$(DString$,N&,3)
            CASE "{P}"
                DType&=1
                PCount&=3
            CASE "{W}"  ' world limits
                DType&=2
                PCount&=3
            CASE "{T}"
                DType&=3
                PCount&=3
            CASE "{Q}"
                DType&=4
                PCount&=4
            CASE "{M}"  ' material
                DType&=5
                PCount&=1
            CASE "{S}"  ' sphere
                DType&=6
                PCount&=4   ' last value is point of origin
            CASE "{C}"  ' cylinder
                DType&=20
                PCount&=6
            CASE "{D}"  ' round disk
                DType&=21
                PCount&=5
            CASE "{X}"  ' axis direction for Cylinder and Disk objects
                DType&=30
                PCount&=1
'            case "{U}"
'                DType&=6    ' not supported yet, but process diferently
            CASE ELSE
                DType&=0
        END SELECT
        IF DType&=0 THEN EXIT LOOP
        N&=N&+3
        PT=PTS+N&-1
        N2&=INSTR(N&,DString$, "{") ' check for next macro
        IF N2&=0 THEN N2&=L& ELSE N2&=N2&-1
        Temp$=""
        FCount&=0
        FOR I&=N& TO N2&
            IF @PT=LB THEN
                 B1&=I&+1
            END IF
            IF @PT=RB AND B1&<>0 THEN
                V$=MID$(DString$, B1&, I&-B1&)
                B1&=0
                FOR J&=1 TO PCount&
                    F(J&)=VAL(PARSE$(V$,",",J&))
                NEXT J&
                Temp$=Temp$+PEEK$(FPTR,PCount&*4)   ' add floats to string
                FCount&=FCount&+1
            END IF
            INCR PT
        NEXT I&
        N&=N2&+1
        RV$=RV$+MKI$(DType&)+MKI$(FCount&)+Temp$
    LOOP
    ' each command cycle will contain the following per draw command macro:
    ' Integer - Draw Type  (2 bytes)
    ' Integer - Count of parameter Sets (2 bytes)
    ' Singles - Count * TypeCount Singles

    ' test code
    FUNCTION=RV$
END FUNCTION

SUB FreeExistingObject(OName$)
    LOCAL M&, QName AS QUAD
    QName=QObject(OName$)
    ARRAY SCAN App_ObjName(1) FOR App_LastObject&, = QName, TO M&
    IF M&<>0 THEN
        IF M&>App_EndCoreObjects& THEN  ' don't free core objects but just user objects
            App_ObjName(M&)=0
            App_ObjDraw(M&)=""
        END IF
    ELSE
        App_ReturnValue&=-1
    END IF
END SUB

SUB SetModelColorRange(BYVAL OName$, BYVAL MinR!, BYVAL MaxR!, BYVAL NewVal!)
    LOCAL QName AS QUAD, M&,lpI AS INTEGER PTR, lpCT AS LONG PTR, L&, CT&, lpW AS WORD PTR, J&
    LOCAL AMinR&, AMaxR&
    REGISTER ANewVal&
    QName=QObject(OName$)
    ARRAY SCAN App_ObjName(1) FOR App_LastObject&, = QName, TO M&
    IF M&<>0 THEN
        L&=LEN(App_ObjDraw(M&))
        IF L&>=2 THEN
            lpI=STRPTR(App_ObjDraw(M&))
            IF @lpI=7 THEN ' this is a model
                IF L&>=84 THEN  ' has a complete header
                    CT&=@lpI[1]
                    IF CT&=-1 THEN
                        lpCT=lpI+4
                        CT&=@lpCT
                    END IF
                    IF L&=(CT&*50)+84 THEN  ' -1,-1 for MinR& and MaxR& will clear all values
                        IF MinR!<1 THEN MinR!=1
                        IF MaxR!=-1 THEN MaxR!=CT&
                        IF MinR!>CT& THEN MinR!=CT&
                        IF MaxR!<MinR! THEN MaxR!=MinR!
                        IF MaxR!>CT& THEN MaxR!=CT&
                        AMinR&=INT(MinR!)
                        AMaxR&=INT(MaxR!)
                        lpW=lpI+84+(AMinR&*50)-2
                        IF NewVal!<0 THEN NewVal!=0
                        IF NewVal!>100 THEN NewVal!=100
                        ANewVal&=INT(NewVal!)
                        FOR J&=AMinR& TO AMaxR&
                            @lpW=ANewVal&
                            lpW=lpW+50
                        NEXT J&
                    END IF
                END IF
            END IF
        END IF
    END IF
END SUB

SUB SetModelColorRangeCmd(T$, BYVAL mode&)
    LOCAL CT&, OName$, MinR!,MaxR!,NewVal!, Cmp&
    CT&=PARSECOUNT(T$,",")
    IF mode&=1 THEN
        Cmp&=3
    ELSE
        Cmp&=4
    END IF
    IF CT&>=Cmp& THEN
        OName$  =UCASE$(TRIM$(PARSE$(T$,",",1)))
        MinR!   =VAL(PARSE$(T$,",",2))
        IF mode&=1 THEN
            MaxR!=MinR!
            NewVal! =VAL(PARSE$(T$,",",3))
        ELSE
            MaxR!   =VAL(PARSE$(T$,",",3))
            NewVal! =VAL(PARSE$(T$,",",4))
        END IF
        SetModelColorRange OName$,MinR!,MaxR!,NewVal!
    END IF
END SUB

SUB ParseNewObject(OName$, OData$, BYVAL mode&)
    LOCAL M&, D$, QName AS QUAD
    STATIC CUSTOM AS QUAD
    IF CUSTOM=0 THEN CUSTOM=QObject("CUSTOM")
    QName=QObject(OName$)
    IF QName=CUSTOM THEN    ' don't allow this object name
        App_ReturnValue&=-1 ' error
        EXIT SUB
    END IF
    ARRAY SCAN App_ObjName(1) FOR App_LastObject&, = QName, TO M&
    IF M&=0 THEN
        ARRAY SCAN App_ObjName(1), = 0, TO M&
    END IF
    IF M&<>0 THEN
        App_ObjName(M&)=QName
        IF mode&=1 THEN
            App_ObjDraw(M&)=ConvVString(OData$)
        END IF
        IF mode&=2 THEN     ' for file loading routines to pass converted data
            App_ObjDraw(M&)=OData$
        END IF
        App_ReturnValue&=M&
        IF M&>App_LastObject& THEN App_LastObject&=M&
    ELSE
        App_ReturnValue&=-1 ' error
    END IF
END SUB

SUB AddNewObject(BYVAL D$)
    LOCAL RV$, Obj$, P1&, P2&, EFlag&, L&
    LOCAL OName$, OData$, P3&
    D$=UCASE$(REMOVE$(D$,ANY CHR$(9)+CHR$(15)+CHR$(10)+CHR$(13)+CHR$(27)+CHR$(0)+CHR$(1)+" |"))
    Obj$=""
    P1&=INSTR(D$,"<")
    IF P1&<>0 THEN
        L&=LEN(D$)
        EFlag&=0
        DO
            IF P1&>L& THEN EXIT LOOP
            P2&=INSTR(P1&+1,D$,"<")
            IF P2&=0 THEN
                P2&=L&+1
            END IF
            Obj$=MID$(D$,P1&, P2&-P1&)
            GOSUB ProcessObj
            P1&=P2&
        LOOP
    END IF
    EXIT SUB

ProcessObj:
    ' now a single object string in Obj$
    P3&=INSTR(Obj$, ">")
    IF P3&<>0 THEN
        OName$=UCASE$(MID$(Obj$,2,P3&-2))
        IF LEN(OName$)>8 THEN OName$=LEFT$(OName$,8)
        ' maximum length of object names is 8
        OData$=MID$(Obj$,P3&+1)
        ParseNewObject OName$, OData$, 1
    END IF
RETURN

END SUB

SUB ClearExtraWord(BYVAL lpFDSTR AS DWORD, BYVAL CT&)
    REGISTER J&
    LOCAL lpW AS WORD PTR
    lpW=lpFDSTR+84+48
    FOR J&=1 TO CT&
        @lpW=0
        lpW=lpW+50
    NEXT J&
END SUB

SUB AutoSizeSTL(BYVAL lpFDSTR AS DWORD, BYVAL CT&, BYVAL Auto&)
    ' auto size and center image
    LOCAL MinX!,MaxX!,MinY!,MaxY!,MinZ!,MaxZ!,lpF AS SINGLE PTR, J&, E&, FX!,FY!,FZ!, lpVert AS DWORD
    lpF=lpFDSTR+84
    FOR J&=1 TO CT&
        IF Auto&=3 OR Auto&=4 THEN     ' generate normals
            lpVert=lpF
            GenNormals lpVert+12, lpVert
        END IF
        IF Auto&=2 OR Auto&=3 THEN
            ' swap Y and Z axis
            SWAP @lpF[1],@lpF[2]    ' swap normals too!
            SWAP @lpF[4],@lpF[5]
            SWAP @lpF[7],@lpF[8]
            SWAP @lpF[10],@lpF[11]
        END IF
        IF @lpF[3]<MinX! THEN MinX!=@lpF[3]
        IF @lpF[6]<MinX! THEN MinX!=@lpF[6]
        IF @lpF[9]<MinX! THEN MinX!=@lpF[9]


        IF @lpF[3]>MaxX! THEN MaxX!=@lpF[3]
        IF @lpF[6]>MaxX! THEN MaxX!=@lpF[6]
        IF @lpF[9]>MaxX! THEN MaxX!=@lpF[9]


        IF @lpF[4]<MinY! THEN MinY!=@lpF[4]
        IF @lpF[7]<MinY! THEN MinY!=@lpF[7]
        IF @lpF[10]<MinY! THEN MinY!=@lpF[10]


        IF @lpF[4]>MaxY! THEN MaxY!=@lpF[4]
        IF @lpF[7]>MaxY! THEN MaxY!=@lpF[7]
        IF @lpF[10]>MaxY! THEN MaxY!=@lpF[10]


        IF @lpF[5]<MinZ! THEN MinZ!=@lpF[5]
        IF @lpF[8]<MinZ! THEN MinZ!=@lpF[8]
        IF @lpF[11]<MinZ! THEN MinZ!=@lpF[11]


        IF @lpF[5]>MaxZ! THEN MaxZ!=@lpF[5]
        IF @lpF[8]>MaxZ! THEN MaxZ!=@lpF[8]
        IF @lpF[11]>MaxZ! THEN MaxZ!=@lpF[11]



        lpF=lpF+50
    NEXT J&
    lpF=lpFDSTR+8
    FX!=ABS(MaxX!-MinX!)/2
    IF FX!<>0 THEN FX!=100/FX! ELSE FX!=1
    FY!=ABS(MaxY!-MinY!)/2
    IF FY!<>0 THEN FY!=100/FY! ELSE FY!=1
    FZ!=ABS(MaxZ!-MinZ!)/2
    IF FZ!<>0 THEN FZ!=100/FZ! ELSE FZ!=1
    IF FX!<=FY! THEN
        IF FX!<=FZ! THEN
            ' use FX!
        ELSE
            FX!=FZ!
        END IF
    ELSE
        IF FY!<=FZ! THEN
            FX!=FY!
        ELSE
            FX!=FZ!
        END IF
    END IF
    @lpF[0]=FX! ' ratio must be 1 to 1 to 1
    @lpF[1]=FX!
    @lpF[2]=FX!
END SUB


SUB Optimize3DObject(BYVAL QName AS QUAD)
    LOCAL M&, L&, CT&, NewMod$, NL&
    LOCAL EZO AS EZObjHeader PTR, EZO2 AS EZObjHeader PTR
    LOCAL F1 AS DWORD, F2 AS DWORD, C1 AS WORD PTR, C2 AS WORD PTR
    REGISTER I&, J&
    ARRAY SCAN App_ObjName(1) FOR App_LastObject&, = QName, TO M&
    IF M&<>0 THEN
        L&=LEN(App_ObjDraw(M&))
        IF L&>=84 THEN
            EZO=STRPTR(App_ObjDraw(M&))
            IF @EZO.OType=7 THEN    ' this is a STL model
                CT&=@EZO.Count1
                IF CT&=-1 THEN CT&=@EZO.Count2
                IF CT&>0 THEN
                    IF L&=(CT&*50)+84 THEN
                        ' per triangle 36 bytes verts, 36 bytes normals, 36 bytes text coords, 2 bytes Material ID
                        NL&=(CT&*98)+84
                        NewMod$=STRING$(NL&, CHR$(0))
                        EZO2=STRPTR(NewMod$)
                        @EZO2=@EZO  ' first 84 bytes are filled with header
                        @EZO2.OType=8   ' optimized model
'                            MoveMemory DestMemPTR, SrcMemPTR, MemLen&
                        ' Move vertices to array
                        F1=STRPTR(App_ObjDraw(M&))+84+12    ' start with first vertex
                        F2=STRPTR(NewMod$)+84   ' fill vertex array first
                        FOR I&=1 TO CT& ' move vertices to array
                            MoveMemory F2, F1, 36   ' move 9 singles, for 3 vertex total
                            F2=F2+36
                            F1=F1+50
                        NEXT I&
                        ' move normals (and make 3 copies of each)
                        F1=STRPTR(App_ObjDraw(M&))+84    ' start with first normal
                        ' F2 already has proper position now last loop
                        FOR I&=1 TO CT& ' move normals to array
                            FOR J&=1 TO 3   ' move 3 copies of the one normal , so each vertex has its own normal
                                MoveMemory F2, F1, 12
                                F2=F2+12
                            NEXT J&
                            F1=F1+50
                        NEXT I&
                        ' create color array, one word per triangle (not for OpenGL calls, but for tracking material ID's)
                        C1=STRPTR(App_ObjDraw(M&))+84+48    ' start with first color index (2 byte words)
                        ' F2 already has proper position now last loop
                        C2=F2+(CT&*24)  ' save space for tex coordinates, initially zeros
                        FOR I&=1 TO CT&
                            @C2=@C1
                            C1=C1+50
                            INCR C2
                        NEXT I&
                        SWAP App_ObjDraw(M&),NewMod$
                        NewMod$=""
                        ' Vertex Array starts at STRPTR()+84
                        ' Normal Array starts at STRPTR()+84+(CT&*36)
                        ' TexCoord Array starts as STRPTR()+84+(CT&*72)
                        ' Color Tracking Array starts at STRPTR()+84+(CT&*96)   (only a word to store Material ID for triangle)
                    END IF
                END IF
            END IF
        END IF
    END IF
END SUB

FUNCTION TestForAscii(FD$) AS LONG
     LOCAL L&, L2&, T$
     IF UCASE$(PEEK$(STRPTR(FD$),6))="SOLID " THEN
          ' propbably ascii
          L&=LEN(FD$)
          L2&=L&
          IF L&>=256 THEN
               L2&=256
          ELSE
               IF L&>=128 THEN L2&=128
          END IF
          T$=UCASE$(PEEK$(STRPTR(FD$),L2&))
          IF INSTR(T$, "FACET NORMAL")<>0 THEN
               FUNCTION=1
          ELSE
               FUNCTION=0
          END IF
     ELSE
          FUNCTION=0
     END IF
END FUNCTION

SUB Load3DFile(BYVAL hWnd AS LONG, BYVAL OName$, BYVAL ModelFile$, BYVAL Auto&)
    LOCAL OData$, FD$, FileExt$, FType&, L&, OKFlag&, AFN&
    LOCAL lpL AS LONG PTR,lpCT AS INTEGER PTR, CT&, lpF AS SINGLE PTR
    LOCAL MaxCT&, P1&, P2&, lpFD AS DWORD, T$, lpText AS DWORD, EFlag&, TL&, J&, JG&
    LOCAL Vert() AS SINGLE, EZO AS EZObjHeader PTR, Info$, I&
    DIM Vert(1 TO 12) AS SINGLE
    OName$=UCASE$(TRIM$(OName$))
    IF LEN(OName$)>8 THEN OName$=LEFT$(OName$,8)
    FileExt$=UCASE$(PARSE$(ModelFile$,".",-1))
    SELECT CASE AS CONST$ FileExt$
        ' EZGUI limits ascii  STL files to   100,000 triangles
        ' EZGUI limits binary STL files to 5,000,000 triangles
        CASE "STLA"     ' ascii
            FType&=1
        CASE "STLB"
            FType&=2    ' binary
        CASE "STL
            FType&=3    ' unknown STL file
        CASE "STLE", "EZ3S"     ' enhanced STL format
            FType&=10           ' EZGUI normal 3DModel file
        CASE "EZ3D"     ' EZGUI Optimized format
            FType&=10   ' EZGUI 3DModel file
        CASE "EZ3P"
            FType&=11   ' EZGUI  3D Primitive file
        CASE ELSE
            FTYpe&=0
    END SELECT
    I&=INSTR(-1,ModelFile$,"\")
    IF I&<>0 THEN Info$=MID$(ModelFile$, I&+1) ELSE Info$=ModelFile$
    IF FType&<>0 THEN
        IF DIR$(ModelFile$)<>"" THEN    ' file exists
            FD$=""
            AFN&=FREEFILE
            OPEN ModelFile$ FOR BINARY AS AFN&
            L&=LOF(AFN&)
            IF L&>0 THEN
                GET$ AFN&, L&, FD$
            END IF
            CLOSE AFN&
            IF FD$<>"" THEN
                IF FType&=3 THEN    ' unknown STL file type
                    IF L&>=6 THEN
                        IF TestForAscii(FD$) THEN
                            FType&=1
                        ELSE
                            IF L&>=84 THEN
                                lpL=STRPTR(FD$)+80
                                CT&=@lpL    ' get count of facets in file
                                IF 84+(CT&*50)=L& THEN  ' must match length
                                    FType&=2    ' binary
                                ELSE
                                    ' invalid file
                                    EXIT SUB
                                END IF
                            ELSE
                                ' invalid file
                                EXIT SUB
                            END IF
                        END IF
                    ELSE
                        ' invalid file
                        EXIT SUB
                    END IF
                END IF
                IF FType&=10 THEN
                    IF L&>=84 THEN
                        EZO=STRPTR(FD$)
                        IF @EZO.OType=7 OR @EZO.OType=8 THEN    ' type matches internal coding which is currently 7 or 8
                            CT&=@EZO.Count1
                            IF CT&=-1 THEN
                                CT&=@EZO.Count2
                            END IF
                            IF @EZO.OType=7 THEN
                                MaxCT&=(CT&*50)+84
                            ELSE
                                MaxCT&=(CT&*98)+84
                            END IF
                            IF L&=MaxCT& THEN
                                IF @EZO.WhoAmI="EZGUIModel" THEN
                                    IF @EZO.Version=500 THEN
                                        ParseNewObject OName$, FD$,2
                                        IF @EZO.OType=7 THEN
                                            Info$="EZ3S|"+Info$+"|Loaded|"+TRIM$(STR$(CT&))+" Triangles"
                                        ELSE
                                            Info$="EZ3D|"+Info$+"|Loaded|"+TRIM$(STR$(CT&))+" Triangles"
                                        END IF
                                        SetInfoString hWnd, Info$
                                    END IF
                                END IF
                            END IF
                        END IF
                    END IF
                    EXIT SUB
                END IF
                IF FType&=11 THEN
                    ParseNewObject OName$, FD$,2
                    Info$="EZ3P|"+Info$+"|Loaded"
                    SetInfoString hWnd, Info$
                END IF
                OData$=""
                SELECT CASE AS LONG FType&
                    CASE 1  ' STLA   (ascii format)
                        LOCAL lpOD AS SINGLE PTR
                        FD$=UCASE$(FD$) ' required because some files small case and others all caps
                        MaxCT&=TALLY(FD$,"FACET NORMAL ")
                        ' Build a binary format just like STL binary
                        IF MaxCT&>100000 THEN MaxCT&=100000   ' maximum # of triangles permitted by EZGUI
                        OData$=STRING$((MaxCT&*50)+84,CHR$(0))
                        lpFD=STRPTR(FD$)
                        P1&=INSTR(FD$,CHR$(13)) ' skip first line
                        IF P1&<=0 THEN P1&=1
                        CT&=0
                        lpOD=STRPTR(OData$)+84
                        DO
                            P2&=INSTR(P1&, FD$,"FACET N")
                            IF P2&=0 THEN EXIT LOOP
                            ' get normals
                            P1&=P2&+13
                            JG&=1
                            GOSUB GetNextSTLVert
                            IF EFlag& THEN EXIT LOOP
                            FOR J&=1 TO 3
                                IF P1&>=L& THEN  EFlag&=1:EXIT FOR
                                P2&=INSTR(P1&, FD$,"VERTEX ")
                                IF P2&=0 THEN EFlag&=1:EXIT FOR
                                P1&=P2&+7
                                IF P1&>=L& THEN  EFlag&=1:EXIT FOR
                                GOSUB GetNextSTLVert
                            NEXT J&
                            IF EFlag& THEN EXIT LOOP
                            ' got all 12 values
                            IF CT&=MaxCT& THEN EXIT LOOP
                            CT&=CT&+1
                            @lpOD[0]=Vert(1)
                            @lpOD[1]=Vert(2)
                            @lpOD[2]=Vert(3)
                            @lpOD[3]=Vert(4)
                            @lpOD[4]=Vert(5)
                            @lpOD[5]=Vert(6)
                            @lpOD[6]=Vert(7)
                            @lpOD[7]=Vert(8)
                            @lpOD[8]=Vert(9)
                            @lpOD[9]=Vert(10)
                            @lpOD[10]=Vert(11)
                            @lpOD[11]=Vert(12)
                            lpOD=lpOD+50
                        LOOP
                        IF CT&>0 THEN
                            lpCT=STRPTR(OData$)    ' write over header since not needed
                            @lpCT=7  ' STLB type file format
                            IF CT&<=32000 THEN
                                @lpCT[1]=CT&
                                lpL=lpCT+4
                                @lpL=CT&    ' simply redundant here
                            ELSE
                                @lpCT[1]=-1
                                lpL=lpCT+4
                                @lpL=CT&
                            END IF
                            IF Auto&<>0 THEN
                                AutoSizeSTL STRPTR(OData$), CT&, Auto&
                            ELSE
                                lpF=STRPTR(OData$)+8
                                @lpF[0]=1.0
                                @lpF[1]=1.0
                                @lpF[2]=1.0
                            END IF
                            EZO=STRPTR(OData$)
                            @EZO.ColorFlag  =0   ' no colors defined
                            @EZO.dummy=""   ' fill with spaces
                            @EZO.WhoAmI="EZGUIModel"
                            @EZO.ColorFlag=0
                            @EZO.Version=500    ' for 5.00
                            @EZO.STLSize=CT&    ' for STL compatibility
                            ClearExtraWord STRPTR(OData$), CT&
                            ParseNewObject OName$, OData$,2
                            Info$="STL Ascii|"+Info$+"|Loaded|"+TRIM$(STR$(CT&))+" Triangles"
                            SetInfoString hWnd, Info$
                        END IF
                    CASE 2
                        IF L&>=84 THEN
                            lpL=STRPTR(FD$)+80
                            CT&=@lpL    ' get count of facets in file
                            ' maximum of 250 meg file to read (50 bytes per record * 5000000)
                            IF 84+(CT&*50)=L& AND CT&<=5000000 THEN  ' must match length
                                lpCT=STRPTR(FD$)    ' write over header since not needed
                                @lpCT=7  ' STLB type file format
                                IF CT&<=32000 THEN
                                    @lpCT[1]=CT&
                                    lpL=lpCT+4
                                    @lpL=CT&    ' simply redundant here
                                ELSE
                                    @lpCT[1]=-1
                                    lpL=lpCT+4
                                    @lpL=CT&
                                END IF
                                IF Auto&<>0 THEN
                                   AutoSizeSTL STRPTR(FD$), CT&, Auto&
                                ELSE
                                    lpF=STRPTR(FD$)+8
                                    @lpF[0]=1.0
                                    @lpF[1]=1.0
                                    @lpF[2]=1.0
                                END IF
                                EZO=STRPTR(FD$)
                                @EZO.ColorFlag  =0   ' no colors defined
                                @EZO.dummy=""   ' fill with spaces
                                @EZO.WhoAmI="EZGUIModel"
                                @EZO.ColorFlag=0
                                @EZO.Version=500    ' for 5.00
                                @EZO.STLSize=CT&
                                ClearExtraWord STRPTR(FD$), CT&
                                ParseNewObject OName$, FD$,2
                                Info$="STL Binary|"+Info$+"|Loaded|"+TRIM$(STR$(CT&))+" Triangles"
                                SetInfoString hWnd, Info$
                            END IF
                        END IF
                    CASE ELSE
                        EXIT SUB
                END SELECT
            END IF
        END IF
    END IF
    EXIT SUB

GetNextSTLVert:
    EFlag&=1
    P2&=INSTR(P1&,FD$,CHR$(13)) ' get 3 vertices or 3 normals
    IF P2&<>0 THEN
        TL&=P2&-P1&
        IF TL&<>0 THEN
            lpText=lpFD+P1&-1
            T$=PEEK$(lpText,TL&)
            LOCAL lpB AS BYTE PTR, lpTT AS DWORD, U&, U1&, lpU AS DWORD
            lpTT=STRPTR(T$)
            lpB=lpTT
            U1&=0
            FOR U&=1 TO TL&
                IF @lpB<>32 THEN
                    IF U1&=0 THEN
                        lpU=lpTT
                        U1&=U&
                    END IF
                    IF U&=TL& THEN GOSUB ProcessNumStr
                ELSE
                    GOSUB ProcessNumStr
                END IF
                lpTT=lpTT+1
                INCR lpB
            NEXT U&
            EFlag&=0
            P1&=P1&+TL&+1
        END IF
    END IF
RETURN

ProcessNumStr:
    IF U1&<>0 THEN  ' first space or CR after non-spaces
        Vert(JG&)=VAL(PEEK$(lpU,U&-U1&))
        JG&=JG&+1
        U1&=0
    END IF
RETURN

END SUB

SUB Load3DFileCommand(BYVAL hWnd AS LONG, BYVAL T$)
    LOCAL OName$, ModelFile$, P&, Auto&, V!
    T$=LTRIM$(T$)
    P&=INSTR(T$,",")
    IF P&<>0 THEN
        OName$=LEFT$(T$,P&-1)
        T$=TRIM$(MID$(T$,P&+1))
        P&=INSTR(T$,",")
        Auto&=0
        IF P&<>0 THEN
            V!=ABS(VAL(TRIM$(MID$(T$,P&+1))))
            IF V!>10 THEN V!=10
            Auto&=INT(V!)
            T$=TRIM$(LEFT$(T$,P&-1))
        END IF
        ModelFile$=TRIM$(REMOVE$(T$, ANY CHR$(34)+"'"))    ' remove quotes
        Load3DFile hWnd, OName$, ModelFile$,Auto&
    END IF
END SUB

SUB SaveEZ3DFile(BYVAL OName$, BYVAL ModelFile$)
    LOCAL M&, QName AS QUAD, AFN&, L&
    LOCAL EZO AS EZObjHeader PTR, DType AS INTEGER PTR
    QName=QObject(OName$)
    ARRAY SCAN App_ObjName(1) FOR App_LastObject&, = QName, TO M&
    IF M&<>0 THEN
        IF LEN(App_ObjDraw(M&))>=2 THEN ' enought data for type value
            DType=STRPTR(App_ObjDraw(M&))
            IF @DType=7 OR @DType=8 THEN    ' enhanced STL format (EZGUI's internal format)
                IF LEN(App_ObjDraw(M&))>=84 THEN
                    EZO=STRPTR(App_ObjDraw(M&))
                    @EZO.WhoAmI="EZGUIModel"
                    @EZO.Version=500    ' for 5.00
                    IF @DType=8 THEN
                        ModelFile$=ModelFile$+".ez3d"
                    ELSE
                        ModelFile$=ModelFile$+".ez3s"
                    END IF
                    GOSUB SaveFileNow
                END IF
            ELSE
                ModelFile$=ModelFile$+".ez3p"
                GOSUB SaveFileNow
            END IF
        END IF
    END IF
    EXIT SUB

SaveFileNow:
    ON ERROR GOTO BadSave
    IF DIR$(ModelFile$)<>"" THEN KILL ModelFile$
    AFN&=FREEFILE
    OPEN ModelFile$ FOR BINARY AS AFN&
    ON ERROR RESUME NEXT
    PUT$ AFN&, App_ObjDraw(M&)
    CLOSE AFN&
    BadSave:
    ON ERROR GOTO 0
RETURN

END SUB

SUB SaveEZ3DFileCommand(T$)
    LOCAL OName$, ModelFile$, P&
    T$=LTRIM$(T$)
    P&=INSTR(T$,",")
    IF P&<>0 THEN
        OName$=TRIM$(LEFT$(T$,P&-1))
        T$=TRIM$(MID$(T$,P&+1))
        ModelFile$=TRIM$(REMOVE$(T$, ANY CHR$(34)+"'"))    ' remove quotes
        P&=INSTR(-1,ModelFile$,".")
        IF P&<>0 THEN
            ModelFile$=LEFT$(ModelFile$,P&-1)
        END IF
        SaveEZ3DFile OName$, ModelFile$
    END IF
END SUB


' it should be -1 to 1 in all directions unless not square window
' if width was twice as long as height then width coordinates would be -2 and 2 while height remain the same

' NOTE:  The Front side of a Face must have its points in a counter clockwise order
SUB AddCoreObjects()
    ' assume a world of -100 to 100 on each axis
    DATA "<PLANE>"
    DATA "{P}1(-100,100,0)2(100,100,0)3(100,-100,0)4(-100,-100,0){M}(1){Q}(4,3,2,1)"
    DATA "<CUBE>"
    DATA "{P}1(-100,100,100)2(100,100,100)3(-100,-100,100)4(100,-100,100)5(-100,100,-100)6(100,100,-100)7(-100,-100,-100)8(100,-100,-100)"
    DATA "{M}(1){Q}(1,3,4,2)"
    DATA "{M}(2){Q}(5,6,8,7)"
    DATA "{M}(3){Q}(1,5,7,3)"
    DATA "{M}(4){Q}(2,4,8,6)"
    DATA "{M}(5){Q}(5,1,2,6)"
    DATA "{M}(6){Q}(7,8,4,3)"
    DATA "<PYRAMID>"
    DATA "{P}1(-100,-100,100)2(100,-100,100)3(-100,-100,-100)4(100,-100,-100)5(0,100,0)"
    DATA "{M}(1){Q}(1,3,4,2)"
    DATA "{M}(2){T}(1,2,5)"
    DATA "{M}(3){T}(2,4,5)"
    DATA "{M}(4){T}(4,3,5)"
    DATA "{M}(5){T}(3,1,5)"
    DATA "<SPHERE_Q>"
    ' quality sphere
    DATA "{M}(1){S}(100,50,50,0)"
    DATA "<SPHERE>"
    ' normal sphere
    DATA "{M}(1){S}(100,20,20,0)"
    DATA "<SPHERE_F>"
    ' fast sphere
    DATA "{M}(1){S}(100,12,12,0)"
    DATA "<ROCK1>"
    DATA "{M}(1){S}(100,5,4,0)"
    DATA "<MOON>"
    ' moon sphere
    DATA "{P}1(150,0,0)
    DATA "{M}(1){S}(25,20,20,1)"

    DATA "<CYL_Q>"
    DATA "{M}(1){C}(100,100,50,10,200,0)"
    DATA "<CYL>"
    DATA "{M}(1){C}(100,100,30,10,200,0)"
    DATA "<CYL_F>"
    DATA "{M}(1){C}(100,100,12,4,200,0)"
    DATA "<CYL8>"
    DATA "{M}(1){C}(100,100,8,2,200,0)"
    DATA "<CYL6>"
    DATA "{M}(1){C}(100,100,6,2,200,0)"


    DATA "<CYL_C>"
    DATA "{M}(1){C}(100,100,30,10,200,0)"
    DATA "{X}(1){P}1(0,0,-100){M}(2){D}(100,0,30,10,1)"
    DATA "{X}(0){P}1(0,0,100){M}(2){D}(100,0,30,10,1)"
    DATA "<CYL_FC>"
    DATA "{M}(1){C}(100,100,12,4,200,0)"
    DATA "{X}(1){P}1(0,0,-100){M}(2){D}(100,0,12,4,1)"
    DATA "{X}(0){P}1(0,0,100){M}(2){D}(100,0,12,4,1)"
    DATA "<CYL8_C>"
    DATA "{M}(1){C}(100,100,8,2,200,0)"
    DATA "{X}(1){P}1(0,0,-100){M}(2){D}(100,0,8,2,1)"
    DATA "{X}(0){P}1(0,0,100){M}(2){D}(100,0,8,2,1)"
    DATA "<CYL6_C>"
    DATA "{M}(1){C}(100,100,6,2,200,0)"
    DATA "{X}(1){P}1(0,0,-100){M}(2){D}(100,0,6,2,1)"
    DATA "{X}(0){P}1(0,0,100){M}(2){D}(100,0,6,2,1)"


    DATA "<CONE_Q>"
    DATA "{M}(1){C}(100,.1,50,10,200,0)"
    DATA "<CONE>"
    DATA "{M}(1){C}(100,.1,30,10,200,0)"
    DATA "<CONE_F>"
    DATA "{M}(1){C}(100,.1,12,4,200,0)"
    DATA "<CONE8>"
    DATA "{M}(1){C}(100,.1,8,2,200,0)"
    DATA "<CONE6>"
    DATA "{M}(1){C}(100,.1,6,2,200,0)"
    DATA "<CONE_C>"
    ' with bottom
    DATA "{M}(1){C}(100,.1,30,10,200,0)"
    DATA "{X}(1){P}1(0,0,-100){M}(2){D}(100,0,30,10,1)"
    DATA "<CONE_FC>"
    DATA "{M}(1){C}(100,.1,12,4,200,0)"
    DATA "{X}(1){P}1(0,0,-100){M}(2){D}(100,0,12,4,1)"
    DATA "<CONE8_C>"
    DATA "{M}(1){C}(100,.1,8,2,200,0)"
    DATA "{X}(1){P}1(0,0,-100){M}(2){D}(100,0,8,2,1)"
    DATA "<CONE6_C>"
    DATA "{M}(1){C}(100,.1,6,2,200,0)"
    DATA "{X}(1){P}1(0,0,-100){M}(2){D}(100,0,6,2,1)"


    DATA "<DISK_Q>"
    DATA "{M}(1){D}(100,0,50,10,0)"
    DATA "<DISK>"
    DATA "{M}(1){D}(100,0,30,10,0)"
    DATA "<DISK_F>"
    DATA "{M}(1){D}(100,0,12,4,0)"
    DATA "<DISK8>"
    DATA "{M}(1){D}(100,0,8,2,0)"
    DATA "<DISK6>"
    DATA "{M}(1){D}(100,0,6,2,0)"

    DATA "<RING_Q>"
    DATA "{M}(1){D}(100,50,50,30,0)"
    DATA "<RING>"
    DATA "{M}(1){D}(100,50,30,20,0)"
    DATA "<RING_F>"
    DATA "{M}(1){D}(100,50,12,12,0)"
    DATA "<RING8>"
    DATA "{M}(1){D}(100,50,8,8,0)"
    DATA "<RING6>"
    DATA "{M}(1){D}(100,50,6,6,0)"







    LOCAL I&, CT&, T$, D$
    CT&=DATACOUNT
    T$=""
    FOR I&=1 TO CT&
        D$=READ$(I&)
        IF LEFT$(D$,1)="<" THEN App_EndCoreObjects&=App_EndCoreObjects&+1
        T$=T$+D$
    NEXT I&
    IF T$<>"" THEN AddNewObject T$
END SUB


'   sample format for EZObj files
'   <Name>  (S) - Sphere, {P} - points, {Q} - quads, {T} - Triangles
'  Point macros will ignore the number in front of each vertice, but put them there for eacy reading
' if point order (always sequential from 1 to #
' <PLANE>
' {P}1(-1,1,0)2(1,1,0)3(1,-1)4(-1,-1,0)
' {Q}(1,2,3,4)
' <CUBE>
' {P}1(-1,1,1)2(1,1,1)3(-1,-1,1)4(1,-1,1)5(-1,1,-1)6(1,1,-1)7(-1,-1,-1)8(1,-1,-1)
' {Q}(1,2,4,3)(5,6,8,7)(1,5,7,3)(2,6,8,4)(5,6,2,1)(7,8,4,3)

' <ROOF>
' {P}1(-1,-1,1)2(1,-1,1)3(-1,-1,-1)4(1,-1,-1)5(0,1,1)6(0,1,-1))
' {Q}(1,2,4,3)(3,6,5,1)(4,6,5,2)
' {T}(1,2,5)(3,4,6)

'    EnableBlend 1,1
'    glPolygonMode %GL_FRONT_AND_BACK, %GL_LINE  ' %GL_FILL
'    glLineWidth LineWidth!



SUB DrawSphere(BYVAL RadiusF AS SINGLE, BYVAL slicesF AS SINGLE, BYVAL stacksF AS SINGLE, BYVAL SolidFlag&, BYVAL LineWidth!, BYVAL AFlag&, BYVAL RVFlag&)
    LOCAL QObj AS DWORD, slices AS LONG, stacks AS LONG, Radius AS DOUBLE
    slices=INT(slicesF)
    stacks=INT(stacksF)
    Radius=RadiusF
    IF slices<=0 THEN slices=30
    IF stacks<=0 THEN stacks=30

    ' maybe I could try an z offset (further back) for the line version so it is behind solid version
    ' OpenGL does not draw lines exactly in the same position as a filled sphere, which causes a
    ' patterned effect.
    IF SolidFlag&<>0 THEN
        QObj=gluNewQuadric()
        gluQuadricDrawStyle QObj ,%GLU_FILL
        gluQuadricNormals QObj ,%GLU_SMOOTH
        gluQuadricOrientation QObj ,%GLU_OUTSIDE
        IF RVFlag& THEN gluQuadricTexture QObj, %GL_TRUE
        gluSphere QObj , Radius, slices, stacks
        ' gluCylinder QObj, Radius, TRadius, Height, slices, stacks
        gluDeleteQuadric QObj
    END IF

    IF SolidFlag&=0 THEN
        IF AFlag& THEN EnableBlend 1,1
        QObj=gluNewQuadric()
        glLineWidth LineWidth!
        gluQuadricDrawStyle QObj ,%GLU_LINE
        gluQuadricNormals QObj ,%GLU_SMOOTH
        gluQuadricOrientation QObj ,%GLU_OUTSIDE
        gluSphere QObj , Radius, slices, stacks
        ' gluCylinder QObj, Radius, TRadius, Height, slices, stacks
        gluDeleteQuadric QObj
        glLineWidth 1.0 ' set back to default
        IF AFlag& THEN EnableBlend 0,0
    END IF
END SUB

SUB RotatePos(BYVAL rCX!, BYVAL rCY!, BYVAL rCZ!)
    IF rCX!<>0 THEN glRotatef rCX!,1,0,0
    IF rCY!<>0 THEN glRotatef rCY!,0,1,0
    IF rCZ!<>0 THEN glRotatef rCZ!,0,0,1
END SUB

SUB DrawGLUObject(BYVAL mode&, BYVAL RType&, BYVAL Radius1 AS SINGLE, BYVAL Radius2 AS SINGLE, BYVAL slicesF AS SINGLE, BYVAL stacksF AS SINGLE, BYVAL Length AS SINGLE, BYVAL SolidFlag&, BYVAL LineWidth!, BYVAL AFlag&, _
                  BYVAL XScale!, BYVAL YScale!, BYVAL ZScale!, BYVAL X!, BYVAL Y!, BYVAL Z!)
    LOCAL QObj AS DWORD, slices AS LONG, stacks AS LONG, Radius AS DOUBLE, SRadius AS DOUBLE, Height AS DOUBLE, RVFlag&
    IF (Mode& AND 16) = 16 THEN
        RVFlag&=1
        Mode&=Mode& AND 15
    ELSE
        RVFlag&=0
    END IF
    slices=INT(slicesF)
    stacks=INT(stacksF)
    Radius=Radius1
    SRadius=Radius2

    IF slices<=0 THEN slices=30
    IF stacks<=0 THEN stacks=30
    IF X!=0 AND Y!=0 AND Z!=0 THEN

    ELSE
        glTranslatef X!,Y!,Z!
    END IF
    SELECT CASE AS LONG RType&
        CASE 1  ' top points toward -Z
            RotatePos 0,180,0
        CASE 2  ' top points toward +X
            RotatePos 0,90,0
        CASE 3  ' top points toward -X
            RotatePos 0,270,0
        CASE 4  ' top points toward +Y
            RotatePos 270,0,0
        CASE 5  ' top points toward -Y
            RotatePos 90,0,0
        CASE ELSE ' =0  top points toward +Z
            ' assumed
    END SELECT
    SELECT CASE AS LONG mode&
        CASE 1  ' Cylinder
            Height=ABS(Length)
            glTranslatef 0,0, -(Height/2)    ' centers cylinder on origin
    END SELECT
    glScalef XScale!, YScale!, ZScale!
    IF SolidFlag&<>0 THEN
        QObj=gluNewQuadric()
        gluQuadricDrawStyle QObj ,%GLU_FILL
        gluQuadricNormals QObj ,%GLU_SMOOTH
        gluQuadricOrientation QObj ,%GLU_OUTSIDE
        IF RVFlag& THEN gluQuadricTexture QObj, %GL_TRUE
        SELECT CASE AS LONG mode&
            CASE 1
                gluCylinder QObj, Radius, SRadius, Length, slices, stacks
            CASE 2
                gluDisk QObj, SRadius, Radius, slices, stacks
        END SELECT
        gluDeleteQuadric QObj
    END IF

    IF SolidFlag&=0 THEN
        IF AFlag& THEN EnableBlend 1,1
        QObj=gluNewQuadric()
        glLineWidth LineWidth!
        gluQuadricDrawStyle QObj ,%GLU_LINE
        gluQuadricNormals QObj ,%GLU_SMOOTH
        gluQuadricOrientation QObj ,%GLU_OUTSIDE
        SELECT CASE AS LONG mode&
            CASE 1
                gluCylinder QObj, Radius, SRadius, Height, slices, stacks
            CASE 2
                gluDisk QObj, SRadius, Radius, slices, stacks
        END SELECT
        gluDeleteQuadric QObj
        glLineWidth 1.0 ' set back to default
        IF AFlag& THEN EnableBlend 0,0
    END IF
END SUB


SUB GenNormals(BYVAL P AS SINGLE PTR, BYVAL N AS SINGLE PTR)   ' assume 9 singles in an array, then 3 singles in return array
     LOCAL V() AS SINGLE, L AS SINGLE
     DIM V(1 TO 9) AS SINGLE
     V(1)= @P[0]-@P[3]
     V(2)= @P[1]-@P[4]
     V(3)= @P[2]-@P[5]
     V(4)= @P[3]-@P[6]
     V(5)= @P[4]-@P[7]
     V(6)= @P[5]-@P[8]
     V(7)=(V(2)*V(6))-(V(3)*V(5))
     V(8)=(V(3)*V(4))-(V(1)*V(6))
     V(9)=(V(1)*V(5))-(V(2)*V(4))
     ' convert to unit 1
     L=SQR((V(7)*V(7))+(V(8)*V(8))+(V(9)*V(9)))
     IF L=0 THEN L=1
     @N[0]=V(7)/L
     @N[1]=V(8)/L
     @N[2]=V(9)/L
END SUB

SUB GenNormalsX(BYVAL X1!, BYVAL Y1!, BYVAL Z1!,BYVAL X2!, BYVAL Y2!, BYVAL Z2!,BYVAL X3!, BYVAL Y3!, BYVAL Z3!)
    LOCAL Vert() AS SINGLE
    DIM Vert(1 TO 12)
    Vert(1)=X1!
    Vert(2)=Y1!
    Vert(3)=Z1!
    Vert(4)=X2!
    Vert(5)=Y2!
    Vert(6)=Z2!
    Vert(7)=X3!
    Vert(8)=Y3!
    Vert(9)=Z3!
    GenNormals VARPTR(Vert(1)), VARPTR(Vert(10))
    glNormal3f Vert(10), Vert(11), Vert(12)
END SUB


%DefMatID   =   9

SUB DoDefaultColor(BYVAL I&, BYVAL CurMat&, BYVAL MatMode&, RVFlag&, TxMin!, TxMax!, AlphaFlag&, BYVAL gluQFlag&)
    LOCAL V() AS SINGLE, SP!, SH!, NW&, NH&, SizePat&, lpPixels AS DWORD, X&, Y&, XL&, lpPixels2 AS DWORD, J&, AFlag&, CA!
    STATIC NBuffer$
    DIM V(1 TO 4) AS SINGLE
    RVFlag&=0
    IF MatMode&=2 THEN  ' is a palette index
        IF I&>=0 AND I&<=UBOUND(App_Palettes) THEN
            IF LEN(App_Palettes(I&)) >= (CurMat&+1)*4 THEN
                I&=CVL(MID$(App_Palettes(I&),(CurMat&*4)+1,4))
            ELSE
                I&=%DefMatID
            END IF
        ELSE
            I&=%DefMatID    ' palette undefined so use default color
        END IF
    ELSE
        I&=I&+CurMat&   ' CurMat& is zero indexed
    END IF
    IF I&<0 THEN I&=%DefMatID
    IF I&>UBOUND(App_Material) THEN I&=%DefMatID    ' default blue
    IF App_Material(I&).CType&=0 THEN I&=%DefMatID  ' use default blue when material not defined
    IF App_Material(I&).AlphaFlag THEN AFlag&=1 ELSE AFlag&=0
    AlphaFlag&=AFlag&   ' set return value
    IF AFlag& THEN
        V(1)=SP!
        V(2)=SP!
        V(3)=SP!
        V(4)=1
        glMaterialfv %GL_BACK,%GL_SPECULAR, V(1)
    ELSE
        V(1)=.1
        V(2)=.1
        V(3)=.1
        V(4)=1
        glMaterialfv %GL_BACK,%GL_SPECULAR, V(1)
    END IF
    SP!=App_Material(I&).Specular
    V(1)=SP!
    V(2)=SP!
    V(3)=SP!
    V(4)=1
    glMaterialfv %GL_FRONT,%GL_SPECULAR, V(1)
    ' ----------------------------------------
    SH!=App_Material(I&).Shiny  ' 0 to 128
    CA!=(App_Material(I&).Red+App_Material(I&).Green+App_Material(I&).Blue)/3
    IF CA!<.05 THEN
        SH!=SH!/64
    ELSEIF CA!<.10 THEN
        SH!=SH!/256
    ELSE
        SH!=SH!/1024 ' gives a value from 0 to .125
    END IF
    ' the darker the color the more that you can increase
    ' emission values
    ' Emission transformed into relation to actual color
    V(1)=SH!*App_Material(I&).Red
    V(2)=SH!*App_Material(I&).Green
    V(3)=SH!*App_Material(I&).Blue
    V(4)=0
    glMaterialfv %GL_FRONT,%GL_EMISSION, V(1)
    IF AFlag& THEN
        V(1)=SH!*App_Material(I&).Red
        V(2)=SH!*App_Material(I&).Green
        V(3)=SH!*App_Material(I&).Blue
        V(4)=0
        glMaterialfv %GL_BACK,%GL_EMISSION, V(1)
    ELSE
        V(1)=0
        V(2)=0
        V(3)=0
        V(4)=0
        glMaterialfv %GL_BACK,%GL_EMISSION, V(1)
    END IF
    ' ----------------------------------------
    IF AFlag& THEN
        glMateriali %GL_BACK,%GL_SHININESS, App_Material(I&).Shiny
    ELSE
        glMateriali %GL_BACK,%GL_SHININESS,0
    END IF
    glMateriali %GL_FRONT,%GL_SHININESS, App_Material(I&).Shiny
    ' ----------------------------------------
    TxMin!  = 0     ' defaults for glGenTexCoord
    TxMax!  = 1
    IF App_Material(I&).CType&=2 THEN   ' a textures
        ' ----------------------------------------
        IF LEN(App_MaterialDataMap(I&))<>0 THEN
'            glEnable %GL_TEXTURE_GEN_S
'            glEnable %GL_TEXTURE_GEN_T
'            glEnable %GL_TEXTURE_GEN_R
'            glEnable %GL_TEXTURE_GEN_Q

            SizePat&=1  ' increase size by this amount
            TxMin!  = App_Material(I&).TexMin
            TxMax!  = App_Material(I&).TexMax
            IF gluQFlag& THEN
                IF TXMax!>=2 THEN SizePat&=INT(TXMax!)
            END IF
            NW&=App_Material(I&).BmpW
            NH&=App_Material(I&).BmpH
            IF SizePat&<=1 THEN
                lpPixels=STRPTR(App_MaterialDataMap(I&))
            ELSE
                NBuffer$=STRING$(NW&*NH&*4*SizePat&*SizePat&, CHR$(0))
                XL&=NW&*4
                lpPixels2=STRPTR(NBuffer$)
                FOR J&=1 TO SizePat&
                    lpPixels=STRPTR(App_MaterialDataMap(I&))
                    FOR Y&=1 TO NH&
                        FOR X&=1 TO SizePat&
                            POKE$ lpPixels2, PEEK$(lpPixels, XL&)
                            lpPixels2=lpPixels2+XL&
                        NEXT X&
                        lpPixels=lpPixels+XL&
                    NEXT Y&
                NEXT J&
                NW&=NW&*SizePat&
                NH&=NH&*SizePat&
                lpPixels=STRPTR(NBuffer$)   ' new enlarged buffer
            END IF

            glEnable %GL_TEXTURE_2D
            glPixelStorei %GL_UNPACK_SWAP_BYTES,0
            glPixelStorei %GL_UNPACK_LSB_FIRST,0
            glPixelStorei %GL_UNPACK_ROW_LENGTH, NW&
            glPixelStorei %GL_UNPACK_SKIP_ROWS,0
            glPixelStorei %GL_UNPACK_SKIP_PIXELS,0
            glPixelStorei %GL_UNPACK_ALIGNMENT,4
            ' -----------------------------------
            glPixelTransferi %GL_MAP_COLOR, 0   ' must be zero
            ' ------- rest are Floats ---------------
            ' scale darkens or lightens the colors (1.0 is normal, <1.0 is darker, >1.0 is lighter)
            glPixelTransferf %GL_RED_SCALE, 1.0
            glPixelTransferf %GL_RED_BIAS, 0
            glPixelTransferf %GL_GREEN_SCALE, 1.0
            glPixelTransferf %GL_GREEN_BIAS, 0
            glPixelTransferf %GL_BLUE_SCALE, 1.0
            glPixelTransferf %GL_BLUE_BIAS, 0
            IF AFlag& THEN
                glPixelTransferf %GL_ALPHA_SCALE, App_Material(I&).Alpha
            ELSE
                glPixelTransferf %GL_ALPHA_SCALE, 1.0
            END IF
            glPixelTransferf %GL_ALPHA_BIAS, 0
            glTexParameteri %GL_TEXTURE_2D, %GL_TEXTURE_WRAP_S, %GL_REPEAT
            glTexParameteri %GL_TEXTURE_2D, %GL_TEXTURE_WRAP_T, %GL_REPEAT
            glTexEnvi %GL_TEXTURE_ENV,%GL_TEXTURE_ENV_MODE, %GL_MODULATE

'            glTexImage2D %GL_TEXTURE_2D, 0, 4,App_Material(I&).BmpW,App_Material(I&).BmpH,0,%GL_RGBA, %GL_UNSIGNED_BYTE,STRPTR(App_MaterialDataMap(I&))
            gluBuild2DMipmaps %GL_TEXTURE_2D,%GL_RGBA,NW&,NH&,%GL_RGBA, %GL_UNSIGNED_BYTE,lpPixels
            ' try different parameter values here to see effect
            IF AFlag& THEN
                glColor4f App_Material(I&).Red,App_Material(I&).Green,App_Material(I&).Blue, App_Material(I&).Alpha
            ELSE
                glColor3f App_Material(I&).Red,App_Material(I&).Green,App_Material(I&).Blue
            END IF
            RVFlag&=1  ' flag indicating a texture was used
        ELSE    ' not bitmap texture so use color
            IF AFlag& THEN
                glColor4f App_Material(I&).Red,App_Material(I&).Green,App_Material(I&).Blue, App_Material(I&).Alpha
            ELSE
                glColor3f App_Material(I&).Red,App_Material(I&).Green,App_Material(I&).Blue
            END IF
        END IF
        ' ----------------------------------------
    ELSE
        ' ----------------------------------------
            IF AFlag& THEN
                glColor4f App_Material(I&).Red,App_Material(I&).Green,App_Material(I&).Blue, App_Material(I&).Alpha
            ELSE
                glColor3f App_Material(I&).Red,App_Material(I&).Green,App_Material(I&).Blue
            END IF
        ' ----------------------------------------
    END IF

'   App_Material(I&).CType&=1   ' defined as color
'   App_Material(I&).CType&=2   ' defined as texture
'   App_Material(I&).hBitmap



END SUB


SUB TestSub(BYVAL X!,BYVAL Y!, BYVAL Z!)
END SUB

'TYPE EZObjHeader    ' must be 84 bytes total!
'    OType AS INTEGER     ' 2 bytes  ( = 7 if STL Enhanced, = 8 if EZGUI Optimized)
'    Count1 AS INTEGER    ' 2 bytes  ( = count if less than 32000, = -1 if > 32000
'    Count2 AS LONG       ' 4 bytes  ( actual count if first one is -1)
'    ScaleX AS SINGLE     ' 4 bytes
'    ScaleY AS SINGLE     ' 4 bytes
'    ScaleZ AS SINGLE     ' 4 bytes
'    ColorFlag AS SINGLE  ' 4 bytes
'    dummy AS STRING*42   ' 42 bytes
'    Version AS LONG      ' 4 bytes
'    WhoAmI AS STRING*10  ' has the text: "EZGUIModel"  (you can use any name you prefer, but EZGUI requires this name)
'    STLSize AS DWORD     ' 4 bytes  (STL Header polygon count)
'END TYPE


%MaxPoints      =   50

SUB DrawOne3DObject(BYVAL OID&, BYVAL QName AS QUAD, BYVAL XScale!, BYVAL YScale!, BYVAL ZScale!, BYVAL MatID&, BYVAL MatMode&, BYVAL SolidFlag&, BYVAL LineWidth!, BYVAL AntiAlias&,BYVAL CBA AS DWORD, BYVAL DListID&, BYVAL DListFlag&)
    LOCAL V$, F AS SINGLE PTR, I AS INTEGER PTR, CT&, N&, DType&, PCount&, J&, DCount&, E&, M&
    LOCAL P() AS SINGLE, VERT() AS SINGLE, SFlag&, SCALE() AS SINGLE, PI&, LastE AS SINGLE, NewE AS SINGLE
    LOCAL Material AS SINGLE, Sphere() AS SINGLE, NCount&, AFlag&, RVFlag&, OldMaterial AS SINGLE, BI AS LONG PTR, TVert AS SINGLE PTR, TexC AS SINGLE PTR
    LOCAL CombineXScale!,CombineYScale!,CombineZScale!, GMode&
    LOCAL Mat1&,OldMat1&, lpVertArray AS DWORD, lpNormArray AS DWORD, lpTexCoord AS DWORD
    LOCAL TXZero!, TXMax!, lpMat AS WORD PTR, TCount&, CurMat&, FirstMatFlag&
    LOCAL EZO AS EZObjHeader PTR, RType!, AlphaFlag&, gluQFlag&
    REGISTER FastRVFlag&, FastBegin&
    STATIC CUSTOM AS QUAD
    DIM P(1 TO %MaxPoints,1 TO 3)   ' store temporary point vertices
    DIM Vert(1 TO 12) AS SINGLE
    DIM SCALE(1 TO 3) AS SINGLE
    DIM Sphere(1 TO 6) AS SINGLE
    TXZero!    = 0     ' will be changed by DoDefaultColor call
    TXMax!     = 1     ' will be changed by DoDefaultColor call
    IF DListFlag&=0 THEN    ' draw mode only
        IF DListID&<>0 THEN ' use the display list
            glCallList DListID&
            EXIT SUB
        END IF
    END IF
    IF CUSTOM=0 THEN CUSTOM=QObject("CUSTOM")
    RVFlag&=0
    IF QName=CUSTOM THEN
        IF CBA<>0 THEN  ' callback for custom objects
            AFlag&=0
            IF AntiAlias&<>0 THEN AFlag&=1
            Material  = 1
            GOSUB DoLineStuff1
            GOSUB SetMaterial
            CALL DWORD CBA USING OpenGLCallBackX(2, OID&,SolidFlag&,AntiAlias&,CODEPTR(GenNormalsX),XScale!, YScale!, ZScale!)
            GOSUB DoLineStuff2
            IF RVFlag& THEN GOSUB End2DTex
        END IF
    END IF
    ARRAY SCAN App_ObjName(1) FOR App_LastObject&, = QName, TO M&
    IF M&<>0 THEN
        AFlag&=0
        IF AntiAlias&<>0 THEN AFlag&=1
'        V$=App_ObjDraw(M&)
'        CT&=LEN(V$)\4
'        I=STRPTR(V$)
        CT&=LEN(App_ObjDraw(M&))\4
        I=STRPTR(App_ObjDraw(M&))

        N&=1
        SCALE(1)=1
        SCALE(2)=1
        SCALE(3)=1
        OldMaterial = 0
        Material    = 1
        RType!=0    ' Glu objects point towards +Z axis
        FirstMatFlag&=1
        DO
            IF N&<=CT& THEN
                DType&=@I[0]
                PCount&=@I[1]   ' maximum count is %MaxPoints
                N&=N&+1
                F=I+4
                gluQFlag&=0
                SELECT CASE AS LONG DType&
                    CASE 1  ' points
                        DCount&=3
                    CASE 2  ' world limits (ie. a world limit of 100 means coordinates will be scaled 1/100)
                        DCount&=3
                    CASE 3  ' Triangles
                        IF FirstMatFlag& THEN GOSUB SetMaterial
                        FirstMatFlag&=0
                        DCount&=3
                        GOSUB DoLineStuff1
                        glBegin %GL_TRIANGLES
                    CASE 4  ' Quads
                        IF FirstMatFlag& THEN GOSUB SetMaterial
                        FirstMatFlag&=0
                        DCount&=4
                        GOSUB DoLineStuff1
                        glBegin %GL_QUADS
                    CASE 5  ' materials
                        DCount&=1
                    CASE 6  ' sphere
                        gluQFlag&=1
                        IF FirstMatFlag& THEN GOSUB SetMaterial
                        FirstMatFlag&=0
                        DCount&=4
                    CASE 20 ' cylinder
                        gluQFlag&=1
                        IF FirstMatFlag& THEN GOSUB SetMaterial
                        FirstMatFlag&=0
                        DCount&=6
                    CASE 21 ' disk (round circle)
                        gluQFlag&=1
                        IF FirstMatFlag& THEN GOSUB SetMaterial
                        FirstMatFlag&=0
                        DCount&=5
                    CASE 30 ' direction flag
                        DCount&=1
                    CASE 8  ' Optimized Model for Vertex Array drawing
                        ' Vertex Array starts at STRPTR()+84            (three singles per vertext)
                        ' Normal Array starts at STRPTR()+84+(CT&*36)   (three singles per vertext)
                        ' TexCoord Array starts as STRPTR()+84+(CT&*72) (two singles per vertext)
                        ' Color Tracking Array starts at STRPTR()+84+(CT&*96)   (only a word to store Material ID for triangle(3 vertice))
                        IF PCount&=-1 THEN
                            ' count is larger than can be held in Integer (2 byte) variable
                            ' so next 4 bytes is a LONG with actual count
                            BI=I+4
                            PCount&=@BI
                        END IF
                        EZO=I
                        SCALE(1)=@EZO.ScaleX
                        SCALE(2)=@EZO.ScaleY
                        SCALE(3)=@EZO.ScaleZ

'                        TVert=I+8
'                        Scale(1)=@TVert[0]
'                        Scale(2)=@TVert[1]
'                        Scale(3)=@TVert[2]

                        CombineXScale!=XScale!*SCALE(1)
                        CombineYScale!=YScale!*SCALE(2)
                        CombineZScale!=ZScale!*SCALE(3)
                        glScalef CombineXScale!,CombineYScale!,CombineZScale!

                        lpVertArray =I+84
                        lpNormArray =I+84+(PCount&*36)
                        lpTexCoord  =I+84+(PCount&*72)
                        lpMat       =I+84+(PCount&*96)
                        TexC=lpTexCoord     ' Single pointer
                        GOSUB SetMaterial
                        GOSUB DoLineStuff1
                        ' prepare TexCoord values   (no matter what)

'                        FOR J&=1 TO PCount&
'                            @TexC[0]=TXZero!
'                            @TexC[1]=TXZero!
'                            @TexC[2]=TXMax!
'                            @TexC[3]=TXZero!
'                            @TexC[4]=TXMax!
'                            @TexC[5]=TXMax!
'                            TexC=TexC+24
'                        NEXT J&
                        FastBegin&=1
                        TCount&=0
                        CurMat&=1
                        FastBegin&=1
                        glEnableClientState %GL_VERTEX_ARRAY
                        glVertexPointer 3,%GL_FLOAT,0,lpVertArray
                        glEnableClientState %GL_NORMAL_ARRAY
                        glNormalPointer %GL_FLOAT,0,lpNormArray
                        glDisableClientState %GL_COLOR_ARRAY
                        glDisableClientState %GL_INDEX_ARRAY
                        glDisableClientState %GL_EDGE_FLAG_ARRAY
                        RVFlag&=0
                        FastRVFlag&=0
                        FOR J&=1 TO PCount&
                            IF MatMode&<>0 THEN  ' multi-colored
                                IF @lpMat<>0 THEN
                                    IF @lpMat<>CurMat& THEN ' color change
                                        FastBegin&=1
                                        CurMat&=@lpMat
                                    END IF
                                END IF
                            END IF
                            IF FastBegin&=1 THEN
                                IF TCount&<>0 THEN  ' draw previous stuff
                                    ' -----------------------------------------------
                                    ' draw now
                                    IF RVFlag&=0 THEN
                                        glDisableClientState %GL_TEXTURE_COORD_ARRAY
                                    ELSE
                                        glEnableClientState %GL_TEXTURE_COORD_ARRAY
                                        glTexCoordPointer 2, %GL_FLOAT,0,lpTexCoord
                                    END IF
                                    glDrawArrays %GL_TRIANGLES,(J&-TCount&-1)*3,TCount&*3
                                    ' -----------------------------------------------
                                    TCount&=0
                                END IF
                                IF MatMode&=0 THEN    ' solid color
                                    IF J&=1 THEN
                                         DoDefaultColor MatID&,0, MatMode&,RVFlag&, TXZero!, TXMax!, AlphaFlag&,0
                                         GOSUB SetAlpha
                                    END IF
                                ELSE
                                    DoDefaultColor MatID&,CurMat&-1, MatMode&, RVFlag&, TXZero!, TXMax!, AlphaFlag&,0
                                    GOSUB SetAlpha
                                END IF
                                FastRVFlag&=RVFlag&
                                FastBegin&=0
                            END IF
                            INCR lpMat
                            TCount&=TCount&+1   ' count triangles
                            IF FastRVFlag& THEN
                                @TexC[0]=TXZero!
                                @TexC[1]=TXZero!
                                @TexC[2]=TXMax!
                                @TexC[3]=TXZero!
                                @TexC[4]=TXMax!
                                @TexC[5]=TXMax!
                            END IF
                            TexC=TexC+24
                        NEXT J&
                        IF TCount&<>0 THEN
                            ' -----------------------------------------------
                            ' draw now
                            IF RVFlag&=0 THEN
                                glDisableClientState %GL_TEXTURE_COORD_ARRAY
                            ELSE
                                glEnableClientState %GL_TEXTURE_COORD_ARRAY
                                glTexCoordPointer 2, %GL_FLOAT,0,lpTexCoord
                            END IF
                            glDrawArrays %GL_TRIANGLES,(PCount&-TCount&)*3,TCount&*3
                            ' -----------------------------------------------
                        END IF
                        GOSUB DoLineStuff2
                        IF RVFlag& THEN GOSUB End2DTex
                        EXIT LOOP
                    CASE 7  ' STLB (binary STL) 3D Model as set of triangles
                        IF PCount&=-1 THEN
                            ' count is larger than can be held in Integer (2 byte) variable
                            ' so next 4 bytes is a LONG with actual count
                            BI=I+4
                            PCount&=@BI
                        END IF
                        GOSUB SetMaterial
                        GOSUB DoLineStuff1
                        EZO=I
                        SCALE(1)=@EZO.ScaleX
                        SCALE(2)=@EZO.ScaleY
                        SCALE(3)=@EZO.ScaleZ

'                        TVert=I+8
'                        Scale(1)=@TVert[0]
'                        Scale(2)=@TVert[1]
'                        Scale(3)=@TVert[2]

                        TVert=I+84 ' pass pointer to string data
                        CombineXScale!=XScale!*SCALE(1)
                        CombineYScale!=YScale!*SCALE(2)
                        CombineZScale!=ZScale!*SCALE(3)
                        IF MatMode&=0 THEN   ' solid Material
                            IF RVFlag&=0 THEN
                                glScalef CombineXScale!,CombineYScale!,CombineZScale!
                                glBegin %GL_TRIANGLES
                                FOR J&=1 TO PCount&
                                    glNormal3f @TVert[0],@TVert[1],@TVert[2]
                                    glVertex3f @TVert[3],@TVert[4],@TVert[5]
                                    glVertex3f @TVert[6],@TVert[7],@TVert[8]
                                    glVertex3f @TVert[9],@TVert[10],@TVert[11]

                                    TVert=TVert+50
                                NEXT J&
                                glEnd
                            ELSE
                                glScalef CombineXScale!,CombineYScale!,CombineZScale!
                                glBegin %GL_TRIANGLES
                                FOR J&=1 TO PCount&
                                    glNormal3f @TVert[0],@TVert[1],@TVert[2]
                                    glTexCoord2f TXZero!,TXZero!
'                                    glVertex3f @TVert[3]*CombineXScale!,@TVert[4]*CombineYScale!,@TVert[5]*CombineZScale!
                                    glVertex3f @TVert[3],@TVert[4],@TVert[5]
                                    glTexCoord2f TXMax!,TXZero!
'                                    glVertex3f @TVert[6]*CombineXScale!,@TVert[7]*CombineYScale!,@TVert[8]*CombineZScale!
                                    glVertex3f @TVert[6],@TVert[7],@TVert[8]
                                    glTexCoord2f TXMax!,TXMax!
'                                    glVertex3f @TVert[9]*CombineXScale!,@TVert[10]*CombineYScale!,@TVert[11]*CombineZScale!
                                    glVertex3f @TVert[9],@TVert[10],@TVert[11]
                                    TVert=TVert+50
                                NEXT J&
                                glEnd
                            END IF
                        ELSE    ' not a solid color but multi-colors
                            lpMat=TVert+48  ' get color word at end of each vertice
                            OldMat1&=1
                            Mat1&=1
                            FastRVFlag&=RVFlag&
                            FastBegin&=1
                            glScalef CombineXScale!,CombineYScale!,CombineZScale!
                            FOR J&=1 TO PCount&
                                ' when Material is zero, it means don't change it
                                IF @lpMat<>0 THEN
                                    Mat1&=@lpMat    ' always positive because it is a WORD
                                    IF (MatID&+Mat1&)-1 > UBOUND(App_Material) THEN Mat1&=1
                                    IF Mat1&<>OldMat1& THEN
                                        ' ------------------------
                                        IF FastBegin&=0 THEN
                                            glEnd
                                        END IF
                                        ' ------------------------
                                        DoDefaultColor MatID&, Mat1&-1,MatMode&, RVFlag&, TXZero!, TXMax!, AlphaFlag&,0
                                        GOSUB SetAlpha
                                        ' ------------------------
                                        Fastbegin&=1
                                        ' ------------------------
                                        FastRVFlag&=RVFlag&
                                        OldMat1&=Mat1&
                                    END IF
                                END IF
                                IF FastBegin&=1 THEN
                                    glBegin %GL_TRIANGLES
                                    FastBegin&=0
                                END IF
                                glNormal3f @TVert[0],@TVert[1],@TVert[2]
                                IF FastRVFlag& THEN glTexCoord2f TXZero!,TXZero!
'                                glVertex3f @TVert[3]*CombineXScale!,@TVert[4]*CombineYScale!,@TVert[5]*CombineZScale!
                                glVertex3f @TVert[3],@TVert[4],@TVert[5]
                                IF FastRVFlag& THEN glTexCoord2f TXMax!,TXZero!
'                                glVertex3f @TVert[6]*CombineXScale!,@TVert[7]*CombineYScale!,@TVert[8]*CombineZScale!
                                glVertex3f @TVert[6],@TVert[7],@TVert[8]
                                IF FastRVFlag& THEN glTexCoord2f TXMax!,TXMax!
'                                glVertex3f @TVert[9]*CombineXScale!,@TVert[10]*CombineYScale!,@TVert[11]*CombineZScale!
                                glVertex3f @TVert[9],@TVert[10],@TVert[11]
                                TVert=TVert+50
                                lpMat=lpMat+50
                            NEXT J&
                            glEnd
                        END IF
                        GOSUB DoLineStuff2
                        IF RVFlag& THEN GOSUB End2DTex
                        EXIT LOOP
                    CASE ELSE
                        EXIT LOOP
                END SELECT
                FOR J&=1 TO PCount&
                    NCount&=0
                    FOR E&=1 TO DCount&
                        IF N&<=CT& THEN
                            SELECT CASE AS LONG DType&
                                CASE 1
                                    IF J&<=%MaxPoints THEN P(J&,E&)=@F
                                CASE 2
                                    IF @F>0 THEN    ' don't divide by zero
                                        SCALE(E&)=@F    ' 1/@F
                                    ELSE
                                        SCALE(E&)=1
                                    END IF
                                CASE 3,4
                                    NCount&=NCount&+1
'                                    IF NCount&=1 THEN
'                                        GOSUB SetMaterial
'                                    END IF
                                    PI&=INT(@F)
                                    IF PI&<1 THEN PI&=1
                                    IF PI&>%MaxPoints THEN PI&=%MaxPoints
                                    SELECT CASE AS LONG NCount&
                                        CASE 1
                                            Vert(1)=(P(PI&,1)*SCALE(1))*XScale!
                                            Vert(2)=(P(PI&,2)*SCALE(2))*YScale!
                                            Vert(3)=(P(PI&,3)*SCALE(3))*ZScale!
                                        CASE 2
                                            Vert(4)=(P(PI&,1)*SCALE(1))*XScale!
                                            Vert(5)=(P(PI&,2)*SCALE(2))*YScale!
                                            Vert(6)=(P(PI&,3)*SCALE(3))*ZScale!
                                        CASE 3
                                            Vert(7)=(P(PI&,1)*SCALE(1))*XScale!
                                            Vert(8)=(P(PI&,2)*SCALE(2))*YScale!
                                            Vert(9)=(P(PI&,3)*SCALE(3))*ZScale!
                                            GenNormals VARPTR(Vert(1)), VARPTR(Vert(10))
                                            glNormal3f Vert(10), Vert(11), Vert(12)
                                            IF RVFlag& THEN glTexCoord2f TXZero!,TXZero!
                                            glVertex3f Vert(1), Vert(2), Vert(3)
                                            IF RVFlag& THEN glTexCoord2f TXMax!,TXZero!
                                            glVertex3f Vert(4), Vert(5), Vert(6)
                                            IF RVFlag& THEN glTexCoord2f TXMax!,TXMax!
                                            glVertex3f Vert(7), Vert(8), Vert(9)
                                        CASE 4
                                            Vert(1)=(P(PI&,1)*SCALE(1))*XScale!
                                            Vert(2)=(P(PI&,2)*SCALE(2))*YScale!
                                            Vert(3)=(P(PI&,3)*SCALE(3))*ZScale!
                                            IF RVFlag& THEN glTexCoord2f TXZero!,TXMax!
                                            glVertex3f Vert(1), Vert(2), Vert(3)
                                        CASE ELSE
                                            Vert(1)=(P(PI&,1)*SCALE(1))*XScale!
                                            Vert(2)=(P(PI&,2)*SCALE(2))*YScale!
                                            Vert(3)=(P(PI&,3)*SCALE(3))*ZScale!
                                            IF RVFlag& THEN glTexCoord2f TXZero!,TXMax!
                                            glVertex3f Vert(1), Vert(2), Vert(3)
                                    END SELECT
                                CASE 5
                                    IF MatMode&<>0 THEN    ' multi colored
                                        FirstMatFlag&=1 ' next Polygon drawn must select new color
                                        Material=@F ' current only one parameter for materials
                                        IF (ABS(MatID&)+Material)-1 > UBOUND(App_Material) THEN Material=1
                                    END IF
                                CASE 6, 20,21
                                    Sphere(E&)=@F
                                CASE 30
                                    RType!=@F
                                CASE ELSE
                            ' @F holds the current parameter value
                            END SELECT
                            INCR F
                        END IF
                        N&=N&+1
                    NEXT E&
                NEXT J&
                I=F
                SELECT CASE AS LONG DType&
                    CASE 1
                    CASE 2
                    CASE 3
                        glEnd
                        GOSUB DoLineStuff2
'                        IF RVFlag& THEN GOSUB End2DTex
                    CASE 4
                        glEnd
                        GOSUB DoLineStuff2
'                        IF RVFlag& THEN GOSUB End2DTex
                    CASE 6
                        glPushMatrix
                        IF Sphere(4)<0 THEN Sphere(4)=0
                        IF Sphere(4)>%MaxPoints THEN Sphere(4)=%MaxPoints
                        PI&=INT(Sphere(4))
                        IF PI&<>0 THEN
                            glTranslatef P(PI&,1),P(PI&,2),P(PI&,3)
                        END IF
                        glScalef XScale!*SCALE(1), YScale!*SCALE(2), ZScale!*SCALE(3)
                        DrawSphere Sphere(1),Sphere(2),Sphere(3),SolidFlag&, LineWidth!, AntiAlias&, RVFlag&
'                        IF RVFlag& THEN GOSUB End2DTex
                        glPopMatrix
                    CASE 20
                        glPushMatrix
                        IF Sphere(6)<0 THEN Sphere(6)=0
                        IF Sphere(6)>%MaxPoints THEN Sphere(6)=%MaxPoints
                        PI&=INT(Sphere(6))
                        GMode&=1
                        IF RVFlag& THEN GMode&=GMode& OR 16
                        IF PI&<>0 THEN
                            DrawGLUObject GMode&, INT(RType!), Sphere(1), Sphere(2), Sphere(3), Sphere(4), Sphere(5),SolidFlag&, LineWidth!,AntiAlias&,XScale!*SCALE(1), YScale!*SCALE(2), ZScale!*SCALE(3), P(PI&,1),P(PI&,2),P(PI&,3)
                        ELSE
                            DrawGLUObject GMode&, INT(RType!), Sphere(1), Sphere(2), Sphere(3), Sphere(4), Sphere(5),SolidFlag&, LineWidth!,AntiAlias&,XScale!*SCALE(1), YScale!*SCALE(2), ZScale!*SCALE(3), 0,0,0
                        END IF
'                        IF RVFlag& THEN GOSUB End2DTex
                        glPopMatrix
                    CASE 21
                        glPushMatrix
                        IF Sphere(5)<0 THEN Sphere(5)=0
                        IF Sphere(5)>%MaxPoints THEN Sphere(5)=%MaxPoints
                        PI&=INT(Sphere(5))
                        GMode&=2
                        IF RVFlag& THEN GMode&=GMode& OR 16
                        IF PI&<>0 THEN
                            DrawGLUObject GMode&, INT(RType!), Sphere(1), Sphere(2), Sphere(3), Sphere(4), 0,SolidFlag&, LineWidth!,AntiAlias&,XScale!*SCALE(1), YScale!*SCALE(2), ZScale!*SCALE(3), P(PI&,1),P(PI&,2),P(PI&,3)
                        ELSE
                            DrawGLUObject GMode&, INT(RType!), Sphere(1), Sphere(2), Sphere(3), Sphere(4), 0,SolidFlag&, LineWidth!,AntiAlias&,XScale!*SCALE(1), YScale!*SCALE(2), ZScale!*SCALE(3), 0,0,0
                        END IF
'                        IF RVFlag& THEN GOSUB End2DTex
                        glPopMatrix
                    CASE ELSE
                END SELECT
            ELSE
                EXIT LOOP
            END IF
        LOOP

    END IF
    IF RVFlag& THEN GOSUB End2DTex
    IF AlphaFlag& THEN EnableBlend 0,0
    EXIT SUB

SetMaterial:
    IF Material<>OldMaterial THEN
        IF MatMode&=0 THEN
            IF RVFlag& THEN GOSUB End2DTex
            DoDefaultColor MatID&,0, MatMode&, RVFlag&, TXZero!, TXMax!, AlphaFlag&,gluQFlag&
            GOSUB SetAlpha
        ELSE
            ' if MatMode&>1 then it is a Palette so use indexed value from a palette
            IF RVFlag& THEN GOSUB End2DTex
            DoDefaultColor MatID&, INT(Material)-1,MatMode&, RVFlag&, TXZero!, TXMax!, AlphaFlag&,gluQFlag&
            GOSUB SetAlpha
        END IF
        OldMaterial=Material
    END IF
RETURN

SetAlpha:
    IF AlphaFlag& THEN
        EnableBlend 1,1
    ELSE
        EnableBlend 0,0
    END IF
RETURN

DoLineStuff1:
'    IF DListFlag&=0 THEN
        IF AFlag& THEN EnableBlend 1,1:AlphaFlag&=1
        IF SolidFlag&=0 THEN
            glPolygonMode %GL_FRONT_AND_BACK, %GL_LINE
            glLineWidth LineWidth!
        END IF
'    END IF
RETURN

DoLineStuff2:
'    IF DListFlag&=0 THEN
        IF AFlag& THEN EnableBlend 0,0:AlphaFlag&=0
        IF SolidFlag&=0 THEN
            glPolygonMode %GL_FRONT_AND_BACK, %GL_FILL
            glLineWidth 1.0
        END IF
'    END IF
RETURN

End2DTex:
    glDisable %GL_Texture_2D
RETURN

END SUB


'                     Scale size:        Position:     Rotation:    Scene Rotation:
' SetOrigins: ScaleX!, ScaleY!, ScaleZ!, X!, Y!, Z!, rX!, rY!, rZ!, rCX!, rCY!, rCZ!

SUB SetOrigins(BYVAL ScaleX!, BYVAL ScaleY!, BYVAL ScaleZ!, BYVAL X!, BYVAL Y!, BYVAL Z!, BYVAL rX!, BYVAL rY!, BYVAL rZ!, BYVAL rCX!, BYVAL rCY!, BYVAL rCZ!)
    ' assume Modelview matrix
    glPushMatrix
    glTranslatef 0,0,0  ' redundant

    ' rotate from scene center
    IF rCX!<>0 THEN glRotatef rCX!,1,0,0
    IF rCY!<>0 THEN glRotatef rCY!,0,1,0
    IF rCZ!<>0 THEN glRotatef rCZ!,0,0,1

    glTranslatef X!,Y!,Z!

    IF rX!<>0 THEN glRotatef rX!,1,0,0
    IF rY!<>0 THEN glRotatef rY!,0,1,0
    IF rZ!<>0 THEN glRotatef rZ!,0,0,1

    glScalef ScaleX!,ScaleY!,ScaleZ!
END SUB

' YDeg& = 0 to 359 degrees (0 degrees is coming from viewer)
' XDeg& = 0 to 90 degrees (0 degrees is eye level from viewer)
' ZDist& is distance from center of scene (viewer is 1 unit from center)
' ALevel& is level of ambient light (0 to 100)
' DLevel& is level of diffuse light (0 to 100)


SUB SetLight(BYVAL UseLight&, BYVAL YDeg&, BYVAL XDeg&, BYVAL ZDist&, BYVAL ALevel&, BYVAL DLevel&)
    LOCAL V() AS SINGLE, Scale!, WLight&
    LOCAL ALev!, DLev!
    DIM V(1 TO 4) AS SINGLE
    IF UseLight&<>0 THEN
        IF ALevel&<0 THEN ALevel&=0
        IF ALevel&>100 THEN ALevel&=100
        IF DLevel&<0 THEN DLevel&=0
        IF DLevel&>100 THEN DLevel&=100
        ALev!=ALevel&/100!
        DLev!=DLevel&/100!
        IF UseLight&=1 THEN
            glShadeModel %GL_SMOOTH
            glEnable %GL_LIGHTING
            V(1)=ALev!:V(2)=ALev!:V(3)=ALev!:V(4)=1.0
            glLightModelfv %GL_LIGHT_MODEL_AMBIENT,V(1)
            glColorMaterial %GL_FRONT_AND_BACK, %GL_AMBIENT_AND_DIFFUSE
            WLight&=%GL_LIGHT0
        ELSE
            WLight&=%GL_LIGHT1
        END IF
        ' -----------------------------------------------
        V(1)=ALev!:V(2)=ALev!:V(3)=ALev!:V(4)=1.0
        glLightfv WLight&, %GL_AMBIENT, V(1)
        ' -----------------------------------------------
        V(1)=DLev!:V(2)=DLev!:V(3)=DLev!:V(4)=1.0
        glLightfv WLight&, %GL_DIFFUSE, V(1)
        ' -----------------------------------------------
        DLev!=DLev!*2   ' make specular light twice the diffuse
        IF DLev!>1.0 THEN DLev!=1.0
        V(1)=DLev!:V(2)=DLev!:V(3)=DLev!:V(4)=1.0
        glLightfv WLight&, %GL_SPECULAR, V(1)
        ' -----------------------------------------------
        ' calculate light position
        Scale!=1000

        LOCAL AL!,RX!,RY!, RX2!, RY2!
        AL!=ZDist&*Scale!
        ' convert Degrees to floats later
        CalcPointF 0,0,AL!,YDeg&,RX!,RY!

        IF XDeg&>90 THEN XDeg&=90
        ' convert Degrees to floats later
        CalcPointF 0,0,AL!,XDeg&,RX2!,RY2!
        V(1)=(-RX!)/Scale!
        V(2)=(RX2!)/Scale!
        V(3)=(-RY!)/Scale!
        V(4)=0
        glLightfv WLight&, %GL_POSITION, V(1)


        V(1)=0
        V(2)=0
        V(3)=0
        V(4)=0
        glLightfv WLight&, %GL_SPOT_DIRECTION, V(1)
        V(1)=180 ' 0 to 90 or a value of 180
        glLightfv WLight&, %GL_SPOT_CUTOFF, V(1)
'        V(1)=64    ' 0 to 128
'        glLightfv %GL_LIGHT0, %GL_SPOT_EXPONENT, V(1)
        ' -----------------------------------------------
        glEnable WLight&
        IF UseLight&=1 THEN
            glFrontFace %GL_CCW ' polygons front face is counter clockwise points
            glEnable %GL_COLOR_MATERIAL
            glEnable %GL_NORMALIZE  ' critical to proper lighting and reflection (shinyness)
        END IF
    ELSE
        glDisable %GL_LIGHTING
        glDisable %GL_LIGHT0
        glDisable %GL_LIGHT1
        glDisable %GL_COLOR_MATERIAL
        glDisable %GL_NORMALIZE
    END IF
END SUB

'                     Scale size:        Position:     Rotation:    Scene Rotation:
' SetOrigins: ScaleX!, ScaleY!, ScaleZ!, X!, Y!, Z!, rX!, rY!, rZ!, rCX!, rCY!, rCZ!
' Draw Object also has its own world scaling:  SX!, SY!, SZ!

' scene objects are defined as follows:
' ObjectName(8 byte Quad) and then 17 singles:

TYPE EZGLOBJ
    QName AS QUAD
    VFlag AS LONG   ' is it visible
    ID AS LONG
    Material AS LONG    ' material is an offset for Material #1
    ScaleX AS SINGLE
    ScaleY AS SINGLE
    ScaleZ AS SINGLE
    X AS SINGLE
    Y AS SINGLE
    Z AS SINGLE
    rX AS SINGLE
    rY AS SINGLE
    rZ AS SINGLE
    rCX AS SINGLE
    rCY AS SINGLE
    rCZ AS SINGLE
    SX AS SINGLE
    SY AS SINGLE
    SZ AS SINGLE
    SceneX AS SINGLE
    SceneY AS SINGLE
    SceneZ AS SINGLE
    SolidFlag AS LONG
    LineWidth AS SINGLE
    AntiAlias AS LONG
    DListFlag AS LONG
    DListID AS LONG
    MatFlag AS LONG
END TYPE

FUNCTION GetObjectSize() AS LONG
    LOCAL GL AS EZGLOBJ
    FUNCTION=SIZEOF(GL)
END FUNCTION

'
' not axis like this:
'             0 degrees
'             |+Y
'             |
'          -------- +X
'             |
'             |
' then convert to real axis
SUB CalcPlaneRotation(BYVAL X!, BYVAL Y!, BYVAL Deg!, NX!, NY!)
    LOCAL L!, DG!
    IF X!=0 AND Y!=0 THEN
        NX!=0:NY!=0
        EXIT SUB
    END IF
    IF X!=0 THEN
        L!=Y!
        IF Y!<0 THEN DG!=180 ELSE DG!=0
    ELSE
        IF Y!=0 THEN
            L!=X!
            IF X!<0 THEN DG!=90 ELSE DG!=270
        ELSE
            ' 1/2  of the SQR of (2*ABS(X))^2 + (2*ABS(Y))^2
            L!=SQR( 4*ABS(X!)*ABS(X!) )/2
            IF Y!>0 AND X!>0 THEN
                IF X!>0 THEN
                    ' 270 to 360 degree
                ELSE
                    ' 0 to 90 degrees
                END IF
            ELSE
                IF X!>0 THEN
                    ' 180 to 270 degree
                ELSE
                    ' 90 to 180 degrees
                END IF
            END IF
        END IF
    END IF
'    CalcPointF (BYVAL AX!,BYVAL AY!,BYVAL AL!,BYVAL ADG!,RX!,RY!)
END SUB


SUB DrawSceneObjects(BYVAL hWnd AS LONG,BYVAL CBA AS DWORD)
    LOCAL lpAddress AS DWORD, SLen&, MX&, I&, OKFlag&, N&
    STATIC GLen&, CUSTOM AS QUAD
    IF CUSTOM=0 THEN CUSTOM=QObject("CUSTOM")
    IF GLen&=0 THEN GLen&=GetObjectSize
    EZ_LockSuperClassString hWnd, 18,lpAddress, SLen&
    IF lpAddress=0 THEN ' then data does not exist so no need to unlock
        ' string data block has nothing in it
        EXIT SUB
    END IF
    MX&=SLen&/GLen&
    IF MX&=0 THEN   ' string data stored but not enought to fill one structure
        EZ_UnlockSuperClassString  hWnd, 18
        EXIT SUB
    END IF
    DIM GL(1 TO MX&) AS EZGLOBJ AT lpAddress
    DIM CZ(1 TO MX&) AS SINGLE
    DIM OB(1 TO MX&) AS LONG
    FOR N&=1 TO MX&
        ' GL(I&).rCY   Y rotation
        ' GL(I&).SX
        ' GL(I&).SZ
    NEXT N&

    ' add display generation code in this subroutine
    ' GL(I&).DListFlag  - Display List flag
    ' GL(I&).DListID    - current Display List ID

    FOR N&=1 TO MX&
        I&=N&
        IF GL(I&).VFlag<>0 THEN
            OKFlag&=1
            IF GL(I&).QName=CUSTOM THEN
                IF CBA=0 THEN OKFlag&=0 ' don't attempt to draw custom if no callback
            END IF
            IF OKFlag& THEN
                ' Setorigins calls glPushMatrix
                SetOrigins GL(I&).ScaleX, GL(I&).ScaleY, GL(I&).ScaleZ, GL(I&).X, GL(I&).Y, GL(I&).Z, GL(I&).rX, GL(I&).rY, GL(I&).rZ, GL(I&).rCX, GL(I&).rCY, GL(I&).rCZ
                ' GL(I&).MatFlag
                DrawOne3DObject GL(I&).ID, GL(I&).QName, GL(I&).SX, GL(I&).SY, GL(I&).SZ, GL(I&).Material,GL(I&).MatFlag,GL(I&).SolidFlag, GL(I&).LineWidth,GL(I&).AntiAlias, CBA, GL(I&).DListID, 0
                ' use to call DrawOne3DObjectInWorld
                glPopMatrix
            END IF
        END IF
    NEXT N&
    EZ_UnlockSuperClassString  hWnd, 18
END SUB

FUNCTION ProcessSceneObjects(BYVAL hWnd AS LONG, BYVAL mode&, BYVAL MyID&, BYVAL AllFlag&) AS LONG
    LOCAL lpAddress AS DWORD, SLen&, MX&, I&
    LOCAL hDC AS LONG,hGLRC AS LONG, hDList&, InitFlag&, OKFlag&, RV&
    STATIC GLen&, CUSTOM AS QUAD
    IF CUSTOM=0 THEN CUSTOM=QObject("CUSTOM")
    IF GLen&=0 THEN GLen&=GetObjectSize
    EZ_LockSuperClassString hWnd, 18,lpAddress, SLen&
    IF lpAddress=0 THEN ' then data does not exist so no need to unlock
        ' string data block has nothing in it
        FUNCTION=1
        EXIT FUNCTION
    END IF
    MX&=SLen&/GLen&
    IF MX&=0 THEN   ' string data stored but not enought to fill one structure
        EZ_UnlockSuperClassString  hWnd, 18
        FUNCTION=1
        EXIT FUNCTION
    END IF
    DIM GL(1 TO MX&) AS EZGLOBJ AT lpAddress

    ' mode& =    1 (Create Display Lists)   2 (Delete Display Lists)   3 (Test for Object ID)
    IF Mode&=3 THEN
        RV&=1
        FOR I&=1 TO MX&
            IF GL(I&).ID = MyID& THEN
                RV&=0       ' ID found so don't use again
                EXIT FOR
            END IF
        NEXT I&
    ELSE
        RV&=1
        hDC=EZ_GetSuperClassProp(hWnd,1)
        hGLRC=EZ_GetSuperClassProp(hWnd,2)
        wglMakeCurrent hDC, hGLRC
        InitFlag&=1     ' Prepare RC only once for all objects, only if at least one object must calculate a display list

        FOR I&=1 TO MX&
           IF AllFlag& THEN  ' do all objects
                OKFlag&=1
           ELSE
               IF GL(I&).ID = MyID& THEN OKFlag&=1 ELSE OKFlag&=0
           END IF
           IF OKFlag& THEN
'               IF GL(I&).DListFlag<>0 THEN
                   SELECT CASE AS LONG mode&
                       CASE 1   ' create Display List for objects
                           GOSUB FreeList
                           GOSUB CreateList
                            ' this call is only to generate a Display List for each object
                            IF GL(I&).DListID<>0 THEN
                               GOSUB PrepareRC
                               glPushMatrix
                               glNewList GL(I&).DListID, %GL_COMPILE
                               ' GL(I&).MatFlag
                               DrawOne3DObject GL(I&).ID, GL(I&).QName, GL(I&).SX, GL(I&).SY, GL(I&).SZ, GL(I&).Material,GL(I&).MatFlag,GL(I&).SolidFlag, GL(I&).LineWidth,GL(I&).AntiAlias, 0, GL(I&).DListID, 1
                               glEndList
                               glPopMatrix
                            END IF
                        CASE 2  ' delete Display List for object
                           GOSUB FreeList
                        CASE ELSE
                    END SELECT
'               END IF
           END IF
        NEXT N&
        wglMakeCurrent hDC, %NULL
    END IF
    EZ_UnlockSuperClassString  hWnd, 18
    FUNCTION=RV&
    EXIT FUNCTION

CreateList:
    hDList&=glGenLists(1)
    IF hDList&<>0 THEN
        GL(I&).DListID=hDList&
        GL(I&).DListFlag=1
    ELSE
        GL(I&).DListID=0
        GL(I&).DListFlag=0
    END IF
RETURN

FreeList:
    IF GL(I&).DListID<>0 THEN
        glDeleteLists GL(I&).DListID,1
        GL(I&).DListID=0
        GL(I&).DListFlag=0
    END IF
RETURN

PrepareRC:
    IF InitFlag& THEN
        glMatrixMode %GL_PROJECTION
        glLoadIdentity
        glMatrixMode %GL_MODELVIEW
        glLoadIdentity
        glOrtho -100,100,-100,100,100,-100
        InitFlag&=0
    END IF
RETURN

END FUNCTION


SUB Draw3DObjects(BYVAL hWnd AS LONG, BYVAL hDC AS LONG, BYVAL hGLRC AS LONG, BYVAL W!, BYVAL H!, BYVAL CBA AS DWORD)
    LOCAL Distance!
    LOCAL YDeg&, XDeg&, ZDist&, ALevel&, DLevel&

    IF H!<=0 THEN H!=1
    IF W!<=0 THEN W!=1

    SetLight 0,0,0,0,0,0    ' turn off both main light and second light
    glMatrixMode %GL_PROJECTION
    glLoadIdentity

    glOrtho -1,1,-1,1,1,-1

    Distance!=LongToFloat(EZ_GetSuperClassProp(hWnd,%PROP_PERSP))

    gluPerspective Distance!, W!/H!, .1, 50  'set frustum using viewport aspect ratio
                  ' ^
                  ' vertical field of view  26 degrees (closeup) to   180 degrees (so far can't see it)  (tested with object which fills screen)
                  '                                                    95% displays about 1/4 size
                  ' horizontal filed of view ration w/h
                  ' near must be >0 , yet small
                  ' far 50 is about right

    gluLookAt 0,0,5,0,0,0,0,0.01,0
             '^ ^ ^  distance from screen and distance from left and right looking from



    glMatrixMode %GL_MODELVIEW
    glLoadIdentity

    '(*)
'    glOrtho -1,1,-1,1,1,-1
    glOrtho -100,100,-100,100,100,-100

    glTranslatef 0,0,0

    YDeg&   = EZ_GetSuperClassProp(hWnd,%PROP_LIGHTY)   ' Light Y Degrees (0 to 360)
    XDeg&   = EZ_GetSuperClassProp(hWnd,%PROP_LIGHTX)   ' Light X Degree (0 to 90)
    ZDist&  = EZ_GetSuperClassProp(hWnd,%PROP_LIGHTZ)   ' Light Distance (0 to 100+)
    ALevel& = EZ_GetSuperClassProp(hWnd,%PROP_LIGHTA)   ' Light Ambient Level (0 to 100)
    DLevel& = EZ_GetSuperClassProp(hWnd,%PROP_LIGHTD)   ' Light Diffuse Level (0 to 100)

    SetLight 1, YDeg&, XDeg&, ZDist&, ALevel&, DLevel&

    IF EZ_GetSuperClassProp(hWnd,%PROP_LIGHT2)<>0 THEN
        YDeg&   = EZ_GetSuperClassProp(hWnd,%PROP_LIGHT2Y)   ' Light Y Degrees (0 to 360)
        XDeg&   = EZ_GetSuperClassProp(hWnd,%PROP_LIGHT2X)   ' Light X Degree (0 to 90)
        ZDist&  = EZ_GetSuperClassProp(hWnd,%PROP_LIGHT2Z)   ' Light Distance (0 to 100+)
        ALevel& = EZ_GetSuperClassProp(hWnd,%PROP_LIGHT2A)   ' Light Ambient Level (0 to 100)
        DLevel& = EZ_GetSuperClassProp(hWnd,%PROP_LIGHT2D)   ' Light Diffuse Level (0 to 100)
        SetLight 2, YDeg&, XDeg&, ZDist&, ALevel&, DLevel&
    END IF

    DrawSceneObjects hWnd, CBA

    ' -----------------------------------
'    STATIC RD!, RD1!
    ' ------------
'    DrawSceneObjectsTemp hWnd, RD!, RD1!
    ' ------------
'    RD=RD+2
'    IF RD>360 THEN RD=0
'    RD1!=RD1!+1
'    IF RD1!>360 THEN RD1!=0
    ' -----------------------------------

    glMatrixMode %GL_PROJECTION
    glLoadIdentity
    glMatrixMode %GL_MODELVIEW

END SUB

SUB GetQFlags(BYVAL hWnd&, FQ&, LNQ&, PERQ&, PTQ&, POLYQ&)
    LOCAL F&
    F&=EZ_GetSuperClassProp(hWnd&,%PROP_QUALITY)
    FQ&=BIT(F&,0)
    LNQ&=BIT(F&,1)
    PERQ&=BIT(F&,2)
    PTQ&=BIT(F&,3)
    POLYQ&=BIT(F&,4)
END SUB


' if paramater is 1 - set bit to 1, 0 - set bit to 0, -1 - leave bit alone
SUB SetQFlags(BYVAL hWnd&, BYVAL FQ&, BYVAL LNQ&, BYVAL PERQ&, BYVAL PTQ&, BYVAL POLYQ&)
    LOCAL F&
    F&=EZ_GetSuperClassProp(hWnd&,%PROP_QUALITY)
    IF FQ&=1 THEN BIT SET F&,0
    IF FQ&=0 THEN BIT RESET F&,0

    IF LNQ&=1 THEN BIT SET F&,1
    IF LNQ&=0 THEN BIT RESET F&,1

    IF PERQ&=1 THEN BIT SET F&,2
    IF PERQ&=0 THEN BIT RESET F&,2

    IF PTQ&=1 THEN BIT SET F&,3
    IF PTQ&=0 THEN BIT RESET F&,3

    IF POLYQ&=1 THEN BIT SET F&,4
    IF POLYQ&=0 THEN BIT RESET F&,4

    EZ_SetSuperClassProp hWnd&,%PROP_QUALITY, F&
END SUB

SUB DoCallBackOther(BYVAL hWnd AS LONG, BYVAL hDC AS LONG, BYVAL hGLRC AS LONG, BYVAL CBA AS DWORD, BYVAL Mode&)
    ' current modes acceptable are:
    ' -1 to init control
    ' -2 to free control
    IF CBA<>0 THEN
        wglMakeCurrent hDC, hGLRC
        CALL DWORD CBA USING OpenGLCallBackX(Mode&,0, 0,0,0,0,0,0)
        wglMakeCurrent hDC, %NULL
    END IF
END SUB

SUB DrawOpenGLWindow(BYVAL hWnd AS LONG, BYVAL hDC AS LONG, BYVAL hGLRC AS LONG, BYVAL GLMode AS LONG, BYVAL BGDrawMode&, BYVAL CBA AS DWORD, BYVAL BR&, BYVAL XZ&, BYVAL YZ&)
    LOCAL lpBits AS DWORD, W&, H&, PW!,PH!
    LOCAL hBmp&, PA AS DWORD, hMemDC&, CT&, CurDBuf&, Param1&, Bright!, FX!, FY!, ZoomX!, ZoomY!, ClearFlag&
    REGISTER I&
    LOCAL PT1 AS BYTE PTR, PT2 AS BYTE PTR , C&, PTL AS DWORD PTR
    LOCAL W2 AS SINGLE, H2 AS SINGLE, BestDrawMode&, CutH!, TmpH&, CutFlag&, CutDif&
    LOCAL FQ&, LNQ&, PERQ&, PTQ&, POLYQ&
    Bright!=BR&
    Bright!=Bright!/100# ' defines brightness in a percentage value
    GetWH hWnd, W&,H&
    PW!=W&
    PH!=H&

    TmpH&=EZ_GetSuperClassProp(hWnd,%PROP_BGCUTOFF)
    IF TmpH&<0 THEN TmpH&=0
    IF TmpH&>95 THEN TmpH&=95
    IF TmpH&=0 THEN
        CutFlag&=0
        CutDif&=0
    ELSE
        CutH!=TmpH&
        CutH!=(CutH!/100)*PH!
        TmpH&=INT(CutH!)
        CutDif&=H&-TmpH&
        IF CutDif&>2 THEN
            CutFlag&=1
        ELSE
            CutFlag&=0
            CutDif&=0
        END IF
    END IF


    ClearFlag&=0
    ZoomX!=XZ&
    ZoomY!=YZ&
    ZoomX!=ZoomX!/100#
    ZoomY!=ZoomY!/100#
    IF ZoomX!<1.0 THEN ClearFlag&=1
    IF ZoomY!<1.0 THEN ClearFlag&=1
    FX!=0-ZoomX!
    IF FX!<-1.0 THEN FX!=-1.0
    FY!=0-ZoomY!
    IF FY!<-1.0 THEN FY!=-1.0
    IF CutFlag&<>0 THEN ClearFlag&=1
    wglMakeCurrent hDC, hGLRC

    IF GLMode=1 THEN
        glDrawBuffer %GL_BACK
    ELSE
        glDrawBuffer %GL_FRONT
    END IF


    IF TestExtension("GL_EXT_bgra",1,"") THEN
        BestDrawMode&=1
    ELSE
        BestDrawMode&=0
    END IF

    glMatrixMode %GL_PROJECTION
    glLoadIdentity
    glMatrixMode %GL_TEXTURE
    glLoadIdentity
    glMatrixMode %GL_MODELVIEW
    glLoadIdentity

    EnableBlend 0,0         ' turn off blending
    EnableDepth 0           ' sets %GL_DEPTH_TEST if 1
    ' fog, line_smooth, perspective_coorection, Point_smooth, Polygon_smooth   quality
    SetDrawQuality 0,0,0,0,0
    ClearBuffers 0,0,1, 1.0    ' clear depth buffers only

    ' ---------------------------------------------------------------
'    C&=EZ_GetSuperClassProp(hWnd,%PROP_COLOR)    ' get current color
'    ClearBuffers 1,C&,1,1.0   ' clear colors and depth buffer always
    ' ---------------------------------------------------------------

    ' ----------------------------------------------
    ' 10% of the time lost in building bitmap for copy
    ' ----------------------------------------------
    GOSUB GetFullBitmap    ' convert to RGBA and flip
    ' ----------------------------------------------
    ' ----------------------------------------------
    ' 75% time spent here in call to glDrawPixels
    ' ----------------------------------------------
    GOSUB DrawBitmap    ' draw background and prepare for drawing
    ' ----------------------------------------------

    EnableDepth 1           ' sets %GL_DEPTH_TEST if 1


    ' fog, line_smooth, perspective_coorection, Point_smooth, Polygon_smooth   quality
    GetQFlags hWnd, FQ&, LNQ&, PERQ&, PTQ&, POLYQ&
    SetDrawQuality FQ&, LNQ&, PERQ&, PTQ&, POLYQ&

    glEnable %GL_LINE_SMOOTH    ' glLineWidth affects line width
    glEnable %GL_POINT_SMOOTH   ' glPointSize effects point size
    glDisable %GL_POLYGON_SMOOTH ' don't enable since it does not work like expected and is terribly slow

    ' ----------------------------------------------
    IF CBA<>0 THEN  ' callback before primitives drawn
        Param1&=0
        CALL DWORD CBA USING OpenGLCallBackX(1, W&, H&,0,0,0,0,0)
    END IF
    ' ----------------------------------------------
    ' draw primitives here
    ' ----------------------------------------------
    Draw3DObjects hWnd, hDC, hGLRC, PW!, PH!, CBA
    ' ----------------------------------------------
    IF CBA<>0 THEN  ' callback after primitives drawn
        Param1&=0
        CALL DWORD CBA USING OpenGLCallBackX(3, 0, 0,0,0,0,0,0)
    END IF
    ' ----------------------------------------------
    SetLight 0,0,0,0,0,0    ' turn off both main light and second light
    IF GLMode=1 THEN
        SwapBuffers hDC
    ELSE
        glFlush
    END IF
    TestExtension "",0,""   ' clear extension list
    wglMakeCurrent hDC, %NULL
    EXIT SUB

GetFullBitmap:
    ' Background Draw Mode (0) - use GL color, (1) - update and use copy of Canvas Bitmap, (2) - use GL copy of Canvas Bitmap only
    PA=EZ_GetSuperClassProp(hWnd,5)
    IF BGDrawMode&=1 THEN   ' update controls bitmap with Canvas image
        hMemDC&=EZ_GetSuperClassProp(hWnd,3)
        SendMessage hWnd, %WM_PRINTCLIENT, hMemDC&, %PRF_CLIENT
        GDIFlush
        SELECT CASE AS LONG BestDrawMode&
            CASE 1  ' BGRA
                ' already in this format
            CASE 2  ' ABGR  ' not currently used but leave this code
                PTL=PA
                CT&=W&*H&
                FOR I&=1 TO CT&
                    SHIFT LEFT @PTL,8
                    INCR PTL
                NEXT I&
            CASE ELSE ' default RGBA        Mode = 0
                PT1=PA
                PT2=PT1+2
                CT&=W&*H&
                FOR I&=1 TO CT&
                    SWAP @PT1, @PT2
                    PT1=PT1+4
                    PT2=PT2+4
                NEXT I&
        END SELECT
    END IF
    lpBits=PA
RETURN

DrawBitmap:
'    IF GLMode=1 THEN
'        glDrawBuffer %GL_BACK
'    ELSE
'        glDrawBuffer %GL_FRONT
'    END IF
    IF BGDrawMode&=0 THEN   ' clear BG color only
        C&=EZ_GetSuperClassProp(hWnd,%PROP_COLOR)    ' get current color
        ClearBuffers 1,C&,0,0   ' clear colors only
    ELSE
        IF lpBits<>0 THEN
            ' -----------------------------------
            glPixelStorei %GL_UNPACK_SWAP_BYTES,0
            glPixelStorei %GL_UNPACK_LSB_FIRST,0
            glPixelStorei %GL_UNPACK_ROW_LENGTH, W&
            glPixelStorei %GL_UNPACK_SKIP_ROWS,0
            glPixelStorei %GL_UNPACK_SKIP_PIXELS,0
            glPixelStorei %GL_UNPACK_ALIGNMENT,4
            ' -----------------------------------
            glPixelTransferi %GL_MAP_COLOR, 0   ' must be zero
            ' ------- rest are Floats ---------------
            ' scale darkens or lightens the colors (1.0 is normal, <1.0 is darker, >1.0 is lighter)
            glPixelTransferf %GL_RED_SCALE, Bright!
            glPixelTransferf %GL_RED_BIAS, 0
            glPixelTransferf %GL_GREEN_SCALE, Bright!
            glPixelTransferf %GL_GREEN_BIAS, 0
            glPixelTransferf %GL_BLUE_SCALE, Bright!
            glPixelTransferf %GL_BLUE_BIAS, 0
            glPixelTransferf %GL_ALPHA_SCALE, 1.0
            glPixelTransferf %GL_ALPHA_BIAS, 0


''            glPixelTransferf %GL_DEPTH_SCALE, 1.0
''            glPixelTransferf %GL_DEPTH_BIAS, 1.0
            IF ClearFlag& THEN
                C&=EZ_GetSuperClassProp(hWnd,%PROP_COLOR)    ' get current color
                ClearBuffers 1,C&,0,0   ' clear colors only
            END IF
            ' -----------------------------------
            ' OpenGL Cartesian Coordinate Plane
            ' (-1,+1)           (0,+1)             (+1,+1)
            '                      |
            '                      |    Z (-1)
            '                      Y   /
            '                      |  /
            '                      | /
            ' (-1,0)------X------(0,0)------X------(+1,0)
            '                      |
            '                     /|
            '                    / Y
            '                   /  |
            '            (+1) Z   |
            '                      |
            ' (-1,-1)           (0,-1)             (+1,-1)
            ' -----------------------------------
            glOrtho -1,1,-1,1,1,-1
            ' -----------------------------------
            glRasterPos3f FX!,FY!, -.99   ' default raster position
            ' -----------------------------------
            glPixelZoom ZoomX!,ZoomY! ' scales image
            ' -----------------------------------
            ' 75% time lost here in call to glDrawPixels  (no difference when using a Float array)

            SELECT CASE AS LONG BestDrawMode&
                CASE 1  ' BGRA
                    IF lpBits<>0 THEN glDrawPixels W&,H&-CutDif&, %GL_BGRA_EXT, %GL_UNSIGNED_BYTE,lpBits
                CASE 2  ' ABGR  ' not currently used by leave
                    IF lpBits<>0 THEN glDrawPixels W&,H&-CutDif&, %GL_ABGR_EXT, %GL_UNSIGNED_BYTE,lpBits
                CASE ELSE ' default RGBA
                    IF lpBits<>0 THEN glDrawPixels W&,H&-CutDif&, %GL_RGBA, %GL_UNSIGNED_BYTE,lpBits
            END SELECT
        END IF
    END IF

RETURN

END SUB



SUB DefColorMaterial(T$)
    LOCAL CT&, I!, C!, Sp!, Sh!
    CT&=PARSECOUNT(T$,",")
    IF CT&>=4 THEN
        I!=VAL(PARSE$(T$,",",1))
        IF I!>App_EndCoreMaterials& AND I!<=UBOUND(App_Material) THEN
            C!=VAL(PARSE$(T$,",",2))
            Sp!=VAL(PARSE$(T$,",",3))
            Sh!=VAL(PARSE$(T$,",",4))
            DefMaterial INT(I!), C!, Sp!, Sh!, 0,0,0,0
        END IF
    END IF
END SUB

SUB DefTextureMaterial(T$, BYVAL Mode&)
    LOCAL CT&, I!, C!, Sp!, Sh!, TexMin!,TexMax!, BN!, hSBmp&, SID&
    CT&=PARSECOUNT(T$,",")
    IF CT&>=7 THEN
        I!=VAL(PARSE$(T$,",",1))
        IF I!>App_EndCoreMaterials& AND I!<=UBOUND(App_Material) THEN
            C!=VAL(PARSE$(T$,",",2))
            Sp!=VAL(PARSE$(T$,",",3))
            Sh!=VAL(PARSE$(T$,",",4))
            BN!=VAL(PARSE$(T$,",",5))
            TexMin!=VAL(PARSE$(T$,",",6))
            TexMax!=VAL(PARSE$(T$,",",7))
            IF Mode&=1 THEN
                 IF BN!>=1 AND BN!<=%MaxDefBitmaps THEN
                     DefMaterial INT(I!), C!, Sp!, Sh!, App_DefaultBitmaps(INT(BN!)),TexMin!,TexMax!,0
                 END IF
            END IF
            IF Mode&=2 THEN   ' use sprite
                 IF BN!>=1 AND BN!<=64000 THEN
                      SID&=INT(BN!)
                      hSBmp&=EZGL_GetSpriteBitmap(SID&)
                      IF hSBmp&<>0 THEN
                           DefMaterial INT(I!), C!, Sp!, Sh!, hSBmp&, TexMin!, TexMax!,0
                      END IF
                 END IF
            END IF
        END IF
    END IF
END SUB

SUB DefMaterialAlpha(T$)
    LOCAL CT&, I!, ID&, V!
    CT&=PARSECOUNT(T$,",")
    IF CT&>=2 THEN
        I!=VAL(PARSE$(T$,",",1))
        IF I!>=0 AND I!<=UBOUND(App_Material) THEN
            ID&=INT(I!)
            V!=VAL(PARSE$(T$,",",2))
            IF V!<0 THEN V!=0
            IF V!>100 THEN V!=100
            V!=V!/100
            IF App_Material(ID&).CType&<>0 THEN
                App_Material(ID&).Alpha=V!
                IF V!<1.0! THEN
                    App_Material(ID&).AlphaFlag=1
                ELSE
                    App_Material(ID&).AlphaFlag=0
                END IF
            END IF
        END IF
    END IF
END SUB

SUB AddNewSceneObject(BYVAL hWnd AS LONG, T$)
    LOCAL L&, CT&, GL AS EZGLOBJ, OID!, MatID!, MinID&, MaxID&, MyID&, MCFlag&, V!
    T$=REMOVE$(T$, ANY "<> ")
    CT&=PARSECOUNT(T$,",")
    IF CT&>=10 THEN
        OID!=VAL(PARSE$(T$,",",2))
        IF OID!<1 OR OID!>1000000 THEN
            EXIT SUB
        END IF
        MyID&=INT(OID!)
        IF ProcessSceneObjects(hWnd, 3, MyID&, 1) THEN  ' test to see if IF exists
            GL.QName    = QObject(PARSE$(T$,",",1))
            MatID!=ABS(VAL(PARSE$(T$,",",9)))
            V!=VAL(PARSE$(T$,",",10))
            IF V!<0 THEN V!=0
            IF V!>2 THEN V!=2
            MCFlag&=INT(V!)
            IF MCFlag&=2 THEN
                MaxID&=UBOUND(App_Palettes)
                MinID&=0
            ELSE
                MaxID&=UBOUND(App_Material)
                MinID&=0
            END IF
            IF MatID!>MaxID& THEN MatID!=MaxID&
            IF MatID!<MinID& THEN MatID!=MinID&
            GL.VFlag    = 1 ' default is visible
            GL.ID       = MyID&
            GL.Material = INT(MatID!)   ' Material ID's can be negative or positive (negative means no offset)
            GL.ScaleX   = 1
            GL.ScaleY   = 1
            GL.ScaleZ   = 1
            GL.X        = VAL(PARSE$(T$,",",3))
            GL.Y        = VAL(PARSE$(T$,",",4))
            GL.Z        = VAL(PARSE$(T$,",",5))
            GL.rX       = 0
            GL.rY       = 0
            GL.rZ       = 0
            GL.rCX      = 0
            GL.rCY      = 0
            GL.rCZ      = 0
            GL.SX       = VAL(PARSE$(T$,",",6))
            GL.SY       = VAL(PARSE$(T$,",",7))   ' these IScale values should be passed to the scale values (ie. GL.ScaleX)
            GL.SZ       = VAL(PARSE$(T$,",",8))
            GL.SceneX   = 0   ' scene center for rotation
            GL.SceneY   = 0
            GL.SceneZ   = 0
            GL.SolidFlag = 1    ' if 1 draw as solid material
            GL.LineWidth = 1.0  ' use 3.0 for anti-alias lines
            GL.AntiAlias = 0    ' anti-alias when drawing solid
            GL.DListFlag = 0    ' Is a Display List flag
            GL.DListID   = 0    ' current Display List ID
            GL.MatFlag   = MCFlag&  ' 0 - solid color, 1 - multi colored, 2 - palette
            EZ_SetSuperClassString hWnd, 18, EZ_GetSuperClassString(hWnd, 18)+PEEK$(VARPTR(GL), SIZEOF(GL))
        END IF
    END IF
END SUB

SUB FreeSceneObject(BYVAL hWnd AS LONG, T$)
    LOCAL OID!,MyID&, GL1 AS EZGLOBJ PTR, GL2 AS EZGLOBJ PTR, LP&,CT&, SCObj$, L&, FFlag&
    STATIC GLen&
    OID!=VAL(TRIM$(T$))
    IF OID!<1 OR OID!>1000000 THEN EXIT SUB
    MyID&=INT(OID!)

    IF GLen&=0 THEN GLen&=GetObjectSize
    SCObj$=EZ_GetSuperClassString(hWnd, 18)
    L&=LEN(SCObj$)
    CT&=L&/GLen&
    IF CT&>0 THEN
        L&=CT&*GLen&
        GL1=STRPTR(SCObj$)
        GL2=GL1
        FFlag&=0
        FOR LP&=1 TO CT&
            IF FFlag& THEN
                @GL1=@GL2   ' move other records up one place
                GL1=GL1+GLen&
            ELSE
                IF @GL1.ID=MyID& THEN
                    FFlag&=1
                    L&=L&-GLen& ' subtract one records
                ELSE
                    GL1=GL1+GLen&
                END IF
            END IF
            GL2=GL2+GLen&
        NEXT LP&
        IF FFlag& THEN
            EZ_SetSuperClassString hWnd, 18, LEFT$(SCObj$, L&)
        END IF
    END IF
END SUB

SUB SetInfoString(BYVAL hWnd AS LONG, BYVAL T$)
    EZ_SetSuperClassString hWnd, %PROP_INFOSTR, T$
END SUB

FUNCTION GetInfoString(BYVAL hWnd AS LONG) AS STRING
    FUNCTION=EZ_GetSuperClassString(hWnd, %PROP_INFOSTR)
END FUNCTION


SUB ChangeSceneObject(BYVAL hWnd AS LONG, T$, BYVAL mode&, BYVAL AFlag&)
    LOCAL L&, CT&, FID&, I&, MX&, OID!, lpAddress AS DWORD, SLen&, OKFlag&, IV!, V!, P&, MCFlag&
    STATIC GLen&
    IF GLen&=0 THEN GLen&=GetObjectSize
    T$=REMOVE$(T$, ANY "<> ")

    CT&=PARSECOUNT(T$,",")
    IF AFlag&=0 THEN
        OID!=VAL(PARSE$(T$,",",1))
        IF OID!<1 OR OID!>1000000 THEN
            EXIT SUB
        END IF
        FID&=INT(OID!)
    ELSE
        FID&=0
    END IF
    ' ----------------------------------
                     ' NT$=EZ_GetSuperClassString(hWnd, 18)
    ' Lock memory so it can be accessed!
    EZ_LockSuperClassString hWnd, 18,lpAddress, SLen&
    IF lpAddress=0 THEN ' then data does not exist so no need to unlock
        ' string data block has nothing in it
        EXIT SUB
    END IF
    ' ----------------------------------

    MX&=SLen&/GLen&

    IF MX&=0 THEN   ' string data stored but not enought to fill one structure
        EZ_UnlockSuperClassString  hWnd, 18
        EXIT SUB
    END IF
    DIM GL(1 TO MX&) AS EZGLOBJ AT lpAddress


    FOR I&=1 TO MX&
        OKFlag&=0
        IF AFlag&=0 THEN
            IF GL(I&).ID=FID& THEN OKFlag&=1
        ELSE
            OKFlag&=1
        END IF
        IF OKFlag& THEN
            SELECT CASE AS LONG mode&
                CASE 1  ' change scene scale
                    IF CT&>=4 THEN
                        GL(I&).ScaleX   = VAL(PARSE$(T$,",",2))
                        GL(I&).ScaleY   = VAL(PARSE$(T$,",",3))
                        GL(I&).ScaleZ   = VAL(PARSE$(T$,",",4))
                    END IF
                CASE 2  ' change position
                    IF CT&>=4 THEN
                        GL(I&).X        = VAL(PARSE$(T$,",",2))
                        GL(I&).Y        = VAL(PARSE$(T$,",",3))
                        GL(I&).Z        = VAL(PARSE$(T$,",",4))
                    END IF
                CASE 3  ' change rotation
                    IF CT&>=4 THEN
                        GL(I&).rX       = VAL(PARSE$(T$,",",2))
                        GL(I&).rY       = VAL(PARSE$(T$,",",3))
                        GL(I&).rZ       = VAL(PARSE$(T$,",",4))
                    END IF
                CASE 4  ' change scene rotation
                    IF CT&>=4 THEN
                        GL(I&).rCX      = VAL(PARSE$(T$,",",2))
                        GL(I&).rCY      = VAL(PARSE$(T$,",",3))
                        GL(I&).rCZ      = VAL(PARSE$(T$,",",4))
                    END IF
                CASE 5  ' change individual world scale
                    IF CT&>=4 THEN
                        GL(I&).SX       = VAL(PARSE$(T$,",",2))
                        GL(I&).SY       = VAL(PARSE$(T$,",",3))
                        GL(I&).SZ       = VAL(PARSE$(T$,",",4))
                    END IF
                CASE 6  ' change all paramaters
                    IF CT&>=16 THEN
                        GL(I&).ScaleX   = VAL(PARSE$(T$,",",2))
                        GL(I&).ScaleY   = VAL(PARSE$(T$,",",3))
                        GL(I&).ScaleZ   = VAL(PARSE$(T$,",",4))
                        GL(I&).X        = VAL(PARSE$(T$,",",5))
                        GL(I&).Y        = VAL(PARSE$(T$,",",6))
                        GL(I&).Z        = VAL(PARSE$(T$,",",7))
                        GL(I&).rX       = VAL(PARSE$(T$,",",8))
                        GL(I&).rY       = VAL(PARSE$(T$,",",9))
                        GL(I&).rZ       = VAL(PARSE$(T$,",",10))
                        GL(I&).rCX      = VAL(PARSE$(T$,",",11))
                        GL(I&).rCY      = VAL(PARSE$(T$,",",12))
                        GL(I&).rCZ      = VAL(PARSE$(T$,",",13))
                        GL(I&).SX       = VAL(PARSE$(T$,",",14))
                        GL(I&).SY       = VAL(PARSE$(T$,",",15))
                        GL(I&).SZ       = VAL(PARSE$(T$,",",16))
                    END IF
                CASE 7  ' change material
                    IF CT&>=3 THEN
                        IV!=VAL(PARSE$(T$,",",3))
                        IF IV!<0 OR IV!>2 THEN IV!=0
                        MCFlag&=INT(IV!)
                        IF MCFlag&=2 THEN    ' use a palette
                            IV!=ABS(VAL(PARSE$(T$,",",2)))
                            IF IV!<0 OR IV!>UBOUND(App_Palettes) THEN IV!=0
                            GL(I&).Material =INT(IV!)
                            GL(I&).MatFlag=MCFlag&    ' 0 - solid, 1 - multicolor, 2 and up is a palette
                        ELSE    ' solid or multicolor
                            IV!=ABS(VAL(PARSE$(T$,",",2)))
                            IF IV!>UBOUND(App_Material) THEN IV!=UBOUND(App_Material)
                            GL(I&).Material =INT(IV!)
                            GL(I&).MatFlag=MCFlag&    ' 0 - solid, 1 - multicolor, 2 and up is a palette
                        END IF
                    END IF
                CASE 8  ' show object
                    GL(I&).VFlag=1
                CASE 9  ' hide object
                    GL(I&).VFlag=0
                CASE 10 ' scene center coordinate
                    IF CT&>=4 THEN
                        GL(I&).SceneX   = VAL(PARSE$(T$,",",2))
                        GL(I&).SceneY   = VAL(PARSE$(T$,",",3))
                        GL(I&).SceneZ   = VAL(PARSE$(T$,",",4))
                    END IF
                CASE 11     ' Wire Frame
                    IF AFlag&=0 THEN P&=2 ELSE P&=1
                    IF CT&>=P& THEN
                        IF VAL(PARSE$(T$,",",P&))<>0 THEN
                            GL(I&).SolidFlag = 0
                        ELSE
                            GL(I&).SolidFlag = 1
                        END IF
                    END IF
                CASE 12     ' AntiAlias
                    IF AFlag&=0 THEN P&=2 ELSE P&=1
                    IF CT&>=P& THEN
                        IF VAL(PARSE$(T$,",",P&))<>0 THEN
                            GL(I&).AntiAlias = 1
                        ELSE
                            GL(I&).AntiAlias = 0
                        END IF
                    END IF
                CASE 13     ' line width
                    IF AFlag&=0 THEN P&=2 ELSE P&=1
                    IF CT&>=P& THEN
                        V!=VAL(PARSE$(T$,",",P&))
                        IF V!<1.0 THEN V!=1.0
                        IF V!>5.0 THEN V!=5.0
                        GL(I&).LineWidth=V!
                    END IF
            END SELECT
            EXIT FOR
        END IF
    NEXT I&
    EZ_UnlockSuperClassString  hWnd, 18
END SUB

SUB LockObject(BYVAL hWnd AS LONG, T$, BYVAL mode&)
    LOCAL OID!, MyID&, RV&
    OID!=VAL(PARSE$(T$,",",1))
    IF OID!<1 OR OID!>1000000 THEN OID!=-1  ' not possible to match
    MyID&=INT(OID!)
    ' mode 1 is add to display list, mode 2 is delete from display list
    SELECT CASE AS LONG mode&
        CASE 1  ' lock object
            RV&=ProcessSceneObjects(hWnd, 1, MyID&, 0)
        CASE 2  ' unlock object
            RV&=ProcessSceneObjects(hWnd, 2, MyID&, 0)
        CASE 3  ' lock all objects
            RV&=ProcessSceneObjects(hWnd, 1, 0, 1)
        CASE 4  ' unlock all objects
            RV&=ProcessSceneObjects(hWnd, 2, 0, 1)
        CASE ELSE
    END SELECT
END SUB

FUNCTION GetLongVal(T$,BYVAL N&) AS LONG
    LOCAL V!
    V!=VAL(PARSE$(T$,",",N&))
    IF V!< -&H00FFFFFF THEN V!=-&H00FFFFFF
    IF V!> &H00FFFFFF THEN V!=&H00FFFFFF
    FUNCTION=INT(V!)
END FUNCTION

SUB ChangeScene(BYVAL hWnd AS LONG, T$, BYVAL mode&)
    LOCAL CT&, V&, V2&, F!
    T$=REMOVE$(T$, " ")
    CT&=PARSECOUNT(T$,",")
    SELECT CASE AS LONG mode&
        CASE 1  ' set BK color
            IF CT&>=1 THEN
                V&=GetLongVal(T$,1)
                EZ_SetSuperClassProp hWnd,%PROP_COLOR,V&
            END IF
        CASE 2  ' set BG mode
            IF CT&>=1 THEN
                V&=GetLongVal(T$,1)
                SendMessage hWnd,%EZGL_SETBGMODE,V&,0
            END IF
        CASE 3  ' set bright value
            IF CT&>=1 THEN
                V&=GetLongVal(T$,1)
                IF V&<0 THEN V&=0
                IF V&>25500 THEN V&=25500   ' should turn all BG colors to white
                EZ_SetSuperClassProp hWnd,%PROP_BRIGHT, V&

            END IF
        CASE 4  ' set zoom
            IF CT&>=2 THEN
                V&=GetLongVal(T$,1)
                V2&=GetLongVal(T$,2)
                IF V&<1 THEN V&=1
                IF V&>100 THEN V&=100
                EZ_SetSuperClassProp hWnd,%PROP_ZOOMX,V&     ' X Zoom
                IF V2&<1 THEN V2&=1
                IF V2&>100 THEN V2&=100
                EZ_SetSuperClassProp hWnd,%PROP_ZOOMY,V2&     ' Y Zoom
            END IF
        CASE 5  ' set perspective
            IF CT&>=1 THEN
                F!=VAL(PARSE$(T$,",",1))
                IF F!<0 THEN F!=0
                IF F!>180 THEN F!=180
'                SendMessage hWnd,%EZGL_SETPERSP, FloatToLong(F!),0
'
                EZ_SetSuperClassProp hWnd,%PROP_PERSP,FloatToLong(F!)
            END IF
        CASE 6,9
            IF CT&>=2 THEN
                V&=GetLongVal(T$,1)
                IF V&<0 THEN V&=0
                IF V&>360 THEN V&=360
                V2&=GetLongVal(T$,2)
                IF V2&<0 THEN V2&=0
                IF V2&>90 THEN V2&=90
                IF mode&=6 THEN
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHTY,V&
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHTX,V2&
                ELSE
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHT2Y,V&
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHT2X,V2&
                END IF
            END IF
        CASE 7, 10
            IF CT&>=1 THEN
                V&=GetLongVal(T$,1)
                IF V&<0 THEN V&=0
                IF V&>500 THEN V&=500
                IF mode&=7 THEN
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHTZ,V&
                ELSE
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHT2Z,V&
                END IF
            END IF
        CASE 8,11
            IF CT&>=2 THEN
                V&=GetLongVal(T$,1)
                IF V&<0 THEN V&=0
                IF V&>100 THEN V&=100
                V2&=GetLongVal(T$,2)
                IF V2&<0 THEN V2&=0
                IF V2&>100 THEN V2&=100
                IF mode&=8 THEN
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHTA,V&
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHTD,V2&
                ELSE
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHT2A,V&
                    EZ_SetSuperClassProp hWnd,%PROP_LIGHT2D,V2&
                END IF
            END IF
        CASE 12
            IF CT&>=1 THEN
                V&=GetLongVal(T$,1)
                IF V&<>0 THEN V&=1
                EZ_SetSuperClassProp hWnd,%PROP_LIGHT2,V&
            END IF
        CASE 13
            IF CT&>=1 THEN
                V&=GetLongVal(T$,1)
                IF V&<0 THEN V&=0
                IF V&>95 THEN V&=95
                EZ_SetSuperClassProp hWnd,%PROP_BGCUTOFF,V&
            END IF
    END SELECT
END SUB

SUB CmdQFlags(BYVAL hWnd&, T$,BYVAL mode&)
    LOCAL FQ&, LNQ&, PERQ&, PTQ&, POLYQ&, V!
    FQ&     =-1
    LNQ&    =-1
    PERQ&   =-1
    PTQ&    =-1
    POLYQ&  =-1
    V!=VAL(TRIM$(T$))
    SELECT CASE AS LONG mode&
        CASE 0
            IF V!=0 THEN FQ&=0 ELSE FQ&=1
        CASE 1
            IF V!=0 THEN LNQ&=0 ELSE LNQ&=1
        CASE 2
            IF V!=0 THEN PERQ&=0 ELSE PERQ&=1
        CASE 3
            IF V!=0 THEN PTQ&=0 ELSE PTQ&=1
        CASE 4
            IF V!=0 THEN POLYQ&=0 ELSE POLYQ&=1
        CASE 99
            IF V!=0 THEN
                FQ&     =0
                LNQ&    =0
                PERQ&   =0
                PTQ&    =0
                POLYQ&  =0
            ELSE
                FQ&     =1
                LNQ&    =1
                PERQ&   =1
                PTQ&    =1
                POLYQ&  =1
            END IF
        CASE ELSE
            EXIT SUB
    END SELECT
    ' fog, line_smooth, perspective_coorection, Point_smooth, Polygon_smooth   quality
    SetQFlags hWnd&,FQ&, LNQ&, PERQ&, PTQ&, POLYQ&
END SUB

SUB DefPalette(T$)
    LOCAL CT&, V!, D$, MaxM&, I&, E&, M&
    CT&=PARSECOUNT(T$,",")
    IF CT&>=5 THEN  ' palettes must have at least 4 materials
        V!=VAL(PARSE$(T$,",",1))
        V!=INT(V!)
        IF V!>=0 AND V!<=UBOUND(App_Palettes) THEN
            I&=INT(V!)
            D$=""
            FOR E&=2 TO CT&
                V!=VAL(PARSE$(T$,",",E&))
                IF V!>=0 AND V!<=UBOUND(App_Material) THEN
                    M&=INT(V!)
                ELSE
                    M&=9    ' default color
                END IF
                D$=D$+MKL$(M&)
            NEXT E&
            App_Palettes(I&)=D$
        END IF
    END IF
END SUB

' A ,B ,C ,D ,E ,F ,G ,H ,I ,J ,K ,L ,M ,N ,O ,P ,Q ,R ,S ,T ,U ,V ,W ,X ,Y ,Z
' 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90
SUB ProcessEachTextCommand(BYVAL hWnd AS LONG, BYVAL FB&, Cmd$, T$)
    App_ReturnValue&=0
    IF LEN(Cmd$)<>0 THEN
        '
        '
        '  NOTE:     later convert select case structure to search for predefined QUADS like object names
        '
        '
        SELECT CASE AS CONST FB&
            CASE 65 ' A
                SELECT CASE AS CONST$ Cmd$
                    CASE "ADD"   ' add object to scene
                        GOSUB PrepareT
                        AddNewSceneObject hWnd, T$
                        ' syntax is:   (IDNum& can be from 1 to 1000000 and no duplicates of ID's)
                        ' NAME, IDNum, InitX!, InitY!, InitZ!, InitSX!, InitSY!, InitSZ!, MaterialID!, Solid!
                    CASE "ALIAS"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 12,0
                        ' syntax is:
                        ' IDNum, AFlag!
                    CASE "ALIASALL"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 12,1
                        ' syntax is:
                        ' AFlag!
                END SELECT
            CASE 66 ' B
                SELECT CASE AS CONST$ Cmd$
                    CASE "BGCOLOR"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,1
                        ' syntax is:
                        ' RGBColor&
                    CASE "BGMODE"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,2
                        ' syntax is:
                        ' BGMode&   (0 to 2)
                    CASE "BRIGHT"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,3
                        ' syntax is:
                        ' BrightVal&   (0 to 25500)
                    CASE "BGCUTOFF"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,13
                        ' syntax is:
                        ' BGCutOff&   (0 to 95) (percent of top of Bg to cut off)
                END SELECT
            CASE 68 ' D
                SELECT CASE AS CONST$ Cmd$
                    CASE "DEFPAL"
                        GOSUB PrepareT
                        DefPalette T$
                END SELECT
            CASE 70 ' F
                SELECT CASE AS CONST$ Cmd$
                    CASE "FREE"
                        GOSUB PrepareT
                        FreeSceneObject hWnd, T$
                        ' syntax is:
                        ' IDNum&
                    CASE "FREEMODEL"  ' free object from universal object list
                        GOSUB PrepareT
                        T$=UCASE$(TRIM$(T$))
                        FreeExistingObject T$
                        ' syntax is:
                        ' NAME
                    CASE "FREEALLMODELS"  ' free all objects except core objects
                        GOSUB PrepareT
                        FreeAllObjectsExceptCore
                        ' syntax is:
                        '
                END SELECT
            CASE 72 ' H
                SELECT CASE AS CONST$ Cmd$
                    CASE "HIDE"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 9,0
                        ' syntax is:
                        ' IDNum
                    CASE "HIDEALL"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 9,1
                        ' syntax is:
                        '
                END SELECT
            CASE 73 ' I
                SELECT CASE AS CONST$ Cmd$
                    CASE "ISCALE"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 5,0
                        ' syntax is:
                        ' IDNum, IScaleX!, IScaleY!, IScaleZ!
                END SELECT
            CASE 76 ' L
                SELECT CASE AS CONST$ Cmd$
                    CASE "LWIDTH"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 13,0
                        ' syntax is:
                        ' IDNum, Width!
                    CASE "LWIDTHALL"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 13,1
                        ' syntax is:
                        ' Width!
                    CASE "LIGHTYX"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,6
                        ' syntax is:
                        ' YDeg&, XDeg&  (0 to 360)(0 to 90)
                    CASE "LIGHTZ"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,7
                        ' syntax is:
                        ' ZDistance&    (0 to 500)
                    CASE "LIGHTAD"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,8
                        ' syntax is:
                        ' Ambient&, Diffuse&    (0 to 100)(0 to 100)
                    CASE "LIGHT2YX"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,9
                        ' syntax is:
                        ' YDeg&, XDeg&  (0 to 360)(0 to 90)
                    CASE "LIGHT2Z"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,10
                        ' syntax is:
                        ' ZDistance&    (0 to 500)
                    CASE "LIGHT2AD"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,11
                        ' syntax is:
                        ' Ambient&, Diffuse&    (0 to 100)(0 to 100)
                    CASE "LIGHT2"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,12
                        ' syntax is:
                        ' LightON_OFF!    (0 to 1)
                    CASE "LOADNEW"
                        ' don't remove spaces so don't call GOSUB PrepareT
                        Load3DFileCommand hWnd, T$
                        ' syntax is:        (AutoScale value = 2 - swap Y/Z axis only, 3 - Swap and gen normals, 4 - gen normals only
                        ' NAME,Filename, AutoScale        (can have quotes around filename) (autoscale forces control to resize and center image)
                    CASE "LOCK"
                        GOSUB PrepareT
                        LockObject hWnd, T$, 1
                        ' syntax is:
                        ' IDNum
                    CASE "LOCKALL"
                        GOSUB PrepareT
                        LockObject hWnd, T$, 3
                        ' syntax is:
                        '
                END SELECT
            CASE 77 ' M
                SELECT CASE AS CONST$ Cmd$
                    CASE "MAT"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 7,0
                        ' syntax is:
                        ' IDNum, MaterialID&, SolidFlag!
                    CASE "MATCOLOR"
                        GOSUB PrepareT
                        DefColorMaterial T$
                        ' syntax is:
                        ' MatID&, RGBColor!, Reflective!, Shiny!  (last parameters are 0 to 100)
                    CASE "MATPAT"   ' material pattern
                        GOSUB PrepareT
                        DefTextureMaterial T$,1
                        ' syntax is:
                        ' MatID&, RGBColor!, Reflective!, Shiny!, PatID!, TxMin!,TxMax!
                    CASE "MATSPRITE"   ' material using sprite
                        GOSUB PrepareT
                        DefTextureMaterial T$,2
                        ' syntax is:
                        ' MatID&, RGBColor!, Reflective!, Shiny!, SpriteIndex!, TxMin!,TxMax!
                    CASE "MATSETALPHA"
                        GOSUB PrepareT
                        DefMaterialAlpha T$
                        ' syntax is:
                        ' MatID&, Alpha!   (alpha is from 0 to 100)
                    CASE "MODELRANGE"
                        GOSUB PrepareT
                        SetModelColorRangeCmd T$,2
                        ' syntax is:
                        ' NAME, MinR!, MaxR!, NewVal!
                    CASE "MODELSET"
                        GOSUB PrepareT
                        SetModelColorRangeCmd T$,1
                        ' syntax is:
                        ' NAME, Index!, NewVal!
                END SELECT
            CASE 78 ' N
                SELECT CASE AS CONST$ Cmd$
                    GOSUB PrepareT
                    CASE "NEWMODEL"   ' add new object to universal object list
                        AddNewObject T$
                        ' syntax is like core object coding
                        ' <NAME>
                        ' {W}  World Limits  - ie    {W}(100,100,100)
                        '  define world limits. if 100 instead of -1 to 1 you can use -100 to 100 for a coordinate value
                        ' {P}  Points        - ie.   {P}1(-1,1,0)2(1,1,0)3(1,-1)4(-1,-1,0)
                        '  define points in X!,Y!,Z! coordinates. Number before () is ignored but for reference only
                        ' {M}  Material ID   - ie.   {M}(1)
                        '  define material ID number
                        ' {Q}  Quad Face     - ie.   {Q}(1,3,4,2)
                        '  define Quad corners which are in point list
                        ' {T}  Triangle Face - ie.   {T}(1,2,5)
                        '  define Traingle vertices which are in point list
                        ' {S}  Sphere        - ie.   {S}(1,50,50)
                        '  define sphere which is radius and # of splices vertical and horizontal

                END SELECT
            CASE 79 ' O
                SELECT CASE AS CONST$ Cmd$
                    CASE "OPTIMIZE"
                        Optimize3DObject QObject(TRIM$(T$))
                        ' syntax
                        ' Name
                END SELECT
            CASE 80 ' P
                SELECT CASE AS CONST$ Cmd$
                    CASE "POS"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 2,0
                        ' syntax is:
                        ' IDNum, X!, Y!, Z!
                    CASE "PERSPECTIVE"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,5
                        ' syntax is:
                        ' Perspective!   (0.0 to 180.0)
                END SELECT
            CASE 81 ' Q
                SELECT CASE AS CONST$ Cmd$
                    CASE "QFOG"
                        ' syntax is:
                        ' value!     (0 or 1)
                        CmdQFlags hWnd, T$, 0
                    CASE "QLINES"
                        ' syntax is:
                        ' value!     (0 or 1)
                        CmdQFlags hWnd, T$, 1
                    CASE "QPERSPECTIVE"
                        ' syntax is:
                        ' value!     (0 or 1)
                        CmdQFlags hWnd, T$, 2
                    CASE "QPOINTS"
                        ' syntax is:
                        ' value!     (0 or 1)
                        CmdQFlags hWnd, T$, 3
                    CASE "QPOLYGONS"
                        ' syntax is:
                        ' value!     (0 or 1)
                        CmdQFlags hWnd, T$, 4
                    CASE "QALL"
                        ' syntax is:
                        ' value!     (0 or 1)
                        CmdQFlags hWnd, T$, 99
                END SELECT
            CASE 82 ' R
                SELECT CASE AS CONST$ Cmd$
                    CASE "ROTATE"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 3,0
                        ' syntax is:
                        ' IDNum, rX!, rY!, rZ!
                END SELECT
            CASE 83 ' S
                SELECT CASE AS CONST$ Cmd$
                    CASE "SCALE"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 1,0
                        ' syntax is:
                        ' IDNum, ScaleX!, ScaleY!, ScaleZ!
                    CASE "SROTATE"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 4,0
                        ' syntax is:
                        ' IDNum, srX!, srY!, srZ!
                    CASE "SHOW"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 8,0
                        ' syntax is:
                        ' IDNum
                    CASE "SET"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 6,0
                        ' syntax is:
                        ' IDNum, ScaleX!, ScaleY!, ScaleZ!,X!, Y!, Z!,rX!, rY!, rZ!,srX!, srY!, srZ!,IScaleX!, IScaleY!, IScaleZ!
                    CASE "SHOWALL"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 8,1
                        ' syntax is:
                    CASE "SAVE"         ' save an EZGUI 3D Object
                        ' don't call GOSUB PrepareT
                        SaveEZ3DFileCommand T$
                        ' syntax is:    (file extension not needed) (type 7 (model) has extension .EZ3D) (other types have extension .EZ3P)
                        ' NAME,Filename (can have quotes around filename)
                END SELECT
            CASE 85 ' U
                SELECT CASE AS CONST$ Cmd$
                    CASE "UNLOCK"
                        GOSUB PrepareT
                        LockObject hWnd, T$, 2
                        ' syntax is:
                        ' IDNum
                    CASE "UNLOCKALL"
                        GOSUB PrepareT
                        LockObject hWnd, T$, 4
                        ' syntax is:
                        '
                END SELECT
            CASE 87 ' W
                SELECT CASE AS CONST$ Cmd$
                    CASE "WIRE"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 11,0
                        ' syntax is:
                        ' IDNum, SFlag!
                    CASE "WIREALL"
                        GOSUB PrepareT
                        ChangeSceneObject hWnd, T$, 11,1
                        ' syntax is:
                        ' SFlag!
                END SELECT
            CASE 90 ' Z
                SELECT CASE AS CONST$ Cmd$
                    CASE "ZOOM"
                        GOSUB PrepareT
                        ChangeScene hWnd, T$,4
                        ' syntax is:
                        ' XZoom&, YZoom&    (values from 1 to 100)
                END SELECT
        END SELECT
    END IF
    EXIT SUB

PrepareT:
    T$=REMOVE$(T$, " ")
RETURN

END SUB

SUB ProcessTextCommands(BYVAL hWnd AS LONG, BYVAL lpText AS DWORD)
    LOCAL B AS BYTE PTR, T$, CL&, Cmd$, FB&
    REGISTER CT&,L&
    B=lpText
    L&=0
    CL&=0
    FB&=0
 StartByteRead:
   IF @B=32 THEN    ' test for first space
        IF CL&=0 THEN CL&=L&
   END IF
   IF @B=13 THEN    ' RETURN character is end if line delimiter
        GOSUB ProcessData
        IF @B[1]=10 THEN    ' test next character and if LINEFEED skip it
            INCR B
        END IF
        ' prepare for next string to read
        FB&=0
        L&=0
        CL&=0
        lpText=B+1

        INCR B
        GOTO StartByteRead
    END IF
    IF @B=124 THEN  ' | character is end if line delimiter
        GOSUB ProcessData
        ' prepare for next string to read
        FB&=0
        L&=0
        CL&=0
        lpText=B+1

        INCR B
        GOTO StartByteRead
    END IF
    IF @B=0 THEN
        IF CL&=0 THEN CL&=L&
        GOSUB ProcessData
        GOTO EndByteRead
    END IF
    CT&=CT&+1
    IF CT&>%MaxStringData THEN GOTO EndByteRead  ' max limit of characters
    INCR L& ' add a new character to current string
    IF FB&=0 THEN FB&=@B    ' store first character value
    INCR B
    GOTO StartByteRead
 EndByteRead:
 EXIT SUB

 ProcessData:
    IF CL&>0 THEN
        Cmd$=UCASE$(PEEK$(lpText, CL&))
        T$=PEEK$(lpText+CL&+1, L&-(CL&+1))
    ELSE
        Cmd$=""
        T$=PEEK$(lpText, L&)
    END IF
    ProcessEachTextCommand hWnd, FB&, Cmd$, T$
 RETURN

END SUB

FUNCTION OpenGLClassWndProc(BYVAL hWnd   AS LONG, _
                 BYVAL Msg    AS LONG, _
                 BYVAL wParam AS LONG, _
                 BYVAL lParam AS LONG) EXPORT AS LONG
    STATIC OrigAddress AS DWORD
    LOCAL hDC AS LONG, hGLRC AS LONG, GLMode&, BGDrawMode&, V&, CBA AS DWORD, ABuffer&
    LOCAL Bright&, XZ&, YZ&, L&, T$,RV&, lpText AS DWORD
    SELECT CASE AS LONG Msg
        CASE %WM_SETTEXT
            IF IsWindow(hWnd) THEN
                ProcessTextCommands hWnd, lParam
            END IF
            FUNCTION=1
            EXIT FUNCTION
        CASE %EZGL_DRAWNOW
            IF IsWindow(hWnd) THEN
                GOSUB DrawSceneNow
            END IF
            FUNCTION=1
            EXIT FUNCTION
        CASE %WM_PAINT
            IF IsWindow(hWnd) THEN
                GOSUB DrawSceneNow
            END IF
            ValidateRect hWnd, BYVAL %NULL  ' required when OpenGl draws instead of using BeginPaint
            FUNCTION=0
            EXIT FUNCTION
        CASE %WM_GETTEXT
            RV&=0
            T$=GetInfoString(hWnd)
            L&=wParam
            L&=L&-1
            lpText=lParam
            IF L&>LEN(T$) THEN L&=LEN(T$)
            IF L&<>0 THEN
                IF lpText<>0 THEN
                    POKE$ lpText, LEFT$(T$,L&)+CHR$(0)
                    RV&=L&
                END IF
            END IF
            FUNCTION=RV&
            EXIT FUNCTION
        CASE %WM_GETTEXTLENGTH
            T$=GetInfoString(hWnd)
            FUNCTION=LEN(T$)
            EXIT FUNCTION
        CASE %WM_ERASEBKGND
            FUNCTION=0
            EXIT FUNCTION
        CASE %EZGL_SETBGMODE
            V&=wParam
            IF V&<0 THEN V&=0
            IF V&>2 THEN V&=2
            EZ_SetSuperClassProp hWnd,10,V&
            InvalidateRect hWnd, BYVAL %NULL, 1
            FUNCTION=1
            EXIT FUNCTION
        CASE %EZGL_GETBGMODE
            FUNCTION=EZ_GetSuperClassProp(hWnd,10)
            EXIT FUNCTION
        CASE %EZGL_SETCALLBACKS
            EZ_SetSuperClassProp hWnd,12,wParam     ' Callback address
            hDC=EZ_GetSuperClassProp(hWnd,1)
            hGLRC=EZ_GetSuperClassProp(hWnd,2)
'            CBA=EZ_GetSuperClassProp(hWnd,12)
            DoCallBackOther hWnd, hDC, hGLRC, wParam, -1
            FUNCTION=1
            EXIT FUNCTION

        CASE %WM_CREATE
            IF hWnd=0 THEN
                ' window does not exist yet so hWnd=0
                ' this is sent only once when superclass is create
                ' and before any windows are created
                OrigAddress=EZ_GetSuperAddress
                FUNCTION=1
                EXIT FUNCTION
            END IF
            LOCAL WS&
            WS&=GetWindowLong(hWnd, %GWL_STYLE)
            IF (WS& AND %EZCVS_DOUBLEBUFFER) = %EZCVS_DOUBLEBUFFER THEN

            END IF
            GLMode&=1   ' always use OpenGL DoubleBuffering
            ABuffer&=0
            WS&=WS& OR %EZCVS_DIBSECTION OR %EZCVS_32BIT    ' force 32 bit DIBs
            WS&=WS& OR %WS_CLIPCHILDREN OR %WS_CLIPSIBLINGS
            SetWindowLong hWnd, %GWL_STYLE, WS&
            FUNCTION=EZ_CallSuperProc(OrigAddress, hWnd, Msg, wParam, lParam)
            EZ_InitSuperClassProps hWnd  ' all 50 properties are set to zero
            InitOpenGLWindow hWnd, hDC, hGLRC, GLMode&, ABuffer&
            EZ_SetSuperClassProp hWnd,1, hDC
            EZ_SetSuperClassProp hWnd,2, hGLRC
            EZ_SetSuperClassProp hWnd,9, GLMode&
            CreateBuffers hWnd, 1
            EZ_SetSuperClassProp hWnd,10, 1 ' update Bitmap copy and use it to draw background

            EZ_SetSuperClassProp hWnd,%PROP_COLOR, RGB(255,255,255)  ' default BG color is white
            EZ_SetSuperClassProp hWnd,12, 0     ' callback address BEFORE
            EZ_SetSuperClassProp hWnd,%PROP_BGCUTOFF, 0   ' BG Cutoff value (0 to 95%)
            EZ_SetSuperClassProp hWnd,%PROP_BRIGHT, 100   ' brightness factor
            EZ_SetSuperClassProp hWnd,%PROP_ZOOMX, 100   ' X zoom factor
            EZ_SetSuperClassProp hWnd,%PROP_ZOOMY, 100   ' Y zoom factor
            EZ_SetSuperClassProp hWnd,17, ABuffer&  ' accum buffer flag
            EZ_SetSuperClassProp hWnd,%PROP_PERSP, FloatToLong(25.0)     ' default perspective value
            EZ_SetSuperClassProp hWnd,%PROP_LIGHTY, 45    ' Light1 Y Degrees (0 to 360)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHTX, 45    ' Light1 X Degree (0 to 90)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHTZ, 1000  ' Light1 Distance (0 to 1000+)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHTA, 40    ' Light1 Ambient Level (0 to 100)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHTD, 50    ' Light1 Diffuse Level (0 to 100)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHT2, 0     ' is Light 2 ON or off
            EZ_SetSuperClassProp hWnd,%PROP_LIGHT2Y, 315   ' Light2 Y Degrees (0 to 360)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHT2X, 45    ' Light2 X Degree (0 to 90)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHT2Z, 1000  ' Light2 Distance (0 to 1000+)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHT2A, 40    ' Light2 Ambient Level (0 to 100)
            EZ_SetSuperClassProp hWnd,%PROP_LIGHT2D, 50    ' Light2 Diffuse Level (0 to 100)
            EZ_SetSuperClassProp hWnd,%PROP_QUALITY, 0
            SetQFlags hWnd,1,1,1,1,1    ' set individual bit flags for %PROP_QUALITY
            ' may not need this since Windows generates %WM_SIZE when control first is created
            ResizeOpenGLWindow hWnd, hDC, hGLRC
            EXIT FUNCTION
        CASE %WM_LBUTTONUP
            IF ErrorList$<>"" THEN
                MSGBOX ErrorList$
                ErrorList$=""
            END IF
'            else
'                msgbox App_GLVendor$
'                msgbox App_GLRenderer$
'                msgbox App_GLVersion$
'                replace " " with chr$(13)+chr$(10) in App_GLExtensions$
'                msgbox App_GLExtensions$
'            end if
        CASE %WM_SIZE
            FUNCTION=EZ_CallSuperProc(OrigAddress, hWnd, Msg, wParam, lParam)
            CreateBuffers hWnd, 2
            InvalidateRect hWnd, BYVAL %NULL, 1
            EXIT FUNCTION
        CASE %WM_DESTROY
            ' --------------------------------------------
            hDC=EZ_GetSuperClassProp(hWnd,1)
            hGLRC=EZ_GetSuperClassProp(hWnd,2)
            CBA=EZ_GetSuperClassProp(hWnd,12)
            DoCallBackOther hWnd, hDC, hGLRC, CBA, -2
            ' --------------------------------------------
            RV&=ProcessSceneObjects(hWnd, 2, 0, 1)  ' free all display lists
            EZ_FreeSuperClassString hWnd, 18        ' free scene string data
            EZ_FreeSuperClassString hWnd, %PROP_INFOSTR ' last info string
            GOSUB GetGLDCs
            FreeOpenGLWindow hWnd, hDC, hGLRC
            CreateBuffers hWnd, 0   ' frees memory buffer
            EZ_FreeSuperClassProps hWnd
        CASE ELSE
    END SELECT
    FUNCTION=EZ_CallSuperProc(OrigAddress, hWnd, Msg, wParam, lParam)
    EXIT FUNCTION

GetGLDCs:
    hDC=EZ_GetSuperClassProp(hWnd,1)
    hGLRC=EZ_GetSuperClassProp(hWnd,2)
    GLMode&=EZ_GetSuperClassProp(hWnd,9)
    BGDrawMode&=EZ_GetSuperClassProp(hWnd,10)
RETURN

DrawSceneNow:
    ' draw scene now
    GOSUB GetGLDCs
    CBA=EZ_GetSuperClassProp(hWnd,12)   ' get callback address
    Bright&=EZ_GetSuperClassProp(hWnd,%PROP_BRIGHT)
    XZ&=EZ_GetSuperClassProp(hWnd,%PROP_ZOOMX)
    YZ&=EZ_GetSuperClassProp(hWnd,%PROP_ZOOMY)
    DrawOpenGLWindow hWnd, hDC, hGLRC, GLMode&, BGDrawMode&, CBA, Bright&, XZ&, YZ&
RETURN

END FUNCTION
