import pandas as pd
from datetime import datetime

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
    sensor_id = serializers.IntegerField()
    start_timestamp = serializers.DateTimeField()
    end_timestamp = serializers.DateTimeField()
    values = serializers.JSONField()
    day_of_week = serializers.SerializerMethodField()
    day_of_month = serializers.SerializerMethodField()
    month = serializers.SerializerMethodField()
    holiday = serializers.SerializerMethodField()
    weather = serializers.JSONField()

    class Meta:
        model = SensorData
        read_only_fields = ('data_id',)
        fields = ('sensor_id', 'start_timestamp', 'end_timestamp',
                  'values', 'day_of_week', 'day_of_month', 'month', 'holiday', 'weather')

    def get_day_of_week(self, obj):
        # Calculate the name of the day of the week
        return obj['start_timestamp'].strftime('%A')

    def get_day_of_month(self, obj):
        # Calculate the day of the month
        return obj['start_timestamp'].day

    def get_month(self, obj):
        # Calculate the month
        return obj['start_timestamp'].month

    def get_holiday(self, obj):
        # Determine if the day is a Saturday or Sunday
        return obj['start_timestamp'].weekday() in [5, 6]  # Saturday or Sunday

    # def get_weather(self, obj):
    #     # TODO: weather call api
    #     # Load the weather data from the CSV file into a DataFrame
    #     weather_df = pd.read_csv("weather_data.csv")

    #     # Find the closest date and time in the weather data
    #     sensor_timestamp = obj.start_timestamp  # Assuming it's a datetime object
    #     sensor_date_str = sensor_timestamp.strftime("%Y-%m-%d")
    #     sensor_time_str = sensor_timestamp.strftime("%H:%M")

    #     def calculate_date_difference(x):
    #         weather_date = datetime.strptime(x, "%Y-%m-%d")
    #         return abs((sensor_timestamp.date() - weather_date.date()).days)

    #     closest_index = weather_df['Date'].apply(
    #         calculate_date_difference).idxmin()

    #     # Extract the weather information from the closest row
    #     closest_weather = weather_df.loc[closest_index]

    #     # Create a dictionary with the expected keys
    #     weather_info = {
    #         'Temperature_2m': closest_weather['Temperature_2m'],
    #         'RelativeHumidity_2m': closest_weather['RelativeHumidity_2m'],
    #         'Windspeed_10m': closest_weather['Windspeed_10m'],
    #         'Rain': closest_weather['Rain'],
    #     }

    #     return weather_info


class SensorDataConsumesRetrieveSerializer(serializers.Serializer):
    date = serializers.DateField()
    total_water_liters = serializers.FloatField()
    total_gas_volume = serializers.FloatField()


class SensorDataConsumesSerializer(serializers.Serializer):
    day_of_week = serializers.SerializerMethodField()
    day_of_month = serializers.SerializerMethodField()
    month = serializers.SerializerMethodField()
    holiday = serializers.SerializerMethodField()
    total_water_liters = serializers.FloatField()
    total_gas_volume = serializers.FloatField()
    weather = serializers.JSONField()

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

    # def get_weather(self, obj):
    #     # TODO: weather call api
    #     # Load the weather data from the CSV file into a DataFrame
    #     weather_df = pd.read_csv("weather_data.csv")

    #     # Find the closest date and time in the weather data
    #     sensor_date = obj['date']  # Assuming it's a date object

    #     def calculate_date_difference(x):
    #         weather_date = datetime.strptime(x, "%Y-%m-%d")
    #         return abs((sensor_date - weather_date.date()).days)

    #     closest_index = weather_df['Date'].apply(
    #         calculate_date_difference).idxmin()

    #     # Extract the weather information from the closest row
    #     closest_weather = weather_df.loc[closest_index]

    #     # Create a dictionary with the expected keys
    #     weather_info = {
    #         'Temperature_2m': closest_weather['Temperature_2m'],
    #         'RelativeHumidity_2m': closest_weather['RelativeHumidity_2m'],
    #         'Windspeed_10m': closest_weather['Windspeed_10m'],
    #         'Rain': closest_weather['Rain'],
    #     }

    #     return weather_info
