        PAGE    78,132
        TITLE   Dave Dribin     2/28/93

; THIS PROGRAM TAKES A LIST OF RANDOM NUMBERS AND QUICKSORTS THEM.
; THE NUMBER OF RANDOM NUMBERS GENERATED IS SPECIFIED BY THE USER.

CR      EQU     0Dh
LF      EQU     0Ah
BEL     EQU     07h
ESCKEY  EQU     18h
BS      EQU     08h
DEL     EQU     7Fh
MAX     EQU     100                     ; MAX NUMBER OF WORDS TO SORT

        EXTRN   KBDIN:NEAR, DSPOUT:NEAR, DSPMSG:NEAR, DOSXIT:NEAR
        EXTRN   RSAVE:NEAR, RREST:NEAR, ASCBIN:NEAR, BINASC:NEAR

STKSEG  SEGMENT STACK                   ; *** STACK SEGMENT ***
        DB      512 DUP ('STACK   ')
STKSEG  ENDS

CSEG    SEGMENT PUBLIC                  ; *** CODE SEGMENT ***
        ASSUME  CS:CSEG, DS:CSEG, SS:STKSEG, ES:NOTHING

NPROMPT DB      'Enter the number of words to sort: ','$,'
SPROMPT DB      'Enter the random number seed: ','$'
INVALID DB      'Invalid Input, Please Try Again.',CR,LF,'$'
UNSORT  DB      'Unsorted Random Numbers:',CR,LF,'$'
SORT    DB      'Quicksort Results:',CR,LF,'$'
ANYKEY  DB      'Press Any Key to Continue...',CR,LF,'$'
BYE     DB      'Quit to DOS...',CR,LF,'$'
CRLF    DB      CR,LF,'$'

N       DW      ?                       ; NUMBER OF WORDS TO BE SORTED
S       DW      ?                       ; RANDOM NUMBER SEED
RNLIST  DW      MAX DUP (?)             ; LIST OF RANDOM NUMBERS
BUFFER  DB      256 DUP (?)             ; INPUT BUFFER
TMPSTR  DB      7 DUP (?)               ; TEMP STRING FOR BINASC

MAIN    PROC    FAR
        MOV     AX, CSEG                ; INITIALIZE DS REGISTER
        MOV     DS, AX
PROMPT: CALL    INPUT                   ; GET N AND S FROM USER
        CMP     N, 0
        JE      QUIT
        CALL    RANDOM                  ; GET A LIST OF N RANDOM #'S
        LEA     DX, UNSORT              ; PRINT OUT A UNSORTED MESSAGE
        CALL    DSPMSG
        CALL    PRLIST                  ; PRINT OUT LIST
        LEA     DX, ANYKEY              ; PROMPT USER FOR A KEYPRESS
        CALL    DSPMSG
        CALL    KBDIN                   ; WAIT FOR KEYPRESS
        LEA     SI, RNLIST              ; SI = OFFSET OF RNLIST
        MOV     DI, N                   ; DI = OFFSET OF LAST NUMBER IN LIST
        DEC     DI
        SHL     DI, 1
        ADD     DI, SI
        CALL    QSORT                   ; QUICKSORT THE LIST
        LEA     DX, SORT                ; PRINT OUT SORTED MESSAGE
        CALL    DSPMSG
        CALL    PRLIST
        LEA     DX, CRLF                ; PRINT A NEWLINE
        CALL    DSPMSG
        JMP     PROMPT                  ; GET MORE DATA
QUIT:   LEA     DX, BYE                 ; PRINT EXIT MSG
        CALL    DSPMSG
        CALL    DOSXIT                  ; EXIT TO DOS
        RET
MAIN    ENDP

; INPUT SUBROUTINE -- PROMPTS THE USER FOR THE NUMBER OF WORDS TO SORT, N AND
;       INPUTS IT.  THEN IT PROMPTS THE USER FOR THE RANDOM NUMBER SEED, AND
;       INPUTS IT.
;
;       INPUTS -- NONE
;       OUTPUT -- M(N) CONTAINS THE NUMBER OF WORDS TO SORT. M(S) CONTAINS
;               THE RANDOM NUMBER SEED
INPUT   PROC    NEAR
        CALL    RSAVE
