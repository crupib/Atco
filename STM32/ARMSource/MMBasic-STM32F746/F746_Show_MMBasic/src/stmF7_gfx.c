//--------------------------------------------------------------
// File     : stmF7_gfx.c
//--------------------------------------------------------------

#include "stmF7_gfx.h"
#include <stdio.h>
#include <math.h>
#include "lib3d.h"

// Video Buffer as pointer array
uint16_t *VideoBuff = (uint16_t *)GFX_FRAME_BUFFER;
// Sprite and Map Buffer as pointer array
uint16_t *SpriteMemory = (uint16_t *)GFX_SPRITE_START;
//uint16_t *MapMemory = (uint16_t *)GFX_MAP_START;
uint16_t *MapMemory = (uint16_t *)MAP_PIX_START;
sprinfo	 SpriteShow[NbSpriteShow];
// Polygon datas in SDRAM for 100 polygons with 100 points for each
PolyDef	PolySet[MaxPolygon]			__attribute__((section(".GFX_POLYGON_Section")));

// Game Map
uint16_t Map_Width  = 0;
uint16_t Map_Height = 0;

#define ABS(X)  ((X) > 0 ? (X) : -(X))

int SM_Media;	// Sprite + Map Media (SDFS or FLASHFS or USBFS)

static uint32_t P_convert565to8888(uint16_t c);

//--------------------------------------------------------------
// convertiert RGB565 in ARGB8888
//--------------------------------------------------------------
static uint32_t P_convert565to8888(uint16_t c)
{
	uint32_t ret_wert;
	uint32_t Red_Value = 0, Green_Value = 0, Blue_Value = 0;

	Red_Value = (0xF800 & c) << 8;
	Green_Value = (0x07E0 & c) << 5;
	Blue_Value = (0x001F & c) << 3;

	ret_wert=0xFF000000;
	ret_wert|=Red_Value;
	ret_wert|=Green_Value;
	ret_wert|=Blue_Value;

	return ret_wert;
}

// This functions is a modified one from TM Libs
void GFX_CopyBuffer(void* pSrc, void* pDst, uint32_t xSize, uint32_t ySize, uint32_t OffLineSrc, uint32_t OffLineDst) {
	/* Wait for previous operation to be done */
	DMA2D_WAIT;

	/* DeInit DMA2D */
	RCC->AHB1RSTR |= RCC_AHB1RSTR_DMA2DRST;
	RCC->AHB1RSTR &= ~RCC_AHB1RSTR_DMA2DRST;

	DMA2D->CR = 0x00000000UL | (1 << 9);

	/* Set up pointers */
	DMA2D->FGMAR = (uint32_t)pSrc;
	DMA2D->OMAR = (uint32_t)pDst;
	DMA2D->FGOR = OffLineSrc;
	DMA2D->OOR = OffLineDst;

	/* Set up pixel format */
	DMA2D->FGPFCCR = LTDC_PIXEL_FORMAT_RGB565;

	/* Set up size */
	DMA2D->NLR = (uint32_t)(xSize << 16) | (uint16_t)ySize;

	/* Start DMA2D */
	DMA2D->CR |= DMA2D_CR_START;

	/* Wait until transfer is done */
	DMA2D_WAIT;
}

//--------------------------------------------------------------
// Copy one layer to another one
// LayerSrc : Source Layer number to copy from
// LayerDst : Destination where we send the data
// LayerSrc and LayerDst can be 1 to 3
//--------------------------------------------------------------
void GFX_Layer_Copy(uint8_t LayerSrc,uint8_t LayerDst)
{
	uint32_t src_addr = 0;
	uint32_t dst_addr = 0;

	if((LayerSrc > 2) || (LayerDst > 2)) return;
	if(LayerSrc == LayerDst) return;
	switch (LayerSrc)
	{
	case 0:
		src_addr = GFX_FRAME_BUFFER;
		break;
	case 1:
		src_addr = GFX_FRAME_BUFFER + BUFFER_OFFSET;
		break;
	case 2:
		src_addr = GFX_FRAME_BUFFER + (2 * BUFFER_OFFSET);
		break;
	default:
		return;
	}
	switch (LayerDst)
	{
	case 0:
		dst_addr = GFX_FRAME_BUFFER;
		break;
	case 1:
		dst_addr = GFX_FRAME_BUFFER + BUFFER_OFFSET;
		break;
	case 2:
		dst_addr = GFX_FRAME_BUFFER + (2 * BUFFER_OFFSET);
		break;
	default:
		return;
	}
	// Copy buffer using DMA2D //
	GFX_CopyBuffer(
			(void *)(src_addr),
			(void *)(dst_addr),
			LCD_MAXX,
			LCD_MAXY,
			0,
			0
	);
}

// Conversion from my st429 gfx lib with UB dam2d mixing :)

void GFX_PolyInit(void)
{
	uint16_t polnum,polpts;
	// we initialize polygon data here , it will be moved latter
	for(polnum = 0;polnum < MaxPolygon;polnum++){
		for(polpts = 0;polpts < MaxPolyPoint;polpts++){
			PolySet[polnum].Pts[polpts].x = 0;
			PolySet[polnum].Pts[polpts].y = 0;
		}
		PolySet[polnum].Center.x = 0;
		PolySet[polnum].Center.y = 0;
	}
}

void GFX_Clear(uint8_t BuffNum, uint16_t Color)
{
	static DMA2D_HandleTypeDef hDma2dHandler;
	uint32_t col32;
	uint32_t layer_addr = 0;

	switch (BuffNum)
	{
	case 0:
		layer_addr = GFX_FRAME_BUFFER;
		break;
	case 1:
		layer_addr = GFX_FRAME_BUFFER + BUFFER_OFFSET;
		break;
	case 2:
		layer_addr = GFX_FRAME_BUFFER + (2 * BUFFER_OFFSET);
		break;
	default:
		return;
	}
	hDma2dHandler.Init.Mode         = DMA2D_R2M;
	hDma2dHandler.Init.ColorMode    = DMA2D_RGB565;
	hDma2dHandler.Init.OutputOffset = 0;
	hDma2dHandler.Instance = DMA2D;

	col32=P_convert565to8888(Color); // bug workaround

	// DMA2D Initialization
	if(HAL_DMA2D_Init(&hDma2dHandler) == HAL_OK) {
		if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, BuffNum) == HAL_OK) {
			if (HAL_DMA2D_Start(&hDma2dHandler, col32, (uint32_t)layer_addr, LCD_MAXX, LCD_MAXY) == HAL_OK)
			{
				HAL_DMA2D_PollForTransfer(&hDma2dHandler, 10);
			}
		}
	}
}

//--------------------------------------------------------------
// Return Y for LineNumber (must be fix Font)
//--------------------------------------------------------------
uint16_t GFX_StringLine(uint16_t LineNumber)
{
	//return (LineNumber * (GFX_Currentfonts->Height));
	return 0;
}

//--------------------------------------------------------------
// Return X for Column Number (must be fix Font)
//--------------------------------------------------------------
uint16_t GFX_StringColumn(uint16_t ColumnNumber)
{
	//return (ColumnNumber * (GFX_Currentfonts->Width));
	return 0;
}

ClipScreen GFX_Rect_Clip(int16_t Xpos1, int16_t Ypos1, int16_t Xpos2, int16_t Ypos2)
{
	// Clip a rectangle into the screen
	int16_t x1 = Xpos1;
	int16_t y1 = Ypos1;
	int16_t x2 = Xpos2;
	int16_t y2 = Ypos2;
	uint16_t tmp = 0;

	ClipScreen CRes;
	if(x1 < 0) x1 = 0;
	if(x1 > (LCD_MAXX - 1)) x1 = (LCD_MAXX - 1);
	if(x2 < 0) x2 = 0;
	if(x2 > (LCD_MAXX - 1)) x2 = (LCD_MAXX - 1);
	if(y1 < 0) y1 = 0;
	if(y1 > (LCD_MAXY - 1)) y1 = (LCD_MAXY - 1);
	if(y2 < 0) y2 = 0;
	if(y2 > (LCD_MAXY - 1)) y2 = (LCD_MAXY - 1);
	// x1 must be < than x2 and y1 must be < than y2
	if(x1 > x2){tmp = x1;x1 = x2;x2 = tmp;}
	if(y1 > y2){tmp = y1;y1 = y2;y2 = tmp;}
	CRes.x1 = x1 ; CRes.y1 = y1 ;CRes.x2 = x2 ; CRes.y2 = y2 ;
	// get the width and height
	CRes.w = x2-x1+1 ;CRes.h = y2-y1+1 ;
	return CRes;
}

