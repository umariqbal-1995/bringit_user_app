import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/address_repository.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderRepository());
    Get.lazyPut(() => AddressRepository());
    Get.lazyPut(() => CheckoutController(Get.find(), Get.find()));
  }
}
