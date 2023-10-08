#include <string.h>
#include "driverlib.h"

#include "USB_config/descriptors.h"
#include "USB_API/USB_Common/device.h"
#include "USB_API/USB_Common/usb.h"
#include "USB_API/USB_CDC_API/UsbCdc.h"
#include "USB_app/usbConstructs.h"

#include "com.h"
#include "hal.h"

#define FLO                                 // This sensor is a FLOW SENSOR (WATER FLOW + TEMPERATURE)

// Global flags set by events
volatile uint8_t bCDCDataReceived_event = FALSE;   // Flag set by event handler to
                                                   // indicate data has been
                                                   // received into USB buffer

#define BUFFER_SIZE 256
uint8_t dataBuffer[BUFFER_SIZE] = "";
char nl[2] = "\n";
uint16_t count;                    

// Define the structure used to handle the sensor input and state
#ifdef FLO
typedef struct {
    uint32_t hall_ticks;
    float temperature;
    uint32_t hall_ticks_old;
    uint32_t seconds;
    bool ready;
} SensorInput;
#endif

// Initialize the sensor input object
SensorInput sensor_input = {
    .hall_ticks = 0,
    .hall_ticks_old = 0,
    .ready = false,
    .seconds = 0,
    .temperature = 0
};

// This object is used to avoid race conditions
SensorInput shadow_sensor_input = {.ready = false};

void main (void)
{
    WDT_A_hold(WDT_A_BASE); // Stop watchdog timer

    // Minimum Vcore setting required for the USB API is PMM_CORE_LEVEL_2 .
    PMM_setVCore(PMM_CORE_LEVEL_2);

    USBHAL_initPorts();           // Config GPIOS for low-power (output low)
    USBHAL_initClocks(8000000);   // Config clocks. MCLK=SMCLK=FLL=8MHz; ACLK=REFO=32kHz
    USB_setup(TRUE, TRUE); // Init USB & events; if a host is present, connect

    // Configure the P1.3 as input for the sensor
    P1DIR &= ~BIT3;     // P1.3 as input
    P1REN |= BIT3;      // Enable pull-up resistor
    P1IES |= BIT3;      // Falling edge trigger
    P1IFG &= ~BIT3;     // Clear the interrupt flag
    P1IE |= BIT3;       // Enable the interrupt

    // Set up Timer A to trigger an interrupt every second
    TA0CCTL0 = CCIE;           // Enable Timer A interrupt
    TA0CCR0 = 32768 - 1;        // Set the Timer A compare register for 1-second interval
    TA0CTL = TASSEL_1 + MC_1;   // Timer A source: ACLK (32768 Hz), Mode: Up

    uint16_t message_code;
    uint32_t device_address = 0;

    __enable_interrupt();  // Enable interrupts globally

    while (1)
    {
        uint16_t count;
        
        // If this device do not have an address, wait until the bridge send it
        if (device_address == 0)
        {
            // Critical section, wait for messages
            __disable_interrupt();
            if (!USBCDC_getBytesInUSBBuffer(CDC0_INTFNUM))
            {
                __bis_SR_register(LPM0_bits + GIE);
            }
            __enable_interrupt();

            // fetch the received data
            if (bCDCDataReceived_event){

                // Clear the event flag
                bCDCDataReceived_event = FALSE;

                // Data have been received, parse them
                count = USBCDC_receiveDataInBuffer((uint8_t*)dataBuffer, BUFFER_SIZE, CDC0_INTFNUM);

                // Read the message code
                message_code = (dataBuffer[0] << 8) | (dataBuffer[1] & 0xff);

                // In this phase it must be a SET ADDRESS message
                if (message_code == SA)
                {
                    device_address = intDecode(&dataBuffer[2], 10);
                    create_ack_message(dataBuffer, device_address, &count);
                }
                else
                {
                    create_error_message(dataBuffer, device_address, &count);
                }

                // Send the ACK message back to host
                USBCDC_sendDataInBackground((uint8_t*)dataBuffer, count, CDC0_INTFNUM, 1);
            }

            // Initial set address done, wait go back to normal loop
            continue;
        }

        // Check if there is an USB incoming message
        create_ack_message(dataBuffer, device_address, &count);
        USBCDC_sendDataInBackground((uint8_t*)dataBuffer, count, CDC0_INTFNUM, 1);

        // Wait for the incoming message to arrive for a max of 5 seconds
        __disable_interrupt();
        if (!USBCDC_getBytesInUSBBuffer(CDC0_INTFNUM))
        {
            __bis_SR_register(LPM0_bits + GIE);         //TODO: Sostituire con una misura del tempo max
        }
        __enable_interrupt();

        // fetch the received data
        if (bCDCDataReceived_event){

            // Clear the event flag
            bCDCDataReceived_event = FALSE;

            // Data have been received, parse them
            count = USBCDC_receiveDataInBuffer((uint8_t*)dataBuffer, BUFFER_SIZE, CDC0_INTFNUM);

            // Read the message code
            message_code = (dataBuffer[0] << 8) | (dataBuffer[1] & 0xff);

            // In this phase it must be a SET ADDRESS message
            if (message_code == SA)
            {
                device_address = intDecode(&dataBuffer[2], 10);
                create_ack_message(dataBuffer, device_address, &count);
            } // TODO: Scrivere gli altri messaggi possibili
            else
            {
                create_error_message(dataBuffer, device_address, &count);
            }

            // Send the ACK message back to host
            USBCDC_sendDataInBackground((uint8_t*)dataBuffer, count, CDC0_INTFNUM, 1);
        }
    }
}

