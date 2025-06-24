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
    Prefs.setString('token', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDc2NzEwOCwiZXhwIjoxNzUwNzcwNzA4LCJuYmYiOjE3NTA3NjcxMDgsImp0aSI6IjY0ZTM4RjlEbkkzTVY2MkciLCJzdWIiOiI1MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.V_3EqIcVlTq1tchlVC_kMsiz4sL7iLE2y7ZO64w6G8Q');
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
        'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDc2NzEwOCwiZXhwIjoxNzUwNzcwNzA4LCJuYmYiOjE3NTA3NjcxMDgsImp0aSI6IjY0ZTM4RjlEbkkzTVY2MkciLCJzdWIiOiI1MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.V_3EqIcVlTq1tchlVC_kMsiz4sL7iLE2y7ZO64w6G8Q',
        // ...other headers
      };
      Map<String, dynamic> requestData = {
        "workspace_id": Prefs.getString(AppConstant.workSpaceId),
        "type": type
      };
      if (attendanceId.value.isNotEmpty) {
        requestData["attendence_id"] = attendanceId.value;
      }
      // Add current date and time
      final now = DateTime.now();
      requestData["current_date"] = DateFormat('yyyy-MM-dd').format(now);
      requestData["current_time"] = DateFormat('HH:mm:ss').format(now);
      // Add location data if available
      if (latitude != null) {
        requestData["current_latitude"] = latitude.toString();
      }
      if (longitude != null) {
        requestData["current_longitude"] = longitude.toString();
      }
      print('POST API URL===> ' + API.isClockIn);
      print('data===> ' + requestData.toString());
      var response = await NetworkHttps.postRequest(API.isClockIn, requestData);
      print('isCheckInApi response: ' + response.toString());
      // Handle success (clock in or clock out)
      if (response['status'] == 1 || response['status'] == 200) {
        var data = response['data'];
        isCheckIn.value = data['is_clockin'] == 1; 
        attendanceId.value = data['attendence_id']?.toString() ?? "";
        checkInTime.value = data['clock_in'] ?? "--";
        checkOutTime.value = data['clock_out'] ?? "--";
        totalHours.value = data['total_hours'] ?? "--";
        print('DEBUG: isCheckInApi (success) -> isCheckIn: ' + isCheckIn.value.toString() + ', attendanceId: ' + attendanceId.value);
        // Refresh attendance history after check-in/out
        Get.find<AttendanceHistoryController>().attendanceHistory(
          Get.find<AttendanceHistoryController>().currentMonth.value.toString(),
          Get.find<AttendanceHistoryController>().currentYear.value.toString(),
        );
        return true; // Indicate success
      } 
      // Handle already clocked in (clock in fail)
      else if (response['status'] == 422 && response['message'] == "Please Employee First Clock Out.") {
        var data = response['data'];
        isCheckIn.value = data['is_clockin'] == 1;
        attendanceId.value = data['attendence_id']?.toString() ?? "";
        checkInTime.value = data['clock_in'] ?? "--";
        checkOutTime.value = data['clock_out'] ?? "--";
        print('DEBUG: isCheckInApi (already clocked in) -> isCheckIn: ' + isCheckIn.value.toString() + ', attendanceId: ' + attendanceId.value);
        commonToast(response['message']);
        await homeApi();
        return false;
      }
      // Handle already clocked out (clock out fail)
      else if (response['status'] == 422 && response['message'] == "Please Employee First Clock In.") {
        var data = response['data'];
        isCheckIn.value = data['is_clockin'] == 1;
        attendanceId.value = data['attendence_id']?.toString() ?? "";
        checkInTime.value = data['clock_in'] ?? "--";
        checkOutTime.value = data['clock_out'] ?? "--";
        print('DEBUG: isCheckInApi (already clocked out) -> isCheckIn: ' + isCheckIn.value.toString() + ', attendanceId: ' + attendanceId.value);
        commonToast(response['message']);
        await homeApi();
        return false;
      }
      // Handle not in area
      else if (response['status'] == 403 && response['message'] == "You are not within allowed company location.") {
        commonToast(response['message']);
        print('DEBUG: isCheckInApi (not in area)');
        return false;
      }
      // Handle other errors
      else {
        String errorMsg = response["message"] ?? "An error occurred.";
        commonToast(errorMsg);
        print('DEBUG: isCheckInApi (other error) -> ' + errorMsg);
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
      // Call the real API to fetch home data
      // There is no API.homeData, so we use API.isClockIn to get current attendance state
      var response = await NetworkHttps.postRequest(API.isClockIn, {
        "workspace_id": Prefs.getString(AppConstant.workSpaceId),
        "type": "status" // Use a special type or as required by your backend to fetch status only
      });
      if (response != null && response['status'] == 1 && response['data'] != null) {
        var data = response['data'];
        // Update attendance state
        isCheckIn.value = (data['is_clockin'] == 1 && (data['clock_out'] == null || data['clock_out'] == "00:00:00"));
        attendanceId.value = data['attendance_id']?.toString() ?? "";
        checkInTime.value = data['clock_in'] ?? "--";
        checkOutTime.value = data['clock_out'] ?? "--";
        totalHours.value = data['total_hours'] ?? "--";
        print('DEBUG: homeApi -> isCheckIn: ' + isCheckIn.value.toString() + ', attendanceId: ' + attendanceId.value);
      } else {
        // If no data, reset state
        isCheckIn.value = false;
        attendanceId.value = "";
        checkInTime.value = "--";
        checkOutTime.value = "--";
        totalHours.value = "--";
        print('DEBUG: homeApi (no data) -> isCheckIn: ' + isCheckIn.value.toString() + ', attendanceId: ' + attendanceId.value);
      }
      announcementList.clear();
      teamMeetings.clear();

      // Fetch meetings from real API
      try {
        var meetingsResponse = await NetworkHttps.postRequest(API.eventCalender, {
          "workspace_id": Prefs.getString(AppConstant.workSpaceId)
        });
        teamMeetings.clear();
        if (meetingsResponse != null && meetingsResponse['status'] == 200 && meetingsResponse['data'] != null) {
          for (var meeting in meetingsResponse['data']) {
            teamMeetings.add({
              'title': meeting['meeting_title'] ?? '',
              'description': meeting['meeting_description'] ?? '',
              'date': meeting['meeting_date'] != null ? DateTime.parse(meeting['meeting_date']) : DateTime.now(),
            });
          }
        }
      } catch (e) {
        print('Error fetching meetings: ' + e.toString());
      }
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
          print('DEBUG: recordCheckIn (before API) -> isCheckIn: ' + isCheckIn.value.toString() + ', attendanceId: ' + attendanceId.value);
          bool success = await isCheckInApi('clockin', latitude: latitude, longitude: longitude);
          if (!success) {
            isCheckIn.value = previousCheckInState; // Revert on failure
          }
        },
        child: Text('Confirm', style: TextStyle(color: AppColor.cWhite)),
      ),
    );
  }

  void recordCheckOut({double? latitude, double? longitude}) {
    if (attendanceId.value.isEmpty) {
      commonToast("No open attendance record found. Please clock in first.");
      return;
    }
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
          print('DEBUG: recordCheckOut (before API) -> isCheckIn: ' + isCheckIn.value.toString() + ', attendanceId: ' + attendanceId.value);
          bool success = await isCheckInApi('clockout', latitude: latitude, longitude: longitude);
          if (success) {
            // Refresh state from backend after successful clock-out
            await homeApi();
          } else {
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
    // This function is now unused since meetings are fetched from the API
  }
}
