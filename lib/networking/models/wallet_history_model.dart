/*class WalletHistoryModel {
  List<WalletHistory>? walletHistory;

  WalletHistoryModel({this.walletHistory});

  WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['wallet_history'] != null) {
      walletHistory = <WalletHistory>[];
      json['wallet_history'].forEach((v) {
        walletHistory!.add(new WalletHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.walletHistory != null) {
      data['wallet_history'] =
          this.walletHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WalletHistory {
  String? campaignName;
  String? image;
  String? brandName;
  int? amount;
  int? status;
  String? createdAt;
  String? date;

  WalletHistory(
      {this.campaignName,
        this.image,
        this.brandName,
        this.amount,
        this.status,
        this.createdAt,
        this.date});

  WalletHistory.fromJson(Map<String, dynamic> json) {
    campaignName = json['campaign_name'];
    image = json['image'];
    brandName = json['brand_name'];
    amount = json['amount'];
    status = json['status'];
    createdAt = json['createdAt'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['campaign_name'] = this.campaignName;
    data['image'] = this.image;
    data['brand_name'] = this.brandName;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['date'] = this.date;
    return data;
  }
}*/

class WalletHistoryModel {
  List<WalletHistory>? walletHistory;

  WalletHistoryModel({this.walletHistory});

  WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['wallet_history'] != null) {
      walletHistory = <WalletHistory>[];
      json['wallet_history'].forEach((v) {
        walletHistory!.add(WalletHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (walletHistory != null) {
      data['wallet_history'] = walletHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WalletHistory {
  String? campaignName;
  String? image;
  String? brandName;
  dynamic amount;
  String? status;
  int? withdrawType;
  int? withdrawStatus;
  String? createdAt;
  String? message;
  String? date;
  String? attachFile;

  WalletHistory(
      {this.campaignName,
      this.image,
      this.brandName,
      this.amount,
      this.status,
      this.withdrawType,
      this.withdrawStatus,
      this.createdAt,
      this.message,
      this.date,
      this.attachFile});

  WalletHistory.fromJson(Map<String, dynamic> json) {
    campaignName = json['campaign_name'];
    image = json['image'];
    brandName = json['brand_name'];
    amount = json['amount'];
    status = json['status'];
    withdrawType = json['withdraw_type'];
    withdrawStatus = json['withdraw_status'];
    createdAt = json['createdAt'];
    message = json['message'];
    date = json['date'];
    attachFile = json['attch_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['campaign_name'] = campaignName;
    data['image'] = image;
    data['brand_name'] = brandName;
    data['amount'] = amount;
    data['status'] = status;
    data['withdraw_type'] = withdrawType;
    data['withdraw_status'] = withdrawStatus;
    data['createdAt'] = createdAt;
    data['message'] = message;
    data['date'] = date;
    data['attch_file'] = attachFile;
    return data;
  }
}
