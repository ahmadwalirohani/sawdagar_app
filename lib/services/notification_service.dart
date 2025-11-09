import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../constants/constants.dart';
import '../models/notification.dart';
import '../utils/next_screen.dart';
import '../utils/notification_dialog.dart';

class NotificationService {
  Future _handleIosNotificationPermissaion() async {}

  Future initFirebasePushNotification(context) async {}

  Future deleteNotificationData(key) async {
    final notificationList = Hive.box(Constants.notificationTag);
    await notificationList.delete(key);
  }

  Future deleteAllNotificationData() async {
    final notificationList = Hive.box(Constants.notificationTag);
    await notificationList.clear();
  }

  Future<bool?> checkingPermisson() async {
    bool? accepted;

    return accepted;
  }

  Future subscribe() async {}

  Future unsubscribe() async {}
}
