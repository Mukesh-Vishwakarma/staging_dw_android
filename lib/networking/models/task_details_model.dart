class TaskDetailsModel {
  String? previousType;
  String? detailTaskStatus;
  String? revuerTaskStatus;
  List<TaskDetail>? taskDetail;
  String? remarkMsg;
  String? resubmitreason;
  String? social_icon_type;
  String? draft_upload_type;
  int? rejectType;

  TaskDetailsModel(
      {this.previousType,
      this.taskDetail,
      this.detailTaskStatus,
      this.revuerTaskStatus,
      this.remarkMsg,
      this.resubmitreason,
      this.social_icon_type,
      this.draft_upload_type,
      this.rejectType});

  TaskDetailsModel.fromJson(Map<String, dynamic> json) {
    previousType = json['previous_type'];
    revuerTaskStatus = json['revuer_task_status'];
    detailTaskStatus = json['detail_task_status'];
    remarkMsg = json['remark_message'];
    resubmitreason = json['resubmitreason'];
    social_icon_type = json['social_icon_type'];
    draft_upload_type = json['draft_upload_type'];
    rejectType = json['reject_type'];
    if (json['task_detail'] != null) {
      taskDetail = <TaskDetail>[];
      json['task_detail'].forEach((v) {
        taskDetail!.add(TaskDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['previous_type'] = previousType;
    data['revuer_task_status'] = revuerTaskStatus;
    data['detail_task_status'] = detailTaskStatus;
    data['remark_message'] = remarkMsg;
    data['resubmitreason'] = resubmitreason;
    data['social_icon_type'] = social_icon_type;
    data['draft_upload_type'] = draft_upload_type;
    data['reject_type'] = rejectType;
    if (taskDetail != null) {
      data['task_detail'] = taskDetail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TaskDetail {
  String? title;
  String? description;
  String? type;
  dynamic ratings;

  TaskDetail({this.title, this.description, this.type, this.ratings});

  TaskDetail.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    type = json['type'];
    ratings = json['ratings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['description'] = description;
    data['type'] = type;
    data['ratings'] = ratings;
    return data;
  }
}
