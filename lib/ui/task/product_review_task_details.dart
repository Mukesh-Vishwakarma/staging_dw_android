import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revuer/networking/models/task_details_model.dart';
import 'package:revuer/networking/models/task_list_model.dart';
import 'package:revuer/ui/task/fullimage_view_screen.dart';
import 'package:revuer/widgets/spin_kit_loader.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom-dialog.dart';
import '../main/main.dart';

class ProductReviewTaskDetails extends StatefulWidget {
  TaskData taskData;
  bool isLastIndex;

  ProductReviewTaskDetails(
      {Key? key, required this.taskData, required this.isLastIndex})
      : super(key: key);

  @override
  State<ProductReviewTaskDetails> createState() =>
      _ProductReviewTaskDetailsState();
}

class _ProductReviewTaskDetailsState extends State<ProductReviewTaskDetails> {
  double statusBarHeight = 5.0;
  var buttonLoaderStatus = false;

  void _openMyPage() {
    Navigator.of(context).pop();
    /*Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/my-campaign-details'),
        builder: (context) => MyCampaignDetailsScreen(index: 1),
      ),
    );*/
  }

  String previousType = "0";
  bool isApiCalled = false;
  String taskStatus = "";
  TaskDetailsModel taskDetailsModel = TaskDetailsModel();
  TaskListModel taskListModel = TaskListModel();

