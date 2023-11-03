import torch
import torch.nn as nn
from torch.autograd import Variable


class LSTM(nn.Module):

    def __init__(self, num_classes_water, num_classes_gas, input_size, hidden_size, num_layers, seq_length):
        super(LSTM, self).__init__()

        self.num_classes_water = num_classes_water
        self.num_classes_gas = num_classes_gas
        self.num_layers = num_layers
        self.input_size = input_size
        self.hidden_size = hidden_size
        self.seq_length = seq_length

        self.lstm = nn.LSTM(input_size=input_size, hidden_size=hidden_size,
                            num_layers=num_layers, batch_first=True)

        self.fc1 = nn.Linear(hidden_size, num_classes_water)
        self.fc2 = nn.Linear(hidden_size, num_classes_gas)

    def forward(self, x):
        h_0 = Variable(torch.zeros(self.num_layers, x.size(0), self.hidden_size))

        c_0 = Variable(torch.zeros(self.num_layers, x.size(0), self.hidden_size))

        # Propagate input through LSTM
        ula, (h_out, _) = self.lstm(x, (h_0, c_0))

        h_out = h_out.view(-1, self.hidden_size)

        out_water = self.fc1(h_out)
        out_gas = self.fc2(h_out)

        return out_water, out_gas
