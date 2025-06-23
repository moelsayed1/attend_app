class EditProfileResponse {
  int? status;
  String? message;
  Data? data;

  EditProfileResponse({this.status, this.message, this.data});

  EditProfileResponse.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? name;
  String? email;
  String? mobileNo;
  String? type;
  int? activeWorkspace;
  String? avatar;
  String? lang;

  Data(
      {this.id,
        this.name,
        this.email,
        this.mobileNo,
        this.type,
        this.activeWorkspace,
        this.avatar,
        this.lang});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    type = json['type'];
    activeWorkspace = json['active_workspace'];
    avatar = json['avatar'];
    lang = json['lang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['mobile_no'] = mobileNo;
    data['type'] = type;
    data['active_workspace'] = activeWorkspace;
    data['avatar'] = avatar;
    data['lang'] = lang;
    return data;
  }
}