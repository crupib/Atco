SUB EZC_Label3DM_Init(BYVAL N&)
     EZ_DefCustomControl N&, "LABEL3DM", 3, "O", CODEPTR(EZC_Label3DM_Events)
END SUB

' define Macro Text as follows:
' each item defines a percentage and base color scheme , up to 10 items, separated by the | character
SUB EZC_Label3DM_Draw(FormName$, CID&, CVal&)
     LOCAL hMyDC&, X3&, Y3&, IsSel&, IsGry&, IsDis&, IsChk&, IsFoc&, IsDef&
     LOCAL FG&, BG&, FontNum&, N&, X1&, Y1&, X2&,Y2&, T$, I$, P&, PC!, TPC!, C1&, C2&, DrawFlag&
     EZ_GetCColors FormName$, CID&, FG&, BG&
     FontNum&=EZ_GetCFont(FormName$, CID&)
     T$=REMOVE$(EZ_GetText(FormName$,CID&), CHR$(10))
     REPLACE "," WITH "|" IN T$
     REPLACE CHR$(13) WITH "|" IN T$
     EZ_SaveState
     IF EZ_StartOwnerDraw(CVal&, hMyDC&, X3&, Y3&, IsSel&, IsGry&, IsDis&, IsChk&, IsFoc&, IsDef&) THEN
          X1&=0
          Y1&=0
          EZ_Color FG&,BG&
          EZ_DCDraw  hMyDC&, %EZ_FILL, X1&, Y1&, X3&, Y3&, 0, 1
          X2&=0
          Y2&=0
          TPC!=100
          FOR N&=1 TO PARSECOUNT(T$, "|")
               I$=TRIM$(PARSE$(T$,"|", N&))
               IF I$<>"" THEN
                    I$=REMOVE$(UCASE$(I$), " ")
                    P&=INSTR(I$,"%")
                    IF P&>0 THEN
                         PC!=VAL(LEFT$(I$,P&-1))
                         IF PC!>0 AND PC!<=TPC! THEN
                              TPC!=TPC!-PC!
                              X2&=CEIL((PC!/100)*X3&)
                              IF X2&>0 THEN
                                   X2&=X1&+X2&-1
                                   C1&=FG&:C2&=BG&
                                   DrawFlag&=1
                                   SELECT CASE MID$(I$,P&+1)
                                        CASE "BLACK"
                                             C1&=0:C2&=C1&+16
                                        CASE "BLUE"
                                             C1&=9:C2&=C1&+8
                                        CASE "GREEN"
                                             C1&=2:C2&=C1&+8
                                        CASE "CYAN"
                                             C1&=3:C2&=C1&+8
                                        CASE "RED"
                                             C1&=4:C2&=C1&+16
                                        CASE "PURPLE"
                                             C1&=5:C2&=C1&+8
                                        CASE "GOLD"
                                             C1&=6:C2&=C1&+8
                                        CASE "GRAY"
                                             C1&=8:C2&=31
                                        CASE "LIGHTBLUE"
                                             C1&=17:C2&=C1&+8
                                        CASE "LIGHTRED"
                                             C1&=12:C2&=C1&+8
                                        CASE "DARKBLUE"
                                             C1&=1:C2&=C1&+16
                                        CASE "DEFAULT"
                                             C1&=BG&:C2&=FG&
                                        CASE "SKIP"
                                             DrawFlag&=0
                                        CASE ELSE
                                             DrawFlag&=0
                                   END SELECT
                                   EZ_Color C1&, C2&
                                   IF X2&>X3& THEN X2&=X3&
                                   IF DrawFlag& THEN
                                        EZ_DCDrawGradient hMyDC&,X1&,Y1&,X2&,Y3&,6
                                   END IF
                                   X1&=X2&+1
                              END IF
                         END IF
                    END IF
               END IF
          NEXT N&
          EZ_EndOwnerDraw
     END IF
     EZ_RestoreState
END SUB

'SUB FORM1_TAB3_OwnerDraw(BYVAL CID&, BYVAL CVal&, BYVAL FGC&, BYVAL BGC&, BYVAL FntNum&, BYVAL TabText$, BYVAL DFlag&)
'     LOCAL hMyDC&, X2&, Y2&, IsSel&, IsGry&, IsDis&, IsChk&, IsFoc&, IsDef&
'     LOCAL T$,  X1&, Y1&, Item1&, IsEdit&
'     EZ_SaveState
'     IF EZ_StartOwnerDraw(CVal&, hMyDC&, X2&, Y2&, IsSel&, IsGry&, IsDis&, IsChk&, IsFoc&, IsDef&) THEN
'          EZ_GetODItem CVal&, X1&, Y1&, Item1&, IsEdit&
'          IF Item1&>=0 THEN
'               EZ_Color FGC&, BGC&
'               EZ_DCDraw  hMyDC&, %EZ_FILL, X1&, Y1&, X2&, Y2&, 1, 1
'               IF IsEdit&<>0 AND IsFoc&<>0 THEN
'                    EZ_Color 0,0
'                    EZ_DCDraw  hMyDC&, %EZ_RECT, X1&+1, Y1&+1, X2&-1, Y2&-1, 1,0
'               END IF
'               EZ_UseFont FntNum&
'               T$=PARSE$(TabText$, "|", Item1&+1)
'               EZ_Color FGC&, BGC&
'               IF DFlag&=1 THEN
'                    EZ_DCPrintVText hMyDC&, T$, X1&, Y1&, X2&, Y2&, 0
'               ELSEIF DFlag&=2 THEN
'                    EZ_DCPrintVText hMyDC&, T$, X1&, Y1&, X2&, Y2&, 1
'               ELSE
'                    EZ_SetPrintFormat 2, X2&, Y2&, %EZ_Center OR %EZ_VCenter, 0
'                    EZ_DCPrint hMyDC&, X1&,Y1&, T$
'                    EZ_SetPrintFormat 0,0,0,0,0
'               END IF
'          END IF
'          EZ_EndOwnerDraw
'     END IF
'     EZ_RestoreState
'END SUB



SUB EZC_Label3DM_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
     LOCAL FG&, BG&, FontNum&, TXC&
     SELECT CASE AS LONG CMsg&
          CASE %EZ_OwnerDraw
               EZC_Label3DM_Draw FormName$, CID&, CVal&
          CASE ELSE
     END SELECT
END SUB
