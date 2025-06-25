// ignore_for_file: prefer_const_constructors

import 'package:attendance/core/controller/home_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/image_path.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';
import 'package:attendance/views/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:attendance/views/widgets/attendance_row_widget.dart';
import 'package:attendance/views/widgets/team_meetings_section.dart';
import 'package:attendance/views/widgets/announcements_section.dart';
import 'package:geolocator/geolocator.dart';
import 'package:attendance/utils/location_helper.dart';
import 'package:attendance/utils/prefer.dart';

class HomeTabContent extends StatelessWidget {
  final HomeController homeController;

  HomeTabContent({Key? key, required this.homeController}) : super(key: key);

  // Helper method to handle location capture and check-in/out
  Future<void> handleLocationBasedAction(Function({double? latitude, double? longitude}) action) async {
    try {
      Position? position = await LocationHelper.getCurrentLocation();
      
      if (position == null) {
        Get.snackbar(
          'Error',
          'Location permission is required for check-in/out',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      print('Location captured: ${position.latitude}, ${position.longitude}');
      
      // Execute the action with location data
      action(latitude: position.latitude, longitude: position.longitude);
      
    } catch (e) {
      print('Error getting location: $e');
      Get.snackbar(
        'Error',
        'Failed to get location. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                homeController.isTimerRunning.value
                    ? 'Remaining Time: ${homeController.remainingTime.value.inHours}:${(homeController.remainingTime.value.inMinutes % 60).toString().padLeft(2, '0')}:${(homeController.remainingTime.value.inSeconds % 60).toString().padLeft(2, '0')}'
                    : '8:00:00',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColor.darkGreenColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${homeController.getFormattedDate(DateTime.now())}, ${homeController.getFormattedDay(DateTime.now())}',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColor.textColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace(40),
              IconButton(
                iconSize: 100,
                onPressed: () async {
                  print('DEBUG: Fingerprint pressed. isCheckIn: ' + homeController.isCheckIn.value.toString() + ', attendanceId: ' + homeController.attendanceId.value);
                  if (!homeController.isCheckIn.value) {
                    await handleLocationBasedAction(homeController.recordCheckIn);
                    await homeController.homeApi();
                  } else {
                    await handleLocationBasedAction(homeController.recordCheckOut);
                    await homeController.homeApi();
                  }
                },
                icon: assetSvdImageWidget(
                  image: "asset/image/svg_image/ic_fingerprint.svg",
                  height: 100,
                  width: 100,
                ),
              ),
              verticalSpace(40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CommonButton(
                      title: "Check in",
                      onPressed: (homeController.isCheckIn.value && !homeController.isCheckOut.value) ? null : () async {
                        await handleLocationBasedAction(homeController.recordCheckIn);
                      },
                      buttonColor: AppColor.primaryColor,
                    ),
                  ),
                  horizontalSpace(16),
                  Expanded(
                    child: CommonButton(
                      title: "Check Out",
                      onPressed: (homeController.isCheckIn.value && !homeController.isCheckOut.value && homeController.attendanceId.value.isNotEmpty)
                          ? () async {
                              print('DEBUG: [Button] Check Out enabled. isCheckIn: ${homeController.isCheckIn.value}, isCheckOut: ${homeController.isCheckOut.value}, attendanceId: ${homeController.attendanceId.value}');
                              await handleLocationBasedAction(homeController.recordCheckOut);
                            }
                          : null,
                      buttonColor: AppColor.cRed,
                    ),
                  ),
                ],
              ),
              verticalSpace(40),
             
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Attendance",
                  style: pSemiBold21.copyWith(color: AppColor.primaryColor),
                ),
              ),
              verticalSpace(16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.cWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    AttendanceRowWidget(
                        iconPath: ImagePath.check_in,
                        title: "Check in",
                        dateTimeText: "${homeController.checkInDisplayTime.value} ${homeController.getFormattedDate(DateTime.now())}"),
                    verticalSpace(16),
                    AttendanceRowWidget(
                        iconPath: ImagePath.check_out,
                        title: "Check Out",
                        dateTimeText: "${homeController.checkOutDisplayTime.value} ${homeController.getFormattedDate(DateTime.now())}"),
                    verticalSpace(16),
                    AttendanceRowWidget(
                        iconPath: ImagePath.total_hrs,
                        title: "Hours",
                        dateTimeText: homeController.totalHours.value),
                  ],
                ),
              ),
              verticalSpace(30),
              TeamMeetingsSection(homeController: homeController),
              verticalSpace(30),
              AnnouncementsSection(homeController: homeController),
            ],
          ),
        ),
      );
    });
  }
} 