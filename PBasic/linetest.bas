#COMPILE EXE
#DIM ALL

#DEBUG ERROR ON     'catch array/pointer errors - OFF in production
#DEBUG DISPLAY ON   'display untrapped errors   - OFF in production

#INCLUDE "Win32API.inc"

DECLARE SUB RtlFillMemory LIB "Kernel32.dll" ( BYREF Destination AS ANY, BYVAL Length AS LONG, BYVAL FILL AS BYTE)
LOCAL bm AS BitmapInfo

   TYPE BITMAPINFO
      bmiHeader AS BITMAPINFOHEADER     'BITMAPINFOHEADER data structure
      bmiColors AS LONG                 'array of RGBQuad data structures
   END TYPE
TYPE BITMAPINFOHEADER
      biSize AS DWORD           'size of this structure (40 bytes)
      biWidth AS LONG           'image width - pixel width of image (does not include padding bytes)
      biHeight AS LONG          'image height - pixel height of image (- for bottoms up image)
      biPlanes AS WORD          'bit planes - always 1
      biBitCount AS WORD        'resolution (24 or 32 bits per pixel for this tutorial)
      biCompression AS DWORD    'compression method (%BI_RGB for uncompressed)
      biSizeImage AS DWORD      '0 for %BI_RGB compression
      biXPelsPerMeter AS LONG   'not used by CreateDIBSection
      biYPelsPerMeter AS LONG   'not used by CreateDIBSection
      biClrUsed AS DWORD        'no palette with 24/32bit bitmaps, so set to zero
      biClrImportant AS DWORD   'no palette with 24/32bit bitmaps, so set to zero
   END TYPE
  TYPE RGBQUAD
       rgbBlue AS BYTE
       rgbGreen AS BYTE
       rgbRed AS BYTE
       rgbReserved AS BYTE
   END TYPE



GLOBAL hDlg, hGraphic, DC_Graphic AS DWORD
FUNCTION PBMAIN() AS LONG
   Dialog NEW PIXELS, 0, "Test Code",300,300,200,200, %WS_OVERLAPPEDWINDOW TO hDlg
   Control Add Button, hDlg, 100,"Push", 50,10,100,20
   Control Add Image, hDlg, 200,"", 50,40,100,100, %WS_BORDER
   Control HANDLE hDlg, 200 TO hGraphic
   DC_graphic = GetDC (hGraphic)                           'DC for Image control
   Dialog SHOW Modal hDlg CALL DlgProc
END FUNCTION
CallBack FUNCTION DlgProc() AS LONG
   IF CB.Msg = %WM_COMMAND AND CB.Ctl = 100 AND CB.Ctlmsg = %BN_CLICKED THEN
      CreateDisplayDIBSection (100,100, "test.bmp")
   END IF
END FUNCTION

SUB CreateDisplayDIBSection(w AS LONG, h AS LONG, fName AS STRING)

   'Create device context (where the DIB Section will be selected)
   LOCAL hMemDC AS DWORD
   hMemDC = CreateCompatibleDC(%NULL)

   'Create/fill in the BITMAPINFO data structure
   LOCAL BI AS BITMAPINFO
   BI.bmiHeader.biSize = 40                'SizeOf(BI.bmiHeader) = 40
   BI.bmiHeader.biWidth = w
   BI.bmiHeader.biHeight = h
   BI.bmiHeader.biPlanes = 1
   BI.bmiHeader.biBitCount = 32            'must be 32 because an RGBQuad is 32 bytes
   BI.bmiHeader.biCompression = %BI_RGB    '%BI_RGB = 0
   BI.bmiHeader.biSizeImage     = 0        'zero for %BI_RGB images
   BI.bmiHeader.biXPelsPerMeter = 0        'zero (device-specific value)
   BI.bmiHeader.biYPelsPerMeter = 0        'zero (device-specific value)
   BI.bmiHeader.biClrUsed       = 0        'no palette so set to zero
   BI.bmiHeader.biClrImportant  = 0        'zero means all colors are important

   'Create the DIB Section and select it into the DC
   LOCAL hDIBSection AS DWORD, P AS DWORD
   hDIBSection = CreateDIBSection(hMemDC, BI, %DIB_RGB_COLORS, VARPTR(P), 0, 0)

   'Create the RGBQuad color data and pre-load all colors to red (for grins)
   DIM Colors(w-1,h-1) AS RGBQUAD
   LOCAL x, y AS LONG
   FOR x = 0 TO w-1 : FOR y = 0 TO h-1 : Colors(x,y).rgbRed = 128 : NEXT : NEXT
   CopyMemory(BYVAL P, BYVAL VARPTR(Colors(0)), w*h*4)      'Dest, Source, #Bytes

   'Now that the DIB Section is in a device context, you can use API to draw on it
    SelectObject(hMemDC, hDIBSection)
    ELLIPSE hMemDC, 20,20,60,60

   'If desired, you can get the info back into your array, make changes, and put changes into the DIBSection
   CopyMemory(BYVAL VARPTR(Colors(0)), BYVAL P, w*h*4)      'Dest, Source, #Bytes
   FOR x = w/2 TO w-1 : FOR y = h/2 TO h-1 : Colors(x,y).rgbRed = 64 : NEXT : NEXT
   CopyMemory(BYVAL P, BYVAL VARPTR(Colors(0)), w*h*4)      'Dest, Source, #Bytes

   'Copy the completed drawing (hMEMDC) to the graphics control
   BitBlt(DC_Graphic, 0, 0, w, h, hMemDC, 0, 0, %SRCCOPY)

END SUB
