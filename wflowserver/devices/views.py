from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from rest_framework.generics import GenericAPIView, CreateAPIView
from rest_framework.permissions import IsAuthenticated, AllowAny

from .models import Device, Token
from wflow.models import House
from .serializers import TokenSerializer, DeviceLoginSerializer, DeviceRegisterSerializer


class RegisterDeviceAPIView(CreateAPIView):
    """
    This view is responsible for the registration of
    a new device for the currently authenticated user.
    """
    permission_classes = (IsAuthenticated,)
    serializer_class = DeviceRegisterSerializer

    def create(self, request, *args, **kwargs):
        # generate serializer and valid the request data
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # generate device object from perform_create
        device = self.perform_create(serializer)

        # generate response with success headers
        headers = self.get_success_headers(serializer.data)

        # # add token to response, in this case omitted
        # data = TokenSerializer(user.auth_token, context=self.get_serializer_context()).data

        return Response(data={'message': 'device created successfully'}, status=status.HTTP_201_CREATED, headers=headers)

    # override create to generate token and specify the user id manually
    def perform_create(self, serializer):
        device = serializer.save(self.request)

        # create token
        token, _ = Token.objects.get_or_create(device=device)

        # # perform login of the device, in this case omitted because we want to only generate the token
        # complete_signup(
        #     self.request._request, user,
        #     allauth_settings.EMAIL_VERIFICATION,
        #     None,
        # )

        return device

    # override the post method to perform the checks on request data
    def post(self, request, *args, **kwargs):
        # check house ownership
        if House.objects.get(house_id=request.data['house_id']).user_id != request.user:
            return Response(data={'message': 'the user currently logged in is not the owner of the house'}, status=status.HTTP_403_FORBIDDEN)

        # THIS VIEW NEEDS TO GENERATE THE TOKEN OF THE DEVICE WHICH WILL BE SENT ON DEVICE LOGIN

        return self.create(request, *args, **kwargs)


class LoginDeviceAPIView(GenericAPIView):
    """
    This view is responsible for the login of a device
    performed by the bridge itself.

    Accept the following POST parameters: device_id, password (SAME FOR EVERY DEVICE _api_key) 
    Return the Device Token Object's key.
    """
    permission_classes = (AllowAny,)
    serializer_class = DeviceLoginSerializer

    def post(self, request, *args, **kwargs):
        # generate serializer and valid the request data
        serializer = self.get_serializer(data=self.request.data)
        serializer.is_valid(raise_exception=True)

        # perform login
        device = serializer.validated_data['device']

        # get token
        token, _ = Token.objects.get_or_create(device=device)

        # generate and return response
        serializer_class = TokenSerializer
        if token:
            serializer = serializer_class(
                instance=token,
                context=self.get_serializer_context(),
            )
        else:
            return Response(status=status.HTTP_204_NO_CONTENT)

        return Response(serializer.data, status=status.HTTP_200_OK)
