import os
os.environ['PYTHONASYNCIODEBUG'] = '1'
import pdb

import sys, time, json, asyncio, datetime
import data, event, diagnostic, server, deviceManager
from constants import Resources, MainParameters, SensorEvents, NotifyActiveSensorRequest, ActuatorEvents, ActuatorType
from parameters import Parameters, AuthLevel, AttributePrototype, AttributeType
from constants import DeviceLoginRequest, NotifyActiveSensorRequest, SensorParameters, ServerParameters, SendSensorDataRequest, ServerAPI, ActuatorType, ShowerActuatorParameters
from constants import HeaterActuatorParameters, ActuatorEvents
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


		logger = diagnostic.Diagnostic(path = Resources.LOGGER_FILE, logLevel = diagnostic.DEBUG)
		eventHandler = event.Event()
		dataHandler = data.Data()
	except Exception as e:
		print("Error: {}".format(e))
		exit(1)

	return eventHandler, dataHandler, logger

async def main() -> None:
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
		logger.record(msg = "Error occurred while trying to authenticate, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exc = e)
		sys.exit(1)

	# Load the devices' configuration from file
	try:
		with open(Resources.DEVICE_FILE, "r") as f:
			devices_list = json.load(f)
	except Exception as e:
		logger.record(msg = "Error occurred while trying to load devices' configuration, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exc = e)
		sys.exit(1)

	# Register the sensors to the ControlSingals handler
	for sensor in devices_list["sensors"]:
		try:
			# Add the control signal because only sensor have to send back data
			controlSignals.addSensors(id = int(sensor["id"]), pin = int(sensor["GPIO"]))
			
			if serialInterface.addDevice(id = int(sensor["id"]), port = sensor["UART"]) == True:
				converted_uid = f"{sensor['id']:010}"
				current_time = int(datetime.datetime.now().timestamp())
				serialInterface.send(id = int(sensor["id"]), message = f"SA{converted_uid}{current_time:010}")
				resp = serialInterface.receive(id = int(sensor["id"]), timeout = 5)

				if resp != None and "OK" in resp:
					sensor_list[sensor["id"]] = sensor["type"]
				else:
					logger.record(msg = f"Sensor {sensor['id']} didn't respond OK the SA request", logLevel = diagnostic.ERROR, module = _MODULE, code = 1)
		except Exception as e:
			logger.record(msg = f"Error occurred while trying to register sensor {sensor['id']} ", logLevel = diagnostic.ERROR, module = _MODULE, code = 1, exc = e)
			continue

	# Register the actuator without the control signal because they will only take data, never send any
	for actuator in devices_list["actuators"]:
		try:
			if serialInterface.addDevice(id = int(actuator["id"]), port = actuator["UART"]) == True:
				serialInterface.send(id = int(sensor["id"]), message = f"OK")
				resp = serialInterface.receive(id = int(sensor["id"]), timeout = 5)

				if "OK" in resp:
					actuator_list[actuator["id"]] = actuator["type"]
				else:
					logger.record(msg = f"Actuator {actuator['id']} didn't respond OK the SA request", logLevel = diagnostic.ERROR, module = _MODULE, code = 1)
		except Exception as e:
			logger.record(msg = f"Error occurred while trying to register actuator {actuator['id']} ", logLevel = diagnostic.ERROR, module = _MODULE, code = 1, exc = e)
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
		logger.record(msg = "Error occurred while trying to notify the sensor list to the server, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exc = e)
		sys.exit(1)

	# Open the WebSocket connection to server in order to get the actuators commands
	loop = asyncio.get_event_loop()
	loop.set_debug(True)
	loop.create_task(serverHandler.getActuatorsCommands())

	# Main messaging loop
	while True:

		# Wait until there is an event to process
		try:
			await asyncio.sleep(0.1)
			sensor_res = eventInterface.pend(name = SensorEvents.SENSOR_REQUEST_TO_TALK, timeout = 1)
			actuator_res = eventInterface.pend(name = ActuatorEvents.COMMAND_FOR_ACTUATOR, timeout = 1)
		except Exception as e:
			logger.record(msg = "The SENSOR_REQUEST_TO_TALK does not exists", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exc = e)
			sys.exit(1)

		# Process the sensor request queue, one by one
		if sensor_res is True:
			eventInterface.clear(name = SensorEvents.SENSOR_REQUEST_TO_TALK)
			while dataInterface.isQueueEmpty(name = SensorEvents.SENSOR_REQUEST_TO_TALK) == False:

				# Get the sensor ID that requested to talk
				sensor_id = dataInterface.popQueue(name = SensorEvents.SENSOR_REQUEST_TO_TALK)

				# Request to the sensor to provide the data
				serialInterface.send(id = sensor_id, message = "SD")
				resp = serialInterface.receive(id = sensor_id, timeout = 5)

				if type(resp) != str:
					continue

				# The message is a Data Packet, with the recorded values and the shape: DP<id><start_time><end_time><values>
				if "SD" in resp:
					if sensor_list[sensor_id] == "FLO":
						liters = float(resp[2:9])
						temp = float(resp[9:15])
						start = datetime.datetime.fromtimestamp(int(resp[15:25]))
						end = datetime.datetime.fromtimestamp(int(resp[25:35]))

						start = start.strftime("%Y-%m-%d %H:%M:%S")
						end = end.strftime("%Y-%m-%d %H:%M:%S")
						
						serverHandler.sendSensorData(sensor_id = sensor_id, start_timestamp = start, end_timestamp = end, payload = {"temperature": temp, "water_liters": liters})
					elif sensor_list[sensor_id] == "LEV":
						start = datetime.datetime.fromtimestamp(int(resp[2:12]))
						end = start

						start = start.strftime("%Y-%m-%d %H:%M:%S")
						end = end.strftime("%Y-%m-%d %H:%M:%S")
						
						serverHandler.sendSensorData(sensor_id = sensor_id, start_timestamp = start, end_timestamp = end, payload = {"water_liters": 30.0})
					elif sensor_list[sensor_id] == "HEA":
						liters = float(resp[2:9])
						temperature = float(resp[9:15])
						gas = float(resp[15:21])

						start = datetime.datetime.fromtimestamp(int(resp[21:31]))
						end = datetime.datetime.fromtimestamp(int(resp[31:41]))

						serverHandler.sendSensorData(sensor_id = sensor_id, start_timestamp = start, end_timestamp = end, payload = {"water_liters": liters, "temperature": temperature, "gas_volume": gas})



		if actuator_res is True:
			eventInterface.clear(name = ActuatorEvents.COMMAND_FOR_ACTUATOR)
			while dataInterface.isQueueEmpty(name = ActuatorEvents.COMMAND_FOR_ACTUATOR) == False:

				# Get the command
				command = dataInterface.popQueue(name = ActuatorEvents.COMMAND_FOR_ACTUATOR)
				actuator_type = command["type"]

				if actuator_type == ActuatorType.SHOWER_ACTUATOR:
					id = command[ShowerActuatorParameters.ID]
					temperature = int(command[ShowerActuatorParameters.TEMPERATURE] * 10)

					# Send to the actuator this command with the format: EX<temperature>
					serialInterface.send(id = id, message = f"EX{temperature}")
					resp = serialInterface.receive(id = id, timeout = 5)

					if "OK" not in resp:
						logger.record(msg = "The shower actuator responded with an error to a command", logLevel = diagnostic.WARNING, module = _MODULE, code = 1)
						
				elif actuator_type == ActuatorType.HEATER_ACTUATOR:
					id = command["id"]
					status = command["status"]
					temperature = command["temperature"]
					time_start = command["time_start"]
					time_end = command["time_end"]
					automatic = command["automatic"]

					if status == True:
						# Create the tuple for each timeslot
						if len(temperature) != len(time_start) or len(temperature) != len(time_end):
							logger.record(msg = "In heater actuator command, the three lists have different lengths", logLevel = diagnostic.WARNING, module = _MODULE, code = 1, exc = e)
							continue
						
						timeslots = list()
						for i in range(len(temperature)):
							timeslots.append((temperature[i], time_start[i], time_end[i]))

						# Order the list with timestamp increasing order
						timeslots.sort(key = lambda x: x[1])

						# For each timeslot, send a command to the actuator
						for i in range(len(timeslots)):
							sequence_number = len(timeslots) - i - 1
							temperature = int(timeslots[i][0] * 100)
							message = f"EX1{sequence_number:03}{timeslots[i][1]}{timeslots[i][2]}{temperature:03}"

							# Send to the actuator this command with the format: EX<temperature>
							serialInterface.send(id = id, message = message)
							resp = serialInterface.receive(id = id, timeout = 5)

							if "OK" not in resp:
								logger.record(msg = "The Heater actuator responded with an error to a command", logLevel = diagnostic.WARNING, module = _MODULE, code = 1)
					else:
						message = f"EX0"

						# Send to the actuator this command with the format: EX<temperature>
						serialInterface.send(id = id, message = message)
						resp = serialInterface.receive(id = id, timeout = 5)

						if "OK" not in resp:
							logger.record(msg = "The Heater actuator responded with an error to a command", logLevel = diagnostic.WARNING, module = _MODULE, code = 1)
								
if __name__ == "__main__":
	asyncio.run(main())