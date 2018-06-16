// atco_fpm.cpp : Defines the entry point for the DLL application.
//

#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers
// Windows Header Files:
#include <windows.h>
#include <commdlg.h>
#define DLLExport extern  __declspec (dllexport)
#define FP_CHABS_TWOS_COMP_TO_BIPOLAR   1               /**  Convert 2's complelemt to bipolar offset binary chabs() operation  **/
#define FP_CHABS_FULL_WAVE_RECTIFY      2               /**  Full wave rectify chabs() operation  **/
#define FP_CHABS_HALF_WAVE_PLUS         3               /**  Half wave plus chabs() operation  **/
#define FP_CHABS_HALF_WAVE_MINUS        4               /**  Half wave minus chabs() operaiton  **/
#define	FP_PF_LEVEL			            0		        /**  Level mode for fp_peak_find()  **/
#define	FP_PF_EDGE			            1		        /**  Edge mode for fp_peak_find()  **/
#define	FP_PF_LESS_THAN			        0		        /**  Less than mode for threshold_sense of fp_peak_find()  **/
#define	FP_PF_GREATER_THAN		        1		        /**  Greater than mode for threshold_sense of fp_peak_find()  **/
#define	FP_PF_TWOS_COMPLEMENT		    0		        /**  Two's complement mode for data_type of fp_peak_find()  **/
#define	FP_PF_BINARY			        1		        /**  Binary mode for data_type of fp_peak_find()  **/
#define FP_DECI_UNIPOLAR                0               /**  Unipolar binary  **/
#define FP_DECI_BIPOLAR                 1               /**  Biplolar binary  **/
#define FP_DECI_TWOS_COMPLEMENT         2               /**  2's complement   **/
#define FP_ACCUM_FIRST_TIME             0               /**  Indicate initial call to accum  **/
#define FP_ACCUM_SUBSEQUENT             1               /**  Indicate subsequent call to accum  **/
#define FP_ACCUM_TYPE_BINARY            0               /**  binary data  **/
#define FP_ACCUM_TYPE_TWOS_COMPLEMENT   1               /**  2's complement data  **/
//sof print bitmap variables
void PrintInit(PRINTDLG *printdlg, HWND hwnd);
unsigned char blue[256];
unsigned char red[256];
unsigned char green[256];
int BMPWIDTH = 0;
int BMPHEIGHT = 0;
int X = 0, Y = 0; /* current output location */
int maxX, maxY; /* screen dimensions */
HDC memDC, memPrDC; /* virtual device handles */
HBITMAP hBit, hBit2, hImage; /* bitmap handles */
HBRUSH hBrush; /* brush handle */
PRINTDLG printdlg; 
DOCINFO docinfo;

//eof print bitmap variables

//fplot
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
//end of fplot
//
extern void  fp_maxmin_expand_asm( char *input_maxmin_array,  
                               char *input_tof_array,
                               char *output_array,
                               unsigned long  scale,
                               unsigned long input_size );

extern void  fp_maxmin_reduce_tof_asm( char      *input_array,                         //wavesize
                            char             *output_maxmin_array,                 //#points for compression
                            char             *output_tof_array,                    // tof
                            unsigned long    scale,                                // scale wavesize / reduceto / 2 points
                            short int        connect_lines,                        //
                            short int        output_size );
extern void fp_video_filter_asm(unsigned char * ibuff, unsigned char * obuff,
					            short int buflen,  short unsigned int filter);
extern int  fp_peak_find_asm( char *buff,
						  short unsigned length,
						  short int threshold,
		                  short int threshold_sense,
			              short int absolute_value,
                          short int data_type,
						  short int edge_level_logic,
                          short unsigned *time_of_flight );
extern void  chabs_asm( void *in,  void *out,  short int n,  short int type );
extern void  interlb_asm( short int n,  long inc,  void *bufi,  void *bufo );
extern void  interl_asm( short int n,  long inc,  void *bufi,  void *bufo );

//	CallDLL32("olympus_fpm","fplot",int* ipm, struct plot* sp, unsigned char* buff, unsigned char* bitmap8bit, int bmwidth, int bmheight)  

