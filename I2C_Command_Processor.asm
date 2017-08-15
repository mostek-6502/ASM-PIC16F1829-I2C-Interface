;
; Author: Rick Faszold
;
; Date: September 16th, 2014
;
; In order avoid over filling Bank 0, this section was broken out in order to allow the linker to place
; this code in a different Bank, if needed.
;

 list p=16f1829       ; set processor type
#include <C:\Program Files (x86)\Microchip\MPLABX\mpasmx\p16f1829.inc>
#include "system_defines.inc"

    errorlevel -302        ; supress these error messages

    GLOBAL CALL_g_I2C_Command_Processor

    EXTERN g_CP_iI2C_Error_Flag
    EXTERN g_CP_iI2C_ReadByte
    EXTERN g_CP_iI2C_Chip_Address


; internal vars
INIT_VARS UDATA
iI2C_CP_Command                             RES     1
iI2C_MSSP_Counter                           RES     1
iI2C_WriteByte                              RES     1

    CODE

;*******************************************************************************


;*******************************************************************************
CALL_g_I2C_Command_Processor

    nop

LABEL_CP_Get_Next_Command

    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iI2C_CP_Command
    movwf iI2C_CP_Command


LABEL_CP_CMD_START

    movlw CMD_START

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z                 ; run the command if Zero flag is set
    goto LABEL_CP_CMD_AD_0

    call CALL_I2C_Start
    goto LABEL_CP_Get_Next_Command

LABEL_CP_CMD_AD_0

    movlw CMD_AD_0

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z                 ; run the command if Zero flag is set
    goto LABEL_CP_CMD_AD_1

    BANKSEL g_CP_iI2C_Chip_Address
    bcf g_CP_iI2C_Chip_Address, 0        ; setup for read command
    movf g_CP_iI2C_Chip_Address, W

    BANKSEL iI2C_WriteByte
    movwf iI2C_WriteByte

    call CALL_I2C_Write_Byte
    goto LABEL_CP_Get_Next_Command


LABEL_CP_CMD_AD_1

    movlw CMD_AD_1

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z             ; run the command if Zero flag is set
    goto LABEL_CP_CMD_RESTART

    BANKSEL g_CP_iI2C_Chip_Address
    bsf g_CP_iI2C_Chip_Address, 0
    movf g_CP_iI2C_Chip_Address, W

    BANKSEL iI2C_WriteByte
    movwf iI2C_WriteByte

    call CALL_I2C_Write_Byte
    goto LABEL_CP_Get_Next_Command


LABEL_CP_CMD_RESTART

    movlw CMD_RESTART

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z             ; run the command if Zero flag is set
    goto LABEL_CP_CMD_ACK

    call CALL_I2C_Send_ReStart
    goto LABEL_CP_Get_Next_Command


LABEL_CP_CMD_ACK

    movlw CMD_ACK

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z             ; run the command if Zero flag is set
    goto LABEL_CP_CMD_NACK

    call CALL_I2C_Acknowledge
    goto LABEL_CP_Get_Next_Command


LABEL_CP_CMD_NACK

    movlw CMD_NACK

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z             ; run the command if Zero flag is set
    goto LABEL_CP_CMD_COMMAND

    call CALL_I2C_NACK
    goto LABEL_CP_Get_Next_Command

LABEL_CP_CMD_COMMAND

    ; this is a two piece command...
    ; we tell the processor that this is a special command
    ; the actual command follows this
    movlw CMD_COMMAND

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z             ; run the command if Zero flag is set
    goto LABEL_CP_CMD_READ_BYTE

    ; actual command here
    BANKSEL FSR1
    moviw FSR1++

    BANKSEL iI2C_WriteByte
    movwf iI2C_WriteByte

    call CALL_I2C_Write_Byte
    goto LABEL_CP_Get_Next_Command


LABEL_CP_CMD_READ_BYTE

    movlw CMD_READ_BYTE

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z             ; run the command if Zero flag is set
    goto LABEL_CP_CMD_STOP

    call CALL_I2C_Read_Byte
    goto LABEL_CP_Get_Next_Command



LABEL_CP_CMD_STOP

    movlw CMD_STOP

    BANKSEL iI2C_CP_Command
    subwf iI2C_CP_Command, W

    BANKSEL STATUS
    btfss STATUS, Z  ; if the Z flag is set, get out, we are good
    goto LABEL_Command_Processor_Error

    call CALL_I2C_Stop
    goto LABEL_Command_Processor_Exit

LABEL_Command_Processor_Error

    BANKSEL g_CP_iI2C_Error_Flag
    bsf g_CP_iI2C_Error_Flag, ERROR_FLAG_INVALID_COMMAND

LABEL_Command_Processor_Exit

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Start

