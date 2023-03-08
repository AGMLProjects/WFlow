import requests, threading, time, sys, random

running = True
valid_types = ["rubinetto", "wc", "caldaia"]

def generate_data():
    
    # Generate a random amount of time aftwe which send new data
    new_interval = random.randint(10, 60)

    # Reschedule the timer
    timer = threading.Timer(interval = new_interval, function = generate_data)

    # Choose the data type
    sensor_type = random.randint(0, len(valid_types) - 1)

    # Depending on the type, create the data packet
    sensor_id = sensor_type
    payload = dict()

    if sensor_type == 0:
        payload["temperature"] = float(random.randint(100, 1000)) / 10.0
        payload["water_volume"] = float(random.randint(100, 1000)) / 10.0
    elif sensor_type == 1:
        payload["water_volume"] = 10.0
    else:
        payload["water_volume"] = float(random.randint(1000, 100000)) / 10.0
        payload["gas_volume"] = float(random.randint(10, 50)) / 10.0

    # Send the request to server
    requests.post(url = "", data = {"sensor_"})

if __name__ == "__main__":

    # Create a timer object to throw random data
    timer = threading.Timer(interval = 10, function = generate_data)
    timer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        running = False
        sys.exit(0)