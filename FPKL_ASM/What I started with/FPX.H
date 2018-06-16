/*************************************************************************
/*
/*   FPX.H header file for Mike Whalen's FastPlot library
/*   Copyright 1991 Sonix, Inc.
/*
/************************************************************************/




/*****************/
/**             **/
/**  Constants  **/
/**             **/
/*****************/


#define FP_EMS_PAGESIZE                 16384           /**  number of bytes per EMS page  **/

#define FP_USE_CONV                     0               /**  use conventional memory  **/
#define FP_USE_EMS                      1               /**  use expanded memory if available  **/

#define FP_NUMBER_OF_MODES              0x63

#define FP_MODE_CGA_40_COLUMN_MONO      0x00            /**  40 column alphanumeric, color burst off  **/
#define FP_MODE_CGA_40_COLUMN_COLOR     0x01            /**  40 column alphanumeric                   **/
#define FP_MODE_CGA_80_COLUMN_MONO      0x02            /**  80 column alphanumeric, color burst off  **/
#define FP_MODE_CGA_80_COLUMN_COLOR     0x03            /**  80 column alphanumeric                   **/
#define FP_MODE_CGA_LO_MONO             0x04            /**  CGA 320x200x4                            **/
#define FP_MODE_CGA_LO_COLOR            0x05            /**  CGA 320x200x4                            **/
#define FP_MODE_CGA_HI                  0x06            /**  CGA 640x200x2                            **/
#define FP_MODE_MDA                     0x07            /**  80 column alphanumeric, for MDA monitor  **/
#define FP_MODE_EGA_LO                  0x0D            /**  EGA 320x200x16                           **/
#define FP_MODE_EGA_MED                 0x0E            /**  EGA 640x200x16                           **/
#define FP_MODE_EGA_HI_MONO             0x0F            /**  EGA 640x350x2                            **/
#define FP_MODE_EGA_HI_COLOR            0x10            /**  EGA 640x350x16                           **/
#define FP_MODE_VGA_MONO                0x11            /**  VGA 640x480x2                            **/
#define FP_MODE_VGA_16_COLOR            0x12            /**  VGA 640x480x16                           **/
#define FP_MODE_VGA_LO                  0x13            /**  VGA 320x200x256 (packed)                 **/
#define FP_MODE_TS_SUPER_VGA_16_COLOR   0x29            /**  Tseng    SuperVGA 800x600x16             **/
#define FP_MODE_TS_SUPER_VGA_256_COLOR  0x30            /**  Tseng    SuperVGA 800x600x256            **/
#define FP_MODE_TS_HI_256_COLOR         0x38            /**  Tseng    SuperVGA 1024x768x256           **/
#define FP_MODE_PAR_SUPER_VGA_16_COLOR  0x58            /**  Paradise SuperVGA 800x600x16             **/
#define FP_MODE_V7_SUPER_VGA_16_COLOR   0x62            /**  Video7   SuperVGA 800x600x16             **/
#define FP_MODE_ATI_SUPER_VGA_16_COLOR  0x54            /**  ATI      SuperVGA 800x600x16             **/

#define FP_WRITE_MODE_REPLACE           0               /**  data unmodified  **/
#define FP_WRITE_MODE_AND               1               /**  data anded       **/
#define FP_WRITE_MODE_OR                2               /**  data ored        **/
#define FP_WRITE_MODE_XOR               3               /**  data xored       **/

#define FP_KEYSTATE_INSERT_MODE         0x80            /**  insert mode active  **/
#define FP_KEYSTATE_CAPS_LOCK           0x40            /**  CAPs lock on        **/
#define FP_KEYSTATE_NUM_LOCK            0x20            /**  NUM lock on         **/
#define FP_KEYSTATE_SCROLL_LOCK         0x10            /**  SCROLL lock on      **/

#define FP_PLOT_MODE_ERASE_ONLY         0               /**  Erase current waveform in the erase buffer  **/
#define FP_PLOT_MODE_ERASE_AND_PLOT     1               /**  Erase current waveform in erase buffer and plot waveform specified by buff  **/
#define FP_PLOT_MODE_PLOT_ONLY          2               /**  The waveform specified by buff is XOR'd to the screen.  The plotted waveform is also stored in the erase buffer.  **/
#define FP_PLOT_MODE_ACCUMULATE         3               /**  The waveform specified by buff is OR'd to the screen, but is not saved in the erase buffer  **/

#define FP_SP_RECTIFY_OFF               1               /**  Don't rectify data  **/
#define FP_SP_RECTIFY_ON                -1              /**  Rectify the data  **/

#define FP_SP_DATA_BINARY               0               /**  Binary data  **/
#define FP_SP_DATA_BIPOLAR_BINARY       1               /**  Bipolar binary data  **/
#define FP_SP_DATA_TWOS_COMPLEMENT      2               /**  2's complement data  **/

