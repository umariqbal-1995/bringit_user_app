import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../../../data/repositories/order_repository.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderRepository());
    Get.lazyPut(() => OrderController(Get.find()));
  }
}
