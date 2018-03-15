' -------------------------------------------------------------------------------------------
'             Official EZGUI 5.0 Masked Edit control !
' -------------------------------------------------------------------------------------------

#IF %DEF(%BuildSLL)
     ' SLL code is combined into main SLL so need for independent SLL
#ELSE
     %BuildSLL      =    0
#ENDIF

#IF %BuildSLL

#ELSE
     #DEBUG ERROR OFF
     #COMPILE DLL "ezgui5me.dll"
     #REGISTER NONE
     #INCLUDE "editwinclean.inc"
'     #INCLUDE "C:\Pbdll60\winapi\win32api.inc"
     #RESOURCE "ezmedit50.pbr"
#ENDIF



$SLL1_SubclassName   =   "EDIT"              ' Set to ClassName of subclassed class (ie. "EDIT")

' -------------------------------------------------------------------------------------------
'                          Custom Class ControlClass Constants and Types
' -------------------------------------------------------------------------------------------
%SLL1_ControlClassExtraData       = 5     ' # of Extra Data Items (Long) for All Custom Window Classes
                                ' Data Items will be indexed from 1 in GetControlData function
                                ' Data Items can be either a String or a Long
' -------------------------------------------------------------------------------------------
$SLL1_ControlClassName            = "EZGUI50_MASKEDIT32"
' -------------------------------------------------------------------------------------------
'                           XX-XXXX-XXXX-XXX    Bits with - never used
%SLL1_ControlClassOKStyles =   &B0101111011000111    ' Styles Hi Word WM_ styles acceptable
'                              XX-||||-||||-|||    WS_CHILD (01)
'                              ---X|||-||||-|||       WS_VISIBLE
'                              ----X||-||||-|||       WS_DISABLED
'                              -----X|-||||-|||       WS_CLIPSIBLINGS
'                              ------X-||||-|||       WS_CLIPCHILDREN
'                              --------X|||-|||    WS_BORDER
'                              ---------X||-|||    WS_DLGFRAME
'                              ----------X|-|||    WS_VSCROLL
'                              -----------X-|||    WS_HSCROLL
'                              -------------X||       WS_THICKFRAME
'                              --------------X|       WS_GROUP
'                              ---------------X       WS_TABSTOP
' -------------------------------------------------------------------------------------------


' -------------------------------------------------------------------------------------------
'                              Universal Global Variables
' -------------------------------------------------------------------------------------------
GLOBAL SLL1_Instance&

GLOBAL SLL1_OriginalProc&
GLOBAL SLL1_OriginalWndExtra&

%EZMEF_NOCHARPOS            =   -99

%EZME_SETMASK               =   %WM_USER+100    ' wParam = asciiz pointer
%EZME_SETTEXTMODE           =   %WM_USER+101    ' wParam = 0 or 1 (1= Ret=Tab mode)

' -------------------------------------------------------------------------------------------
'                           EZGUI Custom Control Library Declares
' -------------------------------------------------------------------------------------------

DECLARE FUNCTION EZME_GetControlLong(BYVAL hWnd AS LONG, BYVAL N&) AS LONG
DECLARE SUB EZME_SetControlLong(BYVAL hWnd AS LONG, BYVAL N&, BYVAL V&)
DECLARE SUB EZME_SetControlString(BYVAL hWnd AS LONG, BYVAL N&, BYVAL D$)
DECLARE FUNCTION EZME_GetControlString(BYVAL hWnd AS LONG, BYVAL N&) AS STRING
DECLARE SUB EZME_FreeControlString(BYVAL hWnd AS LONG, BYVAL N&)
DECLARE SUB EZME_SetMask(hCtrl AS LONG, BYVAL wParam AS LONG)

' -------------------------------------------------------------------------------------------
'                           Custom Control Control Class Declares
' -------------------------------------------------------------------------------------------
DECLARE SUB EZME_RegisterControlClass()
DECLARE SUB EZME_ControlClassPaint(BYVAL hWnd AS LONG, PS AS PAINTSTRUCT)


' -------------------------------------------------------------------------------------------
'                              DLL Entrance - LibMain
' -------------------------------------------------------------------------------------------
#IF %BuildSLL