#define FP_DECI_UNIPOLAR                0               /**  Unipolar binary  **/
#define FP_DECI_BIPOLAR                 1               /**  Biploar binary  **/
#define FP_DECI_TWOS_COMPLEMENT         2               /**  2's complement  **/

#define FP_ACCUM_FIRST_TIME             0               /**  Indicate initial call to accum  **/
#define FP_ACCUM_SUBSEQUENT             1               /**  Indicate subsequent call to accum  **/

#define FP_ACCUM_TYPE_BINARY            0               /**  binary data  **/
#define FP_ACCUM_TYPE_TWOS_COMPLEMENT   1               /**  2's complement data  **/

#define FP_CHABS_TWOS_COMP_TO_BIPOLAR   1               /**  Convert 2's complelemt to bipolar offset binary chabs() operation  **/
#define FP_CHABS_FULL_WAVE_RECTIFY      2               /**  Full wave rectify chabs() operation  **/
#define FP_CHABS_HALF_WAVE_PLUS         3               /**  Half wave plus chabs() operation  **/
#define FP_CHABS_HALF_WAVE_MINUS        4               /**  Half wave minus chabs() operaiton  **/

#define	FP_PF_LEVEL			0		/**  Level mode for fp_peak_find()  **/
#define	FP_PF_EDGE			1		/**  Edge mode for fp_peak_find()  **/
#define	FP_PF_LESS_THAN			0		/**  Less than mode for threshold_sense of fp_peak_find()  **/
#define	FP_PF_GREATER_THAN		1		/**  Greater than mode for threshold_sense of fp_peak_find()  **/
#define	FP_PF_TWOS_COMPLEMENT		0		/**  Two's complement mode for data_type of fp_peak_find()  **/
#define	FP_PF_BINARY			1		/**  Binary mode for data_type of fp_peak_find()  **/

#define FP_CHRPLT_REVERSE_VIDEO         0x10            /**  Print string in reverse video  **/
#define FP_CHRPLT_EGA_FONT              0x20            /**  Print string using the 8x14 EGA font  **/

#define FP_ED_CURSOR_EXIT               0               /**  Exit if the left or right cursor key is pressed  **/
#define FP_ED_CURSOR_NORMAL             1               /**  Pressing the left or right cursor keys moves the cursor  **/

#define	FP_CPU_8086			0		/**  fp_cpu_id() indicates 8086 processor present  **/
#define	FP_CPU_80286			2		/**  fp_cpu_id() indicates 80286 processor present  **/
#define	FP_CPU_80386			3		/**  fp_cpu_id() indicates 80386 processor present  **/
#define	FP_CPU_80486			4		/**  fp_cpu_id() indicates 80486 processor present  **/

#define	FP_PF_LEVEL			0		/**  Level mode for fp_peak_find()  **/
#define	FP_PF_EDGE			1		/**  Edge mode for fp_peak_find()  **/
#define	FP_PF_LESS_THAN			0		/**  Less than mode for threshold_sense of fp_peak_find()  **/
#define	FP_PF_GREATER_THAN		1		/**  Greater than mode for threshold_sense of fp_peak_find()  **/
#define	FP_PF_TWOS_COMPLEMENT		0		/**  Two's complement mode for data_type of fp_peak_find()  **/
#define	FP_PF_BINARY			1		/**  Binary mode for data_type of fp_peak_find()  **/

#define FP_EMS_SUCCESSFUL               0               /**  Successful  **/
#define FP_EMS_SOFTWARE_ERROR           1               /**  Software Error  **/
#define FP_EMS_HARDWARE_ERROR           2               /**  Hardware Error  **/
#define FP_EMS_UNALLOCATED_HANDLE       3               /**  Unallocated handle error  **/

enum  {
        FP_HPLJ_PRINTER_RES_150_DPI,
        FP_HPLJ_PRINTER_RES_300_DPI,
};

#define FP_HPLJ_150_DPI_LENGTH_RES      1500
#define FP_HPLJ_150_DPI_WIDTH_RES       1125

#define FP_HPLJ_300_DPI_LENGTH_RES      3000
#define FP_HPLJ_300_DPI_WIDTH_RES       2250




/******************/
/**              **/
/**  Prototypes  **/
/**              **/
/******************/


void  accum( int isw,  char *buff,  int *cume,  int type,  int n );
void  attrib( struct plot *sp );
void  avb3( int n,  UBYTE *xin,  UBYTE *xout,  int len );
void  bfplt( char *str,  int ix,  int iy,  int fg,  int bg );

#ifndef VC
void  blank( int n,  int irow,  int icol,  int iattribute );
#endif

