//--------------------------------------------------------------
// File     : wm8994.c
// Datum    : 21.11.2015
// Version  : 1.0
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL
// Funktion : Sound DAC/ADC "WM8994" von Wulfson Microelectronics
//--------------------------------------------------------------


//--------------------------------------------------------------
#include "wm8994.h"

static I2C_HandleTypeDef hI2cAudioHandler = {0};



//--------------------------------------------------------------
#if !defined (VERIFY_WRITTENDATA)  
/* #define VERIFY_WRITTENDATA */
#endif /* VERIFY_WRITTENDATA */


//-------------------------------------------------------------- 
AUDIO_DrvTypeDef wm8994_drv = 
{
  wm8994_Init,
  wm8994_DeInit,
  wm8994_ReadID,

  wm8994_Play,
  wm8994_Pause,
  wm8994_Resume,
  wm8994_Stop,  

  wm8994_SetFrequency,
  wm8994_SetVolume,
  wm8994_SetMute,  
  wm8994_SetOutputMode,

  wm8994_Reset
};

//--------------------------------------------------------------

static uint32_t outputEnabled = 0;
static uint32_t inputEnabled = 0;
static uint8_t CODEC_IO_Write(uint8_t Addr, uint16_t Reg, uint16_t Value);

//--------------------------------------------------------------
uint32_t wm8994_Init(uint16_t DeviceAddr, uint16_t OutputInputDevice, uint8_t Volume, uint32_t AudioFreq)
{
  uint32_t counter = 0;
  uint16_t output_device = OutputInputDevice & 0xFF;
  uint16_t input_device = OutputInputDevice & 0xFF00;
  uint16_t power_mgnt_reg_1 = 0;
  
  /* Initialize the Control interface of the Audio Codec */
  AUDIO_IO_Init();
  /* wm8994 Errata Work-Arounds */
  counter += CODEC_IO_Write(DeviceAddr, 0x102, 0x0003);
  counter += CODEC_IO_Write(DeviceAddr, 0x817, 0x0000);
  counter += CODEC_IO_Write(DeviceAddr, 0x102, 0x0000);
  
  /* Enable VMID soft start (fast), Start-up Bias Current Enabled */
  counter += CODEC_IO_Write(DeviceAddr, 0x39, 0x006C);
  
  /* Enable bias generator, Enable VMID */
  counter += CODEC_IO_Write(DeviceAddr, 0x01, 0x0003);
  
  /* Add Delay */
  AUDIO_IO_Delay(50);

  /* Path Configurations for output */
  if (output_device > 0)
  {
    outputEnabled = 1;
    switch (output_device)
    {
    case OUTPUT_DEVICE_SPEAKER:
      /* Enable DAC1 (Left), Enable DAC1 (Right),
      Disable DAC2 (Left), Disable DAC2 (Right)*/
      counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0C0C);

      /* Enable the AIF1 Timeslot 0 (Left) to DAC 1 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x601, 0x0000);

      /* Enable the AIF1 Timeslot 0 (Right) to DAC 1 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x602, 0x0000);

      /* Disable the AIF1 Timeslot 1 (Left) to DAC 2 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x604, 0x0002);

      /* Disable the AIF1 Timeslot 1 (Right) to DAC 2 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x605, 0x0002);
      break;

    case OUTPUT_DEVICE_HEADPHONE:
      /* Disable DAC1 (Left), Disable DAC1 (Right),
      Enable DAC2 (Left), Enable DAC2 (Right)*/
      counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0303);

      /* Enable the AIF1 Timeslot 0 (Left) to DAC 1 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x601, 0x0001);

      /* Enable the AIF1 Timeslot 0 (Right) to DAC 1 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x602, 0x0001);

      /* Disable the AIF1 Timeslot 1 (Left) to DAC 2 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x604, 0x0000);

      /* Disable the AIF1 Timeslot 1 (Right) to DAC 2 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x605, 0x0000);
      break;

    case OUTPUT_DEVICE_BOTH:
      /* Enable DAC1 (Left), Enable DAC1 (Right),
      also Enable DAC2 (Left), Enable DAC2 (Right)*/
      counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0303 | 0x0C0C);

      /* Enable the AIF1 Timeslot 0 (Left) to DAC 1 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x601, 0x0001);

      /* Enable the AIF1 Timeslot 0 (Right) to DAC 1 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x602, 0x0001);

      /* Enable the AIF1 Timeslot 1 (Left) to DAC 2 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x604, 0x0002);

      /* Enable the AIF1 Timeslot 1 (Right) to DAC 2 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x605, 0x0002);
      break;

    case OUTPUT_DEVICE_AUTO :
    default:
      /* Disable DAC1 (Left), Disable DAC1 (Right),
      Enable DAC2 (Left), Enable DAC2 (Right)*/
      counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0303);

      /* Enable the AIF1 Timeslot 0 (Left) to DAC 1 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x601, 0x0001);

      /* Enable the AIF1 Timeslot 0 (Right) to DAC 1 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x602, 0x0001);

      /* Disable the AIF1 Timeslot 1 (Left) to DAC 2 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x604, 0x0000);

      /* Disable the AIF1 Timeslot 1 (Right) to DAC 2 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x605, 0x0000);
      break;
    }
  }
  else
  {
    outputEnabled = 0;
  }

  /* Path Configurations for input */
  if (input_device > 0)
  {
    inputEnabled = 1;
    switch (input_device)
    {
    case INPUT_DEVICE_DIGITAL_MICROPHONE_2 :
      /* Enable AIF1ADC2 (Left), Enable AIF1ADC2 (Right)
       * Enable DMICDAT2 (Left), Enable DMICDAT2 (Right)
       * Enable Left ADC, Enable Right ADC */
      counter += CODEC_IO_Write(DeviceAddr, 0x04, 0x0C30);

      /* Enable AIF1 DRC2 Signal Detect & DRC in AIF1ADC2 Left/Right Timeslot 1 */
      counter += CODEC_IO_Write(DeviceAddr, 0x450, 0x00DB);

      /* Disable IN1L, IN1R, IN2L, IN2R, Enable Thermal sensor & shutdown */
      counter += CODEC_IO_Write(DeviceAddr, 0x02, 0x6000);

      /* Enable the DMIC2(Left) to AIF1 Timeslot 1 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x608, 0x0002);

      /* Enable the DMIC2(Right) to AIF1 Timeslot 1 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x609, 0x0002);

      /* GPIO1 pin configuration GP1_DIR = output, GP1_FN = AIF1 DRC2 signal detect */
      counter += CODEC_IO_Write(DeviceAddr, 0x700, 0x000E);
      break;

    case INPUT_DEVICE_INPUT_LINE_1 :
      /* Enable AIF1ADC1 (Left), Enable AIF1ADC1 (Right)
       * Enable Left ADC, Enable Right ADC */
      counter += CODEC_IO_Write(DeviceAddr, 0x04, 0x0303);

      /* Enable AIF1 DRC1 Signal Detect & DRC in AIF1ADC1 Left/Right Timeslot 0 */
      counter += CODEC_IO_Write(DeviceAddr, 0x440, 0x00DB);

      /* Enable IN1L and IN1R, Disable IN2L and IN2R, Enable Thermal sensor & shutdown */
      counter += CODEC_IO_Write(DeviceAddr, 0x02, 0x6350);

      /* Enable the ADCL(Left) to AIF1 Timeslot 0 (Left) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x606, 0x0002);

      /* Enable the ADCR(Right) to AIF1 Timeslot 0 (Right) mixer path */
      counter += CODEC_IO_Write(DeviceAddr, 0x607, 0x0002);

      /* GPIO1 pin configuration GP1_DIR = output, GP1_FN = AIF1 DRC1 signal detect */
      counter += CODEC_IO_Write(DeviceAddr, 0x700, 0x000D);
      break;

    case INPUT_DEVICE_DIGITAL_MICROPHONE_1 :
    case INPUT_DEVICE_INPUT_LINE_2 :
    default:
      /* Actually, no other input devices supported */
      counter++;
      break;
    }
  }
  else
  {
    inputEnabled = 0;
  }
  
  /*  Clock Configurations */
  switch (AudioFreq)
  {
  case  AUDIO_FREQUENCY_8K:
    /* AIF1 Sample Rate = 8 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0003);
    break;
    
  case  AUDIO_FREQUENCY_16K:
    /* AIF1 Sample Rate = 16 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0033);
    break;
    
  case  AUDIO_FREQUENCY_48K:
    /* AIF1 Sample Rate = 48 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0083);
    break;
    
  case  AUDIO_FREQUENCY_96K:
    /* AIF1 Sample Rate = 96 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x00A3);
    break;
    
  case  AUDIO_FREQUENCY_11K:
    /* AIF1 Sample Rate = 11.025 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0013);
    break;
    
  case  AUDIO_FREQUENCY_22K:
    /* AIF1 Sample Rate = 22.050 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0043);
    break;
    
  case  AUDIO_FREQUENCY_44K:
    /* AIF1 Sample Rate = 44.1 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0073);
    break; 
    
  default:
    /* AIF1 Sample Rate = 48 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0083);
    break; 
  }
  /* AIF1 Word Length = 16-bits, AIF1 Format = I2S (Default Register Value) */
  counter += CODEC_IO_Write(DeviceAddr, 0x300, 0x4010);
  
  /* slave mode */
  counter += CODEC_IO_Write(DeviceAddr, 0x302, 0x0000);
  
  /* Enable the DSP processing clock for AIF1, Enable the core clock */
  counter += CODEC_IO_Write(DeviceAddr, 0x208, 0x000A);
  
  /* Enable AIF1 Clock, AIF1 Clock Source = MCLK1 pin */
  counter += CODEC_IO_Write(DeviceAddr, 0x200, 0x0001);

  if (output_device > 0)  /* Audio output selected */
  {
    /* Analog Output Configuration */

    /* Enable SPKRVOL PGA, Enable SPKMIXR, Enable SPKLVOL PGA, Enable SPKMIXL */
    counter += CODEC_IO_Write(DeviceAddr, 0x03, 0x0300);

    /* Left Speaker Mixer Volume = 0dB */
    counter += CODEC_IO_Write(DeviceAddr, 0x22, 0x0000);

    /* Speaker output mode = Class D, Right Speaker Mixer Volume = 0dB ((0x23, 0x0100) = class AB)*/
    counter += CODEC_IO_Write(DeviceAddr, 0x23, 0x0000);

    /* Unmute DAC2 (Left) to Left Speaker Mixer (SPKMIXL) path,
    Unmute DAC2 (Right) to Right Speaker Mixer (SPKMIXR) path */
    counter += CODEC_IO_Write(DeviceAddr, 0x36, 0x0300);

    /* Enable bias generator, Enable VMID, Enable SPKOUTL, Enable SPKOUTR */
    counter += CODEC_IO_Write(DeviceAddr, 0x01, 0x3003);

    /* Headphone/Speaker Enable */

    /* Enable Class W, Class W Envelope Tracking = AIF1 Timeslot 0 */
    counter += CODEC_IO_Write(DeviceAddr, 0x51, 0x0005);

    /* Enable bias generator, Enable VMID, Enable HPOUT1 (Left) and Enable HPOUT1 (Right) input stages */
    /* idem for Speaker */
    power_mgnt_reg_1 |= 0x0303 | 0x3003;
    counter += CODEC_IO_Write(DeviceAddr, 0x01, power_mgnt_reg_1);

    /* Enable HPOUT1 (Left) and HPOUT1 (Right) intermediate stages */
    counter += CODEC_IO_Write(DeviceAddr, 0x60, 0x0022);

    /* Enable Charge Pump */
    counter += CODEC_IO_Write(DeviceAddr, 0x4C, 0x9F25);

    /* Add Delay */
    AUDIO_IO_Delay(15);

    /* Select DAC1 (Left) to Left Headphone Output PGA (HPOUT1LVOL) path */
    counter += CODEC_IO_Write(DeviceAddr, 0x2D, 0x0001);

    /* Select DAC1 (Right) to Right Headphone Output PGA (HPOUT1RVOL) path */
    counter += CODEC_IO_Write(DeviceAddr, 0x2E, 0x0001);

    /* Enable Left Output Mixer (MIXOUTL), Enable Right Output Mixer (MIXOUTR) */
    /* idem for SPKOUTL and SPKOUTR */
    counter += CODEC_IO_Write(DeviceAddr, 0x03, 0x0030 | 0x0300);

    /* Enable DC Servo and trigger start-up mode on left and right channels */
    counter += CODEC_IO_Write(DeviceAddr, 0x54, 0x0033);

    /* Add Delay */
    AUDIO_IO_Delay(250);

    /* Enable HPOUT1 (Left) and HPOUT1 (Right) intermediate and output stages. Remove clamps */
    counter += CODEC_IO_Write(DeviceAddr, 0x60, 0x00EE);

    /* Unmutes */

    /* Unmute DAC 1 (Left) */
    counter += CODEC_IO_Write(DeviceAddr, 0x610, 0x00C0);

    /* Unmute DAC 1 (Right) */
    counter += CODEC_IO_Write(DeviceAddr, 0x611, 0x00C0);

    /* Unmute the AIF1 Timeslot 0 DAC path */
    counter += CODEC_IO_Write(DeviceAddr, 0x420, 0x0000);

    /* Unmute DAC 2 (Left) */
    counter += CODEC_IO_Write(DeviceAddr, 0x612, 0x00C0);

    /* Unmute DAC 2 (Right) */
    counter += CODEC_IO_Write(DeviceAddr, 0x613, 0x00C0);

    /* Unmute the AIF1 Timeslot 1 DAC2 path */
    counter += CODEC_IO_Write(DeviceAddr, 0x422, 0x0000);
    
    /* Volume Control */
    wm8994_SetVolume(DeviceAddr, Volume);
  }

  if (input_device > 0) /* Audio input selected */
  {
    if ((input_device == INPUT_DEVICE_DIGITAL_MICROPHONE_1) || (input_device == INPUT_DEVICE_DIGITAL_MICROPHONE_2))
    {
      /* Enable Microphone bias 1 generator, Enable VMID */
      power_mgnt_reg_1 |= 0x0013;
      counter += CODEC_IO_Write(DeviceAddr, 0x01, power_mgnt_reg_1);

      /* ADC oversample enable */
      counter += CODEC_IO_Write(DeviceAddr, 0x620, 0x0002);

      /* AIF ADC2 HPF enable, HPF cut = voice mode 1 fc=127Hz at fs=8kHz */
      counter += CODEC_IO_Write(DeviceAddr, 0x411, 0x3800);
    }
    else if ((input_device == INPUT_DEVICE_INPUT_LINE_1) || (input_device == INPUT_DEVICE_INPUT_LINE_2))
    {
      /* Enable normal bias generator, Enable VMID */
      power_mgnt_reg_1 |= 0x0003;
      counter += CODEC_IO_Write(DeviceAddr, 0x01, power_mgnt_reg_1);

      /* Disable mute on IN1L, IN1L Volume = +0dB */
      counter += CODEC_IO_Write(DeviceAddr, 0x18, 0x000B);

      /* Disable mute on IN1R, IN1R Volume = +0dB */
      counter += CODEC_IO_Write(DeviceAddr, 0x1A, 0x000B);

      /* Disable mute on IN1L_TO_MIXINL, Gain = +0dB */
      counter += CODEC_IO_Write(DeviceAddr, 0x29, 0x0025);

      /* Disable mute on IN1R_TO_MIXINL, Gain = +0dB */
      counter += CODEC_IO_Write(DeviceAddr, 0x2A, 0x0025);

      /* IN1LN_TO_IN1L, IN1LP_TO_VMID, IN1RN_TO_IN1R, IN1RP_TO_VMID */
      counter += CODEC_IO_Write(DeviceAddr, 0x28, 0x0011);

      /* AIF ADC1 HPF enable, HPF cut = hifi mode fc=4Hz at fs=48kHz */
      counter += CODEC_IO_Write(DeviceAddr, 0x410, 0x1800);
    }
    /* Volume Control */
    wm8994_SetVolume(DeviceAddr, Volume);
  }
  /* Return communication control value */
  return counter;  
}

