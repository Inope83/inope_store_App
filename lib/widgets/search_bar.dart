import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => productController.setSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Halo kbusa produtu...',
          prefixIcon:
              const Icon(Icons.search, size: 18, color: Color(0xFFAAAAAA)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2D2D2D), width: 1)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
