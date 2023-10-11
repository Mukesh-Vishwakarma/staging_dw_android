import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:revuer/widgets/spin_kit_loader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/task_details_model.dart';
import '../../networking/models/task_list_model.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom-dialog.dart';
import '../main/main.dart';

class SurveyTaskDetails extends StatefulWidget {
  final TaskData taskData;
  final bool isLastIndex;

  const SurveyTaskDetails(
      {Key? key, required this.taskData, required this.isLastIndex})
      : super(key: key);

  @override
  State<SurveyTaskDetails> createState() => _SurveyTaskDetailsState();
}

class _SurveyTaskDetailsState extends State<SurveyTaskDetails> {
  double statusBarHeight = 5.0;
  var buttonLoaderStatus = false;
  var ratingNumber = "0";

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
  final urlRegExp = RegExp(
      r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?');

  final TextEditingController taskFirstGetController = TextEditingController();
  final TextEditingController taskFirstUpdateController =
      TextEditingController();

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

            if (widget.taskData.taskType == 1) {
              taskFirstGetController.text =
                  taskDetailsModel.taskDetail![1].description!;
            }
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
        setState(() {
          buttonLoaderStatus = false;
        });
      });
    } else {
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
    }
  }

  String? progress;
  int percentProgress = 0;
  Dio dio = Dio();
  bool showProgress = false;

  bool isChecked = false;

  uploadData(File file, String fileName) async {
    setState(() {
      buttonLoaderStatus = true;
    });
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      String uploadUrl = "${Strings.baseUrl}api/save-task";
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename: fileName),
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
        if (kDebugMode) {
          print("response error..");
        }
        Fluttertoast.showToast(msg: "Something went wrong..");
        setState(() {
          buttonLoaderStatus = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
    }
  }

  //text uplaod
  saveTextTaskDetails(String imageName) async {
    setState(() {
      isApiCalled = true;
      buttonLoaderStatus = true;
    });
    var revuerToekn =
        await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken);
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveTextTask(widget.taskData.taskToken!, revuerToekn!, imageName,ratingNumber)
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
        setState(() {
          buttonLoaderStatus = false;
        });
      });
    } else {
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
    }
  }

  int progressDown = 0;
  final ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    ///Looking up for a send port
    SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");
    //print("down progress $progress");
    ///ssending the data
    sendPort!.send([id, status, progress]);
  }

  @override
  void initState() {
    getTaskDetails();
    super.initState();

    ///register a send port for the other isolates
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");

    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      setState(() {
        progressDown = message[2];
        if (progressDown <= 1) {
          Fluttertoast.showToast(msg: "Downloading started..");
        }
        if (progressDown == 100) {
          Fluttertoast.showToast(msg: "File Downloaded Successfully..");
        }
        if (kDebugMode) {
          print("down progress $progressDown");
        }
      });
    });

    FlutterDownloader.registerCallback(downloadingCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping("downloading");
    super.dispose();
  }

  String random() {
    var rndNumber = "";
    var rnd = Random();
    for (var i = 0; i < 5; i++) {
      rndNumber = rndNumber + rnd.nextInt(9).toString();
    }
    if (kDebugMode) {
      print(rndNumber);
    }
    return rndNumber;
  }

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

  // for pick file from phone------->>
  File? selectedFile;
  String fileName = "";

  Future<void> chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.first.name;
      });
    } else {}
  }

  // <<------ for pick file from phone

  /* saveTaskDetails(File image, String imageName) async {
    setState(() {
      isApiCalled = true;
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
    print("reqparam ${map.toString()}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveTask(image, widget.taskData.taskToken!, revuerToekn!)
          .then((it) {
        print("responseSucces save task outer$it");
        if (it["status"] == "SUCCESS") {
          print("responseSucces save task inner $it");
          setState(() {
            isApiCalled = false;
            getTaskDetails();
          });
          Fluttertoast.showToast(msg: it["message"].toString());
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure save task$it");
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption save task ${obj}");
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("status ${res?.statusCode}");
            print("status ${res?.statusMessage}");
            print("status ${res?.data}");
            break;
          default:
            break;
        }
      });
    } else {
      Fluttertoast.showToast(msg: "No Internet Available");
    }
  }*/

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
        return taskFirstGetWidgets();
      } else if (taskStatus == "3") {
        return taskFirstRejectWidgets();
      } else {
        return taskFirstUpdateWidgets();
      }
    } else {
      return elseWidgets();
    }
  }

  // for update First task data first time ----->>>>
  Widget taskFirstUpdateWidgets() {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      return primaryColor;
    }

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
                              // s.split(",")[0] != ""
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[0] !=
                                      ""
                                  ? InkWell(
                                      onTap: () async {
                                        int length = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")
                                            .length;

                                        String name = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")[length - 1]
                                            .toString();
                                        setState(() {
                                          progressDown = 0;
                                        });
                                        final status =
                                            await Permission.storage.request();

                                        if (status.isGranted) {
                                          final externalDir =
                                              await getExternalStorageDirectory();

                                          String url = taskDetailsModel
                                              .taskDetail![0].description!
                                              .split(",")[0]
                                              .toString();
                                          if (kDebugMode) {
                                            print("message $externalDir");
                                          }

                                          final id = await FlutterDownloader.enqueue(
                                                  url: taskDetailsModel
                                                      .taskDetail![0]
                                                      .description!
                                                      .split(",")[0],
                                                  savedDir:
                                                      "/storage/emulated/0/Download",
                                                  fileName:
                                                      "${name.split(".")[0]}${random()}.${url.split(".").last.toString()}",
                                                  showNotification: true,
                                                  openFileFromNotification:
                                                      true,
                                                  saveInPublicStorage: true)
                                              .then((value) {
                                            if (kDebugMode) {
                                              print("completed $value");
                                            }
                                          });
                                        } else {
                                          if (kDebugMode) {
                                            print("Permission denied");
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Image.asset(
                                              "assets/icons/download.png",
                                              width: 32.0,
                                              height: 32.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              // s.split(",")[0],
                                              "Download form",
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0.0,
                                    ),

                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[1] !=
                                      ""
                                  ? InkWell(
                                      onTap: () {
                                        browseInternet(taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[1]);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Image.asset(
                                              'assets/images/browser.png',
                                              width: 30.0,
                                              height: 30.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              "Open form link"
                                              /*taskDetailsModel
                                                  .taskDetail![0].description!
                                                  .split(",")[1]*/
                                              ,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0.0,
                                    ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[0] !=
                                      ""
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                        Expanded(
                                          child: Column(
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
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  chooseFile();
                                                },
                                                child: selectedFile == null
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
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5.0),
                                                            child: Image.asset(
                                                              "assets/icons/doc.png",
                                                              width: 22.0,
                                                              height: 22.0,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10.0,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              fileName,
                                                              style: const TextStyle(
                                                                  color:
                                                                      secondaryColor,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                              ),
                                              const SizedBox(
                                                width: 25,
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              showProgress
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 55,
                                                          height: 55,
                                                          child: Stack(
                                                            fit:
                                                                StackFit.expand,
                                                            children: [
                                                              CircularProgressIndicator(
                                                                value: (percentProgress /
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
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/icons/link.png',
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
                                                  .taskDetail![1].title!,
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
                                                SizedBox(
                                                  width: 25.0,
                                                  height: 25.0,
                                                  child: Checkbox(
                                                    checkColor: Colors.white,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                getColor),
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4.0))),
                                                    value: isChecked,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        isChecked = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isChecked = !isChecked;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: const [
                                                      SizedBox(
                                                        width: 4.0,
                                                      ),
                                                      Text(
                                                        'I have filled the form',
                                                        style: TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
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
        previousType == "0" || isApiCalled || showProgress
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
                        child: (!buttonLoaderStatus)
                            ? ButtonWidget(
                          buttonText: "SUBMIT TASK",
                          onPressed: () {
                            if (taskDetailsModel.taskDetail![0].description!
                                    .split(",")[0] !=
                                "") {
                              if (selectedFile == null) {
                                Fluttertoast.showToast(
                                    msg: "Please select a filled form");
                              } else {
                                uploadData(selectedFile!, fileName);
                              }
                            } else {
                              if (isChecked == false) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Please check the box after fill the form");
                              } else {
                                saveTextTaskDetails("1");
                              }
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

  // for get First task data after submit task----->>>>
  Widget taskFirstGetWidgets() {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      return primaryColor;
    }

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
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[0] !=
                                      ""
                                  ? InkWell(
                                      onTap: () async {
                                        int length = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")
                                            .length;

                                        String name = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")[length - 1]
                                            .toString();
                                        setState(() {
                                          progressDown = 0;
                                        });
                                        final status =
                                            await Permission.storage.request();

                                        if (status.isGranted) {
                                          final externalDir =
                                              await getExternalStorageDirectory();

                                          String url = taskDetailsModel
                                              .taskDetail![0].description!
                                              .split(",")[0]
                                              .toString();
                                          if (kDebugMode) {
                                            print("message $externalDir");
                                          }

                                          final id = await FlutterDownloader.enqueue(
                                                  url: taskDetailsModel
                                                      .taskDetail![0]
                                                      .description!
                                                      .split(",")[0],
                                                  savedDir:
                                                      "/storage/emulated/0/Download",
                                                  fileName:
                                                      "${name.split(".")[0]}${random()}.${url.split(".").last.toString()}",
                                                  showNotification: true,
                                                  openFileFromNotification:
                                                      true,
                                                  saveInPublicStorage: true)
                                              .then((value) {
                                            if (kDebugMode) {
                                              print("completed $value");
                                            }
                                          });
                                        } else {
                                          if (kDebugMode) {
                                            print("Permission denied");
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Image.asset(
                                              "assets/icons/download.png",
                                              width: 30.0,
                                              height: 30.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              // s.split(",")[0],
                                              "Download form"
                                              /*taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]*/
                                              ,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0.0,
                                    ),
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[1] !=
                                      ""
                                  ? InkWell(
                                      onTap: () {
                                        browseInternet(taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[1]);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Image.asset(
                                              'assets/images/browser.png',
                                              width: 30.0,
                                              height: 30.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              // s.split(",")[1],
                                              "Open form link"
                                              /* taskDetailsModel
                                                  .taskDetail![0].description!
                                                  .split(",")[1]*/
                                              ,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0.0,
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
                                    ],
                                  ),
                                ],
                              ),
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[0] !=
                                      ""
                                  ? InkWell(
                                      onTap: () async {
                                        int length = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")
                                            .length;

                                        String name = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")[length - 1]
                                            .toString();
                                        setState(() {
                                          progressDown = 0;
                                        });
                                        final status =
                                            await Permission.storage.request();

                                        if (status.isGranted) {
                                          final externalDir =
                                              await getExternalStorageDirectory();

                                          String url = taskDetailsModel
                                              .taskDetail![1].description!;
                                          if (kDebugMode) {
                                            print("message $externalDir");
                                          }

                                          final id = await FlutterDownloader.enqueue(
                                                  url: url,
                                                  savedDir:
                                                      "/storage/emulated/0/Download",
                                                  fileName:
                                                      "${name.split(".")[0]}${random()}.${url.split(".").last.toString()}",
                                                  showNotification: true,
                                                  openFileFromNotification:
                                                      true,
                                                  saveInPublicStorage: true)
                                              .then((value) {
                                            if (kDebugMode) {
                                              print("completed $value");
                                            }
                                          });
                                        } else {
                                          if (kDebugMode) {
                                            print("Permission denied");
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Image.asset(
                                              "assets/icons/download.png",
                                              width: 32.0,
                                              height: 32.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              // s.split(",")[0],
                                              "Submitted form"
                                              /*taskDetailsModel
                                                  .taskDetail![1].description!*/
                                              ,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 25.0,
                                                  height: 25.0,
                                                  child: Checkbox(
                                                    checkColor: Colors.white,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                getColor),
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4.0))),
                                                    value: true,
                                                    onChanged: (bool? value) {
                                                      /*setState(() {
                                                  isChecked = value!;
                                                });*/
                                                    },
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    /* setState(() {
                                                isChecked = !isChecked;
                                              });*/
                                                  },
                                                  child: Row(
                                                    children: const [
                                                      SizedBox(
                                                        width: 4.0,
                                                      ),
                                                      Text(
                                                        'I have filled the form',
                                                        style: TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              taskStatusWidgets(taskStatus)
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

  // for get First task data after submit task----->>>>
  Widget taskFirstRejectWidgets() {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      return primaryColor;
    }

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
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[0] !=
                                      ""
                                  ? InkWell(
                                      onTap: () async {
                                        int length = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")
                                            .length;

                                        String name = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")[length - 1]
                                            .toString();
                                        setState(() {
                                          progressDown = 0;
                                        });
                                        final status =
                                            await Permission.storage.request();

                                        if (status.isGranted) {
                                          final externalDir =
                                              await getExternalStorageDirectory();

                                          String url = taskDetailsModel
                                              .taskDetail![0].description!
                                              .split(",")[0]
                                              .toString();
                                          if (kDebugMode) {
                                            print("message $externalDir");
                                          }

                                          final id = await FlutterDownloader.enqueue(
                                                  url: taskDetailsModel
                                                      .taskDetail![0]
                                                      .description!
                                                      .split(",")[0],
                                                  savedDir:
                                                      "/storage/emulated/0/Download",
                                                  fileName:
                                                      "${name.split(".")[0]}${random()}.${url.split(".").last.toString()}",
                                                  showNotification: true,
                                                  openFileFromNotification:
                                                      true,
                                                  saveInPublicStorage: true)
                                              .then((value) {
                                            if (kDebugMode) {
                                              print("completed $value");
                                            }
                                          });
                                        } else {
                                          if (kDebugMode) {
                                            print("Permission denied");
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Image.asset(
                                              "assets/icons/download.png",
                                              width: 30.0,
                                              height: 30.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              "Download Form"
                                              // s.split(",")[0],
                                              /*taskDetailsModel
                                                  .taskDetail![0].description!
                                                  .split(",")[0]*/
                                              ,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0.0,
                                    ),
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[1] !=
                                      ""
                                  ? InkWell(
                                      onTap: () {
                                        browseInternet(taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[1]);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Image.asset(
                                              'assets/images/browser.png',
                                              width: 30.0,
                                              height: 30.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              "Open form link"
                                              // s.split(",")[1],
                                              /*taskDetailsModel
                                                  .taskDetail![0].description!
                                                  .split(",")[1]*/
                                              ,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0.0,
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
                                    ],
                                  ),
                                ],
                              ),
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[0] !=
                                      ""
                                  ? InkWell(
                                      onTap: () async {
                                        int length = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")
                                            .length;

                                        String name = taskDetailsModel
                                            .taskDetail![0].description!
                                            .split(",")[0]
                                            .split("/")[length - 1]
                                            .toString();
                                        setState(() {
                                          progressDown = 0;
                                        });
                                        final status =
                                            await Permission.storage.request();

                                        if (status.isGranted) {
                                          final externalDir =
                                              await getExternalStorageDirectory();

                                          String url = taskDetailsModel
                                              .taskDetail![1].description!;
                                          if (kDebugMode) {
                                            print("message $externalDir");
                                          }

                                          final id = await FlutterDownloader.enqueue(
                                                  url: url,
                                                  savedDir:
                                                      "/storage/emulated/0/Download",
                                                  fileName:
                                                      "${name.split(".")[0]}${random()}.${url.split(".").last.toString()}",
                                                  showNotification: true,
                                                  openFileFromNotification:
                                                      true,
                                                  saveInPublicStorage: true)
                                              .then((value) {
                                            if (kDebugMode) {
                                              print("completed $value");
                                            }
                                          });
                                        } else {
                                          if (kDebugMode) {
                                            print("Permission denied");
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Image.asset(
                                              "assets/icons/download.png",
                                              width: 30.0,
                                              height: 30.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              "Submitted form"
                                              // s.split(",")[0],
                                              /*taskDetailsModel
                                                  .taskDetail![1].description!*/
                                              ,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 25.0,
                                                  height: 25.0,
                                                  child: Checkbox(
                                                    checkColor: Colors.white,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                getColor),
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4.0))),
                                                    value: isChecked,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        isChecked = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isChecked = !isChecked;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: const [
                                                      SizedBox(
                                                        width: 4.0,
                                                      ),
                                                      Text(
                                                        'I have filled the form',
                                                        style: TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              taskStatusWidgets(taskStatus),
                              const SizedBox(
                                height: 20.0,
                              ),
                              taskDetailsModel.taskDetail![0].description!
                                          .split(",")[0] !=
                                      ""
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  chooseFile();
                                                },
                                                child: selectedFile == null
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
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5.0),
                                                            child: Image.asset(
                                                              "assets/icons/doc.png",
                                                              width: 22.0,
                                                              height: 22.0,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10.0,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              fileName,
                                                              style: const TextStyle(
                                                                  color:
                                                                      secondaryColor,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                              ),
                                              const SizedBox(
                                                width: 25,
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              showProgress
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 55,
                                                          height: 55,
                                                          child: Stack(
                                                            fit:
                                                                StackFit.expand,
                                                            children: [
                                                              CircularProgressIndicator(
                                                                value: (percentProgress /
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
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
        isApiCalled
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
                        child: (!buttonLoaderStatus)
                            ? ButtonWidget(
                          buttonText: "SUBMIT TASK",
                          onPressed: () {
                            if (taskDetailsModel.taskDetail![0].description!
                                    .split(",")[0] !=
                                "") {
                              if (selectedFile == null) {
                                Fluttertoast.showToast(
                                    msg: "Please select a filled form");
                              } else {
                                uploadData(selectedFile!, fileName);
                              }
                            } else {
                              if (isChecked == false) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Please check the box after fill the form");
                              } else {
                                saveTextTaskDetails("1");
                              }
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
                  child: ButtonWidget(
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
                  child: ButtonWidget(
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
                  child: ButtonWidget(
                    buttonText: "GO TO HOME",
                    onPressed: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => MainScreen(
                            index: 1,
                          ),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                      /*Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/main'),
                          builder: (context) => MainScreen(index: 1),
                        ),
                      );*/
                    },
                  ),
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
                  "Pending Approval",
                  style: TextStyle(
                      color: pdDarkColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ],
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
