<<<<<<< HEAD
'AtcoNDT Library - written by Bill Crupi
'comportlist - returns FTDI comm ports

DECLARE FUNCTION comportlist LIB "atcondt_lib.dll" _
=======
#INCLUDE "Win32Api.Inc"
'USB4
%USB4_SUCCESS    =            0
DECLARE FUNCTION USB4_Initialize LIB "usb4.dll" ALIAS "USB4_Initialize" (BYREF pDeviceCount AS DWORD) AS INTEGER
DECLARE FUNCTION USB4_DeviceCount LIB "usb4.dll" ALIAS "USB4_DeviceCount" () AS INTEGER
DECLARE FUNCTION USB4_GetCount LIB "usb4.dll" ALIAS "USB4_GetCount" (BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYREF pulVal AS LONG) AS INTEGER
DECLARE FUNCTION USB4_SetCount LIB "usb4.dll" ALIAS "USB4_SetCount" (BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYVAL ulVal AS LONG) AS INTEGER
DECLARE FUNCTION USB4_SetMultiplier LIB "usb4.dll" ALIAS "USB4_SetMultiplier" (BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYVAL iVal AS LONG) AS INTEGER
DECLARE FUNCTION USB4_SetCounterMode LIB "usb4.dll" ALIAS "USB4_SetCounterMode" (BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYVAL iVal AS LONG) AS INTEGER
DECLARE FUNCTION USB4_SetCounterEnabled LIB "usb4.dll" ALIAS "USB4_SetCounterEnabled" (BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYVAL bVal AS BYTE) AS INTEGER
DECLARE SUB USB4_Shutdown LIB "usb4.dll" ALIAS "USB4_Shutdown" ()
%QSB_MAX_COMM_PORTS = 255

%QSB_DEFAULT_BAUD_RATE =  230400

'// QSB Return Codes
%QSB_SUCCESS =                         &H00    '// Success.
%QSB_INVALID_PARAMETER =               &H03    '// Invalid Parameter
%QSB_INVALID_COMPORT =                 &H07    '// Invalid com port specified.
%QSB_FAIL_TO_OPEN_COM_PORT  =          &H08    '// Failed to com port.
%QSB_COMM_ERROR   =                    &H09    '// Generic com error.
%QSB_COM_PORT_NOT_OPEN  =              &H0a    '// Com port not open.
%QSB_FAILED_TO_CLEAR_COM_ERROR  =      &H0d    '// Failed to clear com port error
%QSB_FAILED_TO_SET_COM_PORT_TIMEOUT =  &H0b    '// Failed to set com port timeout
%QSB_FAILED_TO_FLUSH_COM_PORT =        &H0c    '// Failed to purge the com port
%QSB_FAILED_TO_READ_CONNECTION_REPLY =  &H0d   ' // Failed to read connection reply. Usually something like 'QSB-M 0A!'
%QSB_COMM_TIMEOUT   =                  &H0f    '// Failed to receive expected data
%QSB_NOT_FOUND    =                    &Hff    '// Not a QSB device.
'QSB enums
'// QSB Enums
ENUM COMMAND
    '/// <summary>
    '/// RESET (default): MD_QUIT command is issued to the motor, stoppping it.
    '/// The Encoder, Digital I/O and MD_Status streaming data functions are deactivated.
    '/// Motor drive is deactivate. The digital I/O bits 1 and 2 return to their input
    '/// I/O function.
    '/// </summary>
    RESET = 0
    '/// <summary>
    '/// Deactivate all Encoder, Digital I/O and MD_Status streaming data.
    '/// The motor state is unaffected.
    '/// </summary>
    DisableStreaming = 1
    '/// <summary>
    '/// Activate motor drive mode. The digital I/O bits 1 and 2 are reserved for the motor drive.
    '/// </summary>
    EnableMotor = 2
    '/// <summary>
    '/// Save the current configuration to user flash memory. (not implemented)
    '/// </summary>
    SaveConfiguration = 3
    '/// <summary>
    '/// Stop the motor using the acceleration step rate.
    '/// </summary>
    MotorStop = 4
    '/// <summary>
    '/// Immediately stop the motor.
    '/// </summary>
    MotorQuit = 5
    '/// <summary>
    '/// Pause the motor using the deceleration step rate.
    '/// </summary>
    MotorPause = 6
    '/// <summary>
    '/// Resume motor operation if it was previously stopped using the pause command.
    '/// Uses the programmed motor acceleration.
    '/// </summary>
    MotorResume = 7
    '/// <summary>
    '/// Move the selected number of move-steps. Refer to <see cref="Register.StepsToMove"/>.
    '/// </summary>
    MotorMove = 8
    '/// <summary>
    '/// Jog at the selected jog step rate. Refer to <see cref="Register.JogRate"/>.
    '/// </summary>
    MotorJog = 9
