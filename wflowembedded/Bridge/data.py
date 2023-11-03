import threading, copy

# Data types supported
INT = "int"
FLOAT = "float"
STR = "str"
BOOL = "bool"
FIFO = "fifo"
LIFO = "lifo"
DICT = "dict"
FUNCTION = "function"
OBJECT_DICT = "object_dict"
CUSTOM = "custom"

class QueueIsFullException(Exception):
	pass

class QueueIsEmptyException(Exception):
	pass

class Data():
	'''Provide a centralized interface to exchange data betwheen threads'''

	_TYPE = "type"
	_VALUE = "value"
	_MAX_LENGTH = "maxLength"

	def __init__(self):
		self._data = dict()
		self._dataLock = threading.Lock()
		self._supportedTypes = [INT, FLOAT, STR, BOOL, FIFO, LIFO, DICT, FUNCTION, OBJECT_DICT, CUSTOM]

	# Get the list of available data
	@property
	def availableData(self) -> list:
		'''List of data currently stored in this object'''
		with self._dataLock:
			return copy.deepcopy(list(self._data.keys()))

	# Get the list of supported types
	@property
	def supportedTypes(self) -> list:
		'''List of supported data types'''
		return list(self._supportedTypes)

	# Esare all data
	def erase(self) -> None:
		'''Delete all data in this object'''
		with self._dataLock:
			self._data = dict()

	# Store a new value or overwrite it
	def store(self, name: str, dataType: str, value: object, maxLength: int = None) -> None:
		'''
		Add a new value or if another value with the same name is already present, overwrite it.
		This method also verifies that "newValue" match "valueType" specification.
		Return True in case of success, False if there is a type mistmatch between newValue and valueType.
		If "valueType" is an unknown type, it is considered "custom"
		'''

		if type(name) != str or type(dataType) != str:
			raise TypeError

		if maxLength != None and type(maxLength) != int:
			raise TypeError

		if dataType not in self._supportedTypes:
			raise ValueError

		if dataType == INT and type(value) != int:
			raise ValueError
		if dataType == FLOAT and type(value) != float:
			raise ValueError
		if dataType == STR and type(value) != str:
			raise ValueError
		elif dataType == BOOL and type(value) != bool:
			raise ValueError			
		if (dataType == FIFO or dataType == LIFO) and type(value) != list:
			raise ValueError
		if (dataType == DICT or dataType == OBJECT_DICT) and type(value) != dict:
			raise ValueError
		if dataType == FUNCTION and callable(value) == False:
			raise ValueError

		with self._dataLock:
			if dataType in [OBJECT_DICT, FUNCTION, CUSTOM]:
				self._data[name] = {self._TYPE: dataType, self._VALUE: value}
			else:
				self._data[name] = {self._TYPE: dataType, self._VALUE: copy.deepcopy(value)}

				if dataType in [FIFO, LIFO]:
					self._data[name][self._MAX_LENGTH] = maxLength

	# Append a new item to a list value
	def pushQueue(self, name: str, newItem: object, replace: bool = True) -> None:
		'''
		Append an item to a "fifo" or "lifo" queue.
		If the value is not a queue or it doesn't exist raise ValueError
		'''

		if type(name) != str or type(replace) != bool:
			return TypeError

		if name not in self.availableData:
			raise ValueError

		if self._data[name][self._TYPE] not in [FIFO, LIFO]:
			raise ValueError

		with self._dataLock:
			if self._data[name][self._TYPE] == FIFO:
				if self._data[name][self._MAX_LENGTH] != None:		
					if self._data[name][self._MAX_LENGTH] <= len(self._data[name][self._VALUE]):
						if replace == False:
							raise QueueIsFullException
						else:
							self._data[name][self._VALUE].pop(0)
				self._data[name][self._VALUE].append(copy.deepcopy(newItem))

			if self._data[name][self._TYPE] == LIFO:
				self._data[name][self._VALUE].insert(0, copy.deepcopy(newItem))

				if self._data[name][self._MAX_LENGTH] != None:		
					if self._data[name][self._MAX_LENGTH] < len(self._data[name][self._VALUE]):     # Space limit reached
						if replace == False:
							raise QueueIsFullException
						else:
							self._data[name][self._VALUE].pop(-1)                                       # Remove the last item in tail

	# Get and remove an item from a "list" value
	def popQueue(self, name: str) -> object:
		'''
		Get and return an element from a "fifo" or "lifo" queue. 
		If the value doesn't exists, it's not a queue or if the queue is empty raise ValueError.
		'''

		if type(name) != str:
			return TypeError

		if name not in self.availableData:
			raise ValueError

		if self._data[name][self._TYPE] not in [FIFO, LIFO]:
			raise ValueError

		if self._data[name][self._VALUE] == []:
			raise QueueIsEmptyException
		else:
			with self._dataLock:
				if self._data[name][self._TYPE] == FIFO:
					item = self._data[name][self._VALUE].pop(0)
				elif self._data[name][self._TYPE] == LIFO:
					item = self._data[name][self._VALUE].pop(-1)

			return copy.deepcopy(item)

	def getQueue(self, name: str) -> object:
		'''
		Get and return an element from a "fifo" or "lifo" queue without removing it.
		If the value doesn't exists, it's not a queue or if the queue is empty raise ValueError.
		'''

		if type(name) != str:
			return TypeError

		if name not in self.availableData:
			raise ValueError

		if self._data[name][self._TYPE] not in [FIFO, LIFO]:
			raise ValueError

		if self._data[name][self._TYPE] == []:
			raise ValueError
		else:
			with self._dataLock:
				if self._data[name][self._TYPE] == FIFO:
					item = self._data[name][self._VALUE][0]
				elif self._data[name][self._TYPE] == LIFO:
					item = self._data[name][self._VALUE][-1]
			
			return copy.deepcopy(item)

	def isQueueFull(self, name: str) -> bool:
		'''
		Returns True if the max number of items is reached.
		If the requested value is not queue raise ValueError.
		'''

		if type(name) != str:
			return TypeError

		if name not in self.availableData:
			raise ValueError

		if self._data[name][self._TYPE] not in [FIFO, LIFO]:
			raise ValueError

		with self._dataLock:
			if self._data[name][self._MAX_LENGTH] != None:
				if self._data[name][self._MAX_LENGTH] <= len(self._data[name][self._VALUE]):
					return True
		
		return False

	def isQueueEmpty(self, name: str) -> bool:
		'''
		Returns True if the queue is empty.
		If the requested value is not queue raise ValueError.
		'''

		if type(name) != str:
			return TypeError

		if name not in self.availableData:
			raise ValueError

		if self._data[name][self._TYPE] not in [FIFO, LIFO]:
			raise ValueError

		with self._dataLock:
			if  len(self._data[name][self._VALUE]) == 0:
				return True
			else:
				return False
	
	def insertDict(self, name: str, newValues: dict) -> None:
		'''
		Insert new elements into an existing dictionary. If the given newValues 
		contains keys that are already stored into the dict, overwrite their values with the new ones.
		If the requested dict doesn't exist, raise ValueError.
		'''

		if type(name) != str or type(newValues) != dict:
			raise TypeError

		if name not in self.availableData:
			raise ValueError

		if self._data[name][self._TYPE] not in [DICT, OBJECT_DICT]:
			raise ValueError

		with self._dataLock:
			self._data[name][self._VALUE] = {**self._data[name][self._VALUE], **newValues}

	def get(self, name: str) -> object:
		'''
		Returns the requested value if exists, otherwise raise ValueError.
		'''

		if type(name) != str:
			raise TypeError

		if name not in self.availableData:
			raise ValueError

		with self._dataLock:
			if self._data[name][self._TYPE] in [OBJECT_DICT, FUNCTION, CUSTOM]:
				return self._data[name][self._VALUE]
			else:
				return copy.deepcopy(self._data[name])[self._VALUE]

	def set(self, name: str, value: object) -> None:
		'''
		Update the value of an existing item. If the item doesn't exit raise ValueError.
		If dataTypes mismatch raise TypeError
		'''

		if type(name) != str:
			raise TypeError

		if name not in self.availableData:
			raise ValueError

		if self._data[name][self._TYPE] == INT and type(value) != int:
			raise ValueError
		if self._data[name][self._TYPE] == FLOAT and type(value) != float:
			raise ValueError
		if self._data[name][self._TYPE] == STR and type(value) != str:
			raise ValueError
		if self._data[name][self._TYPE] == BOOL and type(value) != bool:
			raise ValueError
		if (self._data[name][self._TYPE] == FIFO or self._data[name][self._TYPE] == LIFO) and type(value) != list:
			raise ValueError
		if (self._data[name][self._TYPE] == DICT or self._data[name][self._TYPE] == OBJECT_DICT) and type(value) != dict:
			raise ValueError
		if self._data[name][self._TYPE] == FUNCTION and callable(value) == False:
			raise ValueError

		with self._dataLock:
			if self._data[name][self._TYPE] in [OBJECT_DICT, FUNCTION, CUSTOM]:
				self._data[name][self._VALUE] = value
			else:
				self._data[name][self._VALUE] = copy.deepcopy(value)

	def getDict(self, name: str, key: object) -> object:
		'''
		Return the requested element from a dict item
		If the requested dictionary doesn't exist raise ValueError.
		If the dataTypes mismatch raise TypeError.
		If the requested key is not in the dict raise KeyError
		'''

		if type(name) != str or key == None:
			raise TypeError

		if name not in self.availableData:
			raise ValueError

		if self._data[name][self._TYPE] not in [DICT, OBJECT_DICT]:
			raise TypeError

		with self._dataLock:
			if key in self._data[name][self._VALUE].keys():
				if self._data[name][self._TYPE] == DICT:
					return copy.deepcopy(self._data[name][self._VALUE][key])
				else:
					return self._data[name][self._VALUE][key]
			else:
				raise KeyError

	# Delete a value, if present
	def remove(self, name: str) -> None:
		'''Delete a value'''

		if type(name) != str:
			raise TypeError

		if name not in self.availableData:
			return

		with self._dataLock:
			self._data.pop(name)

