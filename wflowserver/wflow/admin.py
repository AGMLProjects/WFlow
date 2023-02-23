from django.contrib import admin
from .models import House


class HouseAdmin(admin.ModelAdmin):
    list_display = ('house_id', 'user_id', 'name', 'address',
                    'total_liters', 'total_gas', 'future_total_liters', 'future_total_gas',
                    'city', 'house_type')


admin.site.register(House, HouseAdmin)
