// CAN2.c
// Copyright 2012 - John Harding
// See license.txt for details of licensing


#include <p32xxxx.h>
#include <plib.h>
#include <stdio.h>
#include "../MMBasic/MMBasic.h"
#include "../Maximite.h"
#include "../MMSource/Memory.h"

#ifdef INCLUDE_CAN

#define CAN_VERSION   "beta 2"

///////////////////////////////
// CAN Implementation
#define CAN_EXT_ID_BIT_MASK              (0x80000000ul)  // bit to indicate that the id is 29-bit instead of 11-bit
#define CAN_COMMUNICATION_SPEED_MIN      (10000ul)       // 10 kbps
#define CAN_COMMUNICATION_SPEED_MAX      (1000000ul)     // 1 Mbps

#define ULONG unsigned long

static void CanFree();
static BYTE CanConfig();
static BYTE CanGetSpeedConfig(unsigned long baud, CAN_BIT_CONFIG *canBitConfig);
static BYTE CanSetSpeed(ULONG speed);
static BYTE CanAddRXChnl(BYTE channel_number, ULONG id, BYTE typ, BYTE buffer_size);
static BYTE CanAddTXChnl(BYTE channel_number, BYTE buffer_size);
static BYTE CanEnable();
static BYTE CanDisable();
static BYTE CanFullRX(BYTE channel_number, ULONG* id, BYTE* len, BYTE* data);
static BYTE CanRX(BYTE channel_number, BYTE* data);
static BYTE CanTX(BYTE channel_number, ULONG id, BYTE len, BYTE* data);
static void CanTest();

static void subcmd_canFree     (char* subcmd);
static void subcmd_canConfig   (char* subcmd);
static void subcmd_canSetSpeed (char* subcmd);
static void subcmd_canAddRXChnl(char* subcmd);
static void subcmd_canAddTXChnl(char* subcmd);
static void subcmd_canEnable   (char* subcmd);
static void subcmd_canDisable  (char* subcmd);
static void subcmd_canFullRX   (int argc, char* argv[]);
static void subcmd_canRX       (char* subcmd);
static void subcmd_canTX       (char* subcmd);



static BYTE  canOnline = 0;
static BYTE* pCanBuffer = NULL;
static size_t canBufferSize = 0;
static ULONG   canChannelFlags = 0;
static int   canSpeed = 0;

#define CAN_FULL_RECORD_SIZE 16
#define CAN_DATA_ONLY_SIZE   8

// Based on code copyright (2010) David Harding - used with permission by his little bruvver
static BYTE CanGetSpeedConfig(unsigned long baud, CAN_BIT_CONFIG *canBitConfig)
{
    // Calculate bit timing registers
    BYTE BRP;
    float TQ;
    BYTE BT=0;
    BYTE SJW = 1;
    float tempBT;

    float NBT = 1.0 / (float)baud; // Nominal Bit Time
    for(BRP=0;BRP<8;BRP++) {
        TQ = 2.0 * (float)(BRP + 1) / (float) (CLOCKFREQ);
        tempBT = NBT / TQ;
        if(tempBT<=25) {
            BT = (int)tempBT;
            if(tempBT-BT==0) break;
        }
    }

    BYTE SPT = (0.7 * BT); // Sample point
    BYTE PRSEG = (SPT - 1) / 2;
    BYTE PHSEG1 = SPT - PRSEG - 1;
    BYTE PHSEG2 = BT - PHSEG1 - PRSEG - 1;

    // Programming requirements
    if(PRSEG + PHSEG1 < PHSEG2) return 0;
    if(PHSEG2 <= SJW) return 0;

    // note the -1 because the can library is using a zero based enum
    canBitConfig->phaseSeg2Tq            = PHSEG2-1;
    canBitConfig->phaseSeg1Tq            = PHSEG1-1;
    canBitConfig->propagationSegTq       = PRSEG-1;
    canBitConfig->phaseSeg2TimeSelect    = TRUE;
    canBitConfig->sample3Time            = FALSE;
    canBitConfig->syncJumpWidth          = SJW-1;

   return 1;
}

