	PAGE	78,132
        TITLE   MP4         Dave Dribin         March 4, 1993

COMMENT  *
        Copy this program to the D: drive and call it MP4.ASM.  Also 
        copy  MP4MAIN.C to the D: drive.  This file is the minimal 
        MP4.ASM required for the command  "cc  mp4  mp4main" to work.   
        This version of MP4.ASM declares the three global variables, 
        which are necessary for the library subroutines. 
        *

	PUBLIC	SAVOFF, SAVSEG, _TICKS

CSEG	SEGMENT PUBLIC			; *** CODE SEGMENT ***
        ASSUME  CS:CSEG, DS:CSEG

SAVOFF	DW	?			; OFFSET FOR INT 1Ch VECTOR
SAVSEG	DW	?			; SEGMENT FOR INT 1Ch
_TICKS	DW	0			; NUMBER OF CLOCK TICKS

COMMENT *
	Put the _INIT, _CLRSCR, _DISPLAY, _WTTIME, _SCROLL, _CHKBOT,
	and _RESTORE subroutines here.
	Make the 7 subroutines type FAR and their names PUBLIC.
	*

EXTRN   RSAVE:NEAR, RREST:NEAR, KBDIN:NEAR
PUBLIC  _INIT, _CLRSCR, _DISPLAY, _WTTIME
PUBLIC  _SCROLL, _CHKBOT, _RESTORE

; CONSTANT DEFINITIONS
SPACE   EQU     20h                     ; ASCII SPACE
SECOND  EQU     182                     ; HOW MANY TICKS PER SECOND
TIMEOUT EQU     (SECOND*1)              ; TIME OUT AFTER A SECOND
ESCKEY  EQU     1Bh                     ; ASCII ESC
AXTEMP  EQU     16                      ; WHERE AX IS SAVED ON STACK

; _INIT SUBROUTINE -- INITIALIZES THE INTERRUPT VECTOR 1Ch TO OUR FUNCTION
;       TIME.  IT ALSO SAVE THE OLD VECTOR, SO WE CAN RESTORE IT LATER.
;
;       INPUTS -- NONE
;       OUTPUT -- NONE
VEC1C   EQU     70h                     ; VECTOR FOR 1Ch(4*1Ch=70h)
_INIT   PROC    FAR
        CLI                             ; BLOCK INTERRUPTS
        CALL    RSAVE
        MOV     AX, CS                  ; SET CS = DS
        MOV     DS, AX
        MOV     AX, 0                   ; MAKE ES = 0000h
        MOV     ES, AX
        MOV     AX, ES:VEC1C            ; SAVE OLD VECTOR OFFSET
        MOV     SAVOFF, AX
        MOV     AX, ES:VEC1C+2          ; SAVE OLD VECTOR SEGMENT
        MOV     SAVSEG, AX
        LEA     AX, TIME                ; LOAD NEW OFFSET
        MOV     ES:VEC1C, AX
        MOV     AX, CS                  ; LOAD NEW SEGMENT
        MOV     ES:VEC1C+2, AX
        STI                             ; ENABLE INTERRUPTS
        CALL    RREST
        RET
_INIT   ENDP

; TIME SUBROUTINE -- INTERRUPT SERVICE ROUTINE INVOKED BY INTERRUPT 1Ch.
;
;       INPUTS -- NONE
;       OUTPUT -- NONE
TIME    PROC    FAR
        ADD     CS:_TICKS, 10           ; INCREMENT GLOBALE C VARIABLE TICKS
        IRET
TIME    ENDP

; _CLRSCR SUBROUTINE -- CLEARS THE SCREEN AND SETS THE BACKGOUND COLOR
;       TO RED AND FOREGROUND COLOR TO YELLOW.  THE CURSOR IS PUT IN
;       THE UPPER LEFT CORNER.
;
;       INPUTS -- NONE
;       OUTPUT -- NONE
_CLRSCR PROC    FAR
        CALL    RSAVE
        MOV     AX, CS                  ; MAKE CS = DS
        MOV     DS, AX
        MOV     DL, 79                  ; RIGHT COLUMN = 80
        MOV     DH, 24                  ; BOTTOM ROW = 25 LINES
        MOV     CL, 0                   ; LEFT COLUMN = 0
        MOV     CH, 0                   ; TOP COLUMN = 0
        MOV     BH, 01001110b           ; SET BG=RED, FG=YELLOW, NO BLINKING
        MOV     AL, 0                   ; CLEAR ENTIRE WINDOW, I.E. SCREEN
        MOV     AH, 07h                 ; SET COMMAND TO SCROLL DOWN LINES
        INT     10h                     ; DO BIOS INTERRUPT 10h
        MOV     DL, 0                   ; SET CURSOR POSITION COLUMN 0
        MOV     DH, 0                   ;  AND ROW 0
        MOV     BH, 0                   ; ON CURRENT SCREEN
        MOV     AH, 2                   ; SET CURSOR POSITION COMMAND
        INT     10h                     ; EXECUTE BIOS AGAIN
        CALL    RREST
        RET
