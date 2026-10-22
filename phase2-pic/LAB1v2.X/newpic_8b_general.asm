LIST P=PIC18F4321 F=INHX32
    #include <p18f4321.inc>
    CONFIG  OSC=HS     ; Set oscillator mode
    CONFIG  PBADEN=DIG ; Set PORTB digital mode
    CONFIG  WDT=OFF    ; Turn off Watchdog Timer
    CONFIG MCLRE = ON
    CONFIG LVP = OFF
  
NUM_NOTES EQU 0x00 ; number of notes entered
COMPLETED_NOTES EQU 0x01 ; number of processed notes after game start
PART_HIGH EQU 0x02 ; outer counter
PART_LOW EQU 0x03 ; inner counter
CURRENT_NOTE EQU 0x04 ; current note for the game
DISTANCE EQU 0x05 ; current note for the game
SPEAKER EQU 0x06 ; current note for the game
PERIOD EQU 0x07 ; current note for the game
CNT50 EQU 0x08 ; current note for the game
TIMEOUT EQU 0x09 ; current note for the game
CURRENT_DURATION EQU 0x0A ; current note for the game
SEC_COUNTER1 EQU 0x0B ; current note for the game
SEC_COUNTER2 EQU 0x0C ; current note for the game
VARL EQU 0x0D ; current note for the game
VARH EQU 0x0E ; current note for the game
MS500_1 EQU 0x0F ; current note for the game
MS500_2 EQU 0x10 ; current note for the game 
THRL EQU 0x11
THRH EQU 0x12
SCORE EQU 0x13
COUNTER_20 EQU 0x14
TICK EQU 0x15
SERVO1 EQU 0x16
SERVO2 EQU 0x17
COMPLETED_LOOPS EQU 0x18
COUNT_REG EQU 0x19
 
TABLE7S EQU 0x020
 
    ORG 0x0000
    GOTO    MAIN

    ORG 0x0008
    GOTO HIGH_RSI
    ORG 0x0018
    RETFIE  FAST
 
ORG TABLE7S
    ;0 segments, 1 segments 
    DB 0xFD, 0xB0
    ;2 Segments, 3 segments 
    DB 0xEE, 0xFA
    ;4 Segments, 5 segments 
    DB 0xB3, 0xDB
    ;6 Segments, 7 segments 
    DB 0x9F, 0xF0
    ;8 Segments, 9 segments 
    DB 0xFF, 0xF3    
  
ORG  0x0280     
PERIOD_TBL
    DB   1,2,3,4,5,6,7
    
ORG   0x0400         
SERVO_TBL  
    DB    .251,  .15      ; 1 note
    DB    .253,  .53      ; 2 notes
    DB    .254,  .58      ; 3 notes
    DB    .254, .105      ; 4 notes
    DB    .255,  .19      ; 5 notes
    DB    .255,  .57      ; 6 notes
    DB    .255,  .87      ; 7 notes
    DB    .255, .109      ; 8 notes
    DB    .255, .126      ; 9 notes
    DB    .255, .138      ;10 notes
    DB    .255, .150      ;11 notes
    DB    .255, .159      ;12 notes
    DB    .255, .168      ;13 notes
    DB    .255, .174      ;14 notes
    DB    .255, .180      ;15 notes
    DB    .255, .185      ;16 notes    
    
    
WAIT_1MS
    ; to be completed(there is code in lab)
    MOVLW   .192         
    MOVWF   PART_LOW
    MOVLW   .247         
    MOVWF   PART_HIGH
WAIT_TIME                 ;Debouncing waiting routine.
    INCF    PART_LOW,1
    BTFSS   STATUS,C,0
    GOTO    WAIT_TIME                 
    MOVLW   .192
    MOVWF   PART_LOW
    INCF    PART_HIGH,1
    BTFSS   STATUS,C,0
    GOTO    WAIT_TIME                 
    RETURN
    
WAIT_500US    
   MOVLW   .239      
    MOVWF   PART_LOW
    MOVLW   .210      
    MOVWF   PART_HIGH
