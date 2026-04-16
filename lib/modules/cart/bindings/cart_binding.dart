import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../data/repositories/cart_repository.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartRepository());
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
  }
}
