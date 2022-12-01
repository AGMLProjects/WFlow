from rest_framework import serializers
from .models import TestObject


class TestObjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = TestObject
        fields = ['id', 'name', 'description']
