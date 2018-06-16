################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../mmsource/Audio_F7.c \
../mmsource/DrawChar.c \
../mmsource/Editor.c \
../mmsource/External.c \
../mmsource/Files.c \
../mmsource/Graphics.c \
../mmsource/I2C_F7.c \
../mmsource/MM_Misc.c \
../mmsource/Memory.c \
../mmsource/Touch_F7.c \
../mmsource/Video.c \
../mmsource/serial.c 

OBJS += \
./mmsource/Audio_F7.o \
./mmsource/DrawChar.o \
./mmsource/Editor.o \
./mmsource/External.o \
./mmsource/Files.o \
./mmsource/Graphics.o \
./mmsource/I2C_F7.o \
./mmsource/MM_Misc.o \
./mmsource/Memory.o \
./mmsource/Touch_F7.o \
./mmsource/Video.o \
./mmsource/serial.o 

C_DEPS += \
./mmsource/Audio_F7.d \
./mmsource/DrawChar.d \
./mmsource/Editor.d \
./mmsource/External.d \
./mmsource/Files.d \
./mmsource/Graphics.d \
./mmsource/I2C_F7.d \
./mmsource/MM_Misc.d \
./mmsource/Memory.d \
./mmsource/Touch_F7.d \
./mmsource/Video.d \
./mmsource/serial.d 


# Each subdirectory must supply rules for building sources it contributes
mmsource/%.o: ../mmsource/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo %cd%
	arm-none-eabi-gcc -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16 -DSTM32F746G_DISCO -DSTM32F746NGHx -DSTM32F7 -DSTM32 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F746xx -DUSE_USB_FS -DUSE_USB_HS -DUSER_UB -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/inc" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/CMSIS/core" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/CMSIS/device" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/HAL_Driver/Inc/Legacy" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/HAL_Driver/Inc" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/fatfs" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/mmbasic" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/mmsource" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/usb" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


