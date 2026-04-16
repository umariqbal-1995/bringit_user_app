import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio = DioClient.getDio();

  Future<List<NotificationModel>> getNotifications() async {
    final res = await _dio.get('/notifications');
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? data['notifications'] ?? []);
    return (list as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }
}
