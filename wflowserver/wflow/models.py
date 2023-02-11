from django.db import models
from users.models import CustomUser


class House(models.Model):
    house_id = models.BigAutoField(primary_key=True)
    user_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE)

    name = models.CharField(max_length=200)
    total_expenses = models.FloatField()
    address = models.CharField(max_length=200)
    city = models.CharField(max_length=200)

    def __str__(self):
        return "House:%s of User:%s" % (self.house_id, self.user_id)
