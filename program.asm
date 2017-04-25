			title	"Maze Solver"
			list	p=16f84A
			radix	hex
			include	"p16f84A.inc"

COUNTER		EQU		d'12'
COUNTER2	EQU		d'13'
TIMER3		EQU		d'14'
SELECT		EQU		d'15'
DEBOUNCECOUNT	EQU		d'16'
ADDRESSING_COUNTER	EQU	d'17'
CURRENT_ADDRESS		EQU	d'18'
OBSTACLE_COUNTER	EQU	d'19'
CURRENT_POSITION	EQU	d'40'
ITERATIONS_COUNTER  EQU d'41'
STARTING_POSITION EQU d'42'	
CURSOR_POSITION		EQU	d'42'	
PREVIOUS_COMMAND	EQU	d'43'	;
MAZE_STATUS		EQU	d'43'	; to check if maze solved, no path, or not solved
;      0th bit: solved, not solved
; 	   1st bit: path, no path
REMAINING_NUMBER	EQU	d'50'
LINE	EQU		d'44'
TEMP	EQU		d'59';RAMI

			ORG		0x0
			GOTO	START

			ORG 	0x04
			BTFSC	INTCON, RBIF	;interrupt for button presses
			GOTO	BUTTONPRESS
			BTFSC	INTCON, T0IF	;timer interrupt flag test
			GOTO	timerInterrupt	


			
START		CLRF	PORTA
			;clearing flags for menu star
			CLRF	SELECT
			MOVLW	b'10'
			MOVWF	SELECT	

			
			BSF		STATUS,RP0	;jumping to bank 1
			CLRF	TRISA	;all port A out
			
			;CONFIGURING PORTB PINS:
			;RB0 -> OUTPUT TO BUZZER
			;RB4-7 -> INPUTS 
			;RB2 , RB3 -> OUTPUTS TO LEDS
			;RB1 -> OUTPUT TO LCD ENABLE
			MOVLW	0xF0	
			MOVWF	TRISB

			MOVLW	b'10000111'	;SETTING OPTION REG to support interrupts
			MOVWF	OPTION_REG

			BCF		STATUS,RP0	;jumping back to bank 0
			
			CLRF 	PORTA	;clearing PORTA
			CLRF	PORTB	;CLEARING PORTB

			CALL	POWERUPDELAY ;delaying 40ms waiting power up LCD
			
			MOVLW	b'00010'
			CALL	ET
			
			MOVLW	b'00010'
			CALL	ET

			MOVLW	b'01000'	;N=1 2 line mode, F=0
			CALL	ET

			MOVLW	b'00000'	;initializing display
			CALL	ET			

			MOVLW	b'01100'	;setting display to ON
			CALL	ET

			CALL	CURSOR_MOVERIGHT

			CALL 	CLEARDISPLAY

			

WELCOME 	CALL	charSp	;Welcome Screen
			CALL	charSp
			CALL	charSp
			CALL	letterM
			CALL	letterA
			CALL	letterZ
			CALL	letterE
			CALL	charSp
			CALL	letterS
			CALL	letterO
			CALL	letterL
			CALL	letterV
			CALL	letterE
			CALL	letterR

			CALL 	LONGER_DELAY	; delay before clearing the display
			CALL	CLEARDISPLAY	; clear display		



;----------------|
;START MENU		 |
;----------------|

MENU		CALL	charSp  ;Mode Selection Menu
			CALL	charSp
			CALL	charSp
			CALL	charSp
			CALL	charStar
			CALL	letterD
			CALL	letterE
			CALL	letterF
			CALL	letterA
			CALL	letterU
			CALL	letterL
			CALL	letterT
			
			CALL	NEWLINE
			
			CALL	charSp
			CALL	letterO
			CALL	letterB
			CALL	letterS
			CALL	letterT
			CALL	letterA
			CALL	letterC
			CALL	letterL
			CALL	letterE
			CALL	charSp
			CALL	charSp
			CALL	charSp
			CALL	letterM
			CALL	letterA
			CALL	letterZ
			CALL	letterE

			;Initializing first timer delay
			CLRF	TMR0
			MOVLW	d'38'
			MOVWF	TIMER3

			BSF		INTCON,RBIE
			BSF		INTCON,GIE

MENULOOP		GOTO	MENULOOP


;--------------------DEFAULT MODE-------------------
DEFAULT_START	CALL CLEARDISPLAY
				CALL	SET_BLINKING 
				MOVLW	b'110'
				MOVWF	SELECT
				
				BSF d'20',0 ;obstacle
				BSF d'21',1 ;empty
				BSF d'22',1 ;empty
				BSF d'23',1 ;empty
				BSF d'24',1 ;empty
				BSF d'25',2 ;S
				BSF d'26',1 ;empty
				BSF d'27',1 ;empty
				BSF d'28',1 ;empty
				BSF d'29',1 ;empty
				BSF d'30',3 ;E
				BSF d'31',0 ;obstacle
				BSF d'32',1 ;empty
				BSF d'33',0 ;obstacle
				BSF d'34',0 ;obstacle
				BSF d'35',1 ;empty
				BSF d'36',1 ;empty
				BSF d'37',1 ;empty
				BSF d'38',0 ;obstacle
				BSF d'39',0 ;obstacle
			

				BSF PORTB,3	;turn on RED LED	
				BCF PORTB,2 ;ground GREEN LED
				
				CALL INDA	;PRINT THE ELEMENTS PRESENT IN THE REGISTERS
				CALL charSp
				CALL charSp
				CALL charSp
				CALL letterS
				CALL charSp
				CALL at

				CALL NEWLINE

				CALL INDA1
				CALL charSp
				CALL charSp
				CALL charSp
				CALL nb0
				CALL comma
				CALL nb5

				MOVLW 	b'01000' ; Set Cursor Starting Position
				CALL 	ET
		
				MOVLW 	b'00101' 
				CALL 	ET

				
				MOVLW	d'25'
				MOVWF	CURRENT_POSITION
				MOVWF	STARTING_POSITION
				
				RETFIE

;--------------------OBSTACLE MODE-------------------
OBSTACLE_START	CALL 	CLEARDISPLAY
				CALL	SET_BLINKING
				MOVLW	b'100'
				MOVWF	SELECT

				BSF 	d'20',2 ;S
				CALL	SET_EMPTY_REGISTERS
				BSF 	d'39',3 ;E

				BSF 	PORTB,2	;TURN ON GREEN LED
				BCF 	PORTB,3 ;GROUND RED LED

				CALL	INDA	;PRINT THE ELEMENTS PRESENT IN THE REGISTERS
				CALL	charSp
				CALL	charSp
				CALL	charSp
				CALL	letterS
				CALL 	charSp
				CALL 	at
				
				CALL	NEWLINE
	
				CALL 	INDA1
				CALL 	charSp
				CALL 	charSp
				CALL 	charSp
				CALL 	nb0
				CALL 	comma
				CALL 	nb5

				MOVLW 	b'01000' ; Set Cursor Starting Position
				CALL 	ET
		
				MOVLW 	b'00001' 
				CALL 	ET

				MOVLW	d'0'
				MOVWF	ADDRESSING_COUNTER
				MOVWF	OBSTACLE_COUNTER				

				MOVLW	d'21'
				MOVWF	CURRENT_ADDRESS
				MOVWF	FSR

				MOVLW	d'20'
				MOVWF	CURRENT_POSITION
				MOVWF	STARTING_POSITION

				RETFIE


