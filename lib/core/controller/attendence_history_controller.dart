// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:attendance/core/model/attendance_history.dart';
import 'package:attendance/network_dio/requests.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:intl/intl.dart';

class AttendanceHistoryController extends GetxController {
  RxList<AttendanceData> attendanceHistoryList = <AttendanceData>[].obs;

  RxInt currentMonth = 0.obs;
  RxInt currentYear = 0.obs;

  RxBool isLoading = false.obs;

  RxString selectedDateText = "".obs;
  var selectedDate = DateTime.now().obs;
  @override
  void onInit() {
    super.onInit();
    currentMonth.value = DateTime.now().month;
    currentYear.value = DateTime.now().year;

    selectedDateText.value = getMonthNameFromDate(selectedDate.value) +
        " " +
        selectedDate.value.year.toString();

    WidgetsBinding.instance.addObserver(AppLifecycleListener());
  }

  int getMonth() {
    DateTime now = DateTime.now();
    return now.month;
  }

  navigateToPreviousMonth() {
    selectedDate.update((val) {
      if (val!.month == 1) {
        val = DateTime(val.year - 1, 12);
        selectedDateText.value =
            getMonthNameFromDate(val) + " " + val.year.toString();
        selectedDate.value = val;

        currentMonth.value = val.month;
        currentYear.value = val.year;
      } else {
        val = DateTime(val.year, val.month - 1);
        selectedDateText.value =
            "${getMonthNameFromDate(val) + " " + val.year.toString()}";
        selectedDate.value = val;

        currentMonth.value = val.month;
        currentYear.value = val.year;
      }
      log(getMonthNameFromDate(val));
    });
    log("CurrentYear $currentYear");
    log("CurrentMonth $currentMonth");
    getAttendanceHistory(
        currentMonth.value.toString(), currentYear.value.toString());
  }

  navigateToNextMonth() {
    selectedDate.update((val) {
      if (val!.month == 12) {
        val = DateTime(val.year + 1, 1);
        selectedDateText.value =
            getMonthNameFromDate(val) + " " + val.year.toString();
        selectedDate.value = val;

        currentMonth.value = val.month;
        currentYear.value = val.year;
      } else {
        val = DateTime(val.year, val.month + 1);
        selectedDateText.value =
            getMonthNameFromDate(val) + " " + val.year.toString();
        selectedDate.value = val;

        currentMonth.value = val.month;
        currentYear.value = val.year;
      }
      log(getMonthNameFromDate(val));
    });

    getAttendanceHistory(
        currentMonth.value.toString(), currentYear.value.toString());
    log("CurrentYear $currentYear");
    log("CurrentMonth $currentMonth");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(AppLifecycleListener());
    super.dispose();
  }

  Future<void> getAttendanceHistory(String month, String year) async {
    try {
      isLoading.value = true;

      var response = await Requests.getAttendanceList(API.attendanceHistory, {
        "workspace_id": Prefs.getString(AppConstant.workSpaceId),
        "type": "monthly",
        "month": month,
        "year": year
      });
      if ((response['status'] == 1 || response['status'] == 200)) {
        AttendanceHistory attendanceHistoryResponse =
            AttendanceHistory.fromJson(response);
        attendanceHistoryList.assignAll(attendanceHistoryResponse.data!);
      }
      isLoading.value = false;
      update();
    } catch (e) {
      isLoading.value = false;
      log("Error fetching attendance history: $e");
    }
  }

  getMonthNameFromDate(DateTime date) {
    final formatter = DateFormat('MMMM');
    final formattedDate = formatter.format(date);
    return formattedDate;
  }

  getFormattedDate(String date) {
    final formatter = DateFormat('dd/MMM/yyyy');
    final formattedDate = formatter.format(DateTime.parse(date));
    return formattedDate;
  }
}
