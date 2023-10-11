import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:revuer/provider_helper/campaign_provider.dart';
import 'package:revuer/shared_preference/preference_provider.dart';
import 'package:revuer/ui/campaign/campaign-details.dart';
import 'package:revuer/ui/campaign/my-campaign-details.dart';
import 'package:revuer/ui/earnings/my-earnings.dart';
import 'package:revuer/ui/main/main.dart';
import 'package:revuer/ui/splash/splash_screen.dart';
import 'routes/routes.dart';
import '../../res/app_theme.dart';
import '../../res/constants.dart';
import '../../res/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    // navigation bar color
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    //status bar brigtness
    statusBarIconBrightness: Brightness.light,
    //status barIcon Brightness
    systemNavigationBarDividerColor: Colors.transparent,
    //Navigation bar divider color
    systemNavigationBarIconBrightness: Brightness.light, //navigation bar icon
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  customError();
  return runZonedGuarded(() async {
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => CampTrendingProvider()),
      ChangeNotifierProvider(create: (_) => CampRecentListProvider()),
      ChangeNotifierProvider(create: (_) => CampAllListProvider()),
      ChangeNotifierProvider(create: (_) => CampaignDetailsProvider()),
    ], child: const MyApp()));
  }, (error, stack) {
    if (kDebugMode) {
      print(stack);
    }
    if (kDebugMode) {
      print(error);
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  var clickType = "";
  var requestType = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    registerAnalytics();
  }

  Future<void> registerAnalytics() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await FirebaseAnalytics.instance
        .setDefaultEventParameters({"version": packageInfo.version});
    await FirebaseAnalytics.instance
        .setCurrentScreen(screenName: 'Splash Screen');
  }

  Future<void> initPlatformState() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.setAppId(Strings.oneSignalAppId);
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      debugPrint('notify result: $result');
      var data = result.action?.actionId;
      var type = result.action?.type;
      var additionalData = result.notification.additionalData;
      debugPrint('notify data: $data');
      debugPrint('notify type: $type');
      debugPrint('notify additionalData: $additionalData');
      if (additionalData!["type"] == "1") {
        /* var revuerToken = additionalData["revuer_token"];
        SharedPrefProvider.setString(
            SharedPrefProvider.uniqueToken, "$revuerToken");*/
        var reqType = additionalData["request_type"];
        if (reqType == "1") {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScreen(),
            ),
          );
        }
      } else if (additionalData["type"] == "2") {
        var campToken = additionalData["token"];
        var brandToken = additionalData["brand_token"];
        var reqType = additionalData["request_type"];
        SharedPrefProvider.setString(
            SharedPrefProvider.campaignToken, "$campToken");
        SharedPrefProvider.setString(
            SharedPrefProvider.brandloginUniqueToken, "$brandToken");
        if (reqType == "1") {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MyCampaignDetailsScreen(
                location: "notify",
                index: 0,
              ),
            ),
          );
        } else if (reqType == "2") {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/campaign-task'),
              builder: (context) => CampaignDetailsScreen(
                location: "notify",
              ),
            ),
          );
        }
      } else if (additionalData["type"] == "3") {
        var campToken = additionalData["token"];
        var brandToken = additionalData["brand_token"];
        SharedPrefProvider.setString(
            SharedPrefProvider.campaignToken, "$campToken");
        SharedPrefProvider.setString(
            SharedPrefProvider.brandloginUniqueToken, "$brandToken");
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MyCampaignDetailsScreen(
              location: "notify",
              index: 1,
            ),
          ),
        );
      } else if (additionalData["type"] == "4") {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MyEarningsScreen(
              location: "notify",
            ),
          ),
        );
      } else if (additionalData["type"] == "5") {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MyEarningsScreen(
              location: "notify",
            ),
          ),
        );
      }
      setState(() {
        clickType = additionalData["type"];
        requestType = additionalData["request_type"];
      });
    });
    /*OneSignal.shared.setSubscriptionObserver((changes) async {
     final status = await OneSignal.shared.getDeviceState();
     if (status!.subscribed){
       final String? playerId = status.userId;
       SharedPrefProvider.setString(SharedPrefProvider.playerId, playerId!);
       debugPrint('Player ID: $playerId');
     }
   });*/
    /*OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      setState(() {});
    });*/
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    if (kDebugMode) {
      print("screen called main");
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      /*theme: ThemeData().copyWith(
        primaryColor: Colors.white,
        colorScheme: ThemeData().colorScheme.copyWith(primary: primaryColor),
      ),*/
      theme: lightTheme,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics), // <-- here
      ],
      navigatorKey: navigatorKey,
      title: Strings.appName,
      routes: Routes.routes,
      /*initialRoute: '/initial',*/
      home: showScreens(context),
    );
  }

  Widget? showScreens(BuildContext context) {
    if (clickType == "1") {
      if (requestType == "1") {
        return MainScreen();
      }
    } else if (clickType == "2") {
      if (requestType == "1") {
        return MyCampaignDetailsScreen(
          location: "notify",
          index: 0,
        );
      } else if (requestType == "2") {
        return CampaignDetailsScreen(
          location: "notify",
        );
      }
    } else if (clickType == "3") {
      return MyCampaignDetailsScreen(
        location: "notify",
        index: 1,
      );
    } else if (clickType == "4") {
      return MyEarningsScreen(
        location: "notify",
      );
    } else if (clickType == "5") {
      return MyEarningsScreen(
        location: "notify",
      );
    } else {
      return const SplashScreen();
    }
    return null;
  }
}

customError() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return ErrorWidgetsScreen(
      errorDetails: errorDetails,
    );
  };
}

class ErrorWidgetsScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorWidgetsScreen({Key? key, required this.errorDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(errorDetails.toString()),
            ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      Clipboard.setData(
                              ClipboardData(text: errorDetails.toString()))
                          .then((value) {
                        Fluttertoast.showToast(msg: "Copied to Clipboard");
                      });
                    },
                    child: const Text(
                      "Copy",
                      style: TextStyle(color: secondaryColor),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                    },
                    child: const Text(
                      "Restart",
                      style: TextStyle(color: secondaryColor),
                    ))
              ],
            ),
          ],
        ),
      )),
    );
  }
}
