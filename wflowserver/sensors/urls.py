from django.urls import path, re_path

from .views import RegisterSensorAPIView

urlpatterns = [
    # sensor management endpoints
    path('register/', RegisterSensorAPIView.as_view()),
]
