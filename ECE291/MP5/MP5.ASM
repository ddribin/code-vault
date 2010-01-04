          PAGE      78,132
          TITLE     MP4       Dave Dribin         April 7, 1993

COMMENT   *
          This program uses the serial port as a mini-talk program.  There are
          two windows on the screen.  One is for typing information that is
          sent out, and the other window is for displaying information that
          was receive over the serial port.  The program uses queues to send
          and receive data.
          *

; The following are the EQU declarations
ESCKEY    EQU       1Bh                 ; ESC IS QUIT CHARACTER
MAXQ      EQU       90                  ; MAXIMUM QUEUE LENGTH
CR        EQU       0Dh                 ; CARRIAGE RETURN
BS        EQU       08h                 ; BACK SPACE
BEL       EQU       07h                 ; BEEP

; External Function Declarations
          EXTRN     DSPCTL:NEAR, RSAVE:NEAR, RREST:NEAR, DOSXIT:NEAR
          EXTRN     KBDIN:NEAR, DSPOUT:NEAR, DSPMSG:NEAR, BINASC:NEAR

; Here is the data structure type for the queues
QLIST     STRUC
QBEG      DW        ?                   ; OFFSET OF FIRST BYTE OF QUEUE AREA
QEND      DW        ?                   ; OFFSET OF FIRST BYTE NOT IN Q AREA
FRONT     DW        ?                   ; POINTER TO BYTE AT FRONT OF QUEUE
REAR      DW        ?                   ; POINTER TO BYTE AT REAR OF QUEUE
COUNT     DW        ?                   ; NUMBER OF BYTES CURRENTLY IN QUEUE
STATUS    DB        ?                   ; 0 = NO ERROR, 1 = ERROR
QDATA     DB        ?         ; BYTE ENQUEUED OR DEQUEUED
QLIST     ENDS

STKSEG    SEGMENT   STACK               ; *** STACK SEGMENT ***
          DB        256 DUP(?)
STKSEG    ENDS

CSEG      SEGMENT   PUBLIC              ; *** CODE SEGMENT ***
          ASSUME    CS:CSEG, DS:CSEG, SS:STKSEG, ES:NOTHING

; Global variable declarations
TQ        QLIST     <TQBEG, TQEND, TQBEG+1, TQBEG, 0,,>     ; TRANSMIT QUEUE
TQBEG     DB        MAXQ DUP(?)         ; QUEUE AREA
TQEND     LABEL     BYTE

RQ        QLIST     <RQBEG, RQEND, RQBEG+1, RQBEG, 0,,>     ; RECEIVE QUEUE
RQBEG     DB        MAXQ DUP(?)         ; QUEUE AREA
RQEND     LABEL     BYTE

LOCCOL    DB        ?                   ; CURRENT COLUMN IN LOCAL WINDOW
REMCOL    DB        ?                   ; CURRENT COLUMN IN REMOTE WINDOW
TQSTR     DB        " TQ Length: ","$"
TQLEN     DW        ?                   ; PREVIOUS LENGTH OF TQ
RQSTR     DB        " RQ Length: ","$"
RQLEN     DW        ?                   ; PREVIOUS LENGTH OF RQ
BUFFER    DB        7 DUP(?)
SAVOFF    DW        ?
SAVSEG    DW        ?

MAIN      PROC      FAR
          MOV       AX, CS              ; INITIALIZE DS TO CS
          MOV       DS, AX
          CALL      INIT                ; INITIALIZE SCREEN AND VECTORS
MAINLOOP: CALL      TASK1
          CALL      TASK2
          CALL      TASK3
          JMP       MAINLOOP
MAIN      ENDP

; Macros RIS and EOI
; Subroutines ENA_TI, DSB_TI, SER_INIT, SER_RESET

          .XLIST                        ; SUSPEND LISTING

BASE_8259 EQU       0020h               ; Base IO address of the 8259
BASE_8250 EQU       03F8h               ; Base IO address of the 8250
EOI4      EQU       64h                 ; End-of-Interrupt 4 command

RIS       MACRO
          PUSH      DX
          MOV       DX, BASE_8250+2     ; Point to Int ID Reg of 8250
          IN        AL, DX              ; Read Interrupt Status
          POP       DX
          ENDM