; This generates a Start Condition.
; If the Condition Fails...
; It'll issue a Stop and then it'll try to issue a Start again

    BANKSEL SSP1CON2
    bsf SSP1CON2, SEN               ; START Condition

    call CALL_I2C_Wait_MSSP         ; btfss PIR1, SSP1IF

    nop

    ; we issue the start commend...
    ; we wait...
    ; did we set an error flag in the wait command???
    ; if not, we are OK, get out
    ; if so, issue a STOP command... to try to clear tuff up
    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F     ; move it to itself and test the flag

    BANKSEL STATUS
    btfsc STATUS, Z  ; if the Z flag is set, get out, we are good
    goto LABEL_I2C_Start_Exit


    ; clear the flag, try again
    BANKSEL g_CP_iI2C_Error_Flag
    clrf g_CP_iI2C_Error_Flag


    ; issue the stop
    BANKSEL SSP1CON2
    bsf SSP1CON2,PEN                    ; Send STOP condition

    call CALL_I2C_Wait_MSSP


    ; we have to execute these anyway, so let's drop the error checking
    nop
    nop
    nop

    ; re-issue the start....
    BANKSEL SSP1CON2
    bsf SSP1CON2, SEN               ; START Condition

    call CALL_I2C_Wait_MSSP         ; btfss PIR1, SSP1IF


LABEL_I2C_Start_Exit

    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Acknowledge

    ; this simply means that if there is an error to skip this entire toutine
    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_Acknowledge_Exit


    ; now, start the fun stuff - this is just a check and does not need a wait
    BANKSEL SSP1CON2
    btfss SSP1CON2, ACKSTAT  ; 0 = Good, 1 = BAD
    goto LABEL_I2C_Acknowledge_Exit    ; go to the next command

    BANKSEL g_CP_iI2C_Error_Flag
    bsf g_CP_iI2C_Error_Flag, ERROR_FLAG_ACKNOWLEDGEMENT

LABEL_I2C_Acknowledge_Exit

    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Write_Byte

    ; this simply means that if there is an error to skip this entire toutine
    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_Send_Byte_Exit

    BANKSEL iI2C_WriteByte
    movf iI2C_WriteByte, W

    BANKSEL SSP1BUF
    movwf SSP1BUF              ; Get value to send put in SSPBUF

    call CALL_I2C_Wait_MSSP         ; btfss PIR1, SSP1IF

LABEL_I2C_Send_Byte_Exit

    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Send_ReStart

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_Send_ReStart_Exit


	BANKSEL SSP1CON2
    bsf SSP1CON2, RSEN

    call CALL_I2C_Wait_MSSP

LABEL_I2C_Send_ReStart_Exit

    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Read_Byte

    BANKSEL g_CP_iI2C_ReadByte
    clrf g_CP_iI2C_ReadByte

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_Receive_Byte_Exit


    BANKSEL SSP1CON2
    bsf SSP1CON2, RCEN   ; initiate receive

    call CALL_I2C_Wait_MSSP         ; btfss PIR1, SSP1IF


    ; check the flag again because we are doing more commands!!!
    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_Receive_Byte_Exit


    ; we issued the read command, we waited for MSSP to complete, we acked it... read the byte!
    BANKSEL SSP1BUF
    movf SSP1BUF, W             ; Get value to send put in SSPBUF

    BANKSEL g_CP_iI2C_ReadByte
    movwf g_CP_iI2C_ReadByte

LABEL_I2C_Receive_Byte_Exit

    nop

    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_NACK

    BANKSEL g_CP_iI2C_Error_Flag
    movf g_CP_iI2C_Error_Flag, F

    BANKSEL STATUS
    btfss STATUS, Z
    goto LABEL_I2C_NACK_Exit


    BANKSEL SSPCON2 ; select SFR
    bsf SSPCON2, ACKDT ; set ack bit
    bsf SSPCON2, ACKEN ; initiate ack    // nack

    call CALL_I2C_Wait_MSSP


LABEL_I2C_NACK_Exit

    return
;*******************************************************************************




;*******************************************************************************
CALL_I2C_Stop

    ; we ALWAYS call the STOP condition if we get this far.

    BANKSEL SSP1CON2
    bsf SSP1CON2,PEN                    ; Send STOP condition

    call CALL_I2C_Wait_MSSP


    return
;*******************************************************************************



;*******************************************************************************
CALL_I2C_Wait_MSSP

    ; This routine waits for the last I2C operation to complete.
    ; It does this by polling the SSPIF flag in PIR1.

    BANKSEL iI2C_MSSP_Counter
    clrf iI2C_MSSP_Counter


LABEL_I2C_Wait_MSSP_Try_Again

        BANKSEL iI2C_MSSP_Counter
        incf iI2C_MSSP_Counter, f

        BANKSEL STATUS
        btfss STATUS, Z
        goto LABEL_I2C_Wait_MSSP_Check_PIR1         ; 0 flag not set, test PIR1

        BANKSEL g_CP_iI2C_Error_Flag
        bsf g_CP_iI2C_Error_Flag, ERROR_FLAG_WAIT_MSSP
        goto LABEL_I2C_Wait_MSSP_Exit

LABEL_I2C_Wait_MSSP_Check_PIR1
        BANKSEL PIR1
        btfss PIR1, SSP1IF                       ; Check if I2C operation done
        goto LABEL_I2C_Wait_MSSP_Try_Again       ; I2C module is not ready yet

        ; clear it, we are good...
        BANKSEL PIR1              ; CLEAR IT
        bcf PIR1, SSP1IF          ; Check if I2C operation done

LABEL_I2C_Wait_MSSP_Exit

    ; used to test to see how h igh the iI2C_MSSP_Counter is going...
    BANKSEL iI2C_MSSP_Counter
    nop

    return
;*******************************************************************************



;*******************************************************************************

    END
