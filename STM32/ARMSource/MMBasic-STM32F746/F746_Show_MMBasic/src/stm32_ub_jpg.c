//--------------------------------------------------------------
// File     : stm32_ub_picture.c
// Datum    : 19.03.2013
// Version  : 1.2
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F4
// IDE      : CooCox CoIDE 1.7.0
// Module   : STM32_UB_LCD_ST7783, STM32_UB_FATFS
// Funktion : Bilder per FATFS anzeigen
//
// Formate  : 1. Windows-JPG
//
// Speed    : 1. JPG 240x320 von SD ca. 580 ms
//
// Modified : the 2014-10-05 by Fabrice
//          : Removed all non Jpeg routines
//          : Compile with Keil uVision 5.12
//--------------------------------------------------------------


//--------------------------------------------------------------
// Quelle vom JPG-Encoder :
// http://en.pudn.com/downloads263/sourcecode/
//        embed/detail1210390_en.html
// Version 1.4 (2009.04.21)
//--------------------------------------------------------------


//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_jpg.h"


//--------------------------------------------------------------
// interne Funktionen
//--------------------------------------------------------------
unsigned int P_Cal(unsigned char*pc);
int InitTag(void);
void InitTable(void);
int Decode(uint8_t BuffNum);
void GetYUV(short flag);
void StoreBuffer(uint8_t BuffNum);
int DecodeMCUBlock(void);
int HufBlock(PBYTE dchufindex,PBYTE achufindex);
int DecodeElement(void);
void IQtIZzMCUComponent(short flag);
void IQtIZzBlock(short  *s ,short * d,short flag);
void Fast_IDCT(int * block);
PBYTE ReadByte(void);
void Initialize_Fast_IDCT(void);
void idctrow(int * blk);
void idctcol(int * blk);  
//--------------------------------------------------------------
PICTURE_ERR_t P_Picture_Check_BMPHeader(void);
uint16_t P_Picture_2Bytes(uint32_t start);
uint32_t P_Picture_4Bytes(uint32_t start);


//--------------------------------------------------------------
// Globale Variabeln
//--------------------------------------------------------------
FIL myPictureFile;
unsigned char picture_buf[PICTURE_BUF_SIZE];


//--------------------------------------------------------------
// Globale Variabeln für JPG
//--------------------------------------------------------------
const int PICTURE_JPG_ZZ[8][8]={
		{0,1,5,6,14,15,27,28},
		{2,4,7,13,16,26,29,42},
		{3,8,12,17,25,30,41,43},
		{9,11,18,24,37,40,44,53},
		{10,19,23,32,39,45,52,54},
		{20,22,33,38,46,51,55,60},
		{21,34,37,47,50,56,59,61},
		{35,36,48,49,57,58,62,63}
};

const PBYTE PICTURE_JPG_AND[9]={
		0,1,3,7,0xf,0x1f,0x3f,0x7f,0xff
};

PICTURE_JPG_t PICTURE_JPG;
PICTURE_BMP_t PICTURE_BMP;



//--------------------------------------------------------------
// zeichnet ein Windows-JPG-File
// (file muss schon geöffnet sein)
// Return_wert :
//     0 , Bild gezeichnet
//  != 0 , fehler beim zeichnen
//--------------------------------------------------------------
PICTURE_ERR_t UB_Picture_DrawJpg(FIL* fileptr, uint16_t xpos, uint16_t ypos, uint8_t BuffNum)
{
	FATFS_t check_fat;
	uint32_t read_size;
	int funcret;

	PICTURE_JPG.CurX=xpos;
	PICTURE_JPG.CurY=ypos;

	myPictureFile=*fileptr;

    check_fat=UB_Fatfs_ReadBlock(&myPictureFile,picture_buf,PICTURE_BUF_SIZE,&read_size);
	if(check_fat==FATFS_RD_BLOCK_ERR) return 4;

	InitTable();
	if((funcret=InitTag())!=PFUNC_OK) return 5;

	if(BuffNum < 10)
	{
		if(PICTURE_JPG.ImgWidth>LCD_MAXX) return 6;
		if(PICTURE_JPG.ImgHeight>LCD_MAXY) return 7;
	}
	else
	{
		if((PICTURE_JPG.ImgWidth * PICTURE_JPG.ImgHeight * 2) > GFX_MAP_LENGTH) {
			return 11;				// Map too big for the Map buffer
		}
	}

	if((PICTURE_JPG.SampRate_Y_H==0)||(PICTURE_JPG.SampRate_Y_V==0)) return 12;

	funcret=Decode(BuffNum );
	if(funcret!=PFUNC_OK) return 13;

	return 0;
}

//--------------------------------------------------------------
unsigned int P_Cal(unsigned char*pc)
{	
	FATFS_t check_fat;
	uint32_t read_size;
	unsigned short cont=0;
	unsigned long buffer_val=0;
	unsigned long point_val=0;
	unsigned char secoff;
	unsigned short t;
	unsigned char *p;

	p=picture_buf+PICTURE_JPG_BLOCK;
	point_val=(unsigned long)pc;
	buffer_val=(unsigned long)&picture_buf;
	cont=point_val-buffer_val;
	if(cont>=PICTURE_JPG_BLOCK) {
		secoff=cont/PICTURE_JPG_BLOCK;
		while(secoff) {
			for(t=0;t<PICTURE_JPG_BLOCK;t++) {
				picture_buf[t]=p[t];
			}

			check_fat=UB_Fatfs_ReadBlock(&myPictureFile,p,PICTURE_JPG_BLOCK,&read_size);
			if(check_fat==FATFS_RD_BLOCK_ERR) {
				break;
			}

			secoff--;
		}
	}

	return cont-cont%PICTURE_JPG_BLOCK;
}