/*
static BYTE CanCheckFilter(BYTE filter_number) {
  int i = 8000;
  while(CANIsFilterDisabled(CAN1, filter_number) && i-- > 0) { ; }
  if (i<=0) {
      // error("Failed to set channel filter");
      return 0;
  }
  return 1;
}
*/

static void CanDisplayConfig() {
    char output[80];
    sprintf(output, "CAN Config\r\n==========\r\n\n");
    MMPrintString(output);
    sprintf(output, "online = %u\r\n", canOnline);
    MMPrintString(output);
    sprintf(output, "buffer size = %lu\r\n", canBufferSize);
    MMPrintString(output);
    sprintf(output, "speed = %u\r\n", canSpeed);
    MMPrintString(output);
    sprintf(output, "channel flags = 0X%lx\r\n", canChannelFlags);
    MMPrintString(output);

    int i=0;
    int mask = 1;
    MMPrintString("Channels in use: ");
    for(i=0;i<32;i++) {
        if (canChannelFlags & mask) {
            sprintf(output, "%u ", i);
            MMPrintString(output);
        }
        mask = mask << 1;
    }
    MMPrintString("\r\r\nEnd of CAN Config\r\n\n");
}

/*
static void CanEnableFilters() {
    int i=0;
    int mask = 1;
    for(i=0;i<32;i++) {
        if (canChannelFlags & mask) {
            CANEnableFilter         (CAN1, i, TRUE);
        }
        mask = mask << 1;
    }

}
*/
/////////////////////////
// Is this ID a 29 bit id?
static BYTE isExtId(ULONG id) {
  return id & CAN_EXT_ID_BIT_MASK;
}

//////////
// put CAN1 into config mode and re-initialize config variables
static BYTE CanConfig() {

//    MMPrintString("CanConfig");
  CanFree();
//  MMPrintString("..CanFree");

  CANEnableModule(CAN1,TRUE);
  int i = 8000;
  while(C1CONbits.ON == 0 && i-- > 0);
  if (i<=0) {
      error("Failed to enable CAN module");
      return 0;
  }
//  MMPrintString("..CANEnableModule");

  CANSetOperatingMode(CAN1, CAN_CONFIGURATION);
//  MMPrintString("..CANSetOperatingMode");
  i = 8000;
  while(CANGetOperatingMode(CAN1) != CAN_CONFIGURATION && i-- > 0)  { ; }
  if (i<=0) {
      error("Failed to set CAN mode to CONFIGURATION");
      return 0;
  }

  CANConfigureFilterMask  (CAN1, CAN_FILTER_MASK0, 0x7FF, CAN_SID, CAN_FILTER_MASK_IDE_TYPE);
  CANConfigureFilterMask  (CAN1, CAN_FILTER_MASK1, 0,     CAN_EID, CAN_FILTER_MASK_ANY_TYPE);


//  MMPrintString("..CANConfigureFilterMask");
  CANEnableModuleEvent(CAN1, CAN_RX_EVENT, TRUE);
//  MMPrintString("..CANEnableModuleEvent");

  canOnline=0;
  return 1;
}

///////////
// put CAN1 into disabled mode
static BYTE CanDisable() {
  CANSetOperatingMode(CAN1, CAN_DISABLE);
  int i = 8000;
  while(CANGetOperatingMode(CAN1) != CAN_DISABLE && i-- > 0)  { ; }
  if (i<=0) return 0;
  canOnline=0;
  return 1;
}

///////////
// put CAN1 into disabled mode and free memory
static void CanFree() {

  CanDisable();
  if (pCanBuffer!=NULL) FreeHeap(pCanBuffer);
  pCanBuffer = NULL;
  canBufferSize = 0;
  canChannelFlags = 0;
  canSpeed = 0;
  CANEnableModule(CAN1,FALSE);
}

