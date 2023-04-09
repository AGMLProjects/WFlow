#ifndef UART_H_
#define UART_H_

#define BAUDRATE        9600
#define END_CHR         0x0D

typedef struct {
    uint8_t rxBuffer[256];
    uint8_t rxIndex;
    bool receiving;
    bool messageReady;
} UartState;

bool init_uart_interface();

#endif /* UART_H_ */
