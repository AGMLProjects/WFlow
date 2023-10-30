from datetime import date, timedelta, datetime
from calendar import monthrange
import pandas as pd

from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from django.db.models import Sum, F, Case, When, Value, FloatField
from django.db.models.functions import TruncDate, ExtractMonth

from rest_framework.generics import ListAPIView, CreateAPIView, ListCreateAPIView, RetrieveUpdateDestroyAPIView, RetrieveAPIView, GenericAPIView
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import mixins

from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

from .models import House, PredictedConsumes
from .serializers import HouseSerializer, HouseIdSerializer, PredictedConsumesSerializer

from users.models import CustomUser
from users.serializers import CustomUserSerializer
from devices.models import Device
from devices.serializers import DeviceSerializer
from sensors.models import Sensor, SensorData
from sensors.serializers import SensorDataSerializer, SensorSerializer, SensorDataDailySerializer, SensorDataConsumesSerializer, SensorDataConsumesRetrieveSerializer

ACTIVE_ACTUATORS = {}

# TODO: integrare nel send sensor data 
class SendMessageToActuatorAPIView(mixins.CreateModelMixin, GenericAPIView):
    """
    This view is responsible for the forwarding of messages from the app
    to the actuators by using django channels
    """
    permission_classes = (IsAuthenticated,)

    def post(self, request, *args, **kwargs):

        # qui devo assicurarmi che l'utente sia autenticato
        # poi devo prendere dalla request l'id del sensore (attuatore) e vedere se é suo
        # poi se é suo vedo se esiste un channel con quel nome (sensor_id) e se si mando la roba

        actuator_id = kwargs['actuator_id']

        if actuator_id not in ACTIVE_ACTUATORS:
            return Response("Actuator not found.")

        channel_layer = get_channel_layer()
        channel_name =  f"actuator_{actuator_id}"

        # Channel exists, send the message
        async_to_sync(channel_layer.group_send)(
            channel_name,
            {
                "type": "send.message",
                "message": "Hello, Raspberry Pi!",
            },
        )
        
        return Response("Message sent to Raspberry Pi.")




class CreateHouseAPIView(CreateAPIView):
    """
    This view is responsible for the creation of
    a new house for the currently authenticated user.
    """
    permission_classes = (IsAuthenticated,)
    serializer_class = HouseSerializer

    def perform_create(self, serializer):
        return serializer.save(user_id=self.request.user)


# TODO: update
class ListHousesAPIView(ListAPIView):
    """
    This view should return a list of all the houses
    for the currently authenticated user.
    """
    permission_classes = (IsAuthenticated,)
    serializer_class = HouseSerializer

    def get_queryset(self):
        return House.objects.filter(user_id=self.request.user)

    # override list method to add total consumes
    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)

        current_date = datetime.now().date()

        # cycle through each house
        for house in serializer.data:
            # get all the sensor_datas from all the sensor of all the devices of house provided
            
            sensor_datas_water = SensorData.objects.filter(
                sensor_id__in=Sensor.objects.filter(
                    device_id__in=Device.objects.filter(house_id=house['house_id'])
                ).exclude(sensor_type="HEA"),
                start_timestamp__date=current_date
            )
            # sensor_datas_water = SensorDataSerializer(sensor_datas_water, many=True).data

            sensor_datas_gas = SensorData.objects.filter(
                sensor_id__in=Sensor.objects.filter(
                    device_id__in=Device.objects.filter(house_id=house['house_id'])
                ),
                start_timestamp__date=current_date
            )
            # sensor_datas_gas = SensorDataSerializer(sensor_datas_gas, many=True).data

            house['total_liters'] = sum(float(item['values'].get(
                'water_liters', 0)) for item in sensor_datas_water)
            house['total_gas'] = sum(float(item['values'].get(
                'gas_volume', 0)) for item in sensor_datas_gas)

            house['future_total_liters'] = -1
            house['future_total_gas'] = -1

        return Response(serializer.data)