//////////
// initialize can buffer (if necessary) and put CAN1 into normal operating mode
static BYTE CanEnable() {
    char buf[20];
    sprintf(buf, "Enable %d %d %d", canOnline, (int)canBufferSize, canSpeed);
//    MMPrintString(buf);
  if (canOnline==1) return 0;
  if (canBufferSize==0) return 0;
  if (canSpeed==0) return 0;

  if (pCanBuffer == NULL) {
     pCanBuffer = getmemory(canBufferSize);
  //   MMPrintString(" .. getmemory");
    if (pCanBuffer == NULL) return 0;
    CANAssignMemoryBuffer(CAN1, pCanBuffer, canBufferSize);
    //MMPrintString(" .. CANAssignMemoryBuffer");
  }
  CANSetOperatingMode(CAN1, CAN_NORMAL_OPERATION);
    //MMPrintString(" .. CANSetOperatingMode");
  int i = 8000;
  while(CANGetOperatingMode(CAN1) != CAN_NORMAL_OPERATION && i-- > 0) { ; }
  if (i<=0) {
      error("Failed to set operating mode to NORMAL");
      return 0;
  }

//  CanEnableFilters();

  //MMPrintString(" .. done\r\n");
  canOnline=1;

  // CanDisplayConfig();

  return 1;

}

//////////
// set speed
static BYTE CanSetSpeed(ULONG speed) {
  CAN_BIT_CONFIG  canBitConfig;
  if (CanGetSpeedConfig(speed, &canBitConfig)==0) return 0;
  CANSetSpeed(CAN1,&canBitConfig,CLOCKFREQ, speed);
  canSpeed = speed;
  return 1;
}

//////////
// config a channel for Transmission
static BYTE CanAddTXChnl(BYTE channel_number, BYTE buffer_size) {
  // must be off line to configure channels
  if (canOnline==1) return 0;
  // can only configure channels once (config is cleared with CanConfig)
  if (canChannelFlags & (1 << channel_number)) return 0;

  CANConfigureChannelForTx(CAN1, channel_number, buffer_size, CAN_TX_RTR_DISABLED, CAN_LOW_MEDIUM_PRIORITY);

  // keep track of what's been configured
  canBufferSize += (buffer_size * CAN_FULL_RECORD_SIZE);
  canChannelFlags = canChannelFlags | (1 << channel_number);

  return 1;
}

///////////
// config a channel to receive all messages
static BYTE CanAddRXAllChnl(BYTE channel_number, BYTE buffer_size) {
  BYTE filterNumber = channel_number;
  CANConfigureChannelForRx(CAN1, channel_number, buffer_size, CAN_RX_FULL_RECEIVE);
  CANLinkFilterToChannel  (CAN1, filterNumber, CAN_FILTER_MASK1, channel_number);
  CANEnableFilter         (CAN1, filterNumber, TRUE);
  CANEnableChannelEvent   (CAN1, channel_number, CAN_RX_CHANNEL_NOT_EMPTY, TRUE);


  // keep track of what's been configured
  canBufferSize += (buffer_size * CAN_FULL_RECORD_SIZE);
  canChannelFlags = canChannelFlags | (1 << channel_number);

  return 1;
}

