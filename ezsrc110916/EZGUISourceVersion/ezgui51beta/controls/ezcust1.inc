SUB EZC_ColorCombo_Init(BYVAL N&)
     EZ_DefCustomControl N&, "COLORCOMBO", 1, "O$J", CODEPTR(EZC_ColorCombo_Events)
END SUB

SUB EZC_ColorCombo_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE AS LONG CMsg&
          CASE %EZ_OwnerSize
               EZ_SizeComboBox CVal&, EZ_ODIFont
          CASE %EZ_OwnerDraw
               EZ_DrawComboBox FormName$, CID&, CVal&, EZ_ODIFont,0, "C"
     END SELECT
END SUB
