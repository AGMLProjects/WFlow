#include <string.h>
#include "driverlib.h"

#include "USB_config/descriptors.h"
#include "USB_API/USB_Common/device.h"
#include "USB_API/USB_Common/usb.h"
#include "USB_API/USB_CDC_API/UsbCdc.h"
#include "USB_app/usbConstructs.h"

#include "com.h"
#include "hal.h"

#include "list.h"
#include "ds18b20.h"

#define TARGET_TEMPERATURE_TOLLERANCE 2.0

// Global flags set by events
volatile uint8_t bCDCDataReceived_event = FALSE;   // Flag set by event handler to
                                                   // indicate data has been
                                                   // received into USB buffer

#define BUFFER_SIZE 256
uint8_t dataBuffer[BUFFER_SIZE] = "";
char nl[2] = "\n";
uint16_t count;                    
Node *input_list = NULL;

bool sleeping = false;                              // Flag to handle the sleeping state. If waiting USB this flag is true, otherwise is false
uint32_t timestamp = 0;

// Initialize the sensor input object
#ifdef FLO
SensorInput sensor_input = {
    .hall_ticks = 0,
    .hall_ticks_old = 0,
    .ready = true,
    .seconds = 0,
    .temperature = 0,
    .start = 0,
    .end = 0
};

ActuatorState actuator_state = {
    .active = false
};
#elif defined(LEV)
SensorInput sensor_input = {
    .timestamp = 0,
    .ready = true
};
#elif defined(HEA)
SensorInput sensor_input = {
    .liters = 0.0,
    .gas_volume = 0.0,
    .temperature = 0.0,
    .start = 0,
    .end = 0,
    .ready = false
};

ActuatorState actuator_state = {
    .target_temperature = 0.0,
    .warming_up = false
};

HeaterSequence heater_sequence = {
    .complete = true,
};
#endif

void main (void)
{
    WDT_A_hold(WDT_A_BASE); // Stop watchdog timer

    ds18b20_init_port();

    // Minimum Vcore setting required for the USB API is PMM_CORE_LEVEL_2 .
    PMM_setVCore(PMM_CORE_LEVEL_2);

    USBHAL_initPorts();           // Config GPIOS for low-power (output low)
    USBHAL_initClocks(8000000);   // Config clocks. MCLK=SMCLK=FLL=8MHz; ACLK=REFO=32kHz
    USB_setup(TRUE, TRUE); // Init USB & events; if a host is present, connect

#ifdef FLO
    // Configure the P1.3 as input for the water flow sensor
    P1DIR &= ~BIT3;     // P1.3 as input
    P1REN |= BIT3;      // Enable pull-up resistor
    P1IES |= BIT3;      // Falling edge trigger
    P1IFG &= ~BIT3;     // Clear the interrupt flag
    P1IE |= BIT3;       // Enable the interrupt

    // Configure the P1.4 as output. Will be used for 1-Wire communication with temperature sensor
    P1DIR |= BIT4;
    P1OUT |= BIT4;

    // Configure RED LED P1.0 to mimic the hot water output
    P1DIR |= BIT0;
    P1OUT &= ~BIT0;

    // Configure GREEN LED P4.7 to mimic cold water output
    P4DIR |= BIT7;
    P4OUT &= ~BIT7;

    // Configure P6.0, P6.1, P6.2, P6.3 as output to define the level of hot water
    P6DIR |= BIT0 | BIT1 | BIT2 | BIT3;
    P6OUT &= ~(BIT0 | BIT1 | BIT2 | BIT3);

    // Configure P3.0, P3.1, P3.2, P3.3 as output to define the level of cold water
    P3DIR |= BIT0 | BIT1 | BIT2 | BIT3;
    P3OUT &= ~(BIT0 | BIT1 | BIT2 | BIT3);

#elif defined(LEV)
    // Configure the P1.3 as input for the sensor
    P1DIR &= ~BIT3;     // P1.3 as input
    P1REN |= BIT3;      // Enable pull-up resistor
    P1IES |= BIT3;      // Falling edge trigger
    P1IFG &= ~BIT3;     // Clear the interrupt flag
    P1IE |= BIT3;       // Enable the interrupt
#elif defined(HEA)
    // Configure RED LED P1.0 to mimic 'water is warming up'
    P1DIR |= BIT0;
    P1OUT &= ~BIT0;

    // Configure GREEN LED P4.7 to mimic 'heater is on'
    P4DIR |= BIT7;
    P4OUT &= ~BIT7;

    // Configure P6.0, P6.1, P6.2 as output to define the water heating level (from 0% to 100%)
    P6DIR |= BIT0 | BIT1 | BIT2;
    P6OUT &= ~(BIT0 | BIT1 | BIT2);
#endif

    // Configure P1.5 as output for signaling USB messages
    P1DIR |= BIT5;
    P1OUT |= BIT5;

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
                    __disable_interrupt();
                    timestamp = intDecode(&dataBuffer[12], 10);
                    __enable_interrupt();
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

        // Check if there are new sensor data
        if(available_data(input_list) == true)
        {
            // There are data so we must raise the alert flag
            P1OUT &= ~BIT5;
        }
        else
        {
            // There is no message waiting to be sent, reset the flag
            P1OUT |= BIT5;
        }

        // Check if there is an USB incoming message
        __disable_interrupt();
        if (!USBCDC_getBytesInUSBBuffer(CDC0_INTFNUM))
        {
            sleeping = true;
            __bis_SR_register(LPM0_bits + GIE);
        }
        __enable_interrupt();
        sleeping = false;

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
                __disable_interrupt();
                timestamp = intDecode(&dataBuffer[12], 10);
                __enable_interrupt();
                create_ack_message(dataBuffer, device_address, &count);
            }
            else if (message_code == OK)
            {
                create_ack_message(dataBuffer, device_address, &count);
            }
            else if (message_code == SD)
            {
                // Check if there are data to be sent
                if(available_data(input_list) == true)
                {
                    SensorInput data = popNode(&input_list);

#ifdef FLO
                    create_sd_message(dataBuffer, convert_hall_to_liters(data.hall_ticks, data.seconds), data.temperature, data.start, data.end, &count);
#elif defined(LEV)
                    create_sd_message(dataBuffer, data.timestamp, &count);
#elif defined(HEA)
                    create_sd_message(dataBuffer, data.liters, data.temperature, data.gas_volume, data.start, data.end, &count);
#else
                create_error_message(dataBuffer, device_address, &count);
#endif
                }
                else
                {
                    // There are no data, just send an ACK
                    create_ack_message(dataBuffer, device_address, &count);
                }
            }
            else if (message_code == EX)
            {
#ifdef FLO
                parse_ex_command(dataBuffer, &actuator_state);
                create_ack_message(dataBuffer, device_address, &count);
#elif defined(HEA)
                parse_ex_command(dataBuffer, &heater_sequence);
#else
                create_error_message(dataBuffer, device_address, &count);
#endif
            }
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
#ifdef FLO
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
            sensor_input.start = timestamp;
        }

        // Increase hall ticks as there is another tick
        sensor_input.hall_ticks = sensor_input.hall_ticks + 1;

        P1IFG &= ~BIT3;     // Clear the interrupt
    }
