import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Dio _dio = DioClient.getDio();

  Future<OrderModel> placeOrder(
    String storeId,
    String addressId, {
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await _dio.post('/orders', data: {
      'storeId': storeId,
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      'items': items,
    });
    final data = res.data['data'] ?? res.data['order'] ?? res.data;
    return OrderModel.fromJson(data is Map<String, dynamic> ? data : res.data);
  }

  Future<List<OrderModel>> getOrders() async {
    final res = await _dio.get('/orders');
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? data['orders'] ?? []);
    return (list as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrder(String orderId) async {
    final res = await _dio.get('/orders/$orderId');
    final data = res.data['data'] ?? res.data['order'] ?? res.data;
    return OrderModel.fromJson(data is Map<String, dynamic> ? data : res.data);
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    await _dio.post('/orders/$orderId/cancel', data: {'reason': reason});
  }
}
