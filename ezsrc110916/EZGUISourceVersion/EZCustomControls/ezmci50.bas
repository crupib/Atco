' -------------------------------------------------------------------------------------------
'                       Official EZGUI 4.0 MCI control !
' -------------------------------------------------------------------------------------------

#DEBUG ERROR OFF

#COMPILE DLL "ezgui5mm.dll"
$RESOURCE "ezmci50.pbr
#REGISTER NONE
'#INCLUDE "win32api.inc"
 #INCLUDE "mciwinclean.inc"


' #include "c:\pbdll60\winapi\mmsystem.inc"

' DECLARE FUNCTION mciSendSTRING LIB "MMSYSTEM" (lpstrCommand AS ASCIIZ, lpstrReturnSTRING AS ASCIIZ, BYVAL uReturnLength AS WORD, BYVAL hWndCallback AS WORD) AS DWORD
' DECLARE FUNCTION mciGetErrorSTRING LIB "MMSYSTEM" (BYVAL wError AS DWORD, lpstrBuffer AS ASCIIZ, BYVAL uLength AS WORD) AS WORD

' #RESOURCE "ezmedit.pbr"

' -------------------------------------------------------------------------------------------
'                          Custom Class ControlClass Constants and Types
' -------------------------------------------------------------------------------------------
%ControlClassExtraData       = 5     ' # of Extra Data Items (Long) for All Custom Window Classes
                                ' Data Items will be indexed from 1 in GetControlData function
                                ' Data Items can be either a String or a Long
' -------------------------------------------------------------------------------------------
$ControlClassName            = "EZGUI50_MCI_32"
' -------------------------------------------------------------------------------------------
'                           XX-XXXX-XXXX-XXX    Bits with - never used
%ControlClassOKStyles =   &B0101111011000111    ' Styles Hi Word WM_ styles acceptable
'                           XX-||||-||||-|||    WS_CHILD (01)
'                           ---X|||-||||-|||       WS_VISIBLE
'                           ----X||-||||-|||       WS_DISABLED
'                           -----X|-||||-|||       WS_CLIPSIBLINGS
'                           ------X-||||-|||       WS_CLIPCHILDREN
'                           --------X|||-|||    WS_BORDER
'                           ---------X||-|||    WS_DLGFRAME
'                           ----------X|-|||    WS_VSCROLL
'                           -----------X-|||    WS_HSCROLL
'                           -------------X||       WS_THICKFRAME
'                           --------------X|       WS_GROUP
'                           ---------------X       WS_TABSTOP
' -------------------------------------------------------------------------------------------


' -------------------------------------------------------------------------------------------
'                              Universal Global Variables
' -------------------------------------------------------------------------------------------
GLOBAL DLL_Instance&
GLOBAL DLL_OriginalProc&
GLOBAL DLL_OriginalWndExtra&


%EZMM_PLAY                  =   %WM_USER+100    ' wParam is Asciiz ptr to filename

' -------------------------------------------------------------------------------------------
'                           EZGUI Custom Control Library Declares
' -------------------------------------------------------------------------------------------
DECLARE FUNCTION GetControlLong(BYVAL hWnd AS LONG, BYVAL N&) AS LONG
DECLARE SUB SetControlLong(BYVAL hWnd AS LONG, BYVAL N&, BYVAL V&)
DECLARE SUB SetControlString(BYVAL hWnd AS LONG, BYVAL N&, BYVAL D$)
DECLARE FUNCTION GetControlString(BYVAL hWnd AS LONG, BYVAL N&) AS STRING
DECLARE SUB FreeControlString(BYVAL hWnd AS LONG, BYVAL N&)

' -------------------------------------------------------------------------------------------
'                           Custom Control Control Class Declares
' -------------------------------------------------------------------------------------------
DECLARE SUB RegisterControlClass()

' -------------------------------------------------------------------------------------------
'                              DLL Entrance - LibMain
' -------------------------------------------------------------------------------------------

