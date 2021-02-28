;***************************
 ;Archivo:	laboratorio4.s
;Dispositivo:	PIC16F887
;Autor:		Eliseo Lux
;Compilador:	pic-as (v2.30), MPLABX v5.40
;
;Programa:	Interrupt-on-change del PORTB
;Hardware:	LEDs en el puerto A
;
;Creado: 23 de febrero, 2021
;Última modificación: 23 de feb, 2021
;***************************
PROCESSOR 16F887
    #include <xc.inc>
    
    CONFIG FOSC=INTRC_NOCLKOUT 
    CONFIG WDTE=OFF	
    CONFIG PWRTE=ON	
    CONFIG MCLRE=OFF	
    CONFIG CP=OFF	
    CONFIG CPD=OFF	

    CONFIG BOREN=OFF	
    CONFIG IESO=OFF	
    CONFIG FCMEN=OFF	
    CONFIG LVP=ON	
    

    CONFIG WRT=OFF	
    CONFIG BOR4V=BOR40V 
    
UP EQU 1
DOWN EQU 0

PSECT UDATA_bank0
 ;cont:  DS 2;
    
PSECT UDATA_SHR
 W_TEMP:   DS  1
 STATUS_TEMP: DS 1
 VAR: DS 1
    
 PSECT resVect, CLASS=CODE, ABS, DELTA=2
 ORG 00H
 resetVec:
    PAGESEL lux
    goto lux
 
 GOTO lux
 ORG 04H
 PUSH:
    MOVWF W_TEMP
    SWAPF STATUS , W
    MOVWF STATUS_TEMP 
    
  ISR:
    BTFSC INTCON, 0
    CALL INT_IOCB
  POP:
SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE
    
    PSECT code, delta=2, abs
    ORG 100h
    
Pantalla7Seg:
    clrf PCLATH
    bsf PCLATH,0
    
    addwf PCL

    retlw 00111111B	;0
    retlw 00000110B	;1
    retlw 01011011B	;2
    retlw 01001111B	;3
    retlw 01100110B	;4
    retlw 01101101B	;5
    retlw 01111101B	;6
    retlw 00000111B	;7
    retlw 01111111B	;8
    retlw 01100111B	;9
    retlw 01110111B	;A
    retlw 01111100B	;B
    retlw 00111001B	;C
    retlw 01011110B	;D
    retlw 01111001B	;E
    retlw 01110001B	;F
 ;***************************   
INT_IOCB:
   BANKSEL PORTA
   BTFSS   PORTB, UP
   INCF    PORTA
   BTFSS   PORTB, DOWN
   DECF    PORTA
   BCF	   INTCON, 0
   
   RETURN 
 ;***************************  
  PSECT CODE, ABS, DELTA=2
  ORG 100H
 ;***************************
 lux:
    CALL  CONFIG_IO
    CALL  CONFIG_RELOJ
    CALL CONFIG_IOCRB
    CALL  CONFIG_INT_ENABLE
    
    
  LOOP:
    movf PORTA,w
    call Pantalla7Seg
    movwf PORTD
    GOTO LOOP 
    
  CONFIG_IOCRB:
    BANKSEL TRISA
    BSF     IOCB,UP
    BSF     IOCB , DOWN
    
    BANKSEL PORTA
    MOVF    PORTB,W
    BCF     RBIF
    RETURN
  CONFIG_IO:
        BSF STATUS, 5
	BSF STATUS, 6
	CLRF ANSEL
	CLRF ANSELH

	Banksel TRISB
	CLRF TRISA
	CLRF TRISB
	BSF  TRISB, UP
	BSF TRISB , DOWN
	
	BCF OPTION_REG, 7
	BSF WPUB, UP
	BSF WPUB, DOWN
	
	BCF STATUS,5
	BCF STATUS,6
	CLRF PORTA
	CLRF PORTD
	CLRF PORTC
	RETURN
CONFIG_RELOJ:
    BANKSEL OSCCON
    BSF IRCF2
    BSF IRCF1
    BCF IRCF0
    BSF SCS
    RETURN
    
  CONFIG_INT_ENABLE:
    BSF INTCON, 7
    BSF  INTCON, 3
    BCF  INTCON,0
    RETURN
    END
    