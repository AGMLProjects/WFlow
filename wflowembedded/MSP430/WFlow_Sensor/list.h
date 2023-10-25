#ifndef LIST_H_
#define LIST_H_

#include "driverlib.h"

#ifdef FLO
typedef struct {
    uint32_t hall_ticks;
    float temperature;
    uint32_t hall_ticks_old;
    uint32_t seconds;
    uint32_t start;
    uint32_t end;
    bool ready;
} SensorInput;

typedef struct {
    bool active;
    float target_temperature;
    float current_temperature;
    bool cold_active;
    bool hot_active;
    uint8_t cold_level;
    uint8_t hot_level;
} ActuatorState;

#elif defined(LEV)
typedef struct {
    uint32_t timestamp;
    bool ready;
} SensorInput;

#elif defined(HEA)
typedef struct {
    float liters;
    float temperature;
    float gas_volume;
    uint32_t start;
    uint32_t end;
    bool ready;
} SensorInput;

typedef struct {
    float target_temperature;
    bool warming_up;
} ActuatorState;

typedef struct {
    uint32_t start;
    uint32_t end;
    float temperature;
    uint16_t sequence_number;
} HeaterInterval;

typedef struct {
    HeaterInterval timeslots[144];
    bool complete;
} HeaterSequence;

#else
typedef uint32_t SensorInput;
#endif

// Node structure
typedef struct {
    SensorInput data;
    void* next;
} Node;

Node* createNode(SensorInput);
void insertNode(Node **, SensorInput);
SensorInput popNode(Node **);
bool available_data(Node *);

#endif /* LIST_H_ */
