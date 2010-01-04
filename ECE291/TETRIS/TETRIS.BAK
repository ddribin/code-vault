                PAGE    78,132
                TITLE   GRAPH   Dave Dribin     April 12, 1993

COMMENT         *
                This program implements Tetris using 640x480 16 color
                mode VGA graphics.  Tetris itself is pretty self
                explanatory.
                *

                INCLUDE MACROS.ASM

; ALL EQU'S GO HERE!
BOXHEIGHT       EQU     16              ; BOX HEIGHT IS 16 LINES
BOXWIDTH        EQU     2               ; BOX WIDTH IS TWO BYTES
PLAYFIELDLINE   EQU     470             ; LINE WHERE PLAYFIELD STARTS
PLAYFIELDBYTE   EQU     28              ; BYTE WHERE PLAYFIELD STARTS
PLAYFIELDHEIGHT EQU     20              ; THE HEIGHT OF PLAYFIELD IN BLOCKS
PLAYFIELDWIDTH  EQU     10              ; THE WIDTH OF PLAYFIELD IN BLOCKS
NEXTLINE        EQU     150             ; LINE WHERE NEXT BLOCK APPEARS
NEXTBYTE        EQU     58              ; BYTE WHERE NEXT BLOCK APPEARS
BLOCKWIDTH      EQU     4               ; BLOCKS CAN BE 4 BOXES WIDE
BLOCKHEIGHT     EQU     4               ; BLOCKS CAN BE 4 BOXES TALL
BLOCKSIZE       EQU     BLOCKWIDTH*BLOCKHEIGHT  ; SIZE IN BYTES OF ONE BLOCK
ROWLENGTH       EQU     14              ; NUMBER OF BOXES PER ROW
COLUMNLENGTH    EQU     23              ; NUMBER OF BOXES PER COLUMN
CR              EQU     0Dh             ; ASCII CARRIAGE RETURN
LF              EQU     0Ah             ; ASCII LINE FEED
ESCKEY          EQU     1Bh             ; ASCII ESC KEY
SECOND          EQU     182             ; 182 TICKS PER SECOND
STARTDELAY      EQU     150             ; STATRING DELAY FOR LEVEL 0
NEXTDELAY       EQU     15              ; DELAY DIFFERENCE BETWEEN LEVELS
STARTLEVEL      EQU     1               ; STARTING LEVEL NUMBER

RECT            STRUC                   ; STRUCTURE FOR RECTANGLES
RROW            DW      ?
RCOLUMN         DW      ?
RWIDTH          DW      ?
RHEIGHT         DW      ?
RCOLOR          DB      ?
RECT            ENDS

STKSEG          SEGMENT STACK                   ; *** STACK SEGMENT ***
                DB      256 DUP('STACK   ')
STKSEG          ENDS

CSEG            SEGMENT PUBLIC                  ; *** CODE SEGMENT ***
                ASSUME  CS:CSEG, DS:CSEG, SS:STKSEG, ES:NOTHING

; DATA GOES HERE!
BLOCKS          DB      000h, 000h, 000h, 000h  ; BLOCK 0, ROTATION 0
                DB      000h, 000h, 000h, 000h
                DB      000h, 004h, 004h, 004h
                DB      000h, 000h, 004h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 0, ROTATION 1
                DB      000h, 000h, 004h, 000h
                DB      000h, 004h, 004h, 000h
                DB      000h, 000h, 004h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 0, ROTATION 2
                DB      000h, 000h, 004h, 000h
                DB      000h, 004h, 004h, 004h
                DB      000h, 000h, 000h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 0, ROTATION 3
                DB      000h, 000h, 004h, 000h
                DB      000h, 000h, 004h, 004h
                DB      000h, 000h, 004h, 000h


                DB      000h, 000h, 000h, 000h  ; BLOCK 1, ROTATION 0
                DB      000h, 000h, 000h, 000h
                DB      000h, 001h, 001h, 001h
                DB      000h, 000h, 000h, 001h

                DB      000h, 000h, 000h, 000h  ; BLOCK 1, ROTATION 1
                DB      000h, 000h, 001h, 000h
                DB      000h, 000h, 001h, 000h
                DB      000h, 001h, 001h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 1, ROTATION 2
                DB      000h, 001h, 000h, 000h
                DB      000h, 001h, 001h, 001h
                DB      000h, 000h, 000h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 1, ROTATION 3
                DB      000h, 000h, 001h, 001h
                DB      000h, 000h, 001h, 000h
                DB      000h, 000h, 001h, 000h


                DB      000h, 000h, 000h, 000h  ; BLOCK 2, ROTATION 0
                DB      000h, 000h, 000h, 000h
                DB      000h, 005h, 005h, 000h
                DB      000h, 000h, 005h, 005h

                DB      000h, 000h, 000h, 000h  ; BLOCK 2, ROTATION 1
                DB      000h, 000h, 000h, 005h
                DB      000h, 000h, 005h, 005h
                DB      000h, 000h, 005h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 2, ROTATION 2
                DB      000h, 000h, 000h, 000h
                DB      000h, 005h, 005h, 000h
                DB      000h, 000h, 005h, 005h

                DB      000h, 000h, 000h, 000h  ; BLOCK 2, ROTATION 3
                DB      000h, 000h, 000h, 005h
                DB      000h, 000h, 005h, 005h
                DB      000h, 000h, 005h, 000h


                DB      000h, 000h, 000h, 000h  ; BLOCK 3, ROTATION 0
                DB      000h, 000h, 000h, 000h
                DB      000h, 003h, 003h, 000h
                DB      000h, 003h, 003h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 3, ROTATION 1
                DB      000h, 000h, 000h, 000h
                DB      000h, 003h, 003h, 000h
                DB      000h, 003h, 003h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 3, ROTATION 2
                DB      000h, 000h, 000h, 000h
                DB      000h, 003h, 003h, 000h
                DB      000h, 003h, 003h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 3, ROTATION 3
                DB      000h, 000h, 000h, 000h
                DB      000h, 003h, 003h, 000h
                DB      000h, 003h, 003h, 000h


                DB      000h, 000h, 000h, 000h  ; BLOCK 4, ROTATION 0
                DB      000h, 000h, 000h, 000h
                DB      000h, 000h, 007h, 007h
                DB      000h, 007h, 007h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 4, ROTATION 1
                DB      000h, 000h, 007h, 000h
                DB      000h, 000h, 007h, 007h
                DB      000h, 000h, 000h, 007h

                DB      000h, 000h, 000h, 000h  ; BLOCK 4, ROTATION 3
                DB      000h, 000h, 000h, 000h
                DB      000h, 000h, 007h, 007h
                DB      000h, 007h, 007h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 4, ROTATION 4
                DB      000h, 000h, 007h, 000h
                DB      000h, 000h, 007h, 007h
                DB      000h, 000h, 000h, 007h


                DB      000h, 000h, 000h, 000h  ; BLOCK 5, ROTATION 0
                DB      000h, 000h, 000h, 000h
                DB      000h, 002h, 002h, 002h
                DB      000h, 002h, 000h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 5, ROTATION 1
                DB      000h, 002h, 002h, 000h
                DB      000h, 000h, 002h, 000h
                DB      000h, 000h, 002h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 5, ROTATION 2
                DB      000h, 000h, 000h, 002h
                DB      000h, 002h, 002h, 002h
                DB      000h, 000h, 000h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 5, ROTATION 3
                DB      000h, 000h, 002h, 000h
                DB      000h, 000h, 002h, 000h
                DB      000h, 000h, 002h, 002h


                DB      000h, 000h, 000h, 000h  ; BLOCK 6, ROTATION 0
                DB      000h, 000h, 000h, 000h
                DB      008h, 008h, 008h, 008h
                DB      000h, 000h, 000h, 000h

                DB      000h, 000h, 008h, 000h  ; BLOCK 6, ROTATION 1
                DB      000h, 000h, 008h, 000h
                DB      000h, 000h, 008h, 000h
                DB      000h, 000h, 008h, 000h

                DB      000h, 000h, 000h, 000h  ; BLOCK 6, ROTATION 2
                DB      000h, 000h, 000h, 000h
                DB      008h, 008h, 008h, 008h
                DB      000h, 000h, 000h, 000h

                DB      000h, 000h, 008h, 000h  ; BLOCK 6, ROTATION 3
                DB      000h, 000h, 008h, 000h
                DB      000h, 000h, 008h, 000h
                DB      000h, 000h, 008h, 000h


BLANKFIELD      DB      2 DUP (0FFh), 10 DUP (000h), 2 DUP (0FFh)
                REPT    21
                DB      2 DUP (0FFh), 10 DUP (000h), 2 DUP (0FFh)
                ENDM
                DB      15 DUP (0FFh)
                DB      15 DUP (0FFh)

PLAYFIELD       DB      COLUMNLENGTH DUP (ROWLENGTH DUP (0))


; THE FOLLOWING ARE THE KEYMAPPINGS
CCW             DB      'J'                     ; COUNTER-CLOCK WISE ROTATION
CW              DB      'L'                     ; CLOCK WISE ROTAION
LEFT            DB      'S'                     ; MOVE BLOCK LEFT
RIGHT           DB      'F'                     ; MOVE BLOCK RIGHT
DROP            DB      ' '                     ; DROP
QUIT            DB      ESCKEY                  ; ESC TO QUIT

