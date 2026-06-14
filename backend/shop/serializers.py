from rest_framework import serializers
from .models import (
    Category, Product, ProductImage, CartItem,
    Order, WishlistItem, Address, PaymentMethod,
)


class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'sort_order']


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'created_at']


class ProductListSerializer(serializers.ModelSerializer):
    category = serializers.StringRelatedField()
    category_id = serializers.IntegerField(source='category.id', read_only=True)
    image_urls = serializers.SerializerMethodField()
    first_image = serializers.SerializerMethodField()
    has_discount = serializers.SerializerMethodField()
    discount_percent = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'category', 'category_id', 'price',
            'original_price', 'description', 'image_urls', 'first_image',
            'stock', 'is_active', 'created_at', 'has_discount', 'discount_percent',
        ]

    def get_image_urls(self, obj):
        request = self.context.get('request')
        return [
            request.build_absolute_uri(img.image.url) if request else img.image.url
            for img in obj.images.all()
        ]

    def get_first_image(self, obj):
        first = obj.images.first()
        if first:
            request = self.context.get('request')
            return request.build_absolute_uri(first.image.url) if request else first.image.url
        return ''

    def get_has_discount(self, obj):
        return obj.original_price is not None and obj.original_price > obj.price

    def get_discount_percent(self, obj):
        if obj.original_price and obj.original_price > obj.price:
            return int((1 - float(obj.price) / float(obj.original_price)) * 100)
        return 0


class ProductWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            'name', 'category', 'price', 'original_price',
            'description', 'stock', 'is_active',
        ]


class CartItemSerializer(serializers.ModelSerializer):
    subtotal = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = ['id', 'product_id', 'product_name', 'product_image', 'price', 'quantity', 'subtotal']

    def get_subtotal(self, obj):
        return float(obj.price) * obj.quantity


class CartItemAddSerializer(serializers.Serializer):
    product_id = serializers.CharField()
    product_name = serializers.CharField()
    product_image = serializers.CharField(required=False, allow_blank=True)
    price = serializers.DecimalField(max_digits=12, decimal_places=2)


class CartItemUpdateSerializer(serializers.Serializer):
    quantity = serializers.IntegerField(min_value=0)


class OrderSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.first_name', read_only=True)
    user_email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = Order
        fields = [
            'id', 'user', 'user_name', 'user_email', 'items',
            'total', 'address', 'payment_method', 'payment_proof', 'status',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']


class OrderCreateSerializer(serializers.Serializer):
    address = serializers.CharField()
    payment_method = serializers.CharField(default='Cash on Delivery')


class WishlistItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = WishlistItem
        fields = ['id', 'name', 'price', 'product_id', 'image_url', 'created_at']


class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = [
            'id', 'label', 'full_name', 'phone', 'address',
            'city', 'district', 'postal_code', 'is_default', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class PaymentMethodSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentMethod
        fields = ['id', 'title', 'subtitle', 'icon', 'is_default', 'created_at']
        read_only_fields = ['id', 'created_at']


class OrderStatusSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=['pending', 'finished', 'cancelled'])


class AdminStatsSerializer(serializers.Serializer):
    product_count = serializers.IntegerField()
    order_count = serializers.IntegerField()
    user_count = serializers.IntegerField()
    pending_order_count = serializers.IntegerField()
    total_revenue = serializers.DecimalField(max_digits=14, decimal_places=2)
