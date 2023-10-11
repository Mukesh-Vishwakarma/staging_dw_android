/*
class MyEarningWalletModel {
  int? walletBalance;
  List<ChartData>? chartData;

  MyEarningWalletModel({this.walletBalance, this.chartData});

  MyEarningWalletModel.fromJson(Map<String, dynamic> json) {
    walletBalance = json['wallet_balance'];
    if (json['chart_data'] != null) {
      chartData = <ChartData>[];
      json['chart_data'].forEach((v) {
        chartData!.add(ChartData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wallet_balance'] = walletBalance;
    if (chartData != null) {
      data['chart_data'] = chartData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChartData {
  String? monthName;
  int? amount;

  ChartData({this.monthName, this.amount});

  ChartData.fromJson(Map<String, dynamic> json) {
    monthName = json['month_name'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['month_name'] = monthName;
    data['amount'] = amount;
    return data;
  }
}
*/

class MyEarningWalletModel {
  dynamic walletBalance;
  List<ChartData>? chartData;
  List<String>? yearName;
  List<String>? monthName;

  MyEarningWalletModel(
      {this.walletBalance, this.chartData, this.yearName, this.monthName});

  MyEarningWalletModel.fromJson(Map<String, dynamic> json) {
    walletBalance = json['wallet_balance'];
    if (json['chart_data'] != null) {
      chartData = <ChartData>[];
      json['chart_data'].forEach((v) {
        chartData!.add(ChartData.fromJson(v));
      });
    }
    yearName = json['year_name'].cast<String>();
    monthName = json['month_name'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wallet_balance'] = walletBalance;
    if (chartData != null) {
      data['chart_data'] = chartData!.map((v) => v.toJson()).toList();
    }
    data['year_name'] = yearName;
    data['month_name'] = monthName;
    return data;
  }
}

class ChartData {
  String? monthName;
  dynamic amount;

  ChartData({this.monthName, this.amount});

  ChartData.fromJson(Map<String, dynamic> json) {
    monthName = json['month_name'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['month_name'] = monthName;
    data['amount'] = amount;
    return data;
  }
}