//--------------------------------------------------------------
int InitTag(void)
{
	PBYTE finish=0;
	PBYTE id;
	short  llength;
	short  i,j,k;
	short  huftab1,huftab2;
	short  huftabindex;
	PBYTE hf_table_index;
	PBYTE qt_table_index;
	PBYTE comnum;
	unsigned char  *lptemp;
	short  colorount;

	PICTURE_JPG.lp=picture_buf+2;
	PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);

	while (!finish)
	{
		id=*(PICTURE_JPG.lp+1);
		PICTURE_JPG.lp+=2;
		PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
		switch (id)
		{
		case PM_APP0:
			llength=PMAKEWORD(*(PICTURE_JPG.lp+1),*PICTURE_JPG.lp);
			PICTURE_JPG.lp+=llength;
			PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
			break;
		case PM_DQT:
			llength=PMAKEWORD(*(PICTURE_JPG.lp+1),*PICTURE_JPG.lp);
			qt_table_index=(*(PICTURE_JPG.lp+2))&0x0f;
			lptemp=PICTURE_JPG.lp+3;
			if(llength<80) {
				for(i=0;i<64;i++) {
					PICTURE_JPG.qt_table[qt_table_index][i]=(short)*(lptemp++);
				}
			}
			else {
				for(i=0;i<64;i++) {
					PICTURE_JPG.qt_table[qt_table_index][i]=(short)*(lptemp++);
				}
				qt_table_index=(*(lptemp++))&0x0f;
				for(i=0;i<64;i++) {
					PICTURE_JPG.qt_table[qt_table_index][i]=(short)*(lptemp++);
				}
			}
			PICTURE_JPG.lp+=llength;
			PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
			break;
		case PM_SOF0:
			llength=PMAKEWORD(*(PICTURE_JPG.lp+1),*PICTURE_JPG.lp);
			PICTURE_JPG.ImgHeight=PMAKEWORD(*(PICTURE_JPG.lp+4),*(PICTURE_JPG.lp+3));
			PICTURE_JPG.ImgWidth=PMAKEWORD(*(PICTURE_JPG.lp+6),*(PICTURE_JPG.lp+5));
			PICTURE_JPG.comp_num=*(PICTURE_JPG.lp+7);
			if((PICTURE_JPG.comp_num!=1)&&(PICTURE_JPG.comp_num!=3))return PFUNC_FORMAT_ERROR;
			if(PICTURE_JPG.comp_num==3)	{
				PICTURE_JPG.comp_index[0]=*(PICTURE_JPG.lp+8);
				PICTURE_JPG.SampRate_Y_H=(*(PICTURE_JPG.lp+9))>>4;
				PICTURE_JPG.SampRate_Y_V=(*(PICTURE_JPG.lp+9))&0x0f;
				PICTURE_JPG.YQtTable=(short *)PICTURE_JPG.qt_table[*(PICTURE_JPG.lp+10)];
				PICTURE_JPG.comp_index[1]=*(PICTURE_JPG.lp+11);
				PICTURE_JPG.SampRate_U_H=(*(PICTURE_JPG.lp+12))>>4;
				PICTURE_JPG.SampRate_U_V=(*(PICTURE_JPG.lp+12))&0x0f;
				PICTURE_JPG.UQtTable=(short *)PICTURE_JPG.qt_table[*(PICTURE_JPG.lp+13)];

				PICTURE_JPG.comp_index[2]=*(PICTURE_JPG.lp+14);
				PICTURE_JPG.SampRate_V_H=(*(PICTURE_JPG.lp+15))>>4;
				PICTURE_JPG.SampRate_V_V=(*(PICTURE_JPG.lp+15))&0x0f;
				PICTURE_JPG.VQtTable=(short *)PICTURE_JPG.qt_table[*(PICTURE_JPG.lp+16)];
			}
			else {
				PICTURE_JPG.comp_index[0]=*(PICTURE_JPG.lp+8);
				PICTURE_JPG.SampRate_Y_H=(*(PICTURE_JPG.lp+9))>>4;
				PICTURE_JPG.SampRate_Y_V=(*(PICTURE_JPG.lp+9))&0x0f;
				PICTURE_JPG.YQtTable=(short *)PICTURE_JPG.qt_table[*(PICTURE_JPG.lp+10)];
				PICTURE_JPG.comp_index[1]=*(PICTURE_JPG.lp+8);
				PICTURE_JPG.SampRate_U_H=1;
				PICTURE_JPG.SampRate_U_V=1;
				PICTURE_JPG.UQtTable=(short *)PICTURE_JPG.qt_table[*(PICTURE_JPG.lp+10)];
				PICTURE_JPG.comp_index[2]=*(PICTURE_JPG.lp+8);
				PICTURE_JPG.SampRate_V_H=1;
				PICTURE_JPG.SampRate_V_V=1;
				PICTURE_JPG.VQtTable=(short *)PICTURE_JPG.qt_table[*(PICTURE_JPG.lp+10)];
			}
			PICTURE_JPG.lp+=llength;
			PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
			break;
		case PM_DHT:
			llength=PMAKEWORD(*(PICTURE_JPG.lp+1),*PICTURE_JPG.lp);
			if (llength<0xd0) {
				huftab1=(short)(*(PICTURE_JPG.lp+2))>>4;
				huftab2=(short)(*(PICTURE_JPG.lp+2))&0x0f;
				huftabindex=huftab1*2+huftab2;
				lptemp=PICTURE_JPG.lp+3;
				for (i=0; i<16; i++) {
					PICTURE_JPG.code_len_table[huftabindex][i]=(short)(*(lptemp++));
				}
				j=0;
				for (i=0; i<16; i++) {
					if(PICTURE_JPG.code_len_table[huftabindex][i]!=0) {
						k=0;
						while(k<PICTURE_JPG.code_len_table[huftabindex][i]) {
							PICTURE_JPG.code_value_table[huftabindex][k+j]=(short)(*(lptemp++));
							k++;
						}
						j+=k;
					}
				}
				i=0;
				while (PICTURE_JPG.code_len_table[huftabindex][i]==0)i++;
				for (j=0;j<i;j++) {
					PICTURE_JPG.huf_min_value[huftabindex][j]=0;
					PICTURE_JPG.huf_max_value[huftabindex][j]=0;
				}
				PICTURE_JPG.huf_min_value[huftabindex][i]=0;
				PICTURE_JPG.huf_max_value[huftabindex][i]=PICTURE_JPG.code_len_table[huftabindex][i]-1;
				for (j=i+1;j<16;j++) {
					PICTURE_JPG.huf_min_value[huftabindex][j]=(PICTURE_JPG.huf_max_value[huftabindex][j-1]+1)<<1;
					PICTURE_JPG.huf_max_value[huftabindex][j]=PICTURE_JPG.huf_min_value[huftabindex][j]+PICTURE_JPG.code_len_table[huftabindex][j]-1;
				}
				PICTURE_JPG.code_pos_table[huftabindex][0]=0;
				for (j=1;j<16;j++) {
					PICTURE_JPG.code_pos_table[huftabindex][j]=PICTURE_JPG.code_len_table[huftabindex][j-1]+PICTURE_JPG.code_pos_table[huftabindex][j-1];
				}
				PICTURE_JPG.lp+=llength;
				PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
			}
			else {
				hf_table_index=*(PICTURE_JPG.lp+2);
				PICTURE_JPG.lp+=2;
				PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
				while (hf_table_index!=0xff) {
					huftab1=(short)hf_table_index>>4;
					huftab2=(short)hf_table_index&0x0f;
					huftabindex=huftab1*2+huftab2;
					lptemp=PICTURE_JPG.lp+1;
					colorount=0;
					for (i=0; i<16; i++) {
						PICTURE_JPG.code_len_table[huftabindex][i]=(short)(*(lptemp++));
						colorount+=PICTURE_JPG.code_len_table[huftabindex][i];
					}
					colorount+=17;
					j=0;
					for (i=0; i<16; i++) {
						if(PICTURE_JPG.code_len_table[huftabindex][i]!=0) {
							k=0;
							while(k<PICTURE_JPG.code_len_table[huftabindex][i]) {
								PICTURE_JPG.code_value_table[huftabindex][k+j]=(short)(*(lptemp++));
								k++;
							}
							j+=k;
						}
					}
					i=0;
					while (PICTURE_JPG.code_len_table[huftabindex][i]==0)i++;
					for (j=0;j<i;j++) {
						PICTURE_JPG.huf_min_value[huftabindex][j]=0;
						PICTURE_JPG.huf_max_value[huftabindex][j]=0;
					}
					PICTURE_JPG.huf_min_value[huftabindex][i]=0;
					PICTURE_JPG.huf_max_value[huftabindex][i]=PICTURE_JPG.code_len_table[huftabindex][i]-1;
					for (j=i+1;j<16;j++) {
						PICTURE_JPG.huf_min_value[huftabindex][j]=(PICTURE_JPG.huf_max_value[huftabindex][j-1]+1)<<1;
						PICTURE_JPG.huf_max_value[huftabindex][j]=PICTURE_JPG.huf_min_value[huftabindex][j]+PICTURE_JPG.code_len_table[huftabindex][j]-1;
					}
					PICTURE_JPG.code_pos_table[huftabindex][0]=0;
					for (j=1;j<16;j++) {
						PICTURE_JPG.code_pos_table[huftabindex][j]=PICTURE_JPG.code_len_table[huftabindex][j-1]+PICTURE_JPG.code_pos_table[huftabindex][j-1];
					}
					PICTURE_JPG.lp+=colorount;
					PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
					hf_table_index=*PICTURE_JPG.lp;
				}
			}
			break;
		case PM_DRI:
			llength=PMAKEWORD(*(PICTURE_JPG.lp+1),*PICTURE_JPG.lp);
			PICTURE_JPG.restart=PMAKEWORD(*(PICTURE_JPG.lp+3),*(PICTURE_JPG.lp+2));
			PICTURE_JPG.lp+=llength;
			PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
			break;
		case PM_SOS:
			llength=PMAKEWORD(*(PICTURE_JPG.lp+1),*PICTURE_JPG.lp);
			comnum=*(PICTURE_JPG.lp+2);
			if(comnum!=PICTURE_JPG.comp_num) return PFUNC_FORMAT_ERROR;
			lptemp=PICTURE_JPG.lp+3;
			for (i=0;i<PICTURE_JPG.comp_num;i++) {
				if(*lptemp==PICTURE_JPG.comp_index[0]) {
					PICTURE_JPG.YDcIndex=(*(lptemp+1))>>4;
					PICTURE_JPG.YAcIndex=((*(lptemp+1))&0x0f)+2;
				}
				else {
					PICTURE_JPG.UVDcIndex=(*(lptemp+1))>>4;
					PICTURE_JPG.UVAcIndex=((*(lptemp+1))&0x0f)+2;
				}
				lptemp+=2;
			}
			PICTURE_JPG.lp+=llength;
			PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
			finish=1;
			break;
		case PM_EOI:
			return PFUNC_FORMAT_ERROR;
			//      break;
		default:
			if ((id&0xf0)!=0xd0) {
				llength=PMAKEWORD(*(PICTURE_JPG.lp+1),*PICTURE_JPG.lp);
				PICTURE_JPG.lp+=llength;
				PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
			}
			else {
				PICTURE_JPG.lp+=2;
			}
			break;
		}
	}
	return PFUNC_OK;
}


