/***********************************************************************************************************************
MMBasic

Audio_F7.c

Handles all the audio related commands and functions for the STM32F7 version of MMBasic.


Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following 
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

************************************************************************************************************************/



#include <stdio.h>
#include <math.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

//--------------------------------------------------------------
// audio buffer
uint8_t *SDRAM_Mod_Load = (uint8_t *)MOD_MEMORY_START;
uint8_t *wave_ptr;
WAVE_SAMPLE_t WAVE_SAMPLE[MAX_WAVE_FILES];
WAVE_POLY_t WAVE_POLY;
uint32_t wave_load_adr=0;
uint16_t audio_buffer[AUDIO_BUFFER_SIZE];
//--------------------------------------------------------------
AUDIO_DrvTypeDef          *audio_drv;
SAI_HandleTypeDef         haudio_out_sai={0};



/********************************************************************************************************************************************
 custom commands and functions
 each function is responsible for decoding a command
 all function names are in the form cmd_xxxx() (for a basic command) or fun_xxxx() (for a basic function) so, if you want to search for the
 function responsible for the NAME command look for cmd_name

 There are 4 items of information that are setup before the command is run.
 All these are globals.

 int cmdtoken	This is the token number of the command (some commands can handle multiple
				statement types and this helps them differentiate)

 char *cmdline	This is the command line terminated with a zero char and trimmed of leading
				spaces.  It may exist anywhere in memory (or even ROM).

 char *nextstmt	This is a pointer to the next statement to be executed.  The only thing a
				command can do with it is save it or change it to some other location.

 char *CurrentLinePtr  This is read only and is set to NULL if the command is in immediate mode.

 The only actions a command can do to change the program flow is to change nextstmt or
 execute longjmp(mark, 1) if it wants to abort the program.

 ********************************************************************************************************************************************/


uint8_t Load_Wave(char* filename , uint16_t ObjectNum);
uint8_t Check_Wave(uint32_t start_adr, uint16_t ObjectNum);
uint32_t P_4Bytes(uint16_t start);
uint16_t P_2Bytes(uint16_t start);
void Play_Wave(uint16_t ObjectNum, uint16_t volume, uint8_t mode);
void Stop_Wave(uint16_t ObjectNum);
void P_ClearBufferComplete(void);
void P_FillBufferFirst(void);
void P_FillBufferSecond(void);

//--------------------------------------------------------------
void BSP_AUDIO_OUT_ClockConfig(SAI_HandleTypeDef *hsai, uint32_t AudioFreq, void *Params);
void BSP_AUDIO_OUT_MspInit(SAI_HandleTypeDef *hsai, void *Params);
void BSP_AUDIO_OUT_SetAudioFrameSlot(uint32_t AudioFrameSlot);
static void SAIx_Out_Init(uint32_t AudioFreq);
static void SAIx_Out_DeInit(void);

//--------------------------------------------------------------
// Load and play Wave-Files
// Syntax : Wave Load "file.wav", Objnumber
// Syntax : Wave Play Objnumber, Volume
// Syntax : Wave Loop Objnumber, Volume
// Syntax : Wave Stop Objnumber
// Syntax : Wave Clear
void cmd_wave(void){
	char *p;
	uint8_t n;
	uint8_t	LoadStatus = 0;

	// reset data
	if(wave_load_adr==0) {
	  for(n=0;n<MAX_WAVE_FILES;n++) {
		WAVE_SAMPLE[n].status=0;
	  }
	  WAVE_POLY.cnt=0;
	}

	// Syntax : Wave LOAD "file" objnum
	if(*cmdline == GetTokenValue("LOAD")) {
		char *fp;
		int objnumber = 0;

		p = cmdline + 1;                                            // step over the token
		skipspace(p);
		getargs(&p, 3, ",");
		if(argc != 3) error("Invalid number of parameters");
		fp = GetFileName(argv[0], NULL);
		objnumber = getinteger(argv[2]);
		if((objnumber < 0) || (objnumber >= MAX_WAVE_FILES)) error("ObjNumber out of range");
		if(WAVE_SAMPLE[objnumber].status>0) error("ObjNumber already defined");

		LoadStatus = Load_Wave(fp,objnumber);
		if(LoadStatus != 0) error("wave error");
		return;
	}

	// Syntax : Wave PLAY objnum,volume
	if((p = checkstring(cmdline, "PLAY")) != NULL) {
		int objnumber=0, volume;

		p = cmdline + 4;								// step over the token
		skipspace(p);
		getargs(&p, 3, ",");
		if(argc != 3) error("Invalid number of parameters");
		objnumber = getinteger(argv[0]);
		if((objnumber < 0) || (objnumber >= MAX_WAVE_FILES)) error("ObjNumber out of range");
		volume=getinteger(argv[2]);
		if((volume < 0) || (volume > 100)) error("volume out of range");
		if(WAVE_SAMPLE[objnumber].status<1) error("ObjNumber not ready");
		if(WAVE_SAMPLE[objnumber].status>1) return; // allready playing

		Play_Wave(objnumber, volume,2);
		return;
	}

	// Syntax : Wave LOOP objnum,volume
	if((p = checkstring(cmdline, "LOOP")) != NULL) {
		int objnumber=0, volume;

		p = cmdline + 4;								// step over the token
		skipspace(p);
		getargs(&p, 3, ",");
		if(argc != 3) error("Invalid number of parameters");
		objnumber = getinteger(argv[0]);
		if((objnumber < 0) || (objnumber >= MAX_WAVE_FILES)) error("ObjNumber out of range");
		volume=getinteger(argv[2]);
		if((volume < 0) || (volume > 100)) error("volume out of range");
		if(WAVE_SAMPLE[objnumber].status<1) error("ObjNumber not ready");
		if(WAVE_SAMPLE[objnumber].status>1) return; // allready playing

		Play_Wave(objnumber, volume,3);
		return;
	}

	// Syntax : Wave STOP objnum
	if((p = checkstring(cmdline, "STOP")) != NULL) {
		int objnumber=0;

		p = cmdline + 4;								// step over the token
		skipspace(p);
		getargs(&p, 3, ",");
		if(argc != 1) error("Invalid number of parameters");
		objnumber = getinteger(argv[0]);
		if((objnumber < 0) || (objnumber >= MAX_WAVE_FILES)) error("ObjNumber out of range");
		if(WAVE_SAMPLE[objnumber].status<1) error("ObjNumber not ready");
		if(WAVE_SAMPLE[objnumber].status==1) return; //not playing

		Stop_Wave(objnumber);
		return;
	}

	// Syntax : Wave Clear
	if((p = checkstring(cmdline, "CLEAR")) != NULL) {
		int n;

		if(WAVE_POLY.cnt>0) error("playing");

		// reset data
		wave_load_adr=0;
		for(n=0;n<MAX_WAVE_FILES;n++) {
			WAVE_SAMPLE[n].status=0;
		}
		WAVE_POLY.cnt=0;

		return;
	}
}

