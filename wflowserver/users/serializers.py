from rest_framework import serializers
from dj_rest_auth.registration.serializers import RegisterSerializer
from dj_rest_auth.models import TokenModel
# get_adapter in save method to get an instance of our user model
from allauth.account.adapter import get_adapter

from .models import CustomUser


class CustomUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ('email', 'first_name', 'last_name',
                  'occupation', 'date_of_birth',
                  'status', 'family_members', 'personal_data')
        read_only_fields = ('email',)


class CustomLoginSerializer(serializers.ModelSerializer):

    class Meta:
        model = CustomUser
        fields = ('email', 'password')


class CustomRegisterSerializer(RegisterSerializer):
    first_name = serializers.CharField(max_length=150)
    last_name = serializers.CharField(max_length=150)

    occupation = serializers.CharField(max_length=50)
    date_of_birth = serializers.DateField()
    city = serializers.CharField(max_length=20)

    class Meta:
        model = CustomUser
        fields = ('username', 'first_name', 'last_name', 'email', 'password',
                  'occupation', 'date_of_birth')

    # override get_cleaned_data of RegisterSerializer

    def get_cleaned_data(self):
        return {
            'username': self.validated_data.get('username', ''),
            'first_name': self.validated_data.get('first_name', ''),
            'last_name': self.validated_data.get('last_name', ''),
            'password1': self.validated_data.get('password1', ''),
            'password2': self.validated_data.get('password2', ''),
            'email': self.validated_data.get('email', ''),
            'occupation': self.validated_data.get('occupation'),
            'date_of_birth': self.validated_data.get('date_of_birth'),
            'personal_data': self.validated_data.get('personal_data')
        }

    # override save method of RegisterSerializer
    def save(self, request):
        adapter = get_adapter()
        user = adapter.new_user(request)
        self.cleaned_data = self.get_cleaned_data()
        user.occupation = self.cleaned_data.get('occupation')
        user.date_of_birth = self.cleaned_data.get('date_of_birth')
        user.personal_data = self.cleaned_data.get('personal_data')
        user.save()
        adapter.save_user(request, user, self)
        return user
