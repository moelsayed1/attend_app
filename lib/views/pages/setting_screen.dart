// ignore_for_file: prefer_const_constructors

import 'package:attendance/core/controller/setting_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/custom_switch.dart';
import 'package:attendance/utils/image_path.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/pages/login_screen.dart';
import 'package:attendance/views/pages/settings/change_password_screen.dart';
import 'package:attendance/views/pages/settings/edit_profile.dart';
import 'package:attendance/views/pages/settings/workspace_screen.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';
import 'package:attendance/views/widgets/setting_menu_item.dart';
import 'package:attendance/views/widgets/user_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final SettingController settingController = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGround,
      appBar: AppBar(
        backgroundColor: AppColor.cWhite,
        surfaceTintColor: Colors.transparent,
        title: Text("Settings",
            style: pSemiBold21.copyWith(color: AppColor.primaryColor)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() {
            return Column(
              children: [
                UserProfileCard(settingController: settingController),
                verticalSpace(10),
                SettingMenuItem(
                  iconPath: ImagePath.userEdit,
                  title: "Edit Profile".tr,
                  onTap: () {
                    Get.to(() => EditProfileScreen())?.then((value) {
                      if (value == true) {
                        settingController.profileImage.value =
                            Prefs.getString(AppConstant.profileImage);
                        settingController.name.value =
                            Prefs.getString(AppConstant.userName);
                        settingController.email.value =
                            Prefs.getString(AppConstant.emailId);
                      }
                    });
                  },
                ),
                verticalSpace(10),
                SettingMenuItem(
                  iconPath: ImagePath.logoutIcn,
                  title: "Change Password".tr,
                  onTap: () {
                    Get.to(() => ChangePasswordScreen());
                  },
                ),
                verticalSpace(10),
                SettingMenuItem(
                  iconPath:
                      ImagePath.userEdit, // Using userEdit icon for workspace
                  title: "WorkSpace".tr,
                  onTap: () {
                    Get.to(() => WorkSpaceScreen());
                  },
                ),
                verticalSpace(10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      assetSvdImageWidget(
                          image: ImagePath.rtlIcn, width: 24, height: 24),
                      horizontalSpace(16),
                      verticalSpace(50),
                      Expanded(
                        child: Text(
                          "Enable RTL".tr,
                          style: pMedium16.copyWith(
                              color: AppColor.cBlack, fontSize: 18),
                        ),
                      ),
                      CustomSwitch(
                        value: settingController.isRtl.value,
                        onChanged: (value) {
                          if (value == true) {
                            settingController.languageCode.value = 'ar';
                            settingController.isRtl.value = true;
                            settingController
                                .updateLanguage(const Locale("ar", "AR"));
                          } else {
                            settingController.isRtl.value = false;
                            settingController.languageCode.value = 'en';
                            settingController
                                .updateLanguage(const Locale("en", "US"));
                          }
                          Prefs.setBool(
                              AppConstant.isRtl, settingController.isRtl.value);
                        },
                      ),
                    ],
                  ),
                ),
                verticalSpace(10),
                SettingMenuItem(
                  iconPath: ImagePath.logoutIcn,
                  title: "Logout".tr,
                  onTap: () {
                    if (Prefs.getBool(AppConstant.isDemoMode)) {
                      Get.offAll(() => LoginScreen());
                    } else {
                      settingController.logOutData();
                    }
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Prefs.getBool(AppConstant.isDemoMode) == true) {
      settingController.profileImage.value = "";
      settingController.name.value = "Alex";
      settingController.email.value = "alex.turner@example.com";
    } else {
      settingController.profileImage.value =
          Prefs.getString(AppConstant.profileImage);
      settingController.name.value = Prefs.getString(AppConstant.userName);
      settingController.email.value = Prefs.getString(AppConstant.emailId);
    }
  }
}
