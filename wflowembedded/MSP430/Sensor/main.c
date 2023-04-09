#include "driverlib.h"

#include "constants.h"
#include "uart.h"

int main(void) {

    WDT_A_hold(WDT_A_BASE);

    // Define the UART interface to communicate with bridge
    if (init_uart_interface() == false)
    {
        return (0);         // TODO: Inserire una routine di lampeggio di emergenza
    }

    // Initialize differtent component depending on the sensor type
#ifdef WATER_FLOW_SENSOR

    /* Water flow sensor has two sensors, a flow sensor and a temperature sensor */


#endif

    return (0);
}
