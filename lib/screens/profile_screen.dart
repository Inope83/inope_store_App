import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _fmt(double price) =>
      price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF888888);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Hein';
      case 'processing':
        return 'Prosesando';
      case 'completed':
        return 'Kompletu';
      case 'cancelled':
        return 'Kansela';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final OrderController orderController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header Profile ────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: Colors.white,
                child: Obx(() {
                  final user = authController.currentUser.value;
                  return Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Utilizador',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A)),
                      ),
                      const Text(
                        'Kliente Inope Store',
                        style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      ),
                    ],
                  );
                }),
              ),
            ),

            // ── Account Info Section ──────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Informasaun Konta',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() {
                  final user = authController.currentUser.value;
                  return Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? '-',
                      ),
                      const Divider(indent: 50, height: 1),
                      _buildInfoTile(
                        icon: Icons.phone_android_outlined,
                        label: 'Telemóvel',
                        value: user?.phone ?? '-',
                      ),
                    ],
                  );
                }),
              ),
            ),

            // ── Orders Summary ────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Sumáriu Pedidu',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Obx(() {
                final orders = orderController.orders;
                final pending = orders.where((o) => o['status'] == 'pending').length;
                final finished = orders.where((o) => o['status'] == 'finished' || o['status'] == 'completed').length;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard('Hotu', '${orders.length}', Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatCard('Hein', '$pending', Colors.orange),
                      const SizedBox(width: 12),
                      _buildStatCard('Kompletu', '$finished', Colors.green),
                    ],
                  ),
                );
              }),
            ),

            // ── Recent Orders Title ───────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Istória Pedidu Foun',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
            ),

            Obx(() {
              if (orderController.isLoading.value) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                          color: Color(0xFF1A1A1A)),
                    ),
                  ),
                );
              }

              final orders = orderController.orders;

              if (orders.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('Seidauk iha pedidu',
                            style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF888888))),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final order = orders[i];
                    final status = order['status'] ?? 'pending';
                    final total =
                        (order['total'] as num?)?.toDouble() ?? 0.0;
                    final createdAt = order['created_at'];
                    String dateStr = '';
                    if (createdAt is Timestamp) {
                      final d = createdAt.toDate();
                      dateStr = '${d.day}/${d.month}/${d.year}';
                    }
                    final items =
                        List<dynamic>.from(order['items'] ?? []);

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order['id'] ?? '-',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status)
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _statusColor(status)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${items.length} item • $dateStr',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888)),
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF888888))),
                              Text(
                                'Rp ${_fmt(total)}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: orders.length,
                ),
              );
            }),

            // ── Admin Panel Button (If Admin) ────────────────
            Obx(() {
              if (authController.isAdmin) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/admin'),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.admin_panel_settings,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Admin Panel',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }),

            // ── Logout Button ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                child: GestureDetector(
                  onTap: () {
                    Get.defaultDialog(
                      title: 'Logout',
                      middleText: 'Ita boot hakarak sai husi konta?',
                      textConfirm: 'Sai',
                      textCancel: 'Lae',
                      confirmTextColor: Colors.white,
                      buttonColor: const Color(0xFFE53935),
                      onConfirm: () {
                        Get.back();
                        authController.signOut();
                      },
                    );
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFE53935), width: 1.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout,
                            color: Color(0xFFE53935), size: 18),
                        SizedBox(width: 8),
                        Text('Logout',
                            style: TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1A1A1A), size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A)),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}