//--------------------------------------------------------------
void InitTable(void)
{
	short i,j;

	PICTURE_JPG.sizei=0;
	PICTURE_JPG.sizej=0;
	PICTURE_JPG.ImgWidth=0;
	PICTURE_JPG.ImgHeight=0;
	PICTURE_JPG.rrun=0;
	PICTURE_JPG.vvalue=0;
	PICTURE_JPG.BitPos=0;
	PICTURE_JPG.CurByte=0;
	PICTURE_JPG.IntervalFlag=0;
	PICTURE_JPG.restart=0;
	for(i=0;i<3;i++) {
		for(j=0;j<64;j++) {
			PICTURE_JPG.qt_table[i][j]=0;
		}
	}
	PICTURE_JPG.comp_num=0;
	PICTURE_JPG.HufTabIndex=0;
	for(i=0;i<3;i++) {
		PICTURE_JPG.comp_index[i]=0;
	}
	for(i=0;i<4;i++) {
		for(j=0;j<16;j++) {
			PICTURE_JPG.code_len_table[i][j]=0;
			PICTURE_JPG.code_pos_table[i][j]=0;
			PICTURE_JPG.huf_max_value[i][j]=0;
			PICTURE_JPG.huf_min_value[i][j]=0;
		}
	}
	for(i=0;i<4;i++) {
		for(j=0;j<256;j++) {
			PICTURE_JPG.code_value_table[i][j]=0;
		}
	}

	for(i=0;i<10*64;i++) {
		PICTURE_JPG.MCUBuffer[i]=0;
		PICTURE_JPG.QtZzMCUBuffer[i]=0;
	}
	for(i=0;i<64;i++) {
		PICTURE_JPG.Y[i]=0;
		PICTURE_JPG.U[i]=0;
		PICTURE_JPG.V[i]=0;
		PICTURE_JPG.BlockBuffer[i]=0;
	}
	PICTURE_JPG.ycoef=0;
	PICTURE_JPG.ucoef=0;
	PICTURE_JPG.vcoef=0;
}