#ELSE
     FUNCTION LIBMAIN(BYVAL hInstance   AS LONG, _
                      BYVAL fwdReason   AS LONG, _
                      BYVAL lpvReserved AS LONG) EXPORT AS LONG
          SELECT CASE AS LONG fwdReason
               CASE %DLL_PROCESS_ATTACH    ' =1 - Where DLL starts
                 SLL1_Instance&=hInstance
                 EZME_RegisterControlClass
               CASE %DLL_THREAD_ATTACH
               CASE %DLL_THREAD_DETACH
               CASE %DLL_PROCESS_DETACH    ' =0 - Where DLL exits
               CASE ELSE
          END SELECT
          LIBMAIN=1
     END FUNCTION
#ENDIF

' -------------------------------------------------------------------------------------------
'                          Custom Control ControlClass Functions / Subs
' -------------------------------------------------------------------------------------------

SUB EZME_RegisterControlClass()
LOCAL Windowclass    AS WndClassEx
LOCAL szClassName AS ASCIIZ * 80
szClassName=$SLL1_SubclassName+CHR$(0)
#IF %BuildSLL
     SLL1_Instance&=GetModuleHandle(BYVAL %NULL)
#ENDIF
IF GetClassInfoEx(SLL1_Instance&, szClassName, Windowclass) THEN
    SLL1_OriginalProc&        =    Windowclass.lpfnWndProc
    SLL1_OriginalWndExtra&    =    Windowclass.cbWndExtra

    szClassName            = $SLL1_ControlClassName+CHR$(0)
    Windowclass.cbSize        = SIZEOF(Windowclass)
    Windowclass.lpfnWndProc   = CODEPTR(EZME_ControlClassWndProc)
    Windowclass.cbWndExtra    = Windowclass.cbWndExtra+(%SLL1_ControlClassExtraData*4)
    Windowclass.hInstance     = GetModuleHandle(BYVAL %NULL)   ' instance or process
    Windowclass.lpszClassName = VARPTR( szClassName )
    Windowclass.style=Windowclass.style AND (NOT %CS_GLOBALCLASS) ' remove global class
ELSE
    EXIT SUB
END IF
RegisterClassEx Windowclass
END SUB

' -------------------------------------------------------------------------------------------

FUNCTION EZME_ControlClassWndProc(BYVAL hCtrl AS LONG, _
                 BYVAL Msg    AS LONG, _
                 BYVAL wParam AS LONG, _
                 BYVAL lParam AS LONG) EXPORT AS LONG