#elif defined(LEV)
    if(P1IFG & BIT3)
    {
        // Save the timestamp of this event
        sensor_input.timestamp = timestamp;

        // Store this item as the input is ready
        insertNode(&input_list, sensor_input);

        P1IFG &= ~BIT3;     // Clear the interrupt
    }
#endif
}

#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer_A_ISR(void)
{
    timestamp = timestamp + 1;

#ifdef FLO
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

        // Read the temperature value
        sensor_input.temperature = ds18b20_get_temp();

        // Set the end timestamp
        sensor_input.end = timestamp;

        // Store this item as the input is ready
        insertNode(&input_list, sensor_input);
    }

    // If the actuator is active, behave accordingly
    if (actuator_state.active == true)
    {
        // Get the current temperature
        actuator_state.current_temperature = ds18b20_get_temp();

        // The water is too hot, we need to cool down
        if (actuator_state.current_temperature - actuator_state.target_temperature > 0.5)
        {
            // If we still have space to cool down
            if (actuator_state.cold_level < 10)
            {
                actuator_state.cold_level = actuator_state.cold_level + 1;
                actuator_state.hot_level = actuator_state.hot_level - 1;
            }
        }
        else if (actuator_state.target_temperature - actuator_state.current_temperature > 0.5)
        {
            // In this case the water is too cold, if there is space warm it up
            if (actuator_state.hot_level < 10)
            {
                actuator_state.cold_level = actuator_state.cold_level - 1;
                actuator_state.hot_level = actuator_state.hot_level + 1;
            }
        }

        // Apply the change
        set_water_output(actuator_state.hot_level, actuator_state.cold_level);
    }
