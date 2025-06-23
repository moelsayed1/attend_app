import 'dart:async';

import 'package:attendance/core/model/clock_in_response.dart';
import 'package:attendance/core/model/home_response.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/views/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/core/controller/attendence_history_controller.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();
  
  RxBool isCheckIn = false.obs;
  RxString checkInTime = "00:00".obs;
  RxString checkOutTime = "00:00".obs;
  RxString totalHours = "00:00".obs;
  RxString attendanceId = "".obs;

  RxBool isLoading = false.obs;
  RxBool isViewVisible = false.obs;

  Rx<DateTime> currentTime = DateTime.now().obs;
  late Timer _timer;

  RxList<Announcements> announcementList = <Announcements>[].obs;

  // Observables to hold check-in and check-out display times
  RxString checkInDisplayTime = "--:--".obs;
  RxString checkOutDisplayTime = "--:--".obs;

  // Internal DateTime objects for calculation
  DateTime? _checkInDateTime;
  DateTime? _checkOutDateTime;

  Timer? _workTimer;
  final Rx<Duration> remainingTime = const Duration(hours: 8).obs;
  final RxBool isTimerRunning = false.obs;

  RxList<Map<String, dynamic>> teamMeetings = <Map<String, dynamic>>[].obs;

  // PageController for Bottom Navigation
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    WidgetsBinding.instance.addObserver(AppLifecycleListener());
    homeApi();
    loadCheckInOutTimes();
    addTeamMeeting(); // Add initial team meeting
    Get.put(AttendanceHistoryController()); // Initialize AttendanceHistoryController
    Prefs.setString('token', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDY4NjYxMSwiZXhwIjoxNzUwNjkwMjExLCJuYmYiOjE3NTA2ODY2MTEsImp0aSI6ImNzeFoycThlNTVmRkp2NEYiLCJzdWIiOiI1MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.2jA-t-9GkGraSa7Uxf8uFzFrWyu17dzWXNVTg0jVqgs');
  }

  @override
  void onClose() {
    _timer.cancel();
    _workTimer?.cancel();
    pageController.dispose(); // Dispose the pageController
    WidgetsBinding.instance.removeObserver(AppLifecycleListener());
    super.onClose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (timer) {
        currentTime.value = DateTime.now();
      },
    );
  }

  void startWorkTimer() {
    isTimerRunning.value = true;
    remainingTime.value = const Duration(hours: 8);
    _workTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value.inSeconds > 0) {
        remainingTime.value = remainingTime.value - const Duration(seconds: 1);
      } else {
        _workTimer?.cancel();
        isTimerRunning.value = false;
        Get.snackbar(
          'Time Complete',
          'Your 8-hour work period has ended!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
  }
    });
  }

  Future<bool> isCheckInApi(String type, {double? latitude, double? longitude}) async {
    print('Calling isCheckInApi with type: ' + type + ', lat: ' + (latitude?.toString() ?? 'null') + ', lng: ' + (longitude?.toString() ?? 'null'));
    Loader.showLoader();
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDY4NjYxMSwiZXhwIjoxNzUwNjkwMjExLCJuYmYiOjE3NTA2ODY2MTEsImp0aSI6ImNzeFoycThlNTVmRkp2NEYiLCJzdWIiOiI1MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.2jA-t-9GkGraSa7Uxf8uFzFrWyu17dzWXNVTg0jVqgs',
        // ...other headers
      };
      Map<String, dynamic> requestData = {
        "workspace_id": Prefs.getString(AppConstant.workSpaceId),
        "type": type,
        "attendence_id": attendanceId.value
      };
      // Add location data if available
      if (latitude != null) {
        requestData["latitude"] = latitude.toString();
      }
      if (longitude != null) {
        requestData["longitude"] = longitude.toString();
      }
      print('POST API URL===> ' + API.isClockIn);
      print('data===> ' + requestData.toString());
      var response = await NetworkHttps.postRequest(API.isClockIn, requestData);
      print('isClockInApi response: ' + response.toString());
      if (response['status'] == 1) {
        var attendanceReport = ClockInResponse.fromJson(response);
        Prefs.setString(
            Prefs.Attendance_Id, attendanceReport.data!.attendenceId.toString());
        checkInTime.value = attendanceReport.data!.clockIn ?? "--";
        checkOutTime.value = attendanceReport.data!.clockOut ?? "--";
        totalHours.value = attendanceReport.data!.totalHours ?? "--";
        attendanceId.value = attendanceReport.data!.attendenceId.toString();
        
        // Refresh attendance history after check-in/out
        Get.find<AttendanceHistoryController>().attendanceHistory(
          Get.find<AttendanceHistoryController>().currentMonth.value.toString(),
          Get.find<AttendanceHistoryController>().currentYear.value.toString(),
        );
        return true; // Indicate success
      } else {
        // Show the API's error message to the user
        String errorMsg = response["message"] ?? "An error occurred.";
        commonToast(errorMsg);
        return false; // Indicate failure
      }
    } catch (e) {
      commonToast("An error occurred. Please try again.");
      return false; // Indicate failure
    } finally {
      Loader.hideLoader();
    }
  }

  String getFormattedDate(DateTime now) {
    final formatter = DateFormat('MMM dd yyyy');
    final formattedDate = formatter.format(now);
    return formattedDate;
  }

  String eventDate(String? date) {
    if (date == null) return '';
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd/MMM/yyyy').format(dateTime);
  }

  homeApi() async {
    if (isLoading.value) return; // Prevent multiple simultaneous calls
    
    isLoading.value = true;
    Loader.showLoader();
    
    try {
      // TODO: Integrate real API call here to fetch home data
      // Example:
      // var response = await NetworkHttps.postRequest(API.homeData, { ... });
      // if (response['status'] == 1) {
      //   checkInTime.value = response['data']['clockIn'] ?? "--";
      //   checkOutTime.value = response['data']['clockOut'] ?? "--";
      //   totalHours.value = response['data']['totalHours'] ?? "--";
      //   // ...and so on
      // } else {
      //   commonToast(response["message"]);
      // }
      // For now, do not assign any static values.
      announcementList.clear();
      teamMeetings.clear();
    } catch (e) {
      commonToast("An error occurred. Please try again.");
    } finally {
      isLoading.value = false;
      Loader.hideLoader();
    }
  }

  String getFormattedTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  void recordCheckIn({double? latitude, double? longitude}) {
    print('DEBUG: recordCheckIn called with latitude: ' + (latitude?.toString() ?? 'null') + ', longitude: ' + (longitude?.toString() ?? 'null'));
    Get.snackbar(
      'Confirm Check-in',
      'Welcome back! Are you check in now?',
      backgroundColor: AppColor.primaryColor,
      colorText: AppColor.cWhite,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () async {
          Get.back();
          // Real API logic only
          final previousCheckInState = isCheckIn.value;
          isCheckIn.value = true; // Optimistic update
          final now = DateTime.now();
          _checkInDateTime = now;
          checkInDisplayTime.value = DateFormat('hh:mm a').format(now);
          Prefs.setString('check_in_time', checkInDisplayTime.value);
          Prefs.setString('check_in_latitude', (latitude ?? 0.0).toString());
          Prefs.setString('check_in_longitude', (longitude ?? 0.0).toString());
          startWorkTimer();
          bool success = await isCheckInApi('in', latitude: latitude, longitude: longitude);
          if (!success) {
            isCheckIn.value = previousCheckInState; // Revert on failure
          }
        },
        child: Text('Confirm', style: TextStyle(color: AppColor.cWhite)),
      ),
    );
  }

  void recordCheckOut({double? latitude, double? longitude}) {
    print('DEBUG: recordCheckOut called with latitude: ' + (latitude?.toString() ?? 'null') + ', longitude: ' + (longitude?.toString() ?? 'null'));
    Get.snackbar(
      'Confirm Check-out',
      'Are you sure you want to check out now?',
      backgroundColor: AppColor.cRed,
      colorText: AppColor.cWhite,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () async {
          Get.back();
          // Real API logic only
          final previousCheckInState = isCheckIn.value;
          isCheckIn.value = false;
          final now = DateTime.now();
          _checkOutDateTime = now;
          checkOutDisplayTime.value = DateFormat('hh:mm a').format(now);
          Prefs.setString('check_out_time', checkOutDisplayTime.value);
          Prefs.setString('check_out_latitude', (latitude ?? 0.0).toString());
          Prefs.setString('check_out_longitude', (longitude ?? 0.0).toString());
          // Calculate total time
          if (_checkInDateTime != null) {
            final difference = now.difference(_checkInDateTime!);
            final hours = difference.inHours;
            final minutes = difference.inMinutes.remainder(60);
            totalHours.value = '$hours:${minutes.toString().padLeft(2, '0')}';
            Prefs.setString('total_hours', totalHours.value);
          }
          _workTimer?.cancel();
          isTimerRunning.value = false;
          bool success = await isCheckInApi('out', latitude: latitude, longitude: longitude);
          if (!success) {
            isCheckIn.value = previousCheckInState;
          }
        },
        child: Text('Confirm', style: TextStyle(color: AppColor.cWhite)),
      ),
    );
  }

  String getFormattedDay(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  void loadCheckInOutTimes() {
    checkInDisplayTime.value = Prefs.getString('check_in_time') ?? "";
    checkOutDisplayTime.value = Prefs.getString('check_out_time') ?? "";
  }

  void addTeamMeeting() {
    final now = DateTime.now();
    final meetingTime = DateTime(now.year, now.month, now.day, 17, 0); // 5 PM
    
    teamMeetings.add({
      'title': 'Team Meeting',
      'description': 'Team meeting regarding productivity',
      'date': meetingTime,
    });
  }
}
