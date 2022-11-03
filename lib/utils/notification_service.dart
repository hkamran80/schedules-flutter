import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_schedules_logo');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _selectNotification,
    );
  }

  void _selectNotification(String? payload) async {}

  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {}

  NotificationDetails _notificationDetails(
    String channelId,
    String channelName,
    String channelDescription,
    Importance? importance,
    Priority? priority,
    String? subtitle,
  ) {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance ?? Importance.defaultImportance,
      priority: priority ?? Priority.defaultPriority,
    );

    IOSNotificationDetails iosPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      threadIdentifier: channelId,
      subtitle: subtitle,
    );

    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );
  }

  Future<void> createNotification(
    int id,
    String title,
    String body,
    String channelId,
    String channelName,
    String channelDescription,
    Importance? importance,
    Priority? priority,
    String? subtitle,
  ) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(
        channelId,
        channelName,
        channelDescription,
        importance,
        priority,
        subtitle,
      ),
    );
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    String channelId,
    String channelName,
    String channelDescription,
    Importance? importance,
    Priority? priority,
    String? subtitle,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(
        scheduledDate.toUtc(),
        UTC,
      ),
      _notificationDetails(
        channelId,
        channelName,
        channelDescription,
        importance,
        priority,
        subtitle,
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );







    
  }
}
