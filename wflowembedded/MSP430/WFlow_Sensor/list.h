#ifndef LIST_H_
#define LIST_H_

#include "driverlib.h"

#ifdef FLO
typedef struct {
    uint32_t hall_ticks;
    float temperature;
    uint32_t hall_ticks_old;
    uint32_t seconds;
    bool ready;
} SensorInput;
#else
typedef uint32_t SensorInput;
#endif

// Node structure
typedef struct {
    SensorInput data;
    void* next;
} Node;

Node* createNode(SensorInput);
void insertNode(Node *, SensorInput);
SensorInput popNode(Node *);
bool available_data(Node *);

#endif /* LIST_H_ */
