;
; Author: Rick Faszold
;
; Date: December 6th, 2014
;
; Open Items
; 5. RST Line to reset the Chip - This will force restarts on everything
; 7. Lock the Processor Code
; 8. Last Reboot - How do we track them...

; 4.2.1 PROGRAM MEMORY PROTECTION
; The entire program memory space is protected from
; external reads and writes by the CP bit in Configuration
; Word 1. When CP = 0, external reads and writes of
; program memory are inhibited and a read will return all
; ?0?s. The CPU can continue to read program memory,
; regardless of the protection bit settings. Writing the
; program memory is dependent upon the write
; protection setting. See Section 4.3 ?Write
; Protection? for more information.


 list p=16f1829       ; set processor type
#include <C:\Program Files (x86)\Microchip\MPLABX\mpasmx\p16f1829.inc>
#include "system_defines.inc"


; CONFIG1
; __config 0x3FE4
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0x1EFF
 __CONFIG _CONFIG2, _WRT_OFF & _PLLEN_OFF & _STVREN_ON & _BORV_LO & _LVP_OFF


 errorlevel -302        ; supress these error messages

    EXTERN CALL_g_Initialize
    EXTERN CALL_g_I2C_Init_Error_Codes
    EXTERN CALL_g_I2C_Command_Processor

GLOBAL_CP_VARS UDATA
g_CP_iI2C_Error_Flag                        RES     1
g_CP_iI2C_ReadByte                          RES     1
g_CP_iI2C_Chip_Address                      RES     1

    GLOBAL g_CP_iI2C_Error_Flag
    GLOBAL g_CP_iI2C_ReadByte
    GLOBAL g_CP_iI2C_Chip_Address


UART_VARS UDATA
iI2C_WriteByte                              RES     1
iI2C_Error_Chip_1                           RES     1
iI2C_Error_Chip_2                           RES     1
iI2C_Read_Pointer                           RES     1
iI2C_ProbeIndex                             RES     1
iI2C_Channel_Selected                       RES     1
iI2C_Device_Command                         RES     1
iI2C_Clear_1WB_Counter                      RES     1
iI2C_Check_1WB_Counter                      RES     1
iUART_Out_Counter                           RES     1
iI2C_Read_Ptr_Register                      RES     1
iI2C_FSR_ROM_Code_Position                  RES     1
iI2C_FSR_Temp_Code_Position                 RES     1
iI2C_Buffer_XFER_Counter                    RES     1
iI2C_C1WBS_Counter                          RES     1
iI2C_Count_8                                RES     1
iI2C_Count_9                                RES     1
cUART_Input                                 RES     1
cUART_Interrupt_Flag                        RES     1
iUART_Out_Bytes                             RES     1
iI2C_Delay_It_1                             RES     1
iI2C_W1MS_1                                 RES     1
iControl_Wait_For_Data                      RES     1
iOutput_Index                               RES     1
iByte0TempLSB                               RES     1
iByte1TempMSB                               RES     1
iByte2THReg                                 RES     1
iByte3THReg                                 RES     1
iByte4CFGReg                                RES     1
iByte5_FF                                   RES     1
iByte6_Reserved                             RES     1
iByte7_10                                   RES     1
iByte8CRC                                   RES     1
iCRC_1Wire                                  RES     1
iOutboundCRC                                RES     1
iError_Code                                 RES     1
iByteFractionAndErrorCode                   RES     1
iFRS1_Pos                                   RES     1
iIndex                                      RES     1
iHEXOutCRC                                  RES     1
iUART_Char_Out                              RES     1
iROM_Out                                    RES     1
iI2C_ROM_CRC                                RES     1

RESET_VECTOR        CODE 0x0000            ; processor reset vector
    pagesel PROGRAM_START
    GOTO    PROGRAM_START


INTERRUPT_VECTOR    CODE 0x0004           ; interrupt vector location
    pagesel PROCESS_INTERRUPT
    GOTO PROCESS_INTERRUPT



;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************
MAIN_PROG CODE                      ; let linker place the main program
PROGRAM_START

    call CALL_Set_Int_Clk_16Mhz

    ; start up for programming
    call CALL_I2C_Delay_750ms
    call CALL_I2C_Delay_750ms


    call CALL_Initialize_Port_A

    call CALL_Init_RA0_RA1_For_Power
    call CALL_Port_A_RA0_RA1_Off

    call CALL_Init_RA5_For_Wake
    call CALL_Disable_Change_On_Pin_RA5


    pagesel CALL_g_Initialize
    call CALL_g_Initialize
    pagesel $

    call CALL_Setup_Interrupts
    call CALL_Setup_UART_Pins
    call CALL_Setup_UART_Port
    call CALL_Setup_I2C_Pins
    call CALL_Disable_UART
    call CALL_Peripheral_Interupt_Disable

    ; this helps with debugging UART PINS
    goto LABEL_Do_It_Again
;*******************************************************************************
;**********************TEST CODE!!!  TEST CODE!!! ******************************

    call CALL_Peripheral_Interupt_Enable
    call CALL_Enable_UART

LABEL_TEST

    call CALL_Send_Out_WakeUp_Reply
    call CALL_Receive_Data_Command

    goto LABEL_TEST
;**********************TEST CODE!!!  TEST CODE!!! ******************************
;*******************************************************************************


LABEL_Do_It_Again

    BANKSEL cUART_Input
    clrf cUART_Input               ; clears the buffer as well

    BANKSEL cUART_Interrupt_Flag
    clrf cUART_Interrupt_Flag

    call CALL_Disable_Global_Interrupt
    call CALL_Clear_PORT_A_To_Reset_Latch
    call CALL_Enable_Change_On_Pin_RA5


    nop
    nop
    SLEEP
    nop
    nop


    call CALL_Disable_Change_On_Pin_RA5
    call CALL_Clear_RA5_Interrupt_Flags
    call CALL_Clear_PORT_A_To_Reset_Latch
    call CALL_Clear_Ext_Interrupt_Flag

    call CALL_Enable_Global_Interrupt


    ; if this returns nothing, it was probably a spurrious electrical spike
    call CALL_Peripheral_Interupt_Enable
    call CALL_Enable_UART
    call CALL_Send_Out_WakeUp_Reply
    call CALL_Receive_Data_Command


    ;if this flag was set, we received a "D" from the maincontroller, time to process the data
    BANKSEL cUART_Interrupt_Flag
    btfss cUART_Interrupt_Flag, UART_INTERUPT_FLAG_TEMPS
    goto LABEL_Do_It_Again


    ; process away
    call CALL_I2C_Get_TEMP_Control
    call CALL_Send_Data_Out

    call CALL_Disable_UART
    call CALL_Peripheral_Interupt_Disable

    goto LABEL_Do_It_Again

    ; we should never get there
    return
;*******************************************************************************


;*******************************************************************************
CALL_Set_Int_Clk_16Mhz

    ;bit 7 SPLLEN: Software PLL Enable bit
    ;    If PLLEN in Configuration Word 1 = 1:
    ;        SPLLEN bit is ignored. 4x PLL is always enabled (subject to oscillator requirements)
    ;    If PLLEN in Configuration Word 1 = 0:
    ;        1 = 4x PLL Is enabled
    ;        0 = 4x PLL is disabled

    ;bit 6-3 IRCF<3:0>: Internal Oscillator Frequency Select bits
    ;    000x = 31 kHz LF
    ;    0010 = 31.25 kHz MF
    ;    0011 = 31.25 kHz HF(1)
    ;    0100 = 62.5 kHz MF
    ;    0101 = 125 kHz MF
    ;    0110 = 250 kHz MF
    ;    0111 = 500 kHz MF (default upon Reset)
    ;    1000 = 125 kHz HF(1)
    ;    1001 = 250 kHz HF(1)
    ;    1010 = 500 kHz HF(1)
    ;    1011 = 1MHz HF
    ;    1100 = 2MHz HF
    ;    1101 = 4MHz HF
    ;    1110 = 8 MHz or 32 MHz HF(see Section 5.2.2.1 ?HFINTOSC?)
    ;    1111 = 16 MHz HF

    ;bit 2 Unimplemented: Read as ?0?

    ;bit 1-0 SCS<1:0>: System Clock Select bits
    ;    1x = Internal oscillator block
    ;    01 = Timer1 oscillator
    ;    00 = Clock determined by FOSC<2:0> in Configuration Word 1.

    ; internal clock, 16Mhz
      ; Bits 76543210
     movlw B'01111011'

    BANKSEL OSCCON
    movwf OSCCON

    return
;*******************************************************************************



;*******************************************************************************
CALL_Send_Out_Test_Char

    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond

    movlw D'63' ; ?
    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out
    call CALL_UART_TX_Char

    return
;*******************************************************************************


;*******************************************************************************
CALL_Send_Out_WakeUp_Reply

    call CALL_Wait_1_MilliSecond

    movlw D'33' ; !
    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char
    call CALL_Wait_1_MilliSecond

    ;call CALL_UART_TX_Char
    ;call CALL_Wait_1_MilliSecond
    ;
    ;call CALL_UART_TX_Char

    return
;*******************************************************************************


;*******************************************************************************
CALL_Receive_Data_Command
  
    BANKSEL iControl_Wait_For_Data
    clrf iControl_Wait_For_Data

