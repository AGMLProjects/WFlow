#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include "driverlib.h"

#include "com.h"

/// Table to convert HEX to ASCII
const uint8_t HEXASCII[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
//-------------------------------------------------------------------------------------------------


/**
 * Decode from ASCII to integer numbers
 * @param adr Array of ASCII char to be decoded
 * @param n Length of array (how many digits)
 * @return The decoded number
 */
uint32_t intDecode(uint8_t *adr, uint32_t n)
{
    uint32_t val = 0;

    while (n > 0)
    {
        val = val * 10;
        val = val + (*adr++) - '0';
        n = n - 1;
    }
    return val;
}

/**
 * Encode from integer numbers to ASCII
 * @param val Integer to be encoded
 * @param adr Destination string array
 * @param n Number of digits to be encoded
 */
void intEncode(uint32_t val, uint8_t *adr, uint8_t n)
{
    while (n > 0)
    {
        if (val != 0)
        {
            adr[n-1] = val % 10 + '0';
            val /= 10;
        }
        else
        {
            adr[n-1] = '0';
        }

        n = n - 1;
    }
}

/**
 * Encode from BCD decimal numbers to ASCII
 * Most significant byte is the integer part, less significant one is the decimal part
 * @param val Number to be encoded
 * @param adr Destination array
 */
void dec_encode(uint32_t val, uint8_t *adr)
{
    uint8_t n;
    uint32_t aux;

    // Decode the integer part
    aux = val >> 8;
    n = 2;
    while (n > 0)
    {
        if (aux != 0)
        {
            adr[n-1] = aux % 10 + '0';
            aux /= 10;
        }
        else
        {
            adr[n - 1] = '0';
        }

        n = n - 1;
    }

    // Decode the decimal part
    adr[2] = '.';
    aux = (val & 0xFF) * 100 / 256;
    n = 2;
    while (n > 0)
    {
        if (aux != 0)
        {
            adr[n + 2] = aux % 10 + '0';
            aux = aux / 10;
        }
        else
        {
            adr[n + 2] = '0';
        }

        n = n - 1;
    }
}

/**
 * Check if the given string represent a number
 * @param txt ASCII string to check
 * @param len Length of the number to check
 * @return True if it's a number
 */
bool isDigit(uint8_t *txt, int8_t len)
{
   while (len > 1)
   {
       if (*txt < '0' || *txt > '9')
       {
           return false;
       }
       txt = txt + 1;
       len = len - 1;
   }

   return true;
}

void floatEncode(uint8_t *buffer, float number, uint8_t int_len, uint8_t dec_len)
{
    uint32_t integer_part = 0, decimal_part = 0;
    uint8_t tmp;

    // Extract the decimal part of given len
    tmp = dec_len;
    integer_part = (uint32_t) number;       // Keep only the integer

    while(tmp > 0)
    {
        if(decimal_part == 0)
        {
            decimal_part = 10;
        }
        else
        {
            decimal_part = decimal_part * 10;
        }

        number = number * 10;
        tmp = tmp - 1;
    }

    // Keep only the decimal part
    decimal_part = (uint32_t) number % decimal_part;

    // Encode the two parts
    intEncode(integer_part, buffer, int_len);
    buffer[int_len] = '.';
    intEncode(decimal_part, &buffer[int_len + 1], dec_len);
}

void create_ack_message(uint8_t *message, uint32_t device_address, uint16_t *count)
{
    message[0] = 'O';
    message[1] = 'K';
    intEncode(device_address, &message[2], 10);
    message[12] = '\n';
    *count = 13;
}

void create_error_message(uint8_t *message, uint32_t device_address, uint16_t *count)
{
    message[0] = 'E';
    message[1] = 'R';
    intEncode(device_address, &message[2], 10);
    message[12] = '\n';
    *count = 13;
}

#ifdef FLO
void create_sd_message(uint8_t *message, float liters, float temperature, uint32_t start, uint32_t end, uint16_t *count)
{
    message[0] = 'S';
    message[1] = 'D';

    // Convert the liters into string
    floatEncode(&message[2], liters, 4, 2);

    // Convert the temperature
    floatEncode(&message[9], temperature, 3, 2);

    intEncode(start, &message[15], 10);
    intEncode(end, &message[25], 10);
    message[35] = '\n';

    *count = 36;

}

void parse_ex_command(uint8_t *message, ActuatorState *actuator_state)
{
    float target = 0.0;

    target = intDecode(&message[2], 3) / 10.0;

    // If the actuator was active, just turn it off
    if (actuator_state->active == true)
    {
        actuator_state->active = false;
        return;
    }
    else
    {
        // Set the initial state to open both hot and cold water
        actuator_state->target_temperature = target;
        actuator_state->hot_active = true;
        actuator_state->cold_active = true;
        actuator_state->hot_level = 5;
        actuator_state->cold_level = 5;

        set_water_output(5, 5);
        actuator_state->active = true;
    }
}

void set_water_output(uint8_t hot_value, uint8_t cold_value)
{
    uint8_t bitmask;

    // Ensure that the values are correct
    if (hot_value + cold_value != 10)
    {
        return;
    }

    // Set the HOT WATER level output
    bitmask = 0b00001111;
    bitmask &= ~(1 << hot_value);
    P6OUT = bitmask;

    // Update the indicator
    if (hot_value > 0)
    {
        P1OUT |= BIT0;
    }
    else
    {
        P1OUT &= ~BIT0;
    }

    // Set the COLD WATER level output
    bitmask = 0b00001111;
    bitmask &= ~(1 << cold_value);
    P3OUT = bitmask;

    // Update the indicator
    if (cold_value > 0)
    {
        P4OUT |= BIT7;
    }
    else
    {
        P4OUT &= ~BIT7;
    }


}

#elif defined(LEV)
void create_sd_message(uint8_t *message, uint32_t start, uint16_t *count)
{
    message[0] = 'S';
    message[1] = 'D';

    intEncode(start, &message[2], 10);
    message[12] = '\n';

    *count = 13;

}
#elif defined(HEA)
void create_sd_message(uint8_t *message, float liters, float temperature, float gas_volume, uint32_t start, uint32_t end, uint16_t *count)
{
    message[0] = 'S';
    message[1] = 'D';

    // Convert the liters into string
    floatEncode(&message[2], liters, 4, 2);

    // Convert the temperature
    floatEncode(&message[9], temperature, 3, 2);

    // Convert the gas
    floatEncode(&message[15], gas_volume, 2, 3);

    intEncode(start, &message[21], 10);
    intEncode(end, &message[31], 10);
    message[46] = '\n';

    *count = 47;

}

void parse_ex_command(uint8_t *message, HeaterSequence *heater_sequence)
{
    float target = 0.0;
    uint32_t start = 0, end = 0;
    uint16_t sequence_number = 0;

    sequence_number = intDecode(&message[2], 3);
    start = intDecode(&message[5], 10);
    end = intDecode(&message[15], 10);
    target = intDecode(&message[25], 3) / 10.0;

    // If the previous sequence was completed, clean all
    if (heater_sequence->complete == true)
    {
        HeaterInterval empty = {.start = 0, .end = 0, .sequence_number = 0, .temperature = 0.0};

        for (int i = 0; i < 144; i = i + 1)
        {
            heater_sequence->timeslots[i] = empty;
        }
    }

    // Search the slot to insert the new sequence
    HeaterInterval new = {.sequence_number = sequence_number, .start = start, .end = end, .temperature = target};

    for(int i = 0; i < 144; i = i + 1)
    {
        if (heater_sequence->timeslots[i].sequence_number == 0)
        {
            heater_sequence->timeslots[i] = new;
        }
    }

    // If this packet has a sequence number of 0, it completes the sequence
    if(sequence_number == 0)
    {
        heater_sequence->complete = true;
    }
    else
    {
        heater_sequence->complete = false;
    }
}
#else
void create_sd_message(uint8_t *message, uint16_t *count)
{
    message[0] = 'E';
    message[1] = 'R';
    message[2] = 'R';

    *count = 3;
}
#endif

float convert_hall_to_liters(uint32_t hall_pulses, uint32_t seconds)
{
    // Flow rate in Hz
    return ((float)hall_pulses / (float)seconds) / 35.0;
}
