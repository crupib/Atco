//--------------------------------------------------------------
// File     : stm32_ub_fatfs.c
// Datum    : 09.08.2015
// Version  : 1.0
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL, FATFS
// Funktion : File-Funktionen per FatFS-Library
//              USB und/oder MMC im H-File aktivieren
//
// Hinweis  : Copy all FATFS-LoLevel Files in a new folder : "\fatfs"
//            and add the include Path : "${ProjDirPath}/fatfs"
//--------------------------------------------------------------
// nur USB : Pfad-USB = "0:/"
//           Files    = "usbh_diskio.c+h"
//                      "stm32_ub_usb_msc_host.c+h"
//
// nur MMC : Pfad-MMC = "0:/"
//           Files    = "sd_diskio.c+h"
//                      "stm32746g_discovery_sd.c+h"
//
// USB+MMC : Pfad-USB = "0:/"
//           Pfad-MMC = "1:/"
//           Files    = "usbh_diskio.c+h"
//                      "stm32_ub_usb_msc_host.c+h"
//                      "sd_diskio.c+h"
//                      "stm32746g_discovery_sd.c+h"
//--------------------------------------------------------------



//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_fatfs.h"
#if FATFS_USE_USB_MEDIA==1
  #include "usbh_diskio.h"
  #include "stm32_ub_usb_msc_host.h"
  FATFS usb_FATFS;
  char USBPath[4];
  uint8_t usb_device_ok=0;
#endif
#if FATFS_USE_MMC_MEDIA==1
  #include "sd_diskio.h"
  #include "stm32746g_discovery_sd.h"
  FATFS sd_FATFS;
  char SDPath[4];
  uint8_t mmc_device_ok=0;
#endif




//--------------------------------------------------------------
// Init-Funktion
// (init aller Systeme)
//--------------------------------------------------------------
void UB_Fatfs_Init(void)
{
  uint8_t check;

  #if FATFS_USE_USB_MEDIA==1
    check=FATFS_LinkDriver(&USBH_Driver, USBPath);
    if(check==0) usb_device_ok=1;
  #endif

  #if FATFS_USE_MMC_MEDIA==1
    check=FATFS_LinkDriver(&SD_Driver, SDPath);
    if(check==0) mmc_device_ok=1;
  #endif
}