;--------------------MAZE MODE-------------------
MAZE_START		CALL 	CLEARDISPLAY
				CALL	SET_BLINKING
				MOVLW	b'101'
				MOVWF	SELECT

				BSF 	d'20',1 ;empty
				CALL	SET_EMPTY_REGISTERS
				BSF 	d'39',1 ;empty

				BSF 	PORTB,2	;TURN ON GREEN LED
				BSF 	PORTB,3 ;TURN ON RED LED

				CALL	INDA	;PRINT THE ELEMENTS PRESENT IN THE REGISTERS
				CALL	charSp
				CALL	charSp
				CALL	letterO
				CALL	letterB
				CALL	letterS

				CALL	NEWLINE

				CALL	INDA1
				CALL	charSp
				CALL	letterR
				CALL	letterE
				CALL	letterM
				CALL	charSp
				CALL	nb5

				MOVLW 	b'01000' ; Set Cursor Starting Position
				CALL 	ET
		
				MOVLW 	b'00000' 
				CALL 	ET

				MOVLW	d'0'
				MOVWF	ADDRESSING_COUNTER
				MOVWF	OBSTACLE_COUNTER

				MOVLW	d'0'
				MOVWF	REMAINING_NUMBER

				MOVLW	d'20'
				MOVWF	CURRENT_ADDRESS
				MOVWF	FSR				

				BSF		INTCON,T0IE	;ENABLE TIMER INTERRUPT

				MOVLW	d'50'
				MOVWF	TIMER3
				CLRF	TMR0

				RETFIE

;-------------------------|
;END MAIN PROGRAM         |
;-------------------------| 


BUTTONPRESS		CALL	DEBOUNCE_DELAY	;CALLED WHEN ANY BUTTON IS PRESSED	
				BTFSS	PORTB, 4	;checking if button 1 pressed
				GOTO	MOVE_BUTTON
				BTFSS	PORTB, 5	;checking if button 2 pressed
				GOTO	CONFIRM_BUTTON
				BTFSS	PORTB, 6	;checking if button 3 pressed
				GOTO	START_BUTTON	
				BTFSS	PORTB, 7	;checking if button 4 pressed
				GOTO	END_BUTTON
				GOTO	RETURN_TO_PROGRAM
				
MOVE_BUTTON		BTFSS	SELECT, 2	; if bit 2 of select is cleared, we are in the menu
				GOTO	INCREMENT_POINTER ; used to navigate the menu
				GOTO	MOVE_CURSOR_MAZE ;to navigate the cursor around the maze

CONFIRM_BUTTON	BTFSS	SELECT, 2	; if bit 2 of select is cleared, we are in the menu
				GOTO	CHOOSE_MODE ; used to confirm the mode we are currently pointing at
				BTFSS	SELECT,1	; SELECT = 110 --> DEFAULT MODE / ELSE --> OBSTACLE MODE OR MAZE MODE
				GOTO	PLACE_OBSTACLECHOOSE
				GOTO	INIT_MAZE ; we solve the maze directly in default mode

CHOOSE_MODE		BCF		INTCON, RBIF	;WE CHECK WHICH OF THE MODES THE POINTER IS CURRENTLY POINTING TO
				BTFSS	SELECT,0
				GOTO	S0
				BTFSC	SELECT,0
				GOTO	S1
S0				BTFSS	SELECT,1
				GOTO	MAZE_START
				BTFSC	SELECT,1
				GOTO	DEFAULT_START
S1				BTFSS	SELECT,1
				GOTO	OBSTACLE_START
				GOTO	RETURN_TO_PROGRAM


START_BUTTON	BTFSS	SELECT, 2	;IF THE START BUTTON IS PRESSED IN DEFAULT OR OBSTACLE MODE WE RETURN
				GOTO	RETURN_TO_PROGRAM
				BTFSS	SELECT, 0
				GOTO	RETURN_TO_PROGRAM
				
				BTFSS	INDF,1	;CHECK IF THE POSITION IS EMPTY
				GOTO	CANNOT_PLACE	;IF NOT EMPTY RETURN

				BTFSC	OBSTACLE_COUNTER,4	;BIT 4 IS SET THEN START POSITION HAS ALREADY BEEN PLACED
				GOTO	CANNOT_PLACE

				CALL	letterS ;Print S
				CALL	RETURN_TO_PREV_POSITION
				BCF 	PORTB,3 ;GROUND RED LED
				BSF		OBSTACLE_COUNTER,4	;SET THAT START HAS BEEN PLACED
				BSF		INDF, 2  ;SET THE ADDRESS AS CONTAINING THE STARTING POSITION
				BCF		INDF, 1 ;SET THE ADDRESS AS NOT EMPTY
				
				MOVF	FSR,0
				MOVWF	CURRENT_POSITION
				MOVWF	STARTING_POSITION	;SET CURRENT POSITION AS THE STARTING POSITION
				
				GOTO	CHECK_IF_DONE ;CHECK IF ALL ELEMENTS OF MAZE MODE HAVE BEEN PLACED

END_BUTTON		BTFSS	SELECT, 2 ;IF THE END BUTTON IS PRESSED IN DEFAULT OR OBSTACLE MODE WE RETURN
				GOTO	RETURN_TO_PROGRAM
				BTFSS	SELECT, 0
				GOTO	RETURN_TO_PROGRAM

				BTFSS	INDF,1 ;CHECK IF THE POSITION IS EMPTY
				GOTO	CANNOT_PLACE ;IF NOT EMPTY RETURN

				BTFSC	OBSTACLE_COUNTER,5 ;BIT 5 IS SET WHEN END POSITION HAS ALREADY BEEN PLACED
				GOTO	CANNOT_PLACE

				CALL	letterE ;PRINT E
				CALL	RETURN_TO_PREV_POSITION
				BCF 	PORTB,2	;GROUND GREEN LED
				BSF		OBSTACLE_COUNTER,5 ;SET THAT END HAS BEEN PLACED
				BSF		INDF, 3 ; SET THE ADDRESS AS CONTAINING THE END POSITION
				BCF		INDF, 1 ; SET THE ADDRESS AS NOT EMPTY
				
				GOTO	CHECK_IF_DONE ;CHECK IF ALL ELEMENTS OF MAZE MODE HAVE BEEN PLACED
	