LABEL_WAIT_FOR_D_AGAIN

    ; give it a little bit for the "D" to come back
    call CALL_Wait_10ms
    call CALL_Wait_10ms
    call CALL_Wait_10ms

    BANKSEL cUART_Interrupt_Flag
    btfsc cUART_Interrupt_Flag, UART_INTERUPT_FLAG_TEMPS
    goto LABEL_WAIT_FOR_D_GET_OUT


    BANKSEL iControl_Wait_For_Data
    incf iControl_Wait_For_Data, F

    movlw D'100' ;  // just send a few of these out...

    BANKSEL iControl_Wait_For_Data
    subwf iControl_Wait_For_Data, W

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_WAIT_FOR_D_AGAIN

    nop ; ok, we did not receive anything, just get out

LABEL_WAIT_FOR_D_GET_OUT

    nop

    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Get_TEMP_Control

    ; take care of initilization....
    BANKSEL iI2C_FSR_ROM_Code_Position
    clrf iI2C_FSR_ROM_Code_Position

    BANKSEL iI2C_FSR_Temp_Code_Position
    clrf iI2C_FSR_Temp_Code_Position


    ;===========================================================================
    call CALL_Port_A_RA0_RA1_On

    call CALL_I2C_Reset_DS2482_Chip_1
    call CALL_I2C_Reset_DS2482_Chip_2

    call CALL_I2C_ROM_CODE_And_Temps

    call CALL_Port_A_RA0_RA1_Off
    ;===========================================================================

    BANKSEL iI2C_Error_Chip_1
    movf iI2C_Error_Chip_1, W
    movwf g_CP_iI2C_Error_Flag
    call CALL_I2C_Add_Byte_To_Error_Data

    ; probe index is controlling the postion of the error byte
    BANKSEL iI2C_ProbeIndex
    incf iI2C_ProbeIndex, f

    BANKSEL iI2C_Error_Chip_2
    movf iI2C_Error_Chip_2, W
    movwf g_CP_iI2C_Error_Flag
    call CALL_I2C_Add_Byte_To_Error_Data
  
    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_ROM_CODE_And_Temps

    BANKSEL g_CP_iI2C_Error_Flag
    clrf g_CP_iI2C_Error_Flag

    BANKSEL iI2C_ProbeIndex
    clrf iI2C_ProbeIndex

    ; tell all of the probes to start working on the tempetratures
LABEL_Prep_Getting_The_Temp

    call CALL_I2C_Get_Chip_Address
    call CALL_I2C_Set_SPU
    call CALL_I2C_Channel_Select
    call CALL_I2C_Read_ROM
    call CALL_I2C_Prep_The_Temperature

    BANKSEL iI2C_ProbeIndex
    incf iI2C_ProbeIndex, F

    BANKSEL iI2C_ProbeIndex
    btfss iI2C_ProbeIndex, 4
    goto LABEL_Prep_Getting_The_Temp


    ; let the probes have time to do their work
    ; DELAY=====================================================================
    call CALL_I2C_Delay_750ms
    ; DELAY=====================================================================


    BANKSEL iI2C_ProbeIndex
    clrf iI2C_ProbeIndex

LABEL_Now_Get_The_Temperature

    call CALL_I2C_Get_Chip_Address
    call CALL_I2C_Set_SPU
    call CALL_I2C_Channel_Select
    call CALL_I2C_Get_The_Temperature

    call CALL_I2C_Add_Byte_To_Error_Data

    ; clear it for the next probe....
    BANKSEL g_CP_iI2C_Error_Flag
    clrf g_CP_iI2C_Error_Flag

    BANKSEL iI2C_ProbeIndex
    incf iI2C_ProbeIndex, F

    ; Increment and Check the Probe Index, if Greater than 15, set back to Zero
    BANKSEL iI2C_ProbeIndex
    btfss iI2C_ProbeIndex, 4
    goto LABEL_Now_Get_The_Temperature

    nop

    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Get_Chip_Address

    movlw low LOC_I2C_DEVICE_ADDRESSES
    movwf FSR1L
    movlw high LOC_I2C_DEVICE_ADDRESSES
    movwf FSR1H

    BANKSEL iI2C_ProbeIndex
    movf iI2C_ProbeIndex, W

    BANKSEL FSR1
    addwf FSR1, F

    BANKSEL FSR1
    moviw FSR1++

    BANKSEL g_CP_iI2C_Chip_Address
    movwf g_CP_iI2C_Chip_Address

    return
;*******************************************************************************


;*******************************************************************************
CALL_I2C_Set_SPU

    movlw low LOC_CMD_Config_Reg_SPU_On
    movwf FSR1L
    movlw high LOC_CMD_Config_Reg_SPU_On
    movwf FSR1H

    call CALL_I2C_Command_Processor


LABEL_I2C_Determine_SPU_Exit

    ; wait 5ms for the power to be applied
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond


    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Add_Byte_To_Error_Data

    ; add the error flag for the chip here....
    ; get the buffer - this should be the 17th byte
    movlw low LOC_I2C_ALL_ERROR_CODES
    movwf FSR1L
    movlw high LOC_I2C_ALL_ERROR_CODES
    movwf FSR1H

    ; get the location to drop this
    BANKSEL iI2C_ProbeIndex
    movf iI2C_ProbeIndex, W

    BANKSEL FSR1
    addwf FSR1, F

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, W

    ; drop the value in the array
    BANKSEL FSR1
    movwi FSR1++

    return
;*******************************************************************************



;*******************************************************************************
CALL_Check_Chip_Status

    ; RST set to 1,
    ; 1WB, PPD, SD, SBR, TSB, DIR set to 0
    ; correct response = 16 or 24
    ;
    ;  7   6   5   4   3  2  1   0
    ; DIR TSB SBR RST LL SD PPD 1WB
    ;  0   0   0   1   ?  0  0   0  <- Expected Settings

    BANKSEL g_CP_iI2C_ReadByte
    bcf g_CP_iI2C_ReadByte, 3  ; clear the LL bit, we do not care about that

    ; just looking for RST on the Chip
    movlw B'00010000'

    BANKSEL g_CP_iI2C_ReadByte
    subwf g_CP_iI2C_ReadByte, W

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Check_Chip_Status_Exit

    ; if ZERO, we know RST was the only thing set, make that zero - and the all is zero and get out
    BANKSEL g_CP_iI2C_ReadByte
    bcf g_CP_iI2C_ReadByte, 4

    nop

LABEL_Check_Chip_Status_Exit

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Reset_DS2482_Chip_1

    BANKSEL iI2C_Error_Chip_1
    clrf iI2C_Error_Chip_1

    BANKSEL g_CP_iI2C_Chip_Address
    movlw DS2482_DEVICE_1_ADDRESS
    movwf g_CP_iI2C_Chip_Address
    call CALL_I2C_Reset_DS2482

    call CALL_I2C_Clr_1WB_Rtn_Status

    call CALL_Check_Chip_Status

    BANKSEL g_CP_iI2C_ReadByte
    movf g_CP_iI2C_ReadByte, W

    BANKSEL iI2C_Error_Chip_1
    movwf iI2C_Error_Chip_1

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Reset_DS2482_Chip_2

    BANKSEL iI2C_Error_Chip_2
    clrf iI2C_Error_Chip_2

    BANKSEL g_CP_iI2C_Chip_Address
    movlw DS2482_DEVICE_2_ADDRESS
    movwf g_CP_iI2C_Chip_Address
    call CALL_I2C_Reset_DS2482

    call CALL_I2C_Clr_1WB_Rtn_Status

    call CALL_Check_Chip_Status

    BANKSEL g_CP_iI2C_ReadByte
    movf g_CP_iI2C_ReadByte, W

    BANKSEL iI2C_Error_Chip_2
    movwf iI2C_Error_Chip_2

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Reset_DS2482

    movlw low LOC_CMD_Reset_DS2482
    movwf FSR1L
    movlw high LOC_CMD_Reset_DS2482
    movwf FSR1H

    call CALL_I2C_Command_Processor

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Reset_A_Specific_Probe

    movlw low LOC_CMD_Reset_A_Probe
    movwf FSR1L
    movlw high LOC_CMD_Reset_A_Probe
    movwf FSR1H

    call CALL_I2C_Command_Processor

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Clr_1WB_Rtn_Stat_Cmd

    movlw low LOC_CMD_1WB_Rtn_Byte
    movwf FSR1L
    movlw high LOC_CMD_1WB_Rtn_Byte
    movwf FSR1H

    call CALL_I2C_Command_Processor

    nop

    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL iI2C_C1WBS_Counter
    clrf iI2C_C1WBS_Counter

LABEL_Clear_1WB_Try_Again

        BANKSEL iI2C_C1WBS_Counter
        incf iI2C_C1WBS_Counter, f

        BANKSEL STATUS
        btfss STATUS, Z
        goto LABEL_Clear_1WB_Try_Check         ; 0 flag not set

        BANKSEL g_CP_iI2C_Error_Flag
        bsf g_CP_iI2C_Error_Flag, ERROR_FLAG_CLEAR_1WB_TO
        goto LABEL_Clear_1WB_Try_Exit


LABEL_Clear_1WB_Try_Check

        ; go out and get the status byte
        call CALL_I2C_Clr_1WB_Rtn_Stat_Cmd

        BANKSEL g_CP_iI2C_Error_Flag
        movf g_CP_iI2C_Error_Flag, F

        BANKSEL STATUS
        btfss STATUS, Z
        goto LABEL_Clear_1WB_Try_Exit


        ; see if the byte is reasonable
        call CALL_I2C_Check_Valid_Status_Byte

        BANKSEL g_CP_iI2C_Error_Flag
        movf g_CP_iI2C_Error_Flag, F

        BANKSEL STATUS
        btfss STATUS, Z
        goto LABEL_Clear_1WB_Try_Exit

        nop


