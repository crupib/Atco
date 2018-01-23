SUB EZC_ListBarLong_Init(BYVAL N&)
     EZ_DefCustomControl N&, "LISTBARLONG", 5, "-!", CODEPTR(EZC_ListBarLong_Events)
END SUB

SUB EZC_ListBarLong_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE AS LONG CMsg&
          CASE %EZ_NoCustomDraw
               Cancel&=1
          CASE %EZ_CustomDraw
               LOCAL LVRow&, LVCol&, CFlag&, FontNum&, FG&, BG&, UserColor&
               LVRow&=EZ_GetCDrawItem(CVal&, LVCol&)
               ' get a flag stored in Listview Long parameter
               UserColor&=EZ_GetLVLong(FormName$, CID&, LVRow&)
               FontNum&=EZ_GetCFont(FormName$, CID&)
               EZ_GetCColors FormName$, CID&, FG&, BG&
               IF UserColor&>0 THEN
                    FG&=HIWRD(UserColor&)
                    BG&=LOWRD(UserColor&)
               END IF
               EZ_SetCDrawItem CVal&, FontNum&, FG&, BG&
          CASE ELSE
     END SELECT
END SUB
