import sys
import data, event, diagnostic, server
from constants import Resources, MainParameters
from parameters import Parameters, AuthLevel, AttributePrototype, AttributeType

_MODULE = "MAIN"
defaultMainParam = {
	MainParameters.BRIDGE_ID: "",
	MainParameters.SECRET: "",
	MainParameters.TIMEOUT_TIMER_TO_AUTH_ATTEMPT: 1 * 60,
    MainParameters.LOG_LEVEL: diagnostic.WARNING,
}

defaultMainAttr = {
	MainParameters.BRIDGE_ID: {AttributePrototype.TYPE: AttributeType.TEXT, AttributePrototype.WRITABLE : False, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
	MainParameters.SECRET: {AttributePrototype.TYPE: AttributeType.PASSWORD, AttributePrototype.WRITABLE : False, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "", AttributePrototype.AUTH_LEVEL : AuthLevel.ADMIN},
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
    serverHandler = server.ServerConnector() #TODO: Definire come prendere questi parametri
    # TODO: Definire come fare il loop di autenticazione