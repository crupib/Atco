/***********************************************************************************************************************
MMBasic

mod32.h

Generates music for the PlayMOD command.

Copyright 2012 Pascal Piazzalunga.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following 
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

************************************************************************************************************************/

#define SYSCLK 80000000L

#define BITDEPTH 11                               // 11 bits PWM
#define SAMPLERATE (SYSCLK / (1 << BITDEPTH))     // Best audio quality 80MHz / (1 << 11) = 39062.5Hz
//#define SAMPLERATE (SYSCLK / (1 << BITDEPTH) / 2) // Medium audio quality 80MHz / (1 << 11) / 2 = 19531.25Hz

#define SOUNDBUFFERSIZE 512                       // Stereo circular sound buffer 2 * 512 = 1024 bytes of memory
#define FSBUFFERSIZE 1024                         // File system buffers CHANNELS * 1024 = 4096 bytes of memory
#define DIVIDER 10                                // Fixed-point mantissa used for integer arithmetic

#if defined(COLOUR)
    #define STEREOSEPARATION 32                   // 0 (max) to 64 (mono)
#else
    #define STEREOSEPARATION 64                   // 0 (max) to 64 (mono)
#endif

// Hz = 7093789 / (amigaPeriod * 2) for PAL
// Hz = 7159091 / (amigaPeriod * 2) for NTSC
#define AMIGA (7093789 / 2 / SAMPLERATE << DIVIDER)
// Mixer.channelFrequency[channel] = AMIGA / amigaPeriod

#define ROWS 64
#define SAMPLES 31
#define CHANNELS 4
#define NONOTE 0xFFFF

typedef struct {
 uint8_t name[22];
 uint16_t length;
 int8_t fineTune;
 uint8_t volume;
 uint16_t loopBegin;
 uint16_t loopLength;
} Sample;

struct s_Mod {
 uint8_t name[20];
 Sample samples[SAMPLES];
 uint8_t songLength;
 uint8_t numberOfPatterns;
 uint8_t order[128];
 uint8_t numberOfChannels;
} ;

typedef struct {
 uint8_t sampleNumber[ROWS][CHANNELS];
 uint16_t note[ROWS][CHANNELS];
 uint8_t effectNumber[ROWS][CHANNELS];
 uint8_t effectParameter[ROWS][CHANNELS];
} Pattern;

struct s_Player {
 Pattern currentPattern;

 bool run;

 uint32_t amiga;
 uint16_t samplesPerTick;
 uint8_t speed;
 uint8_t tick;
 uint8_t row;
 uint8_t lastRow;

 uint8_t orderIndex;
 uint8_t oldOrderIndex;
 uint8_t patternDelay;
 uint8_t patternLoopCount[CHANNELS];
 uint8_t patternLoopRow[CHANNELS];

 uint8_t lastSampleNumber[CHANNELS];
 int8_t volume[CHANNELS];
 uint16_t lastNote[CHANNELS];
 uint16_t amigaPeriod[CHANNELS];
 int16_t lastAmigaPeriod[CHANNELS];

 uint16_t portamentoNote[CHANNELS];
 uint8_t portamentoSpeed[CHANNELS];

 uint8_t waveControl[CHANNELS];

 uint8_t vibratoSpeed[CHANNELS];
 uint8_t vibratoDepth[CHANNELS];
 int8_t vibratoPos[CHANNELS];

 uint8_t tremoloSpeed[CHANNELS];
 uint8_t tremoloDepth[CHANNELS];
 int8_t tremoloPos[CHANNELS];
} ;

    struct s_Mixer {
 uint32_t sampleBegin[SAMPLES];
 uint32_t sampleEnd[SAMPLES];
 uint32_t sampleloopBegin[SAMPLES];
 uint16_t sampleLoopLength[SAMPLES];
 uint32_t sampleLoopEnd[SAMPLES];

 uint8_t channelSampleNumber[CHANNELS];
 uint32_t channelSampleOffset[CHANNELS];
 uint16_t channelFrequency[CHANNELS];
 uint8_t channelVolume[CHANNELS];
 uint8_t channelPanning[CHANNELS];
} ;


struct s_FsBuffer {
 uint8_t channels[CHANNELS][FSBUFFERSIZE];
 uint32_t samplePointer[CHANNELS];
 uint8_t channelSampleNumber[CHANNELS];
};

struct s_SoundBuffer {
 uint16_t left[SOUNDBUFFERSIZE];
 uint16_t right[SOUNDBUFFERSIZE];
 uint16_t writePos;
 volatile uint16_t readPos;
} ;

// Effects
#define ARPEGGIO              0x0
#define PORTAMENTOUP          0x1
#define PORTAMENTODOWN        0x2
#define TONEPORTAMENTO        0x3
#define VIBRATO               0x4
#define PORTAMENTOVOLUMESLIDE 0x5
#define VIBRATOVOLUMESLIDE    0x6
#define TREMOLO               0x7
#define SETCHANNELPANNING     0x8
#define SETSAMPLEOFFSET       0x9
#define VOLUMESLIDE           0xA
#define JUMPTOORDER           0xB
#define SETVOLUME             0xC
#define BREAKPATTERNTOROW     0xD
#define SETSPEED              0xF

// 0xE subset
#define SETFILTER             0x0
#define FINEPORTAMENTOUP      0x1
#define FINEPORTAMENTODOWN    0x2
#define GLISSANDOCONTROL      0x3
#define SETVIBRATOWAVEFORM    0x4
#define SETFINETUNE           0x5
#define PATTERNLOOP           0x6
#define SETTREMOLOWAVEFORM    0x7
#define RETRIGGERNOTE         0x9
#define FINEVOLUMESLIDEUP     0xA
#define FINEVOLUMESLIDEDOWN   0xB
#define NOTECUT               0xC
#define NOTEDELAY             0xD
#define PATTERNDELAY          0xE
#define INVERTLOOP            0xF

// Function prototypes
void loadMod();
void player();
void mixer();

extern struct s_FsBuffer *FsBuffer;
extern struct s_SoundBuffer *SoundBuffer;
extern struct s_Mod *Mod;
extern struct s_Mixer *Mixer;
extern struct s_Player *Player;

