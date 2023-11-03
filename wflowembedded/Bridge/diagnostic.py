import os, threading, logging, copy, sys, datetime


# Log levels constants
DEBUG = logging.DEBUG
INFO = logging.INFO
WARNING = logging.WARNING
ERROR = logging.ERROR
CRITICAL = logging.CRITICAL

class Diagnostic():
	'''Provides a common interface to record important events'''

	_VALID_LOG_LEVELS = [DEBUG, INFO, WARNING, ERROR, CRITICAL]

	def __init__(self, path: str, logLevel: int) -> object:

		if type(path) != str or type(logLevel) != int:
			raise TypeError

		if logLevel not in self._VALID_LOG_LEVELS:
			raise ValueError

		self._path = path
		self._logLevel = logLevel
		self._lock = threading.Lock()                                                                                         	# Sync operations on logging module
		self._fileHandler = logging.FileHandler(filename=path, mode='a', encoding='utf-8')                                     	# Creates the log file's instance
		self._fileHandler.setFormatter(logging.Formatter("%(levelname)s:%(asctime)s,%(message)s", datefmt="%Y/%m/%d %H:%M:%S")) # Sets the format of the log message
		logging.getLogger().setLevel(INFO)
		logging.getLogger().addHandler(self._fileHandler)                                                                       # Adds the log file's handler between those handled by logging module
		self.record(msg = "Starting program", logLevel = INFO, module = "MRC", code = 0)
		logging.getLogger().setLevel(logLevel)                                                                                  # Sets the minimum log level to save the message on the file
		

	@property
	def validLogLevels(self) -> list:
		'''Get a list of supported log levels'''
		return copy.deepcopy(self._VALID_LOG_LEVELS)

	@property
	def activedLogLevel(self) -> list:
		'''Get the log level in use'''
		return self._logLevel
	
	# Change file location
	def updateParam(self, path: str, logLevel: int) -> bool:
		'''
		Change the path of logger file. 
		'''
		
		if type(path) != str or type(logLevel) != int:
			raise TypeError

		if logLevel not in self._VALID_LOG_LEVELS:
			raise ValueError

		with self._lock:
			try:
				logging.getLogger().removeHandler(self._fileHandler)
				self._fileHandler = logging.FileHandler(filename = path, mode = 'a', encoding = 'utf-8')
				self._fileHandler.setFormatter(logging.Formatter("%(levelname)s:%(asctime)s,%(message)s", datefmt="%Y/%m/%d %H:%M:%S")) # Sets the format of the log message
				logging.getLogger().addHandler(self._fileHandler)      
				self._path = path
			except Exception as e:
				return False

			try:
				logging.getLogger().setLevel(logLevel)
				self._logLevel = logLevel
			except Exception as e:
				return False
		
		return True

	# Truncate files to reduce their demension
	@staticmethod
	def truncate(filename: str) -> None:
		'''
		Truncate the file to fix its dimension to 50 rows (most recent rows are preserved)
		'''
		if type(filename) != str:
			raise TypeError
		if os.path.isfile(filename) == False:
			raise ValueError

		os.system('echo "$(tail -n 300 ' + filename + ' )" > ' + filename)
	
	# Record an event into logger file
	def record(self, msg: str, logLevel: int, module: str, code: int, exc: Exception = None) -> None:
		'''
		Record a message in the logger file. If the logger file is too big, it is truncated.
		'''

		if type(msg) != str or type(logLevel) != int or type(module) != str or type(code) != int:
			raise TypeError("Diagnostic record method")

		if exc != None and isinstance(exc, Exception) == False:
			raise ValueError("Diagnostic record method")

		if logLevel not in self._VALID_LOG_LEVELS:
			raise ValueError("Diagnostic record method")

		with self._lock:

			# Check the logger file's size
			if (os.path.getsize(self._path) >= 3000000):
				self.truncate(filename = self._path)

			if exc != None:
				logging.log(logLevel, " [{module}-{code}] {msg}. {type}:{exception}".format(module = module, code = code, msg = msg, type= type(exc), exception = str(exc)))
			else:
				logging.log(logLevel, " [{module}-{code}] {msg}".format(module = module, code = code, msg = msg))

	def clear(self) -> None:
		'''
		Clear log file.
		'''

		with self._lock:
			os.system('echo "$(tail -n 10 ' + self._path + ' )" > ' + self._path)

	def readLog(self) -> str:
		'''
		Read log file.
		'''

		contents = ""
		with self._lock:
			with open(self._path, 'r') as log_file:
				contents = log_file.read()
		return contents

	# Close all handler    
	def shutdown(self):
		'''
		Close all handlers handle from logging module.
		'''
		with self._lock:
			logging.shutdown()

	def sysReboot(self) -> None:
		'''Invoke a system reboot'''

		with self._lock:
			with open(self._path, 'r') as log:                                      # Open the logger file in reading mode
				logEvents = log.read()                                              # Read the contenent 
				reboot = True                                                       # Assume that we can reboot

				if "Reboot because of exception" in logEvents:              # If a reboot is already happened
					for line in logEvents.split('\n'):                              # For each logged event (file lines)
						if "Reboot because of exception" in line:
							line = line.split(',')                                  # Parse the line to see if it matches the logger format
							line = str(line[0])[9:]                                 # Get the datetime component of this string
							date = datetime.datetime.strptime(line, "%Y/%m/%d %H:%M:%S")     # Create a datetime object
							now = datetime.datetime.now()                                    # Get the current datetime to compare with the log line one
							if(now - date) <= datetime.timedelta(minutes = 10):     # If the reboot happened in the last ten minutes
								reboot = False                                      # Avoid the reboot
								break

		if reboot == True:                                                      # Go ahead with the system reboot
			self.record(msg = "Reboot because of exception", logLevel = CRITICAL, module = "SYS", code = 1)
			self.shutdown()
			os.system("sudo reboot")
		else:
			self.record(msg = "Impossible to reboot, terminating the program", logLevel = CRITICAL, module = "SYS", code = 2)
			self.shutdown()
			sys.exit("Critical error, impossible to reboot")