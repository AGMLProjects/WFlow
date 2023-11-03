from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import path
from sensors.consumers import ActuatorConsumer

websocket_urlpatterns = [
    path('actuator/<int:device_id>', ActuatorConsumer.as_asgi()),
]


# application = ProtocolTypeRouter({
#     "websocket": URLRouter([
#         path("ws/actuator/", ActuatorConsumer.as_asgi()),
#     ]),
# })