FUNCTION LIBMAIN(BYVAL hInstance   AS LONG, _
                 BYVAL fwdReason   AS LONG, _
                 BYVAL lpvReserved AS LONG) EXPORT AS LONG
    SELECT CASE AS LONG fwdReason
        CASE %DLL_PROCESS_ATTACH    ' =1 - Where DLL starts
            DLL_Instance&=hInstance
            RegisterControlClass
        CASE %DLL_THREAD_ATTACH
        CASE %DLL_THREAD_DETACH
        CASE %DLL_PROCESS_DETACH    ' =0 - Where DLL exits
        CASE ELSE
    END SELECT
    LIBMAIN=1
END FUNCTION


' -------------------------------------------------------------------------------------------
'                          Custom Control ControlClass Functions / Subs
' -------------------------------------------------------------------------------------------
SUB RegisterControlClass()
LOCAL windowclass    AS WndClassEx
LOCAL szClassName AS ASCIIZ * 80
szClassName               = $ControlClassName+CHR$(0)
windowclass.cbSize        = SIZEOF(windowclass)
windowclass.style         = %CS_HREDRAW OR %CS_VREDRAW OR %CS_DBLCLKS  ' OR %CS_GLOBALCLASS
windowclass.lpfnWndProc   = CODEPTR(ControlClassWndProc)
windowclass.cbClsExtra    = 0
windowclass.cbWndExtra    = %ControlClassExtraData*4
windowclass.hInstance     = GetModuleHandle(BYVAL %NULL)    'DLL_Instance&
windowclass.hIcon         = %NULL
windowclass.hCursor       = LoadCursor(%NULL, BYVAL %IDC_ARROW)
windowclass.hbrBackground = GetStockObject( %BLACK_BRUSH )
windowclass.lpszMenuName  = %NULL
windowclass.lpszClassName = VARPTR( szClassName )
windowclass.hIconSm       = %NULL
RegisterClassEx windowclass
' RegisterClassEx windowclass
END SUB


FUNCTION MCISend(BYVAL hCtrl&, BYVAL MCIText$, BYVAL NFlag&) AS LONG
LOCAL RText$, RV&, RV2&, Tmp$, hWndCB&
RText$=STRING$(129," ")
hWndCB&=%NULL
Tmp$=TRIM$(UCASE$(MCIText$))
IF RIGHT$(Tmp$,7)=" NOTIFY" THEN hWndCB&=hCtrl&
IF LEFT$(Tmp$,7)="SIGNAL " THEN hWndCB&=hCtrl&
RV&=mciSendSTRING(BYVAL STRPTR(MCIText$), BYVAL STRPTR(RText$), 128, hWndCB&)
IF RV&=0 THEN
    RText$=TRIM$(REMOVE$(RText$, CHR$(0)))
    IF RText$="1" AND NFlag&=0 THEN RText$="OK"
    SetControlString hCtrl&, 3, RText$
ELSE
    RText$=STRING$(129," ")
    RV2&=mciGetErrorString(RV&, BYVAL STRPTR(RText$), 128)
    IF RV2&=0 THEN RText$=""
    RText$="ERROR: "+RText$
    SetControlString hCtrl&, 3, RText$
END IF
FUNCTION=RV&
END FUNCTION

' -------------------------------------------------------------------------------------------

FUNCTION GetNextWord(MCIText$) AS STRING
LOCAL P&, RV$, N&, QFlag&, BPTR AS BYTE PTR
MCIText$=TRIM$(MCIText$)
QFlag&=0
BPTR=STRPTR(MCIText$)
FOR N&=1 TO LEN(MCIText$)
    IF @BPTR=34 THEN
        IF QFlag&=0 THEN QFlag&=1 ELSE QFlag&=0
    END IF
    IF QFlag&=1 AND @BPTR=32 THEN @BPTR=255
    INCR BPTR
NEXT N&
P&=INSTR(MCIText$," ")
IF P&<>0 THEN
    RV$=LEFT$(MCIText$, P&-1)
    MCIText$=MID$(MCIText$, P&+1)
ELSE
    RV$=TRIM$(MCIText$)
    MCIText$=""
