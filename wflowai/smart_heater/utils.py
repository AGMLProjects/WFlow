import datetime

import numpy as np
import torch

HOURS = [i for i in range(24)]
MINUTES = [0, 10, 20, 30, 40, 50]


# Create sliding window dataset for training the LSTM
def create_sliding_window_dataset(X, y, window_size):
    X_sequences, y_sequences = [], []
    for i in range(len(X) - window_size):
        X_sequences.append(X[i:i + window_size])
        y_sequences.append(y[i + window_size])
    return torch.stack(X_sequences), torch.stack(y_sequences)


def sliding_windows(data, seq_length):
    x = []
    y = []

    for i in range(len(data) - seq_length - 1):
        _x = data[i:(i + seq_length)]
        _y = data[i + seq_length]
        x.append(_x)
        y.append(_y)

    return np.array(x), np.array(y)


def rmse(actual, pred):
    actual, pred = np.array(actual), np.array(pred)
    return np.sqrt(np.square(np.subtract(actual, pred)).mean())


def create_inference_data(family_members):
    X = []
    day_of_week_mapping = {
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
    }
    today = datetime.datetime.today()
    date = today + datetime.timedelta(days=1)
    day_of_week = date.strftime("%A")
    day_of_week = day_of_week_mapping[day_of_week]
    holiday = 0
    if day_of_week >= 6:
        holiday = 1
    day = date.day
    month = date.month
    # TODO: get those
    temperature = 24
    rain = 0

    for HOUR in HOURS:
        for MINUTE in MINUTES:
            start_hour = HOUR
            start_minute = MINUTE
            end_hour = start_hour
            end_minute = start_minute + 10
            if end_minute == 60:
                end_hour = start_hour + 1
                end_minute = 0

            x = torch.tensor(data=[month, day, start_hour, start_minute, end_hour, end_minute, day_of_week, holiday,
                                   temperature, rain, 0, 1])
            X.append(x)
    X = torch.stack(X)
    X = X.float()
    X, _ = create_sliding_window_dataset(X, X, 3)
    return X