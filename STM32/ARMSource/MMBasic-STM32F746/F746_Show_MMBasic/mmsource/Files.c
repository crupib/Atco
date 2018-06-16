/***********************************************************************************************************************
MMBasic

Files.c

Handles all the file input/output in MMBasic.

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


#define NBRERRMSG 17

#include <stdlib.h>									// standard library functions
#include <string.h>									// string functions
#include <stdio.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

F7FILE *MMFilePtr[MAXOPENFILES];
FIL MMFile;
int MMDrive=0;
extern uint8_t usb_msc_enable;
extern uint8_t usb_hid_enable;
char path_name[STRINGSIZE]="";
char sd_path_name[STRINGSIZE]="";
char usb_path_name[STRINGSIZE]="";
#if FATFS_USE_USB_MEDIA==1
  char USBPath[4] ="0:/";
  char SDPath[4] ="1:/";
#else
  char SDPath[4] ="0:/";
  char USBPath[4] ="1:/";
#endif
  void DISABLE_HID(void) {
	  // disable USB-HID
	  usb_hid_enable=false;
  }

  void DISABLE_USB(void) {
	  // disable USB-HID and USB-MSC
	  usb_hid_enable=false;
	  usb_msc_enable=false;
  }

  void ENABLE_USB(void) {
	  // enable USB-HID and USB-MSC
	  usb_msc_enable=true;
	  usb_hid_enable=true;
  }

  void errorF7(char *msg)  {
	  // enable USB-HID and USB-MSC
	  // and show error message
	  ENABLE_USB();
	  error(msg);
  }



#if defined(USER_UB)
  int DefaultDrive = SDFS;
#else
  int DefaultDrive = USBFS;
#endif

int FlashStatus = CLOSED;

int FlashEOF = false;
int OptionErrorAbort = true;
int MMerrno = 0;





//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////// ERROR HANDLING ////////////////////////////////////////////


/*****************************************************************************************
Mapping of errors reported by the Microchip FAT 16/32 file system to MMBasic file errors
*****************************************************************************************/
const int ErrorMap[34] = {			0, 	// 0  =   No error
									11, // 1  =   An erase failed
									1, 	// 2  =   No SD card found
									15, // 3  =   The disk is of an unsupported format
									15, // 4  =   The boot record is bad
									15, // 5  =   The file system type is unsupported
									15, // 6  =   An initialization error has occurred
									15, // 7  =   An operation was performed on an uninitialized device
									10, // 8  =   A bad read of a sector occurred
									11, // 9  =   Could not write to a sector
									15, // 10 =  Invalid cluster value
									6, 	// 11 =  Could not find the file on the device
									7, 	// 12 =  Could not find the directory
									10, // 13 =  File is corrupted
									0, 	// 14 =  No more files in this directory
									15, // 15 =  Could not load/allocate next cluster in file
									5, 	// 16 =  A specified file name is too long to use
									9, 	// 17 =  A specified filename already exists on the device
									5, 	// 18 =  Invalid file name
									12, // 19 =  Attempt to delete a directory with KILL
									4, 	// 20 =  All root directory entries are taken
									3, 	// 21 =  All clusters in partition are taken
									14, // 22 =  This directory is not empty yet, remove files before deleting
									15, // 23 =  The disk is too big to format as FAT16
									2, 	// 24 =  Card is write protected
									11, // 25 =  File not opened for the write
									11, // 26 =  File location could not be changed successfully
									10, // 27 =  Bad cache read
									15, // 28 =  FAT 32 - card not supported
									8, 	// 29 =  The file is read-only
									10, // 30 =  The file is write-only
									15, // 31 =  Invalid argument
									9, 	// 32 =  Too many files are already open
									15, // 33 =  Unsupported sector size
							};

/******************************************************************************************
Text for the file related error messages reported by MMBasic
******************************************************************************************/

const char *FErrorMsg[NBRERRMSG] = {	"No error",									// 0
										"SD card not found",						// 1
										"SD card is write protected",				// 2
										"No space on media",						// 3
										"All root directory entries are taken",		// 4
										"Invalid file or directory name",			// 5
										"Cannot find file",							// 6
										"Cannot find or create directory",			// 7
										"File is read only",						// 8
										"Cannot open file",							// 9
										"Cannot read from file",					// 10
										"Cannot write to file",						// 11
										"Not a file",								// 12
										"Not a directory",							// 13
										"Directory not empty",						// 14
										"Cannot access the SD card",				// 15
										"Flash memory write failure"				// 16
									};


int ErrorThrow(int e) {
#if !defined(STM32F7) // PIC
	MMerrno = e;
	if(e == 15) SDCardRemoved = true;
	if(e > 0 && e < NBRERRMSG && OptionErrorAbort) error((char *)FErrorMsg[e]);
	return e;
#else // STM32F746
  return e;
#endif // STM32F746
}