_CLRSCR ENDP


; W. K. Fuchs   March 1993
; Subroutine RANDOM8: Generate 8-bit pseudo random numbers
;	Inputs	SEED -- random number seed
;		(BL) -- maximum+1 random value desired
;	Output  (DL) -- 8-bit random value, with range  0 <= (DL) < (BL)
;		(DH) -- 0
SEED	DW	231h			; First value for Random Seed 
RANDOM8	PROC	NEAR
	CALL	RSAVE			; Save everything
	MOV	AX, SEED		; SEED
	MOV	CX, 8			; # random bits generated
NEXTB:	MOV	DX, 0			;Clear DX
	TEST	AX, 010b		;Check if bit 1 = 1
	JZ	BIT1E0			;If bit 1 = 0, then (DL) = 0
	MOV	DL, 1			;If bit 1 = 1, then (DL) = 1
BIT1E0:	TEST	AX, 0100b		;Check if bit 2 = 1
	JZ	BIT2E0			;If bit 2 = 0, then (DH) = 0
	MOV	DH, 1			;If bit 2 = 1, then (DH) = 1
BIT2E0:	XOR	DL, DH			;(DL) bit 0 = XOR AX (bits 1, 2)
	SHR	DL, 1			;Carry flag = bit 0 of DL
	RCR	AX, 1			;rotate carry flag into (AX) bit 15
					;shift all other bits of AX right 1
	LOOP	NEXTB			;repeat 8 times
	MOV	SEED, AX		; Save the seed for next time
	MOV	AH, 0			; Now get  SEED MOD (BL)
	DIV	BL			; Divide by max val+1
	MOV	DL, AH			; Random value passed in DL
	MOV	DH, 0			; (DH) returned as 0
	MOV	BP, SP			; Put Remainder DX into stack
	MOV	10[BP],DX
	CALL	RREST
	RET
RANDOM8	ENDP

; _DISPLAY SUBROUTINE -- DISPLAYS RANDOM CHARACTERS OF THE TOP ROW IN
;       RANDOM COLUMNS.  THE COLOR CYCLES THROUGH COLOR NUMBER 8-15.
;
;       INPUTS -- PASS THE NUMBER OF CHARACTERS TO BE DISPLAYED ON THE STACK
;       OUTPUT -- NONE
COLOR   DB      14                      ; FIRST COLOR IS 14(YELLOW)
N       EQU     22                      ; PARAMETER AT [SP] + 22, AFTER RSAVE
_DISPLAY PROC   FAR
        CALL    RSAVE
        MOV     AX, CS                  ; MAKE DS = CS
        MOV     DS, AX
        MOV     BP, SP                  ; DIG DOWN IN STACK TO GET THE
        MOV     CX, N[BP]               ;  PARAMETER PASSED BY C
DSPLP:  PUSH    CX
        MOV     BL, 80                  ; GET THE RANDOM COLUMN
        CALL    RANDOM8                 ;  BETWEEN 0-79
        MOV     BH, 0                   ; SET PAGE 0 FOR BIOS INTERRUPT
        MOV     AH, 2                   ; SELECT CURSOR FUNCTION
        INT     10h                     ; INVOKE BIOS
        MOV     BL, 58                  ; GET THE RANDOM ASCII CHAR
        CALL    RANDOM8                 ;  BETWEEN 0-57
        ADD     DL, 33                  ; CHAR NOW BETWEEN 33-90
        MOV     AL, DL                  ; PUT CHAR IN CORRECT PARAMETER
        MOV     CX, 1                   ; DISPLAY CHARACTER ONLY ONCE
        MOV     BH, 0                   ; USE PAGE 0
        MOV     BL, COLOR               ; USE COLOR VARIABLE
        AND     BL, 00001111b           ; MASK ON RED BG W/ NO BLINKING
        OR      BL, 01000000b
        MOV     AH, 9                   ; SELECT WRITE CHAR FUNCTION
        INT     10h                     ; INVOKE BIOS
        INC     COLOR                   ; INCREMENT COLOR
        CMP     COLOR, 15               ; IF COLOR > 15 (i.e. 16)
        JBE     DSP1
        MOV     COLOR, 8                ;  COLOR = 8