END ENUM

ENUM QSB_Register
'    /// <summary>
'    /// Holds several bits that configure the operation mode of the encoder.
'    ///
'    /// <para>BITS: B7 B6 B5 B4 B3 B2 B1 B0</para>
'    ///
'    /// <para>
'    /// B1 B0<br />
'    /// = 00: quadrature mode. This is the default mode and the actual behavior is further
'    /// determined by <see cref="DigitalIOConfiguration"/> <br />
'    /// = 01: Pulse Width Modulation (PWM) mode.<br />
'    /// = 10: Analog Mode.<br />
'    /// = 11: Unused/Invalid value.
'    /// </para>
'    ///
'    /// <para>
'    /// B2 B3<br />
'    /// Unused.
'    /// </para>
'    ///
'    /// <para>
'    /// B4<br />
'    /// This bit is readonly and reports the PWM resolution if applicable.
'    /// = 0: 10-bit resolution.<br />
'    /// = 1: 12-bit resolution.
'    /// </para>
'    ///
'    /// <para>
'    /// B5-B7<br />
'    /// Unused.
'    /// </para>
'    ///
'    /// <para>Data range: <c>0x00</c> - <c>0x12</c></para>
'    /// </summary>
    EncoderMode = &H0
    '/// <summary>
    '/// Holds a four bit value that maps to the actual I/O
    '/// state of the input and output pins. A read returns the actual state measured at the
    '/// four digital I/O bit inputs, bit3 – bit0.  A write sets the open-drain output state
    '/// of the four digital I/O bits.
    '///
    '/// <para>
    '/// BITS:   B3 B2 B1 B0<br />
    '/// Bx = 1 = Open Drain Output High<br />
    '/// Bx = 0 = Open Drain Output Low
    '/// </para>
    '///
    '/// <para>
    '/// In stream mode, the new I/O state is read at a rate set by the “Interval Rate”
    '/// parameter; however, data will only be “streamed out” out if the I/O bit state has changed.
    '/// A read of the bits will deactivate the streaming mode.  Initial state after power up is
    '/// all outputs high.
    '/// </para>
    '///
    '/// <para>Data range: <c>0x00</c> - <c>0x0F</c></para>
    '/// </summary>
    DigitalIO = &H1
    '/// <summary>
    '/// Sets the direction and interrupt capability of the digital I/O pins.
    '///
    '/// <para>BITS:   B12 B11 B10 B9 B8 B7 B6 B5 B4 B3 B2 B1 B0</para>
    '///
    '/// <para>
    '/// B12<br />
    '/// Match Output Pulse - 1=enabled, 0=disabled
    '/// </para>
    '///
    '/// <para>
    '/// B11 … B8<br />
    '/// I/O Direction – I/O bit3…bit0, 1=output, 0=input
    '/// </para>
    '///
    '/// <para>
    '/// B7 … B4<br />
    '/// Interrupt enable – I/O bit3…bit0, 1=enabled, 0=disabled
    '/// </para>
    '///
    '/// <para>
    '/// B3… B0<br />
    '/// Interrupt Polarity – I/O bit3…bit0, 1= high-low, 0= low-high
    '/// </para>
    '///
    '/// <para>
    '/// NOTE: The only interrupt available is for I/O input, bit 3.  This interrupt will
    '/// load the current 7366’s quadurature encoder CNTR value into the OTR register.
    '/// </para>
    '///
    '/// <para>Data range: <c>0x000</c> - <c>0xFFF</c></para>
    '/// </summary>
    DigitalIOConfiguration = &H2
    '/// <summary>
    '/// Holds the values used to define the behavior of the
    '/// quadrature encoder counter and index circuitry.
    '///
    '/// <para>
    '/// Counter Mode Register 0<br />
    '/// The MDR0 (Mode Register 0) is an 8-bit read/write value that sets up the operating
    '/// mode for the LS7366R counter.  Upon power up MDR0 is cleared to zero. The following
    '/// is a breakdown of the MDR bits:
    '/// </para>
    '///
    '/// <para>BITS:   B7 B6 B5 B4 B3 B2 B1 B0</para>
    '///
    '/// <para>
    '/// B1 B0<br />
    '/// = 00: non-quadrature count mode. (A = clock, B = direction)<br />
    '/// = 01: x1 quadrature count mode (one count per quadrature cycle)<br />
    '/// = 10: x2 quadrature count mode (two counts per quadrature cycle)<br />
    '/// = 11: x4 quadrature count mode (four counts per quadrature cycle)
    '/// </para>
    '///
    '/// <para>
    '/// B3 B2<br />
    '/// = 00: free-running count mode<br />
    '/// = 01: single-cycle count mode (counter disabled with carry or borrow, re-enabled
    '/// with reset or load)<br />
    '/// = 10: range-limit count mode (up and down count-ranges are limited between DTR and zero,
    '/// respectively; counting freezes at these limits but resumes when direction reverses)<br />
    '/// = 11: modulo-n count mode (input count clock frequency is divided by a factor of (n+1),
    '/// where n = DTR, in both up and down directions)
    '/// </para>
    '///
    '/// <para>
    '/// B5 B4<br />
    '/// = 00: disable index<br />
    '/// = 01: configure index as the "load CNTR" input (transfers DTR to CNTR)<br />
    '/// = 10: configure index as the "reset CNTR" input (clears CNTR to 0)<br />
    '/// = 11: configure index as the "load OTR" input (transfers CNTR to OTR)
    '/// </para>
    '///
    '/// <para>
    '/// B6<br />
    '/// = 0: Asynchronous Index<br />
    '/// = 1: Synchronous Index (overridden in non-quadrature mode)
    '/// </para>
    '///
    '/// <para>
    '/// B7  (note: The filter clock input is 24MHz)<br />
    '/// = 0: Filter clock division factor = 1<br />
    '/// = 1: Filter clock division factor = 2
    '/// </para>
    '///
    '/// <para>Data range: <c>0x00</c> - <c>0xFF</c></para>
    '/// </summary>
    CounterMode0 = &H3
    '/// <summary>
    '/// Holds the values used to enable or disable the quadrature
    '/// encoder counter and specific trigger events.
    '///
    '/// <para>
    '/// Counter Mode Register 1<br />
    '/// The MDR1 (Mode Register 1) is an 8-bit read/write value which is appended to MDR0
    '/// for additional modes.  Upon power-up MDR1 is cleared to zero.
    '/// </para>
    '///
    '/// <para>BITS: B8 B7 B6 B5 B4 B3 B2 B1 B0</para>
    '///
    '/// <para>
    '/// B1 B0<br />
    '/// = 00: 4-byte counter mode<br />
    '/// = 01: 3-byte counter mode<br />
    '/// = 10: 2-byte counter mode<br />
    '/// = 11: 1-byte counter mode
    '/// </para>
    '///
    '/// <para>
    '/// B2<br />
    '/// = 0: Enable counting<br />
    '/// = 1: Disable counting
    '/// </para>
    '///
    '/// <para>
    '/// B3: Encoder Index Polarity<br />
    '/// = 0: Non invert index (default)<br />
    '/// = 1: Invert Index
    '/// </para>
    '///
    '/// <para>
    '/// B4<br />
    '/// = 0: NOP<br />
    '/// = 1: FLAG on IDX (B4 of STR)
    '/// </para>
    '///
    '/// <para>
    '/// B5<br />
    '/// = 0: NOP<br />
    '/// = 1: FLAG on CMP (B5 of STR)
    '/// </para>
    '///
    '/// <para>
    '/// B6<br />
    '/// = 0: NOP<br />
    '/// = 1: FLAG on BW (B6 of STR)
    '/// </para>
    '///
    '/// <para>
    '/// B7<br />
    '/// = 0: NOP<br />
    '/// = 1: FLAG on CY (B7 of STR)
    '/// </para>
    '///
    '/// <para>
    '/// B7<br />
    '/// = 0: NOP<br />
    '/// = 1: FLAG on CY (B7 of STR)
    '/// </para>
    '/// <para>Data range: <c>0x000</c> - <c>0x1FF</c></para>
    '/// </summary>
    CounterMode1 = &H4
    '/// <summary>
    '/// Holds the value of the quadrature state counter. The size
    '/// is configured by the CounterMode1 register.
    '///
    '/// <para>Data range: <c>0x00000000</c> - <c>0xFFFFFFFF</c></para>
    '/// </summary>
    CapturedEncoderCounter = &H5
    '/// <summary>
    '/// Holds count related status information.
    '///
    '/// <para>Data range: <c>0x00</c> - <c>0xFF</c></para>
    '/// </summary>
    EncoderStatus = &H6
    '/// <summary>
    '/// Drop-off site for instantaneous encoder counter data
    '/// which can be read without interfering with the counting process.
    '///
    '/// <para>Data range: <c>0x00000000</c> - <c>0xFFFFFFFF</c></para>
    '/// </summary>
    EncoderOutputLatch = &H7
    '/// <summary>
    '/// Maps to the LS7266 DTR field.  This value can be transferred
    '/// into the 32-bit counter under program control or by hardware index signal.  In compare
    '/// operations, whereby compre flag is set, this value is compared with the encoder
    '/// counter value.
    '///
    '/// <para>Data range: <c>0x00000000</c> - <c>0xFFFFFFFF</c></para>
    '/// </summary>
    PresetMatch = &H8
    '/// <summary>
    '/// Writing one of the following values clears the corresponding register.
    '/// <para>
    '/// 0 = CounterMode0<br />
    '/// 1 = CounterMode1<br />
    '/// 2 = EncoderCounter<br />
    '/// 3 = EncoderStatus.
    '/// </para>
    '///
    '/// <para>Data range: <c>0x00</c> - <c>0x03</c></para>
    '/// </summary>
    ClearRegister = &H9
    '/// <summary>
    '/// Writing one of the following values causes data to be transfered to the corresponding register.
    '/// <para>
    '/// 0 = transfers the <see cref="Register.PresetMatch"/> value to the <see cref="Register.ReadEncoder"/> register<br />
    '/// 1 = transfers the <see cref="Register.ReadEncoder"/> value to the <see cref="Register.EncoderOutputLatch"/> register
    '/// </para>
    '///
    '/// <para>Data range: <c>0x00</c> - <c>0x01</c></para>
    '/// </summary>
    LoadRegister = &HA
    '/// <summary>
    '/// Holds the absolute count threshold between the previous
    '/// count value and the current count value before a new value is reported at the selected
    '/// interval rate. A value of 0 will report all values at the selected interval rate.
    '/// A count that exceeds the threshold value will be immediately reported if the interval
    '/// rate is disabled (<c>0xFFFF</c>).  The threshold default value is 0.
    '///
    '/// <para>Data range: <c>0x0000</c> - <c>0xFFFF</c></para>
    '/// </summary>
    Threshold = &HB
    '/// <summary>
    '/// Holds the interval display rate in 1.953125ms steps (1/512 Hz clock).
    '/// A rate of <c>0xFFFF</c> will disable the streaming value.  A rate of <c>0x0000</c> will
    '/// update the data as fast as possible (approximately every 500 &#181;s).
    '///
    '/// <para>Data range: <c>0x0000</c> - <c>0xFFFF</c></para>
    '/// </summary>
    IntervalRate = &HC
    '/// <summary>
    '/// The time stamp counter is a 32-bit counter clocked every 1.953125ms (1/512Hz clock).
    '/// It is used to time-stamp data that is saved in the on board RAM chip.  This counter is cleared
    '/// on a power-cycle or by an externally triggered event.  Write a 1 to this value to clear
    '/// the timer. A read will return the current 32-bit time stamp value.
    '///
    '/// <para>Data range: <c>0x00000000</c> - <c>0xFFFFFFFF</c></para>
    '/// </summary>
    TimeStamp = &HD
    '/// <summary>
    '/// Holds the value of the encoder.  If in Quadrature mode, the encoder value will be returned
    '/// with the count precision selected by the MDR1 value (8 to 32 bits, 2 to 8 characters).
    '/// If in PWM mode or Analog mode, a 12-bit (4 character, leading 0) value will be returned.
    '/// In stream mode, the new encoder value is output at a rate set by the “Interval Rate”
    '/// and “Threshold” parameters.  A read of the register will disable the streaming data mode.
    '///
    '/// <para>Data range: <c>0x00000000</c> - <c>0xFFFFFFFF</c></para>
    '/// </summary>
    ReadEncoder = &HE
    '/// <summary>
    '/// Holds the motor step rate from 100 - 13440 steps/second.
    '///
    '/// <para>Data range: <c>0x0020</c> - <c>0x3480</c></para>
    '/// </summary>
    StepRate = &HF
    '/// <summary>
    '/// Holds the motor step acceleration from 1 - 1000000.
    '///
    '/// <para>Data range: <c>0x000040</c> - <c>0x07FFFF</c></para>
    '/// </summary>
    Acceleration = &H10
    '/// <summary>
    '/// Holds the number of motor steps to move. Range +/– (2^31)-1
    '/// (negative value indicates opposite direction).
    '///
    '/// <para>Data range: <c>0x80000001</c> - <c>0x7FFFFFFF</c></para>
    '/// </summary>
    StepsToMove = &H11
    '/// <summary>
    '/// Holds the motor rate in steps/second. The range is -13440 to 13440.
    '///
    '/// <para>Data range: <c>0xFFFFCB80</c> - <c>0x00003480</c></para>
    '/// </summary>
    JogRate = &H12
    '/// <summary>
    '/// Holds the current motor movement status.
    '///
    '/// <para>BITS: B4 B3 B2 B1 B0</para>
    '///
    '/// <para>
    '/// B0 = done/ready<br />
    '/// B1 = moving<br />
    '/// B2 = paused<br />
    '/// B3 = jogging<br />
    '/// B4 = Motor Enabled
    '/// </para>
    '///
    '/// <para>
    '/// In stream mode, the new MD_STATUS is output upon a state change.
    '/// A read of MD_STATUS will cancel the streaming mode.
    '/// Default Motor Enabled = 0, disabled.
    '/// </para>
    '///
    '/// <para>Data range: <c>0x00</c> - <c>0x1F</c></para>
    '/// </summary>
    MotorStatus = &H13
    '/// <summary>
    '/// Returns the product type and firmware version.  The initial version will be XX01.
    '///
    '/// <para>
    '/// Product type (MSB):<br />
    '/// 00 = QSB-DI<br />
    '/// 01 = QSB-SI<br />
    '/// 02 = QSB-I<br />
    '/// 03 = QSB-S
    '/// </para>
    '///
    '/// <para>
    '/// Firmware Version:<br />
    '/// Initial version = 01
    '/// </para>
    '///
    '/// <para>Example: 0301 = QSB-S, Version 01</para>
    '///
    '/// <para>Data range: <c>0x00000000</c> - <c>0xFFFFFFFF</c></para>
    '/// </summary>
    Version = &H14
    '/// <summary>
    '/// Holds the code that defines the command response format.
    '/// This command defines the type of formatting for the command response termination.
    '/// Each feature is enabled with a bit=1 or disabled with a bit=0.
    '/// The default value is: CR/LF = <c>0x03</c>.
    '///
    '/// <para>
    '/// BITS:   B3 B2 B1 B0<br />
    '/// B0 = Line Feed<br />
    '/// B1 = Carriage Return<br />
    '/// B2 = 4-byte Time Stamp appended to response<br />
    '/// B3 = Spaces between returned fields
    '/// </para>
    '///
    '/// <para>Data range: <c>0x00</c> - <c>0x0F</c></para>
    '/// </summary>
    ResponseFormat = &H15
    '/// <summary>
    '/// Command value is used to execute QSB commands.
    '/// <seealso cref="ResponseFormatFlags"/>
    '///
    '/// <para>Data range: <c>0x00</c> - <c>0x09</c></para>
    '/// </summary>
    CommandRegister = &H16
    '/// <exclude>
    '/// Identifies the number of registers.
    '/// </exclude>
    EnumCount = &H17
