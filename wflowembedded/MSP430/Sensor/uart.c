#include "driverlib.h"

#include "uart.h"

const USCI_A_UART_initParam param = {
     USCI_A_UART_CLOCKSOURCE_SMCLK,
     UCS_getSMCLK(UCS_BASE),
     BAUDRATE,
     USCI_A_UART_NO_PARITY,
     USCI_A_UART_LSB_FIRST,
     USCI_A_UART_ONE_STOP_BIT,
     USCI_A_UART_MODE,
     USCI_A_UART_OVERSAMPLING_BAUDRATE_GENERATION
};

static UartState state;

bool init_uart_interface()
{
    // Initialize the UART module with proper settings
    if (STATUS_FAIL == USCI_A_UART_init(USCI_A0_BASE, &param))
    {
        return false;
    }

    // Enable the UART module for operation
    USCI_A_UART_enable(USCI_A0_BASE);

    // Enable the RX input
    USCI_A_UART_enableInterrupt(USCI_A0_BASE, UCRXIE);

    state.receiving = false;
    state.messageReady = false;

    return true;
}

void send_uart_data(uint8_t *message, uint8_t len)
{
    for(uint8_t index = 0; index < len; index = index + 1)
    {
        // Wait the TX buffer to be ready
        while (!USCI_A_UART_interruptStatus(USCI_A0_BASE, UCTXIFG));

        // Send one byte
        USCI_A_transmitData(USCI_A0_BASE, message[index]);
    }

    return;
}

// Define the RX interrupt vector routine
#pragma vector=USCI_A0_VECTOR
__interrupt void USCI_A0_ISR(void)
{
    switch(__even_in_range(UCA0IV, 4))
    {
        // Vector 2 is RX interrupt flag
        case 2:
        {
            if (state.receiving == false || state.rxIndex >= 255)
            {
                state.rxIndex = 0;
                state.receiving = true;
                state.messageReady = false;
            }

            state.rxBuffer[state.rxIndex] =  USCI_A_UART_receiveData(USCI_A0_BASE);

            if (state.rxBuffer[state.rxIndex] == END_CHR)
            {
                state.receiving = false;
                state.messageReady = true;
            }
            else
            {
                state.rxIndex = state.rxIndex + 1;
            }

            break;
        }
        default: break;
    }
}
