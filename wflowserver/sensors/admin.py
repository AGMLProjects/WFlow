from django.contrib import admin
from .models import Sensor, SensorData, PredictedSensorData, SensorTypeDefinition


class SensorAdmin(admin.ModelAdmin):
    list_display = ('device_id', 'active', 'sensor_id', 'sensor_type')


class SensorTypeDefinitionAdmin(admin.ModelAdmin):
    list_display = ('sensor_type', 'values')


class SensorDataAdmin(admin.ModelAdmin):
    list_display = ('data_id', 'sensor_id', 'start_timestamp',
                    'end_timestamp', 'values')


class PredictedSensorDataAdmin(admin.ModelAdmin):
    list_display = ('data_id', 'sensor_id', 'start_timestamp',
                    'end_timestamp', 'values')


admin.site.register(Sensor, SensorAdmin)
admin.site.register(SensorData, SensorDataAdmin)
admin.site.register(PredictedSensorData, PredictedSensorDataAdmin)
admin.site.register(SensorTypeDefinition, SensorTypeDefinitionAdmin)
