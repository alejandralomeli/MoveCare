import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'AUTH_TOKEN', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'AUTH_TOKEN');
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
