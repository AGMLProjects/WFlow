import requests, json, datetime
import data, event, parameters, diagnostic
from constants import DeviceLoginRequest, NotifyActiveSensorRequest, SensorParameters

class ServerConnector():
    _MODULE = "SRV"

    def __init__(self, address: str, device_id: str, secret: str, logger: diagnostic.Diagnostic) -> object:
        if type(address) is not str or type(device_id) is not str or type(secret) is not str or isinstance(logger, diagnostic.Diagnostic) is False:
            raise TypeError("Error: Invalid type of arguments")
        
        self._address = address
        self._device_id = device_id
        self._secret = secret
        self._token = None

        self._logger = logger
    
    def authenticate(self) -> bool:

        try:
            body = {
                DeviceLoginRequest.DEVICE_ID: self._device_id,
                DeviceLoginRequest.PASSWORD: self._secret
            }

            result = requests.post(self._address + "/devices/login", json = body)

            if result.status_code != 200:
                self._token = None
                return False
            else:
                self._token = str(result.json()["key"])
                return True
        except Exception as e:
            self._logger.record(msg = "Error while authenticating", logLevel = diagnostic.ERROR, module = self._MODULE, code = 1)
            return False

    def notifySensors(self, sensors: list) -> bool:
        if type(sensors) is not list:
            raise TypeError("Error: Invalid type of arguments")
        
        # Check if the sensors are valid
        for sensor in sensors:
            if type(sensor) is not dict:
                raise TypeError("Error: Invalid sensor format")
            
            if SensorParameters.SENSOR_TYPE not in sensor or SensorParameters.SENSOR_ID not in sensor:
                raise TypeError("Error: Invalid sensor format")

        try:
            body = {
                NotifyActiveSensorRequest.SENSOR_LIST: sensors
            }

            result = requests.post(self._address + "/devices/sensors/register", json = body, headers = {"Authorization": "Token " + self._token})

            if result.status_code == 200:
                return True
            else:
                self._logger.record(msg = "Sensor register failed with code " + str(result.status_code), logLevel = diagnostic.WARNING, module = self._MODULE, code = 3)
        except Exception as e:
            self._logger.record(msg = "Error while notifying sensors", logLevel = diagnostic.ERROR, module = self._MODULE, code = 2)

        return False