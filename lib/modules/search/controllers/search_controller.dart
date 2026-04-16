import 'package:get/get.dart';
import '../../../data/models/store_model.dart';
import '../../../data/repositories/store_repository.dart';

class AppSearchController extends GetxController {
  final StoreRepository _repo;
  AppSearchController(this._repo);

  final query = ''.obs;
  final isLoading = false.obs;
  final allStores = <StoreModel>[].obs;
  final selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      isLoading.value = true;
      final rResult = await _repo.getRestaurants(limit: 50);
      final sResult = await _repo.getStores(limit: 50);
      allStores.value = [...rResult.items, ...sResult.items];
    } catch (e) {
      allStores.value = _mockAll();
    } finally {
      isLoading.value = false;
    }
  }

  List<StoreModel> get searchResults {
    List<StoreModel> filtered;
    switch (selectedFilter.value) {
      case 'Food':
        filtered = allStores.where((s) => s.type == 'restaurant').toList();
        break;
      case 'Grocery':
        filtered = allStores.where((s) => s.type == 'store').toList();
        break;
      default:
        filtered = allStores.toList();
    }

    if (query.value.isEmpty) return filtered;

    final q = query.value.toLowerCase();
    return filtered.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.categories.any((c) => c.toLowerCase().contains(q));
    }).toList();
  }

  List<StoreModel> _mockAll() => [
        StoreModel(id: '1', name: 'Burger Lab', type: 'restaurant', rating: 4.7, categories: ['Burgers', 'Fast Food'], deliveryTime: 30, deliveryFee: 49, isOpen: true),
        StoreModel(id: '2', name: 'Biryani Chaska', type: 'restaurant', rating: 4.5, categories: ['Desi', 'Biryani'], deliveryTime: 40, deliveryFee: 0, isOpen: true),
        StoreModel(id: '3', name: 'Pizza Point', type: 'restaurant', rating: 4.2, categories: ['Pizza', 'Fast Food'], deliveryTime: 25, deliveryFee: 59, isOpen: true),
        StoreModel(id: '4', name: 'Savour Restaurant', type: 'restaurant', rating: 4.6, categories: ['Pakistani', 'Desi'], deliveryTime: 35, deliveryFee: 49, isOpen: true),
        StoreModel(id: '5', name: 'Metro Superstore', type: 'store', rating: 4.3, categories: ['Grocery', 'Supermarket'], deliveryTime: 25, deliveryFee: 99, isOpen: true),
        StoreModel(id: '6', name: 'Imtiaz Super Market', type: 'store', rating: 4.1, categories: ['Grocery', 'Fresh Food'], deliveryTime: 30, deliveryFee: 79, isOpen: true),
        StoreModel(id: '7', name: 'Al-Fatah Stores', type: 'store', rating: 4.4, categories: ['Grocery', 'General'], deliveryTime: 20, deliveryFee: 49, isOpen: true),
      ];
}
