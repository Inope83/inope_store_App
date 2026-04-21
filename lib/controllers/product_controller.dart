import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class ProductController extends GetxController {
  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<Product> featuredProducts = <Product>[].obs;
  final RxList<Product> newProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'Hotu'.obs;
  final RxString searchQuery = ''.obs;

  final List<String> categories = [
    'Hotu',
    'Sapatu',
    'Topu',
    'Kalsa',
    'Vestidu',
    'Bolsa'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      Database db = await DatabaseHelper().database;
      List<Map<String, dynamic>> result = await db.query('products');

      allProducts.value = result.map((e) => Product.fromJson(e)).toList();
      featuredProducts.value = allProducts.where((p) => p.isFeatured).toList();
      newProducts.value = allProducts.where((p) => p.isNew).toList();
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> get filteredProducts {
    List<Product> products = allProducts;
    if (selectedCategory.value != 'Hotu') {
      products =
          products.where((p) => p.category == selectedCategory.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
    return products;
  }

  void setCategory(String category) => selectedCategory.value = category;
  void setSearchQuery(String query) => searchQuery.value = query;
}
