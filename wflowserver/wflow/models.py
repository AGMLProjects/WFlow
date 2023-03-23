from django.db import models
from users.models import CustomUser

HOUSE_TYPE_CHOICES = [
    ('SFH', 'Single-Family House'),
    ('SDH', 'Semi-Detached House'),
    ('MFH', 'Multifamily House'),
    ('APA', 'Apartment'),
    ('CON', 'Condominium'),
    ('COP', 'Co-Op'),
    ('TIN', 'Tiny House'),
    ('MAN', 'Manufactured House'),
]


class House(models.Model):
    house_id = models.BigAutoField(primary_key=True)
    user_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE)

    name = models.CharField(max_length=200)

    address = models.CharField(max_length=200)
    city = models.CharField(max_length=200)
    house_type = models.CharField(
        choices=HOUSE_TYPE_CHOICES, max_length=3)

    def __str__(self):
        return "House:%s of User:%s" % (self.house_id, self.user_id)
