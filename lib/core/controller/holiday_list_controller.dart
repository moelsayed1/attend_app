import 'package:attendance/core/model/holiday_list_response.dart';
import 'package:attendance/network_dio/requests.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';

class HolidayListController extends GetxController {
  RxList<HolidayData> holidayList = <HolidayData>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      WidgetsBinding.instance.addObserver(AppLifecycleListener());
      // Defer API call until after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!Get.isRegistered<HolidayListController>()) return;
        getHolidayList();
      });
    } catch (e) {
      log("Error in onInit: $e");
    }
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
      var response = await Requests.getHolidayList(API.holidayList);

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
      update();
    } catch (e) {
      log("Error fetching holiday list: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
