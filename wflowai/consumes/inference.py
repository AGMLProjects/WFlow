import datetime
import time

import requests
from torch.autograd import Variable
import numpy as np
import torch


def fetch_weather_data():
    temperature_list = []
    rain_list = []

    latitude = 44.64783
    longitude = 10.92539

    base_url = "https://api.open-meteo.com/v1/forecast"

    # Make the API request
    params = {
        "timezone": "Europe/Berlin",
        "latitude": latitude,
        "longitude": longitude,
        "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum"
    }

    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        data = response.json()

        temperature_max_list = data['daily']['temperature_2m_max']
        temperature_min_list = data['daily']['temperature_2m_min']
        for i in range(0, 5):
            temperature_list.append((temperature_max_list[i] + temperature_min_list[i]) / 2)

        precipitation_sum_list = data['daily']['precipitation_sum']
        for i in range(0, 5):
            if precipitation_sum_list[i] > 0.5:
                rain_list.append(1)
            else:
                rain_list.append(0)

    except requests.exceptions.RequestException as e:
        print("Request error: ", e)

    return temperature_list, rain_list


def create_inference_data(family_members):
    inference_data = []

    temperature_list, rain_list = fetch_weather_data()

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
        temperature = temperature_list[x - 1]
        rain = rain_list[x - 1]

        inference_data.append([month, day_of_week, holiday, family_members, temperature, rain])

    inference_data = np.array(inference_data)
    inference_data = Variable(torch.Tensor(np.array(inference_data)))
    inference_data = inference_data.unsqueeze(1)
    return inference_data