WAIT_TIME3                ;Debouncing waiting routine.
    INCF    PART_LOW,1
    BTFSS   STATUS,C,0
    GOTO    WAIT_TIME3                 
    MOVLW   .250
    MOVWF   PART_LOW
    INCF    PART_HIGH,1
    BTFSS   STATUS,C,0
    GOTO    WAIT_TIME3                 
    RETURN
    
WAIT_10US ; for the sensor(trigger)
    NOP
    MOVLW .251
    MOVWF PART_LOW
WAIT_TIME1
    INCF PART_LOW, 1, 0
    BTFSS STATUS, C, 0
    GOTO WAIT_TIME1
    RETURN
    
WAIT_STEP ; for the sensor(echo)
    NOP
    NOP
    MOVLW .40
    MOVWF PART_LOW
WAIT_TIME2
    INCF PART_LOW, 1, 0
    BTFSS STATUS, C, 0
    GOTO WAIT_TIME2
    RETURN    
 
SERVO_STEP
    ; to be completed(there is code in lab)
    MOVFF SERVO1, PART_LOW
    MOVFF SERVO2, PART_HIGH
WAIT_SERVO                 ;Debouncing waiting routine.
    INCF    PART_LOW,1
    BTFSS   STATUS,C,0
    GOTO    WAIT_SERVO                 
    MOVFF SERVO1, PART_LOW
    INCF    PART_HIGH,1
    BTFSS   STATUS,C,0
    GOTO    WAIT_SERVO               
    RETURN    
    
LOAD_TIMER
    BCF	INTCON,TMR0IF,0  ; Clear interrupt bit
    MOVLW b'00011101'
    ; for a 0.5ms interrupt time
    MOVWF TMR0L
    MOVLW b'11111011'
    MOVWF TMR0H
    RETURN
    
HIGH_RSI
    BTG LATC, 3, 0
    INCF TICK, 1, 0
    CALL SPEAKER_PWM
    
    BTFSS   INTCON,TMR0IF,0      ; skip if it was TMR0
    RETFIE  FAST

    CALL    LOAD_TIMER           ; reload TMR0
    INCF    TIMEOUT,1,0          
    
    ;seconds counter
    INCF SEC_COUNTER1,1, 0
    BTFSC STATUS, C
    INCF SEC_COUNTER2, 1, 0
    
    ;500 ms counters
    INCF MS500_1,1, 0
    BTFSC STATUS, C
    INCF MS500_2, 1, 0

    INCF COUNTER_20, 1, 0
    
    RETFIE  FAST

    
INIT_TMR0
    BCF	RCON,IPEN,0	    
    MOVLW   b'10001000'	    
    MOVWF   T0CON,0         
    CALL   LOAD_TIMER       
    RETURN
  
LOAD_SERVO_VALUES
    MOVLW   LOW(SERVO_TBL)
    MOVWF   TBLPTRL
    MOVLW   HIGH(SERVO_TBL)
    MOVWF   TBLPTRH
    MOVLW   UPPER(SERVO_TBL)
    MOVWF   TBLPTRU

    MOVF    NUM_NOTES, W
    MOVWF   COUNT_REG    
    DECFSZ  COUNT_REG, F  
    GOTO    OFFSET_LOOP
    GOTO    READ_ENTRY    

OFFSET_LOOP
    TBLRD*+               
    TBLRD*+               
    DECFSZ  COUNT_REG, F 
    GOTO    OFFSET_LOOP  

READ_ENTRY
    TBLRD*+               
    MOVFF   TABLAT, SERVO2
    TBLRD*            
    MOVFF   TABLAT, SERVO1

    RETURN    
    
SAVE_NOTE
    ; Increment NUM_NOTES (count of entered notes)
    INCF NUM_NOTES, 1

    MOVF PORTB, 0, 0        ; Load PORTC into WREG
    ANDLW b'00111111'       ; Isolate RC0?RC5 (BCD note and duration)
    MOVWF POSTINC0          ; Write to memory, increment FSR0
    
    BSF LATC, 0, 0          ; Set RA2 high for acknowledgment
    CALL WAIT_1MS	    ; Wait for 1 ms apx
    CALL WAIT_1MS	    ; Wait for 1 ms apx
    BCF LATC, 0, 0          ; Clear RA2 (acknowledgment complete)
   
    RETURN
 
