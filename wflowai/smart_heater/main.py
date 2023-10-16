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
            row["temperature"] = float(entry["weather"]["temperature"])
            row["rain"] = int(bool(entry["weather"]["rain"]))

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
            random_values_liters = np.random.normal(liters / duration, 1, int(duration))
            random_values_gas = np.random.normal(gas_volume / duration, 0.2, int(duration))

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

        df["water_liters"] = df["water_liters"] / (750 * family_members)
        df["gas_volume"] = df["gas_volume"] / (10 * family_members)

        intervals_in_df = (df['start_hour'].astype(str) + ':' + df['start_minute'].astype(str)).tolist()

        # TODO: Riempire il training set con valori mancanti (intervalli di 10 min con dati a 0 se non già presenti)
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
                else:
                    print('interval already in df')

                df_index += 1

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
        X, y = utils.create_sliding_window_dataset(X, y, 10)

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
            loss_water = criterion_water(outputs_water, y[:, 0])
            loss_gas = criterion_gas(outputs_gas, y[:, 1])
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