RETURN_TO_PROGRAM		BCF		INTCON, RBIF	;RESET FLAGS
						RETFIE

CHECK_IF_DONE	BTFSS	OBSTACLE_COUNTER,0 ;CHECK IF ALL 5 OBSTACLES HAVE BEEN PLACED
				GOTO	RETURN_TO_PROGRAM
				BTFSS	OBSTACLE_COUNTER,2
				GOTO	RETURN_TO_PROGRAM
				BTFSS	OBSTACLE_COUNTER,4 ;CHECK IF THE START POSITION HAS BEEN PLACED
				GOTO	RETURN_TO_PROGRAM
				BTFSS	OBSTACLE_COUNTER,5 ;CHECK IF THE END POSITION HAS BEEN PLACED
				GOTO	RETURN_TO_PROGRAM

				MOVF	STARTING_POSITION,0
				MOVWF	CURRENT_POSITION
				CALL	MOVE_CURSOR_TO_CURRENT_POSITION

				GOTO	INIT_MAZE ;IF ALL ELEMENTS HAVE BEEN PLACED, WE SOLVE THE MAZE


;---------------TIMER INTERRUPT CODE--------------------------------
timerInterrupt	CALL	POWERUPDELAY
				DECFSZ	TIMER3,F ;decrementing timer3 to get 2s delay
				GOTO	RETTIMER3

				;INCREMENTING START POSITION
				MOVLW	d'50'
				MOVWF	TIMER3
				CLRF	TMR0
				BTFSC	ADDRESSING_COUNTER,3	;IF ADDRESSING_COUNTER = 9 --> MOVE TO THE OTHER ROW
				BTFSS	ADDRESSING_COUNTER,0
				GOTO	CURSOR_INCREMENT	
				GOTO	CURSOR_SWITCH_ROW		
				
RETTIMER3	RETFIE
;------------------------------------------------------------------




;---------------INCREMENT POINTER CODE----------------------------
INCREMENT_POINTER	BTFSS	SELECT,0
					GOTO	S00CHECKS1
					BTFSC	SELECT,0
					GOTO	S01CHECKS1

S00CHECKS1		BTFSS	SELECT,1
				GOTO	POSITION1
				BTFSC	SELECT,1
				GOTO	POSITION2

S01CHECKS1		BTFSS	SELECT,1
				GOTO	POSITION3
				GOTO	RETURN_TO_PROGRAM

;CLEARING CAN BE OPTIMIZED FURTHER IF NECESSARY
POSITION1		MOVLW	b'01100' ;4AH IS THE LOCATION
				CALL 	ET
		
				MOVLW b'01011' ; 4 bits to jump address
				CALL ET	
				CALL	charSp


				MOVLW b'01000' ; 00 IS THE LOCATION
				CALL ET
		
				MOVLW b'00100' ; 4 bits to jump address
				CALL ET

				CALL	charStar;print star before DEFAULT
				BSF		SELECT,1
				
				GOTO	RETURN_TO_PROGRAM

;CLEARING CAN BE OPTIMIZED FURTHER IF NECESSARY
POSITION2		MOVLW 	b'01000' ; clearing position 1
				CALL 	ET
		
				MOVLW 	b'00100' ; 4 bits to jump address
				CALL 	ET
				CALL	charSp		


				MOVLW b'01100' ; 40H IS THE LOCATION
				CALL ET
		
				MOVLW b'00000' ; 4 bits to jump address
				CALL ET	
				
				CALL	charStar;print star before OBSTACLE	

				BSF		SELECT,0
				BCF		SELECT,1
				GOTO	RETURN_TO_PROGRAM
				

;CLEARING CAN BE OPTIMIZED FURTHER IF NECESSARY
POSITION3		MOVLW b'01100' ; clearing position 2
				CALL ET
		
				MOVLW 	b'00000' ; clearing position 2
				CALL 	ET	
				CALL	charSp

				MOVLW	b'01100' ;4AH IS THE LOCATION
				CALL 	ET
		
				MOVLW b'01011' ; 4 bits to jump address
				CALL ET	
				
				CALL	charStar;print star before MAZE
				BCF		SELECT,0
				BCF		SELECT,1
				GOTO	RETURN_TO_PROGRAM

;---------------MOVE CURSOR CODE----------------------------

MOVE_CURSOR_MAZE	BTFSC	SELECT,0	;SELECT = 101 --> MAZE MODE
					GOTO	RETURN_TO_PROGRAM
					BTFSS	SELECT,1
					GOTO	MOVE_CURSOR_OBSTACLE	;SELECT = 100 --> OBSTACLE MODE / SELECT = 110 --> DEFAULT MODE
					GOTO	RETURN_TO_PROGRAM
;-------OBSTACLE MODE RELATED:-------------------
MOVE_CURSOR_OBSTACLE	BTFSS	ADDRESSING_COUNTER, 3	;IF BIT 3 IS SET, WE HAVE MOVED 8 POSITIONS WITHIN A SINGLE ROW IN OBSTACLE MODE
						GOTO	CURSOR_INCREMENT		; --> IF WE ARE ON ROW0 WE NEED TO GO DOWN,
						MOVF	STARTING_POSITION, 0	; --> IF WE ARE ON ROW1 WE ARE DONE
						MOVWF	CURRENT_POSITION
						BTFSC	ADDRESSING_COUNTER, 4	;IF BIT 4 IS SET --> WE ARE ON ROW1 AND WE ARE DONE
						GOTO 	INIT_MAZE				;IF BIT 4 IS CLEAR --> WE ARE ON ROW0 AND NEED TO GO DOWN
						GOTO	CURSOR_NEXTLINE

CURSOR_INCREMENT		BTFSC INDF,0	;CHECK WHICH ELEMENT IS ON THIS POSITION AND PRINT IT AGAIN
						CALL rectangle
						BTFSC INDF,1
						CALL empty
						BTFSC INDF,2
						CALL letterS
						BTFSC INDF,3
						CALL letterE	
						BTFSS	ADDRESSING_COUNTER, 4 ;IF BIT4 OF ADDRESSING COUNTER IS SET, WE ARE IN THE SECOND LINE AND MOVING BACKWARDS
						CALL	INCREMENT		;MOVE TO THE RIGHT				
						BTFSC	ADDRESSING_COUNTER, 4
						CALL	DECREMENT		;MOVE TO THE LEFT		
						INCF	ADDRESSING_COUNTER	;INCREMENT HOW MANY POSITIONS WE HAVE MOVED
						GOTO	RETURN_TO_PROGRAM

