import sys, time
import data, event, diagnostic, server
from constants import Resources, MainParameters
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
    arguments = len(sys.argv) - 1
    
    if arguments > 0:
        import ptvsd
        # Allow other computers to attach to ptvsd at this IP address and port.
        ptvsd.enable_attach(address = ("127.0.0.1", 3001))
        # Pause the program until a remote debugger is attached
        ptvsd.wait_for_attach()

    eventInterface, dataInterface, logger = init_system_object()
    serverHandler = server.ServerConnector(dataInterface = dataInterface, eventInterface = eventInterface, logger = logger)
    
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

    # Scann the sensors connected to the system in order to notify the server
    # TODO: Trovare i sensori connessi
    sensor_list = list()

    # Notify the sensor list to the server
    try:
        if serverHandler.notifySensors(sensors = sensor_list) is False:
            logger.record(msg = "Server refused our sensor list, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1)
            sys.exit(1)
    except Exception as e:
        logger.record(msg = "Error occurred while trying to notify the sensor list to the server, abort main", logLevel = diagnostic.CRITICAL, module = _MODULE, code = 1, exception = e)
        sys.exit(1)

    # TODO: Far partire il loop che gestisce la raccolta dati dai sensori
    # TODO: Far partire il loop che riceve i comandi dal server e li inoltra agli attuatori