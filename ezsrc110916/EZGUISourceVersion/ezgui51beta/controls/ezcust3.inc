SUB EZC_ColorList_Init(BYVAL N&)
     EZ_DefCustomControl N&, "COLORLIST", 2, "O$", CODEPTR(EZC_ColorList_Events)
END SUB

SUB EZC_ColorList_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE AS LONG CMsg&
          CASE %EZ_OwnerSize
               EZ_SizeListBox CVal&, EZ_ODIFont
          CASE %EZ_OwnerDraw
               EZ_DrawListBox FormName$, CID&, CVal&, EZ_ODIFont,0, "C"
     END SELECT
END SUB