int ErrorCheck(void) {
#if !defined(STM32F7) // PIC
	int e;
	e = FSerror();
	if(e == 15) SDCardRemoved = true;
	if(e < 1 || e > 33) return e;
	return ErrorThrow(ErrorMap[e]);
#else // STM32F746
  return 0;
#endif // STM32F746
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////


/*******************************************************************************************
File related commands in MMBasic
================================
These are the functions responsible for executing the file related commands in MMBasic
They are supported by utility functions that are grouped at the end of this file

Each function is responsible for decoding a command
all function names are in the form cmd_xxxx() (for a basic command) or fun_xxxx() (for a
basic function) so, if you want to search for the function responsible for the LOCATE command
look for cmd_name

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

********************************************************************************************/



void cmd_open(void) {
#if !defined(STM32F7) // PIC
	int fnbr, i;
	char *mode = NULL, *fname;
	char ss[3];														// this will be used to split up the argument line

	ss[0] = GetTokenValue("FOR");
	ss[1] = tokenvalue[TKN_AS];
	ss[2] = 0;
	{																// start a new block
		getargs(&cmdline, 5, ss);									// getargs macro must be the first executable stmt in a block
		fname = GetFileName(argv[0], NULL);

		// check if it is a serial port that we are opening and, if so, handle it as a special case
		if(argc == 3 && mem_equal(fname, "COM", 3) && fname[4] == ':' && fname[3] >= '0' && fname[3] <= '0' + NBR_SERIAL_PORTS) {
			i = (str_equal(argv[2], "CONSOLE")) ? 1 : 0;
			SerialOpen(fname, i);
			if(i == false) {
				// if it is NOT the console get the file number
				if(*argv[2] == '#') argv[2]++;
				fnbr = getinteger(argv[2]);
				if(fnbr < 1 || fnbr > 10) error("Invalid file number");
				if(MMFilePtr[fnbr - 1] != NULL) error("File number is already open");
				MMFilePtr[fnbr - 1] = (FSFILE *)(fname[3] - '0');
			}
			return;
		}

		if(argc != 5) error("Invalid Syntax");
		if(str_equal(argv[2], "OUTPUT"))
			mode = "w";
		else if(str_equal(argv[2], "APPEND"))
			mode = "a";
		else if(str_equal(argv[2], "INPUT"))
			mode = "r";
		else if(str_equal(argv[2], "RANDOM"))
			mode = "x";
		else
			error("Invalid file access mode");
		if(*argv[4] == '#') argv[4]++;
		fnbr = getinteger(argv[4]);
		MMfopen(fname, mode, fnbr);
	}
#else // STM32F746
	int fnbr, i;
	char *mode = NULL, *fname;
	char ss[3];														// this will be used to split up the argument line

	ss[0] = GetTokenValue("FOR");
	ss[1] = tokenvalue[TKN_AS];
	ss[2] = 0;
	{																// start a new block
		getargs(&cmdline, 5, ss);									// getargs macro must be the first executable stmt in a block
		fname = GetFileName(argv[0], NULL);

		// check if it is a serial port that we are opening and, if so, handle it as a special case
		if(argc == 3 && mem_equal(fname, "COM", 3) && fname[4] == ':' && fname[3] >= '0' && fname[3] <= '0' + NBR_SERIAL_PORTS) {
			i = (str_equal(argv[2], "CONSOLE")) ? 1 : 0;
			SerialOpen(fname, i);
			if(i == false) {
				// if it is NOT the console get the file number
				if(*argv[2] == '#') argv[2]++;
				fnbr = getinteger(argv[2]);
				if(fnbr < 1 || fnbr > 10) error("Invalid file number");
				if(MMFilePtr[fnbr - 1] != NULL) error("File number is already open");
				MMFilePtr[fnbr - 1] = (F7FILE *)(fname[3] - '0');
			}
			return;
		}
		error("Invalid Syntax");
	}
#endif // STM32F746
}



void cmd_close(void) {
	int i;
	getargs(&cmdline, (MAX_ARG_COUNT * 2) - 1, ",");				// getargs macro must be the first executable stmt in a block
	if((argc & 0x01) == 0) error("Invalid syntax");

	if(argc == 1 && str_equal(argv[0], "CONSOLE")) {
		SerialClose(SerialConsole);
		return;
	}

	MMerrno = 0;
	for(i = 0; i < argc; i += 2) {
		if(*argv[i] == '#') argv[i]++;
		MMfclose(getinteger(argv[i]));
	}
}


void fun_inputstr(void) {
	int nbr, fnbr;
	char *p;
	getargs(&ep, 3, ",");
	if(argc != 3) error("Invalid syntax");
	nbr = getinteger(argv[0]);
	if(nbr < 1 || nbr > MAXSTRLEN) error("Number out of bounds");
	if(*argv[2] == '#') argv[2]++;
	fnbr = getinteger(argv[2]);
	sret = GetTempStringSpace();									// this will last for the life of the command
	p = sret + 1;													// point to the start of the char array
	*sret = nbr;													// set the length of the returned string
	while(nbr) {
		if(MMfeof(fnbr)) break;
		*p++ = MMfgetc(fnbr);										// get the char and save in our returned string
		nbr--;
	}
	*sret -= nbr;													// correct if we get less than nbr chars
}



// search for a volume label, directory or file
// s$ = DIR$(fspec, VOL|DIR|FILE)		will return the first entry
// s$ = DIR$()							will return the next
// If s$ is empty then no (more) files found
void fun_dir(void) {
#if !defined(STM32F7) // PIC
	static SearchRec file;
	int r, flags;
	char *p;

	getargs(&ep, 3, ",");
	if(argc == 2) error("Invalid syntax");

	flags = ATTR_HIDDEN | ATTR_SYSTEM | ATTR_READ_ONLY | ATTR_ARCHIVE;
	if(argc == 3) {
		if(checkstring(argv[2], "VOL"))
			flags = ATTR_VOLUME;
		else if(checkstring(argv[2], "DIR"))
			flags = ATTR_DIRECTORY;
		else if(checkstring(argv[2], "FILE"))
			flags = ATTR_HIDDEN | ATTR_SYSTEM | ATTR_READ_ONLY | ATTR_ARCHIVE;
		else
			error("Invalid flag specification");
	}

	if(!InitSDCard()) ErrorThrow(1);								// setup the SD card
	SDActivityLED = SDActivityTime;
	if(argc > 0) {
		// this must be the first call eg:  DIR$("*.*", FILE)
		p = getCstring(argv[0]);
		if(GetDrive(p) == FLASHFS) error("Command not valid on A:");
		p = GetFName(p);
		r = FindFirst(p, flags, &file);
	} else
		// this is a subsequent call for more files
		r = FindNext(&file);

	sret = GetTempStringSpace();									// this will last for the life of the command
	if(r) return;													// no more file names so return empty
	ErrorCheck();

	#if defined(SUPPORT_LFN)
		if(file.utf16LFNfoundLength == 0)
			strcpy(sret, file.filename);
		else {
			int i;
			for(i = 0; i < file.utf16LFNfoundLength; i++)
				sret[i] = (char) file.utf16LFNfound[i];
			sret[i] = 0;
		}
	#else
			strcpy(sret, file.filename);
	#endif

	CtoM(sret);														// convert to a MMBasic style string
#else // STM32F746
	error("fun_dir");
#endif // STM32F746
}



void cmd_mkdir(void) {
	char *p;
	FRESULT res;
	p = GetFileName(cmdline, NULL);										// get the directory name and convert to a standard C string
	if(GetDrive(p) == FLASHFS)  {
		error("flash not supported");
	}
	else if(GetDrive(p) == SDFS)  {
		// SD card filesystem		
		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[1]);
		if(UB_Fatfs_Mount(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[15]);
		SetPathNameF7(p,SDFS);
		res = f_mkdir(path_name);
		if(res!=FR_OK) errorF7((char *)FErrorMsg[7]);
		UB_Fatfs_UnMount(MMC_1);
		ENABLE_USB();
	}
	else if(GetDrive(p) == USBFS)  {
		// USB-Drive filesystem		
		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) errorF7("USB-Drive not found");
		if(UB_Fatfs_Mount(USB_0)!=FATFS_OK) errorF7("Cannot access the USB-Drive");
		SetPathNameF7(p,USBFS);
		res = f_mkdir(path_name);
		if(res!=FR_OK) errorF7((char *)FErrorMsg[7]);
		UB_Fatfs_UnMount(USB_0);
		ENABLE_USB();
	}
}



void cmd_rmdir(void){
	FRESULT res;
	char *p;
	FILINFO fno;
	p = GetFileName(cmdline, NULL);									// get the directory name and convert to a standard C string
	if(GetDrive(p) == FLASHFS)  {
		error("flash not supported");
	}
	else if(GetDrive(p) == SDFS)  {
		// SD card filesystem		
		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[1]);
		if(UB_Fatfs_Mount(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[15]);
		SetPathNameF7(p,SDFS);
		res = f_stat(path_name, &fno);
		if(res!=FR_OK) errorF7((char *)FErrorMsg[5]);
		if(!(fno.fattrib & AM_DIR)) errorF7((char *)FErrorMsg[13]);
		res=f_unlink(path_name);
		if(res!=FR_OK) errorF7("Cannot delete dir");
		UB_Fatfs_UnMount(MMC_1);
		ENABLE_USB();
	}
	else if(GetDrive(p) == USBFS)  {
		// USB-Drive filesystem		
		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) errorF7("USB-Drive not found");
		if(UB_Fatfs_Mount(USB_0)!=FATFS_OK) errorF7("Cannot access the USB-Drive");
		SetPathNameF7(p,USBFS);
		res = f_stat(path_name, &fno);
		if(res!=FR_OK) errorF7((char *)FErrorMsg[5]);
		if(!(fno.fattrib & AM_DIR)) errorF7((char *)FErrorMsg[13]);
		res=f_unlink(path_name);
		if(res!=FR_OK) errorF7("Cannot delete dir");
		UB_Fatfs_UnMount(USB_0);
		ENABLE_USB();
	}
}



