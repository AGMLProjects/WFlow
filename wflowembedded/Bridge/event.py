import threading, time, copy, signal

class Event():
	'''Provide a centralized interface to manage intermodule communications through events.'''

	_EVENT = "event"

	def __init__(self):
		self._events = dict()
		self._eventsLock = threading.Lock()

	@property
	def eventsList(self) -> list:
		'''List of events handled by this object'''
		
		with self._eventsLock:
			return copy.deepcopy(list(self._events.keys()))

	@property
	def eventsNumber(self) -> int:
		'''Number of events handled by this object'''

		with self._eventsLock:
			return len(self._events.keys())

	def pend(self, name: str, timeout: int = None) -> bool:
		'''
		Block on the event until someone set it or until the timeout expires, if present.
		Returns True if someone set the event, False if the timeout expires.
		If the event doesn't exist raise ValueError
		'''

		if type(name) != str:
			raise TypeError

		if timeout != None and type(timeout) != int:
			raise TypeError

		if name in self._events.keys():
			if timeout != None:
				return self._events[name][self._EVENT].wait(float(timeout))
			else:
				return self._events[name][self._EVENT].wait()
		else:
			raise ValueError

	def check(self, name: str) -> bool:
		'''
		Check the event status.
		Returns True if is set, False if not.
		If the event doesn't exist raise ValueError
		'''
		if type(name) != str:
			raise TypeError

		if name in self._events.keys():
			return self.pend(name = name, timeout = 0)
		else:
			raise ValueError

	def clear(self, name: str) -> None:
		'''Clear an event. If it doesn't exits raise ValueError'''

		if type(name) != str:
			raise TypeError

		with self._eventsLock:
			if name in self._events.keys():
				self._events[name][self._EVENT].clear()
			else:
				raise ValueError

	def create(self, name: str) -> bool:
		'''
		Create a new event.
		If the event already exist return False, otherwise return True.
		'''

		if type(name) != str:
			raise TypeError

		with self._eventsLock:
			if name in self._events.keys():
				return False
			else:
				self._events[name] = {self._EVENT: threading.Event()}
				return True
		
	def set(self, name: str) -> None:
		'''
		Raise an event.
		If the event doesn't exist raise ValueError
		'''

		if type(name) != str:
			raise TypeError

		if name not in self.eventsList:
			raise ValueError

		with self._eventsLock:
			if self._events[name][self._EVENT].is_set() == False:
				self._events[name][self._EVENT].set()

	def waitEventCreation(self, name: str, timeout: int = None) -> bool:
		'''
		Block until the requested event is created by another thread.
		If timeout is given, return False after that time (in seconds)
		if the requested event hasn't been created.
		If the requested event has been created return True
		'''

		if type(name) != str:
			raise TypeError

		if timeout != None and type(timeout) != int:
			raise TypeError

		while True:
			if name in self.eventsList:
				return True
			else:
				if timeout != None:
					if timeout <= 0:
						return False
					timeout = timeout - 1
			time.sleep(1)

class InterruptHandler(object):
    '''Handle system signals gracefully to permit a clean exit'''

    def __init__(self, event: Event, signals: tuple = (signal.SIGINT, signal.SIGTERM)):
        if type(signals) != tuple:
            raise TypeError

        self.signals = signals                                          # Touple of handled signals (for us only the ones related to closign the program)
        self.original_handlers = {}                                     # Original handlers from the signal module

        self._event = event

    def __enter__(self):                                                # Method called when this object is opened as an handler
        self.interrupted = False                                        # Reset status flags
        self.released = False

        for sig in self.signals:                                        
            self.original_handlers[sig] = signal.getsignal(sig)         # Get the original handlers for each signal
            signal.signal(sig, self.handler)                            # Substitute the origina ones with this class' one

        return self

    def __exit__(self, type, value, tb) -> None:                        # Method called when this class' object is closed
        self.release()
        self.interrupted = True

    def handler(self, signum, frame) -> None:                           # Method invoked when a system signal is received
        self.release()
        self.interrupted = True
        self._event.raiseEvent(name = "kill")

    def release(self) -> bool:                                          # For each signal that we are handling, set back the original handler
        if self.released == True:
            return False

        for sig in self.signals:
            signal.signal(sig, self.original_handlers[sig])

        self.released = True
        return True