INIT_POINTERS_R
    CLRF FSR0L, 0 ;When all the values have been stored, we need to clear
    MOVLW 0x01 ;the pointers are initialized again, we use the BANK1 to store the notes and duration 
    MOVWF  FSR0H,0
    
    RETURN
    
INIT_POINTERS_T
    
    MOVLW LOW(TABLE7S)
    MOVWF TBLPTRL, 0
    MOVLW HIGH(TABLE7S)
    MOVWF TBLPTRH, 0
    MOVLW UPPER(TABLE7S)
    MOVWF TBLPTRU, 0  
    RETURN

FETCH_SEGMENT
    CALL INIT_POINTERS_T
    
    MOVF POSTINC0, 0, 0
    
    ;duration logic
    BTFSC WREG, 4, 0
    BSF LATA, 3, 0
    BTFSC WREG , 5, 0
    BSF LATA, 4, 0
    
    MOVWF CURRENT_NOTE, 0
    ANDLW b'00110000'
    MOVWF CURRENT_DURATION
    
    MOVF CURRENT_NOTE, 0, 0
    
    ANDLW b'00001111'
    MOVWF CURRENT_NOTE, 0 ; to keep the current note
    
    ADDWF TBLPTRL, F, 0
    TBLRD*
    MOVF TABLAT, 0, 0          ; Move the fetched pattern to WREG
    MOVWF LATD, 0
    
    RETURN   

END_GAME
    MOVLW 0x02
    MOVWF LATD, 0
    CLRF CNT50, 0
    CLRF PERIOD, 0
    CALL WHOLE_SERVO
    GOTO END_GAME
   
CLEAR_OUTPUTS
    CLRF LATD, 0
    BCF LATA, 3, 0
    BCF LATA, 4, 0
    RETURN
    
HRC_MEASURE
    
    ;10 us pulse
    
    BSF LATC, 2, 0
    CALL WAIT_10US
    BCF LATC, 2, 0
    
    CLRF TIMEOUT
    
    CALL WAIT_ECHO1
    
    CLRF    DISTANCE            
    MEASURE_DIST
    CALL    WAIT_STEP           

    BTFSS   PORTC,1           
    GOTO    END_MEASURE        

    INCF    DISTANCE,1, 0         
    CALL WHOLE_SERVO
    MOVLW   7                   
    CPFSEQ  DISTANCE,0          
    GOTO    MEASURE_DIST        
    
    ; out of range distance
    OUT_OF_RANGE

    CLRF    PERIOD             
    CLRF    CNT50
    
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    
    GOTO PERIOD_DONE         
    
    END_MEASURE

    MOVLW   LOW(PERIOD_TBL)
    MOVWF   TBLPTRL
    MOVLW   HIGH(PERIOD_TBL)
    MOVWF   TBLPTRH
    MOVLW   UPPER(PERIOD_TBL)
    MOVWF   TBLPTRU

    MOVF    DISTANCE,W
    ADDWF   TBLPTRL,F
    BTFSC   STATUS,C
    INCF    TBLPTRH,F
    TBLRD*
    MOVF    TABLAT,W
    MOVWF   PERIOD
    CLRF    CNT50               

    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    CALL WHOLE_SERVO
    CALL DELAY_INVALID
    
    PERIOD_DONE
    RETURN
    
GE_THR
    MOVF   THRH,W
    SUBWF  VARH,W      
    BTFSS  STATUS,Z
    BRA    GE_HI_DONE
    MOVF   THRL,W
    SUBWF  VARL,W 

GE_HI_DONE
    RETURN    
   
RESET_500MS_COUNTERS
    CLRF MS500_1
    CLRF MS500_2
    RETURN
	
