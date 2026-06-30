import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import '../../utils/app_colors.dart';
import 'product_form_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tabIndex = 0;

  static const _titles = ['Dashboard', 'Produtu', 'Orden', 'Kategoria', 'Uzuáriu'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCurrentTab());
  }

  Future<void> _refreshCurrentTab() async {
    final admin = Get.find<AdminController>();
    final products = Get.find<ProductController>();
    if (_tabIndex == 0) {
      await admin.refreshAll();
    } else if (_tabIndex == 1) {
      await products.fetchProductsForAdmin();
    } else if (_tabIndex == 2) {
      await admin.fetchAllOrders();
    } else if (_tabIndex == 3) {
      await admin.fetchCategories();
    } else {
      await admin.fetchAllUsers();
    }
  }

  void _confirmDelete(ProductModel product, ProductController controller) {
    Get.defaultDialog(
      title: 'Hamos Produtu',
      middleText: 'Ita boot hakarak hamos "${product.name}"?',
      textConfirm: 'Hamos',
      textCancel: 'Lae',
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.red,
      onConfirm: () async {
        Get.back();
        try {
          final api = ApiService();
          final res = await api.delete('/products/${product.id}/');
          if (res.statusCode == 204) {
            await controller.fetchProductsForAdmin();
            await Get.find<ProductController>().fetchProducts();
            await Get.find<AdminController>().refreshAll();
            Get.snackbar('Suksesu', '${product.name} hamos ona',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white);
          } else {
            Get.snackbar('Error', 'Falha atu hamos produtu',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white);
          }
        } catch (e) {
          Get.snackbar('Error', 'Falha atu hamos produtu',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: Text(_titles[_tabIndex],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshCurrentTab),
          IconButton(icon: const Icon(Icons.logout), onPressed: () {
            auth.signOut();
            Get.offAllNamed('/login');
          }),
        ],
      ),
      floatingActionButton: (_tabIndex == 1 || _tabIndex == 3)
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.dark,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.add),
              label: Text(_tabIndex == 1 ? 'Produtu Foun' : 'Kategoria Foun'),
              onPressed: () async {
                if (_tabIndex == 1) {
                  await Get.to(() => const ProductFormScreen());
                } else {
                  _showCategoryDialog(context);
                }
                if (mounted) _refreshCurrentTab();
              },
            )
          : null,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _DashboardTab(onOpenOrders: () => setState(() => _tabIndex = 2)),
          _ProductsTab(onDelete: _confirmDelete),
          const _OrdersTab(),
          _CategoriesTab(
            onEditCategory: (cat) => _showCategoryDialog(context, category: cat),
          ),
          const _UsersTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.dark.withValues(alpha: 0.12),
        onDestinationSelected: (i) {
          setState(() => _tabIndex = i);
          _refreshCurrentTab();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Produtu'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orden'),
          NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Kategoria'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Uzuáriu'),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Map<String, dynamic>? category}) {
    final ctrl = TextEditingController(text: category?['name'] ?? '');
    Get.defaultDialog(
      title: category == null ? 'Kategoria Foun' : 'Edita Kategoria',
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(labelText: 'Naran Kategoria'),
      ),
      textConfirm: 'Salva',
      textCancel: 'Kansela',
      confirmTextColor: AppColors.white,
      onConfirm: () async {
        if (ctrl.text.trim().isEmpty) return;
        final admin = Get.find<AdminController>();
        final prodCtrl = Get.find<ProductController>();
        try {
          if (category == null) {
            await admin.addCategory(ctrl.text.trim());
          } else {
            final api = ApiService();
            final res = await api.put('/categories/${category['id']}/',
                body: {'name': ctrl.text.trim()});
            if (res.statusCode == 200) {
              await admin.fetchCategories();
              await prodCtrl.fetchProductsForAdmin();
            } else {
              Get.snackbar('Error', 'Falha atualiza kategoria',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white);
              return;
            }
          }
        } catch (e) {
          Get.snackbar('Error', 'Falha: $e',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          return;
        }
        Get.back();
      },
    ).then((_) => ctrl.dispose());
  }
}