LOCAL hWnd AS LONG
LOCAL P&, C&, OKFlag&, ML&, P1&, P2&, VKMode&
LOCAL ControlMask$, ControlMode&, RV&
SELECT CASE AS LONG Msg
      CASE %WM_KEYUP, %WM_KEYDOWN        ' Process Enter key here
                IF EZME_GetControlLong( hCtrl,  1)>=1 THEN
                    DIM VKFlag&
                    VKFlag&=0
                    hWnd=GetParent(hCtrl)
                    SELECT CASE AS LONG wParam
                            CASE %VK_RIGHT, %VK_LEFT
                                IF EZME_GetControlLong(hCtrl,1)=3 OR EZME_GetControlLong(hCtrl,1)=5 THEN
                                    VKFlag&=1
                                END IF
                            CASE %VK_RETURN
                                IF EZME_GetControlLong(hCtrl, 1)<>4 THEN
                                    VKFlag&=1
                                    IF Msg=%WM_KEYUP THEN
                                        IF EZME_GetControlLong(hCtrl, 3)=1 THEN
                                           SendMessage hWnd, %WM_NEXTDLGCTL, 0, 0
                                        END IF
                                    END IF
                                END IF
                            CASE %VK_DOWN
                                IF EZME_GetControlLong(hCtrl, 1)<>4 THEN
                                    VKFlag&=1
                                    IF Msg=%WM_KEYDOWN THEN
                                        IF EZME_GetControlLong(hCtrl, 3)=1 THEN
                                           SendMessage hWnd, %WM_NEXTDLGCTL, 0, 0
                                        END IF
                                    END IF
                                ELSE
                                    IF EZME_GetControlLong(hCtrl, 3)=1 THEN
                                       VKMode&=0
                                       GOSUB CheckUpDown
                                    END IF
                                END IF
                            CASE %VK_UP
                                IF EZME_GetControlLong( hCtrl,  1)<>4 THEN
                                    VKFlag&=1
                                    IF Msg=%WM_KEYDOWN THEN
                                        IF EZME_GetControlLong(hCtrl, 3)=1 THEN
                                           SendMessage hWnd, %WM_NEXTDLGCTL, 1, 0
                                        END IF
                                    END IF
                                ELSE
                                    IF EZME_GetControlLong(hCtrl, 3)=1 THEN
                                       VKMode&=1
                                       GOSUB CheckUpDown
                                    END IF
                                END IF
                            CASE %VK_DELETE, %VK_INSERT
                                IF EZME_GetControlLong( hCtrl,  1)<>2 THEN VKFlag&=1
                                IF EZME_GetControlLong( hCtrl,  1)=4 THEN VKFlag&=0
                            CASE ELSE
                                VKFlag&=0
                    END SELECT
                    IF VKFlag& THEN
                        FUNCTION=0
                        EXIT FUNCTION
                    END IF
                 END IF
      CASE %WM_CHAR
                ControlMask$=EZME_GetControlString(hCtrl, 2)
                ControlMode&=EZME_GetControlLong(hCtrl,1)
                IF ControlMode&=1 THEN
                    DIM IPFlag&
                    OKFlag&=0
                    IPFlag&=1
                    P&=SendMessage(hCtrl, %EM_GETSEL, 0, 0 )
                    P2&=HIWRD(P&)
                    P1&=LOWRD(P&)
                    C&=wParam
                    IF C&=8 THEN        ' backspace
                        IF P1&>0 THEN
                            P1&=P1&-1
                            C&=32
                            IPFlag&=0   ' don't increment pos
                        END IF
                    END IF
                    P&=P1&+1    '   return character position
                    ML&=LEN(ControlMask$)
                    P1&=P&
                    IF P1&<1 THEN P1&=1
                    IF P&<=ML& THEN
                        OKFlag&=0
                        SELECT CASE AS CONST$ MID$(ControlMask$, P&,1)
                            CASE "X"
                                IF C&>=32 AND C&<=126 THEN OKFlag&=1
                            CASE "9"
                                IF C&>=48 AND C&<=57 THEN OKFlag&=1
                                IF C&=32 AND IPFlag&=0 THEN ' backspace
                                    C&=48   ' make a zero
                                    OKFlag&=1
                                END IF
                            CASE "A"
                                IF C&>=65 AND C&<=90 THEN OKFlag&=1
                                IF C&>=97 AND C&<=122 THEN OKFlag&=1
                                IF C&=32 THEN OKFlag&=1
                            CASE "U"
                                IF C&>=65 AND C&<=90 THEN OKFlag&=1
                                IF C&>=97 AND C&<=122 THEN
                                    C&=C&-32
                                    OKFlag&=1
                                END IF
                                IF C&=32 THEN OKFlag&=1
                            CASE "#"
                                IF C&>=48 AND C&<=57 THEN OKFlag&=1
                                IF C&=32 OR C&=45 OR C&=43 OR C&=46 THEN OKFlag&=1
                            CASE "N"
                                IF C&>=65 AND C&<=90 THEN OKFlag&=1
                                IF C&>=97 AND C&<=122 THEN OKFlag&=1
                                IF C&>=48 AND C&<=57 THEN OKFlag&=1
                                IF C&=32 THEN OKFlag&=1
                            CASE "L"
                                SELECT CASE AS CONST$ CHR$(C&)
                                    CASE "Y","N", "T", "F"
                                         OKFlag&=1
                                    CASE "y", "n", "t", "f"
                                         OKFlag&=1
                                         C&=C&-32
                                    CASE ELSE
                                END SELECT
                            CASE "T"
                                SELECT CASE AS CONST$ CHR$(C&)
                                    CASE "T", "F"
                                         OKFlag&=1
                                    CASE "t", "f"
                                         OKFlag&=1
                                         C&=C&-32
                                    CASE ELSE
                                END SELECT
                            CASE "Y"
                                SELECT CASE AS CONST$ CHR$(C&)
                                    CASE "Y","N"
                                         OKFlag&=1
                                    CASE "y", "n"
                                         OKFlag&=1
                                         C&=C&-32
                                    CASE ELSE
                                END SELECT
                            CASE ELSE
                                IF C&=32 AND IPFlag&=0 THEN
                                    P&=P&-1
                                    SendMessage hCtrl, %EM_SETSEL, P&, P&
                                END IF
                        END SELECT
                    END IF
                    IF ML&=1 THEN IPFlag&=0
                    IF OKFlag& THEN
                        DIM TL&, MText$, ATL&, RVText AS ASCIIZ*255
                        TL&=SendMessage(hCtrl, %WM_GETTEXTLENGTH, 0, 0)
                        MText$=SPACE$(TL&+1)
                        ATL&=GetWindowText(hCtrl, BYVAL STRPTR(MText$), TL&+1)
                        MText$=LEFT$(MText$,ATL&)
                        MID$(MText$, P&,1)=CHR$(C&)
                        IF IPFlag& THEN
                            P1&=P&+1
                            P2&=LEN(ControlMask$)
                            DIM A$
                            FOR P&=P1& TO P2&
                                A$=MID$(ControlMask$, P&,1)
                                IF INSTR("X9ANL#UTY", A$) THEN
                                    EXIT FOR
                                END IF
                            NEXT P&
                        END IF
                        P&=P&-1 ' set back to zero index
                        RVText=MText$+CHR$(0)
                        SetWindowText hCtrl, RVText
                        SendMessage hCtrl, %EM_SETSEL, P&, P&
                    END IF
                    FUNCTION=0
                    EXIT FUNCTION
                ELSEIF ControlMode&=3 OR ControlMode&=5 THEN
                   DIM BKFlag&, NN$, PL$, J&, DCFlag&
                   IF INSTR(ControlMask$,".") THEN DCFlag&=1 ELSE DCFlag&=0
                   C&=wParam
                   OKFlag&=1
                   NN$=""
                   PL$=""
                   BKFlag&=0
                   SELECT CASE AS LONG C&
                        CASE 48 TO 57
                            NN$=CHR$(C&)
                        CASE 43
                            PL$=" "
                        CASE 45
                            PL$="-"
                        CASE 46
                           OKFlag&=0
                           IF ControlMode&=3 THEN
                               IF DCFlag&=0 THEN
                                   NN$="."
                                   OKFlag&=1
                               END IF
                           END IF
                        CASE 8
                            BKFlag&=1
                        CASE ELSE
                            OKFlag&=0
                   END SELECT
                   IF OKFlag& THEN
                        DIM NL&, NText$, ANL&, RNText AS ASCIIZ*255, DCP&, Z$
                        NL&=SendMessage(hCtrl, %WM_GETTEXTLENGTH, 0, 0)
                        NText$=SPACE$(NL&+1)
                        ANL&=GetWindowText(hCtrl, BYVAL STRPTR(NText$), NL&+1)
                        NText$=LEFT$(NText$, ANL&)
                        IF EZME_GetControlLong(hCtrl,5)=1 THEN
                            NText$=MID$(NText$,3)   ' remove "$ "
                        END IF
                        IF EZME_GetControlLong(hCtrl,5)=2 THEN
                            NText$=LEFT$(NText$,LEN(NText$)-2)   ' remove " %"
                        END IF
                        IF LEFT$(ControlMask$,1)="+" THEN
                            IF PL$="" THEN PL$=MID$(NText$,1,1)
                            NText$=MID$(NText$,2)
                        ELSE
                            PL$=""
                        END IF
                        IF DCFlag& THEN
                            DCP&=INSTR(NText$, ".")
                        ELSE
                            DCP&=0
                            IF NN$="." THEN
                                IF INSTR(NText$,".") THEN NN$=""
                            END IF
                        END IF
                        IF DCP&>0 THEN NText$=LEFT$(NText$,DCP&-1)+MID$(NText$,DCP&+1)
                        IF NN$<>"" THEN
                            IF MID$(NText$,1,1)=" " THEN
                                NText$=MID$(NText$,2)+NN$
                            END IF
                        END IF
                        IF BKFlag& THEN
                            NText$=" "+MID$(NText$,1, LEN(NText$)-1)
                        END IF
                        IF DCP&>0 THEN
                            NText$=LEFT$(NText$, DCP&-1)+"."+MID$(NText$,DCP&)
                        END IF
                        IF DCP&=0 THEN DCP&=LEN(NText$)
                        FOR J&=1 TO LEN(NText$)
                            Z$=MID$(NText$,J&,1)
                            IF J&<DCP& THEN
                                IF Z$="0" OR Z$=" " THEN
                                    MID$(NText$,J&,1)=" "
                                ELSE
                                    J&=DCP&
                                END IF
                            ELSE
                                IF Z$=" " THEN MID$(NText$, J&,1)="0"
                            END IF
                        NEXT J&
                        NText$=PL$+NText$
                        P&=LEN(NText$)
                        IF EZME_GetControlLong(hCtrl,5)=1 THEN
                            NText$="$ "+NText$
                            P&=P&+2
                        END IF
                        IF EZME_GetControlLong(hCtrl,5)=2 THEN
                            NText$=NText$+" %"
                        END IF
                        RNText=NText$+CHR$(0)
                        SetWindowText hCtrl, RNText
                        SendMessage hCtrl, %EM_SETSEL, P&, P&
                   END IF
                   FUNCTION=0
                   EXIT FUNCTION
                ELSEIF ControlMode&=4 THEN
                   IF wParam=13 THEN
                       IF EZME_GetControlLong(hCtrl, 3)=1 THEN
                           P&=SendMessage(hCtrl, %EM_GETSEL, 0, 0 )
                           P2&=HIWRD(P&)
                           P1&=LOWRD(P&)
                           IF P1&<>P2& THEN
                              hWnd=GetParent(hCtrl)
                              VKMode&=0
                              SendMessage hWnd, %WM_NEXTDLGCTL, VKMode&, 0
                              FUNCTION=0
                              EXIT FUNCTION
                           END IF
                       END IF
                   END IF
                END IF
      CASE %WM_CREATE
          IF (GetWindowLong(hCtrl, %GWL_STYLE) AND %ES_MULTILINE)=%ES_MULTILINE THEN
              EZME_SetControlLong hCtrl, 1, 4    ' Mode   4= No Mask and MultiLine by Default
          ELSE
              EZME_SetControlLong hCtrl, 1, 2    ' Mode   2= No Mask by Default
          END IF
          EZME_SetControlLong hCtrl, 2, 0    ' Mask string (no Global handle assigned yet)
          EZME_SetControlLong hCtrl, 3, 0    ' Text Mode (0-normal, 1-Return acts like Tab key)
          EZME_SetControlLong hCtrl, 4, %EZMEF_NOCHARPOS  ' cursor position - default don't remember
          EZME_SetControlLong hCtrl, 5, 0    ' extra info for calculator mode
      CASE %WM_DESTROY
          EZME_FreeControlString hCtrl, 2
      CASE %EZME_SETMASK
          IF (GetWindowLong(hCtrl, %GWL_STYLE) AND %ES_MULTILINE)<>%ES_MULTILINE THEN
              EZME_SetMask hCtrl, wParam
              FUNCTION=1
              EXIT FUNCTION
          ELSE
              FUNCTION=0
              EXIT FUNCTION
          END IF
      CASE %EZME_SETTEXTMODE
          IF wParam=0 THEN
             EZME_SetControlLong hCtrl, 3, 0
          ELSE
             EZME_SetControlLong hCtrl, 3, 1
          END IF
          FUNCTION=1
          EXIT FUNCTION
      CASE %WM_KILLFOCUS
          IF EZME_GetControlLong(hCtrl,4)<>%EZMEF_NOCHARPOS THEN
              P&=SendMessage(hCtrl, %EM_GETSEL, 0, 0 )
              P2&=HIWRD(P&)
              P1&=LOWRD(P&)
              EZME_SetControlLong hCtrl, 4, P1&
          END IF
      CASE %WM_SETFOCUS
          P&=SendMessage(hCtrl, %EM_GETSEL, 0, 0 )
          P2&=HIWRD(P&)
          P1&=LOWRD(P&)
          IF P2&>P1& THEN   ' block selected so make it only 1 char
              ControlMode&=EZME_GetControlLong(hCtrl,1)
              IF ControlMode&=1 OR ControlMode&=2 THEN
                  IF EZME_GetControlLong(hCtrl,4)=%EZMEF_NOCHARPOS THEN
                      SendMessage hCtrl, %EM_SETSEL, 0,0
                  ELSE
                      P&=EZME_GetControlLong(hCtrl,4)
                      IF P&<0 THEN P&=0
                      SendMessage hCtrl, %EM_SETSEL, P&, P&
                  END IF
              END IF
              IF ControlMode&=3 OR ControlMode&=5 THEN
                  ControlMask$=EZME_GetControlString(hCtrl, 2)
                  P&=LEN(ControlMask$)
