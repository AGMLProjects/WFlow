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

	CUSTOM_DIR = "/home/wflow/config/"
	PARAMETERS_FILE = CUSTOM_DIR + "params.json"
	LOGGER_FILE = CUSTOM_DIR + "logger.txt"
	BACKUP_FILE = CUSTOM_DIR + "logger.backup"

class MainParameters(_AbstractEnum):
	TIMEOUT_TIMER_TO_AUTH_ATTEMPT = "timeoutTimerToAuthAttempt"
	LOG_LEVEL = "logLevel"

class DeviceLoginRequest(_AbstractEnum):

	DEVICE_ID = "device_id"
	PASSWORD = "password"

class NotifyActiveSensorRequest(_AbstractEnum):

	SENSOR_LIST = "active_sensors"

class SensorParameters(_AbstractEnum):
	SENSOR_TYPE = "sensor_type"
	SENSOR_ID = "sensor_id"

class ServerParameters(_AbstractEnum):
	ADDRESS = "server_address"
	SECRET = "server_secret"
	DEVICE_ID = "server_device_id"