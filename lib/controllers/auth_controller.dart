import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<AuthController> init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return this;
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
      Database db = await DatabaseHelper().database;

      List<Map<String, dynamic>> existing =
          await db.query('users', where: 'email = ?', whereArgs: [email]);
      if (existing.isNotEmpty) {
        errorMessage.value = 'Email ona rejisu';
        return false;
      }

      String id = DateTime.now().millisecondsSinceEpoch.toString();
      UserModel newUser = UserModel(
        id: id,
        email: email.trim(),
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      );

      await db.insert('users', newUser.toJson());
      currentUser.value = newUser;
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
      Database db = await DatabaseHelper().database;
      List<Map<String, dynamic>> result = await db
          .query('users', where: 'email = ?', whereArgs: [email.trim()]);

      if (result.isNotEmpty) {
        currentUser.value = UserModel.fromJson(result.first);
        return true;
      } else {
        errorMessage.value = 'Uzuáriu la hetan';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    currentUser.value = null;
  }

  bool get isLoggedIn => currentUser.value != null;
  String get userId => currentUser.value?.id ?? '';
}