//////////
// config a channel to receive messages
static BYTE CanAddRXChnl(BYTE channel_number, ULONG id, BYTE typ, BYTE buffer_size) {
  // must be off line to configure channels
  if (canOnline==1) return 0;
  // can only configure channels once (config is cleared with CanOffline)
  if (canChannelFlags & (1 << channel_number)) return 0;

  // ID of 0 is special and means "receive all ids"
  if (id==0)
    return CanAddRXAllChnl(channel_number, buffer_size);

  BYTE filterNumber = channel_number;
  CANConfigureChannelForRx(CAN1, channel_number, buffer_size, CAN_RX_FULL_RECEIVE);
  CANEnableFilter         (CAN1, filterNumber, FALSE);
  CANConfigureFilter      (CAN1, filterNumber, id, (typ==0 ? CAN_SID : CAN_EID));
  CANLinkFilterToChannel  (CAN1, filterNumber, CAN_FILTER_MASK0, channel_number);
  CANEnableFilter         (CAN1, filterNumber, TRUE);
  CANEnableChannelEvent   (CAN1, channel_number, CAN_RX_CHANNEL_NOT_EMPTY, TRUE);

  // keep track of what's been configured
  canBufferSize += (buffer_size * CAN_FULL_RECORD_SIZE);
  canChannelFlags = canChannelFlags | (1 << channel_number);

  return 1;
}

////////////////////////
// Transmit data over previously configured channel
static BYTE CanTX(BYTE channel_number, ULONG id, BYTE len, BYTE* data) {
  if (canOnline==0) return 0;
  if (!(canChannelFlags & (1 << channel_number))) return 0;
  if (len > 8) return 0;
  CANTxMessageBuffer* pMsg = CANGetTxMessageBuffer(CAN1, channel_number);
  if (pMsg==NULL) return 0;

//  MMPrintString(".. got message buffer..\r\n");
//  uSec(1 * 1000 * 1000);

  memset(pMsg, 0, sizeof(pMsg));

//  MMPrintString(".. cleared message buffer\r\n");
//  uSec(1 * 1000 * 1000);

  if (isExtId(id)) {
    id &= ~CAN_EXT_ID_BIT_MASK;
    pMsg->msgSID.SID = (id >> 18) & 0x7ff;
    pMsg->msgEID.EID = id & 0x3ffff;
    pMsg->msgEID.IDE = 1;
  }
  else {
    pMsg->msgSID.SID = id & 0x7ff;
    pMsg->msgEID.IDE = 0;
  }
  pMsg->msgEID.DLC = len;

//  MMPrintString(".. initialized message buffer\r\n");
//  uSec(1 * 1000 * 1000);


  BYTE i;
  for (i=0; i<len; i++)
    pMsg->data[i] = data[i];

//  MMPrintString(".. initialized message buffer with data\r\n");
//  uSec(1 * 1000 * 1000);

  CANUpdateChannel(CAN1, channel_number);
//  MMPrintString(".. called CANUpdateChannel\r\n");
//  uSec(1 * 1000 * 1000);

  CANFlushTxChannel(CAN1, channel_number);
//  MMPrintString(".. called CANFlushTxChannel\r\n");
//  uSec(1 * 1000 * 1000);

  return 1;
}

////////////////////
// Receive full data (id, length and data) from previously configured channel
static BYTE CanFullRX(BYTE channel_number, ULONG* id, BYTE* len, BYTE* data) {
  if (canOnline==0) return 0;
  if (!(canChannelFlags & (1 << channel_number))) return 0;
  CANRxMessageBuffer* pMsg = (CANRxMessageBuffer *)CANGetRxMessage(CAN1, channel_number);
  if(pMsg == NULL) return 0;

  if (pMsg->msgEID.IDE == 0)
    *id = pMsg->msgSID.SID;
  else
    *id = pMsg->msgEID.EID | (pMsg->msgSID.SID << 18) | CAN_EXT_ID_BIT_MASK;
  *len = pMsg->msgEID.DLC;
  BYTE i;
  for (i=0; i<*len; i++)
    data[i] = pMsg->data[i];
  CANUpdateChannel(CAN1, channel_number);

  return 1;
}

////////////////////
// Receive data from previously configured channel
static BYTE CanRX(BYTE channel_number, BYTE* data) {

  if (canOnline==0) return 0;
  if (!(canChannelFlags & (1 << channel_number))) return 0;
  CANRxMessageBuffer* pMsg = (CANRxMessageBuffer *)CANGetRxMessage(CAN1, channel_number);
  if(pMsg == NULL) return 0;

  BYTE i;
  for (i=0; i<8; i++)
    data[i] = pMsg->data[i];

  CANUpdateChannel(CAN1, channel_number);

  return 1;
}

