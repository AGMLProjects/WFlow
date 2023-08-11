from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import path, re_path
from wflow.consumers import ActuatorConsumer

websocket_urlpatterns = [
    re_path(r'/actuator/(?P<device_id>\w+)/$', ActuatorConsumer.as_asgi()),
]


# application = ProtocolTypeRouter({
#     "websocket": URLRouter([
#         path("ws/actuator/", ActuatorConsumer.as_asgi()),
#     ]),
# })