LABEL_Clear_1WB_Try_Test_1WB

        ; check to see if the Status Bit Cleared
        BANKSEL g_CP_iI2C_ReadByte
        btfsc g_CP_iI2C_ReadByte, 0      ; seeing if the read byte is OK
        goto LABEL_Clear_1WB_Try_Again


LABEL_Clear_1WB_Try_Exit

    nop

    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Channel_Select

    ; {0xF0, 0xE1, 0xD2, 0xC3, 0xB4, 0xA5, 0x96, 0x87};
    movlw low LOC_I2C_CHANNEL_WRITE_DATA
    movwf FSR1L
    movlw high LOC_I2C_CHANNEL_WRITE_DATA
    movwf FSR1H

    BANKSEL iI2C_ProbeIndex
    movf iI2C_ProbeIndex, w      ; this should give the starting position

    BANKSEL FSR1
    addwf FSR1, F

    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iI2C_Channel_Selected
    movwf iI2C_Channel_Selected

    ; get starting position
    movlw low LOC_CMD_Channel_Select
    movwf FSR1L
    movlw high LOC_CMD_Channel_Select
    movwf FSR1H

    movlw D'7'
    BANKSEL FSR1
    addwf FSR1, F ; get to the position of the channel select

    ;=== S AD,0 A CMD,CHSL A [CMD,??h] A Sr AD,1 A <byte> A\ P
    BANKSEL iI2C_Channel_Selected
    movf iI2C_Channel_Selected, w

    BANKSEL FSR1
    movwi FSR1++

    ; reset to the beginnning
    movlw low LOC_CMD_Channel_Select
    movwf FSR1L
    movlw high LOC_CMD_Channel_Select
    movwf FSR1H


    call CALL_I2C_Command_Processor



    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_Channel_Select_Exit



    ; look up the channel - {0xB8, 0xB1, 0xAA, 0xA3, 0x9C, 0x95, 0x8E, 0x87};
    movlw low LOC_I2C_CHANNEL_READ_DATA
    movwf FSR1L
    movlw high LOC_I2C_CHANNEL_READ_DATA
    movwf FSR1H

    BANKSEL iI2C_ProbeIndex
    movf iI2C_ProbeIndex, w      ; this should give the starting position

    BANKSEL FSR1
    addwf FSR1, F
    moviw FSR1++                    ; we have the channel byte in W at this point


    BANKSEL g_CP_iI2C_ReadByte
    subwf g_CP_iI2C_ReadByte, W

    BANKSEL STATUS
    btfsc STATUS, Z
    goto LABEL_I2C_Channel_Select_Exit

    ; this just says that the return code from the device was NOT zero... not a good result.
    BANKSEL g_CP_iI2C_Error_Flag
    bsf g_CP_iI2C_Error_Flag, ERROR_FLAG_BAD_CHANNEL_SELECT

    nop

LABEL_I2C_Channel_Select_Exit

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Check_Valid_Status_Byte

    ; bit 7  bit 6  bit 5  bit 4  bit 3  bit 2  bit 1  bit 0
    ; DIR    TSB    SBR    RST     LL    SD      PPD    1WB

    ; this is just a general check of the Status byte
    BANKSEL g_CP_iI2C_ReadByte
    btfsc g_CP_iI2C_ReadByte, 7  ; DIR Bit Should Be Clear
    goto LABEL_Valid_Status_Byte_Error

    BANKSEL g_CP_iI2C_ReadByte
    btfsc g_CP_iI2C_ReadByte, 6  ; TSB Bit Should Be Clear
    goto LABEL_Valid_Status_Byte_Error

    BANKSEL g_CP_iI2C_ReadByte
    btfsc g_CP_iI2C_ReadByte, 5  ; TSB Bit Should Be Clear
    goto LABEL_Valid_Status_Byte_Error

    nop ; the byte is OK, get out

    goto LABEL_Valid_Status_Byte_Exit

LABEL_Valid_Status_Byte_Error

    BANKSEL g_CP_iI2C_Error_Flag
    bsf g_CP_iI2C_Error_Flag, ERROR_FLAG_CLEAR_1WB_BAD_READ


LABEL_Valid_Status_Byte_Exit

    nop

    return
;*******************************************************************************



;*******************************************************************************
Check_I2C_PPD

    ; bit 7  bit 6  bit 5  bit 4  bit 3  bit 2  bit 1  bit 0
    ; DIR    TSB    SBR    RST     LL    SD      PPD    1WB
    ; CHK    CHK    CHK    SKP     SKP

    call CALL_I2C_Check_Valid_Status_Byte

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_PPD_Exit


    ; Bit 4 - RST May be Set - So skip

    ; Bit 3 - LL May be Set  - So skip

    ; bit 7  bit 6  bit 5  bit 4  bit 3  bit 2  bit 1  bit 0
    ; DIR    TSB    SBR    RST     LL    SD      PPD    1WB
    ; CHK    CHK    CHK    SKP     SKP    X       X      X


    ; is there a short in the line... like electronically messed up?
    BANKSEL g_CP_iI2C_ReadByte
    btfsc g_CP_iI2C_ReadByte, 2  ; SD Bit Should Be Clear
    goto LABEL_PPD_Error

    ; do we have PPD?
    BANKSEL g_CP_iI2C_ReadByte
    btfsc g_CP_iI2C_ReadByte, 1  ; SD Bit Should Be Clear
    goto LABEL_PPD_Exit     ; if we hit this goto - we are good!!!!


LABEL_PPD_Error

    BANKSEL g_CP_iI2C_Error_Flag
    bsf g_CP_iI2C_Error_Flag, ERROR_FLAG_NO_PPD


LABEL_PPD_Exit

    nop

    return

;*******************************************************************************



;*******************************************************************************
CALL_I2C_Read_ROM

    ; see if any errors here...  if so, bail out
    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_ROM_Fake_it

    ; reset the specific probe
    call CALL_I2C_Reset_A_Specific_Probe

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_ROM_Fake_it


    ; check the return status
    call CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_ROM_Fake_it


    ; check the presense of pulse
    call Check_I2C_PPD

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_ROM_Fake_it


    nop


    movlw low LOC_CMD_Read_ROM
    movwf FSR1L
    movlw high LOC_CMD_Read_ROM
    movwf FSR1H

    call CALL_I2C_Command_Processor

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_ROM_Fake_it


    call CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_ROM_Fake_it

    nop


LABEL_Read_ROM_Fake_it

    ; right here, we start setting things up to read the ROM codes.
    ; if an error flag was thrown ReadByte will be set and not changed from R (for ROM)
    movlw D'8'

    BANKSEL iI2C_Count_8
    movwf iI2C_Count_8

    movlw low LOC_I2C_ALL_ROM_CODES
    movwf FSR0L
    movlw high LOC_I2C_ALL_ROM_CODES
    movwf FSR0H

    BANKSEL iI2C_FSR_ROM_Code_Position
    movf iI2C_FSR_ROM_Code_Position, W

    BANKSEL FSR0
    addwf FSR0, F


LABEL_READ_ROM_BYTE

    ; if there is an error, Read The Byte Will Not work and ReadByte is Set to '0'
    ; this is what is needed
    movlw H'0'
    BANKSEL g_CP_iI2C_ReadByte
    movwf g_CP_iI2C_ReadByte

    call CALL_I2C_Read_The_1_Wire_Byte

    BANKSEL g_CP_iI2C_ReadByte
    movf g_CP_iI2C_ReadByte, W

    BANKSEL FSR0
    movwi FSR0++

    BANKSEL iI2C_FSR_ROM_Code_Position    ; this bascially skips to the next slot.
    incf iI2C_FSR_ROM_Code_Position, F ; 1

    BANKSEL iI2C_Count_8
    decf iI2C_Count_8, f

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_READ_ROM_BYTE    ; get more data

    nop


    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Prep_The_Temperature

    ; see if any errors here...  if so, bail out
    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Prep_Temp_Error_Exit



    ; [RESET PROBE], PPD, SKIP, Convert=======================================
    call CALL_I2C_Reset_A_Specific_Probe

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Prep_Temp_Error_Exit


    ; check the status
    call CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Prep_Temp_Error_Exit


    ; RESET PROBE, [PPD], SKIP, Convert=======================================
    call Check_I2C_PPD

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Prep_Temp_Error_Exit


    ; RESET PROBE, PPD, [SKIP], Convert=======================================
    movlw low LOC_CMD_Get_TEMP_Skip_ROM
    movwf FSR1L
    movlw high LOC_CMD_Get_TEMP_Skip_ROM
    movwf FSR1H

    call CALL_I2C_Command_Processor

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Prep_Temp_Error_Exit


    call CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Prep_Temp_Error_Exit


    ; RESET PROBE, PPD, SKIP, [Convert]=======================================
    movlw low LOC_CMD_Get_TEMP_Convert_TEMP
    movwf FSR1L
    movlw high LOC_CMD_Get_TEMP_Convert_TEMP
    movwf FSR1H

    call CALL_I2C_Command_Processor

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Prep_Temp_Error_Exit

    call CALL_I2C_Clr_1WB_Rtn_Status