void cmd_chdir(void){
	FRESULT res;
	char *p;
	char *tp;
	FILINFO fno;
	p = GetFileName(cmdline, NULL);									// get the directory name and convert to a standard C string
	if(GetDrive(p) == FLASHFS)  {
		error("flash not supported");
	}
	else if(GetDrive(p) == SDFS)  {
		// SD card filesystem
		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[1]);
		if(UB_Fatfs_Mount(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[15]);

		if(strcmp(p, "\\") == 0) {
			// back to root
		  sd_path_name[0]=0;
		  sprintf(path_name,"%s",SDPath);
	      res=f_chdir(path_name);
		  if(res!=FR_OK) errorF7("Cannot change dir");
		}
		else if(strcmp(p, "..") == 0) {
		  if(sd_path_name[0]!=0) {
			// one level back
			tp = sd_path_name + strlen(sd_path_name);
			while(tp != sd_path_name && *tp != '/') tp--;
			*tp=0x00;
			if(strlen(sd_path_name)<3) {
				// now we are in root
				sd_path_name[0]=0;
				sprintf(path_name,"%s",SDPath);
			    res=f_chdir(path_name);
				if(res!=FR_OK) errorF7("Cannot change dir");
			}
			else {
				// now we are in new path
				sprintf(path_name,"%s",sd_path_name);
			    res = f_stat(path_name, &fno);
				if(res!=FR_OK) errorF7((char *)FErrorMsg[5]);
				if(!(fno.fattrib & AM_DIR)) errorF7((char *)FErrorMsg[13]);
			    res=f_chdir(path_name);
				if(res!=FR_OK) errorF7("Cannot change dir");
				sprintf(sd_path_name,"%s",path_name);	// save new path
			}
		  }
		}
		else {
		  SetPathNameF7(p,SDFS);
	  	  res = f_stat(path_name, &fno);
		  if(res!=FR_OK) errorF7((char *)FErrorMsg[5]);
		  if(!(fno.fattrib & AM_DIR)) errorF7((char *)FErrorMsg[13]);
	      res=f_chdir(path_name);
		  if(res!=FR_OK) errorF7("Cannot change dir");
		  sprintf(sd_path_name,"%s",path_name);	// save new path
		}
		UB_Fatfs_UnMount(MMC_1);
		ENABLE_USB();
	}
	else if(GetDrive(p) == USBFS)  {
		// USB-Drive filesystem
		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) errorF7("USB-Drive not found");
		if(UB_Fatfs_Mount(USB_0)!=FATFS_OK) errorF7("Cannot access the USB-Drive");

		if(strcmp(p, "\\") == 0) {
			// back to root
		  usb_path_name[0]=0;
		  sprintf(path_name,"%s",USBPath);
	      res=f_chdir(path_name);
		  if(res!=FR_OK) errorF7("Cannot change dir");
		}
		else if(strcmp(p, "..") == 0) {
		  if(usb_path_name[0]!=0) {
			// one level back
			tp = usb_path_name + strlen(usb_path_name);
			while(tp != usb_path_name && *tp != '/') tp--;
			*tp=0x00;
			if(strlen(usb_path_name)<3) {
				// now we are in root
				usb_path_name[0]=0;
				sprintf(path_name,"%s",USBPath);
			    res=f_chdir(path_name);
				if(res!=FR_OK) errorF7("Cannot change dir");
			}
			else {
				// now we are in new path
				sprintf(path_name,"%s",usb_path_name);
			    res = f_stat(path_name, &fno);
				if(res!=FR_OK) errorF7((char *)FErrorMsg[5]);
				if(!(fno.fattrib & AM_DIR)) errorF7((char *)FErrorMsg[13]);
			    res=f_chdir(path_name);
				if(res!=FR_OK) errorF7("Cannot change dir");
				sprintf(usb_path_name,"%s",path_name);	// save new path
			}
		  }
		}
		else {
		  SetPathNameF7(p,USBFS);
	  	  res = f_stat(path_name, &fno);
		  if(res!=FR_OK) errorF7((char *)FErrorMsg[5]);
		  if(!(fno.fattrib & AM_DIR)) errorF7((char *)FErrorMsg[13]);
	      res=f_chdir(path_name);
		  if(res!=FR_OK) errorF7("Cannot change dir");
		  sprintf(usb_path_name,"%s",path_name);	// save new path
		}
		UB_Fatfs_UnMount(USB_0);
		ENABLE_USB();
	}
}




void fun_eof(void) {
#if !defined(STM32F7) // PIC
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fret = (float)MMfeof(getinteger(argv[0]));
#else // STM32F746
	error("fun_eof");
#endif // STM32F746
}



void fun_loc(void) {
	int fnbr;
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	if(MMFilePtr[fnbr] <= (F7FILE *)NBR_SERIAL_PORTS)
		fret = (float)SerialRxStatus((int)MMFilePtr[fnbr]);
	else
		//fret = (float)(MMFilePtr[fnbr]->seek + 1);
		error("fun_loc");
}

    int iiii;


void fun_lof(void) {
	int fnbr;
	getargs(&ep, 1, ",");
	if(argc == 0) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	if(MMFilePtr[fnbr] <= (F7FILE *)NBR_SERIAL_PORTS)
		fret = (float)SerialTxStatus((int)MMFilePtr[fnbr]);
	else
		//fret = (float)MMFilePtr[fnbr]->size;
		error("fun_lof");
}



void fun_cwd(void) {
	MMerrno = 0;
	sret = GetTempStringSpace();								// this will last for the life of the command
	if(DefaultDrive == FLASHFS) {
		sret[0] = 3; sret[1] = 'A'; sret[2] = ':'; sret[3] = '\\';  // this is a MMBasic string
	}
	else if(DefaultDrive == SDFS) {
		sret[0] = 3; sret[1] = 'B'; sret[2] = ':'; sret[3] = '\\';  // this is a MMBasic string
	}
	else if(DefaultDrive == USBFS) {
		sret[0] = 3; sret[1] = 'C'; sret[2] = ':'; sret[3] = '\\';  // this is a MMBasic string
	}
}



void cmd_kill(void){
	FRESULT res;
	char *p;
	FILINFO fno;
	p = GetFileName(cmdline, NULL);									// get the file name (can be non quoted)
	if(GetDrive(p) == FLASHFS)  {
		error("flash not supported");
	}
	else if(GetDrive(p) == SDFS)  {
		// SD card filesystem
                DISABLE_USB();
		if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[1]);
		if(UB_Fatfs_Mount(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[15]);
		SetPathNameF7(p,SDFS);
		res = f_stat(path_name, &fno);
		if(res!=FR_OK) errorF7((char *)FErrorMsg[5]);
		if(fno.fattrib & AM_DIR) errorF7((char *)FErrorMsg[12]);
		res=f_unlink(path_name);
		if(res!=FR_OK) errorF7("Cannot delete file");
		UB_Fatfs_UnMount(MMC_1);
                ENABLE_USB();
	}
	else if(GetDrive(p) == USBFS)  {
		// USB-Drive filesystem
                DISABLE_USB();
		if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) errorF7("USB-Drive not found");
		if(UB_Fatfs_Mount(USB_0)!=FATFS_OK) errorF7("Cannot access the USB-Drive");
		SetPathNameF7(p,USBFS);
		res = f_stat(path_name, &fno);
		if(res!=FR_OK) errorF7((char *)FErrorMsg[5]);
		if(fno.fattrib & AM_DIR) errorF7((char *)FErrorMsg[12]);
		res=f_unlink(path_name);
		if(res!=FR_OK) errorF7("Cannot delete file");
		UB_Fatfs_UnMount(USB_0);
                ENABLE_USB();
	}
}