INCREMENT				INCF	CURRENT_ADDRESS
						INCF	FSR	;INCREMENT CURRENT LOCATION WHEN MOVING TO THE RIGHT
						RETURN

DECREMENT				DECF	CURRENT_ADDRESS
						DECF	FSR ;DECREMENT CURRENT LOCATION WHEN MOVING TO THE LEFT
						RETURN

CURSOR_NEXTLINE			MOVLW	b'01100' ;move to ROW1 COLUMN 8
						CALL	ET
						MOVLW	b'01000'
						CALL	ET
						CALL	CURSOR_MOVELEFT ;SET THE CURSOR TO MOVE FROM RIGHT TO LEFT
						MOVLW	b'10000'
						MOVWF	ADDRESSING_COUNTER	;SET BIT 4 AS A SIGN THAT WE ARE ON ROW1
						MOVLW	d'38'	;38 IS THE LOCATION OF ROW1 COLUMN 8
						MOVWF	CURRENT_ADDRESS
						MOVWF	FSR		;SET IT AS OUR CURRENT ADDRESS
						GOTO	RETURN_TO_PROGRAM

;------------------MAZE MODE RELATED---------------------

CURSOR_SWITCH_ROW		BTFSC	ADDRESSING_COUNTER,4 ;IF BIT4 IS SET WE ARE ON ROW1 AND NEED TO GO UP
						GOTO	SWITCH_UP			 ;OTHERWISE WE ARE ON ROW0 AND NEED TO GO DOWN
						GOTO	SWITCH_DOWN

SWITCH_DOWN				MOVLW	b'01100' ; move to ROW1 COLUMN 9
						CALL	ET
						MOVLW	b'01001'
						CALL	ET
						CALL	CURSOR_MOVELEFT ;SET THE CURSOR TO MOVE FROM RIGHT TO LEFT
						MOVLW	b'10000'
						MOVWF	ADDRESSING_COUNTER	;SET BIT 4 AS A SIGN THAT WE ARE ON ROW1
						MOVLW	d'39' ;39 IS THE LOCATION OF ROW1 COLUMN 9
						MOVWF	CURRENT_ADDRESS
						MOVWF	FSR		;ADJUST FSR TO OUR CURRENT ADDRESS
						GOTO	RETURN_TO_PROGRAM

SWITCH_UP				MOVLW	b'01000' ;move to ROW0 COLUMN 0
						CALL	ET
						MOVLW	b'00000'
						CALL 	ET
						CALL	CURSOR_MOVERIGHT ;SET THE CURSOR TO MOVE FROM LEFT TO RIGHT
						MOVLW	b'00000'
						MOVWF	ADDRESSING_COUNTER ;CLEAR BIT 4 AS A SIGN THAT WE ARE ON ROW0
						MOVLW	d'20' ;20 IS THE LOCATION OF ROW0 COLUMN 0
						MOVWF	CURRENT_ADDRESS
						MOVWF	FSR		;ADJUST FSR TO OUR CURRENT ADDRESS
						GOTO	RETURN_TO_PROGRAM

;MOVE_CURSOR_MAZEMODE
;-----------------------------------------------------------------------------	

;---------------PLACE OBSTACLES CODE----------------------------

PLACE_OBSTACLECHOOSE	BTFSS	SELECT,0	;SELECT = 100 --> OBSTACLE MODE / SELECT = 101 --> MAZE MODE
						GOTO	PLACE_OBSTACLEMODE
						GOTO	PLACE_MAZEMODE

;---------------PLACE OBSTACLES IN OBSTACLE MODE:---------------
PLACE_OBSTACLEMODE	CALL	PLACE_OBSTACLE	;PLACE OBSTACLE IN CURRENT POSITION
					CALL	BUZZ_SHORT ;BUZZ SOUND
					INCF	OBSTACLE_COUNTER	;ADJUST NUMBER OF PLACED OBSTACLES									
					BTFSC	OBSTACLE_COUNTER,2 ;CHECK IF 5 OBSTACLES HAVE BEEN PLACED
					BTFSS	OBSTACLE_COUNTER,0
					GOTO	ADJUST_NEXT_POSITION ; ADJUST CURSOR TO KEEP PLACING OBSTACLES
					MOVF	STARTING_POSITION, 0
					MOVWF	CURRENT_POSITION
					GOTO	INIT_MAZE	;IF WE HAVE PLACE 5 OBSTACLES WE SOLVE THE MAZE

ADJUST_NEXT_POSITION		BTFSS	ADDRESSING_COUNTER, 3	; IF IT IS SET, WE ARE ON ROW0 COLUMN9, OR ROW1 COLUMN0
							GOTO	INCREMENT_NEXT_POSITION	
							BTFSC	ADDRESSING_COUNTER, 4 	; IF IT IS SET, WE ARE ON ROW1 COLUMN0, ELSE WE ARE ON ROW0 COLUMN9
							GOTO	INIT_MAZE
							GOTO	CURSOR_NEXTLINE
							
INCREMENT_NEXT_POSITION		BTFSS	ADDRESSING_COUNTER, 4 ;IF BIT4 OF ADDRESSING COUNTER IS SET, WE ARE IN ROW1 AND NEED TO MOVE BACKWARDS
							CALL	INCREMENT		  
							BTFSC	ADDRESSING_COUNTER, 4
							CALL	DECREMENT
							INCF	ADDRESSING_COUNTER
							GOTO	RETURN_TO_PROGRAM

;-------------PLACE OBSTACLES IN MAZE MODE:----------------
PLACE_MAZEMODE		BTFSS	INDF,1	;CHECK IF THE POSITION IS EMPTY
					GOTO	CANNOT_PLACE	;IF NOT EMPTY RETURN
					BTFSC	OBSTACLE_COUNTER,2 ;CHECK IF 5 OBSTACLES HAVE BEEN PLACED
					BTFSS	OBSTACLE_COUNTER,0
					GOTO	PLACE_OBS_MAZEMODE
					GOTO	CANNOT_PLACE	

PLACE_OBS_MAZEMODE	CALL	PLACE_OBSTACLE
					INCF	OBSTACLE_COUNTER	;INCREMENT OBSTACLE COUNTER
					;ADJUST REMAINING:
					; MOVE TO THE REMAINING NB OF OBSTACLES POSITION
					MOVLW	b'01100'
					CALL	ET
					MOVLW	b'01111'
					CALL	ET
					;WRITE NUMBER
					;WE START WITH REMAINING_NUMBER = 0
					;EACH TIME WE PLACE AN OBSTACLE WE SHIFT IT TO THE LEFT
					;HERE WE CHECK THE LEFTMOST POSITION THAT IS SET TO SEE HOW MANY OBSTACLES HAVE BEEN PLACED
					BTFSS	REMAINING_NUMBER,3
					GOTO	REMAINING_CASE1
					CALL	nb0
					CALL	RETURN_TO_PREV_POSITION
					GOTO	PLACE_MAZEMODE_RETURN

