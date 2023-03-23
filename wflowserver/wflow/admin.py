from django.contrib import admin
from .models import House


class HouseAdmin(admin.ModelAdmin):
    list_display = ('house_id', 'user_id', 'name', 'address',
                    'city', 'house_type')


admin.site.register(House, HouseAdmin)