END ENUM

ENUM CounterMode
    FreeRunningCounter = 0
    NonRecycle = 1
    RangeLimit = 2
    ModuloN = 3
END ENUM

ENUM  QuadratureMode
    ClockAndDirection = 0
    X1 = 1
    X2 = 2
    X4 = 3
END ENUM

ENUM EncoderDirection
    CountingDown = 0
    CountingUp = 1
END ENUM

ENUM IndexConfiguration
    Disabled = 0
    PresetCounter = 1
    ResetCounter = 2
    CaptureCounter = 3
END ENUM
DECLARE FUNCTION QSB_InitComm LIB "QSBUser.dll" ALIAS "QSB_InitComm" (BYVAL comPort AS DWORD) AS INTEGER
DECLARE FUNCTION QSB_InitCommScan LIB "QSBUser.dll" ALIAS "QSB_InitCommScan" (BYREF comPort AS DWORD) AS INTEGER
DECLARE FUNCTION QSB_CloseComm LIB "QSBUser.dll" ALIAS "QSB_CloseComm" (BYVAL comPort AS DWORD) AS INTEGER
DECLARE FUNCTION QSB_GetDeviceInfo LIB "QSBUser.dll" ALIAS "QSB_GetDeviceInfo" (BYVAL comPort AS DWORD, BYREF product AS STRING * 10, _
                            BYREF version AS STRING * 10, BYREF serialNo AS STRING * 10 ) AS INTEGER
