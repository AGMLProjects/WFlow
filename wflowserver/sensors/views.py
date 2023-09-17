from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from rest_framework.generics import GenericAPIView, ListAPIView, CreateAPIView, ListCreateAPIView, RetrieveUpdateDestroyAPIView
from rest_framework.permissions import IsAuthenticated, AllowAny

from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

from devices.permissions import DeviceAuthentication

from .models import Sensor, SensorTypeDefinition, SensorData
from .serializers import SensorSerializer, SensorTypeDefinitionSerializer, SensorDataSerializer

import json


class RegisterSensorAPIView(CreateAPIView):
    """
    This view is responsible for the registration of
    a new sensor for the currently authenticated device.
    """
    authentication_classes = (DeviceAuthentication,)
    permission_classes = (IsAuthenticated,)
    serializer_class = SensorSerializer

    # override the create method to perform create for active sensors
    def create(self, request, *args, **kwargs):
        # get active sensors
        active_sensors = request.data['active_sensors']
        # active_sensors = [json.loads(idx.replace("'", '"'))
        #                   for idx in active_sensors]
        active_ids = [element['sensor_id'] for element in active_sensors]

        # cycle through objects to elaborate sensor information piecewise
        for active_sensor in active_sensors:
            # get and validate the serializer on a single object
            # serializer = self.get_serializer(data=active_sensor)
            # serializer.is_valid(raise_exception=True)

            # if not Sensor.objects.filter(sensor_id=active_sensor['sensor_id']).exists():
            #     # generate sensor object
            #     self.perform_create(serializer)
            Sensor.objects.update_or_create(
                sensor_id=active_sensor['sensor_id'],
                device_id=self.request.user,
                sensor_type=SensorTypeDefinition(active_sensor['sensor_type']),
                defaults={'active': True})

        # update the active flag if existing sensor is not updated
        Sensor.objects.filter(device_id=self.request.user).exclude(
            sensor_id__in=active_ids).update(active=False)

        # # generate response with success headers
        # headers = self.get_success_headers(serializer.data)

        return Response(data={'message': 'sensors updated successfully'}, status=status.HTTP_201_CREATED)

    # override the perform_create method to perform the checks on request data for active sensors
    def perform_create(self, serializer):
        # NB: here it is called user by convention, it's actually the device id
        serializer.save(device_id=self.request.user)


class UploadSensorDataAPIView(CreateAPIView):
    """
    This view is responsible for the upload of new data recorded 
    from the specified sensor for the currently authenticated device
    """
    authentication_classes = (DeviceAuthentication,)
    permission_classes = (IsAuthenticated,)
    serializer_class = SensorDataSerializer

    # override the create method to perform create for active sensors
    def create(self, request, *args, **kwargs):
        # get and validate the serializer on a single object
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        self.perform_create(serializer)

        # generate response with success headers
        headers = self.get_success_headers(serializer.data)

        return Response(data={'message': 'data uploaded successfully'}, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        serializer.save()


class UploadActuatorDataAPIView(CreateAPIView):
    """
    This view is responsible for the upload of new data sent  
    from the app for the specified actuator for the currently authenticated user
    """
    permission_classes = (IsAuthenticated,)
    serializer_class = SensorDataSerializer

    # override the create method to perform create for active sensors
    def create(self, request, *args, **kwargs):
        # get and validate the serializer on a single object
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        actuator_id = request.data['sensor_id']
        message = request.data['values']

        # TODO: get device_id from actuator_id

        device_id = 1

        # if actuator_id not in ACTIVE_ACTUATORS:
        #     return Response("Actuator not found.")

        try:
            channel_layer = get_channel_layer()
            channel_name = f"device_{device_id}"

            # Channel exists, send the message
            async_to_sync(channel_layer.group_send)(
                channel_name,
                {
                    "type": "send.message",
                    "message": message,
                },
            )
        except Exception as e:
            return Response("ERROR")

        # return Response("Message sent to Raspberry Pi.")

        self.perform_create(serializer)

        # generate response with success headers
        headers = self.get_success_headers(serializer.data)

        return Response(data={'message': 'data uploaded successfully'}, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        serializer.save()


# # TODO: endpoint to get the last sensordata based on id
# class GetLastActuatorData(ListAPIView):