'                  open "maskedit.txt" for append as #1
'                  print #1, ControlMask$+"   "+str$(P&)
'                  close #1
                  IF EZME_GetControlLong(hCtrl, 5)=1 THEN
                      P&=P&+2
                  END IF
                  SendMessage hCtrl, %EM_SETSEL, P&, P&
              END IF
          END IF
      CASE %WM_GETDLGCODE
           RV& = CallWindowProc(BYVAL SLL1_OriginalProc&,hCtrl,Msg,wParam,lParam)
           RV&=RV& AND (NOT(%DLGC_HASSETSEL))
           FUNCTION=RV&
           EXIT FUNCTION
      CASE ELSE
END SELECT

FUNCTION = CallWindowProc(BYVAL SLL1_OriginalProc&,hCtrl,Msg,wParam,lParam)
EXIT FUNCTION

CheckUpDown:
P&=SendMessage(hCtrl, %EM_GETSEL, 0, 0 )
P2&=HIWRD(P&)
P1&=LOWRD(P&)
IF P1&<>P2& THEN
    IF Msg=%WM_KEYUP THEN
        hWnd=GetParent(hCtrl)
        SendMessage hWnd, %WM_NEXTDLGCTL, VKMode&, 0
    END IF
    VKFlag&=1
END IF
RETURN

