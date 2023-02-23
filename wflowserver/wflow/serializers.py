from rest_framework import serializers
from .models import House


class HouseSerializer(serializers.ModelSerializer):

    class Meta:
        model = House
        read_only_fields = ('house_id', 'user_id')
        fields = ('house_id', 'user_id', 'name',
                  'total_liters', 'total_gas', 'future_total_liters', 'future_total_gas',
                  'address', 'city', 'house_type')
