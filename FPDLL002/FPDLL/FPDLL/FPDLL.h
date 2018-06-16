// FPDLL.h
// Copyright 2012 Denver Informatics
// http://www.denverinformatics.com

#ifdef _COMPILING_FPDLL
    #define LIBSPEC __declspec(dllexport)
#else
    #define LIBSPEC __declspec(dllimport)
#endif


const int FP_PLOT_MODE_ERASE_ONLY     = 0;
const int FP_PLOT_MODE_ERASE_AND_PLOT = 1;
const int FP_PLOT_MODE_PLOT_ONLY      = 2;
const int FP_PLOT_MODE_ACCUMULATE     = 3;

const int FP_SP_RECTIFY_OFF           = 0;
const int FP_SP_RECTIFY_ON            = 1;

const int FP_SP_DATA_BINARY           = 0;
const int FP_SP_DATA_BIPOLAR_BINARY   = 1;
const int FP_SP_DATA_TWOS_COMPLEMENT  = 2;


struct plot
{
	unsigned __int64 iscale;
	int              ishift;
	int              n;
	int              xoff;
	int              yoff;
	int              lolim;
	int              hilim;
	int              color;
	int              idel;
	int              irec;
	int              type;
	int              oldn[1024];
    int              oldy[1024];
};

extern LIBSPEC void fplot(int* ipm, struct plot* sp, unsigned char* buff,
                          unsigned char* bitmap8bit, int bmwidth, int bmheight);

