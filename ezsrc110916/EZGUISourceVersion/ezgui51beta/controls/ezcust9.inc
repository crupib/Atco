SUB EZC_GradTab_Init(BYVAL N&)
     EZ_DefCustomControl N&, "GRADTAB", 4, "O", CODEPTR(EZC_GradTab_Events)
END SUB

SUB EZC_GradTab_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
     LOCAL FG&, BG&, FontNum&, TXC&, Color1&,Color2&, CV&
     SELECT CASE AS LONG CMsg&
          CASE %EZ_EraseBG
               EZ_GetCColors FormName$, CID&, FG&, BG&
               IF BG&<-1 THEN BG&=-1    ' no patterns
               EZ_GetFColors FormName$, Color1&, Color2&
               EZ_DefTopHalfBGDraw FormName$, CID&, Color2&,Color2&, ""
               EZ_DrawBG CVal&, Cancel&, BG&, FG&, "G^"
          CASE %EZ_OwnerDraw
               EZ_GetCColors FormName$, CID&, FG&, BG&
               IF BG&<-1 THEN BG&=-1    ' no patterns
               TXC&=0
               SELECT CASE FG&
                    CASE 0 TO 6,9
                         TXC&=15
                    CASE -1, 7,8,10 TO 31
                    CASE ELSE
                         CV&=EZ_ColorVal(FG&,0)
                         IF EZ_TestRGBColor(CV&, RGB(0,128,0), 2) THEN TXC&=15
                         IF EZ_TestRGBColor(CV&, RGB(230,0,0), 2) THEN TXC&=15
               END SELECT
               FontNum&=EZ_GetCFont(FormName$, CID&)
               EZ_DrawTab CVal&, BG&, FG&, TXC&, EZ_ODIFont, EZ_GetText(FormName$, CID&), 0, "G"
     END SELECT
END SUB
