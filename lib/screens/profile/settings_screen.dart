import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingItem(
            icon: Icons.language, title: 'Lian',
            subtitle: settingsController.language.value,
            onTap: () => _showLanguageDialog(context, settingsController),
          ),
          _SettingToggle(
            icon: Icons.notifications_outlined, title: 'Notifikasaun',
            value: settingsController.notificationsEnabled.value,
            onChanged: (v) => settingsController.toggleNotifications(v),
          ),
          _SettingToggle(
            icon: Icons.dark_mode_outlined, title: 'Modu Klan (Dark)',
            value: settingsController.isDarkMode.value,
            onChanged: (v) => settingsController.toggleDarkMode(v),
          ),
          _SettingItem(
            icon: Icons.security, title: 'Seguransa', subtitle: 'Password, Autentikasaun',
            onTap: () => Get.snackbar('Avizu', 'Funsionalidade ida ne\'e sei dezenvolve hela'),
          ),
          _SettingItem(
            icon: Icons.info_outline, title: 'Tentang Aplikasaun', subtitle: 'Versaun 1.0.0',
            onTap: () {
              Get.defaultDialog(
                title: 'Tentang Aplikasaun',
                content: const Column(
                  children: [
                    ListTile(title: Text('Inope Store'), subtitle: Text('Versaun 1.0.0')),
                    ListTile(title: Text('Plataforma'), subtitle: Text('Flutter + Django')),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 24),
          _SettingItem(
            icon: Icons.person_outline, title: 'About Me',
            subtitle: authController.currentUser.value?.name ?? 'User',
            onTap: () {
              final user = authController.currentUser.value;
              Get.defaultDialog(
                title: 'About Me',
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(leading: const Icon(Icons.person), title: const Text('Naran'),
                        subtitle: Text(user?.name ?? '-')),
                    ListTile(leading: const Icon(Icons.email), title: const Text('Email'),
                        subtitle: Text(user?.email ?? '-')),
                    ListTile(leading: const Icon(Icons.phone), title: const Text('Telefone'),
                        subtitle: Text(user?.phone ?? '-')),
                    ListTile(leading: const Icon(Icons.calendar_today), title: const Text('Membru desde'),
                        subtitle: Text(user != null
                            ? '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                            : '-')),
                  ],
                ),
              );
            },
          ),
        ],
      )),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    final selected = controller.language.value.obs;
    Get.defaultDialog(
      title: 'Hili Lian',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => selected.value = 'Tetun',
            child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: selected.value == 'Tetun' ? Colors.black : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(selected.value == 'Tetun' ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 20),
                  const SizedBox(width: 12),
                  const Text('Tetun'),
                ],
              ),
            )),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => selected.value = 'English',
            child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: selected.value == 'English' ? Colors.black : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(selected.value == 'English' ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 20),
                  const SizedBox(width: 12),
                  const Text('English'),
                ],
              ),
            )),
          ),
        ],
      ),
      onConfirm: () {
        controller.updateLanguage(selected.value);
        Get.back();
      },
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingToggle({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        secondary: Icon(icon, color: const Color(0xFF2D2D2D)),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF2D2D2D),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingItem({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2D2D2D)),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
        onTap: onTap,
      ),
    );
  }
}
