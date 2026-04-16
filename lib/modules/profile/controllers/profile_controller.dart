import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../routes/app_routes.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;
  PlaceSuggestion({required this.placeId, required this.description});
}

class ProfileController extends GetxController {
  // ignore: unused_field
  final AuthRepository _authRepo;
  final AddressRepository _addressRepo;

  ProfileController(this._authRepo, this._addressRepo);

  final _storage = StorageService();
  final isLoading = false.obs;
  final user = Rxn<UserModel>();
  final addresses = <AddressModel>[].obs;
  final selectedLabel = 'Home'.obs;

  // Map state
  final selectedLat = 31.5204.obs;
  final selectedLng = 74.3587.obs;
  final isLocating = false.obs;
  final isSearching = false.obs;
  final placeSuggestions = <PlaceSuggestion>[].obs;
  final mapAddressController = TextEditingController();

  final _placesClient = Dio(BaseOptions(
    baseUrl: 'https://maps.googleapis.com/maps/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void onInit() {
    super.onInit();
    loadUser();
    fetchAddresses();
  }

  @override
  void onClose() {
    mapAddressController.dispose();
    super.onClose();
  }

  void loadUser() {
    final data = _storage.getUser();
    if (data != null) {
      user.value = UserModel.fromJson(data);
    } else {
      user.value = UserModel(
        id: 'user1',
        name: 'Guest User',
        phone: '+92300XXXXXXX',
      );
    }
  }

  Future<void> fetchAddresses() async {
    try {
      addresses.value = await _addressRepo.getAddresses();
    } catch (e) {
      addresses.value = [
        AddressModel(
          id: 'addr1',
          label: 'Home',
          address: 'House 12, Block B, Gulberg III, Lahore',
          lat: 31.5204,
          lng: 74.3587,
          isDefault: true,
        ),
      ];
    }
  }

  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      placeSuggestions.clear();
      return;
    }
    try {
      isSearching.value = true;
      final res = await _placesClient.get(
        '/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': AppConstants.googleMapsApiKey,
          'language': 'en',
        },
      );
      final predictions = res.data['predictions'] as List<dynamic>? ?? [];
      placeSuggestions.value = predictions.map((p) {
        return PlaceSuggestion(
          placeId: p['place_id'] as String,
          description: p['description'] as String,
        );
      }).toList();
    } catch (_) {
      placeSuggestions.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectPlace(PlaceSuggestion suggestion,
      {required Function(double lat, double lng, String address)
          onSelected}) async {
    try {
      final res = await _placesClient.get(
        '/place/details/json',
        queryParameters: {
          'place_id': suggestion.placeId,
          'fields': 'geometry,formatted_address',
          'key': AppConstants.googleMapsApiKey,
        },
      );
      final result = res.data['result'];
      final lat =
          (result['geometry']['location']['lat'] as num).toDouble();
      final lng =
          (result['geometry']['location']['lng'] as num).toDouble();
      final address = result['formatted_address'] as String;

      selectedLat.value = lat;
      selectedLng.value = lng;
      mapAddressController.text = address;
      placeSuggestions.clear();
      onSelected(lat, lng, address);
    } catch (_) {
      // fall back to description as address text
      mapAddressController.text = suggestion.description;
      placeSuggestions.clear();
    }
  }

  Future<void> reverseGeocode(double lat, double lng) async {
    try {
      selectedLat.value = lat;
      selectedLng.value = lng;
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        mapAddressController.text = parts;
      }
    } catch (_) {}
  }

  Future<void> getCurrentLocation(
      {required Function(double lat, double lng) onLocated}) async {
    try {
      isLocating.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location Disabled',
            'Please enable location services to use this feature.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Permission Denied',
              'Location permission is required to auto-detect your address.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission Denied',
            'Enable location in settings to use this feature.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await reverseGeocode(position.latitude, position.longitude);
      onLocated(position.latitude, position.longitude);
    } catch (_) {
      Get.snackbar('Error', 'Could not determine your location.');
    } finally {
      isLocating.value = false;
    }
  }

  Future<void> addAddress({
    required String label,
    required String address,
    double lat = 0,
    double lng = 0,
  }) async {
    try {
      isLoading.value = true;
      final newAddr = await _addressRepo.createAddress({
        'label': label,
        'street': address,
        'city': 'Lahore',
        'latitude': lat,
        'longitude': lng,
      });
      addresses.add(newAddr);
      Get.back();
      Get.snackbar('Success', 'Address added successfully');
    } catch (e) {
      debugPrint('[ProfileController] addAddress error: $e');
      Get.snackbar('Error', 'Failed to save address. Please try again.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _addressRepo.deleteAddress(id);
    } catch (_) {}
    addresses.removeWhere((a) => a.id == id);
  }

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFEF4444),
      onConfirm: () {
        _storage.clearAll();
        Get.offAllNamed(AppRoutes.onboarding);
      },
    );
  }
}