END FUNCTION

' -------------------------------------------------------------------------------------------





' -------------------------------------------------------------------------------------------
'                             EZGUI Custom Control Library
' -------------------------------------------------------------------------------------------

FUNCTION EZME_GetControlLong(BYVAL hWnd AS LONG, BYVAL N&) AS LONG
LOCAL I&, RV&
RV&=0
IF N&>=1 AND N&<=%SLL1_ControlClassExtraData THEN
    I&=(N&-1)*4 + SLL1_OriginalWndExtra&
    IF IsWindow(hWnd) THEN
        RV&=GetWindowLong(hWnd, I&)
    END IF
END IF
FUNCTION=RV&
END FUNCTION

' -------------------------------------------------------------------------------------------

SUB EZME_SetControlLong(BYVAL hWnd AS LONG, BYVAL N&, BYVAL V&)
LOCAL I&
IF N&>=1 AND N&<=%SLL1_ControlClassExtraData THEN
    I&=(N&-1)*4 + SLL1_OriginalWndExtra&
    IF IsWindow(hWnd) THEN
        SetWindowLong hWnd, I&, V&
    END IF
END IF
END SUB

' -------------------------------------------------------------------------------------------

SUB EZME_SetControlString(BYVAL hWnd AS LONG, BYVAL N&, BYVAL D$)
LOCAL hData AS LONG, lpAddress AS LONG
IF LEN(D$)<>0 THEN
    IF N&>=1 AND N&<=%SLL1_ControlClassExtraData THEN
        IF IsWindow(hWnd) THEN
            hData=EZME_GetControlLong(hWnd, N&)
            IF hData<>0 THEN
                GlobalFree hData
            END IF
            hData=GlobalAlloc(%GMEM_MOVEABLE, LEN(D$))
            lpAddress=GlobalLock(hData)
            POKE$ lpAddress, D$
            GlobalUnlock hData
            EZME_SetControlLong hWnd, N&, hData
        END IF
    END IF
