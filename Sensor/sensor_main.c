#include <driverlib.h>
#include <time.h>

#include "sensor_main.h"

void init_sensors(void)
{

    GPIO_setAsInputPin(GPIO_PORT_P3, TEMPERATURE_SENSOR_PIN);
    GPIO_setAsInputPin(GPIO_PORT_P4, FLOW_SENSOR_PIN);
}

SensorsInputData read_sensors(void)
{
    SensorsInputData input;
    uint32_t

    // Get the current time
    time(&input.timestamp);

    // Read temperature and flow

    return input
}
