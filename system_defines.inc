;
; Author: Rick Faszold
;
; Date: September 15th, 2014, 2014
;
; System Defines

#define DS2482_DEVICE_1_ADDRESS             H'30'   ; Base Address for Device 1 - Add Bit at end for R/W 0011000?
#define DS2482_DEVICE_2_ADDRESS             H'32'   ; Base Address for Device 1 - Add Bit at end for R/W 0011001?
#define DS2482_MAX_CHANNELS                 D'8'    ;

#define DS2482_DEVICE_RESET                 H'F0'   ; Status Reg Set,  Wait 800, Can Be Executed At Anytime */
#define DS2482_SET_READ_POINTER_COMMAND     H'E1'   ; Any Set,         Wait 0  , Can Be Executed At Anytime */
#define DS2482_WRITE_CONFIGURATION          H'D2'   ; Config Reg Set,  Wait 0  , 1-Wire Clear (Status Register 1WB == 0) */
#define DS2482_CHANNEL_SELECT_COMMAND       H'C3'   ; Channel Reg Set, Wait 0  , 1-Wire Clear (Status Register 1WB == 0) */
#define DS2482_ONE_WIRE_RESET               H'B4'   ; Status Reg Set,  Wait 600, 1-Wire Clear (Status Register 1WB == 0) */
#define DS2482_ONE_WIRE_WRITE_BYTE          H'A5'   ; Status Reg Set,  Wait 600, 1-Wire Clear (Status Register 1WB == 0) */
#define DS2482_ONE_WIRE_READ_BYTE           H'96'   ; Status Reg Set,  Wait 600, 1-Wire Clear (Status Register 1WB == 0) */

    ; DS2482 Register Pointer Codes
#define DS2482_STATUS_REGISTER              H'F0'
#define DS2482_READ_DATA_REGISTER           H'E1'
#define DS2482_CHANNEL_SELECTION_REGISTR    H'D2'
#define DS2482_CONFIGURATION_REGISTER       H'C3'

#define DS18B20_READ_ROM                    H'33'
#define DS18B20_SKIP_ROM                    H'CC'
#define DS18B20_CONVERT_TEMP                H'44'
#define DS18B20_READ_SCRATCHPAD             H'BE'
#define DS18B20_READ_POWER_SUPPLY           H'B4'


#define LOC_I2C_LINEAR_MEMORY_2000          H'2000'     ; Place Holder
#define LOC_I2C_LINEAR_MEMORY_2100          H'2100'     ; Place Holder
#define LOC_I2C_LINEAR_MEMORY_2200          H'2200'     ; Place Holder


; Address Range 2000-2010 Reserved for Global Data
#define LOC_CMD_Reset_DS2482                H'2010'     ;   8 bytes 
#define LOC_CMD_Reset_A_Probe               H'2018'     ;   8 bytes
; Gap - 8 Bytes
#define LOC_CMD_Read_1W_Byte_1_of_2         H'2028'     ;   8 bytes 
#define LOC_CMD_HEX_TO_DECIMAL_CVT          H'2030'     ;  16 Bytes 
#define LOC_CMD_Get_TEMP_Convert_TEMP       H'2040'     ;  16 bytes 
#define LOC_CMD_Get_TEMP_Skip_ROM           H'2050'     ;  16 bytes 
#define LOC_CMD_Get_TEMP_Read_Scratch       H'2060'     ;  16 bytes 
#define LOC_CMD_Channel_Select              H'2070'     ;  16 bytes 

#define LOC_CMD_1WB_Rtn_Byte                H'2080'     ;  16 bytes 
#define LOC_CMD_Read_ROM                    H'2090'     ;  16 bytes 
#define LOC_CMD_Read_1W_Byte_2_of_2         H'20A0'     ;  16 bytes 
#define LOC_CMD_Config_Reg_SPU_On           H'20B0'     ;  16 Bytes
#define LOC_I2C_DEVICE_ADDRESSES            H'20C0'     ;  16 Bytes
#define LOC_I2C_CHANNEL_READ_DATA           H'20D0'     ;  16 bytes 2008-200F
#define LOC_I2C_SOFTWARE_VERSION            H'20E0'     ;  32 bytes 20E0-20FF

#define LOC_I2C_ALL_ERROR_CODES             H'2100'     ;  32 bytes 2050-2067
#define LOC_I2C_ALL_ROM_CODES               H'2120'     ; 128 bytes 2070-20EF

#define LOC_BINARY_TO_BASE16_ASCII          H'2200'     ; 0, 1, 3, 4, 5
#define LOC_I2C_ALL_TEMP_CODES              H'2210'     ; 144 bytes 2150-223F
#define LOC_I2C_CHANNEL_WRITE_DATA          H'22C0'     ;  16 bytes 2000-2007


#define CMD_START                           D'83'   ; S - Start
#define CMD_AD_0                            D'82'   ; R - Have Device Read a Byte
#define CMD_AD_1                            D'87'   ; W - Have Device Write a Byte
#define CMD_RESTART                         D'72'   ; r - ReStart
#define CMD_ACK                             D'65'   ; A - Acknowledge
#define CMD_NACK                            D'78'   ; N - NACK
#define CMD_COMMAND                         D'67'   ; C - Command
#define CMD_READ_BYTE                       D'66'   ; B - Byte -> Get Byte off the Written from Device
#define CMD_STOP                            D'80'   ; P - Stop


#define ERROR_FLAG_WAIT_MSSP                D'0'
#define ERROR_FLAG_ACKNOWLEDGEMENT          D'1'
#define ERROR_FLAG_CLEAR_1WB_TO             D'2'
#define ERROR_FLAG_CLEAR_1WB_BAD_READ       D'3'
#define ERROR_FLAG_BAD_CHANNEL_SELECT       D'4'
#define ERROR_FLAG_INVALID_COMMAND          D'5'
#define ERROR_FLAG_NO_PPD                   D'6'
;#define ERROR_FLAG_BAD_COMMUNICATIONS       D'7'
;#define ERROR_FLAG_BAD_CHIP_INIT            D'7'


#define UART_INTERUPT_FLAG_TEMPS            D'0'



