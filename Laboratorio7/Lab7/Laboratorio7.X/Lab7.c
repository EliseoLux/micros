/*
 * File:   Lab7.c
 * Author: Eliseo Lux
 *
 * Created on April 13, 2021, 6:33 PM
 */
// PIC16F887 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1
#pragma config FOSC = EXTRC_NOCLKOUT// Oscillator Selection bits (RCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, RC on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF        // Watchdog Timer Enable bit (WDT enabled)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF       // RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF       // Brown Out Reset Selection bits (BOR enabled)
#pragma config IESO = OFF        // Internal External Switchover bit (Internal/External Switchover mode is enabled)
#pragma config FCMEN = OFF       // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
#pragma config LVP = OFF         // Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <stdint.h> //tipos de datos estandard y otros
//*****************************************************************************
//Variables:

char    Senial;
char    valor[3];
char    resta;
char    UNO;
char    DOS;
char    TRES;

//*****************************************************************************
//Función para tabla de 7 segmentos:
unsigned char tabla_seg(unsigned char valor){
    switch(valor) {
            case 0:                     //0
                return 0x3F;
                break;
            case 1:                     //1
                return 0x06;
                break;
            case 2:                     //2
                return 0x5B;
                break;
            case 3:                     //3
                return 0x4F;
                break;   
            case 4:                     //4
                return 0x66;
                break; 
            case 5:                     //5
                return 0x6D;
                break;
            case 6:                     //6
                return 0x7D;
                break;
            case 7:                     //7
                return 0x07;
                break;
            case 8:                     //8
                return 0x7F;
                break;
            case 9:                     //9
                return 0x6F;
                break;
            case 10:                    //A
                return 0x77;
                break;  
            case 11:                    //B
                return 0x7C;
                break;
            case 12:                    //C
                return 0x39;
                break;
            case 13:                    //D
                return 0x5E;
                break;
            case 14:                    //E
                return 0x79;
                break;
            case 15:                    //F
                return 0x71;
                break;
            
        }
}

//******************************************************************************
//Función para interrrupción:
void __interrupt() isr(void){       
    
    if(RBIF == 1)  {
        if (PORTBbits.RB0 == 0) {   //Señal para incrementaar
            PORTA++; 
        }
        if (PORTBbits.RB1 == 0) {   //Señal para decrementar
            PORTA--; 
        } 
        INTCONbits.RBIF = 0;    
    }
    
    if (T0IF == 1) {                
        TMR0 = 100;                 //Se realiza limpieza del Tmr0
        INTCONbits.T0IF = 0;        //Se realiza limipieza de banderas
        switch(Senial) {
            case 0:
                PORTD = 0;
                PORTC = valor[2];
                PORTDbits.RD0 = 1;
                Senial++;
                break;
            case 1:
                PORTD = 0;
                PORTC = valor[1];
                PORTDbits.RD1 = 1;
                Senial++;
                break;
            case 2:
                PORTD = 0;
                PORTC = valor[0];
                PORTDbits.RD2 = 1;
                Senial = 0;
                break;
        }
    }    
      
          
}
void main(void) {
    
//---------------------------------CONFIGURACIONES-------------------------------

    //configuraciones de RELOJ
    OSCCONbits.IRCF2 = 1;       
    OSCCONbits.IRCF1 = 0;
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.SCS   = 1;
    
    ANSELH = 0;
    ANSEL  = 0;
    TRISB  = 3;
    TRISA  = 0;
    TRISC  = 0;
    TRISD  = 0;
    OPTION_REGbits.nRBPU = 0;
    WPUBbits.WPUB0 = 1;         //Activación de PULL-UP
    WPUBbits.WPUB1 = 1;
    PORTA  = 0;                 //Puertos en cero
    PORTB  = 0;
    PORTC  = 0;
    PORTD  = 0;
    
    //INTERRUPT ON CHANGE
    IOCBbits.IOCB0 = 1;
    IOCBbits.IOCB1 = 1;
    
    //configuraciones en tmr0
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA  = 0;
    OPTION_REGbits.PS2  = 0;
    OPTION_REGbits.PS1  = 1;
    OPTION_REGbits.PS0  = 1;
    TMR0 = 100;                 
    INTCONbits.T0IF = 0;        
    
    //HABILITADO DE INTERRUPCIONES
    INTCONbits.GIE  = 1;
    INTCONbits.RBIE = 1;
    INTCONbits.T0IE = 1;
    

//---------------------------------PRINCIPAL------------------------------------
    while (1)
    {
        TRES = PORTA / 100;         //Convertidor a decimal
        resta = PORTA % 100;
        DOS = resta / 10;
        UNO = resta % 10;
        
        valor[2] = tabla_seg(TRES);   //Asignación de valores en display
        valor[1] = tabla_seg(DOS);
        valor[0] = tabla_seg(UNO);
     }
          
}