//--------------------------------------------------------------
void wm8994_DeInit(void)
{
  /* Deinitialize Audio Codec interface */
  AUDIO_IO_DeInit();
}

//--------------------------------------------------------------
uint32_t wm8994_ReadID(uint16_t DeviceAddr)
{
  /* Initialize the Control interface of the Audio Codec */
  AUDIO_IO_Init();

  return ((uint32_t)AUDIO_IO_Read(DeviceAddr, WM8994_CHIPID_ADDR));
}

//--------------------------------------------------------------
uint32_t wm8994_Play(uint16_t DeviceAddr, uint16_t* pBuffer, uint16_t Size)
{
  uint32_t counter = 0;
 
  /* Resumes the audio file playing */  
  /* Unmute the output first */
  counter += wm8994_SetMute(DeviceAddr, AUDIO_MUTE_OFF);
  
  return counter;
}

//--------------------------------------------------------------
uint32_t wm8994_Pause(uint16_t DeviceAddr)
{  
  uint32_t counter = 0;
 
  /* Pause the audio file playing */
  /* Mute the output first */
  counter += wm8994_SetMute(DeviceAddr, AUDIO_MUTE_ON);
  
  /* Put the Codec in Power save mode */
  counter += CODEC_IO_Write(DeviceAddr, 0x02, 0x01);
 
  return counter;
}