DLLExport void fplot(int* ipm, struct plot* sp, unsigned char* buff,
                          unsigned char* bitmap8bit, int bmwidth, int bmheight)
{
	int i;
	int j;
	int prevy;
	int cury;
	unsigned char prevyraw;

	if (*ipm == FP_PLOT_MODE_ERASE_AND_PLOT  ||  *ipm == FP_PLOT_MODE_ERASE_ONLY)
		for (i = 0; i < sp->n; i++)
			for (j = 0; j < sp->oldn[i]; j++)
				bitmap8bit[bmwidth * (sp->oldy[i] + j) + i + sp->xoff] ^= sp->color;

	for (i = 0; i < sp->n; i++)
	{
		prevyraw = i == 0 ? buff[sp->idel] : buff[sp->idel + i - 1];
		prevy = (signed char) prevyraw + 128;
		cury  = (signed char) buff[sp->idel + i] + 128;
		sp->oldy[i] = min(prevy, cury) + sp->yoff;
		sp->oldn[i] = abs(prevy - cury) + 1;
		for (j = 0; j < sp->oldn[i]; j++)
			bitmap8bit[bmwidth * (sp->oldy[i] + j) + i + sp->xoff] ^= sp->color;
	}

	if (*ipm == FP_PLOT_MODE_PLOT_ONLY)
		*ipm = FP_PLOT_MODE_ERASE_AND_PLOT;

}

DLLExport void fp_maxmin_expand( char *input_maxmin_array,  
                               char *input_tof_array,
                               char *output_array,
                               unsigned long  scale,
                               unsigned long input_size )
{
	fp_maxmin_expand_asm( input_maxmin_array,  
                          input_tof_array,
                          output_array,
                          scale,
                          input_size );


}
DLLExport void  fp_maxmin_reduce_tof( char      *input_array,                      //wavesize
                            char             *output_maxmin_array,                 //#points for compression
                            char             *output_tof_array,                    // tof
                            unsigned long    scale,                                // scale wavesize / reduceto / 2 points
                            short int        connect_lines,                        //
                            short int        output_size )
{
	fp_maxmin_reduce_tof_asm(input_array,                         //wavesize
                             output_maxmin_array,                 //#points for compression
                             output_tof_array,                    // tof
                             scale,                               // scale wavesize / reduceto / 2 points
                             connect_lines,                       //
                             output_size );   


}
DLLExport void  fp_video_filter(unsigned char * ibuff, unsigned char * obuff,
					    int buflen,  unsigned int filter)
{
	fp_video_filter_asm(ibuff, obuff, buflen, filter);
}

DLLExport int fp_peak_find( char *buff,
						  short unsigned length,
						  short int threshold,
		                  short int threshold_sense,
			              short int absolute_value,
                          short int data_type,
						  short int edge_level_logic,
                          short unsigned *time_of_flight )
{
	return fp_peak_find_asm(buff, length, threshold, threshold_sense, absolute_value,
                           data_type, edge_level_logic, time_of_flight );
}
DLLExport void  chabs( void *in,  void *out,  short int n,  short int type )
{
	chabs_asm(in,out,n,type);
}

