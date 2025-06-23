class LoginResponse {
  int? status;
  String? message;
  LoginData? data;

  LoginResponse({
    this.status,
    this.message,
    this.data,
  });

  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? LoginData.fromJson(json['data']) : null;
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

class LoginData {
  String? token;
  User? user;
  String? password;
  List<Workspace>? workspaces;
  String? loginTime;

  LoginData({
    this.token,
    this.user,
    this.password,
    this.workspaces,
    this.loginTime,
  });

  LoginData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    password = json['password'];
    loginTime = json['login_time'];
    if (json['workspaces'] != null) {
      workspaces = <Workspace>[];
      json['workspaces'].forEach((v) {
        workspaces!.add(Workspace.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['password'] = password;
    data['login_time'] = loginTime;
    if (workspaces != null) {
      data['workspaces'] = workspaces!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? mobileNo;
  String? type;
  int? activeWorkspace;
  String? avatar;
  String? lang;

  User({
    this.id,
    this.name,
    this.email,
    this.mobileNo,
    this.type,
    this.activeWorkspace,
    this.avatar,
    this.lang,
  });

  User.fromJson(Map<String, dynamic> json) {
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

class Workspace {
  int? id;
  String? name;
  String? slug;
  String? status;
  int? createdBy;

  Workspace({
    this.id,
    this.name,
    this.slug,
    this.status,
    this.createdBy,
  });

  Workspace.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    status = json['status'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['status'] = status;
    data['created_by'] = createdBy;
    return data;
  }
} 