INPUT1: LEA     DX, NPROMPT             ; PROMPT USER FOR N(UMBER OF WORDS)
        CALL    DSPMSG
        LEA     BX, BUFFER
        CALL    GETSTR                  ; READ IN N FROM KEYBOARD
        CALL    ASCBIN                  ; CONVERT STRING TO INTEGER
        CMP     DL, 0                   ; CHECK FOR VALID INPUT
        JNE     BADIN1
        MOV     N, AX                   ; STORE INPUT AT M(N)
        CMP     AX, 0                   ;  AND CORRECT RANGE OF INPUT
        JL      BADIN1
        JE      INPUT3
        CMP     AX, MAX                 ; RE-ENTER N IF N > 100
        JG      BADIN1
INPUT2: LEA     DX, SPROMPT             ; PROMPT USER FOR S(EED)
        CALL    DSPMSG
        LEA     BX, BUFFER              ; READ IN S FROM KEYBOARD
        CALL    GETSTR
        CALL    ASCBIN                  ; CONVERT STRING TO INTEGER
        CMP     DL, 0                   ; CHECK FOR VALID INPUT
        JNE     BADIN2
        MOV     S, AX                   ; STORE INPUT AT M(S)
INPUT3: CALL    RREST                   ; GET REGISTERS BACK AND RETURN
        RET
BADIN1: LEA     DX, INVALID             ; BAD DATA, SO TELL USER
        CALL    DSPMSG
        LEA     DX, CRLF
        CALL    DSPMSG
        JMP     INPUT1                  ;  AND TRY AGAIN
BADIN2: LEA     DX, INVALID             ; BAD DATA FOR SEED...
        CALL    DSPMSG                  ;  TELL USER
        LEA     DX, CRLF
        CALL    DSPMSG
        JMP     INPUT2                  ;  AND TRY AGAIN
INPUT   ENDP

; GETSTR SUBOURTINE -- INPUTS A STRING OF CHARACTERS FROM THE KEYBOARD. WHEN
;       A CR IS HIT, IT APPENDS A '$' TO THE END OF THE STRING.  IT ALLOWS
;       FOR USE OF BACKSPACE AS WELL.  ASSUMES BUFFER IS 256 BYTES LONG.
;
;       INPUTS -- BX CONTAINS OFFSET OF CHARACTER BUFFER
;       OUTPUT -- '$' TERMINATED STRING IS POINTED TO BY BX.
GETSTR  PROC    NEAR
        PUSH    DX                      ; SAVE AX, DX, DI REGISTERS ON STACK
        PUSH    AX
        PUSH    DI
        MOV     DI, 0
GETCHR: CALL    KBDIN                   ; GET NEXT CHARACTER FROM KBD
        CMP     AL, CR                  ; IF ENTER KEY, STOP AND RETURN
        JE      GETRET
        CMP     AL, BS                  ; IF BACKSPACE, HANDLE IT
        JE      GETBS
        MOV     DL, AL                  ; ECHO CHARACTER
        CALL    DSPOUT
        MOV     [BX + DI], AL           ; STORE IT IN THE BUFFER
        INC     DI
        CMP     DI, 255                 ; CHECK IF STRING TO LARGE
        JB      GETCHR
        JAE     GETRET
GETBS:  CMP     DI, 0                   ; IF AT BEGINING OF BUFFER,
        JE      GETCHR                  ;  IGNORE IT
        MOV     DL, BS                  ; DISPLAY A BS,SPACE,BS
        CALL    DSPOUT
        MOV     DL, ' '
        CALL    DSPOUT
        MOV     DL, BS
        CALL    DSPOUT
        DEC     DI                      ; BUFFER POINTER BACK
        JMP     GETCHR
GETRET: MOV     AL, '$'                 ; APPEND '$'
        MOV     [BX + DI], AL
        LEA     DX, CRLF                ; PRINT A NEWLINE
        CALL    DSPMSG
        POP     DI                      ; GET REGISTERS BACK
        POP     AX
        POP     DX
        RET
GETSTR  ENDP

