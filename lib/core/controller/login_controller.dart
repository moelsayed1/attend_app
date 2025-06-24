import 'package:attendance/controllers/face_scan_controller.dart';
import 'package:attendance/core/model/login_response.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/views/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/utils/biometric_helper.dart';
import 'package:attendance/utils/location_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:attendance/views/pages/face_scan_screen.dart';
import 'package:attendance/views/pages/home _screen.dart';

String defaultLanguageCode = Prefs.getString(AppConstant.languageCode) == '' ? 'en' : Prefs.getString(AppConstant.languageCode);

class LoginController extends GetxController  {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxList workSpaceList = <Workspace>[].obs;
  RxBool isHiddenPassword = true.obs;
  
  // Method to fetch and store workspace data from API
  void fetchWorkspaceData() async {
    try {
      // Store the provided token
      String testToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDU5MTEyNCwiZXhwIjoxNzUwNTk0NzI0LCJuYmYiOjE3NTA1OTExMjQsImp0aSI6IjZyYkxYNVlNb2FMcXRxdjAiLCJzdWIiOiI0NiIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.FTpI73_N7-Kv2GmzO6FB-wvLlPe3Clehpi1RKfJlyMY";
      Prefs.setToken(testToken);
      
      // Set workspace ID
      Prefs.setString(AppConstant.workSpaceId, "4");
      
      // Create sample workspace data (you can replace this with actual API call)
      List<Workspace> sampleWorkspaces = [
        Workspace(id: 4, name: "Main Office", slug: "main-office", status: "active", createdBy: 1),
        Workspace(id: 5, name: "Branch Office", slug: "branch-office", status: "active", createdBy: 1),
        Workspace(id: 6, name: "Remote Team", slug: "remote-team", status: "active", createdBy: 1),
      ];
      
      // Store workspaces
      workSpaceList.value = sampleWorkspaces;
      Prefs.setString(AppConstant.workSpaceArray, jsonEncode(sampleWorkspaces));
      
      print("✅ Workspace data stored successfully");
      print("Available workspaces: ${sampleWorkspaces.map((w) => '${w.name} (ID: ${w.id})').join(', ')}");
      
    } catch (e) {
      print("❌ Error fetching workspace data: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    emailController.clear();
    passwordController.clear();
    
    // Set the provided token for all API calls
    Prefs.setToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDY4MjQxOSwiZXhwIjoxNzUwNjg2MDE5LCJuYmYiOjE3NTA2ODI0MTksImp0aSI6IlJoUTJkeHZIZ25uaUlWZlAiLCJzdWIiOiI1MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.OLwmMAVoTHmy8-yigDyN3fvpJgwHXtQZNbnWREZC0fg");
    // Fetch workspace data
    fetchWorkspaceData();
    // Test the provided token
    // testToken(); // Commented out to prevent automatic testing
  }

  // Method to decode JWT token
  Map<String, dynamic> decodeJWT(String token) {
    try {
      List<String> parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format');
      }
      
      String payload = parts[1];
      // Add padding if needed
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      
      // Decode base64
      String normalized = base64Url.normalize(payload);
      String resp = utf8.decode(base64Url.decode(normalized));
      Map<String, dynamic> payloadMap = json.decode(resp);
      
      return payloadMap;
    } catch (e) {
      print("Error decoding JWT: $e");
      return {};
    }
  }

  // Method to test the provided token
  void testToken() async {
    // Store the provided token
    String testToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDU5MTEyNCwiZXhwIjoxNzUwNTk0NzI0LCJuYmYiOjE3NTA1OTExMjQsImp0aSI6IjZyYkxYNVlNb2FMcXRxdjAiLCJzdWIiOiI0NiIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.FTpI73_N7-Kv2GmzO6FB-wvLlPe3Clehpi1RKfJlyMY";
    Prefs.setToken(testToken);
    print("Test token stored: $testToken");
    
    // Set workspace ID (you may need to adjust this value)
    Prefs.setString(AppConstant.workSpaceId, "4");
    print("Workspace ID set to: 4");
    
    // Decode and print token information
    Map<String, dynamic> tokenData = decodeJWT(testToken);
    print("Token payload: $tokenData");
    print("User ID: ${tokenData['sub']}");
    print("Token expires: ${DateTime.fromMillisecondsSinceEpoch(tokenData['exp'] * 1000)}");
    print("Current time: ${DateTime.now().toUtc()}");
    
    // Check if token is expired
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (tokenData['exp'] < currentTime) {
      print("❌ Token is expired!");
      return;
    }
    
    // Test API call with the token - try a simpler endpoint first
    try {
      print("Testing token with API...");
      var response = await NetworkHttps.getRequest("/get-leaves-types");
      print("Token test response: $response");
      if (response != null) {
        print("✅ Token is working! API call successful.");
      }
    } catch (e) {
      print("❌ Token test failed: $e");
      print("This might be due to:");
      print("1. Token permissions");
      print("2. API endpoint access");
      print("3. Workspace ID requirements");
    }
  }

  authLogin({required String email, required String password}) async {
    Loader.showLoader();
    update();
    
    try {
      var response = await NetworkHttps.postRequest(API.loginLink, {'email': email, 'password': password});
      print("Login Response: $response");
      
      if (response != null && response['status'] == 200) {
        // Optional: Biometric authentication (can be disabled for development)
        bool isAuthenticated = true; // Set to true to skip biometric for now
        try {
          isAuthenticated = await BiometricHelper.authenticate();
        } catch (e) {
          print("Biometric auth error: $e");
          isAuthenticated = true; // Continue without biometric for development
        }
        
        if (!isAuthenticated) {
          Loader.hideLoader();
          commonToast("Biometric authentication failed");
          return;
        }

        // Optional: Location detection (can be disabled for development)
        // Position? position;
        // try {
        //   position = await LocationHelper.getCurrentLocation();
        // } catch (e) {
        //   print("Location error: $e");
        //   // Continue without location for development
        // }

        var loginResponse = LoginResponse.fromJson(response);
        
        if (loginResponse.data != null && loginResponse.data!.user != null) {
          // Store token properly
          String token = loginResponse.data!.token ?? "";
          Prefs.setToken(token);
          print("Token stored: $token");
          
          // Store user data in preferences
          Prefs.setUserID(loginResponse.data!.user!.id.toString());
          Prefs.setString(AppConstant.userName, loginResponse.data!.user!.name ?? "");
          Prefs.setString(AppConstant.emailId, loginResponse.data!.user!.email ?? "");
          Prefs.setString(AppConstant.phoneNo, loginResponse.data!.user!.mobileNo ?? "");
          Prefs.setString(AppConstant.profileImage, loginResponse.data!.user!.avatar ?? "");
          Prefs.setString(AppConstant.userType, loginResponse.data!.user!.type ?? "");
          Prefs.setString(AppConstant.workSpaceId, loginResponse.data!.user!.activeWorkspace.toString());
          
          // Store workspaces
          if (loginResponse.data!.workspaces != null) {
            workSpaceList.value = loginResponse.data!.workspaces!;
            Prefs.setString(AppConstant.workSpaceArray, jsonEncode(loginResponse.data!.workspaces!));
          }
          
          Loader.hideLoader();
          // Check if today's face scan is uploaded
          final faceScanController = Get.put(FaceScanController());
          bool isUploaded = await faceScanController.isTodayFaceScanUploaded();
          if (isUploaded) {
            Get.offAll(() => const HomeScreen());
          } else {
            Get.offAll(() => const FaceScanScreen());
          }
          commonToast("${loginResponse.data!.user!.name ?? ""} Login successfully");
        } else {
          Loader.hideLoader();
          commonToast("Invalid response data");
        }
      } else {
        Loader.hideLoader();
        commonToast(response?["message"] ?? "Login failed");
      }
    } catch (e) {
      Loader.hideLoader();
      commonToast("An error occurred during login");
      print("Login error: $e");
    }
  }
} 