from django.contrib import admin
from .models import House, PredictedConsumes


class HouseAdmin(admin.ModelAdmin):
    list_display = ('house_id', 'user_id', 'name', 'address',
                    'city', 'region', 'country', 'house_type')


class PredictedConsumesAdmin(admin.ModelAdmin):
    list_display = ('id', 'house_id', 'date',
                    'predicted_liters', 'predicted_volumes')


admin.site.register(House, HouseAdmin)
admin.site.register(PredictedConsumes, PredictedConsumesAdmin)
