import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/helpers/db_helper.dart';
import '../data/id_counter.dart';

class NotificationApi {
  final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  Future _notificationDetails(int id) async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        id.toString(),
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
      ),
      iOS: const IOSNotificationDetails(),
    );
  }

  Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = IOSInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings,
        onSelectNotification: (payload) async {
      onNotifications.add(payload);
    });
  }

  Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(id, title, body, await _notificationDetails(0),
          payload: payload);

  Future showScheduledNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    required DateTime scheduledDate,
  }) async =>
      {
        _notifications.zonedSchedule(
            id,
            title,
            body,
            _scheduleDaily(
              Time(scheduledDate.hour, scheduledDate.minute,
                  scheduledDate.second),
            ),
            await _notificationDetails(0),
            payload: payload,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time),
        DBHelper.insert('regular_event', {
          'id': id,
          'name': title,
          'body': body,
          'time': scheduledDate.toString(),
        }),
        updateId(id + 1),
      };

  static tz.TZDateTime _scheduleDaily(Time time) {
    var now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute, time.second);
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

  void deleteNotification(int id) {
    _notifications.cancel(id);
  }
}