DSP1:   POP     CX
        LOOP    DSPLP                   ; DO ANOTHER CHARACTER IF WE HAVE TO
        CALL    RREST
        RET
_DISPLAY ENDP

; _WTTIME SUBROUTINE -- IT CONTINUALLY CHECKS THE KEYBOARD BUFFER UNTIL
;       THE TIMEOUTTIME HAS EXPIRED, AND RETURNS AX=0.  FOR EVERY KEY
;       THAT WAS INPUT DURING THIS PERIOD, IT SCANS THE DISPLAY FOR ANY
;       OCCURENCES OF THIS CHARACTER AND REPLACES IT WITH A SPACE.  IF AN
;       ESC IS HIT DURING THE PERIOD, IT RETURNS AX=2 IMMEDIATELLY, NOT
;       WAITING FOR A TIMEOUT TO OCCUR.
;
;       INPUTS -- NONE
;       OUTPUT -- AX=0 IF TIMED OUT SUCCESFULLY, AX=2 IF ESC KEY WAS HIT
BEGTIME EQU     0                       ; POINTER TO LOCAL VARIABLE
_WTTIME PROC    FAR
        MOV     AX, 0                   ; BY DEFAULT RETURN AX=0
        CALL    RSAVE
        MOV     AX, CS                  ; MAKE DS = CS
        MOV     DS, AX
        SUB     SP, 2                   ; ALLOCATE TWO BYTES FOR LOCAL VARS
        MOV     BP, SP
        MOV     AX, _TICKS
        MOV     BEGTIME[BP], AX         ; LET DX CONTAIN BEGINING TIME
WTLP1:  MOV     AX, _TICKS              ; COMPARE CURRENT TICKS TO
        SUB     AX, BEGTIME[BP]         ;  NUMBER OF TICKS AT START AND
        CMP     AX, TIMEOUT             ;  CHECK IF TIME OUT TIME PASSED
        JA      TIMOUT                  ; IF SO, RETURN AX ACCORDINGLY
        MOV     AH, 1                   ; CHECK TO SEE IF A KEY IS WAITING
        INT     16h                     ; BIOS CHECKS FOR US
        JZ      WTLP1                   ; NO CHAR, SO SEE IF TIMED OUT YET
        CALL    KBDIN                   ; GET THE CHARACTER
        CMP     AL, ESCKEY              ; CHECK TO SEE IF IT'S AN ESC
        JE      ESCHIT                  ;  IF YES, DEAL WITH IT LATER
        MOV     BX, 0B800h              ; SET UP ES TO POINT TO VIDEO PAGE
        MOV     ES, BX
        MOV     CX, 80*25               ; THERE ARE 80*25 CHARACTER ON SCREEN
        MOV     DI, 0                   ; POINT TO THE FIRST CHARCTER
REPLCE: CMP     AL, BYTE PTR ES:[DI]    ; CHECK CURRENT CHAR W/ CHAR TYPED
        JNE     REPLP                   ; NO MATCH SO CHECK NEXT
        MOV     BL, SPACE               ; MATCH, SO REPLACE
        MOV     ES:[DI], BL             ; CHARACTER W/ SPACE
REPLP:  ADD     DI, 2                   ; GO TO NEXT CHAR & SKIP ATTRIBUTE
        LOOP    REPLCE                  ; DECREMENT COUNTER & LOOP
        JMP     WTLP1                   ; CHECK TIME OUT
ESCHIT: MOV     WORD PTR AXTEMP+2[BP], 2 ; CHANGE SAVED AX (+2 FROM LOCAL VAR)
TIMOUT: ADD     SP, 2                   ; DON'T NEED TO CHANGE AX (DEFAULT
        CALL    RREST                   ;  IS 0), SO DEALLOC MEM FOR LOCAL VAR
        RET                             ; GET REGISTERS BACK AND RETURN