DECLARE FUNCTION QSB_GetResponseFormat LIB "QSBUser.dll" ALIAS "QSB_GetResponseFormat" (BYVAL comPort AS DWORD, BYREF linefeed AS BYTE, _
                            BYREF carriageReturn AS BYTE, BYREF timeStamp AS BYTE, BYREF spaces AS BYTE ) AS INTEGER
DECLARE FUNCTION QSB_SetResponseFormat LIB "QSBUser.dll" ALIAS "QSB_SetResponseFormat" (BYVAL comPort AS DWORD, BYREF elinefeed AS BYTE, _
                            BYREF carriageReturn AS BYTE, BYREF timeStamp AS BYTE, BYREF spaces AS BYTE  ) AS INTEGER
DECLARE FUNCTION QSB_ReadRegister LIB "QSBUser.dll" ALIAS "QSB_ReadRegister" (BYVAL comPort AS DWORD, BYVAL regNo AS DWORD, _
                            BYREF regValue AS LONG ) AS INTEGER
DECLARE FUNCTION QSB_WriteRegister LIB "QSBUser.dll" ALIAS "QSB_WriteRegister" (BYVAL comPort AS DWORD, BYVAL regNo AS DWORD, _
                            BYVAL regValue AS LONG ) AS INTEGER
DECLARE FUNCTION QSB_GetCount LIB "QSBUser.dll" ALIAS "QSB_GetCount" (BYVAL comPort AS DWORD, _
                            BYREF count AS LONG ) AS INTEGER
