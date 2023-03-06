#ifndef SENSOR_SENSOR_MAIN_H_
#define SENSOR_SENSOR_MAIN_H_


#define TEMPERATURE_SENSOR_PIN      GPIO_PIN0       ///< Define which PIN to use for temperature sensor input
#define FLOW_SENSOR_PIN             GPIO_PIN1       ///< Define which PIN to use for water flow sensor input

/// Handle sensors' inputs with the relative timestamp
typedef struct {
    uint32_t temperature;
    uint32_t flow;
    time_t timestamp;
} SensorsInputData;

void init_sensors(void);
SensorsInputData read_sensors(void);

#endif /* SENSOR_SENSOR_MAIN_H_ */
