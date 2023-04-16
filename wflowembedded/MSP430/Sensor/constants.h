#ifndef CONSTANTS_H_
#define CONSTANTS_H_

// Sensor type definition
#define WATER_FLOW_SENSOR           0x01
//#define WATER_LEVEL_SENSOR          0x02
//#define SMART_HEAER_SENSOR          0x03

// Water flow sensor parameters
#define MAX_PRESSURE                1750000     // Pascal
#define MIN_PRESSURE                0           // Pascal

#define MIN_WATER_FLUX              1           // Liter/Minute
#define MAX_WATER_FLUX              30

// Led used to signal errors or other problems
#define EMERGENCY_LED_PIN           GPIO_PIN0
#define EMERGENCY_LED_PORT          GPIO_PORT_P1

// Water flow sensor
#define WFS_INTERRUPT_PIN           GPIO_PIN1
#define WFS_INTERRUPT_PORT          GPIO_PORT_P2

#endif /* CONSTANTS_H_ */
