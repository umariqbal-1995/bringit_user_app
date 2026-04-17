import 'package:get/get.dart';
import '../controllers/track_order_controller.dart';
import '../../../data/repositories/order_repository.dart';

class TrackOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderRepository());
    Get.lazyPut(() => TrackOrderController(Get.find()));
  }
}
