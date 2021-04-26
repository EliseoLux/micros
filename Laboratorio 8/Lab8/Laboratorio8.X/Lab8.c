/*
 * File:   Lab8.c
 * Author: Eliseo Lux
 *
 * Created on April 20, 2021
 */
// PIC16F887 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits 
#pragma config WDTE = OFF       // Watchdog Timer Enable bit 
#pragma config PWRTE = OFF      // Power-up Timer Enable bit 
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit 
#pragma config CP = OFF         // Code Protection bit 
#pragma config CPD = OFF        // Data Code Protection bit 
#pragma config BOREN = OFF      // Brown Out Reset Selection bits 
#pragma config IESO = OFF       // Internal External Switchover bit 
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit 
#pragma config LVP = ON         // Low Voltage Programming Enable bit 

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit 
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits 

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>         //Librerias
#include <stdint.h>     //Librerias
#define _tmr0_value 100     //Valor del tmr0
#define _XTAL_FREQ 8000000 //Frecuenia del reloj

//Variables:
char centena, decena, unidad;
char dividendo, divisor;
char turno;
                          // 0     1    2     3     4
const char num_display[] = {0xFC, 0x60, 0xDA, 0xF2, 0x66,
                            0xB6, 0xBE, 0xE0, 0xFE, 0xF6};
                          //  5     6     7    8     9

//Interrupcion del timer0

void __interrupt()isr(void){

    if (T0IF == 1) { 
   
        //se apagan los display
        RD0 = 0;                          
        RD1 = 0;                        
        RD2 = 0;
        
        //se enciende un solo display
        if (turno == 3) {
            PORTC = (num_display[centena]);
            RD0 = 1;                        
        } 
        else if (turno == 2) {
            PORTC = (num_display[decena]);
            RD1 = 1;                        
        }
        else if (turno == 1) {
            PORTC = (num_display[unidad]);
            RD2 = 1;                       
        }
        //Lo realiza de nuevo
        turno--;
        if (turno == 0){
            turno = 3;                      
        }

        INTCONbits.T0IF = 0; 
        TMR0 = _tmr0_value; 
    }
}


void main(void){
    //Canal 5 y 6 como analogicos
    ANSEL = 0b01100000; 
    ANSELH = 0x00;
    
    //Puertos como salidas digitales
    TRISA = 0x00; 
    TRISC = 0x00; 
    TRISD = 0x00; 
    TRISE = 0b0011; // excepto los 2 pines quue son salidas analogias
    
    //Justificacion a la izquierda
    ADCON1bits.ADFM = 0; 
    //Voltmin:0V y Voltmax:5V
    ADCON1bits.VCFG0 = 0;   
    ADCON1bits.VCFG1 = 0;
    ADCON0bits.ADCS0 = 0;   
    ADCON0bits.ADCS1 = 1;
    ADCON0bits.CHS = 5; 
    __delay_us(100);
    ADCON0bits.ADON = 1;    //activo el modulo
    
    //Prescaler para el timer0, config de oscilacionn
    OSCCONbits.IRCF2 = 1; 
    OSCCONbits.IRCF1 = 1; 
    OSCCONbits.IRCF0 = 1;
    OSCCONbits.SCS = 1; 
    
    //Reloj Interno
    OPTION_REGbits.T0CS = 0; 
    OPTION_REGbits.PSA = 0; 
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 0;
    OPTION_REGbits.PS0 = 1; 
    TMR0 = 100; 

    //Habilitar interrupciones
    INTCONbits.GIE = 1; 
    INTCONbits.T0IE = 1; 
    INTCONbits.T0IF = 0; 
    
    ADCON0bits.GO = 1;  
    
    //Valor 0 a variables y puertos
    PORTA = 0; 
    PORTB = 0; 
    PORTC = 0; 
    PORTD = 0; 
    centena = 0; 
    decena = 0;
    unidad = 0;
    turno = 3;

    //Loop principal
    while (1) {
        
        if(ADCON0bits.GO == 0){
            
            if(ADCON0bits.CHS == 6){
                PORTA = ADRESH;
                ADCON0bits.CHS = 5;
            }
            else if(ADCON0bits.CHS == 5){
                dividendo = ADRESH;
                ADCON0bits.CHS = 6;
            }
            __delay_us(50);    
                            
            ADCON0bits.GO = 1;
        }
        //Se obtienen las unidades, decena y centena
        centena = dividendo / 100;                  
        decena = (dividendo - (100 * centena))/10; 
        unidad = dividendo - (100 * centena) - (decena * 10);   

    }
    return;     //end
}