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

class HomeController extends GetxController with WidgetsBindingObserver {
  static HomeController get to => Get.find();
  
  RxBool isCheckIn = false.obs;
  RxBool isCheckOut = false.obs;
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
  DateTime? checkInDateTime;
  DateTime? checkOutDateTime;

  Timer? workTimer;
  final Rx<Duration> remainingTime = const Duration(hours: 8).obs;
  final RxBool isTimerRunning = false.obs;

  RxList<Map<String, dynamic>> teamMeetings = <Map<String, dynamic>>[].obs;

  // PageController for Bottom Navigation
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    WidgetsBinding.instance.addObserver(this);
    print('DEBUG: [onInit] Calling homeApi to load initial state...');
    homeApi();
    loadCheckInOutTimes();
    addTeamMeeting(); // Add initial team meeting
    Get.put(AttendanceHistoryController()); // Initialize AttendanceHistoryController
    Prefs.setString('token', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDg1OTU5OSwiZXhwIjoxNzUwODYzMTk5LCJuYmYiOjE3NTA4NTk1OTksImp0aSI6IlduRHFERVp5U0VDcTd6YWsiLCJzdWIiOiI1MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.n5bHfUZmTJMp1pkSSdcaiUbjsJN1HY84y7SuGvVQYTI');
    // Print initial state
    printCurrentState('onInit');
  }

  @override
  void onClose() {
    _timer.cancel();
    workTimer?.cancel();
    pageController.dispose(); // Dispose the pageController
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Implement any lifecycle logic if needed
    super.didChangeAppLifecycleState(state);
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
    workTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value.inSeconds > 0) {
        remainingTime.value = remainingTime.value - const Duration(seconds: 1);
      } else {
        workTimer?.cancel();
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
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDg1OTc0NCwiZXhwIjoxNzUwODYzMzQ0LCJuYmYiOjE3NTA4NTk3NDQsImp0aSI6IlhSZmVjZkRNc1lMQUhLUHQiLCJzdWIiOiI1MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.IKTjW46_YKp4aCFG6CDIgZG5Xv2iIz-jNB7Rp3kmAIs',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // ...other headers
      };
      Map<String, dynamic> requestData = {
        "workspace_id": Prefs.getString(AppConstant.workSpaceId),
        "type": type
      };
      // Always send attendence_id for clockout if available
      if (type == 'clockout' && attendanceId.value.isNotEmpty) {
        requestData["attendence_id"] = attendanceId.value;
        print('DEBUG: [isCheckInApi] Adding attendence_id to clockout payload: \\${attendanceId.value}');
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
      print('DEBUG: [isCheckInApi] Payload being sent: $requestData');
      var response = await NetworkHttps.postRequest(API.isClockIn, requestData);
      print('isCheckInApi response: ' + response.toString());
      print('DEBUG: [isCheckInApi] State after API response:');
      printCurrentState('isCheckInApi - after API response');
      // Handle success (clock in or clock out)
      if (response['status'] == 1 || response['status'] == 200) {
        var data = response['data'];
        isCheckIn.value = data['is_clockin'] == 1; 
        isCheckOut.value = data.containsKey('clock_out') && data['clock_out'] != null && data['clock_out'] != '00:00:00';
        attendanceId.value = data['attendence_id']?.toString() ?? "";
        checkInTime.value = data['clock_in'] ?? "--";
        checkOutTime.value = data['clock_out'] ?? "--";
        totalHours.value = data['total_hours'] ?? "--";
        print('DEBUG: isCheckInApi (success) -> isCheckIn: ' + isCheckIn.value.toString() + ', isCheckOut: ' + isCheckOut.value.toString() + ', attendanceId: ' + attendanceId.value);
        // Refresh attendance history after check-in/out
        Get.find<AttendanceHistoryController>().attendanceHistory(
          Get.find<AttendanceHistoryController>().currentMonth.value.toString(),
          Get.find<AttendanceHistoryController>().currentYear.value.toString(),
        );
        return true; // Indicate success
      } 
      // Handle already clocked in (clock in fail)
      else if (response['status'] == 422 && response['message'] == "Please Employee First Clock Out.") {
        // Already checked in, so update state with current attendance data
        var data = response['data'];
        isCheckIn.value = data['is_clockin'] == 1;
        isCheckOut.value = data.containsKey('clock_out') && data['clock_out'] != null && data['clock_out'] != '00:00:00';
        attendanceId.value = data['attendence_id']?.toString() ?? "";
        checkInTime.value = data['clock_in'] ?? "--";
        checkOutTime.value = data['clock_out'] ?? "--";
        totalHours.value = data['total_hours'] ?? "--";
        print('DEBUG: isCheckInApi (already clocked in) -> isCheckIn: ' + isCheckIn.value.toString() + ', isCheckOut: ' + isCheckOut.value.toString() + ', attendanceId: ' + attendanceId.value);
        printCurrentState('isCheckInApi - already clocked in');
        commonToast(response['message']);
        return false;
      }
      // Handle already clocked out (clock out fail)
      else if (response['status'] == 422 && response['message'] == "Please Employee First Clock In.") {
        // Not checked in, so can't check out
        isCheckIn.value = false;
        isCheckOut.value = false;
        attendanceId.value = "";
        checkInTime.value = "--";
        checkOutTime.value = "--";
        totalHours.value = "--";
        print('DEBUG: isCheckInApi (already clocked out) -> isCheckIn: ' + isCheckIn.value.toString() + ', isCheckOut: ' + isCheckOut.value.toString() + ', attendanceId: ' + attendanceId.value);
        commonToast(response['message']);
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
    try {
      printCurrentState('homeApi - start');
      
      bool statusSuccess = await isCheckInApi('status');
      if (!statusSuccess) {
        isCheckIn.value = false;
        isCheckOut.value = false;
        attendanceId.value = "";
        checkInTime.value = "--";
        checkOutTime.value = "--";
        totalHours.value = "--";
        print('DEBUG: homeApi (no data or error) -> isCheckIn: ' + isCheckIn.value.toString() + ', attendanceId: ' + attendanceId.value);
        //printCurrentState('homeApi - no data');
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
      isCheckIn.value = false;
      isCheckOut.value = false;
      attendanceId.value = "";
      checkInTime.value = "--";
      checkOutTime.value = "--";
      totalHours.value = "--";
    } finally {
      isLoading.value = false;
    }
  }

  String getFormattedTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Utility function for animated dialog
  void showAnimatedDialog(BuildContext context, Widget child) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  void recordCheckIn({double? latitude, double? longitude}) {
    print('DEBUG: recordCheckIn called with latitude: ' + (latitude?.toString() ?? 'null') + ', longitude: ' + (longitude?.toString() ?? 'null'));

    // Check if already checked in
    if (isCheckIn.value && attendanceId.value.isNotEmpty) {
      Get.snackbar(
        'Already Checked In',
        'You are already checked in. Please check out first.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Show animated confirmation dialog
    showAnimatedDialog(
      Get.context!,
      AlertDialog(
        title: Text('Confirm Check-in'),
        content: Text('Are you sure you want to check in now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(Get.context!).pop(); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(Get.context!).pop(); // Close dialog
              bool success = await isCheckInApi('clockin', latitude: latitude, longitude: longitude);
              if (success) {
                final now = DateTime.now();
                checkInDateTime = now;
                checkInDisplayTime.value = DateFormat('hh:mm a').format(now);
                Prefs.setString('check_in_time', checkInDisplayTime.value);
                Prefs.setString('check_in_latitude', (latitude ?? 0.0).toString());
                Prefs.setString('check_in_longitude', (longitude ?? 0.0).toString());
                startWorkTimer();
              }
            },
            child: Text('Confirm', style: TextStyle(color: AppColor.primaryColor)),
          ),
        ],
      ),
    );
  }

  void recordCheckOut({double? latitude, double? longitude}) {
    if (attendanceId.value.isEmpty) {
      commonToast("No open attendance record found. Please clock in first.");
      return;
    }
    print('DEBUG: recordCheckOut called with latitude: ' + (latitude?.toString() ?? 'null') + ', longitude: ' + (longitude?.toString() ?? 'null'));
    print('DEBUG: recordCheckOut - attendanceId before API: ' + attendanceId.value);
    
    // Show animated confirmation dialog
    showAnimatedDialog(
      Get.context!,
      AlertDialog(
        title: Text('Confirm Check-out'),
        content: Text('Are you sure you want to check out now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(Get.context!).pop(); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(Get.context!).pop(); // Close dialog
              await _performCheckOut(latitude: latitude, longitude: longitude);
            },
            child: Text('Confirm', style: TextStyle(color: AppColor.cRed)),
          ),
        ],
      ),
    );
  }

