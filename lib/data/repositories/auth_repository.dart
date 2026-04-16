import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class AuthRepository {
  final Dio _dio = DioClient.getDio();

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final res = await _dio.post('/auth/send-otp', data: {'phone': phone});
    return res.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final res = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});
    return res.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/me');
    return res.data;
  }

  Future<Map<String, dynamic>> updateMe(String name) async {
    final res = await _dio.put('/me', data: {'name': name});
    return res.data;
  }
}
