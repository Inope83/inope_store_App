import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/order_controller.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/admin/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => AuthController().init());
  Get.put(CartController());
  Get.put(ProductController());
  Get.put(OrderController());

  runApp(const InopeStore());
}

class InopeStore extends StatelessWidget {
  const InopeStore({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inope Store',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D2D2D),
        useMaterial3: true,
        colorScheme: const ColorScheme.light(primary: Color(0xFF2D2D2D)),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => const MainNavigationScreen()),
        GetPage(name: '/shop', page: () => const ShopScreen()),
        GetPage(name: '/cart', page: () => const CartScreen()),
        GetPage(name: '/checkout', page: () => const CheckoutScreen()),
        GetPage(name: '/admin', page: () => const AdminScreen()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ShopScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2D2D2D),
        unselectedItemColor: const Color(0xFFAAAAAA),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Baranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined), label: 'Shop'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: 'Karréta'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