void cmd_name(void) {
#if !defined(STM32F7) // PIC
	FSFILE *fp;
	char *old, *new, ss[2];
	ss[0] = tokenvalue[TKN_AS];										// this will be used to split up the argument line
	ss[1] = 0;
	{																// start a new block
		getargs(&cmdline, 3, ss);									// getargs macro must be the first executable stmt in a block
		if(argc != 3) error("Invalid syntax");
        old = GetFileName(argv[0], NULL);                           // get the old file name (does not have to use quote marks in immediate mode)
        new = GetFileName(argv[2], NULL);                           // get the new file name (ditto)
		if(GetDrive(old) == FLASHFS) {
			if(GetDrive(new) != FLASHFS) error("Cannot rename across drives");
			if(str_equal(old, new)) error("Old and new filenames are the same");
			FlashCopyRename(GetFName(old), GetFName(new), true);
		} else {
			if(GetDrive(new) != SDFS) error("Cannot rename across drives");
			if(str_equal(old, new)) error("Old and new filenames are the same");
			if(!InitSDCard()) return;
			if(!SDCheckFileName(GetFName(old))) { ErrorThrow(6); return; }
			if(SDCheckFileName(GetFName(new))) { ErrorThrow(9); return; }
		#if defined(SUPPORT_LFN)
			fp = wFSfopen(ConvertToUTF16(old), "r");
		#else
			fp = FSfopen(old, "r");
		#endif
			if(ErrorCheck() || fp == NULL) return;
			SDActivityLED = SDActivityTime;
		#if defined(SUPPORT_LFN)
			wFSrename(ConvertToUTF16(new), fp);
		#else
			FSrename(new, fp);
		#endif
			if(ErrorCheck()) return;
			FSfclose(fp);
		}
	}
#else // STM32F746
	error("cmd_name");
#endif // STM32F746
}



void cmd_copy(void) {                                           // thanks to Bryan Rentoul for the contribution
#if !defined(STM32F7) // PIC
    char *old, *new, ss[2], c;
    const int CBSIZE = 1024 * 2;
    char buf[CBSIZE];
    int n;
    int of, nf;

    ss[0] = tokenvalue[TKN_TO];                                 // this will be used to split up the argument line
    ss[1] = 0;

    getargs(&cmdline, 3, ss);                                   // getargs macro must be the first executable stmt in a block
    if(argc != 3) error("Invalid syntax");
    old = GetFileName(argv[0], NULL);                           // get the old file name (does not have to use quote marks in immediate mode)
    new = GetFileName(argv[2], NULL);                           // get the new file name (ditto)

    if((strchr(new, ':') != NULL) && (strlen(new) == 2)) {      // if only a dest drive letter given then append source name to blank (drive only) dest name.
        if(strrchr(old, '\\') != NULL)
            strcat(new, strrchr(old, '\\') + 1);
        else
            strcat(new, GetFName(old));
    }

    if(GetDrive(old) == GetDrive(new) && str_equal(GetFName(old), GetFName(new)))
    	error("Source and destination are the same");

    if(GetDrive(old) == FLASHFS && GetDrive(new) == FLASHFS) {
    	FlashCopyRename(GetFName(old), GetFName(new), false);
    	return;
    }

    of = FindFreeFileNbr();
    MMfopen(old, "r", of);
    if(MMerrno) return;

    nf = FindFreeFileNbr();
    MMfopen(new, "w", nf); 										// We'll just overwrite any existing file
    if(MMerrno) { MMfclose(of); return; }

    if(GetDrive(old) == SDFS && GetDrive(new) == SDFS)          // If both the source and destination are on the SD card
        do {                                                    // use the fast copy method
        	SDActivityLED = SDActivityTime;
            n = FSfread(buf, 1, CBSIZE, MMFilePtr[of - 1]);
            if(!FSfeof(MMFilePtr[of - 1]) && ErrorCheck()) return;
            CheckAbort();
        	SDActivityLED = SDActivityTime;
            FSfwrite(buf, 1, n, MMFilePtr[nf - 1]);
            if(ErrorCheck()) return;
            CheckAbort();
        } while(n == CBSIZE);
    else
        while(1) {                                              // otherwise use the old (slow) method
            if(MMfeof(of)) break;
            c = MMfgetc(of);
            MMfputc(c, nf);
        }

    MMfclose(of);
    MMfclose(nf);
#else // STM32F746
    error("cmd_copy");
#endif // STM32F746
}



void fun_errno(void) {
	fret = (float)MMerrno;
}


void cmd_drive(void){
	char *p;

	p = GetFileName(cmdline, NULL);
	makeupper(p);
	if(*p == 'B') {
		DefaultDrive = SDFS;
		sd_path_name[0]=0;
	}
	else
		if(*p == 'A')
			DefaultDrive = FLASHFS;
		else
			if(*p == 'C') {
				DefaultDrive = USBFS;
				usb_path_name[0]=0;
			}
			else
				error("Unrecognised drive letter");
}


void cmd_seek(void) {
#if !defined(STM32F7) // PIC
	int fnbr, idx;
	getargs(&cmdline, 5, ",");
	if(argc != 3) error("Invalid syntax");
	if(*argv[0] == '#') argv[0]++;
	fnbr = getinteger(argv[0]) - 1;
	if(fnbr < 0 || fnbr >= 10 || MMFilePtr[fnbr] < (FSFILE *)NBR_SERIAL_PORTS) error("Invalid file number");
	if(MMFilePtr[fnbr] == NULL) error("File number is not open");
	idx = getinteger(argv[2]) - 1;
    FSfseek(MMFilePtr[fnbr], idx, SEEK_SET);
    if(FSerror() == 31)                                             // if the error is "invalid argument" it generally means seek beyond end of file
        ErrorThrow(10);                                             // so throw a "cannot read" error.  This could be made more informative
    else
        ErrorCheck();                                               // otherwise the normal error check
#else // STM32F746
    error("cmd_seek");
#endif // STM32F746
}


// The MM.DRIVE$ automatic variable
void fun_mmdrive(void) {
    sret = GetTempStringSpace();								    // this will last for the life of the command
	sret[0] = 2; sret[2] = ':';                                     // this is a MMBasic string
	if(DefaultDrive == FLASHFS)
		sret[1] = 'A';
	else if(DefaultDrive == SDFS)
		sret[1] = 'B';
	else
		sret[1] = 'C';
}


// The MM.FNAME$ automatic variable
void fun_mmfname(void) {
	char *tp;
	tp = GetTempStringSpace();										// this will last for the life of the command
	strcpy(tp, LastFile);											// get the string and save in a temp place
	CtoM(tp);														// convert to a MMBasic style string
	sret = tp;
}


