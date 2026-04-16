import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class CartRepository {
  final Dio _dio = DioClient.getDio();

  Future<Map<String, dynamic>> getCart(String storeId) async {
    final res = await _dio.get('/cart/$storeId');
    return res.data;
  }

  Future<void> addItem(String storeId, String itemId, int quantity, {bool isMenuItem = true}) async {
    final key = isMenuItem ? 'menuItemId' : 'storeProductId';
    await _dio.post('/cart/$storeId/items', data: {key: itemId, 'quantity': quantity});
  }

  Future<void> updateItem(String storeId, String itemId, int quantity) async {
    await _dio.put('/cart/$storeId/items/$itemId', data: {'quantity': quantity});
  }

  Future<void> deleteItem(String storeId, String itemId) async {
    await _dio.delete('/cart/$storeId/items/$itemId');
  }

  Future<void> clearCart(String storeId) async {
    await _dio.delete('/cart/$storeId');
  }
}
