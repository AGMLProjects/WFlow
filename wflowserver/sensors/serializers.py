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


class PredictedSensorDataSerializer(serializers.ModelSerializer):

    class Meta:
        model = SensorData
        read_only_fields = ('data_id',)
        fields = ('sensor_id', 'start_timestamp', 'end_timestamp', 'values')


class SensorDataDailySerializer(serializers.ModelSerializer):
    day_of_week = serializers.SerializerMethodField()
    day_of_month = serializers.SerializerMethodField()
    month = serializers.SerializerMethodField()
    holiday = serializers.SerializerMethodField()
    weather = serializers.SerializerMethodField()

    class Meta:
        model = SensorData
        read_only_fields = ('data_id',)
        fields = ('sensor_id', 'start_timestamp', 'end_timestamp',
                  'values', 'day_of_week', 'day_of_month', 'month', 'holiday', 'weather')

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

    def get_weather(self, obj):
        # TODO: weather call api
        weather = {'temperature': 80, 'rain': False}
        return weather


class SensorDataConsumesSerializer(serializers.Serializer):
    day_of_week = serializers.SerializerMethodField()
    day_of_month = serializers.SerializerMethodField()
    month = serializers.SerializerMethodField()
    holiday = serializers.SerializerMethodField()
    total_water_liters = serializers.IntegerField()
    total_gas_volumes = serializers.IntegerField()
    weather = serializers.SerializerMethodField()

    def get_day_of_week(self, obj):
        # Calculate the name of the day of the week
        return obj['date'].strftime('%A')

    def get_day_of_month(self, obj):
        # Calculate the day of the month
        return obj['date'].day

    def get_month(self, obj):
        # Calculate the month
        return obj['date'].month

    def get_holiday(self, obj):
        # Determine if the day is a Saturday or Sunday
        return obj['date'].weekday() in [5, 6]

    def get_weather(self, obj):
        # TODO: weather call api
        weather = {'temperature': 80, 'rain': False}
        return weather
