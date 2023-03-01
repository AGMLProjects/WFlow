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
	BRIDGE_ID = "bridgeId"
	SECRET = "secret"
	TIMEOUT_TIMER_TO_AUTH_ATTEMPT = "timeoutTimerToAuthAttempt"
	LOG_LEVEL = "logLevel"