LABEL_Prep_Temp_Error_Exit

    nop

    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Get_The_Temperature

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Get_Temp_Fake_It


    ; [RESET PROBE], PPD, SKIP, SCRATCH=========================================
    call CALL_I2C_Reset_A_Specific_Probe

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Get_Temp_Fake_It


    ; check the status
    call CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Get_Temp_Fake_It


    ; RESET PROBE, [PPD], SKIP, SCRATCH=========================================
    call Check_I2C_PPD

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Get_Temp_Fake_It



    ; RESET PROBE, PPD, [SKIP], SCRATCH=========================================
    movlw low LOC_CMD_Get_TEMP_Skip_ROM
    movwf FSR1L
    movlw high LOC_CMD_Get_TEMP_Skip_ROM
    movwf FSR1H

    call CALL_I2C_Command_Processor

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Get_Temp_Fake_It


    call CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Get_Temp_Fake_It



    ; RESET PROBE, PPD, SKIP, [SCRATCH]=========================================
    movlw low LOC_CMD_Get_TEMP_Read_Scratch
    movwf FSR1L
    movlw high LOC_CMD_Get_TEMP_Read_Scratch
    movwf FSR1H

    call CALL_I2C_Command_Processor

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Get_Temp_Fake_It

    call CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Get_Temp_Fake_It

    nop

    ;goto LABEL_123_Exit

LABEL_Get_Temp_Fake_It


    ; now, get the 9 bytes bytes - we get all 9 to get the CRC
    movlw D'9'

    BANKSEL iI2C_Count_9
    movwf iI2C_Count_9

    movlw low LOC_I2C_ALL_TEMP_CODES
    movwf FSR0L
    movlw high LOC_I2C_ALL_TEMP_CODES
    movwf FSR0H

    BANKSEL iI2C_FSR_Temp_Code_Position
    movf iI2C_FSR_Temp_Code_Position, W

    BANKSEL FSR0
    addwf FSR0, F


LABEL_READ_TEMP_BYTE

    movlw H'00'
    BANKSEL g_CP_iI2C_ReadByte
    movwf g_CP_iI2C_ReadByte

    ; magic happens here
    call CALL_I2C_Read_The_1_Wire_Byte

    BANKSEL g_CP_iI2C_ReadByte
    movf g_CP_iI2C_ReadByte, W

    BANKSEL FSR0
    movwi FSR0++

    BANKSEL iI2C_FSR_Temp_Code_Position
    incf iI2C_FSR_Temp_Code_Position, F

    BANKSEL iI2C_Count_9
    decf iI2C_Count_9, f

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_READ_TEMP_BYTE    ; get more data

LABEL_123_Exit

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Read_The_1_Wire_Byte

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_1Wire_Byte_Exit


    ; 1st part of command
    movlw low LOC_CMD_Read_1W_Byte_1_of_2
    movwf FSR1L
    movlw high LOC_CMD_Read_1W_Byte_1_of_2
    movwf FSR1H

    call CALL_I2C_Command_Processor

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_1Wire_Byte_Exit


    call CALL_I2C_Clr_1WB_Rtn_Status

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_Read_1Wire_Byte_Exit


    ; 2nd part of command
    movlw low LOC_CMD_Read_1W_Byte_2_of_2
    movwf FSR1L
    movlw high LOC_CMD_Read_1W_Byte_2_of_2
    movwf FSR1H

    call CALL_I2C_Command_Processor


LABEL_Read_1Wire_Byte_Exit

    nop

    return

;*******************************************************************************





;*******************************************************************************
CALL_I2C_Command_Processor


    pagesel CALL_g_I2C_Command_Processor
    call CALL_g_I2C_Command_Processor
    pagesel $

    call CALL_Wait_1_MilliSecond

    nop

    return
;*******************************************************************************


;*******************************************************************************
CALL_Wait_10ms

    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond

    return
;*******************************************************************************


;*******************************************************************************
CALL_Wait_1_MilliSecond

; If 16Mhz = 4,000,000 Instructions
; 4,000,000 / 1,000 = 4,000 Instructions Per Milli-Second
; (4000 - 20) / 20 = 199

; If 4Mhz = 1,000,000 Instructions
; 1,000,000 / 1,000 = 1,000 Instructions Per Milli-Second
; (4000 - 20) / 20 = 49

    ; Call   = 2 Cycles
    ; Return = 2 Cycles

    ; 1101 = 4MHz HF
    ; 1111 = 16 MHz HF

    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1


    movlw D'199'                 ; 1
    BANKSEL iI2C_W1MS_1
    movwf iI2C_W1MS_1           ; 1

    ; 20 Cycles Start & End / 20 Cycles in Loop

LABEL_DELAY_1MS

    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 1
    nop                         ; 16

    BANKSEL iI2C_W1MS_1
    decf iI2C_W1MS_1, f         ; 1

    BANKSEL STATUS
    btfss STATUS, Z             ; 1
    goto LABEL_DELAY_1MS        ; 1,1

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Delay_750ms

    movlw D'150'
    BANKSEL iI2C_Delay_It_1
    movwf iI2C_Delay_It_1

LABEL_DELAY_1

    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond

    BANKSEL iI2C_Delay_It_1
    decf iI2C_Delay_It_1, f

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_DELAY_1

    return
;*******************************************************************************




;*******************************************************************************
CALL_ACK_Wake_From_Sleep

    ; just woke up, get everything settled first.
    call CALL_Wait_1_MilliSecond


    movlw D'87' ; W

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char



    movlw D'65' ; A

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char



    movlw D'75' ; K

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char



    movlw D'69' ; E

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char

    return
;*******************************************************************************



;*******************************************************************************
CALL_CRC_1WIRE

;
;    CRC-8 for Dallas iButton products
;    From Maxim/Dallas AP Note 27
;    18JAN03 - T. Scott Dattalo


	xorwf	iCRC_1Wire,f
	clrw

	btfsc	iCRC_1Wire,0
	xorlw	0x5e

	btfsc	iCRC_1Wire,1
	xorlw	0xbc

	btfsc	iCRC_1Wire,2
	xorlw	0x61

	btfsc	iCRC_1Wire,3
	xorlw	0xc2

	btfsc	iCRC_1Wire,4
	xorlw	0x9d

	btfsc	iCRC_1Wire,5
	xorlw	0x23

	btfsc	iCRC_1Wire,6
	xorlw	0x46

	btfsc	iCRC_1Wire,7
	xorlw	0x8c

	movwf	iCRC_1Wire

    return
;*******************************************************************************



;*******************************************************************************
CALL_Reformat_Send_Temp_Output

    BANKSEL iFRS1_Pos
    clrf iFRS1_Pos

    BANKSEL iOutput_Index
    clrf iOutput_Index

LABEL_NEXT_FORMAT

    movlw low LOC_I2C_ALL_TEMP_CODES
    movwf FSR1L
    movlw high LOC_I2C_ALL_TEMP_CODES
    movwf FSR1H

    BANKSEL iFRS1_Pos
    movf iFRS1_Pos, W

    BANKSEL FSR1
    addwf FSR1, F


    BANKSEL iCRC_1Wire
    clrf iCRC_1Wire


    ; ok, get all of the  bytes and start testing them and build the CRC along the way
    ; byte 0 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte0TempLSB
    movwf iByte0TempLSB
    call CALL_CRC_1WIRE


    ; byte 1 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte1TempMSB
    movwf iByte1TempMSB
    call CALL_CRC_1WIRE

    ; byte 2 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte2THReg
    movwf iByte2THReg
    call CALL_CRC_1WIRE

    ; byte 3 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte3THReg
    movwf iByte3THReg
    call CALL_CRC_1WIRE

    ; byte 4 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte4CFGReg
    movwf iByte4CFGReg
    call CALL_CRC_1WIRE

    ; byte 5 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte5_FF
    movwf iByte5_FF
    call CALL_CRC_1WIRE

    ; byte 6 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte6_Reserved
    movwf iByte6_Reserved
    call CALL_CRC_1WIRE

    ; byte 7 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte7_10
    movwf iByte7_10
    call CALL_CRC_1WIRE

    ; byte 8 *****
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iByte8CRC
    movwf iByte8CRC

    ; save off FSR1


    BANKSEL iByteFractionAndErrorCode
    clrf iByteFractionAndErrorCode

    ; we are going to play with the 4 most signicant bits of the temperature
    ; need to set this up now


; ******************************************************************************
    ; ok, compare the CRC from the computed to the returned
    BANKSEL iCRC_1Wire
    movf iCRC_1Wire, W

    BANKSEL iByte8CRC
    subwf iByte8CRC, W

    BANKSEL STATUS
    btfsc STATUS, Z
    goto LABEL_TEST_CFG

    BANKSEL iByteFractionAndErrorCode
    bsf iByteFractionAndErrorCode, 7        ; 7*, 6, 5, 4


; ******************************************************************************
LABEL_TEST_CFG

    ; the config register should come back as 255 / FF

    movlw H'7F'         ; 0111 1111

    BANKSEL iByte4CFGReg
    subwf iByte4CFGReg, W

    BANKSEL STATUS
    btfsc STATUS, Z
    goto LABEL_TEST_255

    BANKSEL iByteFractionAndErrorCode
    bsf iByteFractionAndErrorCode, 6        ; 7, 6*, 5, 4


; ******************************************************************************
LABEL_TEST_255

    ; this reserve register should come back as 255 / FF

    movlw H'FF'

    BANKSEL iByte5_FF
    subwf iByte5_FF, W

    BANKSEL STATUS
    btfsc STATUS, Z
    goto LABEL_TEST_16

    BANKSEL iByteFractionAndErrorCode
    bsf iByteFractionAndErrorCode, 5        ; 7, 6, 5*, 4


