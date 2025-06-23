// ignore_for_file: prefer_const_constructors

import 'package:attendance/core/controller/setting_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/image_path.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileCard extends StatelessWidget {
  final SettingController settingController;

  const UserProfileCard({Key? key, required this.settingController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.cWhite,
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primaryColor,
                width: 2.0,
              ),
            ),
            child: ClipOval(
              child: settingController.profileImage.value != ""
                  ? CachedNetworkImage(
                      imageUrl: settingController.profileImage.value,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Image.asset(ImagePath.placeholder, fit: BoxFit.cover),
                    )
                  : Image.asset(ImagePath.placeholder, fit: BoxFit.cover),
            ),
          ),
          horizontalSpace(16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settingController.name.value.isEmpty 
                      ? "Mostafa"
                      : settingController.name.value,
                  style: pSemiBold18.copyWith(color: AppColor.cBlack),
                  textAlign: TextAlign.start,
                ),
                verticalSpace(4),
                Text(
                  settingController.email.value.isEmpty 
                      ? "Mostafa@example.com"
                      : settingController.email.value,
                  style: pRegular12.copyWith(color: AppColor.textColor),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
} 