from django.contrib import admin
from .models import Device, Token


class DeviceAdmin(admin.ModelAdmin):
    list_display = ('device_id', 'user_id', 'house_id', 'password', 'name')


class TokenAdmin(admin.ModelAdmin):
    list_display = ('key', 'device', 'created')


admin.site.register(Device, DeviceAdmin)
admin.site.register(Token, TokenAdmin)