#if defined(MMFAMILY)
int FLen;       // global that will be loaded with the file length by MMfopen() (this is a kludge - must be fixed at some time)
void cmd_library(void) {
    int fn, i;
    char *pPath, *pFName, *p, *pmem;
    char save_tknbuf[STRINGSIZE];

	p = cmdline;

	// This block of code handles the command:   LIBRARY LOAD filename
	if(*p == GetTokenValue("LOAD")) {
    	p++;                                                        // step over the token
    	pPath = getCstring(p);
    	pFName = strrchr(pPath, '\\') + 1;                          // get just the filename part of a possible path
    	if(pFName == (char *)1) pFName = strrchr(pPath, ':') + 1;
    	if(pFName == (char *)1) pFName = pPath;                     // no path, we were given just the file name
	    if(strchr(pFName, '.') == NULL) strcat(pFName, ".LIB");     // add the default extension if necessary
    	for(i = 0; i < NbrModules; i++)                             // scan the module table to see if it is already loaded
    	    if(str_equal(ModuleTable[i] + 4, pFName))
    	        return;                                             // and exit if already loaded
	    fn = FindFreeFileNbr();
	    MMfopen(pPath, "r", fn);                                    // test open the file and get the file length into FLen
    	MMfclose(fn);
    	pmem = getmemory(FLen + FILENAME_LENGTH + 5);               // get the memory
    	ModuleTable[NbrModules++] = pmem;                           // add this library to our list of modules
    	*((int *)pmem) = FLen;  pmem += 4;                          // put the size in first
    	memmove(pmem, pFName, FILENAME_LENGTH);                     // then copy in the file name
    	pmem += FILENAME_LENGTH + 1;
    	memmove(save_tknbuf, tknbuf, STRINGSIZE);                   // save tknbuf in case we are in command mode (megefile uses tknbuf)
    	mergefile(pPath, pmem);                                     // load the library
    	memmove(tknbuf, save_tknbuf, STRINGSIZE);                   // restore tknbuf
        PrepareProgram();                                           // build the global list of subs/funs
        return;
    }

	// this block of code handles the command:   LIBRARY UNLOAD filename
	if((p = checkstring(cmdline, "UNLOAD")) != NULL) {
    	pPath = getCstring(p);
    	pFName = strrchr(pPath, '\\') + 1;                          // get just the filename part of a possible path
    	if(pFName == (char *)1) pFName = strrchr(pPath, ':') + 1;
    	if(pFName == (char *)1) pFName = pPath;                     // no path, we were given just the file name
	    if(strchr(pFName, '.') == NULL) strcat(pFName, ".LIB");
    	for(i = 0; i < NbrModules; i++)                             // scan the module table to see if it is already loaded
    	    if(str_equal(ModuleTable[i] + 4, pFName)) {
        	    FreeHeap(ModuleTable[i]);                           // free the memory
        	    while(i < NbrModules) {
            	    ModuleTable[i] = ModuleTable[i + 1];            // delete the entry in the module table and close up the gap
            	    i++;
            	}
        	    NbrModules--;
        	    PrepareProgram();                                   // build the global list of subs/funs
        	    return;
    	    }
    	error("Library not loaded");
    }
    error("Invalid Syntax");
}
#endif



/*******************************************************************************************
********************************************************************************************

Utility routines for the file I/O commands in MMBasic

********************************************************************************************
********************************************************************************************/



// get a line from the keyboard or a file handle
// most of the keyboard input is handled by EditInputLine() but it will use this function
// if a line greater than he screen width is being entered.
// IMPORTANT: This will append to the buffer pointed to by p, so (if you don't want this)
//            make sure that the first char of p is zero before calling this.
void MMgetline(int filenbr, char *p) {
	int nbrchars;
	char c, *tp;

	nbrchars = strlen(p);											// the line might not be empty and we want to add to the end
	p += nbrchars;

	while(1) {

		CheckAbort();												// jump right out if CTRL-C


		if(filenbr != 0) {                                          // do NOT check for EOF on console input	
    		// ignore EOF on the COM ports
    		if(MMFilePtr[filenbr - 1] != NULL && MMFilePtr[filenbr - 1] <= (F7FILE *)NBR_SERIAL_PORTS && SerialRxStatus((int)MMFilePtr[filenbr - 1]) == 0) continue;

    		if(MMfeof(filenbr)) break;									// end of file - stop collecting    		
        }


		c = MMfgetc(filenbr);

		if(filenbr == 0 && c >= F1 && c <= F12) {					// expand if a function key
			for(tp = FunKey[c - 0x91]; *tp; ) {
				if(++nbrchars > MAXSTRLEN) error("Line is too long");
				if(*tp == '\n') break;
				MMfputc(*tp, 0);
				*p++ = *tp++;
			}
			continue;
		}

		if(c == '\t') {												// expand tabs to spaces
			 do {
				if(++nbrchars > MAXSTRLEN) error("Line is too long");
				*p++ = ' ';
				if(filenbr == 0) MMfputc(' ', 0);
			} while(nbrchars % 8);
			continue;
		}

		if(c == '\b') {												// handle the backspace
			if(nbrchars) {
				if(filenbr == 0) MMfputs("\3\b \b", 0);
				nbrchars--;
				p--;
			}
			continue;
		}

		if(c == '\r') {
			continue;												// skip a lf (it should follow a cr)
		}

		if(c == '\n') {
			if(filenbr == 0) MMfputs("\2\r\n", 0);
			break;													// end of the line - stop collecting
		}

		if(isprint(c)) {
			if(filenbr == 0) MMfputc(c, 0);							// Maximite requires that chars be specificially echoed
		}
		if(++nbrchars > MAXSTRLEN) error("Line is too long");		// stop collecting if maximum length
		*p++ = c;													// save our char
	}
	*p = 0;
}



void inline CheckAbort(void) {
	if(MMAbort) {
		longjmp(mark, 1);
	}
}


// return a pointer to the part of the file spec immediately after the drive designator.
// For example  GetFName("A:FILE.BAS")  will return a pointer pointing to the F
// It will throw an error if the prefix is not a valid drive
char *GetFName(char *p) {
	if(*p && p[1] == ':') {
		if(toupper(p[0]) == 'B')
			return p + 2;
		else if(toupper(p[0]) == 'A')
			return p + 2;
		else if(toupper(p[0]) == 'C')
			return p + 2;
		else
		    error("Unrecognised drive letter");
	}
	return p;
}


// set full path_name for stm32f7 (drive+file)
// "test.txt"    -> path_name="0:/test.txt"
// "b:/test.txt" -> path_name="1:/test.txt"
int SetPathNameF7(char *fname, int drive) {
  int fs = -1;

  // check if allready full_pathname
  if(*fname && fname[1] == ':') {
    if(toupper(fname[0]) == 'A') fs = FLASHFS;
    if(toupper(fname[0]) == 'B') fs = SDFS;				
    if(toupper(fname[0]) == 'C') fs = USBFS;
    if(fname[0] == '0') fs = USBFS;
    if(fname[0] == '1') fs = SDFS;
  }

  if(fs<0) {
    // filename without drive e.g. "test.txt"
    if(drive==SDFS) {
      if(sd_path_name[0]==0) {
        sprintf(path_name,"%s%s",SDPath,fname);
      }
      else {
        sprintf(path_name,"%s/%s",sd_path_name,fname);
      } 
    }
    else if(drive==USBFS) {
      if(usb_path_name[0]==0) {
        sprintf(path_name,"%s%s",USBPath,fname);
      }
      else {
        sprintf(path_name,"%s/%s",usb_path_name,fname);
      }
    }
    else {
      return -1;
    }
  }
  else {
    // filename with drive e.g. "b:/test.txt"
    sprintf(path_name,"%s",fname);
    if(drive==SDFS) {
      path_name[0]='1';
    }
    else if(drive==USBFS) {
      path_name[0]='0';
    }
    else {
      return -2;
    }    
  }

  return 0;
}