DECLARE FUNCTION QSB_SetCount LIB "QSBUser.dll" ALIAS "QSB_SetCount" (BYVAL comPort AS DWORD, _
                            BYVAL count AS LONG ) AS INTEGER
DECLARE FUNCTION QSB_GetMatchPreset LIB "QSBUser.dll" ALIAS "QSB_GetMatchPreset" (BYVAL comPort AS DWORD, _
                            BYREF count AS LONG ) AS INTEGER

DECLARE FUNCTION QSB_SetMatchPreset LIB "QSBUser.dll" ALIAS "QSB_SetMatchPreset" (BYVAL comPort AS DWORD, _
                            BYVAL matchPreset AS LONG ) AS INTEGER
DECLARE FUNCTION QSB_GetStatus LIB "QSBUser.dll" ALIAS "QSB_GetStatus" (BYVAL comPort AS DWORD, _
                            BYREF status AS LONG ) AS INTEGER

DECLARE FUNCTION QSB_ClearStatus LIB "QSBUser.dll" ALIAS "QSB_ClearStatus" (BYVAL comPort AS DWORD) AS INTEGER


DECLARE FUNCTION QSB_GetCounterMode LIB "QSBUser.dll" ALIAS "QSB_GetCounterMode" (BYVAL comPort AS DWORD, _
                            BYREF mode AS LONG) AS INTEGER