END IF
REPLACE CHR$(255) WITH " " IN RV$
REPLACE CHR$(255) WITH " " IN MCIText$
FUNCTION=RV$
END FUNCTION

' -------------------------------------------------------------------------------------------

FUNCTION ZMyAlias(BYVAL hCtrl&) AS STRING
    FUNCTION="EZGUIMM"+TRIM$(STR$(hCtrl&))
END FUNCTION

SUB ZCloseAlias(BYVAL hCtrl&)
    IF GetControlLong(hCtrl&, 5)<>0 THEN
        RV&=MCISend(hCtrl&, "stop "+ZMyAlias(hCtrl&), 0)
        RV&=MCISend(hCtrl&, "close "+ZMyAlias(hCtrl&), 0)
        SetControlLong hCtrl&, 5, 0  ' no device
    END IF
END SUB

SUB EZMCISend(BYVAL hCtrl&, BYVAL MCIText$)
LOCAL EZMsg$, RV&, Tmp$, F$, CP$, hParent&, MName$, Mode$, TP&, CP2$, D$, V$, MNameTmp$, DV$
LOCAL LastMsg$
MName$=ZMyAlias(hCtrl&)
Tmp$=""
EZMsg$=UCASE$(GetNextWord(MCIText$))
REPLACE "|" WITH CHR$(34) IN MCIText$
LastMsg$=""
SELECT CASE AS CONST$ EZMsg$
    CASE "EZOPENMOVIE"
        GOSUB CloseCurrent
        GOSUB GetWords
        mode$=""        ' figure out by file extension
        DRV$=""
        IF INSTR(CP$,"D")<>0 THEN DRV$=TRIM$(GetNextWord(MCIText$))
        IF DRV$="" THEN
