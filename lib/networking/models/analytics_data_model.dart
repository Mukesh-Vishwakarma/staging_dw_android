class AnalyticsDataModel {
  dynamic earningAmount;
  dynamic rank;
  List<LeaderboardData>? leaderboardData;

  AnalyticsDataModel({this.earningAmount, this.rank, this.leaderboardData});

  AnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    earningAmount = json['earning_amount'];
    rank = json['rank'];
    if (json['leaderboard_data'] != null) {
      leaderboardData = <LeaderboardData>[];
      json['leaderboard_data'].forEach((v) {
        leaderboardData!.add(LeaderboardData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['earning_amount'] = earningAmount;
    data['rank'] = rank;
    if (leaderboardData != null) {
      data['leaderboard_data'] =
          leaderboardData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LeaderboardData {
  String? firstName;
  String? lastName;
  dynamic earningAmount;
  int? rank;

  LeaderboardData(
      {this.firstName, this.lastName, this.earningAmount, this.rank});

  LeaderboardData.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    earningAmount = json['earning_amount'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['earning_amount'] = earningAmount;
    data['rank'] = rank;
    return data;
  }
}
