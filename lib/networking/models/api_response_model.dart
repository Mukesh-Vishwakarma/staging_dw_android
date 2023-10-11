class ApiResponseModel {
  String? status;
  String? message;
  Data? data;

  ApiResponseModel({this.status, this.message, this.data});

  ApiResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? reqData;
  String? reqKey;

  Data({this.reqData, this.reqKey});

  Data.fromJson(Map<String, dynamic> json) {
      reqData = json['reqData'];
      reqKey = json['reqKey'];
    }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reqData'] = this.reqData;
    data['reqKey'] = this.reqKey;
    return data;
  }
}
