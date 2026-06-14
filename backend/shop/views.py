from django.db import transaction
from django.contrib.auth.models import User
from rest_framework import status, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.permissions import SAFE_METHODS, BasePermission

from .models import (
    Category, Product, ProductImage, CartItem,
    Order, WishlistItem, Address, PaymentMethod,
)
from .serializers import (
    CategorySerializer, ProductListSerializer, ProductWriteSerializer,
    ProductImageSerializer, CartItemSerializer, CartItemAddSerializer,
    CartItemUpdateSerializer, OrderSerializer, OrderCreateSerializer,
    OrderStatusSerializer, WishlistItemSerializer, AddressSerializer,
    PaymentMethodSerializer, AdminStatsSerializer,
)


class IsAdminOrReadOnly(BasePermission):
    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        if not request.user or not request.user.is_authenticated:
            return False
        if request.user.is_staff:
            return True
        try:
            return request.user.profile.role == 'admin'
        except AttributeError:
            return False


class IsProfileAdmin(BasePermission):
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        if request.user.is_staff:
            return True
        try:
            return request.user.profile.role == 'admin'
        except AttributeError:
            return False


# ── Products ──────────────────────────────────────────────────────

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.filter(is_active=True)
    serializer_class = ProductListSerializer
    permission_classes = [IsAdminOrReadOnly]
    search_fields = ['name', 'description']
    filterset_fields = ['category__id', 'is_active']

    def get_serializer_class(self):
        if self.action in ('create', 'update', 'partial_update'):
            return ProductWriteSerializer
        return ProductListSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        if self.action == 'list' and self.request.query_params.get('admin') == 'true':
            return Product.objects.all()
        return qs

    def perform_create(self, serializer):
        product = serializer.save()
        images = self.request.FILES.getlist('images')
        for idx, img in enumerate(images):
            ProductImage.objects.create(product=product, image=img, sort_order=idx)

    def perform_update(self, serializer):
        product = serializer.save()
        images = self.request.FILES.getlist('images')
        if images:
            # Optionally clear existing images if new ones are uploaded
            # product.images.all().delete() 
            for idx, img in enumerate(images):
                ProductImage.objects.create(product=product, image=img, sort_order=idx)


class ProductImageViewSet(viewsets.ModelViewSet):
    queryset = ProductImage.objects.all()
    serializer_class = ProductImageSerializer
    permission_classes = [IsAdminOrReadOnly]


# ── Categories ────────────────────────────────────────────────────

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [IsAdminOrReadOnly]
    search_fields = ['name']