class ListCreateHousesAPIView(ListCreateAPIView):
    """
    This view is responsible for:
        - POST --> Creation of a new house for the currently authenticated user.
        - GET --> Return a list of all the houses for the currently authenticated user
    """
    permission_classes = (IsAuthenticated,)
    serializer_class = HouseSerializer

    def perform_create(self, serializer):
        return serializer.save(user_id=self.request.user)

    def get_queryset(self):
        return House.objects.filter(user_id=self.request.user)


class HousesDetailAPIView(RetrieveUpdateDestroyAPIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = HouseSerializer

    # field used to lookup the object
    lookup_field = "house_id"

    # access only objects created by the user
    def get_queryset(self):
        return House.objects.filter(user_id=self.request.user)

    # override retrieve to add the sum of consumes
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        response = serializer.data

        # Calculate the date 20 days ago from today
        twenty_days_ago = datetime.now() - timedelta(days=20)

        # Filter SensorData objects within the last 20 days
        sensor_datas_water = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=instance)
            ).exclude(sensor_type="HEA"),
            start_timestamp__gte=twenty_days_ago
        )
        # sensor_datas_water = SensorDataSerializer(sensor_datas_water, many=True).data

        sensor_datas_gas = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=instance)
            ),
            start_timestamp__gte=twenty_days_ago
        )
        # sensor_datas_gas = SensorDataSerializer(sensor_datas_gas, many=True).data

        response['mean_liters'] = sum(float(item.values.get('water_liters', 0)) for item in sensor_datas_water)/20
        response['mean_volume'] = sum(float(item.values.get('gas_volume', 0)) for item in sensor_datas_gas)/20
        
        predicted_consumes = PredictedConsumes.objects.filter(house_id=instance)

        response['future_mean_liters'] = sum(float(item.predicted_liters) for item in predicted_consumes)/5
        response['future_mean_volume'] = sum(float(item.predicted_volumes) for item in predicted_consumes)/5

        return Response(response)


class HousesSpecificDetailAPIView(RetrieveAPIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = HouseSerializer

    # field used to lookup the object
    lookup_field = "house_id"

    # access only objects created by the user
    def get_queryset(self):
        return House.objects.filter(user_id=self.request.user)

    # override retrieve to add the custom data
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        
        # Calculate the date 20 days ago from today
        twenty_days_ago = datetime.now() - timedelta(days=20)

        sensor_datas_water = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=instance)
            ).exclude(sensor_type="HEA"),
            start_timestamp__gte=twenty_days_ago,
        )
        sensor_datas_gas = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=instance)
            ),
            start_timestamp__gte=twenty_days_ago,
        )

        # Query to calculate total_water_liters excluding sensor_type="HEA"
        water_liters_data = sensor_datas_water.annotate(
            date=TruncDate('start_timestamp')
        ).values('date').annotate(
            total_water_liters=Sum(Case(
                When(values__water_liters__isnull=False, then=F('values__water_liters')),
                default=Value(0),
                output_field=FloatField()
            ))
        ).values('date', 'total_water_liters')

        # Query to calculate total_gas_volume including sensor_type="HEA"
        gas_volume_data = sensor_datas_gas.annotate(
            date=TruncDate('start_timestamp')
        ).values('date').annotate(
            total_gas_volume=Sum(Case(
                When(values__gas_volume__isnull=False, then=F('values__gas_volume')),
                default=Value(0),
                output_field=FloatField()
            ))
        ).values('date', 'total_gas_volume')

        # Combine the two querysets
        from itertools import groupby

        key_func = lambda x: x['date']
        aggregated_data = []
        for key, group in groupby(sorted(list(water_liters_data) + list(gas_volume_data), key=key_func), key=key_func):
            combined_entry = {'date': key}
            for item in group:
                combined_entry.update(item)
            aggregated_data.append(combined_entry)

        predicted_consumes = PredictedConsumes.objects.filter(house_id=instance)

        # Serialize the objects
        house_serializer = HouseSerializer(instance)
        aggregated_data_serializer = SensorDataConsumesRetrieveSerializer(aggregated_data, many=True)
        predicted_data_serializer = PredictedConsumesSerializer(predicted_consumes, many=True)
        
        response = {
            'house': house_serializer.data,
            'sensor_data': aggregated_data_serializer.data,
            'predicted_data': predicted_data_serializer.data,
        }

        # ------------------------------------- device list
        devices = Device.objects.filter(house_id=instance)
        response['devices'] = DeviceSerializer(devices, many=True).data

        for index, device in enumerate(devices):
            sensors = Sensor.objects.filter(device_id=device)
            print(sensors)
            response['devices'][index]['sensors'] = SensorSerializer(
                sensors, many=True).data
            
        # -------------------------------------- last events
        # Get the last 5 sensor data events for the house
        last_events = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=instance)
            )
        ).order_by('-start_timestamp')[:5]

        last_events_serializer = SensorDataSerializer(last_events, many=True)

        response['last_events'] = last_events_serializer.data

        return Response(response)
    