EOI       MACRO
          PUSH      AX
          MOV       AL, EOI4            ; Specify the end of interrupt
          OUT       BASE_8259, AL       ;   service routine to 8259
          POP       AX
          ENDM

; Subroutine ENA_TI
; Enable 8250 ACE to generate ready-to-transmit interrupt requests
; via 8259 PIC.
ENA_TI    PROC      NEAR
          CALL      RSAVE
          MOV       DX, BASE_8250+1     ; Point to Int Enable Reg of 8250
          MOV       AL, 00000011b       ; Enable receive and transmit
          OUT       DX, AL              ;   interrupts from the 8250
          CALL      RREST
          RET
ENA_TI    ENDP

; Subroutine DSB_TI
; Disable 8250 ACE from generating ready-to-transmit interrupt requests
; interrupts.
DSB_TI    PROC      NEAR
          CALL      RSAVE
          MOV       DX, BASE_8250+1     ; Point to Int Enable Reg of 8250
          MOV       AL, 00000001b       ; Disable transmit interrupts
          OUT       DX, AL
          CALL      RREST
          RET
DSB_TI    ENDP

; Subroutine SER_INIT
; Initialize 8250 ACE to communicate at 110 baud with
; 8 data bits and one stop bit.
SER_INIT  PROC      NEAR
          CALL      RSAVE
          CLI                           ; BEGIN CRITICAL SECTION
          IN        AL, BASE_8259+1     ; ENABLE IRQ4 AT 8259 PIC
          AND       AL, 0EFh
          OUT       BASE_8259+1, AL

          MOV       DX, BASE_8250+3     ; LINE CONTROL REG OF 8250
          MOV       AL, 80h             ; SET DLAB BIT
          OUT       DX, AL
          MOV       DX, BASE_8250       ; LOW DIVISOR REG
          MOV       AX, 1047            ; SET UP BAUD RATE--110 BAUD
          OUT       DX, AL              ; WRITE LOW DIVISOR BYTE
          INC       DX                  ; HIGH DIVISOR REG
          MOV       AL, AH
          OUT       DX, AL              ; WRITE HIGH DIVISOR BYTE
          MOV       DX, BASE_8250+3     ; LINE CONTROL REG
          MOV       AL, 00000011b       ; NO PARITY, 8 DATA BITS, 1 STOP BIT
          OUT       DX, AL
          MOV       DX, BASE_8250+1     ; INTERRUPT ENABLE REG
          MOV       AL, 00000001b       ; ENABLE RECEIVE INTERRUPTS
          OUT       DX, AL
          MOV       DX, BASE_8250+4     ; MODEM CONTROL REG
          MOV       AL, 00001011b       ; ENABLE INTERRUPTS
          OUT       DX, AL
          MOV       DX, BASE_8250       ; Get rid of any lingering character
          IN        AL, DX              ;  from a previous session
          STI                           ; END CRITICAL SECTION
          CALL      RREST
          RET
SER_INIT  ENDP

; Subroutine SER_RESET
; Reset 8250 ACE, disabling its interrupt requests.
SER_RESET PROC      NEAR
          CALL      RSAVE
          CLI                           ; BEGIN CRITICAL SECTION
          MOV       DX, BASE_8250+1     ; INTERRUPT ENABLE REG
          MOV       AL, 00000000b       ; DISABLE INTERRUPTS
          OUT       DX, AL
          MOV       DX, BASE_8250+4     ; MODEM CONTROL REG OF 8250
          MOV       AL, 00000000b       ; DISABLE INTERRUPTS
          OUT       DX, AL
          IN        AL, BASE_8259+1     ; DISABLE IRQ4 AT 8259 PIC
          OR        AL, 10h
          OUT       BASE_8259+1, AL
          STI                           ; END CRITICAL SECTION
          CALL      RREST
          RET
SER_RESET ENDP

          .LIST                         ; RESUME LISTING

