;Archivo:	Laboratorio5.s
;Dispositivo:	PIC16F887
;Autor:		Eliseo Lux
;Compilador:	pic-as (v2.30), MPLABX v5.40
;
;Programa:	Displays simultaneos y contador de 8 bits
;Hardware:	Leds en portA, displays en port C y D, pushbotton en PortB
;
;Creado: 6 de marzo del 2021
;Última modificación: 6 de marzo, 2021

    PROCESSOR 16F887
    #include <xc.inc>
    
    
    CONFIG FOSC=INTRC_NOCLKOUT //Oscillador interno
    CONFIG WDTE=OFF	//WDT disabled (reinicio repetitivo del pic)
    CONFIG PWRTE=OFF	//PWRT enabled (espera de 72ms al iniciar)
    CONFIG MCLRE=OFF	//El pin de MCLR se utiliza como I/O
    CONFIG CP=OFF	//Sin proteccion de codigo
    CONFIG CPD=OFF	//Sin proteccion de datos

    CONFIG BOREN=OFF	//Sin reinicio cuando el voltaje de alimentacion baja 4v
    CONFIG IESO=OFF	//Reinicio sin cambio de reloj de interno a externo
    CONFIG FCMEN=OFF	//Cambio de reloj externo a interno en caso de fallo
    CONFIG LVP=OFF	//programacion en bajo voltaje permitida
    
    CONFIG WRT=OFF	//Proteccion de autoescritura por el programa desactivada
    CONFIG BOR4V=BOR40V //Reinicio abajo de 4V, (BOR21v=2.1v)
    
   PSECT udata_shr ;common memory
	Situation_DUR: DS 1 ;1 byte 
	Cont1: DS 1	    ;1 byte 
	Cont2: DS 1	    ;1 byte 
	NowPortb: DS 1	    ;1 byte 
	OldPortb: DS 1	    ;1 byte 
	DECENA: DS 1	    ;1 byte
	CENTENA: DS 1	    ;1 byte
	UNIDAD: DS 1	    ;1 byte
	ValorPorta: DS 1    ;1 byte 
	WDUR: DS 1	    ;1 byte 
 
 PSECT resVect, class=CODE, abs, delta=2
 ORG 0x00	;posición de reset
 GOTO config_io
 
 ORG 0X04
 
 PUSH:
    MOVWF WDUR
    SWAPF STATUS, W
    MOVWF Situation_DUR
    
    BTFSC INTCON, 2 ;VERFICAR OVERFLOW TIMER 0
    CALL ISRTMR0
    BTFSC INTCON, 0
    CALL ISR_CONTADOR
    
 POP:
    SWAPF Situation_DUR,W
    MOVWF STATUS
    SWAPF WDUR, F
    SWAPF WDUR, W
    
    RETFIE
 ;-----------------------------------------------------------------------------
 tabla: ;Tabla de 7 seg para numero binario a decimal
       
    addwf PCL, F
    retlw 00111111B ;0
    retlw 00000110B ;1
    retlw 01011011B ;2
    retlw 01001111B ;3
    retlw 01100110B ;4
    retlw 01101101B ;5
    retlw 01111101B ;6
    retlw 00000111B ;7
    retlw 01111111B ;8
    retlw 01100111B ;9
    retlw 01110111B ;A
    retlw 01111100B ;B
    retlw 00111001B ;C
    retlw 01011110B ;D
    retlw 01111001B ;E
    retlw 01110001B ;F
 
 ISRTMR0:
    BCF INTCON, 2
    MOVLW 246
    MOVWF TMR0
    INCF Cont1, F
    INCF Cont2, F
    
    
    BCF PORTB, 2
    BCF PORTB, 3
    MOVF Cont1, W
    ADDWF PCL, F
    GOTO Display1
    GOTO Display2
 ;----------------------Subrutinas----------------------------------------------  
 Display1: ;Esta subrutina convierte binario a hexadecimal para Display1
    MOVF PORTA, W
    ANDLW 00001111B
    CALL tabla
    MOVWF PORTC
    BSF PORTB, 3
    GOTO SALIR
    
