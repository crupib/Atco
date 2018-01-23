//--------------------------------------------------------------
// File     : stm32f7_random.c
// Datum    : 15.08.2015
// Version  : 1.0
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL, FATFS
// Funktion : Integrated stm32f7 Random number generator

#include "stm32f7_random.h"

void Random_Init(void)
{
	// Init Random number generator
	__HAL_RCC_RNG_CLK_ENABLE();
	RNG->CR |= RNG_CR_RNGEN;
}

void Random_DeInit(void)
{
	// Deinit Random number generator
	RNG->CR &= ~RNG_CR_RNGEN;
	__HAL_RCC_RNG_CLK_DISABLE();
}

uint32_t Random_Get(void)
{
	// Return the random number (32 bit)
	return RNG->DR;
}
