################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../usb/usbh_conf.c \
../usb/usbh_core.c \
../usb/usbh_ctlreq.c \
../usb/usbh_hid.c \
../usb/usbh_hid_keybd.c \
../usb/usbh_hid_mouse.c \
../usb/usbh_hid_parser.c \
../usb/usbh_ioreq.c \
../usb/usbh_msc.c \
../usb/usbh_msc_bot.c \
../usb/usbh_msc_scsi.c \
../usb/usbh_pipes.c 

OBJS += \
./usb/usbh_conf.o \
./usb/usbh_core.o \
./usb/usbh_ctlreq.o \
./usb/usbh_hid.o \
./usb/usbh_hid_keybd.o \
./usb/usbh_hid_mouse.o \
./usb/usbh_hid_parser.o \
./usb/usbh_ioreq.o \
./usb/usbh_msc.o \
./usb/usbh_msc_bot.o \
./usb/usbh_msc_scsi.o \
./usb/usbh_pipes.o 

C_DEPS += \
./usb/usbh_conf.d \
./usb/usbh_core.d \
./usb/usbh_ctlreq.d \
./usb/usbh_hid.d \
./usb/usbh_hid_keybd.d \
./usb/usbh_hid_mouse.d \
./usb/usbh_hid_parser.d \
./usb/usbh_ioreq.d \
./usb/usbh_msc.d \
./usb/usbh_msc_bot.d \
./usb/usbh_msc_scsi.d \
./usb/usbh_pipes.d 


# Each subdirectory must supply rules for building sources it contributes
usb/%.o: ../usb/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo %cd%
	arm-none-eabi-gcc -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16 -DSTM32F746G_DISCO -DSTM32F746NGHx -DSTM32F7 -DSTM32 -DUSE_HAL_DRIVER -DSTM32F746xx -DUSE_USB_FS -DUSE_USB_HS -DUSER_UB -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/inc" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/CMSIS/core" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/CMSIS/device" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/HAL_Driver/Inc/Legacy" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/HAL_Driver/Inc" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/fatfs" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/mmbasic" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/mmsource" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/usb" -O3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


