from django.contrib.auth.models import User
from django.test import TestCase
from rest_framework.test import APIClient

from accounts.models import Profile
from .models import Category, Order, Product


class ShopApiTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='customer',
            email='customer@example.com',
            password='password123',
            first_name='Customer',
        )
        Profile.objects.create(user=self.user, role='customer')
        self.category = Category.objects.create(name='Ropa')
        self.product = Product.objects.create(
            name='Kamiseta',
            category=self.category,
            price='10.50',
            stock=5,
        )

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def test_customer_can_add_cart_item_and_create_order(self):
        self.authenticate(self.user)

        cart_response = self.client.post(
            '/api/cart/add/',
            {
                'product_id': str(self.product.id),
                'product_name': self.product.name,
                'product_image': '',
                'price': '10.50',
            },
            format='json',
        )

        self.assertEqual(cart_response.status_code, 201)

        order_response = self.client.post(
            '/api/orders/create/',
            {
                'address': 'Dili',
                'payment_method': 'Cash on Delivery',
            },
            format='json',
        )

        self.assertEqual(order_response.status_code, 201)
        self.assertEqual(Order.objects.filter(user=self.user).count(), 1)
        self.assertEqual(order_response.data['total'], '10.50')

    def test_profile_admin_can_access_admin_stats(self):
        admin = User.objects.create_user(
            username='admin',
            email='admin@example.com',
            password='password123',
            first_name='Admin',
        )
        Profile.objects.create(user=admin, role='admin')
        self.authenticate(admin)

        response = self.client.get('/api/admin/stats/')

        self.assertEqual(response.status_code, 200)
        self.assertIn('product_count', response.data)

    def test_customer_cannot_access_admin_stats(self):
        self.authenticate(self.user)

        response = self.client.get('/api/admin/stats/')

        self.assertEqual(response.status_code, 403)

    def test_profile_admin_can_create_product(self):
        admin = User.objects.create_user(
            username='admin',
            email='admin@example.com',
            password='password123',
            first_name='Admin',
        )
        Profile.objects.create(user=admin, role='admin')
        self.authenticate(admin)

        response = self.client.post(
            '/api/products/',
            {
                'name': 'Admin Product',
                'category': self.category.id,
                'price': '15.00',
                'stock': 4,
                'description': '',
                'is_active': True,
            },
            format='json',
        )

        self.assertEqual(response.status_code, 201)
        self.assertTrue(Product.objects.filter(name='Admin Product').exists())

    def test_customer_cannot_create_product(self):
        self.authenticate(self.user)

        response = self.client.post(
            '/api/products/',
            {
                'name': 'Customer Product',
                'category': self.category.id,
                'price': '15.00',
                'stock': 4,
            },
            format='json',
        )

        self.assertEqual(response.status_code, 403)
