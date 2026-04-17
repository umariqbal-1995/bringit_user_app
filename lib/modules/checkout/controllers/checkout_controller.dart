import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepo;
  final AddressRepository _addressRepo;

  CheckoutController(this._orderRepo, this._addressRepo);

  final isLoading = false.obs;
  final addresses = <AddressModel>[].obs;
  final selectedAddress = Rxn<AddressModel>();
  final selectedPayment = 'cash'.obs;
  final lastOrderId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      addresses.value = await _addressRepo.getAddresses();
      if (addresses.isNotEmpty) {
        selectedAddress.value =
            addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first;
      }
    } catch (e) {
      debugPrint('[CheckoutController] fetchAddresses error: $e');
      addresses.value = [];
      selectedAddress.value = null;
    }
  }

  Future<void> placeOrder() async {
    final cartController = Get.find<CartController>();
    if (cartController.items.isEmpty) {
      Get.snackbar('Error', 'Your cart is empty');
      return;
    }
    if (selectedAddress.value == null) {
      Get.snackbar('Error', 'Please select a delivery address');
      return;
    }
    if (cartController.storeId.value.isEmpty) {
      Get.snackbar('Error', 'Invalid store. Please restart your order.');
      return;
    }

    try {
      isLoading.value = true;
      final paymentMethod = selectedPayment.value == 'cash'
          ? 'CASH_ON_DELIVERY'
          : selectedPayment.value.toUpperCase();
      final items = cartController.items.map((item) {
        final key = item.itemType == 'menuItem' ? 'menuItemId' : 'storeProductId';
        return {key: item.itemId, 'quantity': item.quantity};
      }).toList();
      final order = await _orderRepo.placeOrder(
        cartController.storeId.value,
        selectedAddress.value!.id,
        paymentMethod: paymentMethod,
        items: items,
      );
      lastOrderId.value = order.id;
      cartController.clear();
      Get.snackbar(
        '🎉 Order Placed!',
        'Your order is confirmed. Track it live below.',
        backgroundColor: const Color(0xFF22C55E),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed(AppRoutes.trackOrder, arguments: order);
    } catch (e) {
      debugPrint('[CheckoutController] placeOrder error: $e');
      String message = 'Failed to place order. Please try again.';
      if (e is DioException) {
        final serverMsg = e.response?.data?['message'];
        if (serverMsg != null && serverMsg.toString().isNotEmpty) {
          message = serverMsg.toString();
        }
      }
      Get.snackbar('Order Failed', message,
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4));
    } finally {
      isLoading.value = false;
    }
  }
}
