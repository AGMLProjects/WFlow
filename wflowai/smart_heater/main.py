import requests, datetime, copy
import torch, pandas as pd, numpy as np
import sys, yaml, utils

from model.lstm import LSTM

if __name__ == "__main__":

    MODEL_DIRECTORY = "./house_models/"
    BASE_DIR = "./"

    DAY_OF_WEEK = {
        "Monday": 0,
        "Tuesday": 1,
        "Wednesday": 2,
        "Thursday": 3,
        "Friday": 4,
        "Saturday": 5,
        "Sunday": 6
    }

    HOURS = [i for i in range(24)]
    MINUTES = [0, 10, 20, 30, 40, 50]

    # Load the model hyperparameters
    try:
        with open(BASE_DIR + "application.yaml", "r") as f:
            config = yaml.load(f, Loader = yaml.FullLoader)
    except:
        print("Error loading configuration file")
        exit(1)

    # Fix the seed for reproducibility
    np.random.seed(config["seed"])

    # Fetch the list of houses from the API
    resp = requests.get("https://wflow.online/AI/get_house_id_list")

    if resp.status_code != 200:
        print("Error fetching houses from the API")
        exit(1)

    resp = resp.json()

    # For each house, fetch the data depending on the existence of the model
    for house in resp:
        house_id = int(house["house_id"])

        # Check if the model exists
        try:
            model = torch.load(MODEL_DIRECTORY + str(house_id) + ".pt")
            print("Model for house " + str(house_id) + " found")
        except FileNotFoundError:
            print("Model for house " + str(house_id) + " not found")
            model = None

        # Fetch the data
        if model is None:
            resp = requests.get("https://wflow.online/AI/fetch_train_data_daily", json = {"house_id": house_id, "all_data": True})
        else:
            resp = requests.get("https://wflow.online/AI/fetch_train_data_daily", json = {"house_id": house_id, "all_data": False})

        # Check if the data was fetched successfully
        if resp.status_code != 200:
            print("Error fetching data for house " + str(house_id))
            continue

        # Parse the data to convert it to a dataframe
        resp = resp.json()
        parsed_data = list()

        for entry in resp["sensor_data"]:
            row = dict()
            row["day_of_week"] = entry["day_of_week"]
            row["day"] = int(entry["day_of_month"])
            row["month"] = int(entry["month"])
            row["holiday"] = int(bool(entry["holiday"]))
            row["temperature"] = float(entry["weather"]["Temperature"])
            row["rain"] = int(bool(entry["weather"]["Rain"]))

            # Import the date and time from string to DateTime
            start = datetime.datetime.strptime(entry["start_timestamp"], '%Y-%m-%dT%H:%M:%SZ')
            end = datetime.datetime.strptime(entry["end_timestamp"], '%Y-%m-%dT%H:%M:%SZ')

            # Round the start and end times to the nearest 10 minutes
            start = start + datetime.timedelta(minutes = -10 + (10 - start.minute % 10) % 10, seconds = -start.second, microseconds = -start.microsecond)
            end = end + datetime.timedelta(minutes = (10 - end.minute % 10) % 10, seconds = -end.second, microseconds = -end.microsecond)

            # Consider the duration with respect to discrete bins of 10 minutes
            duration = round(((end - start).total_seconds() / 60) / 10)

            # Get the values of liters and gas volume
            liters = float(entry["values"]["water_liters"])
            gas_volume = float(entry["values"]["gas_volume"])

            # Distribute the values among bins with the normal distribution
            random_values_liters = np.clip(np.random.normal(liters / duration, 1, int(duration)), 0, None)
            random_values_gas = np.clip(np.random.normal(gas_volume / duration, 0.2, int(duration)), 0.02, None)

            # Order the values
            random_values_liters.sort()
            random_values_gas.sort()

            # Normalize the values
            normalized_values_liters = liters * (random_values_liters / np.sum(random_values_liters))
            normalized_values_gas_volume = gas_volume * (random_values_gas / np.sum(random_values_gas))

            # Assign values to bins
            bins_values_liters = np.zeros(int(duration))
            bins_values_gas_volume = np.zeros(int(duration))

            # For each bin, create a clone row that shares all data except the times and values
            for i in range(int(duration)):
                start_bin_time = start + datetime.timedelta(minutes = 10 * i)
                end_bin_time = start + datetime.timedelta(minutes = 10 * (i + 1))

                # Get the values of liters and gas volume
                bins_values_liters[i] = normalized_values_liters[i]
                bins_values_gas_volume[i] = normalized_values_gas_volume[i]

                row["start_hour"] = int(start_bin_time.hour)
                row["start_minute"] = int(start_bin_time.minute)

                row["end_hour"] = int(end_bin_time.hour)
                row["end_minute"] = int(end_bin_time.minute)

                row["water_liters"] = bins_values_liters[i]
                row["gas_volume"] = bins_values_gas_volume[i]

                if row["water_liters"] < 0:
                    row["water_liters"] = 0

                if row["gas_volume"] < 0:
                    row["gas_volume"] = 0

                # The duration is the number of bins left
                row["duration"] = int(duration) - i

                # Add the row to the parsed data
                parsed_data.append(copy.deepcopy(row))

        if len(parsed_data) == 0:
            print("No data for house " + str(house_id))
            continue

        # Convert the parsed data to a dataframe
        df = pd.DataFrame(parsed_data)

        # Encode the day of the week
        df["day_of_week"] = df["day_of_week"].map(DAY_OF_WEEK)

        # Normalize the data of waters and gas
        try:
            family_members = int(resp["user"]["family_members"])
        except:
            family_members = 4

        df["water_liters"] = df["water_liters"] / 150
        df["gas_volume"] = df["gas_volume"] / 1

        intervals_in_df = (df['start_hour'].astype(str) + ':' + df['start_minute'].astype(str)).tolist()

        df_index = 0
        for HOUR in HOURS:
            for MINUTE in MINUTES:
                start_hour = HOUR
                start_minute = MINUTE
                end_hour = start_hour
                end_minute = start_minute + 10
                if end_minute == 60:
                    end_hour = start_hour + 1
                    end_minute = 0
                interval = f'{start_hour:02}:{start_minute:02}'

                if interval not in intervals_in_df:
                    line = pd.DataFrame(df.iloc[0:1], index=[0])
                    line['start_hour'] = start_hour
                    line['start_minute'] = start_minute
                    line['end_hour'] = end_hour
                    line['end_minute'] = end_minute
                    line['water_liters'] = 0
                    line['gas_volume'] = 0
                    line['duration'] = 0
                    df = pd.concat([df.iloc[:df_index], line, df.iloc[df_index:]]).reset_index(drop=True)

                df_index += 1

        df.set_index(['month', 'day', 'start_hour', 'start_minute', 'end_hour', 'end_minute'], inplace=True)

        df.sort_index(inplace=True)
        df.reset_index(inplace=True)

        # Convert the dataframe to a tensor splitting the data and the labels
        X = df.drop(["water_liters", "gas_volume"], axis = 1).values
        X = torch.from_numpy(X).float()
        y = df[["water_liters", "gas_volume"]].values
        y = torch.from_numpy(y).float()

        # Load the hyperparameters
        num_epochs = config["hyperparameters"]["epochs"]
        learning_rate = config["hyperparameters"]["learning_rate"]
        lstm_depth = config["hyperparameters"]["lstm_depth"]
        seq_length = config["hyperparameters"]["sequence_length"]

        # Create the sliding window dataset
        X, y = utils.create_sliding_window_dataset(X, y, seq_length)

        # Define the model topology
        input_size = X.shape[2]
        num_layers = 1
        num_classes_water = 1
        num_classes_gas = 1

        # Define the model
        if model is None:
            model = LSTM(num_classes_water, num_classes_gas, input_size, lstm_depth, num_layers, seq_length)

        criterion_water = torch.nn.MSELoss()
        criterion_gas = torch.nn.MSELoss()
        optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

        # Train the model
        for epoch in range(num_epochs):
            outputs_water, outputs_gas = model(X)
            loss_water = criterion_water(outputs_water[:, 0], y[:, 0])
            loss_gas = criterion_gas(outputs_gas[:, 0], y[:, 1])
            loss = loss_water + loss_gas
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

            if epoch % 100 == 0:
                print("Epoch: %d, loss: %1.5f" % (epoch, loss.item()))

        # Save the model
        torch.save(model, MODEL_DIRECTORY + str(house_id) + ".pth")

        # Evaluate the model
        model.eval()

        # TODO: Fare la predizione e caricare i dati sul server
        response = requests.get(f'https://wflow.online/AI/get_hac_id/{house_id}')

        if response.status_code != 200:
            print(f'Request failed with status code {response.status_code}')
            # exit(1)

        data = response.json()[0]
        sensor_id = data['sensor_id']

        inference_data = utils.create_inference_data(family_members)

        # TODO: capire perché vengono dei numeri negativi e maggiori di 1
        relu = torch.nn.ReLU()
        predicted_water, predicted_gas = model(inference_data)
        predicted_water = relu(predicted_water[:, 0])
        predicted_water = torch.min(predicted_water, torch.tensor(1.0))
        predicted_gas = relu(predicted_gas[:, 0])
        predicted_gas = torch.min(predicted_gas, torch.tensor(1.0))

        heater_activation_threshold = 0.5
        temperature_max = 45
        temperature_min = 24
        activation_consecutive_times_slot = 2

        # A list of tuples (time_slot, temperature)
        activations = []

        index = 0
        for HOUR in HOURS:
            for MINUTE in MINUTES:
                start_hour = HOUR
                start_minute = MINUTE
                end_hour = start_hour
                end_minute = start_minute + 10
                if end_minute == 60:
                    end_hour = start_hour + 1
                    end_minute = 0

                # FIXME: to fix this, we must modify the inference data in a way that the sliding window
                #  doesn't "eat" the borders
                if 5 <= index < 134:
                    predicted_water_value = predicted_water[index].item()
                    predicted_gas_value = predicted_gas[index].item()
                    # We activate the heater only if the predicted consumed water
                    # is higher than a certain threshold
                    if predicted_water_value >= heater_activation_threshold:
                        # We set the temperature based on the predicted consumed gas
                        temperature = predicted_gas_value * (temperature_max - temperature_min) + temperature_min
                        activations.append((f'{start_hour}:{start_minute}', temperature))
                    else:
                        # If no activation, we set -1 in activations list
                        activations.append((f'{start_hour}:{start_minute}', -1))
                index += 1

        activation_ranges = []
        start_time = None
        current_range = None
        temperatures = []

        for time, value in activations:
            if value > 0:
                temperatures.append(value)
                if current_range is None:
                    start_time = time
                    current_range = [(time, value)]
                else:
                    current_range.append((time, value))
            else:
                if current_range is not None:
                    end_time = time
                    temperature = sum(temperatures) / len(temperatures)
                    temperatures = []
                    activation_ranges.append((start_time, end_time, temperature))
                    current_range = None

        if current_range is not None:
            temperature = sum(temperatures) / len(temperatures)
            activation_ranges.append((start_time, "23:59", temperature))

        if len(activation_ranges) > 0:
            print(f'Sending activations: {activation_ranges}')
            today = datetime.datetime.today()
            temperature, time_start, time_end = [], [], []
            for activation in activation_ranges:
                temperature.append(activation[2])

                time_start_datetime = today
                time_start_datetime = time_start_datetime\
                    .replace(hour=datetime.datetime.strptime(activation[0], '%H:%M').hour)
                time_start_datetime = time_start_datetime\
                    .replace(minute=datetime.datetime.strptime(activation[0], '%H:%M').minute)
                time_start_datetime = time_start_datetime\
                    .replace(second=0)
                time_start.append(time_start_datetime.strftime('%Y-%m-%d %H:%M:%S'))

                time_end_datetime = today
                time_end_datetime = time_end_datetime\
                    .replace(hour=datetime.datetime.strptime(activation[1], '%H:%M').hour)
                time_end_datetime = time_end_datetime\
                    .replace(minute=datetime.datetime.strptime(activation[1], '%H:%M').minute)
                time_end_datetime = time_end_datetime\
                    .replace(second=0)
                time_end.append(time_end_datetime.strftime('%Y-%m-%d %H:%M:%S'))
            json_data = {
                'sensor_id': sensor_id,
                'start_timestamp': today.strftime("%Y-%m-%dT%H:%M:%SZ"),
                'end_timestamp': today.strftime("%Y-%m-%dT%H:%M:%SZ"),
                'values': {
                    "status": True,
                    "temperature": temperature,
                    "time_start": time_start,
                    "time_end": time_end,
                    "automatic": True
                }
            }
            response = requests.post('https://wflow.online/AI/put_daily_prediction', json=json_data)

            if response.status_code != 201:
                print(f'Request failed with status code {response.status_code}')
                exit(1)

            print('Successfully uploaded values')

        else:
            print('No activations detected, not sending anything')
