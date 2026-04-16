import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/store_model.dart';
import '../models/menu_item_model.dart';
import '../models/product_model.dart';

class StoreRepository {
  final Dio _dio = DioClient.getDio();

  Future<({List<StoreModel> items, int totalPages})> getRestaurants({int page = 1, int limit = 10}) async {
    final res = await _dio.get('/restaurants', queryParameters: {'page': page, 'limit': limit});
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? data['restaurants'] ?? []);
    final meta = data is Map ? (data['meta'] as Map?) : null;
    final totalPages = (meta?['totalPages'] as int?) ?? 1;
    return (items: (list as List).map((e) => StoreModel.fromJson(e)).toList(), totalPages: totalPages);
  }

  Future<({List<StoreModel> items, int totalPages})> getStores({int page = 1, int limit = 10}) async {
    final res = await _dio.get('/stores', queryParameters: {'page': page, 'limit': limit});
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? data['stores'] ?? []);
    final meta = data is Map ? (data['meta'] as Map?) : null;
    final totalPages = (meta?['totalPages'] as int?) ?? 1;
    return (items: (list as List).map((e) => StoreModel.fromJson(e)).toList(), totalPages: totalPages);
  }

  Future<List<MenuItemModel>> getRestaurantMenu(String storeId) async {
    final res = await _dio.get('/restaurants/$storeId/menu');
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? data['menu'] ?? []);
    return (list as List).map((e) => MenuItemModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getStoreProducts(String storeId) async {
    final res = await _dio.get('/stores/$storeId/products');
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? data['products'] ?? []);
    return (list as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<StoreModel>> getFavorites() async {
    final res = await _dio.get('/favorites');
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? data['favorites'] ?? []);
    return (list as List)
        .map((e) => StoreModel.fromJson(e is Map ? (e['store'] ?? e) as Map<String, dynamic> : e))
        .toList();
  }

  Future<void> addFavorite(String storeId) async {
    await _dio.post('/favorites/$storeId');
  }

  Future<void> removeFavorite(String storeId) async {
    await _dio.delete('/favorites/$storeId');
  }
}
