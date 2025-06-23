import 'package:attendance/core/model/holiday_list_response.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HolidayListController extends GetxController {
  RxList<HolidayData> holidayList = <HolidayData>[].obs;
  RxBool isLoading=false.obs;

  RxBool _isUsingStaticData = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(AppLifecycleListener());
    if (_isUsingStaticData.value) {
      _loadStaticHolidayList();
    } else {
      getHolidayList();
    }
  }

  void _loadStaticHolidayList() {
    holidayList.clear();
    holidayList.addAll([
      HolidayData(
        title: "Celebration",
        start: "2023-12-30",
        end: "2023-12-30",
        className: "Saturday",
      ),
      HolidayData(
        title: "Party",
        start: "2023-12-07",
        end: "2023-12-07",
        className: "Thursday",
      ),
      HolidayData(
        title: "Good Friday",
        start: "2024-01-07",
        end: "2024-01-07",
        className: "Sunday",
      ),
      HolidayData(
        title: "Event",
        start: "2024-01-10",
        end: "2024-01-10",
        className: "Wednesday",
      ),
      HolidayData(
        title: "Krishna Janmashtami",
        start: "2024-02-10",
        end: "2024-02-10",
        className: "Saturday",
      ),
      HolidayData(
        title: "Indian Independence Day",
        start: "2024-08-15",
        end: "2024-08-15",
        className: "Thursday",
      ),
    ]);
    holidayList.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(AppLifecycleListener());
    super.dispose();
  }

  Future<void> getHolidayList() async {
    try {
      isLoading.value = true;
      if (_isUsingStaticData.value) {
        _loadStaticHolidayList();
    } else {
        var response = await NetworkHttps.postRequest(API.holidayList,{"workspace_id": Prefs.getString(AppConstant.workSpaceId)});
        if (response['status'] == 1) {
          HolidayListResponse holidayListResponse = HolidayListResponse.fromJson(response);
          holidayList.assignAll(holidayListResponse.data!);
        }
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print("Error fetching holiday list: $e");
      }
  }
}
