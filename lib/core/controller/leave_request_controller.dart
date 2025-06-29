import 'dart:convert';
import 'package:attendance/core/model/leave_history_response.dart';
import 'package:attendance/core/model/leave_types_response.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/views/widgets/loading_widget.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/views/pages/leave_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveRequestController extends GetxController {
  RxList<LeaveData> myLeavesHistory = <LeaveData>[].obs;
  RxList<LeaveType> leaveTypes = <LeaveType>[].obs;
  MyLeavesResponse? myLeavesResponse;
  LeaveTypesResponse? leaveTypeResponse;
  RxBool isLoading = false.obs;

  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;

  RxString leaveType = ''.obs;
  RxString leaveId = ''.obs;



  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: startDate.value,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate.value) {
      startDate.value = picked;
      endDate.value = picked;
    }
    print("startDate ${startDate.value}");
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: startDate.value,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate.value) {
      endDate.value = picked;
    }
    print("endDate ${endDate.value}");
  }

  String getFormattedDate(DateTime now) {
    final formatter = DateFormat('dd/MM/yyyy');
    final formattedDate = formatter.format(now);
    return formattedDate;
  }

  String getParameterFormattedDate(DateTime now) {
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedDate = formatter.format(now);
    return formattedDate;
  }

  Future<void> getMyLeaves() async {
    // Set loading state before any UI updates
    isLoading.value = true;

    try {
      // Make API request
      final response = await NetworkHttps.postRequest(
        API.getLeaves,
        {"workspace_id": Prefs.getString(AppConstant.workSpaceId)}
      );

      print("Debug - API Response: $response");

      // Process response outside of build context
      if (response.containsKey("status")) {
        if (response["status"] == 1 || response["status"] == 200) {
          myLeavesResponse = MyLeavesResponse.fromJson(response);
        } else {
          print("API Error: ${response['status']}");
          Get.snackbar('Error', response["message"] ?? 'Unknown error');
          return;
        }
      } else if (response.containsKey("data")) {
        myLeavesResponse = MyLeavesResponse.fromDataArray(response["data"]);
      } else {
        print("Invalid response format");
        Get.snackbar('Error', 'Invalid response format');
        return;
      }

      // Update observable list safely
      if (myLeavesResponse?.data != null) {
        myLeavesHistory.clear();
        
        // Sort the data by appliedOn field in descending order (newest first)
        List<LeaveData> sortedData = List.from(myLeavesResponse!.data!);
        sortedData.sort((a, b) {
          // Handle null values
          if (a.appliedOn == null && b.appliedOn == null) return 0;
          if (a.appliedOn == null) return 1; // null values go to the end
          if (b.appliedOn == null) return -1;
          
          // Parse dates and compare in descending order (newest first)
          try {
            DateTime dateA = DateTime.parse(a.appliedOn!);
            DateTime dateB = DateTime.parse(b.appliedOn!);
            return dateB.compareTo(dateA); // Descending order
          } catch (e) {
            // If date parsing fails, fall back to string comparison
            return b.appliedOn!.compareTo(a.appliedOn!);
          }
        });
        
        myLeavesHistory.addAll(sortedData);
        print("Debug - Loaded ${myLeavesHistory.length} leaves successfully (sorted by newest first)");
      } else {
        myLeavesHistory.clear();
        print("Debug - No leaves found");
      }

    } catch (e) {
      print("Error in getMyLeaves: $e");
      Get.snackbar('Error', 'Failed to load leave history');
      myLeavesHistory.clear();
    } finally {
      isLoading.value = false;
    }
  }

  leaveRequest(Map map) async {
    Loader.showLoader();

    var response = await NetworkHttps.postRequest(API.leaveRequest, map);
    if (response["status"] == 1) {
      Loader.hideLoader();

      commonToast(response["message"]);
      
      // Refresh the leave history data first
      await getMyLeaves();
      
      // Navigate to leave history page using the same controller instance
      Get.offAll(() => const LeaveHistory());
    } else {
      Loader.hideLoader();
      commonToast(response["message"]);
    }
  }

  getLeaveTypes() async {
    try {
      var response = await NetworkHttps.postRequest(API.getLeavesTypes,
          {"workspace_id": Prefs.getString(AppConstant.workSpaceId)});

      if ((response["status"] == 1 || response["status"] == 200)) {
        leaveTypeResponse = LeaveTypesResponse.fromJson(response);
        leaveTypes.clear();

        for (var leaveType in leaveTypeResponse!.data!) {
          if (leaveType.isDisable == 0) {
            leaveTypes.add(leaveType);
          }
        }

        if (leaveTypes.isNotEmpty) {
          leaveType.value = leaveTypes.first.title.toString();
          leaveId.value = leaveTypes.first.id.toString();
          leaveTypes.refresh();
        }
      } else {
        commonToast(response["message"] ?? "Failed to load leave types");
      }
    } catch (e) {
      commonToast("Error loading leave types: $e");
    }
  }
}