; ******************************************************************************
LABEL_TEST_16

    ; this reserved register should come back as 16 / 10

    movlw H'10'

    BANKSEL iByte7_10
    subwf iByte7_10, W

    BANKSEL STATUS
    btfsc STATUS, Z
    goto LABEL_SETUP_MSB

    BANKSEL iByteFractionAndErrorCode
    bsf iByteFractionAndErrorCode, 4        ; 7, 6, 5, 4*


; ******************************************************************************
LABEL_SETUP_MSB
; Get MSB Setup Correctly

    ; get rid of the extraneous sign bit stuff at the higher order
    BANKSEL iByte1TempMSB
    lslf iByte1TempMSB, F
    lslf iByte1TempMSB, F
    lslf iByte1TempMSB, F
    lslf iByte1TempMSB, F

    ; for good measure
    bcf iByte1TempMSB, 0
    bcf iByte1TempMSB, 1
    bcf iByte1TempMSB, 2
    bcf iByte1TempMSB, 3
    ; should look like S1110000


    ; now get the rest of it from the LSB
    BANKSEL iByte0TempLSB
    movf iByte0TempLSB, W

    BANKSEL iI2C_Count_8
    movwf iI2C_Count_8
    lsrf iI2C_Count_8, F
    lsrf iI2C_Count_8, F
    lsrf iI2C_Count_8, F
    lsrf iI2C_Count_8, F

    bcf iI2C_Count_8, 7
    bcf iI2C_Count_8, 6
    bcf iI2C_Count_8, 5
    bcf iI2C_Count_8, 4
    ; should look like 00001111


    BANKSEL iI2C_Count_8
    movf iI2C_Count_8, W

    BANKSEL iByte1TempMSB
    iorwf iByte1TempMSB, F

    ; MSB should be set now

; ******************************************************************************
LABEL_CVT_HEX_TO_DEC

    ; this section is used for converting a 4 bit field to hex
    ; in this case, the are 16 decimal combinations of 0.0000, 0.0625, 0.1250, etc
    ; change to 0, 1, 1, .....
    movlw B'00001111'

    BANKSEL iByte0TempLSB
    andwf iByte0TempLSB, W

    BANKSEL iI2C_Count_8
    movwf iI2C_Count_8

    ; now, use w for the look up.  there are 16 values in this....
    movlw low LOC_CMD_HEX_TO_DECIMAL_CVT
    movwf FSR1L
    movlw high LOC_CMD_HEX_TO_DECIMAL_CVT
    movwf FSR1H

    BANKSEL iI2C_Count_8
    movf iI2C_Count_8, W

    BANKSEL FSR1
    addwf FSR1, F

    BANKSEL FSR1
    moviw FSR1++

    ; we are only focusing on the LSB 4 bits, those bits should have the 
    ; digits after the decimal point that we are looking for.
    ; W has what we want

    BANKSEL iByte0TempLSB
    movwf iByte0TempLSB

    BANKSEL iByteFractionAndErrorCode   ; these were set 7, 6, 5, 4
    movf iByteFractionAndErrorCode, W

    BANKSEL iByte0TempLSB
    iorwf iByte0TempLSB, F

    ; this should look like EEEEFFFF
    ; E = Error Bit Set
    ; F = Fraction Bit Set


; ******************************************************************************
    ; for this part we are looking up the error code for this channel
    movlw low LOC_I2C_ALL_ERROR_CODES
    movwf FSR1L
    movlw high LOC_I2C_ALL_ERROR_CODES
    movwf FSR1H

    BANKSEL iOutput_Index
    movf iOutput_Index, W

    BANKSEL FSR1
    addwf FSR1, F

    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iError_Code
    movwf iError_Code


; ******************************************************************************
    ; ok, and for the final trick, we need to calcualte a CRC on these 3 bytes
    ; this is a simple add them up with no regards to overflow

    clrw
    
    BANKSEL iByte1TempMSB
    addwf iByte1TempMSB, W

    BANKSEL iByte0TempLSB
    addwf iByte0TempLSB, W

    BANKSEL iError_Code
    addwf iError_Code, W

    BANKSEL iOutboundCRC
    movwf iOutboundCRC

    nop


; ******************************************************************************
    ; blast them all out

    BANKSEL iByte1TempMSB
    movf iByte1TempMSB, W

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char

    BANKSEL iByte0TempLSB
    movf iByte0TempLSB, W

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char

    BANKSEL iError_Code
    movf iError_Code, W

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char

    BANKSEL iOutboundCRC
    movf iOutboundCRC, W

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char



; ******************************************************************************

    movlw D'9' ; this gets the next 9 bytes
    BANKSEL iFRS1_Pos
    addwf iFRS1_Pos, F


    ; next one please...
    BANKSEL iOutput_Index
    incf iOutput_Index, f

    ; did we hit 16
    movlw D'16'
    BANKSEL iOutput_Index
    subwf iOutput_Index, W

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_NEXT_FORMAT

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_Reformat_Send_ROM_Output

    BANKSEL iOutput_Index
    clrf iOutput_Index

    movlw low LOC_I2C_ALL_ROM_CODES
    movwf FSR1L
    movlw high LOC_I2C_ALL_ROM_CODES
    movwf FSR1H

LABEL_NEXT_ROM_FORMAT

    BANKSEL iHEXOutCRC
    clrf iHEXOutCRC

    BANKSEL iCRC_1Wire
    clrf iCRC_1Wire

    ; byte 0
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iROM_Out
    movwf iROM_Out

    call CALL_CRC_1WIRE
    call CALL_HEX_OUT       ; 1, 2
    call CALL_DASH_OUT      ; 3

    ; byte 1
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iROM_Out
    movwf iROM_Out

    call CALL_CRC_1WIRE
    call CALL_HEX_OUT       ; 4, 5
    call CALL_DASH_OUT      ; 6

    ; byte 2
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iROM_Out
    movwf iROM_Out

    call CALL_CRC_1WIRE
    call CALL_HEX_OUT       ; 7, 8
    call CALL_DASH_OUT      ; 9

    ; byte 3
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iROM_Out
    movwf iROM_Out

    call CALL_CRC_1WIRE
    call CALL_HEX_OUT       ; 10, 11
    call CALL_DASH_OUT      ; 12

    ; byte 4
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iROM_Out
    movwf iROM_Out

    call CALL_CRC_1WIRE
    call CALL_HEX_OUT       ; 13, 14
    call CALL_DASH_OUT      ; 15

    ; byte 5
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iROM_Out
    movwf iROM_Out

    call CALL_CRC_1WIRE
    call CALL_HEX_OUT       ; 16, 17
    call CALL_DASH_OUT      ; 18

    ; byte 6
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iROM_Out
    movwf iROM_Out

    call CALL_CRC_1WIRE
    call CALL_HEX_OUT       ; 19, 20
    call CALL_DASH_OUT      ; 21

    ; byte 7
    BANKSEL FSR1
    moviw FSR1++

    ; ****** temp holder
    BANKSEL iI2C_ROM_CRC
    movwf iI2C_ROM_CRC
    ; right here we really should check the CRC's against each other and then set the flag


    ; OK, send the CRC out....
    BANKSEL iROM_Out
    movwf iROM_Out
    call CALL_HEX_OUT       ; 22, 23
    ; *********


    ; compare ROM values.....
    BANKSEL iI2C_ROM_CRC
    movfw iI2C_ROM_CRC

    BANKSEL iCRC_1Wire
    subwf iCRC_1Wire, W

    ; added these
    BANKSEL iROM_Out
    clrf iROM_Out

    BANKSEL STATUS
    btfsc STATUS, Z
    goto LABEL_NEXT_ROM_STEPS


    ; set the flag for ROM out...  this is bad
    BANKSEL iROM_Out
    bsf iROM_Out, 1


LABEL_NEXT_ROM_STEPS


    ; ********* this is the error flag for checking the CRC of the ROM codes
    BANKSEL iROM_Out
    movf iROM_Out, W

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char  ; 24
    ; ******** error flag out.....


    ; ************  this is the CRC of the ASCII ROM Code... did it get there OK?
    BANKSEL iHEXOutCRC
    movf iHEXOutCRC, W

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char  ; 25
    ; ************** ASCII CRC out


    ; ************  used as a marker***
    clrw

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char  ; 26
    ; ************* marker


    ; give the main controller a bit of time to digest this
    call CALL_Wait_10ms


    ; next one please...
    BANKSEL iOutput_Index
    incf iOutput_Index, f

    ; did we hit 16
    movlw D'16'
    BANKSEL iOutput_Index
    subwf iOutput_Index, W

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_NEXT_ROM_FORMAT

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_DASH_OUT

    movlw D'45'

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char

    return
;*******************************************************************************



