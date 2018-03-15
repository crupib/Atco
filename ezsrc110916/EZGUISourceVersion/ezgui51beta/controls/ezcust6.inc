SUB EZC_ListBar_Init(BYVAL N&)
     EZ_DefCustomControl N&, "LISTBAR", 5, "-!", CODEPTR(EZC_ListBar_Events)
END SUB

SUB EZC_ListBar_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE AS LONG CMsg&
          CASE %EZ_NoCustomDraw
               Cancel&=1
          CASE %EZ_CustomDraw
               LOCAL LVRow&, LVCol&, CFlag&, FontNum&, FG&, BG&
               LVRow&=EZ_GetCDrawItem(CVal&, LVCol&)
               ' get a flag stored in long buffer
'               CFlag&=EZ_GetLVLong("Form1", %FORM1_LISTVIEW1, LVRow&)
               FontNum&=EZ_GetCFont(FormName$, CID&)
               EZ_GetCColors FormName$, CID&, FG&, BG&
               IF ((LVRow&+1) MOD 2) = 0 THEN
                    EZ_SetCDrawItem CVal&, FontNum&, FG&, 15
               ELSE
                    EZ_SetCDrawItem CVal&, FontNum&, FG&, BG&
               END IF
     END SELECT
END SUB
