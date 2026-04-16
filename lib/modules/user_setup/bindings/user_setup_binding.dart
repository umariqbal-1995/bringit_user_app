import 'package:get/get.dart';
import '../controllers/user_setup_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/address_repository.dart';

class UserSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserSetupController(AuthRepository(), AddressRepository()));
  }
}
