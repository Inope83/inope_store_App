import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartController cartController = Get.find();
  final OrderController orderController = Get.find();
  final AuthController authController = Get.find();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController bankAccountController = TextEditingController();
  final TextEditingController bankAddressController = TextEditingController();
  String selectedPaymentMethod = 'cod';
  String? selectedBank;
  bool isCreatingOrder = false;

  String _fmt(double price) {
    final intPart = price.toInt();
    final formatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '\$$formatted';
  }

  Future<void> _handlePlaceOrder() async {
    String address, phone, email;
    if (selectedPaymentMethod == 'cod') {
      address = addressController.text.trim();
      phone = authController.currentUser.value?.phone ?? '';
      email = authController.currentUser.value?.email ?? '';
      if (address.isEmpty) {
        Get.snackbar(
          'Sala',
          'Favór hatama diresaun entrega nian.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    } else {
      final bankAccount = bankAccountController.text.trim();
      final bankAddr = bankAddressController.text.trim();
      if (selectedBank == null) {
        Get.snackbar('Sala', 'Favór hili banku transfere nian.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
        return;
      }
      if (bankAccount.isEmpty) {
        Get.snackbar('Sala', 'Favór hatama númeru konta banku.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
        return;
      }
      address = bankAddr;
      phone = '';
      email = '';
    }

    setState(() => isCreatingOrder = true);

    final paymentLabel = selectedPaymentMethod == 'cod'
        ? 'Selu iha fatin (COD)'
        : 'Transferénsia Bankária - $selectedBank (${bankAccountController.text.trim()})';

    // Re-validate stock before placing order
    final productController = Get.find<ProductController>();
    for (final item in cartController.items) {
      final product = productController.getProductById(item.productId);
      if (product == null) {
        Get.snackbar('Sala', "Produtu '${item.productName}' la iha",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        setState(() => isCreatingOrder = false);
        return;
      }
      if (product.stock < item.quantity) {
        Get.snackbar('Stock La To\'o',
            "'${item.productName}' stock disponivel: ${product.stock}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
        setState(() => isCreatingOrder = false);
        return;
      }
    }

    final success = await orderController.createOrder(
      address: address,
      phone: phone,
      email: email,
      paymentMethod: paymentLabel,
    );

    setState(() => isCreatingOrder = false);

    if (success) {
      Get.defaultDialog(
        title: 'Pedidu Suksesu',
        middleText: 'Obrigadu barak! Ita-boot nia pedidu rejista ona.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF1A1A1A),
        onConfirm: () {
          Get.back();
          Get.offAllNamed('/home');
        },
        barrierDismissible: false,
      );
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    bankAccountController.dispose();
    bankAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double totalPayable = cartController.totalPrice.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              _buildSectionTitle('Métodu Pagamentu'),
              const SizedBox(height: 8),
              _buildCodOption(),
              if (selectedPaymentMethod == 'cod') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Naran dalan, suku, postu, munisípiu...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF1A1A1A), width: 1.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoField(
                        icon: Icons.phone_outlined,
                        value: authController.currentUser.value?.phone ?? '',
                        hint: 'Telefone',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoField(
                        icon: Icons.email_outlined,
                        value: authController.currentUser.value?.email ?? '',
                        hint: 'Email',
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _buildBankOption(),

              const SizedBox(height: 20),

              _buildSectionTitle('Resumu Pedidu'),
              const SizedBox(height: 8),
              Container(
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
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: cartController.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (_, index) {
                    final item = cartController.items[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: const Color(0xFFF0F0F0),
                            child: item.productImage.isNotEmpty
                                ? Image.network(
                                    item.productImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.shopping_bag,
                                      color: Color(0xFFCCCCCC),
                                    ),
                                  )
                                : const Icon(Icons.shopping_bag,
                                    color: Color(0xFFCCCCCC)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} x ${_fmt(item.price)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _fmt(item.subtotal),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              _buildSectionTitle('Detalle Pagamentu'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
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
                    _buildPriceRow(
                        'Subtotal', _fmt(cartController.totalPrice.value)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pagamentu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          _fmt(totalPayable),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              CustomButton(
                onPressed: _handlePlaceOrder,
                text: 'Konfirma Pedidu',
                isLoading: isCreatingOrder,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
         style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
        )
      ),
    );
  }

  Widget _buildCodOption() {
    final bool isSelected = selectedPaymentMethod == 'cod';
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = 'cod'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.handshake_outlined,
                color: isSelected ? Colors.white : const Color(0xFF666666),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selu iha fatin (COD)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF444444),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Sosa-na\'in selu bainhira produtu to\'o',
                    style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFCCCCCC),
                  width: isSelected ? 2 : 1.5,
                ),
                color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankOption() {
    final bool isSelected = selectedPaymentMethod == 'bank';
    final banks = ['BNU', 'Telemor', 'BNCTL'];
    return GestureDetector(
      onTap: () => setState(() {
        selectedPaymentMethod = 'bank';
        selectedBank = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.fromLTRB(16, 16, 16, isSelected ? 4 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.account_balance_outlined,
                    color: isSelected ? Colors.white : const Color(0xFF666666),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transferénsia Bankária',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Rede bancária no digital',
                        style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFCCCCCC),
                      width: isSelected ? 2 : 1.5,
                    ),
                    color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hili banku transfere nian',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: banks.map((bank) => _buildBankChip(bank)).toList(),
                    ),
                    if (selectedBank != null) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: bankAccountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Númeru konta banku',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: bankAddressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Diresaun banku (opsional)',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankChip(String name) {
    final icons = {
      'BNU': Icons.account_balance,
      'Telemor': Icons.phone_android,
      'BNCTL': Icons.business,
    };
    final isActive = selectedBank == name;
    return GestureDetector(
      onTap: () => setState(() {
        selectedBank = name;
        bankAccountController.clear();
        bankAddressController.clear();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icons[name] ?? Icons.business,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF444444),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF444444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String value,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF888888)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : hint,
              style: TextStyle(
                fontSize: 14,
                color: value.isNotEmpty
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFBBBBBB),
              ),
            ),
          ),
          const Icon(Icons.check_circle,
              size: 16, color: Color(0xFF4CAF50)),
        ],
      ),
    );
  }
}