//--------------------------------------------------------------
uint32_t wm8994_Resume(uint16_t DeviceAddr)
{
  uint32_t counter = 0;
 
  /* Resumes the audio file playing */  
  /* Unmute the output first */
  counter += wm8994_SetMute(DeviceAddr, AUDIO_MUTE_OFF);
  
  return counter;
}

//--------------------------------------------------------------
uint32_t wm8994_Stop(uint16_t DeviceAddr, uint32_t CodecPdwnMode)
{
  uint32_t counter = 0;

  if (outputEnabled != 0)
  {
    /* Mute the output first */
    counter += wm8994_SetMute(DeviceAddr, AUDIO_MUTE_ON);

    if (CodecPdwnMode == CODEC_PDWN_SW)
    {
       /* Only output mute required*/
    }
    else /* CODEC_PDWN_HW */
    {
      /* Mute the AIF1 Timeslot 0 DAC1 path */
      counter += CODEC_IO_Write(DeviceAddr, 0x420, 0x0200);

      /* Mute the AIF1 Timeslot 1 DAC2 path */
      counter += CODEC_IO_Write(DeviceAddr, 0x422, 0x0200);

      /* Disable DAC1L_TO_HPOUT1L */
      counter += CODEC_IO_Write(DeviceAddr, 0x2D, 0x0000);

      /* Disable DAC1R_TO_HPOUT1R */
      counter += CODEC_IO_Write(DeviceAddr, 0x2E, 0x0000);

      /* Disable DAC1 and DAC2 */
      counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0000);

      /* Reset Codec by writing in 0x0000 address register */
      counter += CODEC_IO_Write(DeviceAddr, 0x0000, 0x0000);

      outputEnabled = 0;
    }
  }
  return counter;
}

