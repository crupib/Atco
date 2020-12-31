' -------------------------------------------------------------------------------------------
'                        Copyright Christopher R. Boss, 2011
'                               Alls Rights Reserved
'               The code may be used ROYALTY FREE by registered EZGUI 5.0 users !
' -------------------------------------------------------------------------------------------

SUB DrawMyButtonX(FormName$, BYVAL CID&, BYVAL CVal&, BYVAL BGColor&, BYVAL FGColor&, BYVAL FontN&, BYVAL RType&)
LOCAL hMyDC&, X2&, Y2&, IsSel&, IsGry&, IsDis&, IsChk&, IsFoc&, IsDef&
LOCAL T$, LW&, C&, CL&, YOffset&, FC&, MObj&, LFlag&, LC&, HotFlag&,TC&

IF EZ_StartOwnerDraw(CVal&, hMyDC&, X2&, Y2&, IsSel&, IsGry&, IsDis&, IsChk&, IsFoc&, IsDef&) THEN
    HotFlag&=EZ_IsHot(FormName$, CID&)
    YOffset&=Y2&/4
    IF RType&=-2 THEN EZ_DefCorner -1
    EZ_SaveState
    EZ_SaveColors 96, 100
    C&=EZ_ColorVal(BGColor&,0)
    IF HotFlag& THEN
        C&=EZ_AverageColor(C&, RGB(255,255,255))
    ELSEIF IsFoc& THEN
        C&=EZ_AverageColor(C&, RGB(230,230,230))
    ELSEIF IsDis& THEN
        TC&=EZ_AverageColor(C&, RGB(230,230,230))
        C&=EZ_AverageColor(C&, RGB(100,100,100))
        TC&=EZ_AverageColor(TC&, C&)
        EZ_DefColorL 100, TC&
        FGColor&=100
    ELSE
        C&=EZ_AverageColor(C&, RGB(200,200,200))
    END IF
    EZ_DefColorL 96, EZ_AverageColor(C&, RGB(32,32,32))
    EZ_DefColorL 97, C&
    EZ_DefColorL 98, RGB(255,255,255)
    EZ_DefColorL 99, EZ_AverageColor(C&, RGB(255,255,255))
    IF IsSel& THEN
        EZ_Color 0,97
        EZ_DCDraw hMyDC&, %EZ_FILL, 0, 0, X2&,  Y2&, 0, 1
        EZ_Color 97,-1
    ELSE
        EZ_Color 98,97
        EZ_DCDrawGradient hMyDC&, 0, 1,  X2&,  2*YOffset&, 2
        EZ_Color 0,97
        EZ_DCDraw hMyDC&, %EZ_FILL, 0, 2*YOffset&+1, X2&,  Y2&-YOffset&-1, 0, 1
        EZ_Color 97,96
        EZ_DCDrawGradient hMyDC&, 0, Y2&-YOffset&,  X2&,  Y2&, 2
        EZ_Color 97,-1
    END IF
    SELECT CASE RType&
        CASE 1
            EZ_DCDraw hMyDC&, %EZ_ELLIPSE, 0, 0, X2&,  Y2&, 1, 0
        CASE -2,2
            EZ_DCDraw hMyDC&, %EZ_RRECT, 0, 0, X2&,  Y2&, 1, 0
        CASE ELSE
            EZ_DCDraw hMyDC&, %EZ_RECT, 0, 0, X2&,  Y2&, 1, 0
    END SELECT
    IF IsFoc&<>0 OR HotFlag&<>0 THEN
        EZ_Color 99,-1
        SELECT CASE RType&
            CASE 1
                EZ_DCDraw hMyDC&, %EZ_ELLIPSE, 2, 2, X2&-2,  Y2&-2, 1, 0
            CASE -2,2
                EZ_DCDraw hMyDC&, %EZ_RRECT, 2, 2, X2&-2,  Y2&-2, 1, 0
            CASE ELSE
                EZ_DCDraw hMyDC&, %EZ_RECT, 2, 2, X2&-2,  Y2&-2, 1, 0
        END SELECT
    END IF
    EZ_Color FGColor&,-1
    EZ_UseFont FontN&
    T$=EZ_GetText(FormName$, CID&)
    MObj&=EZ_GetDrawMacro(T$)
    IF MObj&<>0 THEN
        EZ_DCDrawMacro hMyDC&, MObj&, 0, 0, X2&, Y2&, FGColor&, 97
    ELSE
        LFlag&=EZ_CheckLight(T$, LC&)
        EZ_SetPrintFormat 2, X2&, Y2&, %EZ_Center OR %EZ_VCenter, 0
        EZ_DCPrint hMyDC&, 0,0, T$
        EZ_SetPrintFormat 0,0,0,0,0
        IF LFlag& THEN
            EZ_DCDrawLight hMyDC&, 0, 0, X2&, Y2&, LC&
        END IF
    END IF
    EZ_RestoreColors
    EZ_RestoreState
    IF RType&=-2 THEN EZ_DefCorner -2   ' restore
    EZ_EndOwnerDraw
END IF
END SUB

SUB DrawMyButton(BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL BGColor&, BYVAL FGColor&, BYVAL FontN&)
    DrawMyButtonX FormName$, CID&, CVal&, BGColor&, FGColor&, FontN&, 0
END SUB

SUB DrawMyButtonE(BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL BGColor&, BYVAL FGColor&, BYVAL FontN&)
    DrawMyButtonX FormName$, CID&, CVal&, BGColor&, FGColor&, FontN&, 1
END SUB

SUB DrawMyButtonRR(BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL BGColor&, BYVAL FGColor&, BYVAL FontN&)
    DrawMyButtonX FormName$, CID&, CVal&, BGColor&, FGColor&, FontN&, -2
END SUB
