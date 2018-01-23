// FPDLL.cpp : Defines the exported functions for the DLL application.
// Copyright 2012 Denver Informatics
// http://www.denverinformatics.com


#include "stdafx.h"

// getUnipolar
//
int getUnipolar(struct plot* sp, unsigned char* buff, int pointsOffset)
{
	const unsigned char c = buff[sp->idel + pointsOffset];
	if (sp->type == FP_SP_DATA_BINARY  ||  (sp->type == FP_SP_DATA_BIPOLAR_BINARY && sp->irec == FP_SP_RECTIFY_OFF))
		return  c;

	signed char s = 0;

	if (sp->type == FP_SP_DATA_TWOS_COMPLEMENT)
		s = static_cast<signed char>(c);
	else
		s = static_cast<int>(c) - 128;

	if (sp->irec == FP_SP_RECTIFY_ON)
		return  min(127, abs(s)) * 2;
	else
		return  s + 128;
}


// drawpoint
//
void drawpoint(int ipm, struct plot* sp, unsigned char* bitmap8bit, int bmwidth, int bmheight, int x, int y )
{
	if (y >= sp->lolim  &&  y <= sp->hilim)
		if (ipm == FP_PLOT_MODE_ACCUMULATE)
			bitmap8bit[bmwidth * y + x] = sp->color;
		else
			bitmap8bit[bmwidth * y + x] ^= sp->color;
}


// drawline
//
void drawline(int ipm, struct plot* sp, unsigned char* bitmap8bit, int bmwidth, int bmheight, int x, int y, int height)
{
	for (int i = 0;  i < height;  i++)
		drawpoint(ipm, sp, bitmap8bit, bmwidth, bmheight, x, y+i);
}


// plotline
//
void plotline(int ipm, struct plot* sp, unsigned char* bitmap8bit, int bmwidth, int bmheight, int x, int y, int height)
{
	sp->oldy[x] = sp->ishift < 0  ?  y << -sp->ishift  :  y >> sp->ishift;
	sp->oldn[x] = sp->ishift < 0  ?  height << -sp->ishift  :  height >> sp->ishift;

	drawline(ipm, sp, bitmap8bit, bmwidth, bmheight, sp->xoff + x, sp->yoff + sp->oldy[x], sp->oldn[x]);
}


// fplot
//
extern LIBSPEC void fplot(int* ipm, struct plot* sp, unsigned char* buff,
                          unsigned char* bitmap8bit, int bmwidth, int bmheight)
{
	if (*ipm == FP_PLOT_MODE_ERASE_AND_PLOT  ||  *ipm == FP_PLOT_MODE_ERASE_ONLY)
		for (int i = 0; i < sp->n; i++)
			drawline(*ipm, sp, bitmap8bit, bmwidth, bmheight, i + sp->xoff, sp->oldy[i] + sp->yoff, sp->oldn[i]);

	for (int j = 0; j < bmheight; j++)
		for (int i = 0; i < bmwidth; i++)
			if (bitmap8bit[j * bmwidth + i] != 0)
				*ipm = FP_PLOT_MODE_PLOT_ONLY;

	if (*ipm == FP_PLOT_MODE_ERASE_AND_PLOT  ||  *ipm == FP_PLOT_MODE_PLOT_ONLY  ||  *ipm == FP_PLOT_MODE_ACCUMULATE)
	{
		__int64 curx = 0;
		int prevy = 0, prevy2 = 0;
		int t = 0;
		const __int64 reciprocalscale = static_cast<__int64>(static_cast<double>(1LL << 32)
				* static_cast<double>(1LL << 32) / static_cast<double>(sp->iscale));

		for (int i = 0; i < sp->n; i++)
			if (sp->iscale >= (1LL << 32))
			{
				if (i == 0)
					prevy = getUnipolar(sp, buff, 0);

				const int x1 = curx >> 32;
				const int y1 = getUnipolar(sp, buff, x1);
				const int y = ((static_cast<__int64>(getUnipolar(sp, buff, x1+1) - y1)
				                * (curx & ((1LL << 32) - 1)))
				               >> 32) + y1;

				plotline(*ipm, sp, bitmap8bit, bmwidth, bmheight, i, min(prevy, y) + (y > prevy), abs(prevy - y) + (y == prevy));
				curx += reciprocalscale;
				prevy = y;
			}
			else
			{
				const int x1 = curx >> 32;
				int miny = 100000;
				int maxy = -100000;
				do
				{
					const int y = getUnipolar(sp, buff, t++);
					miny = min(miny, y);
					maxy = max(maxy, y);
					curx += sp->iscale;
				} while (curx >> 32  ==  x1);
				const int y1 = min(prevy2+1, miny);
				const int y2 = max(prevy-1, maxy);
				plotline(*ipm, sp, bitmap8bit, bmwidth, bmheight, x1, y1, y2-y1+1);
				prevy = miny;
				prevy2 = maxy;
			}
	}  // end if plotting

	if (*ipm == FP_PLOT_MODE_PLOT_ONLY)
		*ipm = FP_PLOT_MODE_ERASE_AND_PLOT;
}