LOAD_DURATION_THR
    MOVF    CURRENT_DURATION,W,0   
    BTFSC   WREG,4,0              
    GOTO    _CHK_2_OR_3

_LOAD_1S
    MOVLW   0x07                   
    MOVWF   THRH
    MOVLW   0xD0                   
    MOVWF   THRL
    RETURN

_CHK_2_OR_3
    BTFSS   WREG,5,0              
    GOTO    _LOAD_2S               

_LOAD_3S
    MOVLW   0x17                  
    MOVWF   THRH
    MOVLW   0x70                  
    MOVWF   THRL
    RETURN

_LOAD_2S
    MOVLW   0x0F                  
    MOVWF   THRH
    MOVLW   0xA0                   
    MOVWF   THRL
    RETURN
    
WAIT_ECHO1
    BTFSC   PORTC,1,0        
    RETURN                   
    CALL WHOLE_SERVO
    MOVLW   30
    CPFSLT  TIMEOUT,0       
    GOTO    OUT_OF_RANGE      
    GOTO    WAIT_ECHO1     
   
SERVO_PWM
    
    CLRF COUNTER_20
    BSF LATC, 4, 0
    CLRF COMPLETED_LOOPS
    CALL WAIT_500US
    
    MOVLW 0
    CPFSEQ SCORE, 0
    GOTO ON_SCORE
    GOTO FINISHED_SERVO
    
    ON_SCORE
    CALL SERVO_STEP
    INCF COMPLETED_LOOPS, 1
    MOVF SCORE, 0
    CPFSEQ COMPLETED_LOOPS, W
    GOTO ON_SCORE
    
    FINISHED_SERVO
    BCF LATC, 4, 0 
    RETURN    
   
SPEAKER_PWM
    
    MOVLW 0
    CPFSEQ PERIOD, W
    GOTO CONTINUE_SPEAKER
    GOTO CLEARS_PWM
    
    CONTINUE_SPEAKER
    MOVF    PERIOD, W       
    CPFSGT  TICK         
    GOTO ENDS_SPEAKER

    CLRF    TICK           
    BTG    LATE, 0, 0        
    GOTO ENDS_SPEAKER
    
    CLEARS_PWM
    BCF LATE, 0, 0
    ENDS_SPEAKER
    RETURN
    
START_GAME
    CALL INIT_POINTERS_R
    CALL LOAD_SERVO_VALUES
    CLRF COUNTER_20
    CLRF CNT50, 0
    CLRF PERIOD, 0
    CLRF COMPLETED_NOTES
    CLRF COMPLETED_LOOPS
    CLRF SCORE
    
GAME_CONTINUE 
    CALL FETCH_SEGMENT
    CLRF SEC_COUNTER1
    CLRF SEC_COUNTER2
    CALL RESET_500MS_COUNTERS
    
INITIAL_3SEC
    
    CALL WHOLE_SERVO
    CALL HRC_MEASURE
    
    MOVF    CURRENT_NOTE,W,0
    XORWF   DISTANCE,W,0      ; W=0 if note == distance
    BTFSS   STATUS,Z          ; Z=1 ? they match
    CALL RESET_500MS_COUNTERS
    CALL WHOLE_SERVO
    
    MOVLW   0x03        ; high byte of 1000 (0x03E8)
    MOVWF   THRH
    MOVLW   0xE8        ; low  byte of 1000
    MOVWF   THRL
    
    MOVFF   MS500_1, VARL
    MOVFF   MS500_2, VARH
    
    CALL    GE_THR 
    BTFSC   STATUS,C        
    GOTO CLEAR_COUNTERS
    
    ; for comparing 3 sec
    MOVLW   0x17     ; 0x17
    MOVWF   THRH, 0
    MOVLW   0x70     ; 0x70
    MOVWF   THRL, 0
    
    MOVFF   SEC_COUNTER1, VARL
    MOVFF   SEC_COUNTER2, VARH
    
    CALL    GE_THR
    BTFSC   STATUS,C        
    GOTO INCORRECT_NOTE
    GOTO INITIAL_3SEC
    