'            IF EZMsg$="EZOPENAVI" THEN mode$="type AVIVideo "
'            IF EZMsg$="EZOPENMPEG" THEN mode$="type MPEGVideo "
        ELSE
            mode$="type "+DRV$+" "
        END IF
        IF F$<>"" THEN
            Tmp$=" alias "+MName$
            IF INSTR(CP$,"P") THEN
                Tmp$=Tmp$+" parent"+STR$(GetParent&(hCtrl&))+" style overlapped"
            ELSE
                Tmp$=Tmp$+" parent"+STR$(hCtrl&)+" style child"
            END IF
            IF INSTR(CP$,"S") THEN Tmp$=Tmp$+" shareable"
            GOSUB AddWaitNotifyFlags
            RV&=MCISend(hCtrl&, "open "+mode$+F$+Tmp$, 0)
            LastMsg$=TRIM$(GetControlString(hCtrl&, 3))
            IF RV&=0 THEN
                IF INSTR(CP$,"+") THEN
                    DIM R AS RECT, VR AS RECT, SR AS RECT, W&, H&, NW&, NH&
                    GetClientRect hCtrl&, R
                    RV&=MCISend(hCtrl&,"where "+MName$+" source", 0)
                    D$=TRIM$(GetControlString(hCtrl&, 3))
                    IF RV&=0 THEN
                       IF D$<>"" THEN
                           VR.nLeft=VAL(PARSE$(D$," ",1))
                           VR.nTop=VAL(PARSE$(D$," ",2))
                           VR.nRight=VAL(PARSE$(D$," ",3))     ' width
                           VR.nBottom=VAL(PARSE$(D$," ",4))    ' height
                           W&=VR.nRight
                           H&=VR.nBottom
                       ELSE
                           RV&=1
                       END IF
                    END IF
                    IF RV&=0 THEN
                        IF INSTR(CP$,"P") THEN
                            NW&=W&+(2*GetSystemMetrics(%SM_CXSIZEFRAME))
                            NH&=H&+(2*GetSystemMetrics(%SM_CYSIZEFRAME))+GetSystemMetrics(%SM_CYCAPTION)
                            SystemParametersInfo %SPI_GETWORKAREA, 0, BYVAL VARPTR(SR), 0
                            VR.nLeft=SR.nLeft+((SR.nRight-NW&)/2)
                            VR.nTop=SR.nTop+((SR.nBottom-NH&)/2)
                            VR.nRight=NW&
                            VR.nBottom=NH&
                            RV&=MCISend(hCtrl&,"put "+MName$+" window at "+STR$(VR.nLeft)+STR$(VR.nTop)+STR$(VR.nRight)+STR$(VR.nBottom), 0)
                            R.nRight=W&
                            R.nBottom=H&
                        ELSE
                            IF W&<R.nRight AND H&<R.nBottom THEN RV&=1  ' don't size destination
                        END IF
                    END IF
                    IF RV&=0 THEN
                        RV&=MCISend(hCtrl&,"put "+MName$+" destination at "+STR$(R.nLeft)+STR$(R.nTop)+STR$(R.nRight)+STR$(R.nBottom), 0)
                    END IF
                END IF
                SetControlLong hCtrl&, 5, 1  ' video device
                SetControlString hCtrl&, 3, LastMsg$
            END IF
        END IF
    CASE "EZOPENWAVE"
        GOSUB CloseCurrent
        GOSUB GetWords
        IF F$<>"" THEN
            Tmp$=" alias "+MName$
            IF INSTR(CP$,"S") THEN Tmp$=Tmp$+" shareable"
            GOSUB AddWaitNotifyFlags
            RV&=MCISend(hCtrl&, "open "+F$+Tmp$, 0)
            SetControlLong hCtrl&, 5, 2  ' audio device
        END IF
    CASE "EZOPENMIDI"
        GOSUB CloseCurrent
        GOSUB GetWords
        IF F$<>"" THEN
            Tmp$=" alias "+MName$
            IF INSTR(CP$,"S") THEN Tmp$=Tmp$+" shareable"
            GOSUB AddWaitNotifyFlags
            RV&=MCISend(hCtrl&, "open "+F$+Tmp$, 0)
            SetControlLong hCtrl&, 5, 3  ' midi device
        END IF
    CASE "EZOPENCD"
        GOSUB CloseCurrent
        CP$=UCASE$(GetNextWord(MCIText$))
        Tmp$=" alias "+MName$
        IF INSTR(CP$,"S") THEN Tmp$=Tmp$+" shareable"
        GOSUB AddWaitNotifyFlags
        RV&=MCISend(hCtrl&, "open cdaudio"+Tmp$, 0)
        SetControlLong hCtrl&, 5, 4  ' CD device
    CASE "EZCLOSE"
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            RV&=MCISend(hCtrl&, "close "+MName$+" wait", 0)
            SetControlLong hCtrl&, 5, 0  ' no device
        END IF
    CASE "EZPLAY"
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            CP$=UCASE$(GetNextWord(MCIText$))
            Tmp$=""
            IF INSTR(CP$,"F") THEN Tmp$=Tmp$+" fullscreen"
            IF INSTR(CP$,"R") THEN
                Tmp$=Tmp$+" repeat"
            ELSE
                GOSUB AddWaitNotifyFlags
            END IF
            RV&=MCISend(hCtrl&, "play "+MName$+Tmp$, 0)
        END IF
    CASE "EZSTOP"
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            RV&=MCISend(hCtrl&, "stop "+MName$+" wait", 0)
        END IF
    CASE "EZPAUSE"
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            RV&=MCISend(hCtrl&, "pause "+MName$+" wait", 0)
        END IF
    CASE "EZRESUME"
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            RV&=MCISend(hCtrl&, "resume "+MName$+" wait", 0)
        END IF
    CASE "EZSTEP"
        V$=UCASE$(GetNextWord(MCIText$))
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            IF V$<>"" THEN Tmp$=" by "+V$
            RV&=MCISend(hCtrl&, "step "+MName$+Tmp$+" wait", 0)
        END IF
    CASE "EZTO", "EZTOSTART", "EZTOEND"
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            CP$=UCASE$(GetNextWord(MCIText$))
            Tmp$=""
            IF EZMsg$="EZTOSTART" THEN
                Tmp$=" to start"
            ELSEIF EZMsg$="EZTOEND" THEN
                Tmp$=" to end"
            ELSEIF CP$<>"" THEN
                Tmp$=" to "+TRIM$(CP$)
            END IF
            IF Tmp$<>"" THEN
                RV&=MCISend(hCtrl&, "seek "+MName$+Tmp$+" wait", 0)
            END IF
        END IF
    CASE "EZVIDEODLG"
        CP$=UCASE$(GetNextWord(MCIText$))
        GOSUB AddWaitNotifyFlags
        IF GetControlLong(hCtrl&, 5)=1 THEN  ' video only
            RV&=MCISend(hCtrl&, "configure "+MName$+Tmp$+" wait", 0)
        END IF
    CASE "EZALIAS"
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            SetControlString hCtrl&, 3, MName$
        ELSE
            SetControlString hCtrl&, 3, ""
        END IF
    CASE "EZDOOR"
        V$=UCASE$(GetNextWord(MCIText$))
        IF V$="OPEN" OR V$="CLOSE" THEN
            CP$=UCASE$(GetNextWord(MCIText$))
        ELSE
            CP$=V$
            V$=""
        END IF
        GOSUB AddWaitNotifyFlags
        IF GetControlLong(hCtrl&, 5)=4 THEN
            IF V$="OPEN" THEN
                RV&=MCISend(hCtrl&, "set "+MName$+" door open"+Tmp$+" wait", 0)
            ELSE
                RV&=MCISend(hCtrl&, "set "+MName$+" door close"+Tmp$+" wait", 0)
            END IF
        END IF
    CASE "EZSOUND"
        TP&=GetControlLong(hCtrl&, 5)
        IF TP&<>0 AND TP&<>2 THEN
            CP$=UCASE$(GetNextWord(MCIText$))
            CP2$=UCASE$(GetNextWord(MCIText$))
            SELECT CASE AS CONST$ CP$
                CASE "ON"
                    RV&=MCISend(hCtrl&, "set "+MName$+" audio all on", 0)
                CASE "OFF"
                    RV&=MCISend(hCtrl&, "set "+MName$+" audio all off", 0)
                CASE "LEFT"
                    IF CP2$="OFF" THEN
                        RV&=MCISend(hCtrl&, "set "+MName$+" audio left off", 0)
                    ELSE
                        RV&=MCISend(hCtrl&, "set "+MName$+" audio left on", 0)
                    END IF
                CASE "RIGHT"
                    IF CP2$="OFF" THEN
                        RV&=MCISend(hCtrl&, "set "+MName$+" audio right off", 0)
                    ELSE
                        RV&=MCISend(hCtrl&, "set "+MName$+" audio right on", 0)
                    END IF
                CASE ELSE
            END SELECT
        END IF
    CASE "EZTRACK"
        IF GetControlLong(hCtrl&, 5)=4 THEN
            CP$=UCASE$(GetNextWord(MCIText$))
            CP2$=UCASE$(GetNextWord(MCIText$))
            SELECT CASE AS CONST$ CP$
                CASE "MAX"
                    RV&=MCISend(hCtrl&, "status "+MName$+" number of tracks"+" wait",1)
                CASE "CURRENT"
                    RV&=MCISend(hCtrl&, "status "+MName$+" current track"+" wait",1)
                CASE "TYPE"
                    RV&=MCISend(hCtrl&, "status "+MName$+" cdaudio type track "+CP2$+" wait", 0)
                CASE "LENGTH"
                    RV&=MCISend(hCtrl&, "status "+MName$+" length track "+CP2$+" wait",1)
                CASE ELSE
            END SELECT
        END IF
    CASE "EZLENGTH"
        IF GetControlLong(hCtrl&, 5)<>0 THEN
            RV&=MCISend(hCtrl&, "status "+MName$+" length"+" wait", 1)
        END IF
    CASE "EZINFO"
        TP&=GetControlLong(hCtrl&, 5)
        IF TP&<>0 THEN
            CP$=UCASE$(GetNextWord(MCIText$))
            SELECT CASE AS CONST$ CP$
                CASE "DEVICE"
                    RV&=MCISend(hCtrl&, "sysinfo "+MName$+" installname", 0)
                CASE ELSE
                    RV&=MCISend(hCtrl&, "info "+MName$+" product", 0)
                    D$=TRIM$(GetControlString(hCtrl&, 3))
                    IF TP&=1 AND CP$<>"CODEC" THEN
                        IF RV&=0 THEN
                            RV&=MCISend(hCtrl&, "info "+MName$+" version", 1)
                            IF RV&=0 THEN
                                D$=D$+" "+TRIM$(GetControlString(hCtrl&, 3))
                            END IF
                        END IF
                    END IF
                    IF RV&=0 THEN SetControlString hCtrl&, 3, D$
            END SELECT
        END IF
    CASE "EZGETSIZE"
        F$=GetNextWord(MCIText$)
        MNameTmp$=MName$+"TMP"
        CP$=UCASE$(GetNextWord(MCIText$))
        GOSUB AddWaitNotifyFlags
        RV&=MCISend(hCtrl&, "open "+F$+" alias "+MNameTmp$+" wait",0)
        IF RV&=0 THEN
            RV&=MCISend(hCtrl&,"where "+MNameTmp$+" source",1)
            D$=TRIM$(GetControlString(hCtrl&, 3))
            IF D$<>"" THEN
                D$=PARSE$(D$," ",3)+" "+PARSE$(D$," ",4)
            ELSE
                D$="0 0"
            END IF
            RV&=MCISend(hCtrl&, "close "+MNameTmp$+Tmp$, 0)
            SetControlString hCtrl&, 3, D$
        END IF
    CASE "EZFLAG"
        V$=GetNextWord(MCIText$)
        CP$=UCASE$(GetNextWord(MCIText$))
        IF GetControlLong(hCtrl&, 5)=1 THEN  ' video only
            IF INSTR(CP$,"I") THEN
                Tmp$=" every "+V$+" return position"   ' assume frames interval
                GOSUB AddWaitNotifyFlags
            ELSEIF INSTR(CP$,"F") THEN
                Tmp$=" at "+V$+" return position"
                GOSUB AddWaitNotifyFlags
            ELSE
                Tmp$=" cancel"
            END IF
            RV&=MCISend(hCtrl&, "signal "+MName$+Tmp$, 0)
        END IF
    CASE "EZTIMEBY"
        TP&=GetControlLong(hCtrl&, 5)
        CP$=GetNextWord(MCIText$)
        IF TP&<>0 THEN
            SELECT CASE AS LONG TP&
                CASE 1  ' video
                    Tmp$=" time format frames"
                CASE 2  ' wave
                    Tmp$=" time format milliseconds"
                CASE 3  ' MIDI
                    Tmp$=" time format milliseconds"
                CASE 4  ' CD
                    Tmp$=" time format tmsf"
                CASE ELSE
                    Tmp$=" time format milliseconds"
            END SELECT
            SELECT CASE AS CONST$ UCASE$(CP$)
                CASE "F"
                    Tmp$=" time format frames"
                CASE "M"
                    Tmp$=" time format milliseconds"
                CASE "T"
                    Tmp$=" time format track"
                CASE ""
                CASE ELSE
                    REPLACE "_" WITH " " IN CP$
                    Tmp$=" time format "+CP$
            END SELECT
            RV&=MCISend(hCtrl&, "set "+MName$+Tmp$+" wait", 0)
        END IF
    CASE ELSE
