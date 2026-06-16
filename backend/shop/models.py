from django.db import models


class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'categories'
        verbose_name_plural = 'categories'
        ordering = ['name']


class Product(models.Model):
    name = models.CharField(max_length=200)
    category = models.ForeignKey(
        Category, on_delete=models.SET_NULL, null=True, related_name='products'
    )
    price = models.DecimalField(max_digits=12, decimal_places=2)
    original_price = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    description = models.TextField(blank=True, default='')
    stock = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    rating = models.FloatField(default=0.0)
    sizes = models.TextField(default='S,M,L,XL')
    colors = models.TextField(default='Black,White,Blue')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'products'
        ordering = ['-created_at']


class ProductImage(models.Model):
    product = models.ForeignKey(
        Product, on_delete=models.CASCADE, related_name='images'
    )
    image = models.ImageField(upload_to='products/')
    sort_order = models.IntegerField(default=0)

    def __str__(self):
        return f'{self.product.name} - {self.sort_order}'

    class Meta:
        db_table = 'product_images'
        ordering = ['sort_order']


class CartItem(models.Model):
    user = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, related_name='cart_items'
    )
    product_id = models.CharField(max_length=200)
    product_name = models.CharField(max_length=200)
    product_image = models.URLField(blank=True, default='')
    price = models.DecimalField(max_digits=12, decimal_places=2)
    quantity = models.IntegerField(default=1)

    def __str__(self):
        return f'{self.user.email} - {self.product_name} x{self.quantity}'

    class Meta:
        db_table = 'cart_items'


class Order(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('finished', 'Kompleta'),
        ('cancelled', 'Kansela'),
    ]

    user = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, related_name='orders'
    )
    items = models.JSONField(default=list)
    total = models.DecimalField(max_digits=14, decimal_places=2)
    address = models.TextField(blank=True, default='')
    phone = models.CharField(max_length=20, blank=True, default='')
    email = models.EmailField(blank=True, default='')
    payment_method = models.CharField(max_length=100, default='Cash on Delivery')
    payment_proof = models.ImageField(upload_to='payment_proofs/', null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'ORD-{self.id} - {self.user.email}'

    class Meta:
        db_table = 'orders'
        ordering = ['-created_at']


class WishlistItem(models.Model):
    user = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, related_name='wishlist_items'
    )
    name = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    product_id = models.CharField(max_length=200, blank=True, default='')
    image_url = models.URLField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.user.email} - {self.name}'

    class Meta:
        db_table = 'wishlist_items'


class Address(models.Model):
    user = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, related_name='addresses'
    )
    label = models.CharField(max_length=100, blank=True, default='')
    full_name = models.CharField(max_length=200, blank=True, default='')
    phone = models.CharField(max_length=20, blank=True, default='')
    address = models.TextField(blank=True, default='')
    city = models.CharField(max_length=100, blank=True, default='')
    district = models.CharField(max_length=100, blank=True, default='')
    postal_code = models.CharField(max_length=20, blank=True, default='')
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.user.email} - {self.address[:30]}'

    class Meta:
        db_table = 'addresses'


class PaymentMethod(models.Model):
    user = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, related_name='payment_methods'
    )
    title = models.CharField(max_length=100)
    subtitle = models.CharField(max_length=200, blank=True, default='')
    icon = models.CharField(max_length=50, default='credit_card')
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.user.email} - {self.title}'

    class Meta:
        db_table = 'payment_methods'
