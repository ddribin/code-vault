	PAGE	78,132
	TITLE	MP1	Dave Dribin	Feb. 4, 1993
; This program does a very simple search on a permanent set of data
; by using conditional loops, jumps, and compares.  It accepts to characters
; of input, the first used for the country name, and the second used for
; the type of exchange rate.

	CR	EQU	0Dh
	LF	EQU	0Ah
	BEL	EQU	07h
	ESCKEY	EQU	1Bh
        RECLEN  EQU     27

	EXTRN	KBDIN:NEAR, DSPOUT:NEAR, DSPMSG:NEAR, DOSXIT:NEAR

STKSEG	SEGMENT STACK			; *** STACK SEGMENT ***
 	DB	128 DUP ( ? )
STKSEG  ENDS

CSEG	SEGMENT PUBLIC			; *** CODE SEGMENT ***
        ASSUME  CS:CSEG, DS:CSEG, SS:STKSEG, ES:NOTHING
NAMLST	DB	'F Britain (Pound)     1.55','$'
	DB	'D Britain (Pound)     0.65','$'
	DB	'F China (Yuan)        .174','$'
	DB	'D China (Yuan)        5.74','$'
	DB	'F Germany (Mark)      .622','$'
	DB	'D Germany (Mark)      1.61','$'
	DB	'F Hong Kong (Dollar)  .129','$'
	DB	'D Hong Kong (Dollar)  7.74','$'
	DB	'F India (Rupee)       .035','$'
LASTNAM	DB	'D India (Rupee)       28.9','$'
HLPMSG  DB      'Machine Problem 1 -- Mini-Search',CR,LF,CR,LF
        DB      'Type two characters.  The first character will select the',CR,LF
        DB      'country to print.  Valid countries are Britain, China,',CR,LF
        DB      'Germany, Hong Kong, and India.  The second character will',CR,LF
        DB      'select foreign or dollar currency, F or D.  A "*" can be',CR,LF
        DB      'used as a wild card for either character.',CR,LF,CR,LF
        DB      'Type "?" for this message again, or ESC to quit.',CR,LF,CR,LF,'$'
PROMPT  DB      '!','$'
NOREC   DB      'NO RECORDS FOUND',CR,LF,'$'
XITMSG  DB      CR,LF,'MP1: Exit to DOS','$'
CRLF    DB      CR,LF,'$'
MATCH   DB      ?

MAIN    PROC    FAR
	MOV	AX, CSEG		; INITIALIZE DS REGISTER
	MOV	DS, AX
        LEA     DX, HLPMSG              ; DX = ADDRESS OF HLPMSG
	CALL	DSPMSG			; DISPLAY IT
TOPLP:  LEA     DX, PROMPT              ; PROMPT FOR LETTER COMMAND
	CALL	DSPMSG
        CALL    INECHO                  ; GET KBD CHAR IN AL
	CMP	AL, ESCKEY		; EXIT ON ESC CHAR
        JE      MP1XIT
        CMP     AL, '?'                 ; PRINT HELP MSG IF '?'
        JE      PRHELP
        MOV     AH, AL                  ; STORE CHAR IN AH FOR LATER USE
        CALL    INECHO                  ; GET SECOND CHAR FROM KBD
        CMP     AL, ESCKEY              ; EXIT ON ESC CHAR
        JE      MP1XIT
        CMP     AL, '?'                 ; PRINT HELP MSG IF '?'
        JE      PRHELP

        LEA     DX, CRLF
        CALL    DSPMSG
        JMP     PRLP                    ; JUMP TO PRINT LOOP

PRHELP: LEA     DX, CRLF
        CALL    DSPMSG
        LEA     DX, HLPMSG
        CALL    DSPMSG
        JMP     TOPLP

PRLP:   LEA     BX, NAMLST              ; PUT FIRST RECORD IN BX
        MOV     MATCH, 0                ; NO MATHCHES
PRLP1:  CMP     BX, OFFSET LASTNAM      ; CHECK TO SEE IF WE ARE DONE
        JA      PRXIT
        CMP     AL, '*'                 ; CHECK THE CURRENCY TYPE
        JE      CHCTRY                  ;  IF A MATCH CONTINUE
        CMP     AL, [BX]
        JNE     PRINC                   ; ELSE GOTO NEXT RECORD
CHCTRY: CMP     AH, '*'                 ; CHECK THE COUNTRY
        JE      DSPREC                  ;  IF A MATCH, PRINT IT
        CMP     AH, [BX] + 2
        JNE     PRINC                   ; ELSE GOTO NEXT RECORD
DSPREC: MOV     DX, BX                  ; SET UP FOR DSPMSG
        ADD     DX, 2                   ;   AND SKIP OVER FIRST TWO CHARS
        CALL    DSPMSG
        LEA     DX, CRLF
        CALL    DSPMSG
        MOV     MATCH, 1                ; SET MATCH FLAG
PRINC:  ADD     BX, RECLEN              ; INCREMENT POINTER
        JMP     PRLP1                   ;   IF NOT GET NEXT
PRXIT:  LEA     DX, MATCH
        CMP     MATCH, 0                ; IF NO MATCHES, PRINT SO
        JNE     PRXIT1
        LEA     DX, NOREC
        CALL    DSPMSG
PRXIT1: JMP     TOPLP

MP1XIT: MOV     DX, OFFSET XITMSG       ; TYPE OUT EXIT MESSAGE
	CALL	DSPMSG
	CALL	DOSXIT			; EXIT TO DOS
MAIN	ENDP

; INECHO SUBROUTINE: GETS ONE CHARACTER FROM KEYBOARD AND ECHOES IT
;       INPUTS -- NONE
;       OUTPUT -- AL HAS THE CHARACTER

INECHO  PROC    NEAR
        PUSH    DX                      ; SAVE DX
        CALL    KBDIN                   ; FETCH ON CHAR FROM KBD
        MOV     DL, AL
        CALL    DSPOUT                  ;  AND ECHO IT ON DSP
        CMP     AL, CR                  ; ON CR, ECHO BOTH CR AND LF
        JNE     INEXIT
        MOV     DL, LF
        CALL    DSPOUT
INEXIT: POP     DX
        RET
INECHO  ENDP

CSEG    ENDS
	END	MAIN
