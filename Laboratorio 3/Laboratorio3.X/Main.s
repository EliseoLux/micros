;Archivo:	Main.s
;Dispositivo:	PIC16F887
;Autor:		Eliseo Lux
;Compilador:	pic-as (v2.30), MPLABX v5.40
;
;Programa:	Botones y timer 0
;Hardware:	LEDs en el puerto A
;
;Creado: 16 de febrero, 2021
;Última modificación: 20 de feb, 2021

PROCESSOR 16F887
#include <xc.inc>
    ;configuration word 1

    CONFIG FOSC=INTRC_NOCLKOUT // Osilador interno sin salida
    CONFIG WDTE=OFF // WDT disabled (reinicio repetitivo del pic)
    CONFIG PWRTE=ON // PWRT eneable (espeera de 72ms al inicial)
    CONFIG MCLRE=OFF // El pin de MCLR se utiliza como I/O 
    CONFIG CP=OFF // Sin proteccion de código
    CONFIG CPD=OFF // Sin proteccion de datos
    
    CONFIG BOREN=OFF //Sin reinicio cuando el voltaje de alimentación baja de 4V
    CONFIG IESO=OFF // Reinicio sin cambio de reloj de interno a externo
    CONFIG FCMEN=OFF // Cambio de reloj externo a interno en caso de fallo
    CONFIG LVP=ON // Programación en bajo voltaje permitida
    
    ;configuration word 2
    
    CONFIG WRT=OFF // Proteccion de autoescritura por el programa desactivada
    CONFIG BOR4V=BOR40V // Reinicio abajo de 4V1 (BOR21V=2.1V)
    
    PSECT udata_bank0 ;common memory
	num_hex: DS 8 ;1 byte
	;var: DS 5
;_____________________________Para el vector reset______________________________   
    PSECT resVect, class=CODE, abs, delta=2
    OrG 00h	;posicion 0000h para el reset

resetVec:
	PAGESEL Lab03
	goto Lab03
    
    PSECT code, delta=2, abs
    ORG 100h
    
tabla7seg:
    clrf PCLATH
    bsf PCLATH,0
    ;andwf 0x0F
    
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
    
;________________________________Loop del codigo________________________________   

Lab03:
    ;______________________________IN_OUTS______________________________________   

    banksel ANSELH   ;Movernos al banco de ANSELH
    clrf ANSELH	     ;i/o digitales
    
    banksel TRISB    ;Movernos al banco de TRISx
    bsf TRISB,0      ;Para que PORTB sea input el pin 0 y 1
    bsf TRISB,1	     
    
    clrf TRISC	     ;Puertos de C como output
    bsf TRISC,4
    bsf TRISC,5
    bsf TRISC,6
    bsf TRISC,7
    
    clrf TRISD	     ;Puertos de D como output
    clrf TRISA
    clrf TRISE	     ;Puertos de E como output
    bsf TRISD ,7
    
    banksel PORTA    ;Movernos al banco de PORTx
    clrf PORTC	     ;Iniciar con los pines apagados
    clrf PORTD
    clrf PORTE
    clrf PORTA
    
    clrf num_hex
  
    ;______________________________OPTION_REG___________________________________   
 
    banksel OPTION_REG
    bcf OPTION_REG,5 ;Para configurar como timer interno
    bcf OPTION_REG,3 ;Activar el prescaler para timer0
    
    bsf OPTION_REG,0 ;Cargar el prescaler
    bsf OPTION_REG,1 
    bsf OPTION_REG,2 
    
    ;_________________________________OSCCON____________________________________
    
    banksel OSCCON
    bcf OSCCON,6     ;Config del osilador a 125kHz
    bcf OSCCON,5
    bsf OSCCON,4
    
    bsf OSCCON,0     ;osilador interno
    
Loop:
    
    ;Para el contador de 4bits con timer0
    banksel INTCON    
    btfss INTCON,2
    goto $-1
    call inc_puertoB
    call ress
    
    ;Para el contador hex
    
    /*bsf PORTD,0
    bsf PORTD,1
    bsf PORTD,2
    bsf PORTD,3
    bsf PORTD,4
    bsf PORTD,5
    bcf PORTD,6*/
    
    movf num_hex,w
    call tabla7seg
    movwf PORTD
    
    banksel PORTA
    btfsc PORTB,0
    call inc_cont_hex
    btfsc PORTB,1
    call dec_cont_hex
    
    ;Intervncion
    clrf PORTE
    movf PORTC,w
    subwf num_hex,w
    btfsc STATUS,2
    call interr
    
    movf num_hex,w
    movwf PORTA
        
    goto Loop
    
interr:
    ;banksel INTCON
    ;bsf INTCON,2
    clrf PORTC
    bsf PORTE,2
    return
    
dec_cont_hex:
    btfsc PORTB,1
    goto $-1
    decf num_hex
    movf num_hex,w
    call tabla7seg
    movwf PORTD
    
    return
    
inc_cont_hex:
    btfsc PORTB,0
    goto $-1
    incf num_hex
    movf num_hex,w
    call tabla7seg
    movwf PORTD
    return
    
inc_puertoB: 
    incf PORTC
    return
    
ress:
    movlw 195
    movwf TMR0
    bcf INTCON,2
    movwf PORTD
    return
    end
    