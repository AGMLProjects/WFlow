from channels.generic.websocket import AsyncWebsocketConsumer
import json

from .views import ACTIVE_ACTUATORS


class ActuatorConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Extract Raspberry Pi identifier from the URL or headers
        actuator_id = self.scope['url_route']['kwargs']['actuator_id']

        self.actuator_channel_name = f"actuator_{actuator_id}"

        await self.channel_layer.group_add(
            self.actuator_channel_name,
            self.channel_name
        )

        # Add the Raspberry Pi channel to the dictionary
        ACTIVE_ACTUATORS[actuator_id] = True

        await self.accept()

    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']

        # Send the message to the Raspberry Pi (implement your logic here)

        await self.send(text_data=json.dumps({
            'message': 'Message sent to Raspberry Pi successfully.',
        }))