; THE FOLLOWING ARE GLOABL VARIABLES
BLOCKTYPE       DB      ?                       ; CURRENT BLOCK TYPE
ROTATION        DB      ?                       ; CURRENT ROTATION
DELAY           DW      ?                       ; CURRENT FALLING DELAY
ROW             DW      ?                       ; CURRENT ROW
COLUMN          DW      ?                       ; CURRENT COLUMN
NEXT            DB      ?                       ; NEXT BLOCK TYPE
DROPFLAG        DB      ?                       ; =0 NOT DROPPING, =1 DROPPING
PAUSEFLAG       DB      ?                       ; 0 IS PUASE, 1 PLAYING
WRITEMODE       DB      WRITE_XOR               ; CURRENT WRITE MODE
TEMPDB          DB      ?                       ; TEMPORARY VARIABLE
TEMPDW          DW      ?                       ; TEMPORARY VARIABLE
TICKS           DW      0                       ; TIMER
LASTTIME        DW      ?                       ; USED FOR RELATIVE TIMES
SAVOFF          DW      ?                       ; SAVED OFFSET VECTOR
SAVSEG          DW      ?                       ; SAVED SEGMENT VECTOR
LINES           DB      4 DUP (?)               ; WHICH LINES WERE CLEARED
NUMLINES        DW      ?                       ; NUMBER OF LINES CLEARED
NUMLEVEL        DW      ?                       ; LEVEL NUMBER
MAXLINES        DW      ?                       ; HIGH SCORE

; THE FOLLING ARE DATA CONSTANTS USED BY THE PROGRAM
RECT1           RECT    <148, 254, 162, 322, 4>
RECT2           RECT    <147, 253, 164, 324, 4>

NEXTRECT1       RECT    <148, 455, 80, 75, 4>
NEXTRECT2       RECT    <147, 454, 82, 77, 4>
NEXTSTR         DB      'NEXT','$'

LINESSTR        DB      'LINES - ','$'
LEVELSTR        DB      'LEVEL - ','$'

TETRISSTR       DB      'TETRIS -- WRITTEN BY DAVE DRIBIN','$'

INSTRUCTIONSTR  DB      'J -- ROTATE COUNTER-CLOCKWISE',CR,LF
                DB      'L -- ROTATE CLOCKWISE',CR,LF
                DB      'S -- MOVE LEFT',CR,LF
                DB      'F -- MOVE RIGHT',CR,LF
                DB      'SPACE -- DROP BLOCK',CR,LF
                DB      'ESC -- QUIT','$'

GAMEOVER1       DB      'YOUR LOSE!!','$'
GAMEOVER2       DB      'HIT ANY KEY TO PLAY AGAIN, OR ESC TO EXIT','$'


MAIN            PROC    FAR
                MOV     AX, CS
                MOV     DS, AX
                CALL    INIT                    ; INITIALIZE INTERRUPT VECTOR
                CALL    SET640x480x16           ; SET UP GRAPHICS
                CALL    SETUPGAME
MAINLP:         CALL    PLAYGAME                ; PLAY A GAME
                CMP     AX, 0                   ; SHOULD WE QUIT
                JNE     MAINDONE
                CALL    PLAYAGAIN               ; SEE IF WE SHOULD GO AGAIN
                CMP     AX, 1
                JE      MAINDONE
                CALL    SETUPGAME               ; SET UP FOR ANOTHER GAME
                JMP     MAINLP
MAINDONE:       CALL    SETTEXT                 ; RESTORE TEXT
                CALL    RESTORE                 ; RESTORE INTERRUPT
                DOSXIT
MAIN            ENDP

;
; NAME          INIT
;
; FUNCTION      INITIALIZES THE TIMER INTERRUPT TO CALL THE TIME ROUTINE
;
; INTPUTS       NONE
;
; RETURNS       NONE

VEC1C           EQU     70h                     ; VECTOR FOR 1Ch(4*1Ch=70h)
INIT            PROC    NEAR
                CLI                             ; BLOCK INTERRUPTS
                CALL    RSAVE
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
INIT            ENDP

;
; NAME          TIME
;
; FUNCTION      INCREMENTS THE TICKS VARIABLE EVERY TIME IT IS INTERRUPTED
;               AT APPROXAMATELY 18.2 TIMES A SECOND
;
; INPUTS        NONE
;
; RETURNS       NONE

TIME            PROC    FAR
                ADD     CS:TICKS, 10               ; INCREMENT VARIABLE TICKS
                IRET
TIME            ENDP

;
; NAME          RESTORE
;
; FUNCTION      RESTORES THE INTERRUPT VECTOR 1Ch TO ORIGINAL VALUE.
;
; INPUTS        NONE
;
; RETURNS       NONOE
RESTORE         PROC    NEAR
                CALL    RSAVE
                CLI                             ; DISABLE INTERRUPTS
                MOV     AX, 0                   ; SET ES = 0000H
                MOV     ES, AX
                MOV     AX, SAVOFF              ; GET OLD OFFSET
                MOV     ES:VEC1C, AX            ; PUT IT AT VECTOR ADDRESS
                MOV     AX, SAVSEG              ; GET OLD SEGMENT
                MOV     ES:VEC1C+2, AX          ; PUT IT AT VECTOR ALSO
                STI                             ; ENABLE INTERRUPTS NOW
                CALL    RREST
                RET
RESTORE         ENDP

;
; NAME          SETUPGAME
;
; FUNCTION      CLEARS SCREEN AND DRAWS STUFF ON IT
;
; INPUTS        NONE
;
; RETURNS       NONE

SETUPGAME       PROC    NEAR
                CALL    RSAVE

                MOV     DELAY, STARTDELAY       ; SET UP DELAY FOR LEVEL 0

                MOV     DL, 0                   ; MAKE SCREEN BLACK
                CALL    CLEARSCREEN

                LEA     BX, RECT1               ; DRAW BORDER AROUND PLAYFIELD
                CALL    DRAWRECT
                LEA     BX, RECT2
                CALL    DRAWRECT

                MOV     AH, 2                   ; WRITE "NEXT" ON SCREEN
                MOV     DH, 10
                MOV     DL, 60
                MOV     BH, 0
                INT     10H
                LEA     DX, NEXTSTR
                CALL    DSPSTR
                LEA     BX, NEXTRECT1
                CALL    DRAWRECT
                LEA     BX, NEXTRECT2
                CALL    DRAWRECT

                MOV     NUMLINES, 0             ; WE HAVE ZERO LINES AT FIRST
                MOV     NUMLEVEL, STARTLEVEL    ; INIT LEVEL NUMBER
                CALL    SHOWLINES               ; DISPLAY THEM

                MOV     AH, 2                   ; DISPLAY TITLE AND MY NAME
                MOV     DH, 1
                MOV     DL, 25
                MOV     BH, 0
                INT     10H
                LEA     DX, TETRISSTR
                CALL    DSPSTR

                MOV     AH, 2                   ; DISPLAY INSTRUCTIONS
                MOV     DH, 13
                MOV     DL, 0
                MOV     BH, 0
                INT     10H
                LEA     DX, INSTRUCTIONSTR
                CALL    DSPSTR

                LEA     SI, BLANKFIELD           ; ZERO PLAYFIELD
                LEA     DI, PLAYFIELD
                MOV     CX, ROWLENGTH*COLUMNLENGTH
SETUPGAME1:     MOV     AL, [SI]
                MOV     [DI], AL
                INC     SI
                INC     DI
                LOOP    SETUPGAME1

                CALL    RREST
                RET
SETUPGAME       ENDP

;
; NAME          PLAYGAME
;
; FUNCTION      PLAYS A GAME OF TETRIS
;
; INPUTS        NONE
;
; RETURNS       AX = 0 TO PLAY AGAIN, 1 TO QUIT

PLAYGAME        PROC    NEAR
                CALL    RSAVE
                MOV     AH, 0                   ; RANDOMIZE SEED WITH TIME
                INT     1Ah                     ; RETURNS TIME IN CX:DX
                XOR     CX, DX
                MOV     SEED, CX
                MOV     BL, 7                   ; GET A RANDOM # FOR 1ST BLOCK
                CALL    RANDOM8
                MOV     NEXT, DL
                CALL    SHOWNEXT                ; SHOW NEXT BLOCK
                CALL    NEWBLOCK                ; GET NEW BLOCK
PLAYGAME1:      CALL    HANDLEKBD               ; CHECK ANY KEYBOARD INPUT
                CMP     AX, 1                   ; WAS QUIT HIT?
                JE      PLAYGAMEDONE
                CALL    DROPBLOCK               ; CHECK TO SEE IF BLOCK
                CMP     AX, 0                   ;  DROP DOWN A LINE
                JE      PLAYGAME1
                MOV     AX, 0
PLAYGAMEDONE:   MOV     BP, SP                  ; RETURN AX
                MOV     16[BP], AX
                CALL    RREST
                RET
PLAYGAME        ENDP

;
; NAME          PLAYAGAIN
;
; FUNCTION      PROMPTS THE USER TO PLAY AGAIN OR QUIT AND RETURNS RESPONSE
;
; INPUTS        NONE
;
; RETURNS       AX = 0 TO PLAY AGAIN, 1 TO QUIT

PLAYAGAIN       PROC    NEAR
                PUSHM   <BX, DX>
                MOV     AH, 2                   ; TELL PLAYER HE LOST
                MOV     DL, 35
                MOV     DH, 4
                MOV     BH, 0
                INT     10h
                LEA     DX, GAMEOVER1
                CALL    DSPSTR

                MOV     AH, 2                   ; PROMPT USER TO PLAY AGAIN
                MOV     DL, 19
                MOV     DH, 5
                INT     10h
                LEA     DX, GAMEOVER2
                CALL    DSPSTR

                CALL    CLEARBUFFER             ; CLEAR KEYBOARD BUFFER
                CALL    KBDIN                   ; GET RESPONSE
                CMP     AL, QUIT                ; COMPARE TO QUIT KEY
                JE      PLAYAGAIN1
                MOV     AX, 0                   ; RETURN PLAY AGAIN