_WTTIME ENDP

; _SCROLL SUBROUTINE -- SCROLLS ALL ROWS OF THE DISPLAY DOWN ONE ROW.  AFTER
;       THE SCROLL, THE BOTTOM FIVE LINES ARE MADE TO BLINK.
;
;       INPUTS -- NONE
;       OUTPUT -- NONE
_SCROLL PROC    FAR
        CALL    RSAVE
        MOV     AX, CS                  ; MAKE DS = CS
        MOV     DS, AX
        MOV     DL, 79                  ; RIGHT COLUMN = 80
        MOV     DH, 24                  ; BOTTOM ROW = 25 LINES
        MOV     CL, 0                   ; LEFT COLUMN = 0
        MOV     CH, 0                   ; TOP COLUMN = 0
        MOV     BH, 01001110b           ; SET BG=RED, FG=YELLOW, NO BLINKING
        MOV     AL, 1                   ; SCROLL 1 LINE ONLY
        MOV     AH, 07h                 ; SET COMMAND TO SCROLL DOWN LINES
        INT     10h                     ; DO BIOS INTERRUPT 10h
        MOV     AX, 0B800h              ; LOAD ES WITH VIDEO PAGE 1 ADDRESS
        MOV     ES, AX
        MOV     CX, 5*80                ; LOAD CX W/ # OF CHARS TO BLINK
        MOV     DI, (20*80*2+1)         ; FIRST CHARACTER IS ON THE 20th LINE
LP1:    OR      BYTE PTR ES:[DI],80h    ; SET BIT 7 & KEEP THE REST
        ADD     DI, 2                   ; SKIP OVER CHAR & GO TO NEXT ATTR.
        LOOP    LP1                     ; CHECK TO SEE IF WE GOT 'EM ALL
        CALL    RREST
        RET
_SCROLL ENDP

; _CHKBOT SUBROUTINE -- CHECKS TO SEE IF THERE IS A CHARACTER (NON-SPACE)
;       ON THE BOTTOM LINE OF THE SCREEN.  IF THERE IS NO CHARACTER ON
;       THE LINE, IT RETURNS A 0 IN AX, OTHERWISE IT PLAYS A GAME OVER
;       SONG AND RETURNS A 1 IN AX.
;
;       INPUTS -- NONE
;       OUTPUT -- AX=0 IF NO CHARACTERS ON BOTTOM LINE, ELSE AX=1
_CHKBOT PROC    FAR
        CALL    RSAVE
        MOV     AX, CS                  ; MAKE DS = CS
        MOV     DS, AX
        MOV     AX, 0B800h              ; MAKE ES POINT TO VIDEO PAGE (B800h)
        MOV     ES, AX
        MOV     DI, (80*24*2)           ; DI POINTS TO 1st CHAR OF 24th LINE
        MOV     CX, 80                  ; 80 CHARACTERS TO CHECK
CHKLP:  CMP     BYTE PTR ES:[DI], SPACE ; COMPARE CURRENT CHAR TO A SPACE
        JNE     UDIE                    ;  IF IT'S NOT, THEN PLAYER IS DEAD
        ADD     DI, 2                   ; JUMP OVER ATTRIBUTE TO NEXT CHAR
        LOOP    CHKLP                   ; SEE IF WE CHECKED ALL 80 CHARS YET
        MOV     BP, SP                  ; NO CHARACTERS, RETURN AX=0
        MOV     WORD PTR AXTEMP[BP], 0  ;  BY CHANGING SAVED VALUE
CHKDNE: CALL    RREST                   ; GET REGISTERS BACK W/ AX MODIFIED
        RET
UDIE:   MOV     BP, SP                  ; PLAYER IS DEAD, SO RETURN AX=1
        MOV     WORD PTR AXTEMP[BP], 1  ;  BY CHANGING SAVED VALUE
        MOV     DX, 3042                ; PLAY AN 3 NOTE SONG
        MOV     BX, 26                  ;  STARTING WITH A G
        CALL    NOTE
        MOV     DX, 0                   ; REST FOR A WHILE
        MOV     BX, 1
        CALL    NOTE
        MOV     DX, 4831                ; PLAY A B
        MOV     BX, 13
        CALL    NOTE
        MOV     DX, 0                   ; REST AGAIN
        MOV     BX, 1
        CALL    NOTE
        MOV     DX, 4560                ; FINALLY PLAY A C
        MOV     BX, 26
        CALL    NOTE
        JMP     CHKDNE