Display2: ;Esta subrutina convierte binario a hexadecimal para Display2
    SWAPF PORTA, W
    ANDLW 00001111B
    CALL tabla
    MOVWF PORTC
    BSF PORTB, 2
    MOVLW 255
    MOVWF Cont1   
    
 SALIR: ;Esta subrutina mostrara el valor decimal en displays
    BCF PORTB, 4
    BCF PORTB, 5
    BCF PORTB, 6
    MOVF Cont2, W
    ADDWF PCL, F
    GOTO Display3
    GOTO Display4
    GOTO Display5

 Display3:;Esta subrutina convierte binario a hexadecimal para Display3
    MOVF UNIDAD, W
    CALL tabla
    MOVWF PORTD
    BSF PORTB, 6
    RETURN
 
 Display4:;Esta subrutina convierte binario a hexadecimal para Display4
    MOVF DECENA, W
    CALL tabla
    MOVWF PORTD
    BSF PORTB, 5
    RETURN
 
 Display5:;Esta subrutina convierte binario a hexadecimal para Display2
    MOVF CENTENA, W
    CALL tabla
    MOVWF PORTD
    BSF PORTB, 4
    MOVLW 255
    MOVWF Cont2
    RETURN
     
 ISR_CONTADOR: ;interrupcion para el contador binario
    BCF INTCON, 0
    
    MOVF NowPortb,W
    MOVWF OldPortb
    MOVF PORTB, W
    MOVWF NowPortb
    
    BTFSC OldPortb, 0
    GOTO Comprobar
    BTFSC NowPortb, 0
    INCF PORTA, F
    
    
 Comprobar:
    BTFSC OldPortb, 1
    RETURN
    BTFSC NowPortb, 1
    DECF PORTA, F
    RETURN
       
 config_io: ;Configuracion de los bits
    
    BSF STATUS, 5
    BSF STATUS, 6 ;Banco 3
    
    CLRF ANSEL
    CLRF ANSELH
    
    BSF STATUS, 5 ;Banco 1
    BCF STATUS, 6 ;Banco 1
    
    CLRF TRISA
    CLRF TRISC
    CLRF TRISD
    CLRF TRISB ;Puerto A,B,C,D como salidas
    
    BSF TRISB, 0
    BSF TRISB, 1 ;Bit 0 y 1 del puerto B como entrada
    
    BCF OPTION_REG, 7 ;Pull ups puerto B
    BCF OPTION_REG, 5 ;Clok interno
    BCF OPTION_REG, 3 ;Prescaler
    BSF OPTION_REG, 2 ;Prescaler a 256
    BSF OPTION_REG, 1
    BSF OPTION_REG, 0
    
    BSF INTCON, 7 ;INTERRUPCION GLOBAL
    BSF INTCON, 5 ;INTERRUPCION TIMER0
    BSF INTCON, 3 ;INTERRUPCION DEL PUERTO B
    
    BSF IOCB, 0
    BSF IOCB, 1 ;ACTIVAR INTERRUPCION EN PIN RB0 Y RB1
    
    BCF STATUS, 5 ;Banco 0
    
    CLRF PORTA ;Limpiar puertoA
    CLRF PORTB ;Limpiar puertoB
    CLRF PORTC ;Limpiar puertoC
    CLRF PORTD ;Limpiar puertoD
    CLRF Cont1
    CLRF Cont2
    MOVLW 246 
    MOVWF TMR0 ;sucederá interrupción cada 2.5 ms

    
LOOP:
    MOVF PORTA, W ;movemos el valor del puerto A a W
    MOVWF ValorPorta ;Movemos W a la variable VALPORTA
    CALL BINDEC ; Llamamos a la sub rutina que pasa de binario a decimal
    GOTO LOOP
 
BINDEC: ;Esta subrutina pasa de binario a decimal
    BCF INTCON, 7
    CLRF CENTENA
    CLRF DECENA
    CLRF UNIDAD
    RESTCENT:
    MOVLW 100
    SUBWF ValorPorta, W
    BTFSS STATUS, 0
    GOTO RESTDEC
    MOVWF ValorPorta
    INCF CENTENA, F
    GOTO RESTCENT
    RESTDEC:
    MOVLW 10
    SUBWF ValorPorta, W
    BTFSS STATUS, 0
    GOTO RESTUNI
    MOVWF ValorPorta
    INCF DECENA, F
    GOTO RESTDEC
    RESTUNI:
    MOVF ValorPorta, W
    MOVWF UNIDAD
    BSF INTCON, 7
    RETURN
    
END