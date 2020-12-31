SUB EZC_CheckList_Init(BYVAL N&)
     EZ_DefCustomControl N&, "CHECKLIST", 2, "O$M", CODEPTR(EZC_CheckList_Events)
END SUB

SUB EZC_CheckList_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE AS LONG CMsg&
          CASE %EZ_OwnerSize
               EZ_SizeListBox CVal&, EZ_ODIFont
          CASE %EZ_OwnerDraw
               EZ_StartTheme FormName$, CID&
               EZ_DrawListBox FormName$, CID&, CVal&, EZ_ODIFont,0, "X-"
               EZ_EndTheme
     END SELECT
END SUB
