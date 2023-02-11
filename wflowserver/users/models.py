from django.db import models
from django.contrib.auth.models import AbstractUser

from datetime import date


class CustomUser(AbstractUser):
    # basic fields are already included: username, password, first_name, last_name, email

    # custom fields
    age = models.PositiveIntegerField(default=18)
    occupation = models.CharField(max_length=50, default="Unemployed")
    date_of_birth = models.DateField(default=date.today)
    city = models.CharField(max_length=20, default="Modena")

    def __str__(self):
        return "%d" % (self.id)
