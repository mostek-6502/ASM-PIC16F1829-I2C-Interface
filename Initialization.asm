;
; Author: Rick Faszold
;
; Date: September 16th, 2014
;
; In order to allow more program in Bank 0, this llows the linker to place
; this stuff anywhere
;

 list p=16f1829       ; set processor type
#include <C:\Program Files (x86)\Microchip\MPLABX\mpasmx\p16f1829.inc>
#include "system_defines.inc"

    GLOBAL CALL_g_Initialize
    GLOBAL CALL_g_I2C_Init_Error_Codes



INIT_VARS UDATA
iInit_Count                     RES     1


    CODE

;*******************************************************************************



;*******************************************************************************
CALL_g_Initialize

    call CALL_Init_Linear_Memory

    call CALL_I2C_Init_Version_Array
    call CALL_I2C_Init_Channel_Read_Array
    call CALL_I2C_Init_Channel_Wrte_Array
    call CALL_g_I2C_Init_Error_Codes
    call CALL_I2C_Init_ROM_Code_Buffer
    call CALL_I2C_Init_TEMP_Code_Buffer
    call CALL_I2C_Init_Device_Addresses

    call CALL_Init_4Bit_Hex_To_Decimal
    call CALL_Cvt_Binary_To_BASE16_ASCII

    call CALL_I2C_Init_CMD_Reset_DS2482
    call CALL_I2C_Init_CMD_1WB_Rtn_Byte
    call CALL_I2C_Init_CMD_Channel_Select
    call CALL_I2C_Init_CMD_Reset_A_Probe
    call CALL_I2C_Init_CMD_Read_1W_Byte
    call CALL_I2C_Init_CMD_Read_ROM
    call CALL_I2C_Init_CMD_Get_Temp
    call CALL_I2C_Init_CMD_SPU_On

    return
;*******************************************************************************



;*******************************************************************************
CALL_Init_Linear_Memory

    ; this first portion is commands
    movlw low LOC_I2C_LINEAR_MEMORY_2000
    movwf FSR1L
    movlw high LOC_I2C_LINEAR_MEMORY_2000
    movwf FSR1H

    movlw D'255'
    BANKSEL iInit_Count
    movwf iInit_Count

LABEL_INIT_AGAIN_2000

    clrw
    movwi FSR1++

    BANKSEL iInit_Count
    decf iInit_Count, f

    btfss STATUS, Z
    goto LABEL_INIT_AGAIN_2000


;*******************************************************************************
    movlw low LOC_I2C_LINEAR_MEMORY_2100
    movwf FSR1L
    movlw high LOC_I2C_LINEAR_MEMORY_2100
    movwf FSR1H

    movlw D'255'
    BANKSEL iInit_Count
    movwf iInit_Count

LABEL_INIT_AGAIN_2100

    clrw
    movwi FSR1++

    BANKSEL iInit_Count
    decf iInit_Count, f

    btfss STATUS, Z
    goto LABEL_INIT_AGAIN_2100
;*******************************************************************************

    movlw low LOC_I2C_LINEAR_MEMORY_2200
    movwf FSR1L
    movlw high LOC_I2C_LINEAR_MEMORY_2200
    movwf FSR1H

    movlw D'255'
    BANKSEL iInit_Count
    movwf iInit_Count

