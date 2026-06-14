import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart' as prefs;

class SettingsController extends GetxController {
  final RxString language = 'Tetun'.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    language.value = prefs.getString('language') ?? 'Tetun';
    isDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
    notificationsEnabled.value = prefs.getBool('notifications') ?? true;
    
    _applyTheme();
  }

  Future<void> updateLanguage(String newLang) async {
    language.value = newLang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLang);
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    _applyTheme();
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
