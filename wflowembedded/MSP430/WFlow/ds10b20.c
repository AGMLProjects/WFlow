#include "ds18b20.h"

//**********************************************************************************************************************************************************
void ds18b20_init_port(void) {
    DS18B20_PORT_DIR |= DS18B20_PORT_PIN;
    DS18B20_PORT_OUT |= DS18B20_PORT_PIN;
    // Typical pull-up/down resistor from MSP430 is 35kOhm, too large for the ideal value ~5kOhm
    DS18B20_PORT_REN |= DS18B20_PORT_PIN;
}

//**********************************************************************************************************************************************************
uint8_t ds18b20_reset(void)
{
    DS18B20_LO
    __delay_cycles(500 * 8);                  // 480us minimum
    DS18B20_RLS
    __delay_cycles(60 * 8);                   // slave waits 15-60us  // try 80 or 40
    if (DS18B20_IN) return 1;       // line should be pulled down by slave
    __delay_cycles(240 * 8);                  // slave TX presence pulse 60-240us
    if (!DS18B20_IN) return 2;      // line should be "released" by slave
    return 0;
}

//**********************************************************************************************************************************************************
void ds18b20_write_bit(uint8_t bit)
{
    DELAY_US(1);                    // recovery, min 1us
    DS18B20_HI
    if (bit) {
        DS18B20_LO
        DELAY_US(5);                // max 15us
        DS18B20_RLS                 // input
        __delay_cycles(50 * 8);
    }
    else {
        DS18B20_LO
        __delay_cycles(60 * 8);               // min 60us
        DS18B20_RLS                 // input
        DELAY_US(1);
    }
}

//**********************************************************************************************************************************************************
uint8_t ds18b20_read_bit()
{
    uint8_t bit=0;
    DELAY_US(1);
    DS18B20_LO
    DELAY_US(1);                    // hold min 1us
    DS18B20_RLS
    DELAY_US(5);                    // 15us window
    if (DS18B20_IN) bit = 1;
    __delay_cycles(45 * 8);                   // rest of the read slot
    return bit;
}

//**********************************************************************************************************************************************************
void ds18b20_write_byte(uint8_t byte)
{
    uint8_t i;
    for(i = 8; i > 0; i--)
    {
        ds18b20_write_bit(byte & 1);
        byte >>= 1;
    }
}

//**********************************************************************************************************************************************************
uint8_t ds18b20_read_byte()
{
    uint8_t i;
    uint8_t byte = 0;
    for(i = 8; i > 0; i--)
    {
        byte >>= 1;
        if (ds18b20_read_bit()) byte |= 0x80;
    }
    return byte;
}

//**********************************************************************************************************************************************************
uint16_t ds18b20_read_temp_registers ( void )
{
    uint8_t i;
    uint16_t byte = 0;
    for(i = 16; i > 0; i--){
        byte >>= 1;
        if (ds18b20_read_bit()) {
            byte |= 0x8000;
        }
    }
    return byte;
}

//**********************************************************************************************************************************************************
uint64_t readRom (void){
    uint8_t i;
    uint64_t byte = 0;

    ds18b20_reset();
    ds18b20_write_byte(DS1820_READ_ROM);

    for(i = 64; i > 0; i--){
        byte >>= 1;
        if (ds18b20_read_bit()) {
            byte |= 0x8000000000000000;
        }
    }
    return byte;
}

//**********************************************************************************************************************************************************
float ds18b20_get_temp(void)
{
    volatile uint16_t temp = 0;
    ds18b20_reset();
    ds18b20_write_byte(DS18B20_SKIP_ROM);           // skip ROM command
    ds18b20_write_byte(DS18B20_CONVERT_T);          // convert T command
    DS18B20_HI
    volatile int i = 0;
    while(i < 10)
    {
        __delay_cycles(800 * 8);                                  // at least 750 ms for the default 12-bit resolution
        i = i + 1;
    }
    ds18b20_reset();
    ds18b20_write_byte(DS18B20_SKIP_ROM);           // skip ROM command
    ds18b20_write_byte(DS18B20_READ_SCRATCHPAD);    // read scratchpad command
    temp = ds18b20_read_temp_registers();

    return(temp / 16.0);
}

//**********************************************************************************************************************************************************

//**********************************************************************************************************************************************************

