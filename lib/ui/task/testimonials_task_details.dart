import 'dart:convert';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
import '../../widgets/label_widget.dart';
import '../../widgets/spin_kit_loader.dart';
import '../main/main.dart';
import 'fullimage_view_screen.dart';
import 'network_video_play_screen.dart';

class TestimonialsTaskDetails extends StatefulWidget {
  final TaskData taskData;
  final bool isLastIndex;

  const TestimonialsTaskDetails(
      {Key? key, required this.taskData, required this.isLastIndex})
      : super(key: key);

  @override
  State<TestimonialsTaskDetails> createState() =>
      _TestimonialsTaskDetailsState();
}

class _TestimonialsTaskDetailsState extends State<TestimonialsTaskDetails> {
  // List<Asset> images = [];
  // List<File> images = [];

  var buttonLoaderStatus = false;

  List<File> selectedImages = [];
  List<String> base64Images = [];
  List<String> imageNames = [];

  double statusBarHeight = 5.0;

  void _openMyPage() {
    Navigator.of(context).pop();
  }

  String previousType = "0";
  bool isApiCalled = false;
  String taskStatus = "";
  String taskRejectType = "";
  String taskType = "";
  TaskDetailsModel taskDetailsModel = TaskDetailsModel();
  TaskListModel taskListModel = TaskListModel();

  getTaskDetails() async {
    print("eajhsfbdcjhbsx=>${widget.taskData.taskType}");
    setState(() {
      isApiCalled = true;
      // buttonLoaderStatus = true;
    });
    Map<String, dynamic> body = {
      "task_token": widget.taskData.taskToken,
      "campaign_token": widget.taskData.campaignToken,
      "previous_status": widget.taskData.previousStatus,
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken)
    };
    if (kDebugMode) {
      print("reqparamdkjfh==> ${body.toString()}");
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

          print("responseSuccess get task==> ${taskDetailsModel.resubmitreason}");

          setState(() {
            previousType = taskDetailsModel.previousType!;
            taskStatus = taskDetailsModel.revuerTaskStatus!;
            taskRejectType = taskDetailsModel.rejectType!.toString();
            taskType = taskDetailsModel.revuerTaskStatus!;
            if (widget.taskData.taskType == 4) {
              if (taskStatus != "") {
                textUrlController.text =
                    taskDetailsModel.taskDetail![3].description!;
                if (taskDetailsModel.taskDetail![2].description! != "") {
                  generateNetworkThumbnail(
                      taskDetailsModel.taskDetail![2].description!);
                }
              }
            }
            if (widget.taskData.taskType == 3) {
              textController.text =
                  taskDetailsModel.taskDetail![1].description!;
              if (taskStatus != "") {
                if (taskDetailsModel.taskDetail![1].description! != "") {
                  generateNetworkThumbnail(
                      taskDetailsModel.taskDetail![1].description!);
                }
              }
            }
          });

          print("asmdvcbjsdfjkh===> ${previousType}");

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
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
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
          print("responseSucces save task outer$it");
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

  uploadData(File file, String imageName) async {
    bool isOnline = await ApiClient.hasNetwork();

    print("sjdfbjkasdhjzndjx==>${file.path}");
    print("sjdfbjkasdhjzndjx==> ${imageName}");

    setState(() {
      buttonLoaderStatus = true;
    });

    if (isOnline) {
      String uploadUrl = "${Strings.baseUrl}api/save-task";
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename: imageName),
        "task_token": widget.taskData.taskToken,
        "revuer_token":
            await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
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
            thumbnailUrl = null;
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
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
    }
  }

