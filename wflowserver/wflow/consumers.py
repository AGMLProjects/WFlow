from channels.generic.websocket import AsyncWebsocketConsumer
import json

from .views import ACTIVE_ACTUATORS


class ActuatorConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Extract Raspberry Pi identifier from the URL or headers
        device_id = self.scope['url_route']['kwargs']['device_id']

        self.device_channel_name = f"device_{device_id}"

        await self.channel_layer.group_add(
            self.device_channel_name,
            self.channel_name
        )

        # Add the Raspberry Pi channel to the dictionary
        ACTIVE_ACTUATORS[device_id] = True

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
