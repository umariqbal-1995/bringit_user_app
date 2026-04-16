import 'package:get/get.dart';
import '../controllers/restaurant_controller.dart';
import '../../../data/repositories/store_repository.dart';
import '../../cart/controllers/cart_controller.dart';

class RestaurantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoreRepository());
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
    Get.lazyPut(() => RestaurantController(Get.find()));
  }
}