LABEL_INIT_AGAIN_2200

    clrw
    movwi FSR1++

    BANKSEL iInit_Count
    decf iInit_Count, f

    btfss STATUS, Z
    goto LABEL_INIT_AGAIN_2200


    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Init_Version_Array

    ; this simply spells out the software version

    movlw low LOC_I2C_SOFTWARE_VERSION
    movwf FSR1L
    movlw high LOC_I2C_SOFTWARE_VERSION
    movwf FSR1H
   ;  012345678901234567890123456789012
   ;  Ver. 1.00 (C) 2014 Rick Faszold_

    ; at the end of the day this should read ASCII "Ver. T1.00 (C) 2014 Rick Faszold"
    movlw H'56' ; "V"  Byte 1
    movwi FSR1++

    movlw H'65' ; "e"  Byte 2
    movwi FSR1++

    movlw H'72' ; "r"  Byte 3
    movwi FSR1++

    movlw H'2E' ; "."  Byte 4
    movwi FSR1++

    movlw H'20' ; " "  Byte 5
    movwi FSR1++

    movlw H'54' ; "T"  Byte 5
    movwi FSR1++

    movlw H'31' ; "1"  Byte 6
    movwi FSR1++

    movlw H'2E' ; "."  Byte 7
    movwi FSR1++

    movlw H'30' ; "0"  Byte 8
    movwi FSR1++

    movlw H'30' ; "0"  Byte 9
    movwi FSR1++

    movlw H'20' ; " "  Byte 10
    movwi FSR1++

    movlw H'28' ; "("  Byte 11
    movwi FSR1++

    movlw H'43' ; "C"  Byte 12
    movwi FSR1++

    movlw H'29' ; ")"  Byte 13
    movwi FSR1++

    movlw H'20' ; " "  Byte 14
    movwi FSR1++

    movlw H'32' ; "2"  Byte 15
    movwi FSR1++

    movlw H'30' ; "0"  Byte 16
    movwi FSR1++

    movlw H'31' ; "1"  Byte 17
    movwi FSR1++

    movlw H'34' ; "4"  Byte 18
    movwi FSR1++

    movlw H'20' ; " "  Byte 19
    movwi FSR1++

    movlw H'52' ; "R"  Byte 20
    movwi FSR1++

    movlw H'69' ; "i"  Byte 21
    movwi FSR1++

    movlw H'63' ; "c"  Byte 22
    movwi FSR1++

    movlw H'6B' ; "k"  Byte 23
    movwi FSR1++

    movlw H'20' ; " "  Byte 24
    movwi FSR1++

    movlw H'46' ; "F"  Byte 25
    movwi FSR1++

    movlw H'61' ; "a"  Byte 26
    movwi FSR1++

    movlw H'73' ; "s"  Byte 27
    movwi FSR1++

    movlw H'7A' ; "z"  Byte 28
    movwi FSR1++

    movlw H'6F' ; "o"  Byte 29
    movwi FSR1++

    movlw H'6C' ; "l"  Byte 30
    movwi FSR1++

    movlw H'64' ; "d"  Byte 31
    movwi FSR1++

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Init_Channel_Read_Array

    movlw low LOC_I2C_CHANNEL_READ_DATA
    movwf FSR1L
    movlw high LOC_I2C_CHANNEL_READ_DATA
    movwf FSR1H

	; {0xB8, 0xB1, 0xAA, 0xA3, 0x9C, 0x95, 0x8E, 0x87};
    ; TWICE!!!

    movlw H'B8' ;
    movwi FSR1++

    movlw H'B1'
    movwi FSR1++

    movlw H'AA'
    movwi FSR1++

    movlw H'A3'
    movwi FSR1++

    movlw H'9C'
    movwi FSR1++

    movlw H'95'
    movwi FSR1++

    movlw H'8E'
    movwi FSR1++

    movlw H'87'
    movwi FSR1++


    movlw H'B8' ;
    movwi FSR1++

    movlw H'B1'
    movwi FSR1++

    movlw H'AA'
    movwi FSR1++

    movlw H'A3'
    movwi FSR1++

    movlw H'9C'
    movwi FSR1++

    movlw H'95'
    movwi FSR1++

    movlw H'8E'
    movwi FSR1++

    movlw H'87'
    movwi FSR1++


    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Init_Channel_Wrte_Array

    movlw low LOC_I2C_CHANNEL_WRITE_DATA
    movwf FSR1L
    movlw high LOC_I2C_CHANNEL_WRITE_DATA
    movwf FSR1H

    ; {0xF0, 0xE1, 0xD2, 0xC3, 0xB4, 0xA5, 0x96, 0x87};
    ; TWICE

    movlw H'F0' ; "0"
    movwi FSR1++

    movlw H'E1'
    movwi FSR1++

    movlw H'D2'
    movwi FSR1++

    movlw H'C3'
    movwi FSR1++

    movlw H'B4'
    movwi FSR1++

    movlw H'A5'
    movwi FSR1++

    movlw H'96'
    movwi FSR1++

    movlw H'87'
    movwi FSR1++

    movlw H'F0' ; "0"
    movwi FSR1++

    movlw H'E1'
    movwi FSR1++

    movlw H'D2'
    movwi FSR1++

    movlw H'C3'
    movwi FSR1++

    movlw H'B4'
    movwi FSR1++

    movlw H'A5'
    movwi FSR1++

    movlw H'96'
    movwi FSR1++

    movlw H'87'
    movwi FSR1++

    return
