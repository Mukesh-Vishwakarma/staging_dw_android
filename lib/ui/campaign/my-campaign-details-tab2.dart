import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/networking/models/task_list_model.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../shared_preference/preference_provider.dart';
import '../task/influencer_task_details.dart';
import '../task/influencer_task_invisable_details.dart';
import '../task/market_research_task_details.dart';
import '../task/product_review_task_details.dart';
import '../task/sampling_task_details.dart';
import '../task/survey_task_details.dart';
import '../task/testimonials_task_details.dart';
import '../task/testimonials_task_invisable_details.dart';
import '../task/video_review_task_details.dart';
import '../task/visual_review_task_details.dart';

class MyCampaignDetailsTab2Screen extends StatefulWidget {
  const MyCampaignDetailsTab2Screen({Key? key}) : super(key: key);

  @override
  State<MyCampaignDetailsTab2Screen> createState() =>
      _MyCampaignDetailsTab2ScreenState();
}

class _MyCampaignDetailsTab2ScreenState
    extends State<MyCampaignDetailsTab2Screen> {
  TaskListModel taskListModel = TaskListModel();

  bool isApiCalled = false;

  getTaskList() async {
    if (mounted) {
      setState(() {
        isApiCalled = true;
      });
    }
    Map<String, dynamic> body = {
      "campaign_token":
          await SharedPrefProvider.getString(SharedPrefProvider.campaignToken),
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken)
    };
    if (kDebugMode) {
      print("reqParam==> ${body.toString()}");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetTaskList(body).then((it) {
        if (it.status == "SUCCESS") {
          if (mounted) {
            setState(() {
              isApiCalled = false;
            });
            if (kDebugMode) {
              print("responseSuccess===> ${it.data.toString()}");
            }
            var realData = DataEncryption.getDecryptedData(
                it.data!.reqKey.toString(), it.data!.reqData.toString());
            taskListModel = TaskListModel.fromJson(realData);
            if (kDebugMode) {
              print("list data $realData");
            }
          }
        } else if (it.status == "FAILURE") {
          if (mounted) {
            Fluttertoast.showToast(msg: it.message.toString());
          }
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
        if (mounted) {
          Fluttertoast.showToast(msg: "Something went wrong");
        }
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException $obj");
        }
        switch (obj.runtimeType) {
          case DioError:
            // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            if (kDebugMode) {
              print("status ${res?.statusCode}");
            }
            if (kDebugMode) {
              print("status ${res?.statusMessage}");
            }
            if (kDebugMode) {
              print("status ${res?.data}");
            }
            break;
          default:
            break;
        }
      });
    } else {
      Fluttertoast.showToast(msg: "No Internet Available");
    }
  }

  @override
  void initState() {
    getTaskList();
    super.initState();
  }

  openScreens(TaskData taskData, bool isLastIndex) {
    // taskStatus
    print("openScreens-my-campaign-details-tab ===> ${taskData.camType}");
    if (taskData.camType == 1) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/campaign-task'),
              builder: (context) => ProductReviewTaskDetails(
                taskData: taskData,
                isLastIndex: isLastIndex,
              ),
            ),
          )
          .then((value) => {getTaskList()});
    } else if (taskData.camType == 2) {
      if (taskData.task_visiable == "1") {
        // for 1 show all task
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                settings: const RouteSettings(name: '/campaign-task'),
                builder: (context) => VisualReviewTaskDetails(
                  taskData: taskData,
                  isLastIndex: isLastIndex,
                ),
              ),
            )
            .then((value) => {getTaskList()});
      } else if (taskData.task_visiable == "2") {
        // for 1 show all task
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                settings: const RouteSettings(name: '/campaign-task'),
                builder: (context) => VideoReviewTaskDetails(
                  taskData: taskData,
                  isLastIndex: isLastIndex,
                ),
              ),
            )
            .then((value) => {getTaskList()});
      }
    } else if (taskData.camType == 3) {
      print("klasdbcjbhzx===>${taskData.task_visiable}");
      if (taskData.task_visiable == "1") {
        // for 1 show all task

        print("klasdbcjbhzx New===>${taskData.task_visiable}");

        Navigator.of(context)
            .push(
              MaterialPageRoute(
                settings: const RouteSettings(name: '/campaign-task'),
                builder: (context) => TestimonialsTaskDetails(
                  taskData: taskData,
                  isLastIndex: isLastIndex,
                ),
              ),
            )
            .then((value) => {getTaskList()});
      } else if (taskData.task_visiable == "2") {
        // for 2 hide buy and review..
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                settings: const RouteSettings(name: '/campaign-task'),
                builder: (context) => TestimonialsInvisibleTaskDetails(
                  taskData: taskData,
                  isLastIndex: isLastIndex,
                ),
              ),
            )
            .then((value) => {getTaskList()});
      }
    } else if (taskData.camType == 4) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/campaign-task'),
              builder: (context) => SamplingTaskDetails(
                taskData: taskData,
                isLastIndex: isLastIndex,
              ),
            ),
          )
          .then((value) => {getTaskList()});
    } else if (taskData.camType == 5) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/campaign-task'),
              builder: (context) => SurveyTaskDetails(
                taskData: taskData,
                isLastIndex: isLastIndex,
              ),
            ),
          )
          .then((value) => {getTaskList()});
    } else if (taskData.camType == 6) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/campaign-task'),
              builder: (context) => MarketResearchTaskDetails(
                taskData: taskData,
                isLastIndex: isLastIndex,
              ),
            ),
          )
          .then((value) => {getTaskList()});
    } else if (taskData.camType == 7) {
      if (taskData.task_visiable == "1") {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                settings: const RouteSettings(name: '/campaign-task'),
                builder: (context) => InfluencerTaskDetails(
                  taskData: taskData,
                  isLastIndex: isLastIndex,
                ),
              ),
            )
            .then((value) => {getTaskList()});
      } else if (taskData.task_visiable == "2") {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                settings: const RouteSettings(name: '/campaign-task'),
                builder: (context) => InfluencerTaskInvisibleDetails(
                  taskData: taskData,
                  isLastIndex: isLastIndex,
                ),
              ),
            )
            .then((value) => {getTaskList()});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 5.0, left: 16.0, right: 16.0),
        padding: const EdgeInsets.only(
            bottom: 18.0, left: 18.0, right: 18.0, top: 0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff2A3B53).withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 7,
                offset: const Offset(1, 1),
              ),
              BoxShadow(
                color: const Color(0xff2A3B53).withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 20.0,
                offset: const Offset(0, 0),
              )
            ]),
        child: isApiCalled
            ? const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            : taskListModel.taskData!.isNotEmpty
                ? ListView.separated(
                    itemCount: taskListModel.taskData!.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                          height: 1,
                          color: grayColor,
                        ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // print("jsdbjd====>${taskListModel.taskData!.length - 1} == ${index}"); taskStatus
                          if (taskListModel.taskData!.length - 1 == index) {
                            print(
                                "objectjbkjhbsd==> ${taskListModel.taskData![2].taskStatus!.toString()}");
                            print(
                                "objectjbkjhbsd==> ${taskListModel.taskData![2].rejectType!.toString()}");

                            if (taskListModel.taskData![2].taskStatus!
                                        .toString() ==
                                    "2" &&
                                taskListModel.taskData![2].rejectType!
                                        .toString() ==
                                    "6") {
                              // openScreens(taskListModel.taskData![index], true,);
                            } else {
                              openScreens(
                                taskListModel.taskData![index],
                                true,
                              );
                            }
                          } else {
                            openScreens(taskListModel.taskData![index], false);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/icons/interests.png',
                                            width: 19.9,
                                            height: 23.64,
                                            fit: BoxFit.contain,
                                            color: (taskListModel.taskData![2]
                                                            .taskStatus!
                                                            .toString() ==
                                                        "2" &&
                                                    taskListModel.taskData![2]
                                                            .rejectType!
                                                            .toString() ==
                                                        "6" &&
                                                    taskListModel
                                                            .taskData!.length ==
                                                        index + 1)
                                                ? Colors.grey
                                                : null,
                                          ),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "Task ${index + 1} : ${taskListModel.taskData![index].taskName!}",
                                              style: TextStyle(
                                                  color: (taskListModel
                                                                  .taskData![2]
                                                                  .taskStatus!
                                                                  .toString() ==
                                                              "2" &&
                                                          taskListModel
                                                                  .taskData![2]
                                                                  .rejectType!
                                                                  .toString() ==
                                                              "6" &&
                                                          taskListModel
                                                                  .taskData!
                                                                  .length ==
                                                              index + 1)
                                                      ? Colors.grey
                                                      : secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        taskListModel
                                            .taskData![index].taskDetail!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                            color: (taskListModel.taskData![2]
                                                            .taskStatus!
                                                            .toString() ==
                                                        "2" &&
                                                    taskListModel.taskData![2]
                                                            .rejectType!
                                                            .toString() ==
                                                        "6" &&
                                                    taskListModel
                                                            .taskData!.length ==
                                                        index + 1)
                                                ? Colors.grey
                                                : secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                taskStatusWidget(
                                    taskListModel.taskData![index].taskStatus!,
                                    taskListModel.taskData![index].rejectType!,
                                    taskListModel.taskData![index].taskType!),
                                (taskListModel.taskData![index].taskStatus! !=
                                        "2")
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/icons/clock.png',
                                            width: 22.0,
                                            height: 22.0,
                                            fit: BoxFit.contain,
                                            color: (taskListModel.taskData![2]
                                                            .taskStatus!
                                                            .toString() ==
                                                        "2" &&
                                                    taskListModel.taskData![2]
                                                            .rejectType!
                                                            .toString() ==
                                                        "6" &&
                                                    taskListModel
                                                            .taskData!.length ==
                                                        index + 1)
                                                ? Colors.grey
                                                : null,
                                          ),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          const Text(
                                            "Time left : ",
                                            style: TextStyle(
                                              color: thirdColor,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            taskListModel
                                                .taskData![index].taskDays!,
                                            style: TextStyle(
                                              color: (taskListModel.taskData![2]
                                                                  .taskStatus!
                                                                  .toString() !=
                                                              "2" &&
                                                          taskListModel
                                                                  .taskData![2]
                                                                  .taskType!
                                                                  .toString() !=
                                                              "6" ||
                                                      taskListModel.taskData!
                                                                  .length -
                                                              1 !=
                                                          index)
                                                  ? secondaryColor
                                                  : Colors.grey,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                          ],
                        ),
                      );
                    })
                : noTask());
  }

  Widget noTask() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/task.png',
            width: 40.00,
            height: 35.00,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Text(
            "Task is empty...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "You don’t have any Task...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget taskStatusWidget(String taskStatus, int rejectType, int taskType) {
    print("jhbxjhzk taskStatus ===> $taskStatus");
    print("jhbxjhzk rejectType ===> $rejectType");
    print("jhbxjhzk taskType ===> $taskType");

    switch (taskStatus) {
      case "0":
        return Material(
          color: pdColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/pending.png',
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 5.0,
                ),
                const Text(
                  "Pending",
                  style: TextStyle(
                      color: pdDarkColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      case "1":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/ongoing.png',
                width: 20.0,
                height: 20.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                width: 5.0,
              ),
              const Text(
                "On going",
                style: TextStyle(
                    color: onGoingColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      case "2":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/check.png',
                width: 20.0,
                height: 20.0,
                fit: BoxFit.contain,
                color: completedColor,
              ),
              const SizedBox(
                width: 5.0,
              ),
              const Text(
                "Completed",
                style: TextStyle(
                    color: completedColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      case "3":
        if (rejectType == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/close_red.png",
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 5.0,
                ),
                const Text(
                  "Not Yet",
                  style: TextStyle(
                      color: rejectDarkColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/close_red.png",
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 5.0,
                ),
                const Text(
                  "Rejected",
                  style: TextStyle(
                      color: rejectDarkColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

      case "5":
        return (taskType == 3 && rejectType == 5 && taskType == 3)
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/pending.png',
                      width: 20.0,
                      height: 20.0,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    const Text(
                      "Resubmission",
                      style: TextStyle(
                          color: pdDarkColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/ongoing.png',
                      width: 20.0,
                      height: 20.0,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    const Text(
                      "On going",
                      style: TextStyle(
                          color: onGoingColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );

      case "6":
        if (taskType == 3) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/ongoing.png',
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 5.0,
                ),
                const Text(
                  "On going",
                  style: TextStyle(
                      color: onGoingColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/close_red.png",
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 5.0,
                ),
                const Text(
                  "Not Yet",
                  style: TextStyle(
                      color: rejectDarkColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

      case "7":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/close_red.png",
                width: 20.0,
                height: 20.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                width: 5.0,
              ),
              const Text(
                "Rejected",
                style: TextStyle(
                    color: rejectDarkColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }
}