  uploadDataMultipleImage(List<File> resultList) async {
    bool isOnline = await ApiClient.hasNetwork();
    setState(() {
      buttonLoaderStatus = true;
    });
    if (isOnline) {
      String uploadUrl = "${Strings.baseUrl}api/save-task";
      List<MultipartFile> imageFiles = [];

      for (File asset in resultList) {
        final imageFile = await MultipartFile.fromFile(
          asset.path,
          filename: asset.path.split('/').last,
        );
        imageFiles.add(imageFile);
      }

      FormData formData = FormData.fromMap({
        "image": imageFiles,
        "task_token": widget.taskData.taskToken,
        "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken,
        ),
      });

      // formData.files("image": imageFiles,);

      // Print the formData
      print("FormData: ${formData.fields}");

      var response = await dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          String percentage = (sent / total * 100).toStringAsFixed(0);
          setState(() {
            showProgress = true;
            progress = "$sent Bytes of $total Bytes - $percentage % uploaded";
            percentProgress = int.parse(percentage);
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
            thumbnailUrl = null;
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
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
    }
  }

  uploadImageWithUrl(File file, String imageName, String url) async {
    setState(() {
      buttonLoaderStatus = true;
    });
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      if (kDebugMode) {
        print("uploadImageWithUrl file:- $file image:- $imageName url:- $url");
      }
      String uploadUrl = "${Strings.baseUrl}api/save-task";
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename: imageName),
        "task_token": widget.taskData.taskToken,
        "revuer_token":
            await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
        "task_desc": url.isEmpty ? " " : url
      });
      if (kDebugMode) {
        print("form data ${formData.fields}");
      }
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
            thumbnailUrl = null;
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
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
    }
  }

  uploadText(String text, String ratingNumber) async {
    setState(() {
      isApiCalled = true;
      buttonLoaderStatus = true;
    });
    var revuerToekn =
        await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken);
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveTextTask(
              widget.taskData.taskToken!, revuerToekn!, text, ratingNumber)
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
        Fluttertoast.showToast(msg: "Something went wrong upload");
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
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
    }
  }

  final textController = TextEditingController();
  final textRejectController = TextEditingController();
  final textUrlController = TextEditingController();
  final textUrlRejectController = TextEditingController();
  final emojiRegex =
      '(\ud83c|[\udf00-\udfff]|\ud83d|[\udc00-\ude4f]|\ud83d|[\ude80-\udeff])';
  String ratingNumber = "0";

  uploadVideoText(
    File file,
    String text,
    String fileName,
  ) async {
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
        "task_desc": text
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
            thumbnailUrl = null;
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
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
    }
  }

  browseInternet(String url) async {
    try {
      if (kDebugMode) {
        print("url is:$url");
      }
      if (!await launchUrl(Uri.parse(url),
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

  uploadVideo(File file) async {
    setState(() {
      buttonLoaderStatus = true;
    });
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      String uploadUrl = "${Strings.baseUrl}api/save-task";
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename: ""),
        "task_token": widget.taskData.taskToken,
        "revuer_token":
            await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
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
      Fluttertoast.showToast(msg: "No Internet Available");
      setState(() {
        buttonLoaderStatus = false;
      });
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

  Future<void> chooseImageNew() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      // for (XFile image in images) {
      File selectedImage = File(image.path);
      selectedImages.add(selectedImage);

      String base64Image = base64Encode(selectedImage.readAsBytesSync());
      base64Images.add(base64Image);

      String imageName = selectedImage.path.split('/').last;
      imageNames.add(imageName);
      setState(() {});
      // }

      // setState(() {
      //   // Update the state variables with the selected images
      //   selectedImageFiles = selectedImages;
      //   base64ImageList = base64Images;
      //   imageNamesList = imageNames;
      // });

      // Print or handle the selected images as needed
      // print("Selected Images: $selectedImageFiles");
      // print("Base64 Images: $base64ImageList");
      // print("Image Names: $imageNamesList");
    }
  }

  // Future<void> chooseImageNew() async {
  //
  //   List<Asset> resultList = [];
  //   try {
  //     resultList = await MultiImagePicker.pickImages(
  //       maxImages: 3, // Maximum number of images to be selected
  //       enableCamera: true, // Allow camera capture alongside gallery selection
  //       selectedAssets: images, // Pre-selected images
  //     );
  //   } on Exception catch (e) {
  //     // Handle exception/error if any
  //     print(e.toString());
  //   }
  //   setState(() {
  //     images = resultList;
  //   });
  // }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // <<------ for pick image from gallery or camera...

  // pick video from gallery-------->>
  File? _video;
  String videoName = "";
  String? thumbnailFile;
  String? thumbnailUrl;

  pickVideo(int duration) async {
    var videoFile = (await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: duration),
    ));
    if (videoFile != null) {
      VideoPlayerController testLengthController =
          VideoPlayerController.file(File(videoFile.path)); //Your file here
      await testLengthController.initialize();
      if (testLengthController.value.duration.inSeconds > duration) {
        videoFile = null;
        Fluttertoast.showToast(
            msg: "Can't select video greater than $duration seconds");
        if (kDebugMode) {
          print("can not select video greater than 8 seconds");
        }
      } else {
        setState(() {
          _video = File(videoFile!.path);
          videoName = _video!.path.split('/').last;
          generateFileThumbnail(_video);
        });
      }
      testLengthController.dispose();
    }
  }

  pickNoLimitVideo() async {
    var videoFile = (await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    ));
    if (videoFile != null) {
      setState(() {
        _video = File(videoFile.path);
        videoName = _video!.path.split('/').last;
        generateFileThumbnail(_video);
      });
    }
  }

  // void generateNetworkThumbnail(String url) async {
  //   try {
  //     thumbnailUrl = await VideoThumbnail.thumbnailFile(
  //         video: url,
  //         thumbnailPath: (await getTemporaryDirectory()).path,
  //         imageFormat: ImageFormat.WEBP);
  //     setState(() {});
  //   } catch (e) {}
  // }
  //
  // void generateFileThumbnail(File? video) async {
  //   thumbnailFile = await VideoThumbnail.thumbnailFile(
  //       video: video!.path,
  //       thumbnailPath: (await getTemporaryDirectory()).path,
  //       imageFormat: ImageFormat.PNG);
  //   setState(() {});
  // }

  void generateNetworkThumbnail(String url) async {
    try {
      if (isValidUrl(url)) {
        thumbnailUrl = await VideoThumbnail.thumbnailFile(
            video: url,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.WEBP);
        setState(() {});
      }
    } catch (e) {}
  }

  bool isValidUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }

  void generateFileThumbnail(File? video) async {
    try {
      thumbnailFile = await VideoThumbnail.thumbnailFile(
          video: video!.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG);

      setState(() {});
    } catch (e) {}
  }

  // <<<---------

  @override
  void dispose() {
    if (kDebugMode) {
      print("dispose called video selecting");
    }
    super.dispose();
  }

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
    print("djhfbjkasnd===> ${widget.taskData.taskType}");

    if (widget.taskData.taskType == 1) {
      if (taskStatus == "1" || taskStatus == "2") {
        return taskOneGetWidget();
      } else if (taskStatus == "3") {
        return taskOneRejectWidget();
      } else {
        return taskOneUpdateWidget();
      }
    } else if (widget.taskData.taskType == 2) {
      print("djhfbjkasnd===>2 = ${widget.taskData.taskType}");
      if (taskStatus == "1" || taskStatus == "2") {
        try {
          List<String> images = [];
          print(
              "djhfbjkasnd===> ${taskDetailsModel.taskDetail![1].description!}");
          if (taskDetailsModel.taskDetail![1].description!.toString() != "") {
            String str = taskDetailsModel.taskDetail![1].description!;
            print(
                "djhfbjkasnd===> ${taskDetailsModel.taskDetail![1].description!}");
            images = str.split(',');
          }
          return taskTwoGetWidgets(images);
        } catch (e) {}
      } else if (taskStatus == "3") {
        List<String> images = [];
        print(
            "djhfbjkasnd===> ${taskDetailsModel.taskDetail![1].description!}");
        if (taskDetailsModel.taskDetail![1].description!.toString() != "") {
          String str = taskDetailsModel.taskDetail![1].description!;
          print(
              "djhfbjkasnd===> ${taskDetailsModel.taskDetail![1].description!}");
          images = str.split(',');
        }

        return taskTwoRejectWidgets(images);
      } else {
        return taskTwoUpdateWidgets();
      }
    } else if (widget.taskData.taskType == 3) {
      print("ojhbjhbjkuygect=>  $taskStatus");
      print("ojhbjhbjkuygect=>  $taskRejectType");
      if (taskStatus == "1" || taskStatus == "2") {
        return taskThreeGetWidget(taskStatus, taskRejectType);
      } else if (taskStatus == "3") {
        return taskThreeRejectWidget(taskStatus, taskRejectType);
      } else if (taskStatus == "5") {
        return taskThreeRejectWidget(taskStatus, taskRejectType);
      } else if (taskStatus == "6" && taskRejectType == "2") {
        return taskThreeGetWidget(taskStatus, taskRejectType);
      } else if (taskStatus == "7") {
        return taskThreeRejectWidget(taskStatus, taskRejectType);
      } else {
        return taskThreeUpdateWidget();
      }
    } else if (widget.taskData.taskType == 4) {
      if (taskStatus == "1" || taskStatus == "2") {
        return taskFourGetWidget();
      } else if (taskStatus == "3") {
        return taskFourRejectWidget();
      } else {
        return taskFourUpdateWidget();
      }
    } else {
      return elseWidgets();
    }

    // Add a default return statement here
    return elseWidgets(); // Replace Container() with an appropriate default widget for your use case
  }

  // for update first task data first time ----->>>>
  Widget taskOneUpdateWidget() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                  width: double.infinity,
                  // height: 242.0,
                  color: secondaryColor,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        16.0, (statusBarHeight + 15.0), 16.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _openMyPage(),
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
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
                          height: 70.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 75.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    height: 40.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                taskDetailsModel.taskDetail![1]
                                                    .description!),
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
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                                BorderType
                                                                    .RRect,
                                                            radius: const Radius
                                                                .circular(10),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1.0),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          12)),
                                                              child: SizedBox(
                                                                height: 85.0,
                                                                width: 85.0,
                                                                child: Center(
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/icons/plus.png',
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
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
                ),
              ),
            )
          ],
        ),
        previousType == "0" || showProgress
            ? Positioned(
                bottom: 10.0,
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
                bottom: 10.0,
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
                                  if (selectedImage == null) {
                                    Fluttertoast.showToast(
                                        msg: "Please select a image");
                                  } else {
                                    uploadData(selectedImage!, imageName);
                                    //  saveTaskDetails(selectedImage!, imageName);
                                  }
                                },
                              )
                            : const SpinKitLoader(),
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
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                  width: double.infinity,
                  // height: 242.0,
                  color: secondaryColor,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        16.0, (statusBarHeight + 15.0), 16.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _openMyPage(),
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
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
                          height: 70.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    height: 40.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                taskDetailsModel.taskDetail![1]
                                                    .description!),
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
                                    height: 40.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                                  .taskDetail![
                                                                      2]
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
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                          child: Image.network(
                                                            taskDetailsModel
                                                                .taskDetail![2]
                                                                .description!,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              }
                                                              return Shimmer
                                                                  .fromColors(
                                                                baseColor: const Color
                                                                    .fromRGBO(
                                                                    191,
                                                                    191,
                                                                    191,
                                                                    0.5254901960784314),
                                                                highlightColor:
                                                                    Colors
                                                                        .white,
                                                                child:
                                                                    Container(
                                                                  width: 41.0,
                                                                  height: 41.0,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              taskStatusWidgets(
                                                  taskStatus, "", "")
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
                ),
              ),
            )
          ],
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
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                  width: double.infinity,
                  // height: 242.0,
                  color: secondaryColor,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        16.0, (statusBarHeight + 15.0), 16.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _openMyPage(),
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
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
                          height: 70.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                taskDetailsModel.taskDetail![1]
                                                    .description!),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                                  .taskDetail![
                                                                      2]
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
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                          child: Image.network(
                                                            taskDetailsModel
                                                                .taskDetail![2]
                                                                .description!,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
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
                                                                    Colors
                                                                        .white,
                                                                child:
                                                                    Container(
                                                                  width: 41.0,
                                                                  height: 41.0,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              taskStatusWidgets(
                                                  taskStatus, "", "")
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                                BorderType
                                                                    .RRect,
                                                            radius: const Radius
                                                                .circular(10),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1.0),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          12)),
                                                              child: SizedBox(
                                                                height: 85.0,
                                                                width: 85.0,
                                                                child: Center(
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/icons/plus.png',
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
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
                ),
              ),
            )
          ],
        ),
        isApiCalled || showProgress
            ? Positioned(
                bottom: 10.0,
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
                bottom: 10.0,
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
                                  if (selectedImage == null) {
                                    Fluttertoast.showToast(
                                        msg: "Please select a image");
                                  } else {
                                    uploadData(selectedImage!, imageName);
                                    //  saveTaskDetails(selectedImage!, imageName);
                                  }
                                },
                              )
                            : const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  //<----- for get first task data after submit task

  // for update second task data first time ----->>>>
  Widget taskTwoUpdateWidgets() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                    width: double.infinity,
                    // height: 242.0,
                    color: secondaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, (statusBarHeight + 15.0), 16.0, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _openMyPage(),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    2.0, 5.0, 7.0, 5.0),
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
                              height: 70.0,
                            ),
                          ]),
                    )),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10.0),
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
                                  height: 40.0,
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
                                              .taskDetail![1].title!,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                // chooseImage();
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  // selectedImage == null
                                                  // ? DottedBorder(
                                                  //     dashPattern: const [
                                                  //       6,
                                                  //       4
                                                  //     ],
                                                  //     color: thirdColor,
                                                  //     borderType:
                                                  //         BorderType.RRect,
                                                  //     radius: const Radius
                                                  //         .circular(10),
                                                  //     padding:
                                                  //         const EdgeInsets
                                                  //             .all(1.0),
                                                  //     child: ClipRRect(
                                                  //       borderRadius:
                                                  //           const BorderRadius
                                                  //                   .all(
                                                  //               Radius
                                                  //                   .circular(
                                                  //                       12)),
                                                  //       child: SizedBox(
                                                  //         height: 85.0,
                                                  //         width: 85.0,
                                                  //         child: Center(
                                                  //           child:
                                                  //               Image.asset(
                                                  //             'assets/icons/plus.png',
                                                  //             width: 20.0,
                                                  //             height: 20.0,
                                                  //             fit: BoxFit
                                                  //                 .contain,
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //     ),
                                                  //   )
                                                  // : Container(
                                                  //     width: 85.0,
                                                  //     height: 85.0,
                                                  //     decoration: BoxDecoration(
                                                  //         shape: BoxShape
                                                  //             .rectangle,
                                                  //         borderRadius:
                                                  //             BorderRadius
                                                  //                 .circular(
                                                  //                     12),
                                                  //         image: DecorationImage(
                                                  //             fit:
                                                  //                 BoxFit.fill,
                                                  //             image: FileImage(
                                                  //                 selectedImage!)))),

                                                  Visibility(
                                                    visible:
                                                        selectedImages.length !=
                                                            3,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // chooseImage();
                                                        chooseImageNew();
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(right: 10),
                                                        child: DottedBorder(
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
                                                                    .all(Radius
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
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 86,
                                                    child: Wrap(
                                                      spacing: 4.0,
                                                      children: List.generate(
                                                          selectedImages.length,
                                                          (index) {
                                                        File asset =
                                                            selectedImages[
                                                                index];
                                                        return Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Container(
                                                                width: 86,
                                                                height: 86,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.5),
                                                                      blurRadius:
                                                                          4.0,
                                                                      spreadRadius:
                                                                          2.0,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              0),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    child:
                                                                        // AssetThumb(
                                                                        //   asset: asset,
                                                                        //   width: 90,
                                                                        //   height: 100,
                                                                        // ),
                                                                        Image.file(
                                                                      asset,
                                                                      width: 90,
                                                                      height:
                                                                          100,
                                                                    )),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  removeImage(
                                                                      index);
                                                                },
                                                                child:
                                                                    Container(
                                                                  // margin: const EdgeInsets.all(3),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius: const BorderRadius
                                                                        .only(
                                                                        topRight:
                                                                            Radius.circular(
                                                                                5),
                                                                        bottomLeft:
                                                                            Radius.circular(8)),
                                                                    color:
                                                                        primaryColor,
                                                                    border: Border.all(
                                                                        color:
                                                                            primaryColor,
                                                                        width:
                                                                            1.5),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons.clear,
                                                                    size: 15,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 18,
                                            ),
                                            showProgress
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
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
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
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
                                                      ],
                                                    ),
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
                ),
              ),
            )
          ],
        ),
        // previousType == "1" || showProgress
        previousType == "0" || showProgress
            ? Positioned(
                bottom: 10.0,
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
                bottom: 10.0,
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
                                  if (selectedImages.isEmpty) {
                                    Fluttertoast.showToast(
                                        msg: "Please select a image");
                                  } else {
                                    // uploadData(selectedImage!, imageName);
                                    uploadDataMultipleImage(selectedImages);
                                    //  saveTaskDetails(selectedImage!, imageName);
                                  }
                                },
                              )
                            : const SpinKitLoader(),
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
  Widget taskTwoGetWidgets(List<String> images) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                    width: double.infinity,
                    // height: 242.0,
                    color: secondaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, (statusBarHeight + 15.0), 16.0, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _openMyPage(),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    2.0, 5.0, 7.0, 5.0),
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
                              height: 70.0,
                            ),
                          ]),
                    )),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10.0),
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
                                  height: 40.0,
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
                                              .taskDetail![1].title!,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                // Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //       builder: (context) =>
                                                //           FullImageViewScreen(
                                                //             url: taskDetailsModel
                                                //                 .taskDetail![1]
                                                //                 .description!,
                                                //           )),
                                                // );
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
                                                      height: 86,
                                                      child: Wrap(
                                                        spacing: 4.0,
                                                        children: List.generate(
                                                            images.length,
                                                            (index) {
                                                          String url =
                                                              images[index];
                                                          return InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            FullImageViewScreen(
                                                                              url: url,
                                                                            )),
                                                              );
                                                            },
                                                            child: SizedBox(
                                                                width: 85.0,
                                                                height: 85.0,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              12)),
                                                                  child: Image
                                                                      .network(
                                                                    url,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    loadingBuilder: (BuildContext
                                                                            context,
                                                                        Widget
                                                                            child,
                                                                        ImageChunkEvent?
                                                                            loadingProgress) {
                                                                      if (loadingProgress ==
                                                                          null) {
                                                                        return child;
                                                                      }
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
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              41.0,
                                                                          height:
                                                                              41.0,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                )),
                                                          );
                                                        }),
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            taskStatusWidgets(
                                                taskStatus, "", "")
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
                ),
              ),
            )
          ],
        ),
        nextTaskButton()
      ],
    );
  }

  //<----- for get second task data after submit task

  // for get second task data after submit task----->>>>
  Widget taskTwoRejectWidgets(List<String> images) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                  clipper: OvalClipper(),
                  child: Container(
                    width: double.infinity,
                    // height: 242.0,
                    color: secondaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, (statusBarHeight + 15.0), 16.0, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _openMyPage(),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    2.0, 5.0, 7.0, 5.0),
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
                              height: 70.0,
                            ),
                          ]),
                    ),
                  )),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10.0),
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
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                // Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //       builder: (context) =>
                                                //           FullImageViewScreen(
                                                //             url: taskDetailsModel
                                                //                 .taskDetail![1]
                                                //                 .description!,
                                                //           )),
                                                // );
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
                                                      // width: 85.0,
                                                      height: 85.0,
                                                      child: Wrap(
                                                          spacing: 4.0,
                                                          children:
                                                              List.generate(
                                                                  images.length,
                                                                  (index) {
                                                            String url =
                                                                images[index];
                                                            return InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            FullImageViewScreen(
                                                                              url: url,
                                                                            )),
                                                                  );
                                                                },
                                                                child: SizedBox(
                                                                  height: 85.0,
                                                                  width: 85.0,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(12)),
                                                                    child: Image
                                                                        .network(
                                                                      url,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      loadingBuilder: (BuildContext context,
                                                                          Widget
                                                                              child,
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
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                41.0,
                                                                            height:
                                                                                41.0,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ));
                                                          }))),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            taskStatusWidgets(
                                                taskStatus, "", "")
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
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                // chooseImage();
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  // selectedImage == null
                                                  // ? DottedBorder(
                                                  //     dashPattern: const [
                                                  //       6,
                                                  //       4
                                                  //     ],
                                                  //     color: thirdColor,
                                                  //     borderType:
                                                  //         BorderType.RRect,
                                                  //     radius: const Radius
                                                  //         .circular(10),
                                                  //     padding:
                                                  //         const EdgeInsets
                                                  //             .all(1.0),
                                                  //     child: ClipRRect(
                                                  //       borderRadius:
                                                  //           const BorderRadius
                                                  //                   .all(
                                                  //               Radius
                                                  //                   .circular(
                                                  //                       12)),
                                                  //       child: SizedBox(
                                                  //         height: 85.0,
                                                  //         width: 85.0,
                                                  //         child: Center(
                                                  //           child:
                                                  //               Image.asset(
                                                  //             'assets/icons/plus.png',
                                                  //             width: 20.0,
                                                  //             height: 20.0,
                                                  //             fit: BoxFit
                                                  //                 .contain,
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //     ),
                                                  //   )
                                                  // : Container(
                                                  //     width: 85.0,
                                                  //     height: 85.0,
                                                  //     decoration: BoxDecoration(
                                                  //         shape: BoxShape
                                                  //             .rectangle,
                                                  //         borderRadius:
                                                  //             BorderRadius
                                                  //                 .circular(
                                                  //                     12),
                                                  //         image: DecorationImage(
                                                  //             fit:
                                                  //                 BoxFit.fill,
                                                  //             image: FileImage(
                                                  //                 selectedImage!)))),

                                                  Visibility(
                                                    visible:
                                                        selectedImages.length !=
                                                            3,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // chooseImage();
                                                        chooseImageNew();
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(right: 10),
                                                        child: DottedBorder(
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
                                                                    .all(Radius
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
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 86,
                                                    child: Wrap(
                                                      spacing: 4.0,
                                                      children: List.generate(
                                                          selectedImages.length,
                                                          (index) {
                                                        File asset =
                                                            selectedImages[
                                                                index];
                                                        return Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Container(
                                                                width: 86,
                                                                height: 86,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.5),
                                                                      blurRadius:
                                                                          4.0,
                                                                      spreadRadius:
                                                                          2.0,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              0),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    child:
                                                                        // AssetThumb(
                                                                        //   asset: asset,
                                                                        //   width: 90,
                                                                        //   height: 100,
                                                                        // ),
                                                                        Image.file(
                                                                      asset,
                                                                      width: 90,
                                                                      height:
                                                                          100,
                                                                    )),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  removeImage(
                                                                      index);
                                                                },
                                                                child:
                                                                    Container(
                                                                  // margin: const EdgeInsets.all(3),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius: const BorderRadius
                                                                        .only(
                                                                        topRight:
                                                                            Radius.circular(
                                                                                5),
                                                                        bottomLeft:
                                                                            Radius.circular(8)),
                                                                    color:
                                                                        primaryColor,
                                                                    border: Border.all(
                                                                        color:
                                                                            primaryColor,
                                                                        width:
                                                                            1.5),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons.clear,
                                                                    size: 15,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 18,
                                            ),
                                            showProgress
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
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
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                        height: 50,
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
                                                              strokeWidth: 4,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                            ),
                                                            Center(
                                                                child:
                                                                    buildProgress()),
                                                          ],
                                                        ),
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
                ),
              ),
            )
          ],
        ),
        isApiCalled || showProgress
            ? Positioned(
                bottom: 10.0,
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
                bottom: 10.0,
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
                                  if (selectedImages.isEmpty) {
                                    Fluttertoast.showToast(
                                        msg: "Please select a image");
                                  } else {
                                    // uploadData(selectedImage!, imageName);
                                    uploadDataMultipleImage(selectedImages);
                                    //  saveTaskDetails(selectedImage!, imageName);
                                  }
                                },
                              )
                            : const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  //<----- for get second task data after submit task

  // for update third task data first time ----->>>>
  Widget taskThreeUpdateWidget() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                    width: double.infinity,
                    // height: 242.0,
                    color: secondaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, (statusBarHeight + 15.0), 16.0, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _openMyPage(),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    2.0, 5.0, 7.0, 5.0),
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
                              "Task 3: ${widget.taskData.taskName}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 70.0,
                            ),
                          ]),
                    )),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  taskDetailsModel.draft_upload_type == "1"
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black12),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              8.0))),
                                              child: TextFormField(
                                                controller: textController,
                                                maxLines: 6,
                                                decoration:
                                                    const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            "Write from here.."),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30.0,
                                            ),
                                            const Text(
                                              " Tab a star to give your rating.",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(
                                              height: 5.0,
                                            ),
                                            Transform(
                                              transform:
                                                  Matrix4.translationValues(
                                                      -5, 0, 0),
                                              child: RatingBar.builder(
                                                initialRating: 0,
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: false,
                                                itemCount: 5,
                                                itemPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  var ratingInt =
                                                      rating.toInt();

                                                  ratingNumber =
                                                      ratingInt.toString();
                                                  print(
                                                      "Rating number => $ratingNumber");
                                                },
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
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        pickNoLimitVideo();
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          _video == null
                                                              ? DottedBorder(
                                                                  dashPattern: const [
                                                                    6,
                                                                    4
                                                                  ],
                                                                  color:
                                                                      thirdColor,
                                                                  borderType:
                                                                      BorderType
                                                                          .RRect,
                                                                  radius: const Radius
                                                                      .circular(
                                                                      10),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(12)),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          85.0,
                                                                      width:
                                                                          85.0,
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/plus.png',
                                                                          width:
                                                                              20.0,
                                                                          height:
                                                                              20.0,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : thumbnailFile !=
                                                                      null
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () {
                                                                        pickNoLimitVideo();
                                                                        /*Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  VideoPlayFileScreen(
                                                                                    file: _video!,
                                                                                  )),
                                                                        );*/
                                                                      },
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius: const BorderRadius
                                                                            .all(
                                                                            Radius.circular(12)),
                                                                        child:
                                                                            Stack(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          children: [
                                                                            Image.file(
                                                                              File(thumbnailFile!),
                                                                              height: 85,
                                                                              width: 85,
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                            Icon(
                                                                                color: Colors.grey,
                                                                                Icons.play_circle_fill),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Shimmer
                                                                      .fromColors(
                                                                      baseColor: const Color
                                                                          .fromRGBO(
                                                                          191,
                                                                          191,
                                                                          191,
                                                                          0.5254901960784314),
                                                                      highlightColor:
                                                                          Colors
                                                                              .white,
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            85.0,
                                                                        height:
                                                                            85.0,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 18,
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
                                                                  fit: StackFit
                                                                      .expand,
                                                                  children: [
                                                                    CircularProgressIndicator(
                                                                      value: (percentProgress /
                                                                              100)
                                                                          .toDouble(),
                                                                      valueColor:
                                                                          const AlwaysStoppedAnimation(
                                                                              primaryColor),
                                                                      strokeWidth:
                                                                          5,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .grey,
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
                                                                    fontSize:
                                                                        16.0,
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
                                ],
                              ),
                            )),
                ),
              ),
            )
          ],
        ),
        previousType == "0" || showProgress
            ? Positioned(
                bottom: 10.0,
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
                          onPressed: () {
                            print(
                                "ejfndlgjhfd===> $previousType || $showProgress");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Positioned(
                bottom: 10.0,
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
                                  if (taskDetailsModel.draft_upload_type ==
                                      "1") {
                                    if (textController.text.trim().isEmpty) {
                                      Fluttertoast.showToast(
                                          msg: "Please Write Something..");
                                    } else if (textController.text
                                        .trim()
                                        .contains(RegExp(emojiRegex))) {
                                      Fluttertoast.showToast(
                                          msg: "Emojis not acceptable.");
                                    } else if (ratingNumber == "0") {
                                      Fluttertoast.showToast(
                                          msg: "Please select a rating star.");
                                    } else {
                                      uploadText(textController.text.trim(),
                                          ratingNumber);
                                      //  saveTaskDetails(selectedImage!, imageName);
                                    }
                                  } else {
                                    if (_video == null) {
                                      Fluttertoast.showToast(
                                          msg: "Please select a video");
                                    } else {
                                      uploadVideoText(
                                          _video!,
                                          textController.text.trim(),
                                          videoName);
                                      //  saveTaskDetails(selectedImage!, imageName);
                                    }
                                  }
                                },
                              )
                            : const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  //<----- for third first task data first time

  // for get third task data after submit task----->>>>
  Widget taskThreeGetWidget(status, taskRejectType) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                    width: double.infinity,
                    // height: 242.0,
                    color: secondaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, (statusBarHeight + 15.0), 16.0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => _openMyPage(),
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
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
                            "Task 3: ${widget.taskData.taskName}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 70.0,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  taskDetailsModel.draft_upload_type == "1"
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5.0),
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
                                                        .taskDetail![1]
                                                        .description!,
                                                    style: const TextStyle(
                                                        color: secondaryColor,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            if ((taskStatus == "2" && taskRejectType == "7") || (taskStatus == "2" && taskRejectType=="2"))
                                              InkWell(
                                                onTap: () {
                                                  FlutterClipboard.copy(
                                                          taskDetailsModel
                                                              .taskDetail![1]
                                                              .description!
                                                              .toString())
                                                      .then((value) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Text copied: ${taskDetailsModel.taskDetail![1].description!.toString()}')),
                                                    );
                                                  });
                                                },
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            top: 3,
                                                            bottom: 3,
                                                            right: 10),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.blue,
                                                          width: 2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: const Text("Copy",
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            Transform(
                                              transform:
                                                  Matrix4.translationValues(
                                                      5, 0, 0),
                                              child: RatingBarIndicator(
                                                rating: double.parse(
                                                    taskDetailsModel
                                                        .taskDetail![1].ratings
                                                        .toString()),
                                                itemBuilder: (context, index) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                itemCount: 5,
                                                itemSize:
                                                    40, // Adjust the size of the star
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            if(status=="2" && taskRejectType!="7" && taskRejectType!="2")
                                              Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 10),
                                                  child: const Text(
                                                    "Thank You for your feedback, it is registered with us. You are now eligible to withdraw your campaign earnings",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
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
                                                Text(
                                                  taskDetailsModel
                                                      .taskDetail![1].title!,
                                                  style: const TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 19,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                InkWell(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      thumbnailUrl != null
                                                          ? InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              VideoPlayNetworkScreen(
                                                                                url: taskDetailsModel.taskDetail![1].description!,
                                                                              )),
                                                                );
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            12)),
                                                                child: Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Image.file(
                                                                      File(
                                                                          thumbnailUrl!),
                                                                      height:
                                                                          85,
                                                                      width: 85,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    ),
                                                                    const Icon(
                                                                        color: Colors
                                                                            .grey,
                                                                        Icons
                                                                            .play_circle_fill),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Shimmer.fromColors(
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
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 25,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        ),
                                  taskStatusWidgets(
                                      taskStatus, taskRejectType, "")
                                ],
                              ),
                            )),
                ),
              ),
            )
          ],
        ),
        nextTaskButton()
      ],
    );
  }

  //<----- for get third task data after submit task

  // for get third task data after submit task----->>>>
  Widget taskThreeRejectWidget(taskStatus, taskRejectType) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                    width: double.infinity,
                    // height: 242.0,
                    color: secondaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, (statusBarHeight + 15.0), 16.0, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _openMyPage(),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    2.0, 5.0, 7.0, 5.0),
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
                              "Task 3: ${widget.taskData.taskName}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 70.0,
                            ),
                          ]),
                    )),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  taskDetailsModel.draft_upload_type == "1"
                                      ? Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5.0),
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
                                                        .taskDetail![1]
                                                        .description!,
                                                    style: const TextStyle(
                                                        color: secondaryColor,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
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
                                                Text(
                                                  taskDetailsModel
                                                      .taskDetail![1].title!,
                                                  style: const TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 20.0,
                                                  height: 21.0,
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                InkWell(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      thumbnailUrl != null
                                                          ? InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              VideoPlayNetworkScreen(
                                                                                url: taskDetailsModel.taskDetail![1].description!,
                                                                              )),
                                                                );
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            12)),
                                                                child: Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Image.file(
                                                                      File(
                                                                          thumbnailUrl!),
                                                                      height:
                                                                          85,
                                                                      width: 85,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    ),
                                                                    const Icon(
                                                                        color: Colors
                                                                            .grey,
                                                                        Icons
                                                                            .play_circle_fill),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Shimmer.fromColors(
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
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 25,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                  if (taskStatus == "3" || taskStatus == "5"&&taskRejectType=="5")
                                    InkWell(
                                      onTap: () {
                                        FlutterClipboard.copy(taskDetailsModel
                                                .taskDetail![1].description!
                                                .toString())
                                            .then((value) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Text copied: ${taskDetailsModel.taskDetail![1].description!.toString()}')),
                                          );
                                        });
                                      },
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              top: 3,
                                              bottom: 3,
                                              right: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blue, width: 2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text("Copy",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  taskDetailsModel.draft_upload_type == "1"
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black12),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              8.0))),
                                              child: TextFormField(
                                                controller:
                                                    textRejectController,
                                                maxLines: 6,
                                                decoration:
                                                    const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            "Write from here.."),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            const Text(
                                              " Tab a star to give your rating.",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(
                                              height: 5.0,
                                            ),
                                            Transform(
                                              transform:
                                                  Matrix4.translationValues(
                                                      -5, 0, 0),
                                              child: RatingBar.builder(
                                                initialRating: 0,
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: false,
                                                itemCount: 5,
                                                itemPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  var ratingInt =
                                                      rating.toInt();

                                                  ratingNumber =
                                                      ratingInt.toString();
                                                  print(
                                                      "Rating number => ${ratingNumber}");
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                                                            pickNoLimitVideo();
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _video == null
                                                                  ? DottedBorder(
                                                                      dashPattern: const [
                                                                        6,
                                                                        4
                                                                      ],
                                                                      color:
                                                                          thirdColor,
                                                                      borderType:
                                                                          BorderType
                                                                              .RRect,
                                                                      radius: const Radius
                                                                          .circular(
                                                                          10),
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius: const BorderRadius
                                                                            .all(
                                                                            Radius.circular(12)),
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              85.0,
                                                                          width:
                                                                              85.0,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/icons/plus.png',
                                                                              width: 20.0,
                                                                              height: 20.0,
                                                                              fit: BoxFit.contain,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : thumbnailFile !=
                                                                          null
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            pickNoLimitVideo();
                                                                            /*Navigator
                                                                                .push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => VideoPlayFileScreen(
                                                                                        file: _video!,
                                                                                      )),
                                                                            );*/
                                                                          },
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                const BorderRadius.all(Radius.circular(12)),
                                                                            child:
                                                                                Stack(
                                                                              alignment: Alignment.center,
                                                                              children: [
                                                                                Image.file(
                                                                                  File(thumbnailFile!),
                                                                                  height: 85,
                                                                                  width: 85,
                                                                                  fit: BoxFit.fill,
                                                                                ),
                                                                                Icon(color: Colors.grey, Icons.play_circle_fill),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Shimmer
                                                                          .fromColors(
                                                                          baseColor: const Color
                                                                              .fromRGBO(
                                                                              191,
                                                                              191,
                                                                              191,
                                                                              0.5254901960784314),
                                                                          highlightColor:
                                                                              Colors.white,
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                85.0,
                                                                            height:
                                                                                85.0,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 18,
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
                                                                    child:
                                                                        Stack(
                                                                      fit: StackFit
                                                                          .expand,
                                                                      children: [
                                                                        CircularProgressIndicator(
                                                                          value:
                                                                              (percentProgress / 100).toDouble(),
                                                                          valueColor:
                                                                              const AlwaysStoppedAnimation(primaryColor),
                                                                          strokeWidth:
                                                                              5,
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
                                                                        fontSize:
                                                                            16.0,
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
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                          ],
                                        ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    child:
                                        taskStatusWidgets(taskStatus, "", ""),
                                  )
                                ],
                              ),
                            )),
                ),
              ),
            )
          ],
        ),
        isApiCalled || showProgress
            ? Positioned(
                bottom: 10.0,
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
                bottom: 10.0,
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
                                  if (taskDetailsModel.draft_upload_type ==
                                      "1") {
                                    if (textRejectController.text
                                        .trim()
                                        .isEmpty) {
                                      Fluttertoast.showToast(
                                          msg: "Please Write Something..");
                                    } else if (textRejectController.text
                                        .trim()
                                        .contains(RegExp(emojiRegex))) {
                                      Fluttertoast.showToast(
                                          msg: "Emojis not acceptable");
                                    } else if (ratingNumber == "0") {
                                      Fluttertoast.showToast(
                                          msg: "Please select a rating star.");
                                    } else {
                                      uploadText(
                                          textRejectController.text.trim(),
                                          ratingNumber);
                                      //  saveTaskDetails(selectedImage!, imageName);
                                    }
                                  } else {
                                    if (_video == null) {
                                      Fluttertoast.showToast(
                                          msg: "Please select a video");
                                    } else {
                                      uploadVideoText(
                                          _video!,
                                          textController.text.trim(),
                                          videoName);
                                      //  saveTaskDetails(selectedImage!, imageName);
                                    }
                                  }
                                },
                              )
                            : const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  //<----- for get third task data after submit task

  // for update Four task data first time ----->>>>
  Widget taskFourUpdateWidget() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                  width: double.infinity,
                  // height: 242.0,
                  color: secondaryColor,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        16.0, (statusBarHeight + 15.0), 16.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _openMyPage(),
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
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
                          "Task 4: ${widget.taskData.taskName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 70.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  taskDetailsModel.draft_upload_type == "2"
                                      ? Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5.0),
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
                                                Row(
                                                  children: [
                                                    Text(
                                                      taskDetailsModel
                                                          .taskDetail![1]
                                                          .title!,
                                                      style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    const SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Text(
                                                      "${taskDetailsModel.taskDetail![1].description!} seconds",
                                                      style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                                BorderType
                                                                    .RRect,
                                                            radius: const Radius
                                                                .circular(10),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1.0),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          12)),
                                                              child: SizedBox(
                                                                height: 85.0,
                                                                width: 85.0,
                                                                child: Center(
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/icons/plus.png',
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
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
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
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
                                        taskDetailsModel.taskDetail![3].title!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const LabelWidget(
                                          labelText: "", mandatory: true),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(0.0),
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black12),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8.0))),
                                    child: TextFormField(
                                      controller: textUrlController,
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Enter publish URL.."),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                ),
              ),
            )
          ],
        ),
        previousType == "0" || showProgress
            ? Positioned(
                bottom: 10.0,
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
                bottom: 10.0,
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
                                  if (textUrlController.text.trim().isEmpty) {
                                    Fluttertoast.showToast(
                                        msg: "Please enter URL..");
                                  } else if (textUrlController.text
                                      .trim()
                                      .contains(RegExp(emojiRegex))) {
                                    Fluttertoast.showToast(
                                        msg: "Emojis not acceptable");
                                  } else if (!hasValidUrl(
                                      textUrlController.text.trim())) {
                                    Fluttertoast.showToast(
                                        msg: "Please enter valid URL..");
                                  } else {
                                    if (selectedImage != null) {
                                      uploadImageWithUrl(
                                          selectedImage!,
                                          imageName,
                                          textUrlController.text.trim());
                                    } else {
                                      uploadText(textUrlController.text.trim(),
                                          ratingNumber);
                                    }
                                    //  saveTaskDetails(selectedImage!, imageName);
                                  }
                                },
                              )
                            : const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  //<----- for update Four task data first time

  // for get Four task data after submit task----->>>>
  Widget taskFourGetWidget() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                    width: double.infinity,
                    // height: 242.0,
                    color: secondaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, (statusBarHeight + 15.0), 16.0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => _openMyPage(),
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
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
                            "Task 4: ${widget.taskData.taskName}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  taskDetailsModel.draft_upload_type == "2"
                                      ? Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5.0),
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
                                                Row(
                                                  children: [
                                                    Text(
                                                      taskDetailsModel
                                                          .taskDetail![1]
                                                          .title!,
                                                      style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    const SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Text(
                                                      "${taskDetailsModel.taskDetail![1].description!} seconds",
                                                      style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  taskDetailsModel
                                              .taskDetail![2].description! ==
                                          ""
                                      ? const SizedBox()
                                      : Column(
                                          children: [
                                            Row(
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
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      taskDetailsModel
                                                          .taskDetail![2]
                                                          .title!,
                                                      style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w600),
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
                                                                  builder:
                                                                      (context) =>
                                                                          FullImageViewScreen(
                                                                            url:
                                                                                taskDetailsModel.taskDetail![2].description!,
                                                                          )),
                                                            );
                                                          },
                                                          child: isApiCalled
                                                              ? Shimmer
                                                                  .fromColors(
                                                                  baseColor: const Color
                                                                      .fromRGBO(
                                                                      191,
                                                                      191,
                                                                      191,
                                                                      0.5254901960784314),
                                                                  highlightColor:
                                                                      Colors
                                                                          .white,
                                                                  child:
                                                                      Container(
                                                                    width: 85.0,
                                                                    height:
                                                                        85.0,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                )
                                                              : SizedBox(
                                                                  width: 85.0,
                                                                  height: 85.0,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(12)),
                                                                    child: Image
                                                                        .network(
                                                                      taskDetailsModel
                                                                          .taskDetail![
                                                                              2]
                                                                          .description!,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      loadingBuilder: (BuildContext context,
                                                                          Widget
                                                                              child,
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
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                41.0,
                                                                            height:
                                                                                41.0,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  )),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        ),
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
                                        taskDetailsModel.taskDetail![3].title!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const LabelWidget(
                                          labelText: "", mandatory: true),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      browseInternet(taskDetailsModel
                                          .taskDetail![3].description!);
                                    },
                                    child: Text(
                                        taskDetailsModel
                                            .taskDetail![3].description!,
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 16)),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  taskStatusWidgets(taskStatus, "", "")

                                  /*Row(
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
                                    height: 40.0,
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
                                      Row(
                                        children: [
                                          Text(
                                            taskDetailsModel
                                                .taskDetail![1].title!,
                                            style: const TextStyle(
                                                color: secondaryColor,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            "${taskDetailsModel.taskDetail![1].description!} seconds",
                                            style: const TextStyle(
                                                color: secondaryColor,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40.0,
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
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    thumbnailUrl != null
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            VideoPlayNetworkScreen(
                                                                              url:
                                                                                  taskDetailsModel.taskDetail![2].description!,
                                                                            )),
                                                              );
                                                            },
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              12)),
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Image.file(
                                                                    File(
                                                                        thumbnailUrl!),
                                                                    height: 85,
                                                                    width: 85,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ),
                                                                  Icon(
                                                                      color: Colors
                                                                          .grey,
                                                                      Icons
                                                                          .play_circle_fill),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Shimmer.fromColors(
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
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 25,
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
                                  ),*/
                                ],
                              ),
                            )),
                ),
              ),
            )
          ],
        ),
        nextTaskButton()
      ],
    );
  }

  //<----- for get Four task data after submit task

  // for get Five task data after submit task----->>>>
  Widget taskFourRejectWidget() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                  width: double.infinity,
                  // height: 242.0,
                  color: secondaryColor,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        16.0, (statusBarHeight + 15.0), 16.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _openMyPage(),
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
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
                          "Task 5: ${widget.taskData.taskName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 70.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  taskDetailsModel.draft_upload_type == "2"
                                      ? Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5.0),
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
                                                Row(
                                                  children: [
                                                    Text(
                                                      taskDetailsModel
                                                          .taskDetail![1]
                                                          .title!,
                                                      style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    const SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Text(
                                                      "${taskDetailsModel.taskDetail![1].description!} seconds",
                                                      style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  taskDetailsModel
                                              .taskDetail![2].description! ==
                                          ""
                                      ? const SizedBox()
                                      : Column(
                                          children: [
                                            Row(
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
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      taskDetailsModel
                                                          .taskDetail![2]
                                                          .title!,
                                                      style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w600),
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
                                                                  builder:
                                                                      (context) =>
                                                                          FullImageViewScreen(
                                                                            url:
                                                                                taskDetailsModel.taskDetail![2].description!,
                                                                          )),
                                                            );
                                                          },
                                                          child: isApiCalled
                                                              ? Shimmer
                                                                  .fromColors(
                                                                  baseColor: const Color
                                                                      .fromRGBO(
                                                                      191,
                                                                      191,
                                                                      191,
                                                                      0.5254901960784314),
                                                                  highlightColor:
                                                                      Colors
                                                                          .white,
                                                                  child:
                                                                      Container(
                                                                    width: 85.0,
                                                                    height:
                                                                        85.0,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                )
                                                              : SizedBox(
                                                                  width: 85.0,
                                                                  height: 85.0,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(12)),
                                                                    child: Image
                                                                        .network(
                                                                      taskDetailsModel
                                                                          .taskDetail![
                                                                              2]
                                                                          .description!,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      loadingBuilder: (BuildContext context,
                                                                          Widget
                                                                              child,
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
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                41.0,
                                                                            height:
                                                                                41.0,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  )),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        ),
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
                                        taskDetailsModel.taskDetail![3].title!,
                                        style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const LabelWidget(
                                          labelText: "", mandatory: true),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      browseInternet(taskDetailsModel
                                          .taskDetail![3].description!);
                                    },
                                    child: Text(
                                        taskDetailsModel
                                            .taskDetail![3].description!,
                                        style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 16)),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                                BorderType
                                                                    .RRect,
                                                            radius: const Radius
                                                                .circular(10),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1.0),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          12)),
                                                              child: SizedBox(
                                                                height: 85.0,
                                                                width: 85.0,
                                                                child: Center(
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/icons/plus.png',
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
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
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(0.0),
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black12),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8.0))),
                                    child: TextFormField(
                                      controller: textUrlRejectController,
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Enter publish URL.."),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  taskStatusWidgets(taskStatus, "", ""),

                                  /*Row(
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
                                    height: 40.0,
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
                                      Row(
                                        children: [
                                          Text(
                                            taskDetailsModel
                                                .taskDetail![1].title!,
                                            style: const TextStyle(
                                                color: secondaryColor,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            "${taskDetailsModel.taskDetail![1].description!} seconds",
                                            style: const TextStyle(
                                                color: secondaryColor,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40.0,
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
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    thumbnailUrl != null
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            VideoPlayNetworkScreen(
                                                                              url:
                                                                                  taskDetailsModel.taskDetail![2].description!,
                                                                            )),
                                                              );
                                                            },
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              12)),
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Image.file(
                                                                    File(
                                                                        thumbnailUrl!),
                                                                    height: 85,
                                                                    width: 85,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ),
                                                                  Icon(
                                                                      color: Colors
                                                                          .grey,
                                                                      Icons
                                                                          .play_circle_fill),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Shimmer.fromColors(
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
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 25,
                                              ),
                                              taskStatusWidgets(taskStatus),
                                            ],
                                          ),
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
                                      Container(
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
                                                  pickVideo(int.parse(
                                                      taskDetailsModel
                                                          .taskDetail![1]
                                                          .description!));
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    _video == null
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
                                                        : thumbnailFile != null
                                                            ? InkWell(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                VideoPlayFileScreen(
                                                                                  file: _video!,
                                                                                )),
                                                                  );
                                                                },
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              12)),
                                                                  child: Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: [
                                                                      Image.file(
                                                                        File(
                                                                            thumbnailFile!),
                                                                        height:
                                                                            85,
                                                                        width: 85,
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      ),
                                                                      Icon(
                                                                          color: Colors
                                                                              .grey,
                                                                          Icons
                                                                              .play_circle_fill),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : Shimmer.fromColors(
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
                                                                  color:
                                                                      Colors.grey,
                                                                ),
                                                              ),
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
                                  ),*/
                                ],
                              ),
                            )),
                ),
              ),
            )
          ],
        ),
        isApiCalled || showProgress
            ? Positioned(
                bottom: 10.0,
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
                bottom: 10.0,
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
                                  if (textUrlRejectController.text
                                      .trim()
                                      .isEmpty) {
                                    Fluttertoast.showToast(
                                        msg: "Please enter URL..");
                                  } else if (textUrlRejectController.text
                                      .trim()
                                      .contains(RegExp(emojiRegex))) {
                                    Fluttertoast.showToast(
                                        msg: "Emojis not acceptable");
                                  } else if (!hasValidUrl(
                                      textUrlRejectController.text.trim())) {
                                    Fluttertoast.showToast(
                                        msg: "Please enter valid URL..");
                                  } else {
                                    if (selectedImage != null) {
                                      uploadImageWithUrl(
                                          selectedImage!,
                                          imageName,
                                          textUrlRejectController.text.trim());
                                    } else {
                                      uploadText(
                                          textUrlRejectController.text.trim(),
                                          ratingNumber);
                                    }
                                    //  saveTaskDetails(selectedImage!, imageName);
                                  }
                                },
                              )
                            : const SpinKitLoader(),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  //<----- for get Five task data after submit task

  Widget elseWidgets() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                    width: double.infinity,
                    // height: 242.0,
                    color: secondaryColor,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, (statusBarHeight + 15.0), 16.0, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _openMyPage(),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    2.0, 5.0, 7.0, 5.0),
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
                              height: 70.0,
                            ),
                          ]),
                    )),
              ),
            ),
            Flexible(
              child: Transform(
                transform: Matrix4.translationValues(0, -55, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, (0.0), 16.0, 0),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10.0),
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
                ),
              ),
            )
          ],
        ),
        Positioned(
          bottom: 10.0,
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
    print("kxajbjbsdhj===> ");

    if (taskStatus == "1") {
      if (widget.isLastIndex) {
        return Positioned(
          bottom: 10.0,
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
          bottom: 10.0,
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
          bottom: 10.0,
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
                          buttonText: "GO TO HOME",
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                settings: const RouteSettings(name: '/main'),
                                builder: (context) => MainScreen(index: 1),
                              ),
                            );
                          },
                        )
                      : const SpinKitLoader(),
                ),
              ],
            ),
          ),
        );
      } else {
        // for go back to task list to view other  task
        return Positioned(
          bottom: 10.0,
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
                          buttonText: "NEXT TASK",
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      : const SpinKitLoader(),
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

  Widget taskStatusWidgets(String status, rejectType, taskType) {
    print("sidzxcaskmcksjhdmsdb===> $status");
    print("sidzxcaskmcksjhdmsdb===> $rejectType");
    print("sidzxcaskmcksjhdmsdb===> ${taskDetailsModel.rejectType}");

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
                builder: (BuildContext context) => showRejectCampaignDialog(
                    taskDetailsModel.remarkMsg.toString(),
                    taskDetailsModel.resubmitreason.toString(),
                    status),
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
                    width: 35.0,
                    height: 35.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          );
        } else {
          return InkWell(
            onTap: () {
              print("${taskDetailsModel.remarkMsg}==> ${taskDetailsModel.resubmitreason.toString()}==>$status");
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => showRejectCampaignDialog(
                    taskDetailsModel.remarkMsg.toString(),
                    taskDetailsModel.resubmitreason.toString(),
                    status),
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
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Image.asset(
                    "assets/icons/info.png",
                    width: 20.0,
                    height: 20.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          );
        }
      case "5":
        if (taskDetailsModel.rejectType == 1) {
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => showRejectCampaignDialog(
                    taskDetailsModel.remarkMsg!,
                    taskDetailsModel.resubmitreason!,
                    status),
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
                    "assets/icons/pending.png",
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
                        color: pdDarkColor,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Image.asset(
                    "assets/icons/info.png",
                    width: 35.0,
                    height: 35.0,
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
                builder: (BuildContext context) => showRejectCampaignDialog(
                    taskDetailsModel.remarkMsg!,
                    taskDetailsModel.resubmitreason.toString(),
                    status),
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
                    "assets/icons/ongoing.png",
                    width: 20.0,
                    height: 20.0,
                    fit: BoxFit.contain,
                    color: pdDarkColor,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  const Text(
                    "Resubmission",
                    style: TextStyle(
                        color: pdDarkColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Image.asset(
                    "assets/icons/info.png",
                    width: 25.0,
                    height: 25.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          );
        }

      case "6":
        if (rejectType == "2") {
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
        } else {
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
        }

      case "7":
        if (taskDetailsModel.rejectType == 1) {
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => showRejectCampaignDialog(
                    taskDetailsModel.remarkMsg.toString(),
                    taskDetailsModel.resubmitreason.toString(),
                    status),
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
                    width: 35.0,
                    height: 35.0,
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
                builder: (BuildContext context) => showRejectCampaignDialog(
                    taskDetailsModel.remarkMsg!,
                    taskDetailsModel.resubmitreason!,
                    status),
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
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Image.asset(
                    "assets/icons/info.png",
                    width: 20.0,
                    height: 20.0,
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

  Widget showRejectCampaignDialog(
      String remarkMsg, String remarkMsgNew, status) {

    List<String> lines = remarkMsgNew.split('<br/>');

    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      child: CustomDialog(
        Child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 18.0, 10.0, 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status != '5')
                    Column(
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
                      ],
                    ),
                  if (status == '5')
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          (remarkMsgNew.toString() != "")
                              ? const Text(
                                  "Resubmission Reason:",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700),
                                )
                              : Container(),
                          const SizedBox(
                            height: 8.0,
                          ),

                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: lines.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0,bottom: 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // (lines[index].isNotEmpty)?const Text(
                                    //   "\u2022 ", // Bullet character
                                    //   style: TextStyle(
                                    //     color: Colors.black, // Change the color as needed
                                    //     fontSize: 20.0,
                                    //     fontWeight: FontWeight.w500,
                                    //   ),
                                    // ):Container(),
                                    Flexible(
                                      child: Text(
                                        lines[index],
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Colors.black, // Change the color as needed
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Htm(
                          //   (remarkMsgNew.toString() != "") ? remarkMsgNew : "",
                          //   textAlign: TextAlign.start,
                          //   // style: const TextStyle(
                          //   //     color: secondaryColor,
                          //   //     fontSize: 16.0,
                          //   //     fontWeight: FontWeight.w500),
                          // ),

                          // Text(
                          //   (remarkMsgNew.toString() != "") ? remarkMsgNew : "",
                          //   textAlign: TextAlign.start,
                          //   style: const TextStyle(
                          //       color: secondaryColor,
                          //       fontSize: 16.0,
                          //       fontWeight: FontWeight.w500),
                          // ),
                        ]),
                  const SizedBox(
                    height: 5.0,
                  ),
                  (!buttonLoaderStatus)
                      ? ButtonWidget(
                          buttonText: "Try Again",
                          onPressed: () {
                            // print("jhsadzkjxkjns==> $remarkMsgNew");
                            Navigator.of(context).pop();
                          })
                      : const SpinKitLoader(),
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
        size: 30,
      );
    } else {
      return Text(
        "${percentProgress.toString()}%",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: secondaryColor,
          fontSize: 17,
        ),
      );
    }
  }

  Widget showSocialIcon() {
    if (taskDetailsModel.social_icon_type == "1") {
      return Image.asset(
        "assets/images/facebook.png",
        width: 20,
        height: 20,
      );
    } else if (taskDetailsModel.social_icon_type == "2") {
      return Image.asset(
        "assets/images/instagram.png",
        width: 20,
        height: 20,
      );
    }
    if (taskDetailsModel.social_icon_type == "3") {
      return Image.asset(
        "assets/images/twitter.png",
        width: 20,
        height: 20,
      );
    }
    if (taskDetailsModel.social_icon_type == "4") {
      return Image.asset(
        "assets/images/youtube.png",
        width: 20,
        height: 20,
      );
    }
    if (taskDetailsModel.social_icon_type == "5") {
      return Image.asset(
        "assets/images/pinterest.png",
        width: 20,
        height: 20,
      );
    } else {
      return Image.asset(
        "assets/images/linkedin.png",
        width: 20,
        height: 20,
      );
    }
  }

  bool hasValidUrl(String value) {
    String pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (regExp.hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }
}
