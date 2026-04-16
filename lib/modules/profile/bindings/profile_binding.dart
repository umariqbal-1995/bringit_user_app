import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/address_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthRepository());
    Get.lazyPut(() => AddressRepository());
    Get.lazyPut(() => ProfileController(Get.find(), Get.find()));
  }
}
