from rest_framework import serializers
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.hashers import (
    check_password,
    is_password_usable,
    make_password,
)
from rest_framework.exceptions import ValidationError

from .models import Device, Token
from wflow.models import House


class DeviceSerializer(serializers.ModelSerializer):

    class Meta:
        model = Device
        read_only_fields = ('user_id', )
        fields = ('device_id', 'user_id', 'house_id', 'name')


_api_key = "FLzdTj@22EV74gflnyN6^9qKD$37AOL4kQD3&dm^@61Qb1p96z"


class DeviceRegisterSerializer(serializers.ModelSerializer):
    device_id = serializers.IntegerField()
    house_id = serializers.IntegerField()

    name = serializers.CharField(max_length=200)

    def get_cleaned_data(self):
        return {
            'device_id': self.validated_data.get('device_id', ''),
            'house_id': self.validated_data.get('house_id', ''),
            'name': self.validated_data.get('name', ''),
        }

    def save(self, request):
        # create new device instance
        device = Device()
        self.cleaned_data = self.get_cleaned_data()
        device.device_id = self.cleaned_data.get('device_id')
        device.user_id = request.user
        device.house_id = House.objects.get(
            house_id=self.cleaned_data.get('house_id'))
        # STATICALLY PUT ---------------------------------
        device.set_password(_api_key)
        # ------------------------------------------------
        device.name = self.cleaned_data.get('name')
        device.save()

        return device

    class Meta:
        model = Device
        fields = ('device_id', 'house_id', 'name')


class DeviceLoginSerializer(serializers.ModelSerializer):
    device_id = serializers.IntegerField()
    password = serializers.CharField(style={'input_type': 'password'})

    # auth function which compares the hashes
    def authenticate(self, device_id, password):
        device = Device.objects.get(device_id=device_id)

        if device.check_password(password):
            return device
        else:
            return None

    def validate(self, attrs):
        device_id = attrs.get('device_id')
        password = attrs.get('password')

        # check if the device exists
        try:
            device = Device.objects.get(device_id=device_id)
        except Device.DoesNotExist:
            msg = _('Device does not exists.')
            raise ValidationError(msg)

        if device_id and password:
            device = self.authenticate(device_id, password)
        else:
            msg = _('Must include "device_id" and "password".')
            raise ValidationError(msg)

        if not device:
            msg = _('Unable to log in with provided credentials.')
            raise ValidationError(msg)

        attrs['device'] = device
        return attrs

    class Meta:
        model = Device
        fields = ('device_id', 'password')


class TokenSerializer(serializers.ModelSerializer):
    """
    Serializer for Device Token model.
    """

    class Meta:
        model = Token
        fields = ('key', 'device')
