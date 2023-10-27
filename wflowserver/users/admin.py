from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import CustomUser


class CustomUserAdmin(admin.ModelAdmin):
    list_display = ('id', 'username', 'first_name', 'last_name', 'email', 'password',
                    'age', 'occupation', 'date_of_birth', 'status', 'family_members', 'personal_data')


admin.site.register(CustomUser, CustomUserAdmin)
