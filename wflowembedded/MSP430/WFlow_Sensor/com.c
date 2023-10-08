#include <string.h>
#include <stdint.h>
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

float convert_hall_to_liters(uint32_t hall_pulses, uint32_t seconds)
{
    // Flow rate in Hz
    float flow_rate = hall_pulses / seconds;
    float flow_rate_lpm = 1 + (flow_rate - 1) * (30 - 1) / (30 - 1);

    return flow_rate_lpm * (seconds / 60);

}