//--------------------------------------------------------------
uint8_t Load_Wave(char* filename , uint16_t ObjectNum)
{
	uint8_t ret_value=0,check=0;
	int			fn;
	uint32_t  fsize,n=0;

	if(WAVE_SAMPLE[ObjectNum].status>0) return 1;

	fn = FindFreeFileNbr();

	// File to read
	MMfopen(filename, "r", fn);
	if(MMerrno) return 3;

	fsize=GetFileLength(fn);

	if((fsize<(MOD_MEMORY_LENGTH-wave_load_adr)) && (fsize>60)) {
		for(n=0;n<fsize;n++) {
			SDRAM_Mod_Load[wave_load_adr+n] = MMfgetc(fn);
			if(n==50) {
				// after loading header -> check wave format
				check=Check_Wave(wave_load_adr, ObjectNum);
				if(check!=0) break; // error in header
			}
		}
	}
	else ret_value=1;

	MMfclose(fn);

	if(fsize!=n) ret_value=2;

	if(ret_value==0) wave_load_adr+=fsize; // for next sample


  return ret_value;
}


//--------------------------------------------------------------
void Play_Wave(uint16_t ObjectNum, uint16_t volume, uint8_t mode)
{
	uint32_t frq;
	uint8_t check;


	if(WAVE_POLY.cnt==0) {
	  WAVE_POLY.cnt=1;
	  WAVE_POLY.ch1=ObjectNum;
	  P_ClearBufferComplete();

	  frq=WAVE_SAMPLE[ObjectNum].samplerate/2; // mono
	  if(WAVE_SAMPLE[ObjectNum].channels==2) frq=WAVE_SAMPLE[ObjectNum].samplerate; // stereo

      check=UB_AUDIO_OUT_Init(OUTPUT_DEVICE_HEADPHONE, volume,frq);
	  if(check!=0) return;

	  WAVE_SAMPLE[ObjectNum].status=mode;
	  WAVE_SAMPLE[ObjectNum].play_adr=0;
	  check=UB_AUDIO_OUT_Play_Array(audio_buffer, AUDIO_BUFFER_SIZE*2);
	  if(check!=0) return;
	}
	else {
		// check if same settings as ch1
		if(WAVE_SAMPLE[WAVE_POLY.ch1].channels!=WAVE_SAMPLE[ObjectNum].channels) return;
		if(WAVE_SAMPLE[WAVE_POLY.ch1].samplerate!=WAVE_SAMPLE[ObjectNum].samplerate) return;

		if(WAVE_POLY.cnt==1) {
		  WAVE_POLY.ch2=ObjectNum;
		  WAVE_SAMPLE[ObjectNum].status=mode;
		  WAVE_SAMPLE[ObjectNum].play_adr=0;
		  WAVE_POLY.cnt=2;
		}
		else if(WAVE_POLY.cnt==2) {
		  WAVE_POLY.ch3=ObjectNum;
		  WAVE_SAMPLE[ObjectNum].status=mode;
		  WAVE_SAMPLE[ObjectNum].play_adr=0;
		  WAVE_POLY.cnt=3;
		}
		else if(WAVE_POLY.cnt==3) {
		  WAVE_POLY.ch4=ObjectNum;
		  WAVE_SAMPLE[ObjectNum].status=mode;
		  WAVE_SAMPLE[ObjectNum].play_adr=0;
		  WAVE_POLY.cnt=4;
		}
		else return;
	}
}

