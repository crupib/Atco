/*******************************************************************
/**
/**  FastPlot Demonstration program -- Plot Sine and Cosine Waves on Screen
/**
/******************************************************************/




#include <math.h>
#include <types.h>
#include <fpx.h>
#include <fpkl.h>
#include <strplxkl.h>




/*****************/
/**             **/
/**  Constants  **/
/**             **/
/*****************/

#define	FALSE			0
#define	TRUE			1

#define	NUMBER_OF_WAVEFORMS	4
#define	SQUEEZE_FACTOR		1.02

#define	BUFFER_SINE		0
#define	BUFFER_VIDEO_SINE	1
#define	BUFFER_COSINE		2
#define	BUFFER_FFT		3




/***************/
/**           **/
/**  Globals  **/
/**           **/
/***************/

struct plot _far sp[ NUMBER_OF_WAVEFORMS ] = {
	{ 65536L,			/**  iscale:     1:1 plotting  **/
	  0,				/**  ishift:     data shift 0 bits to the right **/
	  512,				/**  n:          plot 512 data points  **/
	  52,				/**  nperstrip:  do 10 strips  **/
	  0,				/**  startpoint: initialize to 0  **/
	  0,				/**  stripdel:   initialize to 0  **/
	  66,				/**  xoff:       66 pixels from left edge of screen  **/
	  168,				/**  yoff:       168 pixels from bottom of screen to zero-line*/
	  40,				/**  lolim:      don't write pixels below line 40  **/
	  296,				/**  hilim:      don't write pixels above line 296  **/
	  2,				/**  color:      use color register 2  **/
	  0,				/**  idel:       start plotting from start of buffer  **/
	  FP_SP_RECTIFY_OFF,		/**  irec:       do not rectify data  **/
	  FP_SP_DATA_TWOS_COMPLEMENT,	/**  type:       Data in buffer is two's complement  **/
	  0,				/**  on:         reserved  **/
	  0L, },			/**  lastremainder: initialize to 0  **/

	{ 65536L,			/**  iscale:     1:1 plotting  **/
	  0,				/**  ishift:     data shift 0 bits to the right **/
	  512,				/**  n:          plot 512 data points  **/
	  52,				/**  nperstrip:  do 10 strips  **/
	  0,				/**  startpoint: initialize to 0  **/
	  0,				/**  stripdel:   initialize to 0  **/
	  66,				/**  xoff:       66 pixels from left edge of screen  **/
	  40,				/**  yoff:       168 pixels from bottom of screen to zero-line*/
	  40,				/**  lolim:      don't write pixels below line 40  **/
	  296,				/**  hilim:      don't write pixels above line 296  **/
	  3,				/**  color:      use color register 3  **/
	  0,				/**  idel:       start plotting from start of buffer  **/
	  FP_SP_RECTIFY_OFF,		/**  irec:       do not rectify data  **/
	  FP_SP_DATA_BINARY,         	/**  type:       Data in buffer is two's complement  **/
	  0,				/**  on:         reserved  **/
	  0L, },			/**  lastremainder: initialize to 0  **/

	{ 65536L,			/**  iscale:     1:1 plotting  **/
	  0,				/**  ishift:     data shift 0 bits to the right **/
	  512,				/**  n:          plot 512 data points  **/
	  52,				/**  nperstrip:  do 10 strips  **/
	  0,				/**  startpoint: initialize to 0  **/
	  0,				/**  stripdel:   initialize to 0  **/
	  66,				/**  xoff:       66 pixels from left edge of screen  **/
	  168,				/**  yoff:       168 pixels from bottom of screen to zero-line*/
	  40,				/**  lolim:      don't write pixels below line 40  **/
	  296,				/**  hilim:      don't write pixels above line 296  **/
	  5,				/**  color:      use color register 5  **/
	  0,				/**  idel:       start plotting from start of buffer  **/
	  FP_SP_RECTIFY_OFF,		/**  irec:       do not rectify data  **/
	  FP_SP_DATA_TWOS_COMPLEMENT,	/**  type:       Data in buffer is two's complement  **/
	  0,				/**  on:         reserved  **/
	  0L, },			/**  lastremainder: initialize to 0  **/

