import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  IconData _getIconData(String name) {
    switch (name) {
      case 'money': return Icons.money;
      case 'account_balance_wallet': return Icons.account_balance_wallet;
      default: return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPaymentDialog(context, paymentController),
          ),
        ],
      ),
      body: Obx(() {
        if (paymentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final methods = paymentController.paymentMethods;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (methods.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Seidauk iha metodu pagamentu personalizadu',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ),
              _PaymentMethodCard(
                icon: Icons.money, title: 'Cash on Delivery',
                subtitle: 'Hola depois selu',
                isSelected: paymentController.selectedMethodId.value == 'cod',
                onTap: () => paymentController.selectedMethodId.value = 'cod',
              ),
            ] else
              ...methods.map((m) => _PaymentMethodCard(
                icon: _getIconData(m['icon'] ?? 'credit_card'),
                title: m['title'] ?? '',
                subtitle: m['subtitle'] ?? '',
                isSelected: paymentController.selectedMethodId.value == m['id'].toString(),
                onTap: () => paymentController.selectMethod(m['id'].toString()),
              )),
          ],
        );
      }),
    );
  }

  void _showAddPaymentDialog(BuildContext context, PaymentController controller) {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'Tau Payment Foun',
      content: Column(
        children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Naran (ex: MB Way)')),
          TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Deskrisaun')),
        ],
      ),
      onConfirm: () {
        if (titleCtrl.text.isNotEmpty) {
          controller.addPaymentMethod(titleCtrl.text, subtitleCtrl.text, 'credit_card');
          Get.back();
        }
      },
    ).then((_) {
      titleCtrl.dispose();
      subtitleCtrl.dispose();
    });
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  const _PaymentMethodCard({
    required this.icon, required this.title, required this.subtitle,
    required this.isSelected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D2D2D) : const Color(0xFFEEEEEE),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF2D2D2D)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
