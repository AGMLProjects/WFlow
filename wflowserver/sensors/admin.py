from django.contrib import admin
from .models import Sensor, SensorData, SensorTypeDefinition


class SensorAdmin(admin.ModelAdmin):
    list_display = ('device_id', 'active', 'sensor_id', 'sensor_type')


class SensorDataAdmin(admin.ModelAdmin):
    list_display = ('sensor_type', 'values')


class SensorTypeDefinitionAdmin(admin.ModelAdmin):
    list_display = ('data_id', 'sensor_id', 'start_timestamp',
                    'end_timestamp', 'values')


admin.site.register(Sensor, SensorAdmin)
admin.site.register(SensorData, SensorDataAdmin)
admin.site.register(SensorTypeDefinition, SensorTypeDefinitionAdmin)