; INIT Subroutine -- This  subroutine initiallizes the display with the
;         windows, and sets up the interrupt vectors.
INIT      PROC      NEAR
          CALL      RSAVE
          MOV       AL, 0               ; CLEAR SCREEN AND SET UP COLORS
          CALL      DSPCTL
          MOV       AL, 4               ; DRAW WINDOWS
          CALL      DSPCTL
          MOV       LOCCOL, 1           ; SET CURRENT LOCAL COLUMN TO 1
          MOV       REMCOL, 1           ; SET CURRENT REMOTE COLUMN TO 1
          MOV       TQLEN, -1           ; SET PREV TQ LENGTH TO -1
          MOV       AL, 1               ; MOVE CURSOR POSITION
          MOV       DH, 8
          MOV       DL, 0
          CALL      DSPCTL
          LEA       DX, TQSTR           ; PRINT OUT TQ LENGTH STRING
          CALL      DSPMSG
          MOV       RQLEN, -1           ; SET PREV RQ LENGTH TO -1
          MOV       AL, 1               ; MOVE CURSOR POSITION
          MOV       DH, 20
          MOV       DL, 0
          CALL      DSPCTL
          LEA       DX, RQSTR           ; PRINT OUT TQ LENGTH STRING
          CALL      DSPMSG
          CALL      RREST
          CALL      SETVECT             ; CHANGE INTERRUPT VECTOR
          CALL      SER_INIT            ; INITIALIZE SERIAL PORT
          RET
INIT      ENDP

; INT_SRV
INT_SRV   PROC      FAR
          PUSH      AX                  ; SAVE AX
          RIS                           ; READ THE INTERRUPT STATUS OF ACE
          AND       AL, 00000010b       ; GET ONLY BIT ONE
          JNZ       RTTIRQ              ;  IF SET, THEN READY-TO-TRANSMIT IRQ
          CALL      RECV_SRV            ; READ DATA FROM PORT
          JMP       SENDEOI             ; SEND EOI TO 8259 PIC
RTTIRQ:   CALL      TRAN_SRV            ; SEND DATA TO PORT
SENDEOI:  EOI                           ; SEND EOI TO 8259 PIC
          POP       AX                  ; RESTORE AX
          IRET                          ; RETURN FROM SERVICE
INT_SRV   ENDP

; RECV_SRV
RECV_SRV  PROC      NEAR
          PUSH      AX                  ; SAVE AX, BX, DX, DS
          PUSH      BX
          PUSH      DX
          PUSH      DS
          MOV       AX, CS              ; SET DS = CS
          MOV       DS, AX
          MOV       DX, 03F8h           ; USE DX FOR A VARIABLE PORT
          IN        AL, DX              ; READ THE 8250 ACE DATA REGISTER
          LEA       BX, RQ              ; PREPARE TO ACCESS RECEIVE QUEUE
          MOV       [BX].QDATA, AL      ; LOAD DATA INTO QDATA
          CALL      ENQ                 ; ENQUEUE QDATA TO RQ
          POP       DS                  ; RESTORE AX, BX, DX, DS
          POP       DX
          POP       BX
          POP       AX
          RET
RECV_SRV  ENDP

; TRAN_SRV
TRAN_SRV  PROC      NEAR
          PUSH      AX                  ; SAVE AX, BX, DX, DS
          PUSH      BX
          PUSH      DX
          PUSH      DS
          MOV       AX, CS              ; SET DS = CS
          MOV       DS, AX
          LEA       BX, TQ              ; PREPARE TO ACCESS TRANS. QUEUE
          CMP       [BX].COUNT, 0       ; IF TRANS. Q IS EMPTY, STOP TRYING
          JE        STOPTRAN            ;  TO TRANSMIT DATA
          CALL      DEQ                 ; GET THE BYTE TO TRANSMIT
          MOV       AL, [BX].QDATA
          MOV       DX, 03F8h           ; USE DX FOR A VARIABLE PORT
          OUT       DX, AL              ; TRANSMIT BYTE
TRANXIT:  POP       DS                  ; RESTORE AX, BX, DX, DS
          POP       DX
          POP       BX
          POP       AX
          RET
STOPTRAN: CALL      DSB_TI              ; DISABLE READY-TO-TRANSMIT
          JMP       TRANXIT             ; RETURN
TRAN_SRV  ENDP


