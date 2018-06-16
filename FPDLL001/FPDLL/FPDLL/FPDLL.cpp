// FPDLL.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

extern LIBSPEC void fplot(int* ipm, struct plot* sp, unsigned char* buff,
                          unsigned char* bitmap8bit, int bmwidth, int bmheight)
{
	if (*ipm == FP_PLOT_MODE_ERASE_AND_PLOT  ||  *ipm == FP_PLOT_MODE_ERASE_ONLY)
		for (int i = 0; i < sp->n; i++)
			for (int j = 0; j < sp->oldn[i]; j++)
				bitmap8bit[bmwidth * (sp->oldy[i] + j) + i + sp->xoff] ^= sp->color;

	for (int i = 0; i < sp->n; i++)
	{
		unsigned char prevyraw = i == 0 ? buff[sp->idel] : buff[sp->idel + i - 1];
		int prevy = static_cast<signed char>(prevyraw) + 128;
		int cury  = static_cast<signed char>(buff[sp->idel + i]) + 128;
		sp->oldy[i] = min(prevy, cury) + sp->yoff;
		sp->oldn[i] = abs(prevy - cury) + 1;
		for (int j = 0; j < sp->oldn[i]; j++)
			bitmap8bit[bmwidth * (sp->oldy[i] + j) + i + sp->xoff] ^= sp->color;
	}

	if (*ipm == FP_PLOT_MODE_PLOT_ONLY)
		*ipm = FP_PLOT_MODE_ERASE_AND_PLOT;

	
}

