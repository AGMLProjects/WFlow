from model.lstm import LSTM
from utils import sliding_windows
import numpy as np
import torch
from torch.autograd import Variable


def train(training_set, family_members, config):
    # Scale y in [0, 1]
    consume_max = family_members * config['consume']['avgWater']
    consume_min = 0
    training_set[:, -2:-1] = (training_set[:, -2:-1] - consume_min) / (consume_max - consume_min)
    consume_max = family_members * config['consume']['avgGas']
    consume_min = 0
    training_set[:, -1:] = (training_set[:, -1:] - consume_min) / (consume_max - consume_min)
    training_data = training_set

    seq_length = config['hyperparams']['sequence_length']
    x, y = sliding_windows(training_data, seq_length)
    x = x[:, :, :-2]
    y = y[:, -2:]

    trainX = Variable(torch.Tensor(np.array(x)))
    trainY = Variable(torch.Tensor(np.array(y)))

    # Training
    num_epochs = config['hyperparams']['epochs']
    learning_rate = config['hyperparams']['learning_rate']

    input_size = training_set.shape[1] - 2
    hidden_size = config['hyperparams']['lstm_depth']
    num_layers = 1
    num_classes_water = 1
    num_classes_gas = 1

    lstm = LSTM(num_classes_water, num_classes_gas, input_size, hidden_size, num_layers, seq_length)

    criterion_water = torch.nn.MSELoss()
    criterion_gas = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(lstm.parameters(), lr=learning_rate)

    # Train the model
    for epoch in range(num_epochs):
        outputs_water, outputs_gas = lstm(trainX)
        outputs_water = outputs_water.squeeze()
        outputs_gas = outputs_gas.squeeze()
        optimizer.zero_grad()

        loss_water = criterion_water(outputs_water, trainY[:, 0])
        loss_gas = criterion_gas(outputs_gas, trainY[:, 1])
        loss = loss_water + loss_gas

        loss.backward()

        optimizer.step()
        if epoch % 500 == 0:
            print("Epoch: %d, loss: %1.5f" % (epoch, loss.item()))

    print(f'Finished training')

    return lstm


def retrain(training_set, family_members, config):
    # Scale y in [0, 1]
    consume_max = family_members * config['consume']['avgWater']
    consume_min = 0
    training_set[:, -2:-1] = (training_set[:, -2:-1] - consume_min) / (consume_max - consume_min)
    consume_max = family_members * config['consume']['avgGas']
    consume_min = 0
    training_set[:, -1:] = (training_set[:, -1:] - consume_min) / (consume_max - consume_min)
    training_data = training_set

    x = training_data[:, :-2]
    x = Variable(torch.Tensor(np.array(x)))
    x = x.unsqueeze(1)

    y = training_data[:, -2:]
    y = Variable(torch.Tensor(np.array(y)))

    train_x = x
    train_y = y

    # Training
    num_epochs = config['hyperparams']['epochs_retraining']
    learning_rate = config['hyperparams']['learning_rate']

    input_size = training_set.shape[1] - 2
    hidden_size = config['hyperparams']['lstm_depth']
    num_layers = 1
    num_classes_water = 1
    num_classes_gas = 1

    lstm = LSTM(num_classes_water, num_classes_gas, input_size, hidden_size, num_layers, 1)

    criterion_water = torch.nn.MSELoss()
    criterion_gas = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(lstm.parameters(), lr=learning_rate)

    # Train the model
    for epoch in range(num_epochs):
        outputs_water, outputs_gas = lstm(train_x)
        optimizer.zero_grad()

        loss_water = criterion_water(outputs_water, train_y[:, 0])
        loss_gas = criterion_gas(outputs_gas, train_y[:, 1])
        loss = loss_water + loss_gas

        loss.backward()

        optimizer.step()
        if epoch % 9 == 0:
            print("Epoch: %d, loss: %1.5f" % (epoch, loss.item()))

    print(f'Finished retraining')

    return lstm
