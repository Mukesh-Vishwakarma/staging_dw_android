class MyCampaignDetailsModel {
  String? sId;
  String? name;
  String? categoryName;
  String? campaignName;
  String? campaignObj;
  List<String>? dos;
  List<String>? donts;
  String? campTypeId;
  List<String>? campTaskNameId;
  List<String>? campaignTaskNames;
  String? earnUpto;
  String? image;
  String? campaignToken;
  String? brandloginUniqueToken;
  String? additionals;
  String? revuerLimit;
  String? camTypeName;
  int? camTypeNumber;
  String? totaldays;
  bool? cam_type;


  MyCampaignDetailsModel(
      {this.sId,
        this.name,
        this.categoryName,
        this.campaignName,
        this.campaignObj,
        this.dos,
        this.donts,
        this.campTypeId,
        this.campTaskNameId,
        this.campaignTaskNames,
        this.earnUpto,
        this.image,
        this.campaignToken,
        this.brandloginUniqueToken,
        this.additionals,
        this.revuerLimit,
        this.camTypeName,
        this.camTypeNumber,
        this.totaldays,
        this.cam_type
      });

  MyCampaignDetailsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    categoryName = json['brand_name'];//change
    campaignName = json['campaign_name'];
    campaignObj = json['campaign_obj'];
    dos = json['dos'] == null? [] : List<String>.from(json['dos'].map((x) => x));
    donts = json['donts'] == null? [] : List<String>.from(json['donts'].map((x) => x));
    campTypeId = json['camp_type_id'];
    campTaskNameId = json['Camp_task_name_id'] == null? [] : List<String>.from(json['Camp_task_name_id'].map((x) => x));
    campaignTaskNames = json['campaignTaskNames'] == null? [] : List<String>.from(json['campaignTaskNames'].map((x) => x));
    earnUpto = json['earn_upto'];
    image = json['image'];
    campaignToken = json['campaign_token'];
    brandloginUniqueToken = json['brandlogin_unique_token'];
    additionals = json['additionals'];
    revuerLimit = json['revuerLimit'];
    camTypeName = json['cam_type_name'];
    camTypeNumber = json['cam_type_number'];
    totaldays = json['totaldays'];
    cam_type = json['cam_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['brand_name'] = categoryName;
    data['campaign_name'] = campaignName;
    data['campaign_obj'] = campaignObj;
    data['dos'] = dos;
    data['donts'] = donts;
    data['camp_type_id'] = campTypeId;
    data['Camp_task_name_id'] = campTaskNameId;
    data['campaignTaskNames'] = campaignTaskNames;
    data['earn_upto'] = earnUpto;
    data['image'] = image;
    data['campaign_token'] = campaignToken;
    data['brandlogin_unique_token'] = this.brandloginUniqueToken;
    data['additionals'] = this.additionals;
    data['revuerLimit'] = this.revuerLimit;
    data['cam_type_name'] = camTypeName;
    data['cam_type_number'] = camTypeNumber;
    data['totaldays'] = this.totaldays;
    data['cam_type'] = this.cam_type;
    return data;
  }

}