REMAINING_CASE1		BTFSS	REMAINING_NUMBER,2
					GOTO	REMAINING_CASE2
					CALL	nb1
					CALL	RETURN_TO_PREV_POSITION
					GOTO	PLACE_MAZEMODE_RETURN

REMAINING_CASE2		BTFSS	REMAINING_NUMBER,1
					GOTO	REMAINING_CASE3
					CALL	nb2
					CALL	RETURN_TO_PREV_POSITION
					GOTO	PLACE_MAZEMODE_RETURN

REMAINING_CASE3		BTFSS	REMAINING_NUMBER,0
					GOTO	REMAINING_CASE4
					CALL	nb3
					CALL	RETURN_TO_PREV_POSITION
					GOTO	PLACE_MAZEMODE_RETURN

REMAINING_CASE4		CALL	nb4
					CALL	RETURN_TO_PREV_POSITION
					GOTO	PLACE_MAZEMODE_RETURN

					;RETURN TO PREVIOUS POSITION
RETURN_TO_PREV_POSITION		BTFSS	ADDRESSING_COUNTER, 4 ;IF BIT4 = 1 --> WE ARE IN ROW 1, ELSE WE ARE IN ROW 0
							MOVLW	b'01000'	  
							BTFSC	ADDRESSING_COUNTER, 4
							MOVLW	b'01100'
							CALL	ET
							BTFSS	ADDRESSING_COUNTER, 4
							MOVLW	d'20'	;ROW 0 : D'20' to d'29'
							BTFSC	ADDRESSING_COUNTER, 4
							MOVLW	d'30'	;ROW 1 : d'30' to d'39'
							SUBWF	FSR,0	; ADDRESS REGISTER - VALUE IN W = OFFSET
							CALL	ET	
							RETURN					

PLACE_MAZEMODE_RETURN		RLF		REMAINING_NUMBER,1 ;ROTATE IT ONCE TO THE LEFT TO SELECT CORRECT CASE FOR REMAINING NUMBER
							GOTO	CHECK_IF_DONE

CANNOT_PLACE		CALL	BUZZ_SHORT	;BUZZ SOUND
					GOTO	RETURN_TO_PROGRAM


PLACE_OBSTACLE		BSF		INDF, 0 ;SET THE ADDRESS AS CONTAINING AN OBSTACLE
					BCF		INDF, 1 ;SET THE ADDRESS AS NOT EMPTY
					CALL	rectangle
					RETURN


;---------------MAZE SOLVING ALGORITHM----------------------------

INIT_MAZE		CALL	CLEARDISPLAY ;CLEAR THE DISPLAY
				BCF		PORTB,2	;TURN OFF GREEN LED
				BCF		PORTB,3	;TURN OFF RED LED
				CALL	INDA	; PRINT THE MAZE
				CALL	NEWLINE
				CALL	INDA1

				;--PRINT ITR
				MOVLW	b'01000'
				CALL	ET
				MOVLW	b'01011'
				CALL	ET
				CALL	letterI
				CALL	letterT
				CALL	letterR
				;--PRINT ITR NUMBER
				MOVLW	d'9'
				SUBWF	ITERATIONS_COUNTER,0	; IF ITERATIONS < 10, GOTO SMALLER
				BTFSC	STATUS,Z				; OTHERWISE GOTO GREATER
				GOTO	GREATER	
				BTFSC	STATUS,C				
				GOTO	GREATER
				BTFSS	STATUS,C
				GOTO	SMALLER

GREATER			CALL	nb1		;PRINT 1 AS THE FIRST DIGIT SINCE ITR >= 10
				MOVLW	b'10011'
				CALL	ET
				MOVLW	d'9'
				SUBWF	ITERATIONS_COUNTER,0 ;SUBTRACT 9 FROM THE NUMBER OF ITERATIONS SO THAT 0 <= 2ND DIGIT <= 9
				GOTO	PRINT_ITERATIONS

SMALLER			CALL	nb0		;PRINT 0 AS THE FIRST DIGIT SINCE ITR < 10
				MOVLW	b'10011'	;HIGHER ORDER BITS FOR THE LCD TO PRINT A NUMBER
				CALL	ET
				INCF	ITERATIONS_COUNTER,0 ;MOVE TO W THE NUMBER OF ITERATIONS TO THAT THE LCD PRINTS THE CORRECT NUMBER
											 ;WE PASS IT INCREMENTED SINCE WE NEED THE COUNT TO START FROM 1 INSTEAD OF 0
				GOTO	PRINT_ITERATIONS
			
PRINT_ITERATIONS	IORLW	b'00010000'	;MOVE THE LOWER ORDER BITS TO THE LCD SO THAT THE 2ND DIGIT IS PRINTED
					CALL	ET
				
SOLVE_MAZE		CALL	MOVE_CURSOR_TO_CURRENT_POSITION	;MOVE CURSOR TO START
				CALL	CLEAR_BLINKING	;STOP BLINKING
				CALL	LONGDELAY
										
				

CHECK_RIGHT			MOVLW	b'0001'
					MOVWF	PREVIOUS_COMMAND

					;-------------CHECKING BOUNDS----------------

					;TOP RIGHT
					MOVLW	d'29'
					SUBWF	CURRENT_POSITION, 0

					;IF EQUAL GOTO CHECK LEFT
					BTFSC	STATUS, Z
					GOTO	CHECK_LEFT
					
					;BOT RIGHT
					MOVLW	d'39'
					SUBWF	CURRENT_POSITION, 0					

					;IF EQUAL GOTO CHECK LEFT
					BTFSC	STATUS, Z
					GOTO	CHECK_LEFT					
					;--------------------------------------------

					CALL	CURSOR_MOVERIGHT	;SETTING CURSOR MOVING DIRECTION

					;---------CHECKING POSITION TO RIGHT OF CURRENT POSITION--------
					
					MOVLW	b'1'
					ADDWF	CURRENT_POSITION,0	;SAVING CURR_POS + 1 IN W
					MOVWF	FSR

					;CHECK IF THIS REG CONTENT IS END
					BTFSC	INDF, 3
					GOTO	SOLVED

					;CHECKING IF CURRENT POSITION IS VISITED
					BTFSC	INDF, 4
					GOTO	CHECK_LEFT

					;CHECK IF THIS REG CONTENT IS EMPTY
					BTFSC	INDF, 1
					GOTO	EMPTY_CASE

					
