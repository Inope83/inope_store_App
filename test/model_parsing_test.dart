import 'package:flutter_test/flutter_test.dart';
import 'package:inope_store/models/cart_model.dart';
import 'package:inope_store/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parses Django decimal strings and computes discounts', () {
      final product = ProductModel.fromJson({
        'id': 1,
        'name': 'Kamiseta',
        'category': 'Ropa',
        'category_id': 2,
        'price': '75.50',
        'original_price': '100.00',
        'description': 'Produto teste',
        'image_urls': ['https://example.com/product.png'],
        'stock': '8',
        'is_active': true,
        'created_at': '2026-06-09T10:00:00Z',
      });

      expect(product.price, 75.50);
      expect(product.originalPrice, 100);
      expect(product.stock, 8);
      expect(product.hasDiscount, isTrue);
      expect(product.discountPercent, 25);
      expect(product.firstImage, 'https://example.com/product.png');
    });

    test('falls back safely when optional values are missing', () {
      final product = ProductModel.fromJson({
        'name': 'Produto',
        'price': null,
        'image_urls': null,
      });

      expect(product.id, 0);
      expect(product.price, 0);
      expect(product.originalPrice, isNull);
      expect(product.firstImage, isEmpty);
      expect(product.isActive, isTrue);
    });
  });

  group('CartItemModel.fromJson', () {
    test('parses string price and quantity from API payloads', () {
      final item = CartItemModel.fromJson({
        'id': 5,
        'product_id': 9,
        'product_name': 'Sapatu',
        'product_image': 'https://example.com/shoe.png',
        'price': '12.25',
        'quantity': '3',
      });

      expect(item.productId, '9');
      expect(item.price, 12.25);
      expect(item.quantity, 3);
      expect(item.subtotal, 36.75);
    });
  });
}
