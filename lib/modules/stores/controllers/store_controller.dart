import 'package:get/get.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/store_repository.dart';

class StoreController extends GetxController {
  final StoreRepository _repo;
  StoreController(this._repo);

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isProductsLoading = false.obs;
  final stores = <StoreModel>[].obs;
  final products = <ProductModel>[].obs;
  final selectedFilter = 'All'.obs;
  final selectedCategory = ''.obs;
  final currentStore = Rxn<StoreModel>();

  final filters = ['All', 'Grocery', 'Supermarket', 'Fresh Food', 'General'].obs;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
    final args = Get.arguments;
    if (args is StoreModel) {
      currentStore.value = args;
      fetchProducts(args.id);
    }
  }

  Future<void> fetchStores() async {
    try {
      isLoading.value = true;
      _currentPage = 1;
      final result = await _repo.getStores(page: 1);
      _totalPages = result.totalPages;
      stores.value = result.items;
    } catch (e) {
      stores.value = _mockStores();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreStores() async {
    if (!hasMore || isLoadingMore.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;
      final result = await _repo.getStores(page: _currentPage);
      _totalPages = result.totalPages;
      stores.addAll(result.items);
    } catch (_) {
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void setStoreIfNeeded(StoreModel store) {
    if (currentStore.value?.id != store.id) {
      currentStore.value = store;
      fetchProducts(store.id);
    }
  }

  Future<void> fetchProducts(String storeId) async {
    try {
      isProductsLoading.value = true;
      products.value = await _repo.getStoreProducts(storeId);
    } catch (e) {
      products.value = _mockProducts(storeId);
    } finally {
      isProductsLoading.value = false;
    }
  }

  List<StoreModel> get filteredStores {
    if (selectedFilter.value == 'All') return stores;
    return stores
        .where((s) => s.categories
            .any((c) => c.toLowerCase().contains(selectedFilter.value.toLowerCase())))
        .toList();
  }

  List<ProductModel> get filteredProducts {
    if (selectedCategory.value.isEmpty) return products;
    return products.where((p) => p.category == selectedCategory.value).toList();
  }

  List<String> get productCategories {
    final cats = products.map((p) => p.category ?? 'Other').toSet().toList();
    return ['All', ...cats];
  }

  List<StoreModel> _mockStores() => [
        StoreModel(id: '5', name: 'Metro Superstore', type: 'store', rating: 4.3, reviewCount: 120, deliveryTime: 25, deliveryFee: 99, categories: ['Grocery', 'Supermarket'], isOpen: true),
        StoreModel(id: '6', name: 'Imtiaz Super Market', type: 'store', rating: 4.1, reviewCount: 89, deliveryTime: 30, deliveryFee: 79, categories: ['Grocery', 'Fresh Food'], isOpen: true),
        StoreModel(id: '7', name: 'Al-Fatah Stores', type: 'store', rating: 4.4, reviewCount: 156, deliveryTime: 20, deliveryFee: 49, categories: ['Grocery', 'General'], isOpen: true),
        StoreModel(id: '8', name: 'Carrefour', type: 'store', rating: 4.5, reviewCount: 200, deliveryTime: 35, deliveryFee: 99, categories: ['Grocery', 'Supermarket'], isOpen: true),
      ];

  List<ProductModel> _mockProducts(String storeId) => [
        ProductModel(id: 'p1', name: 'Whole Milk 1L', description: 'Fresh whole milk', price: 180, category: 'Dairy', isAvailable: true, storeId: storeId),
        ProductModel(id: 'p2', name: 'Brown Bread Loaf', description: 'Whole wheat bread loaf', price: 120, category: 'Bakery', isAvailable: true, storeId: storeId),
        ProductModel(id: 'p3', name: 'Basmati Rice 5kg', description: 'Premium aged basmati rice', price: 1200, category: 'Grains', isAvailable: true, storeId: storeId),
        ProductModel(id: 'p4', name: 'Desi Ghee 1kg', description: 'Pure desi ghee', price: 2200, category: 'Dairy', isAvailable: true, storeId: storeId),
        ProductModel(id: 'p5', name: 'Chicken Breast 1kg', description: 'Fresh boneless chicken breast', price: 650, category: 'Meat', isAvailable: true, storeId: storeId),
        ProductModel(id: 'p6', name: 'Tomatoes 1kg', description: 'Fresh ripe tomatoes', price: 80, category: 'Vegetables', isAvailable: true, storeId: storeId),
        ProductModel(id: 'p7', name: 'Orange Juice 1L', description: 'Fresh squeezed orange juice', price: 250, category: 'Beverages', isAvailable: true, storeId: storeId),
        ProductModel(id: 'p8', name: 'Eggs 12 Pack', description: 'Farm fresh eggs', price: 280, category: 'Dairy', isAvailable: true, storeId: storeId),
      ];
}
