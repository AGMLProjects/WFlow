import requests, json, datetime
import data, event, diagnostic
from parameters import Parameters, AuthLevel, AttributePrototype, AttributeType
from constants import DeviceLoginRequest, NotifyActiveSensorRequest, SensorParameters, ServerParameters

SERVER_DEFAULT_PARAM = {
    	ServerParameters.ADDRESS: "https://wflow.online",
        ServerParameters.DEVICE_ID: 123456789,
        ServerParameters.SECRET: "5C3D6637D62DA6B9183487CE123DC6A622570ACFF9A07EE909525C3FC104F139"
}

SERVER_DEFAULT_ATTR = {
    ServerParameters.ADDRESS: {AttributePrototype.TYPE: AttributeType.TEXT, AttributePrototype.WRITABLE : False, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
	ServerParameters.SECRET: {AttributePrototype.TYPE: AttributeType.PASSWORD, AttributePrototype.WRITABLE : False, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
	ServerParameters.DEVICE_ID: {AttributePrototype.TYPE: AttributeType.NUM, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.MIN: 1, AttributePrototype.MAX: 999999999, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
}

class ServerConnector():
    _MODULE = "SRV"

    def __init__(self, dataInterface: data.Data, eventInterface: event.Event, logger: diagnostic.Diagnostic) -> object:
        if isinstance(logger, diagnostic.Diagnostic) is False or isinstance(dataInterface, data.Data) is False or isinstance(eventInterface, event.Event) is False:
            raise TypeError("Error: Invalid type of arguments")
        
        try:
            Parameters.loadParam(defaultParam = SERVER_DEFAULT_PARAM, defaultAttr = SERVER_DEFAULT_ATTR)
        except Exception as e:
            raise Exception("Error: Impossible to load parameters in module " + self._MODULE)

        self._address = Parameters.getParam(key = ServerParameters.ADDRESS)
        self._device_id = Parameters.getParam(key = ServerParameters.DEVICE_ID)
        self._secret = Parameters.getParam(key = ServerParameters.SECRET)
        self._token = None

        self._logger = logger
        self._data = dataInterface
        self._event = eventInterface

        self._logger.record(msg = "Server module initialized", logLevel = diagnostic.INFO, module = self._MODULE, code = 0)
    
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
            self._logger.record(msg = "Error while notifying sensors", logLevel = diagnostic.ERROR, module = self._MODULE, code = 2, exc = e)

        return False