from rest_framework import serializers
from .models import House, PredictedConsumes


class HouseSerializer(serializers.ModelSerializer):

    class Meta:
        model = House
        read_only_fields = ('house_id', 'user_id')
        fields = ('house_id', 'user_id', 'name',
                  'address', 'city', 'house_type')


class HouseIdSerializer(serializers.ModelSerializer):
    class Meta:
        model = House
        fields = ('house_id',)


class PredictedConsumesSerializer(serializers.ModelSerializer):

    class Meta:
        model = PredictedConsumes
        read_only_fields = ('id',)
        fields = ('house_id', 'date', 'predicted_liters', 'predicted_volumes')