PLAYAGAINDONE:  POPM    <DX, BX>
                RET
PLAYAGAIN1:     MOV     AX, 1                   ; RETURN QUIT
                JMP     PLAYAGAINDONE
PLAYAGAIN       ENDP

;
; NAME          NEWBLOCK
;
; FUNCTION      GETS A NEW BLOCK AND DISPLAYS IT ON THE SCREEN.  CHECKS TO
;               SEE IF GAME IS OVER.
;
; INPUTS        NONE
;
; RETURNS       AX = 1 IF GAME IS OVER, 0 IF NOT OVER

NEWBLOCK        PROC    NEAR
                PUSHM   <BX, CX, DX>
                MOV     DROPFLAG, 0             ; NO MORE DROP
                CALL    SHOWNEXT
                MOV     DL, NEXT
                MOV     BLOCKTYPE, DL
                MOV     BL, 7                   ; GET A RANDOM BLOCK
                CALL    RANDOM8
                MOV     NEXT, DL                ; MAKE RANDOM BLOCKTYPE
                MOV     ROTATION, 0             ; MAKE ROTATION 0
                MOV     ROW, 22                 ; NEW BLOCKS APPEAR AT ROW 20
                MOV     COLUMN, 5               ; NEW BLOCKS APPEAR AT COL. 5
                CURRENTBLOCK
                CALL    CHECKBLOCK              ; SEE IF GAME IS OVER
                PUSH    CX
                MOV     WRITEMODE, WRITE_REPLACE
                MOV     DH, 1                   ; ADD TO MAP
                CALL    SHOWBLOCK               ;  AND PLOT BLOCK
                MOV     WRITEMODE, WRITE_XOR
                CALL    SHOWNEXT                ; SHOW NEXT BLOCK
                POP     AX
                CMP     AL, 1
                JE      GAMEOVER
                MOV     AX, 0
NEWBLOCK1:      POPM    <DX, CX, BX>
                CALL    CLEARBUFFER
                SETTIME 0
                RET
GAMEOVER:       MOV     AX, 1
                JMP     NEWBLOCK1
NEWBLOCK        ENDP

;
; NAME          HANDLEKBD
;
; FUNCTION      HANDLES ALL KEYBOARD INPUT DURIN GAMEPLAY.  IT FIRST CHECKS
;               SEE IF A KEY IS HIT.  IF NOT IT EXITS SUCCESSFULLY.
;               OTHERWISE IT HANDLES THE KEY.  IF THE KEY IS QUIT, A QUIT
;               IS RETURNED.
;
; INPUTS        NONE
;
; RETURNS       AX = 1 FOR GAME OVER, 0 FOR SUCCESSFUL TURN

HANDLEKBD       PROC    NEAR
                MOV     AX, 0
                CALL    RSAVE
                MOV     DROPFLAG, 0             ; DEFAULT IS NO DROP
                MOV     AH, 1                   ; CHECK TO SEE IF A KEY IS
                INT     16h                     ;  HIT
                JZ      HANDLEKBD1
                MOV     WRITEMODE, WRITE_XOR
                CALL    KBDIN                   ; YES SO GET IT
                CMP     AL, QUIT                ; CASE PARADIGM
                JE      QUITHIT
                CMP     AL, CCW
                JE      CCWHIT
                CMP     AL, CW
                JE      CWHIT
                CMP     AL, RIGHT
                JE      RIGHTHIT
                CMP     AL, LEFT
                JE      LEFTHIT
                CMP     AL, DROP
                JE      DROPHIT
HANDLEKBD1:     CALL    RREST
                RET

QUITHIT:        JMP     QUITHIT0                ; MUST HAVE THESES BECASUE
CCWHIT:         JMP     CCWHIT0                 ;  BRANCHES AREN'T LONG
CWHIT:          JMP     CWHIT0                  ;  ENOUGH TO REACH ALL THE
RIGHTHIT:       JMP     RIGHTHIT0               ;  ADDRESSES
LEFTHIT:        JMP     LEFTHIT0
DROPHIT:        JMP     DROPHIT0

QUITHIT0:       MOV     BP, SP                  ; RETURN AX = 1
                MOV     AX, 1
                MOV     16[BP], AX
                JMP     HANDLEKBD1

CCWHIT0:        CURRENTBLOCK                    ; ERASE BLOCK IN MEMORY
                CALL    PLACEBLOCK
                DECROTATION                     ; CHANGE ROTATION
                CURRENTBLOCK                    ; CHECK TO SEE IF IT WILL
                CALL    CHECKBLOCK              ;  FIT IN NEW POSITION
                CMP     CL, 0
                JNE     CCWHIT1
                INCROTATION                     ; IT FITS SO GO BACK TO
                CURRENTBLOCK                    ;  ORIGINAL POSITION
                MOV     DH, 0                   ;  AND ERASE ON THE SCREEN
                CALL    SHOWBLOCK
                DECROTATION                     ; NOW CHANGE TO NEW POSITION
                CURRENTBLOCK                    ;  AND DISPLAY NEW BLOCK
                MOV     DH, 1                   ;  IN MEMORY AND ON THE
                CALL    SHOWBLOCK               ;  SCREEN
                JMP     HANDLEKBD1              ; GET OUT OF HERE
CCWHIT1:        INCROTATION                     ; IT DOESN'T FIT SO PUT
                CURRENTBLOCK                    ;  THE BLOCK BACK IN MEMORY
                CALL    PLACEBLOCK              ; AND IGNORE THE MOVE
                JMP     HANDLEKBD1

CWHIT0:         CURRENTBLOCK                    ; ERASE BLOCK IN MEMORY
                CALL    PLACEBLOCK
                INCROTATION                     ; ROTATE CLOCKWISE
                CURRENTBLOCK                    ;  AND CHECK TO SEE IF BLOCK
                CALL    CHECKBLOCK              ;  FITS HERE
                CMP     CL, 0
                JNE     CWHIT1
                DECROTATION                     ; IT FITS SO GO BACK TO
                CURRENTBLOCK                    ;  ORIGINAL POSITION AND
                MOV     DH, 0                   ;  ERASE FROM THE SCREEN
                CALL    SHOWBLOCK
                INCROTATION                     ; CHANGE TO NEW POSITION
                CURRENTBLOCK                    ;  AND DISPLAY BLOCK IN
                MOV     DH, 1                   ;  MEMORY AND ON THE SCREEN
                CALL    SHOWBLOCK
                JMP     HANDLEKBD1
CWHIT1:         DECROTATION                     ; IT DOESN'T FIT AT NEW
                CURRENTBLOCK                    ;  POSITION SO GO BACK TO
                CALL    PLACEBLOCK              ;  ORIGINAL POSITION, PLACE
                JMP     HANDLEKBD1              ;  IT IN MEMORY AND RETURN

RIGHTHIT0:      CURRENTBLOCK                    ; ERASE BLOCK IN MEMORY
                CALL    PLACEBLOCK              ;  ONLY
                INC     COLUMN                  ; MOVE IT RIGHT AND SEE IF
                CURRENTBLOCK                    ;  WE HIT ANYTHING
                CALL    CHECKBLOCK
                CMP     CL, 0
                JNE     RIGHTHIT1               ; THE BLOCK FITS SO MOVE
                DEC     COLUMN                  ;  BACK TO ORIGINAL POSITION
                CURRENTBLOCK                    ;  AND ERASE IT FROM THE
                MOV     DH, 0                   ;  SCREEN THIS TIME
                CALL    SHOWBLOCK
                INC     COLUMN                  ; NOW GO TO NEW POSITION
                CURRENTBLOCK                    ;  AND PUT IT IN BOTH
                MOV     DH, 1                   ;  THE MEMORY AND SCREEN
                CALL    SHOWBLOCK
                JMP     HANDLEKBD1              ; RETURN HOME
RIGHTHIT1:      DEC     COLUMN                  ; IT DIDN'T FIT SO PUT
                CURRENTBLOCK                    ;  ORIGINAL BLOCK IN MEMORY
                CALL    PLACEBLOCK              ;  AGAIN AND RETURN
                JMP     HANDLEKBD1

LEFTHIT0:       CURRENTBLOCK                    ; ERASE BLOCK FROM MEMORY
                CALL    PLACEBLOCK              ;  ONLY
                DEC     COLUMN                  ; MOVE BLOCK LEFT AND CHECK
                CURRENTBLOCK                    ;  TO SEE IF WE ARE ABLE
                CALL    CHECKBLOCK              ;  TO MOVE THERE
                CMP     CL, 0
                JNE     LEFTHIT1                ; IT FITS SO GO BACK TO
                INC     COLUMN                  ;  ORIGINAL POSITION
                CURRENTBLOCK                    ;  AND ERASE FROM THE
                MOV     DH, 0                   ;  SCREEN ONLY
                CALL    SHOWBLOCK
                DEC     COLUMN                  ; MOVE LEFT AGAIN AND
                CURRENTBLOCK                    ;  PUT IT IN MEMORY AS
                MOV     DH, 1                   ;  WELL AS ON THE SCREEN
                CALL    SHOWBLOCK
                JMP     HANDLEKBD1              ; RETURN