;*******************************************************************************


;*******************************************************************************
CALL_g_I2C_Init_Error_Codes

    movlw low LOC_I2C_ALL_ERROR_CODES
    movwf FSR1L
    movlw high LOC_I2C_ALL_ERROR_CODES
    movwf FSR1H

    movlw D'32'

    BANKSEL iInit_Count
    movwf iInit_Count

LABEL_Init_Next_Error_Byte

    movlw H'45'
    movwi FSR1++

    BANKSEL iInit_Count
    decf iInit_Count, f

    btfss STATUS, Z
    goto LABEL_Init_Next_Error_Byte

    nop

    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Init_ROM_Code_Buffer

    movlw low LOC_I2C_ALL_ROM_CODES
    movwf FSR1L
    movlw high LOC_I2C_ALL_ROM_CODES
    movwf FSR1H

    movlw D'128'
    BANKSEL iInit_Count
    movwf iInit_Count

    movlw H'0'  ; 'S'

LABEL_I2C_Reset_ROM_Buffer_Again

    movwi FSR1++

    BANKSEL iInit_Count
    decf iInit_Count, f

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_Reset_ROM_Buffer_Again

    nop

    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Init_TEMP_Code_Buffer

    movlw low LOC_I2C_ALL_TEMP_CODES
    movwf FSR1L
    movlw high LOC_I2C_ALL_TEMP_CODES
    movwf FSR1H

    movlw D'144'
    BANKSEL iInit_Count
    movwf iInit_Count

    movlw H'0'  ; 'U'

LABEL_I2C_Reset_TEMP_Buff_Again

    movwi FSR1++

    BANKSEL iInit_Count
    decf iInit_Count, f

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_Reset_TEMP_Buff_Again

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Init_Device_Addresses

    movlw low LOC_I2C_DEVICE_ADDRESSES
    movwf FSR1L
    movlw high LOC_I2C_DEVICE_ADDRESSES
    movwf FSR1H

    movlw DS2482_DEVICE_1_ADDRESS
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++

    movlw DS2482_DEVICE_2_ADDRESS
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++
    movwi FSR1++

    return
;*******************************************************************************



;*******************************************************************************
CALL_Init_4Bit_Hex_To_Decimal

    movlw low LOC_CMD_HEX_TO_DECIMAL_CVT
    movwf FSR1L
    movlw high LOC_CMD_HEX_TO_DECIMAL_CVT
    movwf FSR1H

    ;  Converts a 4 Bit Hex to Decimal...  .0625 to .1
    ; 0,   1,   2,   3,   4,   5,   6,   7,  8,   9,   A,   B,   C,   D,   E,   F
    ;{0,   1,   1,   2,   3,   3,   4,   4,  5,   6,   6,   7,   8,   8,   9,   9};

    movlw H'0' ;    0
    movwi FSR1++

    movlw H'1' ;    1
    movwi FSR1++

    movlw H'1' ;    2
    movwi FSR1++

    movlw H'2' ;    3
    movwi FSR1++

    movlw H'3' ;    4
    movwi FSR1++

    movlw H'3' ;    5
    movwi FSR1++

    movlw H'4' ;    6
    movwi FSR1++

    movlw H'4' ;    7
    movwi FSR1++

    ; 0,   1,   2,   3,   4,   5,   6,   7,  8,   9,   A,   B,   C,   D,   E,   F
    ;{0,   1,   1,   2,   3,   3,   4,   4,  5,   6,   6,   7,   8,   8,   9,   9};

    movlw H'5' ;    8
    movwi FSR1++

    movlw H'6' ;    9
    movwi FSR1++

    movlw H'6' ;    A
    movwi FSR1++

    movlw H'7' ;    B
    movwi FSR1++

    movlw H'8' ;    C
    movwi FSR1++

    movlw H'8' ;    D
    movwi FSR1++

    movlw H'9' ;    E
    movwi FSR1++

    movlw H'9' ;    F
    movwi FSR1++

    return
