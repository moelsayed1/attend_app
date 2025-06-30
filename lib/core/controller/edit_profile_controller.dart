import 'dart:convert';

import 'package:attendance/core/controller/setting_controller.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  SettingController settingController = Get.find<SettingController>();

  final ImagePicker _picker = ImagePicker();
  RxString imagePath = ''.obs;
  RxString profileImage = ''.obs;

  // Add loading state
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    imagePath.value = '';

    // Initialize text controllers with stored data from preferences
    nameController.text = Prefs.getString(AppConstant.userName);
    emailController.text = Prefs.getString(AppConstant.emailId);
    phoneController.text = Prefs.getString(AppConstant.phoneNo);
    profileImage.value = Prefs.getString(AppConstant.profileImage);

    log("Initial text controller values - Name: '${nameController.text}', Email: '${emailController.text}', Phone: '${phoneController.text}'");
    log("Initial profile image: '${profileImage.value}'");

    // Show local data immediately, then fetch fresh data from server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First, show local data if available
      if (nameController.text.isNotEmpty ||
          emailController.text.isNotEmpty ||
          phoneController.text.isNotEmpty) {
        isLoading.value = false;
        update();
        log("Showing local data immediately");
      }

      // Then fetch fresh data from server in background
      initializeData();
    });
  }

  // Separate initialization method
  Future<void> initializeData() async {
    try {
      isLoading.value = true;
      await getUserProfile();
      update();
    } catch (e) {
      log("Error initializing data: $e");
      commonToast("Failed to load profile data");
    } finally {
      isLoading.value = false;
    }
  }

  pickImage({required ImageSource imageSource}) async {
    try {
      final XFile? media = await _picker.pickImage(source: imageSource);
      Get.back();
      log("media--->$media");
      if (media != null) {
        imagePath.value = media.path;
        log("imagePath---->(£$imagePath)");
      } else {
        commonToast("Image not picked");
      }
    } catch (e) {
      log("Error picking image: $e");
      commonToast("Failed to pick image");
    }
  }

  saveProfileData({
    String? email,
    String? name,
    String? phoneNo,
    String? avatar,
  }) async {
    try {
      isLoading.value = true;
      String url = API.baseUrl + API.editProfile;
      log("url==>$url");
      log("data==>${{'name': name!, 'email': email!, "mobile_no": phoneNo!}}");

      var headers = {
        "Authorization": 'Bearer ${Prefs.getToken()}',
      };
      var request = http.MultipartRequest("POST", Uri.parse(url));

      request.fields.addAll({
        'name': name,
        'email': email,
        "mobile_no": phoneNo,
      });

      log("avatar$avatar");
      if (avatar != null && avatar.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile', avatar));
      }
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var decodedData = jsonDecode(await response.stream.bytesToString());
      log(response.statusCode.toString());
      log(jsonEncode(decodedData['data']));

      if (response.statusCode == 200) {
        if (decodedData['status'] == 1) {
          // Update local data immediately
          _updateUserData(decodedData['data']);
          commonToast(decodedData['message']);

          // Navigate back with success result
          Get.back(result: true);
        } else {
          commonToast(decodedData['message']);
        }
      } else {
        commonToast(decodedData['message']);
      }
    } catch (e) {
      log("Error saving profile: $e");
      commonToast("Failed to save profile data");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to update user data
  void _updateUserData(Map<String, dynamic> data) {
    log("_updateUserData called with data: $data");

    // Store data in preferences
    Prefs.setString(AppConstant.userName, data['name'] ?? '');
    Prefs.setString(AppConstant.emailId, data['email'] ?? '');
    Prefs.setString(AppConstant.phoneNo, data['mobile_no'] ?? '');
    Prefs.setString(AppConstant.profileImage, data['avatar'] ?? '');

    // Update setting controller
    settingController.name.value = data['name'] ?? '';
    settingController.email.value = data['email'] ?? '';
    settingController.profileImage.value = data['avatar'] ?? '';

    // Populate text controllers with user data
    nameController.text = data['name'] ?? '';
    emailController.text = data['email'] ?? '';
    phoneController.text = data['mobile_no'] ?? '';
    profileImage.value = data['avatar'] ?? '';

    log("Text controllers populated - Name: '${nameController.text}', Email: '${emailController.text}', Phone: '${phoneController.text}'");
    log("Profile image set to: '${profileImage.value}'");
    log("Setting controller values - Name: '${settingController.name.value}', Email: '${settingController.email.value}', ProfileImage: '${settingController.profileImage.value}'");

    // Force UI update
    update();
  }

  // Method to refresh UI after data is loaded
  void refreshUI() {
    update();
  }

  // Method to refresh data from server
  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      await getUserProfile();
    } catch (e) {
      log("Error refreshing data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Test method to manually set data (for debugging)
  void setTestData() {
    nameController.text = "Test User";
    emailController.text = "test@example.com";
    phoneController.text = "1234567890";
    profileImage.value = "https://example.com/test.jpg";
    log("Test data set - Name: '${nameController.text}', Email: '${emailController.text}', Phone: '${phoneController.text}'");
    update();
  }

  Future<void> getUserProfile() async {
    try {
      isLoading.value = true;
      String endPoint = API.getUserProfile;
      var headers = {
        "Authorization": 'Bearer ${Prefs.getToken()}',
        "Content-Type": "application/json",
        "Cache-Control": "no-cache"
      };
      log("authHeaders===>$headers");
      log("endPoint===>$endPoint");
      var response = await NetworkHttps.getRequestWithoutLoader(endPoint);
      log("response==>$response");

      if (response['status'] == 1) {
        log("Profile data received: ${response['data']}");
        _updateUserData(response['data']);
        refreshUI();
      } else {
        log("Profile fetch failed: ${response['message']}");
        commonToast(response['message']);
      }
    } catch (e) {
      log("Error fetching profile: $e");
      commonToast("Failed to fetch profile data");
    } finally {
      isLoading.value = false;
    }
  }
}
