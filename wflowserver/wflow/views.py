from datetime import date, timedelta, datetime
from calendar import monthrange

from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from django.db.models import Sum, F, Case, When, Value, IntegerField
from django.db.models.functions import TruncDate

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
from sensors.serializers import SensorDataSerializer, SensorSerializer, SensorDataDailySerializer, SensorDataConsumesSerializer

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

        # cycle through each house
        for house in serializer.data:
            # get all the sensor_datas from all the sensor of all the devices of house provided
            sensor_datas = SensorData.objects.filter(sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=house['house_id'])))
            sensor_datas = SensorDataSerializer(sensor_datas, many=True).data

            house['total_liters'] = sum(float(item['values'].get(
                'water_liters', 0)) for item in sensor_datas)
            house['total_gas'] = sum(float(item['values'].get(
                'gas_volume', 0)) for item in sensor_datas)

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

        # get all the sensor_datas from all the sensor of all the devices of house provided
        sensor_datas = SensorData.objects.filter(sensor_id__in=Sensor.objects.filter(
            device_id__in=Device.objects.filter(house_id=instance)))
        sensor_datas = SensorDataSerializer(sensor_datas, many=True).data

        # Calculate the date 20 days ago from today
        twenty_days_ago = datetime.now() - timedelta(days=20)

        # Filter SensorData objects within the last 20 days
        sensor_datas = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=instance)
            ),
            start_timestamp__gte=twenty_days_ago,
        )

        response['mean_liters'] = sum(float(item.values.get('water_liters', 0)) for item in sensor_datas)/20
        response['mean_volume'] = sum(float(item.values.get('gas_volume', 0)) for item in sensor_datas)/20
        
        predicted_consumes = PredictedConsumes.objects.filter(house_id=instance)

        response['future_mean_liters'] = sum(float(item.predicted_liters) for item in predicted_consumes)/20
        response['future_mean_volume'] = sum(float(item.predicted_volumes) for item in predicted_consumes)/20

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

        # get all the sensor_datas from all the sensor of all the devices of house provided
        sensor_datas = SensorData.objects.filter(sensor_id__in=Sensor.objects.filter(
            device_id__in=Device.objects.filter(house_id=instance)))
        
        # Calculate the date 20 days ago from today
        twenty_days_ago = datetime.now() - timedelta(days=20)

        # Filter SensorData objects within the last 20 days
        sensor_datas = SensorData.objects.filter(
            sensor_id__in=Sensor.objects.filter(
                device_id__in=Device.objects.filter(house_id=instance)
            ),
            start_timestamp__gte=twenty_days_ago,
        )

        # sommare i dati
        # Group the SensorData by day and sum their values
        aggregated_data = sensor_datas.annotate(
            date=TruncDate('start_timestamp')
        ).values('date').annotate(
            total_water_liters=Sum(Case(
                When(values__water_liters__isnull=False, then=F('values__water_liters')),
                default=Value(0),
                output_field=IntegerField()
            )),
            total_gas_volumes=Sum(Case(
                When(values__gas_volumes__isnull=False, then=F('values__gas_volumes')),
                default=Value(0),
                output_field=IntegerField()
            ))
        ).values('date', 'total_water_liters', 'total_gas_volumes')

        predicted_consumes = PredictedConsumes.objects.filter(house_id=instance)

        # Serialize the objects
        house_serializer = HouseSerializer(instance)
        aggregated_data_serializer = SensorDataConsumesSerializer(aggregated_data, many=True)
        predicted_data_serializer = PredictedConsumesSerializer(predicted_consumes, many=True)
        
        response = {
            'house': house_serializer.data,
            'sensor_data': aggregated_data_serializer.data,
            'predicted_data': predicted_data_serializer.data,
        }

        return Response(response)
    

class GetHouseIdListAPIView(ListAPIView):
    serializer_class = HouseIdSerializer
    queryset = House.objects.all()
    

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

        # Serialize the objects
        house_serializer = HouseSerializer(house)
        custom_user_serializer = CustomUserSerializer(user)


        # sommare i dati
        # Group the SensorData by day and sum their values
        aggregated_data = sensor_data_query.annotate(
            date=TruncDate('start_timestamp')
        ).values('date').annotate(
            total_water_liters=Sum(Case(
                When(values__water_liters__isnull=False, then=F('values__water_liters')),
                default=Value(0),
                output_field=IntegerField()
            )),
            total_gas_volumes=Sum(Case(
                When(values__gas_volumes__isnull=False, then=F('values__gas_volumes')),
                default=Value(0),
                output_field=IntegerField()
            ))
        ).values('date', 'total_water_liters', 'total_gas_volumes')

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
    This view is responsible for the creation of
    a new data prediction for the specified house and day.
    """
    serializer_class = PredictedConsumesSerializer


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