  getTaskList() async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> body = {
      "campaign_token":
          await SharedPrefProvider.getString(SharedPrefProvider.campaignToken),
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken)
    };
    if (kDebugMode) {
      print("reqparam ${body.toString()}");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetTaskList(body).then((it) {
        if (it.status == "SUCCESS") {
          setState(() {
            isApiCalled = false;
          });
          // Fluttertoast.showToast(msg: it["message"].toString());
          if (kDebugMode) {
            print("responseSuccess ${it.data.toString()}");
          }
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          taskListModel = TaskListModel.fromJson(realData);
          if (kDebugMode) {
            print("list data $realData");
          }
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
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

  getTaskDetails() async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> body = {
      "task_token": widget.taskData.taskToken,
      "campaign_token": widget.taskData.campaignToken,
      "previous_status": widget.taskData.previousStatus,
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken)
    };
    if (kDebugMode) {
      print("reqParam ${body.toString()}");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetTaskDetails(body).then((it) {
        setState(() {
          buttonLoaderStatus = false;
        });
        if (it.status == "SUCCESS") {
          setState(() {
            isApiCalled = false;
          });
          // Fluttertoast.showToast(msg: it["message"].toString());
          if (kDebugMode) {
            print("responseSuccess get task ${it.data.toString()}");
          }
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          taskDetailsModel = TaskDetailsModel.fromJson(realData);
          setState(() {
            previousType = taskDetailsModel.previousType!;
            taskStatus = taskDetailsModel.revuerTaskStatus!;
          });
          if (taskDetailsModel.previousType == "0") {
            // Fluttertoast.showToast(msg: it.message.toString());
          }
          if (kDebugMode) {
            print("details data $realData");
          }
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure get task$it");
          }
        }
      }).catchError((Object obj) {
        setState(() {
          buttonLoaderStatus = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException get task$obj");
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
      setState(() {
        buttonLoaderStatus = false;
      });
      Fluttertoast.showToast(msg: "No Internet Available");
    }
  }

  saveTaskDetails(File image, String imageName) async {
    setState(() {
      isApiCalled = true;
        buttonLoaderStatus = true;
    });
    var revuerToekn =
        await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken);
    Map<String, dynamic> map = {
      "task_token": widget.taskData.taskToken,
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "image": image,
      "image_name": imageName,
    };
    if (kDebugMode) {
      print("reqParam ${map.toString()}");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveTask(image, widget.taskData.taskToken!, revuerToekn!, "")
          .then((it) {
        setState(() {
          buttonLoaderStatus = false;
        });
        if (kDebugMode) {
          print("responseSuccess save task outer$it");
        }
        if (it["status"] == "SUCCESS") {
          if (kDebugMode) {
            print("responseSuccess save task inner $it");
          }
          setState(() {
            isApiCalled = false;
            getTaskDetails();
          });
          Fluttertoast.showToast(msg: it["message"].toString());
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          if (kDebugMode) {
            print("responseFailure save task$it");
          }
        }
      }).catchError((Object obj) {
        setState(() {
          buttonLoaderStatus = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException save task $obj");
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
      setState(() {
        buttonLoaderStatus = false;
      });
      Fluttertoast.showToast(msg: "No Internet Available");
    }
  }

  // upload task image for task 1 and task 2:------>>>>>
  String? progress;
  int percentProgress = 0;
  Dio dio = Dio();
  bool showProgress = false;

  uploadData(File file, String imageName) async {
    setState(() {
      buttonLoaderStatus = true;
    });
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      String uploadUrl = "${Strings.baseUrl}api/save-task";
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename: imageName),
        "task_token": widget.taskData.taskToken,
        "revuer_token":
            await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
        "task_desc": ""
      });
      var response = await dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          String percentage = (sent / total * 100).toStringAsFixed(0);
          setState(() {
            showProgress = true;
            progress = "$sent Bytes of $total Bytes - $percentage % uploaded";
            percentProgress = int.parse(percentage);
            //update the progress
          });
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          buttonLoaderStatus = false;
        });
        if (kDebugMode) {
          print(response.toString());
        }
        if (kDebugMode) {
          print(response.data);
        }
        if (kDebugMode) {
          print(response.statusMessage);
        }
        if (response.data["status"] == "SUCCESS") {
          Fluttertoast.showToast(msg: response.data["message"]);
          setState(() {
            showProgress = false;
            getTaskDetails();
          });
          if (kDebugMode) {
            print("response success..");
          }
        } else if (response.data["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: response.data["message"]);
          if (kDebugMode) {
            print("response failure..");
          }
        }
        //print response from server
      } else {
        setState(() {
          buttonLoaderStatus = false;
        });
        if (kDebugMode) {
          print("response error..");
        }
        Fluttertoast.showToast(msg: "Something went wrong..");
      }
    } else {
      setState(() {
        buttonLoaderStatus = false;
      });
      Fluttertoast.showToast(msg: "No Internet Available");
    }
  }

  // <<<<----------upload task image for task 1 and task 2

  browseInternet(String url) async {
    try {
      if (kDebugMode) {
        print("url is:$url");
      }
      if (!await launchUrl(Uri.parse(url.trim()),
          mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
      return true;
    } catch (error) {
      if (kDebugMode) {
        print("url is error :$error");
      }
    }
  }

  // for pick image from gallery or camera ------->>
  File? selectedImage;
  String base64Image = "";
  String imageName = "";

  File? selectedVideo;

  Future<void> chooseImage() async {
    // ignore: prefer_typing_uninitialized_variables
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        base64Image = base64Encode(selectedImage!.readAsBytesSync());
        imageName = selectedImage!.path.split('/').last;
        if (kDebugMode) {
          print("base 64 ${base64Image.length}");
        }
        if (kDebugMode) {
          print("base 64 selected image $selectedImage");
        }
        if (kDebugMode) {
          print("base 64 $base64Image");
        }
        // won't have any error now
      });
      if (kDebugMode) {
        print("selected image $selectedImage ");
      }
      if (kDebugMode) {
        print("selected image name $imageName ");
      }
      if (kDebugMode) {
        print("selected image image ${image.toString()} ");
      }
    }
  }

  // <<------ for pick image from gallery or camera...

  @override
  void initState() {
    getTaskDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    return WillPopScope(
      onWillPop: () async {
        _openMyPage();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: showWidgets(),
      ),
    );
  }

  Widget showWidgets() {
    if (widget.taskData.taskType == 1) {
      if (taskStatus == "1" || taskStatus == "2") {
        return taskOneGetWidget();
      } else if (taskStatus == "3") {
        return taskOneRejectWidget();
      } else {
        return taskOneUpdateWidget();
      }
    } else if (widget.taskData.taskType == 2) {
      if (taskStatus == "1" || taskStatus == "2") {
        return taskTwoGetWidgets();
      } else if (taskStatus == "3") {
        return taskTwoRejectWidgets();
      } else {
        return taskTwoUpdateWidgets();
      }
    } else {
      return elseWidgets();
    }
  }

  // for update first task data first time ----->>>>
  Widget taskOneUpdateWidget() {
    return Stack(
      children: [
        SizedBox(
          child: ClipPath(
            clipper: OvalClipper(),
            child: Container(
              width: double.infinity,
              height: 242.0,
              color: secondaryColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openMyPage(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                  child: Image.asset(
                    'assets/icons/back.png',
                    width: 23.0,
                    height: 23.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Task 1: ${widget.taskData.taskName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Flexible(
                child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 80.0),
                    padding: const EdgeInsets.all(16.0),
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
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/interests.png',
                                      width: 20.01,
                                      height: 25.87,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      taskDetailsModel.taskDetail![0].title!,
                                      style: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5.0),
                                      child: Image.asset(
                                        'assets/icons/right-arrow.png',
                                        width: 22.0,
                                        height: 12.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Text(
                                        taskDetailsModel
                                            .taskDetail![0].description!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/icons/link.png',
                                      width: 18.0,
                                      height: 18.0,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          taskDetailsModel
                                              .taskDetail![1].title!,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        InkWell(
                                          onTap: () => browseInternet(
                                              taskDetailsModel
                                                  .taskDetail![1].description!),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/images/browser.png',
                                                width: 30.0,
                                                height: 30.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              const Text(
                                                "Browser",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        )
                                        /* Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/browser.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Amazon",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/flipkart.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Flipkart",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/myntra.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Myntra",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/meesho.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Meesho",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )*/
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/icons/upload.png',
                                      width: 20.0,
                                      height: 21.0,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          taskDetailsModel
                                              .taskDetail![2].title!,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                chooseImage();
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  selectedImage == null
                                                      ? DottedBorder(
                                                          dashPattern: const [
                                                            6,
                                                            4
                                                          ],
                                                          color: thirdColor,
                                                          borderType:
                                                              BorderType.RRect,
                                                          radius: const Radius
                                                              .circular(10),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                        .all(
                                                                    Radius
                                                                        .circular(
                                                                            12)),
                                                            child: SizedBox(
                                                              height: 85.0,
                                                              width: 85.0,
                                                              child: Center(
                                                                child:
                                                                    Image.asset(
                                                                  'assets/icons/plus.png',
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          width: 85.0,
                                                          height: 85.0,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              image: DecorationImage(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: FileImage(
                                                                      selectedImage!)))),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 18,
                                            ),
                                            showProgress
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: 55,
                                                        height: 55,
                                                        child: Stack(
                                                          fit: StackFit.expand,
                                                          children: [
                                                            CircularProgressIndicator(
                                                              value:
                                                                  (percentProgress /
                                                                          100)
                                                                      .toDouble(),
                                                              valueColor:
                                                                  const AlwaysStoppedAnimation(
                                                                      primaryColor),
                                                              strokeWidth: 5,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                            ),
                                                            Center(
                                                                child:
                                                                    buildProgress()),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      const Text(
                                                        "Uploading..",
                                                        style: TextStyle(
                                                            color:
                                                                secondaryColor,
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          )),
              )
            ],
          ),
        ),
        previousType == "0" || showProgress
            ? Positioned(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          buttonColor: primaryLightColor,
                          buttonText: "SUBMIT TASK",
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Positioned(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child:  (!buttonLoaderStatus)
                              ? ButtonWidget(
                          buttonText: "SUBMIT TASK",
                          onPressed: () {
                            if (selectedImage == null) {
                              Fluttertoast.showToast(
                                  msg: "Please select a image");
                            } else {
                              uploadData(selectedImage!, imageName);
                              //  saveTaskDetails(selectedImage!, imageName);
                            }
                          },
                        ):const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  //<----- for update first task data first time

  // for get first task data after submit task----->>>>
  Widget taskOneGetWidget() {
    return Stack(
      children: [
        SizedBox(
          child: ClipPath(
            clipper: OvalClipper(),
            child: Container(
              width: double.infinity,
              height: 242.0,
              color: secondaryColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openMyPage(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                  child: Image.asset(
                    'assets/icons/back.png',
                    width: 23.0,
                    height: 23.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Task 1: ${widget.taskData.taskName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Flexible(
                child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 80.0),
                    padding: const EdgeInsets.all(16.0),
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
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/interests.png',
                                      width: 20.01,
                                      height: 25.87,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      taskDetailsModel.taskDetail![0].title!,
                                      style: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5.0),
                                      child: Image.asset(
                                        'assets/icons/right-arrow.png',
                                        width: 22.0,
                                        height: 12.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Text(
                                        taskDetailsModel
                                            .taskDetail![0].description!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/icons/link.png',
                                      width: 18.0,
                                      height: 18.0,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          taskDetailsModel
                                              .taskDetail![1].title!,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        InkWell(
                                          onTap: () => browseInternet(
                                              taskDetailsModel
                                                  .taskDetail![1].description!),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/images/browser.png',
                                                width: 30.0,
                                                height: 30.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              const Text(
                                                "Browser",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        )
                                        /* Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/browser.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Amazon",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/flipkart.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Flipkart",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/myntra.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Myntra",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/meesho.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Meesho",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )*/
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/icons/upload.png',
                                      width: 20.0,
                                      height: 21.0,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          taskDetailsModel
                                              .taskDetail![2].title!,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImageViewScreen(
                                                            url: taskDetailsModel
                                                                .taskDetail![2]
                                                                .description!,
                                                          )),
                                                );
                                              },
                                              child: isApiCalled
                                                  ? Shimmer.fromColors(
                                                      baseColor: const Color
                                                              .fromRGBO(
                                                          191,
                                                          191,
                                                          191,
                                                          0.5254901960784314),
                                                      highlightColor:
                                                          Colors.white,
                                                      child: Container(
                                                        width: 85.0,
                                                        height: 85.0,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: 85.0,
                                                      height: 85.0,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    12)),
                                                        child: Image.network(
                                                          taskDetailsModel
                                                              .taskDetail![2]
                                                              .description!,
                                                          fit: BoxFit.cover,
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return Shimmer
                                                                .fromColors(
                                                              baseColor: const Color
                                                                      .fromRGBO(
                                                                  191,
                                                                  191,
                                                                  191,
                                                                  0.5254901960784314),
                                                              highlightColor:
                                                                  Colors.white,
                                                              child: Container(
                                                                width: 41.0,
                                                                height: 41.0,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            taskStatusWidgets(taskStatus)
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          )),
              )
            ],
          ),
        ),
        nextTaskButton()
      ],
    );
  }

  //<----- for get first task data after submit task

  // for get first task data after submit task----->>>>
  Widget taskOneRejectWidget() {
    return Stack(
      children: [
        SizedBox(
          child: ClipPath(
            clipper: OvalClipper(),
            child: Container(
              width: double.infinity,
              height: 242.0,
              color: secondaryColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openMyPage(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                  child: Image.asset(
                    'assets/icons/back.png',
                    width: 23.0,
                    height: 23.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Task 1: ${widget.taskData.taskName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Flexible(
                child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 80.0),
                    padding: const EdgeInsets.all(16.0),
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
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/interests.png',
                                      width: 20.01,
                                      height: 25.87,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      taskDetailsModel.taskDetail![0].title!,
                                      style: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5.0),
                                      child: Image.asset(
                                        'assets/icons/right-arrow.png',
                                        width: 22.0,
                                        height: 12.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Text(
                                        taskDetailsModel
                                            .taskDetail![0].description!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/icons/link.png',
                                      width: 18.0,
                                      height: 18.0,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          taskDetailsModel
                                              .taskDetail![1].title!,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        InkWell(
                                          onTap: () => browseInternet(
                                              taskDetailsModel
                                                  .taskDetail![1].description!),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/images/browser.png',
                                                width: 30.0,
                                                height: 30.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              const Text(
                                                "Browser",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        )
                                        /* Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/browser.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Amazon",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/flipkart.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Flipkart",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/myntra.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Myntra",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30.0,
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/icons/meesho.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                const Text(
                                                  "Meesho",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )*/
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/icons/upload.png',
                                      width: 20.0,
                                      height: 21.0,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          taskDetailsModel
                                              .taskDetail![2].title!,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImageViewScreen(
                                                            url: taskDetailsModel
                                                                .taskDetail![2]
                                                                .description!,
                                                          )),
                                                );
                                              },
                                              child: isApiCalled
                                                  ? Shimmer.fromColors(
                                                      baseColor: const Color
                                                              .fromRGBO(
                                                          191,
                                                          191,
                                                          191,
                                                          0.5254901960784314),
                                                      highlightColor:
                                                          Colors.white,
                                                      child: Container(
                                                        width: 85.0,
                                                        height: 85.0,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: 85.0,
                                                      height: 85.0,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    12)),
                                                        child: Image.network(
                                                          taskDetailsModel
                                                              .taskDetail![2]
                                                              .description!,
                                                          fit: BoxFit.cover,
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return Shimmer
                                                                .fromColors(
                                                              baseColor: const Color
                                                                      .fromRGBO(
                                                                  191,
                                                                  191,
                                                                  191,
                                                                  0.5254901960784314),
                                                              highlightColor:
                                                                  Colors.white,
                                                              child: Container(
                                                                width: 41.0,
                                                                height: 41.0,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            taskStatusWidgets(taskStatus)
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 20.0,
                                      height: 21.0,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                chooseImage();
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  selectedImage == null
                                                      ? DottedBorder(
                                                          dashPattern: const [
                                                            6,
                                                            4
                                                          ],
                                                          color: thirdColor,
                                                          borderType:
                                                              BorderType.RRect,
                                                          radius: const Radius
                                                              .circular(10),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                        .all(
                                                                    Radius
                                                                        .circular(
                                                                            12)),
                                                            child: SizedBox(
                                                              height: 85.0,
                                                              width: 85.0,
                                                              child: Center(
                                                                child:
                                                                    Image.asset(
                                                                  'assets/icons/plus.png',
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          width: 85.0,
                                                          height: 85.0,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              image: DecorationImage(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: FileImage(
                                                                      selectedImage!)))),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 18,
                                            ),
                                            showProgress
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: 55,
                                                        height: 55,
                                                        child: Stack(
                                                          fit: StackFit.expand,
                                                          children: [
                                                            CircularProgressIndicator(
                                                              value:
                                                                  (percentProgress /
                                                                          100)
                                                                      .toDouble(),
                                                              valueColor:
                                                                  const AlwaysStoppedAnimation(
                                                                      primaryColor),
                                                              strokeWidth: 5,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                            ),
                                                            Center(
                                                                child:
                                                                    buildProgress()),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      const Text(
                                                        "Uploading..",
                                                        style: TextStyle(
                                                            color:
                                                                secondaryColor,
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          )),
              )
            ],
          ),
        ),
        showProgress
            ? Positioned(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:ButtonWidget(
                          buttonColor: primaryLightColor,
                          buttonText: "SUBMIT TASK",
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Positioned(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:  (!buttonLoaderStatus)
                            ? ButtonWidget(
                          buttonText: "SUBMIT TASK",
                          onPressed: () {
                            if (selectedImage == null) {
                              Fluttertoast.showToast(
                                  msg: "Please select a image");
                            } else {
                              uploadData(selectedImage!, imageName);
                              //  saveTaskDetails(selectedImage!, imageName);
                            }
                          },
                        ):const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              )
      ],
    );
  }

  //<----- for get first task data after submit task

  // for update second task data first time ----->>>>
  Widget taskTwoUpdateWidgets() {
    return Stack(
      children: [
        SizedBox(
          child: ClipPath(
            clipper: OvalClipper(),
            child: Container(
              width: double.infinity,
              height: 242.0,
              color: secondaryColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openMyPage(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                  child: Image.asset(
                    'assets/icons/back.png',
                    width: 23.0,
                    height: 23.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Task 2: ${widget.taskData.taskName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 80.0),
                  padding: const EdgeInsets.all(16.0),
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
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/interests.png',
                                    width: 20.01,
                                    height: 25.87,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    taskDetailsModel.taskDetail![0].title!,
                                    style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5.0),
                                    child: Image.asset(
                                      'assets/icons/right-arrow.png',
                                      width: 22.0,
                                      height: 12.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      taskDetailsModel
                                          .taskDetail![0].description!,
                                      style: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/icons/upload.png',
                                    width: 20.0,
                                    height: 21.0,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        taskDetailsModel.taskDetail![1].title!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              chooseImage();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                selectedImage == null
                                                    ? DottedBorder(
                                                        dashPattern: const [
                                                          6,
                                                          4
                                                        ],
                                                        color: thirdColor,
                                                        borderType:
                                                            BorderType.RRect,
                                                        radius: const Radius
                                                            .circular(10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          child: SizedBox(
                                                            height: 85.0,
                                                            width: 85.0,
                                                            child: Center(
                                                              child:
                                                                  Image.asset(
                                                                'assets/icons/plus.png',
                                                                width: 20.0,
                                                                height: 20.0,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: 85.0,
                                                        height: 85.0,
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            image: DecorationImage(
                                                                fit:
                                                                    BoxFit.fill,
                                                                image: FileImage(
                                                                    selectedImage!)))),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 18,
                                          ),
                                          showProgress
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 55,
                                                      height: 55,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            value:
                                                                (percentProgress /
                                                                        100)
                                                                    .toDouble(),
                                                            valueColor:
                                                                const AlwaysStoppedAnimation(
                                                                    primaryColor),
                                                            strokeWidth: 5,
                                                            backgroundColor:
                                                                Colors.grey,
                                                          ),
                                                          Center(
                                                              child:
                                                                  buildProgress()),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      "Uploading..",
                                                      style: TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
        previousType == "0" || showProgress
            ? Positioned(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          buttonColor: primaryLightColor,
                          buttonText: "SUBMIT TASK",
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Positioned(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:  (!buttonLoaderStatus)
                            ? ButtonWidget(
                          buttonText: "SUBMIT TASK",
                          onPressed: () {
                            if (selectedImage == null) {
                              Fluttertoast.showToast(
                                  msg: "Please select a image");
                            } else {
                              uploadData(selectedImage!, imageName);
                              //  saveTaskDetails(selectedImage!, imageName);
                            }
                          },
                        ):const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  //<----- for update second task data first time

  // for get second task data after submit task----->>>>
  Widget taskTwoGetWidgets() {
    return Stack(
      children: [
        SizedBox(
          child: ClipPath(
            clipper: OvalClipper(),
            child: Container(
              width: double.infinity,
              height: 242.0,
              color: secondaryColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openMyPage(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                  child: Image.asset(
                    'assets/icons/back.png',
                    width: 23.0,
                    height: 23.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Task 2: ${widget.taskData.taskName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 80.0),
                  padding: const EdgeInsets.all(16.0),
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
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/interests.png',
                                    width: 20.01,
                                    height: 25.87,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    taskDetailsModel.taskDetail![0].title!,
                                    style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5.0),
                                    child: Image.asset(
                                      'assets/icons/right-arrow.png',
                                      width: 22.0,
                                      height: 12.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      taskDetailsModel
                                          .taskDetail![0].description!,
                                      style: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/icons/upload.png',
                                    width: 20.0,
                                    height: 21.0,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        taskDetailsModel.taskDetail![1].title!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullImageViewScreen(
                                                          url: taskDetailsModel
                                                              .taskDetail![1]
                                                              .description!,
                                                        )),
                                              );
                                            },
                                            child: isApiCalled
                                                ? Shimmer.fromColors(
                                                    baseColor:
                                                        const Color.fromRGBO(
                                                            191,
                                                            191,
                                                            191,
                                                            0.5254901960784314),
                                                    highlightColor:
                                                        Colors.white,
                                                    child: Container(
                                                      width: 85.0,
                                                      height: 85.0,
                                                      color: Colors.grey,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width: 85.0,
                                                    height: 85.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  12)),
                                                      child: Image.network(
                                                        taskDetailsModel
                                                            .taskDetail![1]
                                                            .description!,
                                                        fit: BoxFit.cover,
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent?
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Shimmer
                                                              .fromColors(
                                                            baseColor: const Color
                                                                    .fromRGBO(
                                                                191,
                                                                191,
                                                                191,
                                                                0.5254901960784314),
                                                            highlightColor:
                                                                Colors.white,
                                                            child: Container(
                                                              width: 41.0,
                                                              height: 41.0,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          taskStatusWidgets(taskStatus)
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
        nextTaskButton()
      ],
    );
  }

  //<----- for get second task data after submit task

  // for get second task data after submit task----->>>>
  Widget taskTwoRejectWidgets() {
    return Stack(
      children: [
        SizedBox(
          child: ClipPath(
            clipper: OvalClipper(),
            child: Container(
              width: double.infinity,
              height: 242.0,
              color: secondaryColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openMyPage(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                  child: Image.asset(
                    'assets/icons/back.png',
                    width: 23.0,
                    height: 23.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Task 2: ${widget.taskData.taskName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 80.0),
                  padding: const EdgeInsets.all(16.0),
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
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/interests.png',
                                    width: 20.01,
                                    height: 25.87,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    taskDetailsModel.taskDetail![0].title!,
                                    style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5.0),
                                    child: Image.asset(
                                      'assets/icons/right-arrow.png',
                                      width: 22.0,
                                      height: 12.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      taskDetailsModel
                                          .taskDetail![0].description!,
                                      style: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/icons/upload.png',
                                    width: 20.0,
                                    height: 21.0,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        taskDetailsModel.taskDetail![1].title!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullImageViewScreen(
                                                          url: taskDetailsModel
                                                              .taskDetail![1]
                                                              .description!,
                                                        )),
                                              );
                                            },
                                            child: isApiCalled
                                                ? Shimmer.fromColors(
                                                    baseColor:
                                                        const Color.fromRGBO(
                                                            191,
                                                            191,
                                                            191,
                                                            0.5254901960784314),
                                                    highlightColor:
                                                        Colors.white,
                                                    child: Container(
                                                      width: 85.0,
                                                      height: 85.0,
                                                      color: Colors.grey,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width: 85.0,
                                                    height: 85.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  12)),
                                                      child: Image.network(
                                                        taskDetailsModel
                                                            .taskDetail![1]
                                                            .description!,
                                                        fit: BoxFit.cover,
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent?
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Shimmer
                                                              .fromColors(
                                                            baseColor: const Color
                                                                    .fromRGBO(
                                                                191,
                                                                191,
                                                                191,
                                                                0.5254901960784314),
                                                            highlightColor:
                                                                Colors.white,
                                                            child: Container(
                                                              width: 41.0,
                                                              height: 41.0,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          taskStatusWidgets(taskStatus)
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 20.0,
                                    height: 21.0,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              chooseImage();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                selectedImage == null
                                                    ? DottedBorder(
                                                        dashPattern: const [
                                                          6,
                                                          4
                                                        ],
                                                        color: thirdColor,
                                                        borderType:
                                                            BorderType.RRect,
                                                        radius: const Radius
                                                            .circular(10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          child: SizedBox(
                                                            height: 85.0,
                                                            width: 85.0,
                                                            child: Center(
                                                              child:
                                                                  Image.asset(
                                                                'assets/icons/plus.png',
                                                                width: 20.0,
                                                                height: 20.0,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: 85.0,
                                                        height: 85.0,
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            image: DecorationImage(
                                                                fit:
                                                                    BoxFit.fill,
                                                                image: FileImage(
                                                                    selectedImage!)))),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 18,
                                          ),
                                          showProgress
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 55,
                                                      height: 55,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            value:
                                                                (percentProgress /
                                                                        100)
                                                                    .toDouble(),
                                                            valueColor:
                                                                const AlwaysStoppedAnimation(
                                                                    primaryColor),
                                                            strokeWidth: 5,
                                                            backgroundColor:
                                                                Colors.grey,
                                                          ),
                                                          Center(
                                                              child:
                                                                  buildProgress()),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      "Uploading..",
                                                      style: TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
        showProgress
            ? Positioned(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          buttonColor: primaryLightColor,
                          buttonText: "SUBMIT TASK",
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Positioned(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:  (!buttonLoaderStatus)
                            ? ButtonWidget(
                          buttonText: "SUBMIT TASK",
                          onPressed: () {
                            if (selectedImage == null) {
                              Fluttertoast.showToast(
                                  msg: "Please select a image");
                            } else {
                              uploadData(selectedImage!, imageName);
                              //  saveTaskDetails(selectedImage!, imageName);
                            }
                          },
                        ):const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              )
      ],
    );
  }

  //<----- for get second task data after submit task

  Widget elseWidgets() {
    return Stack(
      children: [
        SizedBox(
          child: ClipPath(
            clipper: OvalClipper(),
            child: Container(
              width: double.infinity,
              height: 242.0,
              color: secondaryColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openMyPage(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                  child: Image.asset(
                    'assets/icons/back.png',
                    width: 23.0,
                    height: 23.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Task 2: ${widget.taskData.taskName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 80.0),
                  padding: const EdgeInsets.all(16.0),
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
                      : const Center(
                          child: Text(
                            "Coming Soon",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          bottom: 24.0,
          left: 16.0,
          right: 16.0,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:ButtonWidget(
                    buttonColor: primaryLightColor,
                    buttonText: "SUBMIT TASK",
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget nextTaskButton() {
    if (taskStatus == "1") {
      if (widget.isLastIndex) {
        return Positioned(
          bottom: 24.0,
          left: 16.0,
          right: 16.0,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:ButtonWidget(
                    buttonColor: primaryLightColor,
                    buttonText: "GO TO HOME",
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Positioned(
          bottom: 24.0,
          left: 16.0,
          right: 16.0,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:ButtonWidget(
                    buttonColor: primaryLightColor,
                    buttonText: "NEXT TASK",
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else if (taskStatus == "2") {
      if (widget.isLastIndex) {
        // for go to home
        return Positioned(
          bottom: 24.0,
          left: 16.0,
          right: 16.0,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:  (!buttonLoaderStatus)
                      ? ButtonWidget(
                    buttonText: "GO TO HOME",
                    onPressed: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => const MainScreen(
                            index: 1,
                          ),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    },
                  ):const SpinKitLoader(),
                ),
              ],
            ),
          ),
        );
      } else {
        // for go back to task list to view other  task
        return Positioned(
          bottom: 24.0,
          left: 16.0,
          right: 16.0,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ButtonWidget(
                    buttonText: "NEXT TASK",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }

  Widget taskStatusWidgets(String status) {
    switch (status) {
      case "1":
        return Center(
          child: Material(
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
                    "Pending Approval",
                    style: TextStyle(
                        color: pdDarkColor,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
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
                "Task Approved",
                style: TextStyle(
                    color: completedColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      case "3":
        if (taskDetailsModel.rejectType == 1) {
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    showRejectCampaignDialog(taskDetailsModel.remarkMsg!,taskDetailsModel.resubmitreason.toString),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
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
                  Image.asset(
                    "assets/icons/info.png",
                    width: 15.0,
                    height: 15.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          );
        } else {
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    showRejectCampaignDialog(taskDetailsModel.remarkMsg!,taskDetailsModel.resubmitreason.toString),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
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
                  Image.asset(
                    "assets/icons/info.png",
                    width: 15.0,
                    height: 15.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          );
        }
      default:
        return const SizedBox();
    }
  }

  Widget showRejectCampaignDialog(String remarkMsg,remarkMsgNew) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      child: CustomDialog(
        Child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 18.0, 10.0, 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reason:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    remarkMsg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                  ),


                  const SizedBox(
                    height: 10.0,
                  ),
                  (taskDetailsModel.resubmitreason.toString()!="")?const Text(
                    "Resubmission Reason:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700),
                  ):Container(),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    (taskDetailsModel.resubmitreason.toString()!="")?remarkMsgNew:"",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                  ),


                  const SizedBox(
                    height: 18.0,
                  ),
                  ButtonWidget(
                      buttonText: "Try Again",
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgress() {
    if (percentProgress == 100) {
      return const Icon(
        Icons.done,
        color: primaryColor,
        size: 35,
      );
    } else {
      return Text(
        "${percentProgress.toString()}%",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: secondaryColor,
          fontSize: 20,
        ),
      );
    }
  }
}
