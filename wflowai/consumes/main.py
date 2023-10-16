import requests
from utils import *
from train import *
from inference import *
import yaml

BASE_PATH = '/home/wflow/WFlow/wflowai/consumes'
BASE_PATH = '.'

with open(f'{BASE_PATH}/application.yaml') as file:
    config = yaml.load(file, Loader=yaml.FullLoader)

print('Config: %s' % config)

# Fixed seed
torch.manual_seed(config['seed'])

url = 'https://wflow.online/AI/get_house_id_list'

response = requests.get(url)

if response.status_code != 200:
    print(f'Request failed with status code {response.status_code}')
    exit(1)

data = response.json()
houses = [int(item['house_id']) for item in data]

for house in houses:
    print(f'Elaborating house {house}')
    print(f'Loading model {house}.pth')
    initial_train = False
    try:
        lstm = torch.load(f'{BASE_PATH}/checkpoint/{house}.pth')
    except FileNotFoundError:
        initial_train = True

    if initial_train:
        print(f'File not found, need to train from scratch')
        url = 'https://wflow.online/AI/fetch_train_data_consumes'
        json_data = {'house_id': house, 'all_data': 'True'}
        response = requests.get(url, json=json_data)

        if response.status_code != 200:
            print(f'Request failed with status code {response.status_code}')
            exit(1)

        data = response.json()
        if len(data['sensor_data']) == 0:
            print(f'Warning: no sensor data!')
        else:
            # df = parse_response(data)
            df = create_mock_dataframe(f'{BASE_PATH}/input.csv')

            # Training
            training_set = df.values
            training_set = training_set.astype('float32')

            lstm = train(training_set, config)

            torch.save(lstm, f'{BASE_PATH}/checkpoint/{house}.pth')

            inference_data = create_inference_data(int(training_set[0, 3]))

            # Inference
            lstm.eval()
            predictions_water, predictions_gas = lstm(inference_data)

            # Upload predicted values
            url = 'https://wflow.online/AI/put_consumes_prediction'
            today = datetime.datetime.today()
            for i in range(1, 6):
                day = today + datetime.timedelta(days=i)

                json_data = {
                    'house_id': house,
                    'date': day.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    'predicted_liters': float(predictions_water[i - 1, :]),
                    'predicted_volumes': float(predictions_gas[i - 1, :])
                }
                response = requests.post(url, json=json_data)

                if response.status_code != 201:
                    print(f'Request failed with status code {response.status_code}')
                    exit(1)

            print(f'Successfully uploaded predicted data for house {house}')

    else:
        print(f'Successfully loaded LSTM model')
        url = 'https://wflow.online/AI/fetch_train_data_consumes'
        json_data = {'house_id': house, 'all_data': 'False'}
        response = requests.get(url, json=json_data)

        if response.status_code != 200:
            print(f'Request failed with status code {response.status_code}')
            exit(1)

        data = response.json()
        if len(data['sensor_data']) == 0:
            print('Warning: no sensor data!')
        else:
            df = parse_response(data)

            # Re-training
            training_set = df.values
            training_set = training_set.astype('float32')

            print('Retraining model')
            lstm = retrain(training_set, config)

            torch.save(lstm, f'{BASE_PATH}/checkpoint/{house}.pth')

            inference_data = create_inference_data(family_members=int(training_set[0, 3]))

            # Inference
            lstm.eval()
            predictions_water, predictions_gas = lstm(inference_data)

            # Upload predicted values
            url = 'https://wflow.online/AI/put_consumes_prediction'
            today = datetime.datetime.today()
            for i in range(1, 6):
                day = today + datetime.timedelta(days=i)

                json_data = {
                    'house_id': house,
                    'date': day.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    'predicted_liters': float(predictions_water[i - 1, :]),
                    'predicted_volumes': float(predictions_gas[i - 1, :])
                }
                response = requests.post(url, json=json_data)

                if response.status_code != 201:
                    print(f'Request failed with status code {response.status_code}')
                    exit(1)

            print(f'Successfully uploaded predicted data for house {house}')