/*  
 * ======== UNMI_ISR ========
 */
#if defined(__TI_COMPILER_VERSION__) || (__IAR_SYSTEMS_ICC__)
#pragma vector = UNMI_VECTOR
__interrupt void UNMI_ISR (void)
#elif defined(__GNUC__) && (__MSP430__)
void __attribute__ ((interrupt(UNMI_VECTOR))) UNMI_ISR (void)
#else
#error Compiler not found!
#endif
{
    switch (__even_in_range(SYSUNIV, SYSUNIV_BUSIFG ))
    {
        case SYSUNIV_NONE:
            __no_operation();
            break;
        case SYSUNIV_NMIIFG:
            __no_operation();
            break;
        case SYSUNIV_OFIFG:
            UCS_clearFaultFlag(UCS_XT2OFFG);
            UCS_clearFaultFlag(UCS_DCOFFG);
            SFR_clearInterrupt(SFR_OSCILLATOR_FAULT_INTERRUPT);
            break;
        case SYSUNIV_ACCVIFG:
            __no_operation();
            break;
        case SYSUNIV_BUSIFG:
            // If the CPU accesses USB memory while the USB module is
            // suspended, a "bus error" can occur.  This generates an NMI.  If
            // USB is automatically disconnecting in your software, set a
            // breakpoint here and see if execution hits it.  See the
            // Programmer's Guide for more information.
            SYSBERRIV = 0; // clear bus error flag
            USB_disable(); // Disable
    }
}

#pragma vector=PORT1_VECTOR
__interrupt void Port1_ISR(void)
{
    // Sensor input interrupt
    if(P1IFG & BIT3)
    {
        // If the sensor input is new event, reset the structure
        if(sensor_input.ready == true)
        {
            sensor_input.hall_ticks = 0;
            sensor_input.hall_ticks_old = 0;
            sensor_input.seconds = 0;
            sensor_input.temperature = 0;
            sensor_input.ready = false;
        }

        // Increase hall ticks as there is another tick
        sensor_input.hall_ticks = sensor_input.hall_ticks + 1;

        // Read the temperature

        P1IFG &= ~BIT3;     // Clear the interrupt
    }
}

#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer_A_ISR(void)
{
    // In this state there is an active measurement of water flow
    if(sensor_input.hall_ticks > sensor_input.hall_ticks_old && sensor_input.ready == false)
    {
        // Update this support variable to acknowledge that we have seen this step
        sensor_input.hall_ticks_old = sensor_input.hall_ticks;

        // Increase the number of seconds passed since the start
        sensor_input.seconds = sensor_input.seconds + 1;
    }
    else if (sensor_input.ready == false && sensor_input.hall_ticks != 0)
    {
        // In this state the water flow finished and we can close the event
        sensor_input.ready = true;
        float f = convert_hall_to_liters(sensor_input.hall_ticks, sensor_input.seconds);
        shadow_sensor_input = sensor_input;
    }
}
