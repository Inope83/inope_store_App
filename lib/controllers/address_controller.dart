import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class AddressController extends GetxController {
  final ApiService _api = ApiService();
  final RxList<Map<String, dynamic>> addresses = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_api.accessToken != null) {
      fetchAddresses();
    }
  }

  Future<void> fetchAddresses() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/addresses/');
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        addresses.value = data.map((a) => a as Map<String, dynamic>).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege load address');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAddress({
    required String address,
    required String city,
    required String phone,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final res = await _api.post('/addresses/', body: {
        'address': address,
        'city': city,
        'phone': phone,
        'full_name': authController.currentUser.value?.name ?? '',
        'label': 'Address ${addresses.length + 1}',
      });
      if (res.statusCode == 201 || res.statusCode == 200) {
        await fetchAddresses();
        Get.snackbar('Suksesu', 'Address tau tiha ona');
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege rai address');
    }
  }

  Future<void> deleteAddress(dynamic id) async {
    try {
      final res = await _api.delete('/addresses/$id/');
      if (res.statusCode == 200 || res.statusCode == 204) {
        addresses.removeWhere((a) => a['id'] == id);
        Get.snackbar('Suksesu', 'Address hamos tiha ona');
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege hamos address');
    }
  }
}