// ── Dashboard ─────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  final VoidCallback onOpenOrders;
  const _DashboardTab({required this.onOpenOrders});

  String _fmt(double n) => FormatUtils.formatPrice(n);

  @override
  Widget build(BuildContext context) {
    final admin = Get.find<AdminController>();

    return Obx(() {
      if (admin.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.dark),
        );
      }
      return RefreshIndicator(
        color: AppColors.dark,
        onRefresh: admin.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Ringkasan Loja',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _StatCard(icon: Icons.inventory_2_outlined, label: 'Total Produtu', value: '${admin.productCount.value}', color: AppColors.dark),
                _StatCard(icon: Icons.receipt_long_outlined, label: 'Total Orden', value: '${admin.orderCount.value}', color: const Color(0xFF1565C0)),
                _StatCard(icon: Icons.people_outline, label: 'Total Uzuáriu', value: '${admin.userCount.value}', color: const Color(0xFF2E7D32)),
                _StatCard(icon: Icons.pending_actions_outlined, label: 'Orden Pending', value: '${admin.pendingOrderCount.value}', color: const Color(0xFFE65100)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Receita (Orden Kompleta)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(_fmt(admin.totalRevenue.value),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Orden Foun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                TextButton(onPressed: onOpenOrders, child: const Text('Hare hotu')),
              ],
            ),
            const SizedBox(height: 8),
            ...admin.allOrders.take(5).map((o) => _OrderCard(order: o)),
            if (admin.allOrders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Seidauk iha orden', style: TextStyle(color: AppColors.textSecondary))),
              ),
          ],
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Products tab ──────────────────────────────────────────────
class _ProductsTab extends StatelessWidget {
  final void Function(ProductModel, ProductController) onDelete;
  const _ProductsTab({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return Obx(() {
      if (productController.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.dark));
      }
      final products = productController.adminProducts;
      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Seidauk iha produtu', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              const Text('Taka + atu hatama produtu foun', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (_, i) => _ProductAdminCard(
          product: products[i],
          onEdit: () async {
            await Get.to(() => ProductFormScreen(product: products[i]));
            await productController.fetchProductsForAdmin();
            await Get.find<AdminController>().refreshAll();
          },
          onDelete: () => onDelete(products[i], productController),
        ),
      );
    });
  }
}