//BYTE CAN1MessageFifoArea[2 * 8 * 16];

static void CanTest() {

    MMPrintString("there's no test code currently available ...\r\n");


    /*
    MMPrintString("about to run test code...\r\n");

    CANEnableModule(CAN1, TRUE);
    CanSetSpeed(500000);

    CANConfigureChannelForTx(CAN1, CAN_CHANNEL0, 8, CAN_TX_RTR_DISABLED, CAN_LOW_MEDIUM_PRIORITY);
    CANConfigureChannelForRx(CAN1, CAN_CHANNEL1, 8, CAN_RX_FULL_RECEIVE);
    CANConfigureFilter      (CAN1, CAN_FILTER0, 0x52C, CAN_SID);
    CANConfigureFilterMask  (CAN1, CAN_FILTER_MASK0, 0x7FF, CAN_SID, CAN_FILTER_MASK_IDE_TYPE);
    CANLinkFilterToChannel  (CAN1, CAN_FILTER0, CAN_FILTER_MASK0, CAN_CHANNEL1);
    CANEnableFilter         (CAN1, CAN_FILTER0, TRUE);

    CANAssignMemoryBuffer(CAN1,CAN1MessageFifoArea,(2 * 8 * 16));

    CANSetOperatingMode(CAN1, CAN_NORMAL_OPERATION);
    while(CANGetOperatingMode(CAN1) != CAN_NORMAL_OPERATION);

    CANRxMessageBuffer* pMsg = NULL;
    char output[80];

     MMPrintString("config set - listen only for 0x52C on channel 1.... \r\n");
     MMPrintString( CanCheckFilter(CAN_FILTER0) ? "Filter 0 is set\r\n":"Filter 0 is NOT set\r\n");
     while(1) {
        pMsg = (CANRxMessageBuffer *)CANGetRxMessage(CAN1, CAN_CHANNEL1);
        if(pMsg == NULL) continue;

        double ect = pMsg->data[1] / 2.0;
        sprintf(output, "ECT = %g\r\n", ect);
        MMPrintString(output);

        CANUpdateChannel(CAN1, CAN_CHANNEL1);

     }
*/

}

///////////////////////////////
// COMMAND HANDLERS

float* getVar(char* argv[], BYTE n, char* szName) {
  float* ptr;
  if(vartype(argv[n]) != T_NBR) error("Numeric variable required");
  //ptr = (float *)findvar(argv[n], V_NOFIND_NULL);
  ptr = (float *)findvar(argv[n], V_FIND);
//  if (ptr == NULL)  {
//    char buff[50];
//    sprintf(buff, "Output variable %s not found", szName);
//    error(buff);
//  }
  return ptr;
}

void subcmd_canFree(char* subcmd) {
  checkend(subcmd);
  CanFree();
}

void subcmd_canPrintConfig(char* subcmd) {
  checkend(subcmd);
  CanDisplayConfig();
}

void subcmd_canTest(char* subcmd) {
  checkend(subcmd);
  CanTest();
}

void subcmd_canConfig(char* subcmd) {
//    MMPrintString("cmd_canConfig");
  getargs(&subcmd, 2, ",");
  if (argc != 1) {
    error("Incorrect syntax: CANCONFIG ok");
    return;
  }
  float* ok = getVar(argv, 0, "<ok>");
  if (ok == NULL) return;
  //  MMPrintString("..getVar");
  *ok = CanConfig();
}

