import numpy as np
import torch

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