//--------------------------------------------------------------
int Decode(uint8_t BuffNum)
{
	int funcret;

	PICTURE_JPG.Y_in_MCU=PICTURE_JPG.SampRate_Y_H*PICTURE_JPG.SampRate_Y_V;
	PICTURE_JPG.U_in_MCU=PICTURE_JPG.SampRate_U_H*PICTURE_JPG.SampRate_U_V;
	PICTURE_JPG.V_in_MCU=PICTURE_JPG.SampRate_V_H*PICTURE_JPG.SampRate_V_V;
	PICTURE_JPG.H_YtoU=PICTURE_JPG.SampRate_Y_H/PICTURE_JPG.SampRate_U_H;
	PICTURE_JPG.V_YtoU=PICTURE_JPG.SampRate_Y_V/PICTURE_JPG.SampRate_U_V;
	PICTURE_JPG.H_YtoV=PICTURE_JPG.SampRate_Y_H/PICTURE_JPG.SampRate_V_H;
	PICTURE_JPG.V_YtoV=PICTURE_JPG.SampRate_Y_V/PICTURE_JPG.SampRate_V_V;
	Initialize_Fast_IDCT();
	while((funcret=DecodeMCUBlock())==PFUNC_OK) {
		PICTURE_JPG.interval++;
		if((PICTURE_JPG.restart)&&(PICTURE_JPG.interval % PICTURE_JPG.restart==0)) {
			PICTURE_JPG.IntervalFlag=1;
		}
		else {
			PICTURE_JPG.IntervalFlag=0;
		}
		IQtIZzMCUComponent(0);
		IQtIZzMCUComponent(1);
		IQtIZzMCUComponent(2);
		GetYUV(0);
		GetYUV(1);
		GetYUV(2);
		StoreBuffer(BuffNum );
		PICTURE_JPG.sizej+=PICTURE_JPG.SampRate_Y_H*8;
		if(PICTURE_JPG.sizej>=PICTURE_JPG.ImgWidth) {
			PICTURE_JPG.sizej=0;
			PICTURE_JPG.sizei+=PICTURE_JPG.SampRate_Y_V*8;
		}
		if ((PICTURE_JPG.sizej==0)&&(PICTURE_JPG.sizei>=PICTURE_JPG.ImgHeight)) break;
	}
	return funcret;
}

//--------------------------------------------------------------
void GetYUV(short flag)
{
	short	H,VV;
	short	i,j,k,h;
	short *buf;
	short *pQtZzMCU;

	switch(flag)
	{
	case 0:
		H=PICTURE_JPG.SampRate_Y_H;
		VV=PICTURE_JPG.SampRate_Y_V;
		buf=PICTURE_JPG.Y;
		pQtZzMCU=PICTURE_JPG.QtZzMCUBuffer;
		break;
	case 1:
		H=PICTURE_JPG.SampRate_U_H;
		VV=PICTURE_JPG.SampRate_U_V;
		buf=PICTURE_JPG.U;
		pQtZzMCU=PICTURE_JPG.QtZzMCUBuffer+PICTURE_JPG.Y_in_MCU*64;
		break;
	case 2:
		H=PICTURE_JPG.SampRate_V_H;
		VV=PICTURE_JPG.SampRate_V_V;
		buf=PICTURE_JPG.V;
		pQtZzMCU=PICTURE_JPG.QtZzMCUBuffer+(PICTURE_JPG.Y_in_MCU+PICTURE_JPG.U_in_MCU)*64;
		break;
	}
	for (i=0;i<VV;i++) {
		for(j=0;j<H;j++) {
			for(k=0;k<8;k++) {
				for(h=0;h<8;h++) {
					buf[(i*8+k)*PICTURE_JPG.SampRate_Y_H*8+j*8+h]=*pQtZzMCU++;
				}
			}
		}
	}
}

//--------------------------------------------------------------
void StoreBuffer(uint8_t BuffNum)
{
	short i=0,j=0;
	unsigned char R,G,B;
	int y,u,v,rr,gg,bb;
	long color;

	if(BuffNum == 10){
	Map_Width = PICTURE_JPG.ImgWidth;
	Map_Height= PICTURE_JPG.ImgHeight;
	}

	for(i=0;i<PICTURE_JPG.SampRate_Y_V*8;i++) {
		if((PICTURE_JPG.sizei+i)<PICTURE_JPG.ImgHeight) {
			for(j=0;j<PICTURE_JPG.SampRate_Y_H*8;j++) {
				if((PICTURE_JPG.sizej+j)<PICTURE_JPG.ImgWidth) {
					y=PICTURE_JPG.Y[i*8*PICTURE_JPG.SampRate_Y_H+j];
					u=PICTURE_JPG.U[(i/PICTURE_JPG.V_YtoU)*8*PICTURE_JPG.SampRate_Y_H+j/PICTURE_JPG.H_YtoU];
					v=PICTURE_JPG.V[(i/PICTURE_JPG.V_YtoV)*8*PICTURE_JPG.SampRate_Y_H+j/PICTURE_JPG.H_YtoV];
					rr=((y<<8)+18*u+367*v)>>8;
					gg=((y<<8)-159*u-220*v)>>8;
					bb=((y<<8)+411*u-29*v)>>8;
					R=(unsigned char)rr;
					G=(unsigned char)gg;
					B=(unsigned char)bb;
					if (rr&0xffffff00) {
						if (rr>255) {
							R=255;
						}
						else {
							if (rr<0) R=0;
						}
					}
					if (gg&0xffffff00) {
						if (gg>255) {
							G=255;
						}
						else {
							if (gg<0) G=0;
						}
					}
					if (bb&0xffffff00) {
						if (bb>255) {
							B=255;
						}
						else {
							if (bb<0) B=0;
						}
					}
					color=R>>3;
					color=color<<6;
					color |=(G>>2);
					color=color<<5;
					color |=(B>>3);

					// Pixel zeichnen
					if(BuffNum <=2) {
						// Normal buffer
						GFX_SetPixel(PICTURE_JPG.sizej+j+PICTURE_JPG.CurX , PICTURE_JPG.sizei+i+PICTURE_JPG.CurY , color , BuffNum);
					} else {
						// nicht ok ... eine ideen Uwe ? (todo: fix this)
						MapMemory[(Map_Width * i) + j] = color;
					}
				}
				else  break;
			}
		}
		else break;
	}
}

