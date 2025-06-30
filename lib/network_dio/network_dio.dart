import 'dart:convert';
import 'dart:io'; // Import for SocketException

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import '../utils/base_api.dart';
import '../utils/common_snackbar_widget.dart';
import '../utils/prefer.dart';
import '../views/pages/login_screen.dart';
import '../views/widgets/loading_widget.dart';

class NetworkHttps {
  // accessToken is not used here, consider removing if not needed or make it static
  // String accessToken = Prefs.getToken();

  NetworkHttps._privateConstructor();

  static final NetworkHttps getInstance = NetworkHttps._privateConstructor();

  // Headers are better defined per request as Authorization changes
  // static final Map<String, String> headers = {
  //   HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
  //   HttpHeaders.cacheControlHeader: "no-cache",
  // };

  // Helper to get common headers
  static Future<Map<String, String>> _getHeaders() async {
    return {
      "Authorization": 'Bearer ${Prefs.getToken()}',
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.cacheControlHeader: "no-cache",
    };
  }

  static Future<Map<String, dynamic>> getRequest(String endPoint) async {
    var getUrl = API.baseUrl + endPoint;
    log("GET API URL===> $getUrl");
    log("authHeaders===>[0m");
    Loader.showLoader(); // Show loader for every API call
    try {
      var response =
          await http.get(Uri.parse(getUrl), headers: await _getHeaders());
      log("statusCode===> ${response.statusCode}");
      log("response body===> ${response.body}");

      Map<String, dynamic> responseBody;
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        // Not JSON, likely an HTML error page
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
          // Fallback for empty body, assume some generic error structure
          responseBody = {
            "status": response.statusCode,
            "message": "Empty response body"
          };
        }
      } catch (e) {
        // If JSON decoding fails, return a structured error with raw status code
        log("Error decoding GET response body: $e");
        responseBody = {
          "status": response.statusCode,
          "message": "Invalid JSON response from server: $e"
        };
      }

