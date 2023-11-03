import requests
import sys
import random
import datetime

running = True
valid_types = ["Flow Sensor", "Water Level", "Water Heater"]

SECRET = "FLzdTj@22EV74gflnyN6^9qKD$37AOL4kQD3&dm^@61Qb1p96z"
API_KEY = None
SENSOR_ID_LIST = [10, 20, 30]
DEVICE_ID = 2

SERVER_URL = "https://wflow.online/"
SENSORT_REGISTER = "sensors/register/"
SENSORT_DATA_UPLOAD = "sensors/upload/"


def generate_data():
    # Define the start and end dates
    start_date = datetime.date(2023, 9, 1)
    end_date = datetime.date(2023, 10, 25)

    current_date = start_date
    while current_date <= end_date:
        for sensor_type in range(len(SENSOR_ID_LIST)):
            # Choose the data type
            sensor_id = SENSOR_ID_LIST[sensor_type]
            payload = dict()

            # Define time intervals for each sensor type
            if sensor_type == 0:
                # Define time intervals for sensor_type 0
                # 8-9 AM, 12-2 PM, 6-8 PM
                time_intervals = [(8, 9), (12, 14), (18, 20)]
            elif sensor_type == 1:
                # Define time intervals for sensor_type 1
                # 10-11 AM, 3-4 PM, 7-8 PM
                time_intervals = [(10, 11), (15, 16), (19, 20)]
            else:
                # Define time intervals for other sensor types
                # 9-10 AM, 1-3 PM, 5-7 PM
                time_intervals = [(9, 10), (13, 15), (17, 19)]

            for interval in time_intervals:
                # Generate random data
                if sensor_type == 0:
                    start_hour = random.randint(interval[0], interval[1])
                    start_minute = random.randint(0, 59)
                    duration = random.randint(5, 30)
                    multiplier = random.randint(800, 1200) / 100
                    start_time = datetime.datetime.combine(
                        current_date, datetime.time(start_hour, start_minute, 0))
                    end_time = start_time + \
                        datetime.timedelta(minutes=duration)

                    payload["temperature"] = round((float(
                        random.randint(100, 400)) / 10.0), 2)
                    payload["water_liters"] = round(
                        float(multiplier * duration), 2)
                elif sensor_type == 1:
                    start_hour = random.randint(interval[0], interval[1])
                    start_minute = random.randint(0, 59)
                    start_time = datetime.datetime.combine(
                        current_date, datetime.time(start_hour, start_minute, 0))
                    end_time = start_time
                    payload["water_liters"] = 30.0
                else:
                    start_hour = random.randint(interval[0], interval[1])
                    start_minute = random.randint(0, 59)
                    duration = random.randint(10, 120)
                    water_multiplier = random.randint(600, 1200) / 100
                    gas_multiplier = water_multiplier / 1000
                    gas_multiplier *= (random.randint(9, 11) / 10)
                    start_time = datetime.datetime.combine(
                        current_date, datetime.time(start_hour, start_minute, 0))
                    end_time = start_time + \
                        datetime.timedelta(minutes=duration)

                    payload["water_liters"] = round(float(
                        duration * water_multiplier), 2)
                    payload["gas_volume"] = round(
                        float(duration * gas_multiplier), 2)

                # Send the request to the server
                body = {
                    "sensor_id": sensor_id,
                    "start_timestamp": start_time.strftime("%Y-%m-%d %H:%M:%S"),
                    "end_timestamp": end_time.strftime("%Y-%m-%d %H:%M:%S"),
                    "values": payload
                }

                header = {
                    "Authorization": "Token " + API_KEY,
                }

                try:
                    req = requests.post(
                        url=SERVER_URL + SENSORT_DATA_UPLOAD, json=body, headers=header)
                except Exception as e:
                    print("Error: ", e)
                    sys.exit(1)

                if req.status_code == 201:
                    print("Data upload successful for sensor " + str(sensor_id))
                else:
                    print("Data upload failed with status code " +
                          str(req.status_code))

        # Move to the next day
        current_date += datetime.timedelta(days=1)


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
        resp = requests.post(
            url=SERVER_URL + SENSORT_REGISTER, json=body, headers=header)
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
        resp = requests.post(url=SERVER_URL + "devices/login/", data=body)
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

    try:
        generate_data()
    except KeyboardInterrupt:
        print("Exiting... Waiting for the last record to be sent, it might take up to one minute")
        running = False
        sys.exit(0)
