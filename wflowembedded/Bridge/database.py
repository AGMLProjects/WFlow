import mariadb, copy
import diagnostic
from contextlib import closing
from parameters import Parameters, AttributePrototype, AttributeType, AuthLevel
from constants import DatabaseParameters, Device, DatabaseRecord

_MODULE = "DBMS"

defaultDatabaseParam = {
	DatabaseParameters.HOST: "127.0.0.1",
	DatabaseParameters.USERNAME: "root",
	DatabaseParameters.PASSWORD: "ViaMarx@1407",
	DatabaseParameters.PORT: 3306,
	DatabaseParameters.DATABASE: "VPC0101"
}

defaultDatabaseAttr = {
	DatabaseParameters.HOST: 	{AttributePrototype.TYPE: AttributeType.IP, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "MariaDB running host's IP", AttributePrototype.AUTH_LEVEL : AuthLevel.MICROLOG},
	DatabaseParameters.USERNAME:{AttributePrototype.TYPE: AttributeType.TEXT, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "Database username login", AttributePrototype.AUTH_LEVEL : AuthLevel.MICROLOG},
	DatabaseParameters.PASSWORD:{AttributePrototype.TYPE: AttributeType.PASSWORD, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "Database password login", AttributePrototype.AUTH_LEVEL : AuthLevel.MICROLOG},
	DatabaseParameters.PORT: 	{AttributePrototype.TYPE: AttributeType.NUM, AttributePrototype.MAX: 65535, AttributePrototype.MIN:1, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "MariaDB communication port", AttributePrototype.AUTH_LEVEL : AuthLevel.MICROLOG},
	DatabaseParameters.DATABASE:{AttributePrototype.TYPE: AttributeType.TEXT, AttributePrototype.WRITABLE : True, AttributePrototype.NULLABLE : False, AttributePrototype.DOC : "Used database", AttributePrototype.AUTH_LEVEL : AuthLevel.MICROLOG},
}

