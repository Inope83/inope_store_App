import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../controllers/cart_controller.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final OrderController orderController = Get.find();
  final CartController cartController = Get.find();
  final TextEditingController addressController = TextEditingController();
  final RxString selectedPayment = 'Dinheru Iha Entrega'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Colors.white,
          elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enderesu Ombak',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Hatama ita enderesu',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Metodu Pagamentu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() => Column(
                  children: [
                    RadioListTile(
                      title: const Text('Dinheru Iha Entrega'),
                      value: 'Cash on Delivery',
                      groupValue: selectedPayment.value,
                      onChanged: (v) => selectedPayment.value = v.toString(),
                    ),
                    RadioListTile(
                      title: const Text('Kartaun Kreditu'),
                      value: 'Credit Card',
                      groupValue: selectedPayment.value,
                      onChanged: (v) => selectedPayment.value = v.toString(),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Montante Totál',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Obx(() => Text(
                      '\$${cartController.totalPrice.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: orderController.isLoading.value
                        ? null
                        : () async {
                            if (addressController.text.isEmpty) {
                              Get.snackbar('Sala', 'Favor hatama enderesu');
                              return;
                            }
                            await orderController.createOrder(
                              paymentMethod: selectedPayment.value,
                              address: addressController.text,
                            );
                            Get.offAllNamed('/home');
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D2D2D),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: orderController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Halo Orde',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