DECLARE FUNCTION QSB_SetCounterMode LIB "QSBUser.dll" ALIAS "QSB_SetCounterMode" (BYVAL comPort AS DWORD, _
                            BYVAL mode AS LONG) AS INTEGER
DECLARE FUNCTION QSB_GetQuadratureMode LIB "QSBUser.dll" ALIAS "QSB_GetQuadratureMode" (BYVAL comPort AS DWORD, _
                            BYREF mode AS LONG) AS INTEGER
DECLARE FUNCTION QSB_SetQuadratureMode LIB "QSBUser.dll" ALIAS "QSB_SetQuadratureMode" (BYVAL comPort AS DWORD, _
                            BYVAL mode AS LONG) AS INTEGER

DECLARE FUNCTION QSB_GetDirection LIB "QSBUser.dll" ALIAS "QSB_GetDirection" (BYVAL comPort AS DWORD, _
                            BYREF direction AS LONG) AS INTEGER
DECLARE FUNCTION QSB_SetDirection LIB "QSBUser.dll" ALIAS "QSB_SetDirection" (BYVAL comPort AS DWORD, _
                            BYVAL direction AS LONG) AS INTEGER
DECLARE FUNCTION QSB_SendReceive LIB "QSBUser.dll" ALIAS "QSB_SendReceive" (BYVAL comPort AS DWORD, _
                            BYVAL ulSendSize AS LONG, BYREF pucSendBuff AS BYTE, BYREF pulRecvSize AS LONG, _
                            BYREF pucRecvBuff AS BYTE) AS INTEGER
%ClassName                         = 001
%GuidTxt                           = 002
%Friendly                          = 003
%DevDesc                           = 004
%DevDriver                         = 005
%PortName                          = 006
%Manufacturer                      = 007

%DIGCF_DEFAULT                     = 001
%DIGCF_PRESENT                     = 002
%DIGCF_ALLCLASSES                  = 004
%DIGCF_PROFILE                     = 008
%DIGCF_DEVICEINTERFACE             = 016

%MAX_CLASS_NAME_LEN                = 128

%DIREG_DEV                         = 001
%DIREG_DRV                         = 002

%DICS_FLAG_GLOBAL                  = 001
%DICS_FLAG_CONFIGSPECIFIC          = 002