END SELECT
EXIT SUB

AddWaitNotifyFlags:
    IF INSTR(CP$,"W") THEN Tmp$=Tmp$+" wait"
    IF INSTR(CP$,"N") THEN Tmp$=Tmp$+" notify"
RETURN

GetWords:
F$=GetNextWord(MCIText$)
CP$=UCASE$(GetNextWord(MCIText$))
RETURN

CloseCurrent:
    ZCloseAlias hCtrl&
RETURN

END SUB

' -------------------------------------------------------------------------------------------

%EZ_FinishMCI   =   50
%EZ_FlagMCI     =   51


TYPE EZMCI_NMHDR
  hwndFrom AS LONG
  idfrom AS LONG
  CODE AS LONG
  signal AS LONG
END TYPE

SUB SendMyMMNotify(BYVAL hCtrl&, BYVAL Msg&, BYVAL wParam&, BYVAL lParam&)
    LOCAL hParent&, MyID&, RV&
    LOCAL NM AS EZMCI_NMHDR
    MyID&=GetWindowLong(hCtrl&,%GWL_ID)
    NM.hwndFrom=hCtrl&
    NM.idfrom=MyID&

    SELECT CASE AS LONG Msg&
        CASE %MM_MCINOTIFY
            NM.code     = %EZ_FinishMCI
            NM.signal   = wParam&   ' flags
        CASE %MM_MCISIGNAL
            NM.code     = %EZ_FlagMCI
            NM.signal   = lParam&
        CASE ELSE
            EXIT SUB
    END SELECT
    hParent&=GetParent(hCtrl&)
    IF hParent&<>0 THEN
        RV&=SendMessage(hParent&, %WM_NOTIFY, MyID&,VARPTR(NM))
    END IF