void  blnkln( int ix,  int iy,  int n );
void  btmsk( int value );
int   bufems( unsigned start,  long where,  unsigned len,  int (*bufmov)() );
int   cgapal( int id,  int val );
void  chabs( void *in,  void *out,  int n,  int type );
int   chkey( void );
int   chkeye( void );
int   chkprn( void );
void  chrplt( char *str,  int ix,  int iy,  int ic );
void  c_cli( void );
void  codoc( int value );
void  colco( int value );
void  colrln( int ix,  int iy,  int n,  int clr,  int mask );
void  compsc( int len,  int mindex,  UBYTE *in,  UBYTE *accum);
void  compsl( int len,  int ifac,  UBYTE *xdat);
int   cursor( int irow,  int icol );
void  cvtbin( void *in,  void *out,  unsigned len );
void  decim( int scale,  int npts,  char *ibuff,  char *obuff,  int type);
void  degen( void );
void  difb3( int n,  UBYTE *xin,  UBYTE *xout,  int flen );
int   dskems( int han,  long where,  unsigned len );
void  dspchr( char ichar,  int iat );
void  dspla2( char *x,  int n,  int ir,  int ic,  int color);
int   dsplac(  char *string,  int irow,  int icol,  int iattribute );
void  dsplaf( char *x,  int ir,  int ic,  int color );
int   dsplay( char *string,  int n,  int irow,  int icol,  int iattribute );
void  dsplin(  char *string,  int irow,  int icol,  int iattribute );

int   ed( int im,  char *t,  int n,  int ir,  int ic,  int color,  int invc,
          int *ix );

void  edge( int n,  UBYTE *in1,  UBYTE *in2,  UBYTE *in3,  UBYTE *out );
int   emalloc( int pages,  int memtyp );
int   ems1( void );
int   ems2( UWORD *pfba );
int   ems3( UWORD unalloc,  UWORD total );
int   ems4( UWORD *noptoa,  UWORD *handle );
int   ems5( UWORD handle,  UWORD lopano,  UWORD lowino );
int   ems6( UWORD handle );
int   ems7( void );
int   ems8( UWORD handle );
int   ems9( UWORD handle );
int   emsdsk( int han,  long where,  unsigned len );
void  enasr( int value );
void  expand( void *from,  void *to,  int nbytes,  int xf );
void  fgln( int ix,  int iy,  int n,  int color,  int mask );
void  fgplt( char *str,  int ix,  int iy,  int fg );
void  filmem( int *y,  int n,  int ii );
void  filscr( int ival,  int clr );
int   findth( void *buff,  int ista,  int len,  char thresh);
int   fp_cpu_id( void );
int   fp_dsk_ems( int file_han,  int handle,  long where,  unsigned len );
int   fp_ems_alloc( long  number_of_bytes_needed );
int   fp_ems_free( int handle );

int   fp_ems_init ( int  ems_handle,  int  first_page,  int  last_page,
                    int  value);

int   fp_ems_read( int handle,  UBYTE  *conventional_memory,
                   long  ems_location,  unsigned  length );

int   fp_ems_write( int handle,  UBYTE  *conventional_memory,
                    long  ems_location,  unsigned  length );

int   fp_ems_bufems (int ems_handle, unsigned start, long where, unsigned len,
                 int (*bufmov)());

int   fp_ems_seek( int  ems_handle,  long  ems_location,
                   UBYTE  **conventional_memory_location );

void  fplot( int *ipm,  struct plot *sp,  char *buff);

int   fp_peak_find( char *buff,  unsigned length,  int threshold,
                    int threshold_sense,  int absolute_value,
                    int data_type,  int edge_level_logic,
                    unsigned *time_of_flight );

int   fp_xfer32_align_source( UBYTE *dest,  UBYTE *source,
                              unsigned  number_of_bytes );

int   fp_xfer32_align_source_lace( UBYTE *dest,  UBYTE *source,
                                   unsigned  number_of_bytes,
                                   int  interleave );

void  funct( int value );
long  getmode( void );
void  getcregs( char *preg );
int   get_ems( int *pfba,  int *unalpgs,  int *total );
int   getkey( void );
int   getkeyc( void );
int   getkeye( void );
int   get_pfba( void );
void  getpix( int line,  int icol,  char *string );
void  getpix2( int line,  int icol,  char *string );
void  getpregs( char *preg );

int   get_unal( void );

int   gred( int mode,  char *label,  char *string,  int n,  int ix,  int iy,
            int ic1,  int ic2,  int *nlen );

void  grid( int ix1,  int nxd,  int ixd,  int iy1,  int nyd,  int iyd,  int ic,
            int color );

int   hp_laser_screen_dump( int mag,  int x0,  int y0,  int width,  int height,
                            int  printer_res );

