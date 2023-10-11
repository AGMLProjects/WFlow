class _AbstractEnum():
	def __init__(self) -> None:
		raise Exception("Enum Classes can't be concrete!")

	@classmethod
	def list(cls):
		varList = [attr for attr in vars(cls) if not callable(getattr(cls, attr)) and not attr.startswith("__")]
		return [vars(cls)[elem] for elem in varList]

class Resources(_AbstractEnum):
	'''
	Defines the resources that can be used by the system.
	'''

	CUSTOM_DIR = "/home/wflow/Bridge/config/"
	PARAMETERS_FILE = CUSTOM_DIR + "params.json"
	LOGGER_FILE = CUSTOM_DIR + "logger.txt"
	BACKUP_FILE = CUSTOM_DIR + "logger.backup"
	DEVICE_FILE = CUSTOM_DIR + "devices.json"

class MainParameters(_AbstractEnum):
	TIMEOUT_TIMER_TO_AUTH_ATTEMPT = "timeoutTimerToAuthAttempt"
	LOG_LEVEL = "logLevel"

class DeviceLoginRequest(_AbstractEnum):
	DEVICE_ID = "device_id"
	PASSWORD = "password"

class ServerAPI(_AbstractEnum):
	DEVICE_AUTH = "/devices/login/"
	SENSOR_REGISTER = "/sensors/register/"
	SEND_SENSOR_DATA = "/sensors/upload/"

class NotifyActiveSensorRequest(_AbstractEnum):
	SENSOR_LIST = "active_sensors"
	SENSOR_ID = "sensor_id"
	SENSOR_TYPE = "sensor_type"

class SendSensorDataRequest(_AbstractEnum):
	SENSOR_ID = "sensor_id"
	START_TIMESTAMP = "start_timestamp"
	END_TIMESTAMP = "end_timestamp"
	PAYLOAD = "values"

class SensorParameters(_AbstractEnum):
	SENSOR_TYPE = "sensor_type"
	SENSOR_ID = "sensor_id"

class ServerParameters(_AbstractEnum):
	ADDRESS = "server_address"
	SECRET = "server_secret"
	DEVICE_ID = "server_device_id"
	WEBSOCKET_ADDRESS = "websocket_address"

class SensorEvents(_AbstractEnum):
	SENSOR_REQUEST_TO_TALK = "sensor_request_to_talk"

class ActuatorType(_AbstractEnum):
	SHOWER_ACTUATOR = "shower_actuator"
	HEATER_ACTUATOR = "heater_actuator"

class ShowerActuatorParameters(_AbstractEnum):
	ID = "id"
	TEMPERATURE = "temperature"

class HeaterActuatorParameters(_AbstractEnum):
	ID = "id"
	STATUS = "status"
	TEMPERATURE = "temperature"
	TIME_START = "time_start"
	TIME_END = "time_end"
	AUTOMATIC = "automatic"

class ActuatorEvents(_AbstractEnum):
	COMMAND_FOR_ACTUATOR = "command_for_actuator"
	