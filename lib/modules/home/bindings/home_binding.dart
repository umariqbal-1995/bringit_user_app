import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/repositories/store_repository.dart';
import '../../../data/repositories/address_repository.dart';
import '../../cart/controllers/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoreRepository());
    Get.lazyPut(() => AddressRepository());
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
    Get.lazyPut(() => HomeController(Get.find(), Get.find()));
  }
}
