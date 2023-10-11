class ReferContentModel {
  List<ReferList>? referList;
  ReferData? referData;

  ReferContentModel({this.referList, this.referData});

  ReferContentModel.fromJson(Map<String, dynamic> json) {
    if (json['referList'] != null) {
      referList = <ReferList>[];
      json['referList'].forEach((v) {
        referList!.add(ReferList.fromJson(v));
      });
    }
    referData = json['referData'] != null
        ? ReferData.fromJson(json['referData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (referList != null) {
      data['referList'] = referList!.map((v) => v.toJson()).toList();
    }
    if (referData != null) {
      data['referData'] = referData!.toJson();
    }
    return data;
  }
}

class ReferList {
  String? firstName;
  String? revuerImage;
  String? lastName;
  String? createdAt;

  ReferList({this.firstName, this.revuerImage, this.lastName, this.createdAt});

  ReferList.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    revuerImage = json['revuer_image'];
    lastName = json['last_name'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['revuer_image'] = revuerImage;
    data['last_name'] = lastName;
    data['createdAt'] = createdAt;
    return data;
  }
}

class ReferData {
  String? referContent;
  String? image;
  String? referMessage;
  String? referCode;

  ReferData({this.referContent, this.image, this.referMessage, this.referCode});

  ReferData.fromJson(Map<String, dynamic> json) {
    referContent = json['refer_content'];
    image = json['image'];
    referMessage = json['refer_message'];
    referCode = json['refer_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refer_content'] = referContent;
    data['image'] = image;
    data['refer_message'] = referMessage;
    data['refer_code'] = referCode;
    return data;
  }
}
