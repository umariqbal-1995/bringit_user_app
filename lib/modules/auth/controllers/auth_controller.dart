import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _repo;
  AuthController(this._repo);

  final _storage = StorageService();

  final isLoading = false.obs;
  final phone = ''.obs;

  Future<void> sendOtp(String phoneNumber) async {
    try {
      isLoading.value = true;
      phone.value = phoneNumber;
      await _repo.sendOtp(phoneNumber);
      Get.toNamed(AppRoutes.verifyOtp, arguments: {'phone': phoneNumber});
    } catch (e) {
      Get.snackbar(
        'Error',
        _errorMessage(e),
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    try {
      isLoading.value = true;
      final data = await _repo.verifyOtp(phoneNumber, otp);
      final responseData = (data['data'] as Map<String, dynamic>?) ?? data;
      final token = responseData['token'] ?? responseData['accessToken'];
      if (token != null) {
        _storage.saveToken(token);
        final userData = responseData['user'] as Map<String, dynamic>?;
        if (userData != null) {
          _storage.saveUser(Map<String, dynamic>.from(userData));
        }
        // New user = no name yet → send to onboarding setup
        final isNewUser = responseData['isNewUser'] == true ||
            (userData?['name'] == null || (userData?['name'] as String).trim().isEmpty);
        if (isNewUser) {
          Get.offAllNamed(AppRoutes.userSetup);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        throw Exception('Invalid response');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        _errorMessage(e),
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _errorMessage(dynamic e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Something went wrong';
  }
}