//--------------------------------------------------------------
uint32_t wm8994_SetVolume(uint16_t DeviceAddr, uint8_t Volume)
{
  uint32_t counter = 0;
  uint8_t convertedvol = VOLUME_CONVERT(Volume);

  /* Output volume */
  if (outputEnabled != 0)
  {
    if(convertedvol > 0x3E)
    {
      /* Unmute audio codec */
      counter += wm8994_SetMute(DeviceAddr, AUDIO_MUTE_OFF);

      /* Left Headphone Volume */
      counter += CODEC_IO_Write(DeviceAddr, 0x1C, 0x3F | 0x140);

      /* Right Headphone Volume */
      counter += CODEC_IO_Write(DeviceAddr, 0x1D, 0x3F | 0x140);

      /* Left Speaker Volume */
      counter += CODEC_IO_Write(DeviceAddr, 0x26, 0x3F | 0x140);

      /* Right Speaker Volume */
      counter += CODEC_IO_Write(DeviceAddr, 0x27, 0x3F | 0x140);
    }
    else if (Volume == 0)
    {
      /* Mute audio codec */
      counter += wm8994_SetMute(DeviceAddr, AUDIO_MUTE_ON);
    }
    else
    {
      /* Unmute audio codec */
      counter += wm8994_SetMute(DeviceAddr, AUDIO_MUTE_OFF);

      /* Left Headphone Volume */
      counter += CODEC_IO_Write(DeviceAddr, 0x1C, convertedvol | 0x140);

      /* Right Headphone Volume */
      counter += CODEC_IO_Write(DeviceAddr, 0x1D, convertedvol | 0x140);

      /* Left Speaker Volume */
      counter += CODEC_IO_Write(DeviceAddr, 0x26, convertedvol | 0x140);

      /* Right Speaker Volume */
      counter += CODEC_IO_Write(DeviceAddr, 0x27, convertedvol | 0x140);
    }
  }

  /* Input volume */
  if (inputEnabled != 0)
  {
    convertedvol = VOLUME_IN_CONVERT(Volume);

    /* Left AIF1 ADC1 volume */
    counter += CODEC_IO_Write(DeviceAddr, 0x400, convertedvol | 0x100);

    /* Right AIF1 ADC1 volume */
    counter += CODEC_IO_Write(DeviceAddr, 0x401, convertedvol | 0x100);

    /* Left AIF1 ADC2 volume */
    counter += CODEC_IO_Write(DeviceAddr, 0x404, convertedvol | 0x100);

    /* Right AIF1 ADC2 volume */
    counter += CODEC_IO_Write(DeviceAddr, 0x405, convertedvol | 0x100);
  }
  return counter;
}

