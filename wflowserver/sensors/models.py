from django.db import models

from devices.models import Device

SENSOR_TYPE_CHOICES = [
    ('FLO', 'Flow Sensor'),
    ('LEV', 'Water Level'),
    ('HEA', 'Water Heater'),
]


class SensorTypeDefinition(models.Model):
    sensor_type = models.CharField(
        choices=SENSOR_TYPE_CHOICES, max_length=3, primary_key=True)

    values = models.JSONField()

    def __str__(self):
        return "Sensor type:%s" % (self.sensor_type)


class Sensor(models.Model):
    # from QR code
    sensor_id = models.IntegerField(primary_key=True)

    device_id = models.ForeignKey(Device, on_delete=models.CASCADE)
    sensor_type = models.ForeignKey(
        SensorTypeDefinition, on_delete=models.CASCADE)
    active = models.BooleanField(default=False)

    def __str__(self):
        return "Sensor:%s linked to Device:%s" % (self.sensor_id, self.device_id)


class SensorData(models.Model):
    data_id = models.AutoField(primary_key=True)

    sensor_id = models.ForeignKey(Sensor, on_delete=models.CASCADE)
    start_timestamp = models.DateTimeField()
    end_timestamp = models.DateTimeField()

    values = models.JSONField()