ClipMapScreen GFX_Map_Clip(int16_t StartX, int16_t StartY, int16_t Xpos1, int16_t Ypos1, int16_t Width, int16_t Height)
{//                         -------    source   --------    ------  destination ------    ----------  size  --------
	// Clip a rectangle into the screen
	int16_t		sx = StartX;
	int16_t		sy = StartY;
	int16_t		dx = Xpos1;
	int16_t		dy = Ypos1;
	int16_t		w = Width;
	int16_t		h = Height;
	uint16_t	mw = Map_Width - sx;
	uint16_t	mh = Map_Height - sy;
	uint8_t		destpos = 0;

	ClipMapScreen CRes;

	// Check if we are on screen
	if(w<0)
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}
	if(h<0)
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}
	if(dx>GFX_MAX_X)
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}
	if(dy>GFX_MAX_Y)
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}

	// Negative coordinate on map memory are cancelled
	if((sx < 0) | (sy < 0))
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}

	// Found one of the 9 Clipping scenario
	if((dx < 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 1;
	if((dx >= 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 2;
	if((dx >= 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 3;
	if((dx < 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 4;
	if((dx >= 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 5;
	if((dx >= 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 6;
	if((dx < 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 7;
	if((dx >= 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 8;
	if((dx >= 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 9;
	// big map (> as 480 x 272)
	if((dx < 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 10;
	if((dx < 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 11;
	if((dx < 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 12;
	if((dx < 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 13;
	if((dx >= 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 14;
	if((dx < 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 15;
	if((dx >= 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 16;


	switch (destpos)
	{
	case 1:
		sx += abs(dx) ; sy += abs(dy); mw += dx ; mh += dy ; w += dx ; h += dy ;
		dx = 0 ; dy = 0;
		break;
	case 2:
		sy += abs(dy); mh += dy ; h += dy ;
		dy = 0;
		break;
	case 3:
		sy += abs(dy); mw = GFX_MAX_X - dx ; mh += dy ; h += dy ;
		dy = 0;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		break;
	case 4:
		sx += abs(dx) ; mw += dx ; w += dx ;
		dx = 0;
		break;
	case 5:
		break;
	case 6:
		mw = GFX_MAX_X - dx ;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		break;
	case 7:
		sx += abs(dx) ; mw += dx ; mh = GFX_MAX_Y - dy ; w += dx ;
		dx = 0;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 8:
		mh = GFX_MAX_Y - dy ;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 9:
		mw = GFX_MAX_X - dx ; mh = GFX_MAX_Y - dy ;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 10:
		sx += abs(dx) ; sy += abs(dy); mw += dx ; mh += dy ; w += dx ; h += dy ;
		dx = 0 ; dy = 0;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 11:
		sx += abs(dx) ; sy += abs(dy); mw += dx ; mh += dy ; w += dx ; h += dy ;
		dx = 0 ; dy = 0;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		break;
	case 12:
		sx += abs(dx) ; sy += abs(dy); mw += dx ; mh += dy ; w += dx ; h += dy ;
		dx = 0 ; dy = 0;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 13:
		sx += abs(dx) ; mw += dx ; w += dx ;
		dx = 0 ;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		break;
	case 14:
		sy += abs(dy); mh += dy ; h += dy ;
		dy = 0;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 15:
		sx += abs(dx) ; mw += dx ; w += dx ;
		dx = 0 ;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 16:
		sy += abs(dy); mh += dy ; h += dy ;
		dy = 0;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	default:
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}

	// Set the Clipping variable
	CRes.Src_x1  = sx ; CRes.Src_y1  = sy;
	CRes.Dest_x1 = dx ; CRes.Dest_y1 = dy ;
	// get the width and height
	CRes.Dest_w = w ;CRes.Dest_h = h ;

	return CRes;
}

ClipMapScreen GFX_Blit_Clip(int16_t StartX, int16_t StartY, int16_t Xpos1, int16_t Ypos1, int16_t Width, int16_t Height)
{//                         -------    source   --------    ------  destination ------    ----------  size  --------
	// Clip a rectangle into the screen
	int16_t		sx = StartX;
	int16_t		sy = StartY;
	int16_t		dx = Xpos1;
	int16_t		dy = Ypos1;
	int16_t		w = Width;
	int16_t		h = Height;
	uint16_t	mw = LCD_MAXX - sx + 1;
	uint16_t	mh = LCD_MAXY - sy + 1;
	uint8_t		destpos = 0;

	ClipMapScreen CRes;

	// Check if we are on screen
	if(w<0)
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}
	if(h<0)
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}
	if(dx>GFX_MAX_X)
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}
	if(dy>GFX_MAX_Y)
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}

	// Negative coordinate on map memory are cancelled
	if((sx < 0) | (sy < 0))
	{
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}

	// Found one of the 9 Clipping scenario
	if((dx < 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 1;
	if((dx >= 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 2;
	if((dx >= 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 3;
	if((dx < 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 4;
	if((dx >= 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 5;
	if((dx >= 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 6;
	if((dx < 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 7;
	if((dx >= 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 8;
	if((dx >= 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 9;
	// big map (> as 480 x 272)
	if((dx < 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 10;
	if((dx < 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 11;
	if((dx < 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 12;
	if((dx < 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) <= GFX_MAX_Y)) destpos = 13;
	if((dx >= 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) <= GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 14;
	if((dx < 0) & (dy >= 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 15;
	if((dx >= 0) & (dy < 0) & ((dx + mw) > 0) & ((dy + mh) > 0) & ((dx + mw) > GFX_MAX_X) & ((dy + mh) > GFX_MAX_Y)) destpos = 16;


	switch (destpos)
	{
	case 1:
		sx += abs(dx) ; sy += abs(dy); mw += dx ; mh += dy ; w += dx ; h += dy ;
		dx = 0 ; dy = 0;
		break;
	case 2:
		sy += abs(dy); mh += dy ; h += dy ;
		dy = 0;
		break;
	case 3:
		sy += abs(dy); mw = GFX_MAX_X - dx ; mh += dy ; h += dy ;
		dy = 0;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		break;
	case 4:
		sx += abs(dx) ; mw += dx ; w += dx ;
		dx = 0;
		break;
	case 5:
		break;
	case 6:
		mw = GFX_MAX_X - dx ;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		break;
	case 7:
		sx += abs(dx) ; mw += dx ; mh = GFX_MAX_Y - dy ; w += dx ;
		dx = 0;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 8:
		mh = GFX_MAX_Y - dy ;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 9:
		mw = GFX_MAX_X - dx ; mh = GFX_MAX_Y - dy ;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 10:
		sx += abs(dx) ; sy += abs(dy); mw += dx ; mh += dy ; w += dx ; h += dy ;
		dx = 0 ; dy = 0;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 11:
		sx += abs(dx) ; sy += abs(dy); mw += dx ; mh += dy ; w += dx ; h += dy ;
		dx = 0 ; dy = 0;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		break;
	case 12:
		sx += abs(dx) ; sy += abs(dy); mw += dx ; mh += dy ; w += dx ; h += dy ;
		dx = 0 ; dy = 0;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 13:
		sx += abs(dx) ; mw += dx ; w += dx ;
		dx = 0 ;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		break;
	case 14:
		sy += abs(dy); mh += dy ; h += dy ;
		dy = 0;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 15:
		sx += abs(dx) ; mw += dx ; w += dx ;
		dx = 0 ;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	case 16:
		sy += abs(dy); mh += dy ; h += dy ;
		dy = 0;
		if((dx + w) > GFX_MAX_X) w = GFX_MAX_X - dx;
		if((dy + h) > GFX_MAX_Y) h = GFX_MAX_Y - dy;
		break;
	default:
		CRes.Dest_w = 0 ;CRes.Dest_h = 0;
		return CRes;
	}

	// Set the Clipping variable
	CRes.Src_x1  = sx ; CRes.Src_y1  = sy;
	CRes.Dest_x1 = dx ; CRes.Dest_y1 = dy ;
	// get the width and height
	CRes.Dest_w = w ;CRes.Dest_h = h ;

	return CRes;
}

ClipScreen GFX_Line_Clip(int16_t Xpos, int16_t Ypos, int16_t Length, uint8_t Direction)
{
	// Clip Horizontal or Vertical Line into screen
	int16_t x1 = Xpos;
	int16_t y1 = Ypos;
	int16_t x2 = 0;
	int16_t y2 = 0;
	uint16_t tmp = 0;
	ClipScreen CRes;

	if (Direction == LCD_DIR_HORIZONTAL)
	{
		if((y1 < 0) || (y1 > (LCD_MAXY - 1)))
		{
			// This will not allow the line drawing
			CRes.x1 = 0;CRes.y1 = 0;CRes.w = 0;CRes.h = 0;
			return CRes;
		}
		x2 = x1 + Length;
		if(x1 < 0) x1 = 0;
		if(x1 > (LCD_MAXX - 1)) x1 = (LCD_MAXX - 1);
		if(x2 < 0) x2 = 0;
		if(x2 > (LCD_MAXX - 1)) x2 = (LCD_MAXX - 1);
		// x1 must be < than x2
		if(x1 > x2){tmp = x1;x1 = x2;x2 = tmp;}
		CRes.x1 = x1;CRes.y1 = y1;CRes.w = x2-x1+1;CRes.h = 0;
		return CRes;
	}
	else
	{
		if((x1 < 0) || (x1 > (LCD_MAXX - 1)))
		{
			// This will not allow the line drawing
			CRes.x1 = 0;CRes.y1 = 0;CRes.w = 0;CRes.h = 0;
			return CRes;
		}
		y2 = y1 + Length;
		if(y1 < 0) y1 = 0;
		if(y1 > (LCD_MAXY - 1)) y1 = (LCD_MAXY - 1);
		if(y2 < 0) y2 = 0;
		if(y2 > (LCD_MAXY - 1)) y2 = (LCD_MAXY - 1);
		// y1 must be < than y2
		if(y1 > y2){tmp = y1;y1 = y2;y2 = tmp;}
		CRes.x1 = x1;CRes.y1 = y1;CRes.h = y2-y1+1;CRes.w = 0;
		return CRes;
	}
}


// Display a Pixel.
// Xpos: X Coord.
// Ypos: Y Coord.
// Color: Pixel Color
// BuffNum : Layer Number (1 to 3)
void GFX_SetPixel(int16_t Xpos, int16_t Ypos, uint16_t Color, uint8_t BuffNum)
{
	if(Xpos < 0 || Xpos > GFX_MAX_X || Ypos < 0 || Ypos > GFX_MAX_Y){return;}
	VideoBuff[(uint32_t)(((LCD_MAXX * Ypos) + Xpos) + (PIXEL_COUNT * BuffNum))] = Color;
}

// Get a Pixel color.
// Xpos		: X Coord.
// Ypos		: Y Coord.
// BuffNum	: Layer number (1 to 3)
// Returned	: Color value
uint16_t GFX_GetPixel(int16_t Xpos, int16_t Ypos, uint8_t BuffNum)
{
	if(Xpos < 0 || Xpos > GFX_MAX_X || Ypos < 0 || Ypos > GFX_MAX_Y){return 0;}
	uint32_t PixelAdress = (uint32_t)(((LCD_MAXX * Ypos) + Xpos) + (PIXEL_COUNT * BuffNum));
	return VideoBuff[PixelAdress];
}


// Displays a line.
// Xpos: specifies the X position
// Ypos: specifies the Y position
// Length: line length.
// Direction: line direction.
// This parameter can be one of the following values: LCD_DIR_HORIZONTAL or LCD_DIR_VERTICAL.
// retval None
void GFX_DrawLine(int16_t Xpos, int16_t Ypos, int16_t Length, uint8_t Direction, uint16_t Color, uint8_t BuffNum)
{
	static DMA2D_HandleTypeDef hDma2dHandler;
	uint32_t  Xaddress = 0;
	uint32_t col32,offset,w,h;
	ClipScreen LineClip;

	LineClip = GFX_Line_Clip(Xpos,Ypos,Length,Direction);

	// Test if we can draw the line
	if(Direction == LCD_DIR_HORIZONTAL)
	{
		if((LineClip.x1 == 0) && (LineClip.y1 == 0) && (LineClip.w == 0)){return;}
	}
	else
	{
		if((LineClip.x1 == 0) && (LineClip.y1 == 0) && (LineClip.h == 0)){return;}
	}

	col32=P_convert565to8888(Color); // bug workaround (rgb565 bug)

	Xaddress = (GFX_FRAME_BUFFER + (BuffNum * BUFFER_OFFSET)) + 2*(LCD_MAXX*LineClip.y1 + LineClip.x1);

	if(Direction==LCD_DIR_HORIZONTAL) {
		w=LineClip.w;
		h=1;
		offset=0;
	}
	else {
		w=1;
		h=LineClip.h;
		offset=LCD_MAXX-1;
	}

	hDma2dHandler.Init.Mode         = DMA2D_R2M;
	hDma2dHandler.Init.ColorMode    = DMA2D_RGB565;
	hDma2dHandler.Init.OutputOffset = offset;
	hDma2dHandler.Instance = DMA2D;


	// DMA2D Initialization
	if(HAL_DMA2D_Init(&hDma2dHandler) == HAL_OK) {
		if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, LCD_CurrentLayer) == HAL_OK) {
			if (HAL_DMA2D_Start(&hDma2dHandler, col32, (uint32_t)Xaddress, w, h) == HAL_OK)
			{
				HAL_DMA2D_PollForTransfer(&hDma2dHandler, 10);
			}
		}
	}
}


//--------------------------------------------------------------
// Draw a line between 2 points
// x1,y1   : 1st point
// x2,y2   : 2nd point
// Color   : 16bits color
// BuffNum : Layer to use
//--------------------------------------------------------------
void GFX_DrawUniLine(int16_t x1, int16_t y1, int16_t x2, int16_t y2 , uint16_t color , uint8_t BuffNum)
{
	uint8_t yLonger = 0;
	int incrementVal, endVal;
	int shortLen = y2-y1;
	int longLen = x2-x1;
	int decInc;
	int j = 0, i = 0;

	if(ABS(shortLen) > ABS(longLen)) {
		int swap = shortLen;
		shortLen = longLen;
		longLen = swap;
		yLonger = 1;
	}

	endVal = longLen;

	if(longLen < 0) {
		incrementVal = -1;
		longLen = -longLen;
		endVal--;
	} else {
		incrementVal = 1;
		endVal++;
	}

	if(longLen == 0)
		decInc = 0;
	else
		decInc = (shortLen << 16) / longLen;

	if(yLonger) {
		for(i = 0;i != endVal;i += incrementVal) {
			GFX_SetPixel(x1 + (j >> 16),y1 + i,color , BuffNum);
			j += decInc;
		}
	} else {
		for(i = 0;i != endVal;i += incrementVal) {
			GFX_SetPixel(x1 + i,y1 + (j >> 16),color , BuffNum);
			j += decInc;
		}
	}
}

//  Displays a rectangle.
//  Xpos1,Ypos1: specifies the Upper Left Corner from the Rectangle.
//  Xpos2,Ypos2: specifies the Lower Right Corner from the Rectangle.
//  Color: specifies the Color to use.
//  BuffNum: specifies the Video Buffer to use.
void GFX_DrawRect(int16_t Xpos, int16_t Ypos, int16_t Width, int16_t Height, uint16_t Color, uint8_t BuffNum)
{
	/* draw horizontal lines */
	GFX_DrawLine(Xpos, Ypos, Width, LCD_DIR_HORIZONTAL,Color,BuffNum);
	GFX_DrawLine(Xpos, (Ypos+ Height), Width, LCD_DIR_HORIZONTAL,Color,BuffNum);

	/* draw vertical lines */
	GFX_DrawLine(Xpos, Ypos, Height, LCD_DIR_VERTICAL,Color,BuffNum);
	GFX_DrawLine((Xpos + Width), Ypos, Height, LCD_DIR_VERTICAL,Color,BuffNum);
}


//  Displays a filled Rectangle.
//  Xpos,Ypos    : specifies the Upper Left Corner from the Rectangle.
//  Width,Height : specifies the size of the Rectangle.
//  FillColor    : specifies the Color to use for Fill the Rectangle.
//  BorderColor  : specifies the Color to use for draw the Border from the Rectangle.
//  BuffNum      : specifies the Video Layer to use.
void GFX_DrawFullRect(int16_t Xpos, int16_t Ypos, int16_t Width, int16_t Height, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum)
//void GFX_DrawFullRect(int16_t Xpos1, int16_t Ypos1, int16_t Xpos2, int16_t Ypos2, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum)
{
	static DMA2D_HandleTypeDef hDma2dHandler;

	uint32_t  Xaddress = 0;
	uint32_t col32;
	uint16_t dl , dh;
	ClipScreen RectClip;

	dl = Xpos + Width;
	dh = Ypos + Height;
	// Test Screen Clipping
	RectClip = GFX_Rect_Clip(Xpos,Ypos,dl,dh);
	if((RectClip.w == 0) || (RectClip.h == 0)) return;

	Xaddress = (GFX_FRAME_BUFFER + (BuffNum * BUFFER_OFFSET)) + 2*(LCD_MAXX * RectClip.y1 + RectClip.x1);

	col32=P_convert565to8888(FillColor); // bug workaround (rgb565 bug)

	hDma2dHandler.Init.Mode         = DMA2D_R2M;
	hDma2dHandler.Init.ColorMode    = DMA2D_RGB565;
	hDma2dHandler.Init.OutputOffset = LCD_MAXX-RectClip.w;
	hDma2dHandler.Instance = DMA2D;

	// DMA2D Initialization
	if(HAL_DMA2D_Init(&hDma2dHandler) == HAL_OK) {
		if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, LCD_CurrentLayer) == HAL_OK) {
			if (HAL_DMA2D_Start(&hDma2dHandler, col32, (uint32_t)Xaddress, RectClip.w, RectClip.h) == HAL_OK)
			{
				HAL_DMA2D_PollForTransfer(&hDma2dHandler, 10);
			}
		}
	}

	dl = RectClip.x2-RectClip.x1;
	dh = RectClip.y2-RectClip.y1;
	GFX_DrawRect(RectClip.x1,RectClip.y1,dl,dh,BorderColor,BuffNum);
}


void GFX_RoundedRectangle(int16_t x, int16_t y, uint16_t width, uint16_t height, uint16_t r, uint16_t BorderColor, uint8_t BuffNum)
{
	// Check input parameters //
	if (width == 0 || height == 0) {
		return;
	}

	// Check max radius //
	if (r > (width / 2)) {
		r = width / 2 - 1;
	}
	if (r > (height / 2)) {
		r = height / 2 - 1;
	}
	if (
		r > (width / 2) ||
		r > (height / 2)
	) {
		r = 0;
	}

	// No radius //
	if (r == 0) {
		// Draw normal rectangle //
		GFX_DrawRect(x, y, width, height, BorderColor,BuffNum);

		// Return from function //
		return;
	}

	// Draw lines //
	GFX_DrawLine(x + r, y, width - 2 * r,LCD_DIR_HORIZONTAL, BorderColor,BuffNum); // Top //
	GFX_DrawLine(x + r, y + height - 1, width - 2 * r,LCD_DIR_HORIZONTAL, BorderColor,BuffNum); // Bottom //

	GFX_DrawLine(x, y + r, height - 2 * r, LCD_DIR_VERTICAL, BorderColor,BuffNum); // Right //
	GFX_DrawLine(x + width - 1, y + r, height - 2 * r, LCD_DIR_VERTICAL, BorderColor,BuffNum); // Left //

	// Draw corners //
	GFX_CircleCorner(x + r, y + r, r, 0x01, BorderColor,BuffNum); // Top left //
	GFX_CircleCorner(x + width - r - 1, y + r, r, 0x02, BorderColor,BuffNum); // Top right //
	GFX_CircleCorner(x + width - r - 1, y + height - r - 1, r, 0x04, BorderColor,BuffNum); // Bottom right //
	GFX_CircleCorner(x + r, y + height - r - 1, r, 0x08, BorderColor,BuffNum); // Bottom left //
}

void GFX_FullRoundedRectangle(int16_t x, int16_t y, uint16_t width, uint16_t height, uint16_t r, uint16_t BorderColor, uint16_t FillColor, uint8_t BuffNum)
{
	// Check input parameters //
	if (width == 0 || width == 0) {
		return;
	}

	// Check max radius //
	if (r > (width / 2)) {
		r = width / 2 - 1;
	}
	if (r > (height / 2)) {
		r = height / 2 - 1;
	}
	if (
		r > (width / 2) ||
		r > (height / 2)
	) {
		r = 0;
	}

	// No radius //
	if (r == 0) {
		GFX_DrawFullRect(x, y, width, height, BorderColor, FillColor, BuffNum);
		return;
	}

	// Draw rectangles //
	GFX_DrawFullRect(x + r , y, width - (2 * r) - 1, height - 1, FillColor, FillColor, BuffNum);
	GFX_DrawFullRect(x, y + r, r, height - (2 * r), FillColor, FillColor, BuffNum);
	GFX_DrawFullRect(x + width - r, y + r, r - 1, height - (2 * r), FillColor, FillColor, BuffNum);

	// Draw corners //
	GFX_FullCircleCorner(x + r, y + r, r, 0x01, BorderColor, FillColor, BuffNum); // Top left //
	GFX_FullCircleCorner(x + width - r - 1, y + r, r, 0x02, BorderColor, FillColor, BuffNum); // Top right //
	GFX_FullCircleCorner(x + width - r - 1, y + height - r - 1, r, 0x04, BorderColor, FillColor, BuffNum); // Bottom right //
	GFX_FullCircleCorner(x + r, y + height - r - 1, r, 0x08, BorderColor, FillColor, BuffNum); // Bottom left //
	// Draw the border from rounded rectangle
	GFX_RoundedRectangle(x,y,width,height,r,BorderColor,BuffNum);
}

void GFX_CircleCorner(int16_t x0, int16_t y0, int16_t r, uint8_t corner, uint16_t BorderColor, uint8_t BuffNum)
{
	int16_t f = 1 - r;
	int16_t ddF_x = 1;
	int16_t ddF_y = -2 * r;
	int16_t x = 0;
	int16_t y = r;

    while (x < y) {
        if (f >= 0) {
            y--;
            ddF_y += 2;
            f += ddF_y;
        }
        x++;
        ddF_x += 2;
        f += ddF_x;

        if (corner & 0x01) {// Top left //
        	GFX_SetPixel(x0 - y, y0 - x, BorderColor,BuffNum);
        	GFX_SetPixel(x0 - x, y0 - y, BorderColor,BuffNum);
		}

        if (corner & 0x02) {// Top right //
        	GFX_SetPixel(x0 + x, y0 - y, BorderColor,BuffNum);
        	GFX_SetPixel(x0 + y, y0 - x, BorderColor,BuffNum);
		}

		if (corner & 0x04) {// Bottom right //
			GFX_SetPixel(x0 + x, y0 + y, BorderColor,BuffNum);
			GFX_SetPixel(x0 + y, y0 + x, BorderColor,BuffNum);
		}

        if (corner & 0x08) {// Bottom left //
        	GFX_SetPixel(x0 - x, y0 + y, BorderColor,BuffNum);
        	GFX_SetPixel(x0 - y, y0 + x, BorderColor,BuffNum);
		}
    }
}

void GFX_FullCircleCorner(int16_t x0, int16_t y0, int16_t r, uint8_t corner, uint16_t BorderColor, uint16_t FillColor, uint8_t BuffNum)
{
	int16_t f = 1 - r;
	int16_t ddF_x = 1;
	int16_t ddF_y = -2 * r;
	int16_t x = 0;
	int16_t y = r;

    while (x < y) {
        if (f >= 0) {
            y--;
            ddF_y += 2;
            f += ddF_y;
        }
        x++;
        ddF_x += 2;
        f += ddF_x;

        if (corner & 0x01) {// Top left //
        	GFX_DrawUniLine(x0, y0 - y, x0 - x, y0 - y, FillColor, BuffNum);
        	GFX_DrawUniLine(x0, y0 - x, x0 - y, y0 - x, FillColor, BuffNum);
		}

        if (corner & 0x02) {// Top right //
        	GFX_DrawUniLine(x0 + x, y0 - y, x0, y0 - y, FillColor, BuffNum);
        	GFX_DrawUniLine(x0 + y, y0 - x, x0, y0 - x, FillColor, BuffNum);
		}

		if (corner & 0x04) {// Bottom right //
			GFX_DrawUniLine(x0, y0 + y, x0 + x, y0 + y, FillColor, BuffNum);
			GFX_DrawUniLine(x0 + y, y0 + x, x0, y0 + x, FillColor, BuffNum);
		}

        if (corner & 0x08) {// Bottom left //
        	GFX_DrawUniLine(x0 - x, y0 + y, x0, y0 + y, FillColor, BuffNum);
        	GFX_DrawUniLine(x0, y0 + x, x0 - y, y0 + x, FillColor, BuffNum);
		}
    }
}


//--------------------------------------------------------------
// Draw a circle.
// x, y - center of circle.
// r - radius.
// color - color of the circle.
//--------------------------------------------------------------
void GFX_DrawCircle(int16_t x, int16_t y, uint16_t radius, uint16_t color , uint8_t BuffNum)
{
	int16_t a, b, P;

	a = 0;
	b = radius;
	P = 1 - radius;

	do {
		if(((a+x) >= 0) && ((b+x) >= 0))
			GFX_SetPixel(a+x, b+y, color , BuffNum);
		if(((b+x) >= 0) && ((a+y) >= 0))
			GFX_SetPixel(b+x, a+y, color , BuffNum);
		if(((x-a) >= 0) && ((b+y) >= 0))
			GFX_SetPixel(x-a, b+y, color , BuffNum);
		if(((x-b) >= 0) && ((a+y) >= 0))
			GFX_SetPixel(x-b, a+y, color , BuffNum);
		if(((b+x) >= 0) && ((y-a) >= 0))
			GFX_SetPixel(b+x, y-a, color , BuffNum);
		if(((a+x) >= 0) && ((y-b) >= 0))
			GFX_SetPixel(a+x, y-b, color , BuffNum);
		if(((x-a) >= 0) && ((y-b) >= 0))
			GFX_SetPixel(x-a, y-b, color , BuffNum);
		if(((x-b) >= 0) && ((y-a) >= 0))
			GFX_SetPixel(x-b, y-a, color , BuffNum);

		if(P < 0)
			P+= 3 + 2*a++;
		else
			P+= 5 + 2*(a++ - b--);
	} while(a <= b);
}


// Displays a full circle.
// Xpos       : specifies the X position
// Ypos       : specifies the Y position
// Radius     : specifies the Circle Radius
// FillColor  : specifies the Circle Fill Color
// BorderColor: specifies the Circle Border Color
// BuffNum    : specifies the Video Layer number
void GFX_DrawFullCircle(int16_t Xpos, int16_t Ypos, int16_t Radius, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum)
{
	int32_t  D;    /* Decision Variable */
	uint32_t  CurX;/* Current X Value */
	uint32_t  CurY;/* Current Y Value */

	D = 3 - (Radius << 1);

	CurX = 0;
	CurY = Radius;

	while (CurX <= CurY)
	{
		if(CurY > 0)
		{
			GFX_DrawLine(Xpos - CurX, Ypos - CurY, 2*CurY, LCD_DIR_VERTICAL,FillColor,BuffNum);
			GFX_DrawLine(Xpos + CurX, Ypos - CurY, 2*CurY, LCD_DIR_VERTICAL,FillColor,BuffNum);
		}

		if(CurX > 0)
		{
			GFX_DrawLine(Xpos - CurY, Ypos - CurX, 2*CurX, LCD_DIR_VERTICAL,FillColor,BuffNum);
			GFX_DrawLine(Xpos + CurY, Ypos - CurX, 2*CurX, LCD_DIR_VERTICAL,FillColor,BuffNum);
		}
		if (D < 0)
		{
			D += (CurX << 2) + 6;
		}
		else
		{
			D += ((CurX - CurY) << 2) + 10;
			CurY--;
		}
		CurX++;
	}

	GFX_DrawCircle(Xpos, Ypos, Radius,BorderColor,BuffNum);
}


//--------------------------------------------------------------
// Draw a Triangle.
// Triangle	- the triangle points.
// color		- color of the triangle.
//--------------------------------------------------------------
void GFX_Draw_Triangle(TriPoint Triangle, uint16_t color, uint8_t BuffNum)
{
	GFX_DrawUniLine((int16_t)Triangle.ax , (int16_t)Triangle.ay , (int16_t)Triangle.bx , (int16_t)Triangle.by , color , BuffNum);
	GFX_DrawUniLine((int16_t)Triangle.bx , (int16_t)Triangle.by , (int16_t)Triangle.cx , (int16_t)Triangle.cy , color , BuffNum);
	GFX_DrawUniLine((int16_t)Triangle.cx , (int16_t)Triangle.cy , (int16_t)Triangle.ax , (int16_t)Triangle.ay , color , BuffNum);
}


//--------------------------------------------------------------
// Draw a Filled Triangle.
// Triangle	- the triangle points.
// incolor	- Fill color of the triangle.
// outcolor	- Border color of the triangle.
//--------------------------------------------------------------
void GFX_Draw_Full_Triangle(TriPoint Triangle, uint16_t incolor, uint16_t outcolor, uint8_t BuffNum)
{
	float ma, mb, mc    ; //'gradient of the lines
	float start, finish ; //'draw a line from start to finish!
	float tempspace     ; //'temporary storage for swapping values...
	double x1,x2,x3      ;
	double y1,y2,y3      ;
	int16_t n           ;

	//' need to sort out ay, by and cy into order.. highest to lowest
	//'
	if(Triangle.ay < Triangle.by)
	{
		//'swap x's
		tempspace = Triangle.ax;
		Triangle.ax = Triangle.bx;
		Triangle.bx = tempspace;

		//'swap y's
		tempspace = Triangle.ay;
		Triangle.ay = Triangle.by;
		Triangle.by = tempspace;
	}

	if(Triangle.ay < Triangle.cy)
	{
		//'swap x's
		tempspace = Triangle.ax;
		Triangle.ax = Triangle.cx;
		Triangle.cx = tempspace;

		//'swap y's
		tempspace = Triangle.ay;
		Triangle.ay = Triangle.cy;
		Triangle.cy = tempspace;
	}

	if(Triangle.by < Triangle.cy)
	{
		//'swap x's
		tempspace = Triangle.bx;
		Triangle.bx = Triangle.cx;
		Triangle.cx = tempspace;

		//'swap y's
		tempspace = Triangle.by;
		Triangle.by = Triangle.cy;
		Triangle.cy = tempspace;
	}

	//' Finally - copy the values in order...

	x1 = Triangle.ax; x2 = Triangle.bx; x3 = Triangle.cx;
	y1 = Triangle.ay; y2 = Triangle.by; y3 = Triangle.cy;

	//'bodge if y coordinates are the same
	if(y1 == y2)  y2 = y2 + 0.01;
	if(y2 == y3)  y3 = y3 + 0.01;
	if(y1 == y3)  y3 = y3 + 0.01;

	ma = (x1 - x2) / (y1 - y2);
	mb = (x3 - x2) / (y2 - y3);
	mc = (x3 - x1) / (y1 - y3);

	//'from y1 to y2
	for(n = 0;n >= (y2 - y1);n--)
	{
		start = n * mc;
		finish = n * ma;
		GFX_DrawUniLine((int16_t)(x1 - start), (int16_t)(n + y1), (int16_t)(x1 + finish), (int16_t)(n + y1), incolor , BuffNum);
	}


	//'and from y2 to y3

	for(n = 0;n >= (y3 - y2);n--)
	{
		start = n * mc;
		finish = n * mb;
		GFX_DrawUniLine((int16_t)(x1 - start - ((y2 - y1) * mc)), (int16_t)(n + y2), (int16_t)(x2 - finish), (int16_t)(n + y2), incolor , BuffNum);
	}

	// draw the border color triangle
	GFX_Draw_Triangle(Triangle,outcolor,BuffNum);
}


// Displays an Ellipse.
// Xpos: specifies the X position
// Ypos: specifies the Y position
// Radius: specifies Radius.
// Radius2: specifies Radius2.
// Color: specifies the Color to use for draw the Border from the Ellipse.
// BuffNum: specifies the Layer to use.
void GFX_DrawEllipse(int16_t Xpos, int16_t Ypos, uint16_t Radius, uint16_t Radius2, uint16_t Color, uint8_t BuffNum)
{
	int x = -Radius, y = 0, err = 2-2*Radius, e2;
	float K = 0, rad1 = 0, rad2 = 0;

	rad1 = Radius;
	rad2 = Radius2;

	if (Radius > Radius2)
	{
		do {
			K = (float)(rad1/rad2);
			GFX_SetPixel(Xpos-x,Ypos+(uint16_t)(y/K),Color,BuffNum);
			GFX_SetPixel(Xpos+x,Ypos+(uint16_t)(y/K),Color,BuffNum);
			GFX_SetPixel(Xpos+x,Ypos-(uint16_t)(y/K),Color,BuffNum);
			GFX_SetPixel(Xpos-x,Ypos-(uint16_t)(y/K),Color,BuffNum);

			e2 = err;
			if (e2 <= y) {
				err += ++y*2+1;
				if (-x == y && e2 <= x) e2 = 0;
			}
			if (e2 > x) err += ++x*2+1;
		}
		while (x <= 0);
	}
	else
	{
		y = -Radius2;
		x = 0;
		do {
			K = (float)(rad2/rad1);
			GFX_SetPixel(Xpos-(uint16_t)(x/K),Ypos+y,Color,BuffNum);
			GFX_SetPixel(Xpos+(uint16_t)(x/K),Ypos+y,Color,BuffNum);
			GFX_SetPixel(Xpos+(uint16_t)(x/K),Ypos-y,Color,BuffNum);
			GFX_SetPixel(Xpos-(uint16_t)(x/K),Ypos-y,Color,BuffNum);

			e2 = err;
			if (e2 <= x) {
				err += ++x*2+1;
				if (-y == x && e2 <= y) e2 = 0;
			}
			if (e2 > y) err += ++y*2+1;
		}
		while (y <= 0);
	}
}


// Draw a full ellipse.
// Xpos: specifies the X position
// Ypos: specifies the Y position
// Radius: minor radius of ellipse.
// Radius2: major radius of ellipse.
// FillColor  : specifies the Color to use for Fill the Ellipse.
// BorderColor: specifies the Color to use for draw the Border from the Ellipse.
// BuffNum: specifies the Layer to use.
void GFX_DrawFullEllipse(int16_t Xpos, int16_t Ypos, uint16_t Radius, uint16_t Radius2, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum)
{
	int x = -Radius, y = 0, err = 2-2*Radius, e2;
	float K = 0, rad1 = 0, rad2 = 0;

	rad1 = Radius;
	rad2 = Radius2;

	if (Radius > Radius2)
	{
		do
		{
			K = (float)(rad1/rad2);
			GFX_DrawLine((Xpos+x), (Ypos-(uint16_t)(y/K)), (2*(uint16_t)(y/K) + 1), LCD_DIR_VERTICAL,FillColor,BuffNum);
			GFX_DrawLine((Xpos-x), (Ypos-(uint16_t)(y/K)), (2*(uint16_t)(y/K) + 1), LCD_DIR_VERTICAL,FillColor,BuffNum);

			e2 = err;
			if (e2 <= y)
			{
				err += ++y*2+1;
				if (-x == y && e2 <= x) e2 = 0;
			}
			if (e2 > x) err += ++x*2+1;

		}
		while (x <= 0);
	}
	else
	{
		y = -Radius2;
		x = 0;
		do
		{
			K = (float)(rad2/rad1);
			GFX_DrawLine((Xpos-(uint16_t)(x/K)), (Ypos+y), (2*(uint16_t)(x/K) + 1), LCD_DIR_HORIZONTAL,FillColor,BuffNum);
			GFX_DrawLine((Xpos-(uint16_t)(x/K)), (Ypos-y), (2*(uint16_t)(x/K) + 1), LCD_DIR_HORIZONTAL,FillColor,BuffNum);

			e2 = err;
			if (e2 <= x)
			{
				err += ++x*2+1;
				if (-y == x && e2 <= y) e2 = 0;
			}
			if (e2 > y) err += ++y*2+1;
		}
		while (y <= 0);
	}
	GFX_DrawEllipse(Xpos,Ypos,Radius,Radius2,BorderColor,BuffNum);
}


// Open a Sprite file and record all data to SDRAM Buffer
// name				: name of the file with the full path , ex: "b:/file.ext"
// SpriteStart		: First Sprite number (so you can load more than one sprite file)
// Returned Values: 0 = no error
//					3 = File open error
uint8_t GFX_Load_Sprite(const char* name,uint16_t SpriteStart)
{
	// Open and read a file with Sprites
	//
	// Sprite file format:
	// nn                       : Number of Sprite in File
	//
	// nn                       : First Sprite Wide (16bits)
	// nn                       : First Sprite Height (16bits)
	// nn,nn,nn,nn,nn ...       : 32 x 32 16bits pixels.
	// nn                       : Second Sprite Wide (16bits)
	// nn                       : Second Sprite Height (16bits)
	// nn,nn,nn,nn,nn ...       : 32 x 32 16bits pixels.

	// MSB and LSB have to be inverted (LSB first)

	uint32_t	spr_address	= (SpriteStart * GFX_SPRITE_LENGTH );	// SpriteStart address offset in memory
	int			fn;
	char		b1,b2;
	uint8_t		cntw,cnth;
	uint16_t	sprnumber = 0;
	uint16_t	sprcounter = 0;

	fn = FindFreeFileNbr();

	// File to read
	MMfopen(name, "r", fn);
	if(MMerrno) return 3;

	// Read first the number of Sprite in file
	b1 = MMfgetc(fn);			// LSB wide
	b2 = MMfgetc(fn);			// MSB wide
	sprnumber = (b2 << 8) + b1;

	for(sprcounter=0;sprcounter<sprnumber;sprcounter++) {
		// Read the Sprite wide and height
		b1 = MMfgetc(fn);			// LSB wide
		b2 = MMfgetc(fn);			// MSB wide
		SpriteMemory[spr_address] = (b2 << 8) + b1;
		spr_address++;
		b1 = MMfgetc(fn);			// LSB height
		b2 = MMfgetc(fn);			// MSB height
		SpriteMemory[spr_address] = (b2 << 8) + b1;
		spr_address++;
		// Now we read the 32 x 32 pixel block
		for(cnth=0;cnth<32;cnth++)
			for(cntw=0;cntw<32;cntw++)
			{
				b1 = MMfgetc(fn);			// LSB pixel
				b2 = MMfgetc(fn);			// MSB pixel
				SpriteMemory[spr_address] = (b2 << 8) + b1;
				spr_address++;
			}

	}
	MMfclose(fn);
	return 0;
}


// Open a Map file and record all data to SDRAM Buffer
// name		: name of the file with the full path , ex: "b:/file.ext"
// MapNum	: Map Number
// Returned Values: 0 = no error
//					3 = File open error
//					11= Map size is too big for the allocated Buffer
uint8_t GFX_Load_Map(const char* name,uint8_t MapNum)
{
	// Map file format:
	// H,L                      : Hi and Low byte from the Map Width
	// H,L                      : Hi and Low byte from the Map Height
	// H,L,H,L,H ...       		: Hi and Low byte from each pixel color
	// Hi and Low have to be inverted (LSB first)

	uint32_t	map_addr	= 0;	// Map address offset in memory
    int 		fn;
	char		b1,b2;
	uint16_t	cntw,cnth;

	Map_Width				= 0;
	Map_Height				= 0;

    fn = FindFreeFileNbr();

    // File to read
    MMfopen(name, "r", fn);
    if(MMerrno) return 3;

	// Read the Map wide and height
	b1 = MMfgetc(fn);			// LSB wide
	b2 = MMfgetc(fn);			// MSB wide
	Map_Width = (b2 << 8) + b1;
	b1 = MMfgetc(fn);			// LSB height
	b2 = MMfgetc(fn);			// MSB height
	Map_Height = (b2 << 8) + b1;

	// Check if the Map size fit in the Map memory
    if((Map_Width * Map_Height * 2) > GFX_MAP_LENGTH)
    	return 11;	// Map too big for the Map buffer

    //Here we go for read all Map pixel data
	for(cnth=0;cnth<Map_Height;cnth++)
		for(cntw=0;cntw<Map_Width;cntw++)
		{
			b1 = MMfgetc(fn);			// LSB pixel
			b2 = MMfgetc(fn);			// MSB pixel
			MapMemory[map_addr] = (b2 << 8) + b1;
			map_addr++;
		}
    MMfclose(fn);
	return 0;
}

// Copy the Game Map to one of the video buffer
// StartX	: Upper left Corner from where we start to copy the map.
// StartY	:
// Width	: Width in Pixels.
// Height	: Height in Pixels.
// DestX	: Upper left Destination Corner.
// DestY	:
// GFX_Layer: Layer number where we copy the Map data
// showtrans: 0 = Show the transparent color , other = Don't show the transparent color
void GFX_Show_Map_DMA2D(int16_t StartX, int16_t StartY,uint16_t Width,uint16_t Height,int16_t DestX, int16_t DestY, uint8_t GFX_Layer, uint8_t showtrans)
{
	static DMA2D_HandleTypeDef hDma2dHandler;
	uint32_t	activ_buffer;
	uint32_t	source_address = 0;

	ClipMapScreen MapClip;

	MapClip = GFX_Map_Clip(StartX, StartY, DestX , DestY , Width , Height);
	if((MapClip.Dest_w == 0) || (MapClip.Dest_h == 0)) return;


	// Compute the Source address
	source_address 	= (Map_Width * MapClip.Src_y1) + MapClip.Src_x1;

	if(GFX_Layer==0) activ_buffer = (uint32_t)(GFX_FRAME_BUFFER+(((LCD_MAXX * MapClip.Dest_y1) + MapClip.Dest_x1)*2));
	if(GFX_Layer==1) activ_buffer = (uint32_t)(GFX_FRAME_BUFFER + BUFFER_OFFSET+(((LCD_MAXX * MapClip.Dest_y1) +  MapClip.Dest_x1)*2));
	if(GFX_Layer==2) activ_buffer = (uint32_t)(GFX_FRAME_BUFFER + (BUFFER_OFFSET * 2)+(((LCD_MAXX * MapClip.Dest_y1) +  MapClip.Dest_x1)*2));
	if(GFX_Layer>2) return;

	if(showtrans == 0)
	{ // We show the transparent color

	  hDma2dHandler.Init.Mode         = DMA2D_M2M_PFC;
	  hDma2dHandler.Init.ColorMode    = DMA2D_RGB565;
	  hDma2dHandler.Init.OutputOffset = LCD_MAXX-MapClip.Dest_w;

	  // bug workaround (layer-0 bug)
	  // set layer always to 1
	  hDma2dHandler.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
	  hDma2dHandler.LayerCfg[1].InputAlpha = 0xFF;
	  hDma2dHandler.LayerCfg[1].InputColorMode = CM_ARGB1555; // color-Mode : ARGB1555
	  hDma2dHandler.LayerCfg[1].InputOffset = Map_Width - MapClip.Dest_w;
	  hDma2dHandler.Instance = DMA2D;

	  // DMA2D Initialization
	  if(HAL_DMA2D_Init(&hDma2dHandler) == HAL_OK) {
	    if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, 1) == HAL_OK) {
	      if (HAL_DMA2D_Start(&hDma2dHandler, (uint32_t)&MapMemory[source_address], activ_buffer, MapClip.Dest_w, MapClip.Dest_h) == HAL_OK)
	      {
	        HAL_DMA2D_PollForTransfer(&hDma2dHandler, 10);
	      }
	    }
	  }
	  return;
	}

	// copy MAP into VideoBuffer (with ALPHA-channel)
	hDma2dHandler.Init.Mode         = DMA2D_M2M_BLEND;
	hDma2dHandler.Init.ColorMode    = DMA2D_RGB565;
	hDma2dHandler.Init.OutputOffset = LCD_MAXX-MapClip.Dest_w;

	// Foreground (MAP)
	hDma2dHandler.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
	hDma2dHandler.LayerCfg[1].InputAlpha = 0xFF;
	hDma2dHandler.LayerCfg[1].InputColorMode = CM_ARGB1555; // color-Mode : ARGB1555
	hDma2dHandler.LayerCfg[1].InputOffset = Map_Width - MapClip.Dest_w;

	// Background (VideoBuffer)
	hDma2dHandler.LayerCfg[0].AlphaMode = DMA2D_NO_MODIF_ALPHA;
	hDma2dHandler.LayerCfg[0].InputAlpha = 0xFF;
	hDma2dHandler.LayerCfg[0].InputColorMode = CM_RGB565; // color-Mode : RGB565
	hDma2dHandler.LayerCfg[0].InputOffset = LCD_MAXX-MapClip.Dest_w;

	hDma2dHandler.Instance = DMA2D;

	// DMA2D Initialization
	if(HAL_DMA2D_Init(&hDma2dHandler) == HAL_OK) {
		if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, 1) == HAL_OK) {
			if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, 0) == HAL_OK) {
				if (HAL_DMA2D_BlendingStart(&hDma2dHandler, (uint32_t)&MapMemory[source_address], activ_buffer, activ_buffer, MapClip.Dest_w, MapClip.Dest_h) == HAL_OK)
				{
					HAL_DMA2D_PollForTransfer(&hDma2dHandler, 10);
				}
			}
		}
	}
}

// Move a part of the picture
// StartX	: Upper left Corner from where we start to copy the picture.
// StartY	:
// Width	: Width in Pixels.
// Height	: Height in Pixels.
// DestX	: Upper left Destination Corner.
// DestY	:
// GFX_Layer: Layer number where we are working
void GFX_Blit_DMA2D(int16_t StartX, int16_t StartY,uint16_t Width,uint16_t Height,int16_t DirX, int16_t DirY, uint8_t Roll, uint8_t DST_Layer)
{
	static DMA2D_HandleTypeDef hDma2dHandler;
	uint32_t	activ_buffer;
	uint32_t	source_address = 0;
	ClipMapScreen BlitClip;

	// Copy working buffer to Destination layer
	GFX_Layer_Copy(2,DST_Layer);

	BlitClip = GFX_Blit_Clip(StartX, StartY, StartX + DirX , StartY + DirY , Width , Height);
	if((BlitClip.Dest_w == 0) || (BlitClip.Dest_h == 0)) return;

	// If we roll the graphics we have to copy the part we hide to the place we take free
	if(Roll != 0){
		// to do
	}
	else{
		// Nothing to roll , we put black color to the place we take free in the working layer
		GFX_DrawFullRect(StartX,StartY,Width,Height,0,0,2);
	}

	// Compute the Source address (Destination layer)
	if(DST_Layer==0) source_address = (uint32_t)(GFX_FRAME_BUFFER+(((LCD_MAXX * BlitClip.Src_y1) + BlitClip.Src_x1)*2));
	if(DST_Layer==1) source_address = (uint32_t)(GFX_FRAME_BUFFER + BUFFER_OFFSET+(((LCD_MAXX * BlitClip.Src_y1) +  BlitClip.Src_x1)*2));
	if(DST_Layer>1) return;

	// Compute the Destination address (working buffer)
	activ_buffer 	= (uint32_t)(GFX_FRAME_BUFFER + (BUFFER_OFFSET * 2)+(((LCD_MAXX * BlitClip.Dest_y1) +  BlitClip.Dest_x1)*2));

	// Move the Graphics to working buffer
	hDma2dHandler.Init.Mode         = DMA2D_M2M_PFC;
	hDma2dHandler.Init.ColorMode    = DMA2D_RGB565;
	hDma2dHandler.Init.OutputOffset = LCD_MAXX-BlitClip.Dest_w;

	// bug workaround (layer-0 bug)
	// set layer always to 1
	hDma2dHandler.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
	hDma2dHandler.LayerCfg[1].InputAlpha = 0xFF;
	hDma2dHandler.LayerCfg[1].InputColorMode = CM_RGB565; // color-Mode : RGB565
	hDma2dHandler.LayerCfg[1].InputOffset = LCD_MAXX - BlitClip.Dest_w;
	hDma2dHandler.Instance = DMA2D;

	// DMA2D Initialization
	if(HAL_DMA2D_Init(&hDma2dHandler) == HAL_OK) {
		if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, 1) == HAL_OK) {
			if (HAL_DMA2D_Start(&hDma2dHandler, source_address, activ_buffer, BlitClip.Dest_w, BlitClip.Dest_h) == HAL_OK)
			{
				HAL_DMA2D_PollForTransfer(&hDma2dHandler, 10);
			}
		}
	}

	// Copy result from the working buffer to Destination layer
	GFX_Layer_Copy(2,DST_Layer);
}


//--------------------------------------------------------------
// Show a Sprite on Screen or copy it in Video Buffer
// num     			- Sprite number to Show
// x       			- X coordinate from the Left Upper corner of the Sprite.
// y       			- Y coordinate from the Left Upper corner of the Sprite.
// GFX_Layer		- Screen buffer number where we put the Sprite.
//--------------------------------------------------------------
void GFX_Sprite_Show_DMA2D(uint16_t Sprite_Num , int16_t x , int16_t y , uint8_t GFX_Layer)
{
	static DMA2D_HandleTypeDef hDma2dHandler;

	// Show the Sprite
	uint16_t w		=	0;
	uint16_t h		=	0;
	uint32_t addr	=	0;
	uint32_t activ_buffer;
	uint16_t dl , dh;
	ClipScreen SpriteClip;

	//Starting memory offset for this Sprite
	addr = Sprite_Num * (GFX_SPRITE_LENGTH / 2);
	// Sprite Width
	w = SpriteMemory[addr];
	addr++;
	// Sprite Height
	h = SpriteMemory[addr];
	addr++;

	dl = x + w;
	dh = y + h;
	// Test Screen Clipping
	SpriteClip = GFX_Rect_Clip(x,y,dl,dh);
	if((SpriteClip.w == 0) || (SpriteClip.h == 0)) return;

	if(GFX_Layer==0) activ_buffer = (uint32_t)(GFX_FRAME_BUFFER+(((LCD_MAXX * SpriteClip.y1) + SpriteClip.x1)*2));
	if(GFX_Layer==1) activ_buffer = (uint32_t)(GFX_FRAME_BUFFER + BUFFER_OFFSET+(((LCD_MAXX * SpriteClip.y1) + SpriteClip.x1)*2));
	if(GFX_Layer>1) return;


	// copy sprite into VideoBuffer (with ALPHA-channel)

	hDma2dHandler.Init.Mode         = DMA2D_M2M_BLEND;
	hDma2dHandler.Init.ColorMode    = DMA2D_RGB565;
	hDma2dHandler.Init.OutputOffset = LCD_MAXX-SpriteClip.w;

	// Foreground (Sprite)
	hDma2dHandler.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
	hDma2dHandler.LayerCfg[1].InputAlpha = 0xFF;
	hDma2dHandler.LayerCfg[1].InputColorMode = CM_ARGB1555; // color-Mode : ARGB1555
	hDma2dHandler.LayerCfg[1].InputOffset = 32-SpriteClip.w;

	// Background (VideoBuffer)
	hDma2dHandler.LayerCfg[0].AlphaMode = DMA2D_NO_MODIF_ALPHA;
	hDma2dHandler.LayerCfg[0].InputAlpha = 0xFF;
	hDma2dHandler.LayerCfg[0].InputColorMode = CM_RGB565; // color-Mode : RGB565
	hDma2dHandler.LayerCfg[0].InputOffset = LCD_MAXX-SpriteClip.w;

	hDma2dHandler.Instance = DMA2D;

	// DMA2D Initialization
	if(HAL_DMA2D_Init(&hDma2dHandler) == HAL_OK) {
		if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, 1) == HAL_OK) {
			if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, 0) == HAL_OK) {
				if (HAL_DMA2D_BlendingStart(&hDma2dHandler, (uint32_t)&SpriteMemory[addr], activ_buffer, activ_buffer, SpriteClip.w, SpriteClip.h) == HAL_OK)
				{
					HAL_DMA2D_PollForTransfer(&hDma2dHandler, 10);
				}
			}
		}
	}
}

//  Displays a Rectangle at a given Angle.
//  CenterX			: specifies the center of the Rectangle.
//	CenterY
//  Width,Height 	: specifies the size of the Rectangle.
//	Angle			: specifies the angle for drawing the rectangle
//  Color	    	: specifies the Color to use for Fill the Rectangle.
//  BuffNum      	: specifies the Video Layer to use.
void GFX_DrawQuad(int16_t CenterX, int16_t CenterY, int16_t Width, int16_t Height, int16_t Angle, uint16_t Color, uint8_t BuffNum)
{
	int16_t	px[4],py[4];
	float	l;
	float	raddeg = 3.14159 / 180;
	float	w2 = Width / 2.0;
	float	h2 = Height / 2.0;
	float	vec = (w2*w2)+(h2*h2);
	float	w2l;
	float	pangle[4];

	l = sqrtf(vec);
	w2l = w2 / l;
	pangle[0] = acosf(w2l) / raddeg;
	pangle[1] = 180.0 - (acosf(w2l) / raddeg);
	pangle[2] = 180.0 + (acosf(w2l) / raddeg);
	pangle[3] = 360.0 - (acosf(w2l) / raddeg);
	px[0] = (int16_t)(calcco[((int16_t)(pangle[0]) + Angle) % 360] * l + CenterX);
	py[0] = (int16_t)(calcsi[((int16_t)(pangle[0]) + Angle) % 360] * l + CenterY);
	px[1] = (int16_t)(calcco[((int16_t)(pangle[1]) + Angle) % 360] * l + CenterX);
	py[1] = (int16_t)(calcsi[((int16_t)(pangle[1]) + Angle) % 360] * l + CenterY);
	px[2] = (int16_t)(calcco[((int16_t)(pangle[2]) + Angle) % 360] * l + CenterX);
	py[2] = (int16_t)(calcsi[((int16_t)(pangle[2]) + Angle) % 360] * l + CenterY);
	px[3] = (int16_t)(calcco[((int16_t)(pangle[3]) + Angle) % 360] * l + CenterX);
	py[3] = (int16_t)(calcsi[((int16_t)(pangle[3]) + Angle) % 360] * l + CenterY);
	// here we draw the quad
	GFX_DrawUniLine(px[0],py[0],px[1],py[1],Color,BuffNum);
	GFX_DrawUniLine(px[1],py[1],px[2],py[2],Color,BuffNum);
	GFX_DrawUniLine(px[2],py[2],px[3],py[3],Color,BuffNum);
	GFX_DrawUniLine(px[3],py[3],px[0],py[0],Color,BuffNum);
}

//  Displays a filled Rectangle at a given Angle.
//  CenterX			: specifies the center of the Rectangle.
//	CenterY
//  Width,Height 	: specifies the size of the Rectangle.
//	Angle			: specifies the angle for drawing the rectangle
//  FillColor    	: specifies the Color to use for Fill the Rectangle.
//  BorderColor  	: specifies the Color to use for draw the Border from the Rectangle.
//  BuffNum      	: specifies the Video Layer to use.
void GFX_DrawFullQuad(int16_t CenterX, int16_t CenterY, int16_t Width, int16_t Height, int16_t Angle, uint16_t FillColor, uint16_t BorderColor, uint8_t BuffNum)
{
	int16_t	px[4],py[4];
	float	l;
	float	raddeg = 3.14159 / 180;
	float	w2 = Width / 2.0;
	float	h2 = Height / 2.0;
	float	vec = (w2*w2)+(h2*h2);
	float	w2l;
	float	pangle[4];
	TriPoint t1,t2;

	l = sqrtf(vec);
	w2l = w2 / l;
	pangle[0] = acosf(w2l) / raddeg;
	pangle[1] = 180.0 - (acosf(w2l) / raddeg);
	pangle[2] = 180.0 + (acosf(w2l) / raddeg);
	pangle[3] = 360.0 - (acosf(w2l) / raddeg);
	px[0] = (int16_t)(calcco[((int16_t)(pangle[0]) + Angle) % 360] * l + CenterX);
	py[0] = (int16_t)(calcsi[((int16_t)(pangle[0]) + Angle) % 360] * l + CenterY);
	px[1] = (int16_t)(calcco[((int16_t)(pangle[1]) + Angle) % 360] * l + CenterX);
	py[1] = (int16_t)(calcsi[((int16_t)(pangle[1]) + Angle) % 360] * l + CenterY);
	px[2] = (int16_t)(calcco[((int16_t)(pangle[2]) + Angle) % 360] * l + CenterX);
	py[2] = (int16_t)(calcsi[((int16_t)(pangle[2]) + Angle) % 360] * l + CenterY);
	px[3] = (int16_t)(calcco[((int16_t)(pangle[3]) + Angle) % 360] * l + CenterX);
	py[3] = (int16_t)(calcsi[((int16_t)(pangle[3]) + Angle) % 360] * l + CenterY);
	// We draw 2 filled triangle for made the quad
	// To be uniform we have to use only the Fillcolor
	t1.ax = px[0] ; t1.ay = py[0];
	t1.bx = px[1] ; t1.by = py[1];
	t1.cx = px[2] ; t1.cy = py[2];
	t2.ax = px[2] ; t2.ay = py[2];
	t2.bx = px[3] ; t2.by = py[3];
	t2.cx = px[0] ; t2.cy = py[0];
	GFX_Draw_Full_Triangle(t1,FillColor,FillColor,BuffNum);
	GFX_Draw_Full_Triangle(t2,FillColor,FillColor,BuffNum);
	// here we draw the BorderColor from the quad
	GFX_DrawUniLine(px[0],py[0],px[1],py[1],BorderColor,BuffNum);
	GFX_DrawUniLine(px[1],py[1],px[2],py[2],BorderColor,BuffNum);
	GFX_DrawUniLine(px[2],py[2],px[3],py[3],BorderColor,BuffNum);
	GFX_DrawUniLine(px[3],py[3],px[0],py[0],BorderColor,BuffNum);
}

void GFX_DrawPolygon(uint8_t PolyNum, uint16_t PointCount, uint16_t outcolor, uint8_t BuffNum){
	uint16_t pts = 0;

	GFX_DrawUniLine(PolySet[PolyNum].Pts[0].x, PolySet[PolyNum].Pts[0].y, PolySet[PolyNum].Pts[PointCount - 1].x, PolySet[PolyNum].Pts[PointCount - 1].y, outcolor, BuffNum);
	for (pts = 0; pts < PointCount - 1 ; pts++)
		GFX_DrawUniLine(PolySet[PolyNum].Pts[pts].x, PolySet[PolyNum].Pts[pts].y, PolySet[PolyNum].Pts[pts + 1].x, PolySet[PolyNum].Pts[pts + 1].y, outcolor, BuffNum);
}

void GFX_DrawFullPolygon(uint8_t PolyNum, uint16_t PointCount, uint16_t incolor, uint16_t outcolor, uint8_t BuffNum){
	int n,i,j,k,dy,dx;
	int y,temp;
	int a[MaxPolyPoint][2],xi[MaxPolyPoint];
	float slope[MaxPolyPoint];

	n = PointCount;

	for(i=0;i<n;i++)
	{
		a[i][0] = PolySet[PolyNum].Pts[i].x;
		a[i][1] = PolySet[PolyNum].Pts[i].y;
	}

	a[PointCount][0]=a[0][0];
	a[PointCount][1]=a[0][1];

	for(i=0;i<n;i++)
	{
		dy=a[i+1][1]-a[i][1];
		dx=a[i+1][0]-a[i][0];

		if(dy==0) slope[i]=1.0;
		if(dx==0) slope[i]=0.0;

		if((dy!=0)&&(dx!=0)) /*- calculate inverse slope -*/
		{
			slope[i]=(float) dx/dy;
		}
	}

	for(y=0;y< 480;y++)
	{
		k=0;
		for(i=0;i<n;i++)
		{

			if( ((a[i][1]<=y)&&(a[i+1][1]>y))||
					((a[i][1]>y)&&(a[i+1][1]<=y)))
			{
				xi[k]=(int)(a[i][0]+slope[i]*(y-a[i][1]));
				k++;
			}
		}

		for(j=0;j<k-1;j++) /*- Arrange x-intersections in order -*/
			for(i=0;i<k-1;i++)
			{
				if(xi[i]>xi[i+1])
				{
					temp=xi[i];
					xi[i]=xi[i+1];
					xi[i+1]=temp;
				}
			}

		for(i=0;i<k;i+=2)
		{
			GFX_DrawUniLine(xi[i],y,xi[i+1]+1,y, incolor, BuffNum);
		}

	}

	// Draw the polygon outline
	GFX_DrawPolygon(PolyNum, PointCount, outcolor, BuffNum);
}

void GFX_RotatePolygon(uint8_t PolyNum, uint16_t PointCount, int16_t Angle, uint16_t incolor, uint16_t outcolor, uint8_t Filled, uint8_t BuffNum)
{
	Point2D 	SavePts[MaxPolyPoint];
	uint16_t	n = 0;
	int16_t		cx,cy;
	float		raddeg = 3.14159 / 180;
	float		angletmp;
	float		tosquare;
	float		ptsdist;

	cx = PolySet[PolyNum].Center.x;
	cy = PolySet[PolyNum].Center.y;

	for(n = 0 ; n < PointCount ; n++)
	{
		// Save Original points coordinates
		SavePts[n] = PolySet[PolyNum].Pts[n];
		// Rotate and save all points
		tosquare = ((PolySet[PolyNum].Pts[n].x - cx) * (PolySet[PolyNum].Pts[n].x - cx)) + ((PolySet[PolyNum].Pts[n].y - cy) * (PolySet[PolyNum].Pts[n].y - cy));
		ptsdist  = sqrtf(tosquare);
		angletmp = atan2f(PolySet[PolyNum].Pts[n].y - cy,PolySet[PolyNum].Pts[n].x - cx) / raddeg;
		PolySet[PolyNum].Pts[n].x = (int16_t)((cosf((angletmp + Angle) * raddeg) * ptsdist) + cx);
		PolySet[PolyNum].Pts[n].y = (int16_t)((sinf((angletmp + Angle) * raddeg) * ptsdist) + cy);
	}
	if(Filled == 1)
		GFX_DrawFullPolygon(PolyNum, PointCount, incolor, outcolor, BuffNum);
	else
		GFX_DrawPolygon(PolyNum, PointCount, outcolor, BuffNum);

	// Get the original points back;
	for(n = 0 ; n < PointCount ; n++)
		PolySet[PolyNum].Pts[n] = SavePts[n];
}

//--------------------------------------------------------------
// kopiert aus einem Image  (aus dem Flash)
// ein Teilrechteck ins Grafik-RAM (per DMA2D)
// -> Image muss mit &-Operator uebergeben werden
// Falls Fehler bei den Koordinaten wird nichts gezeichnet
//--------------------------------------------------------------
void GFX_CopyImgDMA(UB_Image *img, DMA2D_Koord koord)
{
  static DMA2D_HandleTypeDef hDma2dHandler;
  uint32_t  dest_address = 0;
  uint32_t  source_address = 0;
  uint32_t offset;
  uint32_t  picture_width;
  uint32_t  picture_height;
  uint32_t w,h;

  // Ziel Adresse im Display RAM
  dest_address = LCD_CurrentFrameBuffer + 2*(LCD_MAXX*koord.dest_yp + koord.dest_xp);

  picture_width=img->width;
  picture_height=img->height;

  // check auf Limit
  if(koord.source_w==0) return;
  if(koord.source_h==0) return;
  if(koord.source_xp+koord.source_w>picture_width) return;
  if(koord.source_yp+koord.source_h>picture_height) return;
  if(koord.dest_xp+koord.source_w>LCD_MAXX) return;
  if(koord.dest_yp+koord.source_h>LCD_MAXY) return;

  // Quell Adresse vom Bild
  offset=(picture_width*koord.source_yp + koord.source_xp);
  source_address  = (uint32_t)&img->table[offset];

  w=koord.source_w;
  h=koord.source_h;

  hDma2dHandler.Init.Mode         = DMA2D_M2M;
  hDma2dHandler.Init.ColorMode    = DMA2D_RGB565;
  hDma2dHandler.Init.OutputOffset = LCD_MAXX-w;

  // bug workaround (layer-0 bug)
  // set layer always to 1
  hDma2dHandler.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
  hDma2dHandler.LayerCfg[1].InputAlpha = 0xFF;
  hDma2dHandler.LayerCfg[1].InputColorMode = CM_RGB565;
  hDma2dHandler.LayerCfg[1].InputOffset = picture_width-koord.source_w;
  hDma2dHandler.Instance = DMA2D;

  // DMA2D Initialization
  if(HAL_DMA2D_Init(&hDma2dHandler) == HAL_OK) {
    if(HAL_DMA2D_ConfigLayer(&hDma2dHandler, 1) == HAL_OK) {
      if (HAL_DMA2D_Start(&hDma2dHandler, source_address, dest_address, w, h) == HAL_OK)
      {
        HAL_DMA2D_PollForTransfer(&hDma2dHandler, 10);
      }
    }
  }
}

