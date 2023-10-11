/*class CampTrendingListModel {
  String? status;
  String? message;
  List<TrendingData>? data;

  CampTrendingListModel({this.status, this.message, this.data});

  CampTrendingListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <TrendingData>[];
      json['data'].forEach((v) {
        data!.add(new TrendingData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TrendingData {
  String? campaignName;
  String? brandName;
  String? campaignObj;
  String? earnUpto;
  String? revuerLimit;//change
  String? joinRevuer;//change
  String? image;
  String? currencyType;
  String? socialIcon;
  String? campaignToken;
  String? brandloginUniqueToken;
  int? approveStatus;

  TrendingData(
      {this.campaignName,
        this.brandName,
        this.campaignObj,
        this.earnUpto,
        this.revuerLimit,
        this.joinRevuer,
        this.image,
        this.currencyType,
        this.socialIcon,
        this.campaignToken,
        this.brandloginUniqueToken,
      this.approveStatus});

  TrendingData.fromJson(Map<String, dynamic> json) {
    campaignName = json['campaign_name'];
    brandName = json['brand_name'];//change
    campaignObj = json['campaign_obj'];
    earnUpto = json['earn_upto'];
    revuerLimit = json['revuerLimit'];//change
    joinRevuer = json['joinRevuer'];//change
    image = json['image'];
    currencyType = json['currency_type'];
    socialIcon = json['social_icon'];
    campaignToken = json['campaign_token'];
    brandloginUniqueToken = json['brandlogin_unique_token'];
    approveStatus = json['approve_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['campaign_name'] = this.campaignName;
    data['brand_name'] = this.brandName;
    data['campaign_obj'] = this.campaignObj;
    data['earn_upto'] = this.earnUpto;
    data['revuerLimit'] = this.revuerLimit;
    data['joinRevuer'] = this.joinRevuer;
    data['image'] = this.image;
    data['currency_type'] = this.currencyType;
    data['social_icon'] = this.socialIcon;
    data['campaign_token'] = this.campaignToken;
    data['brandlogin_unique_token'] = this.brandloginUniqueToken;
    data['approve_status'] = this.approveStatus;
    return data;
  }
}*/

class CampTrendingListModel {
  String? status;
  String? message;
  Data? data;

  CampTrendingListModel({this.status, this.message, this.data});

  CampTrendingListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<CampaignData>? campaignData;
 // List<AdvertisementData>? advertisementData;
  int? newAdValue;

  Data({this.campaignData,this.newAdValue});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['campaign_data'] != null) {
      campaignData = <CampaignData>[];
      json['campaign_data'].forEach((v) {
        campaignData!.add(CampaignData.fromJson(v));
      });
    }
    newAdValue = json['new_adv_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.campaignData != null) {
      data['campaign_data'] =
          this.campaignData!.map((v) => v.toJson()).toList();
    }
    data['new_adv_value'] = this.newAdValue;
    return data;
  }
}

class CampaignData {
  String? brandName;
  dynamic revuerLimit;
  String? campaignName;
  String? campaignObj;
  String? earnUpto;
  String? joinRevuer;
  String? image;
  String? campaignToken;
  String? brandloginUniqueToken;
  int? campaignMainStatus;
  String? socialIcon;
  int? approveStatus;
  int? listDisplayType;
  String? title;
  String? content;
  String? videoName;
  String? thumbnailImage;
  String? iconImage;
  String? advertisementToken;
  String? link;
  int? status;
  int? mainType;

  CampaignData(
      {this.brandName,
        this.revuerLimit,
        this.campaignName,
        this.campaignObj,
        this.earnUpto,
        this.joinRevuer,
        this.image,
        this.campaignToken,
        this.brandloginUniqueToken,
        this.campaignMainStatus,
        this.socialIcon,
        this.approveStatus,
        this.listDisplayType,
        this.title,
        this.content,
        this.videoName,
        this.thumbnailImage,
        this.iconImage,
        this.advertisementToken,
        this.link,
        this.status,
        this.mainType});