      if (response.statusCode == 401) {
        await Prefs.clear();
        Get.offAll(() => LoginScreen());
        Get.deleteAll(); // Ensure controllers are cleaned up
        // Return a specific map to indicate unauthorized and redirection happened
        return {
          "status": 401,
          "message": "Unauthorized. Redirecting to login."
        };
      } else {
        // For all other status codes, return the parsed response body
        // The caller will then check `responseBody['status']` etc.
        return responseBody;
      }
    } on SocketException {
      Loader.hideLoader();
      commonToast("No Internet connection.");
      return {"status": 0, "message": "No Internet connection."};
    } on FormatException catch (e) {
      Loader.hideLoader();
      commonToast("Invalid response format from server.");
      return {"status": -1, "message": "Invalid response format: $e"};
    } on http.ClientException catch (e) {
      Loader.hideLoader();
      commonToast("HTTP client error: ${e.message}");
      return {"status": -2, "message": "HTTP client error: ${e.message}"};
    } catch (e) {
      Loader.hideLoader();
      log("err->${e.toString()}");
      commonToast("An unexpected error occurred.");
      return {
        "status": -3,
        "message": "An unexpected error occurred: ${e.toString()}"
      };
    } finally {
      Loader.hideLoader(); // Ensure loader is hidden in all cases
    }
  }

  // Version without loader for use during initialization
  static Future<Map<String, dynamic>> getRequestWithoutLoader(
      String endPoint) async {
    var getUrl = API.baseUrl + endPoint;
    log("GET API URL (no loader)===> $getUrl");
    log("authHeaders===>[0m");
    try {
      var response =
          await http.get(Uri.parse(getUrl), headers: await _getHeaders());
      log("statusCode===> ${response.statusCode}");
      log("response body===> ${response.body}");

      Map<String, dynamic> responseBody;
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        // Not JSON, likely an HTML error page
        log("Non-JSON response: ${response.body}");
        String message = "Unexpected server response. Please try again later.";
        if (response.statusCode == 405) {
          message =
              "Method Not Allowed (405). Please contact support or check your request.";
        }
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
          // Fallback for empty body, assume some generic error structure
          responseBody = {
            "status": response.statusCode,
            "message": "Empty response body"
          };
        }
      } catch (e) {
        // If JSON decoding fails, return a structured error with raw status code
        log("Error decoding GET response body: $e");
        responseBody = {
          "status": response.statusCode,
          "message": "Invalid JSON response from server: $e"
        };
      }

      if (response.statusCode == 401) {
        await Prefs.clear();
        Get.offAll(() => LoginScreen());
        Get.deleteAll(); // Ensure controllers are cleaned up
        // Return a specific map to indicate unauthorized and redirection happened
        return {
          "status": 401,
          "message": "Unauthorized. Redirecting to login."
        };
      } else {
        // For all other status codes, return the parsed response body
        // The caller will then check `responseBody['status']` etc.
        return responseBody;
      }
    } on SocketException {
      return {"status": 0, "message": "No Internet connection."};
    } on FormatException catch (e) {
      return {"status": -1, "message": "Invalid response format: $e"};
    } on http.ClientException catch (e) {
      return {"status": -2, "message": "HTTP client error: ${e.message}"};
    } catch (e) {
      log("err->${e.toString()}");
      return {
        "status": -3,
        "message": "An unexpected error occurred: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> postRequest(
      String endPoint, Map data) async {
    String postUrl = API.baseUrl + endPoint;
    log("POST API URL===> $postUrl");
    log("data===> ${jsonEncode(data)}");
    log("authHeaders===>${Prefs.getToken()}");
    //  Loader.showLoader(); // Show loader for every API call
    try {
      var response = await http.post(Uri.parse(postUrl),
          body: jsonEncode(data), headers: await _getHeaders());
      log("statusCode===> ${response.statusCode}");
      log("response body===> ${response.body}");
      log("response c===> ${response.statusCode == 200 || response.statusCode == 201}");

      Map<String, dynamic> responseBody;
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        // Not JSON, likely an HTML error page
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
        log("Error decoding POST response body: $e");
        responseBody = {
          "status": response.statusCode,
          "message": "Invalid JSON response from server: $e"
        };
      }

      if (response.statusCode == 401) {
        await Prefs.clear();
        Get.offAll(() => LoginScreen());
        Get.deleteAll(); // Ensure controllers are cleaned up
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
      // Loader.hideLoader();
      Get.forceAppUpdate();
      commonToast("No Internet connection.");
      return {"status": 0, "message": "No Internet connection."};
    } on FormatException catch (e) {
      //  Loader.hideLoader();
      Get.forceAppUpdate();
      commonToast("Invalid response format from server.");
      return {"status": -1, "message": "Invalid response format: $e"};
    } on http.ClientException catch (e) {
      //  Loader.hideLoader();
      Get.forceAppUpdate();
      commonToast("HTTP client error: ${e.message}");
      return {"status": -2, "message": "HTTP client error: ${e.message}"};
    } catch (e) {
      //  Loader.hideLoader();
      Get.forceAppUpdate();
      log("err->${e.toString()}");
      commonToast("An unexpected error occurred.");
      return {
        "status": -3,
        "message": "An unexpected error occurred: ${e.toString()}"
      };
    } finally {
      //  Loader.hideLoader(); // Ensure loader is hidden in all cases
      Get.forceAppUpdate();
    }
  }

  static Future<Map<String, dynamic>> deleteRequest(String endPoint) async {
    String deleteUrl = API.baseUrl + endPoint;
    log("DELETE API URL===> $deleteUrl");
    log("authHeaders===>${Prefs.getToken()}");
    Loader.showLoader(); // Show loader for every API call
    try {
      var response =
          await http.delete(Uri.parse(deleteUrl), headers: await _getHeaders());
      log("statusCode===> ${response.statusCode}");
      log("response body===> ${response.body}");

      Map<String, dynamic> responseBody;
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        // Not JSON, likely an HTML error page
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
          // Fallback for empty body
          responseBody = {
            "status": response.statusCode,
            "message": "Empty response body"
          };
        }
      } catch (e) {
        log("Error decoding DELETE response body: $e");
        responseBody = {
          "status": response.statusCode,
          "message": "Invalid JSON response from server: $e"
        };
      }

      if (response.statusCode == 401) {
        await Prefs.clear();
        Get.offAll(() => LoginScreen());
        Get.deleteAll(); // Ensure controllers are cleaned up
        return {
          "status": 401,
          "message": "Unauthorized. Redirecting to login."
        };
      } else {
        // For other status codes, return the response body.
        // Show toast for errors not explicitly handled by caller
        if (responseBody['status'] != 1 && responseBody['status'] != 200) {
          commonToast(responseBody['message']?.toString() ??
              "An error occurred with status ${response.statusCode}");
        }
        return responseBody;
      }
    } on SocketException {
      Loader.hideLoader();
      commonToast("No Internet connection.");
      return {"status": 0, "message": "No Internet connection."};
    } on FormatException catch (e) {
      Loader.hideLoader();
      commonToast("Invalid response format from server.");
      return {"status": -1, "message": "Invalid response format: $e"};
    } on http.ClientException catch (e) {
      Loader.hideLoader();
      commonToast("HTTP client error: ${e.message}");
      return {"status": -2, "message": "HTTP client error: ${e.message}"};
    } catch (e) {
      Loader.hideLoader();
      commonToast("An unexpected error occurred.");
      log("err->${e.toString()}");
      return {
        "status": -3,
        "message": "An unexpected error occurred: ${e.toString()}"
      };
    } finally {
      Loader.hideLoader(); // Ensure loader is hidden in all cases
    }
  }

  // _handleError is completely removed as its logic is now integrated directly
  // into the request methods by returning structured error maps.
}
