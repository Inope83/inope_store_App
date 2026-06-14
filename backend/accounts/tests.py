from django.contrib.auth.models import User
from django.test import TestCase
from rest_framework.test import APIClient


class AccountApiTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_register_normalizes_email_and_rejects_case_duplicate(self):
        first = self.client.post(
            '/api/auth/register/',
            {
                'email': 'User@Example.com',
                'password': 'password123',
                'name': 'User One',
                'phone': '',
            },
            format='json',
        )

        self.assertEqual(first.status_code, 201)
        self.assertTrue(User.objects.filter(email='user@example.com').exists())

        second = self.client.post(
            '/api/auth/register/',
            {
                'email': 'user@example.com',
                'password': 'password123',
                'name': 'User Two',
                'phone': '',
            },
            format='json',
        )

        self.assertEqual(second.status_code, 400)
        self.assertEqual(User.objects.filter(email__iexact='user@example.com').count(), 1)

    def test_register_configured_admin_gets_staff_and_profile_admin(self):
        response = self.client.post(
            '/api/auth/register/',
            {
                'email': 'angelinorosaleslopes1234@gmail.com',
                'password': 'password123',
                'name': 'Admin User',
                'phone': '',
            },
            format='json',
        )

        self.assertEqual(response.status_code, 201)
        user = User.objects.get(email='angelinorosaleslopes1234@gmail.com')
        self.assertTrue(user.is_staff)
        self.assertEqual(user.profile.role, 'admin')