# ── Cart Items ────────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def cart_list(request):
    items = CartItem.objects.filter(user=request.user)
    serializer = CartItemSerializer(items, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def cart_add(request):
    serializer = CartItemAddSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    data = serializer.validated_data
    existing = CartItem.objects.filter(
        user=request.user, product_id=data['product_id']
    ).first()

    if existing:
        existing.quantity += 1
        existing.save()
        return Response(CartItemSerializer(existing).data)

    item = CartItem.objects.create(
        user=request.user,
        product_id=data['product_id'],
        product_name=data['product_name'],
        product_image=data.get('product_image', ''),
        price=data['price'],
        quantity=1,
    )
    return Response(CartItemSerializer(item).data, status=status.HTTP_201_CREATED)


@api_view(['PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def cart_item_detail(request, item_id):
    try:
        item = CartItem.objects.get(id=item_id, user=request.user)
    except CartItem.DoesNotExist:
        return Response({'error': 'Item la iha'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'DELETE':
        item.delete()
        return Response({'message': 'Item hamos tiha ona'}, status=status.HTTP_204_NO_CONTENT)

    serializer = CartItemUpdateSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    qty = serializer.validated_data['quantity']
    if qty <= 0:
        item.delete()
        return Response({'message': 'Item hamos tiha ona'}, status=status.HTTP_204_NO_CONTENT)

    item.quantity = qty
    item.save()
    return Response(CartItemSerializer(item).data)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def cart_clear(request):
    CartItem.objects.filter(user=request.user).delete()
    return Response({'message': 'Karréta hamos tiha ona'}, status=status.HTTP_204_NO_CONTENT)


# ── Orders ────────────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_list(request):
    orders = Order.objects.filter(user=request.user)
    serializer = OrderSerializer(orders, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def order_create(request):
    serializer = OrderCreateSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    cart_items = CartItem.objects.filter(user=request.user)
    if not cart_items.exists():
        return Response({'error': 'Karréta mamuk'}, status=status.HTTP_400_BAD_REQUEST)

    items_data = []
    for item in cart_items:
        data = CartItemSerializer(item).data
        # Convert Decimal values to floats for JSONField compatibility
        data['price'] = float(data['price'])
        data['subtotal'] = float(data['subtotal'])
        items_data.append(data)

    total = sum(item['subtotal'] for item in items_data)

    with transaction.atomic():
        order = Order.objects.create(
            user=request.user,
            items=items_data,
            total=total,
            address=serializer.validated_data['address'],
            payment_method=serializer.validated_data.get('payment_method', 'Cash on Delivery'),
            payment_proof=request.FILES.get('payment_proof'),
        )
        cart_items.delete()

    return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)


# ── Admin Orders ──────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsProfileAdmin])
def admin_order_list(request):
    orders = Order.objects.all()
    status_filter = request.query_params.get('status')
    if status_filter and status_filter != 'all':
        orders = orders.filter(status=status_filter)
    serializer = OrderSerializer(orders, many=True)
    return Response(serializer.data)


@api_view(['PUT'])
@permission_classes([IsProfileAdmin])
def admin_order_update_status(request, order_id):
    try:
        order = Order.objects.get(id=order_id)
    except Order.DoesNotExist:
        return Response({'error': 'Order la iha'}, status=status.HTTP_404_NOT_FOUND)

    serializer = OrderStatusSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    order.status = serializer.validated_data['status']
    order.save()
    return Response(OrderSerializer(order).data)


# ── Admin Stats ──────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsProfileAdmin])
def admin_stats(request):
    product_count = Product.objects.count()
    order_count = Order.objects.count()
    user_count = User.objects.count()
    pending_order_count = Order.objects.filter(status='pending').count()
    total_revenue = sum(
        float(o.total)
        for o in Order.objects.filter(status='finished')
    )
    data = AdminStatsSerializer({
        'product_count': product_count,
        'order_count': order_count,
        'user_count': user_count,
        'pending_order_count': pending_order_count,
        'total_revenue': total_revenue,
    }).data
    return Response(data)


# ── Admin Users ──────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsProfileAdmin])
def admin_users(request):
    users = User.objects.all().prefetch_related('profile')
    data = []
    for u in users:
        profile = getattr(u, 'profile', None)
        data.append({
            'id': u.id,
            'email': u.email,
            'name': u.first_name,
            'phone': profile.phone if profile else '',
            'role': profile.role if profile else 'customer',
            'created_at': profile.created_at if profile else u.date_joined,
        })
    return Response(data)


# ── Wishlist ──────────────────────────────────────────────────────

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def wishlist_list_create(request):
    if request.method == 'GET':
        items = WishlistItem.objects.filter(user=request.user)
        serializer = WishlistItemSerializer(items, many=True)
        return Response(serializer.data)

    serializer = WishlistItemSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    serializer.save(user=request.user)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def wishlist_delete(request, item_id):
    try:
        item = WishlistItem.objects.get(id=item_id, user=request.user)
    except WishlistItem.DoesNotExist:
        return Response({'error': 'Item la iha'}, status=status.HTTP_404_NOT_FOUND)
    item.delete()
    return Response({'message': 'Hamos tiha ona'}, status=status.HTTP_204_NO_CONTENT)


# ── Addresses ─────────────────────────────────────────────────────

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def address_list_create(request):
    if request.method == 'GET':
        addresses = Address.objects.filter(user=request.user)
        serializer = AddressSerializer(addresses, many=True)
        return Response(serializer.data)

    serializer = AddressSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    if serializer.validated_data.get('is_default'):
        Address.objects.filter(user=request.user, is_default=True).update(is_default=False)

    serializer.save(user=request.user)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def address_delete(request, addr_id):
    try:
        addr = Address.objects.get(id=addr_id, user=request.user)
    except Address.DoesNotExist:
        return Response({'error': 'Address la iha'}, status=status.HTTP_404_NOT_FOUND)
    addr.delete()
    return Response({'message': 'Address hamos tiha ona'}, status=status.HTTP_204_NO_CONTENT)


# ── Payment Methods ────────────────────────────────────────────────

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def payment_method_list_create(request):
    if request.method == 'GET':
        methods = PaymentMethod.objects.filter(user=request.user)
        serializer = PaymentMethodSerializer(methods, many=True)
        return Response(serializer.data)

    serializer = PaymentMethodSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    if serializer.validated_data.get('is_default'):
        PaymentMethod.objects.filter(user=request.user, is_default=True).update(is_default=False)

    serializer.save(user=request.user)
    return Response(serializer.data, status=status.HTTP_201_CREATED)