END IF
END SUB

' -------------------------------------------------------------------------------------------

FUNCTION EZME_GetControlString(BYVAL hWnd AS LONG, BYVAL N&) AS STRING
LOCAL hData AS LONG, lpAddress AS LONG
LOCAL D$, L&, P&
D$=""
' Warning !!!!!!
' Global Memory stores data in blocks so extra bytes may
' be added by Memory manager. Memory will be padded,
' but only first byte after string passed will be
' guaranteed to be a zero byte. Test for the first
' zero byte and if found remove padding
IF N&>=1 AND N&<=%SLL1_ControlClassExtraData THEN
    IF IsWindow(hWnd) THEN
        hData=EZME_GetControlLong(hWnd, N&)
        IF hData<>0 THEN
            lpAddress=GlobalLock(hData)
            L&=GlobalSize(hData)
            D$=PEEK$(lpAddress, L&)
            GlobalUnlock hData
        END IF
    END IF
END IF
P&=INSTR(D$,CHR$(0))
IF P&>0 THEN
    D$=LEFT$(D$,P&-1)
END IF
FUNCTION=D$
END FUNCTION

' -------------------------------------------------------------------------------------------

SUB EZME_FreeControlString(BYVAL hWnd AS LONG, BYVAL N&)
LOCAL hData AS LONG, lpAddress AS LONG
IF N&>=1 AND N&<=%SLL1_ControlClassExtraData THEN
    IF IsWindow(hWnd) THEN
        hData=EZME_GetControlLong(hWnd, N&)
        IF hData<>0 THEN
            GlobalFree hData
            EZME_SetControlLong hWnd, N&, 0
        END IF
    END IF
