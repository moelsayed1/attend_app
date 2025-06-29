import 'dart:convert';
import 'package:attendance/core/model/leave_history_response.dart';
import 'package:attendance/core/model/leave_types_response.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/views/widgets/loading_widget.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/prefer.dart';
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

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true; // Set loading to true at the start of init

    getLeaveTypes();
    getMyLeaves();
  }

  void _loadStaticLeaveTypes() {
    leaveTypes.clear();
    leaveTypes.addAll([
      LeaveType(id: 1, title: "Annual Leave", isDisable: 0),
      LeaveType(id: 2, title: "Sick Leave", isDisable: 0),
      LeaveType(id: 3, title: "Casual Leave", isDisable: 0),
      LeaveType(id: 4, title: "Maternity Leave", isDisable: 0),
      LeaveType(id: 5, title: "Paternity Leave", isDisable: 0),
    ]);
    if (leaveTypes.isNotEmpty) {
      leaveType.value = leaveTypes.first.title.toString();
      leaveId.value = leaveTypes.first.id.toString();
    }
  }

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

  getMyLeaves() async {
    var response = await NetworkHttps.postRequest(API.getLeaves,
        {"workspace_id": Prefs.getString(AppConstant.workSpaceId)});

    if (response["status"] == 1) {
      myLeavesResponse = MyLeavesResponse.fromJson(response);

      myLeavesHistory.addAll(myLeavesResponse!.data!);
      myLeavesHistory.refresh();
    } else {
      commonToast(response["message"]);
    }
    // If using static data, ensure isLoading is set to false after loading.
  }

  leaveRequest(Map map) async {
    Loader.showLoader();

    var response = await NetworkHttps.postRequest(API.leaveRequest, map);
    if (response["status"] == 1) {
      Loader.hideLoader();

      commonToast(response["message"]);
      Get.back(result: true);
    } else {
      Loader.hideLoader();
      commonToast(response["message"]);
    }
  }

  getLeaveTypes() async {
    isLoading.value = true;
    try {
      // var response = await NetworkHttps.postRequest(API.getLeavesTypes,
      //     {"workspace_id": Prefs.getString(AppConstant.workSpaceId)});

      var response1 = await rootBundle.loadString('asset/dummyLeaveTypes.json');
      var response = jsonDecode(response1);

      if (response != null &&
          (response["status"] == 1 || response["status"] == 200)) {
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
        commonToast(response?["message"] ?? "Failed to load leave types");
      }
    } catch (e) {
      commonToast("Error loading leave types: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
