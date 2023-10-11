class GetInterestData {
  String? status;
  String? message;
  List<Data>? data;

  GetInterestData({this.status, this.message, this.data});

  GetInterestData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  String? id;
  String? name;
  bool? checktype;

  Data({this.id, this.name, this.checktype});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    checktype = json['checktype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['name'] = this.name;
    data['checktype'] = this.checktype;
    return data;
  }
}
