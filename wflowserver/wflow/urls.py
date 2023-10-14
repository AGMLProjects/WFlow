"""wflow URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from wflow import views as APIviews
from rest_framework.urlpatterns import format_suffix_patterns

from users import views as users_views

from dj_rest_auth.views import PasswordResetView, PasswordResetConfirmView

urlpatterns = [
    # server management endpoint for administrator
    path('admin/', admin.site.urls),

    # AUTH endpoints with django-rest-auth
    path('users/', include('users.urls')),
    path('password-reset/', PasswordResetView.as_view()),
    path('password-reset-confirm/<uidb64>/<token>/',
         PasswordResetConfirmView.as_view(), name='password_reset_confirm'),

    # AUTH endpoints for devices
    path('devices/', include('devices.urls')),

    # Sensor management endpoints
    path('sensors/', include('sensors.urls')),

    # API endpoints
    # path('API/houses/', APIviews.ListCreateHousesAPIView.as_view()),
    path('API/houses/list', APIviews.ListHousesAPIView.as_view()),
    path('API/houses/add', APIviews.CreateHouseAPIView.as_view()),
    path('API/houses/<int:house_id>', APIviews.HousesDetailAPIView.as_view()),
    path('API/houses/specific/<int:house_id>',
         APIviews.HousesSpecificDetailAPIView.as_view()),
    path('API/control_actuators/<int:actuator_id>',
         APIviews.SendMessageToActuatorAPIView.as_view()),
    path('AI/get_house_id_list',
         APIviews.GetHouseIdListAPIView.as_view()),
    path('AI/fetch_train_data_daily',
         APIviews.FetchTrainDataDailyAPIView.as_view()),
    path('AI/fetch_train_data_consumes',
         APIviews.FetchTrainDataConsumesAPIView.as_view()),
]

urlpatterns = format_suffix_patterns(urlpatterns)
