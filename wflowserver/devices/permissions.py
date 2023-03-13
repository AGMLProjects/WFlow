from rest_framework import authentication, exceptions

from .models import Device, Token


class DeviceAuthentication(authentication.TokenAuthentication):
    def authenticate(self, request):
        secret_token = request.META.get('Authorization')

        if not secret_token:
            return None

        try:
            print(secret_token)
            token_instance = Token.objects.get(key=secret_token)
            print(token_instance)
            print(token_instance.device_id)
            device = Device.objects.get(device_id=token_instance.device_id)
            print(device)
        except (Token.DoesNotExist, Device.DoesNotExist):
            raise exceptions.AuthenticationFailed('Unauthorized')

        return (device, None)