//--------------------------------------------------------------
uint32_t wm8994_SetMute(uint16_t DeviceAddr, uint32_t Cmd)
{
  uint32_t counter = 0;
  
  if (outputEnabled != 0)
  {
    /* Set the Mute mode */
    if(Cmd == AUDIO_MUTE_ON)
    {
      /* Soft Mute the AIF1 Timeslot 0 DAC1 path L&R */
      counter += CODEC_IO_Write(DeviceAddr, 0x420, 0x0200);

      /* Soft Mute the AIF1 Timeslot 1 DAC2 path L&R */
      counter += CODEC_IO_Write(DeviceAddr, 0x422, 0x0200);
    }
    else /* AUDIO_MUTE_OFF Disable the Mute */
    {
      /* Unmute the AIF1 Timeslot 0 DAC1 path L&R */
      counter += CODEC_IO_Write(DeviceAddr, 0x420, 0x0000);

      /* Unmute the AIF1 Timeslot 1 DAC2 path L&R */
      counter += CODEC_IO_Write(DeviceAddr, 0x422, 0x0000);
    }
  }
  return counter;
}

//--------------------------------------------------------------
uint32_t wm8994_SetOutputMode(uint16_t DeviceAddr, uint8_t Output)
{
  uint32_t counter = 0; 
  
  switch (Output) 
  {
  case OUTPUT_DEVICE_SPEAKER:
    /* Enable DAC1 (Left), Enable DAC1 (Right), 
    Disable DAC2 (Left), Disable DAC2 (Right)*/
    counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0C0C);
    
    /* Enable the AIF1 Timeslot 0 (Left) to DAC 1 (Left) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x601, 0x0000);
    
    /* Enable the AIF1 Timeslot 0 (Right) to DAC 1 (Right) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x602, 0x0000);
    
    /* Disable the AIF1 Timeslot 1 (Left) to DAC 2 (Left) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x604, 0x0002);
    
    /* Disable the AIF1 Timeslot 1 (Right) to DAC 2 (Right) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x605, 0x0002);
    break;
    
  case OUTPUT_DEVICE_HEADPHONE:
    /* Disable DAC1 (Left), Disable DAC1 (Right), 
    Enable DAC2 (Left), Enable DAC2 (Right)*/
    counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0303);
    
    /* Enable the AIF1 Timeslot 0 (Left) to DAC 1 (Left) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x601, 0x0001);
    
    /* Enable the AIF1 Timeslot 0 (Right) to DAC 1 (Right) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x602, 0x0001);
    
    /* Disable the AIF1 Timeslot 1 (Left) to DAC 2 (Left) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x604, 0x0000);
    
    /* Disable the AIF1 Timeslot 1 (Right) to DAC 2 (Right) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x605, 0x0000);
    break;
    
  case OUTPUT_DEVICE_BOTH:
    /* Enable DAC1 (Left), Enable DAC1 (Right), 
    also Enable DAC2 (Left), Enable DAC2 (Right)*/
    counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0303 | 0x0C0C);
    
    /* Enable the AIF1 Timeslot 0 (Left) to DAC 1 (Left) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x601, 0x0001);
    
    /* Enable the AIF1 Timeslot 0 (Right) to DAC 1 (Right) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x602, 0x0001);
    
    /* Enable the AIF1 Timeslot 1 (Left) to DAC 2 (Left) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x604, 0x0002);
    
    /* Enable the AIF1 Timeslot 1 (Right) to DAC 2 (Right) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x605, 0x0002);
    break;
    
  default:
    /* Disable DAC1 (Left), Disable DAC1 (Right), 
    Enable DAC2 (Left), Enable DAC2 (Right)*/
    counter += CODEC_IO_Write(DeviceAddr, 0x05, 0x0303);
    
    /* Enable the AIF1 Timeslot 0 (Left) to DAC 1 (Left) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x601, 0x0001);
    
    /* Enable the AIF1 Timeslot 0 (Right) to DAC 1 (Right) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x602, 0x0001);
    
    /* Disable the AIF1 Timeslot 1 (Left) to DAC 2 (Left) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x604, 0x0000);
    
    /* Disable the AIF1 Timeslot 1 (Right) to DAC 2 (Right) mixer path */
    counter += CODEC_IO_Write(DeviceAddr, 0x605, 0x0000);
    break;    
  }  
  return counter;
}

