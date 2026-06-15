from django.contrib.auth.models import User
from rest_framework import serializers
from .models import Profile


class ProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source='user.email', read_only=True)
    name = serializers.CharField(source='user.first_name', read_only=True)

    class Meta:
        model = Profile
        fields = ['id', 'email', 'name', 'phone', 'role', 'created_at']


class RegisterSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, min_length=6)
    name = serializers.CharField(required=True)
    phone = serializers.CharField(required=True, allow_blank=True)

    class Meta:
        model = User
        fields = ['email', 'password', 'name', 'phone']

    def validate_email(self, value):
        email = value.lower().strip()
        if User.objects.filter(email__iexact=email).exists():
            raise serializers.ValidationError('Email rejista tiha ona')
        return email

    def create(self, validated_data):
        email = validated_data['email'].lower().strip()
        name = validated_data['name'].strip()
        phone = validated_data.get('phone', '').strip()
        password = validated_data['password']

        user = User.objects.create_user(
            username=email,
            email=email,
            password=password,
        )
        user.first_name = name
        user.save()

        from django.conf import settings
        is_admin = email.lower().strip() == settings.ADMIN_EMAIL

        if is_admin:
            role = 'admin'
            user.is_staff = True
            user.save(update_fields=['is_staff'])
        else:
            role = 'customer'

        Profile.objects.create(user=user, phone=phone, role=role)
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()


class ProfileUpdateSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='user.first_name')
    phone = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = Profile
        fields = ['name', 'phone']

    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', {})
        if 'first_name' in user_data:
            instance.user.first_name = user_data['first_name']
            instance.user.save()
        if 'phone' in validated_data:
            instance.phone = validated_data['phone']
        instance.save()
        return instance