class GetHouseIdListAPIView(ListAPIView):
    serializer_class = HouseIdSerializer
    queryset = House.objects.all()


class GetHACIdAPIView(RetrieveAPIView):
    serializer_class = SensorSerializer
    lookup_field = "house_id"

    def get_queryset(self):
        house_id = self.kwargs['house_id']
        devices = Device.objects.filter(house_id=house_id)
        sensor_list = []

        for device in devices:
            sensor = Sensor.objects.filter(device_id=device.device_id, sensor_type='HAC')
            if sensor:
                sensor_list.extend(sensor)

        return sensor_list

    def get(self, request, *args, **kwargs):
        queryset = self.get_queryset()

        if not queryset:
            return Response({'error': 'HAC Sensor not found for this house'}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    

class FetchTrainDataDailyAPIView(RetrieveAPIView):
    def retrieve(self, request, *args, **kwargs):
        house_id = request.data.get('house_id')
        all_data = request.data.get('all_data')

        house = House.objects.filter(house_id=house_id).first()
        # Handle the case where no matching house is found
        if house is None:
            return Response({'error': 'House not found'}, status=status.HTTP_404_NOT_FOUND)
        
        user = house.user_id
        # Handle the case where no matching user is found (SHOULDNT BE POSSIBLE BUT OKAY)
        if house is None:
            return Response({'error': 'User not found... EHHHH????'}, status=status.HTTP_404_NOT_FOUND)

        # Serialize the House and CustomUser objects
        house_serializer = HouseSerializer(house)
        custom_user_serializer = CustomUserSerializer(user)

        # get all the sensor_datas from all the sensor of all the devices of house provided
        sensor_data_query = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=house_id), sensor_type='HEA'
            )
        )

        # if not all data, get only the data of yesterday
        if all_data == 'False':
            # Calculate the date for the day before the current day
            previous_day = date.today() - timedelta(days=1)

            # Filter SensorData objects for the day before
            sensor_data_query = sensor_data_query.filter(
                start_timestamp__date=previous_day,
                end_timestamp__date=previous_day,
            )

        # Serialize the objects
        house_serializer = HouseSerializer(house)
        custom_user_serializer = CustomUserSerializer(user)
        sensor_data_serializer = SensorDataDailySerializer(sensor_data_query, many=True)
        
        response = {
            'house': house_serializer.data,
            'user': custom_user_serializer.data,
            'sensor_data': sensor_data_serializer.data,
        }        

        return Response(response)