END SUB

FUNCTION ControlClassWndProc(BYVAL hCtrl AS LONG, _
                 BYVAL Msg    AS LONG, _
                 BYVAL wParam AS LONG, _
                 BYVAL lParam AS LONG) EXPORT AS LONG
LOCAL RV&, MCIText$, MT AS ASCIIZ PTR, Tmp$, MMode&

SELECT CASE AS LONG Msg
      CASE %WM_CREATE
          SetControlLong hCtrl, 1, 0
          SetControlLong hCtrl, 2, 0
          SetControlString hCtrl, 3, " "    ' return string for MCI commands
          SetControlString hCtrl, 4, " "
          SetControlLong hCtrl, 5, 0        ' type of device currently opened
      CASE %WM_SETTEXT
          MT=lParam
          MCIText$=@MT
          MCIText$=LTRIM$(MCIText$)
          SetControlString hCtrl, 3, ""
          MMode&=0
          Tmp$=TRIM$(UCASE$(MCIText$))
          IF LEFT$(Tmp$,2)="EZ" THEN
              EZMCISend hCtrl, MCIText$
          ELSE
              REPLACE "|" WITH CHR$(34) IN MCIText$
              IF INSTR(MCIText$, "{EZ}") THEN
                  REPLACE "{EZ}" WITH ZMyAlias(hCtrl) IN MCIText$
                  IF LEFT$(Tmp$,5)="OPEN " THEN
                       ZCloseAlias hCtrl&
                       MMode&=-1    ' assume movie
                       IF INSTR(Tmp$," CDAUDIO") THEN MMode&=-4
                       IF INSTR(Tmp$,".WAV ") THEN MMode&=-2
                       IF INSTR(Tmp$,".WAV"+CHR$(34)) THEN MMode&=-2
                       IF INSTR(Tmp$,".MID ") THEN MMode&=-3
                       IF INSTR(Tmp$,".MID"+CHR$(34)) THEN MMode&=-3
                  END IF
              END IF
              RV&=MCISend(hCtrl, MCIText$, 1)
              IF RV&=0 THEN     ' command succeeded
                  IF MMode&<0 THEN  ' open command executed
                      ' flag default alias type
                      SetControlLong hCtrl&, 5, ABS(MMode&)
                  END IF
              END IF
          END IF
          FUNCTION=%TRUE
          EXIT FUNCTION
      CASE %WM_GETTEXT
          MCIText$=GetControlString(hCtrl, 3)
          SetControlString hCtrl, 3, ""    ' clear after call
          MCIText$=LEFT$(MCIText$, wParam-1)
          MT=lParam
          @MT=MCIText$
          FUNCTION=LEN(MCIText$)
          EXIT FUNCTION
      CASE %WM_GETTEXTLENGTH
          MCIText$=GetControlString(hCtrl, 3)
          FUNCTION=LEN(MCIText$)
          EXIT FUNCTION
      CASE %WM_DESTROY
          ZCloseAlias hCtrl     ' close any media still open
          FreeControlString hCtrl, 3
          FreeControlString hCtrl, 4
      CASE %MM_MCINOTIFY, %MM_MCISIGNAL
          SendMyMMNotify hCtrl, Msg, wParam, lParam
          FUNCTION=0
          EXIT FUNCTION
      CASE ELSE
