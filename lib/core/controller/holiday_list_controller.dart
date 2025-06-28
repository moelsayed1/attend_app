import 'package:attendance/core/model/holiday_list_response.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HolidayListController extends GetxController {
  RxList<HolidayData> holidayList = <HolidayData>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(AppLifecycleListener());
    getHolidayList();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(AppLifecycleListener());
    super.dispose();
  }

  Future<void> getHolidayList() async {
    try {
      isLoading.value = true;

      // var dummy = await rootBundle.loadString('asset/dummyHolidays.json');
      // var response = jsonDecode(dummy);
      var response = await NetworkHttps.postRequest(API.holidayList,
          {"workspace_id": Prefs.getString(AppConstant.workSpaceId)});

      if (response['status'] == 200) {
        // Changed from 1 to 200 to match typical HTTP status
        HolidayListResponse holidayListResponse =
            HolidayListResponse.fromJson(response);
        if (holidayListResponse.data != null &&
            holidayListResponse.data!.isNotEmpty) {
          holidayList.assignAll(holidayListResponse.data!);
          holidayList.refresh(); // Force UI update
        }
      }
    } catch (e) {
      print("Error fetching holiday list: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
