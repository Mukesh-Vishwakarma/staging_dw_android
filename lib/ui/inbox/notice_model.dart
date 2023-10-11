class NotificationModel {
  List<NotificationList>? notificationList;

  NotificationModel({this.notificationList});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    if (json['notification_list'] != null) {
      notificationList = <NotificationList>[];
      json['notification_list'].forEach((v) {
        notificationList!.add(NotificationList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notificationList != null) {
      data['notification_list'] =
          notificationList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationList {
  String? type;
  String? campaignToken;
  String? brandToken;
  String? taskToken;
  String? revuerToken;
  String? message;
  String? requestType;
  String? insertDate;
  String? revuerImage;
  String? campaignImage;
  String? campaignName;
  String? revuerName;

  NotificationList(
      {this.type,
        this.campaignToken,
        this.brandToken,
        this.taskToken,
        this.revuerToken,
        this.message,
        this.requestType,
        this.insertDate,
        this.revuerImage,
        this.campaignImage,
        this.campaignName,
      this.revuerName});

  NotificationList.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    campaignToken = json['campaign_token'];
    brandToken = json['brand_token'];
    taskToken = json['task_token'];
    revuerToken = json['revuer_token'];
    message = json['message'];
    requestType = json['request_type'];
    insertDate = json['insert_date'];
    revuerImage = json['revuer_image'];
    campaignImage = json['campaign_image'];
    campaignName = json['campaign_name'];
    revuerName = json['revuer_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['campaign_token'] = campaignToken;
    data['brand_token'] = brandToken;
    data['task_token'] = taskToken;
    data['revuer_token'] = revuerToken;
    data['message'] = message;
    data['request_type'] = requestType;
    data['insert_date'] = insertDate;
    data['revuer_image'] = revuerImage;
    data['campaign_image'] = campaignImage;
    data['campaign_name'] = campaignName;
    data['revuer_name'] = revuerName;
    return data;
  }
}