#elif defined(HEA)

    // If the sequence is not complete, do nothing
    if(heater_sequence.complete == true)
    {
        // Check if there is an active event
        bool active = false;

        // Find the sequence element
        for(int i = 0; i < 144; i = i + 1)
        {
            // This element is the current one
            if (heater_sequence.timeslots[i].start >= timestamp && heater_sequence.timeslots[i].end <= timestamp)
            {
                active = true;

                // If the heater off, just turn it on with and initialize the sensor input structure
                if(sensor_input.ready == true)
                {
                    sensor_input.ready = false;             // Initialize a new sensor packet
                    sensor_input.start = timestamp;

                    sensor_input.temperature = 20.0;        // Mock room temperature to start with, it should be the water temperature before heating up (room temperature)
                    sensor_input.gas_volume = 0.0;          // Start with no gas used

                    // Initialize the actuator
                    actuator_state.target_temperature = heater_sequence.timeslots[i].temperature;

                    // Check if there is the need to heat up the water
                    if (actuator_state.target_temperature - sensor_input.temperature >= TARGET_TEMPERATURE_TOLLERANCE)
                    {
                        actuator_state.warming_up = true;
                    }

                    // Turn on the POWER led anyway
                    P4OUT |= BIT4;

                    // If the warming up process is on, turn on the HEATING led and the level leds
                    if(actuator_state.warming_up == false)
                    {
                        P1OUT &= ~BIT0;
                        P6OUT &= ~(BIT0 | BIT1 | BIT2);
                    }
                    else
                    {
                        P1OUT |= BIT0;

                        if((sensor_input.temperature - 20.0) <= ((actuator_state.target_temperature - 20.0) / 2))
                        {
                            // Water heating below 50% of the range
                            P6OUT |= BIT0;
                            P6OUT &= ~(BIT1 | BIT2);
                            actuator_state.warming_up = true;
                        }
                        else if (((sensor_input.temperature - 20.0) >= (actuator_state.target_temperature - 20.0) / 2) || (actuator_state.target_temperature - sensor_input.temperature) >= TARGET_TEMPERATURE_TOLLERANCE)
                        {
                            // Water heating over 50% of the range but not at the target yet
                            P6OUT |= (BIT0 | BIT1);
                            P6OUT &= ~BIT2;
                            actuator_state.warming_up = true;
                        }
                        else
                        {
                            // Water temperature reached the target, just maintain it and turn off the heating led
                            P6OUT |= (BIT0 | BIT1 | BIT2);
                            P1OUT &= ~BIT0;
                            actuator_state.warming_up = false;
                        }
                    }
                }
                else
                {
                    // The heater was already on in this specific interval, add up the consumes
                    if((sensor_input.temperature - 20.0) <= ((actuator_state.target_temperature - 20.0) / 2))
                    {
                        // Water heating below 50% of the range
                        P6OUT |= BIT0;
                        P6OUT &= ~(BIT1 | BIT2);
                        actuator_state.warming_up = true;
                    }
                    else if (((sensor_input.temperature - 20.0) >= (actuator_state.target_temperature - 20.0) / 2) || (actuator_state.target_temperature - sensor_input.temperature) >= TARGET_TEMPERATURE_TOLLERANCE)
                    {
                        // Water heating over 50% of the range but not at the target yet
                        P6OUT |= (BIT0 | BIT1);
                        P6OUT &= ~BIT2;
                        actuator_state.warming_up = true;
                    }
                    else
                    {
                        // Water temperature reached the target, just maintain it and turn off the heating led
                        P6OUT |= (BIT0 | BIT1 | BIT2);
                        P1OUT &= ~BIT0;
                        actuator_state.warming_up = false;
                    }

                    // Depending on the actuator state, update the sensor input values (mock data)
                    if(actuator_state.warming_up == true)
                    {
                        // Heater warming up, use a lot of gas but no water
                        sensor_input.gas_volume = sensor_input.gas_volume + 0.03;

                        // Increase the water temperature of 1° each sensor to mimic the heating up
                        sensor_input.temperature = sensor_input.temperature + 1.0;
                    }
                    else
                    {
                        // The water has been heated up completely. Use less gas but consumes water, temperature remains stable
                        sensor_input.gas_volume = sensor_input.gas_volume + 0.01;
                        sensor_input.liters = sensor_input.liters + (10.0 * (((timestamp % 100) / 10) + (timestamp % 10)));
                    }
                }
                break;
            }
        }

        // If the heater is not active, turn it off if it was on
        if (active == false)
        {
            // Turn off all the leds
            P1OUT &= ~BIT0;
            P4OUT &= ~BIT4;
            P6OUT &= ~(BIT0 | BIT1 | BIT2);

            // Set the end timestamp (the sensor input ends here)
            sensor_input.end = timestamp;

            // Set the input packet as ready
            sensor_input.ready = true;

            // Insert the packet in the queue to be sent to bridge
            insertNode(&input_list, sensor_input);
        }
    }
#endif

    // If the system is sleeping wake it up to check for other events
    if(sleeping == true)
    {
        __bic_SR_register_on_exit(LPM0_bits);
    }
}
