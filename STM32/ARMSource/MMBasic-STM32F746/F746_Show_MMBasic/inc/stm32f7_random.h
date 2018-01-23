//--------------------------------------------------------------
// File     : stm32f7_random.h
//--------------------------------------------------------------

//--------------------------------------------------------------
#ifndef __STM32F7_RANDOM_H
#define __STM32F7_RANDOM_H

#include "stm32_ub_system.h"

void Random_Init(void);
void Random_DeInit(void);
uint32_t Random_Get(void);

#endif // __STM32F7_RANDOM_H