// return the drive designation
// this will:
//   - find the drive prefix (A: or B:) in the argument
//   - throw an error if the prefix is not a valid drive
//   - throw an error if the file name is empty or too long
//   - return with the drive designation (ie, FLASHFS or SDCARD)
//   - if the prefix is not specified this will return with the current default drive.
int GetDrive(char *p) {
	int fs = 0;
	char *pp;

	if(*p && p[1] == ':') {
		if(toupper(p[0]) == 'B')
			fs = SDFS;
		else
			if(toupper(p[0]) == 'A')
				fs = FLASHFS;
			else
				if(toupper(p[0]) == 'C')
					fs = USBFS;
				else
					error("Unrecognised drive letter");
	} else
		fs = DefaultDrive;
	pp = GetFName(p);
	if(fs == FLASHFS && strlen(pp) > FILENAME_LENGTH) error("Invalid Filename");
	return fs;
}



// fname must be a standard C style string (not the MMBasic style)
void MMfopen(char *fname, char *mode, int fnbr) {
	FRESULT res;

	if(fnbr < 1 || fnbr > 10) error("Invalid file number");
	fnbr--;

	if(GetDrive(fname) == FLASHFS) {
		// Flash filesystem
		error("flash not supported");
	}
	else if(GetDrive(fname) == SDFS) {
		// SD card filesystem
                if(MMFilePtr[fnbr] != NULL) error("File number is already open");
		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[1]);
		if(UB_Fatfs_Mount(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[15]);
		SetPathNameF7(fname,SDFS);

		switch(*mode) {
			case 'r':	res=f_open(&MMFile, path_name, FA_OPEN_EXISTING | FA_READ);
						break;
			case 'w':   res=f_open(&MMFile, path_name, FA_CREATE_ALWAYS | FA_WRITE);
			            if(res!=FR_OK) errorF7((char *)FErrorMsg[6]);
			            break;
			case 'a':   res=f_open(&MMFile, path_name, FA_OPEN_ALWAYS | FA_WRITE);
						if(res==FR_OK) res=f_lseek(&MMFile, f_size(&MMFile));
            			break;
    		case 'x':   res=f_open(&MMFile, path_name, FA_OPEN_ALWAYS | FA_WRITE | FA_READ);
    					if(res==FR_OK) res=f_lseek(&MMFile, f_size(&MMFile));
						break;
    		default : res=FR_INVALID_OBJECT;
		}

		if(res!=FR_OK) errorF7((char *)FErrorMsg[6]);
		MMDrive=SDFS;
                MMFilePtr[fnbr] = (F7FILE *)SDFS;
	}
	else if(GetDrive(fname) == USBFS) {
		// USB-Drive filesystem
                if(MMFilePtr[fnbr] != NULL) error("File number is already open");
		if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) error("USB-Drive not found");
		if(UB_Fatfs_Mount(USB_0)!=FATFS_OK) error("Cannot access the USB-Drive");
		SetPathNameF7(fname,USBFS);

		switch(*mode) {
			case 'r':	res=f_open(&MMFile, path_name, FA_OPEN_EXISTING | FA_READ);
						break;
			case 'w':   res=f_open(&MMFile, path_name, FA_CREATE_ALWAYS | FA_WRITE);
			            break;
			case 'a':   res=f_open(&MMFile, path_name, FA_OPEN_ALWAYS | FA_WRITE);
						if(res==FR_OK) res=f_lseek(&MMFile, f_size(&MMFile));
            			break;
    		case 'x':   res=f_open(&MMFile, path_name, FA_OPEN_ALWAYS | FA_WRITE | FA_READ);
    					if(res==FR_OK) res=f_lseek(&MMFile, f_size(&MMFile));
						break;
    		default : res=FR_INVALID_OBJECT;
		}

		if(res!=FR_OK) error((char *)FErrorMsg[6]);
		MMDrive=USBFS;
                MMFilePtr[fnbr] = (F7FILE *)USBFS;
	}
	else {
		error("invalid drive");
	}
}




void MMfclose(int fnbr) {
	if(fnbr < 1 || fnbr > 10) error("Invalid file number");
	fnbr--;
	if(MMFilePtr[fnbr] != NULL && MMFilePtr[fnbr] <= (F7FILE *)NBR_SERIAL_PORTS) {
		SerialClose((int)MMFilePtr[fnbr]);
	}
	else if(MMDrive==SDFS) {
		// SD card filesystem
		if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[1]);
		f_close(&MMFile);
		UB_Fatfs_UnMount(MMC_1);
		ENABLE_USB();
		MMDrive=0;
		MMFilePtr[fnbr] = NULL;
		ErrorCheck();
	}
	else if(MMDrive==USBFS) {
		// USB-Drive filesystem
		if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) errorF7("USB-Drive not found");
		f_close(&MMFile);
		UB_Fatfs_UnMount(USB_0);
		ENABLE_USB();
		MMDrive=0;
		MMFilePtr[fnbr] = NULL;
		ErrorCheck();
	}
	MMFilePtr[fnbr] = NULL;
}



char MMfgetc(int fnbr) {
	char ch;
	unsigned int uread;
	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return MMgetchar();
	fnbr--;
	if(MMFilePtr[fnbr] != NULL && MMFilePtr[fnbr] <= (F7FILE *)NBR_SERIAL_PORTS) {
	  return SerialGetchar((int)MMFilePtr[fnbr]);
	}
	else if(MMDrive==SDFS) {
	  // SD card filesystem
	  if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) return 0;
	  if(f_read(&MMFile, &ch, 1, &uread) != FR_OK)  ch = 0xff;
	  ErrorCheck();
	  return ch;
	}
	else if(MMDrive==USBFS) {
		// USB-Drive filesystem
	  if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) return 0;
	  if(f_read(&MMFile, &ch, 1, &uread) != FR_OK)  ch = 0xff;
	  ErrorCheck();
	  return ch;
	}
	else return 0;
}



char MMfputc(char c, int fnbr) {
	unsigned int uread;
	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return MMputchar(c);
	fnbr--;
	if(MMFilePtr[fnbr] != NULL && MMFilePtr[fnbr] <= (F7FILE *)NBR_SERIAL_PORTS) {
	  return SerialPutchar((int)MMFilePtr[fnbr], c);
	}
	else if(MMDrive==SDFS) {
	  // SD card filesystem
	  if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) return 0;
	  if(f_write(&MMFile, &c, 1, &uread) != FR_OK)  error((char *)FErrorMsg[11]);
	  ErrorCheck();
	  return c;
	}
	else if(MMDrive==USBFS) {
		// USB-Drive filesystem
	  if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) return 0;
	  if(f_write(&MMFile, &c, 1, &uread) != FR_OK)  error((char *)FErrorMsg[11]);
	  ErrorCheck();
	  return c;
	}
	else return 0;
}



int MMfeof(int fnbr) {
	int i;
	if(fnbr < 0 || fnbr > 10) error("Invalid file number");
	if(fnbr == 0) return 0;
	fnbr--;
	if(MMFilePtr[fnbr] != NULL && MMFilePtr[fnbr] <= (F7FILE *)NBR_SERIAL_PORTS) {
		return SerialRxStatus((int)MMFilePtr[fnbr]) == 0;
	}

	if(MMDrive==SDFS) {
		// SD card filesystem
	  if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[1]);	  
	  i = (f_eof(&MMFile) != 0) ? -1 : 0;
	  ErrorCheck();
	  return i;
	}
	else if(MMDrive==USBFS) {
		// USB-Drive filesystem
	  if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) errorF7("USB-Drive not found");
	  i = (f_eof(&MMFile) != 0) ? -1 : 0;
	  ErrorCheck();
	  return i;
	}
	else return 0;
}





