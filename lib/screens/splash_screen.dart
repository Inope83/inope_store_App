import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) {
        Get.offAllNamed('/login');
        return;
      }
      await auth.ensureUserLoaded();
      if (auth.isAdmin) {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.shopping_bag,
                    size: 50, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'INOPE STORE',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            const Text('Fashion ba Hotu',
                style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