//--------------------------------------------------------------
// Status vom Medium abfragen
// dev : [USB_0, MMC_1]
// Return Wert :
//     FATFS_OK    => Medium eingelegt
//  FATFS_NO_MEDIA => kein Medium eingelegt
//--------------------------------------------------------------
FATFS_t UB_Fatfs_CheckMedia(MEDIA_t dev)
{
  FATFS_t ret_wert=FATFS_NO_MEDIA;

  if(dev==USB_0) {
    #if FATFS_USE_USB_MEDIA==1
      if(usb_device_ok==0) return FATFS_NO_MEDIA;
      if(USB_MSC_HOST_STATUS==USB_MSC_DEV_CONNECTED) ret_wert=FATFS_OK;
    #endif
  }
  else if(dev==MMC_1) {
    #if FATFS_USE_MMC_MEDIA==1
      if(mmc_device_ok==0) return FATFS_NO_MEDIA;
      if(BSP_SD_IsDetected()==SD_PRESENT) ret_wert=FATFS_OK;
    #endif
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// Media mounten
// dev : [USB_0, MMC_1]
// Return Wert :
//     FATFS_OK       => kein Fehler
//  FATFS_MOUNT_ERR   => Fehler
//  FATFS_GETFREE_ERR => Fehler
//--------------------------------------------------------------
FATFS_t UB_Fatfs_Mount(MEDIA_t dev)
{
  FATFS_t ret_wert=FATFS_MOUNT_ERR;
  FRESULT check;
  DWORD fre_clust;
  FATFS	*fs;

  if(dev==USB_0) {
    #if FATFS_USE_USB_MEDIA==1
      if(usb_device_ok==0) return FATFS_MOUNT_ERR;
      check=f_mount(&usb_FATFS, (TCHAR const*)USBPath, 0);
      if(check==FR_OK) {
        check=f_getfree((TCHAR const*)USBPath, &fre_clust, &fs);
        if(check==FR_OK) ret_wert=FATFS_OK;
      }
    #endif
  }
  else if(dev==MMC_1) {
    #if FATFS_USE_MMC_MEDIA==1
      if(mmc_device_ok==0) return FATFS_MOUNT_ERR;
      SD_Driver.disk_initialize(0);
      check=f_mount(&sd_FATFS, (TCHAR const*)SDPath, 0);
      if(check==FR_OK) {
        check=f_getfree((TCHAR const*)SDPath, &fre_clust, &fs);
        if(check==FR_OK) ret_wert=FATFS_OK;
      }
    #endif
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// Media unmounten
// dev : [USB_0, MMC_1]
// Return Wert :
//     FATFS_OK     => kein Fehler
//  FATFS_MOUNT_ERR => Fehler
//--------------------------------------------------------------
FATFS_t UB_Fatfs_UnMount(MEDIA_t dev)
{
  FATFS_t ret_wert=FATFS_MOUNT_ERR;
  FRESULT check;

  if(dev==USB_0) {
    #if FATFS_USE_USB_MEDIA==1
      if(usb_device_ok==0) return FATFS_MOUNT_ERR;
      check=f_mount(NULL, (TCHAR const*)USBPath, 0);
      if(check==FR_OK) ret_wert=FATFS_OK;
    #endif
  }
  else if(dev==MMC_1) {
    #if FATFS_USE_MMC_MEDIA==1
      if(mmc_device_ok==0) return FATFS_MOUNT_ERR;
      check=f_mount(NULL, (TCHAR const*)SDPath, 0);
      if(check==FR_OK) ret_wert=FATFS_OK;
    #endif
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// File loeschen
// File darf nicht geoeffnet sein
// Name ist der komplette Pfad z.B. "0:/Test.txt" bzw : "1:/Hallo.txt"
// Return Wert :
//     FATFS_OK      => kein Fehler
//  FATFS_UNLINK_ERR => Fehler
//--------------------------------------------------------------
FATFS_t UB_Fatfs_DelFile(const char* name)
{
  FATFS_t ret_wert=FATFS_UNLINK_ERR;
  FRESULT check=FR_INVALID_PARAMETER;

  check=f_unlink(name);
  if(check==FR_OK) {
    ret_wert=FATFS_OK;
  }
  else {
    ret_wert=FATFS_UNLINK_ERR;
  }

  return(ret_wert);
}

//--------------------------------------------------------------
// File oeffnen (zum lesen oder schreiben)
// File per &-Operator übergeben
// Name ist der komplette Pfad z.B. "0:/Test.txt" bzw : "1:/Hallo.txt"
// mode : [F_RD, F_WR, F_WR_NEW, F_WR_CLEAR]
// Return Wert :
//     FATFS_OK    => kein Fehler
//  FATFS_OPEN_ERR => Fehler
//  FATFS_SEEK_ERR => Fehler bei WR und WR_NEW
//--------------------------------------------------------------
FATFS_t UB_Fatfs_OpenFile(FIL* fp, const char* name, FMODE_t mode)
{
  FATFS_t ret_wert=FATFS_OPEN_ERR;
  FRESULT check=FR_INVALID_PARAMETER;

  if(mode==F_RD) check = f_open(fp, name, FA_OPEN_EXISTING | FA_READ);
  if(mode==F_WR) check = f_open(fp, name, FA_OPEN_EXISTING | FA_WRITE);
  if(mode==F_WR_NEW) check = f_open(fp, name, FA_OPEN_ALWAYS | FA_WRITE);
  if(mode==F_WR_CLEAR) check = f_open(fp, name, FA_CREATE_ALWAYS | FA_WRITE);

  if(check==FR_OK) {
    ret_wert=FATFS_OK;
    if((mode==F_WR) || (mode==F_WR_NEW)) {
      // Pointer ans Ende vom File stellen
      check = f_lseek(fp, f_size(fp));
      if(check!=FR_OK) {
        ret_wert=FATFS_SEEK_ERR;
      }
    }
  }

  return(ret_wert);
}

//--------------------------------------------------------------
// File schliessen
// File per &-Operator übergeben
// Return Wert :
//     FATFS_OK     => kein Fehler
//  FATFS_CLOSE_ERR => Fehler
//--------------------------------------------------------------
FATFS_t UB_Fatfs_CloseFile(FIL* fp)
{
  FATFS_t ret_wert=FATFS_CLOSE_ERR;
  FRESULT check=FR_INVALID_PARAMETER;

  check=f_close(fp);
  if(check==FR_OK) ret_wert=FATFS_OK;

  return(ret_wert);
}

//--------------------------------------------------------------
// String in File schreiben
// File muss offen sein
// File per &-Operator übergeben
// Zeilenendekennung ('\n') wird automatisch angehängt
// Return Wert :
//     FATFS_OK    => kein Fehler
//  FATFS_PUTS_ERR => Fehler
//--------------------------------------------------------------
FATFS_t UB_Fatfs_WriteString(FIL* fp, const char* text)
{
  FATFS_t ret_wert=FATFS_PUTS_ERR;
  int check=0;

  check=f_puts(text, fp);

  if(check>=0) {
    ret_wert=FATFS_OK;
    // Zeilenendekennung hinzufügen
    f_putc('\n', fp);
  }
  else {
    ret_wert=FATFS_PUTS_ERR;
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// String aus einem File lesen
// File muss offen sein
// File per &-Operator übergeben
// text : String
// len  : Grösse des String-Puffers
//        es werden (len) Zeichen ausgelesen
//        oder bis Fileende bzw. Stringende erreicht ist
// Return Wert :
//     FATFS_OK        => kein Fehler
//    FATFS_EOF        => Fileende erreicht
// FATFS_RD_STRING_ERR => Fehler
//--------------------------------------------------------------
FATFS_t UB_Fatfs_ReadString(FIL* fp, char* text, uint32_t len)
{
  FATFS_t ret_wert=FATFS_RD_STRING_ERR;
  int check;

  f_gets(text, len, fp);
  check=f_eof(fp);
  if(check!=0) return(FATFS_EOF);
  check=f_error(fp);
  if(check!=0) return(FATFS_RD_STRING_ERR);
  ret_wert=FATFS_OK;

  return(ret_wert);
}


//--------------------------------------------------------------
// Filegröße auslesen
// File muss offen sein
// File per &-Operator übergeben
// Return Wert :
//   >0 => Filegröße in Bytes
//   0  => Fehler
//--------------------------------------------------------------
uint32_t UB_Fatfs_FileSize(FIL* fp)
{
  uint32_t ret_wert=0;
  int filesize;

  filesize=f_size(fp);
  if(filesize>=0) ret_wert=(uint32_t)(filesize);

  return(ret_wert);
}


//--------------------------------------------------------------
// Datenblock aus einem File lesen
// File muss offen sein
// File per &-Operator übergeben
// buf  : Puffer für die Daten
// len  : Grösse des Daten-Puffers (max 512 Bytes)
//        es werden (len) Zeichen ausgelesen
//        oder bis Fileende erreicht ist
// read : Anzahl der Zeichen die ausgelesen wurden (bei err=>0)
// Return Wert :
//     FATFS_OK        => kein Fehler
//    FATFS_EOF        => Fileende erreicht
//  FATFS_RD_BLOCK_ERR => Fehler
//--------------------------------------------------------------
FATFS_t UB_Fatfs_ReadBlock(FIL* fp, unsigned char* buf, uint32_t len, uint32_t* read)
{
  FATFS_t ret_wert=FATFS_RD_BLOCK_ERR;
  FRESULT check=FR_INVALID_PARAMETER;
  UINT ulen,uread;

  ulen=(UINT)(len);
  if(ulen>_MAX_SS) {
    ret_wert=FATFS_RD_BLOCK_ERR;
    *read=0;
  }
  else {
    check=f_read(fp, buf, ulen, &uread);
    if(check==FR_OK) {
      *read=(uint32_t)(uread);
      if(ulen==uread) {
        ret_wert=FATFS_OK;
      }
      else {
        ret_wert=FATFS_EOF;
      }
    }
    else {
      ret_wert=FATFS_RD_BLOCK_ERR;
      *read=0;
    }
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// Datenblock in ein File schreiben
// File muss offen sein
// File per &-Operator übergeben
// buf  : Daten (in einem Puffer)
// len  : Grösse des Daten-Puffers (max 512 Bytes)
//        es werden (len) Zeichen geschrieben
// write : Anzahl der Zeichen die geschrieben wurden (bei err=>0)
// Return Wert :
//     FATFS_OK        => kein Fehler
//    FATFS_DISK_FULL  => kein Speicherplatz mehr
//  FATFS_WR_BLOCK_ERR => Fehler
//--------------------------------------------------------------
FATFS_t UB_Fatfs_WriteBlock(FIL* fp, unsigned char* buf, uint32_t len, uint32_t* write)
{
  FATFS_t ret_wert=FATFS_WR_BLOCK_ERR;
  FRESULT check=FR_INVALID_PARAMETER;
  UINT ulen,uwrite;

  ulen=(UINT)(len);
  if(ulen>_MAX_SS) {
    ret_wert=FATFS_WR_BLOCK_ERR;
    *write=0;
  }
  else {
    check=f_write(fp, buf, ulen, &uwrite);
    if(check==FR_OK) {
      *write=(uint32_t)(uwrite);
      if(ulen==uwrite) {
        ret_wert=FATFS_OK;
      }
      else {
        ret_wert=FATFS_DISK_FULL;
      }
    }
    else {
      ret_wert=FATFS_WR_BLOCK_ERR;
      *write=0;
    }
  }

  return(ret_wert);
}


