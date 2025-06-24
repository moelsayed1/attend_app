import 'package:attendance/core/model/leave_history_response.dart';
import 'package:attendance/core/model/leave_types_response.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/views/widgets/loading_widget.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveRequestController extends GetxController {
  RxList<LeaveData> myLeavesHistory = <LeaveData>[].obs;
  RxList<LeaveType> leaveTypes = <LeaveType>[].obs;
  MyLeavesResponse? myLeavesResponse;
  LeaveTypesResponse? leaveTypeResponse;
  RxBool isLoading=false.obs;

  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;

  bool _isUsingStaticData = false; // Set to false to enable real API calls
  RxString leaveType=''.obs;
  RxString leaveId=''.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true; // Set loading to true at the start of init
    if (_isUsingStaticData) {
      _loadStaticLeaveTypes();
      _loadStaticLeaveHistory();
      isLoading.value = false; // Set loading to false after static data is loaded
    } else {
      getLeaveTypes();
      getMyLeaves();
    }
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

  void _loadStaticLeaveHistory() {
    myLeavesHistory.clear();
    myLeavesHistory.addAll([
      LeaveData(
        leaveReason: "Attending a family event or celebration",
        startDate: "19/03/2024",
        endDate: "22/03/2024",
        status: "Pending",
      ),
      LeaveData(
        leaveReason: "I want to celebrate the EID festival with my family",
        startDate: "10/04/2024",
        endDate: "13/04/2024",
        status: "Pending",
      ),
      LeaveData(
        leaveReason: "Attending to a sick family member's needs",
        startDate: "22/05/2024",
        endDate: "24/05/2024",
        status: "Pending",
      ),
      LeaveData(
        leaveReason: "Taking a leave to attend a cricket match event.",
        startDate: "22/03/2024",
        endDate: "23/03/2024",
        status: "Pending",
      ),
      LeaveData(
        leaveReason: "Attending a religious or cultural ceremony.",
        startDate: "30/12/2023",
        endDate: "30/12/2023",
        status: "Rejected",
      ),
      LeaveData(
        leaveReason: "Rest and relaxation to recharge both physically and mentally",
        startDate: "15/12/2023",
        endDate: "20/12/2023",
        status: "Approved",
      ),
    ]);
    myLeavesHistory.refresh();
    print("Initial myLeavesHistory count: ${myLeavesHistory.length}");
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
      endDate.value=picked;
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


  String getFormattedDate(DateTime now)  {
    final formatter = DateFormat('dd/MM/yyyy');
    final formattedDate = formatter.format(now);
    return formattedDate;
  }

  String getParameterFormattedDate(DateTime now)  {
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
    if (_isUsingStaticData) {
      isLoading.value = false; // Keep this to dismiss loading indicator if getMyLeaves is explicitly called
    }
  }

  leaveRequest(Map map) async {
    Loader.showLoader();
    if (_isUsingStaticData) {
      // Simulate API success
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      Loader.hideLoader();
      commonToast("Leave request applied successfully (Static)");
      print("myLeavesHistory count before add: ${myLeavesHistory.length}");
      // Add the new request to static data
      myLeavesHistory.add(LeaveData(
        leaveReason: map["leave_reason"],
        startDate: getFormattedDate(startDate.value),
        endDate: getFormattedDate(endDate.value),
        status: "Pending", // Default status for new static requests
      ));
      print("myLeavesHistory count after add: ${myLeavesHistory.length}");
      myLeavesHistory.refresh();
      Get.back(result: true);
    } else {
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
  }

  getLeaveTypes() async {
    isLoading.value=true;
    if (_isUsingStaticData) {
      _loadStaticLeaveTypes();
      isLoading.value = false; // Ensure isLoading is false after loading static types
    } else {
      var response = await NetworkHttps.postRequest(API.getLeavesTypes,
          {"workspace_id": Prefs.getString(AppConstant.workSpaceId)});
      if (response != null && (response["status"] == 1 || response["status"] == 200)) {
        isLoading.value=false;

        leaveTypeResponse=LeaveTypesResponse.fromJson(response);

        for(var  i in leaveTypeResponse!.data!)
          {
            if(i.isDisable==0)
              {
                leaveTypes.add(i);
              }
          }
        // leaveTypes.addAll(leaveTypeResponse!.data!);
        leaveType.value=leaveTypes.first.title.toString();
        leaveId.value=leaveTypes.first.id.toString();
        leaveTypes.refresh();
        print("Leave types loaded: "+leaveTypes.length.toString());
      } else if (response != null) {
        isLoading.value=false;
        commonToast(response["message"]);
      }
    }
  }
}
