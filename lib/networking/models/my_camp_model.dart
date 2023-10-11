class MyCampListModel {
  String? status;
  String? message;
  List<MyCampaignModel>? data;

  MyCampListModel({this.status, this.message, this.data});

  MyCampListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MyCampaignModel>[];
      json['data'].forEach((v) {
        data!.add(MyCampaignModel.fromJson(v));
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

class MyCampaignModel {
  String? brandName;
  String? campaignName;
  String? campaignObj;
  String? earnUpto;
  String? image;
  String? campTypeId;
  String? campaignToken;
  String? brandloginUniqueToken;
  String? revuerCampaignStatus;

  MyCampaignModel(
      {this.brandName,
        this.campaignName,
        this.campaignObj,
        this.earnUpto,
        this.image,
        this.campTypeId,
        this.campaignToken,
        this.brandloginUniqueToken,
      this.revuerCampaignStatus});

  MyCampaignModel.fromJson(Map<String, dynamic> json) {
    brandName = json['brand_name'];
    campaignName = json['campaign_name'];
    campaignObj = json['campaign_obj'];
    earnUpto = json['earn_upto'];
    image = json['image'];
    campTypeId = json['camp_type_id'];
    campaignToken = json['campaign_token'];
    brandloginUniqueToken = json['brandlogin_unique_token'];
    revuerCampaignStatus = json['revuer_campaign_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['brand_name'] = this.brandName;
    data['campaign_name'] = this.campaignName;
    data['campaign_obj'] = this.campaignObj;
    data['earn_upto'] = this.earnUpto;
    data['image'] = this.image;
    data['camp_type_id'] = this.campTypeId;
    data['campaign_token'] = this.campaignToken;
    data['brandlogin_unique_token'] = this.brandloginUniqueToken;
    data['revuer_campaign_status'] = this.revuerCampaignStatus;
    return data;
  }
}

