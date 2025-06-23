class EventResponse {
  int? status;
  String? message;
  List<EventData>? data;

  EventResponse({this.status, this.data});

  EventResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <EventData>[];
      json['data'].forEach((v) {
        data!.add(EventData.fromJson(v));
      });
    }
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

class EventData {
  int? id;
  String? title;
  String? startDate;
  String? endDate;
  String? color;
  String? description;

  EventData(
      {this.id,
        this.title,
        this.startDate,
        this.endDate,
        this.color,
        this.description});

  EventData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    color = json['color'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['color'] = color;
    data['description'] = description;
    return data;
  }
}