; TASK1 Subroutine -- Reads in a key from the keyboard if there is one and
;         checks the character.  If the character is ESC, it quits the
;         program.  It handles a backspace by printing a backspace.  It
;         prevents backing up the left edge, and typing past the right edge.
;
;         INPUTS -- None
;         OUTPUS -- None
TASK1     PROC      NEAR
          CALL      RSAVE
          MOV       AL, 1               ; SET UP CURSOR POSITION
          MOV       DH, 6               ;  TO ROW 6
          MOV       DL, LOCCOL          ;  AND CURRENT COLUMN
          CALL      DSPCTL
          MOV       AH, 1               ; CHECK TO SEE IF THERE IS A CHAR
          INT       16h                 ;  WAITING
          JZ        TASK1XIT            ; RETURN IF THERE IS NO CHAR
          CALL      KBDIN               ; GET THE CHARACTER
          CMP       AL, ESCKEY          ; CHECK TO SEE IF WE SHOULD QUIT
          JE        TYPEDESC
          CMP       AL, CR              ; WAS ENTER TYPED?
          JE        TYPEDCR
          LEA       BX, TQ              ; CHECK THE CAPACITY OF TQ
          CMP       [BX].COUNT, MAXQ-1  ;  LEAVE ONE SPACE OPEN ON THE QUEUE
          JAE       TASK1BEL
          CMP       AL, BS              ; WAS BACKSPACE TYPED?
          JE        TYPEDBS
          CMP       LOCCOL, 79          ; IF IN COLUMN 78, FORGET KEY
          JE        TASK1BEL
          MOV       DL, AL              ; IT'S A NORMAL CHAR, SO ECHO IT
          CALL      DSPOUT
          INC       LOCCOL              ; ADVANCE CURRENT COLUMN
TASK1ENQ: LEA       BX, TQ
          CLI                           ; CRITICAL SECTION
          MOV       [BX].QDATA, AL
          CALL      ENQ
          STI                           ; END CRITICAL SECTION
          CMP       [BX].STATUS, 1      ; CHECK FOR ENQUEUE ERROR
          JE        TASK1BEL
TASK1XIT: CALL      RREST               ; GET REGISTERS BACK AND RETURN
          RET
TYPEDESC: CALL      RREST               ; RETURN STACK TO ORIGINAL POSITION
          CALL      EXIT                ; QUIT THE PROGRAM
TYPEDBS:  CMP       LOCCOL, 1           ; DON'T BS IF AT LEFT EDGE
          JE        TASK1BEL
          MOV       DL, AL              ; ECHO A BS
          CALL      DSPOUT
          DEC       LOCCOL              ; GO BACK A SPACE
          JMP       TASK1ENQ            ; ENQUEUE BACKSPACE
TYPEDCR:  MOV       AL, 2               ; SCROLL UP A LINE
          CALL      DSPCTL
          MOV       LOCCOL, 1           ; GO BACK TO LEFT SIDE
          MOV       AL, CR              ; ENQUEUE THE CR
          CALL      ENA_TI              ; ENABLE TRANSMIT INTERRUPT
          JMP       TASK1ENQ
TASK1BEL: MOV       DL, BEL             ; MAKE A BEEP
          CALL      DSPOUT
          JMP       TASK1XIT            ; RETURN
TASK1     ENDP

; TASK2 Subroutine -- Checks to see if there is any data on the receiving
;         queue.  If there is, it displays it in the remote window.  This
;         subroutine handles backspaces and returns as well.
;
;         INPUTS -- None
;         OUTPUT -- None
TASK2     PROC      NEAR
          CALL      RSAVE
          LEA       BX, RQ              ; PREPARE TO USE RQ
          CMP       [BX].COUNT, 0       ; IS RQ EMPTY?
          JE        TASK2XIT            ; YES, SO RETURN RIGHT AWAY
          CLI                           ; CRITICAL SECTION
          CALL      DEQ                 ; GET A CHARACTER
          MOV       DL, [BX].QDATA
          STI                           ; END CRITICAL SECTION
          PUSH      DX
          MOV       AL, 1               ; MOVE CURSOR TO CORRECT POSITION
          MOV       DH, 18              ; ROW 17
          MOV       DL, REMCOL          ; CURRENT REMOTE COLUMN
          CALL      DSPCTL
          POP       DX
          CMP       DL, CR              ; CHECK IF CHAR IS ENTER
          JE        RECVCR
          CMP       DL, BS              ; CHECK IF CHAR IS BACKSPACE
          JE        RECVBS
          CALL      DSPOUT              ; DISPLAY CHARACTER
          INC       REMCOL              ; GO UP A COLUMN
TASK2XIT: CALL      RREST               ; GET REGISTERS AND RETURN
          RET
RECVCR:   MOV       AL, 3               ; SCROLL REMOTE WINDOW
          CALL      DSPCTL
          MOV       REMCOL, 1           ; RESET TO COLUMN 1
          JMP       TASK2XIT            ; RETURN
