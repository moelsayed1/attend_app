import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/base_api.dart';

class LogoutRepository {
  static Future logout() async {
    try {
      var response = await NetworkHttps.postRequest(API.logoutUrl, {});
      if (response['status'] == 1) {
        return response;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
