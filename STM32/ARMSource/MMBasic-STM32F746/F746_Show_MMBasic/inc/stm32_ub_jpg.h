//--------------------------------------------------------------
// File     : stm32_ub_jpg.h
//--------------------------------------------------------------

//--------------------------------------------------------------
#ifndef __STM32F4_UB_PICTURE_H
#define __STM32F4_UB_PICTURE_H

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32f7xx.h"
#include "stm32f7xx_hal.h"
#include "stm32_ub_lcd_480x272.h"
#include "stm32_ub_sdram.h"
#include "stmF7_gfx.h"
#include "stdlib.h"
#include "stm32_ub_fatfs.h"
#include "Files.h"

//--------------------------------------------------------------
// Lese Puffer Größe (NICHT ÄNDERN !!)
//--------------------------------------------------------------
#define  PICTURE_BUF_SIZE   512  // Puffer in Bytes (512)
#define  PICTURE_JPG_BLOCK  256  // JPG-Block in Bytes (256)

//--------------------------------------------------------------
// Return Werte beim zeichnen
//--------------------------------------------------------------
typedef enum {
	PICTURE_OK =0,
	PICTURE_MEDIA_ERR,
	PICTURE_FILE_ERR,
	PICTURE_SIZE_ERR,
	PICTURE_ID_ERR,
	PICTURE_HEAD_ERR,
	PICTURE_WIDTH_ERR,
	PICTURE_HEIGHT_ERR,
	PICTURE_BPP_ERR,
	PICTURE_COMPR_ERR
}PICTURE_ERR_t;

//--------------------------------------------------------------
// Typedef für Windows-Jpg-File
//--------------------------------------------------------------
typedef uint8_t       PBYTE;
typedef uint16_t      PWORD;
typedef uint32_t      PDWORD;

//--------------------------------------------------------------
// Defines für Windows-Jpg-File
//--------------------------------------------------------------
#define PM_SOF0  0xc0
#define PM_DHT   0xc4
#define PM_EOI   0xd9
#define PM_SOS   0xda
#define PM_DQT   0xdb
#define PM_DRI   0xdd
#define PM_APP0  0xe0

#define PW1 2841  
#define PW2 2676  
#define PW3 2408  
#define PW5 1609  
#define PW6 1108  
#define PW7 565   

#define PMAKEWORD(a, b)      ((PWORD)(((PBYTE)(a)) | ((PWORD)((PBYTE)(b))) << 8))

#define PFUNC_OK 0
#define PFUNC_FORMAT_ERROR 3 

//--------------------------------------------------------------
// Struktur von einem Windows-Jpg-File
//--------------------------------------------------------------
typedef struct{
	long CurX;
	long CurY;
	PDWORD ImgWidth;
	PDWORD ImgHeight;
	short SampRate_Y_H;
	short SampRate_Y_V;
	short SampRate_U_H;
	short SampRate_U_V;
	short SampRate_V_H;
	short SampRate_V_V;
	short H_YtoU;
	short V_YtoU;
	short H_YtoV;
	short V_YtoV;
	short Y_in_MCU;
	short U_in_MCU;
	short V_in_MCU;  // notwendig ??
	unsigned char *lp;
	short qt_table[3][64];
	short comp_num;
	PBYTE comp_index[3];
	PBYTE YDcIndex;
	PBYTE YAcIndex;
	PBYTE UVDcIndex;
	PBYTE UVAcIndex;
	PBYTE HufTabIndex;
	short *YQtTable;
	short *UQtTable;
	short *VQtTable;
	short code_pos_table[4][16];
	short code_len_table[4][16];
	unsigned short code_value_table[4][256];
	unsigned short huf_max_value[4][16];
	unsigned short huf_min_value[4][16];
	short BitPos;
	short CurByte;
	short rrun;
	short vvalue;
	short MCUBuffer[10*64];
	short QtZzMCUBuffer[10*64];
	short BlockBuffer[64];
	short ycoef;
	short ucoef;
	short vcoef;
	PBYTE IntervalFlag;
	short interval;
	short Y[4*64];
	short U[4*64];
	short V[4*64];
	PDWORD sizei;
	PDWORD sizej;
	short restart;
	long iclip[1024];
	long *iclp;
}PICTURE_JPG_t;
extern PICTURE_JPG_t PICTURE_JPG;

//--------------------------------------------------------------
// Struktur von einem Windows-BMP-File
//--------------------------------------------------------------
typedef struct{
  uint32_t offset;
  uint32_t width;
  uint32_t height;
  uint16_t bpp;
  uint32_t compr;
  uint8_t spacer;
  uint16_t bytes_in_buf;
  uint32_t akt_ptr;
}PICTURE_BMP_t;
extern PICTURE_BMP_t PICTURE_BMP;



//--------------------------------------------------------------
// Globale Funktionen
//--------------------------------------------------------------
PICTURE_ERR_t UB_Picture_DrawJpg(FIL* fileptr, uint16_t xpos, uint16_t ypos, uint8_t BuffNum);
PICTURE_ERR_t UB_Picture_DrawBmp(FIL* fileptr, uint16_t xpos, uint16_t ypos, uint8_t BuffNum);


//--------------------------------------------------------------
#endif // __STM32F4_UB_PICTURE_H