//--------------------------------------------------------------
uint32_t wm8994_SetFrequency(uint16_t DeviceAddr, uint32_t AudioFreq)
{
  uint32_t counter = 0;
 
  /*  Clock Configurations */
  switch (AudioFreq)
  {
  case  AUDIO_FREQUENCY_8K:
    /* AIF1 Sample Rate = 8 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0003);
    break;
    
  case  AUDIO_FREQUENCY_16K:
    /* AIF1 Sample Rate = 16 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0033);
    break;
    
  case  AUDIO_FREQUENCY_48K:
    /* AIF1 Sample Rate = 48 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0083);
    break;
    
  case  AUDIO_FREQUENCY_96K:
    /* AIF1 Sample Rate = 96 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x00A3);
    break;
    
  case  AUDIO_FREQUENCY_11K:
    /* AIF1 Sample Rate = 11.025 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0013);
    break;
    
  case  AUDIO_FREQUENCY_22K:
    /* AIF1 Sample Rate = 22.050 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0043);
    break;
    
  case  AUDIO_FREQUENCY_44K:
    /* AIF1 Sample Rate = 44.1 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0073);
    break; 
    
  default:
    /* AIF1 Sample Rate = 48 (KHz), ratio=256 */ 
    counter += CODEC_IO_Write(DeviceAddr, 0x210, 0x0083);
    break; 
  }
  return counter;
}

//--------------------------------------------------------------
uint32_t wm8994_Reset(uint16_t DeviceAddr)
{
  uint32_t counter = 0;
  
  /* Reset Codec by writing in 0x0000 address register */
  counter = CODEC_IO_Write(DeviceAddr, 0x0000, 0x0000);
  outputEnabled = 0;
  inputEnabled=0;

  return counter;
}

//--------------------------------------------------------------
static uint8_t CODEC_IO_Write(uint8_t Addr, uint16_t Reg, uint16_t Value)
{
  uint32_t result = 0;
  
 AUDIO_IO_Write(Addr, Reg, Value);
  
#ifdef VERIFY_WRITTENDATA
  /* Verify that the data has been correctly written */
  result = (AUDIO_IO_Read(Addr, Reg) == Value)? 0:1;
#endif /* VERIFY_WRITTENDATA */
  
  return result;
}