DLLExport void  interlb( short int n,  long inc,  void *bufi,  void *bufo )
{
	interlb_asm(  n,   inc,  bufi,  bufo );
}
DLLExport void  interl( short int n,  long inc,  void *bufi,  void *bufo )
{
	interl_asm(  n,   inc,  bufi,  bufo );
}
DLLExport void  xlate(char * inarray, char * outarray, char * table, short num)
{
	__asm
	{
			mov	esi,dword ptr inarray
			mov	edi,dword ptr outarray
			mov	ebx,dword ptr table
			mov	cx,num
		$L1:
			lods	byte ptr [esi]
			xlat
			stosb
			loop	$L1	
	}
}
DLLExport void  xlatergb(char * inarray, char * outarray, int * table, short num)
{
	__asm
    {  
		mov cx,256
        mov esi,dword ptr table
        lea edi, dword ptr blue
        $L1: 
            lods dword ptr [esi]
            shr eax,16
            stosb
            loop $L1
		mov cx,256
		mov esi,dword ptr table
        lea edi, dword ptr green        
        $L11:            
            lods dword ptr [esi]
            and eax,0000ff00h
			shr eax,8
            stosb
            loop $L11
		mov cx,256
		mov esi,dword ptr table
        lea edi,dword ptr red
        $L12:                        
            lods dword ptr [esi]
            and eax, 000000ffh
            stosb
            loop $L12            
        mov    esi,dword ptr inarray
        mov    edi,dword ptr outarray            
        mov    ecx, dword ptr num
        $L2:
            lods    byte ptr [esi]
			mov     edx,eax
			mov     ebx,offset blue
            xlat                
            stosb
			mov     ebx,offset green
			mov     eax,edx
            xlat    
            stosb                
			mov     ebx,offset red
			mov     eax,edx
            xlat    
            stosb
            loop    $L2
    }
}
DLLExport void  xlate16(unsigned short * inarray, unsigned short * outarray, unsigned short * table, unsigned int num)
{
	__asm
		{
			xor edx,edx
			xor ebx,ebx
			xor eax,eax
			xor ecx,ecx
		    mov	esi,dword ptr inarray
			mov	edi,dword ptr outarray
			mov	edx,dword ptr table
			mov	ecx,num
		    mov	eax,0000h
		$L1:	
		    lodsw			
			mov ebx,eax		
			add ebx,ebx
		    mov	ax, word ptr [edx+ebx]
			stosw
			xor eax,eax
			xor ebx,ebx
		    loop	$L1
		}
}
DLLExport void  findth(void * inarray, short int ista, short len, char thres)
{
	__asm
	{
    	cld
	    mov	cx,len
	    mov	dx,ista
	    mov	esi,dword ptr inarray
	    add	si,dx
	    mov	ah,thres
	    cmp	ah,00h
	    jng	$L1
    $L3:
		lodsb
    	cmp	al,ah
	    jnl	$L2
	    loop	$L3
	    mov	ax,0FFFFh
	    jmp	short $L4
     $L1:
		lodsb
    	cmp	al,ah
	    jng	$L2
	    loop	$L1
	    mov	ax,0FFFFh
	    jmp	short $L4
     $L2:	
		mov	ax,dx
	    sub	ax,cx
	    add	ax,len
     $L4:
	}
}
DLLExport void  pkfind( void *x,  unsigned *start,  unsigned *len,  unsigned *pkamp, unsigned *pkpos )
{
	_asm
	{
		cld
		mov	esi,dword ptr x
		mov	ebx,dword ptr start
		xor edx,edx
		mov	dx,word ptr[ebx]
		add	esi,edx
		mov	ebx,dword ptr len
		mov	cx,[ebx]
		mov	ah,[esi]
		cmp	ah,00h
		jnl	$L1
		neg	ah
	$L1:
		mov	dx,si
	$L5:
		lodsb
		cmp	al,00h
		jnl	$L2
		cmp	al,80h
		jnz	$L3
		add	al,01h
	$L3:	
		neg	al
	$L2:	
		cmp	al,ah
		jbe	$L4
		xchg	al,ah
		mov	dx,si
	$L4:	
		loop	$L5
		xchg	al,ah
		cbw
		mov	ebx,dword ptr pkamp
		mov	[ebx],ax
		mov	ebx,dword ptr x
		sub	edx,ebx
		sub	edx,+001h
		mov	ebx,dword ptr pkpos
		mov	[ebx],dx
	}
}
DLLExport void  xferco( void *from,  void *to,short unsigned nbytes, short int hinge )
{
	__asm
	{
		xor edx,edx
		mov	edi,dword ptr to
		mov	esi,dword ptr from
		mov	cx,nbytes
		mov	dx,hinge
		dec	dx
		cld
	$L2:
		movsb
		add	edi,edx
		loop	$L2		
	}
}
DLLExport void  xferco32( void *from,  void *to, unsigned nbytes, short int hinge )
{
	__asm
	{
		xor edx,edx
		mov	edi,dword ptr to
		mov	esi,dword ptr from
		mov	ecx,nbytes
		mov	dx,hinge
		dec	dx
		cld
	$L2:
		movsb
		add	edi,edx
		loop	$L2		
	}
}
DLLExport void  xfer32( void *from,  void *to,  int n )
{
	__asm
	{
		cld
		mov	edi,dword ptr to
		mov	esi,dword ptr from
		mov	ecx,n
		shr	ecx,1
		rep	movsw		
	}
}
DLLExport void  xfer( void *from,  void *to, short int n )
{
	__asm
	{
		cld
		mov	edi,dword ptr to
		mov	esi,dword ptr from
		mov	cx,n
		shr	cx,1
		rep	movsw		
	}
}
DLLExport void  xferci( void *from,  void *to,short unsigned nbytes, short int hinge )
{
	__asm
	{
		xor edx,edx
		mov	edi,dword ptr to
		mov	esi,dword ptr from
		mov	cx,nbytes
		mov	dx,hinge
		dec	dx
		cld
	$L1:
		movsb
		add	esi,edx
		loop	$L1
	}
}
DLLExport void  xferci32( void *from,  void *to, unsigned nbytes, short int hinge )
{
	__asm
	{
		xor edx,edx
		mov	edi,dword ptr to
		mov	esi,dword ptr from
		mov	ecx,nbytes
		mov	dx,hinge
		dec	dx
		cld
	$L1:
		movsb
		add	esi,edx
		loop	$L1
	}
}