END SELECT
FUNCTION = DefWindowProc(hCtrl,Msg,wParam,lParam)
END FUNCTION

' -------------------------------------------------------------------------------------------





' -------------------------------------------------------------------------------------------
'                             EZGUI Custom Control Library
' -------------------------------------------------------------------------------------------

FUNCTION GetControlLong(BYVAL hWnd AS LONG, BYVAL N&) AS LONG
LOCAL I&, RV&
RV&=0
IF N&>=1 AND N&<=%ControlClassExtraData THEN
    I&=(N&-1)*4 + DLL_OriginalWndExtra&
    IF IsWindow(hWnd) THEN
        RV&=GetWindowLong(hWnd, I&)
    END IF
END IF
FUNCTION=RV&
END FUNCTION

' -------------------------------------------------------------------------------------------

SUB SetControlLong(BYVAL hWnd AS LONG, BYVAL N&, BYVAL V&)
LOCAL I&
IF N&>=1 AND N&<=%ControlClassExtraData THEN
    I&=(N&-1)*4 + DLL_OriginalWndExtra&
    IF IsWindow(hWnd) THEN
        SetWindowLong hWnd, I&, V&
    END IF
END IF
END SUB

' -------------------------------------------------------------------------------------------

SUB SetControlString(BYVAL hWnd AS LONG, BYVAL N&, BYVAL D$)
LOCAL hData AS LONG, lpAddress AS LONG
IF D$="" THEN D$=" "
IF LEN(D$)<>0 THEN
    IF N&>=1 AND N&<=%ControlClassExtraData THEN
        IF IsWindow(hWnd) THEN
            hData=GetControlLong(hWnd, N&)
            IF hData<>0 THEN
                GlobalFree hData
            END IF
            hData=GlobalAlloc(%GMEM_MOVEABLE, LEN(D$))
            lpAddress=GlobalLock(hData)
            POKE$ lpAddress, D$
            GlobalUnlock hData
            SetControlLong hWnd, N&, hData
        END IF
    END IF
