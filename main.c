#include "driverlib.h"

#ifdef TAP
#include "Sensor/sensor_main.h"
#endif

int main(void) {

    WDT_A_hold(WDT_A_BASE);

#ifdef TAP
    init_sensor();
#endif

    return (0);
}
