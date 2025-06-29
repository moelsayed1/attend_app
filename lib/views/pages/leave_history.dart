import 'package:attendance/core/controller/leave_request_controller.dart';
import 'package:attendance/core/model/leave_history_response.dart';
import 'package:attendance/core/model/leave_types_response.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/helper.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/pages/leave_request.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaveHistory extends StatefulWidget {
  const LeaveHistory({super.key});

  @override
  State<LeaveHistory> createState() => _LeaveHistoryState();
}

class _LeaveHistoryState extends State<LeaveHistory> {
  late final LeaveRequestController leavesController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller with proper error handling
    try {
      leavesController = Get.find<LeaveRequestController>();
    } catch (e) {
      leavesController = Get.put(LeaveRequestController());
    }
    
    // Load data only once when the page is first visited
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!_isInitialized) {
        _isInitialized = true;
        leavesController.getMyLeaves();
        leavesController.getLeaveTypes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGround,
      appBar: AppBar(
        backgroundColor: AppColor.cWhite,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "My Leaves",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.cBlack),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryColor,
        onPressed: () {
          Get.to(() => LeaveRequestScreen());
        },
        child: Icon(
          Icons.add,
          color: AppColor.cWhite,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await leavesController.getMyLeaves();
          },
          child: Stack(
            children: [
              Obx(() {
                return leavesController.myLeavesHistory.isEmpty && !leavesController.isLoading.value
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: AppColor.primaryColor.withOpacity(0.7),
                          ),
                          verticalSpace(16),
                          Text(
                            "No Leave History Found",
                            style: pMedium16.copyWith(
                                color: AppColor.cBlack,
                                fontWeight: FontWeight.w500),
                          ),
                          verticalSpace(8),
                          Text(
                            "You haven't applied for any leaves yet",
                            style: pRegular14.copyWith(color: AppColor.cLabel),
                          ),
                        ],
                      ))
                    : ListView.builder(
                        itemBuilder: (context, index) {
                          final LeaveData leaveData =
                              leavesController.myLeavesHistory[index];

                          return GestureDetector(
                            onTap: () {
                              // Open leave request screen with pre-filled data
                              Get.to(() => LeaveRequestScreen(), arguments: {
                                'reason': leaveData.leaveReason,
                                'startDate': leaveData.startDate,
                                'endDate': leaveData.endDate,
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                height: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColor.cWhite),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leaveData.leaveReason.toString(),
                                            style: pRegular16.copyWith(
                                                color: AppColor.cLabel),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                          verticalSpace(5),
                                          Text(
                                              "${formattedDate(leaveData.startDate ?? "")} - ${formattedDate(leaveData.endDate ?? "")}",
                                              style: pMedium14.copyWith(
                                                  color: AppColor.cLabel)),
                                          verticalSpace(5),
                                          Text(
                                            "Leave Type: ${leaveData.leaveTypeName ?? "Unknown"}",
                                            style: pMedium14.copyWith(
                                                color: AppColor.cLabel),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 12),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: getStatus(leaveData.status ?? "")),
                                      child: Text(
                                        leaveData.status ?? "",
                                        style: pMedium14.copyWith(
                                            color: AppColor.cWhite),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: leavesController.myLeavesHistory.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16));
              }),
              // Loading overlay
              Obx(() {
                return leavesController.isLoading.value
                    ? Container(
                        color: Colors.transparent.withOpacity(0.3),
                        child: const Center(),
                      )
                    : const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  String formattedDate(String leaveDate) {
    return dateFormatted(
        date: leaveDate, formatType: formatForDateTime(FormatType.ddMMyyyy));
  }

  String getLeaveTypeName(int? leaveTypeId) {
    if (leaveTypeId == null) return "";
    
    try {
      final leaveType = leavesController.leaveTypes.firstWhere(
        (type) => type.id == leaveTypeId,
        orElse: () => LeaveType(id: 0, title: "Unknown", isDisable: 0),
      );
      return leaveType.title ?? "Unknown";
    } catch (e) {
      return "Unknown";
    }
  }

  Color getStatus(String status) {
    if (status == "Pending") {
      return AppColor.pending;
    } else if (status == "Reject" || status == "Rejected") {
      return AppColor.reject;
    } else if (status == "Approved") {
      return AppColor.approved;
    } else {
      return AppColor.approved;
    }
  }
}