//--------------------------------------------------------------
void Stop_Wave(uint16_t ObjectNum)
{
	if(WAVE_POLY.cnt==1) {
		WAVE_SAMPLE[ObjectNum].status=1;
		WAVE_POLY.cnt=0;
		UB_AUDIO_OUT_Stop();
	}
	else if(WAVE_POLY.cnt==2) {
		if(ObjectNum==WAVE_POLY.ch2) {
			WAVE_POLY.cnt=1;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
		else {
			WAVE_POLY.ch1=WAVE_POLY.ch2;
			WAVE_POLY.cnt=1;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
	}
	else if(WAVE_POLY.cnt==3) {
		if(ObjectNum==WAVE_POLY.ch3) {
			WAVE_POLY.cnt=2;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
		else if(ObjectNum==WAVE_POLY.ch2) {
			WAVE_POLY.ch2=WAVE_POLY.ch3;
			WAVE_POLY.cnt=2;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
		else {
			WAVE_POLY.ch1=WAVE_POLY.ch2;
			WAVE_POLY.ch2=WAVE_POLY.ch3;
			WAVE_POLY.cnt=2;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
	}
	else if(WAVE_POLY.cnt==4) {
		if(ObjectNum==WAVE_POLY.ch4) {
			WAVE_POLY.cnt=3;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
		else if(ObjectNum==WAVE_POLY.ch3) {
			WAVE_POLY.ch3=WAVE_POLY.ch4;
			WAVE_POLY.cnt=3;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
		else if(ObjectNum==WAVE_POLY.ch2) {
			WAVE_POLY.ch2=WAVE_POLY.ch3;
			WAVE_POLY.ch3=WAVE_POLY.ch4;
			WAVE_POLY.cnt=3;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
		else {
			WAVE_POLY.ch1=WAVE_POLY.ch2;
			WAVE_POLY.ch2=WAVE_POLY.ch3;
			WAVE_POLY.ch3=WAVE_POLY.ch4;
			WAVE_POLY.cnt=3;
			WAVE_SAMPLE[ObjectNum].status=1;
		}
	}
}

//--------------------------------------------------------------
uint8_t Check_Wave(uint32_t start_adr, uint16_t ObjectNum)
{
  uint32_t offset=0,temp=0;

  WAVE_SAMPLE[ObjectNum].status=0;
  WAVE_SAMPLE[ObjectNum].start_adr=start_adr;
  WAVE_SAMPLE[ObjectNum].play_adr=0;

  wave_ptr=&SDRAM_Mod_Load[start_adr];

  // check auf "RIFF-ID"
  if((wave_ptr[0]!='R') || (wave_ptr[1]!='I') || (wave_ptr[2]!='F') || (wave_ptr[3]!='F')) return(2);

  // file länge auslesen (egal)
  //WAVE_SAMPLE[ObjectNum].file_len=P_4Bytes(4);

  // check auf "WAV-ID"
  if((wave_ptr[8]!='W') || (wave_ptr[9]!='A') || (wave_ptr[10]!='V') || (wave_ptr[11]!='E')) return(3);

  // check auf "fmt-ID"
  if((wave_ptr[12]!='f') || (wave_ptr[13]!='m') || (wave_ptr[14]!='t') || (wave_ptr[15]!=' ')) return(4);

  // fmt laenge auslesen (16d oder 18d)
  temp=P_4Bytes(16);
  if((temp!=16) && (temp!=18)) return(5);
  if(temp==16) offset=0;
  if(temp==18) offset=14;

  // File-Typ auslesen (0x01=PCM)
  temp=P_2Bytes(20);
  if(temp!=0x01) return(6);

  // Anzahl Kanäle auslesen (0x01=Mono, 0x02=Stereo)
  WAVE_SAMPLE[ObjectNum].channels=P_2Bytes(22);
  if((WAVE_SAMPLE[ObjectNum].channels<1) || (WAVE_SAMPLE[ObjectNum].channels>2)) return(7);

  // Sample Rate auslesen (8kHz bis 48kHz)
  WAVE_SAMPLE[ObjectNum].samplerate=P_4Bytes(24);
  if((WAVE_SAMPLE[ObjectNum].samplerate<8000) || (WAVE_SAMPLE[ObjectNum].samplerate>48000))  return(8);

  // Byterate auslesen (in Bytes/sec)
  //WAVE_SAMPLE[ObjectNum].byterate=P_4Bytes(28);

  // Framesize auslesen (1,2,4)
  temp=P_2Bytes(32);
  if((temp!=1) && (temp!=2) && (temp!=4)) return(9);

  // Bits pro Sample auslesen (16d)
  temp=P_2Bytes(34);
  if(temp!=16) return(10);

  // check auf "DATA-ID"
  if((wave_ptr[36+offset]!='d') || (wave_ptr[37+offset]!='a') || (wave_ptr[38+offset]!='t') || (wave_ptr[39+offset]!='a')) return(11);

  // Data Länge auslesen
  WAVE_SAMPLE[ObjectNum].data_len=P_4Bytes(40+offset);

  // Data-Start Adresse setzen
  WAVE_SAMPLE[ObjectNum].start_adr+=44+offset;
  WAVE_SAMPLE[ObjectNum].status=1;

  return 0;
}


//--------------------------------------------------------------
uint32_t P_4Bytes(uint16_t start)
{
  uint32_t ret_wert=0;

  ret_wert|=(wave_ptr[start]);
  ret_wert|=(wave_ptr[start+1]<<8);
  ret_wert|=(wave_ptr[start+2]<<16);
  ret_wert|=(wave_ptr[start+3]<<24);

  return(ret_wert);
}


//--------------------------------------------------------------
uint16_t P_2Bytes(uint16_t start)
{
  uint16_t ret_wert=0;

  ret_wert|=(wave_ptr[start]);
  ret_wert|=(wave_ptr[start+1]<<8);

  return(ret_wert);
}

//--------------------------------------------------------------
void P_ClearBufferComplete(void)
{
  uint32_t n;

  for(n=0;n<AUDIO_BUFFER_SIZE;n++) {
	  audio_buffer[n]=0;
  }
}

//--------------------------------------------------------------
void P_FillBufferFirst(void)
{
  uint8_t lo,hi;
  uint32_t n;
  uint8_t nr1=0,nr2=0,nr3=0,nr4=0;
  uint32_t pos1,pos2,pos3,pos4;
  uint32_t adr1,adr2,adr3,adr4;
  int16_t l1,r1,l2,r2,l3,r3,l4,r4;
  uint8_t *ptr1,*ptr2,*ptr3,*ptr4;

  if(WAVE_POLY.cnt>0) {
	nr1=WAVE_POLY.ch1;
    adr1=WAVE_SAMPLE[nr1].start_adr;
    pos1=WAVE_SAMPLE[nr1].play_adr;
    ptr1=&SDRAM_Mod_Load[adr1];
    if((WAVE_SAMPLE[nr1].data_len-pos1)<AUDIO_BUFFER_SIZE) {
      if(WAVE_SAMPLE[nr1].status==2) Stop_Wave(nr1);
    }
  }
  if(WAVE_POLY.cnt>1) {
	nr2=WAVE_POLY.ch2;
    adr2=WAVE_SAMPLE[nr2].start_adr;
    pos2=WAVE_SAMPLE[nr2].play_adr;
    ptr2=&SDRAM_Mod_Load[adr2];
    if((WAVE_SAMPLE[nr2].data_len-pos2)<AUDIO_BUFFER_SIZE) {
      if(WAVE_SAMPLE[nr2].status==2) Stop_Wave(nr2);
    }
  }
  if(WAVE_POLY.cnt>2) {
	nr3=WAVE_POLY.ch3;
    adr3=WAVE_SAMPLE[nr3].start_adr;
    pos3=WAVE_SAMPLE[nr3].play_adr;
    ptr3=&SDRAM_Mod_Load[adr3];
    if((WAVE_SAMPLE[nr3].data_len-pos3)<AUDIO_BUFFER_SIZE) {
      if(WAVE_SAMPLE[nr3].status==2) Stop_Wave(nr3);
    }
  }
  if(WAVE_POLY.cnt>3) {
	nr4=WAVE_POLY.ch4;
    adr4=WAVE_SAMPLE[nr4].start_adr;
    pos4=WAVE_SAMPLE[nr4].play_adr;
    ptr4=&SDRAM_Mod_Load[adr4];
    if((WAVE_SAMPLE[nr4].data_len-pos4)<AUDIO_BUFFER_SIZE) {
      if(WAVE_SAMPLE[nr4].status==2) Stop_Wave(nr4);
    }
  }

  if(WAVE_SAMPLE[nr1].channels==1) {
    for(n=0;n<AUDIO_BUFFER_HALF;n++) {
      if(WAVE_POLY.cnt>0) {
        lo=ptr1[pos1];hi=ptr1[pos1+1];l1=(hi<<8)|lo;
        pos1+=2;
        if(pos1>=WAVE_SAMPLE[nr1].data_len) pos1=0;
      }
      else l1=0;
      if(WAVE_POLY.cnt>1) {
        lo=ptr2[pos2];hi=ptr2[pos2+1];l2=(hi<<8)|lo;
        pos2+=2;
        if(pos2>=WAVE_SAMPLE[nr2].data_len) pos2=0;
      }
      else l2=0;
      if(WAVE_POLY.cnt>2) {
        lo=ptr3[pos3];hi=ptr3[pos3+1];l3=(hi<<8)|lo;
        pos3+=2;
        if(pos3>=WAVE_SAMPLE[nr3].data_len) pos3=0;
      }
      else l3=0;
      if(WAVE_POLY.cnt>3) {
        lo=ptr4[pos4];hi=ptr4[pos4+1];l4=(hi<<8)|lo;
        pos4+=2;
        if(pos4>=WAVE_SAMPLE[nr4].data_len) pos4=0;
      }
      else l4=0;
      audio_buffer[n]=(l1>>2)+(l2>>2)+(l3>>2)+(l4>>2);
    }
  }
  else {
    for(n=0;n<AUDIO_BUFFER_HALF;n+=2) {
      if(WAVE_POLY.cnt>0) {
        lo=ptr1[pos1];hi=ptr1[pos1+1];l1=(hi<<8)|lo;
        lo=ptr1[pos1+2];hi=ptr1[pos1+3];r1=(hi<<8)|lo;
        pos1+=4;
        if(pos1>=WAVE_SAMPLE[nr1].data_len) pos1=0;
      }
      else {
        l1=0;r1=0;
      }
      if(WAVE_POLY.cnt>1) {
        lo=ptr2[pos2];hi=ptr2[pos2+1];l2=(hi<<8)|lo;
        lo=ptr2[pos2+2];hi=ptr2[pos2+3];r2=(hi<<8)|lo;
        pos2+=4;
        if(pos2>=WAVE_SAMPLE[nr2].data_len) pos2=0;
      }
      else {
    	l2=0;r2=0;
      }
      if(WAVE_POLY.cnt>2) {
        lo=ptr3[pos3];hi=ptr3[pos3+1];l3=(hi<<8)|lo;
        lo=ptr3[pos3+2];hi=ptr3[pos3+3];r3=(hi<<8)|lo;
        pos3+=4;
        if(pos3>=WAVE_SAMPLE[nr3].data_len) pos3=0;
      }
      else {
    	l3=0;r3=0;
      }
      if(WAVE_POLY.cnt>3) {
        lo=ptr4[pos4];hi=ptr4[pos4+1];l4=(hi<<8)|lo;
        lo=ptr4[pos4+2];hi=ptr4[pos4+3];r4=(hi<<8)|lo;
        pos4+=4;
        if(pos4>=WAVE_SAMPLE[nr4].data_len) pos4=0;
      }
      else {
    	l4=0;r4=0;
      }
      audio_buffer[n]=(l1>>2)+(l2>>2)+(l3>>2)+(l4>>2);
      audio_buffer[n+1]=(r1>>2)+(r2>>2)+(r3>>2)+(r4>>2);
    }
  }

  if(WAVE_POLY.cnt>0) WAVE_SAMPLE[nr1].play_adr=pos1;
  if(WAVE_POLY.cnt>1) WAVE_SAMPLE[nr2].play_adr=pos2;
  if(WAVE_POLY.cnt>2) WAVE_SAMPLE[nr3].play_adr=pos3;
  if(WAVE_POLY.cnt>3) WAVE_SAMPLE[nr4].play_adr=pos4;
}


//--------------------------------------------------------------
void P_FillBufferSecond(void)
{
  uint8_t lo,hi;
  uint32_t n;
  uint8_t nr1=0,nr2=0,nr3=0,nr4=0;
  uint32_t pos1,pos2,pos3,pos4;
  uint32_t adr1,adr2,adr3,adr4;
  int16_t l1,r1,l2,r2,l3,r3,l4,r4;
  uint8_t *ptr1,*ptr2,*ptr3,*ptr4;

  if(WAVE_POLY.cnt>0) {
	nr1=WAVE_POLY.ch1;
    adr1=WAVE_SAMPLE[nr1].start_adr;
    pos1=WAVE_SAMPLE[nr1].play_adr;
    ptr1=&SDRAM_Mod_Load[adr1];
    if((WAVE_SAMPLE[nr1].data_len-pos1)<AUDIO_BUFFER_SIZE) {
      if(WAVE_SAMPLE[nr1].status==2) Stop_Wave(nr1);
    }
  }
  if(WAVE_POLY.cnt>1) {
	nr2=WAVE_POLY.ch2;
    adr2=WAVE_SAMPLE[nr2].start_adr;
    pos2=WAVE_SAMPLE[nr2].play_adr;
    ptr2=&SDRAM_Mod_Load[adr2];
    if((WAVE_SAMPLE[nr2].data_len-pos2)<AUDIO_BUFFER_SIZE) {
      if(WAVE_SAMPLE[nr2].status==2) Stop_Wave(nr2);
    }
  }
  if(WAVE_POLY.cnt>2) {
	nr3=WAVE_POLY.ch3;
    adr3=WAVE_SAMPLE[nr3].start_adr;
    pos3=WAVE_SAMPLE[nr3].play_adr;
    ptr3=&SDRAM_Mod_Load[adr3];
    if((WAVE_SAMPLE[nr3].data_len-pos3)<AUDIO_BUFFER_SIZE) {
      if(WAVE_SAMPLE[nr3].status==2) Stop_Wave(nr3);
    }
  }
  if(WAVE_POLY.cnt>3) {
	nr4=WAVE_POLY.ch4;
    adr4=WAVE_SAMPLE[nr4].start_adr;
    pos4=WAVE_SAMPLE[nr4].play_adr;
    ptr4=&SDRAM_Mod_Load[adr4];
    if((WAVE_SAMPLE[nr4].data_len-pos4)<AUDIO_BUFFER_SIZE) {
      if(WAVE_SAMPLE[nr4].status==2) Stop_Wave(nr4);
    }
  }

  if(WAVE_SAMPLE[nr1].channels==1) {
    for(n=AUDIO_BUFFER_HALF;n<AUDIO_BUFFER_SIZE;n++) {
      if(WAVE_POLY.cnt>0) {
        lo=ptr1[pos1];hi=ptr1[pos1+1];l1=(hi<<8)|lo;
        pos1+=2;
        if(pos1>=WAVE_SAMPLE[nr1].data_len) pos1=0;
      }
      else l1=0;
      if(WAVE_POLY.cnt>1) {
        lo=ptr2[pos2];hi=ptr2[pos2+1];l2=(hi<<8)|lo;
        pos2+=2;
        if(pos2>=WAVE_SAMPLE[nr2].data_len) pos2=0;
      }
      else l2=0;
      if(WAVE_POLY.cnt>2) {
        lo=ptr3[pos3];hi=ptr3[pos3+1];l3=(hi<<8)|lo;
        pos3+=2;
        if(pos3>=WAVE_SAMPLE[nr3].data_len) pos3=0;
      }
      else l3=0;
      if(WAVE_POLY.cnt>3) {
        lo=ptr4[pos4];hi=ptr4[pos4+1];l4=(hi<<8)|lo;
        pos4+=2;
        if(pos4>=WAVE_SAMPLE[nr4].data_len) pos4=0;
      }
      else l4=0;
      audio_buffer[n]=(l1>>2)+(l2>>2)+(l3>>2)+(l4>>2);
    }
  }
  else {
    for(n=AUDIO_BUFFER_HALF;n<AUDIO_BUFFER_SIZE;n+=2) {
      if(WAVE_POLY.cnt>0) {
        lo=ptr1[pos1];hi=ptr1[pos1+1];l1=(hi<<8)|lo;
        lo=ptr1[pos1+2];hi=ptr1[pos1+3];r1=(hi<<8)|lo;
        pos1+=4;
        if(pos1>=WAVE_SAMPLE[nr1].data_len) pos1=0;
      }
      else {
      	l1=0;r1=0;
      }
      if(WAVE_POLY.cnt>1) {
        lo=ptr2[pos2];hi=ptr2[pos2+1];l2=(hi<<8)|lo;
        lo=ptr2[pos2+2];hi=ptr2[pos2+3];r2=(hi<<8)|lo;
        pos2+=4;
        if(pos2>=WAVE_SAMPLE[nr2].data_len) pos2=0;
      }
      else {
    	l2=0;r2=0;
      }
      if(WAVE_POLY.cnt>2) {
        lo=ptr3[pos3];hi=ptr3[pos3+1];l3=(hi<<8)|lo;
        lo=ptr3[pos3+2];hi=ptr3[pos3+3];r3=(hi<<8)|lo;
        pos3+=4;
        if(pos3>=WAVE_SAMPLE[nr3].data_len) pos3=0;
      }
      else {
    	l3=0;r3=0;
      }
      if(WAVE_POLY.cnt>3) {
        lo=ptr4[pos4];hi=ptr4[pos4+1];l4=(hi<<8)|lo;
        lo=ptr4[pos4+2];hi=ptr4[pos4+3];r4=(hi<<8)|lo;
        pos4+=4;
        if(pos4>=WAVE_SAMPLE[nr4].data_len) pos4=0;
      }
      else {
    	l4=0;r4=0;
      }
      audio_buffer[n]=(l1>>2)+(l2>>2)+(l3>>2)+(l4>>2);
      audio_buffer[n+1]=(r1>>2)+(r2>>2)+(r3>>2)+(r4>>2);
    }
  }

  if(WAVE_POLY.cnt>0) WAVE_SAMPLE[nr1].play_adr=pos1;
  if(WAVE_POLY.cnt>1) WAVE_SAMPLE[nr2].play_adr=pos2;
  if(WAVE_POLY.cnt>2) WAVE_SAMPLE[nr3].play_adr=pos3;
  if(WAVE_POLY.cnt>3) WAVE_SAMPLE[nr4].play_adr=pos4;
}

//--------------------------------------------------------------
// ISR called at Half Transfer complete (Audio OUT)
//--------------------------------------------------------------
void HAL_SAI_TxHalfCpltCallback(SAI_HandleTypeDef *hsai)
{
  // check if wav playing
  if(WAVE_POLY.cnt>0) {
    // refill first half of the buffer
    P_FillBufferFirst();
  }
}

//--------------------------------------------------------------
// ISR called at Transfer complete (Audio OUT)
//--------------------------------------------------------------
void HAL_SAI_TxCpltCallback(SAI_HandleTypeDef *hsai)
{
  // check if wav playing
  if(WAVE_POLY.cnt>0) {
    // refill second half of the buffer
    P_FillBufferSecond();
  }
}

//--------------------------------------------------------------
uint8_t UB_AUDIO_OUT_Init(uint16_t device, uint8_t volume, uint32_t frq)
{
  uint8_t ret = 1;
  uint32_t deviceid = 0x00;


  /* Disable SAI */
  SAIx_Out_DeInit();

  /* PLL clock is set depending on the AudioFreq (44.1khz vs 48khz groups) */
  BSP_AUDIO_OUT_ClockConfig(&haudio_out_sai, frq, NULL);

  /* SAI data transfer preparation:
  Prepare the Media to be used for the audio transfer from memory to SAI peripheral */
  haudio_out_sai.Instance = AUDIO_OUT_SAIx;
  if(HAL_SAI_GetState(&haudio_out_sai) == HAL_SAI_STATE_RESET)
  {
    /* Init the SAI MSP: this __weak function can be redefined by the application*/
    BSP_AUDIO_OUT_MspInit(&haudio_out_sai, NULL);
  }
  SAIx_Out_Init(frq);


  /* wm8994 codec initialization */
  deviceid = wm8994_drv.ReadID(WM8994_I2C_ADDRESS);

  if((deviceid) == WM8994_ID)
  {
    /* Reset the Codec Registers */
    wm8994_drv.Reset(WM8994_I2C_ADDRESS);
    /* Initialize the audio driver structure */
    audio_drv = &wm8994_drv;
    ret = 0;
  }
  else
  {
    ret = 1;
  }

  if(ret == 0)
  {
    /* Initialize the codec internal registers */
    audio_drv->Init(WM8994_I2C_ADDRESS, device, volume, frq);


    BSP_AUDIO_OUT_SetAudioFrameSlot(CODEC_AUDIOFRAME_SLOT_02);
  }

  return ret;
}


//--------------------------------------------------------------
uint8_t UB_AUDIO_OUT_Play_Array(uint16_t* pBuffer, uint32_t size)
{

  /* Call the audio Codec Play function */
  if(audio_drv->Play(WM8994_I2C_ADDRESS, pBuffer, size) != 0)
  {
    return 1;
  }
  else
  {
    /* Update the Media layer and enable it for play */
    HAL_SAI_Transmit_DMA(&haudio_out_sai, (uint8_t*) pBuffer, DMA_MAX(size / 2));

    return 0;
  }
}

//--------------------------------------------------------------
uint8_t UB_AUDIO_OUT_Stop(void)
{
  /* Call the Media layer stop function */
  HAL_SAI_DMAStop(&haudio_out_sai);

  /* Call Audio Codec Stop function */
  if(audio_drv->Stop(WM8994_I2C_ADDRESS, CODEC_PDWN_SW) != 0)
  {
    return 1;
  }
  else
  {
    /* Return AUDIO_OK when all operations are correctly done */
    return 0;
  }
}

//--------------------------------------------------------------
__weak void BSP_AUDIO_OUT_ClockConfig(SAI_HandleTypeDef *hsai, uint32_t AudioFreq, void *Params)
{
  RCC_PeriphCLKInitTypeDef RCC_ExCLKInitStruct;

  HAL_RCCEx_GetPeriphCLKConfig(&RCC_ExCLKInitStruct);

  /* Set the PLL configuration according to the audio frequency */
  if((AudioFreq == AUDIO_FREQUENCY_11K) || (AudioFreq == AUDIO_FREQUENCY_22K) || (AudioFreq == AUDIO_FREQUENCY_44K))
  {
    /* Configure PLLSAI prescalers */
    /* PLLI2S_VCO: VCO_429M
    SAI_CLK(first level) = PLLI2S_VCO/PLLSAIQ = 429/2 = 214.5 Mhz
    SAI_CLK_x = SAI_CLK(first level)/PLLI2SDivQ = 214.5/19 = 11.289 Mhz */
    RCC_ExCLKInitStruct.PeriphClockSelection = RCC_PERIPHCLK_SAI2;
    RCC_ExCLKInitStruct.Sai2ClockSelection = RCC_SAI2CLKSOURCE_PLLI2S;
    RCC_ExCLKInitStruct.PLLI2S.PLLI2SP = 8;
    RCC_ExCLKInitStruct.PLLI2S.PLLI2SN = 429;
    RCC_ExCLKInitStruct.PLLI2S.PLLI2SQ = 2;
    RCC_ExCLKInitStruct.PLLI2SDivQ = 19;
    HAL_RCCEx_PeriphCLKConfig(&RCC_ExCLKInitStruct);
  }
  else /* AUDIO_FREQUENCY_8K, AUDIO_FREQUENCY_16K, AUDIO_FREQUENCY_48K), AUDIO_FREQUENCY_96K */
  {
    /* SAI clock config
    PLLI2S_VCO: VCO_344M
    SAI_CLK(first level) = PLLI2S_VCO/PLLSAIQ = 344/7 = 49.142 Mhz
    SAI_CLK_x = SAI_CLK(first level)/PLLI2SDivQ = 49.142/1 = 49.142 Mhz */
    RCC_ExCLKInitStruct.PeriphClockSelection = RCC_PERIPHCLK_SAI2;
    RCC_ExCLKInitStruct.Sai2ClockSelection = RCC_SAI2CLKSOURCE_PLLI2S;
    RCC_ExCLKInitStruct.PLLI2S.PLLI2SP = 8;
    RCC_ExCLKInitStruct.PLLI2S.PLLI2SN = 344;
    RCC_ExCLKInitStruct.PLLI2S.PLLI2SQ = 7;
    RCC_ExCLKInitStruct.PLLI2SDivQ = 1;
    HAL_RCCEx_PeriphCLKConfig(&RCC_ExCLKInitStruct);
  }
}

//--------------------------------------------------------------
__weak void BSP_AUDIO_OUT_MspInit(SAI_HandleTypeDef *hsai, void *Params)
{
  static DMA_HandleTypeDef hdma_sai_tx;
  GPIO_InitTypeDef  gpio_init_structure;

  /* Enable SAI clock */
  AUDIO_OUT_SAIx_CLK_ENABLE();

  /* Enable GPIO clock */
  AUDIO_OUT_SAIx_MCLK_ENABLE();
  AUDIO_OUT_SAIx_SCK_SD_ENABLE();
  AUDIO_OUT_SAIx_FS_ENABLE();


  //I2S out on QSPI chip
  AUDIO_OUT_SAIx_SCK_SD_2_ENABLE();
  AUDIO_OUT_SAIx_FS_2_ENABLE();


  /* CODEC_SAI pins configuration: FS, SCK, MCK and SD pins ------------------*/
  gpio_init_structure.Pin = AUDIO_OUT_SAIx_FS_PIN;
  gpio_init_structure.Mode = GPIO_MODE_AF_PP;
  gpio_init_structure.Pull = GPIO_NOPULL;
  gpio_init_structure.Speed = GPIO_SPEED_HIGH;
  gpio_init_structure.Alternate = AUDIO_OUT_SAIx_FS_SD_MCLK_AF;
  HAL_GPIO_Init(AUDIO_OUT_SAIx_FS_GPIO_PORT, &gpio_init_structure);


  //I2S out on QSPI chip
  gpio_init_structure.Pin = AUDIO_OUT_SAIx_FS_2_PIN;
  gpio_init_structure.Mode = GPIO_MODE_AF_PP;
  gpio_init_structure.Pull = GPIO_NOPULL;
  gpio_init_structure.Speed = GPIO_SPEED_HIGH;
  gpio_init_structure.Alternate = AUDIO_OUT_SAIx_FS_SD_MCLK_AF;
  HAL_GPIO_Init(AUDIO_OUT_SAIx_FS_2_GPIO_PORT, &gpio_init_structure);


  gpio_init_structure.Pin = AUDIO_OUT_SAIx_SCK_PIN;
  gpio_init_structure.Mode = GPIO_MODE_AF_PP;
  gpio_init_structure.Pull = GPIO_NOPULL;
  gpio_init_structure.Speed = GPIO_SPEED_HIGH;
  gpio_init_structure.Alternate = AUDIO_OUT_SAIx_SCK_AF;

  HAL_GPIO_Init(AUDIO_OUT_SAIx_SCK_SD_GPIO_PORT, &gpio_init_structure);



  //I2S out on QSPI chip
  gpio_init_structure.Pin = AUDIO_OUT_SAIx_SCK_2_PIN;
  gpio_init_structure.Mode = GPIO_MODE_AF_PP;
  gpio_init_structure.Pull = GPIO_NOPULL;
  gpio_init_structure.Speed = GPIO_SPEED_HIGH;
  gpio_init_structure.Alternate = AUDIO_OUT_SAIx_SCK_AF;
  HAL_GPIO_Init(AUDIO_OUT_SAIx_SCK_SD_2_GPIO_PORT, &gpio_init_structure);


  gpio_init_structure.Pin =  AUDIO_OUT_SAIx_SD_PIN;
  gpio_init_structure.Mode = GPIO_MODE_AF_PP;
  gpio_init_structure.Pull = GPIO_NOPULL;
  gpio_init_structure.Speed = GPIO_SPEED_HIGH;
  gpio_init_structure.Alternate = AUDIO_OUT_SAIx_FS_SD_MCLK_AF;

  HAL_GPIO_Init(AUDIO_OUT_SAIx_SCK_SD_GPIO_PORT, &gpio_init_structure);



  //I2S out on QSPI chip
  gpio_init_structure.Pin =  AUDIO_OUT_SAIx_SD_2_PIN;
  gpio_init_structure.Mode = GPIO_MODE_AF_PP;
  gpio_init_structure.Pull = GPIO_NOPULL;
  gpio_init_structure.Speed = GPIO_SPEED_HIGH;
  gpio_init_structure.Alternate = AUDIO_OUT_SAIx_FS_SD_MCLK_AF;
  HAL_GPIO_Init(AUDIO_OUT_SAIx_SCK_SD_2_GPIO_PORT, &gpio_init_structure);


  gpio_init_structure.Pin = AUDIO_OUT_SAIx_MCLK_PIN;
  gpio_init_structure.Mode = GPIO_MODE_AF_PP;
  gpio_init_structure.Pull = GPIO_NOPULL;
  gpio_init_structure.Speed = GPIO_SPEED_HIGH;
  gpio_init_structure.Alternate = AUDIO_OUT_SAIx_FS_SD_MCLK_AF;
  HAL_GPIO_Init(AUDIO_OUT_SAIx_MCLK_GPIO_PORT, &gpio_init_structure);

  /* Enable the DMA clock */
  AUDIO_OUT_SAIx_DMAx_CLK_ENABLE();

  if(hsai->Instance == AUDIO_OUT_SAIx)
  {
    /* Configure the hdma_saiTx handle parameters */
    hdma_sai_tx.Init.Channel             = AUDIO_OUT_SAIx_DMAx_CHANNEL;
    hdma_sai_tx.Init.Direction           = DMA_MEMORY_TO_PERIPH;
    hdma_sai_tx.Init.PeriphInc           = DMA_PINC_DISABLE;
    hdma_sai_tx.Init.MemInc              = DMA_MINC_ENABLE;
    hdma_sai_tx.Init.PeriphDataAlignment = AUDIO_OUT_SAIx_DMAx_PERIPH_DATA_SIZE;
    hdma_sai_tx.Init.MemDataAlignment    = AUDIO_OUT_SAIx_DMAx_MEM_DATA_SIZE;
    hdma_sai_tx.Init.Mode                = DMA_CIRCULAR;
    hdma_sai_tx.Init.Priority            = DMA_PRIORITY_HIGH;
    hdma_sai_tx.Init.FIFOMode            = DMA_FIFOMODE_ENABLE;
    hdma_sai_tx.Init.FIFOThreshold       = DMA_FIFO_THRESHOLD_FULL;
    hdma_sai_tx.Init.MemBurst            = DMA_MBURST_SINGLE;
    hdma_sai_tx.Init.PeriphBurst         = DMA_PBURST_SINGLE;

    hdma_sai_tx.Instance = AUDIO_OUT_SAIx_DMAx_STREAM;

    /* Associate the DMA handle */
    __HAL_LINKDMA(hsai, hdmatx, hdma_sai_tx);

    /* Deinitialize the Stream for new transfer */
    HAL_DMA_DeInit(&hdma_sai_tx);

    /* Configure the DMA Stream */
    HAL_DMA_Init(&hdma_sai_tx);
  }

  /* SAI DMA IRQ Channel configuration */
  HAL_NVIC_SetPriority(AUDIO_OUT_SAIx_DMAx_IRQ, AUDIO_OUT_IRQ_PREPRIO, 0);
  HAL_NVIC_EnableIRQ(AUDIO_OUT_SAIx_DMAx_IRQ);
}

//--------------------------------------------------------------
void BSP_AUDIO_OUT_SetAudioFrameSlot(uint32_t AudioFrameSlot)
{
  /* Disable SAI peripheral to allow access to SAI internal registers */
  __HAL_SAI_DISABLE(&haudio_out_sai);

  /* Update the SAI audio frame slot configuration */
  haudio_out_sai.SlotInit.SlotActive = AudioFrameSlot;
  HAL_SAI_Init(&haudio_out_sai);

  /* Enable SAI peripheral to generate MCLK */
  __HAL_SAI_ENABLE(&haudio_out_sai);
}

//--------------------------------------------------------------
static void SAIx_Out_Init(uint32_t AudioFreq)
{
  /* Initialize the haudio_out_sai Instance parameter */
  haudio_out_sai.Instance = AUDIO_OUT_SAIx;

  /* Disable SAI peripheral to allow access to SAI internal registers */
  __HAL_SAI_DISABLE(&haudio_out_sai);

  /* Configure SAI_Block_x
  LSBFirst: Disabled
  DataSize: 16 */
  haudio_out_sai.Init.AudioFrequency = AudioFreq;
  haudio_out_sai.Init.AudioMode = SAI_MODEMASTER_TX;
  haudio_out_sai.Init.NoDivider = SAI_MASTERDIVIDER_ENABLED;
  haudio_out_sai.Init.Protocol = SAI_FREE_PROTOCOL;
  haudio_out_sai.Init.DataSize = SAI_DATASIZE_16;
  haudio_out_sai.Init.FirstBit = SAI_FIRSTBIT_MSB;
  haudio_out_sai.Init.ClockStrobing = SAI_CLOCKSTROBING_RISINGEDGE;
  haudio_out_sai.Init.Synchro = SAI_ASYNCHRONOUS;
  haudio_out_sai.Init.OutputDrive = SAI_OUTPUTDRIVE_ENABLED;
  haudio_out_sai.Init.FIFOThreshold = SAI_FIFOTHRESHOLD_1QF;

  /* Configure SAI_Block_x Frame
  Frame Length: 64
  Frame active Length: 32
  FS Definition: Start frame + Channel Side identification
  FS Polarity: FS active Low
  FS Offset: FS asserted one bit before the first bit of slot 0 */
  haudio_out_sai.FrameInit.FrameLength = 64;
  haudio_out_sai.FrameInit.ActiveFrameLength = 32;
  haudio_out_sai.FrameInit.FSDefinition = SAI_FS_CHANNEL_IDENTIFICATION;
  haudio_out_sai.FrameInit.FSPolarity = SAI_FS_ACTIVE_LOW;
  haudio_out_sai.FrameInit.FSOffset = SAI_FS_BEFOREFIRSTBIT;

  /* Configure SAI Block_x Slot
  Slot First Bit Offset: 0
  Slot Size  : 16
  Slot Number: 4
  Slot Active: All slot active */
  haudio_out_sai.SlotInit.FirstBitOffset = 0;
  haudio_out_sai.SlotInit.SlotSize = SAI_SLOTSIZE_DATASIZE;
  haudio_out_sai.SlotInit.SlotNumber = 4;
  haudio_out_sai.SlotInit.SlotActive = CODEC_AUDIOFRAME_SLOT_0123;

  HAL_SAI_Init(&haudio_out_sai);

  /* Enable SAI peripheral to generate MCLK */
  __HAL_SAI_ENABLE(&haudio_out_sai);
}

//--------------------------------------------------------------
static void SAIx_Out_DeInit(void)
{
  /* Initialize the haudio_out_sai Instance parameter */
  haudio_out_sai.Instance = AUDIO_OUT_SAIx;

  /* Disable SAI peripheral */
  __HAL_SAI_DISABLE(&haudio_out_sai);

  HAL_SAI_DeInit(&haudio_out_sai);
}




//--------------------------------------------------------------
// ISR called at Error
//--------------------------------------------------------------
void HAL_SAI_ErrorCallback(SAI_HandleTypeDef *hsai)
{
  HAL_SAI_StateTypeDef audio_out_state;

  audio_out_state = HAL_SAI_GetState(&haudio_out_sai);

  if ((audio_out_state == HAL_SAI_STATE_BUSY) || (audio_out_state == HAL_SAI_STATE_BUSY_TX)
   || (audio_out_state == HAL_SAI_STATE_TIMEOUT) || (audio_out_state == HAL_SAI_STATE_ERROR))
  {
    // error (Audio OUT)
  }
}

//--------------------------------------------------------------
// DMA Handler (Audio OUT)
//--------------------------------------------------------------
void AUDIO_OUT_SAIx_DMAx_IRQHandler(void)
{
  HAL_DMA_IRQHandler(haudio_out_sai.hdmatx);
}
