import 'package:attendance/utils/base_api.dart';

import '../../network_dio/network_dio.dart';

class ChangePasswordRepository {


 changePassword({
  required String oldPassword,
  required String newPassword,
  required String confirmPassword,
 }) async {
  try {
    var response = await NetworkHttps.postRequest(API.changePasswordUrl, {
      'password': newPassword,
      'password_confirmation': confirmPassword,
      'current_password': oldPassword
    });
    if (response != null && response['status'] == 1) {
      return response;
    }
    return null;
  } catch (e) {
    rethrow;
  }
 }

}