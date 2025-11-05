import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // 앱 아이콘
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true
        );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // 알림 탭했을 때
      }
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showTimerEndNotification(int duration) async { // 세탁/건조 종료 알림
    final now = tz.TZDateTime.now(tz.local);
    final endTime = now.add(Duration(seconds: duration));
    print(endTime);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'laundry_timer_channel',
          '세탁 타이머 알림',
          channelDescription: '세탁 타이머 시작, 완료 알림',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false
          //sound: RawResourceAndroidNotificationSound('alert'),
        );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final minutes = (duration / 60).round();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      '세탁/건조 완료!',
      '세탁/건조가 완료되었습니다. 세탁물을 확인해주세요.',
      endTime,
      platformChannelSpecifics,
      matchDateTimeComponents: null,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  Future<void> cancelNotification() async { // 예약 취소
    await flutterLocalNotificationsPlugin.cancelAll();
    print('All scheduled notifications cancelled');
  }
}