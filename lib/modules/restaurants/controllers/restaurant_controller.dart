import 'package:get/get.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/store_repository.dart';

class RestaurantController extends GetxController {
  final StoreRepository _repo;
  RestaurantController(this._repo);

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isMenuLoading = false.obs;
  final restaurants = <StoreModel>[].obs;
  final menuItems = <MenuItemModel>[].obs;
  final selectedFilter = 'All'.obs;
  final selectedCategory = ''.obs;
  final currentStore = Rxn<StoreModel>();

  final filters = ['All', 'Fast Food', 'Desi', 'Pizza', 'BBQ', 'Biryani'].obs;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
    final args = Get.arguments;
    if (args is StoreModel) {
      currentStore.value = args;
      fetchMenu(args.id);
    }
  }

  Future<void> fetchRestaurants() async {
    try {
      isLoading.value = true;
      _currentPage = 1;
      final result = await _repo.getRestaurants(page: 1);
      _totalPages = result.totalPages;
      restaurants.value = result.items;
    } catch (e) {
      restaurants.value = _mockRestaurants();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreRestaurants() async {
    if (!hasMore || isLoadingMore.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;
      final result = await _repo.getRestaurants(page: _currentPage);
      _totalPages = result.totalPages;
      restaurants.addAll(result.items);
    } catch (_) {
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void setStoreIfNeeded(StoreModel store) {
    if (currentStore.value?.id != store.id) {
      currentStore.value = store;
      fetchMenu(store.id);
    }
  }

  Future<void> fetchMenu(String storeId) async {
    try {
      isMenuLoading.value = true;
      menuItems.value = await _repo.getRestaurantMenu(storeId);
    } catch (e) {
      menuItems.value = _mockMenu(storeId);
    } finally {
      isMenuLoading.value = false;
    }
  }

  List<StoreModel> get filteredRestaurants {
    if (selectedFilter.value == 'All') return restaurants;
    return restaurants
        .where((r) => r.categories
            .any((c) => c.toLowerCase().contains(selectedFilter.value.toLowerCase())))
        .toList();
  }

  List<MenuItemModel> get filteredMenu {
    if (selectedCategory.value.isEmpty) return menuItems;
    return menuItems
        .where((m) => m.category == selectedCategory.value)
        .toList();
  }

  List<String> get menuCategories {
    final cats = menuItems.map((m) => m.category ?? 'Other').toSet().toList();
    return ['All', ...cats];
  }

  List<StoreModel> _mockRestaurants() => [
        StoreModel(id: '1', name: 'Burger Lab', type: 'restaurant', rating: 4.7, reviewCount: 320, deliveryTime: 30, deliveryFee: 49, categories: ['Burgers', 'Fast Food', 'Wraps'], isOpen: true),
        StoreModel(id: '2', name: 'Biryani Chaska', type: 'restaurant', rating: 4.5, reviewCount: 180, deliveryTime: 40, deliveryFee: 0, categories: ['Desi', 'Biryani', 'Rice'], isOpen: true),
        StoreModel(id: '3', name: 'Pizza Point', type: 'restaurant', rating: 4.2, reviewCount: 95, deliveryTime: 25, deliveryFee: 59, categories: ['Pizza', 'Italian', 'Fast Food'], isOpen: true),
        StoreModel(id: '4', name: 'Savour Restaurant', type: 'restaurant', rating: 4.6, reviewCount: 240, deliveryTime: 35, deliveryFee: 49, categories: ['Pakistani', 'Desi', 'BBQ'], isOpen: true),
        StoreModel(id: '5', name: 'Grill Station', type: 'restaurant', rating: 4.3, reviewCount: 110, deliveryTime: 45, deliveryFee: 59, categories: ['BBQ', 'Grills', 'Steaks'], isOpen: true),
      ];

  List<MenuItemModel> _mockMenu(String storeId) => [
        MenuItemModel(id: 'm1', name: 'Classic Burger', description: 'Juicy beef patty with fresh vegetables', price: 650, category: 'Burgers', isAvailable: true, storeId: storeId),
        MenuItemModel(id: 'm2', name: 'Double Smash Burger', description: 'Double smashed beef patties with special sauce', price: 950, category: 'Burgers', isAvailable: true, storeId: storeId),
        MenuItemModel(id: 'm3', name: 'Crispy Chicken Burger', description: 'Crunchy fried chicken fillet with coleslaw', price: 750, category: 'Burgers', isAvailable: true, storeId: storeId),
        MenuItemModel(id: 'm4', name: 'Zinger Wrap', description: 'Spicy chicken wrap with fresh veggies', price: 550, category: 'Wraps', isAvailable: true, storeId: storeId),
        MenuItemModel(id: 'm5', name: 'Loaded Fries', description: 'Crispy fries topped with cheese and jalapenos', price: 350, category: 'Sides', isAvailable: true, storeId: storeId),
        MenuItemModel(id: 'm6', name: 'Onion Rings', description: 'Golden fried onion rings', price: 250, category: 'Sides', isAvailable: true, storeId: storeId),
        MenuItemModel(id: 'm7', name: 'Chocolate Shake', description: 'Rich creamy chocolate milkshake', price: 350, category: 'Drinks', isAvailable: true, storeId: storeId),
        MenuItemModel(id: 'm8', name: 'Fresh Lemonade', description: 'Chilled lemon drink with mint', price: 200, category: 'Drinks', isAvailable: true, storeId: storeId),
      ];
}