void subcmd_canSetSpeed(char* subcmd) {
  int speed;
  getargs(&subcmd, 4, ",");
  if(argc != 3)  {
    error("Incorrect syntax: CANSETSPEED <speed>, <ok>");
    return;
  }
  speed = getinteger(argv[0]);
  if ( (speed < CAN_COMMUNICATION_SPEED_MIN) || (speed > CAN_COMMUNICATION_SPEED_MAX) )
  {
    error("Invalid CAN communication speed (must be 10kbps - 1Mbps)");
    return;
  }
  float* ok = getVar(argv, 2, "<ok>");
  if (ok == NULL) return;
  *ok = CanSetSpeed(speed);
}

void subcmd_canAddRXChnl(char* subcmd) {
  int channelNumber, canID, msgType, bufferSize;
  getargs(&subcmd, 10, ",");
  if (argc != 9) {
    error("Incorrect syntax: CANADDRXCHNL <channel number>, <can id>, <msg type>, <buffer size>, <ok>");
    return;
  }
  channelNumber = getinteger(argv[0]);
  if ( channelNumber < 0 ||channelNumber > 31) {
    error("Invalid CAN Channel - choose a channel between 0 and 31 (inclusive)");
    return;
  }
  canID = getinteger(argv[2]);
  msgType = getinteger(argv[4]);
  if ( msgType != 0 && msgType != 1) {
    error("Invalid Message Type - 0 for Std, 1 for Ext");
    return;
  }
  bufferSize = getinteger(argv[6]);
  if (bufferSize < 1 || bufferSize > 32) {
    error("Invalid buffer size - choose a size between 1 and 32)");
    return;
  }
  float* ok = getVar(argv, 8, "<ok>");
  if (ok == NULL) return;
  *ok = CanAddRXChnl(channelNumber,canID,msgType,bufferSize);
}

void subcmd_canAddTXChnl(char* subcmd) {
  int channelNumber, bufferSize;
  getargs(&subcmd, 6, ",");
  if (argc != 5) {
    error("Incorrect syntax: CANADDTXCHNL <channel number>, <buffer size>, <ok>");
    return;
  }
  channelNumber = getinteger(argv[0]);
  if ( channelNumber < 0 ||channelNumber > 31) {
    error("Invalid CAN Channel - choose a channel between 0 and 31 (inclusive)");
    return;
  }
  bufferSize = getinteger(argv[2]);
  if (bufferSize < 1 || bufferSize > 32) {
    error("Invalid buffer size - choose a size between 1 and 32)");
    return;
  }
  float* ok = getVar(argv, 4, "<ok>");
  if (ok == NULL) return;
  *ok = CanAddTXChnl(channelNumber,bufferSize);
}

void subcmd_canEnable(char* subcmd) {
  getargs(&subcmd, 2, ",");
  if (argc != 1) {
    error("Incorrect syntax: CANENABLE ok");
    return;
  }
  float* ok = getVar(argv, 0, "<ok>");
  if (ok == NULL) return;
  *ok = CanEnable();
}

void subcmd_canDisable(char* subcmd) {
  getargs(&subcmd, 2, ",");
  if (argc != 1) {
    error("Incorrect syntax: CANENABLE ok");
    return;
  }
  float* ok = getVar(argv, 0, "<ok>");
  if (ok == NULL) return;
  *ok = CanDisable();
}

