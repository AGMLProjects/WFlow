from django.urls import path, re_path

from .views import RegisterDeviceAPIView, LoginDeviceAPIView

urlpatterns = [

    # # see device specific information once logged in
    # path('', UserDetailsView.as_view()),

    # device authentication endpoints
    path('register/', RegisterDeviceAPIView.as_view()),
    path('login/', LoginDeviceAPIView.as_view()),
]
