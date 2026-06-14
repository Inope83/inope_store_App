import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../utils/format_utils.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderController _orderController = Get.find();

  @override
  void initState() {
    super.initState();
    _orderController.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ha'u nia Orders"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (_orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = _orderController.orders;
        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Color(0xFFCCCCCC)),
                SizedBox(height: 16),
                Text('Order seidauk iha',
                    style: TextStyle(fontSize: 16, color: Color(0xFF888888))),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final total = FormatUtils.parseDouble(order['total']);
            final status = order['status'] ?? 'pending';
            final createdAt = order['created_at'] as String?;
            String dateStr = '';
            if (createdAt != null) {
              try {
                final d = DateTime.parse(createdAt);
                dateStr = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
              } catch (_) {}
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.receipt),
                title: Text('ORD-${order['id'] ?? ''}'),
                subtitle: Text('Total: Rp ${FormatUtils.formatPrice(total)}\n$status'),
                trailing: Text(dateStr),
              ),
            );
          },
        );
      }),
    );
  }
}