LEFTHIT1:       INC     COLUMN                  ; IT DIDN'T FIT SO MOVE BACK
                CURRENTBLOCK                    ;  RIGHT AND PUT BACK
                CALL    PLACEBLOCK              ;  IN MEMROY
                JMP     HANDLEKBD1              ;  RETURN

DROPHIT0:       MOV     DROPFLAG, 1
                JMP     HANDLEKBD1
HANDLEKBD       ENDP

;
; NAME          DROPBLOCK
;
; FUNCTION      DROPS THE PIECE IF NECESSARY
;
; INPUTS        NONE
;
; RETURNS       AX = 0 IF SUCCESFUL OR NO DROP, 1 IF IT COULDN'T DROP

DROPBLOCK       PROC    NEAR
                MOV     AX, 0
                CALL    RSAVE
                CMP     DROPFLAG, 1             ; IF DROP KEY HIT THEN
                JE      DROPBLOCK2              ;  DROP IMMEDIATELY
                GETTIME AX                      ; GET CURRENT TIME
                CMP     AX, DELAY               ; SEE IF IT TIME TO DROP
                JA      DROPBLOCK2              ;  NO SO GET OUT OF HERE
                JMP     DROPBLOCK1
DROPBLOCK2:     GETTIME AX                      ; START OVER CLOCK
                MOV     DX, 0                   ; TAKE MOD OF DELAY. IT'S
                MOV     BX, DELAY               ;  ENOUGH TIME AND KEEPS
                DIV     BX                      ;  TICKS UNDER CONTROL
                SETTIME AX                      ; SET TIMER TO REMAINDER
                CURRENTBLOCK
                CALL    PLACEBLOCK              ; SEE IF WE ARE ABLE TO DROP
                DEC     ROW                     ;  BY DROPPING IN MEMORY
                CURRENTBLOCK                    ;  FIRST AND
                CALL    CHECKBLOCK              ;  AND CHECK A COLLISION
                CMP     CL, 1
                JE      DROPBLOCK3              ; NO SO GET OUT OF HERE
                INC     ROW                     ; OK, WE CAN DO IT
                CURRENTBLOCK                    ; FIRST ERASE BLOCK FROM
                MOV     DH, 0                   ;  SCREEN ONLY SINCE IT'S
                CALL    SHOWBLOCK               ;  ALREADY ERASED FROM MEMORY
                DEC     ROW                     ; DROP DOWN A ROW
                CURRENTBLOCK                    ;  AND REDISPLAY AT NEW
                MOV     DH, 1                   ;  POSITION IN MEMORY AND
                CALL    SHOWBLOCK               ;  ON SCREEN
DROPBLOCK1:     CALL    RREST
                RET
DROPBLOCK3:     INC     ROW                     ; PUT IT BACK WERE IT WAS
                CURRENTBLOCK
                CALL    PLACEBLOCK
                CALL    CHECKLINES              ; CHECK TO SEE IN ANY LINES
                                                ;  WERE CLEARED
                CALL    NEWBLOCK                ; GET NEW BLOCK
                MOV     BP, SP                  ; SET AX ACCORDINGLY
                MOV     16[BP], AX
                JMP     DROPBLOCK1
DROPBLOCK       ENDP

;
; NAME          CHECKLINES
;
; FUNCTION      CHECKS TO SEE IF ANY LINES WERE COMPLETED BY NEWLY PLACED
;               BLOCK.  IF SO TAKE CARE OF IT BY SHIFTING DOWN OTHER BLOCKS
;               AND CLEARING LINES
;
; INPUTS        AX = ROW WHERE BLOCK WAS PLACED
;
; RETURNS       NONE

CHECKLINES      PROC    NEAR
                CALL    RSAVE
                PUSH    AX
                MOV     CX, 4
                LEA     BX, LINES
CHECKLINES1:    MOV     BYTE PTR[BX], 0         ; INITIALLY NO LINES ARE CLEAR
                INC     BX
                LOOP    CHECKLINES1

; TAG THE 4 POSSIBLE LINES AS CLEARED OR NOT CLEARED
                MOV     CX, 4                   ; OUTER LOOP OF 4 LINES
                LEA     SI, LINES
CHECKLINES2:    CALL    CHECKLINE               ; CHECK EACH LINE INDIVIDUALLY
                MOV     [SI], BL                ; STORE RESULTS IN ARRAY
                ADD     NUMLINES, BX            ; INCREMENT LINE COUNTER
                DEC     AX                      ; DECREMENT ROW
                INC     SI                      ; INCREMENT ARRAY POINTER
                LOOP    CHECKLINES2

                LEA     BX, LINES
                POP     AX
                CALL    CHECKLEVEL              ; INCREASE LEVEL IF WE HAVE TO
                CALL    CLEARLINES              ; CLEAR THE LINES
                CALL    SHOWLINES
                CALL    RREST
                RET
CHECKLINES      ENDP


;
; NAME          CHECKLINE
;
; FUNCTION      CHECKS TO SEE IF LINE IS FULL
;
; INPUTS        AX = LINE TO CHECK
;
; RETURNS       BX = 0 IF NOT FULL, 1 IF FULL

CHECKLINE       PROC    NEAR
                MOV     BX, 0                   ; DEFAULT RETURN IS NOT FULL
                CMP     AX, 20                  ; CHECK ROW TOO LARGE
                JA      CHECKLINEDONE
                CMP     AX, 1                   ; CHECK ROW TOO SMALL
                JB      CHECKLINEDONE
                CALL    RSAVE
                MOV     CX, COLUMNLENGTH        ; ADJUST ROW FOR (0,0) AT
                SUB     CX, AX                  ;  LOWER LEFT INSTEAD OF
                DEC     CX                      ;  AT UPPER RIGHT OF FIELD
                MOV     AX, CX

                LEA     SI, PLAYFIELD           ; SI WILL HOLD ADDRESS
                PUSH    DX                      ;  IN PLAYFIELD
                MOV     DX, ROWLENGTH
                MUL     DX
                ADD     SI, AX                  ; ADD IN OFFSET OF ROW*ROWLEN
                POP     DX

                MOV     CX, ROWLENGTH           ; CHECK ALL BLOCKS ALONG ROW
CHECKLINE1:     MOV     DL, [SI]                ; GET COLOR
                CMP     DL, 0                   ; IF BLACK THEN LINE CANNOT
                JE      CHECKLINE2              ;  BE FULL
                INC     SI
                LOOP    CHECKLINE1
                MOV     BX, 1                   ; GOT HERE, MUST BE FULL
CHECKLINE3:     MOV     BP, SP                  ; STORE BX
                MOV     14[BP], BX
CHECKLINE2:     CALL    RREST
CHECKLINEDONE:  RET
CHECKLINE       ENDP

;
; NAME          CLEARLINES
;
; FUNCTION      CLEARS THE LINES THAT ARE IN THE LINES ARRAY TAGGED AS
;               FULL.
;
; INPUTS        AX = FIRST LINE
;               BX = LINES ARRAY
;
; RETURNS       NONE

CLEARLINES      PROC    NEAR
                CALL    RSAVE
                MOV     WRITEMODE, WRITE_REPLACE
                PUSH    AX
                MOV     SI, BX
                PUSH    SI
                MOV     DI, SI
                MOV     CX, 4                   ; CHECK TO SEE IF WE NEED TO
CLEARLINES6:    CMP     BYTE PTR[DI], 1
                JE      CLEARLINES0
                INC     DI
                LOOP    CLEARLINES6
                POPM    <SI, AX>                ; DON'T CLEAR ANY LINES
                MOV     BX, 1
                CALL    PAUSE
                JMP     CLEARLINESDONE
CLEARLINES0:    MOV     BX, 6                   ; START CLEARING AT 2nd COL.
                MOV     CX, PLAYFIELDWIDTH/2    ; ERASE LINES SIMULTANEOUSLY
CLEARLINES1:    PUSHM   <AX, CX, SI>            ;  AND START FROM MIDDLE
                MOV     CX, 4                   ;  FOR EFFECT
CLEARLINES2:    CMP     BYTE PTR[SI], 1         ; SHOULD WE CLEAR THIS LINE
                JNE     CLEARLINES3
                MOV     DL, 0                   ; PLOT OVER IN BLACK
                MOV     DH, 1
                CALL    SHOWBOX
                PUSHM   <BX, AX>                ; PLOT MIRROR IMAGE OF BOX
                MOV     AX, 13
                SUB     AX, BX
                MOV     BX, AX
                POP     AX
                CALL    SHOWBOX
                POP     BX
CLEARLINES3:    INC     SI                      ; INCREMENT ROW
                DEC     AX
                LOOP    CLEARLINES2
                DEC     BX
                PUSH    BX                      ; PUASE FOR A SHORT WHILE
                MOV     BX, 3
                CALL    PAUSE
                POP     BX
                POPM    <SI, CX, AX>
                LOOP    CLEARLINES1             ; INCREMENT COLUMN

                POP     SI
                POP     AX
                MOV     CX, 4
CLEARLINES4:    CMP     BYTE PTR[SI], 1         ; CRUNCH LINES TOGETHER
                JNE     CLEARLINES5
                CALL    CRUNCH
CLEARLINES5:    INC     SI
                DEC     AX
                LOOP    CLEARLINES4
                CALL    DRAWFIELD               ; REDRAW FIELD
CLEARLINESDONE: MOV     WRITEMODE, WRITE_XOR
                CALL    RREST
                RET
CLEARLINES      ENDP

