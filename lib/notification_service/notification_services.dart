import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notification_app/message_screen.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void notificationRequestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print("user granted permission");
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print("ios permission");
      }
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
      if (kDebugMode) {
        print("user denied permission");
      }
    }
  }

  // Initialize local notification
  void initLocalNotification(
      BuildContext context, RemoteMessage remoteMessage) async {
    //if you want to add your icon in @mipmap then firstly add your icon inside drawable folder and write @drawable/ic_launcher

    var androidInitializationSettings = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // For iOS initialization
    var iOSInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iOSInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (paylod) {
      handleMessage(context, remoteMessage);
    });
  }

  // When app is active/foreground/open
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen(
      (message) {
        if (kDebugMode) {
          print(
              "----- title message is ${message.notification!.title.toString()}");
          print(
              "----- body message is ${message.notification!.body.toString()}");
          print("------ body data key value ------ ${message.data.toString()}");
          print("------ body data1 ------ ${message.data['type']}");
          print("------ body data2 ------ ${message.data['id']}");
        }
        if (Platform.isIOS) {
          forgroundMessage();
        }

        if (Platform.isAndroid) {
          initLocalNotification(context, message);
          showNotification(message);
        }
      },
    );
  }

  Future<void> showNotification(RemoteMessage remoteMessage) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      "high_importance_channel",
      //Random.secure().nextInt(100000).toString(),
      'High Importance Notifications',
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription:
                "This channel is used for important notification",
            importance: Importance.high,
            priority: Priority.high,
            //channelShowBadge: true,
            playSound: true,
            ticker: 'ticker');

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          1,
          remoteMessage.notification!.title,
          remoteMessage.notification!.body,
          notificationDetails);
    });
  }

  // Device Token
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  // To refresh device token after expiry
  void refreshDeviceToken() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print("refresh");
      }
    });
  }

  // When app is in background
  Future<void> setupInteractMessage(BuildContext context) async {
    // When app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // ignore: use_build_context_synchronously
      handleMessage(context, initialMessage);
    }

    // When app is in backgrond
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }
  // To handle page navigation while getting notifications

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data.isNotEmpty) {
      if (message.data['type'] == 'msg') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageScreen(
                      id: message.data['id'] ?? "",
                    )));
      }
    }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
