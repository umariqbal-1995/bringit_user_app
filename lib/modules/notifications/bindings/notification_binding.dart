import 'package:get/get.dart';
import '../controllers/notification_controller.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationRepository());
    Get.lazyPut(() => NotificationController(Get.find()));
  }
}
