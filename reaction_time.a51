
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
    LJMP MAIN

ORG 000BH
	INC R1
	RETI

ORG 100H
MAIN:



      acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
	  START:
	  MOV R1,#00H
      ;step1
      MOV A,#10000000B ;LINE1
	  ACALL lcd_command
	  ACALL delay
	  MOV   dptr,#my_string1
	  ACALL lcd_sendstring
	  ACALL delay
	  
	  MOV A,#11000000B ;LINE2
	  ACALL lcd_command
	  ACALL delay
	  MOV   dptr,#my_string2
	  ACALL lcd_sendstring
	  ACALL delay
	  
	  MOV P1,#0FH ;INPUT
	  
	  ACALL DELAY_SEC
	  ACALL DELAY_SEC
	  
	  SETB P1.4
	  
	  SETB EA
	  SETB ET0
	  MOV TMOD,#01
	  MOV TL0,#00H
	  MOV TH0,#00H
	  SETB TR0
	  
	  
	  LOOP: MOV C,P1.3
	  JNC LOOP
	  CLR TR0
	  CLR P1.4
	  
	  MOV A,#10000000B ;LINE1
	  ACALL lcd_command
	  ACALL delay
	  MOV   dptr,#my_string3
	  ACALL lcd_sendstring
	  ACALL delay
	  
	  MOV A,#11000000B ;LINE2
	  ACALL lcd_command
	  ACALL delay
	  MOV   dptr,#my_string4
	  ACALL lcd_sendstring
	  ACALL delay
	  
	  MOV A,#11001001B
	  ACALL lcd_command
	  ACALL delay
	  MOV A,R1
	  ANL A,#0F0H
	  SWAP A
	  ACALL HEX_ASCII
	  ACALL lcd_senddata
	  ACALL delay
	  
	  MOV A,R1
	  ANL A,#0FH
	  ACALL HEX_ASCII
	  ACALL lcd_senddata
	  ACALL delay
	  
	  MOV A,#11001100B
	  ACALL lcd_command
	  ACALL delay
	  MOV A,TH0
	  ANL A,#0F0H
	  SWAP A
	  ACALL HEX_ASCII
	  ACALL lcd_senddata
	  ACALL delay
	  
	  MOV A,TH0
	  ANL A,#0FH
	  ACALL HEX_ASCII
	  ACALL lcd_senddata
	  ACALL delay
	  
	  MOV A,TL0
	  ANL A,#0F0H
	  SWAP A
	  ACALL HEX_ASCII
	  ACALL lcd_senddata
	  ACALL delay
	  
	  MOV A,TL0
	  ANL A,#0FH
	  ACALL HEX_ASCII
	  ACALL lcd_senddata
	  ACALL delay
	  
	  ACALL DELAY_SEC
	  ACALL DELAY_SEC
	  ACALL DELAY_SEC
	  ACALL DELAY_SEC
	  ACALL DELAY_SEC
	  
	  LJMP START
	  
	  
	  
	  
	  
	  
	
	  
	 
	 
	  
	  
	 
			//stay here 

;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
	push 0e0h
	lcd_sendstring_loop:
	 	 clr   a                 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret

DELAY_SEC:
    PUSH 0
	MOV R0,#40
	
	HERE1:
	MOV TMOD,#01
	MOV TL0,#0B0H
	MOV TH0,#3CH
	SETB TR0
	AGAIN: JNB TF0, AGAIN
    CLR TR0
    CLR TF0
	DJNZ R0,HERE1
	POP 0
	RET

HEX_ASCII:
mov r7,a
clr c 
subb a,#0ah
jc temp
mov a,r7
add a,#7h
sjmp lA1
	
temp:
mov a,r7
lA1 : add a,#30h
ret
;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "  if LED glows  ", 00H
my_string2:
         DB   "   Toggle SW1   ", 00H
my_string3:
         DB   "  Reaction Time ", 00H
my_string4:
         DB   "Count is 00 0000", 00H

			 
			 
end