void subcmd_canFullRX(int argc, char* argv[]) {

  int channelNumber = getinteger(argv[0]);
  if ( channelNumber < 0 ||channelNumber > 31) {
    error("Invalid CAN Channel - choose a channel between 0 and 31 (inclusive)");
    return;
  }

  float* id  = getVar(argv, 2,  "<id>");
  float* typ = getVar(argv, 4,  "<type>");
  float* len = getVar(argv, 6,  "<len>");
  float* ok  = getVar(argv, 10, "<ok>");

  if (id == NULL || typ == NULL || len == NULL || ok == NULL) return;

  BYTE  rxData[8];
  ULONG rxId;
  BYTE  rxLen;
  *ok = CanFullRX(channelNumber, &rxId, &rxLen, rxData);
  if (*ok==0) return;
  *len = rxLen;
  if (isExtId(rxId))
    *typ = 0;
  else {
    *typ = 1;
    *id = (rxId & ~CAN_EXT_ID_BIT_MASK);
  }

  float *data = getVar(argv, 8, "<data>");
  if (data == NULL) return;
  if (vartbl[VarIndex].type != T_NBR) {
    error("Array argument <data> is not numeric");
    return;
  }
  if (vartbl[VarIndex].dims[1] != 0) {
    error("Array argument <data> must be one dimensional");
    return;
  }
  if (vartbl[VarIndex].dims[0] == 0) {
    error("Array argument <data> is not an array");
    return;
  }
  if ((((float *) data - vartbl[VarIndex].val.fa) + *len) > (vartbl[VarIndex].dims[0] + 1 - OptionBase)) {
    error("Insufficient elements in array argument <data>");
    return;
  }

  BYTE i;
  for (i=0; i < *len; i++)
    data[i] = rxData[i];
}

void subcmd_canRX(char* subcmd) {
  getargs(&subcmd, 12, ",");
  if(argc != 11 && argc != 5) {
      error("Incorrect syntax: either CANRX<chnl>,<id>,<type>,<len>,<data()>,<ok>\r\nor CANRX <channel number>,<data(8)>,<ok>");
      return;
  }
  if (argc == 11) {
    subcmd_canFullRX(argc, argv);
    return;
  }
  int channelNumber;
  channelNumber = getinteger(argv[0]);
  if ( channelNumber < 0 ||channelNumber > 31) {
    error("Invalid CAN Channel - choose a channel between 0 and 31 (inclusive)");
    return;
  }
  BYTE rxData[8];
  float* ptr;
  if(vartype(argv[2]) != T_NBR) error("Numeric variable required");
  ptr = (float *)findvar(argv[2], V_NOFIND_NULL);
  if (ptr == NULL) {
      error("Array argument <data> not found");
      return;
  }
  if (vartbl[VarIndex].dims[1] != 0)  {
      error("Array argument <data> must be one dimensional");
      return;
  }
  if (vartbl[VarIndex].dims[0] == 0) {
      error("Array argument <data> is not an array");
      return;
  }
  if ((vartbl[VarIndex].dims[0] + 1 - OptionBase)!=9) {
      char buf[20];
      sprintf(buf,"data only has %d elements",(vartbl[VarIndex].dims[0] + 1 - OptionBase) );
      error(buf);
      return;
  }
  float* ok = getVar(argv, 4, "<ok>");
  if (ok == NULL) return;
  *ok = CanRX(channelNumber, rxData);
  if (*ok == 1) {
    BYTE i;
    for (i=0; i<8; i++)
      ptr[i] = rxData[i];
  }
}

