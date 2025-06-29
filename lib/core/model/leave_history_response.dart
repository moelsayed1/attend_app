class MyLeavesResponse {
  int? status;
  String? message;
  List<LeaveData>? data;

  MyLeavesResponse({this.status, this.message, this.data});

  MyLeavesResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <LeaveData>[];
      json['data'].forEach((v) {
        data!.add(LeaveData.fromJson(v));
      });
    }
  }

  // Constructor for API response that only has data array
  MyLeavesResponse.fromDataArray(List<dynamic> dataArray) {
    status = 1; // Default success status
    message = "Success";
    data = <LeaveData>[];
    dataArray.forEach((v) {
      data!.add(LeaveData.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LeaveData {
  int? id;
  int? employeeId;
  int? userId;
  int? leaveTypeId;
  String? leaveTypeName;
  String? appliedOn;
  String? startDate;
  String? endDate;
  String? totalLeaveDays;
  String? leaveReason;
  String? remark;
  String? status;
  int? workspace;
  int? createdBy;

  LeaveData(
      {this.id,
        this.employeeId,
        this.userId,
        this.leaveTypeId,
        this.leaveTypeName,
        this.appliedOn,
        this.startDate,
        this.endDate,
        this.totalLeaveDays,
        this.leaveReason,
        this.remark,
        this.status,
        this.workspace,
        this.createdBy});

  LeaveData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employee_id'];
    userId = json['user_id'];
    leaveTypeId = json['leave_type_id'];
    leaveTypeName = json['leave_type_name'];
    appliedOn = json['applied_on'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    totalLeaveDays = json['total_leave_days'];
    leaveReason = json['leave_reason'];
    remark = json['remark'];
    status = json['status'];
    workspace = json['workspace'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_id'] = employeeId;
    data['user_id'] = userId;
    data['leave_type_id'] = leaveTypeId;
    data['leave_type_name'] = leaveTypeName;
    data['applied_on'] = appliedOn;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['total_leave_days'] = totalLeaveDays;
    data['leave_reason'] = leaveReason;
    data['remark'] = remark;
    data['status'] = status;
    data['workspace'] = workspace;
    data['created_by'] = createdBy;
    return data;
  }
}