DLLExport void  twocmp( void *input,  void *output,  unsigned short int len )
{
	__asm
	{
		xor ecx,ecx
		mov	ecx,dword ptr len
		mov	edi,dword ptr output
		mov	esi,dword ptr input
	$L23:
		lodsb
		sub	al,80h
		stosb
		loop $L23		
	}
}
DLLExport void  shift(  int *cume,  char *buff,   short int shft,   unsigned short int n )
{
	__asm
	{	
		mov	dx,n
		mov	cx,shft
		mov	edi,buff
		mov	esi,cume
	$L34:
		lodsw
		sar	ax,cl
		stosb
		dec	dx
		cmp	dx,+000h
		jnbe	$L34
		
	}
} 
DLLExport void  cvtbin( void *input,  void *output,  short unsigned len )
{
	__asm
	{
		xor ecx,ecx
		mov	cx,len
		mov	edi,output
		mov	esi,input
	$L24:
		lodsb
		add	al,80h
		stosb
		loop	$L24
		
	}
}

DLLExport void  bexpand(void *from, void *to, unsigned short int nbytes, short int xf)
{
	__asm
	{
#include "initasm.h"		
		mov	edi,to
		mov	esi,from
		mov	dx, xf
		cld
		mov	cx,nbytes
$L1:	
		push	cx
		mov		cx,dx
		lodsb
		rep	stosb
		pop	cx
		loop	$L1		
	}
}
DLLExport void  bexpand32(void *from, void *to, unsigned int nbytes, short int xf)
{
	__asm
	{
#include "initasm.h"		
		mov	edi,to
		mov	esi,from
		mov	edx, dword ptr xf
		cld
		mov	ecx,nbytes
$L1:	
		push	ecx
		mov		ecx,edx
		lodsb
		rep	stosb
		pop	ecx
		loop	$L1		
	}
}
DLLExport void  compsc( unsigned short  int len,  short int mindex,  unsigned char *inbuff,  unsigned char *accum)
{
	__asm
	{		
		xor ecx,ecx
		xor eax,eax
		mov	esi,inbuff
		mov	edi,accum
		mov	cx,len
		mov	ax,mindex
		cmp	ax,00h
		jnz	$L6
		shr	cx,1
		cld
		rep	movsw
		jmp	short $L7
	$L6:
		lodsb
		cmp	al,[edi]
		jbe	$L8
		stosb
		loop	$L6
	$L8:
		cmp cx,00h
        jbe $L7
		inc	edi
		loop	$L6
	$L7:		
		

	}
}
//                            0 - 4gb               0 to 65,535           byte ptr               byte ptr
DLLExport void  compsc32( unsigned long int len,  short int mindex,  unsigned char *inbuff,  unsigned char *accum)
{
	__asm
	{		
		xor ecx,ecx        ; zero out
		xor eax,eax        ; zero out
		mov	esi,inbuff     ; ptr to input buffer
		mov	edi,accum      ; ptr to accumulator
		mov	ecx,len        ; move length to 32bit reg counter
		mov	ax,mindex      ; move mindex to 16bit reg adder
		cmp	ax,00h         ; compare to 0 
		jnz	$L6            ; if mindex not zero then jump to $L6; else fall thru
		shr	ecx,1          ; divide length by 2
		cld                ; clear direction
		rep	movsw          ; move counter number of words (length / 2) this is the loop 
		jmp	short $L7      ; end routine.
	$L6:
		lodsb              ; copy ax(0) to al
		cmp	al,[edi]       ; compare accumm byte to al
		jbe	$L8            ; jump if below or equal to $L8
		stosb              ; otherwise copy al into input buffer
		loop	$L6        ; loop back
	$L8:
		cmp ecx,00h        ; if counter is 0 or less 
        jbe $L7            ; end program 
		inc	edi            ; other wise inc accum
		loop	$L6        ; jump back to $L6
	$L7:		
	}
}
DLLExport void  compscl( unsigned short int len,  short int ifac,  unsigned char *xdat)
{
	__asm
	{

		xor edx,edx
	    xor ebx,ebx
		xor eax,eax
		xor ecx,ecx
		mov	esi,xdat
		mov	edi,xdat
		mov	dx,len
		mov	bx,ifac
	$L5:
		mov	ah,00h
		mov	cx,bx
	$L4:
		lodsb
		cmp	al,ah
		jbe	$L3
		mov	ah,al
	$L3:
		loop	$L4
		mov	al,ah
		stosb
		dec	dx
		cmp	dx,+000h
		jnbe	$L5
		
	}
}
//--------------------------------------------------------------------------+
//Vector Processing                                                         | 
//decim()                                                                   | 
//Performs horizontal compression on input data,                            | 
//retaining peak information. This should be used only for plotting data.   |
//                                                                          |
//scale Decimation factor (1 to n) (1 does no compression; n means find the |
//      peak in every group of n points, and put the peak in obuff)         |
//                                                                          |
//npts  Number of points to produce in obuff                                |
//                                                                          |
//ibuff Input array                                                         |
//                                                                          |
//obuff Output array                                                        |
//                                                                          |
//type  Input data type, should be one of the following:                    |
//FP_DECI_UNIPOLAR                0        /**  Unipolar binary  **/        |
//FP_DECI_BIPOLAR                 1        /**  Biplolar binary  **/        |
//FP_DECI_TWOS_COMPLEMENT         2        /**  2's complement   **/        |
//--------------------------------------------------------------------------+
DLLExport void  decim( short int scale,  short unsigned int npts,  char *ibuff,  char *obuff,  short int typev)
{
	__asm
	{
		xor ecx,ecx    ;zero out
		xor edx,edx    ;zero out 
		xor eax,eax    ;zero out
		xor ebx,ebx    ;zero out
		mov	esi,ibuff  ;set up pointer to ibuff
		mov	edi,obuff  ;set up pointer to obuff
		mov	cx,npts    ;set up counter to npts
		cmp	byte ptr typev, 00h ; check to see if it is unipolar
		jnz	$L15                ; if not zero check to see if bipolar or 2''s complement
		jmp	short $L16          ; if zero jump to $L16(Unipolar)
; check to see of bipolar
	$L15:
		cmp	byte ptr typev,01h
		jnz	$L17
		jmp	short $L18
; check to see if 2''s complement
	$L17:
		cmp	byte ptr typev,02h
		jnz	$L19
		jmp	short $L20
	$L19:
		jmp	$L21
; Unipolar processing
	$L16:
		push	cx      ; save the counter
		mov	cx,scale    ; move the scale to the counter
		mov	dx,0000h    ; zero out dx
	$L23:
		lodsb           ; load byte from ibuff to al reg 
		cmp	al,dl       ; compare to dl (zero to start) 
		jc	$L22        ; jump if lower
		mov	dl,al       ; otherwise move to dl(holder)
	$L22:
		loop	$L23    ; keep looping to get largest value - inner loop
		mov	al,dl       ; move largest to al
		stosb           ; put into obuff
		pop	cx          ; retrieve old counter
		loop	$L16    ; loop back to L16                  - outer loop
		jmp	short $L21  ; when original cx is zeroed jump to finish.
; bipolar processing
	$L18:
		push	cx      ; save counter
		mov	cx,scale    ; move the scale to the counter
		mov	dx,0000h    ; zero out dx
	$L26:
		lodsb           ; load byte from ibuff to al reg 
		sub	al,80h      ; subtract 128 from byte
		cmp	al,00h      ; compare to zero
		jg	$L24        ; jump to $L24 if greater
		cmp	al,dh       ; otherwise compare to zero
		jg	$L25        ; jump to $L25 if greater than zero
		mov	dh,al       ; put btye from ibuff into register
		jmp	short $L25  ; jump to $L25
	$L24:
		cmp	al,dl       ; compare al to dl
		jc	$L25        ; jump if lower to $L25
		mov	dl,al       ; otherwise move al to dl
	$L25:
		loop	$L26    ; loop back to $L26 - inner loop
		cmp	dh,80h      ; compare dh to 128
		jnz	$L27        ; jump if not zero to $L27
		mov	dh,81h      ; otherwise move 129 to dh
	$L27:
		mov	ax,dx       ; move dx to ax
		neg	dh          ; neg dh byte
		cmp	dl,dh       ; compare the hi and lo byte
		jg	$L28        ; jump if > to $L28
		mov	al,ah
	$L28:
		add	al,80h
		stosb
		pop	cx
		loop	$L18
		jmp	short $L21
; 2''s complement processing
	$L20:
		push	cx
		mov	cx,scale
		mov	dx,0000h
	$L31:
		lodsb
		cmp	al,00h
		jg	$L29
		cmp	al,dh
		jg	$L30
		mov	dh,al
		jmp	short $L30
	$L29:
		cmp	al,dl
		jl	$L30
		mov	dl,al
	$L30:
		loop	$L31
		cmp	dh,80h
		jnz	$L32
		mov	dh,81h
	$L32:
		mov	ax,dx
		neg	dh
		cmp	dl,dh
		jg	$L33
		mov	al,ah
	$L33:
		stosb
		pop	cx
		loop	$L20
		jmp	short $L21
	$L21:
	
	}
}
DLLExport void  difb3( short int n,  unsigned char *xin,  unsigned char *xout,  short int flen )
{
	_asm
	{
#include "initasm.h"
		mov	esi,dword ptr xin
		mov	al,[esi]
		inc	esi
		mov	edi,dword ptr xout
		mov	[edi],al
		inc	edi
		mov	cx,n
		sub	cx,+002h
	$L18:	
		mov	dl,[esi+001h]
		xor	dh,dh
		mov	bl,[esi-001h]
		xor	bh,bh
		sub	bx,dx
		sar	bx,1
		lodsb
		add	al,bl
		jnc	$L17
		mov	al,0FFh
	$L17:
		stosb
		loop	$L18
		mov	bl,[esi]
		mov	[edi],bl	
	}
}
DLLExport void  accum( short int isw,  char *buff, short int *cume,  short int typex,  short int n )
{
	__asm
	{
	  mov	cx,n
	  mov	edi,dword ptr cume
	  mov	esi,dword ptr buff
	  cmp	byte ptr isw,00h
	  jnbe	$L28
	  cmp	byte ptr typex,00h
	  jnz	$L29
    $L30:
	  lodsb
      sub	ah,ah
	  stosw
	  loop	$L30
	  jmp	short $L31
    $L29:
	  lodsb
	  cbw
	  stosw
	  loop	$L29
	  jmp	short $L31
    $L28:
	  cmp	byte ptr typex,00h
      jnz	$L32
    $L33:
	  lodsb
      sub	ah,ah
      mov	bx,[edi]
	  add	ax,bx
	  stosw
	  loop	$L33
	  jmp	short $L31
    $L32:
	  lodsb
      cbw
	  mov	bx,[edi]
	  add	ax,bx
	  stosw
	  loop	$L32
    $L31:
	}
}
DLLExport void  edge( short int n,  unsigned char *in1,  unsigned char *in2,  unsigned char *in3,  unsigned char *out1 )
{
	__asm
	{
		cld
        push ebp
        xor ecx,ecx
		xor ebx,ebx
		xor edx,edx
	    xor eax,eax
		mov	cx, n
		mov	ebx,dword ptr in1
		mov	esi,dword ptr in2
		mov	edi,dword ptr out1		
		mov	ebp,dword ptr in3
		sub	edx,edx
		sub	eax,eax
	$L24:	
		mov	dl,[ebx]
		xor	dh,dh
		mov	al,[ebp]
		xor	ah,ah
		sub	dx,ax
		jnl	$L21
		neg	dx
	$L21:
		push	edx
		mov	dl,[esi-001h]
		xor	dh,dh
		mov	al,[esi+001h]
		xor	ah,ah
		sub	ax,dx
		jnl	$L22
		neg	ax
	$L22:
		pop	edx
		add	dx,ax
		shr	dx,1
		lodsb
		add	al,dl
		jc	$L23
		stosb
		inc	ebx
		inc	ebp
		loop	$L24
		jmp	short $L25
	$L23:
		mov	al,0FFh
		stosb
		inc	ebx
		inc	ebp
		loop	$L24
	$L25:
		pop ebp
	}
}
DLLExport void  vavb3( short int n,  unsigned char *in1,  unsigned char *in2,  unsigned char *in3,  unsigned char *outx )
{
	__asm
	{
#include "initasm.h"
		    push ebp
			mov	cx,n
			mov	ebx,dword ptr in1
			mov	esi,dword ptr in2
			mov	edi,dword ptr outx
			mov	ebp,dword ptr in3
			sub	dx,dx
			sub	ax,ax
		$L16:	
			mov	al,[ebx]
			sub	ah,ah
			mov	dl,[ebp]
			sub	dh,dh
			add	dx,ax
			sar	dx,1
			lodsb
			add	ax,dx
			sar	ax,1
			stosb
			inc	ebx
			inc	ebp
			loop	$L16
			pop ebp
	}
}
DLLExport void  invert( short int n,  void *datab )
{
	__asm
	{
#include "initasm.h"
		mov	cx,n
		mov	esi,dword ptr datab
		mov	edi,dword ptr datab
	$L28:
		lodsb
		mov	ah,0FFh
		sub	ah,al
		mov	al,ah
		stosb
		loop	$L28
	}

}
DLLExport void  salb( short int n,  short int ishift,  unsigned char *datas )
{
	__asm
	{
#include "C:\Users\Bill\Documents\Visual Studio 2008\Projects\atco_fpm\atco_fpm\initasm.h"
			mov	cx,n
			mov	dx,ishift
			mov	esi,dword ptr datas
			mov	edi,dword ptr datas
		$L27:
			lodsb
			sub	ah,ah
			xchg	cx,dx
			shl	ax,cl
			xchg	cx,dx
			cmp	ax,00FFh
			jng	$L26
			mov	ax,00FFh
		$L26:
			stosb
			loop	$L27
			
	}
}
DLLExport void  vdifb3( short int n,  unsigned char *in1,  unsigned char *in2,  unsigned char *in3,  unsigned char *outx )
{
	__asm
	{
#include "initasm.h"
			push	ebp	
			mov	cx,n
			mov	ebx,dword ptr in1
			mov	esi,dword ptr in2
			mov	edi,dword ptr outx
			mov	ebp,dword ptr in3
			sub	dx,dx
			sub	ax,ax
			$L20:
			mov	al,[ebx]
			cbw
			mov	dx,ax
			mov	al,[ebp]
			cbw
			sub	dx,ax
			sar	dx,1
			lodsb
			add	al,dl
			jnc	$L19
			mov	al,0FFh
			$L19:
			stosb
			inc	ebx
			inc	ebp
			loop	$L20
			pop	ebp			
	}
}