class FetchTrainDataConsumesAPIView(RetrieveAPIView):
    def retrieve(self, request, *args, **kwargs):
        house_id = request.data.get('house_id')
        all_data = request.data.get('all_data')

        house = House.objects.filter(house_id=house_id).first()
        # Handle the case where no matching house is found
        if house is None:
            return Response({'error': 'House not found'}, status=status.HTTP_404_NOT_FOUND)
        
        user = house.user_id
        # Handle the case where no matching user is found (SHOULDNT BE POSSIBLE BUT OKAY)
        if house is None:
            return Response({'error': 'User not found... EHHHH????'}, status=status.HTTP_404_NOT_FOUND)

        # Serialize the House and CustomUser objects
        house_serializer = HouseSerializer(house)
        custom_user_serializer = CustomUserSerializer(user)

        # get all the sensor_datas from all the sensor of all the devices of house provided
        sensor_data_query = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=house_id)
            )
        )

        # if not all data, get only the data of yesterday
        if all_data == 'False':
            # Calculate the date for the day before the current day
            previous_day = date.today() - timedelta(days=1)

            # Filter SensorData objects for the day before
            sensor_data_query = sensor_data_query.filter(
                start_timestamp__date=previous_day,
                end_timestamp__date=previous_day,
            )

        sensor_datas_water = sensor_data_query.filter(
            sensor_id__in=Sensor.objects.all(
            ).exclude(sensor_type="HEA"),
        )
        sensor_datas_gas = sensor_data_query

        # Query to calculate total_water_liters excluding sensor_type="HEA"
        water_liters_data = sensor_datas_water.annotate(
            date=TruncDate('start_timestamp')
        ).values('date').annotate(
            total_water_liters=Sum(Case(
                When(values__water_liters__isnull=False, then=F('values__water_liters')),
                default=Value(0),
                output_field=FloatField()
            ))
        ).values('date', 'total_water_liters')

        # Query to calculate total_gas_volume including sensor_type="HEA"
        gas_volume_data = sensor_datas_gas.annotate(
            date=TruncDate('start_timestamp')
        ).values('date').annotate(
            total_gas_volume=Sum(Case(
                When(values__gas_volume__isnull=False, then=F('values__gas_volume')),
                default=Value(0),
                output_field=FloatField()
            ))
        ).values('date', 'total_gas_volume')

        # Combine the two querysets
        from itertools import groupby

        key_func = lambda x: x['date']
        aggregated_data = []
        for key, group in groupby(sorted(list(water_liters_data) + list(gas_volume_data), key=key_func), key=key_func):
            combined_entry = {'date': key}
            for item in group:
                combined_entry.update(item)
            aggregated_data.append(combined_entry)

        # Serialize the objects
        house_serializer = HouseSerializer(house)
        custom_user_serializer = CustomUserSerializer(user)

        # Serialize the aggregated data
        aggregated_data_serializer = SensorDataConsumesSerializer(aggregated_data, many=True)
        
        response = {
            'house': house_serializer.data,
            'user': custom_user_serializer.data,
            'sensor_data': aggregated_data_serializer.data,
        }

        return Response(response)
    

class CreatePredictedConsumesAPIView(CreateAPIView):
    """
    This view is responsible for the creation of new data predictions
    for the specified house and day.
    """
    serializer_class = PredictedConsumesSerializer

    def create(self, request, *args, **kwargs):
        requestlist = request.data['list']

        house_id = requestlist[0].get('house_id')  # Assuming house_id is present in the request data

        # Delete existing PredictedData instances with the same house_id
        PredictedConsumes.objects.filter(house_id=house_id).delete()

        # Create new PredictedConsumes instances
        created_instances = []
        
        for item in requestlist:
            serializer = self.get_serializer(data=item)
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            created_instances.append(serializer.instance)

        return Response(self.get_serializer(created_instances, many=True).data, status=status.HTTP_201_CREATED)

    def perform_create(self, serializer):
        serializer.save()