;
; NAME          DRAWFIELD
;
; FUNCTION      REDRAWS ENTIRE PLAYING FIELD USING THE PLAYFIELD ARRAY
;               AS ALL THE COLOR VALUES.
;
; INPUTS        NONE
;
; RETURNS       NONE

DRAWFIELD       PROC    NEAR
                CALL    RSAVE
                MOV     WRITEMODE, WRITE_REPLACE
                LEA     SI, PLAYFIELD           ; JUST GO IN A BIG
                MOV     AX, COLUMNLENGTH        ;  NESTED LOOP AND REDRAW
                MOV     CX, AX                  ;  THE WHOLE SCREEN IN
                DEC     CX                      ;  IN REPLACE MODE
                DEC     AX
DRAWFIELD1:     PUSH    CX
                MOV     BX, 0
                MOV     CX, ROWLENGTH
DRAWFIELD2:     MOV     DL, [SI]
                MOV     DH, 0
                CALL    SHOWBOX
                INC     SI
                INC     BX
                LOOP    DRAWFIELD2
                DEC     AX
                POP     CX
                LOOP    DRAWFIELD1
                MOV     WRITEMODE, WRITE_XOR
                CALL    RREST
                RET
DRAWFIELD       ENDP

;
; NAME          CRUNCH
;
; FUNCTION      CRUNCH LINES DOWN ON TOP OF CHOOSEN LINE
;
; INPUTS        AX = LINE TO CRUNCH
;
; RETURNS       NONE

CRUNCH          PROC    NEAR
                CALL    RSAVE
CRUNCH1:        CALL    MOVEDOWN                ; MOVE DOWN EVERY ROW
                INC     AX                      ; FROM AX UP
                CMP     AX, PLAYFIELDHEIGHT
                JBE     CRUNCH1
                CALL    RREST
CRUNCHDONE:     RET
CRUNCH          ENDP

;
; NAME          MOVEDOWN
;
; FUNCTION      MOVES A LINE TO THE LINE BELOW IT
;
; INPUTS        AX = LINE TO MOVE
;
; RETURNS       NONE

MOVEDOWN        PROC    NEAR
                CALL    RSAVE
                MOV     CX, COLUMNLENGTH        ; ADJUST (0,0) TO
                SUB     CX, AX                  ;  UPPER LEFT INSTEAD OF
                DEC     CX                      ;  AT LOWER LEFT OF FIELD
                MOV     AX, CX

                LEA     SI, PLAYFIELD           ; SI WILL HOLD ADDRESS
                MOV     DX, ROWLENGTH
                MUL     DX
                ADD     SI, AX                  ; ADD IN OFFSET OF ROW*ROWLEN
                ADD     SI, 2                   ; START AT 2nd COL.
                MOV     DI, SI                  ; SI POINTS TO THE LINE ABOVE
                SUB     SI, ROWLENGTH           ;  DI

                MOV     CX, PLAYFIELDWIDTH      ; JUST LOOP AND COPY
MOVEDOWN1:      MOV     AL, [SI]                ;  THE BLOCKS
                MOV     [DI], AL
                INC     SI
                INC     DI
                LOOP    MOVEDOWN1

                CALL    RREST
                RET
MOVEDOWN        ENDP

;
; NAME          CHECKLEVEL
;
; FUNCTION      CHECKS TO SEE IF LEVEL SHOULD BE INCREASED
;
; INPUTS        NONE
;
; RETURNS       NONE

CHECKLEVEL      PROC    NEAR
                CALL    RSAVE
                MOV     AX, NUMLEVEL            ; CHECK TO SEE IF TOTAL LINES
                CWD                             ;  IS GREATER THAN 10 TIMES
                MOV     BX, 10                  ;  THE LEVEL
                MUL     BX
                CMP     NUMLINES, AX
                JB      CHECKLEVELDONE
                INC     NUMLEVEL                ; INCREASE LEVEL NUMBER
                SUB     DELAY, NEXTDELAY
                CMP     DELAY, 1
                JG      CHECKLEVELDONE
                MOV     DELAY, 1
CHECKLEVELDONE: CALL    RREST
                RET
CHECKLEVEL      ENDP

;
; NAME          SHOWLINES
;
; FUNCTIONS     DISPLAYS HOW MANY LINES HAVE BEEN COMPLETED AT THE TOP
;
; INPUTS        NONE
;
; RETURNS       NONE

SHOWLINES       PROC    NEAR
                CALL    RSAVE
                MOV     AH, 2                   ; SPECIFY LOCATION
                MOV     DH, 8                   ; ROW
                MOV     DL, 36                  ; COLUMN
                MOV     BH, 0
                INT     10h
                LEA     DX, LINESSTR
                CALL    DSPSTR

                MOV     AX, NUMLINES            ; GET NUMBER OF LINES
                MOV     DL, 100                 ; PRINT 100'S DIGIT
                DIV     DL                      ; GET IT BY DIVIDING BY 100
                ADD     AL, '0'
                MOV     DL, AL
                CALL    DSPOUT
                MOV     AL, AH
                CBW
                MOV     DL, 10                  ; 10'S DIGIT OBTAINED BY
                DIV     DL                      ;  DIVIDING BY 100
                ADD     AL, '0'
                MOV     DL, AL
                CALL    DSPOUT
                ADD     AH, '0'
                MOV     DL, AH
                CALL    DSPOUT

                MOV     AH, 2                   ; MOVE CURSOR
                MOV     DH, 20                  ; ROW
                MOV     DL, 55                  ; COLUMN
                MOV     BH, 0
                INT     10h
                LEA     DX, LEVELSTR
                CALL    DSPSTR

                MOV     AX, NUMLEVEL            ; PRINT OUT ACTUAL LEVEL
                MOV     DL, 10                  ;  IN THE SAME MANNER AS
                DIV     DL                      ;  THE LINES WERE DONE
                ADD     AL, '0'
                MOV     DL, AL
                CALL    DSPOUT
                ADD     AH, '0'
                MOV     DL, AH
                CALL    DSPOUT

                CALL    RREST
                RET
SHOWLINES       ENDP

;
; NAME          SHOWNEXT
;
; FUNCTION      XOR'S THE NEXT BLOCK ONTO THE SCREEN AT THE SPECIFIED
;               LOCATION
;
; INPUTS        NONE
;
; RETURNS       NONE

SHOWNEXT        PROC    NEAR
                CALL    RSAVE
                MOV     AL, WRITEMODE           ; SAVE WRITE MODE
                MOV     TEMPDB, AL
                MOV     WRITEMODE, WRITE_XOR
                MOV     AX, NEXTLINE
                MOV     BX, NEXTBYTE
                SHRINK  NEXT, 0
                LEA     SI, BLOCKS              ; SI POINTS TO BASE
                PUSH    AX
                PUSH    DX
                MOV     AL, DL                  ; ADD TO SI THE SIZE OF
                MOV     AH, 0                   ;  ONE BLOCK TIMES THE BLOCK
                MOV     DX, BLOCKSIZE           ;  WANTED SO SI POINT TO THE
                MUL     DX                      ;  FIRST BYTE OF THE BLOCK
                ADD     SI, AX                  ;  TO BE DISPLAYED
                POP     DX
                POP     AX

                MOV     CX, BLOCKHEIGHT         ; OUTER LOOP OF HEIGHT
SHOWNEXT1:      PUSH    BX                      ; SAVE BX FOR OUTER LOOP
                PUSH    CX                      ; SAVE THIS CX FOR OUTERLOOP
                MOV     CX, BLOCKWIDTH          ; DISPLAY WIDTH OF BLOCK
SHOWNEXT2:      MOV     DL, [SI]                ; GET COLOR
                CALL    WRITEBOX                ; SHOW BOX
                INC     SI                      ; POINT TO NEXT BYTE
                INC     BX                      ; MOVE OVER A ROW
                INC     BX
                LOOP    SHOWNEXT2
                POP     CX
                POP     BX
                ADD     AX, BOXHEIGHT
                LOOP    SHOWNEXT1
                CALL    RREST
                MOV     AL, TEMPDB              ; RESTORE WRITE MODE
                MOV     WRITEMODE, AL
                RET
                CALL    RSAVE
SHOWNEXT        ENDP


;
; NAME          DISPLAYCOLORS
;
; FUNCTION      DISPLAYS ALL 16 COLORS, EACH COLOR AS BARS 30 PIXELS WID FOR
;               THE ENTIRE SCREEN
;
; INPUTS        NONE
;
; RETURNS       NONE

DISPLAYCOLORS   PROC    NEAR
                CALL    RSAVE
                MOV     AL, WRITEMODE           ; SAVE CURRENT WRITEMODE
                PUSH    AX
                MOV     WRITEMODE, WRITE_REPLACE
                MOV     AX, 0                   ; START AT ROW 0
DISPLAYCOLORS1: MOV     BX, 0                   ; START AT BYTE 0
                MOV     DL, 0
                MOV     DH, 0FFh                ; CHANGE WHOLE BYTE
DISPLAYCOLORS2: MOV     CX, 5                   ; DISPLAY 5 BYTES OF ONE
DISPLAYCOLORS3: CALL    SETVGABYTE              ;  COLOR
                INC     BX
                LOOP    DISPLAYCOLORS3
                INC     DL                      ; CHANGE COLOR
                CMP     DL, 16
                JB      DISPLAYCOLORS2
                INC     AX                      ; INCREASE LINE
                CMP     AX, 640
                JB      DISPLAYCOLORS1
                POP     AX
                MOV     WRITEMODE, AL
                CALL    RREST
                RET
DISPLAYCOLORS   ENDP