void  initems( int ist,  int iend );
void  inter( int n,  int inc,  char *bufi,  char *bufo);
void  interb( int n,  int inc,  void *bufi,  void *bufo );
void  interl( int n,  unsigned long inc,  char *bufi,  char *bufo);
void  interlb( int n,  long inc,  void *bufi,  void *bufo );
void  invert( int n,  void *data );
void  keyrate( int rate,  int delay );
int   keysta( void );
void  lcplt( char *string,  int ix,  int iy,  int ic );
void  line( int startx,  int starty,  int endx,  int endy,  int color );
void  line2( int startx,  int starty,  int endx,  int endy,  int color );
void  linpl1( int ix,  int iy,  int len,  int idum,  UBYTE *data );
void  linpl2( int ix,  int iy,  int len,  int idum,  UBYTE *data );
void  linpl4( int ix,  int iy,  int len,  int idum,  UBYTE *data );
void  linpl8( int ix,  int iy,  int len,  int idum,  UBYTE *data );
void  linpla( int ix,  int iy,  int len,  int xrep,  int yrep,  UBYTE *data );
void  linplc( int ix,  int iy,  int len,  int xrep,  int yrep,  UBYTE *data );
void  mcplt( char *string,  int ix,  int iy,  int ic );
int   mode( int imode );
void  mpmsk( int value );
void  pfclose( void );
int   pfopen( void );

void  pkfind( void *x,  unsigned *start,  unsigned *length,  unsigned *pkamp,
              unsigned *pkpos );

void  pntplt( int ix,  int iy,  int ic );
void  pntplt2( int ix,  int iy,  int ic );
int   prnbuf( char *str,  int n );
int   prnchr( char c );
int   prnstr( char *str );
void  rdcurs( int *row,  int *col );
void  rdmap( int value );
void  rdmod( int value );
void  redcol( UBYTE *buff,  unsigned col,  unsigned hinge,  unsigned isy );
int   redemc( void *temp,  long where,  int lenn,  int isy );
int   redems( UBYTE *temp,  long where,  unsigned len );
void  revvid( void );
void  rotat( int value );
void  rowsca( int value );
void  salb( int n,  int ishift,  UBYTE *data );
void  scrdmp( void );
int   scroll( char ichar,  int inum,  int iattribute );
void  selseg( int writeseg,  int readseg );
int   setbor( int ival );
void  setdac( int index,  long lval );
void  setpag( int ip );
int   setpal( int ireg,  int ival );
void  setre( int num );
int   setvga( int ireg,  long ival );
void  shift( int *cume,  char *buff,  int shft,  int n );
void  stadd( unsigned value );
void  c_sti( void );
void  tblank( int n,  int irow,  int icol,  int iattribute );
void  twocmp( void *in,  void *out,  unsigned len );
int   unalloc( void );
void  vavb3( int n,  UBYTE *in1,  UBYTE *in2,  UBYTE *in3,  UBYTE *out );
void  vdifb3( int n,  UBYTE *in1,  UBYTE *in2,  UBYTE *in3,  UBYTE *out );
void  vectav( int n,  void *in1,  void *in2,  void *out );
void  vertln( int ix,  int iy,  int ih,  int ic );
int   vgaread( int ix,  int iy,  int n,  unsigned loc );
int   vgawrite( int ix,  int iy,  int n,  unsigned loc );
void  vigen( int imode );
void  vlnplt( int ix,  int iy,  int len,  void *data );
void  vlnplt2( int ix,  int iy,  int len,  void *data );
void  vlnplt4( int ix,  int iy,  int len,  void *data );
void  vlnplt8( int ix,  int iy,  int len,  void *data );
void  vpread( int plane,  int iy,  int icol,  int n,  char *data );
void  vpwrite( int plane,  int iy,  int icol,  int n,  char *data );
void  wrmod( int value );
void  wrtcol( char *buff,  int col,  int hinge,  int isy );
int   wrtemc( void *temp,  long where,  int lenn,  int isy );
int   wrtems( UBYTE *temp,  long where,  unsigned len );
void  xfer(  void *from,  void *to,  int n );
void  xferci( void *from,  void *to,  unsigned nbytes,  int hinge );
void  xferco( void *from,  void *to,  unsigned nbytes,  int hinge );
void  xlate( UBYTE *in,  UBYTE *out,  UBYTE *table,  int n );




/***************/
/**           **/
/**  Globals  **/
/**           **/
/***************/


extern int  handle;                     /**  LIM 4.0 handle to the allocated expanded memory block; -1 if ealloc()
                                         **      has not yet been called.                                           **/

extern int  iemssw;                     /**  TRUE if EMS not present  **/
extern int  pfba;                       /**  page frame base address (the segment) for EMS  **/
extern int  unalpgs;                    /**  number of unallocated EMS pages in system  **/
extern int  total;                      /**  total number of EMS pages in system  **/

extern int  vm;                         /**  current video mode  **/

