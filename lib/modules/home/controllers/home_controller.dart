import 'package:get/get.dart';
import '../../../data/models/store_model.dart';
import '../../../data/repositories/store_repository.dart';
import '../../../data/repositories/address_repository.dart';

class HomeController extends GetxController {
  final StoreRepository _repo;
  final AddressRepository _addressRepo;
  HomeController(this._repo, this._addressRepo);

  final isLoading = false.obs;
  final restaurants = <StoreModel>[].obs;
  final stores = <StoreModel>[].obs;
  final deliveryAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final rResult = await _repo.getRestaurants(limit: 6);
      final sResult = await _repo.getStores(limit: 6);
      restaurants.value = rResult.items;
      stores.value = sResult.items;
    } catch (_) {
      restaurants.value = _mockRestaurants();
      stores.value = _mockStores();
    } finally {
      isLoading.value = false;
    }
    _fetchDeliveryAddress();
  }

  Future<void> _fetchDeliveryAddress() async {
    try {
      final addresses = await _addressRepo.getAddresses();
      if (addresses.isNotEmpty) {
        final defaultAddr = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        deliveryAddress.value = defaultAddr.address;
      }
    } catch (_) {
      // Silent fail — view shows "Set your location"
    }
  }

  List<StoreModel> _mockRestaurants() => [
        StoreModel(
          id: '1',
          name: 'Burger Lab',
          type: 'restaurant',
          rating: 4.7,
          reviewCount: 320,
          deliveryTime: 30,
          deliveryFee: 49,
          categories: ['Burgers', 'Fast Food', 'Wraps'],
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
          categories: ['Desi', 'Biryani', 'Rice'],
          isOpen: true,
        ),
        StoreModel(
          id: '3',
          name: 'Pizza Point',
          type: 'restaurant',
          rating: 4.2,
          reviewCount: 95,
          deliveryTime: 25,
          deliveryFee: 59,
          categories: ['Pizza', 'Italian', 'Fast Food'],
          isOpen: true,
        ),
        StoreModel(
          id: '4',
          name: 'Savour Restaurant',
          type: 'restaurant',
          rating: 4.6,
          reviewCount: 240,
          deliveryTime: 35,
          deliveryFee: 49,
          categories: ['Pakistani', 'Desi'],
          isOpen: true,
        ),
      ];

  List<StoreModel> _mockStores() => [
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
          id: '6',
          name: 'Imtiaz Super Market',
          type: 'store',
          rating: 4.1,
          reviewCount: 89,
          deliveryTime: 30,
          deliveryFee: 79,
          categories: ['Grocery', 'Fresh Food'],
          isOpen: true,
        ),
        StoreModel(
          id: '7',
          name: 'Al-Fatah Stores',
          type: 'store',
          rating: 4.4,
          reviewCount: 156,
          deliveryTime: 20,
          deliveryFee: 49,
          categories: ['Grocery', 'General'],
          isOpen: true,
        ),
      ];
}
