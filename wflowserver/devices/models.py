import binascii
import os
from django.utils.translation import gettext_lazy as _
from django.db import models

from django.contrib.auth.hashers import (
    check_password,
    make_password,
)

from users.models import CustomUser
from wflow.models import House


class Device(models.Model):
    # from QR code
    device_id = models.IntegerField(primary_key=True)
    user_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    house_id = models.ForeignKey(House, on_delete=models.CASCADE)

    # password generated statically (API KEY)
    password = models.CharField(_("password"), max_length=128)

    name = models.CharField(max_length=200)

    @property
    def is_authenticated(self):
        """
        Always return True. This is a way to tell if the device has been
        authenticated in templates.
        """
        return True

    def set_password(self, raw_password):
        self.password = make_password(raw_password)

    def check_password(self, raw_password):
        """
        Return a boolean of whether the raw_password was correct. Handles
        hashing formats behind the scenes.
        """

        def setter(raw_password):
            self.set_password(raw_password)
            self.save(update_fields=["password"])

        return check_password(raw_password, self.password, setter)

    def __str__(self):
        return "Device:%s of User:%s assigned to House:%s" % (self.device_id, self.user_id, self.house_id)


class Token(models.Model):
    """
    The device authorization token model.
    """
    key = models.CharField(_("Key"), max_length=40, primary_key=True)
    device = models.OneToOneField(
        Device, related_name='device_token',
        on_delete=models.CASCADE, verbose_name=_("Device")
    )
    created = models.DateTimeField(_("Created"), auto_now_add=True)

    class Meta:
        verbose_name = _("Token")
        verbose_name_plural = _("Tokens")

    def save(self, *args, **kwargs):
        if not self.key:
            self.key = self.generate_key()
        return super().save(*args, **kwargs)

    @classmethod
    def generate_key(cls):
        return binascii.hexlify(os.urandom(20)).decode()

    def __str__(self):
        return self.key