//--------------------------------------------------------------
int DecodeMCUBlock(void)
{
	short *lpMCUBuffer;
	short i,j;
	int funcret;

	if (PICTURE_JPG.IntervalFlag==1) {
		PICTURE_JPG.lp+=2;
		PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
		PICTURE_JPG.ycoef=0;
		PICTURE_JPG.ucoef=0;
		PICTURE_JPG.vcoef=0;
		PICTURE_JPG.BitPos=0;
		PICTURE_JPG.CurByte=0;
	}
	switch(PICTURE_JPG.comp_num)
	{
	case 3:
		lpMCUBuffer=PICTURE_JPG.MCUBuffer;
		for (i=0;i<PICTURE_JPG.SampRate_Y_H*PICTURE_JPG.SampRate_Y_V;i++) {
			funcret=HufBlock(PICTURE_JPG.YDcIndex,PICTURE_JPG.YAcIndex);
			if (funcret!=PFUNC_OK) return funcret;
			PICTURE_JPG.BlockBuffer[0]=PICTURE_JPG.BlockBuffer[0]+PICTURE_JPG.ycoef;
			PICTURE_JPG.ycoef=PICTURE_JPG.BlockBuffer[0];
			for (j=0;j<64;j++) {
				*lpMCUBuffer++=PICTURE_JPG.BlockBuffer[j];
			}
		}
		for (i=0;i<PICTURE_JPG.SampRate_U_H*PICTURE_JPG.SampRate_U_V;i++) {
			funcret=HufBlock(PICTURE_JPG.UVDcIndex,PICTURE_JPG.UVAcIndex);
			if (funcret!=PFUNC_OK) return funcret;
			PICTURE_JPG.BlockBuffer[0]=PICTURE_JPG.BlockBuffer[0]+PICTURE_JPG.ucoef;
			PICTURE_JPG.ucoef=PICTURE_JPG.BlockBuffer[0];
			for (j=0;j<64;j++) {
				*lpMCUBuffer++=PICTURE_JPG.BlockBuffer[j];
			}
		}
		for (i=0;i<PICTURE_JPG.SampRate_V_H*PICTURE_JPG.SampRate_V_V;i++) {
			funcret=HufBlock(PICTURE_JPG.UVDcIndex,PICTURE_JPG.UVAcIndex);
			if (funcret!=PFUNC_OK) return funcret;
			PICTURE_JPG.BlockBuffer[0]=PICTURE_JPG.BlockBuffer[0]+PICTURE_JPG.vcoef;
			PICTURE_JPG.vcoef=PICTURE_JPG.BlockBuffer[0];
			for (j=0;j<64;j++) {
				*lpMCUBuffer++=PICTURE_JPG.BlockBuffer[j];
			}
		}
		break;
	case 1:
		lpMCUBuffer=PICTURE_JPG.MCUBuffer;
		funcret=HufBlock(PICTURE_JPG.YDcIndex,PICTURE_JPG.YAcIndex);
		if (funcret!=PFUNC_OK) return funcret;
		PICTURE_JPG.BlockBuffer[0]=PICTURE_JPG.BlockBuffer[0]+PICTURE_JPG.ycoef;
		PICTURE_JPG.ycoef=PICTURE_JPG.BlockBuffer[0];
		for (j=0;j<64;j++) {
			*lpMCUBuffer++=PICTURE_JPG.BlockBuffer[j];
		}
		for (i=0;i<128;i++) {
			*lpMCUBuffer++=0;
		}
		break;
	default:
		return PFUNC_FORMAT_ERROR;
	}
	return PFUNC_OK;
}

//--------------------------------------------------------------
int HufBlock(PBYTE dchufindex,PBYTE achufindex)
{
	short count=0;
	short i;
	int funcret;

	PICTURE_JPG.HufTabIndex=dchufindex;
	funcret=DecodeElement();
	if(funcret!=PFUNC_OK) return funcret;

	PICTURE_JPG.BlockBuffer[count++]=PICTURE_JPG.vvalue;
	PICTURE_JPG.HufTabIndex=achufindex;
	while (count<64) {
		funcret=DecodeElement();
		if(funcret!=PFUNC_OK) return funcret;
		if ((PICTURE_JPG.rrun==0)&&(PICTURE_JPG.vvalue==0)) {
			for (i=count;i<64;i++) {
				PICTURE_JPG.BlockBuffer[i]=0;
			}
			count=64;
		}
		else {
			for (i=0;i<PICTURE_JPG.rrun;i++) {
				PICTURE_JPG.BlockBuffer[count++]=0;
			}
			PICTURE_JPG.BlockBuffer[count++]=PICTURE_JPG.vvalue;
		}
	}
	return PFUNC_OK;
}

