import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final AuthController _authController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back)),
              const SizedBox(height: 20),
              const Text('Kria Konta',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D))),
              const SizedBox(height: 8),
              const Text('Regista atu kontinua ba Store',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
              const SizedBox(height: 32),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Naran Kompletu',
                  hintText: 'Hatama ita naran kompletu',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2D2D2D), width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Hatama ita email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2D2D2D), width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numeru Telefone',
                  hintText: 'Hatama ita numeru telefone',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2D2D2D), width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Kria Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => isPasswordVisible.toggle()),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE0E0E0))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2D2D2D), width: 2)),
                    ),
                  )),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    onPressed: () async {
                      bool success = await _authController.signUp(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                      );
                      if (success) {
                        Get.offAllNamed('/home');
                      } else {
                        Get.snackbar('Sala', _authController.errorMessage.value,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                    text: 'Regista',
                    isLoading: _authController.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
