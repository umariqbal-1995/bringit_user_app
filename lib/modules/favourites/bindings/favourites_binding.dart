import 'package:get/get.dart';
import '../controllers/favourites_controller.dart';
import '../../../data/repositories/store_repository.dart';

class FavouritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoreRepository());
    Get.lazyPut(() => FavouritesController(Get.find()));
  }
}
