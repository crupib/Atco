//--------------------------------------------------------------
// File     : stmF7_gfx.h
//--------------------------------------------------------------

//--------------------------------------------------------------
#ifndef __STMF7_GFX_H
#define __STMF7_GFX_H

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32f7xx.h"
#include "stm32f7xx_hal.h"
#include "stm32_ub_lcd_480x272.h"
#include "stm32_ub_sdram.h"
#include "stdlib.h"
#include "stm32_ub_fatfs.h"
#include "Files.h"

// *********************** Types and Defs from UB graphics2d lib
typedef enum {
	LCD_DIR_HORIZONTAL =0,
	LCD_DIR_VERTICAL
}LCD_DIR_t;

//--------------------------------------------------------------
// Struktur von einem Image
//--------------------------------------------------------------
typedef struct UB_Image_t
{
	const uint16_t *table; // Tabelle mit den Daten
	uint16_t width;        // Breite des Bildes (in Pixel)
	uint16_t height;       // Hoehe des Bildes  (in Pixel)
}UB_Image;

//--------------------------------------------------------------
// Einbinden der benutzen Bilder
//--------------------------------------------------------------
extern UB_Image logo;

//--------------------------------------------------------------
// Struktur von einer Kopie-Koordinate
//--------------------------------------------------------------
typedef struct DMA2D_Koord_t {
	uint32_t source_xp; // Quelle X-Start
	uint32_t source_yp; // Quelle Y-Start
	uint32_t source_w;  // Quelle Breite
	uint32_t source_h;  // Quelle Höhe
	uint32_t dest_xp;   // Ziel X-Start
	uint32_t dest_yp;   // Ziel Y-Start
}DMA2D_Koord;

// ******************* End Types and Defs from UB graphics2d lib


// Exported Types and variables
#define 	GFX_MAX_X						((uint16_t)(LCD_MAXX - 1))
#define 	GFX_MAX_Y						((uint16_t)(LCD_MAXY - 1))

// Max number of Sprite to show
#define NbSpriteShow						499

// 2D point structure
typedef struct {
	int16_t x;			// X Coordinate on screen
	int16_t y;			// Y Coordinate on screen
}Point2D;

typedef struct {
	int16_t x1;
	int16_t y1;
	int16_t x2;
	int16_t y2;
	int16_t flag;
}GFX_Edge;

// Triangle structure
typedef struct {
	float ax;
	float ay;
	float bx;
	float by;
	float cx;
	float cy;
} TriPoint;

// Rectangle / Line Clipping structure
typedef struct {
	uint16_t x1;
	uint16_t y1;
	uint16_t x2;
	uint16_t y2;
	uint16_t  w;
	uint16_t  h;
} ClipScreen;

// Map Clipping structure
typedef struct {
	uint16_t Src_x1;
	uint16_t Src_y1;
	uint16_t Dest_x1;
	uint16_t Dest_y1;
	uint16_t Dest_w;
	uint16_t Dest_h;
} ClipMapScreen;

// Sprite structure
typedef struct {
	int16_t SprNum;		// Sprite number (0 to 499)
	int16_t x;			// X Coordinate on screen
	int16_t y;			// Y Coordinate on screen
}sprinfo;

// Points for polygon
#define MaxPolyPoint			100
#define MaxPolygon				100
// Polygon structure
typedef struct {
	Point2D		Center;				// Polygon Center
	Point2D		Pts[MaxPolyPoint];	// Point for the polygon (400 bytes)
}PolyDef;

// Global Variables
extern uint16_t  Map_Width;
extern uint16_t  Map_Height;
extern sprinfo 	 SpriteShow[];
// Video Buffer as pointer array
extern uint16_t *VideoBuff;
// Sprites and Map Buffer as pointer array
extern uint16_t *SpriteMemory;
extern uint16_t *MapMemory;

extern PolyDef		PolySet[];

// Start of Video Memory buffer in SDRAM
#define GFX_FRAME_BUFFER       SDRAM_START_ADR	//0xC0000000) st7 Disco board
// Offset for 480 x 272 with 2 bytes/pixels (261.120 bytes)
#define BUFFER_OFFSET						((uint32_t)(LCD_MAXX * LCD_MAXY * 2))

// Number of pixel for one Buffer
#define PIXEL_COUNT							((uint32_t)(LCD_MAXX * LCD_MAXY))
// We reserve 3 Screen buffer into the SDRAM (783.360 bytes)
// Buffer 0 is Layer 1 (Background)
// Buffer 1 is layer 2 (Foreground)
// Buffer 2 is a working buffer
#define GFX_MEMORY_END		(GFX_FRAME_BUFFER + (3 * BUFFER_OFFSET))