CLEAR_COUNTERS
    CLRF SEC_COUNTER1
    CLRF SEC_COUNTER2
    CALL LOAD_DURATION_THR
    
AFTER_500MS
    ; logic for after game
    
    CALL WHOLE_SERVO

    CALL HRC_MEASURE
    MOVF    CURRENT_NOTE,W,0
    XORWF   DISTANCE,W,0      
    BTFSS   STATUS,Z          
    GOTO INCORRECT_NOTE
    
    CALL WHOLE_SERVO
    
    MOVFF   SEC_COUNTER1, VARL
    MOVFF   SEC_COUNTER2, VARH
    
    CALL    GE_THR
    BTFSS   STATUS,C        
    GOTO AFTER_500MS
    GOTO CORRECT_NOTE
    
INCORRECT_NOTE
    BCF LATA, 2, 0 
    BSF LATA, 5, 0
    GOTO PROCESSED_NOTE
    
CORRECT_NOTE
    BCF LATA, 5, 0
    BSF LATA, 2, 0 
    INCF SCORE, 1, 0
    
PROCESSED_NOTE
    
    CALL CLEAR_OUTPUTS
    
    INCF COMPLETED_NOTES, 1
    MOVF NUM_NOTES, W
    CPFSEQ COMPLETED_NOTES, 0
    GOTO GAME_CONTINUE
   
    CALL END_GAME
 
WHOLE_SERVO
    MOVLW .40
    CPFSLT COUNTER_20, 0
    CALL SERVO_PWM
    RETURN
    
INIT_PORTS
    MOVLW   0x0F         
    MOVWF   ADCON1

    CLRF    LATD, 0
    CLRF    TRISD, 0

    MOVLW   b'00111111'  
    MOVWF   TRISB

    BSF     TRISA,0, 0     
    BSF     TRISA,1, 0      
    BCF     TRISA,2, 0     
    BCF     LATA,2, 0      

    BCF     TRISA,3, 0
    BCF     TRISA,4, 0
    BCF     TRISA,2, 0
    BCF     TRISA,5, 0
    
    BCF     LATA,3, 0
    BCF     LATA,4, 0
    BCF     LATA,2, 0
    BCF     LATA,5, 0
    
    BCF TRISE, 0, 0
    BCF LATE, 0, 0

    MOVLW   b'00000010'
    MOVWF   TRISC, 0
    CLRF    LATC, 0

    RETURN
    
DELAY_INVALID
    MOVLW   .225         
    MOVWF   PART_LOW
    MOVLW   .195         
    MOVWF   PART_HIGH
WAIT_TIME4                 ;Debouncing waiting routine.
    INCF    PART_LOW,1
    BTFSS   STATUS,C,0
    GOTO    WAIT_TIME4   
    CALL WHOLE_SERVO
    MOVLW   .225
    MOVWF   PART_LOW
    INCF    PART_HIGH,1
    BTFSS   STATUS,C,0
    GOTO    WAIT_TIME4                 
    RETURN   
    
MAIN
    ; routine to initilize pointers
    CALL INIT_POINTERS_T
    CALL INIT_POINTERS_R
    CALL INIT_PORTS
    CALL INIT_TMR0
    
    ;maybe make it an init
    CLRF CNT50, 0
    CLRF PERIOD, 0
    CLRF NUM_NOTES, 0
    CLRF COMPLETED_NOTES, 0
    CLRF COUNTER_20, 0
    CLRF TICK, 0
    CLRF SERVO1, 0
    CLRF SERVO2, 0
    CLRF COMPLETED_LOOPS, 0
    CLRF SCORE, 0
    
    MOVLW   b'11100000'
    MOVWF   INTCON,0	 ; Activate all interrupts as well as TMR0 
    
LOOP	
    BTFSS PORTA, 0, 0 ; wait until newNote is 0
    CALL SAVE_NOTE
    BTFSC PORTA, 1, 0 ; wait until startGame is 1
    GOTO START_GAME

    CALL WHOLE_SERVO
    
    GOTO    LOOP
    END