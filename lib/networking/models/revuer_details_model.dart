/*
class RevuerDetailsModel {
  String? sId;
  int? mobileNo;
  String? firstName;
  String? lastName;
  String? revuerToken;
  String? image;
  int? revuerApproveStatus;
  bool? profileSetupStatus;
  bool? socialStatus;
  int? rank;

  RevuerDetailsModel(
      {this.sId,
      this.mobileNo,
      this.firstName,
      this.lastName,
      this.revuerToken,
      this.image,
      this.revuerApproveStatus,
      this.profileSetupStatus,
      this.socialStatus,
      this.rank});

  RevuerDetailsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mobileNo = json['mobile_no'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    revuerToken = json['revuer_token'];
    image = json['image'];
    revuerApproveStatus = json['revuer_approve_status'];
    profileSetupStatus = json['profile_setup_status'];
    socialStatus = json['social_status'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['mobile_no'] = this.mobileNo;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['revuer_token'] = this.revuerToken;
    data['image'] = this.image;
    data['revuer_approve_status'] = this.revuerApproveStatus;
    data['profile_setup_status'] = this.profileSetupStatus;
    data['social_status'] = this.socialStatus;
    data['rank'] = this.rank;
    return data;
  }
}
*/

class RevuerDetailsModel {
  Android? android;
  IOS? iOS;
  Maintenance? maintenance;
  RevuerData? revuerData;

  RevuerDetailsModel(
      {this.android, this.iOS, this.maintenance, this.revuerData});

  RevuerDetailsModel.fromJson(Map<String, dynamic> json) {
    android =
    json['android'] != null ? new Android.fromJson(json['android']) : null;
    iOS = json['IOS'] != null ? new IOS.fromJson(json['IOS']) : null;
    maintenance = json['maintenance'] != null
        ? new Maintenance.fromJson(json['maintenance'])
        : null;
    revuerData = json['revuerData'] != null
        ? new RevuerData.fromJson(json['revuerData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.android != null) {
      data['android'] = this.android!.toJson();
    }
    if (this.iOS != null) {
      data['IOS'] = this.iOS!.toJson();
    }
    if (this.maintenance != null) {
      data['maintenance'] = this.maintenance!.toJson();
    }
    if (this.revuerData != null) {
      data['revuerData'] = this.revuerData!.toJson();
    }
    return data;
  }
}

class Android {
  String? minimumVersion;
  String? currentVersion;
  String? message;
  String? link;

  Android({this.minimumVersion, this.currentVersion, this.message,this.link});

  Android.fromJson(Map<String, dynamic> json) {
    minimumVersion = json['minimum_version'];
    currentVersion = json['current_version'];
    message = json['message'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['minimum_version'] = this.minimumVersion;
    data['current_version'] = this.currentVersion;
    data['message'] = this.message;
    data['link'] = this.link;
    return data;
  }
}

class IOS {
  String? iosMinimumVersion;
  String? iosCurrentVersion;
  String? iosMessage;
  String? ios_link;

  IOS({this.iosMinimumVersion, this.iosCurrentVersion, this.iosMessage,this.ios_link});

  IOS.fromJson(Map<String, dynamic> json) {
    iosMinimumVersion = json['ios_minimum_version'];
    iosCurrentVersion = json['ios_current_version'];
    iosMessage = json['ios_message'];
    ios_link = json['ios_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ios_minimum_version'] = this.iosMinimumVersion;
    data['ios_current_version'] = this.iosCurrentVersion;
    data['ios_message'] = this.iosMessage;
    data['ios_link'] = this.ios_link;
    return data;
  }
}

class Maintenance {
  String? maintenanceMessage;
  int? status;
  int? messageStatus;

  Maintenance({this.maintenanceMessage, this.status,this.messageStatus});

  Maintenance.fromJson(Map<String, dynamic> json) {
    maintenanceMessage = json['maintenance_message'];
    status = json['status'];
    messageStatus = json['message_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['maintenance_message'] = this.maintenanceMessage;
    data['status'] = this.status;
    data['message_status'] = this.messageStatus;
    return data;
  }
}

class RevuerData {
  String? sId;
  int? mobileNo;
  String? firstName;
  String? lastName;
  String? instagramUrl;
  bool? profileSetupStatus;
  int? revuerApproveStatus;
  String? revuerToken;
  String? image;
  String? refer_length;
  bool? socialStatus;
  int? rank;

  RevuerData(
      {this.sId,
        this.mobileNo,
        this.firstName,
        this.lastName,
        this.instagramUrl,
        this.profileSetupStatus,
        this.revuerApproveStatus,
        this.revuerToken,
        this.image,
        this.refer_length,
        this.socialStatus,
        this.rank});

  RevuerData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mobileNo = json['mobile_no'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    instagramUrl = json['instagram_url'];
    profileSetupStatus = json['profile_setup_status'];
    revuerApproveStatus = json['revuer_approve_status'];
    revuerToken = json['revuer_token'];
    image = json['image'];
    refer_length = json['refer_length'];
    socialStatus = json['social_status'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['mobile_no'] = this.mobileNo;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['instagram_url'] = this.instagramUrl;
    data['profile_setup_status'] = this.profileSetupStatus;
    data['revuer_approve_status'] = this.revuerApproveStatus;
    data['revuer_token'] = this.revuerToken;
    data['image'] = this.image;
    data['refer_length'] = this.refer_length;
    data['social_status'] = this.socialStatus;
    data['rank'] = this.rank;
    return data;
  }
}