// Here we define a place to put the Sprite , Maps and other graphics related stuff.

// For each Sprite we have the Width , Height and the pixels buffer.
// We define the start address after the Screen Buffer
// Each Sprite can have 2052 bytes [((32 x 32) x 2) + 4]
// For this we need 1.026.000 bytes
#define GFX_SPRITE_START		(GFX_MEMORY_END)
#define GFX_SPRITE_HEADER_LNG	4		// 2 x 16bits value for Width and Height
#define GFX_SPRITE_WIDTH_MAX	32		// Maximum Sprite Width
#define GFX_SPRITE_HEIGHT_MAX	32		// Maximum Sprite Height
#define GFX_SPRITE_MAX			500		// Maximum number of Sprites
// Compute the Sprite lenght in bytes (2052 bytes)
#define GFX_SPRITE_LENGTH		(GFX_SPRITE_HEADER_LNG + ((GFX_SPRITE_WIDTH_MAX * GFX_SPRITE_HEIGHT_MAX) * 2))
// Set the end of Sprite memory buffer (1.809.360)
#define GFX_SPRITE_MEMORY_END	(GFX_MEMORY_END + (GFX_SPRITE_LENGTH * GFX_SPRITE_MAX))

// Here we define a place to put a Game Map or Graphics Level
// We just reserve 2000000 bytes of memory because Game Map can have different size
// Adjust the value if you need bigger maps
#define GFX_MAP_START			(GFX_SPRITE_MEMORY_END)
#define GFX_MAP_HEADER_LNG		4			// 2 x 16bits value for width and height from the Map
#define MAP_PIX_START			(GFX_MAP_START + GFX_MAP_HEADER_LNG) // start at 1.809.364
#define GFX_MAP_LENGTH			2000000		// bytes reserved (1.000.000 of 16bits pixels)
// Set the end of Map memory buffer (3.809.364)
#define GFX_MAP_MEMORY_END		(GFX_MAP_HEADER_LNG + GFX_MAP_START + GFX_MAP_LENGTH)

// Set a define for SDRAM Video memory end at 3.809.364
#define VIDEO_MEMORY_END		GFX_MAP_MEMORY_END
// Set a define for Music module memory file start at 3.809.364
#define MOD_MEMORY_START		VIDEO_MEMORY_END
// Set a define for Music module memory file end at 4.809.364
#define MOD_MEMORY_END			(MOD_MEMORY_START + 1000000)
// Set a define for SDRAM 3D Video buffer memory start at 4.809.364
#define VIDEO_3D_START			MOD_MEMORY_END
// Set a define for SDRAM 3D Video buffer memory end at 5.857.940
#define VIDEO_3D_END			(MOD_MEMORY_END + 1048576)

// 50k from SDRAM reserved for Polygon Data
#define POLYGONDATA_END			(VIDEO_3D_END + 51200)
// Polygon memory end is at 5.909.140

// Still available in SDRAM : 8.388.608 - 5.909.140 = 2.479.468 bytes



// DMA2D Waiting flags From TM Lib//
#define DMA2D_WORKING               ((DMA2D->CR & DMA2D_CR_START))
#define DMA2D_WAIT                  do { while (DMA2D_WORKING); DMA2D->IFCR = DMA2D_IFSR_CTCIF;} while (0)

// GFX Exported Functions from TM Lib
void GFX_CopyBuffer(void* pSrc, void* pDst, uint32_t xSize, uint32_t ySize, uint32_t OffLineSrc, uint32_t OffLineDst);

// Remade TM lib
void GFX_Layer_Copy(uint8_t LayerSrc,uint8_t LayerDst);

// Those have to be continued
void GFX_RoundedRectangle(int16_t x, int16_t y, uint16_t width, uint16_t height, uint16_t r, uint16_t BorderColor, uint8_t BuffNum);
void GFX_FullRoundedRectangle(int16_t x, int16_t y, uint16_t width, uint16_t height, uint16_t r, uint16_t BorderColor, uint16_t FillColor, uint8_t BuffNum);
void GFX_CircleCorner(int16_t x0, int16_t y0, int16_t r, uint8_t corner, uint16_t BorderColor, uint8_t BuffNum);
void GFX_FullCircleCorner(int16_t x0, int16_t y0, int16_t r, uint8_t corner, uint16_t BorderColor, uint16_t FillColor, uint8_t BuffNum);


