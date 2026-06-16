import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void goToTab(int index) => currentIndex.value = index;
  void goToShop() => currentIndex.value = 1;
  void goToCart() => currentIndex.value = 2;
}