//--------------------------------------------------------------
void I2Cx_Init(I2C_HandleTypeDef *i2c_handler)
{
  if(HAL_I2C_GetState(i2c_handler) == HAL_I2C_STATE_RESET)
  {
    if (i2c_handler == (I2C_HandleTypeDef*)(&hI2cAudioHandler))
    {
      /* Audio and LCD I2C configuration */
      i2c_handler->Instance = DISCOVERY_AUDIO_I2Cx;
    }
    else
    {
      /* External, camera and Arduino connector  I2C configuration */
      i2c_handler->Instance = DISCOVERY_EXT_I2Cx;
    }
    i2c_handler->Init.Timing           = DISCOVERY_I2Cx_TIMING;
    i2c_handler->Init.OwnAddress1      = 0;
    i2c_handler->Init.AddressingMode   = I2C_ADDRESSINGMODE_7BIT;
    i2c_handler->Init.DualAddressMode  = I2C_DUALADDRESS_DISABLE;
    i2c_handler->Init.OwnAddress2      = 0;
    i2c_handler->Init.GeneralCallMode  = I2C_GENERALCALL_DISABLE;
    i2c_handler->Init.NoStretchMode    = I2C_NOSTRETCH_DISABLE;

    /* Init the I2C */
    I2Cx_MspInit(i2c_handler);
    HAL_I2C_Init(i2c_handler);
  }
}


//--------------------------------------------------------------
void I2Cx_MspInit(I2C_HandleTypeDef *i2c_handler)
{
  GPIO_InitTypeDef  gpio_init_structure;

  if (i2c_handler == (I2C_HandleTypeDef*)(&hI2cAudioHandler))
  {
    /* AUDIO and LCD I2C MSP init */

    /*** Configure the GPIOs ***/
    /* Enable GPIO clock */
    DISCOVERY_AUDIO_I2Cx_SCL_SDA_GPIO_CLK_ENABLE();

    /* Configure I2C Tx as alternate function */
    gpio_init_structure.Pin = DISCOVERY_AUDIO_I2Cx_SCL_PIN;
    gpio_init_structure.Mode = GPIO_MODE_AF_OD;
    gpio_init_structure.Pull = GPIO_NOPULL;
    gpio_init_structure.Speed = GPIO_SPEED_FAST;
    gpio_init_structure.Alternate = DISCOVERY_AUDIO_I2Cx_SCL_SDA_AF;
    HAL_GPIO_Init(DISCOVERY_AUDIO_I2Cx_SCL_SDA_GPIO_PORT, &gpio_init_structure);

    /* Configure I2C Rx as alternate function */
    gpio_init_structure.Pin = DISCOVERY_AUDIO_I2Cx_SDA_PIN;
    HAL_GPIO_Init(DISCOVERY_AUDIO_I2Cx_SCL_SDA_GPIO_PORT, &gpio_init_structure);

    /*** Configure the I2C peripheral ***/
    /* Enable I2C clock */
    DISCOVERY_AUDIO_I2Cx_CLK_ENABLE();

    /* Force the I2C peripheral clock reset */
    DISCOVERY_AUDIO_I2Cx_FORCE_RESET();

    /* Release the I2C peripheral clock reset */
    DISCOVERY_AUDIO_I2Cx_RELEASE_RESET();

    /* Enable and set I2Cx Interrupt to a lower priority */
    HAL_NVIC_SetPriority(DISCOVERY_AUDIO_I2Cx_EV_IRQn, 0x05, 0);
    HAL_NVIC_EnableIRQ(DISCOVERY_AUDIO_I2Cx_EV_IRQn);

    /* Enable and set I2Cx Interrupt to a lower priority */
    HAL_NVIC_SetPriority(DISCOVERY_AUDIO_I2Cx_ER_IRQn, 0x05, 0);
    HAL_NVIC_EnableIRQ(DISCOVERY_AUDIO_I2Cx_ER_IRQn);
  }
  else
  {
    /* External, camera and Arduino connector I2C MSP init */

    /*** Configure the GPIOs ***/
    /* Enable GPIO clock */
    DISCOVERY_EXT_I2Cx_SCL_SDA_GPIO_CLK_ENABLE();

    /* Configure I2C Tx as alternate function */
    gpio_init_structure.Pin = DISCOVERY_EXT_I2Cx_SCL_PIN;
    gpio_init_structure.Mode = GPIO_MODE_AF_OD;
    gpio_init_structure.Pull = GPIO_NOPULL;
    gpio_init_structure.Speed = GPIO_SPEED_FAST;
    gpio_init_structure.Alternate = DISCOVERY_EXT_I2Cx_SCL_SDA_AF;
    HAL_GPIO_Init(DISCOVERY_EXT_I2Cx_SCL_SDA_GPIO_PORT, &gpio_init_structure);

    /* Configure I2C Rx as alternate function */
    gpio_init_structure.Pin = DISCOVERY_EXT_I2Cx_SDA_PIN;
    HAL_GPIO_Init(DISCOVERY_EXT_I2Cx_SCL_SDA_GPIO_PORT, &gpio_init_structure);

    /*** Configure the I2C peripheral ***/
    /* Enable I2C clock */
    DISCOVERY_EXT_I2Cx_CLK_ENABLE();

    /* Force the I2C peripheral clock reset */
    DISCOVERY_EXT_I2Cx_FORCE_RESET();

    /* Release the I2C peripheral clock reset */
    DISCOVERY_EXT_I2Cx_RELEASE_RESET();

    /* Enable and set I2Cx Interrupt to a lower priority */
    HAL_NVIC_SetPriority(DISCOVERY_EXT_I2Cx_EV_IRQn, 0x05, 0);
    HAL_NVIC_EnableIRQ(DISCOVERY_EXT_I2Cx_EV_IRQn);

    /* Enable and set I2Cx Interrupt to a lower priority */
    HAL_NVIC_SetPriority(DISCOVERY_EXT_I2Cx_ER_IRQn, 0x05, 0);
    HAL_NVIC_EnableIRQ(DISCOVERY_EXT_I2Cx_ER_IRQn);
  }
}

