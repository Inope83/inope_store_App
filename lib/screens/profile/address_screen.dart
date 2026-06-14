import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/address_controller.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ha'u nia Address"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAddressDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.addresses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 64, color: Color(0xFFCCCCCC)),
                SizedBox(height: 16),
                Text('Address seidauk iha',
                    style: TextStyle(fontSize: 16, color: Color(0xFF888888))),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final addr = controller.addresses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(addr['address'] ?? ''),
                subtitle: Text('${addr['city'] ?? ''}\nTel: ${addr['phone'] ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteAddress(addr['id']),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddAddressDialog(BuildContext context, AddressController controller) {
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'Tau Address Foun',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: addressCtrl, decoration: const InputDecoration(hintText: 'Address')),
          TextField(controller: cityCtrl, decoration: const InputDecoration(hintText: 'Cidade')),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(hintText: 'Telefone'),
              keyboardType: TextInputType.phone),
        ],
      ),
      onConfirm: () {
        if (addressCtrl.text.isNotEmpty) {
          controller.addAddress(
            address: addressCtrl.text,
            city: cityCtrl.text,
            phone: phoneCtrl.text,
          );
          Get.back();
        }
      },
    ).then((_) {
      addressCtrl.dispose();
      cityCtrl.dispose();
      phoneCtrl.dispose();
    });
  }
}