CHECK_LEFT			MOVLW	b'0010'
					MOVWF	PREVIOUS_COMMAND

					;-------------CHECKING BOUNDS----------------

					;TOP LEFT
					MOVLW	d'20'
					SUBWF	CURRENT_POSITION, 0

					;IF EQUAL GOTO CHECK UP
					BTFSC	STATUS, Z
					GOTO	CHECK_UP
					
					;BOT LEFT
					MOVLW	d'30'
					SUBWF	CURRENT_POSITION, 0					

					;IF EQUAL GOTO CHECK UP
					BTFSC	STATUS, Z
					GOTO	CHECK_UP					
					;--------------------------------------------		
			
					CALL	CURSOR_MOVELEFT	;SETTING CURSOR MOVING DIRECTION

					;---------CHECKING POSITION TO LEFT OF CURRENT POSITION--------
					
					MOVLW	b'1'
					SUBWF	CURRENT_POSITION,0	;SAVING CURR_POS + 1 IN W
					MOVWF	FSR

					;CHECK IF THIS REG CONTENT IS END
					BTFSC	INDF, 3
					GOTO	SOLVED

					;CHECKING IF CURRENT POSITION IS VISITED
					BTFSC	INDF, 4
					GOTO	CHECK_UP

					;CHECK IF THIS REG CONTENT IS EMPTY
					BTFSC	INDF, 1
					GOTO	EMPTY_CASE


CHECK_UP			MOVLW	b'0100'
					MOVWF	PREVIOUS_COMMAND

					;-------------CHECKING BOUNDS----------------
					CALL	CURSOR_MOVERIGHT	;SETTING CURSOR MOVING DIRECTION

					;IF FIRST ROW, GOTO CHECK_DOWN
					MOVLW	d'30'
					SUBWF	CURRENT_POSITION, 0
					BTFSC	STATUS, Z
					GOTO	ROW2
					BTFSC	STATUS, C
					GOTO	ROW2
					GOTO	CHECK_DOWN

ROW2				;IF SECOND ROW, CHECK UP
					MOVLW	d'10'
					SUBWF	CURRENT_POSITION, 0
					MOVWF	FSR
					
					;CHECK IF THIS REG CONTENT IS END
					BTFSC	INDF, 3
					GOTO	SOLVED

					;CHECKING IF CURRENT POSITION IS VISITED
					BTFSC	INDF, 4
					GOTO	CHECK_DOWN

					;CHECK IF THIS REG CONTENT IS EMPTY
					BTFSC	INDF, 1
					GOTO	EMPTY_CASE
					GOTO	CHECK_DOWN

CHECK_DOWN			MOVLW	b'1000'
					MOVWF	PREVIOUS_COMMAND

					CALL	CURSOR_MOVERIGHT	;SETTING CURSOR MOVING DIRECTION

					;-------------CHECKING BOUNDS----------------
					;IF SECOND ROW, GOTO BLOCK_CURRENTPOSITION
					MOVLW	d'29'
					SUBWF	CURRENT_POSITION, 0
					BTFSC	STATUS, Z
					GOTO	ROW1
					BTFSS	STATUS, C
					GOTO	ROW1
					GOTO	BLOCK_CURRENTPOSITION
					
ROW1				;IF FIRST ROW, CHECK DOWN
					MOVLW	d'10'
					ADDWF	CURRENT_POSITION, 0
					MOVWF	FSR
					
					;CHECK IF THIS REG CONTENT IS END
					BTFSC	INDF, 3
					GOTO	SOLVED

					;CHECKING IF CURRENT POSITION IS VISITED
					BTFSC	INDF, 4
					GOTO	BLOCK_CURRENTPOSITION

					;CHECK IF THIS REG CONTENT IS EMPTY
					BTFSC	INDF, 1
					GOTO	EMPTY_CASE
					GOTO	BLOCK_CURRENTPOSITION

SOLVED				CALL	CURSOR_MOVERIGHT ;SET THE CURSOR TO MOVE FROM LEFT TO RIGHT TO PRINT CORRECTLY
					CALL	PRINTPATH	;PRINT "PATH"
					CALL	charStar	;PRINT "*"
					BSF		PORTB,2		;TURN ON GREEN LED
					CALL	LONGER_DELAY	;DELAY
					BCF		PORTB,2		;TURN OFF GREEN LED
					CALL	CLEARDISPLAY	;CLEAR DISPLAY
					CALL	CLEAR_REGISTERS	;CLEAR REGISTERS FROM THE CONTENTS OF THE MAZE
					CLRF	SELECT			;CLEAR SELECT AND SET IT TO "010" WHICH CORRESPONDS TO THE MENU
					MOVLW	b'10'
					MOVWF	SELECT
					CLRF	ITERATIONS_COUNTER	;CLEAR THE NUMBER OF ITERATIONS
					GOTO	MENU
					

NOPATH				CALL	CURSOR_MOVERIGHT	;SET THE CURSOR TO MOVE FROM LEFT TO RIGHT TO PRINT CORRECTLY
					CALL	PRINTPATH	;PRINT "PATH"
					CALL	letterX		;PRINT "X"
					BSF		PORTB,3		;TURN ON RED LED
					CALL	BUZZ_LONG
					BCF		PORTB,3		;TURN OFF RED LED
					CALL	CLEARDISPLAY	;CLEAR DISPLAY
					CALL	CLEAR_REGISTERS	;CLEAR REGISTERS FROM THE CONTENTS OF THE MAZE
					CLRF	SELECT	;CLEAR SELECT AND SET IT TO "010" WHICH CORRESPONDS TO THE MENU
					MOVLW	b'10'
					MOVWF	SELECT
					CLRF	ITERATIONS_COUNTER	;CLEAR THE NUMBER OF ITERATIONS
					GOTO	MENU

BLOCK_CURRENTPOSITION	MOVF	CURRENT_POSITION, 0
						SUBWF	STARTING_POSITION, 0	;CHECK IF CURRENT POSITION = STARTING POSITION
						BTFSC	STATUS, Z	;IF THE STARTING POSITION IS BLOCKED --> NO PATH
						GOTO	NOPATH

						;INCREMENTING ITERATIONS COUNT				
						INCF	ITERATIONS_COUNTER

						MOVF	CURRENT_POSITION,0
						MOVWF	FSR
						BSF		INDF,0	;SET CURRENT POSITION AS CONTAINING AN OBSTACLE
						BCF		INDF,1	;SET IT AS NOT EMPTY

						;CLEAR VISITED FLAG
						MOVLW	d'20' ;INITIALIZE POINTER
						MOVWF	FSR
NEXT					BCF		INDF,4
						INCF	FSR
						MOVLW	d'39'
						SUBWF	FSR,0
						BTFSS	STATUS,Z
						GOTO	NEXT
						MOVF	STARTING_POSITION,0
						MOVWF	CURRENT_POSITION
						GOTO	INIT_MAZE