//--------------------------------------------------------------
static void I2Cx_Error(I2C_HandleTypeDef *i2c_handler, uint8_t Addr)
{
  /* De-initialize the I2C communication bus */
  HAL_I2C_DeInit(i2c_handler);

  /* Re-Initialize the I2C communication bus */
  I2Cx_Init(i2c_handler);
}

//--------------------------------------------------------------
static HAL_StatusTypeDef I2Cx_WriteMultiple(I2C_HandleTypeDef *i2c_handler,
                                            uint8_t Addr,
                                            uint16_t Reg,
                                            uint16_t MemAddress,
                                            uint8_t *Buffer,
                                            uint16_t Length)
{
  HAL_StatusTypeDef status = HAL_OK;

  status = HAL_I2C_Mem_Write(i2c_handler, Addr, (uint16_t)Reg, MemAddress, Buffer, Length, 1000);

  /* Check the communication status */
  if(status != HAL_OK)
  {
    /* Re-Initiaize the I2C Bus */
    I2Cx_Error(i2c_handler, Addr);
  }
  return status;
}


//--------------------------------------------------------------
static HAL_StatusTypeDef I2Cx_ReadMultiple(I2C_HandleTypeDef *i2c_handler,
                                           uint8_t Addr,
                                           uint16_t Reg,
                                           uint16_t MemAddress,
                                           uint8_t *Buffer,
                                           uint16_t Length)
{
  HAL_StatusTypeDef status = HAL_OK;

  status = HAL_I2C_Mem_Read(i2c_handler, Addr, (uint16_t)Reg, MemAddress, Buffer, Length, 1000);

  /* Check the communication status */
  if(status != HAL_OK)
  {
    /* I2C error occurred */
    I2Cx_Error(i2c_handler, Addr);
  }
  return status;
}

//--------------------------------------------------------------
void AUDIO_IO_Delay(uint32_t Delay)
{
  HAL_Delay(Delay);
}

//--------------------------------------------------------------
void AUDIO_IO_Init(void)
{
  I2Cx_Init(&hI2cAudioHandler);
}
//--------------------------------------------------------------
void AUDIO_IO_DeInit(void)
{
}
//--------------------------------------------------------------
uint16_t AUDIO_IO_Read(uint8_t Addr, uint16_t Reg)
{
  uint16_t read_value = 0, tmp = 0;

  I2Cx_ReadMultiple(&hI2cAudioHandler, Addr, Reg, I2C_MEMADD_SIZE_16BIT, (uint8_t*)&read_value, 2);

  tmp = ((uint16_t)(read_value >> 8) & 0x00FF);

  tmp |= ((uint16_t)(read_value << 8)& 0xFF00);

  read_value = tmp;

  return read_value;
}
//--------------------------------------------------------------
void AUDIO_IO_Write(uint8_t Addr, uint16_t Reg, uint16_t Value)
{
  uint16_t tmp = Value;

  Value = ((uint16_t)(tmp >> 8) & 0x00FF);

  Value |= ((uint16_t)(tmp << 8)& 0xFF00);

  I2Cx_WriteMultiple(&hI2cAudioHandler, Addr, Reg, I2C_MEMADD_SIZE_16BIT,(uint8_t*)&Value, 2);
}



