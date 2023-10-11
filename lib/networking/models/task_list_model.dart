/*class TaskListModel {
  List<TaskData>? taskData;

  TaskListModel({this.taskData});

  TaskListModel.fromJson(Map<String, dynamic> json) {
    if (json['task_data'] != null) {
      taskData = <TaskData>[];
      json['task_data'].forEach((v) {
        taskData!.add(new TaskData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.taskData != null) {
      data['task_data'] = this.taskData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TaskData {
  String? taskName;
  String? campaignToken;
  int? taskNumber;
  String? taskStatus;
  String? taskToken;
  String? taskDetail;
  int? taskType;

  TaskData(
      {this.taskName,
        this.campaignToken,
        this.taskNumber,
        this.taskStatus,
        this.taskToken,
        this.taskDetail,
        this.taskType});

  TaskData.fromJson(Map<String, dynamic> json) {
    taskName = json['task_name'];
    campaignToken = json['campaign_token'];
    taskNumber = json['task_number'];
    taskStatus = json['task_status'];
    taskToken = json['task_token'];
    taskDetail = json['task_detail'];
    taskType = json['task_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_name'] = this.taskName;
    data['campaign_token'] = this.campaignToken;
    data['task_number'] = this.taskNumber;
    data['task_status'] = this.taskStatus;
    data['task_token'] = this.taskToken;
    data['task_detail'] = this.taskDetail;
    data['task_type'] = this.taskType;
    return data;
  }

}*/

class TaskListModel {
  List<TaskData>? taskData;

  TaskListModel({this.taskData});

  TaskListModel.fromJson(Map<String, dynamic> json) {
    if (json['task_data'] != null) {
      taskData = <TaskData>[];
      json['task_data'].forEach((v) {
        taskData!.add(new TaskData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.taskData != null) {
      data['task_data'] = this.taskData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TaskData {
  String? taskName;
  int? camType;
  int? taskNumber;
  String? campaignToken;
  String? taskStatus;
  String? taskToken;
  String? taskDetail;
  String? previousStatus;
  String? taskDays;
  String? task_visiable;
  int? taskType;
  int? rejectType;

  TaskData(
      {this.taskName,
        this.camType,
        this.taskNumber,
        this.campaignToken,
        this.taskStatus,
        this.taskToken,
        this.taskDetail,
        this.previousStatus,
        this.taskDays,
        this.taskType,
      this.task_visiable,
      this.rejectType});

  TaskData.fromJson(Map<String, dynamic> json) {
    taskName = json['task_name'];
    camType = json['cam_type'];
    taskNumber = json['task_number'];
    campaignToken = json['campaign_token'];
    taskStatus = json['task_status'];
    taskToken = json['task_token'];
    taskDetail = json['task_detail'];
    previousStatus = json['previous_status'];
    taskType = json['task_type'];
    taskDays = json['taskDays'];
    task_visiable = json['task_visiable'];
    rejectType = json['reject_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_name'] = this.taskName;
    data['cam_type'] = this.camType;
    data['task_number'] = this.taskNumber;
    data['campaign_token'] = this.campaignToken;
    data['task_status'] = this.taskStatus;
    data['task_token'] = this.taskToken;
    data['task_detail'] = this.taskDetail;
    data['previous_status'] = this.previousStatus;
    data['task_type'] = this.taskType;
    data['taskDays'] = this.taskDays;
    data['task_visiable'] = this.task_visiable;
    data['reject_type'] = this.rejectType;
    return data;
  }

}
