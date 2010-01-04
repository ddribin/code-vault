                PAGE    78,132
                TITLE   GRAPH   Dave Dribin     April 12, 1993

COMMENT         *
                This program will demonstrate some of the graphics routines
                in VGA mode.
                *

                INCLUDE MACROS.ASM

STKSEG          SEGMENT STACK                   ; *** STACK SEGMENT ***
                DB      256 DUP('STACK   ')
STKSEG          ENDS

CSEG            SEGMENT PUBLIC                  ; *** CODE SEGMENT ***
                ASSUME  CS:CSEG, DS:CSEG, SS:STKSEG, ES:NOTHING

MAIN            PROC    FAR
                MOV     AX, CS
                MOV     DS, AX
                CALL    SETVGA
                CALL    TESTVGA
NOKEY:          MOV     AH, 1
                INT     16h
                JZ      NOKEY
                CALL    SETTEXT
                DOSXIT
MAIN            ENDP

;
; NAME              PIXELADDR
;
; FUNCTION          COMPUTES THE PIXEL ADDRESS FOR NATIVE EGA AND VGA MODES
;                   USES FORMULA:
;                             BYTES PER ROW = HORIZONTAL RESOLUTION
;                             NUMBER OF ROW = VERTICAL RESOLUTION
;                             OFFSET = (BYTES PER ROW) * Y + INT(X/8)
;                             BIT # = 7 - (X MOD 8)
;
; INPUTS            AX = Y-COORDINATE
;                   BX = X-COORDINATE
;
; RETURNS           AH = BIT MASK
;                   BX = BYTE OFFSET IN BUFFER
;                   CL = NUMBER OF BITS TO SHIFT LEFT
;                   ES = VIDEO BUFFER SEGMENT

BYTESPERROW     EQU     80
VIDEORAM        EQU     0A000h

                PUBLIC  PIXELADDR
PIXELADDR       PROC    NEAR
                MOV     CL, BL          ; CL = LOW-BYTE OF X COORD
                PUSH    DX              ; SAVE DX
                MOV     DX, BYTESPERROW ; AX = Y * BYTES PER ROW
                MUL     DX
                POP     DX
                SHR     BX, 1           ; BX = X/8
                SHR     BX, 1
                SHR     BX, 1
                ADD     BX, AX          ; BX = OFFSET
                MOV     AX, VIDEORAM
                MOV     ES, AX
                AND     CL, 7           ; CL = X MOD 8
                XOR     CL, 7           ; CL = 7 - (X MOD 8)
                MOV     AH, 1
                RET
PIXELADDR       ENDP

;
; NAME              BYTEADDR
;
; FUNCTION          COMPUTES THE ADDRESS FOR NATIVE EGA AND VGA MODES
;                   USES FORMULA:
;                             BYTES PER ROW = HORIZONTAL RESOLUTION
;                             NUMBER OF ROW = VERTICAL RESOLUTION
;                             OFFSET = (BYTES PER ROW) * Y + BYTENUM
;                             BIT # = 7 - (X MOD 8)
;
; INPUTS            AX = Y-COORDINATE
;                   BX = BYTE NUMBER TO SET
;
; RETURNS           BX = BYTE OFFSET IN BUFFER
;                   ES = VIDEO BUFFER SEGMENT

BYTESPERROW     EQU     80
VIDEORAM        EQU     0A000h

                PUBLIC  BYTEADDR
BYTEADDR        PROC    NEAR
                PUSH    AX
                PUSH    DX              ; SAVE DX
                MOV     DX, BYTESPERROW ; AX = Y * BYTES PER ROW
                MUL     DX
                POP     DX
                ADD     BX, AX          ; BX = Y * B.P.R + BYTE NUMBER
                MOV     AX, VIDEORAM
                MOV     ES, AX
                POP     AX
                RET
BYTEADDR        ENDP

;
; NAME          SETVGAPIXEL
;
; FUNCTION      SETS A PIXEL IN THE VGA SCREEN BUFFER
;
; INPUTS        AX = Y-COORDINATE
;               BX = X-COORDINATE
;               DL = PIXEL VALUE (COLOR)
;
; RETURNS       NONE