  CampaignData.fromJson(Map<String, dynamic> json) {
    brandName = json['brand_name'];
    revuerLimit = json['revuerLimit'];
    campaignName = json['campaign_name'];
    campaignObj = json['campaign_obj'];
    earnUpto = json['earn_upto'];
    joinRevuer = json['joinRevuer'];
    image = json['image'];
    campaignToken = json['campaign_token'];
    brandloginUniqueToken = json['brandlogin_unique_token'];
    campaignMainStatus = json['campaign_main_status'];
    socialIcon = json['social_icon'];
    approveStatus = json['approve_status'];
    listDisplayType = json['list_display_type'];
    title = json['title'];
    content = json['content'];
    videoName = json['video_name'];
    thumbnailImage = json['thumbnail_image'];
    iconImage = json['icon_image'];
    advertisementToken = json['advertisement_token'];
    link = json['link'];
    status = json['status'];
    mainType = json['main_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['brand_name'] = this.brandName;
    data['revuerLimit'] = this.revuerLimit;
    data['campaign_name'] = this.campaignName;
    data['campaign_obj'] = this.campaignObj;
    data['earn_upto'] = this.earnUpto;
    data['joinRevuer'] = this.joinRevuer;
    data['image'] = this.image;
    data['campaign_token'] = this.campaignToken;
    data['brandlogin_unique_token'] = this.brandloginUniqueToken;
    data['campaign_main_status'] = this.campaignMainStatus;
    data['social_icon'] = this.socialIcon;
    data['approve_status'] = this.approveStatus;
    data['list_display_type'] = this.listDisplayType;
    data['title'] = this.title;
    data['content'] = this.content;
    data['video_name'] = this.videoName;
    data['thumbnail_image'] = this.thumbnailImage;
    data['icon_image'] = this.iconImage;
    data['advertisement_token'] = this.advertisementToken;
    data['link'] = this.link;
    data['status'] = this.status;
    data['main_type'] = this.mainType;
    return data;
  }
}

/*class AdvertisementData {
  int? type;
  String? name;
  String? coverImage;
  String? content;

  AdvertisementData({this.type, this.name, this.coverImage, this.content});

  AdvertisementData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    name = json['name'];
    coverImage = json['cover_image'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['name'] = this.name;
    data['cover_image'] = this.coverImage;
    data['content'] = this.content;
    return data;
  }
}*/

/*class CampaignData {
  String? brandName;
  String? revuerLimit;
  String? campaignName;
  String? campaignObj;
  String? earnUpto;
  String? joinRevuer;
  String? image;
  String? campaignToken;
  String? brandloginUniqueToken;
  int? campaignMainStatus;
  String? socialIcon;
  int? approveStatus;
  int? listDisplayType;
  String? title;
  String? content;
  String? videoName;
  String? thumbnailImage;
  String? iconImage;
  String? link;
  int? status;
  int? mainType;

  CampaignData(
      {this.brandName,
        this.revuerLimit,
        this.campaignName,
        this.campaignObj,
        this.earnUpto,
        this.joinRevuer,
        this.image,
        this.campaignToken,
        this.brandloginUniqueToken,
        this.campaignMainStatus,
        this.socialIcon,
        this.approveStatus,
        this.listDisplayType,
        this.title,
        this.content,
        this.videoName,
        this.thumbnailImage,
        this.iconImage,
        this.link,
        this.status,
        this.mainType});

  CampaignData.fromJson(Map<String, dynamic> json) {
    brandName = json['brand_name'];
    revuerLimit = json['revuerLimit'];
    campaignName = json['campaign_name'];
    campaignObj = json['campaign_obj'];
    earnUpto = json['earn_upto'];
    joinRevuer = json['joinRevuer'];
    image = json['image'];
    campaignToken = json['campaign_token'];
    brandloginUniqueToken = json['brandlogin_unique_token'];
    campaignMainStatus = json['campaign_main_status'];
    socialIcon = json['social_icon'];
    approveStatus = json['approve_status'];
    listDisplayType = json['list_display_type'];
    title = json['title'];
    content = json['content'];
    videoName = json['video_name'];
    thumbnailImage = json['thumbnail_image'];
    iconImage = json['icon_image'];
    link = json['link'];
    status = json['status'];
    mainType = json['main_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['brand_name'] = this.brandName;
    data['revuerLimit'] = this.revuerLimit;
    data['campaign_name'] = this.campaignName;
    data['campaign_obj'] = this.campaignObj;
    data['earn_upto'] = this.earnUpto;
    data['joinRevuer'] = this.joinRevuer;
    data['image'] = this.image;
    data['campaign_token'] = this.campaignToken;
    data['brandlogin_unique_token'] = this.brandloginUniqueToken;
    data['campaign_main_status'] = this.campaignMainStatus;
    data['social_icon'] = this.socialIcon;
    data['approve_status'] = this.approveStatus;
    data['list_display_type'] = this.listDisplayType;
    data['title'] = this.title;
    data['content'] = this.content;
    data['video_name'] = this.videoName;
    data['thumbnail_image'] = this.thumbnailImage;
    data['icon_image'] = this.iconImage;
    data['link'] = this.link;
    data['status'] = this.status;
    data['main_type'] = this.mainType;
    return data;
  }*/