DLLExport void  vectav( short int n,  void *in1,  void *in2,  void *outx )
{
	__asm
	{
#include "initasm.h"
			mov	ebx,dword ptr in2
			mov	esi,dword ptr in1
			mov	edi,dword ptr outx
			mov	cx,n
			mov	dh,00h
			mov	ah,00h
		$L2:
			lodsb
			mov	dl,[ebx]
			add	ax,dx
			shr	ax,1
			stosb
			inc	bx
			loop	$L2			
	}
}
DLLExport int openfile(char * filename )
{
	OPENFILENAME fname;	
	static char fn[256];
	char filefilter[] = "atco\0*.*\0";	
    fname.lStructSize = sizeof(OPENFILENAME);
    fname.hwndOwner = NULL;
    fname.lpstrFilter = filefilter; 
    fname.nFilterIndex = 1;
    fname.lpstrFile = fn;
    fname.nMaxFile = sizeof(fn);
    fname.lpstrFileTitle = filename;
    fname.nMaxFileTitle = sizeof(filename)-1;
    fname.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
    fname.lpstrCustomFilter = NULL;
    fname.lpstrInitialDir = NULL;
    fname.lpstrTitle = NULL;
    fname.lpstrDefExt = NULL;
    fname.lCustData = 0;
    GetOpenFileName(&fname);
	strcpy(filename,fn);
	return 0;
}
DLLExport void printbmp(HBITMAP hImage, HWND hwnd )
{
	HDC hdc;    
    int copies;
    double VidXPPI, VidYPPI, PrXPPI, PrYPPI;
    double Xratio, Yratio;
    RECT r;
    BITMAP bmobject;    
      /* get screen coordinates */
    maxX = GetSystemMetrics(SM_CXSCREEN);
    maxY = GetSystemMetrics(SM_CYSCREEN);
    memset(&r,'0',sizeof(RECT));
      /* create a virtual window */
    hdc = GetDC(hwnd);
    memDC = CreateCompatibleDC(hdc);
    hBit = CreateCompatibleBitmap(hdc, maxX, maxY);
    SelectObject(memDC, hBit);
    hBrush = (HBRUSH) GetStockObject(WHITE_BRUSH);
    SelectObject(memDC, hBrush);
    PatBlt(memDC, 0, 0, maxX, maxY, PATCOPY);
    ReleaseDC(hwnd, hdc);
    /* initialize PRINTDLG struct */
    PrintInit(&printdlg, hwnd);
    PrintDlg(&printdlg);
	docinfo.cbSize = sizeof(DOCINFO);
    docinfo.lpszDocName = "Printing bitmaps";        
    docinfo.lpszOutput = NULL;
    docinfo.lpszDatatype = NULL;
    docinfo.fwType = 0;
    if(!(GetDeviceCaps(printdlg.hDC, RASTERCAPS)
         & (RC_BITBLT | RC_STRETCHBLT))) {
       MessageBox(hwnd, "Cannot Print Raster Images",
            "Error", MB_OK);      
    }
    /* create a memory DC compatible with the printer */
    memPrDC = CreateCompatibleDC(printdlg.hDC);
    /* create a bitmap compatible with the printer DC */
    hBit2 = CreateCompatibleBitmap(printdlg.hDC, maxX, maxY);
    SelectObject(memPrDC, hBit2); 
    /* put bitmap image into memory DC */
    SelectObject(memDC, hImage);		  
    if (!GetObject(hImage, sizeof(BITMAP), (LPSTR)&bmobject) )
			MessageBox(hwnd,"Error with passed value","Error",MB_OK);
    BMPWIDTH = bmobject.bmWidth;
    BMPHEIGHT = bmobject.bmHeight;
    /* copy bitmap to printer-compatible DC */
    BitBlt(memPrDC, 0, 0, BMPWIDTH, BMPHEIGHT,
           memDC, 0, 0, SRCCOPY); 
    /* obtain pixels-per-inch */
    VidXPPI = GetDeviceCaps(memDC, LOGPIXELSX);
    VidYPPI = GetDeviceCaps(memDC, LOGPIXELSY);
    PrXPPI = GetDeviceCaps(printdlg.hDC, LOGPIXELSX);
    PrYPPI = GetDeviceCaps(printdlg.hDC, LOGPIXELSY);
    /* get scaling ratios */
    Xratio = PrXPPI / VidXPPI;
    Yratio = PrYPPI / VidYPPI;
    SelectObject(memDC, hBit); /* restore virtual window */
    StartDoc(printdlg.hDC, &docinfo);
    for(copies=0; copies < printdlg.nCopies; copies++)
	{
        StartPage(printdlg.hDC);
    /* copy bitmap to printer DC, as-is */
    /* copy bitmap while maintaining perspective */
        StretchBlt(printdlg.hDC, 0, BMPHEIGHT + 100,
               (int) (BMPWIDTH*Xratio),
               (int) (BMPHEIGHT*Yratio),
               memPrDC, 0, 0,
               BMPWIDTH, BMPHEIGHT,
               SRCCOPY); 
         EndPage(printdlg.hDC);
    }
    EndDoc(printdlg.hDC); 
    DeleteDC(memPrDC);
    DeleteDC(printdlg.hDC);    
    ReleaseDC(hwnd, hdc);         
}
/* Initialize PRINTDLG structure. */
void PrintInit(PRINTDLG *printdlg, HWND hwnd)
{
  printdlg->lStructSize = sizeof(PRINTDLG);
  printdlg->hwndOwner = hwnd;
  printdlg->hDevMode = NULL;
  printdlg->hDevNames = NULL;
  printdlg->hDC = NULL;
  printdlg->Flags = PD_RETURNDC | PD_NOSELECTION |
                    PD_NOPAGENUMS | PD_HIDEPRINTTOFILE;
  printdlg->nFromPage = 0;
  printdlg->nToPage = 0;
  printdlg->nMinPage = 0;
  printdlg->nMaxPage = 0;
  printdlg->nCopies = 1;
  printdlg->hInstance = NULL;
  printdlg->lCustData = 0;
  printdlg->lpfnPrintHook = NULL;
  printdlg->lpfnSetupHook = NULL;
  printdlg->lpPrintTemplateName = NULL;
  printdlg->lpSetupTemplateName = NULL;
  printdlg->hPrintTemplate = NULL;
  printdlg->hSetupTemplate = NULL;
}