; RNSEED SUBROUTINE -- PLANTS THE SEED FOR THE RAND FUNCTION
;
;       INPUTS -- AX CONTAINS THE SEE
;       OUTPUT -- NONE
RNSEED  PROC    NEAR
        MOV     RNUM, AX                ; MAKES SEED THE RANDOM NUMBER
        RET
RNSEED  ENDP

; RAND SUBROUTINE -- GETS A RANDOM NUMBER
;
;       INPUTS -- NONE
;       OUTPUT -- AX CONTAINS A RANDOM NUMBER
RAND    PROC    NEAR
        PUSH    DX                      ; SAVE DX
        MOV     AX, RNUM                ; GET LAST NUMBER GENERATED
        MUL     C2053                   ; USE THE "RANDOM" FORMULA
        ADD     AX, C13849
        ADC     DX, 0
        DIV     CFFFF
        MOV     AX, DX
        MOV     RNUM, AX
        POP     DX                      ; GET DX BACK
        RET
RAND    ENDP

RNUM    DW      ?                       ; RANDOM NUMBER USED BY RAND
C2053   DW      2053                    ; CONSTANS USED IN FORMULA
C13849  DW      13849
CFFFF   DW      65535

; RANDOM SUBROUTINE -- GETS N RANDOM NUMBERS AND STORES THEM IN RNLIST
;
;       INPUTS -- N CONTAINS THE NUMBER OF WORDS TO GENERATE
;                 S CONTAINS THE SEED TO USE
;       OUTPUT -- RNLIST CONTAINS N RANDOM NUMBERS
RANDOM  PROC    NEAR
        CALL    RSAVE
        MOV     DI, 0
        LEA     BX, RNLIST
        MOV     AX, S                   ; USE S AS SEED FOR NUMBERS
        CALL    RNSEED
        MOV     CX, N
RANDLP: CALL    RAND                    ; GET A RANDOM NUMBER
        MOV     [BX + DI], AX           ; STORE IT IN THE LIST
        ADD     DI, 2                   ; INCREMENT INDEX
        LOOP    RANDLP                  ; DEC CX AND JMP IF CX IS NOT 0
        CALL    RREST                   ; GET REGISTERS AND RETURN
        RET
RANDOM  ENDP

; QSORT SUBROUTINE -- USES THE QUICKSORT ALGORITHM TO SORT A LIST OF NUMBERS
;       BETWEEN THE OFFSETS SI AND DI
;
;       INPUTS -- SI CONTAINS OFFSET OF BEGINING OF LIST
;                 DI CONTAINS OFFSET OF END OF LIST
;       OUTPUT -- LIST IS SORTED, SI AND DI ARE SCRAMBLED
QSORT   PROC    NEAR
        MOV     BO1, SI                 ; MOVE SI INTO PARAM LIST FOR PARTIT
        MOV     EO1, DI                 ; MOVE DI INTO PARAM LIST FOR PARTIT
        PUSH    BX                      ; SAVE BX
        LEA     BX, PLIST1
        CALL    PARTIT                  ; PARTIONS LIST AND RETURNS PO
        POP     BX                      ; RESTORE BX
        MOV     SI, PO1                 ; USE SI AS INTERMIEDIATE REGISTER
        CMP     BO1, SI                 ; IF BO < PO
        JAE     QSORT1
        PUSH    BO1                     ;  THEN SAVE BO, EO, AND PO
        PUSH    EO1
        PUSH    PO1
        MOV     SI, BO1                 ;  SI = BO
        MOV     DI, PO1                 ;  DI = PO - 2;
        SUB     DI, 2
        CALL    QSORT                   ; CALL QSORT(BO, PO - 2)
        POP     PO1                     ; RESOTER BO, EO, AND PO
        POP     EO1
        POP     BO1
QSORT1: MOV     SI, EO1                 ; USE SI AS INTERMEDIATE REGISTER
        CMP     PO1, SI                 ; IF PO < EO
        JAE     QSORT2
        PUSH    BO1                     ;  THEN SAVE BO, EO, AND PO
        PUSH    EO1
        PUSH    PO1
        MOV     SI, PO1                 ; SI = PO + 2
        ADD     SI, 2
        MOV     DI, EO1                 ; DI = EO
        CALL    QSORT                   ; CALL QSORT(PO + 2, EO)
        POP     PO1                     ; RESTORE BO, EO, AND PO
        POP     EO1
        POP     BO1