;*******************************************************************************



;*******************************************************************************
CALL_Cvt_Binary_To_BASE16_ASCII

    movlw low LOC_BINARY_TO_BASE16_ASCII
    movwf FSR1L
    movlw high LOC_BINARY_TO_BASE16_ASCII
    movwf FSR1H

   ;  Converts a 4 Bit Hex to Decimal...  .0625 to .1

    movlw H'30' ;   "0"
    movwi FSR1++

    movlw H'31' ;   "1"
    movwi FSR1++

    movlw H'32' ;   "2"
    movwi FSR1++

    movlw H'33' ;   "3"
    movwi FSR1++

    movlw H'34' ;   "4"
    movwi FSR1++

    movlw H'35' ;   "5"
    movwi FSR1++

    movlw H'36' ;   "6"
    movwi FSR1++

    movlw H'37' ;   "7"
    movwi FSR1++

    movlw H'38' ;   "8"
    movwi FSR1++

    movlw H'39' ;   "9"
    movwi FSR1++

    movlw H'41' ;   "A"
    movwi FSR1++

    movlw H'42' ;   "B"
    movwi FSR1++

    movlw H'43' ;   "C"
    movwi FSR1++

    movlw H'44' ;   "D"
    movwi FSR1++

    movlw H'45' ;   "E"
    movwi FSR1++

    movlw H'46' ;   "F"
    movwi FSR1++

    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Init_CMD_Reset_DS2482

    movlw low LOC_CMD_Reset_DS2482
    movwf FSR1L
    movlw high LOC_CMD_Reset_DS2482
    movwf FSR1H


    ;=== [S] AD,0 A CMD,DRST A P        1
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A CMD,DRST A P        2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] CMD,DRST A P        3
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A [CMD,DRST] A P        4
    movlw CMD_COMMAND
    movwi FSR1++

    ;=== S AD,0 A [CMD,DRST] A P        5
    movlw DS2482_DEVICE_RESET
    movwi FSR1++

    ;=== S AD,0 A DRST [A] P            6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A DRST A [P]            7
    movlw CMD_STOP
    movwi FSR1++


    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Init_CMD_1WB_Rtn_Byte

    movlw low LOC_CMD_1WB_Rtn_Byte
    movwf FSR1L
    movlw high LOC_CMD_1WB_Rtn_Byte
    movwf FSR1H

;=== [S]  AD,0 A  SRP A F0 A   Sr AD 1 A <byte> A <byte> A\ P       1
    movlw CMD_START
    movwi FSR1++

;=== S  [AD,0] A  SRP A F0 A   Sr AD 1 A <byte> A <byte> A\ P       2
    movlw CMD_AD_0
    movwi FSR1++

;=== S  AD,0 [A]  SRP A F0 A   Sr AD 1 A <byte> A <byte> A\ P       3
    movlw CMD_ACK
    movwi FSR1++

;=== S  AD,0 A  [CMD,SRP] A F0 A   Sr AD 1 A <byte> A <byte> A\ P   4
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS2482_SET_READ_POINTER_COMMAND                       ;   5
    movwi FSR1++

;=== S  AD,0 A  SRP [A] F0 A   Sr AD 1 A <byte> A <byte> A\ P       6
    movlw CMD_ACK
    movwi FSR1++

;=== S  AD,0 A  SRP A [CMD,F0] A   Sr AD 1 A <byte> A <byte> A\ P   7
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS2482_STATUS_REGISTER                                ;   8
    movwi FSR1++

;=== S  AD,0 A  SRP A CMD,F0 [A] Sr AD 1 A <byte> A <byte> A\ P     9
    movlw CMD_ACK
    movwi FSR1++

;=== S  AD,0 A  SRP A CMD,F0 A [Sr] AD 1 A <byte> A <byte> A\ P     10
    movlw CMD_RESTART
    movwi FSR1++

;=== S  AD,0 A  SRP A CMD,F0 A Sr [AD,1] A <byte> A <byte> A\ P     11
    movlw CMD_AD_1
    movwi FSR1++

;=== S  AD,0 A  SRP A CMD,F0 A Sr AD,1 [A] <byte> A\ P              12
    movlw CMD_ACK
    movwi FSR1++