  Future<void> _performCheckOut({double? latitude, double? longitude}) async {
    try {
      printCurrentState('_performCheckOut - start');
      
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      bool success = await isCheckInApi('clockout', latitude: latitude, longitude: longitude);
      print('DEBUG: recordCheckOut - checkout API result: ' + success.toString());
      printCurrentState('_performCheckOut - after API call');
      Get.back(); // Close loading dialog
      
      if (success) {
        final now = DateTime.now();
        checkOutDateTime = now;
        checkOutDisplayTime.value = DateFormat('hh:mm a').format(now);
        Prefs.setString('check_out_time', checkOutDisplayTime.value);
        Prefs.setString('check_out_latitude', (latitude ?? 0.0).toString());
        Prefs.setString('check_out_longitude', (longitude ?? 0.0).toString());
        if (checkInDateTime != null) {
          final difference = now.difference(checkInDateTime!);
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          totalHours.value = '$hours:${minutes.toString().padLeft(2, '0')}';
          Prefs.setString('total_hours', totalHours.value);
        }
        workTimer?.cancel();
        isTimerRunning.value = false;
        Get.snackbar(
          'Success',
          'Check-out completed successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await homeApi();
      } else {
        Get.snackbar(
          'Error',
          'Failed to check out. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      print('DEBUG: recordCheckOut - Exception: $e');
      Get.snackbar(
        'Error',
        'An error occurred during check-out: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
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

  // Debug method to print current state
  void printCurrentState(String context) {
    print('DEBUG: [$context] Current State:');
    print('  - isCheckIn: ${isCheckIn.value}');
    print('  - isCheckOut: ${isCheckOut.value}');
    print('  - attendanceId: ${attendanceId.value}');
    print('  - checkInTime: ${checkInTime.value}');
    print('  - checkOutTime: ${checkOutTime.value}');
    print('  - totalHours: ${totalHours.value}');
  }

  // Test method for debugging checkout
  void testCheckOut() {
    print('DEBUG: testCheckOut called');
    printCurrentState('testCheckOut');
    recordCheckOut(latitude: 0.0, longitude: 0.0);
  }

  // Test method for debugging snackbar
  void testSnackbar() {
    print('DEBUG: testSnackbar called');
    Get.snackbar(
      'Test',
      'This is a test snackbar',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Method to manually refresh state for testing
  void refreshState() {
    print('DEBUG: refreshState called');
    homeApi();
  }
}