void subcmd_canTX(char* subcmd) {
  getargs(&subcmd, 12, ",");
  if(argc!=11) {
    error("Incorrect syntax: CANTX <chnl>,<id>,<type>,<len>,<data()>,<ok>");
    return;
  }

  int channelNumber;
  channelNumber = getinteger(argv[0]);
  if ( channelNumber < 0 ||channelNumber > 31) {
    error("Invalid CAN Channel - choose a channel between 0 and 31 (inclusive)");
    return;
  }

  int len = getinteger(argv[6]);
  if ( (len > 8) || (len < 1) ) {
    error("Invalid CAN message length (must be 1..8)");
    return;
  }

  int type = getinteger(argv[4]);
  if (type != 0 && type !=2) {
    error("Invalid CAN message type (must be 0 for 11-bit STD or 1 for 29-bit EXT)");
    return;
  }

  ULONG id = getinteger(argv[2]);
  if (type == 0 && id > 0x7ff) {
    error("Invalid CAN message id (must be 0..7FFh)");
    return;
  }
  else if (type == 1) {
    if (id > 0x1fffff) {
      error("Invalid CAN message id (must be 0..1FFFFFh)");
      return;
    }
    id |= CAN_EXT_ID_BIT_MASK;
  }

  float* ptr;
  if(vartype(argv[8]) != T_NBR) error("Numeric variable required");
  ptr = (float *)findvar(argv[8], V_NOFIND_NULL);
  if (ptr == NULL) {
    error("Array argument with CAN message data not found");
    return;
  }
  if (vartbl[VarIndex].dims[1] != 0) {
      error("CAN message data array must be one dimensional");
      return;
  }
  if (vartbl[VarIndex].dims[0] == 0) {
      error("CAN message data argument is not an array");
      return;
  }
  if ((((float *) ptr - vartbl[VarIndex].val.fa) + len) > (vartbl[VarIndex].dims[0] + 1 - OptionBase))  {
      error("Insufficient elements in CAN message data array");
      return;
  }

  BYTE i;
  BYTE data[8];
  for (i=0; i<len; i++) {
    if (ptr[i] > 255){
      error("Invalid CAN data byte (must be 0..255)");
      return;
    }
    data[i] = ptr[i];
  }

  float* ok = getVar(argv, 10, "<ok>");
  if (ok == NULL) return;

//  MMPrintString("about to call CanTX\r\n");
  *ok = CanTX(channelNumber, id, len, data);
}

void cmd_can(void) {
  char* subcmd;
  // put the most time dependent commands first...
  if      ((subcmd = checkstring(cmdline, "RX")) != NULL)          subcmd_canRX(subcmd);
  else if ((subcmd = checkstring(cmdline, "TX")) != NULL)          subcmd_canTX(subcmd);
  else if ((subcmd = checkstring(cmdline, "CONFIG")) != NULL)      subcmd_canConfig(subcmd);
  else if ((subcmd = checkstring(cmdline, "SETSPEED")) != NULL)    subcmd_canSetSpeed(subcmd);
  else if ((subcmd = checkstring(cmdline, "ADDRXCHNL")) != NULL)   subcmd_canAddRXChnl(subcmd);
  else if ((subcmd = checkstring(cmdline, "ADDTXCHNL")) != NULL)   subcmd_canAddTXChnl(subcmd);
  else if ((subcmd = checkstring(cmdline, "ENABLE")) != NULL)      subcmd_canEnable(subcmd);
  else if ((subcmd = checkstring(cmdline, "DISABLE")) != NULL)     subcmd_canDisable(subcmd);
  else if ((subcmd = checkstring(cmdline, "FREE")) != NULL)        subcmd_canFree(subcmd);
  else if ((subcmd = checkstring(cmdline, "PRINTCONFIG")) != NULL) subcmd_canPrintConfig(subcmd);
  else if ((subcmd = checkstring(cmdline, "TEST")) != NULL)        subcmd_canTest(subcmd);
  else {
	MMPrintString("CAN Commands Version ");
    MMPrintString(CAN_VERSION);
    MMPrintString("\r\n\n");
    MMPrintString("Available CAN Commands\r\n\n");
    MMPrintString("CAN CONFIG - put the CAN Module into configuration mode\r\n");
    MMPrintString("CAN SETSPEED - set the baud rate\r\n");
    MMPrintString("CAN ADDRXCHNL - configure a channel for receive\r\n");
    MMPrintString("CAN ADDTXCHNL - configure a channel for transmit\r\n");
    MMPrintString("CAN ENABLE - enable the current configuration\r\n");
    MMPrintString("CAN DISABLE - disable the current configuration\r\n");
    MMPrintString("CAN FREE - free all memory assigned by the CAN commands\r\n");
    MMPrintString("CAN RX - read an incoming message (if available)\r\n");
    MMPrintString("CAN TX - transmit a message\r\n");
    MMPrintString("CAN PRINTCONFIG - print the current configuration details\r\n");
  }
}


#else
void cmd_can(void) {
    error("CAN not supported in this version");
}
#endif  // INCLUDE_CAN