import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _remindersChannel = AndroidNotificationChannel(
    'lifesync_reminders',
    'LifeSync Reminders',
    description: 'Nhắc nhở sự kiện và lịch',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const _budgetChannel = AndroidNotificationChannel(
    'lifesync_budget',
    'LifeSync Budget',
    description: 'Cảnh báo ngân sách',
    importance: Importance.high,
  );

  static const _billsChannel = AndroidNotificationChannel(
    'lifesync_bills',
    'LifeSync Bills',
    description: 'Nhắc hóa đơn định kỳ',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (_) {
      // fallback
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.createNotificationChannel(_remindersChannel);
      await android.createNotificationChannel(_budgetChannel);
      await android.createNotificationChannel(_billsChannel);
      await android.requestNotificationsPermission();
      // Exact alarms may need user grant on Android 12+
      try {
        await android.requestExactAlarmsPermission();
      } catch (_) {}
    }
    _initialized = true;
  }

  void _onResponse(NotificationResponse response) {
    // Handle snooze actions via payload
    final payload = response.payload;
    if (payload != null && payload.startsWith('snooze:')) {
      // Handled by app logic when opened
    }
  }

  Future<void> scheduleEventReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    bool sound = true,
    bool vibration = true,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _remindersChannel.id,
        _remindersChannel.name,
        channelDescription: _remindersChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: sound,
        enableVibration: vibration,
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction('snooze_10', 'Báo lại 10 phút'),
          const AndroidNotificationAction('snooze_30', 'Báo lại 30 phút'),
          const AndroidNotificationAction('snooze_60', 'Báo lại 1 giờ'),
        ],
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'event:$id',
    );
  }

  Future<void> scheduleBillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id + 100000, // offset to avoid collision
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _billsChannel.id,
          _billsChannel.name,
          channelDescription: _billsChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'bill:$id',
    );
  }

  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id + 200000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _budgetChannel.id,
          _budgetChannel.name,
          channelDescription: _budgetChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'budget:$id',
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Reschedule future notifications from DB — call on boot / app start.
  Future<void> rescheduleAllFromDatabase(
    List<({int id, String title, String body, DateTime at})> items,
  ) async {
    for (final item in items) {
      await scheduleEventReminder(
        id: item.id,
        title: item.title,
        body: item.body,
        scheduledAt: item.at,
      );
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Background handler stub — snooze can be processed when app wakes
  if (kDebugMode) {
    // ignore: avoid_print
    print('Background notification: ${response.payload}');
  }
}
