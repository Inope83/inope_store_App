import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button ───────────────────────────────
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // ── Header ────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kria Konta Foun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rejista atu hahú kompra',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // ── Name ──────────────────────────────────────
              _buildTextField(
                controller: nameController,
                label: 'Naran',
                hint: 'Hatama naran kompletu',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // ── Phone ─────────────────────────────────────
              _buildTextField(
                controller: phoneController,
                label: 'Telemóvel',
                hint: 'Hatama númeru telemóvel',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────
              _buildTextField(
                controller: emailController,
                label: 'Email',
                hint: 'Hatama email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // ── Password ──────────────────────────────────
              Obx(
                () => _buildPasswordField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Mínimo 6 karakter',
                  isVisible: isPasswordVisible,
                ),
              ),
              const SizedBox(height: 16),

              // ── Confirm Password ──────────────────────────
              Obx(
                () => _buildPasswordField(
                  controller: confirmPasswordController,
                  label: 'Konfirma Password',
                  hint: 'Repete password',
                  isVisible: isConfirmPasswordVisible,
                ),
              ),
              const SizedBox(height: 28),

              // ── Submit button ─────────────────────────────
              Obx(
                () => CustomButton(
                  onPressed: () => _handleRegister(),
                  text: 'Rejista',
                  isLoading: _authController.isLoading.value,
                ),
              ),
              const SizedBox(height: 24),

              // ── Login link ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Iha ona konta? "),
                  TextButton(
                    onPressed: () => Get.offNamed('/login'),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Validasi & Register ───────────────────────────────────
  Future<void> _handleRegister() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validasi lokal
    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Sala',
        'Por favor prenxe kampu hotu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: AppColors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Sala',
        'Password no konfirmasaun la koresponde',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: AppColors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Sala',
        'Password mínimo 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: AppColors.white,
      );
      return;
    }

    final success = await _authController.signUp(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );

    if (success) {
      if (_authController.isAdmin) {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/home');
      }
    } else {
      Get.snackbar(
        'Sala',
        _authController.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
    }
  }

  // ── Widget helpers ────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required RxBool isVisible,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible.value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(isVisible.value ? Icons.visibility_off : Icons.visibility),
          onPressed: () => isVisible.toggle(),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
