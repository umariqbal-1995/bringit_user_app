import 'package:get/get.dart';
import '../controllers/search_controller.dart';
import '../../../data/repositories/store_repository.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoreRepository());
    Get.lazyPut(() => AppSearchController(Get.find()));
  }
}
