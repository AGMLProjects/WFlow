from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from rest_framework.generics import GenericAPIView, ListAPIView, CreateAPIView, ListCreateAPIView, RetrieveUpdateDestroyAPIView
from rest_framework.permissions import IsAuthenticated, AllowAny

from .models import Sensor, SensorTypeDefinition, SensorData
from .serializers import SensorSerializer, SensorTypeDefinitionSerializer, SensorDataSerialize


class RegisterSensorAPIView(CreateAPIView):
    """
    This view is responsible for the registration of
    a new sensor for the currently authenticated device.
    """
    permission_classes = (IsAuthenticated,)
    serializer_class = SensorSerializer

    # override the create method to perform create for active sensors
    def create(self, request, *args, **kwargs):
        # get active sensors
        actve_sensors = request.data['active_sensors']

        # generate serializer and valid the request data for multiple objects
        serializer = self.get_serializer(data=actve_sensors, many=True)
        serializer.is_valid(raise_exception=True)

        # generate device object from perform_create
        self.perform_create(serializer)

        # generate response with success headers
        headers = self.get_success_headers(serializer.data)

        return Response(data={'message': 'device created successfully'}, status=status.HTTP_201_CREATED, headers=headers)

    # override the perform_create method to perform the checks on request data for active sensors
    def perform_create(self, serializer):
        serializer.save()
