from django.contrib import admin
from .models import (
    Category, Product, ProductImage, CartItem,
    Order, WishlistItem, Address, PaymentMethod,
)

admin.site.register(Category)
admin.site.register(Product)
admin.site.register(ProductImage)
admin.site.register(CartItem)
admin.site.register(Order)
admin.site.register(WishlistItem)
admin.site.register(Address)
admin.site.register(PaymentMethod)
