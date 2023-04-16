#include "driverlib.h"

#include "constants.h"
#include "uart.h"

int main(void) {

    WDT_A_hold(WDT_A_BASE);

    // Setup the emergency led driver in case it's needed
    GPIO_setAsOutputPin(EMERGENCY_LED_PORT, EMERGENCY_LED_PIN);

    // Define the UART interface to communicate with bridge
    if (init_uart_interface() == false)
    {
        while(true)
        {
            // Toggle LED pin
            GPIO_toggleOutputOnPin(EMERGENCY_LED_PORT, EMERGENCY_LED_PIN);

            // Wait for 0.5 seconds
            __delay_cycles(250000);

            // Toggle LED pin again
            GPIO_toggleOutputOnPin(EMERGENCY_LED_PORT, EMERGENCY_LED_PIN);

            // Wait for another 0.5 seconds
            __delay_cycles(250000);
        }
    }

    // Initialize differtent component depending on the sensor type
#ifdef WATER_FLOW_SENSOR

    /* Water flow sensor has two sensors, a flow sensor and a temperature sensor */
    GPIO_setAsInputPin(WFS_INTERRUPT_PORT, WFS_INTERRUPT_PIN);
    GPIO_interruptEdgeSelect(WFS_INTERRUPT_PORT, WFS_INTERRUPT_PIN, GPIO_LOW_TO_HIGH_TRANSITION);
    GPIO_enableInterrupt(WFS_INTERRUPT_PORT, WFS_INTERRUPT_PIN);
    GPIO_clearInterrupt(WFS_INTERRUPT_PORT, WFS_INTERRUPT_PIN);

#endif

    // Enable global interrupts
    __enable_interrupt();

    return (0);
}

#pragma vector=PORT2_VECTOR
__interrupt void Port2_ISR(void)
{
    // Check if interrupt was triggered by the desired pin
    if (GPIO_getInterruptStatus(WFS_INTERRUPT_PORT, WFS_INTERRUPT_PIN) == GPIO_LOW_TO_HIGH_TRANSITION) {
        // Call interrupt callback function

    }

    // Clear interrupt flag
    GPIO_clearInterrupt(WFS_INTERRUPT_PORT, WFS_INTERRUPT_PIN);
}
