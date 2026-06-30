import 'dart:convert';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _api = ApiService();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<AuthController> init() async {
    await _api.init();
    if (_api.accessToken != null) {
      await _loadProfile();
    }
    return this;
  }

  Future<void> _loadProfile() async {
    errorMessage.value = '';
    try {
      final res = await _api.get('/auth/profile/');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          currentUser.value = UserModel.fromJson(data);
        }
      } else {
        errorMessage.value = 'Failed to load profile: ${res.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: $e';
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _api.register({
        'email': email.trim(),
        'password': password,
        'name': name,
        'phone': phone,
      });
      if (result.containsKey('error')) {
        errorMessage.value = result['error'].toString();
        return false;
      }
      if (result['user'] is Map<String, dynamic>) {
        currentUser.value = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _api.login(email.trim(), password);
      if (result.containsKey('error')) {
        errorMessage.value = result['error'].toString();
        return false;
      }
      if (result['user'] is Map<String, dynamic>) {
        currentUser.value = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _api.clearTokens();
    currentUser.value = null;
  }

  Future<void> ensureUserLoaded() async {
    if (_api.accessToken != null && currentUser.value == null) {
      await _loadProfile();
    }
  }

  bool get isLoggedIn => _api.accessToken != null;
  bool get isAdmin => currentUser.value?.isAdmin ?? false;
  int get userId => currentUser.value?.id ?? 0;
}
