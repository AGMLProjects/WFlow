from rest_framework import serializers
from .models import Sensor, SensorTypeDefinition, SensorData


class SensorSerializer(serializers.ModelSerializer):

    class Meta:
        model = Sensor
        read_only_fields = ('device_id', 'active')
        fields = ('sensor_id', 'sensor_type')


class SensorTypeDefinitionSerializer(serializers.ModelSerializer):

    class Meta:
        model = SensorTypeDefinition
        read_only_fields = ('sensor_type', 'values')


class SensorDataSerializer(serializers.ModelSerializer):

    class Meta:
        model = SensorData
        read_only_fields = ('data_id',)
        fields = ('sensor_id', 'start_timestamp', 'end_timestamp', 'values')
