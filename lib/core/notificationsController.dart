import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int? id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

class NotificationContoller {
  final callbackonapp;
  final callbackoffapp;
  NotificationContoller(this.callbackonapp, this.callbackoffapp) {
    initPushNotification(this.callbackonapp, this.callbackoffapp);
    _configureLocalTimeZone();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
  }

  /// Streams are created so that app can respond to notification-related events
  /// since the plugin is initialised in the `main` function

  initPushNotification(callbackonapp, callbackoffapp) async {
//push notification init

    await _configureLocalTimeZone();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    });
  }
  //end of push notification init
}