//--------------------------------------------------------------
int DecodeElement(void)
{
	int thiscode,tempcode;
	unsigned short temp,valueex;
	short codelen;
	PBYTE hufexbyte,runsize,tempsize,sign;
	PBYTE newbyte,lastbyte;

	if(PICTURE_JPG.BitPos>=1) {
		PICTURE_JPG.BitPos--;
		thiscode=(PBYTE)PICTURE_JPG.CurByte>>PICTURE_JPG.BitPos;
		PICTURE_JPG.CurByte=PICTURE_JPG.CurByte&PICTURE_JPG_AND[PICTURE_JPG.BitPos];
	}
	else {
		lastbyte=ReadByte();
		PICTURE_JPG.BitPos--;
		newbyte=PICTURE_JPG.CurByte&PICTURE_JPG_AND[PICTURE_JPG.BitPos];
		thiscode=lastbyte>>7;
		PICTURE_JPG.CurByte=newbyte;
	}
	codelen=1;

	while ((thiscode<PICTURE_JPG.huf_min_value[PICTURE_JPG.HufTabIndex][codelen-1])||
			(PICTURE_JPG.code_len_table[PICTURE_JPG.HufTabIndex][codelen-1]==0)||
			(thiscode>PICTURE_JPG.huf_max_value[PICTURE_JPG.HufTabIndex][codelen-1])) {
		if(PICTURE_JPG.BitPos>=1) {
			PICTURE_JPG.BitPos--;
			tempcode=(PBYTE)PICTURE_JPG.CurByte>>PICTURE_JPG.BitPos;
			PICTURE_JPG.CurByte=PICTURE_JPG.CurByte&PICTURE_JPG_AND[PICTURE_JPG.BitPos];
		}
		else {
			lastbyte=ReadByte();
			PICTURE_JPG.BitPos--;
			newbyte=PICTURE_JPG.CurByte&PICTURE_JPG_AND[PICTURE_JPG.BitPos];
			tempcode=(PBYTE)lastbyte>>7;
			PICTURE_JPG.CurByte=newbyte;
		}
		thiscode=(thiscode<<1)+tempcode;
		codelen++;
		if(codelen>16)return PFUNC_FORMAT_ERROR;
	}
	temp=thiscode-PICTURE_JPG.huf_min_value[PICTURE_JPG.HufTabIndex][codelen-1]+PICTURE_JPG.code_pos_table[PICTURE_JPG.HufTabIndex][codelen-1];
	hufexbyte=(PBYTE)PICTURE_JPG.code_value_table[PICTURE_JPG.HufTabIndex][temp];
	PICTURE_JPG.rrun=(short)(hufexbyte>>4);
	runsize=hufexbyte&0x0f;
	if(runsize==0) {
		PICTURE_JPG.vvalue=0;
		return PFUNC_OK;
	}
	tempsize=runsize;
	if(PICTURE_JPG.BitPos>=runsize) {
		PICTURE_JPG.BitPos-=runsize;
		valueex=(PBYTE)PICTURE_JPG.CurByte>>PICTURE_JPG.BitPos;
		PICTURE_JPG.CurByte=PICTURE_JPG.CurByte&PICTURE_JPG_AND[PICTURE_JPG.BitPos];
	}
	else {
		valueex=PICTURE_JPG.CurByte;
		tempsize-=PICTURE_JPG.BitPos;
		while(tempsize>8) {
			lastbyte=ReadByte();
			valueex=(valueex<<8)+(PBYTE)lastbyte;
			tempsize-=8;
		}
		lastbyte=ReadByte();
		PICTURE_JPG.BitPos-=tempsize;
		valueex=(valueex<<tempsize)+(lastbyte>>PICTURE_JPG.BitPos);
		PICTURE_JPG.CurByte=lastbyte&PICTURE_JPG_AND[PICTURE_JPG.BitPos];
	}
	sign=valueex>>(runsize-1);
	if(sign) {
		PICTURE_JPG.vvalue=valueex;
	}
	else {
		valueex=valueex^0xffff;
		temp=0xffff<<runsize;
		PICTURE_JPG.vvalue=-(short)(valueex^temp);
	}
	return PFUNC_OK;
}

//--------------------------------------------------------------
void IQtIZzMCUComponent(short flag)
{
	short H,VV;
	short i,j;
	short *pQtZzMCUBuffer;
	short  *pMCUBuffer;

	switch(flag){
	case 0:
		H=PICTURE_JPG.SampRate_Y_H;
		VV=PICTURE_JPG.SampRate_Y_V;
		pMCUBuffer=PICTURE_JPG.MCUBuffer;
		pQtZzMCUBuffer=PICTURE_JPG.QtZzMCUBuffer;
		break;
	case 1:
		H=PICTURE_JPG.SampRate_U_H;
		VV=PICTURE_JPG.SampRate_U_V;
		pMCUBuffer=PICTURE_JPG.MCUBuffer+PICTURE_JPG.Y_in_MCU*64;
		pQtZzMCUBuffer=PICTURE_JPG.QtZzMCUBuffer+PICTURE_JPG.Y_in_MCU*64;
		break;
	case 2:
		H=PICTURE_JPG.SampRate_V_H;
		VV=PICTURE_JPG.SampRate_V_V;
		pMCUBuffer=PICTURE_JPG.MCUBuffer+(PICTURE_JPG.Y_in_MCU+PICTURE_JPG.U_in_MCU)*64;
		pQtZzMCUBuffer=PICTURE_JPG.QtZzMCUBuffer+(PICTURE_JPG.Y_in_MCU+PICTURE_JPG.U_in_MCU)*64;
		break;
	}
	for(i=0;i<VV;i++) {
		for (j=0;j<H;j++) {
			IQtIZzBlock(pMCUBuffer+(i*H+j)*64,pQtZzMCUBuffer+(i*H+j)*64,flag);
		}
	}
}

//--------------------------------------------------------------
void IQtIZzBlock(short  *s ,short * d,short flag)
{
	short i,j;
	short tag;
	short *pQt;
	int buffer2[8][8];
	int *buffer1;
	short offset;

	switch(flag)
	{
	case 0:
		pQt=PICTURE_JPG.YQtTable;
		offset=128;
		break;
	case 1:
		pQt=PICTURE_JPG.UQtTable;
		offset=0;
		break;
	case 2:
		pQt=PICTURE_JPG.VQtTable;
		offset=0;
		break;
	}

	for(i=0;i<8;i++) {
		for(j=0;j<8;j++) {
			tag=PICTURE_JPG_ZZ[i][j];
			buffer2[i][j]=(int)s[tag]*(int)pQt[tag];
		}
	}

	buffer1=(int *)buffer2;
	Fast_IDCT(buffer1);
	for(i=0;i<8;i++) {
		for(j=0;j<8;j++) {
			d[i*8+j]=buffer2[i][j]+offset;
		}
	}
}

