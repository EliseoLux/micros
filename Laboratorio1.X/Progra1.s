;Archivo:	main.s
;Dispositivo:	PIC16F887
;Autor:		José Morales
;Compilador:	pic-as (v2.30), MPLABX v5.40
;
;Programa:	contador en el puerto A
;Hardware:	LEDs en el puerto A
;
;Creado: 2 de febrero, 2021
;Última modificación: 2 de feb, 2021

PROCESSOR 16F887
#include <xc.inc>
    
;configuration word 1
 CONFIG FOSC=INTRC_NOCLKOUT //OSCILADOR INTERNO SIN SALIDAS
 CONFIG WDTE=OFF //WDT DISEABLED (REINICIO REPETITIVO DEL PIC)
 CONFIG PWRTE=ON //PWRT ENABLED (ESPERA DE 72ms AL INICIAR)
 CONFIG MCLRE=OFF //EL PIN DE MCLR SE UTILIZA COMO I/0
 CONFIG CP=OFF	//SIN PROTECCIÓN DE CÓDIGO
 CONFIG CPD=OFF	//SIN PROTECCIÓN DE DATOS
 
 CONFIG BOREN=OFF //SIN REINICIO CUÁNDO EL VOLTAJE DE ALIMENTACIÓN BAJA DE 4V
 CONFIG IESO=OFF //REINCIO SIN CAMBIO DE RELOJ DE INTERNO A EXTERNO
 CONFIG FCMEN=OFF //CAMBIO DE RELOJ EXTERNO A INTERNO EN CASO DE FALLO
 CONFIG LVP=ON //PROGRAMACIÓN EN BAJO VOLTAJE PERMITIDA
 
;configuration word 2
 CONFIG WRT=OFF	//PROTECCIÓN DE AUTOESCRITURA POR EL PROGRAMA DESACTIVADA
 CONFIG BOR4V=BOR40V //REINICIO ABAJO DE 4V, (BOR21V=2.1V)


 
 PSECT udata_bank0 ;common memory
    cont_small: DS 1 ;1 byte
    cont_big:	DS 1
 
 PSECT resVect, class=CODE, abs, delta=2
 ;------------------------Vector reset-----------------------------------------
 ORG 00h    ;posición 0000h para el reset
 resetVec:
    PAGESEL main
    goto main
 PSECT code, delta=2, abs
 ORG 100H   ;posición para el código
 ;-----------------------------------------------------------------------------
 main:
    bsf	    STATUS, 5	;banco 11
    bsf	    STATUS, 6	
    clrf    ANSEL	;pines digitales
    clrf    ANSELH
    
    bsf	    STATUS, 5	;banco 01
    bcf	    STATUS, 6
    clrf    TRISA	;port A como salida
    
    bcf	    STATUS, 5	;banco 00
    bcf	    STATUS, 6
 ;-----------------------------------------------------------------------------
 loop:
    incf PORTA,1
    call delay_big
    goto loop	    ;loop forever
 ;-----------------------------------------------------------------------------
 delay_big:
    movlw 200		;valor inicial del contador
    movwf cont_big  
    call delay_small	;rutina de delay
    decfsz cont_big,1	;decrementar el contador
    goto $-2		;ejecutar dos líneas atrás
    return
    
 delay_small:
    movlw 249		;valor incial del contador
    movwf cont_small
    decfsz cont_small,1	;decrementar el contador 
    goto $-1		;ejecutar línea anterior
    return
    
    END
    