SETVGAPIXEL     PROC    NEAR
                PUSHM   <AX, BX, CX, DX, ES>
                PUSH    DX                      ; SAVE PIXEL VALUE
                CALL    PIXELADDR               ; GET PIXEL ADDRESS
                MOV     DX, 3CEh                ; PORT ADDRESS OF VGA REGS
                SHL     AH, CL                  ; SET BIT MASK TO PROPER SPOT
                MOV     AL, 8
                OUT     DX, AX
                MOV     AX, 205h
                OUT     DX, AX
                MOV     AH, 18h
                MOV     AL, 3
                OUT     DX, AX
                MOV     AL, ES:[BX]
                POP     AX
                MOV     ES:[BX], AL
                MOV     AX, 0FF08h
                OUT     DX, AX
                MOV     AX, 0005
                OUT     DX, AX
                MOV     AX, 0003
                OUT     DX, AX
                POPM    <ES, DX, CX, BX, AX>
                RET
SETVGAPIXEL     ENDP

;
; NAME          SETVGABYTE
;
; FUNCTION      SETS A BYTE IN THE VGA SCREEN BUFFER
;
; INPUTS        AX = Y-COORDINATE
;               BX = BYTE NUMBER
;               DL = PIXEL VALUE (COLOR)
;               DH = BITMASK
;
; RETURNS       NONE

                PUBLIC  SETVGABYTE
SETVGABYTE      PROC    NEAR
                PUSHM   <AX, BX, CX, DX, ES>
                PUSH    DX                      ; SAVE PIXEL VALUE
                CALL    BYTEADDR                ; GET PIXEL ADDRESS
                MOV     DX, 3CEh                ; PORT ADDRESS OF VGA REGS
                POP     AX                      ; GET BYTE NUMBER IN AH
                PUSH    AX
                MOV     AL, 8                   ; SET BIT MASK REGISTER
                OUT     DX, AX
                MOV     AX, 205h                ; SET TO WRITE MODE 2
                OUT     DX, AX
                MOV     AH, 18h                 ; USE XOR
                MOV     AL, 3
                OUT     DX, AX
                MOV     AL, ES:[BX]             ; LATCH CURRENT VALUES
                POP     AX
                MOV     ES:[BX], AL             ; REPLACE PIXEL VALUES
                MOV     AX, 0FF08h              ; SET BIT MASK TO DEFAULT
                OUT     DX, AX
                MOV     AX, 0005                ; SET READ/WRITE MODE DEFAULT
                OUT     DX, AX
                MOV     AX, 0003                ; SET ROTATE/FUNCTION DEFAULT
                OUT     DX, AX
                POPM    <ES, DX, CX, BX, AX>
                RET
SETVGABYTE      ENDP

TESTVGA         PROC    NEAR
                PUSHM   <AX, BX, CX, DX>
                MOV     CX, 40
                MOV     BX, 0
                MOV     AX, 0
                MOV     DH, 0FFh
LP1:            MOV     DL, CL
                CALL    SETVGABYTE
                INC     BX
                CALL    SETVGABYTE
                INC     BX
                LOOP    LP1
                POPM    <DX, CX, BX, AX>
                RET
TESTVGA         ENDP




;
; NAME              SETVGA
;
; FUNCTION          STARTS UP VGA GRAPHICS MODE IN 640x480x16 MODE.
;
; INPUTS            NONE
;
; RETURNS           NONE

SETVGA          PROC    NEAR
                PUSH    AX                      ; SAVE AX
                MOV     AH, 0                   ; SELECT VIDEO MODE FUNCTION
                MOV     AL, 12h                 ; VGA 640x480x16 MODE
                INT     10h
                POP     AX
                RET
SETVGA          ENDP

;
; NAME          SETTEXT
;
; FUNCTION      SET THE VIDEO TO TEXT MODE
;
; INPUTS        NONE
;
; RETURNS       NONE
SETTEXT         PROC    NEAR
                PUSH    AX                      ; SAVE AX
                MOV     AH, 0                   ; SELECT VIDEO MODE FUNCTION
                MOV     AL, 2                   ; 80x25x16 TEXT MODE
                INT     10h
                POP     AX
                RET
SETTEXT         ENDP

CSEG            ENDS
                END     MAIN

PIXELADDR PROC      NEAR
