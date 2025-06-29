// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:attendance/core/controller/home_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/image_path.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';
import 'package:attendance/views/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance/views/widgets/attendance_row_widget.dart';
import 'package:attendance/views/widgets/team_meetings_section.dart';
import 'package:geolocator/geolocator.dart';
import 'package:attendance/utils/location_helper.dart';

class HomeTabContent extends StatelessWidget {
  final HomeController homeController;

  const HomeTabContent({Key? key, required this.homeController})
      : super(key: key);

  // Helper method to handle location capture and check-in/out
  Future<void> handleLocationBasedAction(
      Function({double? latitude, double? longitude}) action) async {
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

      log('Location captured: ${position.latitude}, ${position.longitude}');

      // Execute the action with location data
      await action(
          latitude: position.latitude,
          longitude: position
              .longitude); // Ensure the action completes before proceeding
    } catch (e) {
      log('Error getting location: $e');
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
      // Debug: Print button state
      print(
          'DEBUG: [UI] Check Out button state - isCheckIn: ${homeController.isCheckIn.value}, attendanceId: ${homeController.attendanceId.value}, button enabled: ${homeController.isCheckIn.value && homeController.attendanceId.value.isNotEmpty}');

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
              verticalSpace(32),
              // Main Fingerprint Button
              IconButton(
                iconSize: 80,
                onPressed: () async {
                  print('DEBUG: Fingerprint pressed. isCheckIn: ' +
                      homeController.isCheckIn.value.toString() +
                      ', attendanceId: ' +
                      homeController.attendanceId.value);

                  if (!homeController.isCheckIn.value) {
                    // If not checked in, attempt check-in
                    await handleLocationBasedAction(
                        homeController.recordCheckIn);
                  } else if (homeController.isCheckIn.value &&
                      homeController.attendanceId.value.isNotEmpty) {
                    // If checked in AND attendanceId is available, attempt check-out
                    await handleLocationBasedAction(
                        homeController.recordCheckOut);
                  } else {
                    // This scenario means isCheckIn is true but attendanceId is empty.
                    // This implies an inconsistent state or that homeApi hasn't fully loaded the attendanceId yet.
                    // Instead of trying to check out (which will fail without attendanceId),
                    // we should inform the user or refresh data.
                    Get.snackbar(
                      'Information',
                      'Please wait, synchronizing attendance data or manually refresh.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blueAccent,
                      colorText: Colors.white,
                    );
                    // Optionally, force a homeApi call to refresh state
                    // await homeController.homeApi();
                  }
                  // Do NOT call homeApi() unconditionally here!
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
                      // Button enabled if NOT checked in OR if checked in but already checked out for the day
                      onPressed: (homeController.isCheckIn.value &&
                              !homeController.isCheckOut.value)
                          ? null
                          : () async {
                              await handleLocationBasedAction(
                                  homeController.recordCheckIn);
                              // No need for homeApi() here, recordCheckIn handles its own updates and potentially calls homeApi
                            },
                      buttonColor: AppColor.primaryColor,
                    ),
                  ),
                  horizontalSpace(16),
                  Expanded(
                    child: CommonButton(
                      title: "Check Out",
                      // Button enabled if checked in AND attendanceId is present AND not already checked out
                      onPressed: (homeController.isCheckIn.value &&
                              homeController.attendanceId.value.isNotEmpty &&
                              !homeController.isCheckOut.value)
                          ? () async {
                              print(
                                  'DEBUG: [Button] Check Out pressed. isCheckIn: ${homeController.isCheckIn.value}, isCheckOut: ${homeController.isCheckOut.value}, attendanceId: ${homeController.attendanceId.value}');
                              homeController.printCurrentState(
                                  'Check Out Button Pressed');
                              await handleLocationBasedAction(
                                  homeController.recordCheckOut);
                              // No need for homeApi() here, recordCheckOut handles its own updates and potentially calls homeApi
                            }
                          : null, // Disabled if conditions not met
                      buttonColor: AppColor.cRed,
                    ),
                  ),
                ],
              ),
              verticalSpace(32),

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
                        dateTimeText:
                            "${homeController.checkInDisplayTime.value} ${homeController.getFormattedDate(DateTime.now())}"),
                    verticalSpace(16),
                    AttendanceRowWidget(
                        iconPath: ImagePath.check_out,
                        title: "Check Out",
                        dateTimeText:
                            "${homeController.checkOutDisplayTime.value} ${homeController.getFormattedDate(DateTime.now())}"),
                    verticalSpace(16),
                    AttendanceRowWidget(
                        iconPath: ImagePath.total_hrs,
                        title: "Hours",
                        dateTimeText: homeController.totalHours.value),
                  ],
                ),
              ),
              verticalSpace(28),
              if (homeController.teamMeetings.isNotEmpty)
                TeamMeetingsSection(homeController: homeController),
              // verticalSpace(30),
              // AnnouncementsSection(homeController: homeController),
            ],
          ),
        ),
      );
    });
  }
}
