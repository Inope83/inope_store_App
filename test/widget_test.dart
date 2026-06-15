import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:inope_store/controllers/auth_controller.dart';
import 'package:inope_store/controllers/cart_controller.dart';
import 'package:inope_store/controllers/product_controller.dart';
import 'package:inope_store/controllers/order_controller.dart';
import 'package:inope_store/main.dart';

void main() {
  setUp(() {
    Get.put(AuthController());
    Get.put(CartController());
    Get.put(ProductController());
    Get.put(OrderController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InopeStore());
    expect(find.text('INOPE STORE'), findsOneWidget);

    // Wait for the splash screen duration of 2 seconds
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
