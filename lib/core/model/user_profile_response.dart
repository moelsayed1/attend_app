class UserProfileResponse {
  final UserData? data;
  final int status;
  final String message;

  UserProfileResponse({
    this.data,
    required this.status,
    required this.message,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'status': status,
      'message': message,
    };
  }
}

class UserData {
  final int id;
  final String name;
  final String email;
  final String mobileNo;
  final String type;
  final int activeWorkspace;
  final String avatar;
  final String lang;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.type,
    required this.activeWorkspace,
    required this.avatar,
    required this.lang,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      type: json['type'] ?? '',
      activeWorkspace: json['active_workspace'] ?? 0,
      avatar: json['avatar'] ?? '',
      lang: json['lang'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile_no': mobileNo,
      'type': type,
      'active_workspace': activeWorkspace,
      'avatar': avatar,
      'lang': lang,
    };
  }
} 