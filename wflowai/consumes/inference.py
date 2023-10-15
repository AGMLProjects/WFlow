import datetime
from torch.autograd import Variable
import numpy as np
import torch


def create_inference_data(family_members):
    inference_data = []
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
    for x in range(1, 6):
        day = today + datetime.timedelta(days=x)
        date = day.strftime('%m/%d/%Y')
        day_of_week = day.strftime("%A")
        day_of_week = day_of_week_mapping[day_of_week]
        holiday = 0
        if day_of_week >= 6:
            holiday = 1
        month = day.month
        # TODO: get those
        temperature = 24
        rain = 0

        inference_data.append([month, day_of_week, holiday, family_members, temperature, rain])

    inference_data = np.array(inference_data)
    inference_data = Variable(torch.Tensor(np.array(inference_data)))
    inference_data = inference_data.unsqueeze(1)
    return inference_data
