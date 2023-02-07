from rest_framework import serializers
from dj_rest_auth.registration.serializers import RegisterSerializer
from .models import CustomUser

# get_adapter in save method to get an instance of our user model
from allauth.account.adapter import get_adapter


class CustomUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ('id', 'username', 'first_name', 'last_name', 'email', 'password',
                  'age', 'occupation', 'date_of_birth', 'city',)


class CustomRegisterSerializer(RegisterSerializer):
    first_name = serializers.CharField(max_length=150)
    last_name = serializers.CharField(max_length=150)

    age = serializers.IntegerField(max_value=None, min_value=1)
    occupation = serializers.CharField(max_length=50)
    date_of_birth = serializers.DateField()
    city = serializers.CharField(max_length=20)

    class Meta:
        model = CustomUser
        fields = ('username', 'first_name', 'last_name', 'email', 'password',
                  'age', 'occupation', 'date_of_birth', 'city',)

    # override get_cleaned_data of RegisterSerializer
    def get_cleaned_data(self):
        return {
            'username': self.validated_data.get('username', ''),
            'first_name': self.validated_data.get('first_name', ''),
            'last_name': self.validated_data.get('last_name', ''),
            'password1': self.validated_data.get('password1', ''),
            'password2': self.validated_data.get('password2', ''),
            'email': self.validated_data.get('email', ''),
            'age': self.validated_data.get('age'),
            'occupation': self.validated_data.get('occupation'),
            'date_of_birth': self.validated_data.get('date_of_birth'),
            'city': self.validated_data.get('city'),
        }

    # override save method of RegisterSerializer
    def save(self, request):
        adapter = get_adapter()
        user = adapter.new_user(request)
        self.cleaned_data = self.get_cleaned_data()
        user.age = self.cleaned_data.get('age')
        user.occupation = self.cleaned_data.get('occupation')
        user.date_of_birth = self.cleaned_data.get('date_of_birth')
        user.city = self.cleaned_data.get('city')
        user.save()
        adapter.save_user(request, user, self)
        return user