;
; NAME          WRITEBOX
;
; FUNCTION      WRITES A BOX OF BOXTYPE TO THE SCREEN
;
; INPUTS        AX = ROW
;               BX = BYTE
;               DL = COLOR
;
; RETURNS       NONE

WRITEBOX        PROC    NEAR
                PUSHM   <AX, BX, CX, DX>
                CMP     DL, 0
                JE      WRITEBOX4
                MOV     DH, 01010101b           ; DITHER EVERY OTHER PIXEL
                CALL    SETVGABYTE
                INC     BX
                CALL    SETVGABYTE
                DEC     BX

                PUSH    DX
                MOV     DL, 0Fh                 ; WHITE IS IN BETWEEN
                MOV     DH, 10101010b
                CALL    SETVGABYTE
                INC     BX
                CALL    SETVGABYTE
                DEC     BX
                POP     DX

                MOV     CX, BOXHEIGHT
                DEC     CX
                DEC     CX
                SHR     CX, 1
                INC     AX
                PUSH    AX
WRITEBOX2:      MOV     DH, 11111111b
                CALL    SETVGABYTE
                INC     AX
                MOV     DH, 01111111b           ; WRITE LEFT HALF OF BLOCK
                CALL    SETVGABYTE
                PUSH    DX
                MOV     DL, 0Fh
                MOV     DH, 10000000b
                CALL    SETVGABYTE
                POP     DX
                INC     AX
                LOOP    WRITEBOX2

                MOV     DH, 01010101b
                CALL    SETVGABYTE
                POP     AX

                INC     BX
                MOV     CX, BOXHEIGHT
                DEC     CX
                DEC     CX
                SHR     CX, 1
WRITEBOX3:      MOV     DH, 11111111b           ; WRITE RIGHT HALF OF BLOCK
                CALL    SETVGABYTE
                INC     AX
                MOV     DH, 11111110b
                CALL    SETVGABYTE
                INC     AX
                LOOP    WRITEBOX3

                MOV     DH, 01010101b
                CALL    SETVGABYTE

WRITEBOXDONE:   POPM    <DX, CX, BX, AX>
                RET

WRITEBOX4:      MOV     CX, BOXHEIGHT           ; DISPLAY ALL BLACK
WRITEBOX5:      MOV     DH, 11111111b
                CALL    SETVGABYTE
                INC     BX
                CALL    SETVGABYTE
                DEC     BX
                INC     AX
                LOOP    WRITEBOX5
                JMP     WRITEBOXDONE
WRITEBOX        ENDP

;
; NAME          SHOWBOX
;
; FUNCTIONS     SHOWS A BOX IN THE PLAY FIELD AT SPECIFIED ROW AND COLUMN.
;               PLAYFIELD IS 14 (0..13) WIDE, AND 23 (0..22) HIGH.  COLUMNS
;               LESS THAN 2 AND MORE THAN 11 WILL BE CLIPPED.  ROWS MORE THAN
;               20 AND LESS THAN 1 WILL BE CLIPPED.
;
; INPUTS        AX = ROW
;               BX = COLUMN
;               DL = COLOR
;               DH = 0 TO NOT PLACE IN MAP, 1 TO PLACE IN MAP ALSO
;
; RETURNS       NONE

SHOWBOX         PROC    NEAR
                CMP     AX, 20                  ; CHECK ROW TOO LARGE
                JA      SHOWBOXDONE
                CMP     AX, 1                   ; CHECK ROW TOO SMALL
                JB      SHOWBOXDONE
                CMP     BX, 11                  ; CHECK COLUMN TOO LARGE
                JA      SHOWBOXDONE
                CMP     BX, 2                   ; CHECK COLUMN TOO SMALL
                JB      SHOWBOXDONE
                CALL    RSAVE
                CMP     DH, 0
                JE      SHOWBOX1
                CALL    PLACEBOX                ; PLACE BOX IN MAP
SHOWBOX1:       PUSH    DX                      ; SAVE COLOR
                MOV     DX, BOXHEIGHT           ; CALCULATE LINE TO PLACE
                MUL     DX
                MOV     DX, AX
                MOV     AX, PLAYFIELDLINE
                SUB     AX, DX
                PUSH    AX                      ; SAVE THIS LINE
                MOV     AX, BX                  ; CALCULATE BYTE TO PLACE
                MOV     DX, BOXWIDTH
                MUL     DX
                MOV     BX, AX
                MOV     DX, PLAYFIELDBYTE
                ADD     BX, DX
                POP     AX                      ; GET LINE BACK
                POP     DX                      ; GET COLOR BACK
                CALL    WRITEBOX                ; WRITE BOX TO SCREEN
                CALL    RREST
SHOWBOXDONE:    RET
SHOWBOX         ENDP

;
; NAME          PLACEBOX
;
; FUNCTION      PLACES BOX IN THE PLAYFIELD MAP
;
; INPUTS        AX = ROW
;               BX = COLUMN
;               DL = COLOR
;
; RETURNS       NONE

PLACEBOX        PROC    NEAR
                CMP     AX, 20                  ; CHECK ROW TOO LARGE
                JA      PLACEBOXDONE1
                CMP     AX, 1                   ; CHECK ROW TOO SMALL
                JB      PLACEBOXDONE1
                CMP     BX, 11                  ; CHECK COLUMN TOO LARGE
                JA      PLACEBOXDONE1
                CMP     BX, 2                   ; CHECK COLUMN TOO SMALL
                JB      PLACEBOXDONE1
                CALL    RSAVE
                MOV     CX, COLUMNLENGTH        ; ADJUST ROW FOR (0,0) AT
                SUB     CX, AX                  ;  LOWER LEFT INSTEAD OF
                DEC     CX                      ;  AT UPPER RIGHT OF FIELD
                MOV     AX, CX

                LEA     SI, PLAYFIELD           ; SI WILL HOLD ADDRESS
                PUSH    DX                      ;  IN PLAYFIELD
                MOV     DX, ROWLENGTH
                MUL     DX
                ADD     SI, AX                  ; ADD IN OFFSET OF ROW*ROWLEN
                ADD     SI, BX                  ; ADD IN OFFSET OF COLUMN
                POP     DX

                MOV     CL, WRITEMODE           ; USE CURRENT WRITE MODE
                CMP     CL, WRITE_REPLACE
                JE      PLBOXREPLACE
                CMP     CL, WRITE_AND
                JE      PLBOXAND
                CMP     CL, WRITE_OR
                JE      PLBOXOR
                CMP     CL, WRITE_XOR
                JE      PLBOXXOR
PLACEBOXDONE:   CALL    RREST
PLACEBOXDONE1:  RET

PLBOXREPLACE:   MOV     [SI], DL
                JMP     PLACEBOXDONE
PLBOXAND:       AND     [SI], DL
                JMP     PLACEBOXDONE
PLBOXOR:        OR      [SI], DL
                JMP     PLACEBOXDONE
PLBOXXOR:       XOR     [SI], DL
                JMP     PLACEBOXDONE
PLACEBOX        ENDP

;
; NAME          CHECKBOX
;
; FUNCTION      CHECKS TO SEE IF THE BOX CAN BE PLACED ON THE SCREEN AT
;               SPECIFIED LOCATION.
;
; INPUTS        AX = ROW
;               BX = COLUMN
;               DL = COLOR
;
; RETURNS       CL = 0 IF LEGAL, 1 IF ILLEGAL

CHECKBOX        PROC    NEAR
                CALL    RSAVE
                MOV     CX, COLUMNLENGTH        ; ADJUST ROW FOR (0,0) AT
                SUB     CX, AX                  ;  LOWER LEFT INSTEAD OF
                DEC     CX                      ;  AT UPPER RIGHT OF FIELD
                MOV     AX, CX

                LEA     SI, PLAYFIELD           ; SI WILL HOLD ADDRESS
                PUSH    DX                      ;  IN PLAYFIELD
                MOV     DX, ROWLENGTH
                MUL     DX
                ADD     SI, AX                  ; ADD IN OFFSET OF ROW*ROWLEN
                ADD     SI, BX                  ; ADD IN OFFSET OF COLUMN
                POP     DX


                MOV     CL, [SI]                ; GET SCREEN COLOR
                CMP     CL, 0                   ; MAKE CL EITHER 0 OR FFh
                JE      CHECKBOX2               ;  WHERE 0 = NO COLOR AND
                MOV     CL, 0FFh                ;  FFh = ANY COLOR. OTHERWISE
CHECKBOX2:      AND     CL, DL                  ;  SOME COLLISIONS MAY GO
                CMP     CL, 0                   ;  UNDETECTED.
                JE      CHECKBOX1
                MOV     CL, 1
CHECKBOX1:      MOV     BP, SP                  ; RETURN CX, SO STOR ON STACK
                MOV     12[BP], CX
                CALL    RREST
                RET
CHECKBOX        ENDP

;
; NAME          SHOWBLOCK
;
; FUNCTION      SHOWS A BLOCK OF DESIRED TYPED AND ROTATION ON THE SCREEN
;               AT THE SPECIFIED LOCATION.
;
; INPUTS        AX = ROW
;               BX = COLUMN
;               DL = BLOCK TYPE (IN COMPRESSED BLOCK FORMAT)
;               DH = 0 NOT TO PLACE IN MAP , 1 TO PLACE IN MAP ALSO

