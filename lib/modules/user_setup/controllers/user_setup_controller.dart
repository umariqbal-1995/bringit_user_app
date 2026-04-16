import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../routes/app_routes.dart';

class UserSetupPlaceSuggestion {
  final String placeId;
  final String description;
  UserSetupPlaceSuggestion({required this.placeId, required this.description});
}

class UserSetupController extends GetxController {
  final AuthRepository _authRepo;
  final AddressRepository _addressRepo;
  UserSetupController(this._authRepo, this._addressRepo);

  final _storage = StorageService();

  // Step state
  final currentStep = 0.obs;

  // Name step
  final nameController = TextEditingController();
  final isNameLoading = false.obs;

  // Location step
  final selectedLat = 31.5204.obs;
  final selectedLng = 74.3587.obs;
  final isLocating = false.obs;
  final isSearching = false.obs;
  final isSaving = false.obs;
  final placeSuggestions = <UserSetupPlaceSuggestion>[].obs;
  final address = ''.obs;

  final _placesClient = Dio(BaseOptions(
    baseUrl: 'https://maps.googleapis.com/maps/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> submitName() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter your name',
          backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
      return;
    }
    try {
      isNameLoading.value = true;
      final res = await _authRepo.updateMe(name);
      // Update stored user with new name
      final userData = _storage.getUser() ?? {};
      userData['name'] = name;
      if (res['data'] != null) {
        final u = res['data'] as Map<String, dynamic>;
        _storage.saveUser({...userData, ...u});
      } else {
        _storage.saveUser(userData);
      }
      currentStep.value = 1;
    } catch (_) {
      // Still proceed — update local storage optimistically
      final userData = _storage.getUser() ?? {};
      userData['name'] = name;
      _storage.saveUser(userData);
      currentStep.value = 1;
    } finally {
      isNameLoading.value = false;
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
        return UserSetupPlaceSuggestion(
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

  Future<void> selectPlace(
    UserSetupPlaceSuggestion suggestion, {
    required Function(double lat, double lng) onSelected,
  }) async {
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
      final lat = (result['geometry']['location']['lat'] as num).toDouble();
      final lng = (result['geometry']['location']['lng'] as num).toDouble();
      final formattedAddress = result['formatted_address'] as String;
      selectedLat.value = lat;
      selectedLng.value = lng;
      address.value = formattedAddress;
      placeSuggestions.clear();
      onSelected(lat, lng);
    } catch (_) {
      address.value = suggestion.description;
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
        final parts = [p.street, p.subLocality, p.locality, p.administrativeArea]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
        address.value = parts;
      }
    } catch (_) {}
  }

  Future<void> getCurrentLocation({
    required Function(double lat, double lng) onLocated,
  }) async {
    try {
      isLocating.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location Disabled', 'Please enable location services.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Permission Denied', 'Location permission is required.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission Denied', 'Enable location in settings.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await reverseGeocode(position.latitude, position.longitude);
      onLocated(position.latitude, position.longitude);
    } catch (_) {
      Get.snackbar('Error', 'Could not determine your location.');
    } finally {
      isLocating.value = false;
    }
  }

  Future<void> submitLocation() async {
    final addressText = address.value.trim();
    if (addressText.isEmpty) {
      Get.snackbar('Required', 'Please select your delivery location',
          backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
      return;
    }
    try {
      isSaving.value = true;
      await _addressRepo.createAddress({
        'label': 'Home',
        'street': addressText,
        'city': 'Lahore',
        'latitude': selectedLat.value,
        'longitude': selectedLng.value,
        'isDefault': true,
      });
    } catch (_) {
      // Continue anyway — address can be added later
    } finally {
      isSaving.value = false;
    }
    Get.offAllNamed(AppRoutes.home);
  }

  void skipLocation() => Get.offAllNamed(AppRoutes.home);
}
