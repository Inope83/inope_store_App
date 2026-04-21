import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../controllers/auth_controller.dart';
import '../database/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find();
  int _orderCount = 0;
  int _wishlistCount = 0;
  int _addressCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final db = await DatabaseHelper().database;
    final userId = authController.userId;
    
    final orders = await db.query('orders', where: 'user_id = ?', whereArgs: [userId]);
    final wishlist = await db.query('wishlist', where: 'user_id = ?', whereArgs: [userId]);
    final addresses = await db.query('addresses', where: 'user_id = ?', whereArgs: [userId]);
    
    setState(() {
      _orderCount = orders.length;
      _wishlistCount = wishlist.length;
      _addressCount = addresses.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text('Profile',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D))),
              ),
              const SizedBox(height: 20),
              Obx(() => Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                            color: Color(0xFF2D2D2D), shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            authController.currentUser.value?.name[0]?.toUpperCase() ?? 'U',
                            style: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        authController.currentUser.value?.name ?? 'User',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authController.currentUser.value?.email ?? 'email@example.com',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                      ),
                    ],
                  )),
              const SizedBox(height: 20),
              _ProfileMenu(
                orderCount: _orderCount,
                wishlistCount: _wishlistCount,
                addressCount: _addressCount,
              ),
              const SizedBox(height: 16),
              _LogoutButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final int orderCount;
  final int wishlistCount;
  final int addressCount;

  const _ProfileMenu({
    required this.orderCount,
    required this.wishlistCount,
    required this.addressCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5)),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.shopping_bag_outlined,
            title: "Ha'u nia Orders",
            count: orderCount,
            onTap: () => Get.to(() => const MyOrdersScreen()),
            isFirst: true,
          ),
          _MenuItem(
            icon: Icons.favorite_border,
            title: "Wishlist",
            count: wishlistCount,
            onTap: () => Get.to(() => const WishlistScreen()),
          ),
          _MenuItem(
            icon: Icons.location_on_outlined,
            title: "Address",
            count: addressCount,
            onTap: () => Get.to(() => const AddressScreen()),
          ),
          _MenuItem(
            icon: Icons.credit_card_outlined,
            title: "Payment",
            count: 0,
            onTap: () => Get.to(() => const PaymentScreen()),
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: "Settings",
            count: 0,
            onTap: () => Get.to(() => const SettingsScreen()),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? Radius.circular(12) : Radius.zero,
            bottom: isLast ? Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2D2D2D)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF2D2D2D))),
            ),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$count',
                    style: const TextStyle(
                        fontSize: 10, color: Colors.white)),
              ),
            const Icon(Icons.chevron_right,
                size: 16, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return GestureDetector(
      onTap: () => _showLogoutDialog(context, authController),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE53935), width: 0.5),
            borderRadius: BorderRadius.circular(10)),
        child: const Center(
          child: Text('Sai',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE53935))),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sai'),
          content: const Text('Ita boot hakarak sai husi aplikasaun?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Lae')),
            TextButton(
              onPressed: () {
                authController.signOut();
                Navigator.pop(context);
              },
              child: const Text('Sin',
                  style: TextStyle(color: Color(0xFFE53935))),
            ),
          ],
        );
      },
    );
  }
}

