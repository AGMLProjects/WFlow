from django.urls import path, re_path

from .views import RegisterSensorAPIView, UploadSensorDataAPIView

urlpatterns = [
    # sensor management endpoints
    path('register/', RegisterSensorAPIView.as_view()),
    path('upload/', UploadSensorDataAPIView.as_view()),
]