;*******************************************************************************
CALL_HEX_OUT

    BANKSEL iROM_Out
    movf iROM_Out, W

    BANKSEL iIndex
    movwf iIndex
    lsrf iIndex, F
    lsrf iIndex, F
    lsrf iIndex, F
    lsrf iIndex, F

    bcf iIndex, 7
    bcf iIndex, 6
    bcf iIndex, 5
    bcf iIndex, 4


    ; now, use w for the look up.  there are 16 values in this....
    movlw low LOC_BINARY_TO_BASE16_ASCII
    movwf FSR0L
    movlw high LOC_BINARY_TO_BASE16_ASCII
    movwf FSR0H

    BANKSEL iIndex
    movf iIndex, W

    BANKSEL FSR0
    addwf FSR0, F

    BANKSEL FSR0
    moviw FSR0++

    BANKSEL iHEXOutCRC
    addwf iHEXOutCRC, F

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char



    BANKSEL iROM_Out
    movf iROM_Out, W

    BANKSEL iIndex
    movwf iIndex
    bcf iIndex, 7
    bcf iIndex, 6
    bcf iIndex, 5
    bcf iIndex, 4

    ; now, use w for the look up.  there are 16 values in this....
    movlw low LOC_BINARY_TO_BASE16_ASCII
    movwf FSR0L
    movlw high LOC_BINARY_TO_BASE16_ASCII
    movwf FSR0H

    BANKSEL iIndex
    movf iIndex, W

    BANKSEL FSR0
    addwf FSR0, F

    BANKSEL FSR0
    moviw FSR0++

    BANKSEL iHEXOutCRC
    addwf iHEXOutCRC, F

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char

    return
;*******************************************************************************



;*******************************************************************************
CALL_Send_Data_Out

    ; temperatures
    call CALL_Reformat_Send_Temp_Output
    call CALL_Wait_10ms
    call CALL_Wait_10ms
    call CALL_Wait_10ms

    ; ROM Codes
    call CALL_Reformat_Send_ROM_Output
    call CALL_Wait_10ms
    call CALL_Wait_10ms
    call CALL_Wait_10ms

    ; version
    movlw D'32'
    BANKSEL iUART_Out_Bytes
    movwf iUART_Out_Bytes

    movlw low LOC_I2C_SOFTWARE_VERSION
    movwf FSR1L
    movlw high LOC_I2C_SOFTWARE_VERSION
    movwf FSR1H

    call CALL_UART_Send_Data
    call CALL_Wait_10ms
    call CALL_Wait_10ms
    call CALL_Wait_10ms


   ; send out the two chip error codes
    movlw D'2'
    BANKSEL iUART_Out_Bytes
    movwf iUART_Out_Bytes

    movlw low LOC_I2C_ALL_ERROR_CODES
    movwf FSR1L
    movlw high LOC_I2C_ALL_ERROR_CODES
    movwf FSR1H

    ; we already pushed out the error codes for each reading, we need to cicle
    ; back and get the chips - so, we skip the 1st 16 bytes
    movlw D'16'

    BANKSEL FSR1
    addwf FSR1, F

    call CALL_UART_Send_Data


    ; ok, get out of dodge...

    pagesel CALL_g_I2C_Init_Error_Codes
    call CALL_g_I2C_Init_Error_Codes
    pagesel $

    nop

    return

;*******************************************************************************


;*******************************************************************************
CALL_UART_Send_Data

    ; send the UART data out!!!

CALL_UART_Send_Next_Byte

    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iUART_Char_Out
    movwf iUART_Char_Out

    call CALL_UART_TX_Char


    BANKSEL iUART_Out_Bytes
    decf iUART_Out_Bytes, f

    btfss STATUS, Z
    goto CALL_UART_Send_Next_Byte

    nop

    return

;*******************************************************************************



;*******************************************************************************
CALL_UART_TX_Char

    movlw D'255'

    BANKSEL iUART_Out_Counter
    movwf iUART_Out_Counter

    BANKSEL iUART_Char_Out
    movf iUART_Char_Out, W

    BANKSEL TXREG
    movwf   TXREG

LABEL_See_If_TX_Is_CLEAR

    BANKSEL TXSTA
    btfsc   TXSTA, TRMT           ;wait for data TX
    goto LABEL_UART_Char_Sent

    nop
    nop
    nop
    nop
    nop

    BANKSEL iUART_Out_Counter
    decf iUART_Out_Counter

    btfss STATUS, Z
    goto LABEL_See_If_TX_Is_CLEAR

    nop ; this means we hit an error

LABEL_UART_Char_Sent

    return
;*******************************************************************************



;*******************************************************************************
CALL_Setup_UART_Pins


    ; *****
    ; select the pins you want to use and then set for I or O
    BANKSEL APFCON0
    bsf APFCON0, TXCKSEL    ; bit 2 TXCKSEL: Pin Selection bit /
                            ; 0 = TX/CK function is on RB7 - Pin 10 - Green Wire
                            ; 1 = TX/CK function is on RC4 - Pin 06 - Green Wire

    ; clear TRISC is output or transmit
    BANKSEL TRISC
    bcf TRISC, TRISC4
    ; *****


    ; *****
    BANKSEL APFCON0
    bsf APFCON0, RXDTSEL    ; bit 7 RXDTSEL: Pin Selection bit
                            ; 0 = RX/DT function is on RB5 - Pin 12 - Yellow Wire
                            ; 1 = RX/DT function is on RC5 - Pin 05 - Yellow Wire

    ; set TRISC is input or receive
    BANKSEL TRISC
    bsf TRISC, TRISC5
    ; *****


    ;ANSC<7:6>: Analog Select between Analog or Digital Function on pins RC<3:0>, respectively(2)
    ;0 = Digital I/O. Pin is assigned to port or digital special function.
    ;1 = Analog input. Pin is assigned as analog input(1). Digital input buffer disabled.
    BANKSEL ANSELC
    bcf ANSELC, ANSC0
    bcf ANSELC, ANSC1
    bcf ANSELC, ANSC2
    bcf ANSELC, ANSC3


    ;INLVLC<7:0>: PORTC Input Level Select bits(1)
    ;For RC<7:0> pins, respectively
    ;1 = ST input used for port reads and interrupt-on-change
    ;0 = TTL input used for port reads and interrupt-on-change
    BANKSEL INLVLC
    bcf INLVLC, INLVLC4      ; this is for TTL
    bcf INLVLC, INLVLC5      ; this is for TTL


    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_Setup_UART_Port

    BANKSEL OSCCON
    bcf OSCCON,SCS0             ; "0" Selects Internal Oscillator Clock / This does not matter
    bsf OSCCON,SCS1             ; '1' Selects Internal Oscillator Clock
    bsf OSCCON,IRCF0            ; '1' 16Mhz
    bsf OSCCON,IRCF1            ; '1' 16Mhz
    bsf OSCCON,IRCF2            ; '1' 16Mhz
    bsf OSCCON,IRCF3            ; '1' 16Mhz
    bcf OSCCON,SPLLEN           ; "0" 4 x PLL - Need for 32MHX, should be OFF.


    ; All of the following are in Bank 3
    BANKSEL RCSTA
    bcf RCSTA,RX9D               ; RX9D: Ninth bit of Received Data
    bcf RCSTA,OERR               ; OERR: Overrun Error bit
    bcf RCSTA,FERR               ; FERR: Framing Error bit
    bcf RCSTA,ADDEN              ; ADDEN: Address Detect Enable bit - Asynch Don't care
    bsf RCSTA,CREN               ; '1' CREN: Continuous Receive Enable bit
    bcf RCSTA,SREN              ; SREN: Single Receive Enable bit - Asynch Do Not Care
    bcf RCSTA,RX9                ; "?" RX9: 9-bit Receive Enable bit
    bsf RCSTA,SPEN               ; '1' SPEN: Serial Port Enable bit
                                 ; Setting the SPEN bit of the RCSTA register enables the EUSART and automatically configures the TX/CK I/O pin as an output.
    BANKSEL TXSTA
    bcf TXSTA,TX9D               ; The EUSART supports 9-bit character transmissions.  ONLY 8 BIT used
    ;TXSTA.TRMT                  ; The TRMT bit of the TXSTA register indicates the status of the TSR register.
    bsf TXSTA,BRGH               ; '1' Setting the SPEN bit of the RCSTA register enables the EUSART and automatically configures the TX/CK I/O pin as an output.
    ;TXSTA.SENDB                 ; SENDB: Send Break Character bit
    bcf TXSTA,SYNC               ; "0" Clearing the SYNC bit of the TXSTA register configures the EUSART for asynchronous operation.
    bsf TXSTA,TXEN               ; Setting the TXEN bit of the TXSTA register enables the transmitter circuitry of the EUSART.
    bcf TXSTA,TX9                ; TX9: 9-bit Transmit Enable bit
    ;TXSTA.CSRC                  ; CSRC: Clock Source Select bit ... if asynch ... do not care

    BANKSEL BAUDCON
    bcf BAUDCON,ABDEN            ; "0" ABDEN: Auto-Baud Detect Enable bit
    bcf BAUDCON,WUE              ; "0" WUE: Wake-up Enable bit
    bsf BAUDCON,BRG16            ; '1' 1 = 16-bit Baud Rate Generator is used
    bcf BAUDCON,SCKP             ; SCKP: Synchronous Clock Polarity Select bit
    ;BAUDCON.RCIDL               ; RCIDL: Receive Idle Flag bit - read only
    ;BAUDCON.ABDOVF              ; ABDOVF: Auto-Baud Detect Overflow bit - read only


    ; set the Baud Rate based on the Clock, BRGH, BRG16
    ; Page 315 Out of the Book
    ; Find Clock Speed, like 32Mhz and then divide the SPBRG by 2
    ; 2400 BAUD
    ;BANKSEL SPBRGL
    ;movlw D'130'
    ;movwf SPBRGL                  ; 1,666 for 2400 Baud
                                  ; 1,666 = 0000 0110     1000 0010
    ;BANKSEL SPBRGH                ;        SPBRGH = 6  SPBRGL = 130
    ;movlw D'6'
    ;movwf SPBRGH

    ; 9600 BAUD -> SPBRG = 832 for 32MHz... Divide by 2 = 416 for 16Mhz
    ;BANKSEL SPBRGH
    ;movlw D'1'                      ; 416 = 0000 0001  1010 0000
    ;movwf SPBRGH                    ;          HI GH       LOW
                                    ; SPBRGH = 1        SPBRGL = 160
    ;BANKSEL SPBRGL
    ;movlw D'160'
    ;movwf SPBRGL


    ; 57600 BAUD -> SPBRG = 138 for 32MHz... Divide by 2 = 69 for 16Mhz
    BANKSEL SPBRGH
    movlw D'0'                      ; 416 = 0000 0000  0100 0101
    movwf SPBRGH                    ;          HI GH       LOW
                                    ; SPBRGH = 0        SPBRGL = 69
    BANKSEL SPBRGL
    movlw D'69'
    movwf SPBRGL


    nop

    return
