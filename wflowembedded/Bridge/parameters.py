import json, threading, copy, os, re, time

class AttributePrototype():

    TYPE = "type"
    WRITABLE = "writable"
    NULLABLE = "nullable"
    AUTH_LEVEL = "authLevel"
    DOC = "doc"

    MIN = "min"
    MAX = "max"

    VALUES = "values"

    def __init__(self) -> None:
        raise Exception("This class can't be concrete!")

    @classmethod
    def allFieldslist(cls):
        varList = [attr for attr in vars(cls) if not callable(getattr(cls, attr)) and not attr.startswith("__")]
        return [vars(cls)[elem] for elem in varList]
    
    @classmethod
    def mandatoryFieldsList(cls, attributeType: str) -> list:
        '''
        Returns the mandatory fields for an attribute based on its type.
        '''
        if type(attributeType) != str:
            raise TypeError
        
        if attributeType not in AttributeType.list():
            raise ValueError
        
        returnList = [cls.TYPE, cls.WRITABLE, cls.NULLABLE, cls.AUTH_LEVEL, cls.DOC]
        if attributeType == AttributeType.NUM:
            returnList.append(cls.MIN)
            returnList.append(cls.MAX)
        elif attributeType == AttributeType.LIST:
            returnList.append(cls.VALUES)
        
        return returnList

class AttributeType():

    TEXT = "text"
    NUM = "num"
    BOOL = "bool"
    LIST = "list"
    IP = "ip"
    EMAIL = "email"
    TIME = "time"
    MAC = "mac"
    DICT = "dict"
    TUPLE = "tuple"
    PASSWORD = "password"
    QUEUE = "queue"

    def __init__(self) -> None:
        raise Exception("This class can't be concrete!")

    @classmethod
    def list(cls):
        varList = [attr for attr in vars(cls) if not callable(getattr(cls, attr)) and not attr.startswith("__")]
        return [vars(cls)[elem] for elem in varList]

class AuthLevel():
    '''Authorization level related to each parameter'''

    ADMIN = 1
    SERVICE = 2
    USER = 3

    def __init__(self) -> None:
        raise Exception("This class can't be concrete!")

    @classmethod
    def list(cls):
        varList = [attr for attr in vars(cls) if not callable(getattr(cls, attr)) and not attr.startswith("__")]
        return [vars(cls)[elem] for elem in varList]

