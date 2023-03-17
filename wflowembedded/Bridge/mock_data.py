import requests, threading, time, sys, random, datetime

running = True
valid_types = ["Flow Sensor", "Water Level", "Water Heater"]

SECRET = "FLzdTj@22EV74gflnyN6^9qKD$37AOL4kQD3&dm^@61Qb1p96z"
API_KEY = None
SENSOR_ID_LIST = [111111111, 222222222, 333333333]
DEVICE_ID = 1

SERVER_URL = "https://wflow.online/"
SENSORT_REGISTER = "sensors/register/"
SENSORT_DATA_UPLOAD = "sensors/upload/"

def generate_data():
    
    # Generate a random amount of time aftwe which send new data (1 min - 10 min)
    new_interval = random.randint(10, 60)

    # Reschedule the timer
    timer = threading.Timer(interval = new_interval, function = generate_data)

    # Choose the data type
    sensor_type = random.randint(0, len(valid_types) - 1)

    # Depending on the type, create the data packet
    sensor_id = SENSOR_ID_LIST[sensor_type]
    payload = dict()
    start_timestamp = int(time.time()) - 10 * 60   # Tempo di inizio 10 minuti nel passato rispetto ad adesso
    end_timestamp = 0

    if sensor_type == 0:
        payload["temperature"] = float(random.randint(100, 1000)) / 10.0
        payload["water_liters"] = float(random.randint(100, 1000)) / 10.0
        end_timestamp = start_timestamp + (random.randint(1, 9) * 60)
    elif sensor_type == 1:
        payload["water_liters"] = 10.0
        end_timestamp = start_timestamp
    else:
        payload["water_liters"] = float(random.randint(1000, 100000)) / 10.0
        payload["gas_volume"] = float(random.randint(10, 50)) / 10.0
        end_timestamp = int(time.time())

    # Send the request to server
    body = {
        "sensor_id": sensor_id,
        "start_timestamp": datetime.datetime.fromtimestamp(start_timestamp).strftime("%Y-%m-%d %H:%M:%S"),
        "end_timestamp": datetime.datetime.fromtimestamp(end_timestamp).strftime("%Y-%m-%d %H:%M:%S"),
        "values": payload
    }

    header = {
        "Authorization": "Token " + API_KEY,
    }

    try:
        req = requests.post(url = SERVER_URL + SENSORT_DATA_UPLOAD, json = body, headers = header)
    except Exception as e:
        print("Error: ", e)
        sys.exit(1)
    
    if req.status_code == 201:
        print("Data upload successful for sensor " + str(sensor_id))
    else:
        print("Data upload failed with status code " + str(req.status_code))

    if running is True:
        timer.start()

def sensor_register() -> bool:
    body = {
        "active_sensors": [
            {
                "sensor_id": SENSOR_ID_LIST[0],
                "sensor_type": "FLO"
            },
            {
                "sensor_id": SENSOR_ID_LIST[1],
                "sensor_type": "LEV"
            },
            {
                "sensor_id": SENSOR_ID_LIST[2],
                "sensor_type": "HEA"
            }
        ]
    }

    header = {
        "Authorization": "Token " + API_KEY,
    }

    try:
        resp = requests.post(url = SERVER_URL + SENSORT_REGISTER, json = body, headers = header)
    except Exception as e:
        print("Error: ", e)
    
    if resp.status_code == 201:
        print("Sensor registration successful")
        return True
    else:
        print("Sensor registration failed with status code " + str(resp.status_code))
        return False

def device_login():
    global API_KEY
    
    body = {
        "device_id": DEVICE_ID,
        "password": SECRET
    }

    try:
        resp = requests.post(url = SERVER_URL + "devices/login/", data = body)
    except Exception as e:
        print("Error: ", e)
        return False
    
    if resp.status_code == 200:
        print("Device login successful")
        API_KEY = resp.json()["key"]
        return True
    else:
        print("Device login failed with status code " + str(resp.status_code))
        return False

if __name__ == "__main__":

    # Login the device
    if device_login() == False:
        sys.exit(1)

    # Register the sensors
    if sensor_register() == False:
        sys.exit(1)

    # Create a timer object to throw random data
    timer = threading.Timer(interval = 10, function = generate_data)
    timer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Exiting... Waiting for the last record to be sent, it might take up to one minute")
        running = False
        sys.exit(0)