EMPTY_CASE			;Incrementing cursor position
					CALL	INCREMENT_CURSOR

					BTFSC	PREVIOUS_COMMAND, 0
					CALL	INCREMENT_POSITION_RIGHT
					BTFSC	PREVIOUS_COMMAND, 1
					CALL	INCREMENT_POSITION_LEFT
					BTFSC	PREVIOUS_COMMAND, 2
					CALL	INCREMENT_POSITION_UP
					BTFSC	PREVIOUS_COMMAND, 3
					CALL	INCREMENT_POSITION_DOWN

					;Printing star?
					CALL    charStar
					CALL    LONGDELAY
					
					;LABELLING CURRENT POSITION AS VISITED
					MOVF	CURRENT_POSITION,0	;MOVING CURRENT_POS CONTENT TO W
					MOVWF	FSR
					BSF		INDF, 4	;SETTING CUR_POS REGISTER AS VISITED

					GOTO	SOLVE_MAZE

;THIS FUNCTION PRINTS THE OBJECT IN THE CURRENT POSITION AGAIN TO INCREMENT THE CURSOR 
INCREMENT_CURSOR		MOVF	CURRENT_POSITION,0	;MOVING CURRENT_POS CONTENT TO W
						MOVWF	FSR
						BTFSS	INDF, 4
						CALL    CHECK_INDF_PRINT  ;CURSOR INCREMENTED BY PRINTING CUR_POS IN CUR_POS
						BTFSC	INDF, 4
						CALL	charStar
						RETURN

INCREMENT_POSITION_RIGHT		MOVLW	d'1'
								ADDWF	CURRENT_POSITION,1
								RETURN

INCREMENT_POSITION_LEFT			MOVLW	d'1'
								SUBWF	CURRENT_POSITION,1
								RETURN

INCREMENT_POSITION_UP			MOVLW	d'10'
								SUBWF	CURRENT_POSITION,1
								CALL	MOVE_CURSOR_TO_CURRENT_POSITION
								RETURN

INCREMENT_POSITION_DOWN			MOVLW	d'10'
								ADDWF	CURRENT_POSITION,1
								CALL	MOVE_CURSOR_TO_CURRENT_POSITION
								RETURN

CHECK_INDF_PRINT	BTFSC INDF,0
					CALL rectangle
					BTFSC INDF,1
					CALL empty
					BTFSC INDF,2
					CALL letterS
					BTFSC INDF,3
					CALL letterE
					RETURN

MOVE_CURSOR_TO_CURRENT_POSITION		MOVF	CURRENT_POSITION, 0
									SUBLW	d'30'

									;IF Z=0, C=0 : NEGATIVE RESULT, GO TO SECOND LINE MOVE
									BTFSC	STATUS, Z	;IF 1, THEN WE'RE SECOND LINE
									GOTO	MOVE_SECONDLINE	

									BTFSS	STATUS, C	;IF ZERO THEN SECOND LINE
									GOTO	MOVE_SECONDLINE

									;IF Z=0, C = 1 : POSITIVE RESULT, GOTO TO FIRST LINE MOVE
									BTFSS	STATUS, Z
									GOTO	MOVE_FIRSTLINE

MOVE_FIRSTLINE		MOVLW b'01000' ; 3 bits to jump address
					CALL ET
					
					MOVLW	d'20'
					SUBWF	CURRENT_POSITION,0
					CALL 	ET
					RETURN

MOVE_SECONDLINE		MOVLW 	b'01100' ; 3 bits to jump address
					CALL 	ET

					MOVLW	d'30'
					SUBWF	CURRENT_POSITION,0
					CALL 	ET
					RETURN
		

;-----------------------------------------------------------------------------
;------CHARACTER DECLARATIONS---------

charSp	MOVLW b'10010' ;upper bits of Space character
		CALL ET
		MOVLW b'10000' ;lower bits of Space character
		CALL ET	
		RETURN		
letterV	MOVLW b'10101' ;upper bits of V
		CALL ET
		MOVLW b'10110' ;lower bits of V
		CALL ET	 
		RETURN
letterR	MOVLW b'10101' ;upper bits of R
		CALL ET
		MOVLW b'10010' ;lower bits of R
		CALL ET	 
		RETURN
letterM	MOVLW b'10100' ;upper bits of M
		CALL ET
		MOVLW b'11101' ;lower bits of M
		CALL ET	
		RETURN
letterD	MOVLW b'10100' ;upper bits of D
		CALL ET
		MOVLW b'10100' ;lower bits of D
		CALL ET	
		RETURN
letterE	MOVLW b'10100' ;upper bits of E
		CALL ET
		MOVLW b'10101' ;lower bits of E
		CALL ET	
		RETURN
letterF	MOVLW b'10100' ;upper bits of F
		CALL ET
		MOVLW b'10110' ;lower bits of D
		CALL ET	
		RETURN
letterA	MOVLW b'10100' ;upper bits of A
		CALL ET
		MOVLW b'10001' ;lower bits of A
		CALL ET	
		RETURN
letterU	MOVLW b'10101' ;upper bits of U
		CALL ET
		MOVLW b'10101' ;lower bits of U
		CALL ET	
		RETURN
letterL	MOVLW b'10100' ;upper bits of L
		CALL ET
		MOVLW b'11100' ;lower bits of L
		CALL ET	
		RETURN
letterT	MOVLW b'10101' ;upper bits of T
		CALL ET
		MOVLW b'10100' ;lower bits of T
		CALL ET	
		RETURN
letterH	MOVLW b'10100'
		CALL ET
		MOVLW b'11000'
		CALL ET
		RETURN
letterO	MOVLW b'10100' ;upper bits of O
		CALL ET
		MOVLW b'11111' ;lower bits of O
		CALL ET	
		RETURN
letterP	MOVLW b'10101' ;upper bits of P
		CALL ET
		MOVLW b'10000' ;lower bits of P
		CALL ET	
		RETURN
letterB	MOVLW b'10100' ;upper bits of B
		CALL ET
		MOVLW b'10010' ;lower bits of B
		CALL ET	
		RETURN
letterS	MOVLW b'10101' ;upper bits of S
		CALL ET
		MOVLW b'10011' ;lower bits of S
		CALL ET	
		RETURN
letterC	MOVLW b'10100' ;upper bits of C
		CALL ET
		MOVLW b'10011' ;lower bits of C
		CALL ET	
		RETURN
letterZ	MOVLW b'10101' ;upper bits of Z
		CALL ET
		MOVLW b'11010' ;lower bits of Z
		CALL ET	
		RETURN
letterX	MOVLW b'10101' ;upper bits of X
		CALL ET
		MOVLW b'11000' ;lower bits of X
		CALL ET	
		RETURN
letterI MOVLW b'10100' ;upper bits of I
		CALL ET
		MOVLW b'11001' ;lower bits of I
		CALL ET	
		RETURN
