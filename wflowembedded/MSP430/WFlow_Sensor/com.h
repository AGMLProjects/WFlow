#ifndef COM_H_
#define COM_H_

// Define messages' codes
#define SA      0x5341          // Set address
#define SD      0x5344          // Send SensorInput data

uint32_t intDecode(uint8_t *, uint32_t);                // Convert an integer into a string
void intEncode(uint32_t, uint8_t *, uint8_t);           // Convert a string into an integer
void dec_encode(uint32_t, uint8_t *);                   // Convert a decimal into a string
bool isDigit(uint8_t *, int8_t);                        // Check if a string contains an integer
void floatEncode(uint8_t *, float, uint8_t, uint8_t);

void create_ack_message(uint8_t *, uint32_t, uint16_t *);
void create_error_message(uint8_t *, uint32_t, uint16_t *);

#ifdef FLO
void create_sd_message(uint8_t *, float, float, uint32_t, uint32_t, uint16_t *);
#elif defined(LEV)
void create_sd_message(uint8_t *, uint32_t, uint16_t *);
#else
void create_sd_message(uint8_t *, uint16_t *);
#endif

float convert_hall_to_liters(uint32_t, uint32_t);

#endif /* COM_H_ */