QSORT2: RET
QSORT   ENDP

PLIST1   LABEL   WORD                   ; PARAMETER LIST FOR PARTIT
BO1      DW      ?                      ; INPUT: BEGINING OF OFFSET
EO1      DW      ?                      ; INPUT: ENDING OFFSET
PO1      DW      ?                      ; OUTPUT: OFFSET OF PARTITION VALUE

; PARTIT SUBROUTINE -- PARTITIONS A LIST OF WORDS CONTAINED BETWEEN OFFSET
;       BO TO OFFSET EO.  USES FIRST VALUE IN LIST TO PARTION AROUND.
;       RETURNS OFFSET OF PARTION VALUE SUCH THAT M(I) <= [PO] FOR
;       BO <= I < PO, M(J) >= [PO] FOR PO < J <= EO.
;
;       INPUTS -- BX CONTAINS OFFSET TO PARAMETER LIST
;       OUTPUT -- PO CONTAINS OFFSET OF PARTION VALUE
;       PARAMATER LIST:
;               PLIST   LABEL   WORD
;               BO      DW      ?       INPUT: BEGINING OFFSET
;               EO      DW      ?       INPUT: ENDING OFFSET
;               PO      DW      ?       OUTPUT: OFFSET OF PARTITION VALUE
BO      EQU     0
EO      EQU     2
PO      EQU     4
PARTIT  PROC    NEAR
        CALL    RSAVE
        MOV     SI, BO[BX]              ; INIT SI(I) TO BO
        MOV     DI, EO[BX]              ; INIT DI(J) TO EO + 2;
        ADD     DI, 2
        MOV     AX, [SI]                ; USE AX FOR X (PARTITION VALUE)
PART1:  ADD     SI, 2                   ; MAKE SI POINT PAST END OF LIST
        CMP     SI, EO[BX]              ;  OR TO A NUMBER GREATER THAN
        JA      PART2                   ;  OUR PARTION VALUE
        CMP     [SI], AX
        JGE     PART2
        JMP     PART1
PART2:  SUB     DI, 2                   ; MAKE DI POINT TO A NUMBER LESS
        CMP     [DI], AX                ;  THAN OUT PARTION VALUE
        JG      PART2
        CMP     SI, DI                  ; IF SI > DI, THEN LIST IS PARTIONED
        JA      PART3
        MOV     DX, [SI]                ; EXCHANGE: [SI] <--> [DI]
        XCHG    DX, [DI]
        MOV     [SI], DX
PART3:  CMP     SI, DI                  ; IF SI <= DI, LIST IS NOT PARTIONED
        JBE     PART1                   ;  SO CONTINUE...
        MOV     SI, BO[BX]              ; EXCHANGE: [BO](X) <--> [DI]
        MOV     DX, [SI]                ;  PUTS PARTION VALUE AT CORRECT
        XCHG    DX, [DI]                ;  PLACE IN LIST
        MOV     [SI], DX
        MOV     PO[BX], DI              ; PUT [X] IN PARTION OFFSET(PO) PARAM
        CALL    RREST
        RET
PARTIT  ENDP

; PRLIST SUBROUTINE -- PRINT THE LIST OF WORDS USED BY THE SORTING ROUTINE.
;
;       INPUTS -- RNLIST CONTAINS THE LIST OF NUMBERS
;                 N CONTAINS THE NUMBER OF WORDS TO PRINT
;       OUTPUT -- THE LIST IS PRINTED TO THE SCREEN.
PRLIST  PROC    NEAR
        CALL    RSAVE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
        LEA     DX, CRLF                ; PRINT A NEWLINE
        CALL    DSPMSG
        POP     BX                      ; GET BX BACK
        SHR     SI, 1                   ; INCREMENT POINTER TO NUMBER
        INC     SI
PRTEST: CMP     SI, N
        JB      PRLST1
        CALL    RREST                   ; GET REGISTERS AND RETURN
        RET
PRLIST  ENDP

CSEG    ENDS
        END     MAIN
