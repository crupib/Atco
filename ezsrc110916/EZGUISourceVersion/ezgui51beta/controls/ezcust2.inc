SUB EZC_FontCombo_Init(BYVAL N&)
     EZ_DefCustomControl N&, "FONTCOMBO", 1, "O$J", CODEPTR(EZC_FontCombo_Events)
END SUB

SUB EZC_FontCombo_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE AS LONG CMsg&
          CASE %EZ_OwnerSize
               EZ_SizeComboBox CVal&, EZ_ODIFont
          CASE %EZ_OwnerDraw
               EZ_DrawComboBox FormName$, CID&, CVal&, EZ_ODIFont,0, "F"
     END SELECT
END SUB
