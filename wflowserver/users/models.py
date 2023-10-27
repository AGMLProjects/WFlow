from django.db import models
from django.contrib.auth.models import AbstractUser

from django.utils.translation import gettext_lazy as _

from datetime import date

OCCUPATION_CHOICES = [
    ('EMP', 'Employee'),
    ('UNE', 'Unemployed'),
    ('STU', 'Student'),
    ('RET', 'Retired'),
    ('ENT', 'Entepreneur'),
    ('FRE', 'Freelancer'),
]

STATUS_CHOICES = [
    ('SIN', 'Single'),
    ('REL', 'In a relationship'),
    ('ENG', 'Engaged'),
    ('MAR', 'Married'),
]

# TODO: add personal_data flag to users


class CustomUser(AbstractUser):
    # basic fields are already included: username, password, first_name, last_name, email
    # override to add nullable
    first_name = models.CharField(
        _("first name"), max_length=150, default=None, blank=True, null=True)
    last_name = models.CharField(
        _("last name"), max_length=150, default=None, blank=True, null=True)

    # custom fields
    age = models.PositiveIntegerField(default=None, blank=True, null=True)
    occupation = models.CharField(
        choices=OCCUPATION_CHOICES, max_length=3, default=None, blank=True, null=True)
    date_of_birth = models.DateField(default=None, blank=True, null=True)
    city = models.CharField(max_length=50, default=None, blank=True, null=True)
    region = models.CharField(
        max_length=50, default=None, blank=True, null=True)
    country = models.CharField(
        max_length=50, default=None, blank=True, null=True)
    status = models.CharField(
        choices=STATUS_CHOICES, max_length=3, default=None, blank=True, null=True)
    family_members = models.IntegerField(default=None, blank=True, null=True)

    personal_data = models.BooleanField(default=False)

    def __str__(self):
        return "%d" % (self.id)