RECVBS:   CALL      DSPOUT              ; DISPLAY BACKSPACE
          DEC       REMCOL              ; GO BACK A COLUMN
          JMP       TASK2XIT            ; RETURN
TASK2     ENDP

; TASK3 Subroutine -- Displays the current lengths of the two queues on the
;         screen.  It only prints the length if they changed from their
;         previous values.
;
;         INPUTS -- None
;         OUTPUT -- None
TASK3     PROC      NEAR
          CALL      RSAVE
          LEA       BX, TQ              ; CHECK IF TQ LENGTH NEEDS UPDATING
          MOV       AX, TQLEN
          CMP       [BX].COUNT, AX
          JE        CHECKRQ
          MOV       AX, [BX].COUNT      ; UPDATE TQLEN
          MOV       TQLEN, AX
          PUSH      AX                  ; SAVE COUNT
          MOV       AL, 1               ; CHANGE CURSOR POSITION
          MOV       DH, 8
          MOV       DL, 12
          CALL      DSPCTL
          POP       AX                  ; GET COUNT BACK
          LEA       BX, BUFFER          ; CHANGE TQ LENGTH TO A STRING
          CALL      BINASC
          CMP       CL, 1               ; IF TQLEN < 10, PAD WITH A ZERO
          JNE       DSPTQLEN
          MOV       DL, '0'
          CALL      DSPOUT
DSPTQLEN: MOV       DX, BX              ;  AND DISPLAY IT
          CALL      DSPMSG
CHECKRQ:  LEA       BX, RQ              ; CHECK IF RQ LENGTH NEEDS UPDATING
          MOV       AX, RQLEN
          CMP       [BX].COUNT, AX
          JE        TASK3XIT
          MOV       AX, [BX].COUNT      ; UPDATE RQLEN
          MOV       RQLEN, AX
          PUSH      AX                  ; SAVE COUNT
          MOV       AL, 1               ; CHANGE CURSOR POSITION
          MOV       DH, 20
          MOV       DL, 12
          CALL      DSPCTL
          POP       AX                  ; GET COUNT BACK
          LEA       BX, BUFFER          ; CHANGE TQ LENGTH TO A STRING
          CALL      BINASC
          CMP       CL, 1               ; IF TQLEN < 10, PAD WITH A ZERO
          JNE       DSPRQLEN
          MOV       DL, '0'
          CALL      DSPOUT
DSPRQLEN: MOV       DX, BX              ;  AND DISPLAY IT
          CALL      DSPMSG
TASK3XIT: CALL      RREST
          RET
TASK3     ENDP


; EXIT Subroutine -- This subroutine restores the original colors and interrupt
;         vectors, then calls DOSXIT.
EXIT      PROC      NEAR
          CALL      RESETVECT
          CALL      SER_RESET           ; RESET THE SERIAL PORT
          MOV       AL, 5               ; RESET THE COLORS TO STANDARD COLORS
          CALL      DSPCTL
          CALL      DOSXIT
EXIT      ENDP

; ENQ Subroutine -- Enques QDATA to the queue pointed to by BX if is not
;         full.  If the queue is full, ENQ will set STATUS to 1.
;
;         INPUTS -- BX contains offset to queue
;         OUTPUT -- STATUS = 0 on success, otherwise 1
ENQ       PROC      NEAR
          CALL      RSAVE
          MOV       AX, [BX].QBEG       ; CHECK TO SEE IF QUEUE IS FULL BY
          ADD       AX, [BX].COUNT      ;  FINDING OUT HOW MANY BYTES ARE
          CMP       AX, [BX].QEND       ;  USED
          JAE       FULLQ
          MOV       [BX].STATUS, 0      ; CLEAR ERROR FLAG
          MOV       DI, [BX].REAR
          INC       DI                  ; INCREMENT THE REAR POINTER
          CMP       DI, [BX].QEND       ; WRAP AROUND IF NECESSARY
          JB        ENQDATA
          MOV       DI, [BX].QBEG
ENQDATA:  MOV       AL, [BX].QDATA      ; STORE DATA
          MOV       [DI], AL
          INC       [BX].COUNT          ; INCREMENT BYTE COUNT
          MOV       [BX].REAR, DI       ; STORE NEW REAR