END IF
END SUB

' -------------------------------------------------------------------------------------------

FUNCTION GetControlString(BYVAL hWnd AS LONG, BYVAL N&) AS STRING
LOCAL hData AS LONG, lpAddress AS LONG
LOCAL D$, L&
D$=""
IF N&>=1 AND N&<=%ControlClassExtraData THEN
    IF IsWindow(hWnd) THEN
        hData=GetControlLong(hWnd, N&)
        IF hData<>0 THEN
            lpAddress=GlobalLock(hData)
            L&=GlobalSize(hData)
            D$=PEEK$(lpAddress, L&)
            GlobalUnlock hData
        END IF
    END IF
END IF
IF D$=" " THEN D$=""
FUNCTION=D$
END FUNCTION

' -------------------------------------------------------------------------------------------

SUB FreeControlString(BYVAL hWnd AS LONG, BYVAL N&)
LOCAL hData AS LONG, lpAddress AS LONG
IF N&>=1 AND N&<=%ControlClassExtraData THEN
    IF IsWindow(hWnd) THEN
        hData=GetControlLong(hWnd, N&)
        IF hData<>0 THEN
            GlobalFree hData
            SetControlLong hWnd, N&, 0
        END IF
    END IF
END IF
END SUB

' DECLARE FUNCTION sndPlaySound LIB "MMSYSTEM" (lpszSoundName AS ASCIIZ, BYVAL uFlags AS WORD) AS WORD
' DECLARE FUNCTION PlaySound LIB "WINMM.DLL" ALIAS "PlaySoundA" (lpszName AS ASCIIZ, BYVAL hModule AS LONG, BYVAL dwFlags AS LONG) AS LONG