END IF
END SUB


' -------------------------------------------------------------------------------------------

SUB EZME_SetMask(hCtrl AS LONG, BYVAL wParam AS LONG)
LOCAL AppControlMode AS LONG, P&, Tmp$, EMask$, EText AS ASCIIZ PTR
LOCAL CalcInfo&
IF wParam<=0 THEN
    EXIT SUB
END IF
EText=wParam
EMask$=@Etext
AppControlMode=1
CalcInfo&=0
IF LEFT$(EMask$,1)="?" THEN
    EZME_SetControlLong hCtrl, 4, -1
    EMask$=MID$(EMask$,2)
ELSE
    EZME_SetControlLong hCtrl, 4, %EZMEF_NOCHARPOS
END IF
'IF EMask$=STRING$(LEN(EMask$), "X") THEN EMask$=""
IF EMask$="" THEN
    AppControlMode=2
ELSE
    IF LEFT$(EMask$,2)="$ " THEN
         CalcInfo&=1
         EMask$=MID$(EMask$,3)
    ELSEIF RIGHT$(EMask$,2)=" %" THEN
         CalcInfo&=2
         EMask$=LEFT$(EMask$,LEN(EMask$)-2)
    END IF
    P&=INSTR(EMask$,".")
    Tmp$=EMask$
    IF P&<>0 THEN MID$(Tmp$,P&,1)="#"
    IF LEFT$(Tmp$,1)="+" THEN MID$(Tmp$,1,1)="#"
    IF Tmp$=STRING$(LEN(Tmp$), "#") THEN
        AppControlMode=3
    END IF
    P&=INSTR(EMask$,".")
    Tmp$=EMask$
    IF P&<>0 THEN MID$(Tmp$,P&,1)="%"
    IF LEFT$(Tmp$,1)="+" THEN MID$(Tmp$,1,1)="%"
    IF Tmp$=STRING$(LEN(Tmp$), "%") THEN
        AppControlMode=5
    END IF
    IF AppControlMode<>3 AND AppControlMode<>5 THEN
        IF CalcInfo&=1 THEN
            EMask$="$ "+EMask$
        END IF
        IF CalcInfo&=2 THEN
            EMask$=EMask$+" %"
        END IF
        CalcInfo&=0
    END IF
END IF
EZME_SetControlLong hCtrl, 1, AppControlMode
EZME_SetControlLong hCtrl, 5, CalcInfo&
EZME_FreeControlString hCtrl, 2
IF EMask$<>"" THEN
    EMask$=EMask$+CHR$(0)   ' terminating zero necessary because of unexpected padding
    EZME_SetControlString hCtrl, 2, EMask$
END IF
END SUB
