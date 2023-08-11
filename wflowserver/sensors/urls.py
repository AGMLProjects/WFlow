from django.urls import path, re_path

from .views import RegisterSensorAPIView, UploadSensorDataAPIView, UploadActuatorDataAPIView

urlpatterns = [
    # sensor management endpoints
    path('register/', RegisterSensorAPIView.as_view()),
    path('upload/', UploadSensorDataAPIView.as_view()),
    path('set/', UploadActuatorDataAPIView.as_view()),
]
