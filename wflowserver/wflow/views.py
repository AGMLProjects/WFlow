from datetime import date
from calendar import monthrange

from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from django.db.models import Sum

from rest_framework.generics import ListAPIView, CreateAPIView, ListCreateAPIView, RetrieveUpdateDestroyAPIView, RetrieveAPIView
from rest_framework.permissions import IsAuthenticated, AllowAny

from .models import House
from .serializers import HouseSerializer

from devices.models import Device
from devices.serializers import DeviceSerializer
from sensors.models import Sensor, SensorData
from sensors.serializers import SensorDataSerializer, SensorSerializer


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

        response['total_liters'] = sum(
            float(item['values'].get('water_liters', 0)) for item in sensor_datas)
        response['total_gas'] = sum(
            float(item['values'].get('gas_volume', 0)) for item in sensor_datas)

        response['future_total_liters'] = -1
        response['future_total_gas'] = -1

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
        response = serializer.data

        # get all the sensor_datas from all the sensor of all the devices of house provided
        sensor_datas = SensorData.objects.filter(sensor_id__in=Sensor.objects.filter(
            device_id__in=Device.objects.filter(house_id=instance)))

        # get current year and month
        year = date.today().year
        month = date.today().month

        # filter sensor_datas by the current month
        sensor_datas = sensor_datas.filter(start_timestamp__year__gte=year,
                                           start_timestamp__month__gte=month,
                                           end_timestamp__year__lte=year,
                                           end_timestamp__month__lte=month)

        # get number of days to create the list of queries
        number_of_days = monthrange(year, month)[1]

        sensor_datas_per_day = [sensor_datas.filter(start_timestamp__day__gte=(day+1),
                                                    end_timestamp__day__lte=(day+1)) for day in range(number_of_days)]

        # serialize the data
        sensor_datas_per_day = [SensorDataSerializer(
            item, many=True).data for item in sensor_datas_per_day]

        water_liters_per_day = [sum(float(item['values'].get(
            'water_liters', 0)) for item in day) for day in sensor_datas_per_day]
        gas_volume_per_day = [sum(float(item['values'].get(
            'gas_volume', 0)) for item in day) for day in sensor_datas_per_day]

        literConsumes = []
        for day, value in enumerate(water_liters_per_day, 1):
            tmpdate = str(day)+'/'+str(month)+'/'+str(year)
            tmpdict = {'x': tmpdate, 'y': value,
                       'predicted': False if day <= date.today().day else True}
            literConsumes.append(tmpdict)

        gasConsumes = []
        for day, value in enumerate(gas_volume_per_day, 1):
            tmpdate = str(day)+'/'+str(month)+'/'+str(year)
            tmpdict = {'x': tmpdate, 'y': value,
                       'predicted': False if day <= date.today().day else True}
            gasConsumes.append(tmpdict)

        response['literConsumes'] = literConsumes
        response['gasConsumes'] = gasConsumes

        # ------------------------------- FIXME: do better
        # get all the sensor_datas from all the sensor of all the devices of house provided
        sensor_datas = SensorData.objects.filter(sensor_id__in=Sensor.objects.filter(
            device_id__in=Device.objects.filter(house_id=instance)))
        sensor_datas = SensorDataSerializer(sensor_datas, many=True).data

        response['total_liters'] = sum(
            float(item['values'].get('water_liters', 0)) for item in sensor_datas)
        response['total_gas'] = sum(
            float(item['values'].get('gas_volume', 0)) for item in sensor_datas)

        response['future_total_liters'] = -1
        response['future_total_gas'] = -1

        # ------------------------------------- device list
        devices = Device.objects.filter(house_id=instance)
        response['devices'] = DeviceSerializer(devices, many=True).data

        for index, device in enumerate(devices):
            sensors = Sensor.objects.filter(device_id=device)
            response['devices'][index]['sensors'] = SensorSerializer(
                sensors, many=True).data

        return Response(response)


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
