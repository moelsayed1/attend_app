// ignore_for_file: prefer_const_constructors

import 'package:attendance/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loader {
  static showLoader() {
    Get.dialog(LoadingWidget());
  }

  static hideLoader() {
    Get.back();
    // Get.back(closeOverlays: true);
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColor.primaryColor),
    );
  }
}
