import 'package:get/get.dart';
import '../../../data/models/store_model.dart';
import '../../../data/repositories/store_repository.dart';

class FavouritesController extends GetxController {
  final StoreRepository _repo;
  FavouritesController(this._repo);

  final isLoading = false.obs;
  final favourites = <StoreModel>[].obs;
  final selectedTab = 0.obs; // 0=All, 1=Restaurants, 2=Stores

  @override
  void onInit() {
    super.onInit();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    try {
      isLoading.value = true;
      favourites.value = await _repo.getFavorites();
    } catch (e) {
      favourites.value = _mockFavourites();
    } finally {
      isLoading.value = false;
    }
  }

  List<StoreModel> get filteredFavourites {
    switch (selectedTab.value) {
      case 1:
        return favourites.where((s) => s.type == 'restaurant').toList();
      case 2:
        return favourites.where((s) => s.type == 'store').toList();
      default:
        return favourites;
    }
  }

  Future<void> toggleFavourite(StoreModel store) async {
    final idx = favourites.indexWhere((s) => s.id == store.id);
    if (idx >= 0) {
      favourites.removeAt(idx);
      try {
        await _repo.removeFavorite(store.id);
      } catch (_) {}
    } else {
      favourites.add(store);
      try {
        await _repo.addFavorite(store.id);
      } catch (_) {}
    }
  }

  bool isFavourite(String storeId) =>
      favourites.any((s) => s.id == storeId);

  List<StoreModel> _mockFavourites() => [
        StoreModel(
          id: '1',
          name: 'Burger Lab',
          type: 'restaurant',
          rating: 4.7,
          reviewCount: 320,
          deliveryTime: 30,
          deliveryFee: 49,
          categories: ['Burgers', 'Fast Food'],
          isOpen: true,
        ),
        StoreModel(
          id: '5',
          name: 'Metro Superstore',
          type: 'store',
          rating: 4.3,
          reviewCount: 120,
          deliveryTime: 25,
          deliveryFee: 99,
          categories: ['Grocery', 'Supermarket'],
          isOpen: true,
        ),
        StoreModel(
          id: '2',
          name: 'Biryani Chaska',
          type: 'restaurant',
          rating: 4.5,
          reviewCount: 180,
          deliveryTime: 40,
          deliveryFee: 0,
          categories: ['Desi', 'Biryani'],
          isOpen: true,
        ),
      ];
}
