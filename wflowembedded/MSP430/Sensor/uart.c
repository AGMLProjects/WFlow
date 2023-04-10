#include "driverlib.h"

#include "uart.h"

static UartState state;
static USCI_A_UART_initParam param = {0};

bool init_uart_interface()
{
    param.clockPrescalar = UCS_getSMCLK() / BAUDRATE;
    param.selectClockSource = USCI_A_UART_CLOCKSOURCE_SMCLK;
    param.firstModReg = 0;
    param.secondModReg = 0;
    param.msborLsbFirst = USCI_A_UART_LSB_FIRST;
    param.numberofStopBits = USCI_A_UART_ONE_STOP_BIT;
    param.parity = USCI_A_UART_NO_PARITY;
    param.uartMode = USCI_A_UART_MODE;
    param.overSampling = USCI_A_UART_LOW_FREQUENCY_BAUDRATE_GENERATION;

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
    uint8_t index;

    for(index = 0; index < len; index = index + 1)
    {
        // Wait the TX buffer to be ready
        while (!USCI_A_UART_getInterruptStatus(USCI_A0_BASE, UCTXIFG));

        // Send one byte
        USCI_A_UART_transmitData(USCI_A0_BASE, message[index]);
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
