class FeedbackModel {
  List<Options>? options;
  List<Chat>? chat;
  String? authType;

  FeedbackModel({this.options, this.chat,this.authType});

  FeedbackModel.fromJson(Map<String, dynamic> json) {
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(new Options.fromJson(v));
      });
    }
    if (json['chat'] != null) {
      chat = <Chat>[];
      json['chat'].forEach((v) {
        chat!.add(new Chat.fromJson(v));
      });
    }
    authType = json['auth_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.options != null) {
      data['options'] = this.options!.map((v) => v.toJson()).toList();
    }
    if (this.chat != null) {
      data['chat'] = this.chat!.map((v) => v.toJson()).toList();
    }
    data['auth_type'] = this.authType;
    return data;
  }
}

class Options {
  String? name;
  String? optionToken;

  Options({this.name, this.optionToken});

  Options.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    optionToken = json['option_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['option_token'] = this.optionToken;
    return data;
  }
}

class Chat {
  String? message;
  String? type;
  String? date;
  String? image;
  String? revuer_image;

  Chat({this.message, this.type, this.date});

  Chat.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    type = json['type'];
    date = json['date'];
    image = json['image'];
    revuer_image = json['revuer_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['type'] = this.type;
    data['date'] = this.date;
    data['image'] = this.image;
    data['revuer_image'] = this.revuer_image;
    return data;
  }
}
