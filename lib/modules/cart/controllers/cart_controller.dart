import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cart_item_model.dart';

class CartController extends GetxController {
  final items = <CartItemModel>[].obs;
  final storeId = ''.obs;
  final storeName = ''.obs;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get deliveryFee => items.isEmpty ? 0 : 49.0;
  double get tax => subtotal * 0.05;
  double get total => subtotal + deliveryFee + tax;

  void addItem({
    required String itemId,
    required String name,
    required double price,
    String? image,
    required String currentStoreId,
    required String currentStoreName,
    required String itemType,
  }) {
    if (storeId.value.isNotEmpty && storeId.value != currentStoreId) {
      Get.defaultDialog(
        title: 'Clear Cart?',
        middleText:
            'Your cart has items from another store. Clear and add new item?',
        textConfirm: 'Clear & Add',
        textCancel: 'Cancel',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary,
        onConfirm: () {
          items.clear();
          storeId.value = currentStoreId;
          storeName.value = currentStoreName;
          _addOrIncrement(itemId, name, price, image, currentStoreId, itemType);
          Get.back();
        },
      );
      return;
    }
    storeId.value = currentStoreId;
    storeName.value = currentStoreName;
    _addOrIncrement(itemId, name, price, image, currentStoreId, itemType);
  }

  void _addOrIncrement(
    String itemId,
    String name,
    double price,
    String? image,
    String sid,
    String itemType,
  ) {
    final idx = items.indexWhere((e) => e.itemId == itemId);
    if (idx >= 0) {
      items[idx].quantity++;
      items.refresh();
    } else {
      items.add(CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemId: itemId,
        name: name,
        price: price,
        image: image,
        quantity: 1,
        storeId: sid,
        itemType: itemType,
      ));
    }
  }

  void increment(String itemId) {
    final idx = items.indexWhere((e) => e.itemId == itemId);
    if (idx >= 0) {
      items[idx].quantity++;
      items.refresh();
    }
  }

  void decrement(String itemId) {
    final idx = items.indexWhere((e) => e.itemId == itemId);
    if (idx >= 0) {
      if (items[idx].quantity > 1) {
        items[idx].quantity--;
        items.refresh();
      } else {
        items.removeAt(idx);
      }
    }
  }

  void remove(String itemId) {
    items.removeWhere((e) => e.itemId == itemId);
    if (items.isEmpty) storeId.value = '';
  }

  void clear() {
    items.clear();
    storeId.value = '';
    storeName.value = '';
  }

  int getQuantity(String itemId) =>
      items.firstWhereOrNull((e) => e.itemId == itemId)?.quantity ?? 0;
}
