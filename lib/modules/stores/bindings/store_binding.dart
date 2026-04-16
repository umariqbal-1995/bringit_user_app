import 'package:get/get.dart';
import '../controllers/store_controller.dart';
import '../../../data/repositories/store_repository.dart';
import '../../cart/controllers/cart_controller.dart';

class StoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoreRepository());
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
    Get.lazyPut(() => StoreController(Get.find()));
  }
}