// Conversion from my own lib
void GFX_PolyInit(void);
void GFX_Clear(uint8_t BuffNum, uint16_t Color);
uint16_t GFX_StringLine(uint16_t LineNumber);
uint16_t GFX_StringColumn(uint16_t ColumnNumber);
void GFX_SetPixel(int16_t Xpos, int16_t Ypos, uint16_t Color, uint8_t BuffNum);
uint16_t GFX_GetPixel(int16_t Xpos, int16_t Ypos, uint8_t BuffNum);
void GFX_DrawLine(int16_t Xpos, int16_t Ypos, int16_t Length, uint8_t Direction, uint16_t Color, uint8_t BuffNum);
void GFX_DrawUniLine(int16_t x1, int16_t y1, int16_t x2, int16_t y2, uint16_t Color, uint8_t BuffNum);
void GFX_DrawRect(int16_t Xpos, int16_t Ypos, int16_t Width, int16_t Height, uint16_t Color, uint8_t BuffNum);
void GFX_DrawFullRect(int16_t Xpos, int16_t Ypos, int16_t Width, int16_t Height, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum);
void GFX_DrawCircle(int16_t x, int16_t y, uint16_t radius, uint16_t color , uint8_t BuffNum);
void GFX_DrawEllipse(int16_t Xpos, int16_t Ypos, uint16_t Radius, uint16_t Radius2, uint16_t Color, uint8_t BuffNum);
void GFX_DrawFullEllipse(int16_t Xpos, int16_t Ypos, uint16_t Radius, uint16_t Radius2, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum);
void GFX_DrawRectBorder(int16_t Xpos1, int16_t Ypos1, int16_t Xpos2, int16_t Ypos2, uint16_t BorderColor, uint8_t BuffNum);
void GFX_DrawFullCircle(int16_t Xpos, int16_t Ypos, int16_t Radius, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum);
void GFX_Draw_Triangle(TriPoint Triangle, uint16_t color, uint8_t BuffNum);
void GFX_Draw_Full_Triangle(TriPoint Triangle, uint16_t incolor, uint16_t outcolor, uint8_t BuffNum);
void GFX_DrawQuad(int16_t CenterX, int16_t CenterY, int16_t Width, int16_t Height, int16_t Angle, uint16_t Color, uint8_t BuffNum);
void GFX_DrawFullQuad(int16_t CenterX, int16_t CenterY, int16_t Width, int16_t Height, int16_t Angle, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum);
void GFX_DrawPolygon(uint8_t PolyNum, uint16_t PointCount, uint16_t outcolor, uint8_t BuffNum);
void GFX_DrawFullPolygon(uint8_t PolyNum, uint16_t PointCount, uint16_t incolor, uint16_t outcolor, uint8_t BuffNum);
void GFX_RotatePolygon(uint8_t PolyNum, uint16_t PointCount, int16_t Angle, uint16_t incolor, uint16_t outcolor, uint8_t Filled, uint8_t BuffNum);
void GFX_CopyImgDMA(UB_Image *img, DMA2D_Koord koord);


// Screen Clipping functions
ClipScreen GFX_Rect_Clip(int16_t Xpos1, int16_t Ypos1, int16_t Xpos2, int16_t Ypos2);
ClipScreen GFX_Line_Clip(int16_t Xpos, int16_t Ypos, int16_t Length, uint8_t Direction);
ClipMapScreen GFX_Map_Clip(int16_t StartX, int16_t StartY, int16_t Xpos1, int16_t Ypos1, int16_t Width, int16_t Height);
ClipMapScreen GFX_Blit_Clip(int16_t StartX, int16_t StartY, int16_t Xpos1, int16_t Ypos1, int16_t Width, int16_t Height);

// Sprites and Maps functions
uint8_t GFX_Load_Sprite(const char* name,uint16_t SpriteStart);
uint8_t GFX_Load_Map(const char* name,uint8_t MapNum);
void GFX_Show_Map_DMA2D(int16_t StartX, int16_t StartY,uint16_t Width,uint16_t Height,int16_t DestX, int16_t DestY, uint8_t GFX_Layer, uint8_t showtrans);
void GFX_Sprite_Show_DMA2D(uint16_t Sprite_Num , int16_t x , int16_t y , uint8_t GFX_Layer);
void GFX_Blit_DMA2D(int16_t StartX, int16_t StartY,uint16_t Width,uint16_t Height,int16_t DirX, int16_t DirY, uint8_t Roll, uint8_t DST_Layer);

// New funktion under test

//--------------------------------------------------------------
#endif // __STMF7_GFX_H