charStar	MOVLW b'10010' ;upper bits of Star Character
		CALL ET		
		MOVLW b'11010' ;lower bits of Star Character
		CALL ET	
		RETURN
rectangle	MOVLW	b'11111'
			CALL	ET
			MOVLW	b'11111'
			CALL	ET
			RETURN
empty		MOVLW	b'10101'
			CALL	ET	
			MOVLW	b'11111'
			CALL	ET
			RETURN
at			MOVLW	b'10100'
			CALL	ET	
			MOVLW	b'10000'
			CALL	ET
			RETURN
comma		MOVLW	b'10010'
			CALL	ET	
			MOVLW	b'11100'
			CALL	ET
			RETURN
nb0			MOVLW	b'10011'
			CALL	ET	
			MOVLW	b'10000'
			CALL	ET
			RETURN
nb1			MOVLW	b'10011'
			CALL	ET	
			MOVLW	b'10001'
			CALL	ET
			RETURN
nb2			MOVLW	b'10011'
			CALL	ET	
			MOVLW	b'10010'
			CALL	ET
			RETURN
nb3			MOVLW	b'10011'
			CALL	ET	
			MOVLW	b'10011'
			CALL	ET
			RETURN
nb4			MOVLW	b'10011'
			CALL	ET	
			MOVLW	b'10100'
			CALL	ET
			RETURN
nb5			MOVLW	b'10011'
			CALL	ET	
			MOVLW	b'10101'
			CALL	ET
			RETURN
NEWLINE		MOVLW b'01100' ; 3 bits to jump address
			CALL ET
		
			MOVLW b'00000' ; 4 bits to jump address
			CALL ET
			RETURN

PRINTPATH	MOVLW	b'01100'
			CALL	ET
			MOVLW	b'01011'
			CALL	ET
			CALL	letterP
			CALL	letterA
			CALL	letterT
			CALL	letterH
			RETURN

SET_EMPTY_REGISTERS		BSF 	d'21',1 ;empty
						BSF 	d'22',1 ;empty
						BSF 	d'23',1 ;empty
						BSF 	d'24',1 ;empty
						BSF 	d'25',1 ;empty
						BSF 	d'26',1 ;empty
						BSF 	d'27',1 ;empty
						BSF 	d'28',1 ;empty
						BSF 	d'29',1 ;empty
						BSF 	d'30',1 ;empty
						BSF 	d'31',1 ;empty
						BSF 	d'32',1 ;empty
						BSF 	d'33',1 ;empty
						BSF 	d'34',1 ;empty
						BSF 	d'35',1 ;empty
						BSF 	d'36',1 ;empty
						BSF 	d'37',1 ;empty
						BSF 	d'38',1 ;empty
						RETURN

;------------------------------------------

;------DELAYS AND OTHER FIXED FUNCTIONS---------
ET		MOVWF	PORTA
		BSF		PORTB,1; making a falling edge
		NOP
		BCF		PORTB,1
		CALL	PRINTDELAY; this is to wait for LCD to stop executing
		RETURN

LONGDELAY		MOVLW	d'2'
				MOVWF	TEMP

LOOPLONG 		CALL    POWERUPDELAY
                DECFSZ  TEMP,1
                GOTO    LOOPLONG
                RETURN

LONGER_DELAY	MOVLW	d'50'
				MOVWF	TEMP

LOOPLONG2		CALL    POWERUPDELAY
                DECFSZ  TEMP,1
                GOTO    LOOPLONG
                RETURN

POWERUPDELAY	MOVLW	d'00'	; setting up 40ms delay
				MOVWF	COUNTER
				MOVLW	d'51'
				MOVWF	COUNTER2

LOOP	INCFSZ	COUNTER,F
		GOTO	LOOP
		DECFSZ	COUNTER2,F
		GOTO	LOOP
		RETURN

PRINTDELAY	MOVLW	d'00'; SETTING UP 3.85MS DELAY
			MOVWF 	COUNTER	
			MOVLW 	d'5'
			MOVWF	COUNTER2

LOOP1	INCFSZ	COUNTER,F
		GOTO	LOOP1	
		DECFSZ	COUNTER2,F
		GOTO 	LOOP1
		RETURN

BUZZ_LONG	BSF		PORTB, 0
			CALL	LONGER_DELAY
			BCF		PORTB, 0
			RETURN

BUZZ_SHORT	BSF		PORTB, 0
			MOVLW	d'13'
			MOVWF	TEMP
SBUZZDELAY	CALL	POWERUPDELAY
			DECFSZ	TEMP,F
			GOTO	SBUZZDELAY
			BCF		PORTB, 0
			RETURN

DEBOUNCE_DELAY	MOVLW	d'249'
				MOVWF	DEBOUNCECOUNT
			
DEBOUNCELOOP	NOP		
				DECFSZ	DEBOUNCECOUNT
				GOTO	DEBOUNCELOOP
				RETURN

CLEARDISPLAY	MOVLW b'00000' ;initializing clear display
				CALL ET
				MOVLW b'00001' ;clear display
				CALL ET
				RETURN

SET_BLINKING	MOVLW	b'00000'	;initializing display
				CALL	ET			

				MOVLW	b'01111'	;setting display to ON
				CALL	ET
				RETURN

CLEAR_BLINKING	MOVLW	b'00000'
				CALL	ET
				MOVLW	b'01100'
				CALL	ET
				RETURN

CURSOR_MOVELEFT		MOVLW	b'00000';set cursor move position to the left
					CALL	ET
					MOVLW	b'00100'
					CALL	ET
					RETURN

CURSOR_MOVERIGHT	MOVLW	b'00000';set cursor move position to the left
					CALL	ET
					MOVLW	b'00110'
					CALL	ET
					RETURN

CLEAR_REGISTERS			;CLEAR REGISTERS
						MOVLW	d'20' ;INITIALIZE POINTER
						MOVWF	FSR
NEXT2					CLRF	INDF
						INCFSZ	FSR
						MOVLW	d'40'
						SUBWF	FSR,0
						BTFSS	STATUS,Z
						GOTO	NEXT2
						RETURN
;---------------------------

;-----------------INDIRECT ADDRESSING---------------------

INDA           	MOVLW 	d'20'
				MOVWF	FSR
				MOVLW	d'10'
				MOVWF	ADDRESSING_COUNTER
				GOTO	LOOP1M

INDA1           MOVLW d'30'
				MOVWF FSR
				MOVLW d'10'
				MOVWF ADDRESSING_COUNTER

LOOP1M          BTFSC INDF,0
				CALL rectangle
 				
				BTFSC INDF,1
				CALL empty

				BTFSC INDF,2
				CALL letterS

				BTFSC INDF,3
				CALL letterE

				INCF FSR
				DECFSZ ADDRESSING_COUNTER

				GOTO  LOOP1M
				RETURN


END