SHOWBLOCK       PROC    NEAR
                CALL    RSAVE
                LEA     SI, BLOCKS              ; SI POINTS TO BASE
                PUSH    AX
                PUSH    DX
                MOV     AL, DL                  ; ADD TO SI THE SIZE OF
                MOV     AH, 0                   ;  ONE BLOCK TIMES THE BLOCK
                MOV     DX, BLOCKSIZE           ;  WANTED SO SI POINT TO THE
                MUL     DX                      ;  FIRST BYTE OF THE BLOCK
                ADD     SI, AX                  ;  TO BE DISPLAYED
                POP     DX
                POP     AX

                MOV     CX, BLOCKHEIGHT         ; OUTER LOOP OF HEIGHT
SHOWBLOCK1:     PUSH    BX                      ; SAVE BX FOR OUTER LOOP
                PUSH    CX                      ; SAVE THIS CX FOR OUTERLOOP
                MOV     CX, BLOCKWIDTH          ; DISPLAY WIDTH OF BLOCK
SHOWBLOCK2:     MOV     DL, [SI]                ; GET COLOR
                CALL    SHOWBOX                 ; SHOW BOX
                INC     SI                      ; POINT TO NEXT BYTE
                INC     BX                      ; MOVE OVER A ROW
                LOOP    SHOWBLOCK2
                POP     CX
                POP     BX
                DEC     AX
                LOOP    SHOWBLOCK1

                CALL    RREST
                RET
SHOWBLOCK       ENDP

;
; NAME          PLACEBLOCK
;
; FUNCTION      PLACES A BLOCK IN THE PLAYFIELD MAP
;
; INPUTS        AX = ROW
;               BX = COLUMN
;               DL = BLOCK TYPE (IN COMPRESSED FORMAT)
;
; RETURNS       NONE

PLACEBLOCK      PROC    NEAR
                CALL    RSAVE
                LEA     SI, BLOCKS              ; SI POINTS TO BASE
                PUSH    AX
                PUSH    DX
                MOV     AL, DL                  ; ADD TO SI THE SIZE OF
                MOV     AH, 0                   ;  ONE BLOCK TIMES THE BLOCK
                MOV     DX, BLOCKSIZE           ;  WANTED SO SI POINT TO THE
                MUL     DX                      ;  FIRST BYTE OF THE BLOCK
                ADD     SI, AX                  ;  TO BE DISPLAYED
                POP     DX
                POP     AX

                MOV     CX, BLOCKHEIGHT         ; OUTER LOOP OF HEIGHT
PLACEBLOCK1:    PUSH    BX                      ; SAVE BX FOR OUTER LOOP
                PUSH    CX                      ; SAVE THIS CX FOR OUTERLOOP
                MOV     CX, BLOCKWIDTH          ; DISPLAY WIDTH OF BLOCK
PLACEBLOCK2:    MOV     DL, [SI]                ; GET COLOR
                CALL    PLACEBOX                ; PLACE BOX
                INC     SI                      ; POINT TO NEXT BYTE
                INC     BX                      ; MOVE OVER A ROW
                LOOP    PLACEBLOCK2
                POP     CX
                POP     BX
                DEC     AX
                LOOP    PLACEBLOCK1
                CALL    RREST
                RET
PLACEBLOCK      ENDP

;
; NAME          CHECKBLOCK
;
; FUNCTION      CHECKS TO SEE IF BOX AT THIS POSITION IS LEGAL.
;
; INPUTS        AX = ROW
;               BX = COLUMN
;               DL = BLOCK TYPE (IN COMPRESSED FORMAT)
;
;               CL = 0 IF LEGAL, 1 IF ILLEGAL

CHECKBLOCK      PROC    NEAR
                CALL    RSAVE
                LEA     SI, BLOCKS              ; SI POINTS TO BASE
                PUSH    AX
                PUSH    DX
                MOV     AL, DL                  ; ADD TO SI THE SIZE OF
                MOV     AH, 0                   ;  ONE BLOCK TIMES THE BLOCK
                MOV     DX, BLOCKSIZE           ;  WANTED SO SI POINT TO THE
                MUL     DX                      ;  FIRST BYTE OF THE BLOCK
                ADD     SI, AX                  ;  TO BE DISPLAYED
                POP     DX
                POP     AX

                MOV     CX, BLOCKHEIGHT         ; OUTER LOOP OF HEIGHT
CHECKBLOCK1:    PUSH    BX                      ; SAVE BX FOR OUTER LOOP
                PUSH    CX                      ; SAVE THIS CX FOR OUTERLOOP
                MOV     CX, BLOCKWIDTH          ; DISPLAY WIDTH OF BLOCK
CHECKBLOCK2:    MOV     DL, [SI]                ; GET COLOR
                PUSH    CX
                CALL    CHECKBOX                ; PLACE BOX
                CMP     CL, 1
                JE      CHECKBLOCK4
                POP     CX
                INC     SI                      ; POINT TO NEXT BYTE
                INC     BX                      ; MOVE OVER A ROW
                LOOP    CHECKBLOCK2
                POP     CX
                POP     BX
                DEC     AX
                LOOP    CHECKBLOCK1
                MOV     CL, 0
CHECKBLOCK3:    MOV     BP, SP                  ; RETURN CX
                MOV     12[BP], CX
                CALL    RREST
                RET
CHECKBLOCK4:    POP     CX
                POP     CX
                POP     BX
                MOV     CL, 1
                JMP     CHECKBLOCK3
CHECKBLOCK      ENDP


COMMENT         *
                Here are all the utility functions that deal with everything
                from graphics to register saving.
                *

;
; NAME          CLEARSCREEN
;
; FUNCTION      CLEARS SCREEN TO DESIRED COLOR
;
; INPUTS        DL = COLOR
;
; RETURNS       NONE

CLEARSCREEN     PROC    NEAR
                CALL    RSAVE
                MOV     AX, 0
                SETWRITEMODE    WRITE_REPLACE
                MOV     DH, 0FFh                ; USE WHOLE BIT MASK
CLEARSCREEN1:   MOV     BX, 0
CLEARSCREEN2:   CALL    SETVGABYTE
                INC     BX
                CMP     BX, BYTESPERROW
                JB      CLEARSCREEN2
                INC     AX
                CMP     AX, 640
                JB      CLEARSCREEN1
                CALL    RREST
                RET
CLEARSCREEN     ENDP

;
; NAME          DRAWRECT
;
; FUNCTION      DRAWS A RECTANGLE GIVEN THE WIDTH, HEGIHT, AND STARTING
;               PIXEL POINT.
;
; INPUTS        BX = POINTER TO RECT STURCTURE
;
; RETURNS       NONE



DRAWRECT        PROC    NEAR
                CALL    RSAVE
                MOV     SI, BX
                MOV     AX, [SI].RROW           ; GET BASE POINT
                MOV     BX, [SI].RCOLUMN
                MOV     DL, [SI].RCOLOR         ; GET COLOR

                MOV     CX, [SI].RWIDTH         ; DRAW LINE ACROSS TOP
DRAWRECT1:      CALL    SETVGAPIXEL
                INC     BX
                LOOP    DRAWRECT1

                MOV     CX, [SI].RHEIGHT        ; DRAW LINE DOWN RIGHT SIDE
DRAWRECT2:      CALL    SETVGAPIXEL
                INC     AX
                LOOP    DRAWRECT2

                MOV     CX, [SI].RWIDTH         ; DRAW ACROSS BOTTOM
DRAWRECT3:      CALL    SETVGAPIXEL
                DEC     BX
                LOOP    DRAWRECT3

                MOV     CX, [SI].RHEIGHT        ; DRAW LINE UP LEFT SIDE
DRAWRECT4:      CALL    SETVGAPIXEL
                DEC     AX
                LOOP    DRAWRECT4

                CALL    RREST
                RET
DRAWRECT        ENDP



;
; NAME          PIXELADDR
;
; FUNCTION      COMPUTES THE PIXEL ADDRESS FOR NATIVE EGA AND VGA MODES
;               USES FORMULA:
;                         BYTES PER ROW = HORIZONTAL RESOLUTION
;                         NUMBER OF ROW = VERTICAL RESOLUTION
;                         OFFSET = (BYTES PER ROW) * Y + INT(X/8)
;                         BIT # = 7 - (X MOD 8)
;
; INPUTS        AX = Y-COORDINATE
;               BX = X-COORDINATE
;
; RETURNS       AH = BIT MASK
;               BX = BYTE OFFSET IN BUFFER
;               CL = NUMBER OF BITS TO SHIFT LEFT
;               ES = VIDEO BUFFER SEGMENT

BYTESPERROW     EQU     80
VIDEORAM        EQU     0A000h

PIXELADDR       PROC    NEAR
                MOV     CL, BL                  ; CL = LOW-BYTE OF X COORD
                PUSH    DX                      ; SAVE DX
                MOV     DX, BYTESPERROW         ; AX = Y * BYTES PER ROW
                MUL     DX
                POP     DX
                SHR     BX, 1                   ; BX = X/8
                SHR     BX, 1
                SHR     BX, 1
                ADD     BX, AX                  ; BX = OFFSET
                MOV     AX, VIDEORAM
                MOV     ES, AX
                AND     CL, 7                   ; CL = X MOD 8
                XOR     CL, 7                   ; CL = 7 - (X MOD 8)
                MOV     AH, 1
                RET
PIXELADDR       ENDP

