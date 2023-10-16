import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder, MinMaxScaler


def parse_response(data):
    family_members = data['user']['family_members']
    if family_members is None:
        family_members = 1
    sensor_data = data['sensor_data']
    df = pd.DataFrame(sensor_data)
    df['date'] = df['day_of_month'].astype(str) + '/' + df['month'].astype(str) + '/2023'

    columns = [
        'date',
        'month',
        'day_of_week',
        'holiday',
        'family_members',
        'temperature',
        'rain',
        'total_water_liters',
        'total_gas_volumes',
    ]
    df = df.reindex(columns=columns)

    day_of_week_mapping = {
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
    }

    df['day_of_week'] = df['day_of_week'].map(day_of_week_mapping)
    df['family_members'] = family_members
    df.set_index("date", inplace=True)

    return df


def sliding_windows(data, seq_length):
    x = []
    y = []

    for i in range(len(data) - seq_length - 1):
        _x = data[i:(i + seq_length)]
        _y = data[i + seq_length]
        x.append(_x)
        y.append(_y)

    return np.array(x), np.array(y)


def create_mock_dataframe(file):
    df = pd.read_csv(file, delimiter=';', header=0, index_col='date', parse_dates=True, dayfirst=True)

    label_encoder = LabelEncoder()
    min_max_scaler = MinMaxScaler()

    df['state'] = label_encoder.fit_transform(df['state'])
    df['region'] = label_encoder.fit_transform(df['region'])
    df['city'] = label_encoder.fit_transform(df['city'])
    df['occupation'] = label_encoder.fit_transform(df['occupation'])

    # Simplify features
    df = df.drop('year', axis=1)
    df = df.drop('age', axis=1)
    df = df.drop('state', axis=1)
    df = df.drop('region', axis=1)
    df = df.drop('city', axis=1)
    df = df.drop('occupation', axis=1)

    return df
