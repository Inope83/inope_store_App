import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class PaymentController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<Map<String, dynamic>> paymentMethods =
      <Map<String, dynamic>>[].obs;
  final RxString selectedMethodId = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_api.accessToken != null) {
      fetchPaymentMethods();
    }
  }

  Future<void> fetchPaymentMethods() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/payment-methods/');
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        paymentMethods.value =
            data.map((m) => m as Map<String, dynamic>).toList();

        final defaultMethod = paymentMethods.firstWhereOrNull(
            (m) => m['is_default'] == true);
        if (defaultMethod != null) {
          selectedMethodId.value = defaultMethod['id'].toString();
        } else if (paymentMethods.isNotEmpty) {
          selectedMethodId.value = paymentMethods.first['id'].toString();
        }
      }
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectMethod(String id) async {
    selectedMethodId.value = id;
  }

  Future<void> addPaymentMethod(
      String title, String subtitle, String iconName) async {
    try {
      await _api.post('/payment-methods/', body: {
        'title': title,
        'subtitle': subtitle,
        'icon': iconName,
      });
      await fetchPaymentMethods();
    } catch (e) {
      Get.snackbar('Error', 'La konsege tau payment foun');
    }
  }
}
