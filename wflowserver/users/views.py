from django.shortcuts import render

from .models import CustomUser
from rest_framework.generics import ListCreateAPIView, RetrieveUpdateDestroyAPIView
from rest_framework.permissions import IsAuthenticated
from .serializers import CustomUserSerializer


class UserList(ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CustomUserSerializer

    queryset = CustomUser.objects.all()


class UserDetail(RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CustomUserSerializer
    lookup_field = 'id'

    queryset = CustomUser.objects.all()

    # def get_queryset(self):
    #     return CustomUser.objects.filter(id=self.request.user)