char *MMgetcwd(void) {
	char *b;
	b = GetTempStringSpace();
	if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) return b;
	if(!MMerrno) { b[0] = 'B'; b[1] = ':'; }
	return b;
}



void CloseAllFiles(void) {
#if !defined(STM32F7) // PIC
	int i, prev;
	if(year > 2010) SetClockVars(year, month, day, hour, minute, second);
	prev = OptionErrorAbort;
	OptionErrorAbort = false;										// don't abort on error
	for(i = 0; i < MAXOPENFILES; i++) {
		if(MMFilePtr[i] != NULL) MMfclose(i + 1);					// try and close a file
		MMFilePtr[i] = NULL;										// make sure that the entry is removed
	}
	FlashStatus = CLOSED;
	FlashEOF = false;
	OptionErrorAbort = prev;
#else // STM32F746
	int i;
	for(i = 0; i < MAXOPENFILES; i++) {
		if(MMFilePtr[i] != NULL) MMfclose(i + 1);					// try and close a file
		MMFilePtr[i] = NULL;										// make sure that the entry is removed
	}
#endif // STM32F746
}


int InitSDCard(void) {
#if !defined(STM32F7) // PIC
	int i;
	ErrorThrow(0);				// reset mm.errno to zero
	if(SDCardRemoved == false) return true;
	for(i = 0; i < MAXOPENFILES; i++) MMFilePtr[i] = NULL;	            // make sure that the table is empty
	if(!MDD_MediaDetect()) { ErrorThrow(1); return false; }
	if(!FSInit())  { ErrorThrow(15); return false; }
	SDCardRemoved = false;
	SDActivityLED = SDActivityTime;
	return true;
#else // STM32F746
	error("InitSDCard");
	return false;
#endif // STM32F746
}



// finds the first available free file number.  Throws an error if no free file numbers
int FindFreeFileNbr(void) {
	int i;
	for(i = 0; i < MAXOPENFILES; i++)
		if(MMFilePtr[i] == NULL) return i + 1;
	error("Too many files open");
	return 0;
}


int GetFileLength(int fnbr)
{
	if(fnbr < 1 || fnbr > 10) error("Invalid file number");
	fnbr--;

	return f_size(&MMFile);
}



// this function takes a path (ie, "\dir1\dir2\file.bas") and:
//    1.  saves the current working directory in temporary buffer
//    2.  changes to the directory specified in the path
//    3.  returns with a pointer pointing to the file component
// if called with a NULL argument this function will change back to the previously saved directory
char *ChangeToDir(char *p) {
#if !defined(STM32F7) // PIC
	static char *cwd = NULL;
	char *tp;

	// if the argument is NULL the caller wants to return to the previously saved directory
	if(p == NULL) {
		if(cwd != NULL)
		#if defined(SUPPORT_LFN)
			wFSchdir(ConvertToUTF16(cwd));
		#else
			FSchdir(cwd);
		#endif
		return NULL;
	}

	cwd = NULL;

	// adjust p to remove the drive letter if present
	if( p[1] == ':') {
		if(toupper(p[0]) == 'B')
			p += 2;
		else
			error("Unrecognised drive letter");
	}
	if(!*p) error("Invalid file or directory name");

	// search backwards for for the directory separator and set tp to point to it
	tp = p + strlen(p);
	while(tp != p && *tp != '\\') tp--;

	// if we end up pointing to the start of the string this could because of:
	//    1.  The path started at the root (ie, "\file.bas")
	//    2.  There is no directory component (ie, "file.bas")
	if(tp == p) {
		if(*p != '\\') return p;							// if there is no directory component we can return immediately pointing to the file component
		p = "\\";											// otherwise provide the root for the rest of the function to use
	}

	cwd = GetTempStringSpace();								// allocate some memory
	SDActivityLED = SDActivityTime;
	FSgetcwd(cwd, STRINGSIZE - 2);							// get the current directory
	if(ErrorCheck()) return "";
	*tp = 0;												// terminate the directory component in the function's argument
#if defined(SUPPORT_LFN)
	wFSchdir(ConvertToUTF16(p));							// change to the directory component
#else
	FSchdir(p);												// change to the directory component
#endif
	if(ErrorCheck()) return "";
	*tp = '\\';												// replace the character
	return tp + 1;											// return pointing to the file component of the path
#else // STM32F746
	error("ChangeToDir");
	return NULL;
#endif // STM32F746
}




// confirm that a file exists and get its case mapping.
// first this searches the file system looking for a file that has the same name regardless of the case
// if found it rewrites the argument with the file name (and case) as found on the card and returns true.
// if not found it will return false.
// This is needed because the MDD file system is case sensitive and we do not want that.
int SDCheckFileName(char *p) {
	int ret=false;
	FRESULT fr;
	FILINFO fno;

	DISABLE_USB();
	if(UB_Fatfs_Mount(MMC_1)==FATFS_OK) {
	  SetPathNameF7(p,SDFS);
	  fr = f_stat(path_name, &fno);
  	  if(fr==FR_OK) ret=true;
	}
  	UB_Fatfs_UnMount(MMC_1);
  	ENABLE_USB();

	return ret;
}

int USBCheckFileName(char *p) {
	int ret=false;
	FRESULT fr;
	FILINFO fno;

	if(UB_Fatfs_Mount(USB_0)==FATFS_OK) {
	  SetPathNameF7(p,USBFS);
	  fr = f_stat(path_name, &fno);
  	  if(fr==FR_OK) ret=true;
	}
  	UB_Fatfs_UnMount(USB_0);

	return ret;
}




/////////////////////////////////////// routines used by both the flash and SD card file systems //////////////////////////////////

// recursive function to compare a file_name with a wildcard_name
// file_name     : "test.txt"
// wildcard_name : "t*.txt"
// returns 1 if file_name==wilcard_name
int wildcardIsOk(char *filename, char *wildcard)
{
    while (*wildcard)
    {
        if (*wildcard=='?')
        {
            if (!*filename) return 0;

            ++filename;
            ++wildcard;
        }
        else if (*wildcard=='*')
        {
            if (wildcardIsOk(filename,wildcard+1)) return 1;
            if (*filename && wildcardIsOk(filename+1,wildcard)) return 1;
            return 0;
        }
        else
        {
            if(toupper(*filename++)!=toupper(*wildcard++)) return 0;
        }
    }

    return !*filename && !*wildcard;
}