;*******************************************************************************




;*******************************************************************************
CALL_Setup_I2C_Pins

    ;ANSB<7:4>: Analog Select between Analog or Digital Function on pins RB<7:4>, respectively
    ;0 = Digital I/O. Pin is assigned to port or digital special function.
    ;1 = Analog input. Pin is assigned as analog input(1). Digital input buffer disabled.
    BANKSEL ANSELB
    bcf ANSELB, ANSB4

    BANKSEL ANSELB
    bcf ANSELB, 6     ; ANSB6


    ; RB<7:4>: PORTB General Purpose I/O Pin bits
    ; 1 = Port pin is > VIH
    ; 0 = Port pin is < VIL
    BANKSEL PORTB               ; PORTB pins set to drive low
    bcf PORTB, RB4              ; RB4 - 1. SDA (MSSP)     - RB4/AN10/CPS10/SDA1/SDI1 - PIN13
    bcf PORTB, RB6              ; RB6 - 1. SCL/SCK (MSSP) - RB6/SCL1/SCK1            - PIN11


    ; TRISB<7:4>: PORTB Tri-State Control bits
    ; 1 = PORTB pin configured as an input (tri-stated)
    ; 0 = PORTB pin configured as an output
    BANKSEL TRISB
    bsf TRISB, TRISB4           ; RB4 (SDA) to Input - PIN 13
    bsf TRISB, TRISB6           ; RB6 (SCL) to Input - PIN 11



    ; I2C - Configure MSSP module for Master Mode
    ;----- SSP1CON1 Bits -----------------------------------------------------
    ;SSPM3            EQU  H'0003'
    ;SSPEN            EQU  H'0005'

    ; Configure MSSP module for Master Mode
	;BANKSEL SSPCON
	;movlw B00101000 	; Enables MSSP and uses appropriate
                		; PORTC pins for I2C mode (SSPEN set) AND
                    	; Enables I2C Master Mode (SSPMx bits)


    BANKSEL SSP1CON1            ;                     76543210
    clrf SSP1CON1
    bsf SSP1CON1, SSPM3         ; Page 294 of the Specs = 1000 = I2C Master mode, clock = FOSC / (4 * (SSPxADD+1))(4)
    bsf SSP1CON1, SSPEN         ; 1 = Enables serial port and configures SCKx, SDOx, SDIx and SSx as the source of the serial port pins


    ;----- SSP1STAT Bits -----------------------------------------------------
    ;BF               EQU  H'0000'
    ;UA               EQU  H'0001'
    ;R_NOT_W          EQU  H'0002'
    ;S                EQU  H'0003'
    ;P                EQU  H'0004'
    ;D_NOT_A          EQU  H'0005'
    ;CKE              EQU  H'0006'
    ;SMP              EQU  H'0007'
    BANKSEL SSP1STAT
    bsf SSP1STAT, SMP           ; 1 = Input data sampled at end of data output time


    ; OK
    BANKSEL SSP1ADD             ; (16,000,000/(4*10000)) - 1 ... 39d = 27h
    movlw H'27'
    movwf SSP1ADD             ; FOSC FCY BRG Value FCLOCK (2 Rollovers of BRG)
                              ; 32 MHz 8 MHz 13h 400 kHz(1)
                              ; 32 MHz 8 MHz 19h 308 kHz
                              ; 32 MHz 8 MHz 4Fh 100 kHz
                              ; 16 MHz 4 MHz 09h 400 kHz(1)
                              ; 16 MHz 4 MHz 0Ch 308 kHz
                              ; 16 MHz 4 MHz 27h 100 kHz
                              ;  4 MHz 1 MHz 09h 100 kHz


    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_Init_RA0_RA1_For_Power

    ;bit 2-0 TRISA<2:0>: PORTA Tri-State Control bit
    ;1 = PORTA pin configured as an input (tri-stated)
    ;0 = PORTA pin configured as an output
    banksel TRISA
    bcf TRISA, TRISA0     ; intended for the 1st powered probe... this will not allow power to flow to the pinn

    banksel TRISA
    bcf TRISA, TRISA1     ; intended for the 1st powered probe... this will not allow power to flow to the pinn


    ; In order to obtain the effect of open-drain output, it is necessary to use the
    ; TRIS register bit to control the output rather than the more usual use of the
    ; data output register. This is most easily accomplished by leaving the appropriate
    ; bit of the data output register set to 0, and setting the corresponding TRIS bit to 0
    ; when the output should sink current, and 1 when the output should be in the open-drain
    ; (high-impedance) state.
    ;Clear, so when the pin goes low, it is made an output
    banksel PORTA
    bcf PORTA, RA0

    banksel PORTA
    bcf PORTA, RA1


    return
;*******************************************************************************


;*******************************************************************************
CALL_Open_A5_And_Drain_It

    ;bit 2-0 TRISA<2:0>: PORTA Tri-State Control bit
    ;1 = PORTA pin configured as an input (tri-stated)
    ;0 = PORTA pin configured as an output

    banksel TRISA
    bsf TRISA, TRISA5     ; configure as input

    ;The ANSELA register (Register 12-6) is used to
    ;configure the Input mode of an I/O pin to analog.
    ;Setting the appropriate ANSELA bit high will cause all
    ;digital reads on the pin to be read as ?0? and allow
    ;analog functions on the pin to operate correctly.

    ;The state of the ANSELA bits has no affect on digital
    ;output functions. A pin with TRIS clear and ANSEL set
    ;will still operate as a digital output, but the Input mode
    ;will be analog. This can cause unexpected behavior
    ;when executing read-modify-write instructions on the
    ;affected port


    banksel PORTA
    bcf PORTA, RA5

    return
;*******************************************************************************



;*******************************************************************************
CALL_Port_A_RA0_RA1_On

    ;banksel PORTA
    ;bsf PORTA, RA0     ; intended for the 1st powered probe

    ; the purpose of this is to turn on RA0 and RA1 - together
    movlw b'00000011'
    banksel PORTA
    iorwf PORTA, F

    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond

    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond
    call CALL_Wait_1_MilliSecond

    return
;*******************************************************************************



;*******************************************************************************
CALL_Port_A_RA0_RA1_Off

    ;banksel PORTA
    ;bcf PORTA, RA0     ; intended for the 1st powered probe

    ; the purpose of this is to turn off RA0 and RA1 - together
    movlw b'11111100'
    banksel PORTA
    andwf PORTA, F

    call CALL_Wait_1_MilliSecond

    return
;*******************************************************************************


;*******************************************************************************
CALL_Enable_UART

    ; enable UART RECEIVE
    BANKSEL PIE1            ; PERIPHERAL INTERRUPT ENABLE REGISTER 1
    bsf PIE1,RCIE

    BANKSEL PIE1
    bcf PIE1,TXIE


    return
;*******************************************************************************


;*******************************************************************************
CALL_Disable_UART

    ; Disable UART RECEIVE
    BANKSEL PIE1            ; PERIPHERAL INTERRUPT ENABLE REGISTER 1
    bcf PIE1,RCIE

    BANKSEL PIE1
    bcf PIE1,TXIE

    return
;*******************************************************************************


;*******************************************************************************
CALL_Peripheral_Interupt_Enable

    BANKSEL INTCON
    bsf INTCON,PEIE         ; Peripheral Interrupt Enable bit

    return
;*******************************************************************************


;*******************************************************************************
CALL_Peripheral_Interupt_Disable

    BANKSEL INTCON
    bcf INTCON,PEIE         ; Peripheral Interrupt Enable bit

    return
;*******************************************************************************


;*******************************************************************************
CALL_Disable_Global_Interrupt

    BANKSEL INTCON
    bcf INTCON,GIE

    return
;*******************************************************************************


;*******************************************************************************
CALL_Enable_Global_Interrupt

    BANKSEL INTCON
    bsf INTCON,GIE

    return
;*******************************************************************************


;*******************************************************************************
CALL_Clear_Ext_Interrupt_Flag

    BANKSEL INTCON
    bcf INTCON, INTF

    return
;*******************************************************************************


