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


class SensorDataDetailedSerializer(serializers.ModelSerializer):
    day_of_week = serializers.SerializerMethodField()
    day_of_month = serializers.SerializerMethodField()
    month = serializers.SerializerMethodField()
    holiday = serializers.SerializerMethodField()

    class Meta:
        model = SensorData
        read_only_fields = ('data_id',)
        fields = ('sensor_id', 'start_timestamp', 'end_timestamp',
                  'values', 'day_of_week', 'day_of_month', 'month', 'holiday')

    def get_day_of_week(self, obj):
        # Calculate the name of the day of the week
        return obj.start_timestamp.strftime('%A')

    def get_day_of_month(self, obj):
        # Calculate the day of the month
        return obj.start_timestamp.day

    def get_month(self, obj):
        # Calculate the month
        return obj.start_timestamp.month

    def get_holiday(self, obj):
        # Determine if the day is a Saturday or Sunday
        return obj.start_timestamp.weekday() in [5, 6]  # Saturday or Sunday