# Manage access to non-volatile memory.
class Parameters():
    '''Provide a generic interface to store parameters and their attributes into the system's memory'''
    _paramFilePath = None
    _param = None
    _attr = None
    _defaultParam = None
    _memoryLock = None
    _PARAM_VALUES_SUPPORTED_TYPES = [int, str, float, dict, list, tuple, bool, type(None)]

    def __init__(self):
        raise Exception("This class can't be instantiated")

    # Initialize the Parameters module
    @classmethod
    def init(cls, paramFile: str) -> bool:
        '''Initialize the Parameters module. Returns True on success, False otherwise'''
        
        if type(paramFile) != str:
            raise TypeError

        cls._paramFilePath = paramFile
        cls._memoryLock = threading.Lock()
        cls._param = dict()
        cls._attr = dict()
        cls._defaultParam = dict()

        cls._checkFileExistence()

        if os.path.isfile(cls._paramFilePath) == False:
            raise NotImplementedError
            
        cls.loadParam(defaultParam={}, defaultAttr={})
        return True

    # Check if param files exist
    @classmethod
    def _checkFileExistence(cls) -> None:
        '''Check if param files exist'''

        if os.path.isfile(cls._paramFilePath) == False:
            with open(cls._paramFilePath, 'w') as f:
                json.dump(cls._param, f)

    # Return the parameters dictionary
    @classmethod
    def getAllParam(cls) -> dict:
        '''Get (a copy of) the parameters dictionary'''
        if type(cls._paramFilePath) != str or cls._param == None:
            raise Exception("Parameters module is not initialized")
        
        with cls._memoryLock:
            return copy.deepcopy(cls._param)

    # Return the attributes dictionary
    @classmethod
    def getAllAttr(cls) -> dict:
        '''Get (a copy of) the attributes dictionary'''
        if cls._attr == None:
            raise Exception("Parameters module is not initialized")
        
        with cls._memoryLock:
            return copy.deepcopy(cls._attr)

    # Update the parameters dictionary
    @classmethod
    def updateParam(cls, param: dict) -> None:
        '''
        Update the parameters structure, if the given values are valid.
        param must be a dictionary but it can contains only the values that have to be changed.
        '''

        if type(cls._paramFilePath) != str or cls._param == None:
            raise Exception("Parameters module is not initialized")
        if type(param) != dict:
            raise TypeError

        param = copy.deepcopy(param)                                        # Create a copy of the original dictionary to avoid unwanted behavior douring validate

        cls._validateParamStructure(param = param)
        cls._validateParamContent(param = param)                            # Verify the new parameters
        
        with cls._memoryLock:
            cls._param = {**cls._param, **param}
        
        cls._saveParam()

    # Change the value of a specified param
    @classmethod
    def setParam(cls, key: str, value: object) -> bool:
        '''
        Save single parameter into parameters structure
        If the param is wrong returns False, otherwise True.
        '''

        if type(cls._paramFilePath) != str or cls._param == None:
            raise Exception("Parameters module is not initialized")

        if type(key) != str:
            raise TypeError

        tmp = {key:value}

        cls._validateParamStructure(tmp)
        cls._validateParamContent(tmp)

        if tmp == {}:
            return False

        with cls._memoryLock:
            cls._param[key] = copy.deepcopy(value)

        cls._saveParam()
        return True

    # Return the value of a specified param
    @classmethod
    def getParam(cls, key: str) -> object:
        '''Get value of a single parameter saved into parameters structure'''
        
        if type(cls._paramFilePath) != str or cls._param == None:
            raise Exception("Parameters module is not initialized")
                
        if type(key) != str:
            raise TypeError

        with cls._memoryLock:
            if key not in cls._param.keys():
                raise KeyError
            return copy.deepcopy(cls._param[key])
        
    # Read params from file
    @classmethod
    def loadParam(cls, defaultParam: dict, defaultAttr: dict) -> None:
        '''
        Load parameters from the designed file. If the file is not up to date
        this method also store the new parametes in it
        '''

        # Check preconditions
        if type(cls._paramFilePath) != str:
            raise Exception("Parameters module is not initialized")
        if type(cls._attr) != dict or type(cls._param) != dict or type(cls._defaultParam) != dict:
            raise Exception("Parameters module is not initialized")
        if type(defaultAttr) != dict or type(defaultParam) != dict:
            raise TypeError

        cls._validateParamStructure(defaultParam)
        cls._validateAttrStructure(defaultAttr)

        # Load attributes
        with cls._memoryLock:
            check = {**defaultAttr, **cls._attr}                        # Merge the obtained dictionary with the default one
            if check != cls._attr:                                      # If something has changed it means that the file is not up to date
                cls._attr = copy.deepcopy(check)                        # Copy the merged dictionary into the class variable

        # Load parameters
        tmp = copy.deepcopy(defaultParam)
        cls._validateParamContent(param = tmp)
        if tmp != defaultParam:
            raise ValueError

        with cls._memoryLock:
            cls._defaultParam = {**cls._defaultParam, **defaultParam}

        with cls._memoryLock:
            with open(cls._paramFilePath, "r") as fp:
                cls._param = json.load(fp)                              # Read parameters from the file
            check = {**defaultParam, **cls._param}                      # Merge the obtained dictionary with the default one
            
        if check != cls._param:                                         # If something has changed it means that the file is not up to date
            with cls._memoryLock:
                cls._param = copy.deepcopy(check)                       # Copy the merged dictionary into the class variable
            cls._saveParam()

    # Use default param
    @classmethod
    def factoryReset(cls) -> None:
        '''
        Writes default parameters into parameters file.
        '''
        if type(cls._paramFilePath) != str or type(cls._defaultParam) != dict:
            raise Exception("Parameters module is not initialized")

        with cls._memoryLock:
            cls._param = cls._defaultParam
            
        cls._saveParam()

    # Validate parameters using the control attributes
    @classmethod
    def _validateParamContent(cls, param: dict) -> None:
        '''
        Internal method to validate the given parameters usign the corresponding attributes.
        If one or more parameters are invalid, remove them from the dictionary.
        If the corresponding attribute is not available for a given parameter, it is considered valid.
        '''

        if type(param) != dict:
            raise TypeError

        invalidElements = []

        for element in param.keys():                                # For each parameter that has to be validate
            if element in cls._attr.keys():                             # If there is a corresponding attribute, use it to verify the parameter's validity
                if param[element] != None:
                    if cls._attr[element][AttributePrototype.TYPE] == AttributeType.DICT:
                        if type(param[element]) != dict:
                            invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.TEXT:
                        if type(param[element]) != str:
                            invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.IP:
                        if type(param[element]) != str:
                            invalidElements.append(element)
                        else:
                            regex = "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$"
                            if re.search(regex, param[element]) == None:
                                invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.EMAIL:
                        if type(param[element]) != str:
                            invalidElements.append(element)
                        else:
                            regex = re.compile(r'([A-Za-z0-9]+[.-_])*[A-Za-z0-9]+@[A-Za-z0-9-]+(\.[A-Z|a-z]{2,})+')
                            if re.fullmatch(regex, param[element]) == None:
                                invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.MAC:
                        if type(param[element]) != str:
                            invalidElements.append(element)
                        else:
                            regex = "^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$"
                            if re.match(regex, param[element]) == None:
                                invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.TUPLE:
                        if type(param[element]) != tuple:
                            invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.TIME:
                        if type(param[element]) != str:
                            invalidElements.append(element)
                        else:
                            try:
                                time.strptime(param[element], '%H:%M')
                            except ValueError:
                                invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.PASSWORD:
                        if type(param[element]) != str:
                            invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.BOOL:
                        if type(param[element]) != bool:
                            invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.LIST:
                        if param[element] not in cls._attr[element][AttributePrototype.VALUES]:
                            invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.NUM:
                        if type(param[element]) != int and type(param[element]) != float:
                            invalidElements.append(element)
                        else:
                            if param[element] < cls._attr[element][AttributePrototype.MIN] or param[element] > cls._attr[element][AttributePrototype.MAX]:
                                invalidElements.append(element)
                    elif cls._attr[element][AttributePrototype.TYPE] == AttributeType.QUEUE:
                        if type(param[element]) != list:
                            invalidElements.append(element)
                else:
                    if cls._attr[element][AttributePrototype.NULLABLE] == False:
                        invalidElements.append(element)

        for element in invalidElements:
            param.pop(element)
    
    # Validate parameters dict structure using Microlog standard parameters structure
    @classmethod
    def _validateParamStructure(cls, param: dict) -> None:
        '''
        Internal method to check if the parameters dict passed as parameter has the correct structure.
        The valid structure is the Microlog Standard Parameters Structure.
        If the structure is invalid an exception is thrown.
        '''

        if type(param) != dict:
            raise TypeError
        
        for key, value in param.items():
            if type(key) != str:
                raise TypeError
            if type(value) not in cls._PARAM_VALUES_SUPPORTED_TYPES:
                raise TypeError

    # Validate attributes dict structure using Microlog standard attributes structure
    @classmethod
    def _validateAttrStructure(cls, attr: dict) -> None:
        '''
        Internal method to check if the attributes dict passed as parameter has the correct structure.
        The valid structure is the Microlog Standard Attributes Structure.
        If the structure is invalid an exception is thrown.
        '''
        
        if type(attr) != dict:
            raise TypeError

        for attrName, attrProperties in attr.items():
            if type(attrName) != str:
                raise TypeError
            if type(attrProperties) != dict:
                raise TypeError

            if AttributePrototype.TYPE not in attrProperties.keys():
                raise TypeError
            elif sorted(AttributePrototype.mandatoryFieldsList(attrProperties[AttributePrototype.TYPE])) != sorted(attrProperties.keys()):
                raise TypeError

            for propertyName, propertyValue in attrProperties.items():
                if propertyName == AttributePrototype.AUTH_LEVEL:
                    if propertyValue not in AuthLevel.list():
                        raise ValueError
                elif propertyName == AttributePrototype.DOC:
                    if type(propertyValue) != str:
                        raise TypeError
                elif propertyName == AttributePrototype.MAX or propertyName == AttributePrototype.MIN:
                    if type(propertyValue) != int and type(propertyValue) != float:
                        raise TypeError
                elif propertyName == AttributePrototype.NULLABLE or propertyName == AttributePrototype.WRITABLE:
                    if type(propertyValue) != bool:
                        raise TypeError
                elif propertyName == AttributePrototype.VALUES:
                    if type(propertyValue) != list:
                        raise TypeError
                    elif len(propertyValue) < 1:
                        raise ValueError
    
    # Store param into a file
    @classmethod
    def _saveParam(cls) -> None:
        '''Save parameters into the designed file'''
        if type(cls._paramFilePath) != str or cls._param == None:
            raise Exception("Parameters module is not initialized")

        with cls._memoryLock:
            if os.path.exists(cls._paramFilePath):
                with open(cls._paramFilePath, "w") as fp:
                    json.dump(cls._param, fp)
            else:
                raise NotImplementedError