;*******************************************************************************
CALL_Enable_Change_On_Pin_RA5

    ;bit 3 IOCIE: Interrupt-on-Change Enable bit
    ;1 = Enables the interrupt-on-change
    ;0 = Disables the interrupt-on-change
    BANKSEL INTCON
    bsf INTCON,IOCIE

    ;bit 7-6 Unimplemented: Read as ?0?
    ;bit 5-0 IOCAN<5:0>: Interrupt-on-Change PORTA Negative Edge Enable bits
    ;1 = Interrupt-on-Change enabled on the pin for a negative going edge.
    ;   Associated Status bit and interrupt flag will be set upon detecting an edge.
    ;0 = Interrupt-on-Change disabled for the associated pin.
    BANKSEL IOCAN
    bsf IOCAN, IOCAN5

    BANKSEL IOCAN
    bsf IOCAN, IOCAP5


    return
;*******************************************************************************


;*******************************************************************************
CALL_Disable_Change_On_Pin_RA5

    ;bit 3 IOCIE: Interrupt-on-Change Enable bit
    ;1 = Enables the interrupt-on-change
    ;0 = Disables the interrupt-on-change
    BANKSEL INTCON
    bcf INTCON,IOCIE


    ;bit 7-6 Unimplemented: Read as ?0?
    ;bit 5-0 IOCAN<5:0>: Interrupt-on-Change PORTA Negative Edge Enable bits
    ;1 = Interrupt-on-Change enabled on the pin for a negative going edge.
    ;   Associated Status bit and interrupt flag will be set upon detecting an edge.
    ;0 = Interrupt-on-Change disabled for the associated pin.
    BANKSEL IOCAN
    bcf IOCAN, IOCAN5

    BANKSEL IOCAN
    bcf IOCAN, IOCAP5


    return
;*******************************************************************************


;*******************************************************************************
CALL_Clear_PORT_A_To_Reset_Latch

    ; quickly clear the LATCH so it does not trigger another interrupt
    BANKSEL PORTA
    movf PORTA, F

    return
;*******************************************************************************



;*******************************************************************************
CALL_Clear_RA5_Interrupt_Flags

    BANKSEL IOCAF
    bcf IOCAF, IOCAF5

    return
;*******************************************************************************



;*******************************************************************************
CALL_Initialize_Port_A

    ; Note: It is recommended that when initializing the port, the data latch (PORT register)
    ; should be initialized first, and then the data direction (TRIS register). This will eliminate
    ; a possible pin glitch, since the PORT data latch values power up in a random state.

    ;Init PORTA
    BANKSEL PORTA
    CLRF PORTA

    ;Data Latch
    BANKSEL LATA
    CLRF LATA

    ;bit 7-6 Unimplemented: Read as ?0?
    ;bit 5-0 IOCAN<5:0>: Interrupt-on-Change PORTA Negative Edge Enable bits
    ;1 = Interrupt-on-Change enabled on the pin for a negative going edge.
    ;   Associated Status bit and interrupt flag will be set upon detecting an edge.
    ;0 = Interrupt-on-Change disabled for the associated pin.
    ; turn this off for everything....!
    BANKSEL IOCAN
    CLRF IOCAN


    return
;*******************************************************************************


;*******************************************************************************
CALL_Init_RA5_For_Wake


    ;Four of PORTB?s pins, RB7:RB4, have an interrupt on change feature. Only pins configured as
    ;inputs can cause this interrupt to occur (i.e. any RB7:RB4 pin configured as an output is excluded
    ;from the interrupt on change comparison). The input pins (of RB7:RB4) are compared with the
    ;old value latched on the last read of PORTB. The ?mismatch? outputs of RB7:RB4 are OR?ed
    ;together to generate the RB Port Change Interrupt with flag bit RBIF (INTCON<0>).
    ;This interrupt can wake the device from SLEEP. The user, in the interrupt service routine, can
    ;clear the interrupt in the following manner:
        ;a) Any read or write of PORTB. This will end the mismatch condition.
        ;b) Clear flag bit RBIF.
    ;A mismatch condition will continue to set flag bit RBIF. Reading PORTB will end the mismatch
    ;condition, and allow flag bit RBIF to be cleared.
    ;This interrupt on mismatch feature, together with software configurable pull-ups on these four
    ;pins allow easy interface to a keypad and make it possible for wake-up on key-depression.
    ;The interrupt on change feature is recommended for wake-up on key depression and operations
    ;where PORTB is only used for the interrupt on change feature. Polling of PORTB is not recommended
    ;while using the interrupt on change feature.


    ;TIP #4 Use High-Value Pull-Up Resistors
    ;It is more power efficient to use larger pull-up resistors on I/O pins such as MCLR, I2C?
    ;signals, switches and for resistor dividers. 
    ; For example, a typical I2C pull-up is 4.7k. However,when the I2C is transmitting and pulling a line
    ;low, this consumes nearly 700 uA of current for each bus at 3.3V. By increasing the size of the
    ;I2C pull-ups to 10k, this current can be halved.  The tradeoff is a lower maximum I2C bus
    ;speed, but this can be a worthwhile trade in for many low power applications. This technique is
    ;especially useful in cases where the pull-up can be increased to a very high resistance such as
    ;100k or 1M.



    ;
    ; Only pins configured as inputs can cause this interrupt to occur
    ; (i.e. any RB7:RB4 pin configured as an output is excluded from the interrupt on change comparison).
    ; The input pins (of RB7:RB4) are compared with the old value latched on the last read of PORTB.
    ; The ?mismatch? outputs of RB7:RB4 are OR?ed together to generate the RB Port Change Interrupt
    ; with flag bit RBIF (INTCON<0>).

    ;
    ; bit 2-0 TRISA<2:0>: PORTA Tri-State Control bit
    ; 1 = PORTA pin configured as an input (tri-stated)
    ; 0 = PORTA pin configured as an output
    banksel TRISA
    bsf TRISA, TRISA5       ; input


    ;
    ; bit 2-0 ANSA<2:0>: Analog Select between Analog or Digital Function on pins RA<2:0>, respectively
    ; 0 = Digital I/O. Pin is assigned to port or digital special function.
    ; 1 = Analog input. Pin is assigned as analog input(1). Digital input buffer disabled.
    ; banksel ANSELA
    ;bsf ANSELA, ANSA5 ;<- does not exist for PIN 5

    ; bit 5-0 INLVLA<5:0>: PORTA Input Level Select bits
    ; For RA<5:0> pins, respectively
    ; 1 = ST input used for port reads and interrupt-on-change
    ; 0 = TTL input used for port reads and interrupt-on-change

    banksel INLVLA
    bcf INLVLA, INLVLA5


    return
;*******************************************************************************



;*******************************************************************************
CALL_Setup_Interrupts

    ;RCIF interrupts are enabled by setting all of the following bits:
    ;? RCIE interrupt enable bit of the PIE1 register
    ;? PEIE Peripheral Interrupt Enable bit of the INTCON register
    ;? GIE Global Interrupt Enable bit of the INTCON register
    ;The RCIF interrupt flag bit will be set when there is an
    ;unread character in the FIFO, regardless of the state of
    ;interrupt enable bits.

    ; enable interupts in general
    BANKSEL INTCON
    bsf INTCON,GIE

    ; this makes sure all of the peripherals are cleared
    BANKSEL PIE1
    clrf PIE1

    BANKSEL PIE2
    clrf PIE2

    BANKSEL PIE3
    clrf PIE3

    BANKSEL PIE4
    clrf PIE4

    return
;*******************************************************************************


;*******************************************************************************
PROCESS_INTERRUPT

    clrw

    BANKSEL cUART_Input
    clrf cUART_Input               ; clears the buffer as well

    BANKSEL cUART_Interrupt_Flag
    clrf cUART_Interrupt_Flag

    ;***************************************************************************
    ; Let's see if something came in from the UART


    ; if this interupt was generated because we sent something out, get out.
    BANKSEL PIR1
    btfss PIR1, TXIF                ; is something waiting for us?
    goto LABEL_INTERUPT_RCIF

    ; just deal with it and move on
    BANKSEL PIR1
    bcf PIR1, TXIF


LABEL_INTERUPT_RCIF
    ; did something arrive???
    BANKSEL PIR1
    btfss PIR1, RCIF                ; is something waiting for us?
    goto LABEL_INTERUPT_CLEAR_SLEEP

    BANKSEL PIR1
    bcf PIR1, RCIF

    BANKSEL RCREG
    movf RCREG, W                   ; take whats in Receive Buffer and put in W

    ; clear the register
    BANKSEL RCREG
    clrf RCREG


    BANKSEL cUART_Input
    movwf cUART_Input               ; Put The Char where we Want it

    BANKSEL cUART_Input
    movf cUART_Input, W             ; puts contents back into W
    sublw "D"                       ; does W have D in it?

    BANKSEL STATUS
    btfss STATUS,Z	;check if the same
    goto LABEL_INTERUPT_CLEAR_SLEEP

    BANKSEL cUART_Interrupt_Flag
    bsf cUART_Interrupt_Flag, UART_INTERUPT_FLAG_TEMPS

    nop

    ;***************************************************************************
    ; Did we get a wake from sleep?
LABEL_INTERUPT_CLEAR_SLEEP

    ; interupt
    ;BANKSEL IOCAF
    ;bcf IOCAF, IOCAF4

    ; this will only happen right after SLEEP.
    ; It is cleared before Interrupts are enabled.
    ;BANKSEL IOCAF
    ;bcf IOCAF, IOCAF5

    ; just in case this pending
    BANKSEL PIR1
    clrf PIR1

    nop

    ; clear external INT flag
    BANKSEL INTCON
    bcf INTCON, INTF	

    nop


    retfie
;*******************************************************************************


 END


