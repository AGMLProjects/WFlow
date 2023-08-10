import sys, time, json
import data, event, diagnostic, server, deviceManager
from constants import Resources, MainParameters, SensorEvents, NotifyActiveSensorRequest
from parameters import Parameters, AuthLevel, AttributePrototype, AttributeType

_MODULE = "MAIN"
defaultMainParam = {
	MainParameters.TIMEOUT_TIMER_TO_AUTH_ATTEMPT: 1 * 60,
	MainParameters.LOG_LEVEL: diagnostic.WARNING,
}

defaultMainAttr = {
	MainParameters.TIMEOUT_TIMER_TO_AUTH_ATTEMPT: {AttributePrototype.TYPE: AttributeType.NUM, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.MIN: 1, AttributePrototype.MAX: 604800, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
	MainParameters.LOG_LEVEL: {AttributePrototype.TYPE: AttributeType.NUM, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.MIN: 1, AttributePrototype.MAX: 100, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
}

def init_system_object() -> tuple:
	'''
	Create the system objects.
	'''

	try:
		if Parameters.init(paramFile = Resources.PARAMETERS_FILE) == False:
			raise Exception("Error: Parameters file not found!")
		Parameters.loadParam(defaultParam = defaultMainParam, defaultAttr = defaultMainAttr)

		log_level = Parameters.getParam(key= MainParameters.LOG_LEVEL)
		if log_level not in [diagnostic.INFO, diagnostic.DEBUG, diagnostic.WARNING, diagnostic.ERROR, diagnostic.CRITICAL]:
			logger = diagnostic.Diagnostic(path = Resources.LOGGER_FILE, logLevel = diagnostic.INFO)
			logger.record(msg=f"log_level parameter has an invalid value. Value: {log_level}", logLevel= diagnostic.ERROR, module=_MODULE, code=1)
		else:
			logger = diagnostic.Diagnostic(path = Resources.LOGGER_FILE, logLevel = log_level)


		logger = diagnostic.Diagnostic()
		eventHandler = event.Event()
		dataHandler = data.Data()
	except Exception as e:
		print("Error: {}".format(e))
		exit(1)

	return eventHandler, dataHandler, logger

if __name__ == "__main__":

	eventInterface, dataInterface, logger = init_system_object()
	serverHandler = server.ServerConnector(dataInterface = dataInterface, eventInterface = eventInterface, logger = logger)
	controlSignals = deviceManager.ControlSignals(dataInterface = dataInterface, eventInterface = eventInterface, logger = logger)
	serialInterface = deviceManager.SerialInterface(dataInterface = dataInterface, eventInterface = eventInterface, logger = logger)

	sensor_list, actuator_list = dict(), dict()
	
	# Try to authenticate, keep in the loop as long as it's not possible to obtain a valid token
	try:
		authenticated = False

		while authenticated is False:
			authenticated = serverHandler.authenticate()

			if authenticated is False:
				time.sleep(1 * 60)
	except Exception as e:
		logger.record(msg = "Error occurred while trying to authenticate, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exception = e)
		sys.exit(1)

	# Load the devices' configuration from file
	try:
		with open(Resources.DEVICE_FILE, "r") as f:
			devices_list = json.load(f)
	except Exception as e:
		logger.record(msg = "Error occurred while trying to load devices' configuration, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exception = e)
		sys.exit(1)

	# Register the sensors to the ControlSingals handler
	for sensor in devices_list["sensors"]:
		try:
			controlSignals.registerSensor(sensor = int(sensor["GPIO"]))
			
			if serialInterface.addDevice(id = int(sensor["id"]), port = sensor["port"]) == True:
				converted_uid = f"{sensor['id']:010}"
				serialInterface.send(id = int(sensor["id"]), msg = f"SA{converted_uid}")
				resp = serialInterface.receive(id = int(sensor["id"]), timeout = 5)

				if "OK" in resp:
					sensor_list[sensor["id"]] = sensor["type"]
				else:
					logger.record(msg = f"Sensor {sensor['id']} didn't respond OK the SA request", logLevel = diagnostic.ERROR, module = _MODULE, code = 1)
		except Exception as e:
			logger.record(msg = f"Error occurred while trying to register sensor {sensor['id']} ", logLevel = diagnostic.ERROR, module = _MODULE, code = 1, exception = e)
			continue

	for actuator in devices_list["actuators"]:
		try:
			if serialInterface.addDevice(id = int(actuator["id"]), port = actuator["port"]) == True:
				converted_uid = f"{sensor['id']:010}"
				serialInterface.send(id = int(sensor["id"]), msg = f"SA{converted_uid}")
				resp = serialInterface.receive(id = int(sensor["id"]), timeout = 5)

				if "OK" in resp:
					actuator_list[actuator["id"]] = actuator["type"]
				else:
					logger.record(msg = f"Actuator {actuator['id']} didn't respond OK the SA request", logLevel = diagnostic.ERROR, module = _MODULE, code = 1)
		except Exception as e:
			logger.record(msg = f"Error occurred while trying to register actuator {actuator['id']} ", logLevel = diagnostic.ERROR, module = _MODULE, code = 1, exception = e)
			continue

	# Notify the sensor list to the server
	try:

		# Prepare the list as the server want it to be
		formatted_list = []
		for sensor in sensor_list:
			formatted_list.append({NotifyActiveSensorRequest.SENSOR_ID: sensor, NotifyActiveSensorRequest.SENSOR_TYPE: sensor_list[sensor]})

		for actuator in actuator_list:
			formatted_list.append({NotifyActiveSensorRequest.SENSOR_ID: actuator, NotifyActiveSensorRequest.SENSOR_TYPE: actuator_list[actuator]})

		if serverHandler.notifySensors(sensors = formatted_list) is False:
			logger.record(msg = "Server refused our sensor list, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1)
			sys.exit(1)
	except Exception as e:
		logger.record(msg = "Error occurred while trying to notify the sensor list to the server, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exception = e)
		sys.exit(1)

	# TODO: Far partire il loop che riceve i comandi dal server e li inoltra agli attuatori

	# Main messaging loop
	while True:

		# Wait untill a sensor needs to talk with us
		try:
			eventInterface.clear(name = SensorEvents.SENSOR_REQUEST_TO_TALK)
			eventInterface.pend(name = SensorEvents.SENSOR_REQUEST_TO_TALK, timeout = None)
		except Exception as e:
			logger.record(msg = "The SENSOR_REQUEST_TO_TALK does not exists", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exception = e)
			sys.exit(1)

		# Process the request queue, one by one
		while dataInterface.isQueueEmpty(name = SensorEvents.SENSOR_REQUEST_TO_TALK) == False:

			# Get the sensor ID that requested to talk
			sensor_id = dataInterface.popQueue(name = SensorEvents.SENSOR_REQUEST_TO_TALK)

			# Request to the sensor to provide the data
			serialInterface.send(id = sensor_id, msg = "SD")
			resp = serialInterface.receive(id = sensor_id, timeout = 5)

			#TODO: Parse the response
			#TODO: Send to the server the packet

		