// ── Orders / transactions tab ─────────────────────────────────
class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    final admin = Get.find<AdminController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Obx(() => Row(
            children: [
              _FilterChip(label: 'Hotu', selected: admin.orderFilter.value == 'all', onTap: () => admin.orderFilter.value = 'all'),
              const SizedBox(width: 8),
              _FilterChip(label: 'Pending', selected: admin.orderFilter.value == 'pending', onTap: () => admin.orderFilter.value = 'pending'),
              const SizedBox(width: 8),
              _FilterChip(label: 'Kompleta', selected: admin.orderFilter.value == 'finished', onTap: () => admin.orderFilter.value = 'finished'),
            ],
          )),
        ),
        Expanded(
          child: Obx(() {
            final orders = admin.filteredOrders;
            if (admin.isLoading.value && orders.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.dark));
            }
            if (orders.isEmpty) {
              return const Center(child: Text('La iha orden', style: TextStyle(color: AppColors.textSecondary)));
            }
            return RefreshIndicator(
              color: AppColors.dark,
              onRefresh: admin.fetchAllOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (_, i) => _OrderCard(order: orders[i]),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.dark : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.dark : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textMedium)),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = Get.find<AdminController>();
    final status = (order['status'] as String?) ?? 'pending';
    final isPending = status == 'pending';
    final total = FormatUtils.parseDouble(order['total']);
    final userId = order['user'] is int ? order['user'] : (order['user']?.toString());
    final customer = admin.userNameFor(userId) ?? '—';
    final items = order['items'] is List ? (order['items'] as List<dynamic>) : [];
    final orderId = order['id']?.toString() ?? '';
    if (orderId.isEmpty) return const SizedBox.shrink();

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'finished':
        statusColor = Colors.green;
        statusLabel = 'Kompleta';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusLabel = 'Kansela';
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('ORD-$orderId',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(statusLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(customer, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
          Text(_formatDate(order['created_at'] as String?),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          ...items.take(3).map((item) {
            final m = item as Map<String, dynamic>;
            final qty = m['quantity'] ?? 1;
            final name = m['product_name'] ?? 'Item';
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('• $name x$qty',
                  style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
            );
          }),
          if (items.length > 3)
            Text('+ ${items.length - 3} seluk',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const Divider(height: 20),
          Row(
            children: [
              Text(FormatUtils.formatPrice(total),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              if (isPending) ...[
                TextButton.icon(
                  onPressed: () => admin.updateOrderStatus(orderId, 'finished'),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Kompleta'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
                TextButton.icon(
                  onPressed: () => admin.updateOrderStatus(orderId, 'cancelled'),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Kansela'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
              if (status == 'finished')
                TextButton.icon(
                  onPressed: () => admin.updateOrderStatus(orderId, 'pending'),
                  icon: const Icon(Icons.replay, size: 18),
                  label: const Text('Pending'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                ),
              if (status == 'finished')
                TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Hamos Orden',
                      middleText: 'Ita boot hakarak hamos orden ORD-$orderId?',
                      textConfirm: 'Hamos',
                      textCancel: 'Lae',
                      confirmTextColor: AppColors.white,
                      buttonColor: Colors.red,
                      onConfirm: () {
                        Get.back();
                        admin.deleteOrder(orderId);
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hamos'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          if ((order['address'] as String?)?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Morada: ${order['address']}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ),
          if ((order['payment_method'] as String?)?.isNotEmpty == true)
            Text('Pagamentu: ${order['payment_method']}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Categories tab ──────────────────────────────────────────
class _CategoriesTab extends StatelessWidget {
  final void Function(Map<String, dynamic> category)? onEditCategory;
  const _CategoriesTab({this.onEditCategory});

  @override
  Widget build(BuildContext context) {
    final admin = Get.find<AdminController>();

    return Obx(() {
      if (admin.isLoading.value && admin.categories.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.dark));
      }
      final cats = admin.categories;
      if (cats.isEmpty) {
        return const Center(
            child: Text('Seidauk iha kategoria', style: TextStyle(color: AppColors.textSecondary)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final cat = cats[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                const Icon(Icons.category, color: AppColors.textPrimary),
                const SizedBox(width: 16),
                Expanded(child: Text(cat['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                  onPressed: () {
                    if (onEditCategory != null) onEditCategory!(cat);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Hamos Kategoria',
                      middleText: 'Ita boot hakarak hamos "${cat['name']}"?',
                      textConfirm: 'Hamos',
                      textCancel: 'Lae',
                      confirmTextColor: AppColors.white,
                      buttonColor: AppColors.red,
                      onConfirm: () {
                        Get.back();
                        admin.deleteCategory(cat['id']);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

// ── Users tab ─────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final admin = Get.find<AdminController>();

    return Obx(() {
      if (admin.isLoading.value && admin.allUsers.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.dark));
      }
      final users = admin.allUsers;
      return RefreshIndicator(
        color: AppColors.dark,
        onRefresh: admin.fetchAllUsers,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.people, color: AppColors.white, size: 36),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Uzuáriu Rejistadu',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('${admin.userCount.value}',
                          style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...users.map((u) {
              final role = (u['role'] as String?) ?? 'customer';
              final isAdmin = role == 'admin';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isAdmin ? AppColors.dark : AppColors.border,
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: isAdmin ? AppColors.white : AppColors.textMedium,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u['name'] as String? ?? '—',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(u['email'] as String? ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          if ((u['phone'] as String?)?.isNotEmpty == true)
                            Text(u['phone'] as String,
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? AppColors.dark.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAdmin ? 'Admin' : 'Customer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAdmin ? AppColors.textPrimary : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (users.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Seidauk iha uzuáriu',
                    style: TextStyle(color: AppColors.textSecondary))),
              ),
          ],
        ),
      );
    });
  }
}

// ── Product Admin Card ────────────────────────────────────────
class _ProductAdminCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ProductAdminCard({required this.product, required this.onEdit, required this.onDelete});

  String _fmt(double price) => FormatUtils.formatPrice(price);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70, height: 70,
              color: AppColors.imageBg,
              child: product.firstImage.isNotEmpty
                  ? Image.network(product.firstImage, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: AppColors.placeholder))
                  : const Icon(Icons.shopping_bag, color: AppColors.placeholder, size: 32),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(_fmt(product.price),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Stok: ${product.stock}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: product.stock > 0 ? Colors.green : Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.dark.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


