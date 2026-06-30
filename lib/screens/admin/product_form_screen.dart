import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _originalPriceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  int? _selectedCategoryId;
  final List<String> _existingImageUrls = [];
  final List<XFile> _newImageFiles = [];
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _selectedCategoryId = p.categoryId;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _originalPriceCtrl.text = p.originalPrice?.toStringAsFixed(0) ?? '';
      _descCtrl.text = p.description;
      _stockCtrl.text = p.stock.toString();
      _existingImageUrls.addAll(p.imageUrls);
      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 75);
    if (picked.isNotEmpty) {
      setState(() => _newImageFiles.addAll(picked));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImageUrls.isEmpty && _newImageFiles.isEmpty) {
      Get.snackbar('Avizu', 'Hatama foto minimu ida',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final isEdit = widget.product != null;
      final path = isEdit ? '/products/${widget.product!.id}/' : '/products/';

        final fields = <String, String>{
          'name': _nameCtrl.text.trim(),
          'category': _selectedCategoryId.toString(),
          'price': _priceCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'stock': _stockCtrl.text.trim(),
          'is_active': _isActive.toString(),
          if (isEdit) 'existing_images': _existingImageUrls.join(','),
        };
        if (_originalPriceCtrl.text.trim().isNotEmpty) {
          fields['original_price'] = _originalPriceCtrl.text.trim();
        }

      if (isEdit && _newImageFiles.isEmpty) {
        final res = await api.put(path, body: fields);
        if (res.statusCode != 200) {
          Get.snackbar('Error', 'Falha atualiza produtu: ${res.body}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          return;
        }
      } else {
        if (isEdit) {
          fields['existing_images'] = _existingImageUrls.join(',');
        }
        final fileBytes = <Uint8List>[];
        final fileNames = <String>[];
        for (final file in _newImageFiles) {
          final bytes = await file.readAsBytes();
          fileBytes.add(bytes);
          fileNames.add(file.name);
        }
        final res = await api.uploadFiles(
          path,
          fileBytes,
          fileNames: fileNames,
          fields: fields,
          method: isEdit ? 'PUT' : 'POST',
        );
        if (res.statusCode != 200 && res.statusCode != 201) {
          Get.snackbar('Error', 'Falha salva produtu: ${res.body}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          return;
        }
      }

      await Get.find<ProductController>().fetchProductsForAdmin();
      await Get.find<ProductController>().fetchProducts();
      await Get.find<AdminController>().refreshAll();
      Get.back();
      Get.snackbar('Suksesu',
          isEdit ? 'Produtu atualiza ona' : 'Produtu foun hatama ona',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Falha: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: Text(isEdit ? 'Edita Produtu' : 'Produtu Foun',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionLabel('Foto Produtu'),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._existingImageUrls.asMap().entries.map(
                    (e) => _ImageThumb(
                      child: Image.network(e.value, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: AppColors.placeholder)),
                      onRemove: () => setState(() => _existingImageUrls.removeAt(e.key)),
                    ),
                  ),
                  ..._newImageFiles.asMap().entries.map(
                    (e) => _ImageThumb(
                      child: FutureBuilder<Uint8List>(
                        future: e.value.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(snapshot.data!, fit: BoxFit.cover);
                          }
                          return const Icon(Icons.image, color: AppColors.placeholder);
                        },
                      ),
                      onRemove: () => setState(() => _newImageFiles.removeAt(e.key)),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100, height: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.dark),
                          SizedBox(height: 4),
                          Text('Foto', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Info Produtu'),
            const SizedBox(height: 8),
            _Field(controller: _nameCtrl, label: 'Naran Produtu',
                validator: (v) => v!.isEmpty ? 'Hatama naran produtu' : null),
            const SizedBox(height: 12),
            Obx(() {
              final admin = Get.find<AdminController>();
              final cats = admin.categories;
              if (cats.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.orange),
                      SizedBox(width: 12),
                      Expanded(child: Text(
                          'Kategoria seidauk iha. Favór kria uluk kategoria iha tab Kategoria.',
                          style: TextStyle(fontSize: 12, color: AppColors.orange))),
                    ],
                  ),
                );
              }
              return DropdownButtonFormField<int>(
                value: cats.any((c) => c['id'] == _selectedCategoryId)
                    ? _selectedCategoryId
                    : null,
                items: cats.map((c) {
                  final name = c['name'] as String;
                  final id = c['id'] as int;
                  return DropdownMenuItem(value: id, child: Text(name));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategoryId = v);
                },
                decoration: InputDecoration(
                  labelText: 'Kategoria',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border)),
                ),
                validator: (v) => v == null ? 'Hili kategoria' : null,
              );
            }),
            const SizedBox(height: 12),
            _Field(controller: _descCtrl, label: 'Deskrisaun', maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Hatama deskrisaun' : null),
            const SizedBox(height: 20),
            _sectionLabel('Harga & Stok'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Field(controller: _priceCtrl, label: 'Harga (\$)',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Hatama harga';
                        final n = double.tryParse(v);
                        if (n == null) return 'Numeru deit';
                        if (n < 0) return 'Harga labele negativu';
                        return null;
                      }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(controller: _originalPriceCtrl, label: 'Harga Original (opsional)',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isNotEmpty && double.tryParse(v) == null) return 'Numeru deit';
                        return null;
                      }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(controller: _stockCtrl, label: 'Jumlah Stok',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Hatama stok';
                  final n = int.tryParse(v);
                  if (n == null) return 'Numeru deit';
                  if (n < 0) return 'Stok labele negativu';
                  return null;
                }),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Produtu Ativu',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeThumbColor: AppColors.dark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _isLoading ? null : _save,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: _isLoading ? AppColors.textSecondary : AppColors.dark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEdit ? 'Salva Mudansa' : 'Hatama Produtu',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
}

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  const _ImageThumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, height: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: 100, height: 100, child: child),
          ),
          Positioned(
            top: 4, right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const _Field({
    required this.controller, required this.label,
    this.maxLines = 1, this.keyboardType = TextInputType.text, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dark, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.red, width: 2)),
      ),
    );
  }
}
