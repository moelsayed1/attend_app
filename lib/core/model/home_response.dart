class HomeResponse {
  int? status;
  String? message;
  Data? data;

  HomeResponse({this.status, this.message, this.data});

  HomeResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? isClockin;
  int? attendanceId;
  String? clockIn;
  String? clockOut;
  String? totalHours;


  List<Announcements>? announcements;

  Data({this.isClockin, this.announcements,this.clockIn,this.clockOut,this.totalHours,this.attendanceId});

  Data.fromJson(Map<String, dynamic> json) {
    isClockin = json['is_clockin'];
    attendanceId = json['attendance_id'];
    clockIn=json['clock_in'];
    clockOut=json['clock_out'];
    totalHours=json['total_hours'];
    if (json['announcements'] != null) {
      announcements = <Announcements>[];
      json['announcements'].forEach((v) {
        announcements!.add(Announcements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_clockin'] = isClockin;
    data['clock_in'] = clockIn;
    data['clock_out'] = clockOut;
    data['total_hours'] = totalHours;
    data['attendance_id'] = attendanceId;
    if (announcements != null) {
      data['announcements'] =
          announcements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Announcements {
  int? id;
  String? title;
  String? startDate;
  String? endDate;
  String? description;
  int? workspace;
  int? createdBy;

  Announcements(
      {this.id,
        this.title,
        this.startDate,
        this.endDate,
        this.description,
        this.workspace,
        this.createdBy});

  Announcements.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    description = json['description'];
    workspace = json['workspace'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['description'] = description;
    data['workspace'] = workspace;
    data['created_by'] = createdBy;
    return data;
  }
}