	{ 32768L,			/**  iscale:     1:1 plotting  **/
	  0,				/**  ishift:     data shift 0 bits to the right **/
	  512,				/**  n:          plot 512 data points  **/
	  52,				/**  nperstrip:  do 10 strips  **/
	  0,				/**  startpoint: initialize to 0  **/
	  0,				/**  stripdel:   initialize to 0  **/
	  66,				/**  xoff:       66 pixels from left edge of screen  **/
	  40,				/**  yoff:       168 pixels from bottom of screen to zero-line*/
	  40,				/**  lolim:      don't write pixels below line 40  **/
	  296,				/**  hilim:      don't write pixels above line 296  **/
	  6,				/**  color:      use color register 6  **/
	  0,				/**  idel:       start plotting from start of buffer  **/
	  FP_SP_RECTIFY_OFF,		/**  irec:       do not rectify data  **/
	  FP_SP_DATA_BINARY,         	/**  type:       Data in buffer is two's complement  **/
	  0,				/**  on:         reserved  **/
	  0L, },			/**  lastremainder: initialize to 0  **/
};                                                        

                    
signed char    _far  sine_buffer[2048];
unsigned char  _far  video_sine_buffer[2048];
signed char    _far  cosine_buffer[2048];
unsigned char  _far  fft_buffer[2048];

signed char    _far  fft_input_buffer[2048];

void *buffers[ NUMBER_OF_WAVEFORMS ] = {
	sine_buffer,
	video_sine_buffer,
	cosine_buffer,
	fft_buffer
};

float         _far  float_fft[1024];

int   squeeze = FALSE;
int   increase_video_filter = FALSE;

int   ipm[ NUMBER_OF_WAVEFORMS ] = {
	FP_PLOT_MODE_PLOT_ONLY,  FP_PLOT_MODE_PLOT_ONLY,
	FP_PLOT_MODE_PLOT_ONLY,  FP_PLOT_MODE_PLOT_ONLY,
};
                                                                                                                                  /**  initialize plottitng modes  **/




/*****************/
/**             **/
/**  Functions  **/
/**             **/
/*****************/

main()
{
	int       vmod;
	double    arg;
	int       delay;
	unsigned  video_filter_setting = 65535U;

	int  i,  j,  k;


	/**  get the video mode from keyborad input (must be EGA or VGA)  **/

	mode( FP_MODE_VGA_16_COLOR );		/**  set video mode for graphic  **/
	vigen( FP_MODE_VGA_16_COLOR );		/**  video initialization  **/
	funct( FP_WRITE_MODE_OR );		/**  set to OR pixels onto the screen  **/

	for ( i = 0;  i < NUMBER_OF_WAVEFORMS;  i++ )
		attrib( &sp[i] );

	grid( 65,  16,  32,  40,  16,  16,  1,  4 );	/**  draw grid  **/

	chrplt( "Hit Any Key to Quit",  250,  16,
	        FP_CHRPLT_EGA_FONT + FP_CHRPLT_REVERSE_VIDEO + 9 );


	/**  generate a sine wave and a cosine wave and store them into the byte arrays
	 **      sine_buffer[2048] and cosine_buffer[2048]                               **/

	for ( i = 0;  i < 2048;  i++ )  {
		arg = (6.28318 * i ) / 256.;
		sine_buffer[i]=127*sin(arg*4);
		cosine_buffer[i]=127*cos(arg);
	}

	/**  Plot sine and cosine waveforms continuously on the screen  **/

	while ( 1 )  {

		fp_video_filter( &sine_buffer[ sp[ BUFFER_SINE ].idel ],
		                 video_sine_buffer,  512,  video_filter_setting );

		power( &sine_buffer[ sp[ BUFFER_SINE ].idel ],  512,  float_fft,  512 );

		for ( i = 0;  i < 256;  i++ )
			fft_buffer[i] = float_fft[i];	/**  Convert floating point to binary  **/

		for ( k = 0;  k < 10;  k++ )  {
			for ( i = 0;  i < 4;  i++ )
				fplot( &ipm[i],  &sp[i],  buffers[i] );
		}

		/**  Make our artificial data a little more interesting by scrolling through it  **/

		sp[ BUFFER_SINE ].idel += 4;

		if ( sp[ BUFFER_SINE ].idel > 511 )
			sp[ BUFFER_SINE ].idel = 0;

		sp[ BUFFER_COSINE ].idel += 4;

		if ( sp[ BUFFER_COSINE ].idel > 511 )
			sp[ BUFFER_COSINE ].idel = 0;

		if ( squeeze )  {
			if ( sp[ BUFFER_COSINE ].iscale > 100000L )
				squeeze = FALSE;

			sp[ BUFFER_COSINE ].iscale *= 1.03;
		}
		else  {
			if ( sp[ BUFFER_COSINE ].iscale < 40000L )
				squeeze = TRUE;

			sp[ BUFFER_COSINE ].iscale /= 1.03;
		}

		if ( increase_video_filter )  {
			if ( video_filter_setting >= 65526U )
				increase_video_filter = FALSE;

			video_filter_setting += 8;
		}
		else  {
			if ( video_filter_setting <= 65000U )
				increase_video_filter = TRUE;

			video_filter_setting -= 8;
		}

		if( kbhit() )
			break;                                                                             /**  check keyboard for hit  **/
	}


	/**  Set video mode back to text mode then exit  **/

	mode( FP_MODE_CGA_80_COLUMN_COLOR );
}