class DatabaseHandler:
	'''
	Provide an interface to communicate with a mariaDB database.
	'''
	def __init__(self, logger: diagnostic.Diagnostic):
		'''
		Initializates the module
		'''
		if isinstance(logger, diagnostic.Diagnostic) != True:
			raise TypeError

		Parameters.loadParam(defaultParam= defaultDatabaseParam, defaultAttr= defaultDatabaseAttr)
		self._logger = logger
		self._host = ""
		self._username = ""
		self._password = ""
		self._port = 0
		self._database = ""
		self._dbConn = None
		self._tableInUse = ""

	def open(self):
		'''
		Create a connection to a MariaDB database.
		'''

		if self._dbConn == None:
			self._host = Parameters.getParam(DatabaseParameters.HOST)
			self._username = Parameters.getParam(DatabaseParameters.USERNAME)
			self._password = Parameters.getParam(DatabaseParameters.PASSWORD)
			self._port = Parameters.getParam(DatabaseParameters.PORT)
			self._database = Parameters.getParam(DatabaseParameters.DATABASE)
			self._tableInUse = "records"

			try:
				self._dbConn = mariadb.connect( host=self._host,
					user=self._username,
					password=self._password,
					port=self._port,
					database=self._database
				)
				self._dbConn.autocommit = True                                                                              #sets autocommit to true so is not necessary doing 'commit()' every time a query modifies the database
				self._dbConn.auto_reconnect = True

				records_table_creation_query = f"CREATE TABLE IF NOT EXISTS {self._tableInUse}(\
						ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,\
						{DatabaseRecord.SENSOR_ID} INT NOT NULL,\
						{DatabaseRecord.TIMESTAMP} BIGINT DEFAULT 0 NOT NULL,\
						{DatabaseRecord.INBOUND} INT NOT NULL,\
						{DatabaseRecord.OUTBOUND} INT NOT NULL,\
						{DatabaseRecord.GPS_LATITUDE} DOUBLE NOT NULL,\
						{DatabaseRecord.GPS_LONGITUDE} DOUBLE NOT NULL,\
						{DatabaseRecord.EVENT_CREATOR} VARCHAR(255) NOT NULL,\
						{DatabaseRecord.SENSOR_TYPE} VARCHAR(20) NOT NULL CHECK({DatabaseRecord.SENSOR_TYPE} = 'Smartcheck' or {DatabaseRecord.SENSOR_TYPE} = 'Xovis'),\
						UNIQUE({DatabaseRecord.SENSOR_ID}, {DatabaseRecord.TIMESTAMP}, {DatabaseRecord.GPS_LONGITUDE}, {DatabaseRecord.GPS_LATITUDE}, {DatabaseRecord.EVENT_CREATOR}, {DatabaseRecord.SENSOR_TYPE}))"
				
				with closing(self._dbConn.cursor()) as cursor:
					cursor.execute(records_table_creation_query)

			except Exception as e:
				self._logger.record(msg="Impossible to connect to MariaDB DBMS", logLevel=diagnostic.CRITICAL, module=_MODULE, code=1, exc=e)
				raise e  
			
			self._logger.record("Database module correctly started", logLevel=diagnostic.DEBUG, module=_MODULE, code=1)
		else:
			raise Exception("A connection with the database has already been opened")

	def saveRecords(self, records: list) -> None:
		'''
		Store xovis or smartcheck records in the database.
		'''

		if type(records) != list:
			raise TypeError

		if self._dbConn != None:	
			query = f"INSERT INTO {self._tableInUse}({DatabaseRecord.SENSOR_ID}, {DatabaseRecord.TIMESTAMP}, {DatabaseRecord.INBOUND}, {DatabaseRecord.OUTBOUND}, {DatabaseRecord.GPS_LATITUDE}, {DatabaseRecord.GPS_LONGITUDE}, {DatabaseRecord.SENSOR_TYPE}, {DatabaseRecord.EVENT_CREATOR}) values(?,?,?,?,?,?,?,?)"

			for record in copy.deepcopy(records):
				try:
					if type(record) != dict:
						raise TypeError("record is not a dict")
					elif any(key not in record.keys() for key in DatabaseRecord.list()):
						raise Exception(f"A key is missing from the record")
					else:
						with closing(self._dbConn.cursor()) as cursor:
							data = (record[DatabaseRecord.SENSOR_ID], record[DatabaseRecord.TIMESTAMP], record[DatabaseRecord.INBOUND], record[DatabaseRecord.OUTBOUND], record[DatabaseRecord.GPS_LATITUDE], record[DatabaseRecord.GPS_LONGITUDE], record[DatabaseRecord.SENSOR_TYPE], record[DatabaseRecord.EVENT_CREATOR])
							cursor.execute(query, data)
						self._logger.record(msg=f"Record correctly stored in the DB. Record: {data}", logLevel=diagnostic.DEBUG, module=_MODULE, code=1)
				except Exception as e:                              #exception occurs
					self._logger.record(msg=f"Exception occurs while saving a record into the database. Record: {record}", logLevel=diagnostic.ERROR, module=_MODULE, code=4, exc=e)        
		else:
			raise Exception("dbConn is None")

	def selectRecordsYoungerThanTimestamp(self, timestamp: int) -> list:
		if type(timestamp) != int:
			raise TypeError
		
		if self._dbConn != None:
			query = f"SELECT {DatabaseRecord.TIMESTAMP}, {DatabaseRecord.GPS_LATITUDE}, {DatabaseRecord.GPS_LONGITUDE}, {DatabaseRecord.INBOUND}, {DatabaseRecord.OUTBOUND}, {DatabaseRecord.SENSOR_ID}, {DatabaseRecord.SENSOR_TYPE}, {DatabaseRecord.EVENT_CREATOR} FROM {self._tableInUse} WHERE {DatabaseRecord.TIMESTAMP} > ?"
			try:
				with closing(self._dbConn.cursor()) as cursor:
					cursor.execute(query, [timestamp])
					return cursor.fetchall()
			except Exception as e:
				self._logger.record(msg=f"Exception while fetching records from DB based on their timestamp. Timestamp: {timestamp}", logLevel=diagnostic.ERROR, module=_MODULE, code=3, exc=e)
				return list()
		else:
			raise Exception("dbConn is None")

	def sendQuery(self, query: str, return_last_response: bool) -> list:
		'''
		Sends queries to DBMS.
		It expects query: an initial query as a string, return_last_response: if is True returns a list of tuples as the result of the last executed query if exists, otherwise returns an empty list, other_queries: other queries to be executed as a list of string.
		If an exception occurs with the database comunications it returns None.
		'''

		if type(query) != str:
			raise TypeError
		elif type(return_last_response) != bool:
			raise TypeError

		if self._dbConn != None:
			result = []
			try:
				with closing(self._dbConn.cursor()) as cursor:
					cursor.execute(query)                           #executes the query
					if return_last_response == True:                #if return_last_response is set on True and result is not None (No exceptions occurred) the last result is got from the database.
						try:
							result = list(cursor.fetchall())
						except mariadb.Error as e:                  #exception occurs but is not a big problem because if the executed query doesn't return anything it raise an exception, so these exceptions are handled differently.
							result = []
							self._logger.record(msg="Exception while fetching records from database", logLevel= diagnostic.ERROR, module= _MODULE, code= 6, exc= e)        
			except Exception as e:                              #exception occurs
				result = None
				self._logger.record(msg="Exception occurs while sending a query to database", logLevel=diagnostic.ERROR, module=_MODULE, code=7, exc=e)        
			return result
		else:
			raise Exception("dbConn is None")
		
	def close(self) -> bool:
		try:
			if self._dbConn != None:
				self._dbConn.close()
				self._dbConn = None
		except Exception as e:
			self._logger.record(msg="Exception while closing database handler", logLevel= diagnostic.WARNING, module=_MODULE, code=2, exc=e)
			return False
		else:
			self._logger.record(msg="Database module correctly closed", logLevel=diagnostic.DEBUG, module=_MODULE, code=1)
			
		return True

if __name__ == "__main__":
	import sys
	arguments = len(sys.argv) - 1
	if arguments > 0:
		import ptvsd
		# Allow other computers to attach to ptvsd at this IP address and port.
		ptvsd.enable_attach(address=('192.168.1.160', 3777))
		# Pause the program until a remote debugger is attached	
		ptvsd.wait_for_attach()
	l = diagnostic.Diagnostic(path="./log.txt", logLevel=10)
	Parameters.init("param.json")
	dbms = DatabaseHandler(logger=l)
	res = dbms.sendQuery("select * from records", return_last_response=True)
	print(res)
	dbms.close()

