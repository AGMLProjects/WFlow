#include <msp430.h>

void main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // Stop the Watchdog timer

    // Configure UART pins (TXD and RXD) - P3.3 and P3.4
    P3SEL |= BIT3 | BIT4;
    UCA0CTL1 |= UCSWRST;        // Put USCI in reset
    UCA0CTL1 |= UCSSEL_2;        // Clock source: SMCLK

    // Baud rate settings (assuming 16MHz SMCLK)
    // For 9600 baud rate: UCBRx = 1666, UCBRSx = 6, UCBRFx = 0, UCOS16 = 1
    UCA0BR0 = 1666;
    UCA0BR1 = 0;
    UCA0MCTL |= UCBRS_6 | UCBRF_0 | UCOS16;

    UCA0CTL1 &= ~UCSWRST;       // Release USCI from reset

    // Main loop
    while(1)
    {
        // Transmit data
        UCA0TXBUF = 'A';

        // Wait until the transmission is complete
        while(!(UCA0IFG & UCTXIFG));

        // Add a delay between transmissions
        __delay_cycles(1000000);
    }
}