;=== S  AD,0 A  SRP A CMD,F0 A Sr AD,1 A [<byte>] A\ P              13
    movlw CMD_READ_BYTE
    movwi FSR1++


;=== S  AD,0 A  SRP A CMD,F0 A Sr AD,1 A <byte> A <byte> [A\] P     14
    movlw CMD_NACK
    movwi FSR1++

;=== S  AD,0 A  SRP A CMD,F0 A Sr AD,1 A <byte> A <byte> A\ [P]     15
    movlw CMD_STOP
    movwi FSR1++

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Init_CMD_Channel_Select

    movlw low LOC_CMD_Channel_Select
    movwf FSR1L
    movlw high LOC_CMD_Channel_Select
    movwf FSR1H


    ;=== [S] AD,0 A CHSL A E1h A Sr AD,1 A <byte> A\ P          1
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A CHSL A E1h A Sr AD,1 A <byte> A\ P          2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] CHSL A E1h A Sr AD,1 A <byte> A\ P          3
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A [CMD,CHSL] A E1h A Sr AD,1 A <byte> A\ P      4
    movlw CMD_COMMAND
    movwi FSR1++

    ;=== S AD,0 A [CMD,CHSL] A E1h A Sr AD,1 A <byte> A\ P      5
    movlw DS2482_CHANNEL_SELECT_COMMAND
    movwi FSR1++

    ;=== S AD,0 A CMD,CHSL [A] E1h A Sr AD,1 A <byte> A\ P      6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A CMD,CHSL A [CMD,??h] A Sr AD,1 A <byte> A\ P  7
    movlw CMD_COMMAND
    movwi FSR1++

    ;=== S AD,0 A CMD,CHSL A [CMD,??h] A Sr AD,1 A <byte> A\ P  8
    movlw D'0'
    movwi FSR1++
    ;BANKSEL iI2C_Channel_Selected
    ;movf iI2C_Channel_Selected, w


    ;=== S AD,0 A CMD,CHSL A ??h [A] Sr AD,1 A <byte> A\ P      9
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A CMD,CHSL A ??h A [Sr] AD,1 A <byte> A\ P      10
    movlw CMD_RESTART
    movwi FSR1++

    ;=== S AD,0 A CHSL A E1h A Sr [AD,1] A <byte> A\ P          11
    movlw CMD_AD_1
    movwi FSR1++

    ;=== S AD,0 A CMD,CHSL A ??h A Sr AD,1 [A] <byte> A\ P      12
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A CMD,CHSL A ??h A Sr AD,1 A [<byte>] A\ P      13
    movlw CMD_READ_BYTE
    movwi FSR1++

    ;=== S AD,0 A CMD,CHSL A ??h A Sr AD,1 A <byte> [A\] P      14
    movlw CMD_NACK
    movwi FSR1++

    ;=== S AD,0 A CMD,CHSL A ??h A Sr AD,1 A <byte> A\ [P]      15
    movlw CMD_STOP
    movwi FSR1++


    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Init_CMD_Reset_A_Probe

    movlw low LOC_CMD_Reset_A_Probe
    movwf FSR1L
    movlw high LOC_CMD_Reset_A_Probe
    movwf FSR1H

    ;     S  AD,0 A 1WRS A P <- OK
    ;=== [S] AD,0 A 1WRS A P        1
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A 1WRS A P        2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] 1WRS A P        3
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A [CMD,1WRS] A P    4
    movlw CMD_COMMAND
    movwi FSR1++

    ;=== S AD,0 A [CMD,1WRS] A P    5
    movlw DS2482_ONE_WIRE_RESET
    movwi FSR1++

    ;=== S AD,0 A DRST [A] P        6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A DRST A [P]        7
    movlw CMD_STOP
    movwi FSR1++


    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Init_CMD_Read_ROM

    movlw low LOC_CMD_Read_ROM
    movwf FSR1L
    movlw high LOC_CMD_Read_ROM
    movwf FSR1H

    ;=== [S] AD,0 A 1WWB A 33h A P          1
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A 1WWB A 33h A P          2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] 1WWB A 33h A P          3
    movlw CMD_ACK
    movwi FSR1++

    ;    S AD,0 A      1WWB  A [33h] A P    4
    ;=== S AD,0 A [CMD,1WWB] A P
    movlw CMD_COMMAND
    movwi FSR1++

    ; 1WWB Command "1-Wire Write Byte", A5h 5
    movlw DS2482_ONE_WIRE_WRITE_BYTE
    movwi FSR1++

    ;=== S AD,0 A 1WWB [A] 33h A P          6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A 1WWB A [CMD,33h] A P      7
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS18B20_READ_ROM              ;   8
    movwi FSR1++

    ;=== S AD,0 A 1WWB A 33h [A] P          9
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A 1WWB A 33h A [P]          10
    movlw CMD_STOP
    movwi FSR1++


    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Init_CMD_Get_Temp


    ; SKIP ROM==================================================================
    movlw low LOC_CMD_Get_TEMP_Skip_ROM
    movwf FSR1L
    movlw high LOC_CMD_Get_TEMP_Skip_ROM
    movwf FSR1H


    ;=== [S] AD,0 A 1WWB A CCh A P              1
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A 1WWB A CCh A P              2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] 1WWB A CCh A P              3
    movlw CMD_ACK
    movwi FSR1++

    ;    S AD,0 A      1WWB  A CCh A P
    ;=== S AD,0 A [CMD,1WWB] A P                4
    movlw CMD_COMMAND
    movwi FSR1++

    ; 1WWB Command "1-Wire Write Byte", A5h     5
    movlw DS2482_ONE_WIRE_WRITE_BYTE
    movwi FSR1++

    ;=== S AD,0 A 1WWB [A] CCh A P              6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A 1WWB A [CMD,CCh] A P          7
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS18B20_SKIP_ROM              ;       8
    movwi FSR1++

    ;=== S AD,0 A 1WWB A CCh [A] P              9
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A 1WWB A CCh A [P]              10
    movlw CMD_STOP
    movwi FSR1++




    ; CONVERT TEMP==============================================================
    movlw low LOC_CMD_Get_TEMP_Convert_TEMP
    movwf FSR1L
    movlw high LOC_CMD_Get_TEMP_Convert_TEMP
    movwf FSR1H

    ;=== [S] AD,0 A 1WWB A 44h A P              1
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A 1WWB A 44h A P              2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] 1WWB A 44h A P              3
    movlw CMD_ACK
    movwi FSR1++

    ;    S AD,0 A      1WWB  A 44h A P
    ;=== S AD,0 A [CMD,1WWB] A P                4
    movlw CMD_COMMAND
    movwi FSR1++

    ; 1WWB Command "1-Wire Write Byte", A5h     5
    movlw DS2482_ONE_WIRE_WRITE_BYTE
    movwi FSR1++

    ;=== S AD,0 A 1WWB [A] 44h A P              6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A 1WWB A [CMD,44h] A P          7
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS18B20_CONVERT_TEMP          ;       8
    movwi FSR1++

    ;=== S AD,0 A 1WWB A 44h [A] P              9
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A 1WWB A 44h A [P]              10
    movlw CMD_STOP
    movwi FSR1++



    ; READ SCRATCH PAD==========================================================
    movlw low LOC_CMD_Get_TEMP_Read_Scratch
    movwf FSR1L
    movlw high LOC_CMD_Get_TEMP_Read_Scratch
    movwf FSR1H


    ;=== [S] AD,0 A 1WWB A BEh A P              1
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A 1WWB A BEh A P              2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] 1WWB A BEh A P              3
    movlw CMD_ACK
    movwi FSR1++

    ;    S AD,0 A      1WWB  A BEh A P          4
    ;=== S AD,0 A [CMD,1WWB] A P
    movlw CMD_COMMAND
    movwi FSR1++

    ; 1WWB Command "1-Wire Write Byte", A5h     5
    movlw DS2482_ONE_WIRE_WRITE_BYTE
    movwi FSR1++

    ;=== S AD,0 A 1WWB [A] BEh A P              6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A 1WWB A [CMD,BEh] A P          7
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS18B20_READ_SCRATCHPAD           ;   8
    movwi FSR1++

    ;=== S AD,0 A 1WWB A BEh [A] P              9
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A 1WWB A BEh A [P]              10
    movlw CMD_STOP
    movwi FSR1++

    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Init_CMD_Read_1W_Byte

    movlw low LOC_CMD_Read_1W_Byte_1_of_2
    movwf FSR1L
    movlw high LOC_CMD_Read_1W_Byte_1_of_2
    movwf FSR1H


    ; tell it you want to read a BYTE       1
    ;=== [S] AD,0 A 1WRB A P
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A 1WRB A P                2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] 1WRB A P                3
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A [CMD,1WRB] A P            4
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS2482_ONE_WIRE_READ_BYTE      ;  5
    movwi FSR1++

    ;=== S AD,0 A CMD,1WRB [A] P            6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A CMD,1WRB A [P]            7
    movlw CMD_STOP
    movwi FSR1++



    movlw low LOC_CMD_Read_1W_Byte_2_of_2
    movwf FSR1L
    movlw high LOC_CMD_Read_1W_Byte_2_of_2
    movwf FSR1H


    ;=== [S] AD,0 A SRP A E1h A Sr AD,1 A <byte> A\ P           1
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A SRP A E1h A Sr AD,1 A <byte> A\ P           2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] SRP A E1h A Sr AD,1 A <byte> A\ P           3
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A [CMD,SRP] A E1h A Sr AD,1 A <byte> A\ P       4
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS2482_SET_READ_POINTER_COMMAND                   ;   5
    movwi FSR1++

    ;=== S AD,0 A SRP [A] E1h A Sr AD,1 A <byte> A\ P           6
    movlw CMD_ACK
    movwi FSR1++


    ;=== S AD,0 A SRP A [CMD,E1h] A Sr AD,1 A <byte> A\ P       7
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS2482_READ_DATA_REGISTER                         ;   8
    movwi FSR1++

    ;=== S AD,0 A SRP A E1h [A] Sr AD,1 A <byte> A\ P           9
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A SRP A E1h A [Sr] AD,1 A <byte> A\ P           10
    movlw CMD_RESTART
    movwi FSR1++

    ;=== S AD,0 A SRP A E1h A Sr [AD,1] A <byte> A\ P           11
    movlw CMD_AD_1
    movwi FSR1++

    ;=== S AD,0 A SRP A E1h A Sr AD,1 [A] <byte> A\ P           12
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A SRP A E1h A Sr AD,1 A [<byte>] A\ P           13
    movlw CMD_READ_BYTE
    movwi FSR1++

    ;=== S AD,0 A SRP A E1h A Sr AD,1 A <byte> [A\] P           14
    movlw CMD_NACK
    movwi FSR1++

    ;=== S AD,0 A SRP A E1h A Sr AD,1 A <byte> A\ [P]           15
    movlw CMD_STOP
    movwi FSR1++

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Init_CMD_SPU_On

    movlw low LOC_CMD_Config_Reg_SPU_On
    movwf FSR1L
    movlw high LOC_CMD_Config_Reg_SPU_On
    movwf FSR1H

    ; tell it you want to read a BYTE       1
    ;=== [S] AD,0 A WCFG A <byte> A P
    movlw CMD_START
    movwi FSR1++

    ;=== S [AD,0] A WCFG A <byte> A P       2
    movlw CMD_AD_0
    movwi FSR1++

    ;=== S AD,0 [A] WCFG A <byte> A P       3
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A [CMD,WCFG] A <byte> A P    4
    movlw CMD_COMMAND
    movwi FSR1++

    movlw DS2482_WRITE_CONFIGURATION      ;  5
    movwi FSR1++

    ;=== S AD,0 A WCFG [A] <byte> A P        6
    movlw CMD_ACK
    movwi FSR1++

    ;=== S AD,0 A WCFG A [CMD,<byte>] A P    7
    movlw CMD_COMMAND
    movwi FSR1++

    movlw H'B4'                           ;  8    1011,0100
    movwi FSR1++

    ;=== S AD,0 A WCFG A <byte> [A] P        9
    movlw CMD_ACK
    movwi FSR1++


    ;=== S AD,0 A WCFG A <byte> A [P]        10
    movlw CMD_STOP
    movwi FSR1++

    return
;*******************************************************************************



;*******************************************************************************


    END