_CHKBOT ENDP

; _RESTORE SUBROUTINE -- RESTORE ORIGINAL INTERRUPT VECTOR 1Ch AND NORMAL
;       VIDEO COLORS.
;
;       INPUTS -- NONE
;       OUTPUT -- NONE
_RESTORE PROC   FAR
        CALL    RSAVE
        MOV     AX, CS                  ; MAKE DS = CS
        MOV     DS, AX
        CLI                             ; DISABLE INTERRUPTS
        MOV     AX, 0                   ; SET ES = 0000H
        MOV     ES, AX
        MOV     AX, SAVOFF              ; GET OLD OFFSET
        MOV     ES:VEC1C, AX            ; PUT IT AT VECTOR ADDRESS
        MOV     AX, SAVSEG              ; GET OLD SEGMENT
        MOV     ES:VEC1C+2, AX          ; PUT IT AT VECTOR ALSO
        STI                             ; ENABLE INTERRUPTS NOW
        MOV     DL, 79                  ; RIGHT COLUMN = 80
        MOV     DH, 24                  ; BOTTOM ROW = 25 LINES
        MOV     CL, 0                   ; LEFT COLUMN = 0
        MOV     CH, 0                   ; TOP COLUMN = 0
        MOV     BH, 00000111b           ; SET BG=BLK, FG=LT GRAY, NO BLINKING
        MOV     AL, 0                   ; CLEAR ENTIRE WINDOW, I.E. SCREEN
        MOV     AH, 07h                 ; SET COMMAND TO SCROLL DOWN LINES
        INT     10h                     ; DO BIOS INTERRUPT 10h
        MOV     DL, 0                   ; SET CURSOR POSITION COLUMN 0
        MOV     DH, 0                   ;  AND ROW 0
        MOV     BH, 0                   ; ON CURRENT SCREEN
        MOV     AH, 2                   ; SET CURSOR POSITION COMMAND
        INT     10h                     ; EXECUTE BIOS AGAIN
        CALL    RREST
        RET
_RESTORE ENDP

; NOTE SUBROUTINE -- PLAYS A NOTE OF A SPECIFIED FREQUENCY FOR A SPECIFIED
;       DURATION.  IF THE FREQUENCY IS ZERO, THEN IT WILL PLAY A REST
;       (NO SOUND) FOR THE SPECIFIED DURATION.
;
;       INPUTS -- DX=FREQUENCY NUMBER (1,193,180 / TRUE FREQUENCY)
;                 BX=DURATION (25=APPROX. 1 SECOND)
;       OUTPUT -- NONE
NOTE    PROC    NEAR
        PUSH    AX                      ; SAVE AX
        MOV     AL, 182                 ; PREPARE THE SPEAKER FOR THE
        OUT     43h, AL                 ;  NOTE
        CMP     DX, 0                   ; IF ZERO FREQ. THEN WE REST
        JZ      PAUSE1                  ;  AND DON'T TURN ON THE SPEAKER
        MOV     AX, DX                  ; PUT FREQUENCY IN A USABLE REGISTER
        OUT     42h, AL                 ; OUTPUT LOW BYTE
        MOV     AL, AH                  ; OUTPUT HIGH BYTE
        OUT     42h, AL
        IN      AL, 61h                 ; TURN ON NOTE BY
        OR      AL, 00000011b           ;  SETTING BITS 0 AND 1 OF PORT 61h
        OUT     61h, AL                 ; NOTE WILL BE ON NOW
PAUSE1: MOV     CX, 65535               ; PAUSE FOR DURATION OF NOTE
PAUSE2: DEC     CX
        JNE     PAUSE2
        DEC     BX
        JNE     PAUSE1
        CMP     DX, 0                   ; IF ZERO FREQ. THEN NOTE WAS NEVER
        JE      NOTEXIT                 ;  PLAYED, SO DON'T SHUT IT OFF
        IN      AL, 61h                 ; TURN OFF NOTE BY
        AND     AL, 11111100b           ;  CLEARING BITS 0 AND 1 OF PORT 61h
        OUT     61h, AL                 ; NOTE WILL BE OFF NOW
NOTEXIT:POP     AX
        RET
NOTE    ENDP

CSEG    ENDS
	END				; Note the plain "END" here
