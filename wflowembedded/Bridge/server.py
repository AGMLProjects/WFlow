import requests, websockets, asyncio, json
import data, event, diagnostic
from parameters import Parameters, AuthLevel, AttributePrototype, AttributeType
from constants import DeviceLoginRequest, NotifyActiveSensorRequest, SensorParameters, ServerParameters, SendSensorDataRequest, ServerAPI, ActuatorType, ShowerActuatorParameters
from constants import HeaterActuatorParameters, ActuatorEvents

SERVER_DEFAULT_PARAM = {
    	ServerParameters.ADDRESS: "https://wflow.online",
        ServerParameters.DEVICE_ID: 123456789,
        ServerParameters.SECRET: "5C3D6637D62DA6B9183487CE123DC6A622570ACFF9A07EE909525C3FC104F139",
        ServerParameters.WEBSOCKET_ADDRESS: "wss://wflow.online"
}

SERVER_DEFAULT_ATTR = {
    ServerParameters.ADDRESS: {AttributePrototype.TYPE: AttributeType.TEXT, AttributePrototype.WRITABLE : False, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
	ServerParameters.SECRET: {AttributePrototype.TYPE: AttributeType.PASSWORD, AttributePrototype.WRITABLE : False, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
	ServerParameters.DEVICE_ID: {AttributePrototype.TYPE: AttributeType.NUM, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.MIN: 1, AttributePrototype.MAX: 999999999, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
    ServerParameters.WEBSOCKET_ADDRESS: {AttributePrototype.TYPE: AttributeType.TEXT, AttributePrototype.WRITABLE : False, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN}
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

        self._status = True

        self._logger = logger
        self._data = dataInterface
        self._event = eventInterface

        self._actuators_socket = Parameters.getParam(key = ServerParameters.WEBSOCKET_ADDRESS)

        self._logger.record(msg = "Server module initialized", logLevel = diagnostic.INFO, module = self._MODULE, code = 0)
    
    def closeWebsocket(self) -> None:
        self._status = False

    def authenticate(self) -> bool:

        try:
            body = {
                DeviceLoginRequest.DEVICE_ID: self._device_id,
                DeviceLoginRequest.PASSWORD: self._secret
            }

            result = requests.post(self._address + ServerAPI.DEVICE_AUTH, json = body)

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

            result = requests.post(self._address + ServerAPI.SENSOR_REGISTER, json = body, headers = {"Authorization": "Token " + self._token})

            if result.status_code == 201:
                return True
            else:
                self._logger.record(msg = "Sensor register failed with code " + str(result.status_code), logLevel = diagnostic.WARNING, module = self._MODULE, code = 3)
        except Exception as e:
            self._logger.record(msg = "Error while notifying sensors", logLevel = diagnostic.ERROR, module = self._MODULE, code = 2, exc = e)

        return False

    def sendSensorData(self, sensor_id: int, start_timestamp: int, end_timestamp: int, payload: dict) -> bool:
        if type(sensor_id) != int or type(start_timestamp) != str or type(end_timestamp) != str or type(payload) != dict:
            raise TypeError("Error: Invalid type of arguments")
        
        # Prepare the payload
        body = {
            SendSensorDataRequest.SENSOR_ID: sensor_id,
            SendSensorDataRequest.START_TIMESTAMP: start_timestamp,
            SendSensorDataRequest.END_TIMESTAMP: end_timestamp,
            SendSensorDataRequest.PAYLOAD: payload
        }
        
        header = {"Authorization": "Token " + self._token}

        # Send the request
        try:
            resp = requests.post(self._address + ServerAPI.SEND_SENSOR_DATA, json = body, headers = header)
        except Exception as e:
            self._logger.record(msg = "Error while sending sensor data", logLevel = diagnostic.ERROR, module = self._MODULE, code = 4, exc = e)
            return False
        
        if resp.status_code != 201:
            self._logger.record(msg = f"Server replied with {resp.status_code} to our SEND_SENSOR_DATA call", logLevel = diagnostic.WARNING, module = self._MODULE, code = 5)
            return False
    
        return True

    async def getActuatorsCommands(self) -> None:
        async with websockets.connect(self._actuators_socket, extra_headers = [("Authorization", "Token " + self._token)]) as websocket:
            self._logger.record(msg = "Connected to websocket", logLevel = diagnostic.INFO, module = self._MODULE, code = 6)

            while self._status == True:
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout = 1)
                except asyncio.TimeoutError:
                    message = None
                except Exception as e:
                    self._logger.record(msg = "Error while receiving websocket message", logLevel = diagnostic.ERROR, module = self._MODULE, code = 7, exc = e)
                    continue

                if message is not None:
                    message = json.loads(message)

                    if "type" not in message:
                        self._logger.record(msg = "Invalid message format", logLevel = diagnostic.WARNING, module = self._MODULE, code = 8)
                        continue

                    if message["type"] == ActuatorType.SHOWER_ACTUATOR:
                        id = int(message[ShowerActuatorParameters.ID])
                        temperature = float(message[ShowerActuatorParameters.TEMPERATURE])

                        self._data.pushQueue(
                            name = ActuatorEvents.COMMAND_FOR_ACTUATOR, 
                            newItem = {
                                ShowerActuatorParameters.ID: id, 
                                ShowerActuatorParameters.TEMPERATURE: temperature,
                                "type": ActuatorType.SHOWER_ACTUATOR
                            }
                        )
                    elif message["type"] == ActuatorType.HEATER_ACTUATOR:
                        id = int(message[HeaterActuatorParameters.ID])
                        status = bool(message[HeaterActuatorParameters.STATUS])
                        temperature_list = message[HeaterActuatorParameters.TEMPERATURE]
                        start_time_list = message[HeaterActuatorParameters.TIME_START]
                        end_time_list = message[HeaterActuatorParameters.TIME_END]

                        if len(temperature_list) != len(start_time_list) or len(temperature_list) != len(end_time_list):
                            self._logger.record(msg = "Invalid message format", logLevel = diagnostic.WARNING, module = self._MODULE, code = 8)
                            continue

                        self._data.pushQueue(
                            name = ActuatorEvents.COMMAND_FOR_ACTUATOR,
                            newItem = {
                                HeaterActuatorParameters.ID: id, 
                                HeaterActuatorParameters.STATUS: status, 
                                HeaterActuatorParameters.TEMPERATURE: temperature_list, 
                                HeaterActuatorParameters.TIME_START: start_time_list, 
                                HeaterActuatorParameters.TIME_END: end_time_list,
                                "type": ActuatorType.HEATER_ACTUATOR
                            }
                        )
                    else:
                        self._logger.record(msg = "Invalid actuator type in message from Server", logLevel = diagnostic.WARNING, module = self._MODULE, code = 8)
                        continue

                    self._event.set(ActuatorEvents.COMMAND_FOR_ACTUATOR)

                #TODO: Se il messaggio è vuoto, vuol dire che dobbiamo controllare se ci sono messaggi che dobbiamo mandare al server (evento + data interface)
                # Se ci sono dei messaggi, si prendono uno per volta e si mandano, aspettando la risposta di OK