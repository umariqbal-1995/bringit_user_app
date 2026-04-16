import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/address_model.dart';

class AddressRepository {
  final Dio _dio = DioClient.getDio();

  Future<List<AddressModel>> getAddresses() async {
    final res = await _dio.get('/addresses');
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? data['addresses'] ?? []);
    return (list as List).map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<AddressModel> createAddress(Map<String, dynamic> data) async {
    final res = await _dio.post('/addresses', data: data);
    final body = res.data['data'] ?? res.data['address'] ?? res.data;
    return AddressModel.fromJson(body is Map<String, dynamic> ? body : res.data);
  }

  Future<AddressModel> updateAddress(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/addresses/$id', data: data);
    final body = res.data['data'] ?? res.data['address'] ?? res.data;
    return AddressModel.fromJson(body is Map<String, dynamic> ? body : res.data);
  }

  Future<void> deleteAddress(String id) async {
    await _dio.delete('/addresses/$id');
  }
}