%SPDRP_DEVICEDESC                  = 000
%SPDRP_HARDWAREID                  = 001
%SPDRP_COMPATIBLEIDS               = 002
%SPDRP_SERVICE                     = 004
%SPDRP_CLASS                       = 007
%SPDRP_CLASSGUID                   = 008
%SPDRP_DRIVER                      = 009
%SPDRP_CONFIGFLAGS                 = 010
%SPDRP_MFG                         = 011
%SPDRP_FRIENDLYNAME                = 012
%SPDRP_LOCATION_INFORMATION        = 013
%SPDRP_PHYSICAL_DEVICE_OBJECT_NAME = 014
%SPDRP_CAPABILITIES                = 015
%SPDRP_UI_NUMBER                   = 016
%SPDRP_UPPERFILTERS                = 017
%SPDRP_LOWERFILTERS                = 018
%SPDRP_BUSTYPEGUID                 = 019
%SPDRP_LEGACYBUSTYPE               = 020
%SPDRP_BUSNUMBER                   = 021
%SPDRP_ENUMERATOR_NAME             = 022
%SPDRP_SECURITY                    = 023
%SPDRP_SECURITY_SDS                = 024
%SPDRP_DEVTYPE                     = 025
%SPDRP_EXCLUSIVE                   = 026
%SPDRP_CHARACTERISTICS             = 027
%SPDRP_ADDRESS                     = 028
%SPDRP_UI_NUMBER_DESC_FORMAT       = 030

TYPE SP_CLASSIMAGELIST_DATA
  cbSize              AS DWORD
  hImageList          AS DWORD
  Reserved            AS DWORD
END TYPE

TYPE SP_DEVINFO_DATA
  cbSize              AS DWORD
  ClassGuid           AS GUIDAPI
  DevInst             AS DWORD
  Reserved            AS DWORD
END TYPE

TYPE SP_DEVICE_INTERFACE_DATA
  cbSize              AS DWORD
  InterfaceClassGuid  AS GUIDAPI
  Flags               AS DWORD
  Reserved            AS DWORD PTR
END TYPE

TYPE SP_DEVICE_INTERFACE_DETAIL_DATA
  cbSize              AS DWORD
  DevicePath          AS ASCIIZ * 512
END TYPE
DECLARE FUNCTION SetupDiLoadClassIcon LIB "SetupApi.DLL" ALIAS "SetupDiLoadClassIcon"( _
  BYREF ClassGuid                     AS GUIDAPI, _
  BYREF hIconBig                      AS DWORD  , _
  BYREF ImageIndex                    AS LONG) AS LONG

DECLARE FUNCTION SetupDiGetClassImageList LIB "SetupApi.DLL" ALIAS "SetupDiGetClassImageList"( _
  BYREF ClassImageListData            AS SP_CLASSIMAGELIST_DATA) AS LONG

DECLARE FUNCTION SetupDiGetClassImageListEx LIB "SetupApi.DLL" ALIAS "SetupDiGetClassImageListExA"( _
  BYREF ClassImageListData            AS SP_CLASSIMAGELIST_DATA, _
  BYREF MachineName                   AS ASCIIZ                , _
  BYVAL Reserved                      AS DWORD) AS LONG

DECLARE FUNCTION SetupDiDestroyClassImageList LIB "SetupApi.DLL" ALIAS "SetupDiDestroyClassImageList"( _
  BYREF ClassImageListData            AS SP_CLASSIMAGELIST_DATA) AS LONG

DECLARE FUNCTION SetupDiGetClassImageIndex LIB "SetupApi.DLL" ALIAS "SetupDiGetClassImageIndex"( _
  BYREF ClassImageListData            AS SP_CLASSIMAGELIST_DATA, _
  BYREF ClassGuid                     AS GUIDAPI, _
  BYREF ImageIndex                    AS LONG) AS LONG

DECLARE FUNCTION SetupDiOpenClassRegKey LIB "SetupApi.DLL" ALIAS "SetupDiOpenClassRegKey"( _
  BYREF ClassGuidList                 AS GUIDAPI, _
  BYREF samDesired                    AS DWORD) AS LONG

DECLARE FUNCTION SetupDiOpenClassRegKeyEx LIB "SetupApi.DLL" ALIAS "SetupDiOpenClassRegKeyExA"( _
  BYREF ClassGuidList                 AS GUIDAPI, _
  BYREF samDesired                    AS DWORD  , _
  BYREF Flags                         AS DWORD  , _
  BYREF MachineName                   AS ASCIIZ , _
  BYREF Reserved                      AS DWORD) AS LONG

