import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../views/pages/login_screen.dart';

class Requests {
  static Future<Map<String, String>> _getHeaders() async {
    return {
      "Authorization": 'Bearer ${Prefs.getToken()}',
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.cacheControlHeader: "no-cache",
    };
  }

  static Future<Map<String, dynamic>> getHolidayList(String endPoint) async {
    String postUrl = API.baseUrl + endPoint;
    log("GET API URL===> $postUrl");
    log("authHeaders===>${Prefs.getToken()}");

    try {
      var response = await http.post(Uri.parse(postUrl),
          headers: await _getHeaders(),
          body: jsonEncode(
              {"workspace_id": Prefs.getString(AppConstant.workSpaceId)}));

      log("statusCode===> ${response.statusCode}");
      log("response body===> ${response.body}");
      log("response c===> ${response.statusCode == 200 || response.statusCode == 201}");

      Map<String, dynamic> responseBody;
      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        log("Non-JSON response: ${response.body}");
        String message = "Unexpected server response. Please try again later.";
        if (response.statusCode == 405) {
          message =
              "Method Not Allowed (405). Please contact support or check your request.";
        }
        commonToast(message);
        return {
          "status": response.statusCode,
          "message": message,
          "raw": response.body
        };
      }

      try {
        if (response.body.isNotEmpty) {
          responseBody = json.decode(response.body);
        } else {
          responseBody = {
            "status": response.statusCode,
            "message": "Empty response body"
          };
        }
      } catch (e) {
        log("Error decoding GET response body: $e");
        responseBody = {
          "status": response.statusCode,
          "message": "Invalid JSON response from server: $e"
        };
      }

      if (response.statusCode == 401) {
        await Prefs.clear();
        Get.offAll(() => LoginScreen());
        Get.deleteAll();
        return {
          "status": 401,
          "message": "Unauthorized. Redirecting to login."
        };
      } else {
        if (responseBody['status'] != 1 && responseBody['status'] != 200) {
          commonToast(responseBody['message']?.toString() ??
              "An error occurred with status ${response.statusCode}");
        }
        return responseBody;
      }
    } on SocketException {
      commonToast("No Internet connection.");
      return {"status": 0, "message": "No Internet connection."};
    } on FormatException catch (e) {
      commonToast("Invalid response format from server.");
      return {"status": -1, "message": "Invalid response format: $e"};
    } on http.ClientException catch (e) {
      commonToast("HTTP client error: ${e.message}");
      return {"status": -2, "message": "HTTP client error: ${e.message}"};
    } catch (e) {
      log("err->${e.toString()}");
      commonToast("An unexpected error occurred.");
      return {
        "status": -3,
        "message": "An unexpected error occurred: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> getAttendanceList(
      String endPoint, Map<String, dynamic> map) async {
    String postUrl = API.baseUrl + endPoint;
    log("GET API URL===> $postUrl");
    log("authHeaders===>${Prefs.getToken()}");

    try {
      var response = await http.post(Uri.parse(postUrl),
          headers: await _getHeaders(), body: jsonEncode(map));

      log("statusCode===> ${response.statusCode}");
      log("response body===> ${response.body}");
      log("response c===> ${response.statusCode == 200 || response.statusCode == 201}");

      Map<String, dynamic> responseBody;
      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        log("Non-JSON response: ${response.body}");
        String message = "Unexpected server response. Please try again later.";
        if (response.statusCode == 405) {
          message =
              "Method Not Allowed (405). Please contact support or check your request.";
        }
        commonToast(message);
        return {
          "status": response.statusCode,
          "message": message,
          "raw": response.body
        };
      }

      try {
        if (response.body.isNotEmpty) {
          responseBody = json.decode(response.body);
        } else {
          responseBody = {
            "status": response.statusCode,
            "message": "Empty response body"
          };
        }
      } catch (e) {
        log("Error decoding GET response body: $e");
        responseBody = {
          "status": response.statusCode,
          "message": "Invalid JSON response from server: $e"
        };
      }

      if (response.statusCode == 401) {
        await Prefs.clear();
        Get.offAll(() => LoginScreen());
        Get.deleteAll();
        return {
          "status": 401,
          "message": "Unauthorized. Redirecting to login."
        };
      } else {
        if (responseBody['status'] != 1 && responseBody['status'] != 200) {
          commonToast(responseBody['message']?.toString() ??
              "An error occurred with status ${response.statusCode}");
        }
        return responseBody;
      }
    } on SocketException {
      commonToast("No Internet connection.");
      return {"status": 0, "message": "No Internet connection."};
    } on FormatException catch (e) {
      commonToast("Invalid response format from server.");
      return {"status": -1, "message": "Invalid response format: $e"};
    } on http.ClientException catch (e) {
      commonToast("HTTP client error: ${e.message}");
      return {"status": -2, "message": "HTTP client error: ${e.message}"};
    } catch (e) {
      log("err->${e.toString()}");
      commonToast("An unexpected error occurred.");
      return {
        "status": -3,
        "message": "An unexpected error occurred: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String endPoint) async {
    var response = await NetworkHttps.getRequestWithoutLoader(endPoint);
    return response;
  }
}
