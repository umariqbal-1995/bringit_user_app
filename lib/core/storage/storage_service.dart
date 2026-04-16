import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  final _box = GetStorage();

  void saveToken(String token) => _box.write(AppConstants.tokenKey, token);
  String? getToken() => _box.read(AppConstants.tokenKey);
  void removeToken() => _box.remove(AppConstants.tokenKey);
  bool get isLoggedIn => getToken() != null;

  void saveUser(Map<String, dynamic> user) =>
      _box.write(AppConstants.userKey, user);
  Map<String, dynamic>? getUser() => _box.read(AppConstants.userKey);
  void removeUser() => _box.remove(AppConstants.userKey);

  void clearAll() => _box.erase();
}