;
; NAME          BYTEADDR
;
; FUNCTION      COMPUTES THE ADDRESS FOR NATIVE EGA AND VGA MODES
;               USES FORMULA:
;                         BYTES PER ROW = HORIZONTAL RESOLUTION
;                         NUMBER OF ROW = VERTICAL RESOLUTION
;                         OFFSET = (BYTES PER ROW) * Y + BYTENUM
;                         BIT # = 7 - (X MOD 8)
;
; INPUTS        AX = Y-COORDINATE
;               BX = BYTE NUMBER TO SET
;
; RETURNS       BX = BYTE OFFSET IN BUFFER
;               ES = VIDEO BUFFER SEGMENT

BYTESPERROW     EQU     80
VIDEORAM        EQU     0A000h

BYTEADDR        PROC    NEAR
                PUSH    AX
                PUSH    DX                      ; SAVE DX
                MOV     DX, BYTESPERROW         ; AX = Y * BYTES PER ROW
                MUL     DX
                POP     DX
                ADD     BX, AX                  ; BX = Y * B.P.R + BYTE NUMBER
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
                MOV     AH, WRITEMODE           ; GET CURRENT WRITE MODE
                MOV     AL, 3
                OUT     DX, AX
                MOV     AX, 205h
                OUT     DX, AX
                MOV     AL, ES:[BX]
                POP     AX
                MOV     ES:[BX], AL
                MOV     AX, 0FF08h
                OUT     DX, AX
                MOV     AX, 0005
                OUT     DX, AX
                MOV     AX, 0003                ; SET ROTATE/FUNCTION DEFALUT
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

SETVGABYTE      PROC    NEAR
                CALL    RSAVE
                PUSH    DX                      ; SAVE PIXEL VALUE
                CALL    BYTEADDR                ; GET PIXEL ADDRESS
                MOV     DX, 3CEh                ; PORT ADDRESS OF VGA REGS
                POP     AX                      ; GET BYTE NUMBER IN AH
                PUSH    AX
                MOV     AL, 8                   ; SET BIT MASK REGISTER
                OUT     DX, AX
                MOV     AH, WRITEMODE           ; SET CURRENT WRITE MODE
                MOV     AL, 3
                OUT     DX, AX
                MOV     AX, 205h                ; SET TO WRITE MODE 2
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
                CALL    RREST
                RET
SETVGABYTE      ENDP

;
; NAME          SET640x480x16
;
; FUNCTION      STARTS UP VGA GRAPHICS MODE IN 640x480x16 MODE.
;
; INPUTS        NONE
;
; RETURNS       NONE

SET640x480x16   PROC    NEAR
                PUSH    AX                      ; SAVE AX
                MOV     AH, 0                   ; SELECT VIDEO MODE FUNCTION
                MOV     AL, 12h                 ; VGA 640x480x16 MODE
                INT     10h
                POP     AX
                RET
SET640x480x16   ENDP

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

;
; NAME          RSAVE
;
; FUNCTION      SAVES AX, BX, CX, DX, BP, SI, DI, DS, & ES REGISTERS ON THE
;               STACK IN THAT ORDER.
;
; INPUTS        NONE
; RETURNS       NONE

RSAVE           PROC    NEAR
                PUSHM   <BX, CX, DX, BP, SI, DI, DS, ES>
                MOV     BP, SP
                XCHG    AX, 16[BP]              ; SWAP RETURN ADDRESS AND AX
                PUSH    AX                      ; PUT RETURN ADDRES ON TOS
                MOV     AX, 16[BP]              ; SET AX TO ORIGINAL VALUE
                MOV     BP, 8[BP]               ; SET BP TO ORIGINAL VALUE
                RET
RSAVE           ENDP

;
; NAME          KBDIN
;
; FUNCTION      WAITS FOR A CHARACTER TO BE TYPED AND RETURNS THE CODE IN AL.
;
; INPUTS        NONE
;
; RETURNS       AL = ASCII CODE OF CHARACTER TYPED

KBDIN           PROC    NEAR
                MOV     KBDINTMP, AH            ; SAVE AH
                MOV     AH, 7                   ; USE DOS
                INT     21h
                MOV     AH, KBDINTMP
                RET
KBDINTMP        DB      ?
KBDIN           ENDP

;
; NAME          DSPOUT
;
; FUNCTION      DISPLAY THE ASCII CHARACTER IN DL TO THE SCREEN AT THE
;               CURRENT LOCATION.
;
; INPUTS        DL = CHARACTER
;
; RETURNS       NONE

DSPOUT          PROC    NEAR
                PUSH    AX                      ; USE DOS
                MOV     AH, 2
                INT     21H
                POP     AX
                RET
DSPOUT          ENDP

;
; NAME          DSPSTR
;
; FUNCTION      DISPLAYS A '$'-TERMINATED STRING TO THE SCREEN
;
; INPUTS        DX = OFFSET OF STRING
;
; OUTPUTS       NONE

DSPSTR          PROC    NEAR
                PUSH    AX                      ; USE DOS
                MOV     AH, 9
                INT     21H
                POP     AX
                RET
DSPSTR          ENDP

;
; NAME          DUMPMAP
;
; FUNCTION      DUMPS THE PLAYFIELD'S CONTENTS TO THE SCREEN
;
; INPUTS        NONE
;
; RETURNS       NONE

DUMPMAP         PROC    NEAR
                CALL    RSAVE
                MOV     AH, 2                   ; SET CURSOR TO 0,0
                MOV     DH, 0
                MOV     DL, 0
                MOV     BH, 0
                INT     10h

                LEA     SI, PLAYFIELD
                MOV     BL, 01                  ; SET COLOR TO BLUE
                MOV     CX, COLUMNLENGTH
DUMPMAP1:       PUSH    CX                      ; OUTER LOOP OF ROWS
                MOV     CX, ROWLENGTH
DUMPMAP2:       MOV     DL, [SI]                ; INNER LOOP OF COLUMNS
                ADD     DL, '0'
                CMP     DL, '0'
                JE      DUMPMAP3
                MOV     DL, '1'
DUMPMAP3:       CALL    DSPOUT
                INC     SI
                LOOP    DUMPMAP2
                MOV     DL, CR
                CALL    DSPOUT
                MOV     DL, LF
                CALL    DSPOUT
                POP     CX
                LOOP    DUMPMAP1

                CALL    RREST
                RET
DUMPMAP         ENDP

;
; NAME          RREST
;
; FUNCTION      POPS ES, DS, DI, SI, BP, DX, CX, BX, & AX REGISTERS FROM THE
;               STACK IN THAT ORDER.
;
; INPUTS        NONE
; RETURNS       NONE

RREST           PROC    NEAR
                POP     AX                      ; AX = RETURN ADDRESS
                MOV     BP, SP
                XCHG    AX, 16[BP]              ; SWAP SAVED AX AND ADDRESS
                POPM    <ES, DS, DI, SI, BP, DX, CX, BX>
                RET
RREST           ENDP

;
; NAME          PUASE
;
; FUNCTION      PUASES FOR AMOUNT SPECIFIED IN BX, WHERE 25 IS APPROX. 1
;               SECOND.
;
; INPUTS        BX = DURATION
;
; RETURNS       NONE

PAUSE           PROC    NEAR
                PUSHM   <BX,CX>
PAUSE1:         MOV     CX, 07FFFh
PAUSE2:         DEC     CX
                JNE     PAUSE2
                DEC     BX
                JNE     PAUSE1
                POPM    <CX, BX>
                RET
PAUSE           ENDP

;
; NAME          CLEARBUFFER
;
; FUNCTION      CLEARS THE KEYBOARD BUFFER
;
; INPUTS        NONE
;
; RETURNS       NONE

CLEARBUFFER     PROC    NEAR
                PUSH    AX
CLEARBUFFER1:   MOV     AH, 1           ; CHECK TO SEE IF THERE ARE KEYS
                INT     16h             ;  WAITING
                JZ      CLEARBUFFER2
                CALL    KBDIN           ; GET A KEY THAT'S IN BUFFER
                JMP     CLEARBUFFER1    ; CHECK BUFFER AGAIN
CLEARBUFFER2:   POP     AX              ; RESTORE AX
                RET
CLEARBUFFER     ENDP

; Subroutine RANDOM8: Generate 8-bit pseudo random numbers
;	Inputs	SEED -- random number seed
;		(BL) -- maximum+1 random value desired
;	Output  (DL) -- 8-bit random value, with range  0 <= (DL) < (BL)
;		(DH) -- 0
RANDOM8	PROC	NEAR
	CALL	RSAVE			; Save everything
        CALL    RAND                    ; GET A 16-BIT RANDOM NUMBER
        MOV     DX, 0                   ; USE 32-BIT DIVIDE
        MOV     BH, 0
        DIV     BX                      ; Divide by max val+1
        MOV     BP, SP                  ; Put Remainder DX into stack
	MOV	10[BP],DX
        CALL    RREST
	RET
RANDOM8	ENDP

; RAND SUBROUTINE -- GETS A RANDOM NUMBER
;
;       INPUTS -- NONE
;       OUTPUT -- AX CONTAINS A RANDOM NUMBER
RAND    PROC    NEAR
        PUSH    DX                      ; SAVE DX
        MOV     AX, SEED                ; GET LAST NUMBER GENERATED
        MUL     C2053                   ; USE THE "RANDOM" FORMULA
        ADD     AX, C13849
        ADC     DX, 0
        DIV     CFFFF
        MOV     AX, DX
        MOV     SEED, AX
        POP     DX                      ; GET DX BACK
        RET
RAND    ENDP

SEED    DW      213h                    ; RANDOM NUMBER USED BY RAND
C2053   DW      2053                    ; CONSTANS USED IN FORMULA
C13849  DW      13849
CFFFF   DW      0FFFFh

CSEG            ENDS
                END     MAIN
