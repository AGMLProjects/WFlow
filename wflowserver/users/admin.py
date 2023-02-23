from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import CustomUser


class CustomUserAdmin(admin.ModelAdmin):
    list_display = ('id', 'username', 'first_name', 'last_name', 'email', 'password',
                    'age', 'occupation', 'date_of_birth', 'city', 'status', 'family_members', )


admin.site.register(CustomUser, CustomUserAdmin)
