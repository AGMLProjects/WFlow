from rest_framework import authentication, exceptions
from django.utils.translation import gettext_lazy as _


from .models import Device, Token

import logging


class DeviceAuthentication(authentication.TokenAuthentication):
    model = Token

    def authenticate_credentials(self, key):
        model = self.get_model()
        try:
            token = model.objects.select_related('device').get(key=key)
        except model.DoesNotExist:
            raise exceptions.AuthenticationFailed(_('Invalid token.'))

        # if not token.user.is_active:
        #     raise exceptions.AuthenticationFailed(_('User inactive or deleted.'))

        return (token.device, token)