// ==================== MY ORDERS SCREEN ====================
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final db = await DatabaseHelper().database;
    final authController = Get.find<AuthController>();
    final orders = await db.query('orders',
        where: 'user_id = ?', whereArgs: [authController.userId]);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ha'u nia Orders"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 64, color: Color(0xFFCCCCCC)),
                      SizedBox(height: 16),
                      Text('Order seidauk iha',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF888888))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.receipt),
                        title: Text('Order #${order['order_number']}'),
                        subtitle: Text(
                            'Total: \$${order['total_amount']}\n${order['status']}'),
                        trailing: Text(order['created_at'].toString().substring(0, 10)),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== WISHLIST SCREEN ====================
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> _wishlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final db = await DatabaseHelper().database;
    final authController = Get.find<AuthController>();
    final wishlist = await db.query('wishlist',
        where: 'user_id = ?', whereArgs: [authController.userId]);
    setState(() {
      _wishlist = wishlist;
      _isLoading = false;
    });
  }

  Future<void> _removeFromWishlist(String id) async {
    final db = await DatabaseHelper().database;
    await db.delete('wishlist', where: 'id = ?', whereArgs: [id]);
    _loadWishlist();
    Get.snackbar('Suksesu', 'Produtu hamos tiha ona');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlist.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 64, color: Color(0xFFCCCCCC)),
                      SizedBox(height: 16),
                      Text('Wishlist seidauk iha',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF888888))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _wishlist.length,
                  itemBuilder: (context, index) {
                    final item = _wishlist[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Text(item['image_url'] ?? '🛍️',
                            style: const TextStyle(fontSize: 30)),
                        title: Text(item['name']),
                        subtitle: Text('\$${item['price']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFromWishlist(item['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== ADDRESS SCREEN ====================
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final db = await DatabaseHelper().database;
    final authController = Get.find<AuthController>();
    final addresses = await db.query('addresses',
        where: 'user_id = ?', whereArgs: [authController.userId]);
    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  Future<void> _addAddress() async {
    final TextEditingController addressCtrl = TextEditingController();
    final TextEditingController cityCtrl = TextEditingController();
    final TextEditingController phoneCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tau Address Foun'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(hintText: 'Address'),
              ),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(hintText: 'Cidade'),
              ),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(hintText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kansela')),
            TextButton(
              onPressed: () async {
                final db = await DatabaseHelper().database;
                final authController = Get.find<AuthController>();
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                await db.insert('addresses', {
                  'id': id,
                  'user_id': authController.userId,
                  'label': 'Address ${_addresses.length + 1}',
                  'full_name': authController.currentUser.value?.name,
                  'phone': phoneCtrl.text,
                  'address': addressCtrl.text,
                  'city': cityCtrl.text,
                  'district': '',
                  'postal_code': '',
                  'is_default': _addresses.isEmpty ? 1 : 0,
                });
                Navigator.pop(context);
                _loadAddresses();
                Get.snackbar('Suksesu', 'Address tau tiha ona');
              },
              child: const Text('Rai'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAddress(String id) async {
    final db = await DatabaseHelper().database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
    _loadAddresses();
    Get.snackbar('Suksesu', 'Address hamos tiha ona');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ha'u nia Address"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAddress,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off,
                          size: 64, color: Color(0xFFCCCCCC)),
                      SizedBox(height: 16),
                      Text('Address seidauk iha',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF888888))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(addr['address']),
                        subtitle: Text(
                            '${addr['city']}\nTel: ${addr['phone']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAddress(addr['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== PAYMENT SCREEN ====================
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PaymentMethodCard(
            icon: Icons.money,
            title: 'Cash on Delivery',
            subtitle: 'Hola depois selu',
            isSelected: true,
          ),
          const SizedBox(height: 12),
          _PaymentMethodCard(
            icon: Icons.credit_card,
            title: 'Credit Card',
            subtitle: 'Visa, Mastercard',
            isSelected: false,
          ),
          const SizedBox(height: 12),
          _PaymentMethodCard(
            icon: Icons.account_balance_wallet,
            title: 'Digital Wallet',
            subtitle: 'MB Way, OkoPay',
            isSelected: false,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF2D2D2D) : const Color(0xFFEEEEEE),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF2D2D2D)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }
}

// ==================== SETTINGS SCREEN ====================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingItem(
            icon: Icons.language,
            title: 'Lian',
            subtitle: 'Tetun',
            onTap: () {},
          ),
          _SettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasaun',
            subtitle: 'Aktivu',
            onTap: () {},
          ),
          _SettingItem(
            icon: Icons.dark_mode_outlined,
            title: 'Modu Klan',
            subtitle: 'Claru',
            onTap: () {},
          ),
          _SettingItem(
            icon: Icons.security,
            title: 'Seguransa',
            subtitle: 'Password, Autentikasaun',
            onTap: () {},
          ),
          _SettingItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasaun',
            subtitle: 'Versaun 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
