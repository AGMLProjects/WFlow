from django.shortcuts import render

from .models import CustomUser
from rest_framework.generics import ListCreateAPIView, RetrieveUpdateDestroyAPIView, RetrieveUpdateAPIView
from rest_framework.permissions import IsAuthenticated, AllowAny
from .serializers import CustomUserSerializer

from django.contrib.auth import get_user_model


# class UserDetail(RetrieveUpdateDestroyAPIView):
#     permission_classes = [IsAuthenticated]
#     serializer_class = CustomUserSerializer
#     lookup_field = 'id'

#     queryset = CustomUser.objects.all()


class UserDetailsView(RetrieveUpdateAPIView):
    """
    Reads and updates UserModel fields
    Accepts GET, PUT, PATCH methods.

    Default accepted fields: username, first_name, last_name
    Default display fields: pk, username, email, first_name, last_name
    Read-only fields: pk, email

    Returns UserModel fields.
    """
    serializer_class = CustomUserSerializer
    permission_classes = (IsAuthenticated,)

    def get_object(self):
        return self.request.user

    def get_queryset(self):
        """
        Adding this method since it is sometimes called when using
        django-rest-swagger
        """
        return get_user_model().objects.none()
