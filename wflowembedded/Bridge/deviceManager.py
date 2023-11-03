import serial
import data, event, diagnostic
from constants import SensorEvents, ActuatorEvents

import RPi.GPIO as GPIO

class ControlSignals():

    _MODULE = "SIG"

    def __init__(self, dataInterface: data.Data, eventInterface: event.Event, logger: diagnostic.Diagnostic) -> object:
        if isinstance(logger, diagnostic.Diagnostic) is False or isinstance(dataInterface, data.Data) is False or isinstance(eventInterface, event.Event) is False:
            raise TypeError("Error: Invalid type of arguments")
        
        self._logger = logger
        self._data = dataInterface
        self._event = eventInterface

        self._registeredSensors = set()
        self._registeredActuators = set()

        self._event.create(name = SensorEvents.SENSOR_REQUEST_TO_TALK)
        self._data.store(name = SensorEvents.SENSOR_REQUEST_TO_TALK, dataType = data.FIFO, value = [])

        self._event.create(name = ActuatorEvents.COMMAND_FOR_ACTUATOR)
        self._data.store(name = ActuatorEvents.COMMAND_FOR_ACTUATOR, dataType = data.FIFO, value = [])

        GPIO.setmode(GPIO.BCM)

        self._logger.record(msg = "ControlSignals module initialized", logLevel = diagnostic.INFO, module = self._MODULE, code = 0)

    def addSensors(self, id: int, pin: int) -> bool:
        if type(pin) != int or type(id) != int:
            raise TypeError
        
        if (id, pin) not in self._registeredSensors:
            self._registeredSensors.add((id, pin))

            GPIO.setup(pin, GPIO.IN)
            GPIO.add_event_detect(pin, GPIO.FALLING, callback = lambda pin = pin: self._sensorRequestCallback(pin), bouncetime = 200)
            return True
        
        return False

    def _sensorRequestCallback(self, pin: int) -> None:
        if type(pin) != int:
            raise TypeError
        
        for element in self._registeredSensors:
            if element[1] == pin:
                self._event.set(SensorEvents.SENSOR_REQUEST_TO_TALK)
                self._data.pushQueue(name = SensorEvents.SENSOR_REQUEST_TO_TALK, newItem = element[0])

        return None
    
class SerialInterface():

    _MODULE = "SER"

    def __init__(self, dataInterface: data.Data, eventInterface: event.Event, logger: diagnostic.Diagnostic) -> object:
        if isinstance(logger, diagnostic.Diagnostic) is False or isinstance(dataInterface, data.Data) is False or isinstance(eventInterface, event.Event) is False:
            raise TypeError("Error: Invalid type of arguments")
        
        self._logger = logger
        self._data = dataInterface
        self._event = eventInterface

        self._baudrate = 9600
        self._timeout = 1

        self._devices = dict()
        self._usedPort = dict()

    def addDevice(self, id: int, port: str) -> bool:
        if type(id) != int or type(port) != str:
            raise TypeError
        
        # Check if this device has already been registred
        if id in self._devices:
            return False
        
        # If not, register it and open the serial port
        try:
            # If this serial port has never been opened, open it and register the device
            if port not in self._usedPort:
                self._devices[id] = serial.Serial(port = port, baudrate = self._baudrate, timeout = self._timeout)
                self._usedPort[port] = id
            else:
                # If the port is already in use, just link the new device to the original handler
                self._devices[id] = self._devices[self._usedPort[port]]
            return True
        except Exception as e:
            self._logger.record(msg = "Error occurred while trying to add device to serial interface", logLevel = diagnostic.ERROR, module = self._MODULE, code = 1, exc = e)
            return False

    def send(self, id: int, message: str) -> bool:
        if type(id) != int or type(message) != str:
            raise TypeError
        
        if id not in self._devices:
            return False
        
        message = message + '\n'

        try:
            self._devices[id].write(message.encode())
            return True
        except Exception as e:
            self._logger.record(msg = "Error occurred while trying to send message to device", logLevel = diagnostic.ERROR, module = self._MODULE, code = 1, exc = e)
            return False
        
    def receive(self, id: int, timeout: int) -> str:
        if type(id) != int or type(timeout) != int:
            raise TypeError
        
        if id not in self._devices:
            return None
        
        try:
            self._devices[id].timeout = timeout
            x = self._devices[id].readline()
            return x.decode("UTF-8")
        except Exception as e:
            self._logger.record(msg = "Error occurred while trying to receive message from device", logLevel = diagnostic.ERROR, module = self._MODULE, code = 1, exc = e)
            return None