//--------------------------------------------------------------
void Fast_IDCT(int * block)
{
	short i;

	for (i=0; i<8; i++)idctrow(block+8*i);
	for (i=0; i<8; i++)idctcol(block+i);
}

//--------------------------------------------------------------
PBYTE ReadByte(void)
{
	PBYTE  i;

	i=*(PICTURE_JPG.lp++);
	PICTURE_JPG.lp-=P_Cal(PICTURE_JPG.lp);
	if(i==0xff)PICTURE_JPG.lp++;
	PICTURE_JPG.BitPos=8;
	PICTURE_JPG.CurByte=i;
	return i;
}

//--------------------------------------------------------------
void Initialize_Fast_IDCT(void)
{
	short i;

	PICTURE_JPG.iclp = PICTURE_JPG.iclip+512;
	for (i= -512; i<512; i++) {
		PICTURE_JPG.iclp[i] = (i<-256) ? -256 : ((i>255) ? 255 : i);
	}
}

//--------------------------------------------------------------
void idctrow(int * blk)
{
	int x0, x1, x2, x3, x4, x5, x6, x7, x8;

	if (!((x1 = blk[4]<<11) | (x2 = blk[6]) | (x3 = blk[2]) |
			(x4 = blk[1]) | (x5 = blk[7]) | (x6 = blk[5]) | (x7 = blk[3]))) {
		blk[0]=blk[1]=blk[2]=blk[3]=blk[4]=blk[5]=blk[6]=blk[7]=blk[0]<<3;
		return;
	}

	x0 = (blk[0]<<11) + 128;

	x8 = PW7*(x4+x5);
	x4 = x8 + (PW1-PW7)*x4;
	x5 = x8 - (PW1+PW7)*x5;
	x8 = PW3*(x6+x7);
	x6 = x8 - (PW3-PW5)*x6;
	x7 = x8 - (PW3+PW5)*x7;

	x8 = x0 + x1;
	x0 -= x1;
	x1 = PW6*(x3+x2);
	x2 = x1 - (PW2+PW6)*x2;
	x3 = x1 + (PW2-PW6)*x3;
	x1 = x4 + x6;
	x4 -= x6;
	x6 = x5 + x7;
	x5 -= x7;

	x7 = x8 + x3;
	x8 -= x3;
	x3 = x0 + x2;
	x0 -= x2;
	x2 = (181*(x4+x5)+128)>>8;
	x4 = (181*(x4-x5)+128)>>8;

	blk[0] = (x7+x1)>>8;
	blk[1] = (x3+x2)>>8;
	blk[2] = (x0+x4)>>8;
	blk[3] = (x8+x6)>>8;
	blk[4] = (x8-x6)>>8;
	blk[5] = (x0-x4)>>8;
	blk[6] = (x3-x2)>>8;
	blk[7] = (x7-x1)>>8;
}

//--------------------------------------------------------------
void idctcol(int * blk)
{
	int x0, x1, x2, x3, x4, x5, x6, x7, x8;

	if (!((x1 = (blk[8*4]<<8)) | (x2 = blk[8*6]) | (x3 = blk[8*2]) |
			(x4 = blk[8*1]) | (x5 = blk[8*7]) | (x6 = blk[8*5]) | (x7 = blk[8*3]))) {
		blk[8*0]=blk[8*1]=blk[8*2]=blk[8*3]=blk[8*4]=blk[8*5]=blk[8*6]=blk[8*7]=PICTURE_JPG.iclp[(blk[8*0]+32)>>6];
		return;
	}
	x0 = (blk[8*0]<<8) + 8192;

	x8 = PW7*(x4+x5) + 4;
	x4 = (x8+(PW1-PW7)*x4)>>3;
	x5 = (x8-(PW1+PW7)*x5)>>3;
	x8 = PW3*(x6+x7) + 4;
	x6 = (x8-(PW3-PW5)*x6)>>3;
	x7 = (x8-(PW3+PW5)*x7)>>3;

	x8 = x0 + x1;
	x0 -= x1;
	x1 = PW6*(x3+x2) + 4;
	x2 = (x1-(PW2+PW6)*x2)>>3;
	x3 = (x1+(PW2-PW6)*x3)>>3;
	x1 = x4 + x6;
	x4 -= x6;
	x6 = x5 + x7;
	x5 -= x7;

	x7 = x8 + x3;
	x8 -= x3;
	x3 = x0 + x2;
	x0 -= x2;
	x2 = (181*(x4+x5)+128)>>8;
	x4 = (181*(x4-x5)+128)>>8;

	blk[8*0] = PICTURE_JPG.iclp[(x7+x1)>>14];
	blk[8*1] = PICTURE_JPG.iclp[(x3+x2)>>14];
	blk[8*2] = PICTURE_JPG.iclp[(x0+x4)>>14];
	blk[8*3] = PICTURE_JPG.iclp[(x8+x6)>>14];
	blk[8*4] = PICTURE_JPG.iclp[(x8-x6)>>14];
	blk[8*5] = PICTURE_JPG.iclp[(x0-x4)>>14];
	blk[8*6] = PICTURE_JPG.iclp[(x3-x2)>>14];
	blk[8*7] = PICTURE_JPG.iclp[(x7-x1)>>14];
}