ENQXIT:   CALL      RREST               ; RESTORE REGISTERS AND RETURN
          RET
FULLQ:    MOV       [BX].STATUS, 1      ; SET ERROR FLAG
          JMP       ENQXIT              ;  AND RETURN
ENQ       ENDP

; DEQ Subroutine -- Dequeues a byte off the specified queue.  If the queue
;         is empty, then STATUS = 1, otherwise STATUS = 0, and QDATA = the
;         dequeued byte.
;
;         INPUTS -- BX contains the offset to the queue
;         OUTPUT -- STATUS = 0 on success, otheriwse 1
DEQ       PROC      NEAR
          CALL      RSAVE
          CMP       [BX].COUNT, 0       ; CHECK TO SEE IF QUEUE IS EMPTY
          JE        EMPTYQ
          MOV       [BX].STATUS, 0      ; CLEAR ERROR FLAG
          MOV       SI, [BX].FRONT      ; CALCULATE ADDRESS OF FRONT
          MOV       AL, [SI]            ; GET DATA
          MOV       [BX].QDATA, AL
          DEC       [BX].COUNT          ; DECREMENT BYTE COUNT
          INC       SI                  ; INCREMENT FRONT POINTER
          CMP       SI, [BX].QEND       ; WRAP AROUND IF NECESSARY
          JB        SETFRONT
          MOV       SI, [BX].QBEG
SETFRONT: MOV       [BX].FRONT, SI      ; SET FRONT
DEQXIT:   CALL      RREST               ; RESTORE REGISTERS AND RETURN
          RET
EMPTYQ:   MOV       [BX].STATUS, 1      ; SET ERROR FLAG
          JMP       DEQXIT              ;  AND RETURN
DEQ       ENDP

; SETVECT Subroutine -- Sets the vector for type 0Ch to the INT_SRV
;         subroutine.  It saves the previous values for the segment and
;         offset.
;
;         INPUTS -- None
;         OUTPUT -- None
VEC0C     EQU       0Ch*4               ; VECTOR AT 4 * TYPE
SETVECT   PROC      NEAR
          CLI                           ; BLOCK INTERRUPTS
          CALL      RSAVE
          MOV       AX, CS              ; SET CS = DS
          MOV       DS, AX
          MOV       AX, 0               ; MAKE ES = 0000h
          MOV       ES, AX
          MOV       AX, ES:VEC0C        ; SAVE OLD VECTOR OFFSET
          MOV       SAVOFF, AX
          MOV       AX, ES:VEC0C+2      ; SAVE OLD VECTOR SEGMENT
          MOV       SAVSEG, AX
          LEA       AX, INT_SRV         ; LOAD NEW OFFSET
          MOV       ES:VEC0C, AX
          MOV       AX, CS              ; LOAD NEW SEGMENT
          MOV       ES:VEC0C+2, AX
          STI                           ; ENABLE INTERRUPTS
          CALL      RREST
          RET
SETVECT   ENDP

; RESETVECT Subroutine -- Resets the vector for interrupt type 0Ch to what
;         was originally there before this program.
;
;         INPUTS -- None
;         OUTPUT -- None
RESETVECT PROC      NEAR
          CALL      RSAVE
          MOV       AX, CS              ; MAKE DS = CS
          MOV       DS, AX
          CLI                           ; DISABLE INTERRUPTS
          MOV       AX, 0               ; SET ES = 0000H
          MOV       ES, AX
          MOV       AX, SAVOFF          ; GET OLD OFFSET
          MOV       ES:VEC0C, AX        ; PUT IT AT VECTOR ADDRESS
          MOV       AX, SAVSEG          ; GET OLD SEGMENT
          MOV       ES:VEC0C+2, AX      ; PUT IT AT VECTOR ALSO
          STI                           ; ENABLE INTERRUPTS NOW
          CALL      RREST
          RET
RESETVECT ENDP

PORT      PROC      NEAR
          CALL      RSAVE
          LEA       BX, TQ
          CLI
          CALL      DEQ
          STI
          CMP       [BX].STATUS, 1
          JE        PORTXIT
          MOV       AL, [BX].QDATA
          LEA       BX, RQ
          MOV       [BX].QDATA, AL
          CLI
          CALL      ENQ
          STI
PORTXIT:  CALL      RREST
          RET
PORT      ENDP

CSEG      ENDS
          END       MAIN


