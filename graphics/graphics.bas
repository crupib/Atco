ySCRN& = 800 : xSCRN& = 400
PixPerInch! = 0.04! '0.035! '0.05! '0.010! '.040! ' graphic window size
yScrn1! = -(ySCRN& * .400!* PixPerInch!) : yScrn2! = ySCRN& * .400!* PixPerInch!
xScrn1! = -(xSCRN& * .400!* PixPerInch!) : xScrn2! = (xSCRN& * .400!* PixPerInch!)
PlotClr& = %WHITE
BackClr& = %BLACK
ForeClr& = PlotClr&
hWin& = EZ_Handle ( "MAIN",  0 )

GRAPHIC WINDOW "NOZZLE 'Top View'", 10, 10, ySCRN&, xSCRN& TO hWin(0), HIDE 'Create a graphic window and assign it a handle
GRAPHIC ATTACH hWin(0), 0& 'Select standard window
BmpName$=EZ_AppPath+"nude.bmp"
GRAPHIC BITMAP LOAD BmpName$, 800, 400 TO hBmp???
GRAPHIC COPY hBMP,0
GRAPHIC BOX (400, 200) - (430, 230), 20, %BLUE, RGB(191,191,191), 6
GRAPHIC BOX (460, 190) - (490, 220), 20, %BLUE, RGB(191,191,191), 6
GRAPHIC BOX (390, 260) - (420, 290), 20, %BLUE, RGB(191,191,191), 6
GRAPHIC BITMAP END



GRAPHIC WINDOW "NOZZLE 2 'Top View'", 10, 10, ySCRN&, xSCRN& TO hWin(1), HIDE 'Create a graphic window and assign it a handle
GRAPHIC ATTACH hWin(1), 0& 'Select standard window
GRAPHIC COPY hWin(0),0
GRAPHIC WINDOW NORMALIZE hWin(1)
