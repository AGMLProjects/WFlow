from rest_framework import serializers
from .models import House


class HouseSerializer(serializers.ModelSerializer):

    class Meta:
        model = House
        read_only_fields = ('house_id', 'user_id')
        fields = ('house_id', 'user_id', 'name',
                  'address', 'city', 'house_type')
