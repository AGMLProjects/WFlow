from django.shortcuts import render

from .models import CustomUser
from rest_framework.generics import ListCreateAPIView, RetrieveUpdateDestroyAPIView
from rest_framework.permissions import IsAuthenticated, AllowAny
from .serializers import CustomUserSerializer


class UserDetail(RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CustomUserSerializer
    lookup_field = 'id'

    queryset = CustomUser.objects.all()
