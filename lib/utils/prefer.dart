// ignore_for_file: avoid_log, constant_identifier_names

import 'package:get_storage/get_storage.dart';

class Prefs {
  static const String USER_ID = 'userId';
  static const String storeId = 'storeId';
  static const String KEY_TOKEN = 'TOKEN';
  static const String Attendance_Id = 'Attendance_Id';
  static const String BASE_URL = 'base_url';
  static const String IS_CHECK_IN = 'is_check_in';

  static const String last_Face_Scan_Time = 'last_face_scan_time';

  static GetStorage? get _storage => GetStorage();

  static setString(String key, String value) {
    return _storage?.write(key, value);
  }

  static getString(String key) {
    return _storage?.read(key) ?? '';
  }

  static setBool(String key, bool value) {
    return _storage?.write(key, value);
  }

  static bool getBool(String key) {
    return _storage?.read(key) ?? false;
  }

  static String getBaseUrl() {
    return _storage?.read(BASE_URL) ?? '';
  }

  static setBaseUrl(String baseUrl) {
    return _storage?.write(BASE_URL, baseUrl);
  }

  static String getLastFaceScanTime() {
    return _storage?.read(last_Face_Scan_Time) ??
        DateTime.now().toUtc().subtract(const Duration(days: 1)).toString();
  }

  static setLastFaceScanTime(String lastFaceScanTime) async {
    return await _storage?.write(last_Face_Scan_Time, lastFaceScanTime);
  }

  static String getToken() {
    return _storage?.read(KEY_TOKEN) ?? '';
  }

  static setToken(String token) {
    return _storage?.write(KEY_TOKEN, token);
  }

  static String getUserID() {
    return _storage?.read(USER_ID) ?? '';
  }

  static setUserID(String userID) {
    return _storage?.write(USER_ID, userID);
  }

  static String getStoreID() {
    return _storage?.read(storeId) ?? '';
  }

  static setStoreID(String userID) {
    return _storage?.write(storeId, userID);
  }

  static remove(String key) {
    return _storage?.remove(key);
  }

  static clear() {
    return _storage?.erase();
  }
}
