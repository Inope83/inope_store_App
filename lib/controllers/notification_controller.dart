import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class NotificationController extends GetxController {
  final ApiService _api = ApiService();
  final AuthController _authController = Get.find();

  final RxBool hasUnread = false.obs;
  final RxList<Map<String, String>> notifications = <Map<String, String>>[].obs;
  final RxBool isPolling = false.obs;

  Timer? _pollTimer;
  final Map<int, String> _previousStatuses = {};
  DateTime _pollStartTime = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    if (_authController.currentUser.value != null) {
      _startPolling();
    }
    ever(_authController.currentUser, (user) {
      if (user != null) {
        _startPolling();
      } else {
        _stopPolling();
        notifications.clear();
        hasUnread.value = false;
      }
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollStartTime = DateTime.now();
    _previousStatuses.clear();
    _fetchAndCheck();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchAndCheck());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _addNotification(OrderModel order) {
    final items = order.items.take(3).map((item) {
      if (item is Map) return item['product_name'] ?? 'Item';
      return 'Item';
    }).join(', ');
    final suffix = order.items.length > 3 ? ' +${order.items.length - 3} seluk' : '';
    final msg = '$items$suffix';
    for (final n in notifications) {
      if (n['orderId'] == order.id.toString()) return;
    }
    final firstItem = order.items.isNotEmpty && order.items.first is Map
        ? order.items.first as Map
        : null;
    notifications.insert(0, {
      'title': 'Pedidu Kompletu! (#${order.id})',
      'message': msg,
      'orderId': order.id.toString(),
      'productId': firstItem?['product_id']?.toString() ?? '',
    });
    hasUnread.value = true;
  }

  Future<void> _fetchAndCheck() async {
    if (!_authController.isLoggedIn) return;
    isPolling.value = true;
    try {
      final res = await _api.get('/orders/');
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        final orders = data.map((e) => OrderModel.fromJson(e)).toList();

        for (final order in orders) {
          if (order.status == 'finished') {
            final prevStatus = _previousStatuses[order.id];
            if (prevStatus == null) {
              if (order.updatedAt.isAfter(_pollStartTime)) {
                _addNotification(order);
              }
            } else if (prevStatus != order.status) {
              _addNotification(order);
            }
          }
          _previousStatuses[order.id] = order.status;
        }
      }
    } catch (e) {
      debugPrint('Notification poll error: $e');
    } finally {
      isPolling.value = false;
    }
  }

  void markAllRead() {
    hasUnread.value = false;
  }

  void clearNotifications() {
    notifications.clear();
    hasUnread.value = false;
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }
}