//--------------------------------------------------------------
// zeichnet ein Windows-BMP-File
// (file muss schon geöffnet sein)
// PORTRAIT  : linke obere Ecke = xpos,ypos
// LANDSCAPE : linke untere Ecke = xpos,ypos
// Return_wert :
//     0 , Bild gezeichnet
//  != 0 , fehler beim zeichnen
//--------------------------------------------------------------
PICTURE_ERR_t UB_Picture_DrawBmp(FIL *fileptr, uint16_t xpos, uint16_t ypos, uint8_t BuffNum)
{
  PICTURE_ERR_t ret_wert=0;
  FATFS_t check_fat;
  uint32_t read_size;
  uint8_t blue, green, red;
  uint16_t xn=0;
  uint16_t yn=0;
  uint16_t color;
  uint8_t picture_ready=0;

  myPictureFile=*fileptr;

  // BMP-Header prüfen
  ret_wert=P_Picture_Check_BMPHeader();

  if(ret_wert==PICTURE_OK)  {
    do {

      // Byte für "Blau" lesen
      blue=(picture_buf[PICTURE_BMP.akt_ptr]&0xF8); // 5bit
      PICTURE_BMP.akt_ptr++;
      if(PICTURE_BMP.akt_ptr>=PICTURE_BMP.bytes_in_buf) {
        // Puffer leer -> File nachladen
        check_fat=UB_Fatfs_ReadBlock(&myPictureFile,picture_buf,PICTURE_BUF_SIZE,&read_size);
        PICTURE_BMP.bytes_in_buf=read_size;
        PICTURE_BMP.akt_ptr=0;
        if(check_fat==FATFS_RD_BLOCK_ERR) picture_ready=1;
      }

      // Byte für "Grün" lesen
      green=(picture_buf[PICTURE_BMP.akt_ptr]&0xFC); // 6bit
      PICTURE_BMP.akt_ptr++;
      if(PICTURE_BMP.akt_ptr>=PICTURE_BMP.bytes_in_buf) {
        // Puffer leer -> File nachladen
        check_fat=UB_Fatfs_ReadBlock(&myPictureFile,picture_buf,PICTURE_BUF_SIZE,&read_size);
        PICTURE_BMP.bytes_in_buf=read_size;
        PICTURE_BMP.akt_ptr=0;
        if(check_fat==FATFS_RD_BLOCK_ERR) picture_ready=1;
      }

      // Byte für "Rot" lesen
      red=(picture_buf[PICTURE_BMP.akt_ptr]&0xF8); // 5bit
      PICTURE_BMP.akt_ptr++;
      if(PICTURE_BMP.akt_ptr>=PICTURE_BMP.bytes_in_buf) {
        // Puffer leer -> File nachladen
        check_fat=UB_Fatfs_ReadBlock(&myPictureFile,picture_buf,PICTURE_BUF_SIZE,&read_size);
        PICTURE_BMP.bytes_in_buf=read_size;
        PICTURE_BMP.akt_ptr=0;
        if(check_fat==FATFS_RD_BLOCK_ERR) picture_ready=1;
      }

      // Pixel auf Display zeichnen
      color = ((red<<8) | (green<<3) | (blue>>3));
      GFX_SetPixel(xn+xpos , PICTURE_BMP.height-yn-1+ypos , color , BuffNum);

      xn++;
      if(xn>=PICTURE_BMP.width) {
        // Neue Zeile
        xn=0;
        yn++;

        // Check ob BMP fertig gezeichnet
        if(yn>=PICTURE_BMP.height) {
          picture_ready=2;
        }
        else {
          PICTURE_BMP.akt_ptr+=PICTURE_BMP.spacer;
        }
      }
    }while(picture_ready==0);

    if(picture_ready==1) ret_wert=PICTURE_FILE_ERR;
  }

  return ret_wert;
}

PICTURE_ERR_t P_Picture_Check_BMPHeader(void)
{
  PICTURE_ERR_t ret_wert=PICTURE_FILE_ERR;
  FATFS_t check_fat;
  uint32_t read_size;
  uint32_t temp;

  check_fat=UB_Fatfs_ReadBlock(&myPictureFile,picture_buf,PICTURE_BUF_SIZE,&read_size);
  if((check_fat==FATFS_OK) || (check_fat==FATFS_EOF)) {
    // Filesize bei BMP muss > 54 Bytes sein
    if(read_size<54) return(PICTURE_SIZE_ERR);
    // Check auf BMP-ID : 'BM'
    if((picture_buf[0]!='B') || (picture_buf[1]!='M')) return(PICTURE_ID_ERR);
    PICTURE_BMP.offset=P_Picture_4Bytes(10);
    // Check auf Headersize : 40d
    temp=P_Picture_4Bytes(14);
    if(temp!=40) return(PICTURE_HEAD_ERR);
    // Check auf Breite und Hoehe
    PICTURE_BMP.width=P_Picture_4Bytes(18);
    PICTURE_BMP.height=P_Picture_4Bytes(22);
    if(PICTURE_BMP.width>LCD_MAXX) return(PICTURE_WIDTH_ERR);
    if(PICTURE_BMP.height>LCD_MAXY) return(PICTURE_HEIGHT_ERR);
    // Check auf BitPerPixel : 24d
    PICTURE_BMP.bpp=P_Picture_2Bytes(28);
    if(PICTURE_BMP.bpp!=24) return(PICTURE_BPP_ERR);
    // Check auf Kompression : keine
    PICTURE_BMP.compr=P_Picture_4Bytes(30);
    if(PICTURE_BMP.compr!=0) return(PICTURE_COMPR_ERR);
    // Variabeln setzen
    PICTURE_BMP.spacer=(PICTURE_BMP.width & 0x03);
    PICTURE_BMP.bytes_in_buf=read_size;
    PICTURE_BMP.akt_ptr=PICTURE_BMP.offset;
    ret_wert=PICTURE_OK;
  }
  else {
    ret_wert=PICTURE_FILE_ERR;
  }

  return(ret_wert);
}

uint32_t P_Picture_4Bytes(uint32_t start)
{
  uint32_t ret_wert=0;

  ret_wert|=(picture_buf[start]);
  ret_wert|=(picture_buf[start+1]<<8);
  ret_wert|=(picture_buf[start+2]<<16);
  ret_wert|=(picture_buf[start+3]<<24);

  return(ret_wert);
}

uint16_t P_Picture_2Bytes(uint32_t start)
{
  uint16_t ret_wert=0;

  ret_wert|=(picture_buf[start]);
  ret_wert|=(picture_buf[start+1]<<8);

  return(ret_wert);
}
