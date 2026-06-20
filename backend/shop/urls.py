from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'products', views.ProductViewSet, basename='product')
router.register(r'product-images', views.ProductImageViewSet, basename='product-image')
router.register(r'categories', views.CategoryViewSet, basename='category')

urlpatterns = [
    path('', include(router.urls)),

    # Cart
    path('cart/', views.cart_list, name='cart-list'),
    path('cart/add/', views.cart_add, name='cart-add'),
    path('cart/item/<int:item_id>/', views.cart_item_detail, name='cart-item-detail'),
    path('cart/clear/', views.cart_clear, name='cart-clear'),

    # Orders (customer)
    path('orders/', views.order_list, name='order-list'),
    path('orders/create/', views.order_create, name='order-create'),

    # Admin
    path('admin/orders/', views.admin_order_list, name='admin-order-list'),
    path('admin/orders/<int:order_id>/status/', views.admin_order_update_status, name='admin-order-status'),
    path('admin/orders/<int:order_id>/delete/', views.admin_order_delete, name='admin-order-delete'),
    path('admin/stats/', views.admin_stats, name='admin-stats'),
    path('admin/users/', views.admin_users, name='admin-users'),

    # Wishlist
    path('wishlist/', views.wishlist_list_create, name='wishlist-list-create'),
    path('wishlist/<int:item_id>/', views.wishlist_delete, name='wishlist-delete'),

    # Addresses
    path('addresses/', views.address_list_create, name='address-list-create'),
    path('addresses/<int:addr_id>/', views.address_delete, name='address-delete'),

    # Payment Methods
    path('payment-methods/', views.payment_method_list_create, name='payment-method-list-create'),
]