void cmd_files(void) {
	char *p;
	char ts[STRINGSIZE] = "";
	FRESULT res = FR_OK;
	DIR dir;
	FILINFO fno;
	char *fn;
	int dirs=0,fcnt=0,i,fsize;
	s_flist flist[MAXFILES];
	char tmp[STRINGSIZE] = "";

	if(*cmdline)
		p = GetFileName(cmdline, NULL);
	else
		p = ts;


	if(CurrentLinePtr) error("Invalid in a program");
	// is this the flash filesystem?
	if((p[0] == 0 && DefaultDrive == FLASHFS) || (p[1] == ':' && toupper(p[0]) == 'A') || (p[1] != ':' && DefaultDrive == FLASHFS)) {
		error("flash not supported");
	}
	else if((p[0] == 0 && DefaultDrive == SDFS) || (p[1] == ':' && toupper(p[0]) == 'B') || (p[1] != ':' && DefaultDrive == SDFS)) {
		// this is the SD card


//	   	if(!*p) strcat(p, "*.*");										// add wildcard if needed
//    	if(strchr(p, '.') == NULL && strchr(p, '*') == NULL && strchr(p, '?') == NULL)  strcat(p, "\\*.*");	// add wildcard if needed

		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[1]);
		if(UB_Fatfs_Mount(MMC_1)!=FATFS_OK) errorF7((char *)FErrorMsg[15]);		

		if(sd_path_name[0]==0) {
		  sprintf(path_name,"%s",SDPath);
		}
		else {
	      sprintf(path_name,"%s",sd_path_name);
		}
		strcpy(ts, path_name);
		ts[0]='B';
		MMPrintString(ts); MMPrintString("\r\n");

		strcpy(tmp,p);
		if(strcmp(ts,tmp)==0) strcpy(tmp,"*.*"); // replace empty entry with "*.*"
		if(strchr(tmp, '.') == NULL) sprintf(tmp, "%s.*",p); // replace empty fileending with ".*"
		if(strncmp(tmp,".",1)==0)  sprintf(tmp,"*%s",p); // replace empty filename with "*"
		//MMPrintString(tmp); MMPrintString("\r\n"); // this is the wildcard string

		res = f_opendir(&dir, path_name);
		if(res == FR_OK) {
			while(UB_Fatfs_CheckMedia(MMC_1)==FATFS_OK) {
				res = f_readdir(&dir, &fno);
				if(res != FR_OK || fno.fname[0] == 0) break;
				if(fno.fname[0] == '.')	continue;
                  fn = fno.fname;

          		if(fcnt >= MAXFILES) {
          			errorF7("Too many files to list");
          		}

				if((fno.fattrib & AM_MASK) == AM_DIR) { // directory
					ts[0] = 'D';
					fsize=0;
				}
				else { // file
					ts[0] = 'F';
					fsize=fno.fsize;
				}
				strcpy(&ts[1], fn);

		   		// sort the file+dir name into place in the array
				if((ts[0] == 'D') || (wildcardIsOk(ts+1,tmp))) {
 		    		for(i = fcnt; i > 0; i--) {
		    			if(strcmp(flist[i - 1].fn, ts) > 0)
		    				flist[i] = flist[i - 1];
		    			else
		    				break;
		    		}

		    		strcpy(flist[i].fn, ts);
		    		flist[i].fs = fsize;
		    		fcnt++;
				}
			}
			f_closedir(&dir);
		}
		else errorF7((char *)FErrorMsg[15]);
		UB_Fatfs_UnMount(MMC_1);
		ENABLE_USB();

			// show file+dir list
			ListCnt = 2;
			for(i = 0; i < fcnt; i++) {
				if(flist[i].fn[0] == 'D') {
			    	dirs++;
					sprintf(ts,"   <DIR>  %s\r\n", flist[i].fn + 1);
				}
				else {
			   		sprintf(ts, "%8d  %s\r\n", flist[i].fs, flist[i].fn + 1);
				}
				MMPrintString(ts);
				// check if it is more than a screenfull
				if(VRes > 0 && ListCnt >= (VRes / (fontHeight * fontScale)) && i < fcnt) {
					MMPrintString("PRESS ANY KEY ...");
					MMgetchar();
					MMPrintString("\r                 \r");
					ListCnt = 1;
				}
			}
			sprintf(ts, "%d director%s, %d file%s\r\n", dirs, (dirs==1?"y":"ies"), fcnt - dirs, ((fcnt-dirs)==1?"":"s"));
			MMPrintString(ts);



		longjmp(mark, 1);							// jump back to the input prompt
	}
	else {
		// this is the USB-Drive

		DISABLE_USB();
		if(UB_Fatfs_CheckMedia(USB_0)!=FATFS_OK) errorF7("USB-Drive not found");
		if(UB_Fatfs_Mount(USB_0)!=FATFS_OK) errorF7("Cannot access the USB-Drive");

		if(usb_path_name[0]==0) {
		  sprintf(path_name,"%s",USBPath);
		}
		else {
	      sprintf(path_name,"%s",usb_path_name);
		}
		strcpy(ts, path_name);
		ts[0]='C';
		MMPrintString(ts); MMPrintString("\r\n");

		strcpy(tmp,p);
		if(strcmp(ts,tmp)==0) strcpy(tmp,"*.*"); // replace empty entry with "*.*"
		if(strchr(tmp, '.') == NULL) sprintf(tmp, "%s.*",p); // replace empty fileending with ".*"
		if(strncmp(tmp,".",1)==0)  sprintf(tmp,"*%s",p); // replace empty filename with "*"
		//MMPrintString(tmp); MMPrintString("\r\n"); // this is the wildcard string

		res = f_opendir(&dir, path_name);
		if(res == FR_OK) {
			while(UB_Fatfs_CheckMedia(USB_0)==FATFS_OK) {
				UB_USB_MSC_HOST_Do();
				res = f_readdir(&dir, &fno);
				if(res != FR_OK || fno.fname[0] == 0) break;
				if(fno.fname[0] == '.')	continue;
                  fn = fno.fname;

            		if(fcnt >= MAXFILES) {
            			errorF7("Too many files to list");
            		}

  				if((fno.fattrib & AM_MASK) == AM_DIR) { // directory
  					ts[0] = 'D';
  					fsize=0;
  				}
  				else { // file
  					ts[0] = 'F';
  					fsize=fno.fsize;
  				}
  				strcpy(&ts[1], fn);

  		   		// sort the file+dir name into place in the array
  				if((ts[0] == 'D') || (wildcardIsOk(ts+1,tmp))) {
  		    		for(i = fcnt; i > 0; i--) {
  		    			if(strcmp(flist[i - 1].fn, ts) > 0)
  		    				flist[i] = flist[i - 1];
  		    			else
  		    				break;
  		    		}

  		    		strcpy(flist[i].fn, ts);
  		    		flist[i].fs = fsize;
  		    		fcnt++;
  				}
			}
			f_closedir(&dir);
		}
		else errorF7("Cannot access the USB-Drive");
		UB_Fatfs_UnMount(USB_0);
		ENABLE_USB();

			// show file+dir list
			ListCnt = 2;
			for(i = 0; i < fcnt; i++) {
				if(flist[i].fn[0] == 'D') {
			    	dirs++;
					sprintf(ts,"   <DIR>  %s\r\n", flist[i].fn + 1);
				}
				else {
			   		sprintf(ts, "%8d  %s\r\n", flist[i].fs, flist[i].fn + 1);
				}
				MMPrintString(ts);
				// check if it is more than a screenfull
				if(VRes > 0 && ListCnt >= (VRes / (fontHeight * fontScale)) && i < fcnt) {
					MMPrintString("PRESS ANY KEY ...");
					MMgetchar();
					MMPrintString("\r                 \r");
					ListCnt = 1;
				}

			}
			sprintf(ts, "%d director%s, %d file%s\r\n", dirs, (dirs==1?"y":"ies"), fcnt - dirs, ((fcnt-dirs)==1?"":"s"));
			MMPrintString(ts);


		longjmp(mark, 1);							// jump back to the input prompt
	}
}