class GlobalConsumesAPIView(GenericAPIView):
    def post(self, request, *args, **kwargs):
        # Get region and city from the request data
        region = request.data.get('region')
        city = request.data.get('city')
        consume_type_request = request.data.get('type')
        consume_type = ""

        if consume_type_request == "water":
            consume_type = "water_liters"
        elif consume_type_request == "gas":
            consume_type = "gas_volume"

        if not region or not city:
            return Response({"error": "Both 'region' and 'city' must be provided in the request data."}, status=400)

        # Query the database to get the global consumes data for the specified region and city
        city_house_data = House.objects.filter(city=city)
        region_house_data = House.objects.filter(region=region)
        city_sensor_data = SensorData.objects.filter(sensor_id__device_id__house_id__in=city_house_data).prefetch_related('sensor_id__device_id__house_id')
        region_sensor_data =SensorData.objects.filter(sensor_id__device_id__house_id__in=region_house_data).prefetch_related('sensor_id__device_id__house_id')

        # Initialize dictionaries to store the aggregated data
        mont_city_consume = {}
        month_region_consume = {}

        for data in city_sensor_data:
            month = data.start_timestamp.month

            # Check if 'values' JSON contains 'water_liters' and sum it
            values = data.values
            consume = values.get(consume_type, 0)

            mont_city_consume.setdefault(month, 0)
            mont_city_consume[month] += consume

        for data in region_sensor_data:
            month = data.start_timestamp.month

            # Check if 'values' JSON contains 'water_liters' and sum it
            values = data.values
            consume = values.get(consume_type, 0)

            month_region_consume.setdefault(month, 0)
            month_region_consume[month] += consume

        # Format the response data
        response_data = {
            "month_city_consume": [
                {
                    "city": city,
                    "year": data.start_timestamp.year,
                    "month": month,
                    "consume": consume
                }
                for month, consume in mont_city_consume.items()
            ],
            "month_region_consume": [
                {
                    "region": region,
                    "year": data.start_timestamp.year,
                    "month": month,
                    "consume": consume
                }
                for month, consume in month_region_consume.items()
            ]
        }

        return Response(response_data)
    

class GlobalConsumesEveryRegionAPIView(RetrieveAPIView):
    def get(self, request, *args, **kwargs):
        # Get the current month and year
        current_month = datetime.now().month
        current_year = datetime.now().year

        # Query the database to get the global consumes data for the current month and year
        sensor_data = SensorData.objects.filter(start_timestamp__month=current_month, start_timestamp__year=current_year)
        sensor_data = sensor_data.prefetch_related('sensor_id__device_id__house_id')

        # Initialize a dictionary to store aggregated data for each region
        region_consume = {}

        for data in sensor_data:
            region = data.sensor_id.device_id.house_id.region

            # Check if 'values' JSON contains 'water_liters' and sum it
            values = data.values
            water_consume = values.get('water_liters', 0)
            gas_consume = values.get('gas_volume', 0)

            region_consume.setdefault(region, [0, 0])
            region_consume[region][0] += water_consume
            region_consume[region][1] += gas_consume

        # Format the response data
        response_data = {
            "current_month": current_month,
            "current_year": current_year,
            "region_consumes": [
                {
                    "region": region,
                    "water_consume": consume[0],
                    "gas_consume": consume[1],
                }
                for region, consume in region_consume.items()
            ]
        }

        return Response(response_data)



# @api_view(['GET', 'POST'])
# def house_list(request, format=None):

#     if request.method == 'GET':
#         # get all the testobjects
#         testObjects = TestObject.objects.all()
#         # serialize them
#         serializer = TestObjectSerializer(testObjects, many=True)
#         # return json
#         return Response(serializer.data)

#     elif request.method == 'POST':
#         # deserialize the request data
#         serializer = TestObjectSerializer(data=request.data)
#         # check if data is valid format
#         if serializer.is_valid():
#             serializer.save()
#             # return json
#             return Response(serializer.data, status=status.HTTP_201_CREATED)


# @api_view(['GET', 'PUT', 'DELETE'])
# def testobject_detail(request, id, format=None):

#     try:
#         testobject = TestObject.objects.get(pk=id)
#     except TestObject.DoesNotExist:
#         return Response(status=status.HTTP_404_NOT_FOUND)

#     if request.method == 'GET':
#         serializer = TestObjectSerializer(testobject)
#         return Response(serializer.data)

#     elif request.method == 'PUT':
#         serializer = TestObjectSerializer(testobject, data=request.data)
#         if serializer.is_valid():
#             serializer.save()
#             return Response(serializer.data)
#         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#     elif request.method == 'DELETE':
#         testobject.delete()
#         return Response(status=status.HTTP_204_NO_CONTENT)
