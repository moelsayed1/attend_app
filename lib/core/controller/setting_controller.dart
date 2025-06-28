import 'package:attendance/config/repository/logout_repository.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/views/widgets/loading_widget.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/views/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String defaultLanguageCode = Prefs.getString(AppConstant.languageCode) == ''
    ? 'en'
    : Prefs.getString(AppConstant.languageCode);

class SettingController extends GetxController {
  LogoutRepository logoutRepository = LogoutRepository();
  RxBool isDarkTheme = false.obs;
  RxString profileImage = ''.obs;
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxBool isRtl = false.obs;
  RxString languageCode = defaultLanguageCode.obs;
  RxString workSpaceId =
      Prefs.getString(AppConstant.workSpaceId).toString().obs;
  RxInt selectedWorkSpaceId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    isRtl.value = languageCode.value == 'ar' ? true : false;
    profileImage.value = Prefs.getString(AppConstant.profileImage);
    name.value = Prefs.getString(AppConstant.userName);
    email.value = Prefs.getString(AppConstant.emailId);
  }

  logOutData() async {
    Loader.showLoader();
    try {
      var response = await LogoutRepository.logout();
      if (response != null && response['status'] == 1) {
        Prefs.clear();
        Get.deleteAll();
        Get.offAll(() => LoginScreen());
        commonToast(response['message'] ?? 'Logged out successfully');
      } else {
        Prefs.clear();
        Get.deleteAll();
        Get.offAll(() => LoginScreen());
        commonToast('Logged out successfully');
      }
    } catch (e) {
      Prefs.clear();
      Get.deleteAll();
      Get.offAll(() => LoginScreen());
      commonToast('Logged out successfully');
    } finally {
      Loader.hideLoader();
    }
  }

  updateLanguage(Locale locale) {
    Get.updateLocale(locale);
    Prefs.setString(AppConstant.languageCode, locale.languageCode);
  }

  deleteUser() async {
    Loader.showLoader();
    try {
      commonToast('Delete user functionality not implemented');
    } catch (e) {
      commonToast('Error deleting user');
    } finally {
      Loader.hideLoader();
    }
  }
}
