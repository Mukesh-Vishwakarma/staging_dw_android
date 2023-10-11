class GetProfileModel {
  int? mobileNo;
  String? image;
  String? firstName;
  String? lastName;
  String? address;
  String? email;
  int? children;
  String? stateId;
  String? cityId;
  String? dob;
  String? pincode;
  int? gender;
  int? revuerStatus;
  int? emailVerifyStatus;
  int? mobileVerifyStatus;
  String? revuerToken;

  GetProfileModel(
      {this.mobileNo,
        this.image,
        this.firstName,
        this.lastName,
        this.address,
        this.email,
        this.children,
        this.stateId,
        this.cityId,
        this.dob,
        this.pincode,
        this.gender,
        this.revuerStatus,
        this.emailVerifyStatus,
        this.mobileVerifyStatus,
        this.revuerToken});

  GetProfileModel.fromJson(Map<String, dynamic> json) {
    mobileNo = json['mobile_no'];
    image = json['image'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    address = json['address'];
    email = json['email'];
    children = json['children'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    dob = json['dob'];
    pincode = json['pincode'];
    gender = json['gender'];
    revuerStatus = json['revuer_status'];
    emailVerifyStatus = json['email_verify_status'];
    mobileVerifyStatus = json['mobile_verify_status'];
    revuerToken = json['revuer_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobile_no'] = this.mobileNo;
    data['image'] = this.image;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['address'] = this.address;
    data['email'] = this.email;
    data['children'] = this.children;
    data['state_id'] = this.stateId;
    data['city_id'] = this.cityId;
    data['dob'] = this.dob;
    data['pincode'] = this.pincode;
    data['gender'] = this.gender;
    data['revuer_status'] = this.revuerStatus;
    data['email_verify_status'] = this.emailVerifyStatus;
    data['mobile_verify_status'] = this.mobileVerifyStatus;
    data['revuer_token'] = this.revuerToken;
    return data;
  }
}