DECLARE FUNCTION SetupDiEnumDeviceInfo LIB "SetupApi.DLL" ALIAS "SetupDiEnumDeviceInfo"( _
  BYVAL hDeviceInfoSet                AS DWORD, _
  BYVAL MemberIndex                   AS DWORD, _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA) AS LONG

DECLARE FUNCTION SetupDiClassGuidsFromName LIB "SetupApi.DLL" ALIAS "SetupDiClassGuidsFromNameA"( _
  BYREF ClassName                     AS ASCIIZ , _
  BYREF ClassGuidList                 AS GUIDAPI, _
  BYREF ClassGuidListSize             AS DWORD  , _
  BYREF RequiredSize                  AS DWORD) AS LONG

DECLARE FUNCTION SetupDiClassNameFromGuid LIB "SetupApi.DLL" ALIAS "SetupDiClassNameFromGuidA"( _
  BYREF ClassGuid                     AS GUIDAPI, _
  BYREF ClassName                     AS ASCIIZ , _
  BYVAL ClassNameSize                 AS DWORD  , _
  BYREF RequiredSize                  AS DWORD) AS LONG

 DECLARE FUNCTION SetupDiGetClassDevs LIB "SetupApi.DLL" ALIAS "SetupDiGetClassDevsA"( _
  BYREF ClassGuid                     AS GUIDAPI, _
  BYREF Enumerator                    AS ASCIIZ , _
  BYVAL hwndParent                    AS DWORD  , _
  BYVAL Flags                         AS DWORD) AS DWORD

DECLARE FUNCTION SetupDiEnumDeviceInterfaces LIB "SetupApi.DLL" ALIAS "SetupDiEnumDeviceInterfaces"( _
  BYVAL hDeviceInfoSet                AS DWORD          , _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA, _
  BYREF InterfaceClassGuid            AS GUIDAPI        , _
  BYVAL MemberIndex                   AS DWORD          , _
  BYREF DeviceInterfaceData           AS SP_DEVICE_INTERFACE_DATA) AS LONG

DECLARE FUNCTION SetupDiGetDeviceRegistryProperty LIB "SetupApi.DLL" ALIAS "SetupDiGetDeviceRegistryPropertyA"( _
  BYVAL hDeviceInfoSet                AS DWORD          , _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA, _
  BYVAL Property                      AS LONG           , _
  BYREF PropertyRegDataType           AS LONG           , _
  BYREF PropertyBuffer                AS ASCIIZ         , _
  BYVAL PropertyBufferSize            AS DWORD          , _
  BYREF RequiredSize                  AS DWORD) AS LONG

DECLARE FUNCTION SetupDiGetDeviceInterfaceDetail LIB "SetupApi.DLL" ALIAS "SetupDiGetDeviceInterfaceDetailA"( _
  BYVAL hDeviceInfoSet                AS DWORD                          , _
  BYREF DeviceInterfaceData           AS SP_DEVICE_INTERFACE_DATA       , _
  BYREF DeviceInterfaceDetailData     AS SP_DEVICE_INTERFACE_DETAIL_DATA, _
  BYVAL DeviceInterfaceDetailDataSize AS DWORD                          , _
  BYREF RequiredSize                  AS DWORD                          , _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA) AS LONG

DECLARE FUNCTION SetupDiDestroyDeviceInfoList LIB "SetupApi.DLL" ALIAS "SetupDiDestroyDeviceInfoList"( _
  BYVAL hDeviceInfoSet                AS DWORD) AS LONG

DECLARE FUNCTION SetupDiOpenDevRegKey LIB "SetupApi.DLL" ALIAS "SetupDiOpenDevRegKey"( _
  BYVAL hDeviceInfoSet                AS DWORD          , _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA, _
  BYVAL Scope                         AS DWORD          , _
  BYVAL HwProfile                     AS DWORD          , _
  BYVAL KeyType                       AS DWORD          , _
  BYVAL samDesired                    AS DWORD) AS LONG

DECLARE FUNCTION SetupDiOpenDeviceInterfaceRegKey LIB "SetupApi.DLL" ALIAS "SetupDiOpenDeviceInterfaceRegKey"( _
  BYVAL hDeviceInfoSet                AS DWORD                   , _
  BYREF DeviceInterfaceData           AS SP_DEVICE_INTERFACE_DATA, _
  BYVAL Reserved                      AS DWORD                   , _
  BYVAL samDesired                    AS DWORD) AS LONG
'____________
 DECLARE FUNCTION comportlist LIB "atcondt_lib.dll" _
>>>>>>> b2cb08ee7962d6e68f5072d0943eb0a966ad16a5
         ALIAS "comportlist" (BYREF parm1() AS STRING) AS LONG
